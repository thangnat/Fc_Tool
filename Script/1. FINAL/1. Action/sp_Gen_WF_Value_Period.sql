/*
	declare 
		@b_Success		Int,  
		@c_errmsg		Nvarchar(250)

	exec sp_Gen_WF_Value_Period 'CPD','202502','VALUE','budget',@b_Success OUT, @c_errmsg OUT
	
	select @b_Success b_Success, @c_errmsg c_errmsg

	/*
		period key:
			pass,
			fc,
			budget,
			pre-budget,
			trend
	*/
	select * from FC_FM_Original_CPD_202502_budget
*/

Alter Proc sp_Gen_WF_Value_Period
	@Division		nvarchar(3),
	@FM_KEY			nvarchar(6),
	@TypeView		nvarchar(10),--//UNIT/VALUE
	@Periodkey		nvarchar(20),
	@b_Success		Int				OUTPUT,     
	@c_errmsg		Nvarchar(250)	OUTPUT
	with encryption
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
		,@full					nvarchar(4) = ''
		,@GetActive				int=0
		,@sql					nvarchar(max) = ''

	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_Gen_WF_Value_Period',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	select @debug=debug from fnc_Debug('FC')
	select @debug=1

	declare @Monthfc				nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from V_FC_FM_Table
		
	declare @list_column_pass_rsp_promobom		nvarchar(max) = ''
	select @list_column_pass_rsp_promobom = ListColumn from fn_FC_GetColHeader_Historical(@FM_KEY,'h',22221)
	--select list_column_pass_rsp_promobom = ListColumn from fn_FC_GetColHeader_Historical('202404','h',22221)

	declare @list_column_pass_baseline			nvarchar(max) = ''
	select @list_column_pass_baseline = ListColumn from fn_FC_GetColHeader_Historical(@FM_KEY,'h',222213)
	--select list_column_pass_baseline = ListColumn from fn_FC_GetColHeader_Historical('202404','h',222213)

	declare @list_column_pass_value				nvarchar(max) = ''
	select @list_column_pass_value = ListColumn from fn_FC_GetColHeader_Historical(@FM_KEY,'h',222212)
	--select list_column_pass_value = ListColumn from fn_FC_GetColHeader_Historical('202410','h',222212)

	declare @list_column_current_Value			nvarchar(max) = ''
	SELECT @list_column_current_Value = ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'RSP','f')-->RSP
	--SELECT list_column_M_minus_1_Value = ListColumn FROM fn_FC_GetColheader_Current('202404','RSP','f')-->RSP M-1

	--declare @list_column_M_minus_1_Value		nvarchar(max) = ''
	declare @list_column_Budget_Value			nvarchar(max) = ''
	SELECT @list_column_Budget_Value = ListColumn FROM fn_FC_GetColheader_Current_BT(@FM_KEY,'f','B',22)
	--SELECT list_column_Budget_Value = ListColumn FROM fn_FC_GetColheader_Current_BT('202502','f','B',22)

	declare @list_column_PreBudget_Value		nvarchar(max) = ''
	SELECT @list_column_PreBudget_Value = ListColumn FROM fn_FC_GetColheader_Current_BT(@FM_KEY,'f','PB',22)
	--SELECT list_column_PreBudget_Value = ListColumn FROM fn_FC_GetColheader_Current_BT('202404','f','PB',22)

	declare @list_column_trend_Value			nvarchar(max) = ''
	SELECT @list_column_trend_Value = ListColumn FROM fn_FC_GetColheader_Current_BT(@FM_KEY,'f','T',22)
	--SELECT list_column_trend_Value = ListColumn FROM fn_FC_GetColheader_Current_BT('202412','f','T',22)

	declare @tablename			nvarchar(100) = ''
	select @tablename = 'FC_FM_Original_'+@Division+@Monthfc

	declare	@tablename_value	nvarchar(100) = ''
	select @tablename_value = @tablename+'_'+@Periodkey

	if @debug>0
	begin
		select @tablename '@tablename',@tablename_value '@tablename_value'
	end	

	if @n_continue =1
	begin
		if @TypeView = 'VALUE'
		begin		
			if exists
			(
				SELECT * 
				FROM sys.objects 
				WHERE object_id = OBJECT_ID(@tablename_value) AND type in (N'U')
			)
			begin
				select @sql = 'drop table '+@tablename_value
				if @debug >0
				begin
					select @sql '@sql drop table'
				end
				execute(@sql)
			end
			if @debug>0
			begin
				select @tablename_value '@tablename_value'
			end

			if @Periodkey = 'pass'
			begin
				select @sql=
				'select
					f.id,
					f.[Product type],
					f.Signature,
					f.[CAT/Axe],
					f.[SUB CAT/ Sub Axe],
					f.[GROUP/ Class],
					f.[SUB GROUP/ Brand],
					f.HERO,
					f.Channel,
					f.[Product status],
					f.[Time series],'
					+@list_column_pass_rsp_promobom+'
					INTO '+@tablename_value+'
				from '+@tablename+' F
				inner join
				(
					select 
						*
					from fnc_SubGroupMaster_RSP('''+@Division+''','''+@full+''') 
				) s on s.[SUB GROUP/ Brand] = f.[SUB GROUP/ Brand] '
				
				if @debug>0
				begin
					select @sql '@sql insert pass'
				end
				execute(@sql)
				
				--//update pass value from mcsi
				select @sql = 
				'Update '+@tablename_value+'
					set '+@list_column_pass_value+'
				from '+@tablename_value+' f
				inner join
				(
					select 
						* 
					from FC_MCSI_'+@Division+'_VALUE_OK
				) h on h.[SUB GROUP/ Brand] = f.[SUB GROUP/ Brand] and h.Channel = f.channel and h.[Time series] = f.[Time series]
				where f.[Time series] = ''6. Total Qty'' '

				if @debug>0
				begin
					select @sql '@sql insert pass value mcsi'
				end
				execute(@sql)

				--//update pass value from mcsi-promo bom = baseline qty
				select @sql = 
				'Update '+@tablename_value+' 
				set '+@list_column_pass_baseline+'
				from '+@tablename_value+' f
				left join
				(
					select
						* 
					from '+@tablename_value+'  
					where [Time series] = ''6. Total Qty'' and Channel<>''O+O'' 
				) t on t.[SUB GROUP/ Brand] = f.[SUB GROUP/ Brand] and t.Channel = f.channel 
				inner join 
				(
					select 
						* 
					from '+@tablename_value+' 
					where [Time series] = ''3. Promo Qty(BOM)''   and Channel<>''O+O''
				) p on p.[SUB GROUP/ Brand] = f.[SUB GROUP/ Brand] and p.Channel = f.channel 
				where f.Channel<>''O+O'' and f.[Time series] = ''1. Baseline Qty'' '

				if @debug>0
				begin
					select @sql '@sql update pass value from mcsi-promo bom = baseline qty'
				end
				execute(@sql)
			end
			else if @Periodkey = 'fc'
			begin
				select @sql=
				'select
					f.id,
					f.[Product type],
					f.Signature,
					f.[CAT/Axe],
					f.[SUB CAT/ Sub Axe],
					f.[GROUP/ Class],
					f.[SUB GROUP/ Brand],
					f.HERO,
					f.Channel,
					f.[Product status],
					f.[Time series],'
					+@list_column_current_Value+'
					INTO '+@tablename_value+' 
				from '+@tablename+' F
				inner join
				(
					select 
						*
					from fnc_SubGroupMaster_RSP('''+@Division+''','''+@full+''') 
				) s on s.[SUB GROUP/ Brand] = f.[SUB GROUP/ Brand] '

				if @debug>0
				begin
					select @sql '@sql insert fc'
				end
				execute(@sql)
			end
			else if @Periodkey = 'budget'
			begin
				--select @sql=
				--'select
				--	f.id,
				--	f.[Product type],
				--	f.Signature,
				--	f.[CAT/Axe],
				--	f.[SUB CAT/ Sub Axe],
				--	f.[GROUP/ Class],
				--	f.[SUB GROUP/ Brand],
				--	f.HERO,
				--	f.Channel,
				--	f.[Product status],
				--	f.[Time series],'
				--	+@list_column_Budget_Value+'
				--	INTO '+@tablename_value+' 
				--from '+@tablename+' F
				--inner join
				--(
				--	select 
				--		*
				--	from fnc_SubGroupMaster_RSP('''+@Division+''','''+@full+''') 
				--) s on s.[SUB GROUP/ Brand] = f.[SUB GROUP/ Brand] and s.Channel=f.Channel '

				select @sql=
				'select
					f.id,
					f.[Product type],
					f.Signature,
					f.[CAT/Axe],
					f.[SUB CAT/ Sub Axe],
					f.[GROUP/ Class],
					f.[SUB GROUP/ Brand],
					f.HERO,
					f.Channel,
					f.[Product status],
					f.[Time series],
					[(Value)_B_Y0_M1]=isnull(s.[B_Y0_M1],0),
					[(Value)_B_Y0_M2]=isnull(s.[B_Y0_M2],0),
					[(Value)_B_Y0_M3]=isnull(s.[B_Y0_M3],0),
					[(Value)_B_Y0_M4]=isnull(s.[B_Y0_M4],0),
					[(Value)_B_Y0_M5]=isnull(s.[B_Y0_M5],0),
					[(Value)_B_Y0_M6]=isnull(s.[B_Y0_M6],0),[(Value)_B_Y0_M7]=isnull(s.[B_Y0_M7],0),[(Value)_B_Y0_M8]=isnull(s.[B_Y0_M8],0),
					[(Value)_B_Y0_M9]=isnull(s.[B_Y0_M9],0),[(Value)_B_Y0_M10]=isnull(s.[B_Y0_M10],0),[(Value)_B_Y0_M11]=isnull(s.[B_Y0_M11],0),
					[(Value)_B_Y0_M12]=isnull(s.[B_Y0_M12],0)
					,[(Value)_B_Y+1_M1]=isnull(s1.[B_Y+1_M1],0),[(Value)_B_Y+1_M2]=isnull(s1.[B_Y+1_M2],0),
					[(Value)_B_Y+1_M3]=isnull(s1.[B_Y+1_M3],0),[(Value)_B_Y+1_M4]=isnull(s1.[B_Y+1_M4],0),[(Value)_B_Y+1_M5]=isnull(s1.[B_Y+1_M5],0),
					[(Value)_B_Y+1_M6]=isnull(s1.[B_Y+1_M6],0),[(Value)_B_Y+1_M7]=isnull(s1.[B_Y+1_M7],0),[(Value)_B_Y+1_M8]=isnull(s1.[B_Y+1_M8],0),
					[(Value)_B_Y+1_M9]=isnull(s1.[B_Y+1_M9],0),[(Value)_B_Y+1_M10]=isnull(s1.[B_Y+1_M10],0),[(Value)_B_Y+1_M11]=isnull(s1.[B_Y+1_M11],0),
					[(Value)_B_Y+1_M12]=isnull(s1.[B_Y+1_M12],0)
					INTO '+@tablename_value+' 
				from '+@tablename+' F
				left join
				(
					select 
						[SUB GROUP/ Brand],
						[Channel],
						[B_Y0_M1]=[M1 RSP],[B_Y0_M2]=[M2 RSP],[B_Y0_M3]=[M3 RSP],
						[B_Y0_M4]=[M4 RSP],[B_Y0_M5]=[M5 RSP],[B_Y0_M6]=[M6 RSP],
						[B_Y0_M7]=[M7 RSP],[B_Y0_M8]=[M8 RSP],[B_Y0_M9]=[M9 RSP],
						[B_Y0_M10]=[M10 RSP],[B_Y0_M11]=[M11 RSP],[B_Y0_M12]=[M12 RSP]
					from fnc_FC_BUDGET_TREND_RSP_NEW('''+@division+''','''+@FM_KEY+''',''B'',''B0'')
				) s on s.[SUB GROUP/ Brand]=f.[SUB GROUP/ Brand] and s.channel=f.Channel
				left join
				(
					select 
						[SUB GROUP/ Brand],
						[Channel],
						[B_Y+1_M1]=[M1 RSP],[B_Y+1_M2]=[M2 RSP],[B_Y+1_M3]=[M3 RSP],
						[B_Y+1_M4]=[M4 RSP],[B_Y+1_M5]=[M5 RSP],[B_Y+1_M6]=[M6 RSP],
						[B_Y+1_M7]=[M7 RSP],[B_Y+1_M8]=[M8 RSP],[B_Y+1_M9]=[M9 RSP],
						[B_Y+1_M10]=[M10 RSP],[B_Y+1_M11]=[M11 RSP],[B_Y+1_M12]=[M12 RSP]
					from fnc_FC_BUDGET_TREND_RSP_NEW('''+@division+''','''+@FM_KEY+''',''B'',''B1'')
				) s1 on s.[SUB GROUP/ Brand]=f.[SUB GROUP/ Brand] and s.channel=f.Channel '

				if @debug>0
				begin
					select @sql '@sql budget'
				end
				execute(@sql)
			end
			else if @Periodkey = 'pre_budget'
			begin
				select @sql=
				'select
					f.id,
					f.[Product type],
					f.Signature,
					f.[CAT/Axe],
					f.[SUB CAT/ Sub Axe],
					f.[GROUP/ Class],
					f.[SUB GROUP/ Brand],
					f.HERO,
					f.Channel,
					f.[Product status],
					f.[Time series],'
					+@list_column_PreBudget_Value+'
					INTO '+@tablename_value+' 
				from '+@tablename+' F
				inner join
				(
					select 
						*
					from fnc_SubGroupMaster_RSP('''+@Division+''','''+@full+''') 
				) s on s.[SUB GROUP/ Brand] = f.[SUB GROUP/ Brand] '

				if @debug>0
				begin
					select @sql '@sql pre_budget'
				end
				execute(@sql)
			end
			else if @Periodkey = 'trend'
			begin
				select @sql=
				'select
					f.id,
					f.[Product type],
					f.Signature,
					f.[CAT/Axe],
					f.[SUB CAT/ Sub Axe],
					f.[GROUP/ Class],
					f.[SUB GROUP/ Brand],
					f.HERO,
					f.Channel,
					f.[Product status],
					f.[Time series],'
					+@list_column_trend_Value+' 
					INTO '+@tablename_value+' 
				from '+@tablename+' F
				inner join
				(
					select 
						*
					from fnc_SubGroupMaster_RSP('''+@Division+''','''+@full+''') 
				) s on s.[SUB GROUP/ Brand] = f.[SUB GROUP/ Brand] '

				if @debug>0
				begin
					select @sql '@sql trend'
				end
				execute(@sql)
			end
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



