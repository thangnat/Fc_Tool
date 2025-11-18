/*
	Declare
		@b_Success			Int,
		@c_errmsg			Nvarchar(250)

	exec sp_add_FC_MAPPING_SUBGRP_OPTIMUS_Tmp 'CPD','202407',@b_Success OUT,@c_errmsg OUT

	select @b_Success b_Success,@c_errmsg c_errmsg

	select *
	from FC_MAPPING_SUBGRP_OPTIMUS_Tmp
*/
Create or Alter proc sp_add_FC_MAPPING_SUBGRP_OPTIMUS_Tmp
	@Division			nvarchar(3),
	@FM_KEY				Nvarchar(6),
	@b_Success			Int				OUTPUT,     
	@c_errmsg			Nvarchar(250)	OUTPUT
	with encryption
As
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRAN
BEGIN TRY
	DECLARE   
			 @debug					int = 1
			,@sp_name				Nvarchar(100)
			,@n_continue			Int
			,@USERS					Nvarchar(50)
			,@MODIFILED				Datetime
			,@n_err					int

	SELECT	@n_continue=1, 
			@b_success=0,
			@n_err=0,
			@c_errmsg='', 
			@sp_name = 'sp_add_FC_Spectrum_Tmp',
			@USERS = SUSER_NAME(),
			@MODIFILED = GETDATE()
	declare @SharefolderPath nvarchar(500)
	select @SharefolderPath = Value from [SC2].[dbo].[EnvironmentConfig] where Name = 'Sharefolder_SAP_Dir'

	DECLARE @filename			nvarchar(500)=''
	SELECT @filename='Mapping_Subgroup_Internal_Offline_'+@FM_KEY+'.xlsx'
	declare @Full_name nvarchar(500) = ''
	select @Full_name = @SharefolderPath +'\Pending\FORECAST\'+@Division+'\SELL_OUT\'+@filename
	
	if (select dbo.fn_FileExists(@Full_name)) = 1
	begin
		if exists(SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID('FC_MAPPING_SUBGRP_OPTIMUS_Tmp') AND type in (N'U'))
			drop table FC_MAPPING_SUBGRP_OPTIMUS_Tmp

		declare @sql nvarchar(max) = ''
		select @sql =
		'select
			Filename = '''+@filename+''',
			*
			INTO FC_MAPPING_SUBGRP_OPTIMUS_Tmp
		From OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',
						''Excel 12.0; HDR=YES; IMEX=1;Database='+@Full_name+''',
						''SELECT * FROM [Mapping sub group$]'')'

		--select @sql '@sql'

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