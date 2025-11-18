/*
	Declare
		@b_Success			Int,
		@c_errmsg			Nvarchar(250)

	exec sp_FC_FM_Export_Excel_File_OK 'CPD','202406','Baseline Qty','',@b_Success OUT,@c_errmsg OUT

	select @b_Success b_Success,@c_errmsg c_errmsg

	/*
	Baseline Qty
	Promo Qty
	Component Qty
	Launch Qty
	FOC Qty
	*/
	select * from FC_Spectrum_cpd
*/
Alter proc sp_FC_FM_Export_Excel_File_OK
	@Division			Nvarchar(3),
	@FMKEY				nvarchar(6),
	@Timeseries			Nvarchar(20),
	@Subgrp				nvarchar(200),
	@b_Success			Int				OUTPUT,     
	@c_errmsg			Nvarchar(250)	OUTPUT
	with encryption
AS
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRY
	DECLARE   
		 @debug					int = 0
		,@sp_name				Nvarchar(100)
		,@n_continue			Int
		,@USERS					Nvarchar(50)
		,@MODIFILED				Datetime
		,@n_err					int
		,@fm_file_name			nvarchar(100) =''
		--,@Timeseries_ok			nvarchar(30) = ''
		,@DbName NVARCHAR(20)

	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_FC_FM_Export_Excel_File_OK',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	-- Get the environment configuration
	SELECT @DbName = CASE 
		WHEN Value = 'Production' THEN 'master.dbo'
		ELSE 'master_UAT'
	END
	FROM EnvironmentConfig
	WHERE Name = 'Current_Environment'

	declare @sql nvarchar(max) = ''	

	--select TOP 1
	--	@Timeseries_ok = MAP 
	--from v_FC_TIME_SERIES 
	--where TimeSeries = @Timeseries

	if @n_continue = 1
	begin
		--//add tmp table
		declare
			@b_Success1			Int,
			@c_errmsg1			Nvarchar(250)

			if @DbName = 'master.dbo'
				exec link_37.master.dbo.sp_FC_FM_Export_Excel_File @Division,@FMKEY,@Timeseries,@Subgrp,@b_Success OUT,@c_errmsg OUT
			ELSE
				exec link_37.master_UAT.dbo.sp_FC_FM_Export_Excel_File @Division,@FMKEY,@Timeseries,@Subgrp,@b_Success OUT,@c_errmsg OUT

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