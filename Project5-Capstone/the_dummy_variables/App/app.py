from flask import Flask, request, redirect, g, render_template, jsonify
import json
import requests
import random
import base64
import urllib
import os
import pprint
import sys
import pandas as pd

GLOBAL = {
    'authorization_header': None,
    'avatar': None,
    'spotify_playlists_ids': [],
    'spotify_playlists_names': [],
    'tracklist': ['spotify:track:4XEvl1bOlgslzaoAswDIhd', 'spotify:track:2VGDntFPvgvqSiUf9ITEfW',
        'spotify:track:7y9hUAgvdzIJ5N9EVWhv9K','spotify:track:4IUgpL0CgSiloUOHzgd6Qe','spotify:track:0hc4STPqTy1rKPBzqO4E1C',
        'spotify:track:6QLp8WLQlkqSd9l5fEt36R','spotify:track:1NnUbdEvJigY0ARnoOgDrv','spotify:track:7rHeXPJmrbLO0XVObG2sxQ',
        'spotify:track:3AwQuK6FuzeAntfNLJPJNL','spotify:track:11eSOZQj0od3y6DQHGloSW','spotify:track:4EBisBBehGON4ESJsNZBsP',
        'spotify:track:0wtGX0STSRlx0klE2XC6BZ','spotify:track:0IDwsKEghAlHaX6JUWzJr7','spotify:track:6YF8iK4PDoaRmRFYzWmo7Y',
        'spotify:track:2vUrdHYVlmAKnMySapQ33a','spotify:track:25SQI7rcz4fcSJpQg5Ut8J'],
    'choice': ['energy']
    }

app = Flask(__name__)

#  Client Keys
CLIENT_ID = "35a534a9bf1c446c9d9b0c6acd7f9aac"
CLIENT_SECRET = "f26b4a6600de46419e98d45bc9b939fe"

# Spotify URLS
SPOTIFY_AUTH_URL = "https://accounts.spotify.com/authorize"
SPOTIFY_TOKEN_URL = "https://accounts.spotify.com/api/token"
SPOTIFY_API_BASE_URL = "https://api.spotify.com"
API_VERSION = "v1"
SPOTIFY_API_URL = "{}/{}".format(SPOTIFY_API_BASE_URL, API_VERSION)


# Server-side Parameters
CLIENT_SIDE_URL = "http://127.0.0.1"
PORT = 5000
REDIRECT_URI = "{}:{}/callback/q".format(CLIENT_SIDE_URL, PORT)
SCOPE = "playlist-modify-public playlist-modify-private playlist-read-private"
STATE = ""
SHOW_DIALOG_bool = True
SHOW_DIALOG_str = str(SHOW_DIALOG_bool).lower()


auth_query_parameters = {
    "response_type": "code",
    "redirect_uri": REDIRECT_URI,
    "scope": SCOPE,
    "client_id": CLIENT_ID
}

@app.route("/")
def index():
    # Auth Step 1: Authorization
    url_args = "&".join(["{}={}".format(key,urllib.quote(val)) for key,val in auth_query_parameters.iteritems()])
    auth_url = "{}/?{}".format(SPOTIFY_AUTH_URL, url_args)
    return redirect(auth_url)

@app.route("/callback/q")
def callback():
    # Auth Step 4: Requests refresh and access tokens
    auth_token = request.args['code']
    code_payload = {
        "grant_type": "authorization_code",
        "code": str(auth_token),
        "redirect_uri": REDIRECT_URI
    }
    base64encoded = base64.b64encode("{}:{}".format(CLIENT_ID, CLIENT_SECRET))
    headers = {"Authorization": "Basic {}".format(base64encoded)}
    post_request = requests.post(SPOTIFY_TOKEN_URL, data=code_payload, headers=headers)

    # Auth Step 5: Tokens are Returned to Application
    response_data = json.loads(post_request.text)
    access_token = response_data["access_token"]
    refresh_token = response_data["refresh_token"]
    token_type = response_data["token_type"]
    expires_in = response_data["expires_in"]

    # Auth Step 6: Use the access token to access Spotify API
    GLOBAL['authorization_header'] = {"Authorization":"Bearer {}".format(access_token)}

    # Get profile data
    user_profile_api_endpoint = "{}/me".format(SPOTIFY_API_URL)
    profile_response = requests.get(user_profile_api_endpoint, headers=GLOBAL['authorization_header'])
    profile_data = json.loads(profile_response.text)



    return redirect("/orpheus")

@app.route("/orpheus")
def orpheus():
    return render_template("index.html")

@app.route("/orpheus/player")
def player():
    playlist_api_endpoint = "https://api.spotify.com/v1/users/1217498016/playlists/3Fafmpj0dxo6SIF3w8wVNR/tracks"
    data = json.dumps({'uris': GLOBAL['tracklist']})
    playlists_songs = requests.put(playlist_api_endpoint, data, headers=GLOBAL['authorization_header'])
    return render_template("player.html")
# @app.route("/orpheus/putplaylist")
# def putplaylist():

#     playlist_api_endpoint = "https://api.spotify.com/v1/users/1217498016/playlists/3Fafmpj0dxo6SIF3w8wVNR/tracks"
#     playlists_songs = requests.get(playlist_api_endpoint, headers=GLOBAL['authorization_header'])
#     songlist = json.loads(playlists_songs.text)['items']
#     a= []
#     for i in range(0,len(songlist)):
#         a.append(str(songlist[i]['track']['uri']))
#     data = json.dumps({'uris': ['spotify:track:4XEvl1bOlgslzaoAswDIhd', 'spotify:track:2VGDntFPvgvqSiUf9ITEfW',
#         'spotify:track:7y9hUAgvdzIJ5N9EVWhv9K','spotify:track:4IUgpL0CgSiloUOHzgd6Qe','spotify:track:0hc4STPqTy1rKPBzqO4E1C',
#         'spotify:track:6QLp8WLQlkqSd9l5fEt36R','spotify:track:1NnUbdEvJigY0ARnoOgDrv','spotify:track:7rHeXPJmrbLO0XVObG2sxQ',
#         'spotify:track:3AwQuK6FuzeAntfNLJPJNL','spotify:track:11eSOZQj0od3y6DQHGloSW','spotify:track:4EBisBBehGON4ESJsNZBsP',
#         'spotify:track:0wtGX0STSRlx0klE2XC6BZ','spotify:track:0IDwsKEghAlHaX6JUWzJr7','spotify:track:6YF8iK4PDoaRmRFYzWmo7Y',
#         'spotify:track:2vUrdHYVlmAKnMySapQ33a','spotify:track:25SQI7rcz4fcSJpQg5Ut8J']})
#     playlists_songs = requests.put(playlist_api_endpoint, data, headers=GLOBAL['authorization_header'])

    # tracklist = ['spotify:track:4XEvl1bOlgslzaoAswDIhd', 'spotify:track:2VGDntFPvgvqSiUf9ITEfW',
    #     'spotify:track:7y9hUAgvdzIJ5N9EVWhv9K','spotify:track:4IUgpL0CgSiloUOHzgd6Qe','spotify:track:0hc4STPqTy1rKPBzqO4E1C',
    #     'spotify:track:6QLp8WLQlkqSd9l5fEt36R','spotify:track:1NnUbdEvJigY0ARnoOgDrv','spotify:track:7rHeXPJmrbLO0XVObG2sxQ',
    #     'spotify:track:3AwQuK6FuzeAntfNLJPJNL','spotify:track:11eSOZQj0od3y6DQHGloSW','spotify:track:4EBisBBehGON4ESJsNZBsP',
    #     'spotify:track:0wtGX0STSRlx0klE2XC6BZ','spotify:track:0IDwsKEghAlHaX6JUWzJr7','spotify:track:6YF8iK4PDoaRmRFYzWmo7Y',
    #     'spotify:track:2vUrdHYVlmAKnMySapQ33a','spotify:track:25SQI7rcz4fcSJpQg5Ut8J']
    # idlist = [x[14:] for x in GLOBAL['tracklist']]

    # attributes= {
    #     'uri':[],
    #     'energy':[],
    #     'liveness':[],
    #     'tempo':[],
    #     'key':[],
    #     'valence':[]
    # }


    # features = requests.get("https://api.spotify.com/v1/audio-features/?ids="+ ",".join(idlist) ,headers = GLOBAL['authorization_header'])    
    # featurelist = json.loads(features.text)['audio_features']
    # for i in range(0,len(featurelist)):
    #     attributes['uri'].append(str(featurelist[i]['uri']))
    #     attributes['energy'].append(str(featurelist[i]['energy']))
    #     attributes['liveness'].append(str(featurelist[i]['liveness']))
    #     attributes['tempo'].append(str(featurelist[i]['tempo']))
    #     attributes['key'].append(str(featurelist[i]['key']))
    #     attributes['valence'].append(str(featurelist[i]['valence']))

    # df_att = pd.DataFrame.from_dict(attributes)
    # b = df_att.sort('valence')


    # return render_template("sample.html", samplelist = list(b.uri))
@app.route("/orpheus/energy")
def energychoice():
    GLOBAL['choice'][0] = 'energy'
    return redirect("/orpheus")

@app.route("/orpheus/liveness")
def livenesschoice():
    GLOBAL['choice'][0] = 'liveness'
    return redirect("/orpheus")

@app.route("/orpheus/tempo")
def tempochoice():
    GLOBAL['choice'][0] = 'tempo'
    return redirect("/orpheus")

@app.route("/orpheus/valence")
def valencechoice():
    GLOBAL['choice'][0] = 'valence'
    return redirect("/orpheus")


@app.route("/orpheus/player/up")
def upfeatplay():
    idlist = [x[14:] for x in GLOBAL['tracklist']]

    attributes= {
        'uri':[],
        'energy':[],
        'liveness':[],
        'tempo':[],
        'key':[],
        'valence':[]
    }


    features = requests.get("https://api.spotify.com/v1/audio-features/?ids="+ ",".join(idlist) ,headers = GLOBAL['authorization_header'])    
    featurelist = json.loads(features.text)['audio_features']
    for i in range(0,len(featurelist)):
        attributes['uri'].append(str(featurelist[i]['uri']))
        attributes['energy'].append(str(featurelist[i]['energy']))
        attributes['liveness'].append(str(featurelist[i]['liveness']))
        attributes['tempo'].append(str(featurelist[i]['tempo']))
        attributes['key'].append(str(featurelist[i]['key']))
        attributes['valence'].append(str(featurelist[i]['valence']))

    df_att = pd.DataFrame.from_dict(attributes)
    b = df_att.sort_values(GLOBAL['choice'][0])
    data = json.dumps({'uris': list(b.uri)})
    playlist_api_endpoint = "https://api.spotify.com/v1/users/1217498016/playlists/3Fafmpj0dxo6SIF3w8wVNR/tracks"
    playlists_songs = requests.put(playlist_api_endpoint, data, headers=GLOBAL['authorization_header'])
    return render_template("player.html")

@app.route("/orpheus/player/down")
def downfeatplay():
    idlist = [x[14:] for x in GLOBAL['tracklist']]

    attributes= {
        'uri':[],
        'energy':[],
        'liveness':[],
        'tempo':[],
        'key':[],
        'valence':[]
    }


    features = requests.get("https://api.spotify.com/v1/audio-features/?ids="+ ",".join(idlist) ,headers = GLOBAL['authorization_header'])    
    featurelist = json.loads(features.text)['audio_features']
    for i in range(0,len(featurelist)):
        attributes['uri'].append(str(featurelist[i]['uri']))
        attributes['energy'].append(str(featurelist[i]['energy']))
        attributes['liveness'].append(str(featurelist[i]['liveness']))
        attributes['tempo'].append(str(featurelist[i]['tempo']))
        attributes['key'].append(str(featurelist[i]['key']))
        attributes['valence'].append(str(featurelist[i]['valence']))

    df_att = pd.DataFrame.from_dict(attributes)
    b = df_att.sort_values(GLOBAL['choice'][0], ascending = False)
    data = json.dumps({'uris': list(b.uri)})
    playlist_api_endpoint = "https://api.spotify.com/v1/users/1217498016/playlists/3Fafmpj0dxo6SIF3w8wVNR/tracks"
    playlists_songs = requests.put(playlist_api_endpoint, data, headers=GLOBAL['authorization_header'])   
    return render_template("player.html")

if __name__ == '__main__':
    app.run(debug=True)