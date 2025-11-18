/*
	declare 
		@b_Success				Int,
		@c_errmsg				Nvarchar(250)

	exec sp_tag_update_wf_sit_NEW 'LDB','202501',1,@b_Success OUT, @c_errmsg OUT

	select @b_Success b_Success, @c_errmsg c_errmsg
*/

Alter Proc sp_tag_update_wf_sit_NEW
	@Division				nvarchar(3),
	@FM_KEY					nvarchar(6),
	@AllowTotal				int,
	@b_Success				Int				OUTPUT,     
	@c_errmsg				Nvarchar(250)	OUTPUT
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

	declare 
		@b_Success1				Int,
		@c_errmsg1				Nvarchar(250)
			
	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_tag_update_wf_sit_NEW',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	select @debug=debug from fnc_debug('FC')

	if @FM_KEY=''
	begin
		select @FM_KEY=format(GETDATE(),'yyyyMM')
	end
	declare @Monthfc				nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from V_FC_FM_Table
	declare @table_FC_FM_Original nvarchar(200)=''
	select @table_FC_FM_Original='FC_FM_Original_'+@Division+@Monthfc

	if @n_continue=1
	begin
		if not exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID(@table_FC_FM_Original) AND type in (N'U')
		)
		begin
			select @n_continue=3,@c_errmsg='period key not contains table to Update.../'
		end
	end

	if @n_continue = 1
	begin
		exec sp_tag_update_wf_sit @Division,@FM_KEY,@b_Success1 OUT, @c_errmsg1 OUT
		if @b_Success1=0
		begin
			select @n_continue=3,@c_errmsg=@c_errmsg1
		end
	end	
	if @n_continue=1
	begin
		exec sp_tag_update_wf_sit_day @Division,@FM_KEY,@b_Success1 OUT, @c_errmsg1 OUT
		if @b_Success1=0
		begin
			select @n_continue=3,@c_errmsg=@c_errmsg1
		end
	end
	if @n_continue=1
	begin
		if @AllowTotal=1
		begin
			exec sp_calculate_total @Division,@FM_KEY,'SIT',@b_Success OUT,@c_errmsg OUT
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