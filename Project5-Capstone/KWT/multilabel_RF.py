import numpy as np
import pandas as pd
from sklearn.preprocessing import MultiLabelBinarizer
from sklearn.preprocessing import LabelEncoder
from sklearn.preprocessing import MinMaxScaler
from sklearn.multiclass import OneVsRestClassifier
from sklearn.ensemble import RandomForestClassifier
from ml_metrics import mapk

#target_cols = ['ind_ahor_fin_ult1','ind_aval_fin_ult1','ind_cco_fin_ult1','ind_cder_fin_ult1','ind_cno_fin_ult1','ind_ctju_fin_ult1','ind_ctma_fin_ult1','ind_ctop_fin_ult1','ind_ctpp_fin_ult1','ind_deco_fin_ult1','ind_deme_fin_ult1','ind_dela_fin_ult1','ind_ecue_fin_ult1','ind_fond_fin_ult1','ind_hip_fin_ult1','ind_plan_fin_ult1','ind_pres_fin_ult1','ind_reca_fin_ult1','ind_tjcr_fin_ult1','ind_valo_fin_ult1','ind_viv_fin_ult1','ind_nomina_ult1','ind_nom_pens_ult1','ind_recibo_ult1']
target_cols = ['ind_cco_fin_ult1','ind_cno_fin_ult1','ind_ctma_fin_ult1','ind_ctop_fin_ult1','ind_ctpp_fin_ult1','ind_dela_fin_ult1','ind_ecue_fin_ult1','ind_fond_fin_ult1','ind_reca_fin_ult1','ind_tjcr_fin_ult1','ind_valo_fin_ult1','ind_nomina_ult1','ind_nom_pens_ult1','ind_recibo_ult1']

cat_cols = ['ind_empleado', 'sexo', 'ind_nuevo', 'indrel', 'indrel_1mes', 'tiprel_1mes', 'indresi', 'indext', 'indfall', 'ind_actividad_cliente', 'segmento', 'nomprov', 'pais_residencia', 'canal_entrada']

#output_file = raw_input("Output file name: ").strip()
#month = int(raw_input("Train month[2-17]:").strip())
#test_month = int(raw_input("Test month[2-18]:").strip())
output_file = 'RF_output_v3.csv'
month = 6
test_month =18
train_change1 = "change_0102.csv"
train_change2 = "change_0506.csv"
test_change = "change_1314.csv"
path = "input/"
cur_data = "train_"+str(month)+".csv"
pre_data = "train_"+str(month-1)+".csv"
print "Reading :" + path + cur_data
cur_df = pd.read_csv(path + cur_data, usecols = ['ncodpers', 'renta', 'age', 'antiguedad'] + target_cols + cat_cols, dtype ={
	'ind_empleado' : str,
	'sexo': str,
	'ind_nuevo': str,
	'indrel': str,
	'indrel_1mes': str,
	'tiprel_1mes': str,
	'indresi': str,
	'indext' : str,
	'indfall': str,
	'ind_actividad_cliente' : str,
	'segmento':str, 'nomprov':str,
	'pais_residencia':str,
	'canal_entrada': str
})
cur_change = 


print "Reading :" + path + pre_data
pre_df = pd.read_csv(path + pre_data, usecols = ['ncodpers']+target_cols)


if test_month == 18:
	test_data = "test_clean_ver3.csv"
else:
	test_data = "train_"+str(test_month)+".csv"

test_pre_data = "train_"+str(test_month-1)+".csv"

print "Reading :" + path + test_data
if test_month != 18:
    test_df = pd.read_csv(path + test_data, usecols = ['ncodpers', 'renta', 'age', 'antiguedad'] + target_cols + cat_cols, dtype ={'ind_empleado' : str,'sexo': str,'ind_nuevo': str,'indrel': str,'indrel_1mes': str,'tiprel_1mes': str,'indresi': str,'indext' : str,'indfall': str,'ind_actividad_cliente' : str,'segmento':str, 'nomprov':str,'pais_residencia':str,'canal_entrada': str})
else:
    test_df = pd.read_csv(path + test_data, usecols = ['ncodpers', 'renta', 'age', 'antiguedad'] + cat_cols, dtype ={'ind_empleado' : str,'sexo': str,'ind_nuevo': str,'indrel': str,'indrel_1mes': str,'tiprel_1mes': str,'indresi': str,'indext' : str,'indfall': str,'ind_actividad_cliente' : str,'segmento':str, 'nomprov':str,'pais_residencia':str,'canal_entrada': str})

print "Reading :" + path + test_pre_data
test_pre_df = pd.read_csv(path + test_pre_data, usecols = ['ncodpers']+target_cols)

label_encoder = LabelEncoder()
if test_month != 18:
	temp_df = pd.concat([cur_df, test_df])
else:
	temp_df = pd.concat([cur_df[cur_df.columns[0:18]], test_df])

for col in cat_cols:
	print "Processing categorical variables: "+col
	label_encoder.fit(temp_df[col])
	cur_df[col] = label_encoder.transform(cur_df[col])
	test_df[col] = label_encoder.transform(test_df[col])

print "Scaling continuous variables: age, renta, antiguedad"
min_max_scaler = MinMaxScaler()
min_max_scaler.fit(temp_df['age'].values.reshape(-1,1))
cur_df['age'] = min_max_scaler.transform(cur_df['age'].values.reshape(-1,1))
test_df['age'] = min_max_scaler.transform(test_df['age'].values.reshape(-1,1))
min_max_scaler.fit(temp_df['renta'].values.reshape(-1,1))
cur_df['renta'] = min_max_scaler.transform(cur_df['renta'].values.reshape(-1,1))
test_df['renta'] = min_max_scaler.transform(test_df['renta'].values.reshape(-1,1))
min_max_scaler.fit(temp_df['antiguedad'].values.reshape(-1,1))
cur_df['antiguedad'] = min_max_scaler.transform(cur_df['antiguedad'].values.reshape(-1,1))
test_df['antiguedad'] = min_max_scaler.transform(test_df['antiguedad'].values.reshape(-1,1))

print "Feature engineering:"
if test_month != 18:
	test_df['products'] = list(np.array(test_df[test_df.columns[18:32]]))
	test_df['products'] = test_df['products'].apply(lambda x: (' '.join(list(x*temp_df.columns.values[18:32])).split()))

cur_df['products'] = list(np.array(cur_df[cur_df.columns[18:32]]))
cur_df['products'] = cur_df['products'].apply(lambda x: (' '.join(list(x*cur_df.columns.values[18:32])).split()))


test_pre_df['products'] = list(np.array(test_pre_df[test_pre_df.columns[1:15]]))
test_pre_df['products'] = test_pre_df['products'].apply(lambda x: (' '.join(list(x*test_pre_df.columns.values[1:15])).split()))

test_id = np.array(test_df['ncodpers'])


multilabel_encoder = MultiLabelBinarizer()
if test_month != 18:
	multilabel_encoder.fit(cur_df['products'])
	train_y = multilabel_encoder.transform(cur_df['products'])
	test_y = multilabel_encoder.transform(test_df['products'])	
else:
	multilabel_encoder.fit(cur_df['products'])
	train_y = multilabel_encoder.transform(cur_df['products'])

del temp_df

cur_df.drop(['products'] + target_cols, axis = 1, inplace = True)

train_X = cur_df.set_index('ncodpers').join(pre_df.set_index('ncodpers'), rsuffix = '_pre')
train_X.fillna(0, inplace = True)
#train_X.products.loc[train_X.products.isnull()] = train_X.products.loc[train_X.products.isnull()].apply(lambda x: [0 for col in target_cols])
#train_X.drop('products', axis = 1, inplace = True)
train_X.reset_index(drop = True, inplace = True)
#train_X = train_X.rename(columns = {'products':'pre_products'})

if test_month !=18:
	test_df.drop(['products'] + target_cols, axis = 1, inplace = True)


test_X = test_df.set_index('ncodpers').join(test_pre_df.set_index('ncodpers'), rsuffix = '_pre')
test_X.products.loc[test_X.products.isnull()] = test_X.products.loc[test_X.products.isnull()].apply(lambda x: [])
test_X.fillna(0, inplace = True)
test_pre_y = multilabel_encoder.transform(test_X['products'])
test_X.drop('products', axis = 1, inplace = True)
test_X.reset_index(drop = True,inplace = True)

#test_X = test_X.rename(columns = {'products':'pre_products'})
print "Random Forest model:"
forest = RandomForestClassifier(n_estimators=250, random_state=1, verbose = 1, criterion='entropy')
multi_label_forest = OneVsRestClassifier(forest, n_jobs=-1)
multi_label_forest.fit(train_X, train_y)
print "Predicting:"
preds = multi_label_forest.predict_proba(test_X)
new_preds = preds - test_pre_y

new_preds = np.argsort(new_preds, axis=1)
new_preds = np.fliplr(new_preds)[:,:7]
if test_month == 18:
	final_preds = [' '.join([target_cols[pred] for pred in new_pred]) for new_pred in new_preds]
	out_df = pd.DataFrame({'ncodpers':test_id, 'added_products':final_preds})
	out_df.to_csv(output_file, columns = ['ncodpers', 'added_products'], index=False)
else:
	print "Scoring..."
	test_preds = [[target_cols[pred] for pred in new_pred] for new_pred in new_preds]
	truth_list = np.array((test_y - test_pre_y)) ==1
	truth_list = [''.join([target_cols[i]  if i else '' for i in truth]).split() for truth in truth_list]
	print mapk(truth_list, test_preds, 7)

