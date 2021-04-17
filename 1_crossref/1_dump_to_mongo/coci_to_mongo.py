import json
import os
import pandas as pd
from pymongo import MongoClient
import urllib

client = MongoClient('localhost', 27017)

db = client['crossref']
collection = db['citations']

date_end = 1546257600000

DATA_folder = os.path.join('..','coci')

all_data = os.listdir(DATA_folder)

max = len(all_data)
min = curr = 1

for dump in all_data:

    print(f'{curr}/{max}')
    data = []

    df = pd.read_csv(os.path.join(DATA_folder, dump))

    for index, row in df.iterrows():

        current = {
            'citing': row['citing'],
            'cited': row['cited'],
            'date': row['creation']
        }

        data.append(current)
        
    collection.insert_many(data)
    

    curr += 1