import json
import os
import pandas as pd
from pymongo import MongoClient
import urllib

client = MongoClient('localhost', 27017)

db = client['crossref']
collection = db['pubs']

date_start = 946688400000
date_end = 1546257600000

DATA_folder = os.path.join('..','crossref')

all_data = os.listdir(DATA_folder)

max = len(all_data)
min = curr = 1

for dump in all_data:

    print(f'{curr}/{max}')
    data = []

    with open(os.path.join(DATA_folder, dump), 'r') as f:
        json_file = json.load(f)

        for d in json_file['items']:

            date = d['created']['timestamp']
            t = d['type']

            if date >= date_start and date <= date_end and t == 'journal-article':

                current = {
                    'doi': d['DOI'],
                    'date': date
                }

                try:
                    current['title'] = d['title'][0]

                except IndexError as err:
                    pass

                try:
                    for issn in d['issn-type']:
                        if issn.get('type') == 'print':
                            current['ISSN_P'] = issn['value']

                        if issn.get('type') == 'electronic':
                            current['ISSN_E'] = issn['value']

                    data.append(current)

                except KeyError as err:
                    pass

        if len(data) > 0:
            collection.insert_many(data)

        f.close()
    curr += 1