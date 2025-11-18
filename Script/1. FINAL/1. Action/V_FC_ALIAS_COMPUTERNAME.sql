/*
	select * from V_FC_ALIAS_COMPUTERNAME
*/
Alter view V_FC_ALIAS_COMPUTERNAME
As
select
	[ID],
	[ComputerName]=ISNULL(Config1,''),
	[Alias]=ISNULL(Config2,'')
from SysConfigValue(NOLOCK)
where ConfigHeaderID=71
and ISNULL(Config3,'0')='1'