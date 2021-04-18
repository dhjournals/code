-- Get all DH pubs
drop table if exists dh_pubs_intermediate;

create temp table dh_pubs_intermediate as
select distinct c.paper_id, a.level, a.id, c.year
from dh_journals a
join journals b on a.issn_e = b.issn
join pubs c on b.journal_id = c.journal_id
union
select distinct c.paper_id, a.level, a.id, c.year
from dh_journals a
join journals b on a.issn_p = b.issn
join pubs c on b.journal_id = c.journal_id;


drop table if exists pubs_per_year;
create temp table pubs_per_year as
select a.id, a.year, count(*) as pubs
from dh_pubs_intermediate a
group by a.id, a.year;

select a.id, b.title, a.year, a.pubs, b.level
from pubs_per_year a
join dh_journals b on a.id = b.id
where level <= 2
order by a.id, a.year asc;