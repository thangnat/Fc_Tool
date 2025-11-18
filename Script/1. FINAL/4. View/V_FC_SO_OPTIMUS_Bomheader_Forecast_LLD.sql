/*
	select * from V_FC_SO_OPTIMUS_Bomheader_Forecast_LLD
*/

aLTER View V_FC_SO_OPTIMUS_Bomheader_Forecast_LLD
with encryption
As
select
	s.[SUB GROUP/ Brand],
	[Product Type New] = s.[Product Type],
	b.*
from FC_SO_OPTIMUS_Promo_Bom_LLD b
inner join 
(
	select
		[Signature],
		[CAT/Axe],
		[SUB GROUP/ Brand],
		[Type],
		[Bundle Code]=[Material],
		[Product Type]
	from fnc_SubGroupMaster('LLD','full')
) s on s.[Bundle Code] = b.[Bundle code]