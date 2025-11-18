/*
	Declare
		@b_Success			Int,
		@c_errmsg			Nvarchar(250)

	exec sp_add_FC_GIT 'LDB','202502',@b_Success OUT,@c_errmsg OUT

	select @b_Success b_Success,@c_errmsg c_errmsg

	select * from FC_GIT_LDB_202502
	--select * from FC_GIT_More_LDB_202502
*/
Alter proc sp_add_FC_GIT
	@Division			nvarchar(3),
	@FM_Key				nvarchar(6),
	@b_Success			Int				OUTPUT,     
	@c_errmsg			Nvarchar(250)	OUTPUT
	with encryption
AS
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
		,@rowcount1				int = 0
			
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
		@sp_name = 'sp_add_FC_GIT',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()	

	select @debug=debug from fnc_debug('FC')
	--select @debug=1

	declare @Monthfc				nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from V_FC_FM_Table

	declare @GIT_filename			nvarchar(100) = ''
	select @GIT_filename = CASE 
								WHEN @division IN('LLD','PPD','LDB') THEN 'GIT_'+@FM_Key+'.xlsx' 
								when @division = 'CPD' then 'GIT_6M.xlsx' 
								--when @division = 'LDB' then 'GIT_6M.xlsx' 
							END
	declare @tablename nvarchar(100) = ''
	select @tablename = 'FC_GIT_'+@Division+@Monthfc

	--declare @tablename_more nvarchar(100) = ''
	--select @tablename_more = 'FC_GIT_More_'+@Division+@Monthfc

	if @debug>0
	begin
		select @GIT_filename '@GIT_filename', @tablename '@tablename'
	end

	--begin tran
	if @debug>0
	begin
		select 'create table name'
	end
		
	IF @n_continue=1
	BEGIN
		if exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID(@tablename) AND type in (N'U')
		)
		begin
			select @sql ='drop table '+@tablename
			if @debug>0
			begin
				select @sql '@sql drop table'
			end
			execute(@sql)
		end
		if @Division IN('LLD','PPD','LDB')
		begin
			select @sql=
			'CREATE TABLE '+@tablename+'
			(
				[Filename] [varchar](15) NOT NULL,
				[6digits] [nvarchar](255) NULL,
				[Material] [nvarchar](255) NULL,
				[SAP Name] [nvarchar](255) NULL,
				[Vendor] [nvarchar](255) NULL,
				[M0] [float] NULL,
				[M1] [nvarchar](255) NULL,
				[M2] [nvarchar](255) NULL,
				[M3] [nvarchar](255) NULL,
				[M4] [nvarchar](255) NULL,
				[Total] [float] NULL					
			)'
		end
		--else if @Division='LDB123'
		--begin
		--	select @sql=
		--	'CREATE TABLE '+@tablename+'
		--	(
		--		[Filename] [varchar](25) NOT NULL,
		--		[Delivery] [nvarchar](255) NULL,
		--		[Item] [nvarchar](255) NULL,
		--		[Material] [nvarchar](255) NULL,
		--		[Description] [nvarchar](255) NULL,
		--		[Delivery quantity] [float] NULL,
		--		[Purchasing Document] [nvarchar](255) NULL,
		--		[Deliv# date(From/to)] [datetime] NULL,
		--		[Supplier] [nvarchar](255) NULL,
		--		[Means of Trans# ID] [nvarchar](255) NULL,
		--		[Plant] [nvarchar](255) NULL,
		--		[Storage Location] [nvarchar](255) NULL,
		--		[Total gds mvt stat#] [nvarchar](255) NULL,
		--		[Created By] [nvarchar](255) NULL,
		--		[Reference item] [nvarchar](255) NULL,
		--		[FEX invoice nb] [nvarchar](255) NULL
		--		/*,[SKU] [varchar](50) NULL,
		--		[Sales  Org] [varchar](50) NULL*/
		--	)'
		--end
		else if @Division='CPD'
		begin
			select @sql=
			'CREATE TABLE '+@tablename+'
			(
				[Filename] [varchar](25) NOT NULL,
				[Delivery] [nvarchar](255) NULL,
				[Item] [nvarchar](255) NULL,
				[Material] [nvarchar](255) NULL,
				[Description] [nvarchar](255) NULL,
				[Delivery quantity] [float] NULL,
				[Purchasing Document] [nvarchar](255) NULL,
				[Deliv# date(From/to)] [datetime] NULL,
				[Supplier] [nvarchar](255) NULL,
				[Means of Trans# ID] [nvarchar](255) NULL,
				[Plant] [nvarchar](255) NULL,
				[Storage Location] [nvarchar](255) NULL,
				[Total gds mvt stat#] [nvarchar](255) NULL,
				[Created By] [nvarchar](255) NULL,
				[Reference item] [nvarchar](255) NULL,
				[FEX invoice nb] [nvarchar](255) NULL
				/*,[SKU] [varchar](50) NULL,
				[Sales  Org] [varchar](50) NULL*/
			)'
		end
		if @debug>0
		begin
			select @sql 'Create table'
		end
		execute(@sql)
		commit tran
	END
	if @debug>0
	begin
		select 'import tmp file'
	end
	if @n_continue = 1
	begin
		if @DbName = 'master.dbo'
			exec link_37.master.dbo.sp_add_FC_GIT_Tmp @Division,@FM_Key,@GIT_filename, @b_Success1 OUT, @c_errmsg1 OUT
		else
			exec link_37.master_UAT.dbo.sp_add_FC_GIT_Tmp @Division,@FM_Key,@GIT_filename, @b_Success1 OUT, @c_errmsg1 OUT

		if @b_Success1=0
		begin
			select @n_continue = 3, @c_errmsg = @c_errmsg1
		end
	end

	BEGIN TRAN
	if @debug>0
	begin
		select 'import main data', @n_continue '@n_continue'
	end
	if @n_continue =1
	begin
		Select @sql =
		'INSERT INTO '+@tablename+'
		Select
			t.*
		from '+@DbName+'.FC_GIT_'+@Division+@Monthfc+'_Tmp t
		inner join 
		(
			select DISTINCT
				[SKU]=Material,
				[Sales  Org]
			from SC1.dbo.MM_ZMR54OLD_stg (NOLOCK)
		) m on m.SKU = '+case when @Division IN('LLD','LDB') then 't.[sap code]' else 't.[Material]' end+'
		where m.[Sales  Org]='''+case 
									when @Division ='LLD' then 'V100'
									when @Division ='CPD' then 'V200'
									when @Division ='PPD' then 'V300'
									when @Division ='LDB' then 'V400'
									else ''
								end+''' '

		if @debug>0
		begin
			select @sql '@sql import data'
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
	--if @n_continue =1
	--begin
		--if @Division='LDB'
		--begin
		--	if exists
		--	(
		--		SELECT * 
		--		FROM sys.objects 
		--		WHERE object_id = OBJECT_ID(@tablename_more) AND type in (N'U')
		--	)
		--	begin
		--		select @sql ='drop table '+@tablename_more
		--		if @debug>0
		--		begin
		--			select @sql '@sql drop table more'
		--		end
		--		execute(@sql)
		--	end

		--	select @sql=
		--	'create table '+@tablename_More+'
		--	(
		--		[Product Type]			nvarchar(500) null,
		--		[Sales Org]				nvarchar(5) null,
		--		[SUB GROUP/ Brand]		nvarchar(500) null,
		--		[Channel]				nvarchar(10),
		--		[GIT M0]				INT default 0,
		--		[GIT M1]				INT default 0,
		--		[GIT M2]				INT default 0,
		--		[GIT M3]				INT default 0
		--	) '
		--	if @debug>0
		--	begin
		--		select @sql '@sql create table more'
		--	end
		--	execute(@sql)

		--	Select @sql =
		--	'INSERT INTO '+@tablename_more+'
		--	Select
		--		[Product Type]=s.[Product Type],
		--		[Sales Org]=s.[Sales Org],
		--		[SUB GROUP/ Brand]=s.[SUB GROUP/ Brand],
		--		[Channel]=''OFFLINE'',
		--		[GIT M0]=sum(t.[GIT M0]),
		--		[GIT M1]=sum(t.[GIT M1]),
		--		[GIT M2]=sum(t.[GIT M2]),
		--		[GIT M3]=sum(t.[GIT M3])
		--	from '+@DbName+'.FC_GIT_'+@Division+@Monthfc+'_More_Tmp t
		--	inner join 
		--	(
		--		select DISTINCT 
		--			[Product Type],
		--			[Barcode],
		--			[Sales Org],
		--			[SUB GROUP/ Brand] 
		--		from fnc_SubGroupMaster('''+@division+''',''full'')
		--	) s on s.[Barcode] = t.[EAN Code]
		--	where s.[Sales Org]='''+case 
		--								when @Division ='LLD' then 'V100'
		--								when @Division ='CPD' then 'V200'
		--								when @Division ='PPD' then 'V300'
		--								when @Division ='LDB' then 'V400'
		--								else ''
		--							end+''' 
		--	group by
		--		s.[Product Type],
		--		s.[Sales Org],
		--		s.[SUB GROUP/ Brand] '

		--	if @debug>0
		--	begin
		--		select @sql '@sql import data'
		--	end
		--	execute(@sql)


		--	select @n_err = @@ERROR
		--	if @n_err<>0
		--	begin
		--		select @n_continue = 3
		--		--select @n_err=60003
		--		select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +ERROR_MESSAGE()+'./ ('+@sp_name+')'
		--	end
		--end
	--end
	
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