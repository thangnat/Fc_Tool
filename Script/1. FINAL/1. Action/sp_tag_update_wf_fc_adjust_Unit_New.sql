/*
	declare 
		@b_Success				Int,
		@c_errmsg				Nvarchar(250)

	exec sp_tag_update_wf_fc_adjust_Unit_New 'CPD','202406',@b_Success OUT, @c_errmsg OUT

	select @b_Success b_Success, @c_errmsg c_errmsg
*/

Alter Proc sp_tag_update_wf_fc_adjust_Unit_New
	@Division				nvarchar(3),
	@FM_KEY					nvarchar(6),
	@Show_Selected_Status	nvarchar(50),--//Show_All_Selected,Show_Total_Selected,Show_BP_Selected
	@b_Success				Int				OUTPUT,     
	@c_errmsg				Nvarchar(250)	OUTPUT
As
SET NOCOUNT ON
SET XACT_ABORT ON
--BEGIN TRAN
BEGIN TRY
	DECLARE  
			 @debug					int=1
			,@sp_name				Nvarchar(100)
			,@n_continue			Int
			,@USERS					Nvarchar(50)
			,@MODIFILED				Datetime
			,@n_err					int			
			
	SELECT	@n_continue=1, 
			@b_success=0,
			@n_err=0,
			@c_errmsg='', 
			@sp_name = 'sp_tag_update_wf_fc_adjust_Unit_New',
			@USERS = SUSER_NAME(),
			@MODIFILED = GETDATE()
	
	declare 
		@b_Success1				Int=0,
		@c_errmsg1				Nvarchar(250)=''

	if @n_continue =1
	begin
		exec sp_tag_update_wf_fc_adjust_unit @Division,@FM_KEY,@Show_Selected_Status,@b_Success1 OUT, @c_errmsg1 OUT
		if @b_Success1=0
		begin
			select @n_continue=3, @c_errmsg=@c_errmsg1
		end
	end

	if @n_continue = 1
	begin
		exec sp_tag_update_BP_unit @Division,@FM_KEY,@b_Success1 OUT, @c_errmsg1 OUT
		if @b_Success1=0
		begin
			select @n_continue=3, @c_errmsg=@c_errmsg1
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