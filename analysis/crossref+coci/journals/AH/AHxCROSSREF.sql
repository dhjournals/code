-- Get all DH pubs
drop table if exists ah_pubs;

create temp table ah_pubs as
select distinct b.doi, a.nsd_id, b.date
from erih_journals a
join pubs b on a.issn_p = b.issn_p
union
select distinct b.doi, a.nsd_id, b.date
from erih_journals a
join pubs b on a.issn_e = b.issn_e;

-- AH journals with pubs per year
drop table if exists years;
create temp table years as
SELECT DATE_PART('year', to_timestamp(a.date/1000)) as year, a.date from pubs_per_year as a;

drop table if exists tmp;
create temp table tmp as
select a.nsd_id, b.year, sum(a.pubs) as pubs
from pubs_per_year a
join years b on a.date = b.date
group by a.nsd_id, b.year;

select a.nsd_id, b.title, a.year, a.pubs
from tmp a
join erih_journals b on a.nsd_id = b.nsd_id
order by a.nsd_id, a.year asc;
