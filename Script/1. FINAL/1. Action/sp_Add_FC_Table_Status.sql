/*
	declare 
		@b_Success				Int,
		@c_errmsg				Nvarchar(250)
	exec sp_Add_FC_Table_Status 'CPD','','',@b_Success OUT,@c_errmsg OUT

	select @b_Success b_Success,@c_errmsg c_errmsg
*/

Alter Proc sp_Add_FC_Table_Status
	@Division				varchar(3),
	@TypeView				varchar(10),
	@Patchkey				varchar(36),
	@b_Success				Int				OUTPUT,     
	@c_errmsg				Nvarchar(250)	OUTPUT
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
		@sp_name = 'sp_Add_FC_Table_Status',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	select @debug=debug from fnc_Debug('FC')

	declare @FC_Table_Status		nvarchar(200) = 'FC_Table_Status'

	if @n_continue = 1
	begin
		if exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID(@FC_Table_Status) AND type in (N'U')
		)
		begin
			select @sql =
			'INSERT INTO FC_Table_Status
			(
				Patchkey,
				STT,
				Division, 
				Tag_name, 
				ActionName,
				ErrorNumber,
				ErrorMessage
			)
			select 
				Patchkey = '''+@Patchkey+''',
				STT = STT,
				Division = '''+@Division+''',
				Tag_name,
				ActionName = '''+case when @TypeView = '' then 'GEN' else @TypeView end+''',
				ErrorNumber = '''',
				ErrorMessage = ''''
			from fnc_TypeView('''+@TypeView+''',''p'','''') '
		end
		ELSE
		begin
			select @sql = 
			'select 
				Patchkey = '''+@Patchkey+''',
				STT,
				Division = '''+@Division+''',
				Tag_name,
				ActionName = '''+case when @TypeView = '' then 'GEN' else @TypeView end+''',
				ErrorNumber = '''',
				ErrorMessage = ''''
				INTO '+@FC_Table_Status+'
			from fnc_TypeView('''+@TypeView+''',''p'','''') '
		end
		if @debug>0
		begin
			select @sql
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