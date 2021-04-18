-- Retrieve significant clusters
drop table if exists crossref_x_clusters;
create temp table crossref_x_clusters as
select cluster_id, count(*) as n_pubs
from crossref_clusters
group by cluster_id
having count(*) >= 50;

-- [1] add DH percentage
drop table if exists pub_dh;
create temp table pub_dh as
select distinct *
from (
	select a.doi, level
	from pubs a
	join dh_journals b on a.issn_p = b.issn_p
	union
	select a.doi, level
	from pubs a
	join dh_journals b on a.issn_e = b.issn_e
) as a;

-- 441.620
drop table if exists dh_dimensions_clusters;
create temp table dh_dimensions_clusters as
select distinct a.doi, b.pub_no, level
from pub_dh a
join only_pubs b on a.doi = b.doi
join crossref_clusters c on b.pub_no = c.node_id;

-- level 1
drop table if exists dh_level1;
create temp table dh_level1 as
select 
	a.cluster_id,
	sum(case when c.pub_no is not null then 1 else 0 end) as "weight<dh pubs level 1>"
from crossref_x_clusters a
left join crossref_clusters b on a.cluster_id = b.cluster_id
left join dh_dimensions_clusters c on b.node_id = c.pub_no
where level = 1
group by a.cluster_id

-- level 2
drop table if exists dh_level2;
create temp table dh_level2 as
select 
	a.cluster_id,
	sum(case when c.pub_no is not null then 1 else 0 end) as "weight<dh pubs level 2>"
from crossref_x_clusters a
left join crossref_clusters b on a.cluster_id = b.cluster_id
left join dh_dimensions_clusters c on b.node_id = c.pub_no
where level = 2
group by a.cluster_id

-- map
drop table if exists crossref_map;
create temp table crossref_map as
select 
	a.id,
	case when b."weight<dh pubs level 1>" is not null then cast(b."weight<dh pubs level 1>" as float)/a.weight else 0 end as perc1,
	case when c."weight<dh pubs level 2>" is not null then cast(c."weight<dh pubs level 2>" as float)/a.weight else 0 end as perc2
from vosviewer_crossref_map a
left join dh_level1 b on a.id = b.cluster_id
left join dh_level2 c on a.id = c.cluster_id

update vosviewer_crossref_map
set 
"score<perc dh level 1>" = (select perc1 from crossref_map a where vosviewer_crossref_map.id = a.id),
"score<perc dh level 2>" = (select perc2 from crossref_map a where vosviewer_crossref_map.id = a.id),
"score<perc dh pubs>" = (select perc1+perc2 from crossref_map a where vosviewer_crossref_map.id = a.id)