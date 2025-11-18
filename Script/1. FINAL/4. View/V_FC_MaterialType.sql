/*
	select * from V_FC_MaterialType
*/

Alter View V_FC_MaterialType

As
Select
	ID,
	MaterialType = ISNULL(Config1,''),
	Active = ISNULL(Config2,'0')
from SysConfigValue (NOLOCK)
where ConfigHeaderID = 41
and ISNULL(Config2,'0') = '1'