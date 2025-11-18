/*
	select * 
	from V_FC_CONFIG_USER_ALLOW 
	where active = 1 
	and userid = 'admin1'
*/

Alter View V_FC_CONFIG_USER_ALLOW
As
select
	[UserID],
	[User Name],
	[Division],
	[Active] = cast(Active as int),
	[Action]=cast([Action] as int)
from
(
	select
		UserID = ISNULL(config1,''),
		[User Name] = ISNULL(config3,''),
		Division = ISNULL(config2,''),
		Active = ISNULL(config4,'0'),
		[Action] = ISNULL(config5,'0')
	from SysConfigValue (NOLOCK)
	where ConfigHeaderID = 56
) as x