/*
	Declare
		@b_Success			Int,
		@c_errmsg			Nvarchar(250)
	
	exec sp_add_FC_FM_Tmp 'LDB','202501',@b_Success OUT,@c_errmsg OUT

	select @b_Success b_Success,@c_errmsg c_errmsg


	select * from FC_FM_LLD_202411_Tmp 
	where [SKU Code]='DUM_PP209037'
	where (select DISTINCT Material from fnc_SubGroupMaster('CPD','full') where [SUB GROUP/ Brand]='AGE REWIND CONCEALER')
	select * from FC_TotalCOlumn_Tmp
*/
--select round(4800.92180886354,0)
Create or Alter proc sp_add_FC_FM_Tmp
	@Division			nvarchar(3),
	@FM_KEY				nvarchar(6),
	--@filename			nvarchar(500),
	@b_Success			Int				OUTPUT,     
	@c_errmsg			Nvarchar(250)	OUTPUT
	with encryption
As
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRAN
BEGIN TRY
	DECLARE   
		 @debug					int=1
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
		@sp_name = 'sp_add_FC_FM_Tmp',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()
	declare @SharefolderPath nvarchar(500)
	select @SharefolderPath = Value from [SC2].[dbo].[EnvironmentConfig] where Name = 'Sharefolder_SAP_Dir'

	declare @filename	nvarchar(1000)=''
	select @filename = @Division+'_FM_'+@FM_Key+'.xlsx'

	declare @Monthfc				nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from link_33.sc2.dbo.V_FC_FM_Table

	declare @tablename nvarchar(200) = ''
	select @tablename = 'FC_FM_'+@Division+@Monthfc+'_Tmp'
	
	declare @Full_name nvarchar(500) = ''
	select @Full_name = @SharefolderPath +'\Pending\FORECAST\'+@Division+'\FM\'+@filename
	if @debug>0
	begin
		select @Full_name '@Full_name'
	end
	IF @n_continue = 1
	BEGIN
		if (select dbo.fn_FileExists(@Full_name)) = 1
		begin
			if exists
			(
				SELECT * 
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
							''Excel 12.0; HDR=YES; IMEX=1;Database='+@SharefolderPath +'\Pending\FORECAST\'+@Division+'\FM\'+@filename+''',
							''SELECT * FROM [Sheet0$]'')'

			if @debug>0
			begin
				select @sql '@sql'
			end
			execute(@sql)
		end
		else
		begin
			select @n_continue =3, @c_errmsg = 'No files.../'
		end

		--exec sp_getColumCount_New 'FC_TotalCOlumn_Tmp'

		select @n_err = @@ERROR
		if @n_err<>0
		begin				
			select @n_continue = 3
			select @n_err=60002
			select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +ERROR_MESSAGE()+'./ ('+@sp_name+')'
		end
	END

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