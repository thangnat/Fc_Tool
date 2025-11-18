/*
	Declare
		@b_Success			Int,
		@c_errmsg			Nvarchar(250)

	exec sp_tag_gen_fm_non_modeling 'LLD','202411','full',@b_Success OUT,@c_errmsg OUT

	select @b_Success b_Success,@c_errmsg c_errmsg

	select * from FC_FM_Non_modeling_LLD_202411
	select * from FC_FM_Non_modeling_Final_LLD_202409
*/
ALter proc sp_tag_gen_fm_non_modeling
	@Division			nvarchar(3),
	@FM_KEY				Nvarchar(6),
	@Type				nvarchar(4),--//full or ''-->Active
	@b_Success			Int				OUTPUT,     
	@c_errmsg			Nvarchar(250)	OUTPUT
	with encryption
AS
SET NOCOUNT ON
SET XACT_ABORT ON

BEGIN TRY
	DECLARE   
		 @debug					int=0
		,@sp_name				Nvarchar(100)
		,@n_continue			Int
		,@USERS					Nvarchar(50)
		,@MODIFILED				Datetime
		,@n_err					int
		,@fm_file_name			nvarchar(100) =''
		,@sql					nvarchar(max) = ''

	declare
		@b_Success1				Int,
		@c_errmsg1				Nvarchar(250)

	DECLARE @DbName NVARCHAR(20)

	-- Get the environment configuration
	SELECT @DbName = CASE 
		WHEN Value = 'Production' THEN 'master.dbo'
		ELSE 'master_UAT'
	END
	FROM EnvironmentConfig
	WHERE Name = 'Current_Environment'

	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_tag_gen_fm_non_modeling',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	select @debug=debug from fnc_Debug('FC')
	--select @debug=1
	
	declare @Monthfc				nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from V_FC_FM_Table

	select @fm_file_name = @Division+'_FM_Non_Modeling_'+@FM_Key+'.xlsx'

	declare @tablename_tmp nvarchar(200) = ''
	select @tablename_tmp = 'FC_FM_Non_Modeling_'+@Division+@Monthfc+'_tmp'

	declare @tablename nvarchar(200) = ''
	select @tablename = 'FC_FM_Non_Modeling_'+@Division+@Monthfc

	declare @tablename_final nvarchar(200) = ''
	select @tablename_final = 'FC_FM_Non_Modeling_Final_'+@Division+@Monthfc

	declare @result0 nvarchar(MAX) = ''
	SELECT @result0 = ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'FM',',')
	--SELECT result0 = ListColumn FROM fn_FC_GetColheader_Current('202411','FM',',')

	declare @result nvarchar(MAX) = ''
	SELECT @result = ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'FM_non_Tmp',',')
	--SELECT result = ListColumn FROM fn_FC_GetColheader_Current('202411','FM_non_Tmp',',')

	declare @ListColumn_Current nvarchar(max) = ''
	SELECT @ListColumn_Current = ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'NonModelling','')
	--SELECT ListColumn_Current = ListColumn FROM fn_FC_GetColheader_Current('202411','NonModelling','si')

	IF @debug>0
	BEGIN
		select 'imsert tmp'
	END
	if @n_continue = 1
	begin
		--//add tmp table
		IF @DbName = 'master.dbo'
			exec link_37.master.dbo.sp_add_FC_FM_Non_Modeling_Tmp @Division,@FM_KEY,@fm_file_name,@b_Success1 OUT, @c_errmsg1 OUT
		ELSE
			exec link_37.master_UAT.dbo.sp_add_FC_FM_Non_Modeling_Tmp @Division,@FM_KEY,@fm_file_name,@b_Success1 OUT, @c_errmsg1 OUT

		if @b_Success1 = 0
		begin
			select @n_continue = 3, @c_errmsg = @c_errmsg1
		end
		else
		begin
			IF @DbName = 'master.dbo'
				exec link_37.master.dbo.sp_getColumCount_New @tablename_tmp
			ELSE
				exec link_37.master_UAT.dbo.sp_getColumCount_New @tablename_tmp
		end
	end
	if @debug>0
	begin
		select * from FC_TotalCOlumn_Tmp
	end
	BEGIN TRAN
	IF @debug>0
	BEGIN
		select @n_continue '@n_continue','imsert main'
	END
	if @n_continue = 1
	begin
		if exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID(@tablename) AND type in (N'U')
		)
		begin
			select @sql = 
			'truncate table '+@tablename+'
			INSERT INTO '+@tablename+'
			(
				[FM_KEY],
				[Signature],
				[BFL Code],
				[BFL Name],
				[EAN Code],
				[SKU Code],
				[SKU Name],
				[Compass Code],
				[Local Level],
				[Time series],'+
				@result0+'
			)
			Select 
				[FM_KEY] = '''+@FM_KEY+''',
				[Signature],
				[BFL Code],
				[BFL Name],
				[EAN Code],
				[SKU Code],
				[SKU Name],
				[Compass Code],
				[Local Level],
				[Time series],'+
				@result+
			' from ' + @DbName + '.' + @tablename_tmp 
		end
		else
		begin
			select @sql = 
			'Select 
				[FM_KEY] = '''+@FM_KEY+''',
				[Signature],
				[BFL Code],
				[BFL Name],
				[EAN Code],
				[SKU Code],
				[SKU Name],
				[Compass Code],
				[Local Level],
				[Time series],'+
				@result+'
				INTO '+@tablename+'
			from ' + @DbName + '.' + @tablename_tmp 
		end
	
		if @debug>0
		begin
			SELECT @sql '@sql import main 1'
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
		select 'tao table connect subgroup'
	end
	if @n_continue = 1
	begin
		if exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID(@tablename_final) AND type in (N'U')
		)
		begin
			select @sql = 'drop table '+@tablename_final
			if @debug>0
			begin
				select @sql '@sql drop table FM non modeling final'
			end
			execute(@sql)

		end
		select @sql =
		'select 
			[Product Type]=s.[Type],
			[SUB GROUP/ Brand] = isnull(s.[SUB GROUP/ Brand],''''),
			[Local Level] = F.[Local Level],
			[EAN Code]=f.[EAN Code],
			[SKU Code]=f.[SKU Code],
			[Time series] = (SELECT DISTINCT MAP FROM V_FC_TIME_SERIES WHERE TimeSeries = F.[TIME SERIES]),'
			+@ListColumn_Current+'
			INTO '+@tablename_final+'
		from '+@tablename+' f 
		left join 
		(
			select distinct
				'+case when @Division IN('LLD','LDB','PPD') then 'BarCode' else 'Material' end+',
				[Material Type], 
				[Type],
				[SUB GROUP/ Brand],
				[Item Category Group]
			from fnc_SubGroupMaster('''+@Division+''','''+@Type+''') 
			where [Material Type] '+case when @Division IN('LLD','LDB','PPD') then 'in(''YFG'')' else 'in(''YFG'',''YSM2'')' end+'
		) s on '+case when @Division IN('LLD','LDB','PPD') then 's.barcode = f.[Ean Code]' else 's.Material = f.[Sku Code]' end+'	
		Where 
			f.[Time series] '+case when @Division IN('LLD','PPD') then 'NOT IN(''Total Qty'')' else 'IN(''Baseline Qty'')' end+' 
		and f.[Local Level]=''OFFLINE''
		Order by
			s.[Type],
			s.[SUB GROUP/ Brand] asc,
			f.[Local Level] ASC,
			f.[Time series] ASC '

		if @debug>0
		begin
			SELECT @sql '@sql FINAL OFFLINE'
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
	/*
	select @sql =
			'INSERT INTO '+@tablename_final+'
			select 
				[Product Type]=s.[Type],
				[SUB GROUP/ Brand] = s.[SUB GROUP/ Brand],
				[Local Level] = F.[Local Level],
				[EAN Code]=f.[EAN Code],
				[SKU Code]=f.[SKU Code],
				[Time series] = (SELECT DISTINCT MAP FROM V_FC_TIME_SERIES WHERE TimeSeries = F.[TIME SERIES]),'
				+@ListColumn_Current+'
			from '+@tablename+' f 
			left join 
			(
				select distinct
					'+case when @Division IN('LLD','LDB') then 'BarCode' else 'Material' end+',
					[Material Type], 
					[Type],
					[SUB GROUP/ Brand],
					[Item Category Group]
				from fnc_SubGroupMaster('''+@Division+''','''+@Type+''') 
				where [Material Type] '+case when @Division IN('LLD','LDB') then 'in(''YFG'')' else 'in(''YFG'',''YSM2'')' end+'
			) s on '+case when @Division IN('LLD','LDB') then 's.barcode = f.[Ean Code]' else 's.Material = f.[Sku Code]' end+'	
			Where f.[Time series] '+case when @Division='LLD1' then 'NOT IN(''Total Qty'')' else 'IN(''Baseline Qty'')' end+' 
			and f.[Local Level]=''OFFLINE''
			/*GROUP BY
				s.[Type],s.[SUB GROUP/ Brand],F.[Local Level],f.[Time series]*/
			Order by
				s.[Type],
				s.[SUB GROUP/ Brand] asc,
				f.[Local Level] ASC,
				[Time series] ASC'
				/*NOT IN(''Total Qty'')*/
				/*IN(''Baseline Qty'')*/
			if @debug>0
			begin
				SELECT @sql '@sql FINAL OFFLINE'
			end
			execute(@sql)

			select @n_err = @@ERROR
			if @n_err<>0
			begin				
				select @n_continue = 3
				select @n_err=60002
				select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +ERROR_MESSAGE()+'./ ('+@sp_name+')'
			end
	*/

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