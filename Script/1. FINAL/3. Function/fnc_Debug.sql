/*
	select * from fnc_debug('FC')
*/

Alter function fnc_Debug(@App nvarchar(200))
	returns table
As
return
select
	*
from
(
	select
		ID,
		[App] =ISNULL(Config2,''),
		[Debug] = isnull(Config1,'0')
	from SysConfigValue (NOLOCK)
	where ConfigHeaderID = 58
	and isnull(Config2,'')=@App
) as x