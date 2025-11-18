/*
	exec sp_FC_BFL_Master 'CPD',''
	select * from V_FC_BFL_Master_CPD where SeachText like '%6902395465959%'
*/

Alter proc sp_FC_BFL_Master
	@division	nvarchar(3),
	@Filter		nvarchar(max),
	@ColumName	Nvarchar(100),
	@MatchFind	int
with encryption
As	
	declare @debug int=0
	declare @tablename nvarchar(200) = ''
	declare @sql nvarchar(max)=''
	declare @listColumn nvarchar(max)=''
	
	if @division='CPD'
	begin
		select @listColumn='
		[ID],
		[Active]= cast([Active] as bit),
		[SeachText]=[Sub-group FC]+''*''+[Material]+''*''+[Material Type]+''*''+[Signature]+''*''+[EAN (TEXT)]+''*''+[Material Description (Eng)]+''*''+[Category]+''*''+[Sub-Category]+''*''+[Sub Brand],
		[EAN (VALUE)],
		[7digit],
		[Material],
		[Material Type],
		[Material Description (Eng)],
		/*[2nd Language Description],*/
		[EAN (TEXT)],
		[Dchain 02],
		[MMPP Status],
		[Standard Cost],
		[MAP],
		[YPB0 - Currency],
		[YPB0 - Value (Gia nhap tu nha may)],
		[Vendor Code],
		[MRP Group],
		[Signature],
		[Signature Description],
		[Brand Description],
		[SubBrand Description],
		[Reference Description],
		[Axe description],
		[SubAxe Description],
		[Class Description],
		[Function Description],
		[Item Category Group],
		[Material Gr 1],
		[x],
		[Category],
		[Sub-Category],
		[Sub Brand],
		[Sub-group],
		[Group],
		[Sub-group FC],
		[ABC Class],
		[Type],
		[SAP Code Status],
		[EAN Status],
		[Sub Groub Status],
		[Launch Month],
		[DC Month],
		[Final EAN],
		[Compass],
		[Bundle/Single],
		[RSP],
		[FLA],
		[Reason 1],
		[Reason 1 for change],
		[Reason 2],
		[Reason 2 for change],
		[Gross Weight],
		[Nett Weight],
		[Alt UOM Width],
		[Alt UOM Length],
		[Alt UOM Height],
		[Creation Date],
		[YR03 M0],
		[YR03 Y+1],
		[LY-2_ RSP_Jan],
		[LY-2_ RSP_Feb],
		[LY-2_ RSP_Mar],
		[LY-2_ RSP_Apr],
		[LY-2_ RSP_May],
		[LY-2_ RSP_Jun],
		[LY-2_ RSP_Jul],
		[LY-2_ RSP_Aug],
		[LY-2_ RSP_Sep],
		[LY-2_ RSP_Oct],
		[LY-2_ RSP_Nov],
		[LY-2_ RSP_Dec],
		[LY-1_ RSP_Jan],
		[LY-1_ RSP_Feb],
		[LY-1_ RSP_Mar],
		[LY-1_ RSP_Apr],
		[LY-1_ RSP_May],
		[LY-1_ RSP_Jun],
		[LY-1_ RSP_Jul],
		[LY-1_ RSP_Aug],
		[LY-1_ RSP_Sep],
		[LY-1_ RSP_Oct],
		[LY-1_ RSP_Nov],
		[LY-1_ RSP_Dec],
		[CY_ RSP_Jan],
		[CY_ RSP_Feb],
		[CY_ RSP_Mar],
		[CY_ RSP_Apr],
		[CY_ RSP_May],
		[CY_ RSP_Jun],
		[CY_ RSP_Jul],
		[CY_ RSP_Aug],
		[CY_ RSP_Sep],
		[CY_ RSP_Oct],
		[CY_ RSP_Nov],
		[CY_ RSP_Dec],
		[NY__ RSP_Jan],
		[NY__ RSP_Feb],
		[NY__ RSP_Mar],
		[NY__ RSP_Apr],
		[NY__ RSP_May],
		[NY__ RSP_Jun],
		[NY__ RSP_Jul],
		[NY__ RSP_Aug],
		[NY__ RSP_Sep],
		[NY__ RSP_Oct],
		[NY__ RSP_Nov],
		[NY__ RSP_Dec]'
	end
	else if @division='LLD'
	begin
		select @listColumn='[Active]=cast([Active] as bit),
		[SeachText]=[Franchise]+''*''+[BFL Code]+''*''+[BFL Name]+''*''+[SKU Code]+''*''+[Material Type]+''*''+[Signature]+''*''+[EAN code]+''*''+[SKU Name]+''*''+[Product Status]+''*''+[Hero]+''*''+[Product Type]+''*''+[Dchain Specs Status]+''*''+[Item Category Group]+''*''+[Product Status],
		[Signature],[Axe],[Sub Axe],[Brand],[Sub Brand],[Franchise],[Sub Franchise],[BFL Code],[BFL Name],[EAN Code],[SKU Code],[SKU Name],[Country Status],[Hero],[Product Status],[LSI],[Y0 (u) M1],[Y0 (u) M2],[Y0 (u) M3],[Y0 (u) M4],[Y0 (u) M5],[Y0 (u) M6],[Y0 (u) M7],[Y0 (u) M8],[Y0 (u) M9],[Y0 (u) M10],[Y0 (u) M11],[Y0 (u) M12],[Y+1 (u) M1],[Y+1 (u) M2],[Y+1 (u) M3],[Y+1 (u) M4],[Y+1 (u) M5],[Y+1 (u) M6],[Y+1 (u) M7],[Y+1 (u) M8],[Y+1 (u) M9],[Y+1 (u) M10],[Y+1 (u) M11],[Y+1 (u) M12],[B_Y0_M1],[B_Y0_M2],[B_Y0_M3],[B_Y0_M4],[B_Y0_M5],[B_Y0_M6],[B_Y0_M7],[B_Y0_M8],[B_Y0_M9],[B_Y0_M10],[B_Y0_M11],[B_Y0_M12],[B_Y+1_M1],[B_Y+1_M2],[B_Y+1_M3],[B_Y+1_M4],[B_Y+1_M5],[B_Y+1_M6],[B_Y+1_M7],[B_Y+1_M8],[B_Y+1_M9],[B_Y+1_M10],[B_Y+1_M11],[B_Y+1_M12],[PB_Y+1_M1],[PB_Y+1_M2],[PB_Y+1_M3],[PB_Y+1_M4],[PB_Y+1_M5],[PB_Y+1_M6],[PB_Y+1_M7],[PB_Y+1_M8],[PB_Y+1_M9],[PB_Y+1_M10],[PB_Y+1_M11],[PB_Y+1_M12],[T_Y0_M1],[T_Y0_M2],[T_Y0_M3],[T_Y0_M4],[T_Y0_M5],[T_Y0_M6],[T_Y0_M7],[T_Y0_M8],[T_Y0_M9],[T_Y0_M10],[T_Y0_M11],[T_Y0_M12]'
	end
	else if @division='LDB'
	begin
		select @listColumn='[Active]=cast([Active] as bit),
		[SeachText]=[Axe]+''*''+[SUB Axe]+''*''+[Brand]+''*''+[Sub Brand]+''*''+[Franchise]+''*''+[Sub Franchise]+''*''+[BFL Code]+''*''+[BFL Name]+''*''+[EAN code]+''*''+[SKU Code]+''*''+[SKU Name],
		[Signature],[Axe],[SUB Axe],[Brand],[Sub Brand],[Franchise],[Sub Franchise],[BFL Code],[BFL Name],[EAN code],[SKU Code],[SKU Name],[Country Status],[Hero],[Product Type],[Dchain Specs Status],[Item Category Group],[Product Status],[Y-2 (u) M1],[Y-2 (u) M2],[Y-2 (u) M3],[Y-2 (u) M4],[Y-2 (u) M5],[Y-2 (u) M6],[Y-2 (u) M7],[Y-2 (u) M8],[Y-2 (u) M9],[Y-2 (u) M10],[Y-2 (u) M11],[Y-2 (u) M12],[Y-1 (u) M1],[Y-1 (u) M2],[Y-1 (u) M3],[Y-1 (u) M4],[Y-1 (u) M5],[Y-1 (u) M6],[Y-1 (u) M7],[Y-1 (u) M8],[Y-1 (u) M9],[Y-1 (u) M10],[Y-1 (u) M11],[Y-1 (u) M12],[Y0 (u) M1],[Y0 (u) M2],[Y0 (u) M3],[Y0 (u) M4],[Y0 (u) M5],[Y0 (u) M6],[Y0 (u) M7],[Y0 (u) M8],[Y0 (u) M9],[Y0 (u) M10],[Y0 (u) M11],[Y0 (u) M12],[Y+1 (u) M1],[Y+1 (u) M2],[Y+1 (u) M3],[Y+1 (u) M4],[Y+1 (u) M5],[Y+1 (u) M6],[Y+1 (u) M7],[Y+1 (u) M8],[Y+1 (u) M9],[Y+1 (u) M10],[Y+1 (u) M11],[Y+1 (u) M12],[B_Y0_M1],[B_Y0_M2],[B_Y0_M3],[B_Y0_M4],[B_Y0_M5],[B_Y0_M6],[B_Y0_M7],[B_Y0_M8],[B_Y0_M9],[B_Y0_M10],[B_Y0_M11],[B_Y0_M12],[B_Y+1_M1],[B_Y+1_M2],[B_Y+1_M3],[B_Y+1_M4],[B_Y+1_M5],[B_Y+1_M6],[B_Y+1_M7],[B_Y+1_M8],[B_Y+1_M9],[B_Y+1_M10],[B_Y+1_M11],[B_Y+1_M12],[PB_Y+1_M1],[PB_Y+1_M2],[PB_Y+1_M3],[PB_Y+1_M4],[PB_Y+1_M5],[PB_Y+1_M6],[PB_Y+1_M7],[PB_Y+1_M8],[PB_Y+1_M9],[PB_Y+1_M10],[PB_Y+1_M11],[PB_Y+1_M12],[T_Y0_M1],[T_Y0_M2],[T_Y0_M3],[T_Y0_M4],[T_Y0_M5],[T_Y0_M6],[T_Y0_M7],[T_Y0_M8],[T_Y0_M9],[T_Y0_M10],[T_Y0_M11],[T_Y0_M12]'
	end

	select @tablename = 'V_FC_BFL_Master_'+@division
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
			select @sql '@sql'
		end
		execute(@sql)
	end
	if len(@Filter)>0
	begin
		if @MatchFind=1
		begin
			SELECT @sql=		
				'select 
					f.*
				from 
				(
					select
						'+@listColumn+'
					from FC_BFL_Master_'+@division+'
				) f
				where f.['+@ColumName+']= '''+@Filter+''' '		
		end
		else
		begin
			SELECT @sql=		
			'select 
					f.*
				from 
				(
					select
						'+@listColumn+'
					from FC_BFL_Master_'+@division+'
				) f
				left join
				(
					select 
						value=trim(value) 
					from string_split('''+@Filter+''','','')
				) x on f.SeachText like ''%''+x.value+''%''
				where isnull(x.Value,'''')<>'''' '		
		end
	end
	else
	begin
		select @sql ='
		select
			'+@listColumn+'
		from FC_BFL_Master_'+@division
	end

	if @debug>0
	begin
		select @sql	'@sql 1.1.1'
	end
	execute(@sql)
