/*
	Declare
		@b_Success			Int,
		@c_errmsg			Nvarchar(250)

	exec sp_FC_SO_HIS_FINAL_TEST '202201','PPD',@b_Success OUT,@c_errmsg OUT

	select @b_Success b_Success,@c_errmsg c_errmsg

	DROP TABLE FC_PPD_SO_HIS
	DROP TABLE FC_PPD_SO_HIS_FINAL
	--select * from FC_PPD_SO_HIS_FINAL

	DROP TABLE FC_LLD_SO_HIS
	DROP TABLE FC_PPD_SO_HIS_FINAL

	select distinct periodkey 
	from FC_CPD_SO_HIS_FINAL order by periodkey asc

	select distinct periodkey 
	from FC_LLD_SO_HIS_FINAL (NOLOCK) order by periodkey asc
*/

Alter proc sp_FC_SO_HIS_FINAL_TEST
	@periodKey		nvarchar(6),
	@Division		nvarchar(3),
	@b_Success		Int				OUTPUT,     
	@c_errmsg		Nvarchar(250)	OUTPUT
	with encryption
As
SET NOCOUNT ON
SET XACT_ABORT ON
--BEGIN TRAN
BEGIN TRY
	DECLARE   
		 @debug					int=1
		,@sp_name				Nvarchar(100)
		,@n_continue			Int
		,@USERS					Nvarchar(50)
		,@MODIFILED				Datetime
		,@n_err					int
		,@sql					nvarchar(max) = ''
		,@saleOrg				nvarchar(4) = ''
			
	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_FC_SO_HIS_FINAL',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	declare @tablename				nvarchar(50) = ''
	declare @tablename_final		nvarchar(50) = ''

	select @tablename = 'FC_'+@Division+'_SO_HIS_'+@periodKey
	select @tablename_final = 'FC_'+@Division+'_SO_HIS_FINAL'

	select @saleOrg = case 
							when @Division = 'LLD' then 'V100'
							when @Division = 'CPD' then 'V200' 
							when @Division = 'PPD' then 'V300'
							when @Division = 'LDB' then 'V400'
							else ''
					end

	if @n_continue = 1
	begin
		select @sql =
		'if exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID('''+@tablename+''') AND type in (N''U'')
		)
		begin
			drop table '+@tablename+'
		end'
		if @debug >0
		begin
			select @sql '@sql 1.1'
		end
		execute(@sql)
		select @sql = 'exec Link_SISOSIT.[lvn.sisosit'+CASE WHEN @Division = 'CPD' THEN '' ELSE '_'+@saleOrg END+'].dbo.sp_Create_FC_SO_HIS_RAW '''+ @periodKey+''','''+@saleOrg+''' '
		IF @debug>0
		BEGIN
			SELECT @sql '@SQL 1.2'
		END
		EXECUTE(@SQL)

		select @sql =
		'select
			PeriodKey = z.PeriodKey,
			Division = z.Division,
			[Product Type] = s.[Material Type],
			[Sales Org] = '''+@saleOrg+''',
			[StoreCode] = z.[StoreCode],
			[Barcode] = z.[Barcode],
			[OpenStock] = z.[OpenStock],
			[OpenStockValue] = z.[OpenStockValue],
			[SellIn] = z.[SellIn],
			[SellInValue] = z.[SellInValue],
			[SellOut] = z.[SellOut],
			[SellOutValue] = z.[SellOutValue],
			[Adjust] = z.[Adjust],
			[AdjustValue] = z.[AdjustValue],
			[EndStock] = z.[EndStock],
			[EndStockValue] = z.[EndStockValue]
			INTO '+@tablename+'
		from Link_SISOSIT.[lvn.sisosit'+CASE WHEN @Division = 'CPD' THEN '' ELSE '_'+@saleOrg END+'].dbo.FC_SO_HIS_'+@periodKey+' z
		left join 
		(
			select DISTINCT 
				[Barcode],
				[Sales Org],
				[SUB GROUP/ Brand],
				[Material Type] 
			from fnc_SubGroupMaster('''+@Division+''',''full'')
		) s On s.Barcode = z.Barcode '
		/*
		inner join
		(
			select DISTINCT 
				[EAN / UPC],
				[Material Type] 
			from SC1.dbo.MM_ZMR54OLD (NOLOCK)
		) m on m.[EAN / UPC] = z.Barcode


		left join 
		(
			select DISTINCT 
				[Barcode]
				[Type],
				[Sales Org],
				[SUB GROUP/ Brand]
			from fnc_SubGroupMaster('''+@Division+''',''full'')
		) s On s.Barcode = z.Barcode
		*/
		--and s.Material = z.[Sap Code]
		if @debug>0
		begin
			select @sql '@sql 1.3'
		end
		execute(@sql)
		--select * from FC_CPD_SO_HIS
		select @n_err = @@ERROR
		if @n_err<>0
		begin
			select @n_continue = 3
			--select @n_err=60003
			select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +ERROR_MESSAGE()+'./ ('+@sp_name+')'
		end
	end
	
	if @n_continue = 1
	begin
		
		select @sql =
		'if not exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID('''+@tablename_final+''') AND type in (N''U'')
		)
		begin
			CREATE TABLE '+@tablename_final+'
			(
				[PeriodKey] [nvarchar](255) NULL,				
				[Division] [nvarchar](4) NULL,
				[BundleType] [varchar](13) NULL,
				[Sales Org] [nvarchar](255) NULL,
				[Barcode]		nvarchar(30) null,
				[Product Type] [varchar](4) NULL,
				[Channel] [nvarchar](20) NULL,
				[Time series] [varchar](17) NULL,
				[OpenStock] [float] default 0,
				[OpenStockValue] Numeric(18,3) default 0,
				[SellIn] [float] default 0,
				[SellInValue] Numeric(18,3) default 0,
				[SellOut] [float] default 0,
				[SellOutValue] Numeric(18,3) default 0,
				[Adjust] [float] default 0,
				[AdjustValue] Numeric(18,3) default 0,
				[EndStock] [float] default 0,
				[EndStockValue] Numeric(18,3) default 0
			)
		end'
		if @debug >0
		begin
			select @sql '@sql 1.4'
		end
		execute(@sql)
		/*
			SELECT * FROM FC_CPD_SO_HIS_FINAL
		*/
	end
	if @n_continue = 1
	begin
		IF @saleOrg = 'V100'
		BEGIN
			if exists(select 1 from FC_LLD_SO_HIS_FINAL where periodkey = @periodKey)
			begin
				select @n_continue = 3, @c_errmsg = 'This periodkey['+@periodKey+'] had existed.../'
			end
		END
		ELSE IF @saleOrg = 'V200'
		BEGIN
			if exists(select 1 from FC_CPD_SO_HIS_FINAL where periodkey = @periodKey)
			begin
				select @n_continue = 3, @c_errmsg = 'This periodkey['+@periodKey+'] had existed.../'
			end
		END
		--ELSE IF @saleOrg = 'V300'-->PPD
		--BEGIN
		--	if exists(select 1 from FC_PPD_SO_HIS_FINAL where periodkey = @periodKey)
		--	begin
		--		select @n_continue = 3, @c_errmsg = 'This periodkey['+@periodKey+'] had existed.../'
		--	end
		--END
		--ELSE IF @saleOrg = 'V400'-->LDB
		--BEGIN
		--	if exists(select 1 from FC_LDB_SO_HIS_FINAL where periodkey = @periodKey)
		--	begin
		--		select @n_continue = 3, @c_errmsg = 'This periodkey['+@periodKey+'] had existed.../'
		--	end
		--END
	end
	if @n_continue = 1
	begin
		select @sql = 
		'INSERT INTO '+@tablename_final+'
		select
			PeriodKey,
			[Division],
			BundleType,
			[Sales Org],
			[Barcode],
			[Product Type],
			[Channel],
			[Time series],
			[OpenStock],
			[OpenStockValue],
			[SellIn],
			[SellInValue],
			[SellOut],
			[SellOutValue],
			[Adjust],
			[AdjustValue],
			[EndStock],
			[EndStockValue]			
		from
		(
			select
				PeriodKey,
				[Division],
				BundleType = ''Single'',
				[Product Type]=M.[Material Type],
				[Sales Org],
				[Barcode],
				[Channel] = '+case when @Division='PPD' then '''OFFLINE''' else 'c.Channel' end+',
				[Time series] = ''1. Baseline Qty'',
				[OpenStock] = sum(isnull([OpenStock],0)),
				[OpenStockValue] = sum(isnull([OpenStockValue],0)),
				[SellIn] = sum(isnull([SellIn],0)),
				[SellInValue] = sum(isnull([SellInValue],0)),
				[SellOut] = sum(isnull([SellOut],0)),
				[SellOutValue] = sum(isnull([SellOutValue],0)),
				[Adjust] = sum(isnull([Adjust],0)),
				[AdjustValue] = sum(isnull([AdjustValue],0)),
				[EndStock] = sum(isnull([EndStock],0)),
				[EndStockValue] = sum(isnull([EndStockValue],0))	
			from '+@tablename+' x
			'+case 
				when @Division='PPD' then 
					'left join 
					(
						SELECT 
							[Node 5],
							[Name 3]=case when CHARINDEX(''Online'',[Name 3],0)>0 then ''ONLINE'' else ''OFFLINE'' end
						FROM SC1.dbo.zs22
						where [Sales  Org]=''V300''
						and isnull([Node 5],'''')<>''''
					) c  on right(''0000000000''+cast([Node 5] as nvarchar),10) = right(''0000000000''+cast(x.[StoreCode] as nvarchar),10) '
				else 
					'left join 
					(
						select distinct 
							[Node 5],
							[Channel]
						FROM FC_MasterFile_'+@Division+'_Customer_Master (NOLOCK)
					) c  on right(''0000000000''+cast([Node 5] as nvarchar),10) = right(''0000000000''+cast(x.[StoreCode] as nvarchar),10) ' 
			end +'
			left join
			(
				select DISTINCT
					[EAN / UPC],
					[Material Type] 
				from SC1.dbo.MM_ZMR54OLD_Stg (NOLOCK)
			) as m on m.[EAN / UPC]=x.[Barcode]
			group by
				PeriodKey,
				[Division],
				[Sales Org],
				[Barcode],
				[Material Type]'
				+case when @Division='PPD' then '' else ',[Channel]' end+'
		) as x0'
		--/*FROM FC_MasterFile_'+@Division+'_Customer_Master (NOLOCK)*/
		if @debug>0
		begin
			select @sql '@sql 1.5'
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
		--rollback
		select @b_Success = 0
	end
	else
	begin
		--Commit
		select @b_Success = 1, @c_errmsg = 'Successfully.../'
	end
END TRY
BEGIN CATCH
   --ROLLBACK
   DECLARE @ErrorMessage VARCHAR(2000)
   SELECT @ErrorMessage = 'Error: '+ ERROR_MESSAGE()
   RAISERROR(@ErrorMessage , 16, 1)
END CATCH