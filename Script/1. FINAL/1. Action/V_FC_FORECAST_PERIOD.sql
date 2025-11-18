/*
	select * from V_FC_FORECAST_PERIOD
*/

Alter view V_FC_FORECAST_PERIOD
As
select 
	[ID],
	[Period Key]=ISNULL(Config1,''),
	[Open LLD]=isnull(Config2,'0'),
	[Open CPD]=isnull(Config3,'0'),
	[Open LDB]=isnull(Config4,'0'),
	[Open PPD]=isnull(Config5,'0')
from SysConfigValue(NOLOCK) 
where ConfigHeaderID=76
