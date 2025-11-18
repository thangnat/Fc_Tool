/*
	select list_product_type=[Product Type],ColumnRelationShip=[Column Relationship],[Column Compare] from V_FC_DIVISION_BY_PRODUCT_TYPE
*/
Alter View V_FC_DIVISION_BY_PRODUCT_TYPE
As
select
	ID,
	[Division]=isnull(config1,''),
	[Product Type]=isnull(Config2,'YFG'),
	[Column Relationship]=isnull(Config4,'[Material]'),
	[Column Compare]=isnull(Config5,'s.[Material] = f.[Sku Code]')
from sysconfigvalue (NOLOCK)
where configheaderid=81
and isnull(config3,'0')='1'