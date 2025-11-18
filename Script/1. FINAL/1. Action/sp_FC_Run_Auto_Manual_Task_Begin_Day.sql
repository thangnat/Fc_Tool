/*
	Declare 
		@b_Success		Int,
		@c_errmsg		Nvarchar(250)

	exec sp_FC_Run_Auto_Manual_Task_Begin_Day 'LDB','202502',1,@b_Success OUT,@c_errmsg OUT

	select @b_Success b_Success,@c_errmsg c_errmsg

	SELECT * FROM FC_GIT_LDB_202409
	SELECT * FROM FC_GIT_FINAL_LDB_202409
*/
Alter proc sp_FC_Run_Auto_Manual_Task_Begin_Day
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
		@sp_name = 'sp_FC_Run_Auto_Manual_Task_Begin_Day',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	--send email catch up Start import time
	--exec sp_SendEmail_Auto_Order_Process 'sp_FC_Run_Auto_Manual_Task_Begin_Day','sp_FC_Run_Auto_Manual_Task_Begin_Day','Start Processing.../'

	select @debug=debug from fnc_debug('FC')
	--select @debug=1

	if @FM_Key=''
	begin
		select @FM_Key=format(GETDATE(),'yyyyMM')
	end

	declare @Monthfc				nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from V_FC_FM_Table
	
	declare @table_FC_FM_Original nvarchar(200)=''
	select @table_FC_FM_Original='FC_FM_Original_'+@Division+@Monthfc

	if @debug>0
	begin
		select 'run SOH'
	end
	IF @n_continue=1
	BEGIN
		if exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID(@table_FC_FM_Original) AND type in (N'U')
		)
		begin
			exec sp_tag_gen_soh @Division,@FM_Key,@Allow_Total,@b_Success1 OUT,@c_errmsg1 OUT

			if @b_Success1=0
			begin
				select @n_continue = 1, @c_errmsg = @c_errmsg1
			end
		end
	END

	if @debug>0
	begin
		select 'run sp_Create_V_His_SI_Final'
	end
	if @n_continue=1
	begin
		if exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID(@table_FC_FM_Original) AND type in (N'U')
		)
		begin
			exec sp_Create_V_His_SI_Final @Division,@FM_KEY,'h',@b_Success1 OUT,@c_errmsg1 OUT

			if @b_Success1=0
			begin
				select @n_continue=1,@c_errmsg=@c_errmsg1
			end
		end
	end
	if @debug>0
	begin
		select 'run sp_tag_update_wf_mtd_si_NEW'
	end
	if @n_continue=1
	begin
		if exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID(@table_FC_FM_Original) AND type in (N'U')
		)
		begin
			exec sp_tag_update_wf_mtd_si_NEW @Division,@FM_KEY,1,@b_Success1 OUT, @c_errmsg1 OUT

			if @b_Success1=0
			begin
				select @n_continue=3,@c_errmsg=@c_errmsg1
			end
		end
	end
	
	
	if @debug>0
	begin
		select 'run sp_tag_update_wf_sit_NEW'
	end
	IF @n_continue=1
	BEGIN
		if exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID(@table_FC_FM_Original) AND type in (N'U')
		)
		begin
			exec sp_tag_update_wf_sit_NEW @Division,@FM_Key,@Allow_Total,@b_Success1 OUT, @c_errmsg1 OUT

			if @b_Success1=0
			begin
				select @n_continue = 1, @c_errmsg = @c_errmsg1
			end
		end
	END

	if @n_continue = 3
	begin
		--rollback
		select @b_Success = 0
		--exec sp_SendEmail_Auto_Order_Process 'sp_FC_Run_Auto_Manual_Task_Begin_Day','sp_FC_Run_Auto_Manual_Task_Begin_Day','Fail.../'
	end
	else
	begin
		--Commit
		select @b_Success = 1, @c_errmsg = 'Successfully.../'
		--exec sp_SendEmail_Auto_Order_Process 'sp_FC_Run_Auto_Manual_Task_Begin_Day','sp_FC_Run_Auto_Manual_Task_Begin_Day','Successfully.../'
	end

END TRY
BEGIN CATCH
   select @n_continue = 3
   --ROLLBACK
   DECLARE @ErrorMessage VARCHAR(2000)
   SELECT @ErrorMessage = 'Error: '+ ERROR_MESSAGE()
   RAISERROR(@ErrorMessage , 16, 1)
END CATCH
