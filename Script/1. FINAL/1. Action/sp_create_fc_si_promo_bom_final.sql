/*
	Declare
		@b_Success			Int,
		@c_errmsg			Nvarchar(250)

	exec sp_create_fc_si_promo_bom_final 'CPD','202407','3. Promo Qty(BOM)','x',@b_Success OUT,@c_errmsg OUT

	select @b_Success b_Success,@c_errmsg c_errmsg

	select * from fc_si_promo_bom_final_CPD_202410
*/

alter proc sp_create_fc_si_promo_bom_final
	@Division		nvarchar(3),
	@FM_KEY			nvarchar(6),
	@TimeSeries		nvarchar(20),
	@Alias			nvarchar(10),
	@b_Success		Int				OUTPUT,
	@c_errmsg		Nvarchar(250)	OUTPUT
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
		@sp_name = 'sp_create_fc_si_promo_bom_final',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()
	
	select @debug=debug from fnc_Debug('FC')	
	--select @debug=1

	declare @Monthfc				nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from V_FC_FM_Table

	declare @tablename		nvarchar(100) = ''
	select @tablename = 'fc_si_promo_bom_final_'+@Division+@Monthfc

	declare @listcolumn	nvarchar(max) = ''
	select @listcolumn = ListColumn from fn_FC_GetColheader_Current(@FM_KEY,@TimeSeries,@Alias)
	--select listcolumn = ListColumn from fn_FC_GetColheader_Current('202408',@TimeSeries,'x')

	declare @ListColumn_Current_plus	nvarchar(max) = ''
	SELECT @ListColumn_Current_plus = ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'1. Baseline Qty_+','')
	--SELECT ListColumn_Current_plus = ListColumn FROM fn_FC_GetColheader_Current('202410','1. Baseline Qty_+','')

	declare @list_product_type nvarchar(20)=''
	declare @ColumnRelationShip nvarchar(100)=''
	declare @ColumnCompare nvarchar(100)=''

	select 
		@list_product_type=[Product Type]
		,@ColumnRelationShip=[Column Relationship]
		,@ColumnCompare=[Column Compare] 
	from V_FC_DIVISION_BY_PRODUCT_TYPE 
	where [Division]=@Division

	if @debug >0
	begin
		select @listcolumn '@listcolumn'
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
			execute(@sql)
		end
		select @sql =
		'select
			[FM_KEY],
			[Signature],
			[SUB GROUP/ Brand]=[SUB GROUP/ Brand New],
			[Channel],
			[Product Type],
			[Time series]=''3. Promo Qty(BOM)'','
			+@listcolumn+
			'INTO '+@tablename+'
		from
		(
			select   
				[SUB GROUP/ Brand New]=s.[SUB GROUP/ Brand],
				[Material_Component]=zmr.Material_Component,
				[CQty]=zmr.Qty,
				b.*  
			from 
			(
				select 
					FM_KEY='''+@FM_KEY+''',
					* 
				from FC_Bomheader_'+@Division+@Monthfc+'
				where ('+@ListColumn_Current_plus+')<>0
			) b 
			inner join 
			(
				select 
					* 
				from V_ZMR32
				where [Material Type] IN(select value from string_split('''+@list_product_type+''','',''))
			) zmr on zmr.Material_Bom=b.[Sap Code]
			left join 
			(
				select distinct
					[Barcode],
					[SUB GROUP/ Brand]
				from fnc_SubGroupMaster('''+@Division+''',''full'')
				where [Item Category Group]<>''LUMF''
			) s on s.[Barcode] = zmr.[Barcode_Component]  
		) as x
		where ('+@ListColumn_Current_plus+')<>0
		group by
			[FM_KEY],
			[Signature],
			[SUB GROUP/ Brand New],
			[Channel],
			[Product Type]
		order by
			[SUB GROUP/ Brand] asc,
			[Channel] asc'

		if @debug>0
		begin
			select @sql
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