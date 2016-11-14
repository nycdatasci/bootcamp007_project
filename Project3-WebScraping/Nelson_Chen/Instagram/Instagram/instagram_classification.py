import classify_image as CI
import pandas as pd
from sys import argv

num1 = int(argv[1])
num2 = int(argv[2])
mergeFLAG = argv[3]

username = 'instagram'
dir_name = 'data/' + username + '/'

temp = pd.read_csv('temp.csv')
'''
for i in range(instagram.shape[0]):
    classifications, scores = CI.run_inference_on_image("data/instagram/" + str(i) + ".jpg")
    row = {'Class 1': classifications[0], 'score 1': scores[0], \
           'Class 2': classifications[1], 'score 2': scores[1], \
           'Class 3': classifications[2], 'score 3': scores[2], \
           'Class 4': classifications[3], 'score 4': scores[3], \
           'Class 5': classifications[4], 'score 5': scores[4]  }
    temp.append(row, ignore_index=True)
    print(i)'''

#for j in [400,800,1200,1600,2000,2400,2800,3200,3346]:
temp2 = CI.run_inference_on_image(num1,num2)
temp = pd.concat([temp,temp2], ignore_index=True)
temp.to_csv('temp.csv', index = False)

if mergeFLAG == 'True':
    instagram = pd.read_csv(dir_name + username + '_complete.csv')
    instagram = pd.concat([instagram, temp], axis = 1)
    instagram.to_csv('instagram_temp.csv',index = False)
