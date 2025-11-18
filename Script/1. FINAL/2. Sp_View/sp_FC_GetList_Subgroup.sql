/*
	exec sp_FC_GetList_Subgroup 'CPD',''
*/
Alter Proc sp_FC_GetList_Subgroup
	@Division		nvarchar(3),
	@Searchtext		nvarchar(1000)
As
begin
	declare @debug			int = 0
	declare @sql			nvarchar(max) = ''

	select @sql =
	'select DISTINCT
		Selected = cast(0 as bit),
		[Result] = case when substring('''+@searchtext+''',2,2) = ''VN'' then z.Material_Bom else s.[SUB GROUP/ Brand] end
	from V_ZMR32 z /*on f1.[SAP Code] = z.Material_Bom*/
	inner join
	(  
		select  
			*  
		from fnc_SubGroupMaster('''+@Division+''','''')
		where [Item Category Group] NOT IN(''LUMF'')
	) as s on s.Material = z.Material_Component
	where case when substring('''+@searchtext+''',2,2) = ''VN'' then z.Material_Bom else s.[SUB GROUP/ Brand] end like ''%'+@searchtext+'%'' '
	--BC AA SALICYLIC GEL WASH 120ML

	if @debug>0
	begin
		select @sql '@sql 1.1.1'
	end
	execute(@sql)
end
--select * from fnc_SubGroupMaster('CPD','') where [Item Category Group] NOT IN('LUMF')and [SUB GROUP/ Brand]
