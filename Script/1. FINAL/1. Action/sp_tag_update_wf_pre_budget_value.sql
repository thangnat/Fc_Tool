/*
	declare 
		@b_Success				Int,
		@c_errmsg				Nvarchar(250)

	exec sp_tag_update_wf_pre_budget_value 'CPD','202404',@b_Success OUT, @c_errmsg OUT

	select @b_Success b_Success, @c_errmsg c_errmsg
*/

Alter Proc sp_tag_update_wf_pre_budget_value
	@Division				nvarchar(3),
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
		@sp_name = 'sp_tag_update_wf_pre_budget_value',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	select @debug=debug from fnc_debug('FC')

	if @n_continue=1
	begin
		declare @Monthfc				nvarchar(20)=''
		select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from V_FC_FM_Table

		declare @FC_FM_Original			nvarchar(100) = ''
		select @FC_FM_Original = 'FC_FM_Original_'+@Division+@Monthfc	
	
		declare @FC_FM_Original_value	nvarchar(200) = ''
		select @FC_FM_Original_value = @FC_FM_Original+'_pre_budget'
		--prebudget value
		declare @List_pre_Budget_value_zero		nvarchar(max)=''
		SELECT @List_pre_Budget_value_zero = ListColumn FROM fn_FC_GetColheader_Current_BT(@FM_KEY,'','PB',21)
		--SELECT List_Budget_value_zero = ListColumn FROM fn_FC_GetColheader_Current_BT('202408','','PB',21)

		declare @list_Prebudget_Value nvarchar(max) = ''
		SELECT @list_Prebudget_Value = ListColumn FROM fn_FC_GetColheader_Current_BT(@FM_KEY,'si','PB',23)
		--SELECT list_Prebudget_Value = ListColumn FROM fn_FC_GetColheader_Current_BT(202404,'si','PB',23)
	end

	--//tag_Update_Forecast_Budget_SI_Value_WF
	if @n_continue = 1
	begin
		select @sql=
		'update '+@FC_FM_Original
		+' set '+@List_pre_Budget_value_zero
		+' where Channel IN(''OFFLINE'',''ONLINE'',''O+O'') '

		if @debug>0
		begin
			select @sql '@sql update zero'
		end
		execute(@sql)

		select @sql =
		'update '+@FC_FM_Original+'   
		set   '
			+@list_Prebudget_Value+'				
		from '+@FC_FM_Original+' f     
		inner join     
		(     
			select      
				*
			from '+@FC_FM_Original_value+' si (NOLOCK)
		) as si on      
			si.[Product Type] = f.[Product Type]   
		and si.[SUB GROUP/ Brand] = f.[SUB GROUP/ Brand]   
		and si.channel = f.channel 
		and si.[Time series] = f.[Time series] ' 

		if @debug>0
		begin
			select @sql '@sql tag_Update_Forecast_Pre_Budget_SI_Value_WF'
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