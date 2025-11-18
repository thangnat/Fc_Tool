/*
	
	Declare
		@b_Success			Int,
		@c_errmsg			Nvarchar(250)

	exec sp_Gen_BomHeader_Forecast_New 'LDB','202501','FDR',@b_Success OUT,@c_errmsg OUT
	
	select @b_Success b_Success,@c_errmsg c_errmsg
	--//list
	1. ''-->BOM_HEADER
	2. FDR
	3. FOC_TO_VP	 
	4. SO_OPTIMUS-->NO USE
	
	SELECT * FROM FC_BOMHEADER_LDB
	SELECT * FROM FC_BOMHEADER_FDR_<>Division>	
	select * from FC_FDR_FOC_TO_VP_<Division>
	
	select * from FC_SO_OPTIMUS_BomHeader_<Division>
	select * from FC_SO_OPTIMUS_BomHeader_CPD_202408

	select * from FC_BomHeader_CPD_202410
*/
Alter Proc sp_Gen_BomHeader_Forecast_New
	@Division		nvarchar(3),
	@FM_Key			nvarchar(6),
	@Type			nvarchar(10),
	@b_Success		Int				OUTPUT,     
	@c_errmsg		Nvarchar(250)	OUTPUT
	WITH ENCRYPTION
As
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
		,@sql					nvarchar(max) = ''

	Declare
		@b_Success1				Int,
		@c_errmsg1				Nvarchar(250)

	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_Gen_BomHeader_Forecast_New',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	select @debug=debug from fnc_Debug('FC')
	--select @debug=1

	declare @Monthfc		nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from V_FC_FM_Table

	declare @ListColumn_Pass				nvarchar(max) = ''
	declare @ListColumn_Pass_Update			nvarchar(max) = ''
	declare @ListColumn_Current				nvarchar(max) = ''
	declare @ListColumn_Current_BomQty		nvarchar(max) = ''
	declare @ListColumn_Current_Update		nvarchar(max) = ''

	DECLARE @table_FC_BomHeader nvarchar(100) = ''
	select @table_FC_BomHeader = 'FC_BomHeader_'+@Division+@Monthfc

	DECLARE @table_FC_SO_OPTIMUS_BomHeader nvarchar(100) = ''
	select @table_FC_SO_OPTIMUS_BomHeader = 'FC_SO_OPTIMUS_BomHeader_'+@Division+@Monthfc

	DECLARE @table_FC_BomHeader_FDR nvarchar(100) = ''
	select @table_FC_BomHeader_FDR = 'FC_BomHeader_FDR_'+@Division+@Monthfc
	
	DECLARE @table_FC_FDR_FOC_TO_VP nvarchar(100) = ''
	select @table_FC_FDR_FOC_TO_VP = 'FC_FDR_FOC_TO_VP_'+@Division+@Monthfc

	select @ListColumn_Pass = ListColumn from fn_FC_GetColHeader_Historical(@FM_Key,'y',0)
	if @debug>0
	begin
		select @ListColumn_Pass '@ListColumn_Pass'
		--select ListColumn_Pass = ListColumn from fn_FC_GetColHeader_Historical('202408','y',0)
	end
	select @ListColumn_Pass_Update = ListColumn from fn_FC_GetColHeader_Historical(@FM_Key,'b1',12)
	if @debug>0
	begin
		select @ListColumn_Pass_Update '@ListColumn_Pass_Update'
		--select ListColumn_Pass_Update = ListColumn from fn_FC_GetColHeader_Historical('202408','b1',12)
	end
	SELECT @ListColumn_Current = ListColumn FROM fn_FC_GetColheader_Current(@FM_Key,'NewCol','y')
	if @debug>0
	begin
		select @ListColumn_Current '@ListColumn_Current'
		--SELECT ListColumn_Current = ListColumn FROM fn_FC_GetColheader_Current('202408','NewCol','y')
	end
	SELECT @ListColumn_Current_BomQty = ListColumn FROM fn_FC_GetColheader_Current(@FM_Key,'BomheaderQty','b')
	if @debug>0
	begin
		select @ListColumn_Current_BomQty '@ListColumn_Current_BomQty'
		--SELECT ListColumn_Current_BomQty = ListColumn FROM fn_FC_GetColheader_Current('202408','BomheaderQty','b')
	end
	if @Type = 'SO_OPTIMUS'
	begin
		SELECT @ListColumn_Current_Update = ListColumn FROM fn_FC_GetColheader_Current(@FM_Key,'updateForecast','b1')
		if @debug>0
		begin
			select @ListColumn_Current_Update '@ListColumn_Current_Update'
			--SELECT ListColumn_Current_Update = ListColumn FROM fn_FC_GetColheader_Current('202408','updateForecast','b1')
		end 
	end
	else
	begin
		SELECT @ListColumn_Current_Update = ListColumn FROM fn_FC_GetColheader_Current(@FM_Key,'updateForecast','b1')
		if @debug>0
		begin
			select @ListColumn_Current_Update '@ListColumn_Current_Update'
			--SELECT ListColumn_Current_Update = ListColumn FROM fn_FC_GetColheader_Current('202408','updateForecast','b1')
		end
	end
	declare @listcolum_cong_pass	nvarchar(max)=''
	SELECT @listcolum_cong_pass = ListColumn FROM fn_FC_GetColHeader_Historical(@FM_Key,'b',999)
	--select listcolum_cong_pass=ListColumn from fn_FC_GetColHeader_Historical('202407','b',999)	

	declare @listcolumn_pass_plus nvarchar(max) = ''
	SELECT @listcolumn_pass_plus = ListColumn FROM fn_FC_GetColHeader_Historical(@FM_Key,'si',999)
	--SELECT listcolumn_pass_plus = ListColumn FROM fn_FC_GetColHeader_Historical('202408','si',999)

	declare @listcolumn_current_plus nvarchar(max) = ''
	SELECT @listcolumn_current_plus = ListColumn FROM fn_FC_GetColheader_Current(@FM_Key,'1. Baseline Qty_+','b')
	--SELECT listcolumn_current_plus = ListColumn FROM fn_FC_GetColheader_Current('202407','1. Baseline Qty_+','b')
	
	declare @listcolumn_ALL_plus nvarchar(max) = ''
	select @listcolumn_ALL_plus = @listcolumn_pass_plus+'+'+@listcolumn_current_plus
	--select listcolumn_ALL_plus = @listcolumn_pass_plus+'+'+@listcolumn_current_plus

	declare @list_product_type nvarchar(20)=''
	declare @ColumnRelationShip nvarchar(20)=''
	declare @ColumnCompare nvarchar(50)=''
	select 
		@list_product_type=[Product Type],
		@ColumnRelationShip=[Column Relationship],
		@ColumnCompare=[Column Compare] 
	from V_FC_DIVISION_BY_PRODUCT_TYPE 
	where [Division]=@Division
	--//-----------------------------------------------------------------------------------------
	--//chay import FM & xu li all FM file
	if @debug>0
	begin
		select 'IMPORT FM FILE-->TAO BOM DATA'
	end
	if @n_continue =1
	begin
		if @debug>0
		begin
			select 'IMPORT FM FILE-->TAO BOM DATA'
		end
		if @Type=''
		begin
			exec sp_Sum_FC_FM_baseLine @Division,@FM_Key,'full','BOM_ALL',@b_Success1 OUT,@c_errmsg1 OUT

			if @b_Success1 = 0
			begin
				select @n_continue = 3, @c_errmsg = @c_errmsg1
			end
		end
	end
	
	if @n_continue = 1
	begin
		if @debug>0
		begin
			select 'COMBINE 3 TABLE: 1. BOM FM ONLINE,2. BOM TEMPLATE EXCEL FILE'--2. BOM FM OFFLINE(NO USE)
		end
		if @Type=''
		begin
			exec sp_Create_List_Bom_Header_Forecast_All @Division,@FM_Key,@b_Success OUT, @c_errmsg OUT

			if @b_Success1 = 0
			begin
				select @n_continue = 3, @c_errmsg = @c_errmsg1
			end
		end
	end
	BEGIN TRAN
	if @debug>0
	begin
		select 'drop table bom header fc'
	end
	if @n_continue = 1
	begin
		if @Type = ''
		begin
			if exists
			(
				SELECT * 
				FROM sys.objects 
				WHERE object_id = OBJECT_ID(@table_FC_BomHeader) AND type in (N'U')
			)
			begin
				select @sql = 'drop table '+@table_FC_BomHeader
				IF @debug>0
				BEGIN
					SELECT 'Drop table bom header'
				END
				execute(@sql)
		
				select @n_err = @@ERROR
				if @n_err<>0
				begin				
					select @n_continue = 3
					select @n_err=60002
					select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +ERROR_MESSAGE()+'./ ('+@sp_name+')'
				end
			end
			if exists
			(
				SELECT * 
				FROM sys.objects 
				WHERE object_id = OBJECT_ID(@table_FC_BomHeader+'_Tmp') AND type in (N'U')
			)
			begin
				select @sql = 'drop table '+@table_FC_BomHeader+'_Tmp'
				IF @debug>0
				BEGIN
					SELECT 'Drop table bom header tmp'
				END
				execute(@sql)
		
				select @n_err = @@ERROR
				if @n_err<>0
				begin				
					select @n_continue = 3
					select @n_err=60002
					select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +ERROR_MESSAGE()+'./ ('+@sp_name+')'
				end
			end
		end
	end
	if @debug>0
	begin
		select 'insert bom header fc'
	end
	if @n_continue=1
	begin
		if @Type = ''
		begin
			select @sql =
			'select
				[Signature]=s.[Signature],
				[CAT/Axe]=s.[CAT/Axe],
				[SUB CAT/ Sub Axe]=s.[SUB CAT/ Sub Axe],
				[GROUP/ Class]=s.[GROUP/ Class],
				[SUB GROUP/ Brand]=s.[SUB GROUP/ Brand],
				[Channel]=c.Channel,
				[AWO/OS]='''',
				[SAP Code]=s.[Material],
				[Bundle name]=s.[Bundle name],
				[Barcode]=s.Barcode,
				[Product type]=s.[Product Type],
				[Product Status]=s.[Product status],
				[Dchain]=s.[DChain],
				[Customer]=s.Material+c.Channel,'
				+@ListColumn_Pass+','
				+@ListColumn_Current+
				'INTO '+@table_FC_BomHeader+'_tmp				
			from  
			(
				SELECT
					[Signature],
					[CAT/Axe],
					[SUB CAT/ Sub Axe],
					[GROUP/ Class],
					[SUB GROUP/ Brand],
					[Material],
					[Bundle name],
					[Barcode],
					[Product Type],
					[Product status],
					[DChain]
				FROM fnc_SubGroupMaster('''+@Division+''',''full'')
				where 
					[Active]=1
				and [Item Category Group] = ''LUMF''
			) s 
			CROSS join V_FC_Channel c
			where s.[Product Type] IN(select value from string_split('''+@list_product_type+''','','')) '
			+case 
				when @Type IN('FDR') then 
					'AND s.[Material] in(
											SELECT DISTINCT 
												[Sap Code] 
											FROM '+@Division+'_His_SI_Bom_Header_FDR_Final
										) ' 
				else
					'' 
			end

			if @debug >0
			begin
				select @sql '@sql Create tmp bom header forecast '
			end
			execute(@sql)
			/*
				+case 
					when @Division IN('CPD') then 'in(''YFG'',''YSM2'')' 
					else 'in(''YFG'')' 
				end
			*/
			select @n_err = @@ERROR
			if @n_err<>0
			begin				
				select @n_continue = 3
				select @n_err=60002
				select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +ERROR_MESSAGE()+'./ ('+@sp_name+')'
			end
		end
	end
	if @debug>0
	begin
		select 'update bom header fc'
	end
	if @n_continue=1
	begin
		if @Type = ''
		begin
			--update data bom fc 
			--select 'update bomheader fc tmp -->current update'
			select @sql =
			'update '+@table_FC_BomHeader+'_Tmp
			set '+@ListColumn_Current_Update+'
			from '+@table_FC_BomHeader+'_Tmp b
			inner join 
			(
				select 
					[SUB GROUP/ Brand]=s.[SUB GROUP/ Brand],
					[Signature]=s.[Signature],
					[Cat]=s.[Cat],
					[Bundle Code]=b.[Bundle Code],
					[Product Type]=s.[Product Type],
					[Channel]=b.[Channel],'
					+@ListColumn_Current_BomQty+
				'From FC_LIST_BOM_HEADER_ALL_'+@Division+@Monthfc+' b
				Inner join 
				(
					select distinct
						[SUB GROUP/ Brand],
						[Signature],
						[Cat] = [CAT/Axe],
						[Sap Code] = Material,
						[Product Type]
					from fnc_SubGroupMaster('''+@Division+''',''full'')
				) s on s.[Sap Code]=b.[Bundle Code]
				group by
					s.[SUB GROUP/ Brand],
					s.[Signature],
					s.[Cat],
					b.[Bundle Code],
					s.[Product Type],
					b.[Channel]
			) b1 on 
				b1.[Product Type]=b.[Product Type]
			and b1.[Channel]=b.[Channel]
			and b1.[Bundle Code]=b.[Sap Code] '

			if @debug>0
			begin
				select @sql '@sql update data bom header fc 2 years'
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
	end
	if @debug>0
	begin
		select 'update historical actual bom header fc tmp'
	end
	if @n_continue=1
	begin
		if @Type = ''
		begin
			--//update bom header pass 2 years
			--select 'update bomheader fc tmp -->pass update'
			select @sql =
			'update '+@table_FC_BomHeader+'_Tmp
				set '+@ListColumn_Pass_Update+'
			from '+@table_FC_BomHeader+'_Tmp b 
			inner join 
			(
				select 
					*
				from '+@Division+@Monthfc+'_His_SI_Bom_Header_Final
			) b1 on 
				b1.[Product Type]=b.[Product Type]
			and b1.Channel=b.Channel 
			and b1.[SAP Code]=b.[Sap Code] '

			if @debug>0
			begin
				select @sql '@sql update bom header pass 2 years'
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
	end
	if @debug>0
	begin
		select 'create bom forecast final'
	end
	if @n_continue=1
	begin
		if @Type = ''
		begin
			select @sql = 
			'select
				*
				INTO '+@table_FC_BomHeader+'
			from '+@table_FC_BomHeader+'_Tmp b 
			where ('+@listcolum_cong_pass+'+'+@listcolumn_current_plus+')<>0 '
			
			if @debug>0
			begin
				select @sql '@sql create bom header forecast final'
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
	end
	if @debug>0
	begin
		select 'processing FDR-->drop table'
	end
	if @n_continue=1
	begin
		if @Type='FDR'
		begin
			if exists
			(
				SELECT * 
				FROM sys.objects 
				WHERE object_id = OBJECT_ID(@table_FC_BomHeader_FDR) AND type in (N'U')
			)
			begin
				select @sql = 'drop table '+@table_FC_BomHeader_FDR
				if @debug>0
				begin
					select @sql '@sql drop table bomheader fdr'
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
			if exists
			(
				SELECT * 
				FROM sys.objects 
				WHERE object_id = OBJECT_ID(@table_FC_BomHeader_FDR+'_Tmp') AND type in (N'U')
			)
			begin
				select @sql = 'drop table '+@table_FC_BomHeader_FDR+'_Tmp'
				if @debug>0
				begin
					select @sql '@sql drop table bomheader fdr tmp'
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
		end
	end
	if @debug>0
	begin
		select 'processing FDR-->insert table'
	end
	if @n_continue=1
	begin
		if @Type='FDR'
		begin
			--select 'create table tmp -->FDR'
			select @sql =
			'select
				[Signature]=s.[Signature],
				[CAT/Axe]=s.[CAT/Axe],
				[SUB CAT/ Sub Axe]=s.[SUB CAT/ Sub Axe],
				[GROUP/ Class]=s.[GROUP/ Class],
				[SUB GROUP/ Brand]=s.[SUB GROUP/ Brand],
				[Channel]=c.Channel,
				[AWO/OS]='''',
				[SAP Code]=s.[Material],
				[Bundle name]=s.[Bundle name],
				[Barcode]=s.Barcode,
				[Product type]=s.[Product Type],
				[Product Status]=s.[Product status],
				[Dchain]=s.[DChain],
				[Customer]=s.Material+c.Channel,'
				+@ListColumn_Pass				
				+' INTO '+@table_FC_BomHeader_FDR+'_Tmp 
			from  
			(
				SELECT
					[Signature],
					[CAT/Axe],
					[SUB CAT/ Sub Axe],
					[GROUP/ Class],
					[SUB GROUP/ Brand],
					[Material],
					[Bundle name],
					[Barcode],
					[Product Type],
					[Product status],
					[DChain]
				FROM fnc_SubGroupMaster('''+@Division+''',''full'')
				where Active=1
				and [Item Category Group]=''LUMF''
			) s 
			CROSS join V_FC_Channel c
			where s.[Product Type] IN(select value from string_split('''+@list_product_type+''','',''))
			AND s.[Material] in(
									SELECT DISTINCT 
										[Sap Code] 
									FROM '+@Division+@Monthfc+'_His_SI_Bom_Header_FDR_Final
								)'

			if @debug >0
			begin
				select @sql '@sql create table tmp -->FDR'
			end
			execute(@sql)
			/*
				+case 
					when @Division IN('CPD') then 'in(''YFG'',''YSM2'')' 
					else 'in(''YFG'')' 
				end
			*/
			select @n_err = @@ERROR
			if @n_err<>0
			begin				
				select @n_continue = 3
				select @n_err=60002
				select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +ERROR_MESSAGE()+'./ ('+@sp_name+')'
			end
		end
	end
	if @debug>0
	begin
		select 'processing FDR-->update table'
	end
	if @n_continue=1
	begin
		if @Type='FDR'
		begin
			--select 'update FDR tmp -->pass update'
			select @sql =
			'update '+@table_FC_BomHeader_FDR+'_Tmp
			set '+@ListColumn_Pass_Update+'
			from '+@table_FC_BomHeader_FDR+'_Tmp b inner join 
			(
				select 
					*
				from '+@Division+@Monthfc+'_His_SI_Bom_Header_FDR_Final
			) b1 on 
				b1.[Product Type]=b.[Product Type] 
			/*and b1.[SUB GROUP/ Brand]=b.[SUB GROUP/ Brand]*/
			and b1.Channel=b.Channel 
			and b1.[SAP Code]=b.[Sap Code] '

			if @debug>0
			begin
				select @sql '@sql update FDR tmp -->pass update'
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
	end
	if @debug>0
	begin
		select 'processing FDR-->insert tmp table into final table'
	end
	if @n_continue=1
	begin
		if @Type='FDR'
		begin
			--create FDR final
			select 'create table final -->FDR'
			select @sql = 
			'select
				*
				INTO '+@table_FC_BomHeader_FDR+'
			from '+@table_FC_BomHeader_FDR+'_Tmp b
			where ('+@listcolumn_pass_plus+')<>0 '

			if @debug>0
			begin
				select @sql '@sql create FDR final'
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
	end
	if @debug>0
	begin
		select 'processing FOC To VP-->drop table'
	end
	if @n_continue=1
	begin
		if @Type='FOC_TO_VP'
		begin
			if exists
			(
				SELECT * 
				FROM sys.objects 
				WHERE object_id = OBJECT_ID(@table_FC_FDR_FOC_TO_VP) AND type in (N'U')
			)
			begin
				select @sql = 'drop table '+@table_FC_FDR_FOC_TO_VP
				execute(@sql)
		
				select @n_err = @@ERROR
				if @n_err<>0
				begin				
					select @n_continue = 3
					select @n_err=60002
					select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +ERROR_MESSAGE()+'./ ('+@sp_name+')'
				end
			end
			if exists
			(
				SELECT * 
				FROM sys.objects 
				WHERE object_id = OBJECT_ID(@table_FC_FDR_FOC_TO_VP+'_Tmp') AND type in (N'U')
			)
			begin
				select @sql = 'drop table '+@table_FC_FDR_FOC_TO_VP+'_Tmp'
				execute(@sql)
		
				select @n_err = @@ERROR
				if @n_err<>0
				begin				
					select @n_continue = 3
					select @n_err=60002
					select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +ERROR_MESSAGE()+'./ ('+@sp_name+')'
				end
			end
		end
	end
	if @debug>0
	begin
		select 'processing FOC To VP-->insert table'
	end
	if @n_continue=1
	begin
		if @Type='FOC_TO_VP'
		begin
			--select 'create table tmp -->FOC TO VP'
			select @sql =
			'select
				[Signature]=s.[Signature],
				[CAT/Axe]=s.[CAT/Axe],
				[SUB CAT/ Sub Axe]=s.[SUB CAT/ Sub Axe],
				[GROUP/ Class]=s.[GROUP/ Class],
				[SUB GROUP/ Brand]=s.[SUB GROUP/ Brand],
				[Channel]=c.Channel,
				[AWO/OS]='''',
				[SAP Code]=s.[Material],
				[Bundle name]=s.[Bundle name],
				[Barcode]=s.Barcode,
				[Product type]=s.[Product Type],
				[Product Status]=s.[Product status],
				[Dchain]=s.[DChain],
				[Customer]=s.Material+c.Channel,'
				+@ListColumn_Pass
				+' INTO '+@table_FC_FDR_FOC_TO_VP+'_Tmp 			
			from  
			(
				SELECT
					[Signature],
					[CAT/Axe],
					[SUB CAT/ Sub Axe],
					[GROUP/ Class],
					[SUB GROUP/ Brand],
					[Material],
					[Bundle name],
					[Barcode],
					[Product Type],
					[Product status],
					[DChain]
				FROM fnc_SubGroupMaster('''+@Division+''',''full'')
				where Active=1
				and [Item Category Group]=''LUMF''
			) s 
			CROSS join V_FC_Channel c
			where s.[Product Type] IN(select value from string_split('''+@list_product_type+''','','')) '

			if @debug >0
			begin
				select @sql '@sql create table tmp -->FOC TO VP '
			end
			execute(@sql)
			/*
			+case 
				when @Division IN('CPD') then 'in(''YFG'',''YSM2'')' 
				else 'in(''YFG'')' 
			end
			*/

			select @n_err = @@ERROR
			if @n_err<>0
			begin				
				select @n_continue = 3
				select @n_err=60002
				select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +ERROR_MESSAGE()+'./ ('+@sp_name+')'
			end
		end
	end
	if @debug>0
	begin
		select 'processing FOC To VP-->update table'
	end
	if @n_continue=1
	begin
		if @Type='FOC_TO_VP'
		begin
			--select 'update FOC TO VP tmp -->pass update'
			select @sql =
			'update '+@table_FC_FDR_FOC_TO_VP+'_Tmp
			set '+@ListColumn_Pass_Update+'
			from '+@table_FC_FDR_FOC_TO_VP+'_Tmp b 
			inner join 
			(
				select 
					*
				from '+@Division+@Monthfc+'_His_SI_FDR_FOC_TO_VP_Final
			) b1 on 
				b1.[Product Type]=b.[Product Type] 
			/*and b1.[SUB GROUP/ Brand]=b.[SUB GROUP/ Brand]*/
			and b1.Channel=b.Channel 
			and b1.[SAP Code]=b.[Sap Code] '

			if @debug>0
			begin
				select @sql '@sql update FOC TO VP tmp -->pass update'
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
	end
	if @debug>0
	begin
		select 'processing FOC To VP-->insert tmp table into final table'
	end
	if @n_continue=1
	begin
		if @Type='FOC_TO_VP'
		begin
			--create foc to vp final
			select 'create table final -->FOC TO VP'
			select @sql = 
			'select
				*
				INTO '+@table_FC_FDR_FOC_TO_VP+'
			from '+@table_FC_FDR_FOC_TO_VP+'_Tmp b
			where ('+@listcolumn_pass_plus+')<>0 '

			if @debug>0
			begin
				select @sql '@sql create table final -->FOC TO VP'
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