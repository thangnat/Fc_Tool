/*
	declare
		@b_Success			Int,
		@c_errmsg			Nvarchar(250)

	exec sp_Add_ZV14_Forecast_New 'PPD','',@b_Success OUT,@c_errmsg OUT

	select @b_Success b_Success,@c_errmsg c_errmsg

	select * from FC_CPD_ZV14_Historical where [FOC TYPE]<>''

	drop table FC_CPD_ZV14_Historical
*/

Alter Proc sp_Add_ZV14_Forecast_NEW
	@Division			Nvarchar(3),
	@FM_KEY				Nvarchar(6),
	@b_Success			Int				OUTPUT,     
	@c_errmsg			Nvarchar(250)	OUTPUT
As
SET NOCOUNT ON
SET XACT_ABORT ON
--BEGIN TRAN
BEGIN TRY
	DECLARE
		 @debug					INT=0
		,@sp_name				Nvarchar(100)
		,@n_continue			Int
		,@USERS					Nvarchar(50)
		,@MODIFILED				Datetime
		,@n_err					int
		,@sql					nvarchar(max)=''
	
	declare 
		@b_Success1				Int,
		@c_errmsg1				Nvarchar(250)

	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_Add_ZV14_Forecast_New',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	--send email catch up start processing...
	exec sp_SendEmail_Auto_Order_Process 'Convert_ZV14_from_SAP_TO_FM','Convert_ZV14_from_SAP_TO_FM','Start processing.../'
	
	select @debug=debug from fnc_debug('FC')
	--select @debug=1	
	
	if @FM_KEY=''
	begin
		select @FM_KEY=format(getdate(),'yyyyMM')
	end

	declare @table_fc_fm nvarchar(300)=''
	select @table_fc_fm='FC_FM_Original_'+@Division+'_'+@FM_KEY

	if @debug>0
	begin
		select 'sp_Add_ZV14_Forecast_2 raw data'
	end
	if @n_continue=1
	begin
		exec sp_Add_ZV14_Forecast_2 @Division,@FM_KEY,@b_Success1 OUT,@c_errmsg1 OUT
		if @b_Success1=0
		begin
			select @n_continue=3,@c_errmsg=@c_errmsg1
		end
	end

	if @debug>0
	begin
		select 'sp_Create_V_His_SI_Final(connect to master data)-->create data with forecasting line'
	end
	if @n_continue=9
	begin
		if exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID(@table_fc_fm) AND type in (N'U')
		)
		begin
			exec sp_Create_V_His_SI_Final @Division,@FM_KEY,'h',@b_Success1 OUT,@c_errmsg1 OUT

			if @b_Success1=0
			begin
				select @n_continue=3,@c_errmsg=@c_errmsg1
			end
		end
	end
	if @debug>0
	begin
		select 'sp_tag_update_wf_mtd_si_NEW'
	end
	if @n_continue=9
	begin
		if exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID(@table_fc_fm) AND type in (N'U')
		)
		begin
			exec sp_tag_update_wf_mtd_si_NEW @Division,@FM_KEY,1,@b_Success1 OUT, @c_errmsg1 OUT

			if @b_Success1=0
			begin
				select @n_continue=3,@c_errmsg=@c_errmsg1
			end
		end
	end
	
	if @n_continue = 3
	begin
		--rollback
		select @b_Success = 0
		exec sp_SendEmail_Auto_Order_Process 'Convert_ZV14_from_SAP_TO_FM','Convert_ZV14_from_SAP_TO_FM','Fail.../'
	end
	else
	begin
		--Commit
		select @b_Success = 1, @c_errmsg = 'Successfully.../'
		exec sp_SendEmail_Auto_Order_Process 'Convert_ZV14_from_SAP_TO_FM','Convert_ZV14_from_SAP_TO_FM','Successfully.../'
	end
END TRY
BEGIN CATCH
   --ROLLBACK
   DECLARE @ErrorMessage VARCHAR(2000)
   SELECT @ErrorMessage = 'Error: '+ ERROR_MESSAGE()
   RAISERROR(@ErrorMessage , 16, 1)
END CATCH