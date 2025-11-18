/*
	select * from V_FC_DEFINE_BOM_HEADER
*/

Alter View V_FC_DEFINE_BOM_HEADER
with encryption
As
select DISTINCT
	ID,
	[Type] = ISNULL(Config1,''),
	Active = cast(ISNULL(Config2,0) as int)
from SysConfigValue (NOLOCK)
where ConfigHeaderID = 40
and cast(ISNULL(Config2,'0') as int)>0