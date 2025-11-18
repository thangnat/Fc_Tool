/*
	select [Version] from V_FC_VERSION_EXE
*/
Alter View V_FC_VERSION_EXE
As
select
	ID,
	[Version],
	[Content],
	[STT]	
from
(
	select
		ID,
		[Version]=isnull(Config1,''),
		[Content]=isnull(Config2,''),
		[STT]=isnull(Config3,''),
		[Active]=isnull(Config4,'')
	from SysConfigValue (NOLOCK)
	--from sc2.dbo.SysConfigValue (NOLOCK)
	where ConfigHeaderID=67
) as x
where cast([Active] as int)>0