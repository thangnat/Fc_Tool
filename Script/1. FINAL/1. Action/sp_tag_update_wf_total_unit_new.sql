/*
	declare 
		@b_Success				Int,
		@c_errmsg				Nvarchar(250)

	exec sp_tag_update_wf_total_unit_new 'LDB','202409','tag_update_wf_total_git_unit',@b_Success OUT, @c_errmsg OUT

	select @b_Success b_Success, @c_errmsg c_errmsg

	/*
		Type:
			All,
			soh,
			git,
			mtd_si,
			sit,
			historical,
			fc,budget,
			pre_budget,
			trend
		tag_update_wf_total_'+@Tag_name+'_unit
	*/
*/

Alter Proc sp_tag_update_wf_total_unit_new
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
		@sp_name = 'sp_tag_update_wf_total_unit_new',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	select @debug=debug from fnc_Debug('FC')
	--select @debug=1
	declare @Monthfc				nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from V_FC_FM_Table

	declare @FC_FM_Original			nvarchar(100) = ''
	select @FC_FM_Original = 'FC_FM_Original_'+@Division+@Monthfc

	declare @Tag_name_ok nvarchar(200)=''
	select @Tag_name_ok=@Tag_name--'tag_update_wf_total_'+@Tag_name+'_unit'

	if @debug>0
	begin		
		select '@n_continue 1.12'=@n_continue,tablename = 'Update total-->Total qty unit',@FC_FM_Original '@FC_FM_Original'
	end
	--//hitorical
	if @Tag_name = 'all' OR @Tag_name_ok = 'tag_update_wf_total_historical_unit'
	begin
		--Update O+O-->@listcolumn_pass_header->unit
		declare @listcolumn_pass_header_unit nvarchar(max) = ''
		SELECT @listcolumn_pass_header_unit = ListColumn FROM fn_FC_GetColHeader_Historical(@FM_KEY,'si',2)
		--SELECT listcolumn_pass_header_unit = ListColumn FROM fn_FC_GetColHeader_Historical('202408','si',2)
		
		--//update total qty-->@listcolumn_pass-->Unit
		declare @listcolumn_pass_detail_unit nvarchar(max) = ''
		select @listcolumn_pass_detail_unit = ListColumn from fn_FC_GetColHeader_Historical(@FM_KEY,'si',4)
		--select listcolumn_pass_detail_unit = ListColumn from fn_FC_GetColHeader_Historical('202403','si',4)
	end
	--//forcast
	if @Tag_name = 'all' OR @Tag_name_ok = 'tag_update_wf_total_fc_unit'
	begin
		--//CURRENT
		--Update O+O--@listcolumn_current_header-->Unit
		declare @listcolumn_current_header_unit nvarchar(max) = ''
		SELECT @listcolumn_current_header_unit = ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'updateForecast','si')
		--SELECT listcolumn_current_header_unit = ListColumn FROM fn_FC_GetColheader_Current('202404','updateForecast','si')
		
		declare @listcolumn_current_detail_unit nvarchar(max) = ''
		select @listcolumn_current_detail_unit = ListColumn FROM fn_FC_GetColheader_Current(@FM_Key,'6. Total Qty','')
		--select listcolumn_current_detail_unit = ListColumn FROM fn_FC_GetColheader_Current('202406','6. Total Qty','')
	end
	
	--//BUDGET
	if @Tag_name = 'all' OR @Tag_name_ok = 'tag_update_wf_total_budget_unit'
	begin
		--budget unit
		declare @List_Budget_header_unit			nvarchar(max) = ''
		SELECT @List_Budget_header_unit = ListColumn FROM fn_FC_GetColheader_Current_BT(@FM_Key,'si','B',3)
		--SELECT List_Budget_header_unit = ListColumn FROM fn_FC_GetColheader_Current_BT('202404','si','B',3)

		declare @List_Budget_detail_unit			nvarchar(max) = ''
		SELECT @List_Budget_detail_unit = ListColumn FROM fn_FC_GetColheader_Current_BT(@FM_Key,'','B',4)
		--SELECT List_Budget_detail = ListColumn FROM fn_FC_GetColheader_Current_BT('202403','','B',4)
	end

	--Pre budget unit
	if @Tag_name = 'all' OR @Tag_name_ok = 'tag_update_wf_total_pre_budget_unit'
	begin
		declare @List_PreBudget_Header_unit		nvarchar(max) = ''			
		SELECT @List_PreBudget_Header_unit = ListColumn FROM fn_FC_GetColheader_Current_BT(@FM_Key,'si','PB',3)
		--SELECT List_PreBudget_Header_unit = ListColumn FROM fn_FC_GetColheader_Current_BT('202404','si','PB',3)
		
		declare @List_PreBudget_Detail_unit		nvarchar(max) = ''
 		SELECT @List_PreBudget_Detail_unit = ListColumn FROM fn_FC_GetColheader_Current_BT(@FM_Key,'','PB',4)
		--SELECT List_PreBudget_Detail_unit = ListColumn FROM fn_FC_GetColheader_Current_BT('202404','','PB',4)
	end

	--//TREND unit
	if @Tag_name = 'all' OR @Tag_name_ok = 'tag_update_wf_total_trend_unit'
	begin
		declare @list_Trend_header_unit			nvarchar(max) = ''
		SELECT @list_Trend_header_unit = ListColumn FROM fn_FC_GetColheader_Current_BT(@FM_Key,'si','T',3)
		--SELECT list_Trend_header_unit = ListColumn FROM fn_FC_GetColheader_Current_BT('202404','si','T',3)
		
		declare @list_Trend_Detail_unit			nvarchar(max) = ''
		SELECT @list_Trend_Detail_unit = ListColumn FROM fn_FC_GetColheader_Current_BT(@FM_Key,'','T',4)
		--SELECT list_Trend_Detail_unit = ListColumn FROM fn_FC_GetColheader_Current_BT('202404','','T',4)
	end
	--//Update total qty
	if @n_continue = 1
	begin
		select @sql =
		'update '+@FC_FM_Original+'
		set 
			[Product Type]=f.[Product Type] '
			+iif((@Tag_name ='all' OR @Tag_name_ok = 'tag_update_wf_total_soh_unit'),','+'[SOH]=si.[SOH]','')
			--+iif((@Tag_name ='all' OR @Tag_name_ok = 'tag_update_wf_total_git_unit'),','+'[Total GIT]=si.[Total GIT],[GIT M0]=si.[GIT M0],[GIT M1]=si.[GIT M1],[GIT M2]=si.[GIT M2],[GIT M3]=si.[GIT M3]','')
			+iif((@Tag_name ='all' OR @Tag_name_ok = 'tag_update_wf_total_sit_unit'),','+'[SIT]=si.[SIT],[SIT Day]=si.[SIT Day]','')
			+iif((@Tag_name ='all' OR @Tag_name_ok = 'tag_update_wf_total_mtd_si_unit'),','+'[MTD SI]=si.[MTD SI]','')
			+iif((@Tag_name ='all' OR @Tag_name_ok = 'tag_update_wf_total_historical_unit'),','+@listcolumn_pass_header_unit,'')
			+iif((@Tag_name ='all' OR @Tag_name_ok = 'tag_update_wf_total_fc_unit'),','+@listcolumn_current_header_unit,'')
			+iif((@Tag_name ='all' OR @Tag_name_ok = 'tag_update_wf_total_budget_unit'),','+@List_Budget_header_unit,'')			
			+iif((@Tag_name ='all' OR @Tag_name_ok = 'tag_update_wf_total_pre_budget_unit'),','+@List_PreBudget_Header_unit,'')			
			+iif((@Tag_name ='all' OR @Tag_name_ok = 'tag_update_wf_total_trend_unit'),','+@list_Trend_header_unit,'')			
		+'from '+@FC_FM_Original+' f
		inner join 
		(
			select
				[Product Type],
				[SUB GROUP/ Brand],
				Channel '
				+iif((@Tag_name ='all' OR @Tag_name_ok = 'tag_update_wf_total_soh_unit'),','+'[SOH]=sum(SOH)','')
				--+iif((@Tag_name ='all' OR @Tag_name_ok = 'tag_update_wf_total_git_unit'),','+'[Total GIT]=sum([Total GIT]),[GIT M0]=sum([GIT M0]),[GIT M1]=sum([GIT M1]),[GIT M2]=sum([GIT M2]),[GIT M3]=sum([GIT M3])','')
				+iif((@Tag_name ='all' OR @Tag_name_ok = 'tag_update_wf_total_sit_unit'),','+'[SIT]=sum(SIT),[SIT Day]=sum([SIT Day])','')
				+iif((@Tag_name ='all' OR @Tag_name_ok = 'tag_update_wf_total_mtd_si_unit'),','+'[MTD SI]=sum([MTD SI])','')
				+iif((@Tag_name ='all' OR @Tag_name_ok = 'tag_update_wf_total_historical_unit'),','+@listcolumn_pass_detail_unit,'')
				+iif((@Tag_name ='all' OR @Tag_name_ok = 'tag_update_wf_total_fc_unit'),','+@listcolumn_current_detail_unit,'')				
				+iif((@Tag_name ='all' OR @Tag_name_ok = 'tag_update_wf_total_budget_unit'),','+@List_Budget_detail_unit,'')				
				+iif((@Tag_name ='all' OR @Tag_name_ok = 'tag_update_wf_total_pre_budget_unit'),','+@List_PreBudget_Detail_unit,'')				
				+iif((@Tag_name ='all' OR @Tag_name_ok = 'tag_update_wf_total_trend_unit'),','+@list_Trend_Detail_unit,'')				
			+'from '+@FC_FM_Original+' 
			where 
				[Time series] not in(''6. Total Qty'',''5. FOC Qty'',''7. BP Unit'',''8. BP vs FC (u)'',''9. BP vs FC (%)'',''10. Original FM (u)'',''11. FM vs FC (u)'',''12. FM vs FC (%)'') 
			and Channel NOT IN(''O+O'')
			and [Product Type] = ''YFG'' 
			group by
				[Product Type],
				[SUB GROUP/ Brand],
				Channel
		) as si on 
				si.[Product Type] = f.[Product Type] 
			and si.[SUB GROUP/ Brand] = f.[SUB GROUP/ Brand] 
			and si.channel = f.channel
		where 
			f.[Time Series] = ''6. Total Qty'' 
		AND F.CHANNEL NOT IN(''O+O'')
		and f.[Product Type] = ''YFG'' '

		if @debug>0
		begin
			select @sql '@sql Update total qty 1.1'
		end
		execute(@sql)

		--//update total Material type <> YFG
		select @sql =
		'update '+@FC_FM_Original+'
		set 
			[Product Type]=f.[Product Type] '
			+iif((@Tag_name ='all' OR @Tag_name_ok = 'tag_update_wf_total_soh_unit'),','+'[SOH]=si.[SOH]','')
			--+iif((@Tag_name ='all' OR @Tag_name_ok = 'tag_update_wf_total_git_unit'),','+'[Total GIT]=si.[Total GIT],[GIT M0]=si.[GIT M0],[GIT M1]=si.[GIT M1],[GIT M2]=si.[GIT M2],[GIT M3]=si.[GIT M3]','')
			+iif((@Tag_name ='all' OR @Tag_name_ok = 'tag_update_wf_total_sit_unit'),','+'[SIT]=si.[SIT],[SIT Day]=si.[SIT Day]','')
			+iif((@Tag_name ='all' OR @Tag_name_ok = 'tag_update_wf_total_mtd_si_unit'),','+'[MTD SI]=si.[MTD SI]','')
			+iif(@Tag_name ='all' OR @Tag_name_ok = 'tag_update_wf_total_historical_unit',','+@listcolumn_pass_header_unit,'')
			+iif(@Tag_name ='all' OR @Tag_name_ok = 'tag_update_wf_total_fc_unit',','+@listcolumn_current_header_unit,'')
			+iif((@Tag_name ='all' OR @Tag_name_ok = 'tag_update_wf_total_budget_unit'),','+@List_Budget_header_unit,'')
			+iif((@Tag_name ='all' OR @Tag_name_ok = 'tag_update_wf_total_pre_budget_unit'),','+@List_PreBudget_Header_unit,'')
			+iif((@Tag_name ='all' OR @Tag_name_ok = 'tag_update_wf_total_trend_unit'),','+@list_Trend_header_unit,'')
		+'from '+@FC_FM_Original+' f
		inner join 
		(
			select
				[Product Type],
				[SUB GROUP/ Brand],
				Channel '
				+iif((@Tag_name ='all' OR @Tag_name_ok = 'tag_update_wf_total_soh_unit'),','+'[SOH]=sum(SOH)','')
				--+iif((@Tag_name ='all' OR @Tag_name_ok = 'tag_update_wf_total_git_unit'),','+'[Total GIT]=sum([Total GIT]),[GIT M0]=sum([GIT M0]),[GIT M1]=sum([GIT M1]),[GIT M2]=sum([GIT M2]),[GIT M3]=sum([GIT M3])','')
				+iif((@Tag_name ='all' OR @Tag_name_ok = 'tag_update_wf_total_sit_unit'),','+'[SIT]=sum(SIT),[SIT Day]=sum([SIT Day])','')
				+iif((@Tag_name ='all' OR @Tag_name_ok = 'tag_update_wf_total_mtd_si_unit'),','+'[MTD SI]=sum([MTD SI])','')
				+iif((@Tag_name ='all' OR @Tag_name_ok = 'tag_update_wf_total_historical_unit'),','+@listcolumn_pass_detail_unit,'')
				+iif((@Tag_name ='all' OR @Tag_name_ok = 'tag_update_wf_total_fc_unit'),','+@listcolumn_current_detail_unit,'')
				+iif((@Tag_name ='all' OR @Tag_name_ok = 'tag_update_wf_total_budget_unit'),','+@List_Budget_detail_unit,'')
				+iif((@Tag_name ='all' OR @Tag_name_ok = 'tag_update_wf_total_pre_budget_unit'),','+@List_PreBudget_Detail_unit,'')
				+iif((@Tag_name ='all' OR @Tag_name_ok = 'tag_update_wf_total_trend_unit'),','+@list_Trend_Detail_unit,'')
			+'from '+@FC_FM_Original+' 
			where 
				[Time series] NOT IN(''6. Total Qty'',''7. BP Unit'',''8. BP vs FC (u)'',''9. BP vs FC (%)'',''10. Original FM (u)'',''11. FM vs FC (u)'',''12. FM vs FC (%)'')
			and [Product Type] <> ''YFG'' 
			AND CHANNEL NOT IN(''O+O'')
			group by
				[Product Type],
				[SUB GROUP/ Brand],
				Channel
		) as si on 
				si.[Product Type] = f.[Product Type] 
			and si.[SUB GROUP/ Brand] = f.[SUB GROUP/ Brand] 
			and si.channel = f.channel
		where
			f.[Time Series] = ''6. Total Qty'' 
		and F.Channel NOT IN(''O+O'')
		and f.[Product Type] <> ''YFG'' '

		if @debug>0
		begin
			select @sql '@sql Update total qty 1.2'
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