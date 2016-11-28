
# Read raw data from the file

import pandas as pd #provides data structures to quickly analyze data
import numpy as np
import time 
import random
#Since this code runs on Kaggle server, data can be accessed directly in the 'input' folder
#Read the training dataset
train = pd.read_csv("input/allstate_train.csv") 

#Read test train
test = pd.read_csv("input/allstate_test.csv")
#Save the id's for submission file
# ID = test['id']
#Drop unnecessary columns
# test.drop('id', axis=1, inplace=True)
train_id = train['id']
test_id = test['id']

# will factorize in a bit
train.rename(columns = {'cont2':'cat117'}, inplace = True)
test.rename(columns = {'cont2':'cat117'}, inplace = True)

# move the cat117 column
cols = train.columns.tolist()
cols = cols[:117]+ cols[118:116:-1] + cols[119:]
cols.remove('cont12')
# print(cols)
test['loss'] = np.nan
# join them first to do factorize b/c test has some that train doesnt
joined = pd.concat([train, test])


cat_feature = [n for n in joined.columns if n.startswith('cat')]
cont_feature = [n for n in joined.columns if n.startswith('cont')]


for column in cat_feature:
    joined[column] = pd.factorize(joined[column].values, sort=True)[0]

# split again by filtering by rows
train = joined[joined['loss'].notnull()]
test = joined[joined['loss'].isnull()]


# prevent any negative values
# 200 was found to perform well from forums
shift = 200
Y = np.log(train['loss'] + shift)
X = train.drop(['loss', 'id'], 1)
X_test = test.drop(['loss', 'id'], 1)







#Validation chunk size
#val_size = 0.2

#Use a common seed in all experiments so that same chunk is used for validation
#seed = 0


from sklearn import cross_validation
from sklearn.cross_validation import KFold

# w/ shuffle = True it randomizes regardless of seed
print ("Creating K-fold validation dataset indices")
n_folds = 10
kf = KFold(train.shape[0], n_folds=n_folds, shuffle = True)
prediction= 0 # init predictions to sum and then average over for each row
temp_cv_score = []
cv_loss = pd.DataFrame(columns=["id","loss"])

print( "%d folds created." % n_folds)



#Split the data into chunks

# this is 1-Fold
#X_train, X_val, Y_train, Y_val = cross_validation.train_test_split(X, Y, test_size=val_size, random_state=seed)
# del X
# del Y

# alternatively
# pick two of the folds to test on
cache = []
for i, (train_index,test_index) in enumerate(kf):
    cache.append((train_index,test_index))

random.seed()
sample_size = 2
sample = random.sample(range(0,10), sample_size)

print sample

#List of combinations
comb = []

#Dictionary to store the MAE for all algorithms 
mae = []

#Scoring parameter
from sklearn.metrics import mean_absolute_error


#Import the library
from sklearn.svm import SVR

#Add the C value to the below list if you want to run the algo
c_list = np.array([])

    #Import the library
from sklearn.neighbors import KNeighborsRegressor




#Add the N value to the below list if you want to run the algo
n_list = range(425,432)


start_time = time.time() # start time of model(s)
#for i, (train_index, test_index) in enumerate(kf):

for i in sample:

    train_index = cache[i][0]
    test_index = cache[i][1]
    print "-" * 80
    print('\n Fold %d' % (i + 1))

    X_train, X_val = X.iloc[train_index], X.iloc[test_index]
    Y_train, Y_val = Y.iloc[train_index], Y.iloc[test_index]
    print "Training size: " + str(len(X_train))
    print "Validation size: " + str(len(X_val))
    print "Total size: " + str(len(X_train) + len(X_val))



#Evaluation of various combinations of SVM
    '''
    for C in c_list:
	#Set the base model
        model = SVR(C=C)
        algo = "SVM"

	   #Accuracy of the model using all features
        model.fit(X_train,Y_train)
        result = mean_absolute_error(np.expm1(Y_val), np.expm1(model.predict(X_val)))
        mae.append(result)
        print(name + " %s" % result)
	    
        comb.append(algo + " %s" % C )
        print(comb)
        print(mae)
    '''
        




    print("Starting KNN")
    for n_neighbors in n_list:
	#Set the base model
        model = KNeighborsRegressor(n_neighbors=n_neighbors,n_jobs=-1)
        algo = "KNN"

	#Accuracy of the model using all features

        model.fit(X_train,Y_train)

        # getting a matrix  of  N x 1 
        predict_result = np.exp(model.predict(X_val))-200
        print ("Check Results")
        print np.mean(predict_result)
        print np.mean(np.exp(model.predict(X_val)) -200)
        print ("Check Types")


        cv_loss = pd.concat([cv_loss, pd.DataFrame({"id": train_id[test_index], "loss": predict_result})])

        result = mean_absolute_error(np.exp(Y_val)- shift, predict_result)
        np.exp(model.predict(X_test))
        prediction += np.exp(model.predict(X_test)) - shift # on test
        mae.append(result)
        print(result)
        
	    
        comb.append(algo + " %s"  % n_neighbors )

    if (len(n_list)==0):
        mae.append(1745)
        comb.append("KNN" + " %s" % 1 )


    print(comb)
    print(mae)

mae_fold1 = mae[:len(mae)/2]
mae_fold2 = mae[len(mae)/2:]
mae_avg = [(v1 + v2)/2.0 for v1,v2 in zip(mae_fold1, mae_fold2)]

print('MAEs calculated')
print(len(mae_avg))

print("Avg MAE")
print mae_avg

print("Best MAE")
min_mae = min(mae_avg)
print(min_mae)

print("Best K")
index = mae_avg.index(min_mae)
k_index = index % len(n_list)
best_K = n_list[k_index]
print(best_K)
'''
cv_loss.sort(columns = 'id', inplace = True)
cv_loss.to_csv("KNN_CV.csv", index = False)

elapsed_time = time.time() - start_time
print("Elapsed Time")    
print(elapsed_time)


prediction = prediction / n_folds
submission = pd.DataFrame()
submission['id'] = test_id
submission['loss'] = prediction

submission.to_csv('submission_KNN.csv', index=False)
'''


#final_fold_prediction = pd.concat(final_fold_prediction, ignore_index=True)
#final_fold_real = pd.concat(final_fold_real, ignore_index=True)

#cv_score = mean_absolute_error(final_fold_prediction, final_fold_real)
#print cv_score