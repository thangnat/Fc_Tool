/*
	declare 
		@b_Success				Int,
		@c_errmsg				Nvarchar(250)

	exec sp_tag_update_wf_zv14_02_year_actual 'CPD','202407',@b_Success OUT, @c_errmsg OUT

	select @b_Success b_Success, @c_errmsg c_errmsg
*/

Alter Proc sp_tag_update_wf_zv14_02_year_actual
	@Division				nvarchar(3),
	@FM_KEY					nvarchar(6),
	@b_Success				Int				OUTPUT,
	@c_errmsg				Nvarchar(250)	OUTPUT
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
		@sp_name = 'sp_tag_update_wf_zv14_02_year_actual',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	select @debug=debug from fnc_debug('FC')
	--select @debug=1

	declare @Monthfc				nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from V_FC_FM_Table

	declare @FC_FM_Original			nvarchar(100) = ''
	select @FC_FM_Original = 'FC_FM_Original_'+@Division+@Monthfc	

	declare @ListColumn_Pass_2_set_zero		nvarchar(max) = ''
	select @ListColumn_Pass_2_set_zero=ListColumn from fn_FC_GetColHeader_Historical(@FM_Key,'si',2222)
	--select ListColumn_Pass_2_set_zero=ListColumn from fn_FC_GetColHeader_Historical('202408','si',2222)

	declare @ListColumn_Pass_2		nvarchar(max) = ''
	select @ListColumn_Pass_2 = ListColumn from fn_FC_GetColHeader_Historical(@FM_Key,'h',2)
	--select ListColumn_Pass_2 = ListColumn from fn_FC_GetColHeader_Historical('202403','h',2

	if @n_continue = 1
	begin
		--clear data to zero
		select @sql=
		'Update '+@FC_FM_Original+'
			set '+@ListColumn_Pass_2_set_zero+'
		where Channel IN(''ONLINE'',''OFFLINE'',''O+O'')'

		if @debug>0
		begin
			select @sql '@sql update zero before update data current'
		end
		execute(@sql)

		--//Update Historical data 2022-->current M-1 single
		select @sql = 
		'update '+@FC_FM_Original+'
			set '+@ListColumn_Pass_2+'
		from '+@FC_FM_Original+' f
		inner join '+@Division+@Monthfc+'_His_SI_Single_Final h on 
			h.[Product Type] = f.[Product type]
		and h.SubGrp = f.[SUB GROUP/ Brand]
		and h.Channel = f.Channel						
		and h.[Time series] = f.[Time series]
		where 
			f.Channel IN(''ONLINE'',''OFFLINE'') 
		and f.[Time series] = ''1. Baseline Qty'' '

		if @debug>0
		begin
			select @sql '@sql 4 Update his data 2022-current month single'
		end
		execute(@sql)

		--//Update Historical data 2022-->current M-1 single FDR-->FOC Qty row
		select @sql = 
		'update '+@FC_FM_Original+'
		set '+@ListColumn_Pass_2+'
		from '+@FC_FM_Original+' f
		inner join '+@Division+@Monthfc+'_His_SI_FOC_FDR_Final h on 
			h.[Product Type] = f.[Product type]
		and h.SubGrp = f.[SUB GROUP/ Brand]
		and h.Channel = f.Channel						
		and h.[Time series] = f.[Time series]
		where f.[Time series] = ''5. FOC Qty'' '

		if @debug>0
		begin
			select @sql '@sql 4.1 Update his data 2022-current month FOC'
		end
		execute(@sql)

		--//Update Historical data 2022-->current M-1 bom
		select @sql = 
		'update '+@FC_FM_Original+'
			set '+@ListColumn_Pass_2+'
		from '+@FC_FM_Original+' f
		inner join '+@Division+@Monthfc+'_His_SI_Bom_Final h on 
			h.[Product Type] = f.[Product type]
		and h.SubGrp = f.[SUB GROUP/ Brand]
		and h.Channel = f.Channel						
		and h.[Time series] = f.[Time series]
		where f.[Time series] = ''3. Promo Qty(BOM)'' '

		if @debug>0
		begin
			select @sql '@sql 4. Update his data 2022-current month bom'
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