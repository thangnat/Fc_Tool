/*
	Declare 
		@b_Success			Int,     
		@c_errmsg			Nvarchar(250)

	exec sp_Import_File_into_system_SAP_TO_FM @b_Success OUT, @c_errmsg OUT

	select @b_Success as b_Success, @c_errmsg as c_errmsg

	--drop table SAP_TO_FM
*/

Alter proc sp_Import_File_into_system_SAP_TO_FM
	@b_Success			Int				OUTPUT,
	@c_errmsg			Nvarchar(250)	OUTPUT
	with encryption
As
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRAN
BEGIN TRY
	DECLARE   
		 @debug					INT=0
		,@sp_name				Nvarchar(100)
		,@n_continue			Int
		,@USERS					Nvarchar(50)
		,@MODIFILED				Datetime
		,@n_err					int		
		,@error1				int = 0
		,@tableName				nvarchar(100) = 'SAP_TO_FM_Tmp'--//Table temp		
		,@tablenamefinal		nvarchar(100) = 'SAP_TO_FM'--//Table chinh thuc
		,@AllowUpdate			int = 0
		,@sql					nvarchar(max) = ''
		,@FileName				Nvarchar(500)=''
		,@FullName				nvarchar(4000)=''
	
	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='',
		@sp_name = 'sp_Import_File_into_system_SAP_TO_FM',
		@USERS = USER_NAME(),
		@MODIFILED = GETDATE()
	
	declare @SharefolderPath nvarchar(500)
	select @SharefolderPath = Value from [SC2].[dbo].[EnvironmentConfig] where Name = 'Sharefolder_SAP_Dir'
	
	--send mail catch up start time
	exec sp_SendEmail_Auto_Order_Process 'SAP_TO_FM','Import SAP_To_FM_INTO_DATA_LAKE','Start processing.../'
	
	select @debug=debug from fnc_debug('FC')
	--select @debug=1


	select @FileName='SAP_TO_FM_4DIV.TXT'
	--select @FileName='SAP_TO_FM_4DIV_1to9.TXT'
	select @FullName=@SharefolderPath+'\Pending\SAP FM Data\'+@FileName

	if @debug>0
	begin
		select 'kiem tra ten file'
	end
	if @n_continue = 1
	begin
		if CHARINDEX('SAP_TO_FM_4DIV',@FileName,0)=0
		begin
			select @n_continue = 3
			select @n_err=60011
			select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +'This file['+@FileName+'] is valid./ ('+@sp_name+')'
		end
	end
	
	if @debug>0
	begin
		select 'kiem tra table ton tai chua?'
	end
	if @n_continue=1
	begin
		if exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID(@tableName) AND type in (N'U')
		)
		begin
			select @sql='truncate table '+@tableName
			if @debug>0
			begin
				select @sql 'truncate table'
			end
			execute(@sql)
		end
		else
		begin
			select @sql=
			'create table '+@tableName+'
			(
				[Material]						Nvarchar(50) null,
				[FMlevel3]						Nvarchar(20) null,
				[Sold-to party]					Nvarchar(20) null,
				[Sales Group]					Nvarchar(20) null,
				[Sales Office]					Nvarchar(20) null,
				[Plant]							Nvarchar(20) null,
				[Customer group]				Nvarchar(20) null,
				[Customer Hierarchy - Medium]	Nvarchar(20) null,
				[Customer Hierarchy - Top]		Nvarchar(20) null,
				[Billing Date]					Nvarchar(20) null,
				[Billing Quantity]				Nvarchar(20) default ''0'',
				[Gross Sales Value]				Nvarchar(20) default ''0'',
				[Invoiced Sales Value]			Nvarchar(20) default ''0'',
				[Consolidated Net Sales]		Nvarchar(20) default ''0'',
				[Comp. Qty]						Nvarchar(20) default ''0'',
				[Comp. Gross Value]				Nvarchar(20) default ''0'',
				[Comp. Inv. Value]				Nvarchar(20) default ''0'',
				[Comp. Conso. Net Sales]		Nvarchar(20) default ''0'',
				[Promo. Qty]					Nvarchar(20) default ''0'',
				[Promo. Gross Value]			Nvarchar(20) default ''0'',
				[Promo. Inv. Value]				Nvarchar(20) default ''0'',
				[Promo. Conso. Net Sales]		Nvarchar(20) default ''0'',
				[Return Qty]					Nvarchar(20) default ''0'',
				[Consign. Qty]					Nvarchar(20) default ''0'',
				[Free. Qty]						Nvarchar(20) default ''0''
			)'

			if @debug>0
			begin
				select @sql 'Create table'
			end
			execute(@sql)
		end


		select @n_err = @@ERROR
		if @n_err<>0
		begin
			select @n_continue = 3
			select @n_err=60005
			select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +ERROR_MESSAGE()+'./ ('+@sp_name+')'
		end
	end
	if @n_continue=1
	begin
		select @sql = '
		BULK INSERT '+@tablename+'
		FROM '''+@FullName+'''
		WITH
		( 
			DATAFILETYPE = ''char'',
			FIRSTROW = 1,
			FIELDTERMINATOR = '';'', 
			ROWTERMINATOR = ''0x0a''
			,TABLOCK
		)'
		if @debug>0
		begin
			select @sql as 'insert into table tmp'
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
	if @debug>0
	begin
		select 'Delete M0, M-1'
	end
	if @n_continue=1
	begin
		--get fromdate to date from tmp file
		declare @fromdate nvarchar(6), @todate nvarchar(6)
		
		select distinct
			@fromdate=cast(min(cast([Billing Date] as numeric(18,0))) as nvarchar(6)),
			@ToDate=cast(max(cast([Billing Date] as numeric(18,0))) as nvarchar(6))
		from sap_to_fm_tmp (NOLOCK)
		if @debug>0
		begin
			select @fromdate '@fromdate', @todate '@todate'
		end
		if @debug>0
		begin
			select 'check table contains, if yes-->delete Month align month tmp'
		end
		if exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID(@tablenamefinal) AND type in (N'U')
		)
		begin
			select @sql='delete '+@tablenamefinal+' where [Billing Date] between '+@fromdate+' and '+@ToDate+' '
			if @debug>0
			begin
				select @sql 'delete table'
			end
			execute(@sql)
		end
		else
		begin
			select @sql=
			'create table '+@tablenamefinal+'
			(
				[Material]						Nvarchar(50) null,
				[FMlevel3]						Nvarchar(20) null,
				[Sold-to party]					Nvarchar(20) null,
				[Sales Group]					Nvarchar(20) null,
				[Sales Office]					Nvarchar(20) null,
				[Plant]							Nvarchar(20) null,
				[Customer group]				Nvarchar(20) null,
				[Customer Hierarchy - Medium]	Nvarchar(20) null,
				[Customer Hierarchy - Top]		Nvarchar(20) null,
				[Billing Date]					numeric(18,0) default 0,
				[Billing Quantity]				Numeric(18,0) default 0,
				[Gross Sales Value]				Numeric(18,2) default 0,
				[Invoiced Sales Value]			Numeric(18,2) default 0,
				[Consolidated Net Sales]		Numeric(18,2) default 0,
				[Comp. Qty]						Numeric(18,0) default 0,
				[Comp. Gross Value]				Numeric(18,2) default 0,
				[Comp. Inv. Value]				Numeric(18,2) default 0,
				[Comp. Conso. Net Sales]		Numeric(18,2) default 0,
				[Promo. Qty]					Numeric(18,0) default 0,
				[Promo. Gross Value]			Numeric(18,2) default 0,
				[Promo. Inv. Value]				Numeric(18,2) default 0,
				[Promo. Conso. Net Sales]		Numeric(18,2) default 0,
				[Return Qty]					Numeric(18,0) default 0,
				[Consign. Qty]					Numeric(18,0) default 0,
				[Free. Qty]						Numeric(18,0) default 0
			)'
			if @debug>0
			begin
				select @sql 'create table'
			end
			execute(@sql)
		end
	end

	if @n_continue=1
	begin
		select @sql=
		'INSERT INTO '+@tablenamefinal+'
		select
			[Material],
			[FMlevel3],
			[Sold-to party],
			[Sales Group],
			[Sales Office],
			[Plant],
			[Customer group],
			[Customer Hierarchy - Medium],
			[Customer Hierarchy - Top],
			[Billing Date]=cast([Billing Date] as numeric(18,0)),
			[Billing Quantity]=cast(replace([Billing Quantity],'','',''.'') as numeric(18,0)),
			[Gross Sales Value]=cast(replace([Gross Sales Value],'','',''.'') as numeric(18,2)),
			[Invoiced Sales Value]=cast(replace([Invoiced Sales Value],'','',''.'') as numeric(18,2)),
			[Consolidated Net Sales]=cast(replace([Consolidated Net Sales],'','',''.'') as numeric(18,2)),
			[Comp. Qty]=cast(replace([Comp. Qty],'','',''.'') as numeric(18,0)),
			[Comp. Gross Value]=cast(replace([Comp. Gross Value],'','',''.'') as numeric(18,2)),
			[Comp. Inv. Value]=cast(replace([Comp. Inv. Value],'','',''.'') as numeric(18,2)),
			[Comp. Conso. Net Sales]=cast(replace([Comp. Conso. Net Sales],'','',''.'') as numeric(18,2)),
			[Promo. Qty]=cast(replace([Promo. Qty],'','',''.'') as numeric(18,0)),
			[Promo. Gross Value]=cast(replace([Promo. Gross Value],'','',''.'') as numeric(18,2)),
			[Promo. Inv. Value]=cast(replace([Promo. Inv. Value],'','',''.'') as numeric(18,2)),
			[Promo. Conso. Net Sales]=cast(replace([Promo. Conso. Net Sales],'','',''.'') as numeric(18,2)),
			[Return Qty]=cast(replace([Return Qty],'','',''.'') as numeric(18,0)),
			[Consign. Qty]=cast(replace([Consign. Qty],'','',''.'') as numeric(18,0)),
			[Free. Qty]=cast(replace(case when len(replace([Free. Qty],char(13),''''))=0 then ''0'' else replace([Free. Qty],char(13),'''') end,'','',''.'') as numeric(18,0))
		from '+@tableName

		if @debug>0
		begin
			select @sql 'Insert table main'
		end
		execute(@sql)

	end
	if @n_continue = 3
	begin
		rollback
		select @b_Success = 0
		exec sp_SendEmail_Auto_Order_Process 'SAP_TO_FM','Import SAP_To_FM_INTO_DATA_LAKE','Fail.../'
	end
	else
	begin
		Commit
		exec sp_SendEmail_Auto_Order_Process 'SAP_TO_FM','Import SAP_To_FM_INTO_DATA_LAKE','Successfully.../'
		select @b_Success = 1, @c_errmsg = 'Successfully.../'
	end
END TRY
BEGIN CATCH
   ROLLBACK
   DECLARE @ErrorMessage VARCHAR(2000)
   SELECT @ErrorMessage = 'Error: '+ ERROR_MESSAGE()
   RAISERROR(@ErrorMessage , 16, 1)
END CATCH