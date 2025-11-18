/*
select * from V_CPD_His_SI_SingleBomcomponent_FDR
*/

Alter View V_LLD_His_SI_SingleBomcomponent_FDR
with encryption
as
select	
	SubGrp,
	[Year],
	[Month],
	Channel,
	[Pass Column Header],
	HIS_QTY_FOC = sum(HIS_QTY_FOC),
	[Time Series],
	[Product Type]
from
(
	select 
		Tablename = 'Single',
		SubGrp,
		[Year],
		[Month],
		Channel,
		[Pass Column Header],
		HIS_QTY_FOC = HIS_QTY_SINGLE_FDR,
		[Time Series],
		[Product Type]
	from V_LLD_His_SI_Single_FDR
	Union ALL
	select 
		Tablename = 'BomComponent',
		SubGrp,
		[Year],
		[Month],
		Channel,
		[Pass Column Header],
		HIS_QTY_FOC = HIS_QTY_BOM_FDR,
		[Time Series],
		[Product Type]
	from V_LLD_His_SI_Bom_FDR
) as x
where HIS_QTY_FOC<>0
group by
	SubGrp,
	[Year],
	[Month],
	Channel,
	[Pass Column Header],
	[Time Series],
	[Product Type]