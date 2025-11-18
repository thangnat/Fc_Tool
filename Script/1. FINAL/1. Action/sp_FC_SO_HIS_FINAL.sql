/*
	Declare
		@b_Success			Int,
		@c_errmsg			Nvarchar(250)

	exec sp_FC_SO_HIS_FINAL 'PPD','202201',@b_Success OUT,@c_errmsg OUT

	select @b_Success b_Success,@c_errmsg c_errmsg

	DROP TABLE FC_CPD_SO_HIS
	DROP TABLE FC_LDB_SO_HIS_FINAL 
	
	select * from FC_CPD_SO_HIS_Periodkey
	select * from FC_LDB_SO_HIS_FINAL

	select * from FC_CPD_SO_HIS where PeriodKey='202408'
	select * from FC_LLD_SO_HIS_FINAL where PeriodKey='202408'
	delete from FC_LLD_SO_HIS_FINAL where PeriodKey='202408'
*/

Alter proc sp_FC_SO_HIS_FINAL
	@Division		nvarchar(3),
	@periodKey		nvarchar(6),
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
	select @debug=debug from fnc_debug('FC')
	--select @debug=1

	if @n_continue=1
	begin
		if @periodKey=''
		begin
			select @n_continue=3, @c_errmsg='Periodkey should be not null.../'
		end
	end

	if @debug>0
	begin
		select 'get data from sisosit database:fucntion sp_Create_FC_SO_HIS_RAW'
	end
	if @n_continue = 1
	begin
		if exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID(@tablename) AND type in (N'U')
		)
		begin
			select @sql ='drop table '+@tablename

			if @debug >0
			begin
				select @sql '@sql drop table so his period sisosit database'
			end
			execute(@sql)
		end		

		select @sql = 'exec Link_SISOSIT.[lvn.sisosit'
						+CASE 
							WHEN @Division = 'CPD' THEN 
								'' 
							ELSE 
								'_'+@saleOrg 
						END+'].dbo.sp_Create_FC_SO_HIS_RAW '''+ @periodKey+''','''+@saleOrg+''' '
		IF @debug>0
		BEGIN
			SELECT @sql '@SQL insert table so his period sisosit database'
		END
		EXECUTE(@SQL)

		if @debug>0
		begin
			select 'insert into table so his period sc2 from sisosit database'
		end
		select @sql =
		'select
			[PeriodKey] = z.[PeriodKey],
			[Division] = z.[Division],
			[Product Type] = s.[Material Type],
			[Sales Org] = '''+@saleOrg+''',
			[StoreCode] = z.[StoreCode],
			[Group]=z.[Group],
			[Cluster]=z.[Cluster],
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
		from Link_SISOSIT.[lvn.sisosit'+CASE 
											WHEN @Division = 'CPD' THEN 
												''
											ELSE 
												'_'+@saleOrg 
										END+'].dbo.FC_SO_HIS_'+@periodKey+' z
		left join 
		(
			select DISTINCT 
				[Barcode],
				[Sales Org],
				[SUB GROUP/ Brand],
				[Material Type] 
			from fnc_SubGroupMaster('''+@Division+''',''full'')
			where [Item Category Group]<>''LUMF''
		) s On s.Barcode = z.Barcode '

		if @debug>0
		begin
			select @sql '@sql insert into table so his period sc2 from sisosit database'
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
	
	if @debug>0
	begin
		select 'Create table so his final sc2 from so his sc2'
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
				[Group] nvarchar(200) NULL,
				[Cluster]	nvarchar(20) NULL,
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
			select @sql '@sql create table final if not exists'
		end
		execute(@sql)
		/*
			SELECT * FROM FC_CPD_SO_HIS_FINAL
		*/
	end

	if @debug>0
	begin
		select 'delete data by period key so his final sc2'
	end
	if @n_continue = 1
	begin
		IF @saleOrg = 'V100'
		BEGIN
			if exists(select 1 from FC_LLD_SO_HIS_FINAL where periodkey = @periodKey)
			begin
				DELETE FC_LLD_SO_HIS_FINAL WHERE PeriodKey=@periodKey

				select @n_err = @@ERROR
				if @n_err<>0
				begin
					select @n_continue = 3
					--select @n_err=60003
					select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +ERROR_MESSAGE()+'./ ('+@sp_name+')'
				end
			end
		END
		ELSE IF @saleOrg = 'V200'
		BEGIN
			if exists(select 1 from FC_CPD_SO_HIS_FINAL where periodkey = @periodKey)
			begin
				DELETE FC_CPD_SO_HIS_FINAL WHERE PeriodKey=@periodKey

				select @n_err = @@ERROR
				if @n_err<>0
				begin
					select @n_continue = 3
					--select @n_err=60003
					select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +ERROR_MESSAGE()+'./ ('+@sp_name+')'
				end
			end
		END
		ELSE IF @saleOrg = 'V300'-->PPD
		BEGIN
			if exists(select 1 from FC_PPD_SO_HIS_FINAL where periodkey = @periodKey)
			begin
				DELETE FC_PPD_SO_HIS_FINAL WHERE PeriodKey=@periodKey

				select @n_err = @@ERROR
				if @n_err<>0
				begin
					select @n_continue = 3
					--select @n_err=60003
					select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +ERROR_MESSAGE()+'./ ('+@sp_name+')'
				end
			end
		END
		ELSE IF @saleOrg = 'V400'
		BEGIN
			if exists(select 1 from FC_LDB_SO_HIS_FINAL where periodkey = @periodKey)
			begin
				DELETE FC_LDB_SO_HIS_FINAL WHERE PeriodKey=@periodKey

				select @n_err = @@ERROR
				if @n_err<>0
				begin
					select @n_continue = 3
					--select @n_err=60003
					select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +ERROR_MESSAGE()+'./ ('+@sp_name+')'
				end
			end
		END
	end
	if @debug>0
	begin
		select 'insert table so his final sc2 from so his sc2'
	end
	if @n_continue = 1
	begin
		select @sql = 
		'INSERT INTO '+@tablename_final+'
		select
			[PeriodKey],
			[Division],
			[Group],
			[Cluster],
			[BundleType],
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
				[PeriodKey],
				[Division],
				[Group],
				[Cluster],
				[BundleType] = ''Single'',
				[Product Type],
				[Sales Org],
				[Barcode],
				[Channel] = c.Channel,
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
			left join 
			(
				select Distinct 
					[Node 5],
					[Channel]
				FROM FC_MasterFile_'+@Division+'_Customer_Master (NOLOCK)
			) c  on right(''0000000000''+[Node 5],10) = right(''0000000000''+x.[StoreCode],10)
			group by
				[PeriodKey],
				[Division],
				[Group],
				[Cluster],
				[Sales Org],
				[Barcode],
				[Product Type],
				[Channel]
		) as x0 '
		--/*FROM FC_MasterFile_'+@Division+'_Customer_Master (NOLOCK)*/
		if @debug>0
		begin
			select @sql '@sql insert table so his final sc2 from so his sc2'
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
	if @debug>0
	begin
		select 'Drop table '+@tablename
	end
	if @n_continue=1
	begin
		select @sql='drop table '+@tablename
		if @debug>0
		begin
			select 'drop table'
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