/*
	declare 
		@b_Success				int,
		@c_errmsg				Nvarchar(250)	

	exec sp_change_password_Login 'adminfc','12345',@b_Success OUT, @c_errmsg OUT

	select @b_Success b_Success, @c_errmsg c_errmsg
*/

Alter proc sp_change_password_Login
	@UserID			varchar(50),
	@Password		varchar(50),
	@Repasswrod		varchar(50),
	@b_Success			Int				OUTPUT,     
	@c_errmsg			Nvarchar(250)	OUTPUT
	with encryption
AS
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
		,@sql					nvarchar(max) = ''

	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_change_password_Login',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	select @debug=debug from fnc_debug('FC')
	select @debug=1

	declare @password_ok		varchar(50)=''

	if @n_continue=1
	begin
		if @Password<>@Repasswrod
		begin
			select @n_continue = 3
			select @n_err=60011
			select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +':Password & re-password not match./ ('+@sp_name+')'
		end
	end
	if @n_continue=1
	begin
		select @password_ok=convert(varchar(50),HashBytes('MD5', @Password),2)

		if @password_ok is null
		begin
			select @password_ok=''
		end

		if @password_ok=''
		begin
			select @n_continue = 3
			select @n_err=60001
			select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +':Password invalid./ ('+@sp_name+')'
		end
	end
	if @n_continue=1
	begin
		update DM_NhanVien
			set Password=@password_ok
		where MaNV=@UserID

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