/*
	select * from V_FC_Channel
*/

Alter View V_FC_Channel
with encryption
As
SELECT
	ID,
	Channel = ISNULL(Config1,''),
	Active = ISNULL(Config2,'0')
FROM SysConfigValue (NOLOCK)
WHERE ConfigHeaderID = 31
and ISNULL(Config2,'0') = '1'