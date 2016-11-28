# Read raw data from the file

import pandas as pd #provides data structures to quickly analyze data
import numpy as np
import time
#Since this code runs on Kaggle server, data can be accessed directly in the 'input' folder
#Read the training dataset
train = pd.read_csv("input/allstate_train_codetest.csv") 

#Read test train
test = pd.read_csv("input/allstate_test_codetest.csv")
#Save the id's for submission file
# ID = test['id']
#Drop unnecessary columns
# test.drop('id', axis=1, inplace=True)


# will factorize in a bit
train.rename(columns = {'cont2':'cat117'}, inplace = True)
test.rename(columns = {'cont2':'cat117'}, inplace = True)

# move the cat117 column
cols = train.columns.tolist()
cols = cols[1:117]+ cols[118:116:-1] + cols[119:] # lose ID, so start at 1
# print(cols)

train = train[cols]
test = test[cols[:-1]] # remember we dropped ID and there is no loss in test

# print(test.columns.tolist())

split = 118
# print(cols[118])

'''
#Print all rows and columns. Dont hide any
pd.set_option('display.max_rows', None)
pd.set_option('display.max_columns', None)

#Display the first five rows to get a feel of the data
print(train.head(5))
'''
#Learning : cat1 to cat116 contain alphabets

'''
print ("-" * 75)
print ("Factorize Categorical Data")
features = train.columns
cats = [feat for feat in features if 'cat' in feat]
for feat in cats:
    train[feat] = pd.factorize(train[feat], sort=True)[0]

'''

#log1p function applies log(1+x) to all elements of the column
#train["loss"] = np.log1p(train["loss"])
#visualize the transformed column
#sns.violinplot(data=train,y="loss")  
#plt.show()

#Plot shows that skew is corrected to a large extent


#cat1 to cat116 have strings. The ML algorithms we are going to study require numberical data
#One-hot encoding converts an attribute to a binary vector
# modified version below because in cat92 test data has two factors that do not appear in categorical

#Variable to hold the list of variables for an attribute in the train and test data
labels = []

for i in range(0,split):
    train_labels = train[cols[i]].unique()
    test_labels = test[cols[i]].unique()
    labels.append(list(set(train_labels) | set(test_labels)))    

# del test

#Import OneHotEncoder
from sklearn.preprocessing import LabelEncoder
from sklearn.preprocessing import OneHotEncoder

#One hot encode all categorical attributes
cats = []
for i in range(0, split):
    #Label encode
    label_encoder = LabelEncoder()
    label_encoder.fit(labels[i])
    feature = label_encoder.transform(test.iloc[:,i])
    feature = feature.reshape(test.shape[0], 1)
    #One hot encode
    onehot_encoder = OneHotEncoder(sparse=False,n_values=len(labels[i]))
    feature = onehot_encoder.fit_transform(feature)
    cats.append(feature)



# Make a 2D array from a list of 1D arrays
encoded_cats = np.column_stack(cats)

# Print the shape of the encoded data
print(encoded_cats.shape)

dataset_encoded = np.concatenate((encoded_cats,test.iloc[:,split:].values),axis=1)
del cats
del feature
# del dataset
del encoded_cats
print(dataset_encoded.shape)




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

print("Check train/test set size:")
print(len(X_train), len(X_val), len(Y_train), len(Y_val))

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



start_time = time.time()

#Evaluation of various combinations of SVM

#Import the library
from sklearn.svm import SVR

#Add the C value to the below list if you want to run the algo
c_list = np.array([])

for C in c_list:
    #Set the base model SVR is Support Vector Regression
    model = SVR(C=C)
    
    algo = "SVM"

    #Accuracy of the model using all features
    for name,i_cols_list in X_all:
        model.fit(X_train[:,i_cols_list],Y_train)
        result = mean_absolute_error(np.expm1(Y_val), np.expm1(model.predict(X_val[:,i_cols_list])))
        mae.append(result)
        print(name + " %s" % result)
        
    comb.append(algo + " %s" % C )
    print(comb)
    print(mae)
    print('???')


    #Import the library
from sklearn.neighbors import KNeighborsRegressor

#Add the N value to the below list if you want to run the algo
n_list = np.array([1])

for n_neighbors in n_list:
    #Set the base model
    model = KNeighborsRegressor(n_neighbors=n_neighbors,n_jobs=-1)
    
    algo = "KNN"

    #Accuracy of the model using all features
    for name,i_cols_list in X_all:
        model.fit(X_train[:,i_cols_list],Y_train) 
        result = mean_absolute_error(np.expm1(Y_val), np.expm1(model.predict(X_val[:,i_cols_list])))
        mae.append(result)
        print(name + " %s" % result)
        
    comb.append(algo + " %s" % n_neighbors )

if (len(n_list)==0):
    mae.append(1745)
    comb.append("KNN" + " %s" % 1 )


elapsed_time = time.time() - start_time
print(comb)
print(mae)
print(elapsed_time)

# test against regression script tmw