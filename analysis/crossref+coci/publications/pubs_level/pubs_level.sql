-- Get all DH pubs
drop table if exists dh_pubs_intermediate;

create temp table dh_pubs_intermediate as
select distinct b.doi, a.level
from dh_journals a
join pubs b on a.issn_p = b.issn_p
union
select distinct b.doi, a.level
from dh_journals a
join pubs b on a.issn_e = b.issn_e;


-- Get all DH pubs in clusters and level <= 2
drop table if exists dh_pubs;

create temp table dh_pubs as
select distinct a.doi, a.level
from dh_pubs_intermediate a
join crossref_pubs b on a.doi = b.doi
join crossref_clusters c on b.pub_no = c.node_id
join vosviewer_crossref_map d on c.cluster_id = d.id
where a.level <= 2;


-- Get the number of pubs divided per level
select level, count(*) as pubs
from dh_pubs
group by level
order by level asc;