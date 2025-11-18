/*
exec sp_GetHostName
*/

Alter proc sp_GetHostName
with encryption
As
select
	*
from FC_Config_HostName (NOLOCK)