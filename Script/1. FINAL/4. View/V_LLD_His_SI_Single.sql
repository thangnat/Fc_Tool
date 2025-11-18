/*
	select * 
	from V_LLD_His_SI_Single 
	where SubGrp = 'HA SERUM 7.5ML PLV' 
	and [Time Series] = '1. Baseline Qty'
	and [Pass Column Header] = 'Y-2 (u) M7'
*/

Alter View V_LLD_His_SI_Single
with encryption
As
select
	[SubGrp],
	[Year],
	[Month],
	[Channel] = Channel,
	[Pass Column Header],
	HIS_QTY_SINGLE,
	[Time Series]= '1. Baseline Qty',
	[Product Type]
from
(
	select
		[SubGrp],
		[Year],
		[Month],
		[Channel],
		[Pass Column Header] = (
									select replace([Pass],'@',cast(([Year]-year(getdate())) as nvarchar(2))) 
									from V_FC_MONTH_MASTER 
									where Month_number = cast(H.[Month] as int)
								),
		HIS_QTY_SINGLE = sum(HIS_QTY_SINGLE),
		[Product Type]
	from LLD_FC_SI_HIS H (NOLOCK)
	where ISNULL(SubGrp,'')<>''
	group by
		[SubGrp],
		[Year],
		[Month],
		[Channel],
		[Product Type]
) as x