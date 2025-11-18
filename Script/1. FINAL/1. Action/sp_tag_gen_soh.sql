/*
	Declare
		@b_Success			Int,
		@c_errmsg			Nvarchar(250)

	exec sp_tag_gen_soh 'CPD','202412',1,@b_Success OUT,@c_errmsg OUT

	select @b_Success b_Success,@c_errmsg c_errmsg
*/
Alter proc sp_tag_gen_soh
	@Division			nvarchar(3),
	@FM_KEY				nvarchar(6),
	@Allow_Total		INT,
	@b_Success			Int				OUTPUT,     
	@c_errmsg			Nvarchar(250)	OUTPUT
	with encryption
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

	Declare
		@b_Success1				Int,
		@c_errmsg1				Nvarchar(250)
			
	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_tag_gen_soh',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	select @debug=debug from fnc_debug('FC')
	--select @debug=1

	if @n_continue=1
	begin
		if @FM_KEY=''
		begin
			select @FM_KEY=format(getdate(),'yyyyMM')
		end
		if @FM_KEY=''
		begin
			select @n_continue=3,@c_errmsg='FM_KEY = null, can not auto run'
		end
	end
	if @debug>0
	begin
		select 'Create table SOH final'
	end	
	if @n_continue = 1
	begin
		exec sp_Create_SOH_FINAL @Division,@FM_KEY,'full',@b_Success1 OUT,@c_errmsg1 OUT

		if @b_Success1 = 0
		begin
			select @n_continue = 3, @c_errmsg = @c_errmsg1
		end
	end
	if @debug>0
	begin
		select 'Update table soh final into WF'
	end
	if @n_continue = 1
	begin
		exec sp_tag_update_wf_soh @Division,@FM_KEY,@b_Success1 OUT, @c_errmsg1 OUT

		if @b_Success1 = 0
		begin
			select @n_continue = 3, @c_errmsg = @c_errmsg1
		end
	end
	if @debug>0
	begin
		select 'run sp_calculate_total'
	end
	if @n_continue=1
	begin
		if @Allow_Total>0
		begin
			exec sp_calculate_total @Division,@FM_Key,'soh',@b_Success1 OUT,@c_errmsg1 OUT
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
   --ROLLBACK
   DECLARE @ErrorMessage VARCHAR(2000)
   SELECT @ErrorMessage = 'Error: '+ ERROR_MESSAGE()
   RAISERROR(@ErrorMessage , 16, 1)
END CATCH


