/*
	declare
		@b_Success				Int,
		@c_errmsg				Nvarchar(250)

	exec sp_tag_update_wf_foc_unit_only_offline 'CPD','202406',@b_Success OUT, @c_errmsg OUT

	select @b_Success b_Success, @c_errmsg c_errmsg
*/

Alter Proc sp_tag_update_wf_foc_unit_only_offline
	@Division				nvarchar(3),
	@FM_KEY					nvarchar(6),
	@b_Success				Int				OUTPUT,     
	@c_errmsg				Nvarchar(250)	OUTPUT
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
		,@sql					nvarchar(max) = ''
			
	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_tag_update_wf_foc_unit_only_offline',
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
		from fnc_get_List_Signature('tag_add_FC_SI_Group_FC_SI_FOC')

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
		select @FC_FM_Original '@FC_FM_Original'
	end

	if @debug>0
	begin		
		select tablename = 'Update FOC Forecast'
	end
	if @n_continue = 1
	begin
		--//Update FOC Forecast
		declare @listcol_FOC nvarchar(max) = ''
		SELECT @listcol_FOC = ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'updateForecast','si')
		--SELECT listcol_FOC = ListColumn FROM fn_FC_GetColheader_Current('202405','updateForecast','si')
		
		declare @listcol_FOC_detail nvarchar(max) = ''
		SELECT @listcol_FOC_detail = ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'updateForecastnew','si')
		--SELECT listcol_FOC_detail = ListColumn FROM fn_FC_GetColheader_Current('202405','updateForecastnew','si')
		
		declare @listcol_Promo_single_detail_zero nvarchar(max) = ''
		SELECT @listcol_Promo_single_detail_zero = ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'FM_Original','si')
		--SELECT listcol_Promo_single_detail_zero = ListColumn FROM fn_FC_GetColheader_Current('202407','FM_Original','si')	
		
		if @debug>0
		begin
			select 'set zero OFFLINE'
		end
		if @Type_View=''
		begin
			select @sql=
			'update '+@FC_FM_Original+' 
			set '+@listcol_Promo_single_detail_zero+' 
			where
				[Time series]=''5. FOC Qty''
			and Channel =''OFFLINE'' '
		end
		else
		begin
			select @sql=
			'update '+@FC_FM_Original+' 
			set '+@listcol_Promo_single_detail_zero+' 
			where
				[Time series]=''5. FOC Qty''
			and [Channel] =''OFFLINE''
			and [Signature] IN(select value from string_split('''+@list_signature+''','',''))'
		end

		if @debug>0
		begin
			select @sql '@sql update zero'
		end
		execute(@sql)

		if @debug>0
		begin
			select 'Update Unit Update FOC Forecast offline'
		end
		if @Type_View=''
		begin
			select @sql = 
			'update '+@FC_FM_Original+'
			set '+@listcol_FOC+'
			from '+@FC_FM_Original+' f
			Inner join 
			(
				select
					si.SubGrp,
					si.Channel,
					si.[Time series],'
					+@listcol_FOC_detail+'
				from FC_SI_FOC_Single_'+@Division+@Monthfc+' si
				group by
					si.SubGrp,
					si.Channel,
					si.[Time series]
			) si on
				si.SubGrp=f.[SUB GROUP/ Brand]
			and si.Channel=f.[Channel]
			and si.[Time series]=f.[Time series] 
			and f.Channel = ''OFFLINE'' '
		end
		else
		begin
			select @sql = 
			'update '+@FC_FM_Original+'
			set '+@listcol_FOC+'
			from '+@FC_FM_Original+' f
			Inner join 
			(
				select
					si.SubGrp,
					si.Channel,
					si.[Time series],'
					+@listcol_FOC_detail+'
				from FC_SI_FOC_Single_'+@Division+@Monthfc+' si
				group by
					si.SubGrp,
					si.Channel,
					si.[Time series]
			) si on
				si.SubGrp=f.[SUB GROUP/ Brand]
			and si.Channel=f.[Channel]
			and si.[Time series]=f.[Time series] 
			and f.Channel=''OFFLINE'' 
			where f.[Signature] IN(select value from string_split('''+@list_signature+''','',''))'
		end

		if @debug>0
		begin
			select @sql 'Update FOC Forecast'
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