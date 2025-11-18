/*
	exec sp_Create_SOH_FINAL_TEST 'CPD','202412','full'
*/
Alter proc sp_Create_SOH_FINAL_TEST
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
		@sp_name = 'sp_Create_SOH_FINAL_TEST',
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

	--declare @tablename				nvarchar(100) = ''
	--select @tablename = 'SOH_FINAL_TEST_'+@Division+@Monthfc

	if @n_continue=1
	begin
		SELECT @sql =
		'select
			[Type]=''SOH Single'',
			[Product Type],
			/*[Sales Org],*/
			[SUB GROUP/ Brand],
			[Barcode Original],
			[Barcode],
			[Channel],
			[Time series],
			[TotalQty]=sum(TotalQty)

		from
		(
			select
				[Product Type]='+case 
									when @Division NOT IN('CPD') then 
										case 
											when @Division IN('LLD','PPD') then 
												' x1.[Product Type]'
											else 
												' case when x1.[SUB GROUP/ Brand]='''' then b.[Product Type] else x1.[Product Type] end'
										end
									else 
										' case when x1.[SUB GROUP/ Brand]='''' then case when s1.[HERO]=''PLV'' then ''PLV'' else b.[Product Type] end else x1.[Product Type] end' 
								end+',
				/*[Sales Org]=x1.[Sales Org],*/
				[SUB GROUP/ Brand]='+case 
										when @division IN('LLD','PPD') then 
											' x1.[SUB GROUP/ Brand]' 
										else 
											'case when x1.[SUB GROUP/ Brand]='''' then s1.[SUB GROUP/ Brand] else x1.[SUB GROUP/ Brand] end' 
									end+',   
				[Channel],
				[Time series]='+case 
									when @Division IN('LLD','PPD') then 
										'''1. Baseline Qty'''
									else 
										'case when x1.[SUB GROUP/ Brand]='''' then ''3. Promo Qty(BOM)'' else ''1. Baseline Qty'' end'
								end+',
				[Barcode Original]=x1.Barcode,
				[Barcode]='+case 
								when @Division IN('LLD','PPD') then 
									' x1.Barcode' 
								else +' case when x1.[SUB GROUP/ Brand]='''' then b.Barcode_Component else x1.Barcode end' 
							end+',
				[ChildQty]='+case when @Division IN('LLD','PPD') then '0' else 'isnull(b.Qty,0)' end+',
				[Quantity_Normal]=Quantity_Normal,
				[TotalQty]='+case 
								when @Division IN('LLD','PPD') then 'Quantity_Normal'
								else
									'case when isnull(b.Barcode_Bom,'''')<>'''' then isnull(b.Qty,0)*Quantity_Normal else Quantity_Normal end'
							end+' 
			from
			(
				select
					[Product Type],  
					[Sales Org],      
					[SUB GROUP/ Brand],    
					[Channel],    
					[Time series]=''6. Total Qty'',    
					[Barcode],     
					[Quantity_Normal]=sum(Unrestricted+[Stock in transfer]+[In Quality Insp.]+Blocked)
				from
				(
					select
						[Product Type],
						[Sales Org],
						[SUB GROUP/ Brand]=case when [Item Category Group]=''LUMF'' then '''' else [SUB GROUP/ Brand] end,
						[IsBom]=[Item Category Group],
						[Channel]=case when isnull(z.[Storage Location],'''')='''' then ''ONLINE'' else ''OFFLINE'' end,
						[Barcode]=[Barcode],
						[Unrestricted]=cast(replace(case when right(Unrestricted,1)=''-'' then ''-''+REPLACE(Unrestricted,''-'','''') else  Unrestricted end,'','','''') as int),
						[Stock in transfer]=cast(replace(case when right([Stock in transfer],1)=''-'' then ''-''+REPLACE([Stock in transfer],''-'','''') else  [Stock in transfer] end,'','','''') as int),
						[In Quality Insp.]=cast(replace(case when right([In Quality Insp.],1)=''-'' then ''-''+REPLACE([In Quality Insp.],''-'','''') else  [In Quality Insp.] end,'','','''') as int),
						[Blocked]=cast(replace(case when right(Blocked,1)=''-'' then ''-''+REPLACE(Blocked,''-'','''') else  Blocked end,'','','''') as int)			
					from 
					(
						select 
							[Sales Org]=m.[Sales Org],
							[Product Type]='+case when @Division<>'CPD' then 'm.[Product Type]' else 'case when s.[HERO]=''PLV'' then ''PLV'' else m.[Product Type] end' end +',
							[SUB GROUP/ Brand]=s.[SUB GROUP/ Brand],
							[Barcode]=m.[Barcode],
							[Item Category Group]=m.[Item Category Group],
							z1.* 
						from SC1.dbo.STOCK_ZMB52_stg z1 (NOLOCK)
						left join 
						(
							select distinct 
								[Sales Org]=[Sales  Org],
								[Barcode]=[EAN / UPC],
								[Material],
								[Product Type]=[Material Type],
								[Item Category Group]
							from SC1.dbo.MM_ZMR54OLD_Stg (NOLOCK)
						) as m on m.Material=z1.Material
						Left join  
						(      
							select distinct
								[SUB GROUP/ Brand],      
								[Barcode]
								,[Material]='+case when @Division='CPD' then '[Material]' else '''''' end+'
								,[HERO]
							from fnc_SubGroupMaster('''+@Division+''',''full'')							
						) s on s.Barcode=m.[Barcode] '+case when @Division='CPD' then 'and s.[Material]=m.[Material] ' else '' end+'
						where '+case 
									when @Division IN('CPD') then 
										'[Storage Location] in(''VC01'',''VC02'','''')'
									else
										'[Storage Location] not in(select value from string_split(''VL95,VL93,Vl85,VL92,VL82,VL98,VL88,ES72'','',''))'
								end+'
						and m.[Sales Org]='''+@SalesOrg+''' 
					) z
				) as x '
	select @sql1='
				group by
					[Product Type],
					[Sales Org],
					[SUB GROUP/ Brand],
					[Channel],
					[Barcode]
			) as x1
			'+
			case
				when @Division in('CPD','LDB') then
					'left join 
					(
						select 
							[Product Type]=[material Type]
							,[Barcode_Bom]
							,[Barcode_Component]
							,[Material_Component]
							,[Qty]
						FROM V_ZMR32 
						where [Division]='''+@Division+''' 
					) b on b.Barcode_Bom=x1.barcode 
					Left join        
					(      
						select distinct 							
							[SUB GROUP/ Brand]   
							,[Barcode]
							,[Material]='+case when @Division='CPD' then '[Material]' else '''''' end+'
							,[HERO]
						from fnc_SubGroupMaster('''+@Division+''',''full'')
						where [Item Category Group]<>''LUMF''
					) s1 on s1.[Barcode] = b.[Barcode_Component] '+case when @Division='CPD' then 'and s1.[Material]=b.[Material_Component] ' else '' end+'
					where X1.[Sales Org] IN('''+@SalesOrg+''') '
				else ''
			end
			+'
		) as x2 
		where ISNULL([SUB GROUP/ Brand],'''')='''' and [Product Type] '+case when @Division='CPD' then 'IN(''YFG'',''YSM2'')' else 'IN(''YFG'')' end+' 
		group by
			[Product Type],
			/*[Sales Org],*/
			[SUB GROUP/ Brand],
			[Channel],
			[Time series],
			[barcode original],
			[Barcode]
		order by 
			x2.[SUB GROUP/ Brand] asc,
			x2.Channel asc '

		if @debug >0
		begin
			select @sql 'sql insert soh',@sql1
		end
		execute(@sql+@sql1)
	END
