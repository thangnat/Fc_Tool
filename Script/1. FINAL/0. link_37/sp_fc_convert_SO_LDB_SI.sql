/*
	Declare 
		@b_Success			Int,
		@c_errmsg			Nvarchar(250)

	exec sp_fc_convert_SO_LDB_SI 'LDB','202407',@b_Success OUT, @c_errmsg OUT

	select @b_Success b_Success, @c_errmsg c_errmsg

	select * from FC_SO_OPTIMUS_NORMAL_LDB_ALL_Tmp
	select * from FC_SI_OPTIMUS_bundle_LDB_Tmp_OK
	select * from FC_SI_OPTIMUS_NORMAL_LDB_Tmp_OK
	
*/

Create or Alter proc sp_fc_convert_SO_LDB_SI
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
		 @debug					int=0
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
		@sp_name = 'sp_fc_convert_SO_LDB_SI',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()
	declare @SharefolderPath nvarchar(500)
	select @SharefolderPath = Value from [SC2].[dbo].[EnvironmentConfig] where Name = 'Sharefolder_SAP_Dir'

	declare @startyear int = 0
	select @startyear = cast(left(@FM_KEY,4) as int)

	declare @Monthfc				nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from link_33.sc2.dbo.V_FC_FM_Table

	declare @table_ALL nvarchar(200)=''
	select @table_ALL='FC_SO_OPTIMUS_NORMAL_'+@division+@Monthfc+'_ALL_Tmp'

	declare @tablename nvarchar(200) = ''
	select @tablename = 'FC_SI_OPTIMUS_NORMAL_'+@division+@Monthfc+'_Tmp_OK'

	declare @tablename_Bundle nvarchar(200) = ''
	select @tablename_Bundle = 'FC_SI_OPTIMUS_PROMO_BOM_'+@division+@Monthfc+'_Tmp_OK'

	if @n_continue = 1
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
				select @sql 'drop table single optimus'
			end
			execute(@sql)
		end
		select @sql =
				'Create table '+@tablename+
				'(					
					Filename			nvarchar(1000) null,
					[Material]			nvarchar(20) null,
					[Product Type]		nvarchar(20) null,
					[SUB GROUP/ Brand]	nvarchar(500) null,
					[Channel]			nvarchar(10) null,
					[Time series]		nvarchar(30) null,
					[Y0 (u) M1]			int default 0,
					[Y0 (u) M2]			int default 0,
					[Y0 (u) M3]			int default 0,
					[Y0 (u) M4]			int default 0,
					[Y0 (u) M5]			int default 0,
					[Y0 (u) M6]			int default 0,
					[Y0 (u) M7]			int default 0,
					[Y0 (u) M8]			int default 0,
					[Y0 (u) M9]			int default 0,
					[Y0 (u) M10]		int default 0,
					[Y0 (u) M11]		int default 0,
					[Y0 (u) M12]		int default 0,
					[Y+1 (u) M1]		int default 0,
					[Y+1 (u) M2]		int default 0,
					[Y+1 (u) M3]		int default 0,
					[Y+1 (u) M4]		int default 0,
					[Y+1 (u) M5]		int default 0,
					[Y+1 (u) M6]		int default 0,
					[Y+1 (u) M7]		int default 0,
					[Y+1 (u) M8]		int default 0,
					[Y+1 (u) M9]		int default 0,
					[Y+1 (u) M10]		int default 0,
					[Y+1 (u) M11]		int default 0,
					[Y+1 (u) M12]		int default 0
				)'
		if @debug>0
		begin
			select @sql 'create table single optimus'
		end
		execute(@sql)
		--Insert single OFFLINE
		select @sql = '
		INSERT INTO '+@tablename+'
		select
			Filename=t.[Filename],
			[Material]=TRIM(REPLACE(t.[F4] ,CHAR(9) , '''')),
			[Product Type]=m.[Material Type],
			[SUB GROUP/ Brand]='''',
			[Channel]=[Channel],
			[Time series]=case when Channel2=''medical'' then ''7.2. BP Unit Medical'' else ''7.1. BP Unit Offline'' end,
			[Y0 (u) M1]=CAST(replace(replace(replace(replace([636],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y0 (u) M2]=CAST(replace(replace(replace(replace([637],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y0 (u) M3]=CAST(replace(replace(replace(replace([638],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y0 (u) M4]=CAST(replace(replace(replace(replace([639],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y0 (u) M5]=CAST(replace(replace(replace(replace([640],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y0 (u) M6]=CAST(replace(replace(replace(replace([641],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y0 (u) M7]=CAST(replace(replace(replace(replace([76],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y0 (u) M8]=CAST(replace(replace(replace(replace([86],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y0 (u) M9]=CAST(replace(replace(replace(replace([96],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y0 (u) M10]=CAST(replace(replace(replace(replace([106],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y0 (u) M11]=CAST(replace(replace(replace(replace([116],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y0 (u) M12]=CAST(replace(replace(replace(replace([126],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M1]=CAST(replace(replace(replace(replace([642],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M2]=CAST(replace(replace(replace(replace([643],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M3]=CAST(replace(replace(replace(replace([644],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M4]=CAST(replace(replace(replace(replace([645],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M5]=CAST(replace(replace(replace(replace([646],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M6]=CAST(replace(replace(replace(replace([647],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M7]=CAST(replace(replace(replace(replace([77],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M8]=CAST(replace(replace(replace(replace([87],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M9]=CAST(replace(replace(replace(replace([97],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M10]=CAST(replace(replace(replace(replace([107],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M11]=CAST(replace(replace(replace(replace([117],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M12]=CAST(replace(replace(replace(replace([127],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT)
		from FC_SO_OPTIMUS_NORMAL_'+@division+@Monthfc+'_ALL_Tmp t
		Inner join 
		(
			select DISTINCT
				[Material],
				[Item Category Group],
				[Material Type]
			from link_33.sc1.dbo.MM_ZMR54OLD_Stg 
			where 
				[Sales  Org]=''V400'' 
			and [Item Category Group]<>''LUMF''
		) m on m.Material = TRIM(REPLACE(t.[F4] ,CHAR(9) , ''''))
		where 
			isnull([F1],'''')<>''''
		and isnull([F4],'''')<>''Active code''
		and ISNULL([F4],'''')<>''''
		and CHARINDEX(''OFFLINE'',t.[Filename])>0
		and isnull([F16],'''') NOT IN(''ECOM'',''MEDICAL'',''OFFLINE'',''TOTAL ACD'') '			

		--select * from FC_SO_OPTIMUS_NORMAL_LDB_ALL_Tmp t
		if @debug>0
		begin
			select @sql '@sql insert single offline'
		end
		execute(@sql)

		--Insert single MEDICAL
		select @sql = '
		INSERT INTO '+@tablename+'
		select
			Filename=t.[Filename],
			[Material]=TRIM(REPLACE(t.[F4] ,CHAR(9) , '''')),
			[Product Type]=m.[Material Type],
			[SUB GROUP/ Brand]='''',
			[Channel]=[Channel],
			[Time series]=case when Channel2=''medical'' then ''7.2. BP Unit Medical'' else ''7.1. BP Unit Offline'' end,
			[Y0 (u) M1]=CAST(replace(replace(replace(replace([636],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y0 (u) M2]=CAST(replace(replace(replace(replace([637],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y0 (u) M3]=CAST(replace(replace(replace(replace([638],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y0 (u) M4]=CAST(replace(replace(replace(replace([639],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y0 (u) M5]=CAST(replace(replace(replace(replace([640],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y0 (u) M6]=CAST(replace(replace(replace(replace([641],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y0 (u) M7]=CAST(replace(replace(replace(replace([76],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y0 (u) M8]=CAST(replace(replace(replace(replace([86],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y0 (u) M9]=CAST(replace(replace(replace(replace([96],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y0 (u) M10]=CAST(replace(replace(replace(replace([106],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y0 (u) M11]=CAST(replace(replace(replace(replace([116],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y0 (u) M12]=CAST(replace(replace(replace(replace([126],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M1]=CAST(replace(replace(replace(replace([642],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M2]=CAST(replace(replace(replace(replace([643],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M3]=CAST(replace(replace(replace(replace([644],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M4]=CAST(replace(replace(replace(replace([645],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M5]=CAST(replace(replace(replace(replace([646],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M6]=CAST(replace(replace(replace(replace([647],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M7]=CAST(replace(replace(replace(replace([77],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M8]=CAST(replace(replace(replace(replace([87],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M9]=CAST(replace(replace(replace(replace([97],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M10]=CAST(replace(replace(replace(replace([107],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M11]=CAST(replace(replace(replace(replace([117],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M12]=CAST(replace(replace(replace(replace([127],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT)
		from '+@table_ALL+' t
		Inner join 
		(
			select DISTINCT
				[Material],
				[Item Category Group],
				[Material Type]
			from link_33.sc1.dbo.MM_ZMR54OLD_Stg 
			where 
				[Sales  Org]=''V400'' 
			and [Item Category Group]<>''LUMF''
		) m on m.Material = TRIM(REPLACE(t.[F4] ,CHAR(9) , ''''))
		where 
			isnull([F1],'''')<>''''
		and isnull([F4],'''')<>''Active code''
		and ISNULL([F4],'''')<>''''
		and CHARINDEX(''MEDICAL'',t.[Filename])>0
		and isnull([F16],'''') IN(''MEDICAL'') '			

		--select * from FC_SO_OPTIMUS_NORMAL_LDB_ALL_Tmp t
		if @debug>0
		begin
			select @sql '@sql single medical'
		end
		execute(@sql)

		--Insert single ONLINE
		select @sql = '
		INSERT INTO '+@tablename+'
		select
			Filename=t.[Filename],
			[Material]=TRIM(REPLACE(t.[F4] ,CHAR(9) , '''')),
			[Product Type]=m.[Material Type],
			[SUB GROUP/ Brand]='''',
			[Channel]=[Channel],
			[Time series]=case when Channel2=''medical'' then ''7.2. BP Unit Medical'' else ''7.1. BP Unit Offline'' end,
			[Y0 (u) M1]=CAST(replace(replace(replace(replace([636],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y0 (u) M2]=CAST(replace(replace(replace(replace([637],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y0 (u) M3]=CAST(replace(replace(replace(replace([638],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y0 (u) M4]=CAST(replace(replace(replace(replace([639],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y0 (u) M5]=CAST(replace(replace(replace(replace([640],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y0 (u) M6]=CAST(replace(replace(replace(replace([641],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y0 (u) M7]=CAST(replace(replace(replace(replace([76],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y0 (u) M8]=CAST(replace(replace(replace(replace([86],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y0 (u) M9]=CAST(replace(replace(replace(replace([96],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y0 (u) M10]=CAST(replace(replace(replace(replace([106],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y0 (u) M11]=CAST(replace(replace(replace(replace([116],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y0 (u) M12]=CAST(replace(replace(replace(replace([126],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M1]=CAST(replace(replace(replace(replace([642],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M2]=CAST(replace(replace(replace(replace([643],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M3]=CAST(replace(replace(replace(replace([644],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M4]=CAST(replace(replace(replace(replace([645],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M5]=CAST(replace(replace(replace(replace([646],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M6]=CAST(replace(replace(replace(replace([647],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M7]=CAST(replace(replace(replace(replace([77],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M8]=CAST(replace(replace(replace(replace([87],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M9]=CAST(replace(replace(replace(replace([97],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M10]=CAST(replace(replace(replace(replace([107],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M11]=CAST(replace(replace(replace(replace([117],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M12]=CAST(replace(replace(replace(replace([127],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT)
		from '+@table_ALL+' t
		Inner join 
		(
			select DISTINCT
				[Material],
				[Item Category Group],
				[Material Type]
			from link_33.sc1.dbo.MM_ZMR54OLD_Stg 
			where 
				[Sales  Org]=''V400'' 
			and [Item Category Group]<>''LUMF''
		) m on m.Material = TRIM(REPLACE(t.[F4] ,CHAR(9) , ''''))
		where 
			isnull([F1],'''')<>''''
		and isnull([F4],'''')<>''Active code''
		and ISNULL([F4],'''')<>''''
		and CHARINDEX(''ONLINE'',t.[Filename])>0
		and isnull([F16],'''') IN(''ECOM'') '			

		--select * from FC_SO_OPTIMUS_NORMAL_LDB_ALL_Tmp t
		if @debug>0
		begin
			select @sql '@sql single online-ecom'
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
	if @n_continue=1
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
				select @sql 'drop table bom'
			end
			execute(@sql)
		end
		select @sql = 
				'Create table '+@tablename_Bundle+
				'(
					Filename			nvarchar(1000) null,
					[Material]			nvarchar(20) null,
					[Product Type]		nvarchar(20) null,
					[SUB GROUP/ Brand]	nvarchar(500) null,
					[Channel]			nvarchar(10) null,
					[Time series]		nvarchar(30) null,
					[Y0 (u) M1]			int default 0,
					[Y0 (u) M2]			int default 0,
					[Y0 (u) M3]			int default 0,
					[Y0 (u) M4]			int default 0,
					[Y0 (u) M5]			int default 0,
					[Y0 (u) M6]			int default 0,
					[Y0 (u) M7]			int default 0,
					[Y0 (u) M8]			int default 0,
					[Y0 (u) M9]			int default 0,
					[Y0 (u) M10]		int default 0,
					[Y0 (u) M11]		int default 0,
					[Y0 (u) M12]		int default 0,
					[Y+1 (u) M1]		int default 0,
					[Y+1 (u) M2]		int default 0,
					[Y+1 (u) M3]		int default 0,
					[Y+1 (u) M4]		int default 0,
					[Y+1 (u) M5]		int default 0,
					[Y+1 (u) M6]		int default 0,
					[Y+1 (u) M7]		int default 0,
					[Y+1 (u) M8]		int default 0,
					[Y+1 (u) M9]		int default 0,
					[Y+1 (u) M10]		int default 0,
					[Y+1 (u) M11]		int default 0,
					[Y+1 (u) M12]		int default 0
				)'
		if @debug>0
		begin
			select @sql 'create table bom optimus'
		end
		execute(@sql)

		--insert bundle OFFLINE
		select @sql = '
		INSERT INTO '+@tablename_Bundle+'
		select
			Filename=t.[Filename],
			[Material]=TRIM(REPLACE(t.[F4] ,CHAR(9) , '''')),
			[Product Type]=m.[Material Type],
			[SUB GROUP/ Brand]='''',
			[Channel]=[Channel],
			[Time series]=case when Channel2=''medical'' then ''7.2. BP Unit Medical'' else ''7.1. BP Unit Offline'' end,
			[Y0 (u) M1]=CAST(replace(replace(replace(replace([636],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y0 (u) M2]=CAST(replace(replace(replace(replace([637],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y0 (u) M3]=CAST(replace(replace(replace(replace([638],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y0 (u) M4]=CAST(replace(replace(replace(replace([639],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y0 (u) M5]=CAST(replace(replace(replace(replace([640],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y0 (u) M6]=CAST(replace(replace(replace(replace([641],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y0 (u) M7]=CAST(replace(replace(replace(replace([76],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y0 (u) M8]=CAST(replace(replace(replace(replace([86],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y0 (u) M9]=CAST(replace(replace(replace(replace([96],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y0 (u) M10]=CAST(replace(replace(replace(replace([106],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y0 (u) M11]=CAST(replace(replace(replace(replace([116],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y0 (u) M12]=CAST(replace(replace(replace(replace([126],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M1]=CAST(replace(replace(replace(replace([642],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M2]=CAST(replace(replace(replace(replace([643],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M3]=CAST(replace(replace(replace(replace([644],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M4]=CAST(replace(replace(replace(replace([645],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M5]=CAST(replace(replace(replace(replace([646],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M6]=CAST(replace(replace(replace(replace([647],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M7]=CAST(replace(replace(replace(replace([77],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M8]=CAST(replace(replace(replace(replace([87],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M9]=CAST(replace(replace(replace(replace([97],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M10]=CAST(replace(replace(replace(replace([107],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M11]=CAST(replace(replace(replace(replace([117],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M12]=CAST(replace(replace(replace(replace([127],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT)
		from '+@table_ALL+' t
		Inner join 
		(
			select DISTINCT
				[Material],
				[Item Category Group],
				[Material Type]
			from link_33.sc1.dbo.MM_ZMR54OLD_Stg 
			where 
				[Sales  Org]=''V400'' 
			and [Item Category Group]=''LUMF''
		) m on m.Material = TRIM(REPLACE(t.[F4] ,CHAR(9) , ''''))
		where 
			isnull([F1],'''')<>''''
		and isnull([F4],'''')<>''Active code''
		AND ISNULL([F4],'''')<>''''
		and CHARINDEX(''OFFLINE'',t.[Filename])>0
		and isnull([F16],'''') NOT IN(''ECOM'',''MEDICAL'',''OFFLINE'',''TOTAL ACD'') '

		if @debug>0
		begin
			select @sql '@sql insert bom offline'
		end
		execute(@sql)

		--insert bundle MEDICAL
		select @sql = '
		INSERT INTO '+@tablename_Bundle+'
		select
			Filename=t.[Filename],
			[Material]=TRIM(REPLACE(t.[F4] ,CHAR(9) , '''')),
			[Product Type]=m.[Material Type],
			[SUB GROUP/ Brand]='''',
			[Channel]=[Channel],
			[Time series]=case when Channel2=''medical'' then ''7.2. BP Unit Medical'' else ''7.1. BP Unit Offline'' end,
			[Y0 (u) M1]=CAST(replace(replace(replace(replace([636],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y0 (u) M2]=CAST(replace(replace(replace(replace([637],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y0 (u) M3]=CAST(replace(replace(replace(replace([638],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y0 (u) M4]=CAST(replace(replace(replace(replace([639],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y0 (u) M5]=CAST(replace(replace(replace(replace([640],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y0 (u) M6]=CAST(replace(replace(replace(replace([641],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y0 (u) M7]=CAST(replace(replace(replace(replace([76],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y0 (u) M8]=CAST(replace(replace(replace(replace([86],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y0 (u) M9]=CAST(replace(replace(replace(replace([96],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y0 (u) M10]=CAST(replace(replace(replace(replace([106],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y0 (u) M11]=CAST(replace(replace(replace(replace([116],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y0 (u) M12]=CAST(replace(replace(replace(replace([126],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M1]=CAST(replace(replace(replace(replace([642],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M2]=CAST(replace(replace(replace(replace([643],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M3]=CAST(replace(replace(replace(replace([644],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M4]=CAST(replace(replace(replace(replace([645],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M5]=CAST(replace(replace(replace(replace([646],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M6]=CAST(replace(replace(replace(replace([647],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M7]=CAST(replace(replace(replace(replace([77],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M8]=CAST(replace(replace(replace(replace([87],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M9]=CAST(replace(replace(replace(replace([97],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M10]=CAST(replace(replace(replace(replace([107],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M11]=CAST(replace(replace(replace(replace([117],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M12]=CAST(replace(replace(replace(replace([127],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT)
		from '+@table_ALL+' t
		Inner join 
		(
			select DISTINCT
				[Material],
				[Item Category Group],
				[Material Type]
			from link_33.sc1.dbo.MM_ZMR54OLD_Stg 
			where 
				[Sales  Org]=''V400'' 
			and [Item Category Group]=''LUMF''
		) m on m.Material = TRIM(REPLACE(t.[F4] ,CHAR(9) , ''''))
		where 
			isnull([F1],'''')<>''''
		and isnull([F4],'''')<>''Active code''
		and ISNULL([F4],'''')<>''''
		and CHARINDEX(''MEDICAL'',t.[Filename])>0
		and isnull([F16],'''') IN(''MEDICAL'') '

		if @debug>0
		begin
			select @sql '@sql insert bom medical'
		end
		execute(@sql)
		
		--insert bundle online
		select @sql = '
		INSERT INTO '+@tablename_Bundle+'
		select
			Filename=t.[Filename],
			[Material]=TRIM(REPLACE(t.[F4] ,CHAR(9) , '''')),
			[Product Type]=m.[Material Type],
			[SUB GROUP/ Brand]='''',
			[Channel]=[Channel],
			[Time series]=case when Channel2=''medical'' then ''7.2. BP Unit Medical'' else ''7.1. BP Unit Offline'' end,
			[Y0 (u) M1]=CAST(replace(replace(replace(replace([636],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y0 (u) M2]=CAST(replace(replace(replace(replace([637],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y0 (u) M3]=CAST(replace(replace(replace(replace([638],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y0 (u) M4]=CAST(replace(replace(replace(replace([639],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y0 (u) M5]=CAST(replace(replace(replace(replace([640],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y0 (u) M6]=CAST(replace(replace(replace(replace([641],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y0 (u) M7]=CAST(replace(replace(replace(replace([76],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y0 (u) M8]=CAST(replace(replace(replace(replace([86],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y0 (u) M9]=CAST(replace(replace(replace(replace([96],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y0 (u) M10]=CAST(replace(replace(replace(replace([106],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y0 (u) M11]=CAST(replace(replace(replace(replace([116],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y0 (u) M12]=CAST(replace(replace(replace(replace([126],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M1]=CAST(replace(replace(replace(replace([642],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M2]=CAST(replace(replace(replace(replace([643],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M3]=CAST(replace(replace(replace(replace([644],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M4]=CAST(replace(replace(replace(replace([645],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M5]=CAST(replace(replace(replace(replace([646],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M6]=CAST(replace(replace(replace(replace([647],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M7]=CAST(replace(replace(replace(replace([77],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M8]=CAST(replace(replace(replace(replace([87],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M9]=CAST(replace(replace(replace(replace([97],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M10]=CAST(replace(replace(replace(replace([107],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M11]=CAST(replace(replace(replace(replace([117],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT),
			[Y+1 (u) M12]=CAST(replace(replace(replace(replace([127],'','',''0''),''-'',''0''),''('',''-''),'')'','''') AS INT)
		from '+@table_ALL+' t
		Inner join 
		(
			select DISTINCT
				[Material],
				[Item Category Group],
				[Material Type]
			from link_33.sc1.dbo.MM_ZMR54OLD_Stg 
			where 
				[Sales  Org]=''V400'' 
			and [Item Category Group]=''LUMF''
		) m on m.Material = TRIM(REPLACE(t.[F4] ,CHAR(9) , ''''))
		where 
			isnull([F1],'''')<>''''
		and isnull([F4],'''')<>''Active code''
		and ISNULL([F4],'''')<>''''
		and CHARINDEX(''ONLINE'',t.[Filename])>0
		and isnull([F16],'''') IN(''ECOM'') '

		if @debug>0
		begin
			select @sql '@sql insert bom online-ecom'
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