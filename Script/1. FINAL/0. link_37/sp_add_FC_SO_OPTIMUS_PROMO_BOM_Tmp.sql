/*
	declare 
		@b_Success			Int,
		@c_errmsg			Nvarchar(250)

	exec sp_add_FC_SO_OPTIMUS_PROMO_BOM_Tmp 'LLD','202502','FC_SO_OPTIMUS_PROMO_BOM_202502.xlsx',@b_Success OUT, @c_errmsg OUT

	select @b_Success b_Success, @c_errmsg c_errmsg

	select * from FC_SO_OPTIMUS_PROMO_BOM_LLD_202502_Tmp

*/
 
Create or Alter proc sp_add_FC_SO_OPTIMUS_PROMO_BOM_Tmp
	@Division			nvarchar(3),
	@FM_KEY				nvarchar(6),
	@filename			nvarchar(1000),
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
		@sp_name = 'sp_add_FC_SO_OPTIMUS_PROMO_BOM_Tmp',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()
	declare @SharefolderPath nvarchar(500)
	select @SharefolderPath = Value from [SC2].[dbo].[EnvironmentConfig] where Name = 'Sharefolder_SAP_Dir'

	declare	@Sheetname nvarchar(20) = ''

	declare @Monthfc				nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from link_33.sc2.dbo.V_FC_FM_Table

	declare @Full_name nvarchar(500) = ''
	select @Full_name = @SharefolderPath +'\Pending\FORECAST\'+@Division+'\SELL_OUT\'+@filename
	
	declare @Tablename nvarchar(100) = ''
	select @Tablename = 'FC_SO_OPTIMUS_PROMO_BOM_'+@Division+@Monthfc+'_Tmp'

	if @Division = 'CPD'
	begin
		select @Sheetname = 'Sheet1'
	end
	else if @Division = 'LLD'
	begin
		select @Sheetname = 'Sheet1'
	end
	else if @Division = 'LDB'
	begin
		select @Sheetname = 'Sheet1'
	end
	else if @Division = 'PPD'
	begin
		select @Sheetname = 'Sheet1'
	end

	if (select master.dbo.fn_FileExists(@Full_name)) = 1
	begin
		if exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID(@Tablename) AND type in (N'U')
		)
		begin
			select @sql ='drop table '+@Tablename
			if @debug>0
			begin
				select @sql 'drop table'
			end
			execute(@sql)
		end

		select @sql =
			'select
				Filename = '''+@filename+''',
				*
				INTO '+@Tablename+'
			From OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',
							''Excel 12.0; HDR=YES; IMEX=1;Database='+@SharefolderPath +'\Pending\FORECAST\'+@Division+'\SELL_OUT\'+@filename+''',
							''SELECT * FROM ['+@Sheetname+'$]  '') '
		if @debug>0
		begin
			select @sql 'insert table'
		end
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