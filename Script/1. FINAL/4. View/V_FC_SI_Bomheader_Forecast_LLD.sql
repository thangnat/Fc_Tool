/*
	select * from V_FC_SI_Bomheader_Forecast_LLD
*/

ALTER View V_FC_SI_Bomheader_Forecast_LLD
with encryption
As
select
	s.[SUB GROUP/ Brand],
	[Product Type New] = s.[Product Type],
	b.*
from FC_SI_Promo_Bom_LLD b
inner join 
(
	select
		[Signature],
		[CAT/Axe],
		[SUB GROUP/ Brand],
		[Type],
		[Sap Code]=[Material],
		[Product Type]
	from fnc_SubGroupMaster('LLD','full')
	where Active = 1
	and [Item Category Group] = 'LUMF'
) s on s.[Sap Code] = b.[Bundle Code]