import pandas as pd
import matplotlib.pyplot as plt

filein = 'AHxCROSSREF.csv'
fileout = 'JOURNALxPUB.png'
TITLE = 'title'
PUBS = 'pubs'

df = pd.read_csv(filein,sep='\t')

df = df.groupby([TITLE], as_index=False)[PUBS].sum()

fig, ax = plt.subplots(figsize=(75,53))
_id = 0
titles = []
for i, row in df.iterrows():
    titles.append(row[TITLE])
    pubs = row[PUBS]
    plt.bar(_id, pubs, width=1, align='edge', color='tab:grey')
    _id += 2

plt.xticks(range(0, _id, 2), titles)
_, labels = plt.xticks()
plt.setp(labels, rotation=80)

plt.savefig(fileout)
