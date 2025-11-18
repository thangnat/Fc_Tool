/*
	declare
		@b_Success			Int,
		@c_errmsg			Nvarchar(250)

	exec sp_Add_ZV14_Forecast 'LLD','',@b_Success OUT,@c_errmsg OUT

	select @b_Success b_Success,@c_errmsg c_errmsg

	select * from FC_LDB_ZV14_Historical
	select * from FC_ZV14_CPD_From_2022 where [FOC TYPE] = 'FDR' and channel = 'FOC'
	select distinct left([Billing Doc Date],4)+substring([Billing Doc Date],5,2) from FC_ZV14_CPD_From_2022
	select
		*
	from
	(
		select distinct 
			[Year]=year([Billing Doc Date]),
			[Month] = month([Billing Doc Date]) 
		from FC_CPD_ZV14_Historical
	) as x
	order by [Year] asc, [Month] asc

	drop table FC_LLD_ZV14_Historical
	select * from FC_CPD_ZV14_Historical 
	where [FOC TYPE]='FDR' and channel = 'FOC'
*/
Alter proc sp_Add_ZV14_Forecast
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

	declare 
		@defaultDate			nvarchar(10) = '20211231',
		@max_date				nvarchar(10),
		@fromdate				nvarchar(8) = '0', 
		@todate					nvarchar(8) = '0',
		@month					int = 1,
		@from_Current_month		nvarchar(8) = '0',
		@to_current_month		nvarchar(8) = '0',
		@SaleOrg				Nvarchar(4) = '',
		@tablename				nvarchar(100) = '',
		@sql					nvarchar(max) = ''
	--declare @monthhis_Date		date
	--declare @monthhis_from		nvarchar(8)=''
	--declare @monthhis_To		nvarchar(8)=''

	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_Add_ZV14_Forecast',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	select @debug=debug from fnc_Debug('FC')
	select @debug=1
	select @SaleOrg = case
						when @Division = 'LLD' then 'V100'
						when @Division = 'CPD' then 'V200'
						when @Division = 'PPD' then 'V300'
						when @Division = 'LDB' then 'V400'
						else ''
					end
	if @n_continue=1
	begin
		if @FM_KEY=''
		begin
			select @FM_KEY=format(GETDATE(),'yyyyMM')
		end
	end

	if @n_continue=1
	begin
		select @tablename = 'FC_'+@Division+'_ZV14_Historical'
		if not exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID(@tablename) AND type in (N'U')
		)
		begin
			select @sql = 
			'CREATE TABLE '+@tablename+'
			(
				[Ord. type] [nvarchar](20) NULL,
				[Sales document item category] [nvarchar](20) NULL,
				[Sold-to Party Number] [nvarchar](20) NULL,
				[Sold-to Party Name] [nvarchar](100) NULL,
				[Material Type] [varchar](50) NULL,
				[Billing Doc Date] [nvarchar](20) NULL,
				[Bill. Material] [nvarchar](20) NULL,
				[Barcode_Original] [varchar](50) NULL,
				[DO Billed Quantity] [numeric](18, 0) NULL,
				[FOC TYPE] [nvarchar](4000) NOT NULL,
				[Channel] [nvarchar](20) NULL,
				[ABS] [int] NULL
			)'
			if @debug>0
			begin
				select @sql  '@sql create table'
			end
			execute(@sql)

		end
		select 
			@from_Current_month = format(dateadd(MM,-1,getdate()),'yyyyMM')+'01'--format(cast(getdate() as date),'yyyyMM')+'01'
			,@to_current_month = format(eomonth(getdate()),'yyyyMMdd')
		if @debug>0
		begin
			select 
				@from_Current_month '@from_Current_month'
				,@to_current_month '@to_current_month'
		end
		select @sql = 
		'delete '+@tablename+' 
		where cast([Billing Doc Date] as bigint) 
		between cast('+@from_Current_month+' as bigint) and cast('+@to_current_month+' as bigint) '
	
		if @debug>0
		begin
			select @sql '@sql delete historical'
		end
		execute(@sql)
		--if @Division='LLD'
		--begin
		--	--truncate table FC_LLD_ZV14_Historical
		--	select @sql = 
		--	'delete '+@tablename+' 
		--	where cast([Billing Doc Date] as bigint) 
		--	between cast('+@from_Current_month+' as bigint) and cast('+@to_current_month+' as bigint) '
	
		--	if @debug>0
		--	begin
		--		select @sql '@sql 1.1.2'
		--	end
		--	execute(@sql)
		--end
		--else if @Division='CPD'
		--begin
		--	--truncate table FC_CPD_ZV14_Historical
		--	select @sql = 
		--	'delete '+@tablename+' 
		--	where cast([Billing Doc Date] as bigint) 
		--	between cast('+@from_Current_month+' as bigint) and cast('+@to_current_month+' as bigint) '
	
		--	if @debug>0
		--	begin
		--		select @sql '@sql delete historical CPD'
		--	end
		--	execute(@sql)
		--end
		--else if @Division='LDB'
		--begin
		--	--truncate table FC_LDB_ZV14_Historical
		--	--select @from_Current_month=format(dateadd(MM,-1,getdate()),'yyyyMM')+'01',@to_current_month=format(eomonth(getdate()),'yyyyMMdd')

		--	select @sql = 
		--	'delete '+@tablename+' 
		--	where cast([Billing Doc Date] as bigint) 
		--	between cast('+@from_Current_month+' as bigint) and cast('+@to_current_month+' as bigint) '
	
		--	if @debug>0
		--	begin
		--		select @sql '@sql 1.1.2'
		--	end
		--	execute(@sql)
		--end
	end

	if @n_continue=1
	begin
		if @Division = 'LLD'
		begin
			select 
				@max_date = cast(max([Billing Doc Date]) as nvarchar(10))
			from fc_LLD_zv14_Historical
		end
		else if @Division = 'CPD'
		begin
			select 
				@max_date = cast(max([Billing Doc Date]) as nvarchar(10))
			from fc_CPD_zv14_Historical
		end
		else if @Division = 'LDB'
		begin
			select 
				@max_date = cast(max([Billing Doc Date]) as nvarchar(10))
			from fc_LDB_zv14_Historical
		end
		--else if @Division = 'PPD'
		--begin
		--	select 
		--		@max_date = cast(max([Billing Doc Date]) as nvarchar(10))
		--	from fc_PPD_zv14_Historical
		--end

		if @debug >0
		begin
			select @max_date '@max_date'
		end
		if @max_date is null
		begin
			select @max_date = @defaultDate
		end

		if @debug >0
		begin
			select @max_date '@max_date_new'
		end
		select @fromdate = format(dateadd(DD,1,cast(left(@max_date,4)+'-'+SUBSTRING(@max_date,5,2)+'-'+right(@max_date,2) as date)),'yyyyMMdd')
		select @todate = format(eomonth(dateadd(MM,(@month-1),getdate())),'yyyyMMdd')
		if @fromdate>@todate
		begin
			select @fromdate = @todate
		end
		if @debug>0
		begin
			select @fromdate '@fromdate', @todate '@todate'
		end
	end
	declare
		@b_Success1			Int,
		@c_errmsg1			Nvarchar(250)

	if @n_continue=1
	begin
		--//get list Bom header from zv14 raw data
		exec sp_create_bomheader_from_ZV14 @Division,@fromdate,@todate,@b_Success1 OUT,@c_errmsg1 OUT

		if @b_Success1=0
		begin
			select @n_continue=3, @c_errmsg=@c_errmsg1
		end
	end

	if @n_continue=1
	begin
		if @debug>0
		begin
			select @max_date '@max_date',@todate '@todate'
		end

		if @max_date < @todate
		begin
			--if @MonthHis<>''
			--begin
			--	select @monthhis_Date=cast(format(GETDATE(),'yyyy')+'-'+@MonthHis+'-01' as date)
			--	select @monthhis_from=FORMAT(@monthhis_Date,'yyyyMMdd')
			--	select @monthhis_To=format(eomonth(@monthhis_Date),'yyyyMMdd')
				
			--	select @fromdate=@monthhis_from, @todate=@monthhis_To

			--	if @debug>0
			--	begin
			--		select @fromdate '@monthhis_from',@todate '@monthhis_To'
			--	end
			--end
			select @sql = 
			'insert into '+@tablename+'
			SELECT 
				z.[Ord. type],
				z.[Sales document item category],
				z.[Sold-to Party Number],
				z.[Sold-to Party Name],
				m.[Material Type],
				z.[Billing Doc Date],
				[Bill. Material]= case when '''+@Division+'''=''LLD'' then '''' else z.[Bill. Material] end,
				Barcode_Original = m.[EAN / UPC],
				z.[DO Billed Quantity],
				[FOC TYPE] = ISNULL(O.[FOC TYPE],''''),
				[Channel] = c.Channel,
				[ABS] = O.[ABS]			
			FROM ZV14 z (NOLOCK)
			INNER JOIN
			(
				SELECT *
				FROM V_ZV14_ORDER_TYPE
			) O ON O.[Sales Org] = Z.[Sales Organization] AND O.OrderType = Z.[Ord. type]
			inner join 
			(
				select distinct 
					[Material Type],
					Material=case when '''+@Division+'''=''LLD'' then '''' else Material end,
					[EAN / UPC]
				from SC1.dbo.MM_ZMR54OLD_Stg 
				where 
					[Sales  Org] = '''+@SaleOrg+''' 
				and [Material Type] '+case when @Division = 'CPD' then 'IN(''YFG'',''YSM2'')' else 'IN(''YFG'')' end+'
			) m on '+case when @Division='LLD' then 'm.[EAN / UPC]=z.[International Article Number (EAN/UPC)]' else 'm.Material=z.[Bill. Material]' end+'
			left join 
			(
				select distinct
					[Node 5] = right(''0000000000''+[Node 5],10),
					Channel
				from FC_MasterFile_'+@Division+'_Customer_Master (NOLOCK)
				where Channel IN(SELECT Channel FROM V_FC_Channel)
			) c on c.[Node 5] = z.[Sold-to Party Number]
			WHERE 
				z.Active = 1 
			and z.[Sales Organization] = '''+@SaleOrg+''' 
			and cast(z.[Billing Doc Date] as bigint) between cast('+@fromdate+' as bigint) and cast('+@todate+' as bigint) 
			and isnull(c.Channel,'''') not in(''CLEARANCES'') '+case when @Division='LLD' then '' else ' and  z.[Sold-to Party Number] not in(''0000500030'')' end

			if @debug>0
			begin
				select @sql '@sql Import ZV14 historical'
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
	if @n_continue=1
	begin
		exec sp_Create_V_His_SI_Final @Division,@FM_KEY,'h',@b_Success1 OUT,@c_errmsg1 OUT

		if @b_Success1=0
		begin
			select @n_continue=3,@c_errmsg=@c_errmsg1
		end
	end

	if @n_continue=9
	begin
		exec sp_tag_update_wf_mtd_si_NEW @Division,@FM_KEY,1,@b_Success1 OUT, @c_errmsg1 OUT

		if @b_Success1=0
		begin
			select @n_continue=3,@c_errmsg=@c_errmsg1
		end
	end
	if @n_continue=9
	begin
		exec sp_tag_update_wf_pass_02_years_new @Division,@FM_Key,1,@b_Success1 OUT, @c_errmsg1 OUT
		if @b_Success1=0
		begin
			select @n_continue = 3, @c_errmsg = @c_errmsg1
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