
# Read raw data from the file

import pandas as pd #provides data structures to quickly analyze data
import numpy as np
import time 
import random
#Since this code runs on Kaggle server, data can be accessed directly in the 'input' folder
#Read the training dataset
train = pd.read_csv("allstate_train.csv") 

#Read test train
test = pd.read_csv("allstate_test.csv")
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



#List of combinations
comb = []

#List to store the MAE for all algorithms 
mae = []

mae_avg = []

#Scoring parameter
from sklearn.metrics import mean_absolute_error


#Import the library
from sklearn.svm import SVR


# to have float values
def seq2range(start, stop, length):
    
    magnitude = abs(start) + abs(stop)
    step = magnitude / float(length- 1)
    k = start
    seq = [k]
    # dummy loop, could use apply too I suppose
    for l in range(1,length):
        k += step
        seq.append(k)
        
    
    return seq


#Add the C value to the below list if you want to run the algo
c_list = [10 **n for n in seq2range(-1,1,5)]


print c_list
e_list = [10**n for n in [0.05, 0.01, 0.015, 0.02, 0.03, 0.1, 0.5]]
print e_list



cache = []
for i, (train_index,test_index) in enumerate(kf):
    cache.append((train_index,test_index))

random.seed()
sample_size = 2
sample = random.sample(range(0,10), sample_size)

print sample


start_time = time.time() # start time of model(s)
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
    print("Starting SVR")
    for C in c_list:
        print("Looping Through Cost")
        for E in e_list:
            print("Looping Through Epsilon")
	#Set the base model
            model = SVR(C=C, epsilon=E) # verbose = 1 for printouts
            algo = "SVM"


           #Accuracy of the model using all features
            model.fit(X_train,Y_train)
            predict_result = np.exp(model.predict(X_val))-200

            #cv_loss = pd.concat([cv_loss, pd.DataFrame({"id": train_id[test_index], "loss": predict_result})])

            result = mean_absolute_error(np.exp(Y_val)- shift, predict_result)
            #np.exp(model.predict(X_test))
            #prediction += np.exp(model.predict(X_test)) - shift # on test
            mae.append(result)
            print(result)
            
            
            comb.append(algo + " C %s E %s" % (C,E) )
            print(comb)
            print(mae)


# only works with two folds
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

print("Parameters Chosen")
index = mae_avg.index(min_mae)
c_index = index / len(e_list) # 0-4 still for 5 choices of cost (remainder)
e_index = index % len(e_list) # 0-4 still for 5 choices of epsilon

# testing
#print("Counters")
#print(index)
#print(c_index)
#print(e_index)

best_C = c_list[c_index]
best_E = e_list[e_index]
print("Best C: %f Best E: %f" % (best_C, best_E))



'''
cv_loss.sort(columns = 'id', inplace = True)
cv_loss.to_csv("SVR_CV.csv", index = False)
'''
elapsed_time = time.time() - start_time
print("Elapsed Time")    
print(elapsed_time)

f = open('CV_SVR.txt', 'w')
f.write('MAEAVG|BESTMAE|BESTC|BESTE|ELAPSED')
f.write(mae_avg + '|' + min_mae + '|' + c_index + '|' + e_index + '|' + elapsed_time )
f.close()
'''
prediction = prediction / n_folds
submission = pd.DataFrame()
submission['id'] = test_id
submission['loss'] = prediction

submission.to_csv('submission_SVR.csv', index=False)    
'''


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
'''

'''
cv_loss.sort(columns = 'id', inplace = True)
cv_loss.to_csv("KNN_CV.csv", index = False)

elapsed_time = time.time() - start_time    
print(elapsed_time)


prediction = prediction / n_folds
submission = pd.DataFrame()
submission['id'] = test_id
submission['loss'] = prediction

submission.to_csv('sub_KNN.csv', index=False)
'''
#final_fold_prediction = pd.concat(final_fold_prediction, ignore_index=True)
#final_fold_real = pd.concat(final_fold_real, ignore_index=True)

#cv_score = mean_absolute_error(final_fold_prediction, final_fold_real)
#print cv_score