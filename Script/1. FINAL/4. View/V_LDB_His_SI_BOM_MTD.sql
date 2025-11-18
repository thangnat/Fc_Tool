/*
	select * from V_LDB_His_SI_BOM_MTD 
	where 
		SubGrp = 'AGE REWIND CONCEALER BUNDLE' 
	and [Time Series] = '3. Promo Qty(BOM)'
*/

Alter View V_LDB_His_SI_BOM_MTD
with encryption
As
select
	[SubGrp],
	--[Year],
	--[Month],
	[Channel] = Channel,
	--[Pass Column Header],
	HIS_QTY_BOM,
	[Time Series]= '3. Promo Qty(BOM)',
	[Product Type]
from
(
	select
		[SubGrp],
		--[Year],
		--[Month],
		[Channel],
		--[Pass Column Header] = (select replace([Pass],'@',cast(([Year]-year(getdate())) as nvarchar(2))) from V_FC_MONTH_MASTER where Month_number = cast(H.[Month] as int)),
		--HIS_QTY_SINGLE = sum(HIS_QTY_SINGLE),
		HIS_QTY_BOM = sum(HIS_QTY_BOM),
		[Product Type] = s.[Type]
	from LDB_FC_SI_MTD_HIS H (NOLOCK)
	left join 
	(
		SELECT DISTINCT 
			[SUB GROUP/ Brand],
			[Type] 
		FROM fnc_SubGroupMaster('LDB','full')
	) s on  s.[SUB GROUP/ Brand] = h.SubGrp
	where HIS_QTY_BOM>0
	group by
		[SubGrp],
		--[Year],
		--[Month],
		[Channel],
		s.[Type]
) as x

/*
select Barcode,* from V_SubGroupMaster where [SUB GROUP/ Brand] = 'AGE REWIND CONCEALER BUNDLE'
select * from V_His_SI where subgrp = 'AGE REWIND CONCEALER BUNDLE' order by SubGrp asc
*/