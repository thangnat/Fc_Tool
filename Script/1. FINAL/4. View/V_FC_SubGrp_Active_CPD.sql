/*
	select * from V_FC_SubGrp_Active_CPD
*/

Alter VIEW V_FC_SubGrp_Active_CPD
with encryption
As
select
	[SUB GROUP/ Brand]
from
(
	select distinct [SUB GROUP/ Brand] from FC_Subgroup_Master_CPD_ACTIVE
	UNION ALL
	select distinct [SUB GROUP/ Brand] from FC_Subgroup_Master_BomHeader_CPD_ACTIVE
) as x
