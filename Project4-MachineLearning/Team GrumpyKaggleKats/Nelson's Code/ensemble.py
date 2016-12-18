import pandas as pd

'''submission = pd.read_csv('submission_xgboost_10_1133.00639747.csv')
submission['loss'] *= 0.3
submission['loss'] += 0.3 * pd.read_csv('submission_keras_shift_perm_10_10_60.csv')['loss'].values
submission['loss'] += 0.2 * pd.read_csv('submission_xgboost_10_1132.7827513.csv')['loss'].values
submission['loss'] += 0.1 * pd.read_csv('sub_v.csv')['loss'].values
submission['loss'] += 0.1 * pd.read_csv('submission_keras_shift_perm_10_10_30.csv')['loss'].values'''

'''submission['loss'] += 0.1 * pd.read_csv('submission_keras_shift_perm_5_5_30.csv')['loss'].values
submission['loss'] += 0.05 * pd.read_csv('submission_keras_shift_perm.csv')['loss'].values
submission['loss'] += 0.05 * pd.read_csv('sub_v_5_long2.csv')['loss'].values'''
#submission.to_csv('sub_ensemble_weighted_avg_v3.csv', index=False)

'''submission = pd.read_csv('submission_xgboost_10_1133.00639747.csv')
submission['loss'] *= 0.5
submission['loss'] += 0.2 * pd.read_csv('submission_keras_shift_perm_10_10_60.csv')['loss'].values
submission['loss'] += 0.2 * pd.read_csv('submission_xgboost_10_1132.7827513.csv')['loss'].values
submission['loss'] += 0.05 * pd.read_csv('sub_v.csv')['loss'].values
submission['loss'] += 0.05 * pd.read_csv('submission_keras_shift_perm_10_10_30.csv')['loss'].values
submission.to_csv('sub_ensemble_weighted_avg_v2.csv', index=False)'''

'''submission = pd.read_csv('submission_xgboost_10_1133.00639747.csv')
submission['loss'] *= 0.3
submission['loss'] += 0.3 * pd.read_csv('submission_keras_shift_perm_10_10_60.csv')['loss'].values
submission['loss'] += 0.1 * pd.read_csv('submission_xgboost_10_1132.7827513.csv')['loss'].values
submission['loss'] += 0.1 * pd.read_csv('sub_v.csv')['loss'].values
submission['loss'] += 0.1 * pd.read_csv('submission_keras_shift_perm_10_10_30.csv')['loss'].values
submission['loss'] += 0.1 * pd.read_csv('submission_xgboost_3_1044.02304785.csv')['loss'].values
submission.to_csv('sub_ensemble_weighted_avg_v4.csv', index=False)'''

# Best weights
submission = pd.read_csv('submission_xgboost_10_1133.00639747.csv')
submission['loss'] *= 0.1
submission['loss'] += 0.4 * pd.read_csv('submission_keras_shift_perm_10_10_60.csv')['loss'].values
submission['loss'] += 0.05 * pd.read_csv('submission_xgboost_10_1132.7827513.csv')['loss'].values
submission['loss'] += 0.05 * pd.read_csv('submission_keras_shift_perm_10_10_30.csv')['loss'].values
submission['loss'] += 0.4 * pd.read_csv('submission_10fold-average-xgb_fairobj_1130.662975_2016-11-27-13-23.csv')['loss'].values
submission.to_csv('sub_ensemble_weighted_avg_v12.csv', index=False)
