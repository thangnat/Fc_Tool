/*
	declare 
		@b_Success		Int,
		@c_errmsg		Nvarchar(250)

	exec sp_BUDGET_TREND_validate_mismatch 'CPD','202412','T',@b_Success OUT, @c_errmsg OUT

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
Alter proc sp_BUDGET_TREND_validate_mismatch
	@Division		nvarchar(3),
	@FM_KEY			nvarchar(6),
	@Foldername		nvarchar(50),
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
		@sp_name = 'sp_BUDGET_validate_mismatch',
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
	
	declare @table_Name		nvarchar(300)=''
	select @table_Name='fc_validate_mismatch_si_his_fc'

	select @FunctionName=case 
							when @Foldername='B' then 'Budget' 
							when @Foldername='PB' then 'Pre_Budget' 
							when @Foldername='T' then 'Trend' 
							else '' 
						end

	declare @table_budget nvarchar(200)=''
	select @table_budget='FC_'+case 
									when @Foldername='B' then 'Budget' 
									when @Foldername='PB' then 'Pre_Budget' 
									when @Foldername='T' then 'Trend' 
									else '' 
								end+'_'+@division++'_'+@fm_key

	declare @listA	nvarchar(max)
	SELECT @listA=listcolumn FROM fn_FC_GetColheader_Current_BT(@FM_KEY,'','B',103)
	--SELECT listA=listcolumn FROM fn_FC_GetColheader_Current_BT('202407','','B',103)
	declare @listB	nvarchar(max)
	SELECT @listB=listcolumn FROM fn_FC_GetColheader_Current_BT(@FM_KEY,'','B',1031)
	--SELECT listB=listcolumn FROM fn_FC_GetColheader_Current_BT('202407','','T',1031)

	declare @list_column_set0 nvarchar(max)=''
	select @list_column_set0='[Y-2 (u) M1]=0,[Y-2 (u) M2]=0,[Y-2 (u) M3]=0,[Y-2 (u) M4]=0,[Y-2 (u) M5]=0,[Y-2 (u) M6]=0,
	[Y-2 (u) M7]=0,[Y-2 (u) M8]=0,[Y-2 (u) M9]=0,[Y-2 (u) M10]=0,[Y-2 (u) M11]=0,[Y-2 (u) M12]=0,
	[Y-1 (u) M1]=0,[Y-1 (u) M2]=0,[Y-1 (u) M3]=0,[Y-1 (u) M4]=0,[Y-1 (u) M5]=0,[Y-1 (u) M6]=0,
	[Y-1 (u) M7]=0,[Y-1 (u) M8]=0,[Y-1 (u) M9]=0,[Y-1 (u) M10]=0,[Y-1 (u) M11]=0,[Y-1 (u) M12]=0'
	
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
			WHERE object_id = OBJECT_ID(@table_budget) AND type in (N'U')
		)
		begin
			select @n_continue=3,@c_errmsg='Table name'+@table_budget+'not exists.../'
		end
	end
	if @debug>0
	begin
		select @FunctionName+' vs MasterData'--OFFLINE SINGLE
	end
	if @n_continue=1
	begin
		select @Type='MasterData'
		
		if exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID(@table_Name) AND type in (N'U')
		)
		begin
			select @sql=
			'Delete '+@table_Name+' 
			where 
				[Division]='''+@Division+''' 
			and [FM_KEY]='''+@FM_KEY+''' 
			and [Function Name]='''+@FunctionName+'''
			and [Type Name]='''+@Type+''' '

			if @debug>0
			begin
				select @sql '@sql Delete table Name'
			end
			execute(@sql)
		end

		select @sql=
		'INSERT INTO '+@table_Name+'
		select
			[Division]='''+@Division+''',
			[FM_KEY]='''+@FM_KEY+''',
			[Function Name]='''+@FunctionName+''',
			[Type Name]='''+@Type+''',
			[SUB GROUP/ Brand],
			[Channel],
			[Time series],
			[EAN Code],
			[SKU Code],'
			+@list_column_set0+','+@listB+'
		from
		(
			select
				[SUB GROUP/ Brand]=[SUB-GROUP],
				[Channel],
				[Time series],
				[EAN Code]=[EAN],
				[SKU Code]='''',
				[year],'+@listA+'
			from 
			(
				select 
					[Channel],
					[EAN],
					[SUB-GROUP],
					[Time series],
					[M1],
					[M2],
					[M3],
					[M4],
					[M5],
					[M6],
					[M7],
					[M8],
					[M9],
					[M10],
					[M11],
					[M12],
					[Year]=case when [version]=year(getdate()) then ''Y0'' else ''Y+1'' end
				from '+@table_budget+'
			) as x
			left join
			(
				select DISTINCT
					[SUB GROUP/ Brand]
				from fnc_SubGroupMaster('''+@division+''',''full'')
			) s on s.[SUB GROUP/ Brand]=x.[SUB-GROUP]
			where 
				isnull(s.[SUB GROUP/ Brand],'''')=''''
		) as x
		group by
			[Channel],
			[SUB GROUP/ Brand],
			[Time series],
			[EAN Code],
			[SKU Code] '

		if @debug>0
		begin
			select @sql '@sql BUDGET vs MasterData'
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
		'Delete '+@table_Name+' 
		where 
			[Division]='''+@Division+''' 
		and [FM_KEY]='''+@FM_KEY+''' 
		and [Function Name]='''+@FunctionName+'''
		and [Type Name]='''+@Type+'''
		and 
		(
			[Y-2 (u) M1]+[Y-2 (u) M2]+[Y-2 (u) M3]+[Y-2 (u) M4]+[Y-2 (u) M5]+[Y-2 (u) M6]+[Y-2 (u) M7]+[Y-2 (u) M8]+[Y-2 (u) M9]+[Y-2 (u) M10]+[Y-2 (u) M11]+[Y-2 (u) M12]+
			[Y-1 (u) M1]+[Y-1 (u) M2]+[Y-1 (u) M3]+[Y-1 (u) M4]+[Y-1 (u) M5]+[Y-1 (u) M6]+[Y-1 (u) M7]+[Y-1 (u) M8]+[Y-1 (u) M9]+[Y-1 (u) M10]+[Y-1 (u) M11]+[Y-1 (u) M12]+
			[Y0 (u) M1]+[Y0 (u) M2]+[Y0 (u) M3]+[Y0 (u) M4]+[Y0 (u) M5]+[Y0 (u) M6]+[Y0 (u) M7]+[Y0 (u) M8]+[Y0 (u) M9]+[Y0 (u) M10]+[Y0 (u) M11]+[Y0 (u) M12]+
			[Y+1 (u) M1]+[Y+1 (u) M2]+[Y+1 (u) M3]+[Y+1 (u) M4]+[Y+1 (u) M5]+[Y+1 (u) M6]+[Y+1 (u) M7]+[Y+1 (u) M8]+[Y+1 (u) M9]+[Y+1 (u) M10]+[Y+1 (u) M11]+[Y+1 (u) M12]
		)=0'

		if @debug>0
		begin
			select @sql '@sql Delete table Name where =0'
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

	--if @debug>0
	--begin
	--	select @FunctionName+' vs RSP'
	--end
	--if @n_continue=9
	--begin
	--	select @Type='RSP'
		
	--	select @sql=
	--	'Delete '+@table_Name+' 
	--	where 
	--		[Division]='''+@Division+''' 
	--	and [FM_KEY]='''+@FM_KEY+''' 
	--	and [Function Name]='''+@FunctionName+'''
	--	and [Type Name]='''+@Type+''' '

	--	if @debug>0
	--	begin
	--		select 'Delete table Name'
	--	end
	--	execute(@sql)

	--	select @sql=
	--	'INSERT INTO '+@table_Name+'
	--	select
	--		[Division]='''+@Division+''',
	--		[FM_KEY]='''+@FM_KEY+''',
	--		[Function Name]='''+@FunctionName+''',
	--		[Type Name]='''+@Type+''',
	--		[SUB GROUP/ Brand]=x.[SUB GROUP/ Brand],
	--		[Channel],
	--		[Time series],
	--		[EAN Code],
	--		[SKU Code],
	--		'+@ListColumn_Current_validate_RSP_text+'
	--	from
	--	(
	--		select
	--			[SUB GROUP/ Brand]=x.[SUB GROUP/ Brand],
	--			[Channel],
	--			[Time series],
	--			[EAN Code],
	--			[SKU Code],
	--			'+@ListColumn_Current_validate_RSP+'
	--		from
	--		(
	--			select 
	--				[SUB GROUP/ Brand]=[SUB-GROUP],
	--				[Channel],
	--				[Time series],
	--				[EAN Code]=[EAN],
	--				[SKU Code]='''',
	--				M1,M2,M3,M4,M5,M6,M7,M8,M9,M10,M11,M12
	--			from '+@table_budget+' f
	--		) as x
	--		left join
	--		(
	--			select DISTINCT
	--				[SUB GROUP/ Brand],
	--				'+@ListColumn_Current+'
	--			from fnc_SubGroupMaster_RSP('''+@Division+''',''full'') f
	--		) rsp on rsp.[SUB GROUP/ Brand]=x.[SUB GROUP/ Brand]
	--	) as x 
	--	where ('+@ListColumn_Current_plus+')<>0 '

	--	if @debug>0
	--	begin
	--		select @sql+@sql1 'RSP'
	--	end
	--	execute(@sql+@sql1)

	--	select @n_err = @@ERROR
	--	if @n_err<>0
	--	begin				
	--		select @n_continue = 3
	--		select @n_err=60002
	--		select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +ERROR_MESSAGE()+'./ ('+@sp_name+')'
	--	end
	--end

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

	--if @debug>0
	--begin
	--	select 'Update Missing RSP'
	--end
	--if @n_continue=9
	--begin
	--	if exists(select 1 from fnc_fc_validate_mismatch(@Division,@FM_KEY,@FunctionName,'RSP'))
	--	begin
	--		update fc_error_alert
	--		set 
	--			[Status]=isnull([Status],0)+1
	--		where 
	--			[Error Name]='Missing RSP'
	--		and [Division]=@Division
	--		and [FM_KEY]=@FM_KEY

	--		select @n_err = @@ERROR
	--		if @n_err<>0
	--		begin				
	--			select @n_continue = 3
	--			select @n_err=60002
	--			select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +ERROR_MESSAGE()+'./ ('+@sp_name+')'
	--		end
	--	end
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