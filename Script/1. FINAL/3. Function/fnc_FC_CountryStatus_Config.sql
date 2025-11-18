/*
	select * from fnc_FC_CountryStatus_Config('CPD') where Channel = 'OFFLINE'
*/

Alter function fnc_FC_CountryStatus_Config(@Division nvarchar(3))
	Returns table
As
return
select
	Division = isnull(Config1,''),
	--Channel = isnull(Config2,''),
	[Time series] = isnull(Config3,''),
	--[Country status] = isnull(Config4,''),
	[List Country status] = isnull(Config6,'')
from SysConfigValue (NOLOCK)
where ConfigHeaderID=61
and isnull(Config5,'0')='1'
and (len(@Division)=0 OR isnull(config1,'') = @Division)