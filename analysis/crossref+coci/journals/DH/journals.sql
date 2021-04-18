-- Get all DH pubs
drop table if exists dh_pubs_intermediate;

create temp table dh_pubs_intermediate as
select distinct b.doi, a.level, a.id, b.date
from dh_journals a
join pubs b on a.issn_p = b.issn_p
union
select distinct b.doi, a.level, a.id, b.date
from dh_journals a
join pubs b on a.issn_e = b.issn_e;

-- AH journals with pubs per year
drop table if exists pubs_per_year;
create temp table pubs_per_year as
select a.id, a.date, count(*) as pubs
from dh_pubs_intermediate a
group by a.id, a.date;

-- Final with titles
drop table if exists years;
create temp table years as
SELECT DATE_PART('year', to_timestamp(a.date/1000)) as year, a.date from pubs_per_year as a;

drop table if exists tmp;
create temp table tmp as
select a.id, b.year, sum(a.pubs) as pubs
from pubs_per_year a
join years b on a.date = b.date
group by a.id, b.year;

select a.id, b.title, a.year, a.pubs, b.level
from tmp a
join dh_journals b on a.id = b.id
where level <= 2
order by a.id, a.year asc;


