/*
	Declare
		@b_Success			Int,
		@c_errmsg			Nvarchar(250)

	exec sp_FC_Create_Backup_Version_WF_NEW 'CPD','202407','',@b_Success OUT,@c_errmsg OUT

	select @b_Success b_Success,@c_errmsg c_errmsg

	select * from FC_FM_Original_LDB_His
*/
Alter proc sp_FC_Create_Backup_Version_WF_NEW
	@Division			nvarchar(3),
	@FM_KEY				nvarchar(6),
	@FM_KEY_Type		nvarchar(6),
	@b_Success			Int				OUTPUT,     
	@c_errmsg			Nvarchar(250)	OUTPUT
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
		,@sql					nvarchar(max) = ''
			
	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_FC_Create_Backup_Version_WF_NEW',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	select @debug=Debug from fnc_Debug('FC')

	if @n_continue=1
	begin
		if @Division='CPD'
		begin
			if not exists(select 1 from FC_FM_Original_CPD where FM_KEY = @FM_KEY)
			begin
				select @n_continue = 3
				select @n_err=60001
				select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +':forecast month invalid, '+char(10)+'  pls check and run again./ ('+@sp_name+')'
			end
		end
		if @Division='LLD'
		begin
			if not exists(select 1 from FC_FM_Original_LLD where FM_KEY = @FM_KEY)
			begin
				select @n_continue = 3
				select @n_err=60001
				select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +':forecast month invalid, '+char(10)+'  pls check and run again./ ('+@sp_name+')'
			end
		end
		if @Division='LDB'
		begin
			if not exists(select 1 from FC_FM_Original_LDB where FM_KEY = @FM_KEY)
			begin
				select @n_continue = 3
				select @n_err=60001
				select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +':forecast month invalid, '+char(10)+'  pls check and run again./ ('+@sp_name+')'
			end
		end
		--if @Division='PPD'
		--begin
		--	if not exists(select 1 from FC_FM_Original_PPD where FM_KEY = @FM_KEY)
		--	begin
		--		select @n_continue = 3
		--		select @n_err=60001
		--		select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +':forecast month invalid, '+char(10)+'  pls check and run again./ ('+@sp_name+')'
		--	end
		--end
	end

	if @n_continue = 1
	begin
		if exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID('FC_FM_Original_'+@Division+'_His') AND type in (N'U')
		)
		begin
			select @sql = 'truncate table FC_FM_Original_'+@Division+'_His'
			if @debug>0
			begin
				select @sql '@sql 1.1.1'
			end
			execute(@sql)
		end
		select @n_err = @@ERROR
		if @n_err<>0
		begin
			select @n_continue = 3
			--select @n_err=60003
			select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +ERROR_MESSAGE()+'./ ('+@sp_name+')'
		end
	end

	if @n_continue = 1
	begin
		if not exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID('FC_FM_Original_'+@Division+'_His') AND type in (N'U')
		)
		begin
			select @sql ='
			select
				*
				INTO FC_FM_Original_'+@Division+'_His
			from FC_FM_Original_'+@Division+' 	'
			
			if @debug>0
			begin
				select @sql '@sql 1.1.2'
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
		else
		begin
			--select @sql = '
			--if exists(select 1 from FC_FM_Original_'+@Division+'_His (NOLOCK) where FM_KEY = '''+@FM_KEY_NEW+''')
			--begin
			--	delete FC_FM_Original_'+@Division+'_His where FM_KEY = '''+@FM_KEY_NEW+'''
			--end'
			--if @debug>0
			--begin
			--	select @sql '@sql 1.1.3'
			--end
			--execute(@sql)


			select @sql ='
			insert into FC_FM_Original_'+@Division+'_His
			select
				*
			from FC_FM_Original_'+@Division+'
			where FM_KEY = '''+@FM_KEY+''' '
			/*
			

			update FC_FM_Original_'+@Division+'_His set FM_KEY = '''+@FM_KEY_NEW+''' 
			where FM_KEY = '''+@FM_KEY+''' 
			*/
			if @debug >0
			begin
				select @sql '@sql 1.1.4'
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
	end
	if @n_continue=1
	begin
		select @sql=
			'update FC_FM_Original_'+@Division+'_His 
			set FM_KEY = '''+case when len(@FM_KEY_Type)>0 then @FM_KEY_Type else @FM_KEY end+''' 
			where FM_KEY = '''+@FM_KEY+''' '
			
		if @debug>0
		begin
			select @sql '@sql 1.1.2'
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