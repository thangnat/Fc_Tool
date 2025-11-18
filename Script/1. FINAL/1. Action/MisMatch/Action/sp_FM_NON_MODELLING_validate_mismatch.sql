/*
	declare 
		@b_Success		Int,
		@c_errmsg		Nvarchar(250)

	exec sp_FM_NON_MODELLING_validate_mismatch 'PPD','202410',@b_Success OUT, @c_errmsg OUT

	select @b_Success b_Success, @c_errmsg c_errmsg

	/*
		MasterData-->1. select * from fc_validate_mismatch where [Division]='CPD' and FM_KEY='202407' and [Type Name]='FM'
					 3. union -->select * from fnc_validate_mismatch('CPD','202407','FM')
		BOM_vs_masterbom-->1. select * from fc_validate_mismatch where [Division]='CPD'
		BOM_vs_masterdata-->2. select * from fc_validate_mismatch where [Division]='CPD'
							3. select * from fnc_validate_mismatch('CPD','202407','FM')
		RSP-->select * from fc_validate_mismatch where [Division]='CPD' and [FM_KEY]='202407' and [Type Name]='FM'
	*/
*/
Alter proc sp_FM_NON_MODELLING_validate_mismatch
	@Division		nvarchar(3),
	@FM_KEY			nvarchar(6),
	@b_Success		Int				OUTPUT,
	@c_errmsg		Nvarchar(250)	OUTPUT
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
		,@sql1					nvarchar(max) = ''
		,@sql2					nvarchar(max) = ''

	declare 
		@b_Success1				Int,
		@c_errmsg1				Nvarchar(250)

	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_FM_NON_MODELLING_validate_mismatch',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()	

	select @debug=debug from fnc_Debug('FC')	
	--select @debug=1

	declare @Monthfc			nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from V_FC_FM_Table

	declare @list_product_type	nvarchar(20)=''
	declare @ColumnRelationShip nvarchar(20)=''
	declare @ColumnCompare		nvarchar(50)=''
	declare @FunctionName		nvarchar(50)=''
	declare @Type				nvarchar(50)=''

	select 
		@list_product_type=[Product Type],
		@ColumnRelationShip=[Column Relationship],
		@ColumnCompare=[Column Compare] 
	from V_FC_DIVISION_BY_PRODUCT_TYPE 
	where [Division]=@Division

	declare @ListColumn_Current_sum			nvarchar(max) = ''
	SELECT @ListColumn_Current_sum = ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'1. Baseline Qty','')
	--SELECT ListColumn_Current_sum = ListColumn FROM fn_FC_GetColheader_Current('202410','1. Baseline Qty','')

	declare @ListColumn_Current	nvarchar(max) = ''
	SELECT @ListColumn_Current=ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'Column_fc_rsp','')
	--SELECT ListColumn_Current=ListColumn FROM fn_FC_GetColheader_Current('202410','Column_fc_rsp','')

	declare @ListColumn_Current_validate_RSP	nvarchar(max) = ''
	SELECT @ListColumn_Current_validate_RSP=ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'validate_rsp','x')
	--SELECT ListColumn_Current_validate_RSP=ListColumn FROM fn_FC_GetColheader_Current('202410','validate_rsp','x')

	declare @ListColumn_Current_validate_RSP_text	nvarchar(max) = ''
	SELECT @ListColumn_Current_validate_RSP_text=ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'validate_rsp_text','')
	--SELECT ListColumn_Current_validate_RSP_text=ListColumn FROM fn_FC_GetColheader_Current('202407','validate_rsp_text','')

	declare @ListColumn_Current_plus	nvarchar(max) = ''
	SELECT @ListColumn_Current_plus = ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'1. Baseline Qty_+','')
	--SELECT ListColumn_Current_plus = ListColumn FROM fn_FC_GetColheader_Current('202410','1. Baseline Qty_+','')
	
	declare @listColumn_his_error_alert_set_0 nvarchar(max)=''
	select @listColumn_his_error_alert_set_0=ListColumn from fn_FC_GetColHeader_Historical(@FM_KEY,'si',101)
	--select listColumn_his_error_alert_set_0=ListColumn from fn_FC_GetColHeader_Historical('202407','si',101)

	declare @table_Name		nvarchar(300)=''
	select @table_Name='fc_validate_mismatch_si_his_fc'

	declare @tableNon nvarchar(200)=''
	select @tableNon='FC_FM_Non_modeling_Final_'+@Division+'_'+@FM_KEY

	if @debug>0
	begin
		select 'Check table exists'
	end
	if @n_continue=1
	begin
		if not exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID(@tableNon) AND type in (N'U')
		)
		begin
			select @n_continue=3,@c_errmsg='Table name'+@tableNon+'not exists.../'
		end
	end
	if @debug>0
	begin
		select 'FM NON MODELLING vs MasterData'--OFFLINE SINGLE
	end
	if @n_continue=1
	begin
		select @FunctionName='FM Non Modelling',@Type='MasterData'
		
		select @sql=
		'Delete '+@table_Name+' 
		where 
			[Division]='''+@Division+''' 
		and [FM_KEY]='''+@FM_KEY+''' 
		and [Type Name]='''+@FunctionName+'''
		and [Type Name]='''+@Type+'''
		and [Channel]=''OFFLINE''
		and [Time series]=''1. Baseline Qty'' '

		if @debug>0
		begin
			select 'Delete table Name'
		end
		execute(@sql)

		select @sql=
		'INSERT INTO '+@table_Name+'
		select 
			[Division]='''+@Division+''',
			[FM_KEY]='''+@FM_KEY+''',
			[Function Name]='''',
			[Type Name]='''',
			[SUB GROUP/ Brand],
			[Channel]=[Local Level],
			[Time series],
			[EAN Code],
			[SKU Code],'
			+@listColumn_his_error_alert_set_0+','
			+@ListColumn_Current+'
		from '+@tableNon+' f
		where 
			ISNULL([SUB GROUP/ Brand],'''')='''' 
		and ('+@ListColumn_Current_plus+')<>0 '

		if @debug>0
		begin
			select @sql '@sql ONLINE SINGLE vs MasterData'
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
		select 'FM Non Modelling vs RSP'
	end
	if @n_continue=1
	begin
		select @FunctionName='FM Non Modelling',@Type='RSP'
		
		select @sql=
		'Delete '+@table_Name+' 
		where 
			[Division]='''+@Division+''' 
		and [FM_KEY]='''+@FM_KEY+''' 
		and [Function Name]='''+@FunctionName+'''
		and [Type Name]='''+@Type+'''
		and [Channel]=''OFFLINE''
		and [Time series]=''1. Baseline Qty'' '

		if @debug>0
		begin
			select 'Delete table Name'
		end
		execute(@sql)

		select @sql=
		'INSERT INTO '+@table_Name+'
		select
			[Division]='''+@Division+''',
			[FM_KEY]='''+@FM_KEY+''',
			[Function Name]='''+@FunctionName+''',
			[Type Name]='''+@Type+''',
			[SUB GROUP/ Brand]=x.[SUB GROUP/ Brand],
			[Channel],
			[Time series],
			[EAN Code]='''',
			[SKU Code]='''',
			'+@listColumn_his_error_alert_set_0+','
			+@ListColumn_Current_validate_RSP_text+'
		from
		(
			select
				[SUB GROUP/ Brand]=x.[SUB GROUP/ Brand],
				[Product Type],
				[Channel],
				[Time series],
				'+@ListColumn_Current_validate_RSP+'
			from
			(
				select 
					[SUB GROUP/ Brand],
					[Product Type],
					[Channel]=ISNULL(f.[Local Level],''''),
					[Time series],
					'+@ListColumn_Current+'
				from FC_FM_Non_modeling_Final_'+@Division+'_'+@FM_KEY+' f
			) as x
			left join
			(
				select DISTINCT
					[SUB GROUP/ Brand],
					'+@ListColumn_Current+'
				from fnc_SubGroupMaster_RSP('''+@Division+''',''full'') f
			) rsp on rsp.[SUB GROUP/ Brand]=x.[SUB GROUP/ Brand]
		) as x 
		where ('+@ListColumn_Current_plus+')<>0 '

		if @debug>0
		begin
			select @sql+@sql1 'RSP'
		end
		execute(@sql+@sql1)

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
		select 'Update Missing Master Data'
	end
	if @n_continue=1
	begin
		if exists(select 1 from fnc_fc_validate_mismatch(@Division,@FM_KEY,@FunctionName,'Masterdata'))
		begin
			update fc_error_alert
			set 
				[Status]=isnull([Status],0)+1
			where 
				[Error Name]='Missing Master Data'
			and [Division]=@Division
			and [FM_KEY]=@FM_KEY

			select @n_err = @@ERROR
			if @n_err<>0
			begin				
				select @n_continue = 3
				select @n_err=60002
				select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +ERROR_MESSAGE()+'./ ('+@sp_name+')'
			end
		end
	end

	if @debug>0
	begin
		select 'Update Missing RSP'
	end
	if @n_continue=1
	begin
		if exists(select 1 from fnc_fc_validate_mismatch(@Division,@FM_KEY,@FunctionName,'RSP'))
		begin
			update fc_error_alert
			set 
				[Status]=isnull([Status],0)+1
			where 
				[Error Name]='Missing RSP'
			and [Division]=@Division
			and [FM_KEY]=@FM_KEY

			select @n_err = @@ERROR
			if @n_err<>0
			begin				
				select @n_continue = 3
				select @n_err=60002
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