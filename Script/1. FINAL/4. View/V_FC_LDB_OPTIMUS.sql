/*
	select * from V_FC_LDB_OPTIMUS order by cast(Number as int) asc
*/
Alter View V_FC_LDB_OPTIMUS
As
select
	*
from
(
	select
		Number = isnull([Config1],''),
		ColumName = isnull([Config2],''),
		[Desc] = isnull([Config3],''),
		[Type]=isnull(config4,'')
	from SysConfigValue (NOLOCK)
	where ConfigHeaderID = 60
) as x
