/*
	select * from V_ALLOW_DEBUG_NEW where App = 'FC'
*/
Alter View V_ALLOW_DEBUG_NEW
As
select
	ID,
	[App] =ISNULL(Config2,''),
	[Debug] = isnull(Config1,'0')
from SysConfigValue (NOLOCK)
where ConfigHeaderID = 58