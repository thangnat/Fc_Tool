/*
	Declare
		@b_Success			Int,
		@c_errmsg			Nvarchar(250)

	exec sp_add_FC_Master_File_FM 'LDB','202502',@b_Success OUT,@c_errmsg OUT

	select @b_Success b_Success,@c_errmsg c_errmsg

	select * from FC_FM_LDB_202501
	
	select *from FC_FM_Country_Status_LDB
*/
Alter proc sp_add_FC_Master_File_FM
	@Division			nvarchar(3),
	@FM_KEY				Nvarchar(6),
	@b_Success			Int				OUTPUT,     
	@c_errmsg			Nvarchar(250)	OUTPUT
	with encryption
AS
SET NOCOUNT ON
SET XACT_ABORT ON

BEGIN TRY
	DECLARE   
		 @debug					int=0
		,@sp_name				Nvarchar(100)
		,@n_continue			Int
		,@USERS					Nvarchar(50)
		,@MODIFILED				Datetime
		,@n_err					int
		,@fm_file_name			nvarchar(100) =''
		,@sql					nvarchar(max) = ''
	
	declare
		@b_Success1				Int,
		@c_errmsg1				Nvarchar(250)

	DECLARE @DbName NVARCHAR(20)

	-- Get the environment configuration
	SELECT @DbName = CASE 
		WHEN Value = 'Production' THEN 'master.dbo'
		ELSE 'master_UAT'
	END
	FROM EnvironmentConfig
	WHERE Name = 'Current_Environment'

	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_add_FC_Master_File_FM',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()
	
	select @debug=debug from fnc_debug('FC')
	select @debug=1

	declare @Monthfc				nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from V_FC_FM_Table
	
	declare @tablename_CountryStatus nvarchar(200) = ''
	declare @tablename nvarchar(200) = ''
	declare @tablename_tmp nvarchar(200) = ''
	select 
		@tablename = 'FC_FM_'+@Division+@Monthfc,
		@tablename_tmp = 'FC_FM_'+@Division+@Monthfc+'_tmp',
		@tablename_CountryStatus = 'FC_FM_Country_Status_'+@Division+@Monthfc

	
	if @debug>0
	begin
		select 'Import file FM Tmp'
	end
	if @n_continue = 1
	begin
		--//add tmp table
		IF @DbName = 'master.dbo'
			exec link_37.master.dbo.sp_add_FC_FM_Tmp @Division,@FM_KEY,@b_Success1 OUT, @c_errmsg1 OUT
		ELSE
			exec link_37.master_UAT.dbo.sp_add_FC_FM_Tmp @Division,@FM_KEY,@b_Success1 OUT, @c_errmsg1 OUT

		if @b_Success1 = 0
		begin
			select @n_continue = 3, @c_errmsg = @c_errmsg1
		end
	end
	IF @DbName = 'master.dbo'
		exec link_37.master.dbo.sp_getColumCount_New @tablename_tmp
	ELSE
		exec link_37.master_UAT.dbo.sp_getColumCount_New @tablename_tmp
	
	declare @result0 nvarchar(MAX) = ''
	SELECT @result0 = ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'FM',',')
	--SELECT result0 = ListColumn FROM fn_FC_GetColheader_Current('202411','FM',',')
	
	declare @result_table nvarchar(MAX) = ''
	SELECT @result_table = ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'FM-Table',',')
	--SELECT result_table = ListColumn FROM fn_FC_GetColheader_Current('202411','FM-Table',',')
	
	declare @result nvarchar(MAX) = ''
	SELECT @result = ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'FM_Tmp',',')
	--SELECT result = ListColumn FROM fn_FC_GetColheader_Current('202502','FM_Tmp',',')
	if @debug>0
	begin
		select tablename='FC_TotalCOlumn_Tmp',* from FC_TotalCOlumn_Tmp
	end
	if @debug>0
	begin
		select @c_errmsg '@c_errmsg'
	end
	BEGIN TRAN
	if @n_continue = 1
	begin
		if exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID(@tablename_CountryStatus) AND type in (N'U')
		)
		begin
			select @sql = 'drop table '+@tablename_CountryStatus
			if @debug>0
			begin
				select @sql '@sql drop table'
			end
			execute(@sql)
		end
		select @sql = '
		select
			[Channel] = [Local Level],
			[Sku Code],
			[Country Status]
			INTO '+@tablename_CountryStatus+'
		from '+@DbName+'.'+@tablename_tmp

		if @debug>0
		begin
			select @sql '@sql create table tablename_CountryStatus'
		end
		execute(@sql)
	end

	if @n_continue = 1
	begin
		if exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID(@tablename) AND type in (N'U')
		)
		begin
			select @sql='drop table '+@tablename
			execute(@sql)
		end

		select @sql = 
		'create table '+@tablename+'
		(
			[FM_KEY]			nvarchar(6) null,
			[Signature]			nvarchar(50) null,
			[BFL Code]			nvarchar(50) null,
			[BFL Name]			nvarchar(500) null,
			[EAN Code]			nvarchar(50) null,
			[SKU Code]			nvarchar(50) null,
			[SKU Name]			nvarchar(500) null,
			[Compass Code]		nvarchar(50) null,
			[Country Status]	nvarchar(50) null,
			[Local Level]		nvarchar(50) null,
			[Time series]		nvarchar(50) null,'
			+@result_table+'
		) '

		if @debug>0
		begin
			SELECT @sql '@sql create table tmp FM'
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
	if @n_continue=1
	begin
		select @sql=
		'INSERT INTO '+@tablename+'
		(
			[FM_KEY],
			[Signature],
			[BFL Code],
			[BFL Name],
			[EAN Code],
			[SKU Code],
			[SKU Name],
			[Compass Code],
			[Country Status],
			[Local Level],
			[Time series],'
			+@result0+
		')
		Select
			[FM_KEY] = '''+@FM_KEY+''',
			[Signature],
			[BFL Code],
			[BFL Name],
			[EAN Code],
			[SKU Code],
			[SKU Name],
			[Compass Code],
			[Country Status],
			[Local Level] = CASE
				WHEN [Local Level] LIKE ''%(ONLINE)%'' THEN ''ONLINE''
				WHEN [Local Level] LIKE ''%(OFFLINE)%'' THEN ''OFFLINE''
				ELSE [Local Level]
			END,
			[Time series] = CASE
				WHEN [Time series] = ''Validated BL Qty'' THEN ''Baseline Qty''
				ELSE [Time series]
			END,'
			+@result+'
			from '+@DbName+'.'+@tablename_tmp
	
		if @debug>0
		begin
			SELECT @sql '@sql Insert table tmp FM'
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
   IF @@TRANCOUNT > 0
        ROLLBACK
   DECLARE @ErrorMessage VARCHAR(2000)
   SELECT @ErrorMessage = 'Error: '+ ERROR_MESSAGE()
   RAISERROR(@ErrorMessage , 16, 1)
END CATCH