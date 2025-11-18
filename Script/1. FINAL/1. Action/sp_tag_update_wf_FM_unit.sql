/*
	declare 
		@b_Success				Int,
		@c_errmsg				Nvarchar(250)

	exec sp_tag_update_wf_FM_unit 'LDB','202407',@b_Success OUT, @c_errmsg OUT

	select @b_Success b_Success, @c_errmsg c_errmsg
*/

Alter Proc sp_tag_update_wf_FM_unit
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
		@sp_name = 'sp_tag_update_wf_FM_unit',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	select @debug=debug from fnc_Debug('FC')
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
		from fnc_get_List_Signature('tag_gen_FM_FC_SI_BASELINE')
		--and Tag_name='tag_gen_FM_FC_SI_BASELINE'

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

	if @debug>0
	begin
		select 'Set zero'
	end
	if @n_continue=1
	begin
		declare @listcol_column_set_zero nvarchar(max) = ''
		SELECT @listcol_column_set_zero = ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'FM_Original','si')
		--SELECT listcol_column_set_zero = ListColumn FROM fn_FC_GetColheader_Current('202410','FM_Original','si')	
		
		if @Type_View=''
		begin
			--update zero
			select @sql=
			'update '+@FC_FM_Original+' 
			set '+@listcol_column_set_zero+' 
			where
				[Channel]=''OFFLINE'' 
			and [Time series]=''1. Baseline Qty'' '

			if @debug>0
			begin
				select @sql '@sql update zero offline only baseline'
			end
			execute(@sql)

			select @sql=
			'update '+@FC_FM_Original+' 
			set '+@listcol_column_set_zero+' 
			where
				[Channel]=''ONLINE'' '

			if @debug>0
			begin
				select @sql '@sql update zero online all'
			end
			execute(@sql)
		end
		else
		begin
			--update zero
			select @sql=
			'update '+@FC_FM_Original+' 
			set '+@listcol_column_set_zero+' 
			where
				[Channel]=''OFFLINE'' 
			and [Time series]=''1. Baseline Qty''
			and [Signature] IN(select value from string_split('''+@list_signature+''','',''))'

			if @debug>0
			begin
				select @sql '@sql update zero offline only baseline'
			end
			execute(@sql)

			select @sql=
			'update '+@FC_FM_Original+' 
			set '+@listcol_column_set_zero+' 
			where
				[Channel]=''ONLINE''
			and [Signature] IN(select value from string_split('''+@list_signature+''','',''))'

			if @debug>0
			begin
				select @sql '@sql update zero online All'
			end
			execute(@sql)
		end		

		select @n_err = @@ERROR
		if @n_err<>0
		begin
			select @n_continue = 3
			--select @n_err=60003
			select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +ERROR_MESSAGE()+'./ ('+@sp_name+')'
		end
	end
	if @debug>0
	begin		
		select tablename = 'Update FM Forecast'
	end
	if @n_continue=1
	begin		
		--//Update FM forecast
		declare @ListColumn_Current	nvarchar(max) = ''
		SELECT @ListColumn_Current = ListColumn FROM fn_FC_GetColheader_Current(@FM_Key,'1. Baseline Qty','si')
		--SELECT ListColumn_Current = ListColumn FROM fn_FC_GetColheader_Current('202404','1. Baseline Qty','si')

		if @Type_View=''
		begin
			select @sql = 
			'update '+@FC_FM_Original+'
			set '+@ListColumn_Current+'
			from '+@FC_FM_Original+' f
			Inner JOIN 
			(
				SELECT *
				FROM FC_FM_SUM_BASELINE_OFFLINE_'+@Division+@Monthfc+'
				where ISNULL([SUB GROUP/ Brand],'''')<>''''
				UNION ALL
				SELECT *
				FROM FC_FM_SUM_BASELINE_ONLINE_'+@Division+@Monthfc+'
				where ISNULL([SUB GROUP/ Brand],'''')<>''''
			) si on 
				si.[SUB GROUP/ Brand]=f.[SUB GROUP/ Brand] 
			AND si.[Local Level]=f.[Channel] 
			and si.[Time series]=f.[Time series] '
		end
		else
		begin
			select @sql=
			'Update '+@FC_FM_Original+'
			set '+@ListColumn_Current+'
			from '+@FC_FM_Original+' f
			Inner JOIN 
			(
				SELECT 
					*
				FROM FC_FM_SUM_BASELINE_OFFLINE_'+@Division+@Monthfc+'
				where ISNULL([SUB GROUP/ Brand],'''')<>''''
				UNION ALL
				SELECT 
					*
				FROM FC_FM_SUM_BASELINE_ONLINE_'+@Division+@Monthfc+'
				where ISNULL([SUB GROUP/ Brand],'''')<>''''
			) si on 
				si.[SUB GROUP/ Brand]=f.[SUB GROUP/ Brand] 
			AND si.[Local Level]=f.[Channel] 
			and si.[Time series]=f.[Time series]
			where f.[Signature] IN(select value from string_split('''+@list_signature+''','','')) '
		end

		if @debug>0
		begin
			select @sql '@sql Update FM Forecast'
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