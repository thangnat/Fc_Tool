/*
	select * from V_FC_SO_OPTIMUS_Bomheader_Forecast_CPD 
	
*/
Alter View V_FC_SO_OPTIMUS_Bomheader_Forecast_CPD
with encryption
As
select
	s.[SUB GROUP/ Brand],
	[Product Type New] = s.[Product Type],
	b.*
from 
(
	select 
		*	
	from FC_SO_OPTIMUS_Promo_Bom_CPD
) b
inner join 
(
	select
		[Signature],
		[CAT/Axe],
		[SUB GROUP/ Brand],
		[Type],
		[Bundle Code]=[Material],
		[Product Type]
	from fnc_SubGroupMaster('CPD','full')
) s on s.[Bundle Code] = b.[Bundle code]

