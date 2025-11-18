/*
	select * from V_LDB_His_SI_BOM_FDR_MTD 
	where 
		SubGrp = 'AGE REWIND CONCEALER BUNDLE' 
	and [Time Series] = '3. Promo Qty(BOM)'
*/

Alter View V_LDB_His_SI_BOM_FDR_MTD
with encryption
As
select
	[SubGrp],
	[Channel] = Channel,
	HIS_QTY_BOM_FDR,
	[Time Series]= '5. FOC Qty',
	[Product Type]
from
(
	select
		[SubGrp],
		[Channel],
		HIS_QTY_BOM_FDR = sum(HIS_QTY_BOM_FDR),
		[Product Type]
	from LDB_FC_SI_MTD_HIS H (NOLOCK)
	where HIS_QTY_BOM>0
	group by
		[SubGrp],
		[Channel],
		[Product Type]
) as x
