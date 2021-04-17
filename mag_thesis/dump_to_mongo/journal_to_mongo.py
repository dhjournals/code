import pandas as pd
import numpy as np
from pymongo import MongoClient
import json

#37.168

filename = 'Journals.txt'

key_journal_id = 'JournalId'
key_issn = 'Issn'

header = [key_journal_id,'Rank','NormalizedName','DisplayName',key_issn,'Publisher','Webpage','PaperCount','CitationCount','CreatedDate']

client = MongoClient('localhost', 27017)

db = client['mag']
collection = db['jour']

cnt = 0

chunksize = 10 ** 6
for chunk in pd.read_csv(filename, names=header, sep='\t', chunksize=chunksize):

    data = []
    
    for key, val in chunk.iterrows():

        journal_id = val[key_journal_id]
        issn = val[key_issn]

        if pd.notna(issn) :

            current = {
                key_journal_id: journal_id,
                key_issn: issn
            }

            data.append(current)
    
    collection.insert_many(data)
    print(cnt)
    cnt+=1