import pandas as pd
#import reverse_geocoder as rg
#from watson_developer_cloud import AlchemyLanguageV1
#from watson_developer_cloud.watson_developer_cloud_service import WatsonException
import re
import requests
import json
from requests.exceptions import ConnectionError
import time

API_KEY = '4d06ec18e733fb14ab895aeb6b5631b7f5655ef3'
URL_PATTERN = re.compile('http[s]?://(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\(\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+')


def import_data(file_path, api_key=None):
    data = pd.read_pickle(file_path).reset_index(drop=True)
    print(str(data.shape[0]) + ' tweets have been imported.')
    return data


def get_census(data, level='block'):
    pause = 10
    for idx in data.index:
        if level in data.columns and not pd.isnull(data.get_value(col=level, index=idx)):
            continue
        while True:
            try:
                print('Getting block {0}...'.format(idx)),
                block_number = censusData(*data.loc[idx, ['lat', 'lon']]).block()
                break
            except ConnectionError:
                print ConnectionError.message
                print('Retriving block {0} after {1} minutes...'.format(idx, pause))
                time.sleep(60*pause)
                pause += 5
                continue
        data.set_value(col=level, index=idx, value=block_number)
        print(block_number)
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



if __name__ == '__main__':

    pass