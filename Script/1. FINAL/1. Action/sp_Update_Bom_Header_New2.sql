/*
	declare 
		@b_Success		Int,
		@c_errmsg		Nvarchar(250)

	exec sp_Update_Bom_Header_New2 'CPD','202407',@b_Success OUT,@c_errmsg OUT

	select @b_Success b_Success,@c_errmsg c_errmsg
*/

Alter Proc sp_Update_Bom_Header_New2
	@Division				Nvarchar(3),
	@FM_KEY					nvarchar(6),
	@b_Success				Int				OUTPUT,     
	@c_errmsg				Nvarchar(250)	OUTPUT
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
	
	declare 
		@b_Success1			Int,
		@c_errmsg1			Nvarchar(250)

	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_Update_Bom_Header_New2',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()
	
	declare @typebundleChannel nvarchar(30) =''
	--select @typebundleChannel = @BundleCode+'@'+@Channel

	
	if @debug>0
	begin
		select 'sp_Update_Bom_Header'
	end
	if @n_continue=1
	begin
		exec sp_Update_Bom_Header_Excel @Division,@FM_KEY,@b_Success1 OUT,@c_errmsg1 OUT		
		if @b_Success1 = 0
		begin
			select @n_continue = 3, @c_errmsg = @c_errmsg1
		end
	end
	if @debug>0
	begin
		select 'sp_create_fc_si_promo_bom_final'
	end
	IF @n_continue = 1
	BEGIN
		--//no bom
		exec sp_create_fc_si_promo_bom_final @Division,@FM_KEY,'3. Promo Qty(BOM)','x',@b_Success1 OUT,@c_errmsg1 OUT
		--select * from fc_si_promo_bom_final_CPD-->Subgroup level
		if @b_Success1 = 0
		begin
			select @n_continue = 3, @c_errmsg = @c_errmsg1
		end
	END
	if @debug>0
	begin
		select 'sp_tag_update_wf_promo_bom_component_unit'
	end
	if @n_continue = 1
	begin		
		
		--update wf -->use base on select * from fc_si_promo_bom_final_CPD
		exec sp_tag_update_wf_promo_bom_component_unit @Division,@FM_KEY,@b_Success1 OUT, @c_errmsg1 OUT
		
		if @b_Success1 = 0
		begin
			select @n_continue = 3, @c_errmsg = @c_errmsg1
		end
	end
	if @debug>0
	begin
		select 'NO BOM'
	end
	if @n_continue=1
	begin
		exec sp_FC_NO_BOM @Division,@FM_KEY,0,@b_Success1 OUT,@c_errmsg1 OUT
		
		if @b_Success1 = 0
		begin
			select @n_continue = 3, @c_errmsg = @c_errmsg1
		end
	end
	--if @debug>0
	--begin
	--	select 'sp_Gen_WF_Value_Period'
	--end
	--if @n_continue = 9
	--begin
	--	--tao table value
	--	exec sp_Gen_WF_Value_Period @Division,@FM_KEY,'VALUE','fc',@b_Success OUT, @c_errmsg OUT

	--	if @b_Success1 = 0
	--	begin
	--		select @n_continue = 3, @c_errmsg = @c_errmsg1
	--	end
	--end
	--if @debug>0
	--begin
	--	select 'sp_tag_update_wf_fc_02_years_Timeseries_value'
	--end
	--if @n_continue = 9
	--begin	
	--	--update table value to wf
	--	exec sp_tag_update_wf_fc_02_years_Timeseries_value @Division,@FM_KEY,'3. Promo Qty(BOM)',@b_Success1 OUT, @c_errmsg1 OUT
		
	--	if @b_Success1 = 0
	--	begin
	--		select @n_continue = 3, @c_errmsg = @c_errmsg1
	--	end
	--end
	--if @debug>0
	--begin
	--	select 'sp_calculate_total'
	--end
	--if @n_continue = 9
	--begin	
	--	--tinh toal
	--	exec sp_calculate_total @Division,@FM_KEY,'fc',@b_Success1 OUT, @c_errmsg1 OUT
		
	--	if @b_Success1 = 0
	--	begin
	--		select @n_continue = 3, @c_errmsg = @c_errmsg1
	--	end
	--end

	if @n_continue = 3
	begin
		--rollback
		select @b_Success = 0
	end
	else
	begin
		--Commit
		select @b_Success = 1, @c_errmsg = 'Successfully.../'
	end
END TRY
BEGIN CATCH
   --ROLLBACK
   DECLARE @ErrorMessage VARCHAR(2000)
   SELECT @ErrorMessage = 'Error: '+ ERROR_MESSAGE()
   RAISERROR(@ErrorMessage , 16, 1)
END CATCH