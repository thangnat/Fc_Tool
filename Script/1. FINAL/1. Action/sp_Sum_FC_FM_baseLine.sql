/*
	Declare
		@b_Success			Int,
		@c_errmsg			Nvarchar(250)

	exec sp_Sum_FC_FM_baseLine 'LDB','202501','full','BOM_ONLINE',@b_Success OUT,@c_errmsg OUT
	
	select @b_Success b_Success,@c_errmsg c_errmsg

	/*
		type time series:
			SINGLE_OFFLINE, 
			SINGLE_ONLINE,
			SINGLE_ALL, 
			BOM_OFFLINE, 
			BOM_ONLINE,
			BOM_ALL
	*/
	select * from FC_SI_Promo_Bom_LDB
	select * from FC_FM_SUM_BASELINE_OFFLINE_CPD
	select * from FC_FM_SUM_BASELINE_ONLINE_CPD
	--//------------------------------------------------
	seelct * from FC_LIST_BOM_HEADER_OFFLINE_CPD
	seelct * from FC_LIST_BOM_HEADER_ONLINE_CPD
*/

Alter proc sp_Sum_FC_FM_baseLine
	@Division			nvarchar(3),
	@FM_KEY				nvarchar(6),
	@Type				nvarchar(4),--lay master data: full Or only active=null
	@TYPE_TIMESERIES	NVARCHAR(20),
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
	
	Declare
		@b_Success1				Int,
		@c_errmsg1				Nvarchar(250)

	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_Sum_FC_FM_baseLine',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	select @debug=debug from fnc_Debug('FC')
	select @debug=1

	declare @Monthfc			nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from V_FC_FM_Table

	declare @Tablename_OFFLINE			nvarchar(200) = ''
	select @Tablename_OFFLINE = 'FC_FM_SUM_BASELINE_OFFLINE_'+@Division+@Monthfc
	
	declare @Tablename_ONLINE			nvarchar(200) = ''
	select @Tablename_ONLINE = 'FC_FM_SUM_BASELINE_ONLINE_'+@Division+@Monthfc
	
	declare @TableFM					nvarchar(100) = ''
	select @TableFM = 'FC_FM_'+@division+@Monthfc

	declare @ListColumn_Current			nvarchar(max) = ''
	SELECT @ListColumn_Current = ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'1. Baseline Qty','')
	--SELECT ListColumn_Current = ListColumn FROM fn_FC_GetColheader_Current('202411','1. Baseline Qty','')
	
	declare @ListColumn_Current_plus	nvarchar(max) = ''
	SELECT @ListColumn_Current_plus = ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'1. Baseline Qty_+','')
	--SELECT ListColumn_Current_plus = ListColumn FROM fn_FC_GetColheader_Current('202410','1. Baseline Qty_+','')

	DECLARE @LIST_BOM_HEADER_OFFLINE	NVARCHAR(100) = ''
	SELECT @LIST_BOM_HEADER_OFFLINE = 'FC_LIST_BOM_HEADER_OFFLINE_'+@Division+@Monthfc
	
	declare @LIST_BOM_HEADER_ONLINE		NVARCHAR(100) = ''
	SELECT @LIST_BOM_HEADER_ONLINE = 'FC_LIST_BOM_HEADER_ONLINE_'+@Division+@Monthfc

	declare @list_product_type nvarchar(20)=''
	declare @ColumnRelationShip nvarchar(20)=''
	declare @ColumnCompare nvarchar(50)=''

	select 
		@list_product_type=[Product Type],
		@ColumnRelationShip=[Column Relationship],
		@ColumnCompare=[Column Compare] 
	from V_FC_DIVISION_BY_PRODUCT_TYPE 
	where [Division]=@Division
	
	if @debug>0
	begin
		select 'INSERT FM OFFLINE BASELINE'
	end
	IF @n_continue = 1
	BEGIN
		IF @TYPE_TIMESERIES IN('SINGLE_OFFLINE','SINGLE_ALL')
		BEGIN
			select @sql =
			'if exists
			(
				SELECT * 
				FROM sys.objects 
				WHERE object_id = OBJECT_ID('''+@Tablename_OFFLINE+''') AND type in (N''U'')
			)
			begin
				DROP TABLE '+@Tablename_OFFLINE+'				
			end
			
			select
				*
				INTO '+@Tablename_OFFLINE+'
			from
			(
				select 
					[Product Type]=s.[Product Type],
					[SUB GROUP/ Brand]=s.[SUB GROUP/ Brand],
					[Local Level]=F.[Local Level],
					[Time series]=(SELECT DISTINCT MAP FROM V_FC_TIME_SERIES WHERE TimeSeries=F.[TIME SERIES]),'
					+@ListColumn_Current+'
				from '+@TableFM+' f
				left join 
				(
					select distinct 
						'+@ColumnRelationShip+',
						[Product Type],
						[SUB GROUP/ Brand],
						[Item Category Group]
					from fnc_SubGroupMaster('''+@Division+''','''+@Type+''') 
					where [Product Type] IN(select value from string_split('''+@list_product_type+''','',''))
				) s on '+@ColumnCompare+'
				WHERE 
					F.[Local Level]=''OFFLINE'' 
				and f.[Time series]=''BASELINE QTY'' 
				and s.[Item Category Group]<>''LUMF'' 
				and s.[Product Type] IN(select value from string_split('''+@list_product_type+''','',''))
				GROUP BY
					s.[Product Type],
					s.[SUB GROUP/ Brand],
					F.[Local Level],
					f.[Time series]
			) as x
			where ('+@ListColumn_Current_plus+')<>0
			order by
				x.[Product Type],
				x.[SUB GROUP/ Brand] asc,
				x.[Local Level] ASC,
				x.[Time series] ASC '
		
			if @debug >0
			begin
				select @sql '@sql INSERT FM OFFLINE'
			end
			execute(@sql)

			select @n_err = @@ERROR
			if @n_err<>0
			begin				
				select @n_continue = 3
				select @n_err=60002
				select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +ERROR_MESSAGE()+'./ ('+@sp_name+')'
			end
		END
	end
	if @debug>0
	begin
		select 'INSERT FM ONLINE'
	end
	if @n_continue=1
	begin
		IF @TYPE_TIMESERIES IN('SINGLE_ONLINE','SINGLE_ALL')
		BEGIN
			select @sql =
			'if exists
			(
				SELECT * 
				FROM sys.objects 
				WHERE object_id = OBJECT_ID('''+@Tablename_ONLINE+''') AND type in (N''U'')
			)
			begin
				DROP TABLE '+@Tablename_ONLINE+'				
			end
			
			select
				*
				INTO '+@Tablename_ONLINE+'
			from
			(
				select 
					[Product Type]=s.[Product Type],
					[SUB GROUP/ Brand]=s.[SUB GROUP/ Brand],
					[Local Level]=F.[Local Level],
					[Time series]=(SELECT DISTINCT MAP FROM V_FC_TIME_SERIES WHERE TimeSeries=F.[TIME SERIES]),'
					+@ListColumn_Current+'
				from '+@TableFM+' f
				left join 
				(
					select distinct
						'+@ColumnRelationShip+',
						[Product Type],
						[SUB GROUP/ Brand],
						[Item Category Group]
					from fnc_SubGroupMaster('''+@Division+''','''+@Type+''') 
					where 
						[Product Type] IN(select value from string_split('''+@list_product_type+''','',''))
				) s on '+@ColumnCompare+'
				WHERE 
					F.[Local Level]=''ONLINE'' 
				and [Time series]<>''Total Qty'' 
				and s.[Item Category Group]<>''LUMF''  
				GROUP BY
					s.[Product Type],
					s.[SUB GROUP/ Brand],
					F.[Local Level],
					f.[Time series]			
			) as x
			where ('+@ListColumn_Current_plus+')<>0
			order by
				x.[Product Type],
				x.[SUB GROUP/ Brand] asc,
				x.[Local Level] ASC,
				x.[Time series] ASC '

			if @debug >0
			begin
				select @sql '@sql INSERT FM ONLINE'
			end
			execute(@sql)

			select @n_err = @@ERROR
			if @n_err<>0
			begin				
				select @n_continue = 3
				select @n_err=60002
				select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +ERROR_MESSAGE()+'./ ('+@sp_name+')'
			end
		END	
	end
	if @debug>0
	begin
		select 'INSERT LIST BOM HEADER OFFLINE FM'
	end
	if @n_continue=9
	begin
		IF @TYPE_TIMESERIES  IN('BOM_OFFLINE','BOM_ALL')
		BEGIN
			--drop offline
			SELECT @sql ='
			if exists
			(
				SELECT * 
				FROM sys.objects 
				WHERE object_id = OBJECT_ID('''+@LIST_BOM_HEADER_OFFLINE+''') AND type in (N''U'')
			)
			begin
				drop table '+@LIST_BOM_HEADER_OFFLINE+'				
			end
			
			select
				*
				INTO '+@LIST_BOM_HEADER_OFFLINE+'
			from
			(
				select
					[Bundle Code]=f.[Sku Code],
					[Channel]=F.[Local Level],
					[TIME SERIES Original]=F.[TIME SERIES],
					[Time series]=''3. Promo Qty(BOM)'', '
					+@ListColumn_Current+'				
				from '+@TableFM+' f
				left join 
				(
					select distinct
						'+@ColumnRelationShip+',
						/*[Product Type], 
						[SUB GROUP/ Brand],*/
						[Item Category Group]
					from fnc_SubGroupMaster('''+@Division+''','''+@Type+''') 
					where 
						[Product Type] IN(select value from string_split('''+@list_product_type+''','',''))
					AND [Item Category Group]=''LUMF''
				) s on '+@ColumnCompare+'
				WHERE 
					F.[Local Level]=''OFFLINE1'' 
				and [Time series]=''BASELINE QTY'' 
				and s.[Item Category Group]=''LUMF''  
				/*and s.[Product Type] IN(select value from string_split('''+@list_product_type+''','',''))*/
				GROUP BY
					f.[Sku Code],
					F.[Local Level],
					F.[TIME SERIES]
			) as x
			where ('+@ListColumn_Current_plus+')<>0
			Order by
				x.[Bundle Code] ASC,
				x.[Channel] ASC  '

			if @debug >0
			begin
				select @sql '@sql INSERT LIST BOM HEADER OFFLINE FM'
			end
			execute(@sql)

			select @n_err = @@ERROR
			if @n_err<>0
			begin				
				select @n_continue = 3
				select @n_err=60002
				select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +ERROR_MESSAGE()+'./ ('+@sp_name+')'
			end
		END
	end
	if @debug>0
	begin
		select 'INSERT LIST BOM HEADER ONLINE FM'
	end
	if @n_continue=1
	begin		
		if @TYPE_TIMESERIES in('BOM_ONLINE','BOM_ALL')
		BEGIN
			--//drop online
			SELECT @sql = '
			if exists
			(
				SELECT * 
				FROM sys.objects 
				WHERE object_id = OBJECT_ID('''+@LIST_BOM_HEADER_ONLINE+''') AND type in (N''U'')
			)
			begin
				drop table '+@LIST_BOM_HEADER_ONLINE+'
			end
		
			select
				*
				INTO '+@LIST_BOM_HEADER_ONLINE+'
			from
			(
				select
					[Bundle Code]=f.[Sku Code],
					[Channel]=F.[Local Level],
					[TIME SERIES Original]=F.[TIME SERIES],
					[Time series]=''3. Promo Qty(BOM)'', '
					+@ListColumn_Current+'
				from '+@TableFM+' f
				Left join 
				(
					select DISTINCT
						'+@ColumnRelationShip+',
						[Item Category Group]
					from fnc_SubGroupMaster('''+@Division+''','''+@Type+''') 
					where [Product Type] IN(select value from string_split('''+@list_product_type+''','',''))
					 AND [Item Category Group]=''LUMF''
				) s on '+@ColumnCompare+'
				WHERE 
					F.[Local Level]=''ONLINE'' 
				and f.[Time series]<>''Total Qty'' 
				and s.[Item Category Group]=''LUMF''  
				GROUP BY
					F.[Sku Code],
					F.[Local Level],
					F.[TIME SERIES]
			) as x
			where ('+@ListColumn_Current_plus+')<>0
			Order by
				x.[Bundle Code] ASC,
				x.[Channel] ASC '

			if @debug >0
			begin
				select @sql '@sql INSERT LIST BOM HEADER ONLINE FM'
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

