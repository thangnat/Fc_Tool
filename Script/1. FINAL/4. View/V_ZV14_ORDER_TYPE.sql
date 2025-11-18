/*
	select *
	from V_ZV14_ORDER_TYPE 
	where Division = 'LLD'
	AND [FOC TYPE] = 'FDR'
*/

ALTER VIEW V_ZV14_ORDER_TYPE
with encryption
AS
SELECT DISTINCT
	[Sales Org] = ISNULL(Config6,''),
	Division = ISNULL(Config1,''),
	OrderType = ISNULL(Config2,''),
	[FOC TYPE]=ISNULL(Config7,''),
	--Channel = ISNULL(Config4,''),
	[ABS] =	case when len(ISNULL(Config5,'1'))=0 then '1' else ISNULL(Config5,'1') end
FROM SysConfigValue (NOLOCK)
where ConfigHeaderID  = 20
and isnull(Config3,'0') = '1'