This repository is related to the paper **TITLE HERE**.

It contains the code to extract publications from Crossref and Microsoft Academics within 1st January 2000 and 31st December 2018. 
Since the data are massive, the pipeline for iterating through uses first MongoDB because of its efficiency, but then we need a function proper of SQL databases, so the second part need a PostgreSQL database.

**Note:** The pipeline has been created using bash files, therefore it will not work on Windows.

## CROSSREF

The data from CROSSREF have been downloaded from here:

* link crossref
* link coci

1. First download both datasets and, for each of them, unzip the archive inside a new folder with its name. E.g. data from coci must be unzipped inside the folder `1_crossref/coci` in the root. Crossref must be unzipped inside the folder `1_crossref/crossref`.

2. Create a mongodb database. The script assumes:
    1. The database to installed on local machine. 
    2. The port is the default `27017`
    3. The database name is 'crossref'
    4. the collections are called 'citations' in the case of coci, 'pubs' in the case of crossref
    
3. Create a PostgreSQL database

4. Activate the conda environment from the yaml file in root

5. Execute both scripts in `1_crossref/1_dump_to_mongo`. They will populate the MongoDB database.

6. Execute bash files in `1_crossref/2_mongo_to_csv`. They will export the data in MongoDB into csv format

7. Manually upload both tables into PostgreSQL. It will create the tables `crossref_pubs` and `coci_citations`.

8. Execute the SQL code in `1_crossref/3_export/export.sql`. 

9. Export results from `crossref_network` table or `crossref_network_weighted`. The second table weights the relation between the two.

Once the data are exported, you can use the [Leiden Algorithm](https://github.com/CWTSLeiden/networkanalysis) to create clusters.

