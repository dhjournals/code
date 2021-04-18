create temp table crossref_journals_tmp as
select distinct issn_p, issn_e
from crossref_pubs;

create table crossref_journals as
select row_number() over(order by issn_e desc) as journal_id, *
from crossref_journals_tmp;

create table crossref_pubs2 as
select a.*, b.journal_id
from crossref_pubs a 
join crossref_journals b on a.issn_p = b.issn_p and a.issn_e = b.issn_e;