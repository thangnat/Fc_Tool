/*
	exec sp_FC_GetData_AdjustBom 'CPD','',0
*/

Alter Proc sp_FC_GetData_AdjustBom
	@Division		nvarchar(3),
	@Subgrp			nvarchar(300),
	@CreateFilter	int
As
--declare @Subgrp nvarchar(300) = 'BC AA SALICYLIC GEL WASH 120ML'
select top 1
	@subgrp = Subgrp
from FC_Subgrp_AdjustBom
where division = @Division

select
	*
from FC_BomHeader_CPD
where [SAP Code] in
(
	select distinct
		[Bundle Code] = Material
	from fnc_SubGroupMaster(@Division,'')
	where [SUB GROUP/ Brand] like '%'+@subgrp+'%'
	and [Item Category Group] = 'LUMF'
)
order by
	[SAP Code] asc


if @CreateFilter = 1
begin
	exec sp_createDataSet 'sp_FC_GetData_AdjustBom','dt_name'
end