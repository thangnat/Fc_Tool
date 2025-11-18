/*
	declare 
		@b_Success				Int,
		@c_errmsg				Nvarchar(250)

	exec sp_tag_update_wf_O_O_slob 'CPD','202409',@b_Success OUT, @c_errmsg OUT

	select @b_Success b_Success, @c_errmsg c_errmsg
*/

Alter Proc sp_tag_update_wf_O_O_slob
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
		@sp_name = 'sp_tag_update_wf_O_O_slob',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	select @debug=debug from fnc_debug('FC')
	--select @debug=1

	declare @Monthfc				nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from V_FC_FM_Table

	declare @FC_FM_Original			nvarchar(100) = ''
	select @FC_FM_Original = 'FC_FM_Original_'+@Division+@Monthfc

	--//@List_FC_SI_6M
	declare @List_FC_SI_6M				nvarchar(max) = ''
	select @List_FC_SI_6M = ListColumn from fn_FC_GetColHeader_Historical(@FM_KEY,'si',95)
	--select List_FC_SI_6M = ListColumn from fn_FC_GetColHeader_Historical('202404','si',95)
	
	declare @List_FC_SI_6M_ListM				nvarchar(max) = ''
	select @List_FC_SI_6M_ListM = ListColumn from fn_FC_GetColHeader_Historical(@FM_KEY,'si',955)
	--select List_FC_SI_6M_ListM = ListColumn from fn_FC_GetColHeader_Historical('202404','si',955)

	if @debug>0
	begin
		select 'set zero total'
	end
	if @n_continue = 1
	begin
		select @sql=
		'update '+@FC_FM_Original+
		' set 
			[AVE P3M Y-1]=0,
			[AVE F3M Y-1]=0,
			[AVE P3M Y0]=0,
			[AVE F3M Y0]=0,
			[%F3M Y0/ P3M Y0]=0,
			[%F3M Y-1/ P3M Y-1]=0,
			[SLOB]=0
		where 
			[Channel]=''O+O''
		and [Time series]=''6. Total Qty'' '

		if @debug>0
		begin
			select @sql '@sql Update total qty=0 O+O'
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
	if @debug>0
	begin
		select 'Update total qty & O+O'
	end
	if @n_continue = 1
	begin
		select @sql =
		'update '+@FC_FM_Original+'
		set 
			[AVE P3M Y-1] = si.[AVE P3M Y-1],
			[AVE F3M Y-1] = si.[AVE F3M Y-1],
			[AVE P3M Y0] = si.[AVE P3M Y0],
			[AVE F3M Y0] = si.[AVE F3M Y0],
			[%F3M Y0/ P3M Y0] = si.[%F3M Y0/ P3M Y0],
			[%F3M Y-1/ P3M Y-1] = si.[%F3M Y-1/ P3M Y-1],
			SLOB = CASE 
						WHEN f.channel =''O+O'' and f.[Time series] =''6. Total Qty'' then 
							case 
								when isnull((si.SOH+si.[MTD SI]+si.[Total GIT]-'+@List_FC_SI_6M+'),0)<0 then 0
								else isnull((si.SOH+si.[MTD SI]+si.[Total GIT]-'+@List_FC_SI_6M+'),0) 
							end 
						else 0 
				end '		
		+'from '+@FC_FM_Original+' f
		inner join 
		(
			select
				[Product Type],    
				[SUB GROUP/ Brand],
				[Time series],
				[SIT] = Sum(SIT), 
				[SIT Day] = Sum([SIT Day]), 
				[SOH] = sum(SOH),
				[MTD SI] = sum([MTD SI]),
				[Total GIT] = sum([Total GIT]),
				[GIT M0] = sum([GIT M0]),
				[GIT M1] = sum([GIT M1]),
				[GIT M2] = sum([GIT M2]),
				[GIT M3] = sum([GIT M3]),
				[AVE P3M Y-1] = sum([AVE P3M Y-1]),
				[AVE F3M Y-1] = sum([AVE F3M Y-1]),
				[AVE P3M Y0] = sum([AVE P3M Y0]),
				[AVE F3M Y0] = sum([AVE F3M Y0]),
				[%F3M Y0/ P3M Y0] = case when sum([AVE P3M Y0]) = 0 then 0 else sum([AVE F3M Y0])*1.00/sum([AVE P3M Y0]) end,
				[%F3M Y-1/ P3M Y-1] = case when sum([AVE P3M Y-1]) = 0 then 0 else sum([AVE F3M Y-1])*1.00/sum([AVE P3M Y-1]) end, '+@List_FC_SI_6M_ListM
			+'from '+@FC_FM_Original+' 
			where 
					[Channel]<>''O+O''
				and [Time series]=''6. Total Qty''
			group by
				[Product Type],   
				[SUB GROUP/ Brand] ,
				[Time series]
		) as si on
			si.[Product Type]=f.[Product Type] 
		and si.[SUB GROUP/ Brand] = f.[SUB GROUP/ Brand] 
		and replace(f.[Time series],''0. O+O: '','''') = si.[Time series]  
		where 
			f.[Channel]=''O+O''
		and f.[Time series]=''6. Total Qty'' '

		if @debug>0
		begin
			select @sql '@sql Update O+O: total qty 1.1'
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