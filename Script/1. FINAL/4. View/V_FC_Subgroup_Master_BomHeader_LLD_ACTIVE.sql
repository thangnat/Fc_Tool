/*-->subgrp bom header cua anh Quang
select * from V_FC_Subgroup_Master_BomHeader_LLD_ACTIVE

select * from V_FC_Subgroup_Master_BomHeader_CPD_ACTIVE

select * from FC_Subgroup_Master_BomHeader
*/
ALTER view V_FC_Subgroup_Master_BomHeader_LLD_ACTIVE
with encryption
As
select 
	b.[Filename],
	b.[Signature],
	b.[CAT/Axe],
	b.[SUB CAT/ Sub Axe],
	b.[GROUP/ Class],
	b.[SUB GROUP/ Brand],
	b.Channel,
	b.[AWO/OS],
	b.[SAP Code],
	b.[Bundle name],
	b.EAN,
	[Type] = m.[Material Type],
	b.[Status],
	b.Dchain,
	b.Customer,
	m.[Item Category Group]
from FC_Subgroup_Master_BomHeader_LLD_ACTIVE b
inner join 
(
	select * from SC1.dbo.MM_ZMR54OLD (NOLOCK)
) m on m.Material = b.[SAP Code]
where m.[Item Category Group] = 'LUMF'