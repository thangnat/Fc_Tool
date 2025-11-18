/*
	select * from V_FC_FM_Table
*/
Alter view V_FC_FM_Table
As
select
	[Month FC]
from
(
	select
		[Month FC]=case when ISNULL(Config2,'0')='1' then ISNULL(Config1,'') else '' end,
		[Active]=ISNULL(Config2,'0')
	from SysConfigValue(NOLOCK)
	where ConfigHeaderID=64
) as x