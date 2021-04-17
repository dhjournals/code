import pandas as pd
import numpy as np
from pymongo import MongoClient
import json

filename = 'PaperCitationContexts.txt'

key_paper_id = 'PaperId'
key_paper_ref = 'PaperReferenceId'
key_citation_context = 'CitationContext'

header = [key_paper_id,key_paper_ref,key_citation_context]

client = MongoClient('localhost', 27017)

db = client['mag']
collection = db['ref']

cnt = 0

chunksize = 10 ** 6
for chunk in pd.read_csv(filename, names=header, sep='\t', chunksize=chunksize):

    data = []
    
    for key, val in chunk.iterrows():

        paper_id = val[key_paper_id]
        paper_ref = val[key_paper_ref]

        if pd.notna(paper_ref) :

            current = {
                key_paper_id: paper_id,
                key_paper_ref: paper_ref
            }

            data.append(current)
    
    collection.insert_many(data)
    print(cnt)
    cnt+=1