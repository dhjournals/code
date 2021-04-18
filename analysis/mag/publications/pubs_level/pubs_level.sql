-- Get all DH pubs
drop table if exists dh_pubs_intermediate;

create temp table dh_pubs_intermediate as
select distinct c.paper_id, a.level
from dh_journals a
join journals b on a.issn_e = b.issn
join pubs c on b.journal_id = c.journal_id
union
select distinct c.paper_id, a.level
from dh_journals a
join journals b on a.issn_p = b.issn
join pubs c on b.journal_id = c.journal_id;


-- Get all DH pubs in clusters and level <= 2
drop table if exists dh_pubs;

create temp table dh_pubs as
select distinct a.paper_id, a.level
from dh_pubs_intermediate a
join mag_pubs b on a.paper_id = b.pub_id
join mag_clusters c on b.pub_no = c.node_id
join vosviewer_mag_map d on c.cluster_id = d.id
where a.level <= 2;


-- Get the number of pubs divided per level
select level, count(*) as pubs
from dh_pubs
group by level
order by level asc;