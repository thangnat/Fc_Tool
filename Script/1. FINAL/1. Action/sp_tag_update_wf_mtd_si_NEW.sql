/*
	declare 
		@b_Success				Int,
		@c_errmsg				Nvarchar(250)

	exec sp_tag_update_wf_mtd_si_new 'CPD','202412',1,@b_Success OUT, @c_errmsg OUT

	select @b_Success b_Success, @c_errmsg c_errmsg
*/

Alter Proc sp_tag_update_wf_mtd_si_NEW
	@Division				nvarchar(3),
	@FM_KEY					nvarchar(6),
	@AllowTotal				int,--//1,0
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
		,@sql					nvarchar(max) = ''

	declare 
		@b_Success1				Int,
		@c_errmsg1				Nvarchar(250)
			
	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_tag_update_wf_mtd_si',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	select @debug=debug from fnc_debug('FC')
	if @FM_KEY=''
	begin
		select @FM_KEY=format(getdate(),'yyyyMM')
	end
	declare @Monthfc				nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from V_FC_FM_Table
	declare @table_FC_FM_Original nvarchar(200)=''
	select @table_FC_FM_Original='FC_FM_Original_'+@Division+@Monthfc
	
	if @n_continue = 1
	begin
		if exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID(@table_FC_FM_Original) AND type in (N'U')
		)
		begin
			exec sp_tag_update_wf_mtd_si @Division,@FM_KEY,@b_Success1 OUT, @c_errmsg1 OUT
			if @b_Success1=0
			BEGIN
				SELECT @n_continue=3, @c_errmsg=@c_errmsg1
			END
		end
		
	end	
	if @n_continue = 1
	begin
		if exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID(@table_FC_FM_Original) AND type in (N'U')
		)
		begin
			if @AllowTotal>0
			begin
				exec sp_calculate_total @Division,@FM_Key,'mtd_si',@b_Success1 OUT,@c_errmsg1 OUT

				if @b_Success1 = 0
				begin
					select @n_continue = 3, @c_errmsg = @c_errmsg1
				end
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