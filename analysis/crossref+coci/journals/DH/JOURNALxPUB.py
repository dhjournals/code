import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import os
import seaborn as sns
from matplotlib.patches import Patch

lvl1 = '#2ABB9B'
lvl2 = '#F3C13A'

filein = 'journals.tsv'
fileout = 'JOURNALxPUB.png'
key_title = 'title'
key_pubs = 'pubs'
key_level = 'level'

dir_path = os.path.dirname(os.path.realpath(__file__))

df = pd.read_csv(os.path.join(dir_path, filein),sep='\t')
df = df.groupby([key_title, key_level], as_index=False)[key_pubs].sum()
df = df.sort_values(key_level)
df = df[df[key_level] <= 2]

df = df.sort_values([key_level, key_pubs], ascending=[True, True])

plt.figure(figsize=(20,15))
ax = plt.gca()
ax.grid(True)

FONT_SIZE = 25



legend_elements = [
    Patch(facecolor=lvl1, edgecolor=lvl1, label='Exclusively'),
    Patch(facecolor=lvl2, edgecolor=lvl2,label='Significantly')]

colors = [lvl1 if (row[1] == 1) else lvl2 for index, row in df.iterrows()]

b = sns.barplot(x=key_title, y=key_pubs, data=df, estimator=np.mean, ci=95, 
    alpha=0.5, palette=colors)

b.set_xlabel("Journals",fontsize=FONT_SIZE)
b.set_ylabel("Number of publications",fontsize=FONT_SIZE)
b.tick_params(labelsize=20)
b.set_xticklabels(b.get_xticklabels(), rotation=-45, horizontalalignment='left')
ax = b
for p in ax.patches:
    ax.annotate(int(p.get_height()), (p.get_x() + p.get_width() / 2., p.get_height()),
        ha='center', va='center', fontsize=16, color='black', xytext=(0, 20),
        textcoords='offset pixels')

b.spines['right'].set_visible(False)
b.spines['top'].set_visible(False) 

plt.legend(title='Level', loc='upper left',bbox_to_anchor=(1.05, 1), handles=legend_elements, fontsize=FONT_SIZE, title_fontsize=FONT_SIZE)
plt.tight_layout()
#plt.savefig(os.path.join(dir_path, dir_pics, f'{file}.eps'), format='eps', dpi=300)
plt.savefig(os.path.join(dir_path, fileout))