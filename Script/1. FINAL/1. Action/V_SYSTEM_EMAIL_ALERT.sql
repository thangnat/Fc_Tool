/*
	select DISTINCT [Email] from V_SYSTEM_EMAIL_ALERT where [task name]='SAP_TO_FM'
*/
Alter View V_SYSTEM_EMAIL_ALERT
As
select
	[Task Name]=ISNULL(Config3,''),
	[Email]=ISNULL(Config1,'')
from SysConfigValue (NOLOCK)
where ConfigHeaderID=72
and ISNULL(Config2,'0')='1'