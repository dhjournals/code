drop table if exists erih;

create temp table erih as
select * 
from erih_journals a
where a.nsd_id != '422484' and a.nsd_id != '341841' and a.nsd_id != '470652';

-- Get all AH pubs
drop table if exists ah_pubs_intermediate;

create temp table ah_pubs_intermediate as
select c.paper_id, a.nsd_id
from erih a
join journals b on a.issn_p = b.issn
join pubs c on b.journal_id = c.journal_id
union
select c.paper_id, a.nsd_id
from erih a
join journals b on a.issn_e = b.issn
join pubs c on b.journal_id = c.journal_id;

-- Get all pubs per cluster
drop table if exists ah_pubs;

create temp table ah_pubs as
select distinct d.id, a.*
from ah_pubs_intermediate a
join mag_pubs b on a.paper_id = b.pub_id
join mag_clusters c on b.pub_no = c.node_id
join vosviewer_mag_map d on c.cluster_id = d.id;

-- Calculate pub weight based on the number of disciplines
drop table if exists ah_pubs_w;

create temp table ah_pubs_w as
select a.paper_id, cast(1 as float)/b.tot as w
from ah_pubs a
join (
	select a.paper_id, count(*) as tot
	from (
		select a.paper_id, c.discipline_name as discipline
		from ah_pubs a
		join erih_journals_disciplines b on a.nsd_id = b.journal_id
		join erih_disciplines c on b.discipline_id = c.discipline_id
	)a group by a.paper_id
) b on a.paper_id = b.paper_id;

-- Final AH pubs with weight and discipline
drop table if exists ah_pubs_final;

create temp table ah_pubs_final as
select a.paper_id, b.w, d.discipline_name as discipline, d.type
from ah_pubs a
join ah_pubs_w b on a.paper_id = b.paper_id
join erih_journals_disciplines c on a.nsd_id = c.journal_id
join erih_disciplines d on c.discipline_id = d.discipline_id


select a.discipline, a.pubs, c.type
from (
	select discipline, cast(sum(w) as int) as pubs
	from ah_pubs_final 
	group by discipline
) a
join erih_disciplines c on a.discipline = c.discipline_name
order by pubs desc