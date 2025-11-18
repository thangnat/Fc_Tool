/*
	Declare 
		@b_Success		Int,
		@c_errmsg		Nvarchar(250)

	exec sp_FC_GIT_New 'LDB','202502',1,@b_Success OUT,@c_errmsg OUT

	select @b_Success b_Success,@c_errmsg c_errmsg

	SELECT * FROM FC_GIT_LDB_202409
	SELECT * FROM FC_GIT_FINAL_LDB_202409
*/
Alter proc sp_FC_GIT_New
	@Division		nvarchar(3),
	@FM_Key			Nvarchar(6),
	@Allow_Total	INT,
	@b_Success		Int				OUTPUT,
	@c_errmsg		Nvarchar(250)	OUTPUT
	with encryption
As
SET NOCOUNT ON
SET XACT_ABORT ON
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
		@b_Success1				Int,
		@c_errmsg1				Nvarchar(250)
		
	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_FC_GIT_New',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()
 
	select @debug=debug from fnc_debug('FC')
	--select @debug=1

	if @FM_Key=''
	begin
		select @FM_Key=format(GETDATE(),'yyyyMM')
	end

	if @debug>0
	begin
		select 'Insert tag name processing',@n_continue '@n_continue'
	end
	if @n_continue=1
	begin
		exec sp_add_TagName_Processing @division,'tag_gen_git',@b_Success1 OUT,@c_errmsg1 OUT
		if @b_Success1=0
		begin
			select @n_continue=3,@c_errmsg=@c_errmsg1
		end
	end

	if @debug>0
	begin
		select 'run sp_add_FC_GIT',@n_continue '@n_continue'
	end
	IF @n_continue = 1
	BEGIN
		--//import file GIT
		exec sp_add_FC_GIT @division,@FM_Key,@b_Success1 OUT,@c_errmsg1 OUT

		if @b_Success1=0
		begin
			select @n_continue = 3, @c_errmsg = @c_errmsg1
		end
	END
	if @debug>0
	begin
		select 'run sp_func_FC_GIT convert GIT',@n_continue '@n_continue'
	end
	if @n_continue=1
	begin
		exec sp_func_FC_GIT @Division,@FM_Key,@b_Success1 OUT,@c_errmsg1 OUT
		if @b_Success1=0
		begin
			select @n_continue = 3, @c_errmsg = @c_errmsg1
		end
	end
	if @debug>0
	begin
		select 'run sp_FC_GIT final',@n_continue '@n_continue'
	end
	IF @n_continue = 1
	BEGIN
		--//Tao table GIT dua vao function GIT
		exec sp_FC_GIT @division,@FM_Key,@b_Success1 OUT,@c_errmsg1 OUT

		if @b_Success1=0
		begin
			select @n_continue = 3, @c_errmsg = @c_errmsg1
		end
	END
	if @debug>0
	begin
		select 'run sp_tag_update_wf_git',@n_continue '@n_continue'
	end
	if @n_continue = 1
	begin
		--//update GIT into WF
		exec sp_tag_update_wf_git @Division,@FM_Key,@b_Success1 OUT, @c_errmsg1 OUT
		
		if @b_Success1 = 0
		begin
			select @n_continue = 3, @c_errmsg = @c_errmsg1
		end
	end
	if @debug>0
	begin
		select 'run sp_calculate_total',@n_continue '@n_continue'
	end
	if @n_continue=1
	begin
		if @Allow_Total>0
		begin
			exec sp_calculate_total @Division,@FM_Key,'git',@b_Success1 OUT,@c_errmsg1 OUT
			--select @b_Success b_Success,@c_errmsg c_errmsg
			if @b_Success1=0
			begin
				select @n_continue=3, @c_errmsg=@c_errmsg1
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
   select @n_continue = 3
   --ROLLBACK
   DECLARE @ErrorMessage VARCHAR(2000)
   SELECT @ErrorMessage = 'Error: '+ ERROR_MESSAGE()
   RAISERROR(@ErrorMessage , 16, 1)
END CATCH
