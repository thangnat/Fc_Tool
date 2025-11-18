/*
	select * from fnc_ListBombySubgrpComponent('MCLR WTR BI PHASE 400ML')
*/
Alter function fnc_ListBombySubgrpComponent(@subgrp nvarchar(300))
Returns table
with encryption
As
--declare @subgrp nvarchar(300) = 'MCLR WTR BI PHASE 400ML'
return
select distinct
	[SUB GROUP/ Brand],
	x.Material_Bom
from
(
	select 
		s.[SUB GROUP/ Brand],
		z.Material_Bom,
		z.Material_Component
	from V_ZMR32 z
	left join fnc_SubGroupMaster('CPD','full') s on s.Material = z.Material_Component
	where [SUB GROUP/ Brand] = @subgrp
) x
--order by
--	x.Material_Bom asc