/*
	declare 
		@b_Success			Int,
		@c_errmsg			Nvarchar(250)

	exec sp_fc_Create_FM_Original_Full 'CPD','202407','1. Baseline Qty','',@b_Success OUT, @c_errmsg OUT

	select @b_Success b_Success, @c_errmsg c_errmsg

	SELECT * FROM FM_Original_Full_LLD where spectrum = 0
	SELECT * FROM FM_Original_Full_CPD order by [SUB GROUP/ Brand],Channel,[Time series]

*/
--select [Item Category Group] from SC1.dbo.MM_ZMR54OLD_Stg where Material='XVN00214'
Alter proc sp_fc_Create_FM_Original_Full
	@Division			nvarchar(3),
	@FM_KEY				nvarchar(6),
	@Timeseries			nvarchar(30),
	@codeUse			Nvarchar(20),
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
		@sp_name = 'sp_add_FC_FM_Tmp',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	select @debug=debug from fnc_Debug('FC')
	--select @debug=1

	declare @Monthfc				nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from V_FC_FM_Table

	declare @listcolumn nvarchar(max) = ''
	declare @listcolumn2 nvarchar(max) = ''
	SELECT @listcolumn = ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'FM_OriginalFull','')
	--SELECT listcolumn = ListColumn FROM fn_FC_GetColheader_Current('202406','FM_OriginalFull','')
	SELECT @listcolumn2 = ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'FM_OriginalFull','f')
	--SELECT listcolumn2 = ListColumn FROM fn_FC_GetColheader_Current('202405','FM_OriginalFull','f')

	declare @tablename	nvarchar(200) = ''
	select @tablename = 'FM_Original_Full_'+@Division--+@Monthfc
	if @debug>0
	begin
		select @tablename 'tablename'
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
			select @sql = 'drop table '+@tablename
			if @debug>0
			begin
				select @sql 'Drop table'
			end
			execute(@sql)
		end
		/*Spectrum = case when [Time series] IN(''1. Baseline Qty'',''2. Promo Qty(Single)'') then ''1'' else ''0'' end,*/
		select @sql = '
		select
			*
			INTO '+@tablename+' 
		from
		(
			select
				*
			from
			(
				select 
					[TableName] = ''FM1'',
					[SUB GROUP/ Brand] = s.[SUB GROUP/ Brand],
					[Channel] = f.[Local Level],
					[Time series] = '''+@Timeseries+''',
					[Sap Code] = f.[SKU Code],
					[Country Status] = f.[Country Status],'
					+@listcolumn+'
				from FC_FM_'+@Division+@Monthfc+' f
				inner join 
				(
					SELECT DISTINCT
						[Material],
						[SUB GROUP/ Brand],
						[Item Category Group]
					From fnc_SubGroupMaster('''+@Division+''',''full'') 
				) s on s.Material = f.[SKU Code] /*s.Barcode = f.[EAN Code] and */
				left join (select * from V_FC_TIME_SERIES) t on t.TimeSeries = f.[Time series]
				where 
					isnull(f.[Sku Code],'''')<>'''' 
				and t.map in('''+@Timeseries+''')
				and f.[Local Level] = ''OFFLINE''
				and s.[Item Category Group]<>''LUMF''
				group by
					f.[SKU Code],
					f.[Local Level],
					t.MAP,
					s.[SUB GROUP/ Brand],
					f.[Country Status]
				union all 
				select 
					[TableName] = ''FM1'',
					[SUB GROUP/ Brand] = s.[SUB GROUP/ Brand],
					[Channel] = f.[Local Level],
					[Time series] = t.MAP,
					[Sap Code] = f.[SKU Code],
					[Country Status] = f.[Country Status],'
					+@listcolumn+'
				from FC_FM_'+@Division+@Monthfc+' f
				inner join 
				(
					select DISTINCT
						[Material],
						[SUB GROUP/ Brand],
						[Item Category Group]
					from fnc_SubGroupMaster('''+@Division+''',''full'')
				) s on s.Material = f.[SKU Code] /*s.Barcode = f.[EAN Code] and */
				left join (select * from V_FC_TIME_SERIES) t on t.TimeSeries = f.[Time series]
				where 
					isnull(f.[Sku Code],'''')<>'''' 
				and t.map not in(''5. FOC Qty'',''6. Total Qty'',''3. Promo Qty(BOM)'')
				and f.[Local Level] = ''ONLINE''
				and s.[Item Category Group]<>''LUMF''
				group by
					f.[SKU Code],
					f.[Local Level],
					t.MAP,
					s.[SUB GROUP/ Brand],
					f.[Country Status]
			) as x
			where [Time series]='''+@Timeseries+''' 
		) as x1 '
			--+case 
			--	when exists(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('FC_SI_Launch_Single_CPD') AND type in (N'U')) then
			--		'union all
			--		select 
			--			[TableName] = ''Launch_Single Template'',
			--			[SUB GROUP/ Brand] = f.SubGrp,
			--			[Sap Code] = Code,
			--			[Channel],
			--			[Time series],
			--			[Country Status] = (select top 1 [Country Status] from FC_FM_'+@Division+' where '+case when @codeUse = 'BFL_CODE' then '[BFL Code]' else '[Sku Code]' end +' = f.Code and [Local Level] = f.Channel),'
			--			+@listcolumn2+'
			--		from FC_SI_Launch_Single_'+@Division+' f'
			--	when exists(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('FC_SI_Promo_Single_CPD') AND type in (N'U')) then
			--		'union all
			--		select
			--			[TableName] = ''Promo_Single Template'',
			--			[SUB GROUP/ Brand] = f.SubGrp,
			--			[Sap Code] = Code,
			--			[Channel],
			--			[Time series],
			--			[Country Status] = (select top 1 [Country Status] from FC_FM_'+@Division+' where '+case when @codeUse = 'BFL_CODE' then '[BFL Code]' else '[Sku Code]' end +' = f.Code and [Local Level] = f.Channel),'
			--			+@listcolumn2+'
			--		from FC_SI_Promo_Single_'+@Division+' f'
			--	when exists(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('FC_SI_FOC_'+@Division) AND type in (N'U')) then 
			--		'union all
			--		select
			--			[TableName] = ''Promo_Single Template'',
			--			[SUB GROUP/ Brand] = f.SubGrp,
			--			[Sap Code] = Code,
			--			[Channel],
			--			[Time series],
			--			[Country Status] = (select top 1 [Country Status] from FC_FM_'+@Division+' where '+case when @codeUse = 'BFL_CODE' then '[BFL Code]' else '[Sku Code]' end +' = f.Code and [Local Level] = f.Channel),'
			--			+@listcolumn2+'
			--		from FC_SI_FOC_'+@Division+' f'
			--end+			
		/*
		order by
			Channel asc, [sap code] asc,[Time series] asc
		*/

		if @debug >0
		begin
			select @sql 'Create table'
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

	--return
	--select 
	--	[Sap Code] = Code,
	--	Channel,
	--	[Time series]
	--from FC_SI_Launch_Single_CPD
	--select
	--	[Sap Code] = Code,
	--	Channel,
	--	[Time series]

	--from FC_SI_Promo_Single_CPD

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
