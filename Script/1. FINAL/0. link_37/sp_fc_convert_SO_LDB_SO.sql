/*
	Declare 
		@b_Success			Int,
		@c_errmsg			Nvarchar(250)

	exec sp_fc_convert_SO_LDB_SO 'LDB','202501',@b_Success OUT, @c_errmsg OUT

	select @b_Success b_Success, @c_errmsg c_errmsg

	select * from FC_SO_OPTIMUS_NORMAL_LDB_202409_ALL_Tmp
	truncate table FC_SO_OPTIMUS_NORMAL_LDB_ALL_Tmp

	select * from FC_SO_OPTIMUS_bundle_LDB_Tmp_OK
	truncate table FC_SO_OPTIMUS_bundle_LDB_Tmp_OK
	--where brand='CRV' and category='ONLINE' and channel='ONLINE' and [year]=2024 and [month]='Aug'
	select * from FC_SO_OPTIMUS_NORMAL_LDB_202501_Tmp_OK
	select * from FC_SO_OPTIMUS_PROMO_BOM_LDB_202501_Tmp_OK
	
*/

Create or Alter proc sp_fc_convert_SO_LDB_SO
	@division			nvarchar(3),
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
		 @debug					int=1
		,@sp_name				Nvarchar(100)
		,@n_continue			Int
		,@USERS					Nvarchar(50)
		,@MODIFILED				Datetime
		,@n_err					int

	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_fc_convert_SO_LDB_SO',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()
	declare @SharefolderPath nvarchar(500)
	select @SharefolderPath = Value from [SC2].[dbo].[EnvironmentConfig] where Name = 'Sharefolder_SAP_Dir'

	declare @startyear int = 0
	select @startyear = cast(left(@FM_KEY,4) as int)

	declare @Monthfc				nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from link_33.sc2.dbo.V_FC_FM_Table

	if @debug>0
	begin
		select 'Config table tmp'
	end
	if @n_continue = 1
	begin
		declare @table_ALL nvarchar(200) = ''
		select @table_ALL = 'FC_SO_OPTIMUS_NORMAL_'+@division+@Monthfc+'_ALL_Tmp'

		declare @tablename nvarchar(200) = ''
		select @tablename = 'FC_SO_OPTIMUS_NORMAL_'+@division+@Monthfc+'_Tmp_OK'

		declare @tablename_Bundle nvarchar(200) = ''
		select @tablename_Bundle = 'FC_SO_OPTIMUS_PROMO_BOM_'+@division+@Monthfc+'_Tmp_OK'

		declare @tmp table (number int identity(1,1),columnName varchar(20),[Desc] nvarchar(5))
		
		insert into @tmp
		(
			--number,
			[columnName],
			[Desc]
		)
		select 
			--number,
			[columname],
			[Desc] 
		from link_33.sc2.dbo.V_FC_LDB_OPTIMUS 
		where [Type]='SO' 
		--and [number]>12
		order by cast(Number as int) asc

		--select * from @tmp
		declare @totalrows int = 0, @currentrow int = 1,@sql nvarchar(max) = ''
		select @totalrows = isnull(count(*),0) from @tmp

	end
	if @debug>0
	begin
		select 'create table'
	end
	if @n_continue=1
	begin
		--NORMAL
		if exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID(@tablename) AND type in (N'U')
		)
		begin
			select @sql  ='Drop table '+@tablename

			if @debug>0
			begin
				select @sql 'drop table single'
			end
			execute(@sql)
		end
		select @sql =
				'Create table '+@tablename+
				'(					
					[FM_KEY]				nvarchar(6) null,
					[Filename]				nvarchar(500) NULL,
					[Year]					INT DEFAULT 0,
					[Month]					NVARCHAR(5) NULL,
					[Client]				nvarchar(50) NULL,
					[Channel]				NVARCHAR(10) NULL,
					[Brand]					nvarchar(50) NULL,
					[Category]				nvarchar(200) NULL,					
					[Forecasting line]		NVARCHAR(500) NULL,
					[Barcode]				nvarchar(30) NULL,
					[Sell-Out Units]		Numeric(18,0) DEFAULT 0,
					[GROSS SELL-OUT VALUE]	numeric(18,9) default 0,
					[Signature]				nvarchar(300) NULL
				)'
		if @debug>0
		begin
			select @sql 'Create table single'
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
		select 'create table'
	end
	if @n_continue =1
	begin		
		--BUNDLE
		if exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID(@tablename_Bundle) AND type in (N'U')
		)
		begin
			select @sql  ='Drop table '+@tablename_Bundle
			if @debug>0
			begin
				select @sql 'drop table bundle'
			end
			execute(@sql)
		end
		select @sql = 
				'Create table '+@tablename_Bundle+
				'(
					[Filename]				nvarchar(500) NULL,
					[Signature]				nvarchar(300) NULL,
					[Type]					nvarchar(20) null,
					[Channel]				NVARCHAR(10) NULL,
					[Brand]					nvarchar(50) NULL,
					[Category]				nvarchar(200) NULL,
					[Barcode]				NVARCHAR(20) NULL,
					[M1]					numeric(18,0) default 0,
					[M2]					numeric(18,0) default 0,
					[M3]					numeric(18,0) default 0,
					[M4]					numeric(18,0) default 0,
					[M5]					numeric(18,0) default 0,
					[M6]					numeric(18,0) default 0,
					[M7]					numeric(18,0) default 0,
					[M8]					numeric(18,0) default 0,
					[M9]					numeric(18,0) default 0,
					[M10]					numeric(18,0) default 0,
					[M11]					numeric(18,0) default 0,
					[M12]					numeric(18,0) default 0,
					[M13]					numeric(18,0) default 0,
					[M14]					numeric(18,0) default 0,
					[M15]					numeric(18,0) default 0,
					[M16]					numeric(18,0) default 0,
					[M17]					numeric(18,0) default 0,
					[M18]					numeric(18,0) default 0,
					[M19]					numeric(18,0) default 0,
					[M20]					numeric(18,0) default 0,
					[M21]					numeric(18,0) default 0,
					[M22]					numeric(18,0) default 0,
					[M23]					numeric(18,0) default 0,
					[M24]					numeric(18,0) default 0
				)'
		if @debug>0
		begin
			select @sql 'create table bundle'
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
		select 'see total'
	end
	if @n_continue=1
	begin
		if @totalrows<=0
		begin
			select @n_continue = 3, @c_errmsg = 'NO DATA.../'
		end
	end
	if @debug>0
	begin
		select 'insert table'
	end
	if @n_continue = 1
	begin
		while (@currentrow<=@totalrows)
		begin
			declare 
					@number				int = 0
					,@ColumnName		nvarchar(20) = ''
					,@Desc				nvarchar(5) = ''
					,@year_ok			int = 0

			select
				@number =number, 
				@ColumnName = columnName,
				@Desc = [Desc] 
			from @tmp 
			where number = @currentrow

			select @year_ok = iif(@number>12,1,0)+@startyear

			if @debug>0
			begin
				select @year_ok '@year_ok'
			end
			--select @number '@number',@ColumnName '@ColumnName',@Desc '@Desc',@year_ok '@year_ok'	
			
			--INSERT Single off line
			select @sql = '
			INSERT INTO '+@tablename+'
			select
				[FM_KEY]='''+@FM_KEY+''',
				[Filename],
				[Year],
				[Month],
				[Client],
				[Channel],
				[Brand],
				[Category],
				[Forecasting Line],
				[Barcode],
				[Sell-Out Units],
				[GROSS SELL-OUT VALUE],
				[Signature]
			from
			(
				select
					[FM_KEY]='''+@FM_KEY+''',
					[Filename]=t.[Filename],
					[Year]='''+cast(@year_ok as nvarchar(4))+''',
					[Month] = '''+@Desc+''',
					[Client] = '''',
					[Channel] = Channel,
					[Brand]=[Brand],
					[Category]=Channel2,
					[Forecasting Line] = [F9],
					[Barcode]=cast(isnull([7/1/2024],'''') as nvarchar(30)),
					[Sell-Out Units]= CAST(replace(replace(replace(replace('+@ColumnName+','','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
					[GROSS SELL-OUT VALUE]=cast(''0'' as numeric(18,0)),
					[Signature]=''''
				from '+@table_ALL+' t
				INNER join 
				(
					select DISTINCT
						[Material],
						[Item Category Group]
					from link_33.sc1.dbo.MM_ZMR54OLD_Stg 
					where 
						[Sales  Org]=''V400'' 
					and [Item Category Group]<>''LUMF''
				) m on m.Material = TRIM(REPLACE(t.[F4] ,CHAR(9) , ''''))
				where 
					isnull([F1],'''')<>''''
				and isnull([F8],'''')=''NORM''
				and isnull([F4],'''')<>''Active code''
				and isnull([F4],'''')<>''''
				and CHARINDEX(''OFFLINE'',t.[Filename])>0
				and isnull([F16],'''') NOT IN(''ECOM'',''MEDICAL'',''OFFLINE'',''TOTAL ACD'')
			) as x
			where cast([Sell-Out Units] as numeric(18,0))<>0 '

			if @debug>0
			begin
				select @sql '@sql insert single offline'
			end
			execute(@sql)
			--//insert single medical
			select @sql = '
			INSERT INTO '+@tablename+'
			select
				[FM_KEY]='''+@FM_KEY+''',
				[Filename],
				[Year],
				[Month],
				[Client],
				[Channel],
				[Brand],
				[Category],
				[Forecasting Line],
				[Barcode],
				[Sell-Out Units],
				[GROSS SELL-OUT VALUE],
				[Signature]
			from
			(
				select
					[FM_KEY]='''+@FM_KEY+''',
					[Filename]=t.[Filename],
					[Year]='''+cast(@year_ok as nvarchar(4))+''',
					[Month] = '''+@Desc+''',
					[Client] = '''',
					[Channel] = Channel,
					[Brand]=[Brand],
					[Category]=Channel2,
					[Forecasting Line] = [F9],
					[Barcode]=cast(isnull([7/1/2024],'''') as nvarchar(30)),
					[Sell-Out Units]= CAST(replace(replace(replace(replace('+@ColumnName+','','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
					[GROSS SELL-OUT VALUE]=cast(''0'' as numeric(18,0)),
					[Signature]=''''
				from '+@table_ALL+' t
				INNER join 
				(
					select DISTINCT
						Material,
						[Item Category Group]
					from link_33.sc1.dbo.MM_ZMR54OLD_Stg 
					where 
						[Sales  Org]=''V400'' 
					and [Item Category Group]<>''LUMF''
				) m on m.Material = TRIM(REPLACE(t.[F4] ,CHAR(9) , ''''))
				where 
					isnull([F1],'''')<>''''
				and isnull([F8],'''')=''NORM''
				and isnull([F4],'''')<>''Active code''
				and isnull([F4],'''')<>''''
				and CHARINDEX(''MEDICAL'',t.[Filename])>0
				and isnull([F16],'''') IN(''MEDICAL'')
			) as x
			where cast([Sell-Out Units] as numeric(18,0))<>0 '
			if @debug>0
			begin
				select @sql '@sql insert single medical'
			end
			execute(@sql)

			--//insert single ONLINE
			select @sql = '
			INSERT INTO '+@tablename+'
			select
				[FM_KEY]='''+@FM_KEY+''',
				[Filename],
				[Year],
				[Month],
				[Client],
				[Channel],
				[Brand],
				[Category],
				[Forecasting Line],
				[Barcode],
				[Sell-Out Units],
				[GROSS SELL-OUT VALUE],
				[Signature]
			from
			(
				select
					[FM_KEY]='''+@FM_KEY+''',
					[Filename]=t.[Filename],
					[Year]='''+cast(@year_ok as nvarchar(4))+''',
					[Month] = '''+@Desc+''',
					[Client] = '''',
					[Channel] = Channel,
					[Brand]=[Brand],
					[Category]=Channel2,
					[Forecasting Line] = [F9],
					[Barcode]=cast(isnull([7/1/2024],'''') as nvarchar(30)),
					[Sell-Out Units]= CAST(replace(replace(replace(replace('+@ColumnName+','','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
					[GROSS SELL-OUT VALUE]=cast(''0'' as numeric(18,0)),
					[Signature]=''''
				from '+@table_ALL+' t
				INNER join 
				(
					select DISTINCT
						Material,
						[Item Category Group]
					from link_33.sc1.dbo.MM_ZMR54OLD_Stg 
					where 
						[Sales  Org]=''V400'' 
					and [Item Category Group]<>''LUMF''
				) m on m.Material = TRIM(REPLACE(t.[F4] ,CHAR(9) , ''''))
				where 
					isnull([F1],'''')<>''''
				and isnull([F8],'''')=''NORM''
				and isnull([F4],'''')<>''Active code''
				and isnull([F4],'''')<>''''
				and CHARINDEX(''ONLINE'',t.[Filename])>0
				and isnull([F16],'''') IN(''ECOM'')
			) as x
			where cast([Sell-Out Units] as numeric(18,0))<>0 '

			--select CHARINDEX('OFFLINE',t.[Filename])

			if @debug>0
			begin
				select @sql '@sql insert single online'
			end
			execute(@sql)

			select @n_err = @@ERROR
			if @n_err<>0
			begin				
				select @n_continue = 3
				select @n_err=60002
				select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +ERROR_MESSAGE()+'./ ('+@sp_name+')'
			end
			
			select @currentrow = @currentrow +1
		end
		--insert bundle OFFLINE
		select @sql = '
		insert into '+@tablename_Bundle+'
		select
			[Filename],
			[Signature],
			[Type],
			[Channel],
			[Brand],
			[Category],
			[Barcode],
			[M1],
			[M2],
			[M3],
			[M4],
			[M5],
			[M6],
			[M7],
			[M8],
			[M9],
			[M10],
			[M11],
			[M12],
			[M13],
			[M14],
			[M15],
			[M16],
			[M17],
			[M18],
			[M19],
			[M20],
			[M21],
			[M22],
			[M23],
			[M24]
		from
		(
			select
				[Filename]=t.[Filename],
				[Signature]='''',					
				[Sap code] = [F4], 
				[Channel] = Channel,
				[Type]=[Material Type],
				Brand=Brand,
				[Category]=Channel2,
				[Barcode]=cast(isnull([7/1/2024],'''') as nvarchar(30)),
				[M1]=CAST(replace(replace(replace(replace([612],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
				[M2]=CAST(replace(replace(replace(replace([613],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
				[M3]=CAST(replace(replace(replace(replace([614],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
				[M4]=CAST(replace(replace(replace(replace([615],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
				[M5]=CAST(replace(replace(replace(replace([616],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
				[M6]=CAST(replace(replace(replace(replace([617],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
				[M7]=CAST(replace(replace(replace(replace([72],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
				[M8]=CAST(replace(replace(replace(replace([82],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
				[M9]=CAST(replace(replace(replace(replace([92],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
				[M10]=CAST(replace(replace(replace(replace([102],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
				[M11]=CAST(replace(replace(replace(replace([112],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
				[M12]=CAST(replace(replace(replace(replace([122],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
				[M13]=CAST(replace(replace(replace(replace([618],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
				[M14]=CAST(replace(replace(replace(replace([619],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
				[M15]=CAST(replace(replace(replace(replace([620],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
				[M16]=CAST(replace(replace(replace(replace([621],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
				[M17]=CAST(replace(replace(replace(replace([622],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
				[M18]=CAST(replace(replace(replace(replace([623],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
				[M19]=CAST(replace(replace(replace(replace([73],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
				[M20]=CAST(replace(replace(replace(replace([83],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
				[M21]=CAST(replace(replace(replace(replace([93],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
				[M22]=CAST(replace(replace(replace(replace([103],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
				[M23]=CAST(replace(replace(replace(replace([113],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
				[M24]=CAST(replace(replace(replace(replace([123],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0))
			from '+@table_ALL+' t
			INNER join 
			(
				select DISTINCT
					Material,
					[Item Category Group],
					[Material Type]
				from link_33.sc1.dbo.MM_ZMR54OLD_Stg 
				where 
					[Sales  Org]=''V400'' 
				and [Item Category Group] = ''LUMF''
			) m on m.Material = TRIM(REPLACE(t.[F4] ,CHAR(9) , ''''))
			where 
				isnull([F1],'''')<>''''
			and isnull([F8],'''')=''LUMF''
			and isnull([F4],'''')<>''Active code''
			and ISNULL([F4],'''')<>''''
			and CHARINDEX(''OFFLINE'',t.[Filename])>0
			and isnull([F16],'''') NOT IN(''ECOM'',''MEDICAL'',''OFFLINE'',''TOTAL ACD'')
		) as x '

		if @debug>0
		begin
			select @sql '@sql insert bundle offline'
		end
		execute(@sql)
		--insert bundle medical
		select @sql = '
		insert into '+@tablename_Bundle+'
		select
			[Filename],
			[Signature],
			[Type],
			[Channel],
			[Brand],
			[Category],
			[Barcode],
			[M1],
			[M2],
			[M3],
			[M4],
			[M5],
			[M6],
			[M7],
			[M8],
			[M9],
			[M10],
			[M11],
			[M12],
			[M13],
			[M14],
			[M15],
			[M16],
			[M17],
			[M18],
			[M19],
			[M20],
			[M21],
			[M22],
			[M23],
			[M24]
		from
		(
			select
				[Filename]=t.[Filename],
				[Signature]='''',					
				[Sap code] = [F4], 
				[Channel] = Channel,
				[Type]=[Material Type],
				Brand=Brand,
				[Category]=Channel2,
				[Barcode]=cast(isnull([7/1/2024],'''') as nvarchar(30)),
				[M1]=CAST(replace(replace(replace(replace([612],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
				[M2]=CAST(replace(replace(replace(replace([613],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
				[M3]=CAST(replace(replace(replace(replace([614],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
				[M4]=CAST(replace(replace(replace(replace([615],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
				[M5]=CAST(replace(replace(replace(replace([616],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
				[M6]=CAST(replace(replace(replace(replace([617],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
				[M7]=CAST(replace(replace(replace(replace([72],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
				[M8]=CAST(replace(replace(replace(replace([82],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
				[M9]=CAST(replace(replace(replace(replace([92],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
				[M10]=CAST(replace(replace(replace(replace([102],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
				[M11]=CAST(replace(replace(replace(replace([112],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
				[M12]=CAST(replace(replace(replace(replace([122],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
				[M13]=CAST(replace(replace(replace(replace([618],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
				[M14]=CAST(replace(replace(replace(replace([619],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
				[M15]=CAST(replace(replace(replace(replace([620],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
				[M16]=CAST(replace(replace(replace(replace([621],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
				[M17]=CAST(replace(replace(replace(replace([622],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
				[M18]=CAST(replace(replace(replace(replace([623],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
				[M19]=CAST(replace(replace(replace(replace([73],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
				[M20]=CAST(replace(replace(replace(replace([83],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
				[M21]=CAST(replace(replace(replace(replace([93],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
				[M22]=CAST(replace(replace(replace(replace([103],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
				[M23]=CAST(replace(replace(replace(replace([113],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
				[M24]=CAST(replace(replace(replace(replace([123],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0))
			from '+@table_ALL+' t
			INNER join 
			(
				select DISTINCT
					Material,
					[Item Category Group],
					[Material Type]
				from link_33.sc1.dbo.MM_ZMR54OLD_Stg 
				where 
					[Sales  Org]=''V400'' 
				and [Item Category Group] = ''LUMF''
			) m on m.Material = TRIM(REPLACE(t.[F4] ,CHAR(9) , ''''))
			where 
				isnull([F1],'''')<>''''
			and isnull([F8],'''')=''LUMF''
			and isnull([F4],'''')<>''Active code''
			and ISNULL([F4],'''')<>''''
			and CHARINDEX(''MEDICAL'',t.[Filename])>0
			and isnull([F16],'''') IN(''MEDICAL'')
		) as x '
		if @debug>0
		begin
			select @sql '@sql insert bundle medical'
		end
		execute(@sql)

		--insert bundle online
		select @sql = '
		insert into '+@tablename_Bundle+'
		select
			[Filename],
			[Signature],
			[Type],
			[Channel],
			[Brand],
			[Category],
			[Barcode],
			[M1],
			[M2],
			[M3],
			[M4],
			[M5],
			[M6],
			[M7],
			[M8],
			[M9],
			[M10],
			[M11],
			[M12],
			[M13],
			[M14],
			[M15],
			[M16],
			[M17],
			[M18],
			[M19],
			[M20],
			[M21],
			[M22],
			[M23],
			[M24]
		from
		(
			select
				[Filename]=t.[Filename],
				[Signature]='''',					
				[Sap code] = [F4], 
				[Channel] = Channel,
				[Type]=[Material Type],
				Brand=Brand,
				[Category]=Channel2,
				[Barcode]=cast(isnull([7/1/2024],'''') as nvarchar(30)),
				[M1]=CAST(replace(replace(replace(replace([612],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
				[M2]=CAST(replace(replace(replace(replace([613],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
				[M3]=CAST(replace(replace(replace(replace([614],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
				[M4]=CAST(replace(replace(replace(replace([615],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
				[M5]=CAST(replace(replace(replace(replace([616],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
				[M6]=CAST(replace(replace(replace(replace([617],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
				[M7]=CAST(replace(replace(replace(replace([72],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
				[M8]=CAST(replace(replace(replace(replace([82],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
				[M9]=CAST(replace(replace(replace(replace([92],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
				[M10]=CAST(replace(replace(replace(replace([102],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
				[M11]=CAST(replace(replace(replace(replace([112],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
				[M12]=CAST(replace(replace(replace(replace([122],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
				[M13]=CAST(replace(replace(replace(replace([618],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
				[M14]=CAST(replace(replace(replace(replace([619],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
				[M15]=CAST(replace(replace(replace(replace([620],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
				[M16]=CAST(replace(replace(replace(replace([621],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
				[M17]=CAST(replace(replace(replace(replace([622],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
				[M18]=CAST(replace(replace(replace(replace([623],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
				[M19]=CAST(replace(replace(replace(replace([73],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
				[M20]=CAST(replace(replace(replace(replace([83],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
				[M21]=CAST(replace(replace(replace(replace([93],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
				[M22]=CAST(replace(replace(replace(replace([103],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
				[M23]=CAST(replace(replace(replace(replace([113],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0)),
				[M24]=CAST(replace(replace(replace(replace([123],'','',''''),''-'',''0''),''('',''-''),'')'','''') AS NUMERIC(18,0))
			from '+@table_ALL+' t
			INNER join 
			(
				select DISTINCT
					Material,
					[Item Category Group],
					[Material Type]
				from link_33.sc1.dbo.MM_ZMR54OLD_Stg 
				where 
					[Sales  Org]=''V400'' 
				and [Item Category Group] = ''LUMF''
			) m on m.Material = TRIM(REPLACE(t.[F4] ,CHAR(9) , ''''))
			where 
				isnull([F1],'''')<>''''
			and isnull([F8],'''')=''LUMF''
			and isnull([F4],'''')<>''Active code''
			and ISNULL([F4],'''')<>''''
			and CHARINDEX(''ONLINE'',t.[Filename])>0
			and isnull([F16],'''') IN(''ECOM'')
		) as x '

		if @debug>0
		begin
			select @sql '@sql bundle online'
		end
		execute(@sql)
	end

	if @debug>0
	begin
		select @sql = 'select * from '+@tablename
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