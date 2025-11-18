/*
	select * from V_FC_UPLOAD_DATA_INTO_DATA_LAKE
*/

Alter View V_FC_UPLOAD_DATA_INTO_DATA_LAKE
with encryption
As
select
	ID,
	STT = cast(STT as int),
	Selected = cast(0 as bit),
	[Task Upload],
	[Action Name],
	Active = cast(Active as int)
from
(
	select
		ID,
		STT = ISNULL(Config4,'0'),
		[Task Upload] = ISNULL(Config1,''),
		[Action Name] = ISNULL(Config3,''),
		Active = ISNULL(Config2,'0')
	from SysConfigValue (NOLOCK)
	where ConfigHeaderID = 49
	and ISNULL(Config2,'0') = '1'
) as x