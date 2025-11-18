/*
	exec sp_Get_Function_Active_By_PC 'CPD','202411'

	select * from FC_FUNCTION_ACTIVE_VNCORPVNWKS1119

	select distinct [Signature] from FC_FM_Original_CPD_202409
*/

Alter proc sp_Get_Function_Active_By_PC
	@Division				nvarchar(3),
	@FM_KEY					Nvarchar(6)
As
begin
	declare @debug			int=0
	declare @sql			nvarchar(max)=''
	declare @tablename		nvarchar(200)=''
	declare @hostname nvarchar(50)=host_name()
	declare @USERS			Nvarchar(50)=SUSER_NAME()
	--select @hostname='VNCORPVNWKS1119'
	select @tablename='[FC_FUNCTION_ACTIVE_'+@hostname + ']'
	--select tablename='FC_FUNCTION_ACTIVE_'+HOST_NAME()
	--declare @tmpsignature table(id int identity(1,1), [Signature] nvarchar(50) null)

	if exists
	(
		SELECT * 
		FROM sys.objects 
		WHERE object_id = OBJECT_ID(@tablename) AND type in (N'U')
	)
	begin
		select @sql='drop table '+@tablename

		if @debug>0
		begin
			select @sql '@sql drop table FC_FUNCTION_ACTIVE_'
		end
		execute(@sql)
	end
	select @sql=
	'create table '+@tablename+'
	(
		[Selected]			INT default 0,
		[ID]				numeric(18,0) default 0,
		[Tag_name]			nvarchar(500) null,
		[Generated Data]	nvarchar(500) null,
		[Active]			INT default 0,
		[STT]				nvarchar(20) default ''0''
	)'
	if @debug>0
	begin
		select @sql '@sql drop table FC_FUNCTION_ACTIVE_'
	end
	execute(@sql)

	select @sql=
	'INSERT INTO '+@tablename+'
	(
		[Selected],
		[ID],
		[Tag_name],
		[Generated Data],
		[Active],
		[STT]
	)
	select 
		[Selected]=cast(''0'' as int),
		[ID],
		[Tag_name],
		[Caption],
		[Active],
		[STT]
	from fnc_TypeView('''',''a'','''') 
	order by STT ASC '

	if @debug>0
	begin
		select @sql 'Insert table'
	end
	execute(@sql)
	
	if @USERS NOT IN('adminfc1','admin11')
	begin
		--declare @list_signature nvarchar(max)=''
		--declare @table_signature nvarchar(100)=''
		--select @table_signature='FC_Signature_'+@Division+'_'+@hostname

		--select @sql=
		--'insert into '+@table_signature+'
		--select distinct 
		--	[Signature] 
		--from FC_FM_Original_'+@Division+'_'+@FM_KEY+' '

		--declare @currentrow int=1,@totalrows int=0
		--select @totalrows=isnull(count(*),0) from @tmpsignature

		--while (@currentrow<=@totalrows)
		--begin
		--	declare @signature nvarchar(50)=''
		--	select @signature=[Signature] from @tmpsignature where id=@currentrow

		--	if len(@list_signature)=0
		--	begin
		--		select @list_signature='['+@signature+']=cast(''1'' as bit)'
		--	end
		--	else
		--	begin
		--		select @list_signature=@list_signature+',['+@signature+']=cast(''1'' as bit)'
		--	end

		--	select @currentrow=@currentrow+1
		--end

		----select @list_signature '@list_signature'

		--select @sql='
		--select 
		--	[Selected]=cast([Selected] as BIT),
		--	[ID],
		--	[Tag_name],
		--	[Generated Data],
		--	[Active],
		--	[STT],'+@list_signature+'
		--from FC_FUNCTION_ACTIVE_'+@hostname+' f 
		--where [Tag_name] NOT IN(''tag_create_FC_FM_Original'')
		--Order by
		--	[STT] asc '
		--if @debug>0
		--begin
		--	select @sql 'select table'
		--end
		--execute(@sql)
	--end
	--else
	--begin
		select @sql=
		'select 
			[Selected]=cast([Selected] as BIT),
			[ID],
			[Tag_name],
			[Generated Data],
			[Active],
			[STT] 
		from '+@tablename+' 
		where [Tag_name] NOT IN(''tag_create_FC_FM_Original'')
		order by STT ASC '

		if @debug>0
		begin
			select @sql 'select table'
		end
		execute(@sql)
	end
end

