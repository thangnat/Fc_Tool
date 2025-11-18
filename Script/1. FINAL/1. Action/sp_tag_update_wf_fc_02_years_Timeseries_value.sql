/*
	declare 
		@b_Success				Int,
		@c_errmsg				Nvarchar(250)

	exec sp_tag_update_wf_fc_02_years_Timeseries_Value 'LDB','202410','All',@b_Success OUT, @c_errmsg OUT

	select @b_Success b_Success, @c_errmsg c_errmsg

	/*
		1. Baseline Qty
		2. Promo Qty(Single)
		3. Promo Qty(BOM)
		4. Launch Qty
		5. FOC Qty
		6. All
	*/
*/

Alter Proc sp_tag_update_wf_fc_02_years_Timeseries_value
	@Division				nvarchar(3),
	@FM_KEY					nvarchar(6),
	@TimeSeries				nvarchar(20),
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
		@sp_name = 'sp_tag_update_wf_fc_02_years_Timeseries_value',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	select @debug=debug from fnc_Debug('FC')
	--select @debug=1

	declare @Monthfc				nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from V_FC_FM_Table

	declare @FC_FM_Original			nvarchar(100) = ''
	select @FC_FM_Original = 'FC_FM_Original_'+@Division+@Monthfc	
	
	declare @FC_FM_Original_Value	nvarchar(200) = ''
	select @FC_FM_Original_Value = 'FC_FM_Original_'+@Division+@Monthfc+'_fc'
	--current value

	declare @list_C_current_Value	nvarchar(max) = ''
	select @list_C_current_Value = ListColumn FROM fn_FC_GetColheader_Current(@FM_Key,'Current_B_WF_VALUE','si')
	--select list_C_current_Value = ListColumn FROM fn_FC_GetColheader_Current('202408','Current_B_WF_VALUE','si')

	declare @list_C_current_Value_set_zero	nvarchar(max) = ''
	select @list_C_current_Value_set_zero = ListColumn FROM fn_FC_GetColheader_Current(@FM_Key,'set_0_v','si')
	--select list_C_current_Value_set_zero = ListColumn FROM fn_FC_GetColheader_Current('202407','set_0_v','si')

	declare @list_signature nvarchar(500)=''
	declare @Type_View nvarchar(20)=''

	if @debug>0
	begin
		select 'get signature run'
	end
	if @n_continue=1
	begin
		declare @tag_name nvarchar(300)=''
		select @tag_name=isnull([tag_name],'') from fnc_Get_Tag_name_Run_Active(@Division)
		--select tag_name=isnull([tag_name],'') from fnc_Get_Tag_name_Run_Active('LDB')

		if @tag_name<>''
		begin
			select 
				@list_signature=[List_Signature],
				@Type_View=[type_View] 
			from fnc_get_List_Signature(@tag_name)
			--and Tag_name='tag_gen_FM_FC_SI_BASELINE'
			/*
				select 
					list_signature=[List_Signature],
					Type_View=[type_View] 
				from fnc_get_List_Signature('tag_add_BFL_Master')
			*/
		end
		else
		begin
			select @list_signature='', @Type_View=''
		end


		if @list_signature is null
		begin
			select @list_signature=''
		end
		if @Type_View is null
		begin
			select @Type_View=''
		end
	end
	--select @Type_View=''
	--select @Type_View '@Type_View'
	if @n_continue=1
	begin
		if @Type_View='re-gen'
		begin
			if @list_signature=''
			begin
					select @n_continue = 3
				select @n_err=60001
				select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +':Signature should be not null./ ('+@sp_name+')'
			end
		end
	end	
	--//tag_Update_Forecast_Y0 & Y+1SI_Value_WF
	if @n_continue = 1
	begin
		
		if @TimeSeries = 'all'
		begin
			if @debug>0
			begin		
				select 'set Zero all'
			end
			if @Type_View=''
			begin
				--reset zero
				select @sql	=
				'update '+@FC_FM_Original
				+' set '+@list_C_current_Value_set_zero
				+' where 
						[Time series] NOT IN(''6. Total Qty'') 
					and Channel NOT IN(''O+O'') '
			end
			else
			begin
				--reset zero
				select @sql	=
				'update '+@FC_FM_Original+
				' set '+@list_C_current_Value_set_zero+
				' where 
						[Time series] NOT IN(''6. Total Qty'') 
					and [Channel] NOT IN(''O+O'')
					and [Signature] IN(select value from string_split('''+@list_signature+''','','')) '
			end
						
			if @debug>0
			begin
				select @sql '@sql set zero all'
			end
			execute(@sql)
			--//------------------------------------------------------------------
			if @debug>0
			begin
				select 'Update data value all'
			end
			if @Type_View=''
			begin
				--//update data
				select @sql =
				'update '+@FC_FM_Original+'   
				set   '
					+@list_C_current_Value+'				
				from '+@FC_FM_Original+' f     
				inner join     
				(     
					select      
						*
					from '+@FC_FM_Original_Value+' si (NOLOCK)
				) as si on      
					/*si.[Product Type] = f.[Product Type]   
				and */
				si.[SUB GROUP/ Brand] = f.[SUB GROUP/ Brand]   
				and si.channel = f.channel 
				and si.[Time series] = f.[Time series] 
				where 
					f.[Time series] NOT IN(''6. Total Qty'') 
				and f.Channel NOT IN(''O+O'') '
			end
			else
			begin
				--//update data
				select @sql =
				'update '+@FC_FM_Original+'   
				set   '
					+@list_C_current_Value+'				
				from '+@FC_FM_Original+' f     
				inner join     
				(     
					select      
						*
					from '+@FC_FM_Original_Value+' si (NOLOCK)
					where [Signature] IN(select value from string_split('''+@list_signature+''','',''))
				) as si on      
					/*si.[Product Type] = f.[Product Type]   
				and */
				si.[SUB GROUP/ Brand] = f.[SUB GROUP/ Brand]   
				and si.channel = f.channel 
				and si.[Time series] = f.[Time series] 
				where 
					f.[Time series] NOT IN(''6. Total Qty'') 
				and f.Channel NOT IN(''O+O'') 
				and f.[Signature] IN(select value from string_split('''+@list_signature+''','','')) '
			end
		end
		else
		begin
			if @debug>0
			begin		
				select 'set Zero by time series'
			end
			if @Type_View=''
			begin
				--reset zero
				select @sql	=
				'update '+@FC_FM_Original
				+' set '+@list_C_current_Value_set_zero
				+' where [Time series] = '''+@TimeSeries+''' '
			end
			else
			begin
				--reset zero
				select @sql	=
				'update '+@FC_FM_Original+' 
				set '+@list_C_current_Value_set_zero+' 
				where 
					[Time series] = '''+@TimeSeries+''' 
				and [Signature] IN(select value from string_split('''+@list_signature+''','',''))'
			end

			if @debug>0
			begin
				select @sql 'set Zero by time series'
			end
			execute(@sql)

			if @debug>0
			begin
				select 'Update data value by time series'
			end
			--//start update
			if @Type_View=''
			begin
				select @sql =
				'update '+@FC_FM_Original+'   
				set   '
					+@list_C_current_Value+'				
				from '+@FC_FM_Original+' f     
				inner join     
				(     
					select      
						*
					from '+@FC_FM_Original_Value+' si (NOLOCK)
				) as si on      
				/*si.[Product Type] = f.[Product Type]   
				and*/
					si.[SUB GROUP/ Brand] = f.[SUB GROUP/ Brand]   
				and si.channel = f.channel 
				and si.[Time series] = f.[Time series] 
				where 
					f.[Time series] = '''+@TimeSeries+''' 
				and f.[Time series] NOT IN(''6. Total Qty'') 
				and f.Channel NOT IN(''O+O'')' 
			end
			else
			begin
				select @sql =
				'update '+@FC_FM_Original+'   
				set   '
					+@list_C_current_Value+'				
				from '+@FC_FM_Original+' f     
				inner join     
				(     
					select      
						*
					from '+@FC_FM_Original_Value+' si (NOLOCK)
				) as si on      
					/*si.[Product Type] = f.[Product Type]   
				and*/
					si.[SUB GROUP/ Brand] = f.[SUB GROUP/ Brand]   
				and si.channel = f.channel 
				and si.[Time series] = f.[Time series] 
				where 
					f.[Time series] = '''+@TimeSeries+''' 
				and f.[Time series] NOT IN(''6. Total Qty'') 
				and f.Channel NOT IN(''O+O'')
				and f.[Signature] IN(select value from string_split('''+@list_signature+''','','')) ' 
			end
		end

		if @debug>0
		begin
			select @sql '@sql Update_Forecast_Y0 & Y+1SI_Value_WF'
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