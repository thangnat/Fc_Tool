/*
	declare 
		@b_Success				Int,
		@c_errmsg				Nvarchar(250)

	exec sp_tag_update_wf_trend_unit 'LLD','202405',@b_Success OUT, @c_errmsg OUT

	select @b_Success b_Success, @c_errmsg c_errmsg
*/

Alter Proc sp_tag_update_wf_trend_unit
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
		@sp_name = 'sp_tag_update_wf_trend_unit',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()
	
	select @debug=debug from fnc_debug('FC')
	--select @debug=1

	declare @list_signature nvarchar(500)=''
	declare @Type_View nvarchar(20)=''

	if @debug>0
	begin
		select 'get signature run'
	end
	if @n_continue=1
	begin
		select 
			@list_signature=[List_Signature],
			@Type_View=[type_View] 
		from fnc_get_List_Signature('tag_gen_budget_trend')
		--and Tag_name='tag_gen_budget_trend'

		if @list_signature is null
		begin
			select @list_signature=''
		end
		if @Type_View is null
		begin
			select @Type_View=''
		end
	end
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
	if @n_continue=1
	begin
		declare @Monthfc				nvarchar(20)=''
		select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from V_FC_FM_Table
	
		declare @FC_FM_Original			nvarchar(100) = ''
		select @FC_FM_Original = 'FC_FM_Original_'+@Division+@Monthfc	
		--trend unit	
		declare @list_Trend_unit_zero nvarchar(max) = ''
		SELECT @list_Trend_unit_zero = ListColumn FROM fn_FC_GetColheader_Current_BT(@FM_KEY,'','T',1)
		--SELECT list_Trend_unit = ListColumn FROM fn_FC_GetColheader_Current_BT('202407','','T',1)

		declare @list_Trend_unit			nvarchar(max) = ''
		SELECT @list_Trend_unit = ListColumn FROM fn_FC_GetColheader_Current_BT(@FM_Key,'','T',2)
		--SELECT list_Trend_unit = ListColumn FROM fn_FC_GetColheader_Current_BT('202407','','T',2)
		
		declare @year0 nvarchar(4) = ''
		select @year0 = left(@FM_Key,4)

		declare @year1 nvarchar(4) = ''
		select @year1 = cast((cast(@year0 as int)+1) as nvarchar(4))
	end

	if @n_continue=1
	begin
		--//create trend script
		declare @tmpTrend table
		(
			id				int identity(1,1),
			TrendName		nvarchar(5)
		)
		declare @TrendScript		nvarchar(max) = ''
		
		insert into @tmpTrend(TrendName) 
		select TrendName from V_FC_Trend_Config
		
		declare @currentrowTrend int = 1
		declare @totalrowTrend int = 0
		select @totalrowTrend = isnull(count(*),0) from @tmpTrend

		while (@currentrowTrend<=@totalrowTrend)
		begin
			declare @trendname nvarchar(5) = ''
			select @trendname = TrendName from @tmpTrend where id = @currentrowTrend


			if len(@TrendScript)=0
			begin
				select @TrendScript = 'left join 
										(
											select * 
											from fc_Trend_'+@Division+@Monthfc+' 
											where 
												[Type] = ''T'+@trendname+'''
											and isnull([SUB-GROUP],'''')<>''''
										) t'
										+@trendname+' on t'+@trendname+'.[SUB-GROUP] = f.[SUB GROUP/ Brand] and t'
										+@trendname+'.CHANNEL = f.Channel and f.[Time series] = t'+@trendname+'.[Time series]'
			end
			else
			begin
				select @TrendScript = @TrendScript+char(10)
										+' left join 
										(
											select * 
											from fc_Trend_'+@Division+@Monthfc+'
											where 
												[Type] = ''T'+@trendname+'''
											and isnull([SUB-GROUP],'''')<>''''
										) t'+@trendname+' on t'+@trendname+'.[SUB-GROUP] = f.[SUB GROUP/ Brand] and t'
										+@trendname+'.CHANNEL = f.Channel and f.[Time series] = t'+@trendname+'.[Time series]'
			end			

			select @currentrowTrend = @currentrowTrend + 1
		end
	end

	--//sp_tag_update_wf_budget_unit
	if @n_continue = 1
	begin	
		if @debug>0
		begin
			select 'Set zero'
		end
		if @Type_View=''
		begin
			select @sql=
			'update '+@FC_FM_Original+' 
				set '+@list_Trend_unit_zero+' 
			where [Channel] IN(''OFFLINE'',''ONLINE'',''O+O'') '
		end
		else
		begin
			select @sql=
			'update '+@FC_FM_Original+' 
				set '+@list_Trend_unit_zero+' 
			where 
				[Channel] IN(''OFFLINE'',''ONLINE'',''O+O'')
			and [Signature] IN(select value from string_split('''+@list_signature+''','','')) '
		end

		if @debug>0
		begin
			select @sql '@sql update zero'
		end
		execute(@sql)

		if @debug>0
		begin
			select @sql 'sp_tag_update_wf_trend_unit'
		end
		if @Type_View=''
		begin
			select @sql =
			'update '+@FC_FM_Original+'   
			set   '
				+@List_trend_unit+'				
			from '+@FC_FM_Original+' f '+@TrendScript
		end
		else
		begin
			select @sql =
			'update '+@FC_FM_Original+'   
			set   '
				+@List_trend_unit+'				
			from '+@FC_FM_Original+' f '+@TrendScript+'
			where f.[Signature] IN(select value from string_split('''+@list_signature+''','','')) '
		end

		if @debug>0
		begin
			select @sql 'sp_tag_update_wf_trend_unit'
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