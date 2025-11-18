/*
	declare 
		@b_Success				Int,
		@c_errmsg				Nvarchar(250)

	exec sp_tag_update_wf_budget_unit 'CPD','202502',@b_Success OUT, @c_errmsg OUT

	select @b_Success b_Success, @c_errmsg c_errmsg
*/

Alter Proc sp_tag_update_wf_budget_unit
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
		@sp_name = 'sp_tag_update_wf_budget_unit',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	select @debug=debug from fnc_debug('FC')
	--select @debug=1

	declare @Monthfc				nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from V_FC_FM_Table

	declare @FC_FM_Original			nvarchar(100) = ''
	select @FC_FM_Original = 'FC_FM_Original_'+@Division+@Monthfc	

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
		from fnc_get_List_Signature('tag_gen_budget_budget')
		--and Tag_name='tag_gen_budget_budget'

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
	--//sp_tag_update_wf_budget_unit
	if @n_continue = 1
	begin
		declare @year0 nvarchar(4) = ''
		select @year0 = left(@FM_Key,4)

		declare @year1 nvarchar(4) = ''
		select @year1 = cast((cast(@year0 as int)+1) as nvarchar(4))

		declare @List_Budget_unit_zero		nvarchar(max)=''
		SELECT @List_Budget_unit_zero = ListColumn FROM fn_FC_GetColheader_Current_BT(@FM_KEY,'','B',1)
		--SELECT List_Budget_unit_zero = ListColumn FROM fn_FC_GetColheader_Current_BT('202407','','B',1)
			
		--budget unit
		declare @List_Budget_unit			nvarchar(max) = ''
		SELECT @List_Budget_unit = ListColumn FROM fn_FC_GetColheader_Current_BT(@FM_Key,'','B',2)
		--SELECT List_Budget_unit = ListColumn FROM fn_FC_GetColheader_Current_BT('202403','','B',2)
	end
	if @n_continue=1
	begin
		if @debug>0
		begin
			select 'set zero',@Type_View '@Type_View'
		end
		if @Type_View=''
		begin
			select @sql=
			'update '+@FC_FM_Original+' 
			set '+@List_Budget_unit_zero+' 
			where [Channel] IN(''OFFLINE'',''ONLINE'',''O+O'') '
		end
		else
		begin
			select @sql=
			'update '+@FC_FM_Original+' 
			set '+@List_Budget_unit_zero+' 
			where 
				[Channel] IN(''OFFLINE'',''ONLINE'',''O+O'')
			and [Signature] IN(select value from string_split('''+@list_signature+''','','')) '
		end

		if @debug>0
		begin
			select @sql 'update zero'
		end
		execute(@sql)

		if @debug>0
		begin
			select 'sp_tag_update_wf_budget_unit',@Type_View '@Type_View'
		end
		if @Type_View=''
		begin
			select @sql =
			'update '+@FC_FM_Original+'   
			set   '
				+@list_budget_unit+'				
			from '+@FC_FM_Original+' f     
			left join     
			(     
				select 
					* 
				from fc_budget_'+@Division+@Monthfc+' 
				where 
					[version] = '+@year0+' 
				and [Type] = ''B0''
				and isnull([SUB-GROUP],'''')<>''''
			) b0 on 
				b0.[SUB-GROUP] = f.[SUB GROUP/ Brand] 
			and b0.CHANNEL =f.Channel 
			and f.[Time series] = b0.[Time series]  
			left join 
			(
				select * 
				from fc_budget_'+@Division+@Monthfc+' 
				where 
					[version] = '+@year1+' 
				and [Type] = ''B1''
				and isnull([SUB-GROUP],'''')<>''''
			) b1 on
				b1.[SUB-GROUP] = f.[SUB GROUP/ Brand] 
			and b1.[Channel] = f.Channel 
			and b1.[Time series] = f.[Time series]	'
		end
		else
		begin
			select @sql =
			'update '+@FC_FM_Original+'   
			set   '
				+@list_budget_unit+'				
			from '+@FC_FM_Original+' f     
			left join     
			(     
				select * 
				from fc_budget_'+@Division+@Monthfc+' 
				where 
					[version] = '+@year0+' 
				and [Type] = ''B0''
				and isnull([SUB-GROUP],'''')<>''''
			) b0 on 
				b0.[SUB-GROUP] = f.[SUB GROUP/ Brand] 
			and b0.CHANNEL =f.Channel 
			and f.[Time series] = b0.[Time series]  
			left join 
			(
				select * 
				from fc_budget_'+@Division+@Monthfc+' 
				where 
					[version] = '+@year1+' 
				and [Type] = ''B1''
				and isnull([SUB-GROUP],'''')<>''''
			) b1 on
				b1.[SUB-GROUP] = f.[SUB GROUP/ Brand] 
			and b1.[Channel] = f.Channel 
			and b1.[Time series] = f.[Time series]
			where f.[Signature] IN(select value from string_split('''+@list_signature+''','',''))'
		end

		if @debug>0
		begin
			select @sql 'sp_tag_update_wf_budget_unit'
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