/*
	declare 
		@b_Success				Int	,
		@c_errmsg				Nvarchar(250)

	exec sp_set_FMKEY 'hoaiphuong.ho','202409',@b_Success OUT,@c_errmsg OUT

	select @b_Success b_Success,@c_errmsg c_errmsg

	select * from fc_computerName
*/

Alter Proc sp_set_FMKEY
	@Alias				nvarchar(30),
	@FM_KEY				nvarchar(6),
	@b_Success			Int				OUTPUT,     
	@c_errmsg			Nvarchar(250)	OUTPUT
	with encryption
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
		,@sql					nvarchar(max) = ''

	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_set_FMKEY',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()
	declare @host_name nvarchar(50)=''
	select @host_name=[ComputerName] from V_FC_ALIAS_COMPUTERNAME where [Alias]=@Alias

	if @n_continue=1
	begin
		if @host_name='' or @host_name is null
		begin
			select @n_continue = 3
			select @n_err=60001
			select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +':Host_Name invalid./ ('+@sp_name+')'
		end
	end
	if @n_continue=1
	begin
		if exists(select 1 from FC_ComputerName (NOLOCK) where ComputerName=@host_name)
		begin
			update FC_ComputerName
			set 
				UserID=@USERS,
				FM_KEY=@FM_KEY
			where ComputerName=@host_name
		end
		else
		begin
			insert into FC_ComputerName
			(
				ComputerName,
				FM_KEY,
				UserID
			)
			select
				@host_name,
				@FM_KEY,
				@USERS
		end

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
		select @b_Success = 1, @c_errmsg = 'Set FM_KEY Successfully.../'
	end
END TRY
BEGIN CATCH
   ROLLBACK
   DECLARE @ErrorMessage VARCHAR(2000)
   SELECT @ErrorMessage = 'Error: '+ ERROR_MESSAGE()
   RAISERROR(@ErrorMessage , 16, 1)
END CATCH