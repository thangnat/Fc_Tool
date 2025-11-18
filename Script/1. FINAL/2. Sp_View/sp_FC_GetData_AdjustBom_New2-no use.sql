/*
	exec sp_FC_GetData_AdjustBom_New2 'CPD','202405','BC AA SALICYLIC GEL WASH 120ML'
*/
Alter Proc sp_FC_GetData_AdjustBom_New2
	@Division		nvarchar(3),
	@FM_KEY			nvarchar(6),
	@Subgrp			nvarchar(300)
As
begin
	declare @debug int = 0
	declare @sql nvarchar(max) = ''
	--declare @FM_Key nvarchar(6) = '202405'
	--declare @division nvarchar(3) = 'CPD'
	declare @listcolumn_Current nvarchar(max) = ''
	declare @listcolumn_plus nvarchar(max) = ''
	declare @listcolumn_plus2 nvarchar(max) = ''

	SELECT @listcolumn_Current = ListColumn FROM fn_FC_GetColheader_Current(@FM_Key,'1. Baseline Qty','f')
	--SELECT listcolumn = ListColumn FROM fn_FC_GetColheader_Current('202405','1. Baseline Qty','f')
	SELECT @listcolumn_plus = ListColumn FROM fn_FC_GetColheader_Current(@FM_Key,'1. Baseline Qty_+','x')
	--SELECT listcolumn_plus = ListColumn FROM fn_FC_GetColheader_Current('202405','1. Baseline Qty_+','x')

	SELECT @listcolumn_plus2 = ListColumn FROM fn_FC_GetColheader_Current(@FM_Key,'1. Baseline Qty_+','f')
	--SELECT listcolumn_plus2 = ListColumn FROM fn_FC_GetColheader_Current('202405','1. Baseline Qty_+','f')

	declare @ListColumn_Pass nvarchar(max) = ''
	select @ListColumn_Pass = ListColumn from fn_FC_GetColHeader_Historical(@FM_Key,'f',12)
	--select ListColumn_Pass = ListColumn from fn_FC_GetColHeader_Historical('202403','f',12)

	select @sql =
	'select 
		[Bundle Code] = f.[SAP Code],
		[Bundle name] = f.[Bundle name],
		/*[Component Code] = z.Material_Component,*/
		Channel = f.Channel,'
		+@listcolumn_Current+','
		++@ListColumn_Pass+'
	from FC_BomHeader_CPD f
	inner join
	(
		select	
			*
		from V_ZMR32
	) z on z.Material_Bom = f.[SAP Code]
	left join 
	(
		select
			*
		from fnc_SubGroupMaster('''+@division+''','''')
		where [Item Category Group] NOT IN(''LUMF'')
	) as s on s.Material = z.Material_Component
	where s.[SUB GROUP/ Brand] = '''+@Subgrp+''' '
	if @debug >0
	begin
		select @sql '@sql 1.1.1'
	end
	execute(@sql)

end