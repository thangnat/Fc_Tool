/*
	select * from V_FC_ACD_CUSTOMER_CONFIG
*/

Alter View V_FC_ACD_CUSTOMER_CONFIG
As
select
	[Customer Code]=ISNULL(Config1,''),
	[Channel]=ISNULL(Config2,'')
from SysConfigValue (NOLOCK)
where ConfigHeaderID=90
and ISNULL(Config3,0)=1