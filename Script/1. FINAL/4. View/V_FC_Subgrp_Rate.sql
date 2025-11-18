/*
	select * from V_FC_Subgrp_Rate
*/
Alter View V_FC_Subgrp_Rate
with encryption
As
select
	ID,
	[Type rate] = ISNULL(Config1,''),
	[Rate] = ISNULL(Config2,'0')
from SysConfigValue (NOLOCK)
where ConfigHeaderID = 42
and ISNULL(Config3,'0') = '1'