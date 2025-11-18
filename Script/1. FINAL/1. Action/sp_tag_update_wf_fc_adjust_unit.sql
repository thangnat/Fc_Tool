/*
	declare 
		@b_Success				Int,
		@c_errmsg				Nvarchar(250)

	exec sp_tag_update_wf_fc_adjust_unit 'CPD','202410','Show_All_Selected',@b_Success OUT, @c_errmsg OUT

	select @b_Success b_Success, @c_errmsg c_errmsg
*/

Alter Proc sp_tag_update_wf_fc_adjust_unit
	@Division				nvarchar(3),
	@FM_KEY					nvarchar(6),
	@Show_Selected_Status	nvarchar(50),--//Show_All_Selected,Show_Total_Selected,Show_BP_Selected
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
		@sp_name = 'sp_tag_update_wf_fc_adjust_unit',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	select @debug=debug from fnc_debug('FC')
	--select @debug=1

	declare @Monthfc				nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from V_FC_FM_Table

	declare @FC_FM_Original			nvarchar(100) = ''
	select @FC_FM_Original = 'FC_FM_Original_'+@Division+@Monthfc

	declare @fc_fm_original_Adjust	nvarchar(100) = ''
	select @fc_fm_original_Adjust = 'FC_FM_Original_'+@Division+@Monthfc+'_Tmp'
	
	--declare @Status				int=0
	--if @n_continue =9
	--begin
	--	select @Status = isnull([Status],0) from FC_REfresh_WF where TagName = 'tag_gen_fm_non_modeling'
	--	--select Status = isnull([Status],0) from FC_REfresh_WF where TagName = 'tag_gen_fm_non_modeling'
	--	select * from FC_REfresh_WF

	--	if @Status is null
	--	begin
	--		select @Status = 0
	--	end
	--	if @debug>0
	--	begin
	--		select @Status '@Status'
	--	end
	--	--if @Status = 1
	--	--begin
	--	--	select @n_continue = 3, @c_errmsg = N'case 4 on going...'
	--	--end
	--end
	if @n_continue = 1
	begin
		--//Update adjust unit Forecast
		declare @listcol_column nvarchar(max) = ''			
		SELECT @listcol_column = ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'updateForecast','si')
		--SELECT listcol_column = ListColumn FROM fn_FC_GetColheader_Current('202408','updateForecast','si')
			
		declare @listcol_column_set_0 nvarchar(max) = ''	
		SELECT @listcol_column_set_0= ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'Set_0','')
		--SELECT listcol_column_set_0 = ListColumn FROM fn_FC_GetColheader_Current('202406','1. Baseline Qty_+','')
			
		declare @listcol_column_plus nvarchar(max) = ''	
		SELECT @listcol_column_plus= ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'1. Baseline Qty_+','')
		--SELECT * FROM fn_FC_GetColheader_Current('202406','1. Baseline Qty_+','')
	end
	if @n_continue=1
	begin
		if @Show_Selected_Status='Show_All_Selected'
		begin
			--select @sql ='
			--update '+@FC_FM_Original+'
			--set '+@listcol_column_set_0+'
			--where [Channel] NOT IN (''O+O'')
			--and [Time series] IN (''1. Baseline Qty'',''2. Promo Qty(Single)'',''4. Launch Qty'',''6. Total Qty'',''5. FOC Qty'')
			--and ('+@listcol_column_plus+')<>0'

			--if @debug>0
			--begin
			--	select @sql '@sql Clear fc'
			--end
			--execute(@sql)

			select @sql = 
			'update '+@FC_FM_Original+'
			set '+@listcol_column+'
			from '+@FC_FM_Original+' f
			Inner join '+@fc_fm_original_Adjust+' si on si.id = f.id
			where f.[Time series]<>''6. Total Qty'' '

			if @debug>0
			begin
				select @sql '@sql fm adjust Forecast-->Show_All_Selected'
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
		--else if @Show_Selected_Status='Show_Total_Selected'
		--begin
		--	--select @sql ='
		--	--update '+@FC_FM_Original+'
		--	--set '+@listcol_column_set_0+'
		--	--where [Channel] NOT IN (''O+O'')
		--	--and [Time series] IN (''1. Baseline Qty'',''2. Promo Qty(Single)'',''4. Launch Qty'',''6. Total Qty'',''5. FOC Qty'')
		--	--and ('+@listcol_column_plus+')<>0'

		--	--if @debug>0
		--	--begin
		--	--	select @sql '@sql clear fc'
		--	--end
		--	--execute(@sql)

		--	select @sql = 
		--	'update '+@FC_FM_Original+'
		--	set '+@listcol_column+'
		--	from '+@FC_FM_Original+' f
		--	Inner join '+@fc_fm_original_Adjust+' si on si.id = f.id
		--	where f.[Time series]=''6. Total Qty'' '

		--	if @debug>0
		--	begin
		--		select @sql '@sql fm adjust Forecast-->Show_Total_Selected'
		--	end
		--	execute(@sql)

		--	select @n_err = @@ERROR
		--	if @n_err<>0
		--	begin
		--		select @n_continue = 3
		--		--select @n_err=60003
		--		select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +ERROR_MESSAGE()+'./ ('+@sp_name+')'
		--	end
		--end
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