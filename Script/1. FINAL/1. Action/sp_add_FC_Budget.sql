/*
	Declare
		@b_Success			Int,
		@c_errmsg			Nvarchar(250)

	exec sp_add_FC_Budget 'CPD','202502','B',@b_Success OUT,@c_errmsg OUT
	
	select @b_Success b_Success,@c_errmsg c_errmsg

	select * from FC_Trend_CPD_202502
	select * from FC_Trend_RSP_CPD where [FM_KEY]='202502'
*/

Alter proc sp_add_FC_Budget
	@Division			nvarchar(3),
	@FM_KEY				Nvarchar(6),
	@Type				nvarchar(10),--//B,PB,T
	@b_Success			Int				OUTPUT,     
	@c_errmsg			Nvarchar(250)	OUTPUT
	with encryption
AS
SET NOCOUNT ON
SET XACT_ABORT ON
--BEGIN TRAN
BEGIN TRY
	DECLARE   
		 @debug					int=0
		,@sp_name				Nvarchar(100)
		,@n_continue			Int
		,@USERS					Nvarchar(50)
		,@MODIFILED				Datetime
		,@n_err					int
		,@sql					nvarchar(max) = ''
		,@DbName NVARCHAR(20)
	
	Declare
		@b_Success1			Int,
		@c_errmsg1			Nvarchar(250)=''

	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_add_FC_Budget',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	select @debug=debug from fnc_debug('FC')
	--select @debug=1

	declare @Monthfc				nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from V_FC_FM_Table

	declare @Current_key date = cast(left(@FM_KEY,4)+'-'+substring(@FM_KEY,5,2)+'-01' as date)
	declare @currentYear nvarchar(4) = ''
	select @currentYear = year(@Current_key)

	declare @rowcount1 int = 0
	declare @tmp table(id int identity(1,1), [Month_Desc] nvarchar(5),[Year] nvarchar(4))

	-- Get the environment configuration
	SELECT @DbName = CASE 
		WHEN Value = 'Production' THEN 'master.dbo'
		ELSE 'master_UAT'
	END
	FROM EnvironmentConfig
	WHERE Name = 'Current_Environment'

	if @debug>0
	begin
		select 'sp_add_FC_Budget_Tmp'
	end
	if @n_continue=1
	begin
		if @DbName = 'master.dbo'
			exec link_37.master.dbo.sp_add_FC_Budget_Tmp @Division,@FM_KEY,@Type,@b_Success1 OUT,@c_errmsg1 OUT
		else
			exec link_37.master_UAT.dbo.sp_add_FC_Budget_Tmp @Division,@FM_KEY,@Type,@b_Success1 OUT,@c_errmsg1 OUT
		if @b_Success1=0
		begin
			select @n_continue = 3, @c_errmsg = @c_errmsg1
		end
	end

	BEGIN TRAN
	IF @debug>0
	BEGIN
		SELECT 'INSERT UNIT'
	END
	if @n_continue =1
	begin
		declare @tablename_tmp		nvarchar(50)= ''
		declare @tablename			nvarchar(50)= ''
		declare @tablename_RSP		nvarchar(50)= ''
		
		if @Type = 'B'
		begin
			select @tablename_tmp = 'FC_Budget_'+@Division+'_Tmp'
		end
		else if @Type = 'PB'
		begin
			select @tablename_tmp = 'FC_Pre_Budget_'+@Division+'_Tmp'	
		end
		else if @Type = 'T'
		begin
			select @tablename_tmp = 'FC_Trend_'+@Division+'_Tmp'	
		end
		
		select @tablename = REPLACE(@tablename_tmp,'_Tmp',''+@Monthfc)
		if @debug>0
		begin
			select @tablename '@tablename'
		end
		if @Division IN('CPD','LDB','LLD','PPD')
		begin
			select @tablename_RSP=replace(@tablename,@Division+@Monthfc,+'RSP_'+@Division)
			if @debug>0
			begin
				select @tablename_RSP '@tablename RSP'
			end
		end
		
		if exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID(@tablename) AND type in (N'U')
		)
		begin
			select @sql = 'Drop table '+@tablename
			if @debug>0
			begin
				select @sql '@sql Drop table'
			end
			execute(@sql)
		end
		
		if @Division='LDB'
		begin
			select @sql = 
			'select
				[Filename],
				[FM_KEY],
				[Type],
				[Version],
				[CHANNEL],
				[SIGNATURE],
				[Item Category Group],
				[EAN Original],
				[EAN],
				[Ref Code],
				[SUB-GROUP]=m.[SUB GROUP/ Brand],
				[Time series],
				[M1]=sum([M1]),
				[M2]=sum([M2]),
				[M3]=sum([M3]),
				[M4]=sum([M4]),
				[M5]=sum([M5]),
				[M6]=sum([M6]),
				[M7]=sum([M7]),
				[M8]=sum([M8]),
				[M9]=sum([M9]),
				[M10]=sum([M10]),
				[M11]=sum([M11]),
				[M12]=sum([M12])
				into '+@tablename+'
			from
			(
				Select
					[Filename],
					[FM_KEY]='''+@FM_KEY+''',
					[Type],
					[Version],
					[CHANNEL],
					[SIGNATURE],
					[Item Category Group]=m.[Item Category Group],
					[EAN Original]=[BFL Code],
					[EAN]=[BFL Code],
					[Ref Code]=[BFL Code],
					[Time series]=''1. Baseline Qty'',
					[M1]=ISNULL([M1],0),			
					[M2]=ISNULL([M2],0),
					[M3]=ISNULL([M3],0),
					[M4]=ISNULL([M4],0),
					[M5]=ISNULL([M5],0),
					[M6]=ISNULL([M6],0),
					[M7]=ISNULL([M7],0),
					[M8]=ISNULL([M8],0),
					[M9]=ISNULL([M9],0),
					[M10]=ISNULL([M10],0),
					[M11]=ISNULL([M11],0),
					[M12]=ISNULL([M12],0)
				from '+@DbName+'.'+@tablename_tmp+' b 
				inner JOIN
				(
					select DISTINCT
						[EAN / UPC],
						[Item Category Group]
					from SC1.dbo.MM_ZMR54OLD_Stg
					where 
						[Sales  Org]=''V400''
					and [Item Category Group] NOT IN(''LUMF'')
				) m ON m.[EAN / UPC]=b.[BFL Code]
				UNION ALL
				Select
					[Filename],
					[FM_KEY] = '''+@FM_KEY+''',
					[Type],
					[Version],
					[CHANNEL],
					[SIGNATURE],
					[Item Category Group]=m.[Item Category Group],
					[EAN Original]=b.[BFL Code],
					[EAN]=z.Barcode_Component,
					[Ref Code]=[BFL Code],
					[Time series]=''3. Promo Qty(BOM)'',
					[M1]=ISNULL(b.[M1],0)*z.Qty,			
					[M2]=ISNULL(b.[M2],0)*z.Qty,
					[M3]=ISNULL(b.[M3],0)*z.Qty,
					[M4]=ISNULL(b.[M4],0)*z.Qty,
					[M5]=ISNULL(b.[M5],0)*z.Qty,
					[M6]=ISNULL(b.[M6],0)*z.Qty,
					[M7]=ISNULL(b.[M7],0)*z.Qty,
					[M8]=ISNULL(b.[M8],0)*z.Qty,
					[M9]=ISNULL(b.[M9],0)*z.Qty,
					[M10]=ISNULL(b.[M10],0)*z.Qty,
					[M11]=ISNULL(b.[M11],0)*z.Qty,
					[M12]=ISNULL(b.[M12],0)*z.Qty
				from '+@DbName+'.'+@tablename_tmp+' b 
				inner JOIN
				(
					select DISTINCT
						[EAN / UPC],
						[Item Category Group]
					from SC1.dbo.MM_ZMR54OLD_Stg
					where 
						[Sales  Org]=''V400''
					and [Item Category Group] IN(''LUMF'')
				) m ON m.[EAN / UPC] = b.[BFL Code] 
				inner join
				(
					select
						*
					from V_ZMR32
					where Division = '''+@Division+'''
				) z on z.Barcode_Bom =m.[EAN / UPC]
			) as x
			left JOIN
			(
				select DISTINCT
					[EAN / UPC]=[Barcode],
					[SUB GROUP/ Brand]
				from fnc_SubGroupMaster('''+@Division+''',''full'')
			) m ON m.[EAN / UPC] = x.[EAN]
			group by
				[Filename],
				[FM_KEY],
				[Type],
				[Version],
				[CHANNEL],
				[SIGNATURE],
				[Item Category Group],
				[EAN Original],
				[EAN],
				[Ref Code],
				[SUB GROUP/ Brand],
				[Time series] '
		end
		else if @Division='CPD'
		begin
			select @sql = 
			'Select
				[Filename],
				[FM_KEY]='''+@FM_KEY+''',
				[Type],
				[Version],
				[CHANNEL],
				[SIGNATURE],
				[Item Category Group]=s.[Item Category Group],
				[EAN Original]='''',
				[EAN]='''',
				[Ref Code]=[BFL Code],
				[SUB-GROUP]=s.[SUB GROUP/ Brand],
				[Time series]=''1. Baseline Qty'',
				[M1]=ISNULL([M1],0),			
				[M2]=ISNULL([M2],0),
				[M3]=ISNULL([M3],0),
				[M4]=ISNULL([M4],0),
				[M5]=ISNULL([M5],0),
				[M6]=ISNULL([M6],0),
				[M7]=ISNULL([M7],0),
				[M8]=ISNULL([M8],0),
				[M9]=ISNULL([M9],0),
				[M10]=ISNULL([M10],0),
				[M11]=ISNULL([M11],0),
				[M12]=ISNULL([M12],0)
				into '+@tablename+'
			from '+@DbName+'.'+@tablename_tmp+' b
			left JOIN
			(
				select DISTINCT
					[Item Category Group],
					[SUB GROUP/ Brand]
				from fnc_SubGroupMaster('''+@Division+''',''full'')
				where [Item Category Group]<>''LUMF''
			) s ON s.[SUB GROUP/ Brand]=b.[Forecasting Line] '
		end
		else if @Division='LLD'
		begin
			select @sql = 
			'Select
				[Filename],
				[FM_KEY] = '''+@FM_KEY+''',
				[Type],
				[Version],
				[CHANNEL],
				[SIGNATURE],
				[Item Category Group]=s.[Item Category Group],
				[EAN Original]='''',
				[EAN]='''',
				[Ref Code]=[BFL Code],
				[SUB-GROUP]=s.[SUB GROUP/ Brand],
				[Time series] = ''1. Baseline Qty'',
				[M1]=ISNULL([M1],0),			
				[M2]=ISNULL([M2],0),
				[M3]=ISNULL([M3],0),
				[M4]=ISNULL([M4],0),
				[M5]=ISNULL([M5],0),
				[M6]=ISNULL([M6],0),
				[M7]=ISNULL([M7],0),
				[M8]=ISNULL([M8],0),
				[M9]=ISNULL([M9],0),
				[M10]=ISNULL([M10],0),
				[M11]=ISNULL([M11],0),
				[M12]=ISNULL([M12],0)
				into '+@tablename+'
			from '+@DbName+'.'+@tablename_tmp+' b
			left JOIN
			(
				select distinct 
					[Item Category Group],
					[SUB GROUP/ Brand]
				from fnc_SubGroupMaster('''+@Division+''','''')
				where [Item Category Group]<>''LUMF''
			) s on s.[SUB GROUP/ Brand]=b.[Forecasting Line] '
		end
		else if @Division='PPD'
		begin
			select @sql = 
			'Select
				[Filename],
				[FM_KEY] = '''+@FM_KEY+''',
				[Type],
				[Version],
				[CHANNEL],
				[SIGNATURE],
				[Item Category Group]=s.[Item Category Group],
				[EAN Original]='''',
				[EAN]='''',
				[Ref Code]=[BFL Code],
				[SUB-GROUP]=s.[SUB GROUP/ Brand],
				[Time series] = ''1. Baseline Qty'',
				[M1]=ISNULL([M1],0),			
				[M2]=ISNULL([M2],0),
				[M3]=ISNULL([M3],0),
				[M4]=ISNULL([M4],0),
				[M5]=ISNULL([M5],0),
				[M6]=ISNULL([M6],0),
				[M7]=ISNULL([M7],0),
				[M8]=ISNULL([M8],0),
				[M9]=ISNULL([M9],0),
				[M10]=ISNULL([M10],0),
				[M11]=ISNULL([M11],0),
				[M12]=ISNULL([M12],0)
				into '+@tablename+'
			from '+@DbName+'.'+@tablename_tmp+' b
			left JOIN
			(
				select distinct 
					[Item Category Group],
					[SUB GROUP/ Brand]
				from fnc_SubGroupMaster('''+@Division+''','''')
				where [Item Category Group]<>''LUMF''
			) s on s.[SUB GROUP/ Brand]=b.[Forecasting Line] '
		end

		if @debug>0
		begin
			select @sql '@sql Insert table'
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
	IF @debug>0
	BEGIN
		SELECT 'INSERT RSP'
	END
	if @n_continue=1
	begin
		--insert rsp cpd
		if @Division IN('CPD','LDB','LLD','PPD')
		begin
			if exists
			(
				SELECT * 
				FROM sys.objects 
				WHERE object_id = OBJECT_ID(@tablename_RSP) AND type in (N'U')
			)
			begin
				select @sql = 'Delete '+@tablename_RSP+' where [FM_KEY]='''+@FM_KEY+''' '
				if @debug>0
				begin
					select @sql '@sql delete table'
				end
				execute(@sql)
			end
			else
			begin
				select @sql=
				'create table '+@tablename_RSP+
				'(
					[Filename]					nvarchar(500) null,
					[FM_KEY]					nvarchar(6) null,
					[Type]						nvarchar(10) null,
					[Version]					nvarchar(4) null,
					[CHANNEL]					nvarchar(10) null,
					[SIGNATURE]					nvarchar(50) null,
					[Item Category Group]		nvarchar(20) null,
					[EAN Original]				nvarchar(50) null,
					[EAN]						nvarchar(50) null,
					[Ref Code]					nvarchar(50) null,
					[SUB-GROUP]					nvarchar(500) null,
					[Time series]				nvarchar(20) null,
					[M1 RSP]					numeric(18,0) default 0,
					[M2 RSP]					numeric(18,0) default 0,
					[M3 RSP]					numeric(18,0) default 0,
					[M4 RSP]					numeric(18,0) default 0,
					[M5 RSP]					numeric(18,0) default 0,
					[M6 RSP]					numeric(18,0) default 0,
					[M7 RSP]					numeric(18,0) default 0,
					[M8 RSP]					numeric(18,0) default 0,
					[M9 RSP]					numeric(18,0) default 0,
					[M10 RSP]					numeric(18,0) default 0,
					[M11 RSP]					numeric(18,0) default 0,
					[M12 RSP]					numeric(18,0) default 0
				)'
				if @debug>0
				begin
					select @sql 'create table'
				end
				execute(@sql)
			end
			select @sql = 
			'INSERT INTO '+@tablename_RSP+'
			(
				[Filename],
				[FM_KEY],
				[Type],
				[Version],
				[CHANNEL],
				[SIGNATURE],
				[Item Category Group],
				[EAN Original],
				[EAN],
				[Ref Code],
				[SUB-GROUP],
				[Time series],
				[M1 RSP],
				[M2 RSP],
				[M3 RSP],
				[M4 RSP],
				[M5 RSP],
				[M6 RSP],
				[M7 RSP],
				[M8 RSP],
				[M9 RSP],
				[M10 RSP],
				[M11 RSP],
				[M12 RSP]
			)
			Select
				[Filename],
				[FM_KEY] = '''+@FM_KEY+''',
				[Type],
				[Version],
				[CHANNEL],
				[SIGNATURE],
				[Item Category Group]='''',
				[EAN Original]='''',
				[EAN]='''',
				[Ref Code]=[BFL Code],
				[SUB-GROUP]=[Forecasting Line],
				[Time series]=''1. Baseline Qty'',
				[M1 RSP]=isnull([M1_VALUE],0),			
				[M2 RSP]=ISNULL([M2_VALUE],0),
				[M3 RSP]=ISNULL([M3_VALUE],0),
				[M4 RSP]=ISNULL([M4_VALUE],0),
				[M5 RSP]=ISNULL([M5_VALUE],0),
				[M6 RSP]=ISNULL([M6_VALUE],0),
				[M7 RSP]=ISNULL([M7_VALUE],0),
				[M8 RSP]=ISNULL([M8_VALUE],0),
				[M9 RSP]=ISNULL([M9_VALUE],0),
				[M10 RSP]=ISNULL([M10_VALUE],0),
				[M11 RSP]=ISNULL([M11_VALUE],0),
				[M12 RSP]=ISNULL([M12_VALUE],0)			
			from '+@DbName+'.'+@tablename_tmp+' b '	

			if @debug>0
			begin
				select @sql 'Insert into table'
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