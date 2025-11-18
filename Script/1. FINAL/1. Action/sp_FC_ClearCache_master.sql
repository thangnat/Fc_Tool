use master
Go
/*
	declare
		@b_Success				Int,
		@c_errmsg				Nvarchar(250)

	exec sp_FC_ClearCache_master 'LDB',@b_Success OUT,@c_errmsg OUT

	select @b_Success b_Success,@c_errmsg c_errmsg
*/

Alter Proc sp_FC_ClearCache_master
	@Division				nvarchar(3),
	@b_Success				Int				OUTPUT,     
	@c_errmsg				Nvarchar(250)	OUTPUT
As
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRAN
BEGIN TRY
	DECLARE   
		 @sp_name				Nvarchar(100)
		,@n_continue			Int
		,@USERS					Nvarchar(50)
		,@MODIFILED				Datetime
		,@n_err					int
			
	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_FC_ClearCache_master',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	if @n_continue = 1
	begin
		if @Division='LLD'
		begin
			Delete FC_FM_Original_LLD
			where Backup_Time IN
			(
				select
					Backup_Time 
				from
				(
					select distinct Backup_Time 
					from FC_FM_Original_LLD (NOLOCK)
					where cast(Backup_Time as date)<cast(DATEADD(DD,-3,getdate()) as date)
				) x
				--order by Backup_Time desc
			)
		end
		else if @Division='CPD'
		begin
			Delete FC_FM_Original_CPD
			where Backup_Time IN
			(
				select
					Backup_Time 
				from
				(
					select distinct Backup_Time 
					from FC_FM_Original_CPD (NOLOCK)
					where cast(Backup_Time as date)<cast(DATEADD(DD,-3,getdate()) as date)
				) x
				--order by Backup_Time desc
			)
		end
		else if @Division='LDB'
		begin
			Delete FC_FM_Original_LDB
			where Backup_Time IN
			(
				select
					Backup_Time 
				from
				(
					select distinct Backup_Time 
					from FC_FM_Original_LDB (NOLOCK)
					where cast(Backup_Time as date)<cast(DATEADD(DD,-3,getdate()) as date)
				) x
				--order by Backup_Time desc
			)
		end

		select @n_err = @@ERROR
		if @n_err<>0
		begin
			select @n_continue = 3
			--select @n_err=60003
			select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +ERROR_MESSAGE()+'./ ('+@sp_name+')'
		end
	end	
	if @n_continue = 1
	begin
		if @Division='LLD'
		begin
			Delete FC_FM_Original_LLD_FC
			where Backup_Time IN
			(
				select
					Backup_Time 
				from
				(
					select distinct Backup_Time 
					from FC_FM_Original_LLD_FC (NOLOCK)
					where cast(Backup_Time as date)<cast(DATEADD(DD,-3,getdate()) as date)
				) x
				--order by Backup_Time desc
			)
		end
		else if @Division='CPD'
		begin
			Delete FC_FM_Original_CPD_FC
			where Backup_Time IN
			(
				select
					Backup_Time 
				from
				(
					select distinct Backup_Time 
					from FC_FM_Original_CPD_FC (NOLOCK)
					where cast(Backup_Time as date)<cast(DATEADD(DD,-3,getdate()) as date)
				) x
				--order by Backup_Time desc
			)
		end
		else if @Division='LDB'
		begin
			Delete FC_FM_Original_LDB_FC
			where Backup_Time IN
			(
				select
					Backup_Time 
				from
				(
					select distinct Backup_Time 
					from FC_FM_Original_LDB_FC (NOLOCK)
					where cast(Backup_Time as date)<cast(DATEADD(DD,-3,getdate()) as date)
				) x
				--order by Backup_Time desc
			)
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
		select @b_Success = 1, @c_errmsg = 'Successfully.../'
	end
END TRY
BEGIN CATCH
   ROLLBACK
   DECLARE @ErrorMessage VARCHAR(2000)
   SELECT @ErrorMessage = 'Error: '+ ERROR_MESSAGE()
   RAISERROR(@ErrorMessage , 16, 1)
END CATCH