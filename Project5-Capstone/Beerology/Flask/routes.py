from flask import Flask, render_template, request, jsonify, url_for
from model.CB.content_based_recommendation import *
from model.CF.CF_predict import *
import json
import pickle
import numpy as np

app = Flask(__name__)


@app.route("/")
@app.route("/index.html")
def index():
    return render_template("index.html")

# @app.route("/viewbeers.html")
# def viewbeers():
#     return render_template("viewbeers.html")

@app.route("/content.html", methods=['GET', 'POST'])
def content():
    with open("./model/CB/beer_list.p", "rb") as bf:
        beer_list = pickle.load(bf)
    with open("./model/CB/index.p", "rb") as idxf:
        index = pickle.load(idxf)
    with open("./model/CB/beer_keywords.json", "rb") as bk:
        beer_keywords = json.load(bk)
    with open("./model/CB/dict_for_CB_table.p", "rb") as dfct:
        dict_for_CB_table = pickle.load(dfct)

    if request.method == "GET":
        return render_template("content.html", beerlist=beer_list)

    beer_inp = None
    if request.method == "POST" and "beer_inp" in request.form:
        beer_inp = request.form["beer_inp"]
        if beer_inp == '':
            return render_template("content.html", beerlist=beer_list)
        else:
            cb_rec = get_similar_beers(beer_inp, beer_list, index, ntop=10)
            print cb_rec
            table_list = map(lambda x: dict_for_CB_table.get(x), cb_rec)
            key_words = beer_keywords[beer_inp]
            # key_words = get_beer_keywords(beer_inp, corpus_tfidf, beer_list, textDict, ntop=10)
            key_words = map(lambda x: x.decode('utf-8', 'ignore').encode('ascii', 'ignore'), key_words)
            key_words = ', '.join(key_words)
            return render_template("content.html", beerlist=beer_list, cb_rec=cb_rec,
                                   table_list=table_list, key_words=key_words)

@app.route("/collab.html", methods=["GET", "POST"])
def collab():
    with open("./model/CF/beer_dict.pickle", "r") as bf:
        beer_dict = pickle.load(bf)
    beer_list = sorted(beer_dict.values())
    beer_list = [x.decode('ascii', 'ignore') for x in beer_list if '\x8a\x97\xc8' not in x] # we need to fix this later
    ratings_mat = np.load("./model/CF/ratings_svdpp.npy")
    ratings_mat, global_avg = CF_mat_preprocess(ratings_mat)

    if request.method == "POST":
        inp_tup = []
        for i in range(1, 11):
            beer_inp_key = "beer_inp" + str(i)
            rating_inp_key = "rating_inp" + str(i)
            if request.form[beer_inp_key] and request.form[rating_inp_key]:
                inp_tup.append((request.form[beer_inp_key], request.form[rating_inp_key]))
        # for i in range(1, 6):
        #     beer_inp_key = "beer_inp" + str(i)
        #     rating_inp_key = "rating_inp" + str(i)
        #     inp_tup.append((request.form[beer_inp_key], request.form[rating_inp_key]))


        # print inp_tup
        if inp_tup == []:
            return render_template("collab.html", beer_list=beer_list)
        else:
            user_data = CF_user_preprocess(inp_tup, ratings_mat, beer_dict)
            # print user_data
            cf_rec = CF_rec(user_data, ratings_mat, global_avg, beer_dict)
            # print cf_rec

            return render_template("collab.html", cf_rec=cf_rec, beer_list=beer_list)

    else:
        return render_template("collab.html", beer_list=beer_list)


@app.route('/autocomplete', methods=['GET'])
def autocomplete():
    search = request.args.get('q')
    #query = db_session.query(Movie.title).filter(Movie.title.like('%' + str(search) + '%'))
    #results = [mv[0] for mv in query.all()]
    results = ['Beer1', 'Wine1', 'Soda1', 'a', 'b']
    return jsonify(matching_results=results)

if __name__ == "__main__":
    app.run(debug=True)