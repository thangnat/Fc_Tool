/*
	exec sp_validate_FM_Baseline 'LDB','202407','BOM_TEMPLATE'

	/*
		type compare
			FM_OFFLINE-->(Baseline) ignore LUMF
			FM_ONLINE-->(ALL) ignore LUMF
			FM_BOM_OFFLINE
			FM_BOM_ONLINE
			BOM_TEMPLATE
			FM_Non_Modelling-->(ONELINE,OFFLINE)
			Template_Launch-->(OFFLINE)
			Template_FOC-->(OFFLINE)
			Template_Promo_Single-->(OFFLINE)
	*/
	--check bom father contains how much component?
	select * from v_zmr32 where Material_Bom='VVN03236'
	--find out Bom father from child bom
	select * from FC_SI_Promo_Bom_LDB where [Bundle Code] in(select Material_Bom from v_zmr32 where Barcode_Component='3337875734905' and Division='LDB')
	--check bom father belong on online,offline,template?
	select * from FC_LIST_BOM_HEADER_ALL_LDB where [Bundle code]='VVN03236'
*/

Alter proc sp_validate_FM_Baseline
	@Division		nvarchar(3),
	@FM_Key			nvarchar(6),
	@TypeCompare	nvarchar(30)
	with encryption
As
declare @debug int=0
declare @sql nvarchar(max)=''
declare @listcolumn nvarchar(max)=''
declare @listcolumnPlus nvarchar(max)=''

select @listcolumn=ListColumn from fn_FC_GetColheader_Current(@FM_Key,'1. Baseline qty','f')
--select listcolumn=ListColumn from fn_FC_GetColheader_Current('202407','1. Baseline qty_','f')
select @listcolumnPlus=ListColumn from fn_FC_GetColheader_Current(@FM_Key,'1. Baseline qty_+','f')
--select listcolumnPlus=ListColumn from fn_FC_GetColheader_Current('202407','1. Baseline qty_+','f')

declare @SaleOrg nvarchar(4)=''

select @debug=debug from fnc_debug('FC')
select @debug=1
declare @Monthfc				nvarchar(20)=''
select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from V_FC_FM_Table

if @TypeCompare='FM_OFFLINE'
begin
	select @sql='
	select
		[Ref. Code],
		[SUB GROUP/ Brand],
		Channel,
		[Time series],
		[FM TotalQty],
		[WF TotalQty],
		[Not match]=[FM TotalQty]-[WF TotalQty]
	from
	(
		select 
			f1.[Ref. Code],
			f.[SUB GROUP/ Brand],
			f.Channel,
			f.[Time series],
			[FM TotalQty]=sum(f.TotalQty),
			[WF TotalQty]=sum(f1.TotalQty)
		from 
		(
			select
				[SUB GROUP/ Brand],
				Channel=[Local Level],
				[Time series],
				'+@listcolumn+',
				TotalQty=('+@listcolumnPlus+')
			from
			(
				select
					*
				from 
				(
					select * from FC_FM_SUM_BASELINE_OFFLINE_'+@Division+@Monthfc+'
				) as x
				where x.[Time series] in(''1. Baseline Qty'')
			) as f
		) f
		left join
		(
			select
				[Ref. Code],
				[SUB GROUP/ Brand],
				Channel,
				[Time series],
				'+@listcolumn+',
				TotalQty=('+@listcolumnPlus+')
			from FC_FM_Original_'+@Division+@Monthfc+' f
			where 
				[Time series] in(''1. Baseline Qty'')
			and Channel IN(''OFFLINE'')
		) f1 on 
			f1.[SUB GROUP/ Brand]=f.[SUB GROUP/ Brand]
		and f1.Channel=f.Channel
		and f1.[Time series]=f.[Time series]
		group by
			f1.[Ref. Code],
			f.[SUB GROUP/ Brand],
			f.Channel,
			f.[Time series]
	) as z	
	where ([FM TotalQty]-[WF TotalQty])<>0 '
end
else if @TypeCompare='FM_ONLINE'
begin
	select @sql='
	select
		[Ref. Code],
		[SUB GROUP/ Brand],
		Channel,
		[Time series],
		[FM TotalQty],
		[WF TotalQty],
		[Not match]=[FM TotalQty]-[WF TotalQty]
	from
	(
		select 
			f1.[Ref. Code],
			f.[SUB GROUP/ Brand],
			f.Channel,
			f.[Time series],
			[FM TotalQty]=sum(f.TotalQty),
			[WF TotalQty]=sum(f1.TotalQty)
		from 
		(
			select
				[SUB GROUP/ Brand],
				Channel=[Local Level],
				[Time series],
				'+@listcolumn+',
				TotalQty=('+@listcolumnPlus+')
			from
			(
				select
					*
				from 
				(
					select
						* 
					from FC_FM_SUM_BASELINE_ONLINE_'+@Division+@Monthfc+'
				) as x
			) as f
		) f
		left join
		(
			select
				[Ref. Code],
				[SUB GROUP/ Brand],
				Channel,
				[Time series],
				'+@listcolumn+',
				TotalQty=('+@listcolumnPlus+')
			from FC_FM_Original_'+@Division+@Monthfc+' f
			where 
				Channel IN(''ONLINE'')
			and [Time series] NOT IN(''6. Total Qty'')
		) f1 on 
			f1.[SUB GROUP/ Brand]=f.[SUB GROUP/ Brand]
		and f1.Channel=f.Channel
		and f1.[Time series]=f.[Time series]
		group by
			f1.[Ref. Code],
			f.[SUB GROUP/ Brand],
			f.Channel,
			f.[Time series]
	) as z
	where ([FM TotalQty]-[WF TotalQty])<>0 '
end
else if @TypeCompare='FM_BOM_ONLINE'
begin
	exec sp_Get_Bom_raw_Component @Division,@FM_Key,@TypeCompare
	select @sql='
	select
		[Ref. Code],
		[SUB GROUP/ Brand],
		Channel,
		[Time series],
		[FM TotalQty],
		[WF TotalQty],
		[Not match]=[FM TotalQty]-[WF TotalQty]
	from
	(
		select 
			f1.[Ref. Code],
			f.[SUB GROUP/ Brand],
			f.Channel,
			f.[Time series],
			[FM TotalQty]=sum(f.TotalQty),
			[WF TotalQty]=sum(f1.TotalQty)
		from 
		(
			select
				[SUB GROUP/ Brand],
				Channel=[Channel],
				[Time series],
				'+@listcolumn+',
				TotalQty=('+@listcolumnPlus+')
			from
			(
				select
					*
				from 
				(
					select * 
					from Bom_raw_Component_'+@Division+'
				) as x
			) as f
		) f
		left join
		(
			select
				[Ref. Code],
				[SUB GROUP/ Brand],
				Channel,
				[Time series],
				'+@listcolumn+',
				TotalQty=('+@listcolumnPlus+')
			from FC_FM_Original_'+@Division+@Monthfc+' f
			where 
				Channel IN(''ONLINE'')
			and [Time series] IN(''3. Promo Qty(BOM)'')
		) f1 on 
			f1.[SUB GROUP/ Brand]=f.[SUB GROUP/ Brand]
		and f1.Channel=f.Channel
		and f1.[Time series]=f.[Time series]
		group by
			f1.[Ref. Code],
			f.[SUB GROUP/ Brand],
			f.Channel,
			f.[Time series]
	) as z
	where ([FM TotalQty]-[WF TotalQty])<>0 '
end
else if @TypeCompare='BOM_TEMPLATE'
begin
	exec sp_Get_Bom_raw_Component @Division,@FM_Key,@TypeCompare
	select @sql='
	select
		[Ref. Code],
		[SUB GROUP/ Brand],
		Channel,
		[Time series],
		[FM TotalQty],
		[WF TotalQty],
		[Not match]=[FM TotalQty]-[WF TotalQty]
	from
	(
		select 
			f1.[Ref. Code],
			f.[SUB GROUP/ Brand],
			f.Channel,
			f.[Time series],
			[FM TotalQty]=sum(f.TotalQty),
			[WF TotalQty]=sum(f1.TotalQty)
		from 
		(
			select
				[SUB GROUP/ Brand],
				Channel=[Channel],
				[Time series],
				'+@listcolumn+',
				TotalQty=('+@listcolumnPlus+')
			from
			(
				select
					*
				from 
				(
					select * 
					from Bom_raw_Component_'+@Division+'
				) as x
			) as f
		) f
		left join
		(
			select
				[Ref. Code],
				[SUB GROUP/ Brand],
				Channel,
				[Time series],
				'+@listcolumn+',
				TotalQty=('+@listcolumnPlus+')
			from FC_FM_Original_'+@Division+@Monthfc+' f
			where 
				Channel IN(''OFFLINE'')
			and [Time series] IN(''3. Promo Qty(BOM)'')
		) f1 on 
			f1.[SUB GROUP/ Brand]=f.[SUB GROUP/ Brand]
		and f1.Channel=f.Channel
		and f1.[Time series]=f.[Time series]
		group by
			f1.[Ref. Code],
			f.[SUB GROUP/ Brand],
			f.Channel,
			f.[Time series]
	) as z
	where ([FM TotalQty]-[WF TotalQty])<>0 '
end
else if @TypeCompare='FM_Non_Modelling'
begin
	select @sql='
	select
		[Ref. Code],
		[SUB GROUP/ Brand],
		Channel,
		[Time series],
		[FM TotalQty],
		[WF TotalQty],
		[Not match]=[FM TotalQty]-[WF TotalQty]
	from
	(
		select 
			f1.[Ref. Code],
			f.[SUB GROUP/ Brand],
			f.Channel,
			f.[Time series],
			[FM TotalQty]=sum(f.TotalQty),
			[WF TotalQty]=sum(f1.TotalQty)
		from 
		(
			select
				[SUB GROUP/ Brand],
				Channel=[Local Level],
				[Time series],
				'+@listcolumn+',
				TotalQty=('+@listcolumnPlus+')
			from
			(
				select
					*
				from 
				(
					select * 
					from FC_FM_Non_modeling_Final_'+@Division+'
				) as x
			) as f
		) f
		left join
		(
			select
				[Ref. Code],
				[SUB GROUP/ Brand],
				Channel,
				[Time series],
				'+@listcolumn+',
				TotalQty=('+@listcolumnPlus+')
			from FC_FM_Original_'+@Division+@Monthfc+' f
			where 
				Channel IN(''OFFLINE'',''ONLINE'')
			and [Time series] NOT IN(''1. Baseline Qty'',''2. Promo Qty(Single)'',''4. Launch Qty'',''5. FOC Qty'')
		) f1 on 
			f1.[SUB GROUP/ Brand]=f.[SUB GROUP/ Brand]
		and f1.Channel=f.Channel
		and f1.[Time series]=f.[Time series]
		group by
			f1.[Ref. Code],
			f.[SUB GROUP/ Brand],
			f.Channel,
			f.[Time series]
	) as z
	where ([FM TotalQty]-[WF TotalQty])<>0 '
end
else if @TypeCompare='Template_Launch'
begin
	select @sql='
	select
		[Ref. Code],
		[SUB GROUP/ Brand],
		Channel,
		[Time series],
		[FM TotalQty],
		[WF TotalQty],
		[Not match]=[FM TotalQty]-[WF TotalQty]
	from
	(
		select 
			f1.[Ref. Code],
			f.[SUB GROUP/ Brand],
			f.Channel,
			f.[Time series],
			[FM TotalQty]=sum(f.TotalQty),
			[WF TotalQty]=sum(f1.TotalQty)
		from 
		(
			select
				[SUB GROUP/ Brand]=[SubGrp],
				Channel=[Channel],
				[Time series],
				'+@listcolumn+',
				TotalQty=('+@listcolumnPlus+')
			from
			(
				select
					*
				from 
				(
					select * 
					from FC_SI_Launch_Single_'+@Division+'
				) as x
			) as f
		) f
		left join
		(
			select
				[Ref. Code],
				[SUB GROUP/ Brand],
				Channel,
				[Time series],
				'+@listcolumn+',
				TotalQty=('+@listcolumnPlus+')
			from FC_FM_Original_'+@Division+@Monthfc+' f
			where 
				Channel IN(''OFFLINE'')
			and [Time series] NOT IN(''4. Launch Qty'')
		) f1 on 
			f1.[SUB GROUP/ Brand]=f.[SUB GROUP/ Brand]
		and f1.Channel=f.Channel
		and f1.[Time series]=f.[Time series]
		group by
			f1.[Ref. Code],
			f.[SUB GROUP/ Brand],
			f.Channel,
			f.[Time series]
	) as z
	where ([FM TotalQty]-[WF TotalQty])<>0 '
end
else if @TypeCompare='Template_FOC'
begin
	select @sql='
	select
		[Ref. Code],
		[SUB GROUP/ Brand],
		Channel,
		[Time series],
		[FM TotalQty],
		[WF TotalQty],
		[Not match]=[FM TotalQty]-[WF TotalQty]
	from
	(
		select 
			f1.[Ref. Code],
			f.[SUB GROUP/ Brand],
			f.Channel,
			f.[Time series],
			[FM TotalQty]=sum(f.TotalQty),
			[WF TotalQty]=sum(f1.TotalQty)
		from 
		(
			select
				[SUB GROUP/ Brand]=[SubGrp],
				Channel=[Channel],
				[Time series],
				'+@listcolumn+',
				TotalQty=('+@listcolumnPlus+')
			from
			(
				select
					*
				from 
				(
					select * 
					from FC_SI_FOC_'+@Division+'
				) as x
			) as f
		) f
		left join
		(
			select
				[Ref. Code],
				[SUB GROUP/ Brand],
				Channel,
				[Time series],
				'+@listcolumn+',
				TotalQty=('+@listcolumnPlus+')
			from FC_FM_Original_'+@Division+@Monthfc+' f
			where 
				Channel IN(''OFFLINE'')
			and [Time series] NOT IN(''5. FOC Qty'')
		) f1 on 
			f1.[SUB GROUP/ Brand]=f.[SUB GROUP/ Brand]
		and f1.Channel=f.Channel
		and f1.[Time series]=f.[Time series]
		group by
			f1.[Ref. Code],
			f.[SUB GROUP/ Brand],
			f.Channel,
			f.[Time series]
	) as z
	where ([FM TotalQty]-[WF TotalQty])<>0 '
end
else if @TypeCompare='Template_Promo_Single'
begin
	select @sql='
	select
		[Ref. Code],
		[SUB GROUP/ Brand],
		Channel,
		[Time series],
		[FM TotalQty],
		[WF TotalQty],
		[Not match]=[FM TotalQty]-[WF TotalQty]
	from
	(
		select 
			f1.[Ref. Code],
			f.[SUB GROUP/ Brand],
			f.Channel,
			f.[Time series],
			[FM TotalQty]=sum(f.TotalQty),
			[WF TotalQty]=sum(f1.TotalQty)
		from 
		(
			select
				[SUB GROUP/ Brand]=[SubGrp],
				Channel=[Channel],
				[Time series],
				'+@listcolumn+',
				TotalQty=('+@listcolumnPlus+')
			from
			(
				select
					*
				from 
				(
					select * 
					from FC_SI_Promo_Single_'+@Division+'
				) as x
			) as f
		) f
		left join
		(
			select
				[Ref. Code],
				[SUB GROUP/ Brand],
				Channel,
				[Time series],
				'+@listcolumn+',
				TotalQty=('+@listcolumnPlus+')
			from FC_FM_Original_'+@Division+@Monthfc+' f
			where 
				Channel IN(''OFFLINE'')
			and [Time series] NOT IN(''2. Promo Qty(Single)'')
		) f1 on 
			f1.[SUB GROUP/ Brand]=f.[SUB GROUP/ Brand]
		and f1.Channel=f.Channel
		and f1.[Time series]=f.[Time series]
		group by
			f1.[Ref. Code],
			f.[SUB GROUP/ Brand],
			f.Channel,
			f.[Time series]
	) as z
	where ([FM TotalQty]-[WF TotalQty])<>0 '
end

if @debug>0
begin
	select @sql 'Validate Data'
end
execute(@sql)
--and s.[Item Category Group]<>'LUMF'
--and [Ref. Code]='3337872410338'
