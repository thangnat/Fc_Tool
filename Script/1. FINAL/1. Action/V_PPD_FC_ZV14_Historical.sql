/*
	select Count(*) from V_CPD_FC_ZV14_Historical
*/

Alter view V_PPD_FC_ZV14_Historical
with encryption
As
select 
	[Ord. type],
	[Sales document item category],
	[Sold-to Party Number],
	[Sold-to Party Name],
	[Material Type],
	[Billing Doc Date],
	[Bill. Material],
	Barcode_Original,
	[FOC TYPE],
	Channel,
	[DO Billed Quantity],
	[ABS]
from FC_PPD_ZV14_Historical z (NOLOCK)