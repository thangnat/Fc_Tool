/*
select [Only run active] from V_FC_SUBGROUP_ACTIVE
*/
Alter View V_FC_SUBGROUP_ACTIVE
As
select
	id,
	[Only run active] = ISNULL(Config1,'0')
from SysConfigValue (NOLOCK)
where ConfigHeaderID = 52