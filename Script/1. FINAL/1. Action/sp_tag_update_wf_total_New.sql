/*
	declare 
		@b_Success				Int,
		@c_errmsg				Nvarchar(250)

	exec sp_tag_update_wf_total_New 'LLD','202409','All','All',@b_Success OUT, @c_errmsg OUT

	select @b_Success b_Success, @c_errmsg c_errmsg
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

		/*
			tag_update_wf_total_fc_unit/All
			tag_update_wf_total_fc_value/All
		*/
	*/
*/
Alter Proc sp_tag_update_wf_total_New
	@Division				nvarchar(3),
	@FM_KEY					nvarchar(6),
	@Tag_Name_unit			nvarchar(200),
	@Tag_Name_value			nvarchar(200),
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
	
	declare 
		@b_Success1				Int,
		@c_errmsg1				Nvarchar(250)

	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_tag_update_wf_total_New',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()
	
	select @debug=debug from fnc_Debug('FC')
	--select @debug=1

	declare @Monthfc				nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from V_FC_FM_Table

	if @n_continue =1
	begin
		exec sp_tag_update_wf_total_unit_new @Division,@FM_KEY,@Tag_Name_unit,@b_Success1 OUT, @c_errmsg1 OUT
		if @b_Success1 =0
		begin
			select @n_continue = 3,@c_errmsg = @c_errmsg1
		end
	end
	if @n_continue =1
	begin
		exec sp_tag_update_wf_total_value_new @Division,@FM_KEY,@Tag_Name_value ,@b_Success1 OUT, @c_errmsg1 OUT
		if @b_Success1 =0
		begin
			select @n_continue = 3,@c_errmsg = @c_errmsg1
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
   --ROLLBACK
   DECLARE @ErrorMessage VARCHAR(2000)
   SELECT @ErrorMessage = 'Error: '+ ERROR_MESSAGE()
   RAISERROR(@ErrorMessage , 16, 1)
END CATCH