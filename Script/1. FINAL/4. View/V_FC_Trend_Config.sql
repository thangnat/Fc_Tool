/*
select TrendName,* from V_FC_Trend_Config
*/
Alter View V_FC_Trend_Config
with encryption
As
select
	ID,
	TrendName = isnull(Config1,''),
	TrendDescription = ISNULL(Config3,''),
	Active = cast(isnull(Config2,'0') as int)
from SysConfigValue (NOLOCK)
where ConfigHeaderID = 37
and cast(isnull(Config2,'0') as int)>0