/*--30 giây
	Declare
		@b_Success			Int,
		@c_errmsg			Nvarchar(250)

	exec sp_Create_V_His_SI_Final 'LDB','202501','h',@b_Success OUT,@c_errmsg OUT

	select @b_Success b_Success,@c_errmsg c_errmsg
	
	select * from LDB_202410_His_SI_Single_Final
	where isnull(channel,'')=''
	/*
		Normal:
		<Division>_His_SI_Single_Final
		<Division>_His_SI_FOC_FDR_Final
		<Division>_His_SI_Bom_Final
		<Division>_His_SI_Bom_Header_Final
		<Division>_His_SI_Bom_Header_FDR_Final
		_His_SI_FDR_FOC_TO_VP_Final
		MTD:
		<Division>_His_SI_Single_MTD_Final
		<Division>_His_SI_FOC_FDR_MTD_Final
		<Division>_His_SI_Bom_MTD_Final
	*/
*/

Alter Proc sp_Create_V_His_SI_Final
	@Division			nvarchar(3),
	@FM_KEY				nvarchar(6),
	@Alias				nvarchar(5),
	@b_Success			Int				OUTPUT,     
	@c_errmsg			Nvarchar(250)	OUTPUT
	with encryption
As
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

	Declare
		@b_Success1			Int,
		@c_errmsg1			Nvarchar(250)

	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_Create_V_His_SI_Final',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	if @FM_KEY = ''
	begin
		select @FM_KEY = format(getdate(),'yyyyMM')
	end

	select @debug=debug from fnc_Debug('FC')
	--select @debug=1

	declare @Monthfc				nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from V_FC_FM_Table
	
	declare @table_His_SI_Single_Final nvarchar(100)= ''
	select @table_His_SI_Single_Final = @Division+@Monthfc+'_His_SI_Single_Final'

	declare @table_His_SI_FOC_FDR_Final nvarchar(100) = ''
	select @table_His_SI_FOC_FDR_Final = @Division+@Monthfc+'_His_SI_FOC_FDR_Final'

	declare @table_His_SI_Bom_Final nvarchar(100) = ''
	select @table_His_SI_Bom_Final = @Division+@Monthfc+'_His_SI_Bom_Final'

	declare @table_His_SI_Bom_Header_Final nvarchar(100) = ''
	select @table_His_SI_Bom_Header_Final = @Division+@Monthfc+'_His_SI_Bom_Header_Final'

	declare @table_His_SI_Bom_Header_FDR_Final nvarchar(100) = ''
	select @table_His_SI_Bom_Header_FDR_Final = @Division+@Monthfc+'_His_SI_Bom_Header_FDR_Final'

	declare @table_His_SI_FDR_FOC_TO_VP_Final nvarchar(100) = ''
	select @table_His_SI_FDR_FOC_TO_VP_Final = @Division+@Monthfc+'_His_SI_FDR_FOC_TO_VP_Final'

	declare @table_His_SI_Single_MTD_Final nvarchar(100) = ''
	select @table_His_SI_Single_MTD_Final = @Division+@Monthfc+'_His_SI_Single_MTD_Final'

	declare @table_His_SI_FOC_FDR_MTD_Final nvarchar(100) = ''
	select @table_His_SI_FOC_FDR_MTD_Final = @Division+@Monthfc+'_His_SI_FOC_FDR_MTD_Final'

	declare @table_His_SI_Bom_MTD_Final nvarchar(100) = ''
	select @table_His_SI_Bom_MTD_Final = @Division+@Monthfc+'_His_SI_Bom_MTD_Final'	

	--//get SI_HIS
	IF @n_continue = 1
	BEGIN
		--//normal
		declare @Column_LY_SINGLE		nvarchar(max) = ''
		select @Column_LY_SINGLE = ListColumn from fn_FC_GetColHeader_Historical(@FM_KEY,@Alias,1)
		--select Column_LY_SINGLE = ListColumn from fn_FC_GetColHeader_Historical('202407','h',1)

		declare @Column_LY_FOC_FDR		nvarchar(max) = ''
		select @Column_LY_FOC_FDR = ListColumn from fn_FC_GetColHeader_Historical(@FM_KEY,@Alias,21)
		--select Column_LY_FOC_FDR = ListColumn from fn_FC_GetColHeader_Historical('202408','h',21)

		declare @Column_LY_BOM			nvarchar(max) = ''
		select @Column_LY_BOM = ListColumn from fn_FC_GetColHeader_Historical(@FM_KEY,@Alias,11)	
		--select Column_LY_BOM_FDR = ListColumn from fn_FC_GetColHeader_Historical('202408','h',211)	
		
		declare @Column_LY_BOM_HEADER	nvarchar(max) = ''
		select @Column_LY_BOM_HEADER = ListColumn from fn_FC_GetColHeader_Historical(@FM_KEY,@Alias,111)
		--select Column_LY_BOM_HEADER = ListColumn from fn_FC_GetColHeader_Historical('202409','h',111)
		
		declare @Column_LY_BOM_HEADER_FDR	nvarchar(max) = ''
		select @Column_LY_BOM_HEADER_FDR = ListColumn from fn_FC_GetColHeader_Historical(@FM_KEY,@Alias,2111)
		--select Column_LY_BOM_HEADER_FDR = ListColumn from fn_FC_GetColHeader_Historical('202408','h',2111)
		
		declare @Column_LY_BOM_HEADER_FDR_FOC_TO_VP	nvarchar(max) = ''
		select @Column_LY_BOM_HEADER_FDR_FOC_TO_VP = ListColumn from fn_FC_GetColHeader_Historical(@FM_KEY,@Alias,3111)
		--select Column_LY_BOM_HEADER_FDR_FOC_TO_VP = ListColumn from fn_FC_GetColHeader_Historical('202408','h',3111)
	END
	if @debug>0
	begin
		select 'sp_Get_SI_His_New Single'
	end
	if @n_continue = 1
	begin
		--//create table His_SI-->V_His_SI
		exec sp_Get_SI_His_New @Division,@FM_KEY,'',@b_Success1 OUT,@c_errmsg1 OUT

		if @b_Success1=0
		begin
			select @n_continue = 3
			select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +@c_errmsg1+'./ ('+@sp_name+')'
		end
	end
	if @debug>0
	begin
		select 'sp_Get_SI_His_New MTD'
	end
	if @n_continue=1
	begin
		--//create table His_SI-->V_His_SI
		exec sp_Get_SI_His_New @Division,@FM_KEY,'MTD',@b_Success1 OUT,@c_errmsg1 OUT

		if @b_Success1=0
		begin
			select @n_continue = 3
			select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +@c_errmsg1+'./ ('+@sp_name+')'
		end
	end
	
	begin tran
	if @debug>0
	begin
		select 'Drop table'
	end
	if @n_continue =1
	begin
		if exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID(@table_His_SI_Single_Final) AND type in (N'U')
		)
		begin
			select @sql ='Drop table '+@table_His_SI_Single_Final
			execute(@sql)
		end
		if exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID(@table_His_SI_FOC_FDR_Final) AND type in (N'U')
		)
		begin
			select @sql ='Drop table '+@table_His_SI_FOC_FDR_Final
			execute(@sql)
		end
		if exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID(@table_His_SI_Bom_Final) AND type in (N'U')
		)
		begin
			select @sql = 'Drop table '+@table_His_SI_Bom_Final
			execute(@sql)
		end
		if exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID(@table_His_SI_Bom_Header_Final) AND type in (N'U')
		)
		begin
			select @sql = 'Drop table '+@table_His_SI_Bom_Header_Final
			execute(@sql)
		end
		if exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID(@table_His_SI_Bom_Header_FDR_Final) AND type in (N'U')
		)
		begin
			select @sql = 'Drop table '+@table_His_SI_Bom_Header_FDR_Final
			execute(@sql)
		end
		if exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID(@table_His_SI_FDR_FOC_TO_VP_Final) AND type in (N'U')
		)
		begin
			select @sql = 'Drop table '+@table_His_SI_FDR_FOC_TO_VP_Final
			execute(@sql)
		end
		if exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID(@table_His_SI_Single_MTD_Final) AND type in (N'U')
		)
		begin
			select @sql = 'Drop table '+@table_His_SI_Single_MTD_Final
			execute(@sql)
		end
		if exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID(@table_His_SI_FOC_FDR_MTD_Final) AND type in (N'U')
		)
		begin
			select @sql = 'Drop table '+@table_His_SI_FOC_FDR_MTD_Final
			execute(@sql)
		end
		if exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID(@table_His_SI_Bom_MTD_Final) AND type in (N'U')
		)
		begin
			select @sql = 'Drop table '+@table_His_SI_Bom_MTD_Final
			execute(@sql)
		end
	end
	if @debug>0
	begin
		select 'insert table Single'
	end
	if @n_continue=1
	begin
		--//His SI single WF <1. Baseline Qty>
		select @sql = 
		'select   
			[Product Type],
			[SubGrp],      
			Channel,      
			[Time series],'
			+@Column_LY_SINGLE+'
			INTO '+@table_His_SI_Single_Final+'
		from V_'+@Division+'_His_SI_Single '+@Alias+'
		group by 
			[Product Type],
			[SubGrp],      
			[Channel],
			[Time series]
		order by
			[SubGrp] asc,
			[Channel] asc,
			[Product Type] asc '

		if @debug >0
		begin
			select @sql 'His SI single WF <1. Baseline Qty>'
		end
		execute(@sql)

		--//His FDR single WF <5. FOC Qty>
		select @sql = 
		'select   
			[Product Type],
			[SubGrp],      
			Channel,      
			[Time series],'
			+@Column_LY_FOC_FDR+'
			INTO '+@table_His_SI_FOC_FDR_Final+' 
		from V_'+@Division+'_His_SI_SingleBomcomponent_FDR '+@Alias+' 
		group by 
			[Product Type],
			[SubGrp],      
			[Channel],
			[Time series]
		order by
			[SubGrp] asc,
			[Channel] asc,
			[Product Type] asc '

		if @debug >0
		begin
			select @sql 'His FDR single WF <5. FOC Qty>'
		end
		execute(@sql)
		
		--//His SI <Bom Component> Final WF <3. Promo Qty(BOM)>
		select @sql = 
		'select   
			[Product Type],
			[SubGrp],      
			Channel,      
			[Time series],'
			+@Column_LY_BOM+' 
			INTO '+@table_His_SI_Bom_Final+'
		from V_'+@Division+'_His_SI_Bom '+@Alias+'
		group by 
			[Product Type],
			[SubGrp],      
			[Channel],
			[Time series]
		order by
			[SubGrp] asc,
			[Channel] asc,
			[Product Type] asc '

		if @debug >0
		begin
			select @sql 'His SI Bom Component Final WF <3. Promo Qty(BOM)>'
		end
		execute(@sql)

		--//His SI <Sheet Bom Header> Final
		select @sql = 
		'select   
			[Product Type],
			[SUB GROUP/ Brand],      
			Channel,
			[Sap Code],'
			+@Column_LY_BOM_HEADER+'
			INTO '+@table_His_SI_Bom_Header_Final+'
		from V_'+@Division+'_His_SI_BomHeader '+@Alias+'
		group by 
			[Product Type],
			[SUB GROUP/ Brand],
			[Channel],
			[Sap Code] '

		if @debug >0
		begin
			select @sql 'His SI <Sheet Bom Header> Final'
		end
		execute(@sql)
		
		--//His SI <Sheet Bom header> FDR final
		select @sql = 
		'select   
			[Product Type],
			[SUB GROUP/ Brand],      
			Channel,
			[Sap Code],'
			+@Column_LY_BOM_HEADER_FDR+'
			INTO '+@table_His_SI_Bom_Header_FDR_Final+'
		from V_'+@Division+'_His_SI_BomHeader_FDR '+@Alias+'
		group by 
			[Product Type],
			[SUB GROUP/ Brand],
			[Channel],
			[Sap Code]
		order by
			[SUB GROUP/ Brand] asc,
			[Channel] asc,
			[Product Type] asc '

		if @debug >0
		begin
			select @sql 'His SI <Bom header> FDR final'
		end
		execute(@sql)

		--//His SI <FOC TO VP> FDR final
		select @sql = 
		'select   
			[Product Type],
			[SUB GROUP/ Brand],      
			Channel,
			[Sap Code],'
			+@Column_LY_BOM_HEADER_FDR_FOC_TO_VP+'
			INTO '+@table_His_SI_FDR_FOC_TO_VP_Final+'
		from V_'+@Division+'_His_SI_FOC_TO_VP '+@Alias+'
		group by 
			[Product Type],
			[SUB GROUP/ Brand],
			[Channel],
			[Sap Code]
		order by
			[SUB GROUP/ Brand] asc,
			[Channel] asc,
			[Product Type] asc '

		if @debug >0
		begin
			select @sql 'His SI <FOC TO VP> FDR final'
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
	--//MTD
	if @debug>0
	begin
		select 'insert table MTD'
	end
	if @n_continue = 1
	begin
		--//create table His_SI_Final
		select @sql = 
		'select   
			[Product Type],
			[SubGrp],      
			Channel,      
			[Time series],
			[MTD SI] = sum('+@Alias+'.HIS_QTY_SINGLE)
			INTO '+@table_His_SI_Single_MTD_Final+'
		from V_'+@Division+'_His_SI_Single_MTD '+@Alias+'
		group by 
			[Product Type],
			[SubGrp],
			[Channel],
			[Time series]
		order by
			[SubGrp] asc,
			[Channel] asc,
			[Product Type] asc '

		if @debug >0
		begin
			select @sql '@sql single mtd final'
		end
		execute(@sql)

		--//FDR Single MTD
		select @sql = 
		'select   
			[Product Type],
			[SubGrp],      
			Channel,      
			[Time series],
			[MTD SI] = sum('+@Alias+'.HIS_QTY_FOC)
			INTO '+@table_His_SI_FOC_FDR_MTD_Final+'
		from V_'+@Division+'_His_SI_SingleBomcomponent_FDR_MTD '+@Alias+'
		group by 
			[Product Type],
			[SubGrp],
			[Channel],
			[Time series]
		order by
			[SubGrp] asc,
			[Channel] asc,
			[Product Type] asc '

		if @debug >0
		begin
			select @sql '@sql FOC FDR mtd final'
		end
		execute(@sql)

		select @sql = 
		'select   
			[Product Type],
			[SubGrp],      
			Channel,      
			[Time series],
			[MTD SI] = sum('+@Alias+'.HIS_QTY_BOM)
			INTO '+@table_His_SI_Bom_MTD_Final+'
		from V_'+@Division+'_His_SI_Bom_MTD '+@Alias+'
		group by 
			[Product Type],
			[SubGrp],      
			[Channel],
			[Time series]
		order by
			[SubGrp] asc,
			[Channel] asc,
			[Product Type] asc '

		if @debug >0
		begin
			select @sql '@sql bom mTD final'
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