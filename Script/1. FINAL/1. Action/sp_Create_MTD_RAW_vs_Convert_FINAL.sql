/*
	exec sp_Create_MTD_RAW_vs_Convert_FINAL 'CPD','202412','full'
*/
Alter proc sp_Create_MTD_RAW_vs_Convert_FINAL
	@Division			nvarchar(3),
	@FM_Key				nvarchar(6),
	@Type				Nvarchar(4)--//full, active
	with encryption
As
	DECLARE   
		 @debug					int=0
		,@sp_name				Nvarchar(100)
		,@n_continue			Int
		,@USERS					Nvarchar(50)
		,@MODIFILED				Datetime
		,@n_err					int	
		,@sql					nvarchar(max) = ''
		,@sql1					nvarchar(max) = ''

	SELECT	
		@n_continue=1, 
		--@b_success=0,
		@n_err=0,
		--@c_errmsg='', 
		@sp_name = 'sp_Create_MTD_RAW_vs_Convert_FINAL',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	select @debug=debug from fnc_debug('FC')
	--select @debug=1

	declare @Monthfc				nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from V_FC_FM_Table
	
	declare @SalesOrg				nvarchar(4) = ''
	select @SalesOrg = case 
							when @Division  ='LLD' then 'V100'
							when @Division  ='CPD' then 'V200'														
							when @Division  ='PPD' then 'V300'
							when @Division  ='LDB' then 'V400'
					end

	if @n_continue=1
	begin
		declare 
			 @fromdate				date
			,@todate				date
			,@SaleOrg				nvarchar(5)=''	
			,@frommonth_his			date
			,@frommonth_ok			Nvarchar(8)=''
			,@tomonth_his			date
			,@Tomonth_ok			Nvarchar(8)=''			


		select @frommonth_his = DATEADD(MM,0,cast(left(@FM_KEY,4)+'-'+right(@FM_KEY,2)+'-01' as date))
		select @frommonth_ok = format(@frommonth_his,'yyyyMMdd')
		select  @tomonth_his = EOMONTH(DATEADD(MM,0,cast(left(@FM_KEY,4)+'-'+right(@FM_KEY,2)+'-01' as date)))
		select @Tomonth_ok = format(@tomonth_his,'yyyyMMdd')
		if @debug>0
		begin
			select @frommonth_ok '@frommonth_ok',@Tomonth_ok '@Tomonth_ok'
		end
	end
	if @n_continue=1
	begin
		SELECT @sql =
		'select
			[Type]=''MTD Single'',
			[Product Type],
			[SUB GROUP/ Brand],
			[Barcode_Original],
			[Barcode],
			[Channel],
			[Time series],
			[TotalQty]=[Quantity]	
		from
		(
			select
				[Product Type]=s.[Type],
				[SUB GROUP/ Brand]=s.[SUB GROUP/ Brand],
				[Barcode_Original],
				[Barcode]=[Barcode_Original],
				[Channel],
				[Time series]=''1. Baseline Qty'',
				[Quantity]=sum([DO Billed Quantity]*[ABS])
			from 
			(
				select 
					*
				from v_'+@Division+'_FC_ZV14_Historical
			) z
			left join 
			(
				select distinct
					[Type],
					[Product Type],
					[SUB GROUP/ Brand],
					[Barcode],
					[Item Category Group]
				from fnc_SubGroupMaster('''+@Division+''',''full'')
				where [Product Type] '+case when @Division NOT IN('CPD') then 'in(''YFG'')' else 'in(''YFG'',''YSM2'')' end+'
			) s On s.Barcode=z.[Barcode_Original]
			where 
					cast([Billing Doc Date] as bigint) between cast('''+@frommonth_ok+''' as bigint) and cast('''+@Tomonth_ok+''' as bigint) 
				and [FOC TYPE]<>''FDR''
				and [Material Type] '+case when @Division NOT IN('CPD') then 'in(''YFG'')' else 'in(''YFG'',''YSM2'')' end+'
				and s.[Item Category Group]<>''LUMF''		
			group by
				s.[Type],
				s.[SUB GROUP/ Brand],
				[Barcode_Original],
				[Channel]
		) as x
		where ISNULL([SUB GROUP/ Brand],'''')=''''
		union all
		select
			[Type]=''MTD BOM Component'',
			[Product Type],
			[SUB GROUP/ Brand],
			[Barcode_Original],
			[Barcode],	
			[Channel],
			[Time series],
			[TotalQty]=[Quantity]
		from
		(
			select
				[Product Type]='+case when @Division NOT IN('CPD') then 'x.[Product Type]' else +'case when s.[HERO]=''PLV'' then ''PLV'' else x.[Product Type] end' end+',
				[SUB GROUP/ Brand],
				[Barcode_Original],
				[Barcode]=x.[Barcode],
				[Channel],
				[Time series]=''3. Promo Qty(BOM)'',
				[Quantity]=sum([DO Billed Quantity])
			from
			(
				select
					[Product Type],
					[Barcode_Original],
					[Barcode],
					[Material],
					[Channel],
					[DO Billed Quantity]=sum([DO Billed Quantity]*[ABS])			
				from
				(
					select 
						[Product Type],
						[Barcode_Original],
						[Barcode]=zmr.Barcode_Component,
						[Material]=zmr.Material_Component,
						[DO Billed Quantity],
						[Qty],
						[ABS],
						[Channel]
					from 
					(
						select
							*
						from V_CPD_FC_ZV14_Historical			
					) z
					left join
					(
						select DISTINCT
							[Product Type]=[Material Type],
							[EAN / UPC],
							[Material]=[Sap Code],
							[Item Category Group]
						from fnc_MM_ZMR54OLD_Stg('''+@Division+''')
						where [Sales  Org] IN('''+@SalesOrg+''')
					) mm on mm.[EAN / UPC]=z.Barcode_Original and mm.Material=z.[Bill. Material]
					Left join 
					(
						select 
							* 
						from V_ZMR32
					) zmr on zmr.Barcode_Bom = z.Barcode_Original and zmr.Material_Bom=z.[Bill. Material]
					where 
						cast([Billing Doc Date] as bigint) between cast('''+@frommonth_ok+''' as bigint) and cast('''+@Tomonth_ok+''' as bigint)
					and [FOC TYPE]<>''FDR''
					and mm.[Item Category Group]=''LUMF''
					and [DO Billed Quantity]<>0
				) as x
				group by
					[Product Type],
					[Barcode_Original],
					[Barcode],
					[Material],
					[Channel]
			) as x
			Left join 
			(
				select distinct
					[SUB GROUP/ Brand],
					[Barcode],
					[Material],
					[HERO]
				from fnc_SubGroupMaster('''+@Division+''',''full'')
			) s On s.[Barcode]=x.[Barcode] and s.[Material]=x.[Material]
			group by
				 x.[Product Type]
				,s.[SUB GROUP/ Brand]
				,[Channel]
				,[Barcode_Original]
				,x.[Barcode]
				,x.[Product Type]
				,x.[Material]
				,s.[HERO]
		) as x
		where 
			[Product Type] '+case when @Division NOT IN('CPD') then 'IN(''YFG'')' else 'IN(''YFG'',''YSM2'')' end+'
		and ISNULL([SUB GROUP/ Brand],'''')='''' '

		if @debug >0
		begin
			select @sql 'sql insert mtd',len(@sql), len(@sql1)
		end
		execute(@sql+@sql1)
	END
