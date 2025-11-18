/*
	select * from V_FC_WF_FUNCTION_ACTIVE
*/
Alter view V_FC_WF_FUNCTION_ACTIVE
with encryption
As
select
	[ID] = ID,
	[Tag_name] = ISNULL(Config1,''),
	[GEN] = ISNULL(config7,'0'),
	[BOM] = ISNULL(config8,'0'),
	[PARTIAL] = ISNULL(config9,'0'),
	[VALUE] = ISNULL(config10,'0'),
	Active = isnull(config2,'0')
from SysConfigValue (NOLOCK)
where 
	ConfigHeaderID = 48
--AND ISNULL(Config11,'') = 'NEW'
--and isnull(config2,'0') = '1'