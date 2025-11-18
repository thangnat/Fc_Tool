/*
	select * 
	from V_FC_CPD_ZV14 where len([Ord. type])>6
	where [Sales document item category] IN('TAP','YFAP','YFAQ','YMAP','YTAP','YTAQ','YTAT')
	and [Bill# Material] = 'ZVN01501'
*/

Alter View V_FC_CPD_ZV14
with encryption
As
select --* from FC_CPD_ZV14_REPORT
	[Sales Group],
	[Sales Organization],
	[Ord. type]=[Ord# type],
	[Sold-to Party Number] = right('0000000000'+[Sold-to Party Number],10),
	[Bill# Material],
	Barcode = [International Article Number (EAN/UPC)],
	[Dchain]=[Dchain-specific material status],
	Quantity = [DO Billed Quantity],
	[Sales document item category],
	[Billing Doc Date]  = cast([Billing Doc Date] as date)
from FC_CPD_ZV14_REPORT z (NOLOCK)
inner join (select distinct [Material Type],Material,[EAN / UPC] from SC1.dbo.MM_ZMR54OLD (NOLOCK)) mm on mm.Material = z.[Bill# Material]
where cast(FORMAT([Billing Doc Date],'yyyyMMdd') as bigint) between cast('20240101' as bigint) and cast('20240131' as bigint)
and 
[DO Billed Quantity]<>0
and mm.[Material Type] in('YFG')--,'YSM2')

--and [Sales document item category]  IN('TAP','YFAP','YFAQ','YMAP','YTAP','YTAQ','YTAT')