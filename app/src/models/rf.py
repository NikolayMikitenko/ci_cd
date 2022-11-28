import pandas as pd
from random import randint
import os
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import confusion_matrix, log_loss, roc_auc_score

def educate_model():
    try:
        train = get_df(path='./app/data/train.csv')
        validation = get_df(path='./app/data/validation.csv')
        test = get_df(path='./app/data/test.csv')
    except Exception as e:
        raise FileNotFoundError('One of the mandatory file (train, validation, test) not found or imposible to read.')

    return model(train=train, validation=validation)

def get_df(path: str):
    if os.path.exists(path):
        return pd.read_csv(path, sep='~')
    else:
        raise FileNotFoundError(f'File {path} not found.')

def model(train: pd.DataFrame, validation: pd.DataFrame, e: int = None, l: int = None, f: float = None):
    if e:
        n_estimators = e
    else:
        n_estimators = randint(1, 20)*10

    if l:
        min_samples_leaf = l
    else:
        min_samples_leaf = randint(1, 10)

    if f:
        max_features = f
    else:
        max_features = float(randint(1, 10))/10

    inputs = []
    inputs.append({'n_estimators':n_estimators,'min_samples_leaf':min_samples_leaf,'max_features':max_features})

    for _ in range(4):
        n_estimators = randint(1, 20)*10
        min_samples_leaf = randint(1, 10)
        max_features = float(randint(1, 10))/10
        inputs.append({'n_estimators':n_estimators,'min_samples_leaf':min_samples_leaf,'max_features':max_features})

    models = []
    metrics = []

    for i in range(len(inputs)):
        rf = RandomForestClassifier(n_jobs=-1, n_estimators=n_estimators, min_samples_leaf=min_samples_leaf, max_features=max_features)
        rf.fit(train.drop('Survived', axis = 1), train.Survived)
        models.append(rf)
        preds_proba = rf.predict_proba(validation.drop('Survived', axis = 1))
        metrics.append(roc_auc_score(validation.Survived, preds_proba[:,1]))
    
    bi = metrics.index(max(metrics))
    return models[bi]

def main():
    educate_model()

main()
