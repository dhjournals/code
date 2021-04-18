import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker

filein = 'AHxCROSSREF.csv'
fileout = 'JOURNALxYEAR.png'

date2index = {}
out = {}

INDEX = 'title'
THRESHOLD = 2000
YEAR = 'year'

df = pd.read_csv(filein,sep='\t')

index = 0
years = df.year.unique()
years.sort()

for year in years:
    if int(year) >= THRESHOLD:
        date2index[str(year)] = index
        index += 1

columns = [k for k in date2index.keys()]

for i, row in df.iterrows():

    id = row[INDEX]
    date = row[YEAR]

    if row[YEAR] >= THRESHOLD:
        year = date2index.get(str(row[YEAR]))

        if id not in out:
            out[id] = [0] * len(columns)
        
        out[id][year] = 1

outdf = pd.DataFrame.from_dict(out,columns=columns,orient='index')

outdf.index.name = INDEX

STEP = 10

df = outdf

start_year = THRESHOLD
end_year = 2018

fig, gnt = plt.subplots(figsize=(30,12))

ids = []
cnt=0

for key, row in df.iterrows():

    ids.append(key)

    is_started = False
    start_at = 0
    step_f = 0

    for i in range(0, end_year - start_year + 1):
        if not is_started and row[i] == 1:
            start_at += i
            is_started = True

        elif is_started and row[i] == 1:
            step_f += 1

        elif is_started and row[i] == 0:
            y=cnt*STEP
            gnt.broken_barh([(start_year+start_at, step_f)], (y, STEP), facecolors=('tab:grey'))
    
    cnt+=1

gnt.set_ylim(0, cnt*STEP)
gnt.set_xlim(start_year, end_year)

# set major ticks locator and delete labels
gnt.xaxis.set_major_locator(ticker.FixedLocator(range(start_year, end_year+1)))
gnt.xaxis.set_major_formatter(ticker.NullFormatter())

# set minor ticks with years
gnt.xaxis.set_minor_locator(ticker.FixedLocator([x+0.5 for x in range(start_year, end_year+1)]))
gnt.xaxis.set_minor_formatter(ticker.FixedFormatter(range(start_year, end_year+1)))

gnt.axes.get_yaxis().set_ticks([])

# foreach minor tick delete the tick and center the label
for tick in gnt.xaxis.get_minor_ticks():
    tick.tick1line.set_markersize(0)
    tick.tick2line.set_markersize(0)
    tick.label1.set_horizontalalignment('center')

plt.savefig(fileout)