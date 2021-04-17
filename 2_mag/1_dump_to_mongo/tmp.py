import pandas as pd
import numpy as np
from pymongo import MongoClient
import json

filename = 'Papers.txt'

#44.683.358

key_paper_id = 'PaperId'
key_paper_title = 'PaperTitle'
key_year = 'Year'
key_journal_id = 'JournalId'
key_doc_type = 'DocType'

header = [key_paper_id,'Rank','Doi',key_doc_type,key_paper_title,'OriginalTitle','BookTitle',key_year,'Date','Publisher',key_journal_id,'ConferenceSeriesId','ConferenceInstanceId','Volume','Issue','FirstPage','LastPage','ReferenceCount','CitationCount','EstimatedCitation','OriginalVenue','FamilyId','CreatedDate']

client = MongoClient('localhost', 27017)

db = client['mag']
collection = db['pubs']

cnt = 0
total = 0

chunksize = 10 ** 6
for chunk in pd.read_csv(filename, names=header, sep='\t', chunksize=chunksize):

    data = []
    
    for key, val in chunk.iterrows():

        journal_id = val[key_journal_id]

        if journal_id == '1989-9947':
            total += 1
            print(total)
            
    
    collection.insert_many(data)
    print(cnt)
    cnt+=1