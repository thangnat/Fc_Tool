/*
	declare 
		@b_Success				Int,
		@c_errmsg				Nvarchar(250)

	exec sp_tag_update_wf_value_pass_02_years 'CPD','202410',@b_Success OUT, @c_errmsg OUT

	select @b_Success b_Success, @c_errmsg c_errmsg

	select * from FC_FM_Original_CPD_202410_pass where [SUB GROUP/ Brand]='AGE REWIND CONCEALER' and [time series]='1. baseline qty'
*/

Alter Proc sp_tag_update_wf_value_pass_02_years
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
		@sp_name = 'sp_tag_update_wf_value_pass_02_years',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	select @debug=debug from fnc_debug('FC')
	--select @debug=1

	declare @Monthfc				nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from V_FC_FM_Table

	declare @FC_FM_Original			nvarchar(100) = ''
	select @FC_FM_Original = 'FC_FM_Original_'+@Division+@Monthfc	
	
	declare @FC_FM_Original_value			nvarchar(100) = ''
	select @FC_FM_Original_value = @FC_FM_Original+'_pass'

	-->pass value
	declare @ListColumn_Pass_2_set_zero		nvarchar(max) = ''
	select @ListColumn_Pass_2_set_zero=ListColumn from fn_FC_GetColHeader_Historical(@FM_Key,'si',86)
	--select ListColumn_Pass_2_set_zero=ListColumn from fn_FC_GetColHeader_Historical('202408','si',86)

	declare @list_B_Pass_Value	nvarchar(max) = ''
	select @list_B_Pass_Value = ListColumn from fn_FC_GetColHeader_Historical(@FM_KEY,'si',888)
	--select list_B_Pass_Value = ListColumn from fn_FC_GetColHeader_Historical('202403','si',888)
	
	--//update Historical_SI_Value_WF
	if @n_continue = 1
	begin
		select @sql=
		'Update '+@FC_FM_Original+'
			set '+@ListColumn_Pass_2_set_zero+'
		where Channel IN(''ONLINE'',''OFFLINE'',''O+O'') '

		if @debug>0
		begin
			select @sql '@sql set zero'
		end
		execute(@sql)

		select @sql =
		'update '+@FC_FM_Original+'   
		set   '
			+@list_B_Pass_Value+'
		from '+@FC_FM_Original+' f     
		inner join     
		(     
			select      
				*
			from '+@FC_FM_Original_value+' (NOLOCK)
		) as si on      
			si.[Product Type] = f.[Product Type]   
		and si.[SUB GROUP/ Brand] = f.[SUB GROUP/ Brand]   
		and si.channel = f.channel 
		and si.[Time series] = f.[Time series]
		where 
			f.Channel IN(''ONLINE'',''OFFLINE'')
		and f.[Time series] NOT IN(''6. Total Qty'') '

		if @debug>0
		begin
			select @sql '@sql Update Historical_SI_Value_WF'
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