/*
	exec sp_set_FMKEY 'hoaiphuong.ho','202410',0,''
	select * from FC_ComputerName

	Declare
		@b_Success			Int,
		@c_errmsg			Nvarchar(250)

	exec sp_fc_add_fnc_SubGroupMasterFull_New 'CPD','202502',@b_Success OUT,@c_errmsg OUT

	select @b_Success b_Success,@c_errmsg c_errmsg

	select * 
	from fnc_SubGroupMaster_Full_PPD
	where [FM_KEY]='202410'
	
	select * 
	from FC_SO_OPTIMUS_MAPPING_SUBGRP_PPD
	where [FM_KEY]='202410'
*/

Alter proc sp_fc_add_fnc_SubGroupMasterFull_New
	@Division		nvarchar(3),
	@FM_KEY			nvarchar(6),
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

	declare 
		@b_Success1				Int,
		@c_errmsg1				Nvarchar(250)

	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_fc_add_fnc_SubGroupMasterFull_New',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()		

	select @debug=debug from fnc_debug('FC')
	select @debug=1

	select @FM_KEY=(select top 1 FM_KEY from FC_ComputerName (NOLOCK) where [ComputerName]=HOST_NAME())
	--select FM_KEY=(select top 1 FM_KEY from FC_ComputerName (NOLOCK) where [ComputerName]=HOST_NAME())

	if @debug>0
	begin
		select 'Add subgroup master table'
	end
	if @n_continue=1
	begin
		exec sp_fc_add_fnc_SubGroupMasterFull @Division,@FM_KEY,@b_Success1 OUT,@c_errmsg1 OUT
		if @b_Success1=0
		begin
			select @n_continue=1, @c_errmsg = @c_errmsg1+'(Add subgroup master table)'
		end
	end

	if @debug>0
	begin
		select 'Add mapping subgroup master optimus table'
	end
	if @n_continue=1
	begin
		exec sp_add_FC_MAPPING_SUBGRP_OPTIMUS @Division,@FM_KEY,@b_Success1 OUT,@c_errmsg1 OUT
		
		if @b_Success1=0
		begin
			select @n_continue=1, @c_errmsg = @c_errmsg1+'(Add mapping subgroup master optimus table)'
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