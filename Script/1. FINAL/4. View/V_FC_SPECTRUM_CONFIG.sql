/*
	select * from V_FC_SPECTRUM_CONFIG where Division = 'CPD' and channel = 'OFFLINE'
*/

Alter view V_FC_SPECTRUM_CONFIG
As
select
	*
from
(
	select
		Division = ISNULL(Config1,''),
		Channel = ISNULL(Config2,''),
		[Time series] = ISNULL(Config3,''),
		[Spectrum] = ISNULL(Config4,'0')
	from SysConfigValue (NOLOCK)
	where ConfigHeaderID = 59
) as x