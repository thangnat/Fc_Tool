/*
	select [Run Type],[SO Counter] from V_AUTO_ORDER_PROCESS_FOREGROUND
*/

Alter View V_AUTO_ORDER_PROCESS_FOREGROUND
As
select
	ID,
	[Run Type]=ISNULL(Config1,''),
	[SO Counter]=ISNULL(Config3,''),
	[Active]=ISNULL(Config2,'')
from SysConfigValue(NOLOCK)
where ConfigHeaderID=74
and ISNULL(Config2,'')='1'