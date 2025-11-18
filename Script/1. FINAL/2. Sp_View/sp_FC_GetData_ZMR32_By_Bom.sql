/*
	exec sp_FC_GetData_ZMR32_By_Bom 'XVN00349'
*/

Alter Proc sp_FC_GetData_ZMR32_By_Bom
	--@Division		nvarchar(3),
	@BundleCode		nvarchar(20)
As
select
	[Material Type] = z.[Material Type],
	Component = Material_Component,
	Quantity = Qty
	--[SUB GROUP/ Brand] = s.[SUB GROUP/ Brand]
from V_ZMR32 z
--inner join 
--(
--	select DISTINCT
--		Material,
--		[SUB GROUP/ Brand]
--	from fnc_SubGroupMaster(@Division,'')
--) s On s.Material = z.Material_Component
where Material_Bom = @BundleCode
--order by S.[SUB GROUP/ Brand] asc