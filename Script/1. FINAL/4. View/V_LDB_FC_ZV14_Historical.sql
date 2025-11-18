/*
	select Count(*) from V_LDB_FC_ZV14_Historical
*/

Alter view V_LDB_FC_ZV14_Historical
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
from FC_LDB_ZV14_Historical z (NOLOCK)