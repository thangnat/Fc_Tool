/*
	select * from V_FC_FORECAST_MONTH_ALLOW
*/
Alter view V_FC_FORECAST_MONTH_ALLOW
As
SELECT
	ID,
	[Forecast Month]=ISNULL(Config1,''),
	[Active]=ISNULL(Config2,'0')
FROM SysConfigValue(NOLOCK)
where ConfigHeaderID=73
