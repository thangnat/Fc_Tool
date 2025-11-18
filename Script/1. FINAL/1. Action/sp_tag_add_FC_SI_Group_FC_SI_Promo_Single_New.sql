/*
	declare 
		@b_Success		Int,
		@c_errmsg		Nvarchar(250)

	exec sp_tag_add_FC_SI_Group_FC_SI_Promo_Single_New 'PPD','202410',1,@b_Success OUT,@c_errmsg OUT

	select @b_Success b_Success,@c_errmsg c_errmsg

	select * from FC_SI_Promo_Single_PPD_202410
*/

Alter Proc sp_tag_add_FC_SI_Group_FC_SI_Promo_Single_New
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
		@sp_name = 'sp_tag_add_FC_SI_Group_FC_SI_Promo_Single_New',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()
	
	select @debug=debug from fnc_debug('FC')
	--select @debug=1
	--declare @Monthfc				nvarchar(20)=''
	--select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from V_FC_FM_Table

	if @debug>0
	begin
		select 'Insert tag name processing'
	end
	if @n_continue=1
	begin
		exec sp_add_TagName_Processing @division,'tag_add_FC_SI_Group_FC_SI_Promo_Single',@b_Success1 OUT,@c_errmsg1 OUT
		if @b_Success1=0
		begin
			select @n_continue=3,@c_errmsg=@c_errmsg1
		end
	end
	if @debug>0
	begin
		select 'sp_add_FC_SI_Group'
	end
	if @n_continue = 1
	begin		
		exec sp_add_FC_SI_Group @Division,@FM_KEY,'FC_SI_Promo_Single',@b_Success1 OUT,@c_errmsg1 OUT
		
		if @b_Success1 = 0
		begin
			select @n_continue = 3, @c_errmsg = @c_errmsg1
		end
	end
	if @debug>0
	begin
		select 'sp_tag_update_wf_promo_single_unit_only_offline'
	end
	if @n_continue = 1
	begin
		exec sp_tag_update_wf_promo_single_unit_only_offline @Division,@FM_KEY,@b_Success1 OUT,@c_errmsg1 OUT
		
		if @b_Success1 = 0
		begin
			select @n_continue = 3, @c_errmsg = @c_errmsg1
		end
	end
	if @debug>0
	begin
		select 'sp_Gen_WF_Value_Period'
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
		select 'sp_tag_update_wf_fc_02_years_Timeseries_value'
	end
	if @n_continue = 1
	begin
		exec sp_tag_update_wf_fc_02_years_Timeseries_value @Division,@FM_KEY,'2. Promo Qty(Single)',@b_Success1 OUT,@c_errmsg1 OUT
		
		if @b_Success1 = 0
		begin
			select @n_continue = 3, @c_errmsg = @c_errmsg1
		end
	end	
	if @debug>0
	begin
		select 'sp_calculate_total'
	end
	if @n_continue = 1
	begin
		if @AllowTotal>0
		begin
			exec sp_calculate_total  @Division,@FM_Key,'fc',@b_Success1 OUT,@c_errmsg1 OUT

			if @b_Success1 = 0
			begin
				select @n_continue = 3, @c_errmsg = @c_errmsg1
			end
		end
	end
	if @debug>0
	begin
		select 'Mismatch'
	end
	if @n_continue=1
	begin
		if @Division NOT IN('PPD1')
		begin
			exec sp_Promo_validate_mismatch @Division,@FM_KEY,@b_Success1 OUT, @c_errmsg1 OUT

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