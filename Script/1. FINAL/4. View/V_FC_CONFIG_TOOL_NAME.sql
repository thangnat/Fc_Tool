/*
	select Division,FileName,FMKEY,FMKEY_NEW from V_FC_CONFIG_TOOL_NAME where Division = 'CPD'
*/
Alter view V_FC_CONFIG_TOOL_NAME
As
select
	ID,
	Division = ISNULL(Config1,''),
	[FileName] = ISNULL(Config2,''),
	FMKEY = ISNULL(Config3,''),
	FMKEY_NEW = left(ISNULL(Config3,''),4)+'-'+right(ISNULL(Config3,''),2),
	[Path] = ISNULL(Config4,'')
from SysConfigValue (NOLOCK)
where ConfigHeaderID = 55
