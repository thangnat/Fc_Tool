/*
	exec sp_FC_GetData_AdjustBom_New 'CPD','202405','BC AA SALICYLIC GEL WASH 120ML'
*/

Alter Proc sp_FC_GetData_AdjustBom_New
	@Division		nvarchar(3),
	@FMKEY			nvarchar(6),
	@Subgrp			nvarchar(300)
As
declare @debug int = 0
--declare @Subgrp nvarchar(300) = ''--'BC AA SALICYLIC GEL WASH 120ML'
declare 
	@showpass int = 0,
	@showfc0 int = 0,
	@showfc1 int = 0

declare 
	@listColumn_his_unit nvarchar(max) = '',
	@listColumn_Current_y0_unit nvarchar(max) = '',
	@listColumn_Current_y1_unit nvarchar(max) = '',
	@sql nvarchar(max) = ''

select @listColumn_his_unit = Listcolumn from fn_FC_GetColHeader_Historical(@FMKEY,'b',2)
SELECT @listColumn_Current_y0_unit = listcolumn FROM fn_FC_GetColheader_Current(@FMKEY,'updateForecast_bom0','b')
SELECT @listColumn_Current_y1_unit = listcolumn FROM fn_FC_GetColheader_Current(@FMKEY,'updateForecast_bom1','b')

--select top 1
--	@subgrp = Subgrp
--from FC_Subgrp_AdjustBom
--where division = @Division

select @showpass = isnull(Show,0) from V_FC_BOMHEADER_FORM_FILTER_CONFIG where FilterName = 'Y-1 Unit'
select @showfc0 = isnull(Show,0) from V_FC_BOMHEADER_FORM_FILTER_CONFIG where FilterName = 'Y0 Unit'
select @showfc1 = isnull(Show,0) from V_FC_BOMHEADER_FORM_FILTER_CONFIG where FilterName = 'Y+1 Unit'

select @sql = 
'select
	[Bundle Code] = b.[SAP Code],
	[Bundle name] = b.[Bundle name],
	Channel = b.Channel'
	+case when @showpass=1 then ','+@listColumn_his_unit else '' end
		+case when @showfc0=1 or @showfc1 = 1 then ',' else '' end
	+case when @showfc0 =1 then @listColumn_Current_y0_unit else '' end
		+case when @showfc1 = 1 then ',' else '' end
	+case when @showfc1 =1 then @listColumn_Current_y1_unit else '' end+
'from V_ZMR32 z
inner join 
(
	select DISTINCT
		Material,
		[SUB GROUP/ Brand]
	from fnc_SubGroupMaster('''+@Division+''','''')
) s on s.Material = z.Material_Component
left join
(
	select * 
	from FC_BomHeader_CPD
	where Channel in(''ONLINE'',''OFFLINE'')
) b on b.[SAP Code] = z.Material_Bom
where s.[SUB GROUP/ Brand] = '''+@subgrp+''' and isnull([Sap code],'''')<>''''
order by
	b.[SAP Code] asc'
if @debug >0
begin
	select @sql '@sql 1.1.1'
end
execute(@sql)


--if @CreateFilter = 1
--begin
--	exec sp_createDataSet 'sp_FC_GetData_AdjustBom','dt_name'
--end