/*
	Declare 
		@b_Success		Int,
		@c_errmsg		Nvarchar(250)

	exec sp_Bom_Offline_validate_mismatch 'PPD','202410',@b_Success OUT, @c_errmsg OUT

	select @b_Success b_Success, @c_errmsg c_errmsg

	/*
		--MasterData-->1. select * from OT_Bom_validate_mismatch_Offline_MasterData
		--			 2. select * from OT_Bom_validate_mismatch_Online_MasterData
		BOM_vs_masterbom-->select * from OT_Bom_validate_mismatch_BOM_vs_masterbom
		BOM_vs_masterdata-->select * from OT_Bom_validate_mismatch_BOM_vs_masterdata
		RSP-->select * from OT_Bom_validate_mismatch_RSP
	*/
*/
Alter proc sp_Bom_Offline_validate_mismatch
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
		@sp_name = 'sp_Bom_Offline_validate_mismatch',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()
	
	select @debug=debug from fnc_Debug('FC')	
	--select @debug=1

	declare @Monthfc			nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from V_FC_FM_Table

	declare @list_product_type	nvarchar(20)=''
	declare @ColumnRelationShip nvarchar(20)=''
	declare @ColumnCompare		nvarchar(50)=''
	declare @Functionname		nvarchar(50)='Offline Bom'
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

	declare @Table_Name		nvarchar(300)=''
	select @Table_Name='fc_validate_mismatch_si_his_fc'

	if @debug>0
	begin
		select 'BOM_vs_masterbom'
	end
	if @n_continue=1
	begin
		select @Type='BOM_vs_masterbom'
		
		select @sql=
		'Delete '+@Table_Name+' 
		where 
			[Division]='''+@Division+''' 
		and [FM_KEY]='''+@FM_KEY+''' 
		and [Function Name]='''+@Functionname+'''
		and [Type Name]='''+@Type+''' '

		if @debug>0
		begin
			select @sql '@sql Delete table Name'
		end
		execute(@sql)

		select @sql=
		'INSERT INTO '+@Table_Name+'
		select
			[Division]='''+@Division+''',
			[FM_KEY]='''+@FM_KEY+''',
			[Function Name]='''+@FunctionName+''',
			[Type Name]='''+@Type+''',
			x.*
		from
		(
			select
				[SUB GROUP/ Brand]='''',
				[Channel],
				[Time series],
				[EAN Code]=[Barcode Component],
				[SKU Code]=[Material Component],
				'+@listColumn_his_error_alert_set_0+','
				+@ListColumn_Current+'
			from
			(
				select 
					[Channel]=ISNULL(f.[Channel],''''),
					[Time series]=ISNULL(f.[Time series],''''),
					[Barcode Bom]=ISNULL(zmr.[Barcode_Bom],''''),
					[Material Bom]=ISNULL(f.[Bundle Code],''''),
					[Barcode Component]=ISNULL(zmr.Barcode_Component,''''),
					[Material Component]=ISNULL(zmr.Material_Component,''''),
					'+@ListColumn_Current_sum+'
				from FC_SI_Promo_Bom_'+@Division+@Monthfc+' f
				Left join 
				(
					select 
						* 
					from V_ZMR32
					where [Material Type] IN(select value from string_split('''+@list_product_type+''','',''))
				) zmr on zmr.Material_Bom=f.[Bundle Code]
				where 
					ISNULL(f.[Channel],'''')=''OFFLINE''
				and ISNULL(f.[Time series],'''')=''3. Promo Qty(BOM)''
				group by
					f.[Channel],
					f.[Time series],
					f.[Bundle Code],
					zmr.[Barcode_Bom],
					zmr.Barcode_Component,
					zmr.Material_Component
			) as x1
			where 
			(
				'+@ListColumn_Current_plus+'
			)<>0
		) as x
		where ISNULL(x.[Sku Code],'''')='''' '

		if @debug>0
		begin
			select @sql '@Sql Bom Offline vs Master'
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
		select 'Bom Component vs Masterdata'
	end
	if @n_continue=1
	begin
		select @Type='BOM_vs_masterdata'
			
		select @sql=
		'Delete '+@Table_name+' 
		where 
			[Division]='''+@Division+''' 
		and [FM_KEY]='''+@FM_KEY+''' 
		and [Function Name]='''+@FunctionName+'''
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
			[Function Name]='''+@FunctionName+''',
			[Type Name]='''+@Type+''',
			[SUB GROUP/ Brand]=s.[SUB GROUP/ Brand],
			x.*
		from
		(
			select
				*
			from
			(
				select
					[Channel],
					[Time series],
					[EAN Code]=[Barcode Component],
					[SKU Code]=[Material Component],
					'+@listColumn_his_error_alert_set_0+','
					+@ListColumn_Current+'
				from
				(
					select 
						[Channel]=ISNULL(f.[Channel],''''),
						[Time series]=ISNULL(f.[Time series],''''),
						[Barcode Bom]=ISNULL(zmr.[Barcode_Bom],''''),
						[Material Bom]=ISNULL(f.[Bundle Code],''''),
						[Barcode Component]=ISNULL(zmr.Barcode_Component,''''),
						[Material Component]=ISNULL(zmr.Material_Component,''''),
						'+@ListColumn_Current_sum+'
					from FC_SI_Promo_Bom_'+@Division+@Monthfc+' f
					Left join 
					(
						select 
							* 
						from V_ZMR32
						where [Material Type] IN(select value from string_split('''+@list_product_type+''','',''))
					) zmr on zmr.Material_Bom=f.[Bundle Code]
					where 
						ISNULL(f.[Channel],'''')=''OFFLINE''
					and ISNULL(f.[Time series],'''')=''3. Promo Qty(BOM)''
					group by
						f.[Channel],
						f.[Time series],
						f.[Bundle Code],
						zmr.[Barcode_Bom],
						zmr.Barcode_Component,
						zmr.Material_Component
				) as x1
				where 
				(
					'+@ListColumn_Current_plus+'
				)<>0
			) as x
			where ISNULL(x.[SKU Code],'''')<>''''
		) AS x
		left join
		(
			select DISTINCT
				[Barcode],
				[SUB GROUP/ Brand]
			from fnc_SubGroupMaster('''+@Division+''',''full'')
		) s on s.[Barcode]=x.[EAN Code]
		/*s.[Material]=x.[Material Component]*/
		where ISNULL(s.[SUB GROUP/ Brand],'''')='''' '

		if @debug>0
		begin
			select @sql 'OFFLINE BOM vs ZMR32 vs Masterdata'
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
		select 'Missing RSP'
	end
	if @n_continue=1
	begin
		select @Type='RSP'

		select @sql=
		'Delete '+@Table_name+' 
		where 
			[Division]='''+@Division+''' 
		and [FM_KEY]='''+@FM_KEY+''' 
		and [Function Name]='''+@FunctionName+'''
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
				[Channel],
				[Time series],
				'+@ListColumn_Current_validate_RSP+'
			from
			(
				select
					s.[SUB GROUP/ Brand],
					x.*
				from
				(
					select
						*
					from
					(
						select
							[Channel],
							[Time series],
							[Barcode Bom],
							[Material Bom],
							[Barcode Component],
							[Material Component],
							'+@ListColumn_Current+'
						from
						(
							select 
								[Channel]=ISNULL(f.[Channel],''''),
								[Time series]=ISNULL(f.[Time series],''''),
								[Barcode Bom]=ISNULL(zmr.[Barcode_Bom],''''),
								[Material Bom]=ISNULL(f.[Bundle Code],''''),
								[Barcode Component]=ISNULL(zmr.Barcode_Component,''''),
								[Material Component]=ISNULL(zmr.Material_Component,''''),
								'+@ListColumn_Current_sum+'
							from FC_SI_Promo_Bom_'+@Division+@Monthfc+' f
							Left join 
							(
								select 
									* 
								from V_ZMR32
								where [Material Type] IN(select value from string_split('''+@list_product_type+''','',''))
							) zmr on zmr.Material_Bom=f.[Bundle Code] '
			select @sql1=
							'where 
								ISNULL(f.[Channel],'''')=''OFFLINE''
							and ISNULL(f.[Time series],'''')=''3. Promo Qty(BOM)''
							group by
								f.[Channel],
								f.[Time series],
								f.[Bundle Code],
								zmr.[Barcode_Bom],
								zmr.[Barcode_Component],
								zmr.[Material_Component]
						) as x1
						where 
						(
							'+@ListColumn_Current_plus+'
						)<>0
					) as x
					where ISNULL(x.[Material Component],'''')<>''''
				) AS x
				left join
				(
					select DISTINCT
						[Material],
						[SUB GROUP/ Brand]
					from fnc_SubGroupMaster('''+@Division+''',''full'')
				) s on s.[Material]=x.[Material Component]
				where ISNULL(s.[SUB GROUP/ Brand],'''')<>''''
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
		select 'Udpate Missing BOM'
	end
	if @n_continue=1
	begin
		if exists(select 1 from fnc_fc_validate_mismatch(@Division,@FM_KEY,@FunctionName,'BOM_vs_masterbom,BOM_vs_masterdata'))
		begin
			update fc_error_alert
			set 
				[Status]=isnull([Status],0)+1
			where 
				[Error Name]='Missing BOM'
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
		select 'Udpate Missing RSP'
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

