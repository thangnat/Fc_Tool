/*
	Declare
		@b_Success			Int,
		@c_errmsg			Nvarchar(250)

	exec sp_Sum_FC_FM_baseLine_new 'LDB','202502',1,@b_Success OUT,@c_errmsg OUT

	select @b_Success b_Success,@c_errmsg c_errmsg
	
	select * from FC_FM_SUM_BASELINE_CPD_202408
	select * from FC_FM_SUM_BASELINE_LLD

	select * from FC_LIST_BOM_HEADER_OFFLINE_CPD
	select * from FC_LIST_BOM_HEADER_ONLINE_CPD
*/

Alter proc sp_Sum_FC_FM_baseLine_new
	@Division		nvarchar(3),
	@FM_KEY			nvarchar(6),
	@AllowTotal		int,
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
	
	declare 
		@b_Success1				Int,     
		@c_errmsg1				Nvarchar(250)

	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_Sum_FC_FM_baseLine_new',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	select @debug=debug from fnc_debug('FC')
	select @debug=1

	declare @Monthfc			nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from V_FC_FM_Table
	if @debug>0
	begin
		select Monthfc=replace([Month FC],'_@Month_FC','_'+'202408') from V_FC_FM_Table
	end
	
	if @debug>0
	begin
		select 'Insert tag name processing',@n_continue '@n_continue'
	end
	if @n_continue=1
	begin
		exec sp_add_TagName_Processing @division,'tag_gen_FM_FC_SI_BASELINE',@b_Success1 OUT,@c_errmsg1 OUT
		if @b_Success1=0
		begin
			select @n_continue=3,@c_errmsg=@c_errmsg1
		end
	end
	if @debug>0
	begin
		select 'Import data FM modelling'
	end
	if @n_continue = 1
	begin
		exec sp_add_FC_Master_File_FM @Division,@FM_Key,@b_Success1 OUT,@c_errmsg1 OUT

		if @b_Success1 = 0
		begin
			select @n_continue = 3, @c_errmsg = @c_errmsg1
		end
	end
	if @debug>0
	begin
		select 'get data FM had imported to create standard data',@n_continue '@n_continue'
	end
	if @n_continue = 1
	begin
		--get data FM had imported to create standard data
		exec sp_Sum_FC_FM_baseLine @Division,@FM_KEY,'full','SINGLE_ALL',@b_Success OUT,@c_errmsg OUT

		if @b_Success1 = 0
		begin
			select @n_continue = 3, @c_errmsg = @c_errmsg1
		end
	end
	if @debug>0
	begin
		select 'tien hanh update FM to wf',@n_continue '@n_continue'
	end
	IF @n_continue = 1
	BEGIN
		--tien hanh update FM to wf
		EXEC sp_tag_update_wf_FM_unit @Division,@FM_KEY,@b_Success1 OUT,@c_errmsg1 OUT

		if @b_Success1 = 0
		begin
			select @n_continue = 3, @c_errmsg = @c_errmsg1
		end
	END

	if @debug>0
	begin
		select 'lay unit fc tao table value',@n_continue '@n_continue'
	end
	if @n_continue = 1
	begin
		--lay unit fc tao table value
		exec sp_Gen_WF_Value_Period @Division,@FM_KEY,'VALUE','fc',@b_Success OUT, @c_errmsg OUT

		if @b_Success1 = 0
		begin
			select @n_continue = 3, @c_errmsg = @c_errmsg1
		end
	end
	if @debug>0
	begin
		select 'update table value to wf fc',@n_continue '@n_continue'
	end
	IF @n_continue = 1
	BEGIN
		--update table value to wf fc
		exec sp_tag_update_wf_fc_02_years_Timeseries_Value @Division,@FM_KEY,'all',@b_Success OUT, @c_errmsg OUT

		if @b_Success1 = 0
		begin
			select @n_continue = 3, @c_errmsg = @c_errmsg1
		end
	END
	
	if @debug>0
	begin
		select 'calculation total+O_O',@n_continue '@n_continue'
	end
	if @n_continue = 1
	begin
		if @AllowTotal>0
		begin
			exec sp_calculate_total @Division,@FM_Key,'fc',@b_Success1 OUT,@c_errmsg1 OUT

			if @b_Success1 = 0
			begin
				select @n_continue = 3, @c_errmsg = @c_errmsg1
			end
		end
	end
	if @debug>0
	begin
		select 'Mismatch',@n_continue '@n_continue'
	end
	if @n_continue=1
	begin
		if @Division NOT IN('PPD1')
		begin
			exec sp_FM_validate_mismatch @Division,@FM_KEY,@b_Success1 OUT, @c_errmsg1 OUT

			if @b_Success1 = 0
			begin
				select @n_continue = 1, @c_errmsg = @c_errmsg1
			end
		END
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

