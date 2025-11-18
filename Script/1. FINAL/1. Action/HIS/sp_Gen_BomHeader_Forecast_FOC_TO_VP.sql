/*
	Declare
		@b_Success			Int,
		@c_errmsg			Nvarchar(250)

	exec sp_Gen_BomHeader_Forecast_FOC_TO_VP 'CPD','202408',@b_Success OUT,@c_errmsg OUT
	
	select @b_Success b_Success,@c_errmsg c_errmsg
	--//list
	1. FDR
	2. FOC_TO_VP
	3. ''-->BOM_HEADER
	4. SO_OPTIMUS

	SELECT * FROM FC_BOMHEADER_CPD
	SELECT * FROM FC_BOMHEADER_FDR_LLD 	
	select * from FC_FDR_FOC_TO_VP_LLD
	select * from FC_SO_OPTIMUS_BomHeader_LLD

*/
Alter Proc sp_Gen_BomHeader_Forecast_FOC_TO_VP
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

	Declare
		@b_Success1				Int,
		@c_errmsg1				Nvarchar(250)

	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_Gen_BomHeader_Forecast_FOC_TO_VP',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()
	
	select @debug=debug from fnc_debug('FC')

	if @n_continue = 1
	begin
		exec sp_Gen_BomHeader_Forecast_new @Division,@FM_Key,'FOC_TO_VP',@b_Success1 OUT,@c_errmsg1 OUT

		if @b_Success1 = 0
		begin
			select @n_continue = 3, @c_errmsg = @c_errmsg1
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