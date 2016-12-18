import pandas as pd
import numpy as np
from sklearn.preprocessing import LabelEncoder
from sklearn.preprocessing import OneHotEncoder

print "Start"

dat_train = pd.read_csv("./raw/train.csv")
dat_test = pd.read_csv("./raw/test.csv")

ID = dat_test['id']

dat_test.drop('id', axis=1, inplace=True)
dat_train = dat_train.iloc[:, 1:]

# print dat_test.head(5)
# print dat_train.head(5)

pd.set_option('display.max_rows', None)
pd.set_option('display.max_columns', None)

labels = []
split = 116
cols = dat_train.columns



for i in range(0,split):
    train = dat_train[cols[i]].unique()
    test = dat_test[cols[i]].unique()
    labels.append(list(set(train) | set(test)))
    # print "train"
    # print train
    # print "test"
    # print test
    # print "labels"
    # print labels

cats = []
for i in range(0, split):
    # print labels[i]
    #Label encode
    label_encoder = LabelEncoder()
    label_encoder.fit(labels[i])
    feature = label_encoder.transform(dat_train.iloc[:,i])
    # print feature
    feature = feature.reshape(dat_train.shape[0], 1)
    # print feature
    #One hot encode
    onehot_encoder = OneHotEncoder(sparse=False,n_values=len(labels[i]))
    feature = onehot_encoder.fit_transform(feature)
    # print feature
    cats.append(feature)

encoded_cats = np.column_stack(cats)
dataset_encoded = np.concatenate((encoded_cats,dat_train.iloc[:,split:].values),axis=1)
print "finished encoding"
print encoded_cats
# pd.DataFrame(dataset_encoded).to_csv("train_ONE_raw.csv", index=False)


#####################################
# CV setup
#####################################

print "CV split"
# dataset_encoded = pd.read_csv("train_ONE_raw.csv")

print dataset_encoded.shape
#get the number of rows and columns
r, c = dataset_encoded.shape

#create an array which has indexes of columns
i_cols = []
for i in range(0,c-1):
    i_cols.append(i)

#Y is the target column, X has the rest
X = dataset_encoded[:,0:(c-1)]
Y = dataset_encoded[:,(c-1)]
del dataset_encoded

#Validation chunk size
val_size = 0.1

#Use a common seed in all experiments so that same chunk is used for validation
seed = 0

#Split the data into chunks
from sklearn import cross_validation
X_train, X_val, Y_train, Y_val = cross_validation.train_test_split(X, Y, test_size=val_size, random_state=seed)
del X
del Y

#All features
X_all = []

#List of combinations
comb = []

#Dictionary to store the MAE for all algorithms
mae = []

#Scoring parameter
from sklearn.metrics import mean_absolute_error

#Add this version of X to the list
n = "All"
#X_all.append([n, X_train,X_val,i_cols])
X_all.append([n, i_cols])

# print X_all

#Evaluation of various combinations of CART

#Import the library
from sklearn.tree import DecisionTreeRegressor

#Add the max_depth value to the below list if you want to run the algo
d_list = np.array([1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20])

for max_depth in d_list:
    print max_depth
    #Set the base model
    model = DecisionTreeRegressor(max_depth=max_depth,random_state=seed)

    algo = "CART"

    #Accuracy of the model using all features
    for name,i_cols_list in X_all:
        model.fit(X_train[:,i_cols_list],Y_train)
        result = mean_absolute_error(Y_val, model.predict(X_val[:,i_cols_list]))
        mae.append(result)
        print(name + " %s" % result)

    comb.append("%s" % max_depth )

print comb, mae

with open("CART_mae.txt", "w") as f:
    for c, e in zip(comb, mae):
        print >>f, "{},{}".format(c, e)
f.close()

# if (len(d_list)==0):
#     mae.append(1741)
#     comb.append("CART" + " %s" % 5 )

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

#Set figure size
plt.rc("figure", figsize=(25, 10))

#Plot the MAE of all combinations
fig, ax = plt.subplots()
plt.plot(mae)
#Set the tick names to names of combinations
ax.set_xticks(range(len(comb)))
ax.set_xticklabels(comb,rotation=45)
#Plot the accuracy for all combinations
plt.savefig("CART_2.png")
# High computation time
# Best estimated performance is 1363.858 for depth=11