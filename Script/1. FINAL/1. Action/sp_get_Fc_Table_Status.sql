/*
	exec sp_get_Fc_Table_Status 'LDB'
*/

Alter proc sp_get_Fc_Table_Status
	@Division			nvarchar(3)
As
declare @patchkey nvarchar(50) = ''

select top 1 
	@patchkey = Patchkey 
from FC_Table_Status 
where 
	Division = @Division
order by 
	adddate desc


select 
	*
from FC_Table_Status 
where 
	Division = @Division
and Patchkey = @patchkey
order by 
	STT asc

