/*
	Declare
		@b_Success			Int,
		@c_errmsg			Nvarchar(250)

	exec sp_FC_SO_HIS_FINAL_NEW 'PPD','202409','full',@b_Success OUT,@c_errmsg OUT

	select @b_Success b_Success,@c_errmsg c_errmsg

	select * from FC_FM_Original_LDB order by ID asc
*/
Alter Proc sp_FC_SO_HIS_FINAL_NEW
	@Division		nvarchar(3),
	@periodKey		Nvarchar(6),
	@Type			Nvarchar(4),--//Type: full or active = ''
	@b_Success		Int		OUT,
	@c_errmsg		Nvarchar(250)	OUT
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
		,@FM_KEY				nvarchar(6)=''
	
	declare 
		@b_Success1				Int,
		@c_errmsg1				Nvarchar(250)

	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_FC_SO_HIS_FINAL_NEW',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	select @debug=debug from fnc_debug('FC')
	--select @debug=1

	select @FM_KEY=left(@periodKey,4)+format((cast(right(@periodKey,2) as int)+1),'00')

	if @n_continue=1
	begin
		exec sp_FC_SO_HIS_FINAL @Division,@periodKey,@b_Success1 OUT,@c_errmsg1 OUT

		if @b_Success1=0
		begin
			select @n_continue=3,@c_errmsg=@c_errmsg1
		end
	end

	if @n_continue=1
	begin
		exec sp_tag_update_wf_sit_NEW @Division,@FM_KEY,1,@b_Success1 OUT, @c_errmsg1 OUT

		if @b_Success1=0
		begin
			select @n_continue=3,@c_errmsg=@c_errmsg1
		end
	end
	if @debug>0
	begin
		select 'Mismatch'
	end
	if @n_continue=1
	begin
		if @Division NOT IN('PPD1')
		begin
			exec sp_SO_HIS_validate_mismatch @Division,@FM_KEY,@b_Success1 OUT, @c_errmsg1 OUT

			if @b_Success1 = 0
			begin
				select @n_continue = 1, @c_errmsg = @c_errmsg1
			end
		END
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


