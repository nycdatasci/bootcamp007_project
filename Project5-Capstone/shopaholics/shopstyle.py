from urllib import urlencode
from urllib2 import urlopen, Request, HTTPError
from xml.dom.minidom import parseString

try: from simplejson import loads
except ImportError: from json import loads

class ShopStyle(object):
    __api = 'http://api.shopstyle.com/api/v2/%s?%s'
    __formats = ['json', 'xml']
    __sort = ['PriceLoHi', 'PriceHiLo', 'Recency', 'Popular', 'Favorite']
    __filters = ['Category', 'Brand', 'Retailer', 'Price',
                 'Discount', 'Size', 'Color']

    def __init__(self, api_key, format='json', site=None, debug=False):
        format = format if format in self.__formats else self.__formats[0]
        self.base_params = {'format': format, 'pid': api_key, 'site': site,
                            'suppressResponseCode': debug}

    def __request(self, method, params=None):
        if params is None: params = self.base_params
        else: params.update(self.base_params)

        params = dict((k, v) for k, v in params.iteritems() if v)

        url = self.__api % (method, urlencode(params, True))
        request = Request(url)

        try:
            response = urlopen(request).read()
        except HTTPError as e:
            raise ShopStyleException(e)

        if params['format'] == 'json':
            return loads(response)
        elif params['format'] == 'xml':
            return parseString(response)

    def search(self, fts=None, cat=None, fl=None, pdd=None,
               sort=None, offset=None, limit=None):
        sort = sort if sort in self.__sort else None

        params = {'fts': fts, 'cat': cat, 'fl': fl, 'pdd': pdd,
                  'sort': sort, 'offset': offset, 'limit': limit}

        return self.__request('products', params)

    def filter_histogram(self, fts=None, cat=None, fl=None, pdd=None,
                         sort=None, filters=None, floor=None):
        sort = sort if sort in self.__sort else None

        filters = [f for f in filters.split(",") if f in self.__filters]
        filters = ",".join(filters)

        params = {'fts': fts, 'cat': cat, 'fl': fl, 'pdd': pdd,
                  'sort': sort, 'filters': filters, 'floor': floor}

        return self.__request('products/histogram', params)

    def categories(self, cat=None, depth=None):
        return self.__request('categories', {'cat': cat, 'depth': depth})

    def product(self, id):
        return self.__request('products/%d' % id)

    def brands(self):
        return self.__request('brands')

    def retailers(self):
        return self.__request('retailers')

    def colors(self):
        return self.__request('colors')

class ShopStyleException(Exception):
    def __init__(self, message):
        self.message = str(message)

    def __str__(self):
        return self.message
