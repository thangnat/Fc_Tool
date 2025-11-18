/*
select * from V_FC_SOH_CUSTOMER_CONFIG
*/

Alter VIEW V_FC_SOH_CUSTOMER_CONFIG
with encryption
As
SELECT
	Channel = ISNULL(Config1,''),
	Customer = ISNULL(Config2,''),
	[Sales Org] = isnull(Config3,'')
FROM SysConfigValue (NOLOCK)
where ConfigHeaderID = 30
and ISNULL(Config4,'0') = '1'