import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
import os
from matplotlib.patches import Patch 

lvl1 = '#9DD3C7'
lvl2 = '#EDDAA7'

def getColor(lvl):
    if lvl == 4:
        return '#ECF0F1'
    elif lvl == 3:
        return '#EEEEEE'
    elif lvl == 2:
        return lvl2
    elif lvl == 1:
        return lvl1
    return 'black'


filein = 'journals.tsv'

legend_elements = [
    Patch(facecolor=lvl2, edgecolor=lvl2,label='Significantly'),
    Patch(facecolor=lvl1, edgecolor=lvl1, label='Exclusively')]

out = {}
date2index = {}

INDEX = 'title'
YEAR = 'year'
THRESHOLD = 2000
STEP = 10
start_year = 2000
end_year = 2019

FONT_SIZE = 23
SUB_FONT_SIZE = 14
MAX_LEVEL = 2

dir_path = os.path.dirname(os.path.realpath(__file__))

df = pd.read_csv(os.path.join(dir_path, filein),sep='\t')

index = 0
years = np.arange(start_year, end_year)

for year in years:
    if int(year) >= THRESHOLD:
        date2index[str(year)] = index
        index += 1

columns = [k for k in date2index.keys()]

for i, row in df.iterrows():

    id = row[INDEX]
    date = row[YEAR]

    if row['level'] <= MAX_LEVEL:
        if row[YEAR] >= THRESHOLD:
            year = date - start_year

            if id not in out:
                out[id] = [0] * len(columns)
                out[id].append(int(row['level']))
            
            out[id][year] = 1

columns.append('level')
df = pd.DataFrame.from_dict(out,columns=columns,orient='index')
df.index.name = INDEX

print(df)

fig, gnt = plt.subplots(figsize=(24,12))

ids = []

cnt=0

for key, row in df.iterrows():


    ids.append(key)
    lvl = row['level']

    if lvl <= MAX_LEVEL and lvl != 4:
        is_started = False
        start_at = 0
        step_f = 0

        plots = []

        for i in range(0, end_year - start_year):


            if not is_started and row[i] == 1:
                start_at = i
                is_started = True

            if is_started:
                if i+1 >= end_year - start_year or row[i+1] == 0:
                    step_f += 1

                    plots.append((start_year+start_at, step_f))
                    is_started=False 

                else:
                    step_f += 1

        gnt.broken_barh(plots, (cnt*STEP, STEP), facecolors=(getColor(lvl)))
        
        cnt+=1


gnt.set_ylim(0, cnt*STEP)
gnt.set_xlim(start_year, end_year)

# set major ticks locator and delete labels
gnt.xaxis.set_major_locator(ticker.FixedLocator(range(start_year, end_year+1)))
gnt.xaxis.set_major_formatter(ticker.NullFormatter())

# set minor ticks with years
gnt.xaxis.set_minor_locator(ticker.FixedLocator([x+0.5 for x in range(start_year, end_year+1)]))
gnt.xaxis.set_minor_formatter(ticker.FixedFormatter(range(start_year, end_year+1)))

plt.yticks(range(5,cnt*STEP,STEP),ids)

gnt.set_xlabel("Years",fontsize=FONT_SIZE)
gnt.set_ylabel("Journals",fontsize=FONT_SIZE)
gnt.tick_params(labelsize=FONT_SIZE)

plt.legend(title='Level', loc='upper left',bbox_to_anchor=(1.05, 1), handles=legend_elements, fontsize=SUB_FONT_SIZE, title_fontsize=FONT_SIZE)

# foreach minor tick delete the tick and center the label
for tick in gnt.xaxis.get_minor_ticks():
    tick.tick1line.set_markersize(0)
    tick.tick2line.set_markersize(0)
    tick.label1.set_horizontalalignment('center')
    tick.label1.set
    tick.label1.set_fontsize(SUB_FONT_SIZE)



#plt.show()
plt.tight_layout()


plt.savefig(os.path.join(dir_path,"JOURNALxYEAR.png"))