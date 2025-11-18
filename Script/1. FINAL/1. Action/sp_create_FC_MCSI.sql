
/*
	declare 
		@b_Success		Int,
		@c_errmsg		Nvarchar(250)

	exec sp_create_FC_MCSI 'CPD','202410',@b_Success OUT,@c_errmsg OUT

	select @b_Success b_Success,@c_errmsg c_errmsg

	select * from FC_MCSI_CPD_OK
	select * from FC_MCSI_CPD_VALUE_OK
	
	select distinct [Month] from FC_MCSI_CPD
	select * from FC_MCSI_LDB_VALUE_OK
*/

Alter proc sp_create_FC_MCSI
	@Division			nvarchar(3),
	@FM_KEY				nvarchar(6),
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
			
	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_create_FC_MCSI',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	select @debug=debug from fnc_debug('FC')
	--select @debug =1

	declare @tablename1 nvarchar(100) = '', @tablename2 nvarchar(100) = ''
	select 
		@tablename1 = 'FC_MCSI_'+@Division+'_OK',
		@tablename2 = 'FC_MCSI_'+@Division+'_VALUE_OK'

	declare @listcolumn_pass nvarchar(max) = ''
	select @listcolumn_pass = ListColumn from fn_FC_GetColHeader_Historical(@FM_KEY,'h',3112)
	
	declare @currentYear int = 0
	select @currentYear = cast(left(@FM_KEY,4) as int)

	declare @saleOrg nvarchar(4) = ''
	select @saleOrg = case 
						when @Division = 'LLD' then 'V100'
						when @Division = 'CPD' then 'V200'
						when @Division = 'PPD' then 'V300'
						when @Division = 'LDB' then 'V400'
						else ''
					end
	if @saleOrg = ''
	begin
		select @n_continue = 3,@c_errmsg = 'Sale org should be not null'
	end
	if @n_continue = 1
	begin
		if exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID(@tablename1) AND type in (N'U')
		)
		begin
			select @sql ='drop table '+ @tablename1--FC_MCSI_LLD_OK
			if @debug>0
			begin
				select @sql 'drop table mcsi ok'
			end
			execute(@sql)
		end

		if exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID(@tablename2) AND type in (N'U')
		)
		begin
			select @sql ='drop table '+ @tablename2
			if @debug>0
			begin
				select @sql 'drop table mcsi value ok'
			end
			execute(@sql)
			--drop table FC_MCSI_LLD_VALUE_OK
		end

		select @sql =
		'select 
			division = mc.division,
			[Sales org] = mc.[Sales org],
			Customer = Mc.Customer,
			[SUB GROUP/ Brand] = s.[SUB GROUP/ Brand],
			Channel = C.Channel,
			Material = Mc.Material,
			Barcode = mc.Barcode,
			[Year] = mc.[year],
			[Month] = mc.[month],
			[Pass Column Header] = (
										select replace([Pass],''@'',cast(([Year]-'+cast(@currentYear as nvarchar)+') as nvarchar(2))) 
										from V_FC_MONTH_MASTER 
										where Month_number = cast([Month] as int)
									),
			[Total value] = sum(mc.[Total value])
			INTO '+@tablename1+'
		from 
		(
			select 
				Division = '''+@Division+''',
				[Sales org]=[Sales org#],
				Customer = right(''0000000000''+[Sold-to pt],10),
				Material = mc.Material,
				Barcode = m.[EAN / UPC],
				[Year] = cast(right([month],4) as int),
				[Month] = cast(left([month],2) as int),
				[Total Value] = Gr#inv#sls
			from FC_MCSI_'+@Division+' (NOLOCK) mc
			inner join SC1.dbo.MM_ZMR54OLD_stg m on m.Material = mc.Material
			where 
				[Sales org#] ='''+@saleOrg+''' 
			and [Sales  Org] = '''+@saleOrg+''' 
			and left(mc.Material,3) not in(''TVN'',''TSV'')
		) mc
		left join 
		(
			select	distinct
				[SUB GROUP/ Brand],
				Barcode
			from fnc_SubGroupMaster('''+@Division+''',''full'')
		)s on s.Barcode = mc.Barcode
		left join 
		(
			select DISTINCT 
				[Node 5],
				[Channel]
			from FC_MasterFile_'+@Division+'_Customer_Master (NOLOCK)
		) c on RIGHT(''0000000000''+c.[Node 5],10) = RIGHT(''0000000000''+Mc.Customer,10)
		group by
			mc.division,
			mc.[Sales org],
			Mc.Customer,
			s.[SUB GROUP/ Brand],
			C.Channel,
			Mc.Material,
			mc.Barcode,
			mc.[year],
			mc.[month]'
		--,''TSV'')
		if @debug>0
		begin
			select @sql 'insert table mcsi ok', len(@sql) 'Len(sql)'
		end
		EXECUTE(@sql)

		select @sql = 
		'select
			division,
			[Sales org],
			[SUB GROUP/ Brand],
			Channel,
			[Time Series] = ''6. Total Qty'','
			+@listcolumn_pass+'
			INTO '+@tablename2+'
		from '+@tablename1+' h (NOLOCK)
		group by
			division,   
			[Sales org],
			[SUB GROUP/ Brand],
			Channel'

		if @debug>0
		begin
			select @sql 'insert table mcsi value ok', len(@sql) 'Len(sql)'
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

