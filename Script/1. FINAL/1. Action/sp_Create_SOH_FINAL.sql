/*
	Declare
		@b_Success			Int,
		@c_errmsg			Nvarchar(250)

	exec sp_Create_SOH_FINAL 'CPD','202412','full',@b_Success OUT,@c_errmsg OUT

	select @b_Success b_Success,@c_errmsg c_errmsg


	select * from SOH_FINAL_LLD_202408
	WHERE [SUB GROUP/ Brand]='AGE REWIND CONCEALER'
	order by [SUB GROUP/ Brand]  asc,channel asc, [Time series] asc

	select * from SC1.dbo.STOCK_ZMB52 z (NOLOCK) where material=  'ZVN01085'

	select * from SOH_FINAL_LLD_202412
*/
Alter proc sp_Create_SOH_FINAL
	@Division			nvarchar(3),
	@FM_Key				nvarchar(6),
	@Type				Nvarchar(4),--//full, active
	@b_Success			Int				OUTPUT,     
	@c_errmsg			Nvarchar(250)	OUTPUT
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

	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_Create_SOH_FINAL',
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

	declare @tablename				nvarchar(100) = ''
	select @tablename = 'SOH_FINAL_'+@Division+@Monthfc

	if @debug>0
	begin
		select 'Drop table'
	end
	IF @n_continue = 1
	BEGIN
		if exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID(@tablename) AND type in (N'U')
		)
		begin
			select @sql = 'drop table '+@tablename
			if @debug>0
			begin
				select @sql 'Drop table'
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
	if @debug>0
	begin
		select 'Insert into table'
	end
	if @n_continue=1
	begin
		SELECT @sql1 =
		'select
			[Product Type],
			[Sales Org],
			[SUB GROUP/ Brand],
			[Channel],
			[Time series],
			[TotalQty]=sum(TotalQty)
			INTO '+@tablename+'
		from
		(
			select
				[Product Type] = x1.[Product Type],
				[Sales Org] = x1.[Sales Org],
				[SUB GROUP/ Brand] = '+case when @division IN('LLD','PPD') then 'x1.[SUB GROUP/ Brand]' else 'case when x1.[SUB GROUP/ Brand] = '''' then s1.[SUB GROUP/ Brand] else x1.[SUB GROUP/ Brand] end' end+',   
				[Channel],
				[Time series] = '+case 
									when @Division IN('LLD','PPD') then '''1. Baseline Qty'''
									else 'case when x1.[SUB GROUP/ Brand] = '''' then ''3. Promo Qty(BOM)'' else ''1. Baseline Qty'' end'
								end+',
				[Barcode] = x1.Barcode,
				[ChildQty] = '+case when @Division IN('LLD','PPD') then '0' else 'isnull(b.Qty,0)' end+',
				[Quantity_Normal] = Quantity_Normal,
				[TotalQty] = '+case 
								when @Division IN('LLD','PPD') then 'Quantity_Normal'
								else
									'case when isnull(b.Barcode_Bom,'''') <> '''' then isnull(b.Qty,0)*Quantity_Normal else Quantity_Normal end'
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
						[Product Type]=[Product Type],
						[Sales Org]=[Sales Org],
						[SUB GROUP/ Brand]=case when [Item Category Group]=''LUMF'' then '''' else [SUB GROUP/ Brand] end,
						[IsBom]=[Item Category Group],
						[Channel]=case when isnull(z.[Storage Location],'''') = '''' then ''ONLINE'' else ''OFFLINE'' end,
						[Barcode]=[Barcode],
						[Unrestricted]=cast(replace(case when right(Unrestricted,1)=''-'' then ''-''+REPLACE(Unrestricted,''-'','''') else  Unrestricted end,'','','''') as int),
						[Stock in transfer]=cast(replace(case when right([Stock in transfer],1)=''-'' then ''-''+REPLACE([Stock in transfer],''-'','''') else  [Stock in transfer] end,'','','''') as int),
						[In Quality Insp.]=cast(replace(case when right([In Quality Insp.],1)=''-'' then ''-''+REPLACE([In Quality Insp.],''-'','''') else  [In Quality Insp.] end,'','','''') as int),
						[Blocked]=cast(replace(case when right(Blocked,1)=''-'' then ''-''+REPLACE(Blocked,''-'','''') else  Blocked end,'','','''') as int)			
					from 
					(
						select 
							[Sales Org]=m.[Sales Org],
							[Product Type]=m.[Product Type],
							[SUB GROUP/ Brand]=s.[SUB GROUP/ Brand],
							[Barcode]=m.[Barcode],
							[Item Category Group]=m.[Item Category Group],
							z1.* 
						from SC1.dbo.STOCK_ZMB52_stg z1 (NOLOCK)
						left join 
						(
							select distinct 
								[Sales Org]=[Sales  Org],
								[Item Category Group],
								[Product Type]=[Material Type],
								[Barcode]=[EAN / UPC],
								[Material]
							from SC1.dbo.MM_ZMR54OLD_Stg (NOLOCK)
							where [Sales  Org] IN('''+@SalesOrg+''')
						) as m on m.Material=z1.Material
						left join  
						(      
							select distinct
								[SUB GROUP/ Brand],      
								[Barcode],
								[Material]='+case when @Division='CPD' then '[Material]' else '' end+'
							from fnc_SubGroupMaster('''+@Division+''',''full'')							
						) s on s.Barcode=m.[Barcode] '+case when @Division='CPD' then 'and s.[Material]=m.[Material] ' else '' end+'
						where '+case 
									when @Division IN('CPD') then 
										'[Storage Location] in(''VC01'',''VC02'','''')'
									when @Division IN('LDB') then --ACD
										'[Storage Location] in(''VA01'',''VA02'',''VA10'',''VA20'','''')'
									--when @Division IN('LLD') then 

									--when @Division IN('PPD') then

									else
										'[Storage Location] not in(select value from string_split(''VL95,VL93,Vl85,VL92,VL82,VL98,VL88,ES72'','',''))'
								end+'
						and m.[Sales Org] IN('''+@SalesOrg+''')
					) z
				) as x
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
							*
						FROM V_ZMR32 
						where Division='''+@Division+''' 
					) b on b.Barcode_Bom = x1.barcode 
					Left join        
					(      
						select distinct        
							[Product Type],
							[SUB GROUP/ Brand],
							[Barcode],
							[Material]='+case when @Division='CPD' then '[Material]' else '' end+',
							[Item Category Group]
						from fnc_SubGroupMaster('''+@Division+''','''')
					) s1 on s1.Barcode = b.Barcode_Component '+case when @Division='CPD' then 'and s1.[Material]=b.[Material_Component] ' else '' end+'
					where X1.[Sales Org] IN('''+@SalesOrg+''') '
				else ''
			end
			+'
		) as x2
		group by
			[Product Type],
			[Sales Org],
			[SUB GROUP/ Brand],
			[Channel],
			[Time series]
		order by 
			x2.[SUB GROUP/ Brand] asc,
			x2.Channel asc '
		
		SELECT @sql =
		'select
			[Product Type],
			[Sales Org],
			[SUB GROUP/ Brand] = SubGrp,
			Channel,
			[Time series],
			TotalQty = sum(TotalQty)
			INTO '+@tablename+'
		from
		(
			select
				[Product Type] = x1.[Product Type],
				[Sales Org] = x1.[Sales Org],
				SubGrp = '+case when @division IN('LLD','PPD') then 'x1.SubGrp' else 'case when SubGrp = '''' then s1.[SUB GROUP/ Brand] else x1.SubGrp end' end+',   
				Channel,
				[Time series] = '+case 
									when @Division IN('LLD','PPD') then '''1. Baseline Qty'''
									else 
										'case when SubGrp = '''' then ''3. Promo Qty(BOM)'' else ''1. Baseline Qty'' end'
								end+',
				Barcode = x1.Barcode,
				
				ChildQty = '+case when @Division IN('LLD','PPD') then '0' else 'isnull(b.Qty,0)' end+',
				Quantity_Normal = Quantity_Normal,
				TotalQty = '+case 
								when @Division IN('LLD','PPD') then 'Quantity_Normal'
								else
									'case when isnull(b.Barcode_Bom,'''') <> '''' then isnull(b.Qty,0)*Quantity_Normal else Quantity_Normal end'
							end+' 
			from
			(
				select
					[Product Type],
					[Sales Org],
					SubGrp,
					Channel,
					[Time series] = ''6. Total Qty'',
					Barcode,
					Quantity_Normal = sum(Unrestricted+[Stock in transfer]+[In Quality Insp.]+Blocked)
				from
				(
					select
						[Product Type] = s.[Product Type],
						[Sales Org] = s.[Sales Org],
						SubGrp = case when s.[Item Category Group] = ''LUMF'' then '''' else s.[SUB GROUP/ Brand] end,
						IsBom = s.[Item Category Group],
						[Channel] = case when isnull(z.[Storage Location],'''') = '''' then ''ONLINE'' else ''OFFLINE'' end,
						Barcode = s.Barcode,
						Unrestricted = cast(replace(case when right(Unrestricted,1)=''-'' then ''-''+REPLACE(Unrestricted,''-'','''') else  Unrestricted end,'','','''') as int),
						[Stock in transfer] = cast(replace(case when right([Stock in transfer],1)=''-'' then ''-''+REPLACE([Stock in transfer],''-'','''') else  [Stock in transfer] end,'','','''') as int),
						[In Quality Insp.] = cast(replace(case when right([In Quality Insp.],1)=''-'' then ''-''+REPLACE([In Quality Insp.],''-'','''') else  [In Quality Insp.] end,'','','''') as int),
						Blocked = cast(replace(case when right(Blocked,1)=''-'' then ''-''+REPLACE(Blocked,''-'','''') else  Blocked end,'','','''') as int)			
					from 
					(
						select 
							Barcode=m.[EAN / UPC],
							z1.* 
						from SC1.dbo.STOCK_ZMB52_stg z1 (NOLOCK)
						left join 
						(
							select distinct 
								[EAN / UPC],
								Material
							from SC1.dbo.MM_ZMR54OLD_Stg (NOLOCK)
						) as m on m.Material=z1.Material
						where [Storage Location] not in(select value from string_split(''VL95,'+case when @Division IN('LDB','LLD','CPD','PPD') then 'VL93,' else '' end+'Vl85,VL92,VL82,VL98,VL88,ES72'','',''))
					) z
					inner join 
					(
						select distinct 
							[Product Type],
							[Sales Org],
							[SUB GROUP/ Brand],
							Barcode,
							[Item Category Group] 
						from fnc_SubGroupMaster('''+@Division+''','''+@Type+''')
					) s on s.Barcode = z.Barcode
					where s.[Sales Org] = '''+@SalesOrg+'''
					'+case when @Division IN('CPD') then 'and z.[Storage Location] in(''VC01'',''VC02'','''')' else  '' end+'
				) as x
				group by
					[Product Type],
					[Sales Org],
					[SubGrp],
					[Channel],
					[Barcode]
			) as x1
			'+
			case
				when @Division in('CPD','LDB') then
					'left join 
					(
						select *
						FROM V_ZMR32 
						where Division = '''+@Division+''' 
					) b on b.Barcode_Bom = x1.barcode 
					Left join        
					(      
						select distinct        
							[Product Type],   
							[Sales Org],      
							[SUB GROUP/ Brand],   
							Barcode,     
							[Item Category Group]       
						from fnc_SubGroupMaster('''+@Division+''','''')
					) s1 on s1.Barcode = b.Barcode_Component
					where X1.[Sales Org] IN('''+@SalesOrg+''') '
				else ''
			end
			+'
		) as x2
		group by
			[Product Type],
			[Sales Org],
			[SubGrp],
			[Channel],
			[Time series]
		order by 
			x2.SubGrp asc,
			x2.Channel asc '

		if @debug >0
		begin
			select @sql 'sql insert soh'
		end
		execute(@sql)

		select @n_err = @@ERROR
		if @n_err<>0
		begin
			select @n_continue = 3
			--select @n_err=60003
			select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +ERROR_MESSAGE()+'./ ('+@sp_name+')'
		end
	END

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


