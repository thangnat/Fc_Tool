/*
	declare
		@b_Success			Int,
		@c_errmsg			Nvarchar(250)

	exec sp_Add_ZV14_Forecast_2 'LLD','',@b_Success OUT,@c_errmsg OUT

	select @b_Success b_Success,@c_errmsg c_errmsg

	select count(*) from FC_PPD_ZV14_Historical
	select * from FC_LLD_ZV14_Historical
	drop table FC_LLD_ZV14_Historical
*/

Alter Proc sp_Add_ZV14_Forecast_2
	@Division			Nvarchar(3),
	@FM_KEY				Nvarchar(6),
	@b_Success			Int				OUTPUT,     
	@c_errmsg			Nvarchar(250)	OUTPUT
As
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRAN
BEGIN TRY
	DECLARE
		 @debug					INT=0
		,@sp_name				Nvarchar(100)
		,@n_continue			Int
		,@USERS					Nvarchar(50)
		,@MODIFILED				Datetime
		,@n_err					int
		,@sql					nvarchar(max)=''
			
	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_Add_ZV14_Forecast_2',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	select @debug=debug from fnc_debug('FC')
	--select @debug=1

	declare @Salesorg nvarchar(4)=''
	select @Salesorg=case 
						when @division='LLD' then 'V100'
						when @division='CPD' then 'V200'
						when @division='PPD' then 'V300'
						when @division='LDB' then 'V400'
					end
	declare @tablename			nvarchar(100)=''
	select @tablename = 'FC_'+@Division+'_ZV14_Historical'
	
	if @FM_KEY=''
	begin
		select @FM_KEY=format(getdate(),'yyyyMM')
	end

	declare @fromdate nvarchar(6)='', @todate nvarchar(6)=''
	--if exists
	--(
	--	SELECT * 
	--	FROM sys.objects 
	--	WHERE object_id = OBJECT_ID(@tablename) AND type in (N'U')
	--)
	--begin
	--	select @fromdate=format(DATEADD(M,-1,getdate()),'yyyyMM'),@todate=format(getdate(),'yyyyMM')
	--end
	--else
	--begin
	--	select @fromdate='202201',@todate=format(getdate(),'yyyyMM')
	--end
	select @fromdate='202201',@todate=format(getdate(),'yyyyMM')
	if @debug>0
	begin
		select @fromdate '@fromdate', @todate '@todate'
	end

	if @n_continue=1
	begin
		if exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID(@tablename) AND type in (N'U')
		)
		begin
			--select @sql='delete '+@tablename+' where [Billing Doc Date] between '+@fromdate+' and '+@todate+' '
			select @sql='drop table '+@tablename
			if @debug>0
			begin
				select @sql 'drop table'
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
		
		select @sql = 
		'CREATE TABLE '+@tablename+'
		(
			[Ord. type]						[Nvarchar](10) NULL,
			[Sales document item category]	[nvarchar](20) NULL,
			[Sold-to Party Number]			[nvarchar](10) NULL,
			[Sold-to Party Name]			[nvarchar](500) NULL,
			[Material Type]					[nvarchar](10) NULL,
			[Billing Doc Date]				[Nvarchar](10) NULL,
			[Bill. Material]				[nvarchar](50) NULL,
			[Barcode_Original]				[nvarchar](50) NULL,
			[DO Billed Quantity]			[numeric](18,0) default 0,
			[FOC TYPE]						[nvarchar](50) NULL,
			[Channel]						[nvarchar](20) NULL,
			[ABS]							INT default 0				
		)'
		/*
		[Component Qty]					[numeric](18,0) default 0,
		[Promo. Qty]					[Numeric](18,0) default 0,
		[FDR Qty]						[numeric](18,0) default 0,
		*/
		if @debug>0
		begin
			select @sql  '@sql create table'
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
	if @n_continue=1
	begin
		select @sql=
		'INSERT INTO '+@tablename+'
		select
			*
		from
		(
			select
				[Ord. type]=''YOR'',
				[Sales document item category]='''',
				[Sold-to party Number]=[Sold-to party],
				[Sold-to Party Name]='''',
				[Material Type]=m.[Material Type],
				[Billing Doc Date]=format(f.[Billing Date],''000000'')+''01'',
				[Bill. Material]=f.[Material],
				[Barcode_Original]=m.[EAN / UPC],
				[DO Billed Quantity]=abs(f.[Billing Quantity]+f.[Promo. Qty]),
				[FOC TYPE]='''',
				[Channel]=c.[Channel],
				[ABS]=case when (f.[Billing Quantity]+f.[Promo. Qty])<0 then -1 else 1 end
			from SAP_TO_FM f (NOLOCK)
			inner join
			(
				select DISTINCT
					[Material],
					[EAN / UPC],
					[Material Type],
					[Item Category Group]
				from SC1.dbo.MM_ZMR54OLD_Stg (NOLOCK)
				where [Sales  Org]='''+@Salesorg+'''
			) m on m.Material=f.Material
			left join 
			(
				select distinct
					[Node 5] = right(''0000000000''+[Node 5],10),
					[Channel]
				from FC_MasterFile_'+@Division+'_Customer_Master (NOLOCK)
				where
					[FM_KEY]=(select max(FM_KEY) from FC_MasterFile_'+@Division+'_Customer_Master)
				and [Channel] IN(SELECT Channel FROM V_FC_Channel)
			) c on right(''0000000000''+c.[Node 5],10)=right(''0000000000''+f.[Sold-to Party],10)
			where 
				f.[FMlevel3]='''+@Salesorg+'''
			and f.[Billing Date] between '+@fromdate+' and '+@todate+'
			union all
			select
				[Ord. type]=''YOR'',
				[Sales document item category]='''',
				[Sold-to party Number]=[Sold-to party],
				[Sold-to Party Name]='''',
				[Material Type]=m.[Material Type],
				[Billing Doc Date]=format(f.[Billing Date],''000000'')+''01'',
				[Bill. Material]=f.[Material],
				[Barcode_Original]=m.[EAN / UPC],
				[DO Billed Quantity]=abs(f.[Free. Qty]),
				[FOC TYPE]=''FDR'',
				[Channel]=case when f.[Sold-to party]=''0000500000'' then ''FOC'' else c.[Channel] end,
				[ABS]=case when f.[Free. Qty]<0 then -1 else 1 end
			from SAP_TO_FM f (NOLOCK)
			inner join
			(
				select DISTINCT
					[Material],
					[EAN / UPC],
					[Material Type],
					[Item Category Group]
				from SC1.dbo.MM_ZMR54OLD_Stg (NOLOCK)
				where [Sales  Org]='''+@Salesorg+'''
			) m on m.Material=f.Material
			left join 
			(
				select distinct
					[Node 5] = right(''0000000000''+[Node 5],10),
					[Channel]
				from FC_MasterFile_'+@Division+'_Customer_Master (NOLOCK)
				where
					[FM_KEY]=(select max(FM_KEY) from FC_MasterFile_'+@Division+'_Customer_Master)
				and [Channel] IN(SELECT Channel FROM V_FC_Channel)
			) c on right(''0000000000''+c.[Node 5],10)=right(''0000000000''+f.[Sold-to Party],10)
			where 
				f.[FMlevel3]='''+@Salesorg+'''
			and f.[Free. Qty]<>0
			and f.[Billing Date] between '+@fromdate+' and '+@todate+'
		) as x '

		if @debug>0
		begin
			select @sql 'Insert table'
		end
		execute(@sql)
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