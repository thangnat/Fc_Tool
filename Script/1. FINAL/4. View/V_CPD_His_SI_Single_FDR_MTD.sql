/*
	select * 
	from V_CPD_His_SI_Single_FDR_MTD 
	where 
		SubGrp = 'AGE REWIND CONCEALER BUNDLE' 
	and [Time Series] = '1. Baseline Qty'
*/

Alter View V_CPD_His_SI_Single_FDR_MTD
with encryption
As
select
	[SubGrp],
	[Channel] = Channel,	
	HIS_QTY_SINGLE_FDR,
	[Time Series]= '5. FOC Qty',
	[Product Type]
from
(
	select
		[SubGrp],
		[Channel],		
		HIS_QTY_SINGLE_FDR = sum(HIS_QTY_SINGLE_FDR),		
		[Product Type]
	from CPD_FC_SI_MTD_HIS H (NOLOCK)
	where HIS_QTY_SINGLE>0
	group by
		[SubGrp],
		[Channel],
		[Product Type]
) as x