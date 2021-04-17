-- Get all the coci citations of crossref pubs
-- 500.783.162
create table coci_x_crossref as
select distinct a.citing, a.cited
from coci_citations a
join crossref_pubs b on a.citing = b.doi
join crossref_pubs c on a.cited = c.doi

-- Get publications with its 0-index number
-- 43.092.889
create table only_pubs as
select distinct row_number() over (order by doi desc) -1 as pub_no, doi
from (	
	select citing as doi
	from coci_x_crossref 
	union
	select cited as doi
	from coci_x_crossref
) as a

-- Save the number of citation from every doi
-- 24.300.708
create table pub_norm as
select distinct citing as doi, count(*) as n_cit_relations 
from coci_x_crossref
group by citing

-- get final
-- 500.651.018
create table crossref_network as
select distinct 
	case when b.pub_no < c.pub_no then b.pub_no else c.pub_no end as pub_no1,
	case when b.pub_no > c.pub_no then b.pub_no else c.pub_no end as pub_no2,
from coci_x_crossref a
join only_pubs b on a.citing = b.doi
join only_pubs c on a.cited = c.doi

select count(*) from crossref_network

-- 36.073.586
create table weight as
select pub_no1 as citing, count(*) as w
from crossref_network 
group by pub_no1

-- Get final with weights
-- 500.651.018
create table crossref_network_weighted as
select 
	a.pub_no1,
	a.pub_no2,
	cast(1 as float) / b.w as weight
from crossref_network a
join weight b on a.pub_no1 = b.citing 