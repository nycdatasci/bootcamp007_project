import reverse_geocoder as rg
import pandas as pd
from Preprocessing import *

tweets_1 = pd.read_pickle('./tweets_1b.pkl')
get_census(tweets_1)

tweets_1.to_pickle('./tweets_1c.pkl')