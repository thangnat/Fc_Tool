/*
	declare 
		@b_Success		Int,
		@c_errmsg		Nvarchar(250)

	exec sp_SI_Actual_validate_mismatch 'LLD','202412',@b_Success OUT, @c_errmsg OUT

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
Alter proc sp_SI_Actual_validate_mismatch
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
		@sp_name = 'sp_SI_Actual_validate_mismatch',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()	

	select @debug=debug from fnc_Debug('FC')	
	--select @debug=1

	declare @Monthfc			nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from V_FC_FM_Table

	declare @list_product_type	nvarchar(20)=''
	declare @ColumnRelationShip nvarchar(20)=''
	declare @ColumnCompare		nvarchar(50)=''
	declare @FunctionName		nvarchar(50)='SI Actual'
	declare @Type				nvarchar(50)=''

	select 
		@list_product_type=[Product Type],
		@ColumnRelationShip=[Column Relationship],
		@ColumnCompare=[Column Compare] 
	from V_FC_DIVISION_BY_PRODUCT_TYPE 
	where [Division]=@Division
	
	declare @ListColumn_Current_fc_set0	nvarchar(max) = ''
	SELECT @ListColumn_Current_fc_set0 = ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'ErrorAlert_set0','')
	--SELECT ListColumn_Current_fc_set0 = ListColumn FROM fn_FC_GetColheader_Current('202410','ErrorAlert_set0','')

	declare @Column_LY_SINGLE		nvarchar(max) = ''
	select @Column_LY_SINGLE = ListColumn from fn_FC_GetColHeader_Historical(@FM_KEY,'h',1)
	--select Column_LY_SINGLE = ListColumn from fn_FC_GetColHeader_Historical('202407','h',1)

	declare @table_Name		nvarchar(300)=''
	select @table_Name='fc_validate_mismatch_si_his_fc'

	declare @ProductType	nvarchar(200) = ''
	select @ProductType = case when  @Division = 'CPD' then '[Product Type] in(''YFG'',''YSM2'')' else '[Product Type] in(''YFG'')' end
	
	declare @MaterialType_ZV14	nvarchar(200) = ''
	select @MaterialType_ZV14 = case when @Division = 'CPD' then '[Material Type] in(''YFG'',''YSM2'')' else '[Material Type] in(''YFG'')' end

	if @debug>0
	begin
		select 'SI ACTUAL BASELINE vs MasterData'
	end
	IF @n_continue=1
	begin
		select @FunctionName='SI ACTUAL BASELINE',@Type='MasterData'
		
		select @sql=
		'Delete '+@table_Name+' 
		where 
			[Division]='''+@Division+''' 
		and [FM_KEY]='''+@FM_KEY+''' 
		and [Function Name]='''+@FunctionName+''' 
		and [Type Name]='''+@Type+'''
		and [Channel]=''OFFLINE'' 
		and [Time series]=''Baseline Qty'' '

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
			[SUB GROUP/ Brand],
			[Channel],      
			[Time series],
			[EAN Code],
			[SKU Code],'
			+@Column_LY_SINGLE+','+@ListColumn_Current_fc_set0+'
		from
		(
			select
				[SUB GROUP/ Brand],      
				[Channel],      
				[Time series],
				[EAN Code]=[Barcode],
				[SKU Code]=[Material],
				[Pass Column Header] = (
											select replace([Pass],''@'',cast(([Year]-year(getdate())) as nvarchar(2))) 
											from V_FC_MONTH_MASTER 
											where Month_number = cast(x.[Month] as int)
										),
				HIS_QTY_SINGLE=sum([DO Billed Quantity]*[ABS])
			from
			(
				select
					[SUB GROUP/ Brand]=s.[SUB GROUP/ Brand],
					[Year] = left(z.[Billing Doc Date],4),
					[Month] = substring(z.[Billing Doc Date],5,2),					
					[Barcode] = [Barcode_Original],
					[Material]=[Bill. Material],
					[Channel],
					[Time series]=''1. Baseline Qty'',
					[DO Billed Quantity],
					[ABS]
				from V_'+@Division+'_FC_ZV14_Historical z
				left join 
				(
					select DISTINCT
						[Product Type],
						[SUB GROUP/ Brand],
						[Barcode],
						[Item Category Group]
					from fnc_SubGroupMaster('''+@Division+''',''full'')
					where '+@ProductType+'
				) s On s.Barcode = z.[Barcode_Original]
				where 
					[FOC TYPE] <> ''FDR''
				and z.[Channel] <> ''FOC''
				and '+@MaterialType_ZV14+'
				and s.[Item Category Group]<>''LUMF''
			) as x
			where ISNULL([SUB GROUP/ Brand],'''')=''''
			group by
				[SUB GROUP/ Brand],      
				[Channel],      
				[Time series],
				[Barcode],
				[Material],
				[Month],
				[Year]
		) as h		
		group by
			[SUB GROUP/ Brand],    
			[Channel],      
			[Time series],
			[EAN Code],
			[SKU Code] '

		if @debug>0
		begin
			select @sql '@sql SI Single Actual baseline vs MasterData'
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
		select 'SI Actual FOC SINGLE vs MasterData'
	end
	if @n_continue=1
	begin
		select @FunctionName='SI ACTUAL FOC SINGLE',@Type='MasterData'
		
		select @sql=
		'Delete '+@table_Name+' 
		where 
			[Division]='''+@Division+''' 
		and [FM_KEY]='''+@FM_KEY+''' 
		and [Type Name]='''+@FunctionName+'''
		and [Type Name]='''+@Type+'''
		and [Channel]=''ONLINE'' '

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
			[SUB GROUP/ Brand],
			[Channel],      
			[Time series],
			[EAN Code],
			[SKU Code],'+
			@Column_LY_SINGLE+','+@ListColumn_Current_fc_set0+'
		from
		(
			select
				[SUB GROUP/ Brand],      
				[Channel],      
				[Time series],
				[EAN Code]=[Barcode],
				[SKU Code]='''',
				[Pass Column Header] = (
											select replace([Pass],''@'',cast(([Year]-year(getdate())) as nvarchar(2))) 
											from V_FC_MONTH_MASTER 
											where Month_number = cast(x.[Month] as int)
										),
				HIS_QTY_SINGLE=sum([DO Billed Quantity]*[ABS])
			from
			(
				select
					[SUB GROUP/ Brand]=s.[SUB GROUP/ Brand],
					[Year] = left(z.[Billing Doc Date],4),
					[Month] = substring(z.[Billing Doc Date],5,2),					
					[Barcode] = Barcode_Original,
					[Channel],
					[Time series]=''1. Baseline Qty'',
					[DO Billed Quantity],
					[ABS]
				from V_'+@Division+'_FC_ZV14_Historical z
				left join 
				(
					select DISTINCT
						[Product Type],
						[SUB GROUP/ Brand],
						[Barcode],
						[Item Category Group]
					from fnc_SubGroupMaster('''+@Division+''',''full'')
					where '+@ProductType+'
				) s On s.Barcode = z.[Barcode_Original]
				where 
					[FOC TYPE]=''FDR''
				and [Channel]<>''FOC''
				and '+@MaterialType_ZV14+'
				and s.[Item Category Group]<>''LUMF''
			) as x
			where ISNULL([SUB GROUP/ Brand],'''')=''''
			group by
				[SUB GROUP/ Brand],      
				[Channel],      
				[Time series],
				[Barcode],
				[Month],
				[Year]
		) as h		
		group by
			[SUB GROUP/ Brand],    
			[Channel],      
			[Time series],
			[EAN Code],
			[SKU Code] '

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
	--select * from fc_validate_mismatch
	if @debug>0
	begin
		select 'SI FOC BOM Actual vs masterbom'
	end
	if @n_continue=1
	begin
		select @FunctionName='SI ACTUAL FOC BOM',@Type='BOM_vs_masterbom'
		
		select @sql=
		'Delete '+@table_Name+' 
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
		'INSERT INTO '+@table_Name+'
		select
			[Division]='''+@Division+''',
			[FM_KEY]='''+@FM_KEY+''',
			[Function Name]='''+@FunctionName+''',
			[Type Name]='''+@Type+''',
			[SUB GROUP/ Brand]='''',
			[Channel],      
			[Time series]=''5. FOC Qty'',
			[EAN Code],
			[SKU Code],'+
			@Column_LY_SINGLE+','+@ListColumn_Current_fc_set0+'
		from
		(
			select
				[Year],
				[Month],				
				[Channel],
				[EAN Code]=[Barcode],
				[SKU Code]=[Material],
				[Pass Column Header] = (
											select replace([Pass],''@'',cast(([Year]-year(getdate())) as nvarchar(2))) 
											from V_FC_MONTH_MASTER 
											where Month_number = cast(x.[Month] as int)
										),
				[HIS_QTY_SINGLE]=sum([DO Billed Quantity]*[Qty]*[ABS])
			from
			(
				select 
					[Year]=left(z.[Billing Doc Date],4),
					[Month]=substring(z.[Billing Doc Date],5,2),
					[Barcode]=Barcode_Original,
					[Material]=case when '''+@Division+'''<>''CPD'' then '''' else z.[Bill. Material] end,
					[DO Billed Quantity]=z.[DO Billed Quantity],
					[ABS],
					[Channel]
				from V_'+@Division+'_FC_ZV14_Historical z
				inner join 
				(
					select distinct
						[Material]=case when '''+@Division+'''<>''CPD'' then '''' else [Material] end,
						[Barcode]=[EAN / UPC]
					from SC1.dbo.MM_ZMR54OLD_Stg
					where
						[Sales  Org]=case 
										when '''+@Division+'''=''LLD'' then ''V100'' 
										when '''+@Division+'''=''CPD'' then ''V200'' 
										when '''+@Division+'''=''PPD'' then ''V300'' 
										when '''+@Division+'''=''LDB'' then ''V400'' 
										else ''''
									end
					and [Item Category Group]=''LUMF''
				) s On s.[Barcode] = z.[Barcode_Original] '+case when @Division<>'CPD' then '' else ' and s.Material=z.[Bill. Material]' end+'
				where 
					[FOC TYPE]=''FDR''
				and Channel <>''FOC''
			) as x
			Left join 
			(
				select 
					* 
				from V_ZMR32
				where [Division]='''+@Division+'''
			) zmr on zmr.Barcode_Bom=x.Barcode '+case when @Division<>'CPD' then '' else 'and zmr.Material_Bom=x.Material' end+'
			where ISNULL(zmr.[Material_Component],'''')=''''
			group by
				[Year],
				[Month],				
				[Channel],
				[Barcode],
				[Material]
		) as h
		group by
			[Channel],
			[EAN Code],
			[SKU Code] '

		if @debug>0
		begin
			select @sql '@sql SI Actual FOC BOM vs ZMR32'
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
		select 'SI ACTUAL FOC BOM COMPONENT vs Masterdata'
	end
	if @n_continue=1
	begin
		select @FunctionName='SI ACTUAL FOC BOM COMPONENT',@Type='BOM_vs_masterdata'
			
		select @sql=
		'Delete '+@table_Name+' 
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
		'INSERT INTO '+@table_Name+'
		select
			*
		from
		(
			select
				[Division]='''+@Division+''',
				[FM_KEY]='''+@FM_KEY+''',
				[Function Name]='''+@FunctionName+''',
				[Type Name]='''+@Type+''',
				[SUB GROUP/ Brand]=s.[SUB GROUP/ Brand],
				[Channel],      
				[Time series]=''5. FOC Qty'',
				[EAN Code],
				[SKU Code],'+
				@Column_LY_SINGLE+','+@ListColumn_Current_fc_set0+'
			from
			(
				select
					[Year],
					[Month],				
					[Channel],
					/*[Barcode],
					x.[Material],*/
					[EAN Code]=[Barcode_Component],
					[SKU Code]=[Material_Component],
					[Pass Column Header]=(
												select replace([Pass],''@'',cast(([Year]-year(getdate())) as nvarchar(2))) 
												from V_FC_MONTH_MASTER 
												where Month_number = cast(x.[Month] as int)
											),'
				select @sql1='
					[HIS_QTY_SINGLE]=sum([DO Billed Quantity]*[Qty]*[ABS])
				from
				(
					select 
						[Year]=left(z.[Billing Doc Date],4),
						[Month]=substring(z.[Billing Doc Date],5,2),
						[Barcode]=Barcode_Original,
						[Material]=case when '''+@Division+'''<>''CPD'' then '''' else z.[Bill. Material] end,
						[DO Billed Quantity]=z.[DO Billed Quantity],
						[ABS],
						[Channel] 
					from V_'+@Division+'_FC_ZV14_Historical z
					inner join 
					(
						select distinct
							[Material]=case when '''+@Division+'''<>''CPD'' then '''' else [Material] end,
							[Barcode]=[EAN / UPC]
						from SC1.dbo.MM_ZMR54OLD_Stg
						where
							[Sales  Org]=case 
											when '''+@Division+'''=''LLD'' then ''V100'' 
											when '''+@Division+'''=''CPD'' then ''V200'' 
											when '''+@Division+'''=''PPD'' then ''V300'' 
											when '''+@Division+'''=''LDB'' then ''V400'' 
											else ''''
										end
						and [Item Category Group]=''LUMF''
					) s On s.[Barcode] = z.[Barcode_Original] '+case when @Division<>'CPD' then '' else ' and s.Material=z.[Bill. Material]' end+'
					where 
						[FOC TYPE]=''FDR''
					and Channel<>''FOC''
				) as x 
				Left join 
				(
					select 
						* 
					from V_ZMR32
					where [Division]='''+@Division+'''
				) zmr on zmr.[Barcode_Bom]=x.[Barcode] '+case when @Division<>'CPD' then '' else 'and zmr.[Material_Bom]=x.[Material]' end+'			
				group by
					[Year],
					[Month],				
					[Channel],
					/*[Barcode],
					[Material],*/
					[Barcode_Component],
					[Material_Component]
			) as h
			left join 
			(
				select DISTINCT 
					[SUB GROUP/ Brand],
					[Barcode],
					[Material]=case when '''+@Division+'''<>''CPD'' then '''' else [Material] end
				from fnc_SubGroupMaster('''+@Division+''',''full'')
			) s On s.Barcode = h.[EAN Code] '+case when @Division<>'CPD' then '' else 'and s.Material=h.[SKU Code] ' end+'
			where ISNULL(s.[SUB GROUP/ Brand],'''')=''''
			group by	
				[SUB GROUP/ Brand],
				[Channel],
				[EAN Code], 
				[SKU Code]
		) as x
		where 
		(
			[Y-2 (u) M1]+[Y-2 (u) M2]+[Y-2 (u) M3]+[Y-2 (u) M4]+[Y-2 (u) M5]+[Y-2 (u) M6]+[Y-2 (u) M7]+[Y-2 (u) M8]+[Y-2 (u) M9]+[Y-2 (u) M10]+[Y-2 (u) M11]+[Y-2 (u) M12]+
			[Y-1 (u) M1]+[Y-1 (u) M2]+[Y-1 (u) M3]+[Y-1 (u) M4]+[Y-1 (u) M5]+[Y-1 (u) M6]+[Y-1 (u) M7]+[Y-1 (u) M8]+[Y-1 (u) M9]+[Y-1 (u) M10]+[Y-1 (u) M11]+[Y-1 (u) M12]+
			[Y0 (u) M1]+[Y0 (u) M2]+[Y0 (u) M3]+[Y0 (u) M4]+[Y0 (u) M5]+[Y0 (u) M6]+[Y0 (u) M7]+[Y0 (u) M8]+[Y0 (u) M9]+[Y0 (u) M10]+[Y0 (u) M11]+[Y0 (u) M12]+
			[Y+1 (u) M1]+[Y+1 (u) M2]+[Y+1 (u) M3]+[Y+1 (u) M4]+[Y+1 (u) M5]+[Y+1 (u) M6]+[Y+1 (u) M7]+[Y+1 (u) M8]+[Y+1 (u) M9]+[Y+1 (u) M10]+[Y+1 (u) M11]+[Y+1 (u) M12]
		)<>0'

		if @debug>0
		begin
			select @sql+@sql1 '@sql SI Actual FOC Bom component vs Masterdata'
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

	--if @debug>0
	--begin
	--	select 'FM vs RSP'
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
	--		[EAN Code]='''',
	--		[SKU Code]='''',
	--		'+@ListColumn_Current_validate_RSP_text+','+@ListColumn_Current_fc_set0+'
	--	from
	--	(
	--		select
	--			[SUB GROUP/ Brand]=x.[SUB GROUP/ Brand],
	--			[Product Type],
	--			[Channel],
	--			[Time series],
	--			'+@ListColumn_Current_validate_RSP+'
	--		from
	--		(
	--			select 
	--				[SUB GROUP/ Brand]=ISNULL(s.[SUB GROUP/ Brand],''''),
	--				[Product Type],
	--				[Channel]=ISNULL(f.[Local Level],''''),
	--				[Time series]=ISNULL([Time series],''''),
	--				'+@ListColumn_Current_sum+'
	--			from FC_FM_'+@Division+@Monthfc+' f
	--			left join
	--			(
	--				select DISTINCT
	--					[Barcode],
	--					[Material],
	--					[SUB GROUP/ Brand],
	--					[Item Category Group],
	--					[Product Type]
	--				from fnc_SubGroupMaster('''+@Division+''',''full'')
	--			) s on '+case when @Division<>'CPD' then 's.[Barcode]=f.[EAN Code] ' else 's.[Material]=f.[Sku Code] ' end+' '
	--	select @sql1=
	--			'where 
	--				(
	--					(
	--							ISNULL([Local Level],'''')=''OFFLINE''
	--						and ISNULL([Time series],'''')=''Baseline Qty''
	--					)
	--					OR
	--					(
	--						ISNULL([Local Level],'''')=''ONLINE''
	--					)
	--				)
	--				and ISNULL([Time series],'''') NOT IN(''Total Qty'')
	--				and ISNULL([Item Category Group],'''')<>''LUMF''
	--				and ISNULL(s.[Product Type],'''')=''YFG''
	--				and ISNULL(s.[SUB GROUP/ Brand],'''')<>''''
	--			group by
	--				s.[SUB GROUP/ Brand],
	--				s.[Product Type],
	--				f.[Local Level],
	--				f.[Time series]
	--		) as x
	--		left join
	--		(
	--			select DISTINCT
	--				[SUB GROUP/ Brand],
	--				'+@ListColumn_Current+'
	--			from fnc_SubGroupMaster_RSP('''+@Division+''',''full'')
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

	if @debug>0
	begin
		select 'Update Missing BOM'
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