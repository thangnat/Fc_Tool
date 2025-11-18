/*
	exec sp_get_list_subgrp 'CPD','202411','s'
*/

Alter PROC sp_get_list_subgrp
	@Division		nvarchar(3),
	@FM_KEY			nvarchar(6),
	@type			nvarchar(1)--//s: source/d: destination
As
declare @debug		INT=0
declare @sql		nvarchar(max)=''

if @type='s'
begin
	select @sql=
	'declare @tmp table ([Product Type] nvarchar(50) null,[SUB GROUP/ Brand] nvarchar(500) null,[Item Category Group] nvarchar(10) NULL)
	insert into @tmp
	(
		[Product Type],
		[SUB GROUP/ Brand],
		[Item Category Group]
	)
	select distinct 
		[Product Type],
		[SUB GROUP/ Brand],
		[Item Category Group]
	from fnc_SubGroupMaster('''+@Division+''',''full'')
	
	select distinct  
		t.[SUB GROUP/ Brand]  
	from @tmp t
	LEFT JOIN
	(  
		select  
			[SUB GROUP/ Brand]   
		from FC_FM_SUbgrp_Selected (NOLOCK)
		where [Division]='''+@Division+'''  
		union all  
		select
			[SUB GROUP/ Brand] 
		from FC_FM_Original_'+@Division+'_'+@FM_KEY+' (NOLOCK)
	) f on f.[SUB GROUP/ Brand]=t.[SUB GROUP/ Brand]
	where 
		[Item Category Group]<>''LUMF''  
	and [Product Type] IN(''YFG'',''YSM2'')
	and isnull(f.[SUB GROUP/ Brand],'''')=''''
	order by    [SUB GROUP/ Brand] '

	if @debug>0
	begin
		select @sql 'get data source'
	end
	execute(@sql)
end
else if @type='d'
begin
	select @sql=
	'select distinct
		[SUB GROUP/ Brand]
	from FC_FM_SUbgrp_Selected
	where [Division]='''+@Division+'''
	order by
		[SUB GROUP/ Brand]'

	if @debug>0
	begin
		select @sql 'get data source'
	end
	execute(@sql)
end