/*
	declare 
		@b_Success		Int,
		@c_errmsg		Nvarchar(250)

	exec sp_Update_Value_WF_After_Update_Price 'CPD','202410','ALL',1,@b_Success OUT,@c_errmsg OUT
	
	select @b_Success b_Success,@c_errmsg c_errmsg

	/*
		Type:
			All,
			soh,
			git,
			mtd_si,
			sit,
			historical,
			fc,
			budget,
			pre_budget,
			trend
	*/
*/

Alter Proc sp_Update_Value_WF_After_Update_Price
	@Division				nvarchar(3),
	@FM_Key					nvarchar(6),
	@type					nvarchar(20),
	@AllowTotal				INT,
	@b_Success				Int				OUTPUT,     
	@c_errmsg				Nvarchar(250)	OUTPUT
As
SET NOCOUNT ON
SET XACT_ABORT ON
--BEGIN TRAN
BEGIN TRY
	DECLARE   
		 @Debug					int=0
		,@sp_name				Nvarchar(100)
		,@n_continue			Int
		,@USERS					Nvarchar(50)
		,@MODIFILED				Datetime
		,@n_err					int

	declare 
		@b_Success1				Int,
		@c_errmsg1				Nvarchar(250)

	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_Update_Value_WF_After_Update_Price',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	select @debug=debug from fnc_debug('FC')
	--select @debug=1

	declare @Monthfc				nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from V_FC_FM_Table
	
	--if @Debug>0
	--begin
	--	select 'convert data to standard data pass'
	--end
	--if @n_continue=1
	--begin
	--	if @type='All'
	--	begin
	--		exec sp_Create_V_His_SI_Final @Division,@FM_Key,'h',@b_Success1 OUT,@c_errmsg1 OUT
	--		if @b_Success1=0
	--		begin
	--			select @n_continue=3,@c_errmsg=@c_errmsg1
	--		end
	--	end
	--end
	if @Debug>0
	begin
		select 'update data pass into wf'
	end
	if @n_continue=9
	begin
		exec sp_tag_update_wf_pass_02_years_new @Division,@FM_Key,1,@b_Success1 OUT, @c_errmsg1 OUT
		if @b_Success1=0
		begin
			select @n_continue=3,@c_errmsg=@c_errmsg1
		end
	end
	if @Debug>0
	begin
		select 'sp_Gen_WF_Value_Period'
	end
	if @n_continue=1
	begin
		exec sp_Gen_WF_Value_Period @Division,@FM_Key,'VALUE','fc',@b_Success1 OUT, @c_errmsg1 OUT
		if @b_Success1=0
		begin
			select @n_continue=3,@c_errmsg=@c_errmsg1
		end
	end
	if @Debug>0
	begin
		select 'sp_tag_update_wf_fc_02_years_Timeseries_Value'
	end
	if @n_continue=1
	begin
		exec sp_tag_update_wf_fc_02_years_Timeseries_Value @Division,@FM_Key,'All',@b_Success1 OUT, @c_errmsg1 OUT
		if @b_Success1=0
		begin
			select @n_continue=3,@c_errmsg=@c_errmsg1
		end
	end
	if @Debug>0
	begin
		select 'sp_calculate_total'
	end
	if @n_continue = 1
	begin
		if @AllowTotal=1
		begin
			exec sp_calculate_total @Division,@FM_Key,@type,@b_Success1 OUT,@c_errmsg1 OUT

			if @b_Success1 = 0
			begin
				select @n_continue = 3, @c_errmsg = @c_errmsg1
			end
		end
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
  -- ROLLBACK
   DECLARE @ErrorMessage VARCHAR(2000)
   SELECT @ErrorMessage = 'Error: '+ ERROR_MESSAGE()
   RAISERROR(@ErrorMessage , 16, 1)
END CATCH