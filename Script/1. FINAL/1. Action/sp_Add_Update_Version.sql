/*
	declare 
		@b_Success				Int,   
		@c_errmsg				Nvarchar(250)

	exec sp_Add_Update_Version 'adminfc','FC',4,@b_Success OUT,@c_errmsg OUT

	select @b_Success b_Success,@c_errmsg c_errmsg
*/

Alter Proc sp_Add_Update_Version
	@Manv					nvarchar(20),
	@Application			nvarchar(50),
	@Hour					Int,--//1 hour, 2 hour, 4 hour...
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

	declare @timeUpdate_ok		datetime
			
	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_Add_Update_Version',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	select @timeUpdate_ok=DATEADD(HOUR,@Hour,getdate())

	if @n_continue = 1
	begin
		if not exists(select 1 from DM_NhanVien (NOLOCK) where MaNV = @Manv)
		begin
			select @n_continue = 3
			select @n_err=60001
			select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +':Manv invalid./ ('+@sp_name+')'
		end
	end
	if @n_continue = 1
	begin
		Update DM_NhanVien
		SET
			Time_Update=@timeUpdate_ok
		WHERE MaNV=@Manv

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