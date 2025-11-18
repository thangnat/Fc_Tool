/*
	exec sp_get_FC_Master 'CPD','FC_BFL_Master'

*/
Alter proc sp_get_FC_Master
	@Division		nvarchar(3),
	@TableName		nvarchar(100)
As
declare @sql nvarchar(max)=''

select @sql='
select
	*
from '+@TableName+'_'+@Division

execute(@sql)