/*
	Declare
		@b_Success			Int,
		@c_errmsg			Nvarchar(250)

	exec sp_FC_FM_Original_NEW_FINAL 'LDB','202501','full',@b_Success OUT,@c_errmsg OUT

	select @b_Success b_Success,@c_errmsg c_errmsg

	select * from FC_FM_Original_PPD_202410 order by ID asc
*/
Alter Proc sp_FC_FM_Original_NEW_FINAL
	@Division		nvarchar(3),
	@FM_Key			Nvarchar(6),
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
	
	declare 
		@b_Success1				Int,
		@c_errmsg1				Nvarchar(250)

	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_FC_FM_Original_NEW_FINAL',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	select @debug=debug from fnc_debug('FC')
	--select @debug=1

	declare @Monthfc			nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from V_FC_FM_Table

	declare @tablename nvarchar(200)=''
	select @tablename='FC_FM_Original_'+@Division+'_'+left(@FM_Key,4)+format(casT(right(@FM_Key,2) as int)-1,'00')

	if @debug>0
	begin
		select @tablename '@tablename'
	end

	if @debug>0
	begin
		select 'sp_FC_FM_Original_NEW'
	end
	if @n_continue=1
	begin
		exec sp_FC_FM_Original_NEW @Division,@FM_Key,@Type,@b_Success1 OUT,@c_errmsg1 OUT

		if @b_Success1=0
		begin
			select @n_continue=3,@c_errmsg=@c_errmsg1
		end
	end
	if @debug>0
	begin
		select 'sp_tag_update_wf_ver_m_1'
	end
	if @n_continue=1
	begin
		if exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID(@tablename) AND type in (N'U')
		)
		begin
			exec sp_tag_update_wf_ver_m_1 @Division,@FM_KEY,@b_Success1 OUT, @c_errmsg1 OUT

			if @b_Success1=0
			begin
				select @n_continue=3,@c_errmsg=@c_errmsg1
			end
		end
		else
		begin
			select 'the first month'
		end
	end
	if @debug>0
	begin
		select 'sp_tag_update_wf_pass_02_years_new'
	end
	if @n_continue=9
	begin
		exec sp_tag_update_wf_pass_02_years_new @Division,@FM_KEY,0,@b_Success1 OUT, @c_errmsg1 OUT

		if @b_Success1=0
		begin
			select @n_continue=3,@c_errmsg=@c_errmsg1
		end
	end
	if @debug>0
	begin
		select 'sp_Gen_BomHeader_Forecast_FDR'
	end
	if @n_continue=1
	begin
		exec sp_Gen_BomHeader_Forecast_FDR @Division,@FM_KEY,@b_Success1 OUT,@c_errmsg1 OUT

		if @b_Success1=0
		begin
			select @n_continue=3,@c_errmsg=@c_errmsg1
		end
	end
	if @debug>0
	begin
		select 'sp_Gen_BomHeader_Forecast_FOC_TO_VP'
	end
	if @n_continue=1
	begin
		exec sp_Gen_BomHeader_Forecast_FOC_TO_VP @Division,@FM_KEY,@b_Success1 OUT,@c_errmsg1 OUT

		if @b_Success1=0
		begin
			select @n_continue=3,@c_errmsg=@c_errmsg1
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


