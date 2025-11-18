/*
	declare 
		@b_Success		Int,
		@c_errmsg		Nvarchar(250)

	exec sp_tag_add_FC_SI_Group_FC_SI_Promo_Bom 'PPD','202410',1,@b_Success OUT,@c_errmsg OUT

	select @b_Success b_Success,@c_errmsg c_errmsg

	select * from FC_SI_Promo_Bom_PPD_202410
*/

Alter Proc sp_tag_add_FC_SI_Group_FC_SI_Promo_Bom
	@Division				nvarchar(3),
	@FM_KEY					nvarchar(6),
	@AllowTotal				int,
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
		@b_Success1				Int,
		@c_errmsg1				Nvarchar(250)

	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_tag_add_FC_SI_Group_FC_SI_Promo_Bom',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()
	
	select @debug=debug from fnc_debug('FC')
	--select @debug=1

	if @debug>0
	begin
		select 'Insert tag name processing'
	end
	if @n_continue=1
	begin
		exec sp_add_TagName_Processing @division,'tag_add_FC_SI_Group_FC_SI_Promo_Bom',@b_Success1 OUT,@c_errmsg1 OUT
		if @b_Success1=0
		begin
			select @n_continue=3,@c_errmsg=@c_errmsg1
		end
	end

	if @debug>0
	begin
		select 'import OUTSIDE TEMPLATE--LAY BOM OUTSIDE DATA OFFLINE'
	end
	if @n_continue=1
	begin
		exec sp_add_FC_SI_Group @Division,@FM_KEY,'FC_SI_Promo_Bom',@b_Success1 OUT,@c_errmsg1 OUT
		
		if @b_Success1 = 0
		begin
			select @n_continue = 3, @c_errmsg = @c_errmsg1
		end
	end
	
	if @debug>0
	begin
		select 'TAO TABLE BOMHEADER STANDARD'
	end
	if @n_continue = 1
	begiN
		exec sp_Gen_BomHeader_Forecast_NEW @Division,@FM_KEY,'',@b_Success1 OUT,@c_errmsg1 OUT
		if @b_Success1 = 0
		begin
			select @n_continue = 3, @c_errmsg = @c_errmsg1
		end
	end
	if @debug>0
	begin
		select 'NO BOM to update wf'
	end
	IF @n_continue = 1
	BEGIN
		exec sp_create_fc_si_promo_bom_final @Division,@FM_KEY,'3. Promo Qty(BOM)','x',@b_Success1 OUT,@c_errmsg1 OUT
		if @b_Success1 = 0
		begin
			select @n_continue = 3, @c_errmsg = @c_errmsg1
		end
	END
	if @debug>0
	begin
		select 'UPDATE TABLE NO BOM TO WF UNIT'
	end
	if @n_continue = 1
	begin
		exec sp_tag_update_wf_promo_bom_component_unit @Division,@FM_KEY,@b_Success1 OUT, @c_errmsg1 OUT
		
		if @b_Success1 = 0
		begin
			select @n_continue = 3, @c_errmsg = @c_errmsg1
		end
	end
	if @debug>0
	begin
		select 'LAY UNIT TAO TABLE VALUE BASE ON RSP MASTER'
	end
	if @n_continue = 1
	begin
		exec sp_Gen_WF_Value_Period @Division,@FM_KEY,'VALUE','fc',@b_Success OUT, @c_errmsg OUT

		if @b_Success1 = 0
		begin
			select @n_continue = 3, @c_errmsg = @c_errmsg1
		end
	end
	if @debug>0
	begin
		select 'UPDATE TABLE VALUE INTO WF VALUE'
	end
	if @n_continue = 1
	begin
		exec sp_tag_update_wf_fc_02_years_Timeseries_value @Division,@FM_KEY,'3. Promo Qty(BOM)',@b_Success1 OUT, @c_errmsg1 OUT
		
		if @b_Success1 = 0
		begin
			select @n_continue = 3, @c_errmsg = @c_errmsg1
		end
	end
	if @debug>0
	begin
		select 'TOTAL CALCULATION'
	end
	if @n_continue = 1
	begin
		if @AllowTotal>0
		begin
			exec sp_calculate_total @Division, @FM_KEY,'fc',@b_Success1 OUT, @c_errmsg1 OUT
		
			if @b_Success1 = 0
			begin
				select @n_continue = 3, @c_errmsg = @c_errmsg1
			end
		end
	end
	if @debug>0
	begin
		select 'Mismatch bom offline'
	end
	if @n_continue=1
	begin
		if @Division NOT IN('PPD1')
		begin
			exec sp_Bom_Offline_validate_mismatch @Division,@FM_KEY,@b_Success1 OUT, @c_errmsg1 OUT

			if @b_Success1 = 0
			begin
				select @n_continue = 1, @c_errmsg = @c_errmsg1
			end
		END
	end
	if @debug>0
	begin
		select 'Mismatch bom online'
	end
	if @n_continue=1
	begin
		if @Division NOT IN('PPD1')
		begin
			exec sp_FM_BOM_ONLINE_validate_mismatch @Division,@FM_KEY,@b_Success1 OUT, @c_errmsg1 OUT

			if @b_Success1 = 0
			begin
				select @n_continue = 1, @c_errmsg = @c_errmsg1
			end
		END
	end
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