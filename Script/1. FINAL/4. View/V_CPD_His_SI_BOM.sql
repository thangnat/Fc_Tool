/*
	select * from V_CPD_His_SI_BOM 
	where 
		SubGrp = 'HA SERUM 7.5ML PLV' 
	and [Time Series] = '3. Promo Qty(BOM)'
	and [Pass Column Header] = 'Y-2 (u) M7'
*/

Alter View V_CPD_His_SI_BOM
with encryption
As
select
	[SubGrp],
	[Year],
	[Month],
	[Channel] = Channel,
	[Pass Column Header],
	HIS_QTY_BOM,
	[Time Series]= '3. Promo Qty(BOM)',
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
		HIS_QTY_BOM = sum(HIS_QTY_BOM),
		[Product Type]
	from CPD_FC_SI_HIS H (NOLOCK)	
	group by
		[SubGrp],
		[Year],
		[Month],
		[Channel],
		[Product Type]
) as x
