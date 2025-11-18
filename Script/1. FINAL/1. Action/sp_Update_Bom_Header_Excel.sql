/*
	declare 
		@b_Success		Int,
		@c_errmsg		Nvarchar(250)

	exec sp_Update_Bom_Header_Excel 'CPD','202407',@b_Success OUT,@c_errmsg OUT

	select @b_Success b_Success,@c_errmsg c_errmsg
*/

Alter Proc sp_Update_Bom_Header_Excel
	@Division				Nvarchar(3),
	@FM_KEY					nvarchar(6),
	@b_Success				Int				OUTPUT,     
	@c_errmsg				Nvarchar(250)	OUTPUT
As
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRAN
BEGIN TRY
	DECLARE   
		 @debug					int=0
		,@sp_name				Nvarchar(100)
		,@n_continue			Int
		,@USERS					Nvarchar(50)
		,@MODIFILED				Datetime
		,@n_err					int
		,@sql					nvarchar(max) = ''
			
	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_Update_Bom_Header_Excel',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	select @debug=debug from fnc_debug('FC')
	select @debug=1

	declare @Monthfc				nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from V_FC_FM_Table

	declare @listColumn nvarchar(max)=''
	SELECT @listColumn=ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'updateForecast','t')
	--SELECT listColumn=ListColumn FROM fn_FC_GetColheader_Current('202407','updateForecast','t')
	
	if @n_continue = 1
	begin
		select @sql = 
		'Update FC_BomHeader_'+@Division+@Monthfc+' 
			set '+@listColumn+'
		from FC_BomHeader_'+@Division+@Monthfc+' b
		Inner join FC_BomHeader_'+@Division+@Monthfc+'_Excel_Tmp t on t.[Bundle Code]=b.[SAP Code] and t.Channel = b.Channel'

		if @debug>0
		begin
			select @sql '@sql Update Bom header'
		end
		execute(@sql)

		select @n_err = @@ERROR
		if @n_err<>0
		begin
			select @n_continue = 3
			--select @n_err=60003
			select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +ERROR_MESSAGE()+'./ ('+@sp_name+')'
		end
	end	
	
	if @n_continue = 3
	begin
		rollback
		select @b_Success = 0
	end
	else
	begin
		Commit
		select @b_Success = 1, @c_errmsg = 'Successfully.../'
	end
END TRY
BEGIN CATCH
   ROLLBACK
   DECLARE @ErrorMessage VARCHAR(2000)
   SELECT @ErrorMessage = 'Error: '+ ERROR_MESSAGE()
   RAISERROR(@ErrorMessage , 16, 1)
END CATCH