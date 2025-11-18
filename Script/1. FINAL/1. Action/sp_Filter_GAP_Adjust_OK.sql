/*
	declare 
		@b_Success				Int,
		@c_errmsg				Nvarchar(250)

	exec sp_Filter_GAP_Adjust_OK 'CPD','202408',@ID,'','',@b_Success OUT, @c_errmsg OUT

	select @b_Success '@b_Success',@c_errmsg '@c_errmsg'
*/

Alter proc sp_Filter_GAP_Adjust_OK
	@Division				nvarchar(3),
	@FM_KEY					nvarchar(6),
	@ID						nvarchar(20),
	@ColumnName				nvarchar(30),
	@Value					nvarchar(20),
	@b_Success				Int				OUTPUT,     
	@c_errmsg				Nvarchar(250)	OUTPUT
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
		,@fm_file_name			nvarchar(100) =''
		,@sql					nvarchar(max) = ''

	declare 
		@b_Success1				Int,
		@c_errmsg1				Nvarchar(250)

	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_Filter_GAP_Adjust_OK',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	select @debug=debug from fnc_debug('FC')	

	if @n_continue=1
	begin
		exec sp_Filter_GAP_Adjust @Division,@FM_KEY,@ID,@ColumnName,@Value,@b_Success1 OUT, @c_errmsg1 OUT
		if @b_Success1=0
		begin
			select @n_continue=3,@c_errmsg=@c_errmsg1
		end
	END
	if @n_continue=1
	begin
		exec sp_calculate_total @Division,@FM_KEY,'fc',@b_Success OUT,@c_errmsg OUT
		if @b_Success1=0
		begin
			select @n_continue=3,@c_errmsg=@c_errmsg1
		end
	end
	if @n_continue=1
	begin
		exec sp_tag_update_BP_unit_Filter_Adjust @Division,@FM_KEY,@b_Success OUT, @c_errmsg OUT
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
