/*
	select * from V_ZMR32
*/

Alter View V_ZMR32-->14,528
with encryption
As
select DISTINCT
	Division = case 
					when mb.[Sales  Org] = 'V100' then 'LLD'
					when mb.[Sales  Org] = 'V200' then 'CPD'
					when mb.[Sales  Org] = 'V300' then 'PPD'
					when mb.[Sales  Org] = 'V400' then 'LDB'
					else ''
				end,
	[Material_Bom]=z.[Material],
	[Barcode_Bom]=mb.[EAN / UPC],
	[Material_Component]=z.[Component],
	[Barcode_Component]=mc.[EAN / UPC],
	[Qty]=[Quantity],
	[material Type]=mc.[Material Type]
from BOM_MASTER z
inner join SC1.dbo.MM_ZMR54OLD_Stg mb on mb.Material=z.[Material]
inner join SC1.dbo.MM_ZMR54OLD_Stg mc on mc.Material=z.[Component]
where 
	ISNULL(mc.[EAN / UPC],'')<>''
and mc.[Material Type] in('YFG','YSM2')
and mb.[Item Category Group] = 'LUMF'

--select DISTINCT
--	Division = case 
--						when mb.[Sales  Org] = 'V100' then 'LLD'
--						when mb.[Sales  Org] = 'V200' then 'CPD'
--						when mb.[Sales  Org] = 'V300' then 'PPD'
--						when mb.[Sales  Org] = 'V400' then 'LDB'
--						else ''
--					end,

--	Material_Bom = r.Material,
--	Barcode_Bom = mb.[EAN / UPC],
--	Material_Component = r.Component,
--	Barcode_Component = mc.[EAN / UPC],
--	Qty = r.Quantity
--	,[Material Type] = mc.[Material Type]
--from 
--(
--	select * 
--	from SC1.dbo.ZMR32_Stg (NOLOCK)
--) r
--inner join 
--(
--	select 
--		[Sales  Org],
--		[EAN / UPC],
--		Material,
--		[Item Category Group]
--	from SC1.dbo.MM_ZMR54OLD_Stg (NOLOCK)
--) mb on mb.Material = r.Material
--left join 
--(
--	select
--		Material,
--		[EAN / UPC],
--		[Material Type]
--	from SC1.dbo.MM_ZMR54OLD_Stg (NOLOCK)
--) mc on mc.Material = r.Component
--where 
--	ISNULL(mc.[EAN / UPC],'')<>''
--and mc.[Material Type] in('YFG','YSM2')
--and mb.[Item Category Group] = 'LUMF'

