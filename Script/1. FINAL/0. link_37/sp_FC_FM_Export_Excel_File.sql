/*
	Declare
		@b_Success			Int,
		@c_errmsg			Nvarchar(250)

	exec sp_FC_FM_Export_Excel_File 'CPD','202407','Baseline Qty','',@b_Success OUT,@c_errmsg OUT

	select @b_Success b_Success,@c_errmsg c_errmsg
	
*/

Create or Alter proc sp_FC_FM_Export_Excel_File
	@Division			Nvarchar(3),
	@FMKEY				nvarchar(6),
	@Timeseries			Nvarchar(30),
	@Subgrp				nvarchar(200),
	@b_Success			Int				OUTPUT,     
	@c_errmsg			Nvarchar(250)	OUTPUT
	with encryption
As
SET NOCOUNT ON
SET XACT_ABORT ON
--BEGIN TRAN
BEGIN TRY
	DECLARE   
			 @debug					int=0
			,@sp_name				Nvarchar(100)
			,@n_continue			Int
			,@USERS					Nvarchar(50)
			,@MODIFILED				Datetime
			,@n_err					int
			,@fm_file_name			nvarchar(100) =''
			,@Channel				nvarchar(10) = ''

	SELECT	@n_continue=1, 
			@b_success=0,
			@n_err=0,
			@c_errmsg='', 
			@sp_name = 'sp_FC_FM_Export_Excel_File',
			@USERS = SUSER_NAME(),
			@MODIFILED = GETDATE()
	declare @SharefolderPath nvarchar(500)
	select @SharefolderPath = Value from [SC2].[dbo].[EnvironmentConfig] where Name = 'Sharefolder_SAP_Dir'
	declare
		@cmdstring_online		varchar(1000),
		@cmdstring_offline		varchar(1000),
		@filename_Template		nvarchar(200) = '',
		@filename_online		nvarchar(200) = '',
		@filename_offline		nvarchar(200) = '',
		@sql					nvarchar(max) = ''
	


	select @filename_online = format(getdate(),'yyyy_MM_dd_HHmm')+'_FM_ONLINE_'+replace(@Timeseries,' ','')+'.xlsx'
	select @filename_offline = format(getdate(),'yyyy_MM_dd_HHmm')+'_FM_OFFLINE_'+replace(@Timeseries,' ','')+'.xlsx'
	select @filename_Template = 'FM_Template.xlsx'

	if @n_continue = 1
	begin		
		--//copy file and edit name
		select @cmdstring_online = 'copy '+@SharefolderPath +'\Archive\FORECAST\'+@Division+'\FM_Template_Upload\'
								+@filename_Template+' '+@SharefolderPath +'\Archive\FORECAST\'+@Division+'\FM_Template_Upload\FM_Final\'+@filename_online+''

		select @cmdstring_offline = 'copy '+@SharefolderPath +'\Archive\FORECAST\'+@Division+'\FM_Template_Upload\'
								+@filename_Template+' '+@SharefolderPath +'\Archive\FORECAST\'+@Division+'\FM_Template_Upload\FM_Final\'+@filename_offline+''
		if @debug >0
		begin
			select @cmdstring_online '@cmdstring 1.1.1A'
			select @cmdstring_offline '@cmdstring 1.1.1B'
		end
		
		exec master..xp_cmdshell @cmdstring_online
		exec master..xp_cmdshell @cmdstring_offline

		select @n_err = @@ERROR
		if @n_err<>0
		begin				
			select @n_continue = 3
			select @n_err=60002
			select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +ERROR_MESSAGE()+'./ ('+@sp_name+')'
		end
	end

	if @n_continue = 1
	begin
		Select @Channel = 'ONLINE'
		--//paste data to sheet excel file existsed
		/*declare @tmp table
		(
			[Signature]				nvarchar(20) null,
			[Code]					nvarchar(20) null,
			[Event Description]		nvarchar(20) null,
			[SKU]					nvarchar(20) null,
			[SKU Descritpion]		nvarchar(500) null,
			[Customer level]		nvarchar(20) null,
			[Year YYYY]				nvarchar(4) null,
			[Month MM]				nvarchar(2) null,
			[QTy M]					int default 0,
			[QTy M+1]				int default 0,
			[QTy M+2]				int default 0,
			[QTy M+3]				int default 0,
			[QTy M+4]				int default 0,
			[QTy M+5]				int default 0,
			[QTy M+6]				int default 0,
			[QTy M+7]				int default 0,
			[QTy M+8]				int default 0,
			[QTy M+9]				int default 0,
			[QTy M+10]				int default 0,
			[QTy M+11]				int default 0,
			[QTy M+12]				int default 0,
			[QTy M+13]				int default 0,
			[QTy M+14]				int default 0,
			[QTy M+15]				int default 0,
			[QTy M+16]				int default 0,
			[QTy M+17]				int default 0,
			[QTy M+18]				int default 0,
			[QTy M+19]				int default 0
		)*/
		select @sql ='exec link_33.sc2.dbo.sp_FC_EXPORT_TO_FM '''+@Division+''','''+@FMKEY+''','''+@Channel+''','''+@Timeseries+''','''+@Subgrp+'''

		INSERT INTO OPENROWSET
		(
			''Microsoft.ACE.OLEDB.12.0'',
			''Excel 12.0;Database='+@SharefolderPath +'\Archive\FORECAST\'+@Division+'\FM_Template_Upload\FM_Final\'+@filename_online+''',
			''SELECT * FROM [Sheet1$]''
		)
		select * from link_33.sc2.dbo.tmp_spectrum '

		if @debug>0
		begin
			select @sql '@sql 1.1.1'
		end
		execute(@sql)

		select @n_err = @@ERROR
		if @n_err<>0
		begin				
			select @n_continue = 3
			select @n_err=60002
			select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +ERROR_MESSAGE()+'./ ('+@sp_name+')'
		end
	end
	if @n_continue = 1
	begin
		Select @Channel = 'OFFLINE'
		--//paste data to sheet excel file existsed
		/*
		declare @tmp table
		(
			[Signature]				nvarchar(20) null,
			[Code]					nvarchar(20) null,
			[Event Description]		nvarchar(20) null,
			[SKU]					nvarchar(20) null,
			[SKU Descritpion]		nvarchar(500) null,
			[Customer level]		nvarchar(20) null,
			[Year YYYY]				nvarchar(4) null,
			[Month MM]				nvarchar(2) null,
			[QTy M]					int default 0,
			[QTy M+1]				int default 0,
			[QTy M+2]				int default 0,
			[QTy M+3]				int default 0,
			[QTy M+4]				int default 0,
			[QTy M+5]				int default 0,
			[QTy M+6]				int default 0,
			[QTy M+7]				int default 0,
			[QTy M+8]				int default 0,
			[QTy M+9]				int default 0,
			[QTy M+10]				int default 0,
			[QTy M+11]				int default 0,
			[QTy M+12]				int default 0,
			[QTy M+13]				int default 0,
			[QTy M+14]				int default 0,
			[QTy M+15]				int default 0,
			[QTy M+16]				int default 0,
			[QTy M+17]				int default 0,
			[QTy M+18]				int default 0,
			[QTy M+19]				int default 0
		)
		*/
		select @sql ='exec link_33.sc2.dbo.sp_FC_EXPORT_TO_FM '''+@Division+''','''+@FMKEY+''','''+@Channel+''','''+@Timeseries+''','''+@Subgrp+'''

		INSERT INTO OPENROWSET
		(
			''Microsoft.ACE.OLEDB.12.0'',
			''Excel 12.0;Database='+@SharefolderPath +'\Archive\FORECAST\'+@Division+'\FM_Template_Upload\FM_Final\'+@filename_offline+''',
			''SELECT * FROM [Sheet1$]''
		)
		select * from link_33.sc2.dbo.tmp_spectrum '

		if @debug>0
		begin
			select @sql '@sql 1.1.1'
		end
		execute(@sql)

		select @n_err = @@ERROR
		if @n_err<>0
		begin				
			select @n_continue = 3
			select @n_err=60002
			select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +ERROR_MESSAGE()+'./ ('+@sp_name+')'
		end
	end


	if @n_continue = 3
	begin
		--rollback
		select @b_Success = 0
	end
	else
	begin
		--Commit
		select @b_Success = 1, @c_errmsg = 'Successfully.../'
	end
END TRY
BEGIN CATCH
   --ROLLBACK
   DECLARE @ErrorMessage VARCHAR(2000)
   SELECT @ErrorMessage = 'Error: '+ ERROR_MESSAGE()
   RAISERROR(@ErrorMessage , 16, 1)
END CATCH