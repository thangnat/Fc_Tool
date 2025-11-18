/*
	select * from V_Subgroup_BundleDetail
*/
Alter View V_Subgroup_BundleDetail
with encryption
As
SELECT DISTINCT
	[Product Type],
	[Bundle Code],
	[Material_Component],
	[Component Qty],
	[Child SUB GROUP/ Brand],
	[Parent SUB GROUP/ Brand]
FROM
(
	select
		[Product Type] = s.[Type],
		[Bundle Code] = b.[Bundle Code],
		[Material_Component] = zmr.Material_Component,	
		[Component Qty] = zmr.Qty,
		[Child SUB GROUP/ Brand] = s.[SUB GROUP/ Brand],
		[Parent SUB GROUP/ Brand] = b.[SUB GROUP/ Brand]
	from 
	(
		select * from V_FC_SI_Bomheader_Forecast
	) b 
	inner join 
	(
		select * from V_ZMR32
	) zmr on zmr.Material_Bom = b.[Bundle Code]
	inner join 
	(
		select * from fnc_SubGroupMaster('full')
	) s on s.[Material] = zmr.Material_Component
) AS X
--where s.[SUB GROUP/ Brand] = 'AGE REWIND CONCEALER'