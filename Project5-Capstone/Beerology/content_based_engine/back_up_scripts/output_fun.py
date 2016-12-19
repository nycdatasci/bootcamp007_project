def get_beer_keywords(beer_input, corpus_tfidf, beer_list, textDict):
    """
    get all the relevant words for beer_input.
    """
    input_beer_keywords = []

    for item in sorted(corpus_tfidf[beer_list.index(beer_input)], key = lambda x: -x[1])[:5]:
        print item
        print textDict[item[0]]
        input_beer_keywords.append(textDict[item[0]])
    return input_beer_keywords


def get_similar_beers(beer_input, beer_list, index, ntop=10):
    """
    get ntop beers similar to beer_input
    """

    # check if beer_input in the database
    try:
        beer_id = beer_list.index(beer_input)
        beer_name_inputted = 1
    except IndexError:
        beer_id = beer_input
        beer_name_inputted = 0

    recommended_beers = []

    # find the beer_input from similarity matrix
    for i, item in enumerate(index):
        print i
        if i == beer_id:
            beer_simMat = item

    # sort the beer input similarity matrix and get ntop beers
    for beer in sorted(enumerate(beer_simMat), key = lambda x: -x[1])[beer_name_inputted:][:ntop]:
        print beer
        recommended_beers.append(beer_list[beer[0]])
    return recommended_beers
