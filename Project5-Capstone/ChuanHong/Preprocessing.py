import pandas as pd
import reverse_geocoder as rg
from watson_developer_cloud import AlchemyLanguageV1
from watson_developer_cloud.watson_developer_cloud_service import WatsonException
import re
import requests
import json
from requests.exceptions import ConnectionError
import time

API_KEY = ''
URL_PATTERN = re.compile('http[s]?://(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\(\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+')


def import_data(file_path, api_key=None):
    data = pd.read_pickle(file_path).reset_index(drop=True)
    print(str(data.shape[0]) + ' tweets have been imported.')
    return data


def reverse_geocode(data, filter='US'):
    coordinates = tuple(tuple(x) for x in data[['lat', 'lon']].to_records(index=False))
    geo_info = pd.DataFrame(rg.search(coordinates)).rename(columns={'lat': 'city_lat', 'lon': 'city_lon'})
    data = pd.concat([data.reset_index(drop=True), geo_info.reset_index(drop=True)], axis=1)
    if filter:
        data = data.loc[data['cc'] == filter, :].drop(['cc'], axis=1).reset_index(drop=True)
    print(str(data.shape[0]) + ' tweets remaining.')
    return data


def taxonomy(api_key, data, index_range=None, search_key='text'):
    print('Checking AlchemyLanguage service...')
    alchemy_api = AlchemyLanguageV1(api_key=api_key)

    if index_range is None:
        index_range = data.index

    cate_column = 'in_category'
    for i in index_range:
        try:
            if cate_column in data.columns and not pd.isnull(data.get_value(col=cate_column, index=i)):
                continue
            taxonomy = __alchemy_search(alchemy_api, data.text.iloc[i], search_key=search_key)
            print taxonomy
            in_category = __has_category(taxonomy=taxonomy, category='food and drink', score=.05)
            print in_category
            data.set_value(col=cate_column, index=i, value=in_category)
        except WatsonException as e:
            print e.message
            return
    return data


def __alchemy_search(alchemy_api, content, search_key):
    if search_key == 'url':
        try:
            url = re.findall(URL_PATTERN, content)[0]
            taxonomy = alchemy_api.taxonomy(url=url)
            return taxonomy
        except IndexError:
            pass
    taxonomy = alchemy_api.taxonomy(text=content)
    return taxonomy


def __has_category(taxonomy, category, score=.5):
    for x in taxonomy['taxonomy']:
        if float(x['score']) > score and x['label'].find(category) > -1:
            return True
    return False


def get_census(data, level='block'):
    pause = 10
    for idx in data.index:
        if level in data.columns and not pd.isnull(data.get_value(col=level, index=idx)):
            continue
        while True:
            try:
                print('.'),
                if idx % 100 == 0:
                    print('\nGetting block {0}...'.format(idx)),
                    print(block_number)
                block_number = censusData(*data.loc[idx, ['lat', 'lon']]).block()
                break
            except ConnectionError:
                print ConnectionError.message
                print('Retriving block {0} after {1} minutes...'.format(idx, pause))
                time.sleep(60*pause)
                pause += 5
                continue
        data.set_value(col=level, index=idx, value=block_number)
        if idx % 1000 == 0:
            data.to_pickle('./temp.pkl')
    print('Done!')
    return data


class censusData:
    def __init__(self, lat, lon, showall=True):
        url = 'http://data.fcc.gov/api/block/find?format=json'
        payload = {'latitude': lat, 'longitude': lon, 'showall': showall}
        self.r = requests.get(url, params=payload)
        self.y = self.r.json()

    def block(self):
        return str(self.y['Block']['FIPS'])

    def county(self):
        return str(self.y['County']['name'])

    def state(self):
        return str(self.y['State']['name'])

    def intersection(self):
        records = []
        for b in self.y['Block']['intersection']:
            record = filter(lambda x: x.isdigit(), str(b))
            records.append(record)
        return records

    def data(self):
        return json.dumps(self.y)


# class Preprocessing(object):
#
#     def __init__(self, file_path, api_key=None):
#         self.data = pd.read_pickle(file_path).iloc[6:9].reset_index(drop=True)
#         if api_key:
#             self.alchemy_api = AlchemyLanguageV1(api_key=API_KEY)
#         print(str(self.data.shape[0]) + ' tweets have been imported.')
#
#     def reverse_geocode(self, filter='US'):
#         coordinates = tuple(tuple(x) for x in self.data[['lat', 'lon']].to_records(index=False))
#         geoInfo = pd.DataFrame(rg.search(coordinates)).rename(columns={'lat': 'city_lat', 'lon': 'city_lon'})
#         self.data = pd.concat([self.data.reset_index(drop=True),
#                                geoInfo.reset_index(drop=True)], axis=1)
#         if filter:
#             self.data = self.data.loc[self.data['cc'] == 'US', :].drop(['cc'], axis=1)
#         print(str(self.data.shape[0]) + ' tweets remaining.')
#
#     def taxonomy(self, api_key=None, index_range=None, search_key='text'):
#         print('Checking AlchemyLanguage service...')
#         if api_key:
#             alchemy_api = AlchemyLanguageV1(api_key=API_KEY)
#         elif hasattr(self, 'alchemy_api'):
#             alchemy_api = self.alchemy_api
#         else:
#             print('No API KEY found, AlchemyLanguage service aborted.')
#             return
#         if index_range is None:
#             index_range = self.data.index
#
#         cate_column = 'in_category'
#         for i in index_range:
#             try:
#                 if cate_column in self.data.columns and not pd.isnull(self.data.get_value(col=cate_column, index=i)):
#                     continue
#                 taxonomy = Preprocessing.__alchemy_search(alchemy_api,
#                                                           self.data.text.iloc[i],
#                                                           search_key=search_key)
#                 print taxonomy
#                 in_category = Preprocessing.__has_category(taxonomy=taxonomy,
#                                                            category='food and drink',
#                                                            score=.05)
#                 print in_category
#                 self.data.set_value(col=cate_column, index=i,
#                                     value=in_category)
#             except WatsonException as e:
#                 print e.message()
#                 return
#         print self.data
#
#     @staticmethod
#     def __alchemy_search(alchemy_api, content, search_key):
#         if search_key == 'url':
#             try:
#                 url = re.findall(URL_PATTERN, content)[0]
#                 taxonomy = alchemy_api.taxonomy(url=url)
#                 return taxonomy
#             except IndexError:
#                 pass
#         taxonomy = alchemy_api.taxonomy(text=content)
#         return taxonomy
#
#     @staticmethod
#     def __has_category(taxonomy, category, score=.5):
#         for x in taxonomy['taxonomy']:
#             if float(x['score']) > score and x['label'].find(category) > -1:
#                 return True
#         return False



if __name__ == '__main__':

    tweets = import_data('./data/tweets.pkl')
    tweets = reverse_geocode(tweets)
    tweets = taxonomy(API_KEY, tweets)
    print tweets
    # prep.reverse_geocode()
