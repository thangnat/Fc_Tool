/*
	select * from V_AUTO_ORDER_PROCESS_TEST_EMAIL
*/
Alter view V_AUTO_ORDER_PROCESS_TEST_EMAIL
As
select 
	[ALLOW]=ISNULL(Config1,'0')
from SysConfigValue (NOLOCK)
where ConfigHeaderID=75
