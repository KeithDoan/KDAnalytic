#!/usr/bin/python

import pandas as pd
from sklearn import model_selection
from sklearn.externals import joblib
from sklearn.metrics import *
from keras.utils import to_categorical
import pickle
import json
from keras.models import load_model
import time
import sys
import os
import numpy as np
import dsx_core_utils, requests, re, jaydebeapi
from pyspark.sql import SparkSession

# define variables
args = {"threshold": {"metric": "areaUnderROC", "min_value": 0.3, "mid_value": 0.7}, "published": "false", "dataset": "/datasets/MortgageDefaultModelEval.csv"}
model_path = os.getenv("DSX_PROJECT_DIR") + "/models/MortgageDefault_Model/3/model"

# load the input data
input_data = os.getenv("DSX_PROJECT_DIR") + args.get("dataset")
df1 = pd.read_csv(input_data)

y_true = df1[[u'PreviouslyDefaulted']].values.flatten() 
X = df1[[u'CreditCardDebt', u'EducationLevel', u'YearsWithCurrentEmployer', u'OtherDebt', u'Age', u'DebtIncomeRatio', u'Income', u'YearsAtCurrentAddress']].as_matrix()

# load the model from disk 
loaded_model = load_model(model_path)

# predictions
y_pred = loaded_model.predict(X, batch_size=32, verbose=0)

# binary classification case
if loaded_model.output_shape[1] == 1:
    y_pred = np.array([list(1-y_pred.T[0]),list(y_pred.T[0])]).T

# Create Evalutation JSON
evaluation = dict()
evaluation["metrics"] = dict()
evaluation["modelName"] = "MortgageDefault_Model"
evaluation["startTime"] = int(time.time())
evaluation["modelVersion"] = "3"

# Classification Metrics
threshold = {u'metric': 'areaUnderROC', u'min_value': 0.3, u'mid_value': 0.7}

if (len(y_true.shape) == 1):
    y_true_1d = y_true
    y_true_2d = to_categorical(y_true)

else:
    y_true_1d = np.argmax(y_true, axis=1)
    y_true_2d = y_true

if (len(y_pred.shape) == 1):
    y_pred_1d = y_pred
    y_pred_2d = to_categorical(y_pred)

else:
    y_pred_1d = np.argmax(y_pred, axis=1)
    y_pred_2d = y_pred


evaluation["metrics"]["accuracyScore"] = accuracy_score(y_true_1d, y_pred_1d)
evaluation["metrics"]["precisionScore"] = precision_score(y_true_1d, y_pred_1d, average="weighted")
evaluation["metrics"]["recallScore"] = recall_score(y_true_1d, y_pred_1d, average="weighted")
evaluation["metrics"]["areaUnderROC"] = roc_auc_score(y_true_2d, y_pred_2d)
evaluation["metrics"]["threshold"] = threshold

if(evaluation["metrics"][threshold.get('metric','INVALID_METRIC')] >= threshold.get('mid_value', 0.70)):
    evaluation["performance"] = "good"
elif(evaluation["metrics"][threshold.get('metric','INVALID_METRIC')] <= threshold.get('min_value', 0.25)):
    evaluation["performance"] = "poor"
else:
    evaluation["performance"] = "fair"

evaluations_file_path = os.getenv("DSX_PROJECT_DIR") + '/models/' + "MortgageDefault_Model" + '/' + "3" + '/evaluations.json'

if(os.path.isfile(evaluations_file_path)):
    current_evaluations = json.load(open(evaluations_file_path))
else:
    current_evaluations = []
current_evaluations.append(evaluation)

with open(evaluations_file_path, 'w') as outfile:
    json.dump(current_evaluations, outfile, indent=4, sort_keys=True)