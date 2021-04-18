-- Get top 10 clusters with the highest percentage of DH pubs
drop table if exists clusters;

create temp table clusters as
select id, "score<perc dh pubs>"
from vosviewer_mag_map 
where "score<perc dh pubs>" > 0
order by "score<perc dh pubs>" desc
limit 10;

-- Get all DH pubs that are in clusters
select distinct a.id, d.paper_title as title
from clusters a
join mag_clusters b on a.id = b.cluster_id
join mag_pubs c on b.node_id = c.pub_no
join pubs d on c.pub_id = d.paper_id
order by id asc