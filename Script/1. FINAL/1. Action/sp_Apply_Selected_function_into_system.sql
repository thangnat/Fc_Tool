/*
	declare 
		@b_Success				Int,
		@c_errmsg				Nvarchar(250)

	exec sp_Apply_Selected_function_into_system 'LLD','202409','2748_True*True*True*True','2793','1',@b_Success OUT, @c_errmsg OUT

	select @b_Success b_Success, @c_errmsg c_errmsg
*/
--select * from fc_filter_tmp_VNCORPVNWKS0850

Alter Proc sp_Apply_Selected_function_into_system
	@Division				nvarchar(3),
	@FM_KEY					nvarchar(6),
	@List_ID				nvarchar(1000),
	--@List_Signature			nvarchar(1000),
	@List_selected			nvarchar(1000),
	@b_Success				Int				OUTPUT,     
	@c_errmsg				Nvarchar(250)	OUTPUT
	with encryption
As
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRAN
BEGIN TRY
	DECLARE  
		 @debug					int=0
		,@sp_name				Nvarchar(100)
		,@n_continue			Int
		,@USERS					Nvarchar(50)
		,@MODIFILED				Datetime
		,@n_err					int
		,@sql					nvarchar(max)=''
			
	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_Apply_Selected_function_into_system',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	declare @hostname		nvarchar(50)=host_name()
	--select @hostname='VNCORPVNWKS1119'
	select @debug=debug from fnc_debug('FC')
	--select @debug=1
	
	declare @table_filter_tmp	nvarchar(200)=''
	select @table_filter_tmp='[fc_filter_tmp_'+@hostname + ']'
	
	declare @table_filter_selected_tmp	nvarchar(200)=''
	select @table_filter_selected_tmp='[fc_filter_tmp_Selected_'+@hostname + ']'

	--declare @table_filter_signature_tmp	nvarchar(200)=''
	--select @table_filter_signature_tmp='[fc_filter_tmp_Signature_'+@hostname + ']'

	declare @tablename			nvarchar(200)=''	
	select @tablename= '[FC_FUNCTION_ACTIVE_'+@hostname + ']'
	--select * from FC_FUNCTION_ACTIVE_VNCORPVNWKS1094
	if @n_continue=1
	begin
		--//create table filter total
		if exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID(@table_filter_tmp) AND type in (N'U')
		)
		begin
			select @sql='Drop table '+@table_filter_tmp

			if @debug>0
			begin
				select @sql '@sql drop table fc_filter_tmp_host_name'
			end
			execute(@sql)
		end
		select @sql=
		'create table [fc_filter_tmp_'+@hostname+']'+'
		(
			[id]				int identity(1,1),
			[ID_Function]		numeric(18,0) default 0,
			/*[List_Signature]	Nvarchar(500) null,*/
			[Selected]			bit default 0,
		) '
		if @debug>0
		begin
			select @sql '@sql drop table fc_filter_tmp_host_name'
		end
		execute(@sql)
		--//create table selected
		if exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID(@table_filter_selected_tmp) AND type in (N'U')
		)
		begin
			select @sql='Drop table '+@table_filter_selected_tmp

			if @debug>0
			begin
				select @sql '@sql drop table fc_filter_selected_tmp'
			end
			execute(@sql)
		end
		select @sql=
		'Create table [fc_filter_tmp_Selected_'+@hostname+']'+'
		(
			[id]				int identity(1,1),
			[Selected]			bit default 0
		) '
		if @debug>0
		begin
			select @sql '@sql drop table fc_filter_tmp_host_name'
		end
		execute(@sql)
		----//create table signature
		--if exists
		--(
		--	SELECT * 
		--	FROM sys.objects 
		--	WHERE object_id = OBJECT_ID(@table_filter_signature_tmp) AND type in (N'U')
		--)
		--begin
		--	select @sql='Drop table '+@table_filter_signature_tmp

		--	if @debug>0
		--	begin
		--		select @sql '@sql drop table table_filter_signature_tmp'
		--	end
		--	execute(@sql)
		--end
		--select @sql=
		--'Create table '+@table_filter_signature_tmp+'
		--(
		--	[id]				int identity(1,1),
		--	[List_Signature]	nvarchar(500) null
		--) '
		--if @debug>0
		--begin
		--	select @sql '@sql drop table table_filter_signature_tmp'
		--end
		--execute(@sql)
	end	

	if @n_continue=1
	begin
		--//insert table filer total
		select @sql='
		insert into '+@table_filter_tmp+'
		(
			[ID_Function],
			/*[List_Signature],*/
			[Selected]
		)
		select 
			[ID_Function]=[value],
			/*[List_Signature]='''',*/
			[Selected]=0 
		from string_split('''+@List_ID+''','','') '

		if @debug>0
		begin
			select @sql 'insert table filer total'
		end
		execute(@sql)
		--//impot data to table selected
		select @sql=
		'insert into '+@table_filter_selected_tmp+'
		(
			Selected
		)
		select 
			value
		from string_split('''+@List_selected+''','','') '
		if @debug>0
		begin
			select @sql 'impot data to table selected'
		end
		execute(@sql)
		----//impot data to table signature
		--select @sql=
		--'insert into '+@table_filter_signature_tmp+'
		--(
		--	[List_Signature]
		--)
		--select 
		--	value
		--from string_split('''+@List_Signature+''','','') '
		--if @debug>0
		--begin
		--	select @sql 'impot data to table signature'
		--end
		--execute(@sql)

		--//update data selected to filter total
		select @sql=
		'update [fc_filter_tmp_'+@hostname+']'+
		' set 
			[Selected]=t2.[Selected]
		from '+@table_filter_tmp+' t1 
		inner join '+@table_filter_selected_tmp+' t2 on t1.id=t2.id '

		if @debug>0
		begin
			select @sql 'update data selected to filter total'
		end
		execute(@sql)

		----//update data signature to filter total
		--select @sql=
		--'update [fc_filter_tmp_'+@hostname+']'+
		--' set 
		--	[List_Signature]=t2.[List_Signature]
		--from '+@table_filter_tmp+' t1 
		--inner join '+@table_filter_signature_tmp+' t2 on t1.id=t2.id
		--where [Selected]=''1'' '

		--if @debug>0
		--begin
		--	select @sql 'update data signature to filter total'
		--end
		--execute(@sql)

		select @n_err = @@ERROR
		if @n_err<>0
		begin
			select @n_continue = 3
			--select @n_err=60003
			select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +ERROR_MESSAGE()+'./ ('+@sp_name+')'
		end
	end
	if @n_continue=1
	begin
		select @sql='
		Update '+@tablename+
		' set 
			[selected]= 1
		where ID IN(select [ID_Function] from '+@table_filter_tmp+' where [selected]=1) 
		
		Update '+@tablename+
		' set 
			[selected]=0
		where ID IN(select [ID_Function] from '+@table_filter_tmp+' where [selected]=0) '

		if @debug>0
		begin
			select @sql 'apply selected into Main table'
		end
		execute(@sql)

		select @n_err = @@ERROR
		if @n_err<>0
		begin
			select @n_continue = 3
			--select @n_err=60003
			select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +ERROR_MESSAGE()+'./ ('+@sp_name+')'
		end
	end	

	if @n_continue = 3
	begin
		rollback
		select @b_Success = 0
	end
	else
	begin
		Commit
		select @b_Success = 1, @c_errmsg = 'Successfully.../'
	end
END TRY
BEGIN CATCH
   ROLLBACK
   DECLARE @ErrorMessage VARCHAR(2000)
   SELECT @ErrorMessage = 'Error: '+ ERROR_MESSAGE()
   RAISERROR(@ErrorMessage , 16, 1)
END CATCH