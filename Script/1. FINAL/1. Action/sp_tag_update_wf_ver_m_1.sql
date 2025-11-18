/*
	declare 
		@b_Success				Int,
		@c_errmsg				Nvarchar(250)

	exec sp_tag_update_wf_ver_m_1_unit 'LDB','202501',@b_Success OUT, @c_errmsg OUT

	select @b_Success b_Success, @c_errmsg c_errmsg
*/

Alter Proc sp_tag_update_wf_ver_m_1
	@Division				nvarchar(3),
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
	
	declare 
		@b_Success1				Int,
		@c_errmsg1				Nvarchar(250)

	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_tag_update_wf_ver_m_1',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	select @debug=debug from fnc_debug('FC')

	if @debug>0
	begin
		select 'run sp_tag_update_wf_ver_m_1_unit'
	end
	if @n_continue = 1
	begin
		exec sp_tag_update_wf_ver_m_1_unit @Division,@FM_KEY,@b_Success1 OUT, @c_errmsg1 OUT
		
		if @b_Success1 = 0
		begin
			select @n_continue = 3,@c_errmsg = @c_errmsg1
		end
	end
	if @debug>0
	begin
		select 'run sp_tag_update_wf_ver_m_1_value'
	end
	if @n_continue = 1
	begin
		exec sp_tag_update_wf_ver_m_1_value @Division,@FM_KEY,@b_Success OUT, @c_errmsg OUT

		if @b_Success1 = 0
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