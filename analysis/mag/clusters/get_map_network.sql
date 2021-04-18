-- [1] Get clusters file
create temp table significant_clusters as
select cluster_id, count(*) as pubs
from mag_clusters
group by cluster_id
having count(*) >= 50

select 
	cluster_id as id,
	row_number() over (order by pubs desc) -1 as label,
	pubs as weight
from significant_clusters

-- [2] Get network file
create temp table network as
select 
	a.cluster_id as cluster1,
	e.cluster_id as cluster2,
	count(b.node_id) as strength
from significant_clusters a
join mag_clusters b on a.cluster_id = b.cluster_id
join mag_network c on b.node_id = c.pub_no1
join mag_clusters d on c.pub_no2 = d.node_id
join significant_clusters e on d.cluster_id = e.cluster_id
where a.cluster_id != e.cluster_id
group by a.cluster_id, e.cluster_id

create temp table network_norm as
select cluster1, sum(strength) as total
from network
group by cluster1

select a.cluster1, a.cluster2, cast(a.strength as float) / b.total as strength_norm
from network a
join network_norm b on a.cluster1 = b.cluster1