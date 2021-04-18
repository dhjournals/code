-- Get top 10 clusters with the highest percentage of DH pubs
drop table if exists clusters;

create temp table clusters as
select id, "score<perc dh pubs>"
from vosviewer_crossref_map 
order by "score<perc dh pubs>" desc
limit 10;

-- Get all DH pubs that are in clusters
select distinct a.id, d.title
from clusters a
join crossref_clusters b on a.id = b.cluster_id
join crossref_pubs c on b.node_id = c.pub_no
join pubs d on c.doi = d.doi
order by id asc