/*
	select * from V_DivisionMaster
*/
Alter View V_DivisionMaster
with encryption
As
SELECT DISTINCT
	[Sales Org] = ISNULL(Config6,''),
	Division = ISNULL(Config1,'')
FROM SysConfigValue (NOLOCK)
where ConfigHeaderID  = 20