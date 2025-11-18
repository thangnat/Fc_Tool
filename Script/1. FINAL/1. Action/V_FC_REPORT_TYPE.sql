/*
	select * from V_FC_REPORT_TYPE
*/
Alter view V_FC_REPORT_TYPE
As
select
	ID,
	[Report Name]=ISNULL(Config1,''),
	[SQL Script]=ISNULL(Config2,''),
	[Active]=ISNULL(Config3,'0')
from SysConfigValue (NOLOCK)
--from sc2.dbo.SysConfigValue (NOLOCK)
where ConfigHeaderID=80
and ISNULL(Config3,'0')='1'