/*
	Declare
		@b_Success			Int,
		@c_errmsg			Nvarchar(250)

	exec sp_tag_gen_fm_non_modeling_new 'LLD','202410','full',1,@b_Success OUT,@c_errmsg OUT

	select @b_Success b_Success,@c_errmsg c_errmsg
*/
Alter proc sp_tag_gen_fm_non_modeling_new
	@Division			nvarchar(3),
	@FM_KEY				Nvarchar(6),
	@Type				nvarchar(4),--//Type: full or active =''
	@AllowTotal			int,--//Cho phep tinh total & O+O
	@b_Success			Int				OUTPUT,     
	@c_errmsg			Nvarchar(250)	OUTPUT
	with encryption
AS
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
		@sp_name = 'sp_tag_gen_fm_non_modeling_new',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	select @debug=debug from fnc_debug('FC')
	--select @debug=1
	
	--declare @Monthfc				nvarchar(20)=''
	--select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from V_FC_FM_Table

	declare @fm_file_name			nvarchar(100) =''
	select @fm_file_name = @Division+'_FM_Non_Modeling_'+@FM_Key+'.xlsx'
	
	if @debug>0
	begin
		select 'Insert tag name processing'
	end
	if @n_continue=1
	begin
		exec sp_add_TagName_Processing @division,'tag_gen_fm_non_modeling',@b_Success1 OUT,@c_errmsg1 OUT
		if @b_Success1=0
		begin
			select @n_continue=3,@c_errmsg=@c_errmsg1
		end
	end

	if @n_continue = 1
	begin
		exec sp_tag_gen_fm_non_modeling @Division,@FM_KEY,@Type,@b_Success1 OUT,@c_errmsg1 OUT
		if @b_Success1 = 0
		begin
			select @n_continue = 3, @c_errmsg = @c_errmsg1
		end
	end
	if @n_continue = 1
	begin
		exec sp_tag_update_wf_FM_Non_Modeling_unit @Division,@FM_KEY,@b_Success1 OUT, @c_errmsg1 OUT

		if @b_Success1 = 0
		begin
			select @n_continue = 3, @c_errmsg = @c_errmsg1
		end
	end
	if @n_continue = 1
	begin
		exec sp_Gen_WF_Value_Period @Division,@FM_KEY,'VALUE','fc',@b_Success OUT, @c_errmsg OUT

		if @b_Success1 = 0
		begin
			select @n_continue = 3, @c_errmsg = @c_errmsg1
		end
	end
	IF @n_continue = 1
	BEGIN
		exec sp_tag_update_wf_fc_02_years_Timeseries_value @Division,@FM_KEY,'all',@b_Success OUT, @c_errmsg OUT

		if @b_Success1 = 0
		begin
			select @n_continue = 3, @c_errmsg = @c_errmsg1
		end
	END
	if @n_continue = 1
	begin
		if @AllowTotal>0
		begin
			exec sp_calculate_total  @Division,@FM_Key,'fc',@b_Success1 OUT,@c_errmsg1 OUT

			if @b_Success1 = 0
			begin
				select @n_continue = 3, @c_errmsg = @c_errmsg1
			end
		end
	end
	if @debug>0
	begin
		select 'Mismatch'
	end
	if @n_continue=1
	begin
		if @Division NOT IN('PPD1')
		begin
			exec sp_FM_NON_MODELLING_validate_mismatch @Division,@FM_KEY,@b_Success1 OUT, @c_errmsg1 OUT

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