/*
	select * from CPD_FC_SI_HIS
	select * from V_CPD_His_SI_Single 
	
*/

Alter View V_CPD_His_SI_Single
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
	from CPD_FC_SI_HIS H (NOLOCK)
	where ISNULL(SubGrp,'')<>''
	group by
		[SubGrp],
		[Year],
		[Month],
		[Channel],
		[Product Type]
) as x