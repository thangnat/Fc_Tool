/*
	Declare
		@b_Success			Int,
		@c_errmsg			Nvarchar(250)

	exec sp_add_FC_MCSI 'PPD',@b_Success OUT,@c_errmsg OUT

	select @b_Success b_Success,@c_errmsg c_errmsg

	select * from FC_MCSI_CPD
*/
Alter proc sp_add_FC_MCSI
	@Division			nvarchar(3),
	@b_Success			Int				OUTPUT,     
	@c_errmsg			Nvarchar(250)	OUTPUT
	with encryption
AS
SET NOCOUNT ON
SET XACT_ABORT ON
--BEGIN TRAN
BEGIN TRY
	DECLARE   
		 @sp_name				Nvarchar(100)
		,@n_continue			Int
		,@USERS					Nvarchar(50)
		,@MODIFILED				Datetime
		,@n_err					int
		,@debug					int=0
		,@sql					nvarchar(max) = ''
		,@tablename				nvarchar(100) = ''
		,@Filename				nvarchar(500)			
		,@DbName NVARCHAR(20)

	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_add_FC_MCSI',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	select @debug=debug from fnc_debug('FC')
	--select @debug =1

	select @tablename = 'FC_MCSI_'+@Division

	-- Get the environment configuration
	SELECT @DbName = CASE 
		WHEN Value = 'Production' THEN 'master.dbo'
		ELSE 'master_UAT'
	END
	FROM EnvironmentConfig
	WHERE Name = 'Current_Environment'

	if @n_continue = 1
	begin
		declare 
			@b_Success1			Int,
			@c_errmsg1			Nvarchar(250)

		if @DbName = 'master.dbo'
			exec link_37.master.dbo.sp_add_FC_MCSI_Tmp @Division, @b_Success1 OUT, @c_errmsg1 OUT
		else
			exec link_37.master_UAT.dbo.sp_add_FC_MCSI_Tmp @Division, @b_Success1 OUT, @c_errmsg1 OUT

		if @b_Success1=0
		begin
			select @n_continue = 3, @c_errmsg = @c_errmsg1
		end
	end

	BEGIN TRAN
	if @n_continue =1
	begin
		if not exists
		(
			select 1 from INFORMATION_SCHEMA.TABLES
			where TABLE_NAME=@tablename
		)
		begin
			select @sql = 
			'Select
				*
				INTO '+@tablename+'
			from '+@DbName+'.FC_MCSI_'+@Division+'_Tmp '
		end
		else
		begin
			select @sql = 
			'delete '+@tablename+
			' where [Month] IN
			(
				select distinct 
					[Month] 
				from '+@DbName+'.FC_MCSI_'+@Division+'_Tmp
			) 
			
			insert into '+@tablename+' 
			Select
				*
			from '+@DbName+'.FC_MCSI_'+@Division+'_Tmp '
		end

		if @debug>0
		begin
			select @sql 'INSERT TABLE'
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