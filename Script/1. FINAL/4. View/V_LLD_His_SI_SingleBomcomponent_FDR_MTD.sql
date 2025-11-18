/*
select * from V_LLD_His_SI_SingleBomcomponent_FDR_MTD
*/

Alter View V_LLD_His_SI_SingleBomcomponent_FDR_MTD
with encryption
as
select	
	SubGrp,
	Channel,
	HIS_QTY_FOC = sum(HIS_QTY_FOC),
	[Time Series],
	[Product Type]
from
(
	select 
		Tablename = 'Single',
		SubGrp,
		Channel,
		HIS_QTY_FOC = HIS_QTY_SINGLE_FDR,
		[Time Series],
		[Product Type]
	from V_LLD_His_SI_Single_FDR_MTD
	Union ALL
	select 
		Tablename = 'BomComponent',
		SubGrp,
		Channel,		
		HIS_QTY_FOC = HIS_QTY_BOM_FDR,
		[Time Series],
		[Product Type]
	from V_LLD_His_SI_BOM_FDR_MTD
) as x
where HIS_QTY_FOC<>0
group by
	SubGrp,
	Channel,
	[Time Series],
	[Product Type]