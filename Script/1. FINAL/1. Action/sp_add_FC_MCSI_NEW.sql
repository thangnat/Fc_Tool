/*
	Declare
		@b_Success			Int,
		@c_errmsg			Nvarchar(250)

	exec sp_add_FC_MCSI_NEW 'PPD','202410',@b_Success OUT,@c_errmsg OUT

	select @b_Success b_Success,@c_errmsg c_errmsg

	select distinct [Month] from FC_MCSI_LLD
	select distinct [Month] from FC_MCSI_PPD ORDER BY cast(left([Month],2) as int) asc
	select * from FC_MCSI_CPD
	
	/*
		truncate table FC_MCSI_LLD
	*/
	
*/

Alter proc sp_add_FC_MCSI_NEW
	@Division			nvarchar(3),
	@FM_KEY				nvarchar(6),
	@b_Success			Int				OUTPUT,     
	@c_errmsg			Nvarchar(250)	OUTPUT
	with encryption
AS
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
		,@sql					nvarchar(max)=''
		,@tablename				nvarchar(100)=''

	declare 
		@b_Success1			Int,
		@c_errmsg1			Nvarchar(250)

	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_add_FC_MCSI_NEW',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	select @debug=debug from fnc_debug('FC')
	--select @debug=1

	IF @debug>0
	BEGIN
		SELECT 'get fm key'
	END
	if @FM_KEY = ''
	begin
		select @FM_KEY = format(GETDATE(),'yyyyMM')
	end

	--if @debug>0
	--begin
	--	select 'set month forecast for VNCORPVNSC1 run background'
	--end
	--if @n_continue=1
	--begin
	--	--select * from FC_ComputerName
	--	exec sp_set_FMKEY 'link_33',@FM_KEY,0,''
	--end

	IF @debug>0
	BEGIN
		SELECT 'sp_add_FC_MCSI'
	END
	if @n_continue =1
	begin
		exec sp_add_FC_MCSI @Division,@b_Success1 OUT,@c_errmsg1 OUT

		if @b_Success1 = 0
		begin
			select @n_continue = 1, @c_errmsg = @c_errmsg1
		end
	end

	IF @debug>0
	BEGIN
		SELECT 'sp_create_FC_MCSI'
	END
	if @n_continue =9
	begin
		
		if len(@FM_KEY)=6
		begin
			exec sp_fc_add_fnc_SubGroupMasterFull_New @Division,@FM_KEY,@b_Success1 OUT,@c_errmsg1 OUT
			if @b_Success1>0
			begin
				if exists
				(
					select 1 from fnc_SubGroupMaster(@Division,'full')
				)
				begin
					exec sp_create_FC_MCSI @Division,@FM_KEY,@b_Success1 OUT,@c_errmsg1 OUT

					if @b_Success1 = 0
					begin
						select @n_continue = 3, @c_errmsg = @c_errmsg1
					end
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