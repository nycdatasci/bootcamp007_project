import urllib
import pandas as pd

username = 'instagram'
end_index = 7

dir_name = 'data/' + username + '/'

insta_data = pd.read_csv(dir_name + username + '1.csv')
for j in range(2,end_index + 1):
    temp = pd.read_csv(dir_name + username + str(j) + '.csv')
    insta_data = pd.concat([insta_data,temp], ignore_index=True)

insta_data.to_csv(dir_name + username + '_complete.csv')

for i in range(insta_data.shape[0]):
    url = insta_data.loc[i,'image_urls']
    file_name = dir_name + str(i) + ".jpg"
    urllib.urlretrieve(url, file_name)

