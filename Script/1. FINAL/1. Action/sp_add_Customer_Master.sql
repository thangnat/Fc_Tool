/*
	Declare
		@b_Success			Int,
		@c_errmsg			Nvarchar(250)

	exec sp_add_Customer_Master 'LDB','202504',@b_Success OUT,@c_errmsg OUT

	select @b_Success b_Success,@c_errmsg c_errmsg

	select * from FC_MasterFile_LDB_Customer_Master where FM_KEY='202504'
*/

ALTER proc sp_add_Customer_Master
	@Division			nvarchar(3),
	@FM_KEY				Nvarchar(6),
	@b_Success			Int				OUTPUT,     
	@c_errmsg			Nvarchar(250)	OUTPUT
	with encryption
AS
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
		,@TableName				nvarchar(100)=''
		,@DbName NVARCHAR(20)

	Declare
		@b_Success1				Int,
		@c_errmsg1				Nvarchar(250)=''

	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_add_Customer_Master',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()
	
	select @debug=debug from fnc_debug('FC')
	--select @debug=1

	--declare @Monthfc				nvarchar(20)=''
	--select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from V_FC_FM_Table

	IF @Division NOT IN('CPD')
	BEGIN
		select @TableName ='FC_MasterFile_'+@Division+'_Customer_Master'
	END

	declare @Current_key date = cast(left(@FM_KEY,4)+'-'+substring(@FM_KEY,5,2)+'-01' as date),@currentYear nvarchar(4) = ''
	declare @sql nvarchar(max) = '', @rowcount1 int = 0
	declare @tmp table(id int identity(1,1), [Month_Desc] nvarchar(5),[Year] nvarchar(4))
	declare @result nvarchar(MAX) = '',@result0 nvarchar(MAX) = ''
	select @currentYear = year(@Current_key)	

	-- Get the environment configuration
	SELECT @DbName = CASE 
		WHEN Value = 'Production' THEN 'master.dbo'
		ELSE 'master_UAT'
	END
	FROM EnvironmentConfig
	WHERE Name = 'Current_Environment'

	if @debug>0
	begin
		select 'sp_add_MasterFile'
	end
	if @n_continue =1
	begin
		IF @Division IN('CPD')
		BEGIN
			exec sp_add_MasterFile_CPD @Division,@FM_KEY,'Customer_Master',@b_Success1 OUT, @c_errmsg1 OUT

			IF @b_Success1=0
			BEGIN
				SELECT @n_continue=3,@c_errmsg=@c_errmsg1
			END
		END
		else if @Division IN(select value from string_split('LLD,PPD',','))
		begin
			IF @DbName = 'master.dbo'
				exec link_37.master.dbo.sp_add_Customer_Master_Tmp @Division,@FM_KEY,@b_Success1 OUT,@c_errmsg1 OUT
			ELSE
				exec link_37.master_UAT.dbo.sp_add_Customer_Master_Tmp @Division,@FM_KEY,@b_Success1 OUT,@c_errmsg1 OUT

			if @b_Success1=0
			begin
				select @n_continue = 3, @c_errmsg = @c_errmsg1
			end
		end
	end
	BEGIN TRAN

	if @debug>0
	begin
		select 'Insert data'
	end
	IF @n_continue=1
	BEGIN
		if @Division IN(select value from string_split('LDB,LLD,PPD',','))
		begin
			if exists
			(
				SELECT * 
				FROM sys.objects 
				WHERE object_id = OBJECT_ID(@tablename) AND type in (N'U')
			)
			begin
				select @sql = 'Delete '+@tablename+' where [FM_KEY]='''+@FM_KEY+''' '
				if @debug>0
				begin
					select @sql 'delete table'
				end
				execute(@sql)
			end
			else
			begin
				select @sql=
				'create table '+@TableName+'
				(
					[FM_KEY]		nvarchar(6) null,
					[Node 5]		nvarchar(10) null,
					[Channel]		nvarchar(10) null
				)'
				if @debug>0
				begin
					select @sql 'create table'
				end
				execute(@sql)
			end

			if @Division IN(select value from string_split('LLD,PPD',','))
			begin
				select @sql='
				INSERT INTO '+@TableName+'
				SELECT
					[FM_KEY]='''+@FM_KEY+''',
					[Node 5]=right(''0000000000''+[Node 5],10),
					[Channel]					
				FROM '+@DbName+'.FC_MasterFile_'+@Division+'_Customer_Master_Tmp'
			end
			else if @Division IN('LDB')
			begin
				select @sql=
				'INSERT INTO '+@TableName+'
				select
					[FM_KEY]='''+@FM_KEY+''',
					*
				from
				(
					select
						*
					from
					(
						SELECT
							*
						FROM
						(
							select distinct
								[Node 5]=Z.[Node 5],
								[Channel]=CASE 
											WHEN ISNULL(D.[NODE 5],'''')<>'''' THEN 
												D.CHANNEL 
											ELSE
												CASE 
													WHEN [Distribution Channel]=''Y8'' THEN ''ONLINE''	
													ELSE 
														CASE 
															WHEN [Name 2]=''VN ACD OTHERS N2'' THEN ''OTHERS'' 
															WHEN CHARINDEX(''E-Commerce'',[Name 2],0)>0 THEN ''ONLINE'' 
															ELSE ''OFFLINE'' 
														END
												END
										END
							from sc1.dbo.ZS22 Z
							LEFT JOIN
							(
								SELECT 
									* 
								FROM FC_MAPPING_DEACTIVATION_LDB
							) D ON RIGHT(''0000000000''+D.[NODE 5],10)=RIGHT(''0000000000''+Z.[Node 5],10)
							where [Sales  Org]=''V400''
							and z.[Node 5] NOT IN(select DISTINCT [Customer Code] from V_FC_ACD_CUSTOMER_CONFIG)
							union All
							select distinct
								[Node 5]=[Customer Code],
								[Channel]=[Channel]
							from V_FC_ACD_CUSTOMER_CONFIG
						) AS X1
						WHERE CHANNEL<>''OTHERS''
					) as x
					WHERE 
						LEN([Node 5])>0
					AND Channel<>''''
					UNION ALL
					select
						[Node 5]=''999999'',
						[Channel]=''OFFLINE''
				) as x'
			end

			if @debug>0
			begin
				select @sql 'insert table'
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