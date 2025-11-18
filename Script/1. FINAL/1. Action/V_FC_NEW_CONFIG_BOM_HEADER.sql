/*
	select [sp name] from V_FC_NEW_CONFIG_BOM_HEADER where [Tag Name]='tag_gen_FM_FC_SI_BASELINE'
*/

Alter View V_FC_NEW_CONFIG_BOM_HEADER
As
select
	[ID],
	[Tag Name]=ISNULL(Config3,''),
	[Sp Name]=ISNULL(Config1,'')
from SysConfigValue (NOLOCK)
where 
	ConfigHeaderID=84
and ISNULL(Config2,'0')='1'