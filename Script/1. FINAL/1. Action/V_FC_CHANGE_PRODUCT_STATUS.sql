/*
	select * from  V_FC_CHANGE_PRODUCT_STATUS
*/
Alter View V_FC_CHANGE_PRODUCT_STATUS
As
select 
	ID,
	[Barcode]=ISNULL(Config1,''),
	[Product Status]=ISNULL(Config3,'')
from SysConfigValue (NOLOCK)
where ConfigHeaderID=86
and ISNULL(Config2,'0')='1'