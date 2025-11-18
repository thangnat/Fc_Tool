/*
	select * from V_FC_DIV_ADJUST_TOTAL
*/

Alter view V_FC_DIV_ADJUST_TOTAL
As
select
	ID,
	[Division]=ISNULL(Config1,''),
	[Active]=ISNULL(Config2,'0')
from SysConfigValue (NOLOCK)
where ConfigHeaderID=79
and ISNULL(Config2,'0')='1'