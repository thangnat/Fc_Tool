/*
	select * from V_ALLOW_DEBUG 
	--where Projectname = 'FC'
*/
Alter View V_ALLOW_DEBUG
As
select
	ProjectName,
	[Enable]
from FC_Allow_Debug