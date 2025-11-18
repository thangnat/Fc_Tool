/*
	select * from V_Month_Master where Month_Number = 1
*/

Alter View V_Month_Master
with encryption
As
Select
	[PeriodType] = ISNULL(Config6,''),
	Month_Number = Config1,
	Month_Desc = ISNULL(Config2,'0'),
	[Pass] = ISNULL(Config3,''),
	[Current] = ISNULL(Config4,''),
	[Budget] = ISNULL(Config7,''),
	[PreBudget] = ISNULL(Config9,''),
	[Trend] = ISNULL(Config8,'')
from SysConfigValue (NOLOCK)
where ConfigHeaderID = 21