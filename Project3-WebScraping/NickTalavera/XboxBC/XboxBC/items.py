# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy
from scrapy.item import Item, Field


class UserVoiceItem(scrapy.Item):
    gameName = scrapy.Field()
    votes = scrapy.Field()
    comments = scrapy.Field()
    in_progress = scrapy.Field()

class WikipediaXB360ExclusiveItem(scrapy.Item):
    gameName = scrapy.Field()
    publisher = scrapy.Field()
    releaseDate = scrapy.Field()
    exclusiveType = scrapy.Field()

class RemastersItem(scrapy.Item):
    gameName = scrapy.Field()
class MetacriticXbox360Item(scrapy.Item):
    gameName = scrapy.Field()
    reviewScorePro = scrapy.Field()
    reviewScoreUser = scrapy.Field()

class WikipediaXB360KinectItem(scrapy.Item):
    gameName = scrapy.Field()
    publisher = scrapy.Field()
    releaseDate = scrapy.Field()
    kinectRequired = scrapy.Field()
    kinectSupport = scrapy.Field()

class MajorNelsonItem(scrapy.Item):
    gameName = scrapy.Field()
    BCCompatible = scrapy.Field()

class XboxOne_MS_Site_Item(scrapy.Item):
    gameName = scrapy.Field()
    # gamesOnDemandorArcade = scrapy.Field()
    gameUrl = scrapy.Field()
    developer = scrapy.Field()
    publisher = scrapy.Field()
    genre = scrapy.Field()
    highresboxart = scrapy.Field()
    features = scrapy.Field()
    onlineFeatures = scrapy.Field()
    price = scrapy.Field()
    priceGold = scrapy.Field()
    dayRecorded = scrapy.Field()
    releaseDate = scrapy.Field()
    # ESRBRating = scrapy.Field()
    xboxRating = scrapy.Field()
    # Number of Reviews = scrapy.Field()
    # smartglass = scrapy.Field()
    # Avatar Items = scrapy.Field()
    # demos = scrapy.Field()
    # Game Videos = scrapy.Field()
    # Game Addons = scrapy.Field()
    # themes = scrapy.Field()
    # Gamer Pictures = scrapy.Field()
    # Content Links = scrapy.Field()

class Xbox360_MS_Site_Item(scrapy.Item):
    gameName = scrapy.Field()
    gamesOnDemandorArcade = scrapy.Field()
    gameUrl = scrapy.Field()
    developer = scrapy.Field()
    publisher = scrapy.Field()
    genre = scrapy.Field()
    highresboxart = scrapy.Field()
    features = scrapy.Field()
    onlineFeatures = scrapy.Field()
    price = scrapy.Field()
    priceGold = scrapy.Field()
    gameCount = scrapy.Field()
    dayRecorded = scrapy.Field()
    releaseDate = scrapy.Field()
    ESRBRating = scrapy.Field()
    xbox360Rating = scrapy.Field()
    numberOfReviews = scrapy.Field()
    DLsmartglass = scrapy.Field()
    DLavatarItems = scrapy.Field()
    DLdemos = scrapy.Field()
    DLgameVideos = scrapy.Field()
    DLgameAddons = scrapy.Field()
    DLthemes = scrapy.Field()
    DLgamerPictures = scrapy.Field()

class MovieItem(scrapy.Item):
    movie_imdb_link = scrapy.Field()
    imdb_score = scrapy.Field()
    movie_title = scrapy.Field()
    title_year = scrapy.Field()
    num_voted_users = scrapy.Field()
    genres = scrapy.Field()
    budget = scrapy.Field()
    color = scrapy.Field()
    gross = scrapy.Field()
    duration = scrapy.Field()
    country = scrapy.Field()
    language = scrapy.Field()
    plot_keywords = scrapy.Field()
    storyline = scrapy.Field()
    aspect_ratio = scrapy.Field()
    content_rating = scrapy.Field()
    num_user_for_reviews = scrapy.Field()
    num_critic_for_reviews = scrapy.Field()
    cast_info = scrapy.Field()
    director_info = scrapy.Field()
    num_facebook_like = scrapy.Field()
    image_urls = scrapy.Field()
    images = scrapy.Field()

class PosterImageItem(scrapy.Item):
    image_urls = scrapy.Field()
    images = scrapy.Field()
