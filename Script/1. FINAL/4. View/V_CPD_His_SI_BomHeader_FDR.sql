/*
	select * 
	from V_CPD_His_SI_BomHeader_FDR
	where Barcode = '8935274632881' and [Pass Column Header] = 'Y-2 (u) M4'
*/

Alter View V_CPD_His_SI_BomHeader_FDR
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
	HIS_QTY_BOM_HEADER_FDR = sum(HIS_QTY_BOM_HEADER_FDR)
from
(
	select
		[Product Type],
		[SUB GROUP/ Brand],
		[Year],
		[Month],
		[Channel],
		[Sap Code],
		[Pass Column Header] = (select replace([Pass],'@',cast(([Year]-year(getdate())) as nvarchar(2))) from V_FC_MONTH_MASTER where Month_number = cast(H.[Month] as int)),
		HIS_QTY_BOM_HEADER_FDR = HIS_QTY_BOM_HEADER_FDR
	from CPD_FC_SI_HIS_BOM_HEADER_FDR H (NOLOCK)
) as x
group by
	[Product Type],
	[SUB GROUP/ Brand],
	[Year],
	[Month],
	[Channel],
	[Sap Code],
	[Pass Column Header]