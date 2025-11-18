/*
	exec sp_get_FC_UPLOAD_DATA_INTO_DATA_LAKE 1
*/

Alter proc sp_get_FC_UPLOAD_DATA_INTO_DATA_LAKE
	@CreateFilter	int
	with encryption
As
select
	ID,
	STT,
	[Task Upload],
	[Action Name],
	Active
from V_FC_UPLOAD_DATA_INTO_DATA_LAKE
order by
	STT asc

if @CreateFilter = 1
begin
	exec sp_createDataSet 'sp_get_FC_UPLOAD_DATA_INTO_DATA_LAKE','dt_name'
end