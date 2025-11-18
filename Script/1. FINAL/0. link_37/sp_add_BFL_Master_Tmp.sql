/*
	declare 
		@b_Success			Int,
		@c_errmsg			Nvarchar(250)
		
		exec sp_add_BFL_Master_Tmp 'LLD','202502',@b_Success OUT, @c_errmsg OUT

	select @b_Success b_Success, @c_errmsg c_errmsg

	select * from FC_BFL_LLD_Tmp
*/
Create or Alter proc sp_add_BFL_Master_Tmp
	@Division			nvarchar(3),
	@FM_KEY				nvarchar(6),
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
		,@filename				nvarchar(500) = ''
	
	select @filename = 'BFL_Master_'+@FM_KEY+'.xlsx'

	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_add_BFL_Master_Tmp',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()
	declare @SharefolderPath nvarchar(500)
	select @SharefolderPath = Value from [SC2].[dbo].[EnvironmentConfig] where Name = 'Sharefolder_SAP_Dir'

	declare @tablename nvarchar(200) = '',@sql nvarchar(max) = ''
	select @tablename = 'FC_BFL_'+@Division+'_Tmp'

	declare @Full_name nvarchar(500) = ''
	select @Full_name = @SharefolderPath + '\Pending\FORECAST\'+@Division+'\MasterFile\'+@filename

	if @debug>0
	begin
		select @Full_name '@Full_name'
	end

	if @n_continue =1
	begin
		if @Division = 'CPD'
		begin
			select @n_continue = 3, @c_errmsg = N'Không thể chạy Division này trong function này, liện hệ PIM teams.../'
		end
	end

	if @n_continue = 1
	begin
		if (select dbo.fn_FileExists(@Full_name)) = 1
		begin
			if exists
			(
				SELECT * 
				FROM sys.objects 
				WHERE object_id = OBJECT_ID(@tablename) AND type in (N'U')
			)
			begin
				--select @@SERVERNAME
				select @sql = 'drop table '+@tablename
				if @debug>0
				begin
					select @sql 'Drop table name'
				end
				execute(@sql)
			end
	
			select @sql =
			'select
				Filename = '''+@filename+''',
				*
				INTO '+@tablename+'
			From OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',
							''Excel 12.0; HDR=YES; IMEX=1;
							Database='+@Full_name+''',
							''SELECT * FROM [Sheet1$]'')'
			if @debug>0
			begin
				select @sql 'Import excel file'
			end
			execute(@sql)
		end
		else
		begin
			select @n_continue =3, @c_errmsg = 'No files.../'
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