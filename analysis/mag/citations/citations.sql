begin -- [1] Get all DH pubs

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


	-- Get all DH pubs in clusters and level <= 2
	drop table if exists dh_pubs;

	create temp table dh_pubs as
	select distinct a.paper_id, a.level
	from dh_pubs_intermediate a
	join mag_pubs b on a.paper_id = b.pub_id
	join mag_clusters c on b.pub_no = c.node_id
	join vosviewer_mag_map d on c.cluster_id = d.id
	where a.level <= 2;
	
end

begin -- [2] Get all AH pubs

	-- Get all AH pubs
	drop table if exists ah_pubs_intermediate;
	
	create temp table ah_pubs_intermediate as
	select c.paper_id, a.nsd_id
	from erih_journals a
	join journals b on a.issn_p = b.issn
	join pubs c on b.journal_id = c.journal_id
	union
	select c.paper_id, a.nsd_id
	from erih_journals a
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
	
	-- Get all pubs in both sets
	drop table if exists ah_dh_pubs;
	
	create temp table ah_dh_pubs as
	select distinct a.paper_id, 'Digital Humanities' as discipline
	from ah_pubs a
	join dh_pubs b on a.paper_id = b.paper_id;
	
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
			left join ah_dh_pubs d on a.paper_id = d.paper_id
			where d.paper_id is null
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
	
end

begin -- [3] Citations from ERIH disciplines to DH pubs

	-- Get all pubs citing from DH pubs
	drop table if exists outgoing_cited_pubs;

    create temp table outgoing_cited_pubs as
	select distinct b.cited_id as paper_id
	from dh_pubs a
	join cit b on a.paper_id = b.citing_id;
	
	-- Get AH cited pubs
	drop table if exists outgoing_cited_pubs_ah;

    create temp table outgoing_cited_pubs_ah as
	select distinct a.paper_id, b.discipline, b.w, b.type
	from outgoing_cited_pubs a
	join ah_pubs_final b on a.paper_id = b.paper_id;
	
	-- Get DH only cited pubs
	drop table if exists outgoing_cited_pubs_dh;

    create temp table outgoing_cited_pubs_dh as
	select distinct a.paper_id, 'Digital Humanities' as discipline, cast(1 as float) as w, 'dh' as type
	from outgoing_cited_pubs a
	join dh_pubs b on a.paper_id = b.paper_id
	
	-- get Other pubs
	drop table if exists outgoing_cited_pubs_other;

    create temp table outgoing_cited_pubs_other as
	select distinct a.paper_id, 'Other' as discipline, cast(1 as float) as w, 'other' as type
	from outgoing_cited_pubs a
	left join outgoing_cited_pubs_ah b on a.paper_id = b.paper_id
	left join outgoing_cited_pubs_dh c on a.paper_id = c.paper_id
	where b.paper_id is null and c.paper_id is null;
	
	-- Pull all togheter
	drop table if exists outgoing_cited_pubs_all_final;
	
	create temp table outgoing_cited_pubs_all_final as
	select * from outgoing_cited_pubs_other
	union
	select * from outgoing_cited_pubs_dh
	union
	select * from outgoing_cited_pubs_ah;

	-- Final result
	select distinct
		a.discipline,
		cast(a.perc as float) / b.tot * 100 as perc,
		case when a.discipline = 'Digital Humanities' then 'dh' else c.type end as type
	from (
		select discipline, sum(w) as perc
		from outgoing_cited_pubs_all_final 
		group by discipline
	) a
	join (select sum(w) as tot from outgoing_cited_pubs_all_final) b on 1=1
	join outgoing_cited_pubs_all_final c on a.discipline = c.discipline
	order by perc desc;

		-- Pull all togheter [No Other]
	drop table if exists outgoing_cited_pubs_final;
	
	create temp table outgoing_cited_pubs_final as
	select * from outgoing_cited_pubs_dh
	union
	select * from outgoing_cited_pubs_ah;

	-- Final result
	select distinct
		a.discipline,
		cast(a.perc as float) / b.tot * 100 as perc,
		case when a.discipline = 'Digital Humanities' then 'dh' else c.type end as type
	from (
		select discipline, sum(w) as perc
		from outgoing_cited_pubs_final 
		group by discipline
	) a
	join (select sum(w) as tot from outgoing_cited_pubs_final) b on 1=1
	join outgoing_cited_pubs_final c on a.discipline = c.discipline
	order by perc desc;

end

begin -- [4] Citations from DH pubs

	-- Get all pubs citing from DH pubs
	drop table if exists ingoing_cited_pubs;

    create temp table ingoing_cited_pubs as
	select distinct b.citing_id as paper_id
	from dh_pubs a
	join cit b on a.paper_id = b.cited_id;
	
	-- Get AH cited pubs
	drop table if exists ingoing_cited_pubs_ah;

    create temp table ingoing_cited_pubs_ah as
	select distinct a.paper_id, b.discipline, b.w, b.type
	from ingoing_cited_pubs a
	join ah_pubs_final b on a.paper_id = b.paper_id;
	
	-- Get DH only cited pubs
	drop table if exists ingoing_cited_pubs_dh;

    create temp table ingoing_cited_pubs_dh as
	select distinct a.paper_id, 'Digital Humanities' as discipline, cast(1 as float) as w, 'dh' as type
	from ingoing_cited_pubs a
	join dh_pubs b on a.paper_id = b.paper_id
	
	-- get Other pubs
	drop table if exists ingoing_cited_pubs_other;

    create temp table ingoing_cited_pubs_other as
	select distinct a.paper_id, 'Other' as discipline, cast(1 as float) as w, 'other' as type
	from ingoing_cited_pubs a
	left join ingoing_cited_pubs_ah b on a.paper_id = b.paper_id
	left join ingoing_cited_pubs_dh c on a.paper_id = c.paper_id
	where b.paper_id is null and c.paper_id is null;
	
	-- Pull all togheter
	drop table if exists ingoing_cited_pubs_all_final;
	
	create temp table ingoing_cited_pubs_all_final as
	select * from ingoing_cited_pubs_other
	union
	select * from ingoing_cited_pubs_dh
	union
	select * from ingoing_cited_pubs_ah;

	-- Final result
	select distinct
		a.discipline,
		cast(a.perc as float) / b.tot * 100 as perc,
		case when a.discipline = 'Digital Humanities' then 'dh' else c.type end as type
	from (
		select discipline, sum(w) as perc
		from ingoing_cited_pubs_all_final 
		group by discipline
	) a
	join (select sum(w) as tot from ingoing_cited_pubs_all_final) b on 1=1
	join ingoing_cited_pubs_all_final c on a.discipline = c.discipline
	order by perc desc;

		-- Pull all togheter [No Other]
	drop table if exists ingoing_cited_pubs_final;
	
	create temp table ingoing_cited_pubs_final as
	select * from ingoing_cited_pubs_dh
	union
	select * from ingoing_cited_pubs_ah;

	-- Final result
	select distinct
		a.discipline,
		cast(a.perc as float) / b.tot * 100 as perc,
		case when a.discipline = 'Digital Humanities' then 'dh' else c.type end as type
	from (
		select discipline, sum(w) as perc
		from ingoing_cited_pubs_final 
		group by discipline
	) a
	join (select sum(w) as tot from ingoing_cited_pubs_final) b on 1=1
	join ingoing_cited_pubs_final c on a.discipline = c.discipline
	order by perc desc;

end