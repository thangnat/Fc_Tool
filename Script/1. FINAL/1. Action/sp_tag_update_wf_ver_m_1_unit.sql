/*
	declare 
		@b_Success				Int,
		@c_errmsg				Nvarchar(250)

	exec sp_tag_update_wf_ver_m_1_unit 'CPD','202404',@b_Success OUT, @c_errmsg OUT

	select @b_Success b_Success, @c_errmsg c_errmsg
*/

Alter Proc sp_tag_update_wf_ver_m_1_unit
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
		@sp_name = 'sp_tag_update_wf_ver_m_1_unit',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	select @debug=debug from fnc_debug('FC')

	declare @Monthfc				nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from V_FC_FM_Table

	declare @FC_FM_Original			nvarchar(100) = ''
	select @FC_FM_Original = 'FC_FM_Original_'+@Division+@Monthfc

	declare @FC_FM_Original_HIS nvarchar(100)=''
	select @FC_FM_Original_HIS='FC_FM_Original_'+@Division+'_'+case when right(@FM_KEY,2)='01' then format((cast(left(@FM_KEY,4) as int)-1),'0000') else left(@FM_KEY,4) end+format(case when right(@FM_KEY,2)='01' then '12' else cast(right(@FM_KEY,2) as int)-1 end ,'00')
	--select FC_FM_Original_HIS='FC_FM_Original_'+'LDB'+'_'+case when right('202501',2)='01' then format((cast(left('202501',4) as int)-1),'0000') else left('202501',4) end+format(case when right('202501',2)='01' then '12' else cast(right('202501',2) as int)-1 end ,'00')
	--select FC_FM_Original_HIS='FC_FM_Original_'+'LDB'+'_'+left('202501',4)+format(cast(right('202501',2) as int)-1,'00')

	--m-1 unit
	declare @list_month_set_zero nvarchar(max)=''
	SELECT @list_month_set_zero=ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'A_Version_M-1','b')
	--SELECT list_month_set_zero=ListColumn FROM fn_FC_GetColheader_Current('202408','A_Version_M-1','b')

	declare @list_month_set_zero_value nvarchar(max)=''
	SELECT @list_month_set_zero_value=ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'A_Version_M-1_Value','b')
	--SELECT list_month_set_zero_value=ListColumn FROM fn_FC_GetColheader_Current('202408','A_Version_M-1_Value','b')

	declare @listversionM_minus_1B	nvarchar(max) = ''
	select @listversionM_minus_1B = ListColumn FROM fn_FC_GetColheader_Current(@FM_Key,'B_Version_M-1','si')
	--select listversionM_minus_1B = ListColumn FROM fn_FC_GetColheader_Current('202408','B_Version_M-1','si')
	
	declare @listversionM_minus_1C	nvarchar(max) = ''
	select @listversionM_minus_1C = ListColumn FROM fn_FC_GetColheader_Current(@FM_Key,'C_Version_M-1','si')
	--select listversionM_minus_1C = ListColumn FROM fn_FC_GetColheader_Current('202403','A_Version_M-1','si')

	--//Update total qty & O+O
	if @n_continue = 1
	begin
		select @sql=
		'Update '+@FC_FM_Original+'
			set '+@list_month_set_zero+','+@list_month_set_zero_value+'
		where Channel IN(''ONLINE'',''OFFLINE'',''O+O'') '
		
		if @debug>0
		begin		
			select @sql '@sql set zero'
		end
		execute(@sql)

		
		select @sql =
		'update '+@FC_FM_Original+'   
			set '+@listversionM_minus_1C+'
		from '+@FC_FM_Original+' f     
		left join     
		(     
			select      
				[Product Type],   
				[SUB GROUP/ Brand],    
				Channel,    
				[Time series],'
				+@listversionM_minus_1B+'
			from '+@FC_FM_Original_HIS+' si (NOLOCK)
		) as si on      
			si.[Product Type] = f.[Product Type]   
		and si.[SUB GROUP/ Brand] = f.[SUB GROUP/ Brand]   
		and si.channel = f.channel 
		and si.[Time series] = f.[Time series] ' 

		if @debug>0
		begin		
			select @sql '@sql Update Version M-1 unit'
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