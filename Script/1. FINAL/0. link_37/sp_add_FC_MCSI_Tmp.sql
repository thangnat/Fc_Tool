/*
	declare 
		@b_Success			Int,
		@c_errmsg			Nvarchar(250)

	exec sp_add_FC_MCSI_Tmp 'LDB',@b_Success OUT, @c_errmsg OUT

	select @b_Success b_Success, @c_errmsg c_errmsg

select * from FC_MCSI_CPD_Tmp
*/
Create or Alter proc sp_add_FC_MCSI_Tmp
	@Division			nvarchar(3),
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

	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_add_FC_MCSI_Tmp',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()
	declare @SharefolderPath nvarchar(500)
	select @SharefolderPath = Value from [SC2].[dbo].[EnvironmentConfig] where Name = 'Sharefolder_SAP_Dir'

	declare @filename nvarchar(500) = ''
	select @filename = 'MCSI_'+format(GETDATE(),'dd_MM_yyyy')+'.xlsx'--'MCSI_31_07_2024.xlsx'--
	--select @filename = 'MCSI_PPD 01.2024 05.2024.xlsx'
	declare @Full_name nvarchar(500) = ''
	--select @Full_name = '\\10.240.65.43\loreal\10_PUBLIC\03_SAPData\SC_IMPORT\Pending\MCSI\'+@Division+'\'+@filename
	
	--if @Division='LDB'
	--begin
	--	select @Full_name = '\\10.240.65.43\loreal\10_PUBLIC\03_SAPData\SC_IMPORT\Pending\MCSI\LDB\'+@filename
	--end
	--else
	--begin
	--	select @Full_name = '\\10.240.65.43\loreal\10_PUBLIC\03_SAPData\SC_IMPORT\Pending\MCSI\'+@filename
	--end

	select @Full_name = @SharefolderPath +'\Pending\MCSI\'+@filename
	declare @sql nvarchar(max) = '', @tablename nvarchar(100) = '',@SaleOrg nvarchar(4) = ''
	select @tablename = 'FC_MCSI_'+@Division+'_Tmp'
	select @SaleOrg = case 
						when @Division = 'LLD' then 'V100'
						when @Division = 'CPD' then 'V200'
						when @Division = 'PPD' then 'V300'
						when @Division = 'LDB' then 'V400'
						else ''
					end
	if (select dbo.fn_FileExists(@Full_name)) = 1
	begin
		if exists(SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID(@tablename) AND type in (N'U')
		)
		begin
			select @sql = 'drop table '+@tablename
			execute(@sql)
		end

		select @sql =
		'select
			Filename = '''+@filename+''',
			*
			INTO '+@tablename+'
		From OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',
						''Excel 12.0; HDR=YES; IMEX=1;Database='+@SharefolderPath +'\Pending\MCSI\'+@filename+''',
						''SELECT * FROM [Sheet1$] where [Sales org#] = '''''+@SaleOrg+'''''  '')'
		select @sql '@sql'
		execute(@sql)
	end
	else
	begin
		select @n_continue =3, @c_errmsg = 'No files.../'
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