-- Get publications with its 0-index number
-- 30.051.825
create table only_pubs as
select distinct row_number() over (order by pub_id desc) -1 as pub_no, pub_id
from (	
	select citing_id as pub_id
	from cit 
	union
	select cited_id as pub_id
	from cit
) as a

--FROM HERE

-- Save the number of citation from every doi
-- 11.711.722
create table pub_norm as
select distinct citing_id as doi, count(*) as n_cit_relations 
from cit
group by citing_id

-- get final
-- 154.700.710
create table mag_network as
select distinct 
	case when b.pub_no < c.pub_no then b.pub_no else c.pub_no end as pub_no1,
	case when b.pub_no > c.pub_no then b.pub_no else c.pub_no end as pub_no2
from cit a
join only_pubs b on a.citing_id = b.pub_id
join only_pubs c on a.cited_id = c.pub_id

-- 21.822.703
create table weight as
select pub_no1 as citing, count(*) as w
from mag_network 
group by pub_no1

-- Get final with weights
-- 154.700.710
create table mag_network_weighted as
select 
	a.pub_no1,
	a.pub_no2,
	cast(1 as float) / b.w as weight
from mag_network a
join weight b on a.pub_no1 = b.citing 

-- export
\copy (select distinct * from mag_network_weighted order by pub_no1, pub_no2 asc) to '~/Projects/mag_thesis/export/mag_network.txt' csv delimiter E'\t'