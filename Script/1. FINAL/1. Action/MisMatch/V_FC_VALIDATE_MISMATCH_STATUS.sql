/*
	select * from V_FC_VALIDATE_MISMATCH_STATUS
*/
Alter View V_FC_VALIDATE_MISMATCH_STATUS
As
select 
	[ID],
	[Table Name]=ISNULL(Config1,''),
	[Caption Name]=ISNULL(Config2,''),
	[Active]=ISNULL(Config3,'0')
from SysConfigValue (NOLOCK)
where ConfigHeaderID=82
and ISNULL(Config3,'0')='1'

