
/*
	select Selected,Description from V_FC_EXPORT_FM_TYPE Order by [Row_number] asc
*/

Alter view V_FC_EXPORT_FM_TYPE
As
select
	[Selected] =  cast(0 as bit),
	[Description],
	[Row_number]
from
(
	SELECT
		[ID] = ID,
		[Description] = ISNULL(Config1,''),
		[Row_number] = ISNULL(Config2,''),
		[Active] = ISNULL(Config3,'0')
	FROM SysConfigValue (NOLOCK)
	WHERE ConfigHeaderID = 54
	and ISNULL(Config3,'0') ='1'
) as x