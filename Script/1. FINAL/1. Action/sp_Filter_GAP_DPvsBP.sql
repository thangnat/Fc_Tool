/*
	declare 
		@b_Success				Int,
		@c_errmsg				Nvarchar(250)

	exec sp_Filter_GAP_DPvsBP 
					'CPD',
					'202411',
					'%',
					'1',
					'=',
					'47',
					'ONLINE,OFFLINE,O+O',
					'YFG,YSM2',
					'Y0 (u) M11,Y0 (u) M12,Y+1 (u) M1,Y+1 (u) M2,Y+1 (u) M3',
					'INDIVIDUAL',
					'ALL',
					'ALL',
					'ALL',
					'ALL',
					'ALL',
				@b_Success OUT, @c_errmsg OUT

	select @b_Success '@b_Success',@c_errmsg '@c_errmsg'

	select * from FC_FILTER_GAP_DPvsBP_CPD_VNCORPVNWKS0s850
	select * from FC_FILTER_GAP_DPvsBP_CPD_VNCORPVNSC1
*/

Alter proc sp_Filter_GAP_DPvsBP
	@Division				nvarchar(3),
	@FM_KEY					nvarchar(6),
	@Type_UNIT_VALUE		nvarchar(10),
	@abs					nvarchar(1),
	@compare				nvarchar(10),
	@compare_value			nvarchar(20),
	@List_channel			nvarchar(50),
	@List_MaterialType		nvarchar(20),
	@ListMonth				nvarchar(1000),
	@Method_Calculation		nvarchar(50),
	@signature				nvarchar(1000),
	@HERO					nvarchar(1000),
	@Category				nvarchar(1000),
	@Sub_Category			nvarchar(1000),
	@Group_Class			nvarchar(1000),
	@b_Success				Int				OUTPUT,     
	@c_errmsg				Nvarchar(250)	OUTPUT
	with encryption
AS
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRAN
BEGIN TRY
	DECLARE   
		 @debug					int=1
		,@sp_name				Nvarchar(100)
		,@n_continue			Int
		,@USERS					Nvarchar(50)
		,@MODIFILED				Datetime
		,@n_err					int
		,@fm_file_name			nvarchar(100) =''
		,@sql					nvarchar(max) = ''

	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_Filter_GAP_DPvsBP',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()
	--declare @division				nvarchar(3)='CPD'
	--declare @fm_key					nvarchar(6)='202408'
	--declare @debug					int=0
	--declare @sql					nvarchar(max)=''
	--//Unit/value
	--declare @Type_UNIT_VALUE		nvarchar(10)='PERCENT'
	--declare @abs					nvarchar(1)='1'
	--declare @compare				nvarchar(10)='='
	--declare @compare_value			nvarchar(20)='38'
	--//Channel
	--declare @List_channel			nvarchar(50)='ONLINE,OFFLINE'
	--//Period: months
	--declare @ListMonth				nvarchar(1000)='[Y0 (u) M8],[Y0 (u) M9],[Y0 (u) M10]'

	--//Accessories
	--declare @signature				nvarchar(50)='P2,P4'
	--declare @HERO					nvarchar(1000)='SUPER HERO,HERO'
	--declare @Category				nvarchar(1000)='ALL'
	--declare @Sub_Category			nvarchar(1000)='ALL'
	--declare @Group_Class			nvarchar(1000)='ALL'
	select @debug=debug from fnc_debug('FC')
	select @debug=1
	declare @Monthfc				nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from V_FC_FM_Table

	declare @accessories_ok			nvarchar(1000)=''
	declare @tableName				nvarchar(200)='FC_FILTER_GAP_DPvsBP_'+@division+'_'+HOST_NAME()
	declare @list_Column_fc_unit	nvarchar(max)=''
	declare @list_Column_fc_value	nvarchar(max)=''

	--//result
	declare @list_column			nvarchar(1000)=''
	declare @list_condition_ok		nvarchar(1000)=''
	declare @list_condition_summary	nvarchar(1000)=''
	declare @list_Condition_Final	nvarchar(1000)=''
	declare @listmonth_summary		nvarchar(1000)=''
	declare @tmp_convert table(id int identity(1,1),[Month] nvarchar(20),[Convert] nvarchar(200))

	if @n_continue=1
	begin
		select @listmonth_summary='and (['+REPLACE(@listmonth,',',']+[')+'])<>0'
		if @debug>0
		begin
			select @listmonth_summary '@listmonth_summary'
		end
	end
	if @debug>0
	begin
		select HOST_NAME()
	end
	IF @n_continue=1
	BEGIN
		select @list_Column_fc_unit = ListColumn from fn_FC_GetColheader_Current(@FM_KEY,'1. Baseline Qty','f')
		--select list_Column_fc_unit = ListColumn from fn_FC_GetColheader_Current('202408','1. Baseline Qty','f')
		if @debug>0
		begin
			select @list_Column_fc_unit '@list_Column_fc_unit'
		end
		select @list_Column_fc_value = ListColumn from fn_FC_GetColheader_Current(@FM_KEY,'updateForecast_Value','f')
		--select list_Column_fc_value = ListColumn from fn_FC_GetColheader_Current('202408','updateForecast_Value','f')
		if @debug>0
		begin
			select @list_Column_fc_value '@list_Column_fc_value'
		end	

		insert into @tmp_convert([Month],[Convert])
		select 
			[Month]=cast(value as nvarchar(20)),
			[Convert]='@abs1@'+[value]+'@abs2@ @compare@ OR'
		from string_split(@ListMonth,',')

		if @debug>0
		begin
			select * from @tmp_convert
		end

		declare @totalrows int=0
		declare @currentrow int=1
		declare @List_Condition_Months nvarchar(200)=''

		select @totalrows=isnull(count(*),0) from @tmp_convert
		/*
		select @list_condition_summary='('+replace(@ListMonth,',','+')+') '+@compare+@compare_value
		if @debug>0
		begin
			select @list_condition_summary '@list_condition_summary'
		end
		*/
		if @debug>0
		begin
			select @Method_Calculation '@Method_Calculation'
		end
		
		while (@currentrow<=@totalrows)
		begin
			declare @convert_item nvarchar(200)=''
			select @convert_item=[Convert] from @tmp_convert where id=@currentrow
			if @debug>0
			begin
				select @convert_item '@convert_item'
			end
			if @Method_Calculation='INDIVIDUAL'
			begin
				if @List_Condition_Months=''
				begin
					select @List_Condition_Months=case 
														when @abs='1' then 
															replace(replace(@convert_item,'@abs1@','abs(['+case when @Type_UNIT_VALUE='VALUE' then '(Value)_' else '' end+''),'@abs2@','])') 
														else  
															replace(replace(@convert_item,'@abs1@','(['+case when @Type_UNIT_VALUE='VALUE' then '(Value)_' else '' end+''),'@abs2@','])')
													end
				end
				else
				begin
					select @List_Condition_Months=@List_Condition_Months+' '+case 
																				when @abs='1' then 
																					replace(replace(@convert_item,'@abs1@','abs(['+case when @Type_UNIT_VALUE='VALUE' then '(Value)_' else '' end+''),'@abs2@','])') 
																				else  
																					replace(replace(@convert_item,'@abs1@','(['+case when @Type_UNIT_VALUE='VALUE' then '(Value)_' else '' end+''),'@abs2@','])')
																			end
				end
			end
			else
			begin
				if @List_Condition_Months=''
				begin
					select @List_Condition_Months=replace(replace(@convert_item,'@abs1@','['+case when @Type_UNIT_VALUE='VALUE' then '(Value)_' else '' end+''),'@abs2@',']') 
				end
				else
				begin
					select @List_Condition_Months=@List_Condition_Months+replace(replace(@convert_item,'@abs1@','['+case when @Type_UNIT_VALUE='VALUE' then '(Value)_' else '' end+''),'@abs2@',']') 
				end
			end

			select @currentrow=@currentrow+1
		end
		if @debug>0
		begin
			select @List_Condition_Months '@List_Condition_Months'
		end
		if @Method_Calculation='SUMMARY'
		begin
			select @list_Condition_Final=case 
											when @abs='1' then 'ABS('+@List_Condition_Months+')' 
											else '('+@List_Condition_Months+')' 
										end

			select @list_column=replace(replace(@list_Condition_Final,'@compare@ OR','+'),'+)',')')+@compare+@compare_value
		end
		else
		begin
			select @list_Condition_Final=@List_Condition_Months
			select @list_column=replace(@list_Condition_Final,'@compare@',@compare+@compare_value)
		end
		if @debug>0
		begin
			select @list_Condition_Final '@list_Condition_Final',@list_column '@list_column',@compare_value '@compare_value'
		end
		--select @list_column=replace(@list_Condition_Final,'@compare@',@compare+@compare_value)
		select @list_condition_ok=case when @Method_Calculation='INDIVIDUAL' then left(@list_column,len(@list_column)-3) else @list_column end

		if @debug>0
		begin
			select @list_condition_ok '@list_condition_ok'
		end
		select @accessories_ok=case when len(@signature)>0 and @signature<>'ALL' then 'and [Signature] IN(select value from string_split('''+@signature+''','',''))' else '' end
								+case when len(@HERO)>0 and @HERO<>'ALL' then ' and HERO IN(select value from string_split('''+@HERO+''','',''))' else '' end
								+case when len(@Category)>0 and @Category<>'ALL' then ' and [CAT/Axe] IN(select value from string_split('''+@Category+''','',''))' else '' end
								+case when len(@Sub_Category)>0 and @Sub_Category<>'ALL' then ' and [SUB CAT/ Sub Axe] IN(select value from string_split('''+@Sub_Category+''','',''))' else '' end
								+case when len(@Group_Class)>0 and @Group_Class<>'ALL' then ' and [GROUP/ Class] IN(select value from string_split('''+@Group_Class+''','',''))' else '' end
		if @debug>0
		begin
			select @accessories_ok '@accessories_ok'
		end
		if exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID(@tableName) AND type in (N'U')
		)
		begin
			select @sql = 'drop table '+@tableName
			if @debug>0
			begin
				select @sql '@sql drop table filter'
			end
			execute(@sql)
		end
		select @sql='
		select
			[ID],
			[Signature],
			[HERO],
			[CAT/Axe],
			[SUB CAT/ Sub Axe],
			[GROUP/ Class],
			[Product type],
			[Forecasting Line]=[SUB GROUP/ Brand],
			[Channel],
			[Time series],'
			+@list_Column_fc_unit+','
			+@list_Column_fc_value+' 
			INTO '+@tableName+'
		from FC_FM_Original_'+@division+@Monthfc+' f
		where 
			[Time series] IN(select value from string_split('+case when @Type_UNIT_VALUE IN('UNIT','VALUE') then '''8. BP vs FC (u)''' else '''9. BP vs FC (%)''' end+','',''))
		and [Channel] IN(select value from string_split('''+@List_channel+''','',''))
		and [Product type] IN(select value from string_split('''+@List_MaterialType+''','',''))
		and ('+@list_condition_ok+')
		'+case when len(@accessories_ok)>0 then @accessories_ok else '' end
		+@listmonth_summary

		if @debug>0
		begin
			select @sql
		end
		execute(@sql)

		select @n_err = @@ERROR
		if @n_err<>0
		begin				
			select @n_continue = 3
			select @n_err=60002
			select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +ERROR_MESSAGE()+'./ ('+@sp_name+')'
		end
	END

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

/*
[Y0 (u) M8],
[Y0 (u) M9],
[Y0 (u) M10],
[Y0 (u) M11],
[Y0 (u) M12],
[Y+1 (u) M1],
[Y+1 (u) M2],
[Y+1 (u) M3],
[Y+1 (u) M4],
[Y+1 (u) M5],
[Y+1 (u) M6],
[Y+1 (u) M7],
[Y+1 (u) M8],
[Y+1 (u) M9],
[Y+1 (u) M10],
[Y+1 (u) M11],
[Y+1 (u) M12],
[(Value)_Y0 (u) M8],
[(Value)_Y0 (u) M9],
[(Value)_Y0 (u) M10],
[(Value)_Y0 (u) M11],
[(Value)_Y0 (u) M12],
[(Value)_Y+1 (u) M1],
[(Value)_Y+1 (u) M2],
[(Value)_Y+1 (u) M3],
[(Value)_Y+1 (u) M4],
[(Value)_Y+1 (u) M5],
[(Value)_Y+1 (u) M6],
[(Value)_Y+1 (u) M7],
[(Value)_Y+1 (u) M8],
[(Value)_Y+1 (u) M9],
[(Value)_Y+1 (u) M10],
[(Value)_Y+1 (u) M11],
[(Value)_Y+1 (u) M12]
*/
