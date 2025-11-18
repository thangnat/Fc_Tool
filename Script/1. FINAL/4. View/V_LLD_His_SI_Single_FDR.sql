/*
	select * 
	from V_LLD_His_SI_Single_FDR 
	where SubGrp = 'HA SERUM 7.5ML PLV' 
	and [Time Series] = '1. Baseline Qty'
	and [Pass Column Header] = 'Y-2 (u) M7'
*/

Alter View V_LLD_His_SI_Single_FDR
with encryption
As
select
	[SubGrp],
	[Year],
	[Month],
	[Channel] = Channel,
	[Pass Column Header],
	HIS_QTY_SINGLE_FDR,
	[Time Series]= '5. FOC Qty',
	[Product Type]
from
(
	select
		[SubGrp],
		[Year],
		[Month],
		[Channel],
		[Pass Column Header] = (select replace([Pass],'@',cast(([Year]-year(getdate())) as nvarchar(2))) from V_FC_MONTH_MASTER where Month_number = cast(H.[Month] as int)),
		HIS_QTY_SINGLE_FDR = sum(HIS_QTY_SINGLE_FDR),		
		[Product Type]
	from LLD_FC_SI_HIS H (NOLOCK)
	where HIS_QTY_SINGLE_FDR<>0
	group by
		[SubGrp],
		[Year],
		[Month],
		[Channel],
		[Product Type]
) as x

/*
select Barcode,* from V_SubGroupMaster where [SUB GROUP/ Brand] = 'AGE REWIND CONCEALER BUNDLE'
select * from V_His_SI where subgrp = 'AGE REWIND CONCEALER BUNDLE' order by SubGrp asc
*/