/*
	declare 
		@b_Success		Int,
		@c_errmsg		Nvarchar(250)

	exec sp_Launch_validate_mismatch 'PPD','202410',@b_Success OUT, @c_errmsg OUT

	select @b_Success b_Success, @c_errmsg c_errmsg

	/*
		MasterData-->select * from OT_Launch_validate_mismatch_MasterData
		--BOM_vs_masterbom-->select * from OT_Bom_validate_mismatch_BOM_vs_masterbom
		--BOM_vs_masterdata-->select * from OT_Bom_validate_mismatch_BOM_vs_masterdata
		RSP-->select * from OT_Launch_validate_mismatch_RSP
	*/
*/
Alter proc sp_Launch_validate_mismatch
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
		@sp_name = 'sp_Launch_validate_mismatch',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	select @debug=debug from fnc_Debug('FC')	
	--select @debug=1

	declare @Monthfc			nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from V_FC_FM_Table

	declare @list_product_type	nvarchar(20)=''
	declare @ColumnRelationShip nvarchar(20)=''
	declare @ColumnCompare		nvarchar(50)=''
	declare @Functionname		nvarchar(50)='Launch'
	declare @Type				nvarchar(50)=''

	select 
		@list_product_type=[Product Type],
		@ColumnRelationShip=[Column Relationship],
		@ColumnCompare=[Column Compare] 
	from V_FC_DIVISION_BY_PRODUCT_TYPE 
	where [Division]=@Division

	declare @ListColumn_Current	nvarchar(max) = ''
	SELECT @ListColumn_Current=ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'Column_fc_rsp','')
	--SELECT ListColumn_Current=ListColumn FROM fn_FC_GetColheader_Current('202410','Column_fc_rsp','')

	declare @ListColumn_Current_validate_RSP	nvarchar(max) = ''
	SELECT @ListColumn_Current_validate_RSP=ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'validate_rsp','x')
	--SELECT ListColumn_Current_validate_RSP=ListColumn FROM fn_FC_GetColheader_Current('202410','validate_rsp','x')

	declare @ListColumn_Current_validate_RSP_text	nvarchar(max) = ''
	SELECT @ListColumn_Current_validate_RSP_text=ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'validate_rsp_text','')
	--SELECT ListColumn_Current_validate_RSP_text=ListColumn FROM fn_FC_GetColheader_Current('202410','validate_rsp_text','')

	declare @ListColumn_Current_plus	nvarchar(max) = ''
	SELECT @ListColumn_Current_plus = ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'1. Baseline Qty_+','')
	--SELECT ListColumn_Current_plus = ListColumn FROM fn_FC_GetColheader_Current('202410','1. Baseline Qty_+','')

	declare @ListColumn_Current_sum	nvarchar(max) = ''
	SELECT @ListColumn_Current_sum = ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'6. Total Qty','')
	--SELECT @ListColumn_Current_sum = ListColumn FROM fn_FC_GetColheader_Current('202410','6. Total Qty','')
	
	declare @listColumn_his_error_alert_set_0 nvarchar(max)=''
	select @listColumn_his_error_alert_set_0=ListColumn from fn_FC_GetColHeader_Historical(@FM_KEY,'si',101)
	--select listColumn_his_error_alert_set_0=ListColumn from fn_FC_GetColHeader_Historical('202407','si',101)

	declare @table_Name		nvarchar(300)=''
	select @table_Name='fc_validate_mismatch_si_his_fc'

	if @debug>0
	begin
		select 'OFFLINE LAUNCH SINGLE vs MasterData'
	end
	if @n_continue=1
	begin
		select @Type='MasterData'

		select @sql=
		'Delete '+@Table_Name+' 
		where 
			[Division]='''+@Division+''' 
		and [FM_KEY]='''+@FM_KEY+''' 
		and [Function Name]='''+@Functionname+'''
		and [Type Name]='''+@Type+''' '

		if @debug>0
		begin
			select 'Delete table Name'
		end
		execute(@sql)

		select @sql=
		'INSERT INTO '+@Table_Name+'
		select
			[Division]='''+@Division+''',
			[FM_KEY]='''+@FM_KEY+''',
			[Function Name]='''+@Functionname+''',
			[Type Name]='''+@Type+''',
			x.*
		from
		(
			select 
				[SUB GROUP/ Brand]=ISNULL(f.SubGrp,''''),
				[Channel]=ISNULL(f.[Channel],''''),
				[Time series]=ISNULL([Time series],''''),
				[EAN Code]='''',
				[SKU Code]='''',
				'+@listColumn_his_error_alert_set_0+','
				+@ListColumn_Current_sum+'
			from FC_SI_Launch_Single_'+@Division+@Monthfc+' f
			left join
			(
				select DISTINCT
					[SUB GROUP/ Brand],
					[Item Category Group]
				from fnc_SubGroupMaster('''+@Division+''',''full'')
			) s on s.[SUB GROUP/ Brand]=f.SubGrp
			where 
					ISNULL([Channel],'''')=''OFFLINE''
				and ISNULL([Item Category Group],'''')<>''LUMF''
				and ISNULL(s.[SUB GROUP/ Brand],'''')=''''
			group by
				f.SubGrp,
				f.[Channel],
				f.[Time series]
		) as x
		where ('+@ListColumn_Current_plus+')<>0'
		if @debug>0
		begin
			select @sql '@sql OFFLINE LAUNCH SINGLE vs MasterData'
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
		select 'OFFLINE LAUNCH SINGLE vs RSP'
	end
	if @n_continue=1
	begin
		select @Type='RSP'

		select @sql=
		'Delete '+@Table_Name+' 
		where 
			[Division]='''+@Division+''' 
		and [FM_KEY]='''+@FM_KEY+''' 
		and [Function Name]='''+@Functionname+'''
		and [Type Name]='''+@Type+''' '

		if @debug>0
		begin
			select 'Delete table Name'
		end
		execute(@sql)

		select @sql=
		'INSERT INTO '+@Table_Name+'
		select
			[Division]='''+@Division+''',
			[FM_KEY]='''+@FM_KEY+''',
			[Function Name]='''+@Functionname+''',
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
				[Channel],
				[Time series],
				'+@ListColumn_Current_validate_RSP+'
			from
			(
				select 
					[SUB GROUP/ Brand]=ISNULL(f.[SubGrp],''''),
					[Channel]=ISNULL(f.[Channel],''''),
					[Time series]=ISNULL(f.[Time series],''''),
					'+@ListColumn_Current_sum+'
				from FC_SI_Launch_Single_'+@Division+@Monthfc+' f
				left join
				(
					select DISTINCT
						[SUB GROUP/ Brand],
						[Item Category Group],
						[Product Type]
					from fnc_SubGroupMaster('''+@Division+''',''full'')
				) s on s.[SUB GROUP/ Brand]=f.SubGrp '
		select @sql1=
				'where 
						ISNULL(f.[Channel],'''')=''OFFLINE''					
					and ISNULL(s.[Item Category Group],'''')<>''LUMF''
					and ISNULL(s.[Product Type],'''')=''YFG''
					and ISNULL(s.[SUB GROUP/ Brand],'''')<>''''
				group by
					f.[SubGrp],
					f.[Channel],
					f.[Time series]
			) as x
			left join
			(
				select DISTINCT
					[SUB GROUP/ Brand],
					'+@ListColumn_Current+'
				from fnc_SubGroupMaster_RSP('''+@Division+''',''full'')
			) rsp on rsp.[SUB GROUP/ Brand]=x.[SUB GROUP/ Brand]
		) as x 
		where ('+@ListColumn_Current_plus+')<>0 '

		if @debug>0
		begin
			select @sql+@sql1 '@sql OFFLINE LAUNCH SINGLE vs RSP'
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
	--if @debug>0
	--begin
	--	select 'Update Missing BOM_vs_masterbom,BOM_vs_masterdata'
	--end
	--if @n_continue=1
	--begin
	--	if exists(select 1 from fnc_fc_validate_mismatch(@Division,@FM_KEY,@FunctionName,'BOM_vs_masterbom,BOM_vs_masterdata'))
	--	begin
	--		update fc_error_alert
	--		set 
	--			[Status]=isnull([Status],0)+1
	--		where 
	--			[Error Name]='Missing BOM'
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
