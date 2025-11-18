/*
	select * from V_FC_WF_FUNCTION_ACTIVE_NEW where [Re-Gen]>0 order by STT asc
*/
Alter view V_FC_WF_FUNCTION_ACTIVE_NEW
with encryption
As
select
	[ID],
	[Tag_name],
	[StoreProc],
	[Parent] = cast(Parent as int),
	[Child] = cast(Child as int),
	[GEN]=cast([GEN] as int),
	[BOM] = cast([BOM] as int),
	[PARTIAL] = cast([PARTIAL] as int),
	[VALUE] = cast([VALUE] as int),
	[Active] = cast([Active] as int),
	[STT],
	[BeginTran] = cast(BeginTran as int),
	[IsAction] = cast(IsAction as int),
	[Re-Gen] = cast([Re-Gen] as int),
	[Caption],
	[Alias Error Name]
from
(
	select
		[ID] = ID,
		[Tag_name] = ISNULL(Config1,''),
		[StoreProc] = ISNULL(Config6,''),
		[GEN] = ISNULL(config7,'0'),
		[BOM] = ISNULL(config8,'0'),
		[PARTIAL] = ISNULL(config9,'0'),
		[VALUE] = ISNULL(config10,'0'),
		[Active] = isnull(config2,'0'),
		[STT] = ISNULL(Config3,'0.00'),
		[BeginTran] = ISNULL(Config12,'0'),
		[Parent] = ISNULL(Config13,'0'),
		[Child] = ISNULL(Config14,'0'),
		[IsAction] = ISNULL(Config17,'0'),
		[Re-Gen] = ISNULL(Config18,'0'),
		[Caption]=ISNULL(Config24,''),
		[Alias Error Name]=ISNULL(Config25,'')
	from SysConfigValue (NOLOCK)
	where 
		[ConfigHeaderID] = 48
	AND ISNULL([Config11],'') = 'NEW'
) as x