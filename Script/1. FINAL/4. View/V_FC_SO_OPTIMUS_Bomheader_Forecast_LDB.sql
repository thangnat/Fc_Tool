/*
	select * from V_FC_SO_OPTIMUS_Bomheader_Forecast_LDB 
	
*/
--select * from FC_SO_OPTIMUS_Promo_Bom_CPD
Alter View V_FC_SO_OPTIMUS_Bomheader_Forecast_LDB
with encryption
As
select
	s.[SUB GROUP/ Brand],
	[Product Type New] = s.[Product Type],
	b.*
from (select * from FC_SO_OPTIMUS_Promo_Bom_LDB) b
inner join 
(
	select
		[Signature],
		[CAT/Axe],
		[SUB GROUP/ Brand],
		[Type],
		Barcode,
		[Bundle Code]=[Material],
		[Product Type]
	from fnc_SubGroupMaster('LDB','full')
	where Barcode='EVN40087'
) s on s.[Bundle Code] = b.[Bundle code]

--select * from FC_SO_OPTIMUS_Promo_Bom_LDB
--select [Sales  Org],* from SC1.dbo.MM_ZMR54OLD_Stg where Material='EVN40087'