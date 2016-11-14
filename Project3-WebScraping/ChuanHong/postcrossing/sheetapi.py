from __future__ import print_function
import sys
sys.path.append('./')
sys.path.append('/Users/shuyan/anaconda/lib/python2.7/site-packages')
import httplib2
import os

from apiclient import discovery
from oauth2client import client
from oauth2client import tools
from oauth2client.file import Storage

# try:
#     import argparse
#     flags = argparse.ArgumentParser(parents=[tools.argparser]).parse_args()
# except ImportError:
#     flags = None

# If modifying these scopes, delete your previously saved credentials
# at ~/.credentials/sheets.googleapis.com-python-quickstart.json
SCOPES = 'https://www.googleapis.com/auth/spreadsheets'
CLIENT_SECRET_FILE = 'client_secret.json'
APPLICATION_NAME = 'PostCrossing Sheets'


def get_credentials():
    """Gets valid user credentials from storage.

    If nothing has been stored, or if the stored credentials are invalid,
    the OAuth2 flow is completed to obtain the new credentials.

    Returns:
        Credentials, the obtained credential.
    """
    home_dir = os.path.expanduser('~')
    credential_dir = os.path.join(home_dir, '.credentials')
    if not os.path.exists(credential_dir):
        os.makedirs(credential_dir)
    credential_path = os.path.join(credential_dir,
                                   'sheets.googleapis.com-postcrossing.json')

    store = Storage(credential_path)
    credentials = store.get()
    # if not credentials or credentials.invalid:
    #     flow = client.flow_from_clientsecrets(CLIENT_SECRET_FILE, SCOPES)
    #     flow.user_agent = APPLICATION_NAME
    #     if flags:
    #         credentials = tools.run_flow(flow, store, flags)
    #     else: # Needed only for compatibility with Python 2.6
    #         credentials = tools.run(flow, store)
    #     print('Storing credentials to ' + credential_path)

    http = credentials.authorize(httplib2.Http())
    discoveryUrl = ('https://sheets.googleapis.com/$discovery/rest?'
                    'version=v4')
    service = discovery.build('sheets', 'v4', http=http,
                              discoveryServiceUrl=discoveryUrl)
    return service


class SheetWriter(object):

    def __init__(self, spreadsheetId, sheet):
        self.spreadsheetId = spreadsheetId
        self.sheet = sheet
        self.service = get_credentials()
        self.range = None
        self.row = 1
        self.values = list()

    def write(self, item):
        ## add table column names
        if self.range is None:
            self.range = ('A', chr(ord('A') + len(dict(item)) - 1))
            # rangeName = self.sheet + '!' + \
            #             self.range[0] + \
            #             str(self.row) + ':' + \
            #             self.range[1]
            # body = {
            #     'values': [dict(item).keys()]
            # }
            # self.service.spreadsheets().values().update(
            #     spreadsheetId=self.spreadsheetId, range=rangeName,
            #     valueInputOption='RAW', body=body).execute()
            # ## row increased by 1
            # self.row += 1
        ## append item to values
        if len(self.values) < 16:
            self.values.append(dict(item).values())
        ## write values to spreadsheet
        else:
            body = {
                'values': self.values
            }
            rangeName = self.sheet + '!' + \
                        self.range[0] + \
                        str(self.row) + ':' + \
                        self.range[1]
            self.service.spreadsheets().values().append(
                spreadsheetId=self.spreadsheetId, range=rangeName,
                valueInputOption='RAW', body=body).execute()
            ## row increased by the number of items
            self.row += len(self.values)
            self.values = list()


if __name__ == '__main__':
    pass