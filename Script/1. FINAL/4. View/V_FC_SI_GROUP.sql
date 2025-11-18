/*
select * from V_FC_SI_GROUP
*/

Alter view V_FC_SI_GROUP
with encryption
As
select
	ID,
	TableName = ISNULL(Config1,''),
	Active = cast(ISNULL(Config2,'') as int)
from SysConfigValue (NOLOCK)
where ConfigHeaderID = 38
and cast(ISNULL(Config2,'') as int)>0