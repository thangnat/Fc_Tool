/*
	declare 
		@b_Success				Int,
		@c_errmsg				Nvarchar(250)

	exec sp_tag_update_wf_O_O_value_new 'CPD','202406','all',@b_Success OUT, @c_errmsg OUT

	select @b_Success b_Success, @c_errmsg c_errmsg
	
	/*
		Type:tag_update_wf_O_O_
			All,
			soh,
			git,
			mtd_si,
			sit,
			historical,
			fc,
			budget,
			pre_budget,
			trend

		tag_update_wf_O_O_'+@Tag_name+'_value
	*/
*/

Alter Proc sp_tag_update_wf_O_O_value_new
	@Division				nvarchar(3),
	@FM_KEY					nvarchar(6),
	@Tag_name				nvarchar(200),
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
		@sp_name = 'sp_tag_update_wf_O_O_value_new',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	select @debug=debug from fnc_Debug('FC')
	--select @debug=1

	declare @Monthfc				nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from V_FC_FM_Table

	declare @FC_FM_Original			nvarchar(100) = ''
	select @FC_FM_Original = 'FC_FM_Original_'+@Division+@Monthfc

	declare @Tag_name_ok nvarchar(200)=''
	select @Tag_name_ok=@Tag_name--'tag_update_wf_O_O_'+@Tag_name+'_value'

	if @debug>0
	begin		
		select '@n_continue 1.12'=@n_continue,tablename = 'Update O+O-->Total qty unit',@FC_FM_Original '@FC_FM_Original'
	end

	--//Update total-->@listcolumn_pass_update-->value
	if @Tag_name = 'all' OR @Tag_name_ok = 'tag_update_wf_O_O_historical_value'
	begin
		declare @listcolumn_pass_header_value nvarchar(max) = ''
		SELECT @listcolumn_pass_header_value = ListColumn FROM fn_FC_GetColHeader_Historical(@FM_KEY,'si',222)
		--SELECT listcolumn_pass_header_value = ListColumn FROM fn_FC_GetColHeader_Historical('202403','si',222)
		--//update total qty-->@listcolumn_pass-->Value
		
		declare @listcolumn_pass_detail_Value nvarchar(max) = ''
		select @listcolumn_pass_detail_Value = ListColumn from fn_FC_GetColHeader_Historical(@FM_KEY,'si',444)
		--select listcolumn_pass_detail_Value = ListColumn from fn_FC_GetColHeader_Historical('202404','si',444)
	end

	--Update total--@listcolumn_current_header-->value
	if @Tag_name = 'all' OR @Tag_name_ok = 'tag_update_wf_O_O_fc_value'
	begin
		declare @listcolumn_current_header_value nvarchar(max) = ''
		SELECT @listcolumn_current_header_value = ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'updateForecast_Value','si')
		--SELECT listcolumn_current_header_value = ListColumn FROM fn_FC_GetColheader_Current('202403','updateForecast','si')
		--//Update total -->@listcolumn_current-->Value
		
		declare @listcolumn_current_detail_value nvarchar(max) = ''
		select @listcolumn_current_detail_value = ListColumn FROM fn_FC_GetColheader_Current(@FM_Key,'6. Total Value','')	
		--select listcolumn_current_detail_value = ListColumn FROM fn_FC_GetColheader_Current('202404','6. Total Value','')	
	end
	
	--budget value
	if @Tag_name = 'all' OR @Tag_name_ok = 'tag_update_wf_O_O_budget_value'
	begin
		declare @list_budget_header_Value nvarchar(max) = ''
		SELECT @list_budget_header_Value = ListColumn FROM fn_FC_GetColheader_Current_BT(@FM_KEY,'si','B',23)
		--SELECT list_budget_header_Value = ListColumn FROM fn_FC_GetColheader_Current_BT('202403','si','B',23)	
		
		declare @list_budget_detail_Value nvarchar(max) = ''
		SELECT @list_budget_detail_value = ListColumn FROM fn_FC_GetColheader_Current_BT(@FM_KEY,'','B',41)
		--SELECT list_budget_detail_value = ListColumn FROM fn_FC_GetColheader_Current_BT('202403','','B',41)
	end

	--Pre budget value
	if @Tag_name = 'all' OR @Tag_name_ok = 'tag_update_wf_O_O_pre_budget_value'
	begin
		declare @list_Prebudget_header_value nvarchar(max) = ''
		SELECT @list_Prebudget_header_value = ListColumn FROM fn_FC_GetColheader_Current_BT(@FM_KEY,'si','PB',23)
		--SELECT list_Prebudget_header_value = ListColumn FROM fn_FC_GetColheader_Current_BT('202404','si','PB',23)
		
		declare @list_Prebudget_detail_value	nvarchar(max) = ''
		SELECT @list_Prebudget_detail_value = ListColumn FROM fn_FC_GetColheader_Current_BT(@FM_KEY,'','PB',41)
		--SELECT list_Prebudget_detail_value = ListColumn FROM fn_FC_GetColheader_Current_BT('202404','','PB',41)
	end

	--Trend value
	if @Tag_name = 'all' OR @Tag_name_ok = 'tag_update_wf_O_O_trend_value'
	begin
		declare @list_Trend_header_value nvarchar(max) = ''
		SELECT @list_Trend_header_value = ListColumn FROM fn_FC_GetColheader_Current_BT(@FM_KEY,'si','T',23)
		--SELECT list_Trend_header_value = ListColumn FROM fn_FC_GetColheader_Current_BT('202404','si','T',23)
		
		declare @list_Trend_detail_value nvarchar(max) = ''
		SELECT @list_Trend_detail_value = ListColumn FROM fn_FC_GetColheader_Current_BT(@FM_KEY,'','T',41)
		--SELECT list_Trend_detail_value = ListColumn FROM fn_FC_GetColheader_Current_BT('202403','','T',41)
	end
	--//Update total qty & O+O
	if @n_continue = 1
	begin
		if @debug>0
		begin		
			select '@n_continue 1.12A'=@n_continue,tablename = 'Update O+O: total qty'
		end
		select @sql =
		'update '+@FC_FM_Original+'
		set 
			[Product Type] = si.[Product Type] '
			+iif((@Tag_name = 'all' OR @Tag_name_ok = 'tag_update_wf_O_O_historical_value'),','+@listcolumn_pass_header_value,'')
			+iif((@Tag_name = 'all' OR @Tag_name_ok = 'tag_update_wf_O_O_fc_value'),','+@listcolumn_current_header_value,'')
			+iif((@Tag_name = 'all' OR @Tag_name_ok = 'tag_update_wf_O_O_budget_value'),','+@List_Budget_header_value,'')
			+iif((@Tag_name = 'all' OR @Tag_name_ok = 'tag_update_wf_O_O_pre_budget_value'),','+@List_PreBudget_Header_value,'')
			+iif((@Tag_name = 'all' OR @Tag_name_ok = 'tag_update_wf_O_O_trend_value'),','+@list_Trend_header_value,'')			
		+'from '+@FC_FM_Original+' f
		inner join 
		(
			select
				[Product Type],    
				[SUB GROUP/ Brand],
				[Time series] '
				+iif((@Tag_name = 'all' OR @Tag_name_ok = 'tag_update_wf_O_O_historical_value'),','+@listcolumn_pass_detail_value,'')
				+iif((@Tag_name = 'all' OR @Tag_name_ok = 'tag_update_wf_O_O_fc_value'),','+@listcolumn_current_detail_Value,'')
				+iif((@Tag_name = 'all' OR @Tag_name_ok = 'tag_update_wf_O_O_budget_value'),','+@list_budget_Detail_value,'')
				+iif((@Tag_name = 'all' OR @Tag_name_ok = 'tag_update_wf_O_O_pre_budget_value'),','+@list_Prebudget_detail_value,'')
				+iif((@Tag_name = 'all' OR @Tag_name_ok = 'tag_update_wf_O_O_trend_value'),','+@list_Trend_Detail_value,'')
			+'from '+@FC_FM_Original+' 
			where 
				Channel <> ''O+O''	
			group by
				[Product Type],   
				[SUB GROUP/ Brand] ,
				[Time series]
		) as si on
			si.[Product Type] = f.[Product Type] 
		and si.[SUB GROUP/ Brand] = f.[SUB GROUP/ Brand] 
		and si.[Time series] = f.[Time series] 
		where 
			f.[Channel] = ''O+O'' '

		/*and replace(f.[Time series],''0. O+O: '','''') = si.[Time series]  */

		if @debug>0
		begin
			select @sql '@sql Update O+O: total qty 1.1'
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