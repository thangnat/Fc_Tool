/*
	exec sp_validate_mismatch_Status 'CPD','202412','masterdata'

*/

Alter proc sp_validate_mismatch_Status
	@Division		nvarchar(3),
	@FM_KEY			nvarchar(6),
	--@FunctionName	nvarchar(50),
	@TypeName		nvarchar(200)
	with encryption
As
begin
	--declare @Division nvarchar(3)='CPD'
	--declare @fm_key nvarchar(6)='202407'
	--declare @functionName nvarchar(50)='SO_HIS'
	--declare @TypeName nvarchar(50)='MasterData'
	/*and [Function Name]='''+@functionName+'''*/
	declare @totalrow	int=0
	declare @currentrow int=1
	declare @sql		nvarchar(max)=''
	declare @debug		int=0

	create table fc_validate_mismatch_Status_tmp 
	(
		id int identity(1,1),
		[Table Name] nvarchar(200) null,
		[Status] nvarchar(50) null
	)

	insert into fc_validate_mismatch_Status_tmp([Table Name],[Status])
	select
		[Table Name],
		[Status]=''
	from V_FC_VALIDATE_MISMATCH_STATUS

	select @totalrow=isnull(count(*),0) from fc_validate_mismatch_Status_tmp

	while (@currentrow<=@totalrow)
	begin
		declare @tablename nvarchar(200)=''
		declare @status nvarchar(50)=''
		select @tablename= [Table Name] from fc_validate_mismatch_Status_tmp where id=@currentrow

		select @sql=
		'if exists
		(
			select
				1
			from '+@tablename+'
			where 
				[Division]='''+@Division+'''
			and FM_KEY='''+@fm_key+'''
			and [Type Name] IN(select value from string_split('''+@TypeName+''','',''))
		)
		begin
			Update fc_validate_mismatch_Status_tmp
			set [Status]=''OK''
			where [Table Name]='''+@tablename+'''
		end '
		if @debug>0
		begin
			select 'insert update status table_tmp'
		end
		execute(@sql)

		select @currentrow=@currentrow+1
	end
	select 
		[ID],
		[Table Name]
	from fc_validate_mismatch_Status_tmp 
	where [Status]='OK'

	drop table fc_validate_mismatch_Status_tmp 

end
