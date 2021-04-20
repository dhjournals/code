import matplotlib.pyplot as plt

from venn import venn
from matplotlib.pyplot import subplots
from matplotlib_venn import venn2, venn2_circles, venn2_unweighted

from csv import DictReader

def single_venn():
    venn(dois, cmap=['r','g','b','y','purple'])
    plt.show()

def mutiple_venn():

    for k,v in dois.items():
        _, ax = subplots(ncols=4, nrows=1, figsize=(18, 5))
        col=0
        for k2,v2 in dois.items():
            if k!=k2:
                venn2(subsets = (v, v2), set_labels = (k, k2), set_colors=(colors[k], colors[k2]), alpha = 0.5,ax=ax[col])
                col+=1
        plt.show()

CROSSREF='Crossref+COCI'
DIMENSIONS='Dimensions'
MAG='MS Academics'
SCOPUS='Scopus'
WOS='Web of Science'

colors = {
    CROSSREF: 'r',
    DIMENSIONS: 'g',
    MAG: 'b',
    SCOPUS: 'y',
    WOS: 'purple',
}

with open('../crossref+coci/publications/dois.tsv') as f:
    rdr = DictReader(f, delimiter='\t')
    doi_crossref = set([row['doi'] for row in rdr])

with open('../dimensions/publications/dois.tsv') as f:
    rdr = DictReader(f, delimiter='\t')
    doi_dimension = set([row['doi'] for row in rdr])

with open('../mag/publications/dois.tsv') as f:
    rdr = DictReader(f, delimiter='\t')
    doi_mag = set([row['doi'] for row in rdr])

with open('../scopus/publications/dois.tsv') as f:
    rdr = DictReader(f, delimiter='\t')
    doi_scopus = set([row['doi'] for row in rdr])

with open('../wos/publications/dois.tsv') as f:
    rdr = DictReader(f, delimiter='\t')
    doi_wos = set([row['doi'] for row in rdr])

dois = {
    CROSSREF: doi_crossref,
    DIMENSIONS: doi_dimension,
    MAG: doi_mag,
    SCOPUS: doi_scopus,
    WOS: doi_wos
}

single_venn()


mutiple_venn()
