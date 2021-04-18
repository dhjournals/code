begin -- [1] add DH percentage

	-- Get all DH pubs
	drop table if exists dh_pubs_intermediate;

	create temp table dh_pubs_intermediate as
	select distinct c.paper_id, a.level
	from dh_journals a
	join journals b on a.issn_e = b.issn
	join pubs c on b.journal_id = c.journal_id
	union
	select distinct c.paper_id, a.level
	from dh_journals a
	join journals b on a.issn_p = b.issn
	join pubs c on b.journal_id = c.journal_id;

	-- Get all DH pubs in clusters
	drop table if exists dh_pubs;

	create temp table dh_pubs as
	select distinct a.paper_id, a.level
	from dh_pubs_intermediate a
	join mag_pubs b on a.paper_id = b.pub_id
	join mag_clusters c on b.pub_no = c.node_id
	join vosviewer_mag_map d on c.cluster_id = d.id

	-- level 1
	drop table if exists dh_level1;
	
	create temp table dh_level1 as
	select 
		a.id,
		sum(case when c.paper_id is not null then 1 else 0 end) as "weight<dh pubs level 1>"
	from vosviewer_mag_map a
	left join mag_clusters b on a.id = b.cluster_id
	left join dh_pubs c on b.node_id = c.paper_id
	where level = 1
	group by a.id;

	-- level 2
	drop table if exists dh_level2;

	create temp table dh_level2 as
	select 
		a.id,
		sum(case when c.paper_id is not null then 1 else 0 end) as "weight<dh pubs level 2>"
	from vosviewer_mag_map a
	left join mag_clusters b on a.id = b.cluster_id
	left join dh_pubs c on b.node_id = c.paper_id
	where level = 2
	group by a.id;

	-- map
	drop table if exists mag_map;
	
	create temp table mag_map as
	select 
		a.id,
		case when b."weight<dh pubs level 1>" is not null then cast(b."weight<dh pubs level 1>" as float)/a.weight else 0 end as perc1,
		case when c."weight<dh pubs level 2>" is not null then cast(c."weight<dh pubs level 2>" as float)/a.weight else 0 end as perc2
	from vosviewer_mag_map a
	left join dh_level1 b on a.id = b.id
	left join dh_level2 c on a.id = c.id

	update vosviewer_mag_map
	set 
	"score<perc dh level 1>" = (select perc1 from mag_map a where vosviewer_mag_map.id = a.id),
	"score<perc dh level 2>" = (select perc2 from mag_map a where vosviewer_mag_map.id = a.id),
	"score<perc dh pubs>" = (select perc1+perc2 from mag_map a where vosviewer_mag_map.id = a.id)
	