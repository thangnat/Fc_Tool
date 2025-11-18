/*
	select * 
	from V_PPD_His_SI_Single_MTD 
	where 
		SubGrp = 'AGE REWIND CONCEALER BUNDLE' 
	and [Time Series] = '1. Baseline Qty'
*/

Alter View V_PPD_His_SI_Single_MTD
with encryption
As
select
	[SubGrp],
	[Channel] = Channel,
	HIS_QTY_SINGLE,
	[Time Series]= '1. Baseline Qty',
	[Product Type]
from
(
	select
		[SubGrp],		
		[Channel],
		HIS_QTY_SINGLE = sum(HIS_QTY_SINGLE),
		[Product Type] = s.[Type]
	from PPD_FC_SI_MTD_HIS H (NOLOCK)
	left join 
	(
		SELECT DISTINCT 
			[SUB GROUP/ Brand],
			[Type] 
		FROM fnc_SubGroupMaster('PPD','full')
	) s on  s.[SUB GROUP/ Brand] = h.SubGrp
	where HIS_QTY_SINGLE>0
	group by
		[SubGrp],
		[Channel],
		s.[Type]
) as x