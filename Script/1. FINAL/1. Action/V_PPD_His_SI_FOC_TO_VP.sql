/*
	select * 
	from V_PPD_His_SI_FOC_TO_VP 
	order by
		[Year] asc,
		[Month] asc
*/

Alter View V_PPD_His_SI_FOC_TO_VP
with encryption
As
select
	[Product Type],
	[SUB GROUP/ Brand],
	[Year],
	[Month],
	[Channel],
	[Sap Code],
	[Pass Column Header],
	HIS_QTY_FOC_TO_VP = sum(HIS_QTY_FOC_TO_VP)
from
(
	select
		[Product Type],
		[SUB GROUP/ Brand],
		[Year],
		[Month],
		[Channel],
		[Sap Code],
		[Pass Column Header] = (
									select replace([Pass],'@',cast(([Year]-year(getdate())) as nvarchar(2))) 
									from V_FC_MONTH_MASTER 
									where Month_number = cast(H.[Month] as int)
								),
		HIS_QTY_FOC_TO_VP = HIS_QTY_FOC_TO_VP
	from PPD_FC_SI_HIS_FOC_VP_FDR H (NOLOCK)
	where HIS_QTY_FOC_TO_VP<>0
) as x
group by
	[Product Type],
	[SUB GROUP/ Brand],
	[Year],
	[Month],
	[Channel],
	[Sap Code],
	[Pass Column Header]