/*
	Declare 
		@b_Success		Int,
		@c_errmsg		Nvarchar(250)

	exec sp_tag_gen_SUBGROUP_VLOOKUP 'PPD',1,@b_Success OUT,@c_errmsg OUT

	select @b_Success b_Success,@c_errmsg c_errmsg

	SELECT * FROM FC_MMDOWNLOAD_SORTBY_LLD
	SELECT * FROM FC_MMDOWNLOAD_SORTBY_CPD
	SELECT * FROM FC_MMDOWNLOAD_SORTBY_LDB

	select * from FC_Tag_Name_Processing_CPD
*/
Alter proc sp_tag_gen_SUBGROUP_VLOOKUP
	@division		nvarchar(3),
	@Active			nvarchar(1),
	@b_Success		Int				OUTPUT,
	@c_errmsg		Nvarchar(250)	OUTPUT
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
		,@GIT_filename			nvarchar(100) = ''
		
	Declare 
		@b_Success1				Int=0,
		@c_errmsg1				Nvarchar(250)=''

	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_FC_GIT',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()
	
	select @debug=debug from fnc_debug('FC')
	--select @debug=1

	declare @Tablename				nvarchar(100) = ''
	select @Tablename = 'FC_MMDOWNLOAD_SORTBY_'+@division

	IF @n_continue =1
	BEGIN
		if exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID(@Tablename) AND type in (N'U')
		)
		begin
			select @sql = 'drop table '+@Tablename
			if @debug >0
			begin
				select @sql 'drop table'
			end
			execute(@sql)
		end

		select @sql =
		'select 
			*
			INTO '+@Tablename+'
		from V_FC_MMDOWNLOAD_SORTBY_'+@division+'
		where len('''+@Active+''')=0 OR Active = '''+@Active+''' '		

		if @debug >0
		begin
			select @sql 'Insert table'
		end
		execute(@sql)

		select @n_err = @@ERROR
		if @n_err<>0
		begin
			select @n_continue = 3
			--select @n_err=60003
			select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +ERROR_MESSAGE()+'./ ('+@sp_name+')'
		end
	END
	if @debug>0
	begin
		select 'Insert tag name processing'
	end
	if @n_continue=1
	begin
		exec sp_add_TagName_Processing @division,'tag_add_BFL_Master',@b_Success1 OUT,@c_errmsg1 OUT
		if @b_Success1=0
		begin
			select @n_continue=3,@c_errmsg=@c_errmsg1
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
   select @n_continue = 3
   ROLLBACK
   DECLARE @ErrorMessage VARCHAR(2000)
   SELECT @ErrorMessage = 'Error: '+ ERROR_MESSAGE()
   RAISERROR(@ErrorMessage , 16, 1)
END CATCH
