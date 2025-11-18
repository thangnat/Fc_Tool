/*
select * from V_FC_MONTH_HISTORICAL_MASTER
*/
Alter view V_FC_MONTH_HISTORICAL_MASTER
with encryption
As
select top 1
	FromMonth = cast(left(ISNULL(Config1,''),4)+'-'+right(ISNULL(Config1,''),2)+'-01' as date)
from SysConfigValue (NOLOCK)
where ConfigHeaderID = 28