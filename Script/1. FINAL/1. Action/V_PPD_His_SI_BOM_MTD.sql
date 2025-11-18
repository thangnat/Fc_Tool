/*
	select * 
	from V_PPD_His_SI_BOM_MTD 
	where 
		SubGrp = 'AGE REWIND CONCEALER BUNDLE' 
	and [Time Series] = '3. Promo Qty(BOM)'
*/

Alter View V_PPD_His_SI_BOM_MTD
with encryption
As
select
	[SubGrp],
	[Channel] = Channel,
	HIS_QTY_BOM,
	[Time Series]= '3. Promo Qty(BOM)',
	[Product Type]
from
(
	select
		[SubGrp],
		[Channel],		
		HIS_QTY_BOM = sum(HIS_QTY_BOM),
		[Product Type] = s.[Type]
	from PPD_FC_SI_MTD_HIS H (NOLOCK)
	left join 
	(
		SELECT DISTINCT 
			[SUB GROUP/ Brand],
			[Type] 
		FROM fnc_SubGroupMaster('PPD','full')
	) s on  s.[SUB GROUP/ Brand] = h.SubGrp
	where HIS_QTY_BOM>0
	group by
		[SubGrp],
		[Channel],
		s.[Type]
) as x