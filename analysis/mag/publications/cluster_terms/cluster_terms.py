import pandas as pd
from nltk import FreqDist
from nltk.tokenize import word_tokenize
from nltk.tokenize import RegexpTokenizer
from nltk.corpus import stopwords
from nltk.stem import PorterStemmer
import os

porter = PorterStemmer()

filename_in = 'cluster_terms.tsv'
filename_out = 'cluster_frequent_terms.tsv'

dir_path = os.path.dirname(os.path.realpath(__file__))

tokenizer = RegexpTokenizer(r'\w+')

df = pd.read_csv(os.path.join(dir_path, filename_in), sep='\t')

INDEX = 'id'
LABEL = 'title'

data = {}

for i, row in df.iterrows():

    cluster_id = row[INDEX]

    if row[LABEL] is not None and isinstance(row[LABEL], str):

        tokens = tokenizer.tokenize(row[LABEL])

        if cluster_id not in data:
            data[cluster_id] = []
        
        for token in tokens:
            data[cluster_id].append(token)

for key, tokens in data.items():

    # no stopwords, no short tokens
    tokens = FreqDist(porter.stem(w.lower()) for w in tokens if w.lower() not in stopwords.words(['english','spanish','german']) and len(w) > 2 and porter.stem(w.lower()) != 'use')

    data[key] = tokens.most_common(10)
    print(data[key])

df_out = pd.DataFrame(data).T
df_out.to_csv(os.path.join(dir_path,filename_out), sep='\t', header=False)
