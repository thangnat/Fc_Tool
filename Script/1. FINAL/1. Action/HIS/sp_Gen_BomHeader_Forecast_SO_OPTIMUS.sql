/*
	--only run for SI FC
	Declare
		@b_Success			Int,
		@c_errmsg			Nvarchar(250)

	exec sp_Gen_BomHeader_Forecast_SO_OPTIMUS 'LDB','2024067',@b_Success OUT,@c_errmsg OUT
	
	select @b_Success b_Success,@c_errmsg c_errmsg

	--//list
	1. SO_OPTIMUS
	select * from FC_SO_OPTIMUS_BomHeader_CPD-->No use

*/
Alter Proc sp_Gen_BomHeader_Forecast_SO_OPTIMUS
	@Division		nvarchar(3),
	@FM_Key			nvarchar(6),	
	@b_Success		Int				OUTPUT,     
	@c_errmsg		Nvarchar(250)	OUTPUT
	WITH ENCRYPTION
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

	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_Gen_BomHeader_Forecast_SO_OPTIMUS',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	select @debug=debug from fnc_debug('FC')
	
	Declare
		@b_Success1			Int,
		@c_errmsg1			Nvarchar(250)

	if @debug >0
	begin
		select @sp_name+'_1.1.1'
	end
	if @n_continue = 1
	begin
		--//import data from template excel file into datalake
		exec sp_add_FC_SI_Group @Division,@FM_Key,'FC_SO_OPTIMUS_Promo_Bom',@b_Success1 OUT,@c_errmsg1 OUT

		if @b_Success1 = 0
		begin
			select @n_continue = 3, @c_errmsg = @c_errmsg1
		end
	end
	if @debug >0
	begin
		select @sp_name+'_1.1.3', @n_continue '@n_continue'
	end
	if @n_continue = 1
	begin
		exec sp_Gen_BomHeader_Forecast_NEW @Division,@FM_Key,'SO_OPTIMUS',@b_Success1 OUT,@c_errmsg1 OUT

		if @b_Success1 = 0
		begin
			select @n_continue = 3, @c_errmsg = @c_errmsg1
		end
	end
	if @debug >0
	begin
		select @sp_name+'_1.1.4'
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