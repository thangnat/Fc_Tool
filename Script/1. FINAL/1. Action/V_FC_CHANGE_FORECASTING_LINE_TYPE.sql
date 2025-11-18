/*
	select * from V_FC_CHANGE_FORECASTING_LINE_TYPE where [Division]='CPD' and changefc='1'
*/
Alter view V_FC_CHANGE_FORECASTING_LINE_TYPE
as
select
	ID,
	[Division]=isnull(Config3,''),
	[ChangeFC]=isnull(Config2,'')
from SysConfigValue (NOLOCK)
where ConfigHeaderID=89