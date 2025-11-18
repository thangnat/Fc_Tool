/*
	select * from V_FC_WF_FILTER_CONFIG order by STT asc
*/
Alter View V_FC_WF_FILTER_CONFIG
with encryption
As
select
	[ID],
	[List Group Column],
	[Address],
	[List Column]=case when SUSER_NAME() IN('admin1') then case when len([List Column2])=0 then [List Column] else [List Column2] end else [List Column] end,
	[Show],
	[STT]=[STT],
	[Active]
from
(
	select
		ID,
		[List Group Column] = ISNULL(Config1,''),
		[Address] = ISNULL(Config2,''),
		[Show] = ISNULL(Config5,'0'),
		[STT] = ISNULL(Config3,'0'),
		[List Column]=ISNULL(Config6,''),
		[List Column2]=ISNULL(Config7,''),
		[Active] = ISNULL(Config4,'0')
	from SysConfigValue (NOLOCK)
	where ConfigHeaderID = 47
	and ISNULL(Config4,'0') = '1'
) as x

