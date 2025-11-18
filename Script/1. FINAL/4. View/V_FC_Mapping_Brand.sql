/*
select * from V_FC_Mapping_Brand
*/

Alter view V_FC_Mapping_Brand
with encryption
As
Select
	BrandParent = isnull(Config1,''),
	BrandChild = ISNULL(Config2,'')
from SysConfigValue (NOLOCK)
where ConfigHeaderID = 25
and ISNULL(Config3,'0') = '1'