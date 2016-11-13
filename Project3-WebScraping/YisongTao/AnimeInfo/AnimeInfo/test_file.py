import json
item = {'anime_aired': u'Dec 26, 2014 to Jun 24, 2016',
 'anime_background': u'No background information has been added to this title. Help improve our database by adding background information .',
 'anime_episodes': u'4',
 'anime_favorites': u'94',
 'anime_genres': [u'Fantasy', u'Hentai', u'Magic'],
 'anime_mainactors': [u'Tatsumi, Yuiko'],
 'anime_members': u'5,873',
 'anime_popularity': u'#3696',
 'anime_premiered': None,
 'anime_producers': [u'Pink Pineapple'],
 'anime_ranked': u'N/A',
 'anime_rating': u'Rx - Hentai',
 'anime_related': {u'Alternative version:': [u'Rance: Sabaku no Guardian']},
 'anime_score': u'7.59',
 'anime_status': u'Finished Airing',
 'anime_studios': [u'Seven'],
 'anime_synopsis': u'Anime adaptation of the 2013 remake of the 1989 AliceSoft adult PC game .  Rance follows the namesake hero who is tasked with finding and protecting the daughter of a guild owner; however, the case turns out to be much deeper than it initially appears to be.  (Source: MAL News)',
 'anime_title': u'Rance 01: Hikari wo Motomete The Animation',
 'anime_type': u'OVA'}

new_array = json.dumps(item)
print type(new_array)
print new_array