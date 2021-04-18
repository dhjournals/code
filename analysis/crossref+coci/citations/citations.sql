
begin -- [1] Get all DH pubs

	-- Get all DH pubs
	drop table if exists dh_pubs_intermediate;

	create temp table dh_pubs_intermediate as
	select distinct b.doi, a.level
	from dh_journals a
	join pubs b on a.issn_p = b.issn_p
	union
	select distinct b.doi, a.level
	from dh_journals a
	join pubs b on a.issn_e = b.issn_e;


	-- Get all DH pubs in clusters and level <= 2
	drop table if exists dh_pubs;

	create temp table dh_pubs as
	select distinct a.doi, a.level
	from dh_pubs_intermediate a
	join crossref_pubs b on a.doi = b.doi
	join crossref_clusters c on b.pub_no = c.node_id
	join vosviewer_crossref_map d on c.cluster_id = d.id
	where a.level <= 2;
end

begin -- [2] Get all DH pubs

	drop table if exists erih;
	
	create temp table erih as
	select * 
	from erih_journals a
	where a.nsd_id != '422484' and a.nsd_id != '341841' and a.nsd_id != '470652';

	-- Get all AH pubs
	drop table if exists ah_pubs_intermediate;
	
	create temp table ah_pubs_intermediate as
	select b.doi, a.nsd_id
	from erih a
	join pubs b on a.issn_e = b.issn_e 
	union
	select b.doi, a.nsd_id
	from erih a
	join pubs b on a.issn_p = b.issn_p;

	-- Get all pubs per cluster
	drop table if exists ah_pubs;
	
	create temp table ah_pubs as
	select distinct d.id, a.*
	from ah_pubs_intermediate a
	join crossref_pubs b on a.doi = b.doi
	join crossref_clusters c on b.pub_no = c.node_id
	join vosviewer_crossref_map d on c.cluster_id = d.id;
	
	drop table if exists ah_dh_pubs;
	
	create temp table ah_dh_pubs as
	select distinct a.doi, 'Digital Humanities' as discipline
	from ah_pubs a
	join dh_pubs b on a.doi = b.doi;
	
	-- Calculate pub weight based on the number of disciplines
	drop table if exists ah_pubs_w;
	
	create temp table ah_pubs_w as
	select a.doi, cast(1 as float)/b.tot as w
	from ah_pubs a
	join (
		select a.doi, count(*) as tot
		from (
			select a.doi, c.discipline_name as discipline
			from ah_pubs a
			join erih_journals_disciplines b on a.nsd_id = b.journal_id
			join erih_disciplines c on b.discipline_id = c.discipline_id
			left join ah_dh_pubs d on a.doi = d.doi
			where d.doi is null
		)a group by a.doi
	) b on a.doi = b.doi;
	
	-- Final AH pubs with weight and discipline
	drop table if exists ah_pubs_final;
	
	create temp table ah_pubs_final as
	select a.doi, b.w, d.discipline_name as discipline, d.type
	from ah_pubs a
	join ah_pubs_w b on a.doi = b.doi
	join erih_journals_disciplines c on a.nsd_id = c.journal_id
	join erih_disciplines d on c.discipline_id = d.discipline_id;
	
end

begin -- [3] Citations from ERIH disciplines to DH pubs

	-- Get all pubs citing from DH pubs
	drop table if exists outgoing_cited_pubs;

    create temp table outgoing_cited_pubs as
	select distinct b.cited as doi
	from dh_pubs a
	join coci_citations b on a.doi = b.citing;
	
	-- Get the total number of citations, normalized by the disciplines
	drop table if exists outgoing_cited_pubs_ah;

    create temp table outgoing_cited_pubs_ah as
	select distinct b.doi, b.discipline, b.w, b.type
	from outgoing_cited_pubs a
	join ah_pubs_final b on a.doi = b.doi;
	
	-- Get DH only cited pubs
	drop table if exists outgoing_cited_pubs_dh;

    create temp table outgoing_cited_pubs_dh as
	select distinct a.doi, 'Digital Humanities' as discipline, cast(1 as float) as w, 'dh' as type
	from outgoing_cited_pubs a
	join dh_pubs b on a.doi = b.doi;

	-- get Other pubs
	drop table if exists outgoing_cited_pubs_other;

    create temp table outgoing_cited_pubs_other as
	select distinct a.doi, 'Other' as discipline, cast(1 as float) as w, 'other' as type
	from outgoing_cited_pubs a
	left join outgoing_cited_pubs_ah b on a.doi = b.doi
	left join outgoing_cited_pubs_dh c on a.doi = c.doi
	where b.doi is null and c.doi is null;
	
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

begin -- [4] Citations from ERIH disciplines to DH pubs

	-- Get all pubs cited from DH pubs
	drop table if exists ingoing_cited_pubs;

    create temp table ingoing_cited_pubs as
	select distinct b.citing as doi
	from dh_pubs a
	join coci_citations b on a.doi = b.cited;

	-- Get AH cited pubs
	drop table if exists ingoing_cited_pubs_ah;

    create temp table ingoing_cited_pubs_ah as
	select distinct a.doi, b.discipline, b.w, b.type
	from ingoing_cited_pubs a
	join ah_pubs_final b on a.doi = b.doi;
	
	-- Get DH only cited pubs
	drop table if exists ingoing_cited_pubs_dh;

    create temp table ingoing_cited_pubs_dh as
	select distinct a.doi, 'Digital Humanities' as discipline, cast(1 as float) as w, 'dh' as type
	from ingoing_cited_pubs a
	join dh_pubs b on a.doi = b.doi;
	
	-- get Other pubs
	drop table if exists ingoing_cited_pubs_other;

    create temp table ingoing_cited_pubs_other as
	select distinct a.doi, 'Other' as discipline, cast(1 as float) as w, 'other' as type
	from ingoing_cited_pubs a
	left join ingoing_cited_pubs_ah b on a.doi = b.doi
	left join ingoing_cited_pubs_dh c on a.doi = c.doi
	where b.doi is null and c.doi is null;
	
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



















