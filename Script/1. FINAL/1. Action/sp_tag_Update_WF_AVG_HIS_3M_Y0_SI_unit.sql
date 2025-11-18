/*
	declare 
		@b_Success				Int,
		@c_errmsg				Nvarchar(250)

	exec sp_tag_Update_WF_AVG_HIS_3M_Y0_SI_unit 'LLD','202407',@b_Success OUT, @c_errmsg OUT

	select @b_Success b_Success, @c_errmsg c_errmsg
*/

Alter Proc sp_tag_Update_WF_AVG_HIS_3M_Y0_SI_unit
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
		 @debug					int = 0
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
		@sp_name = 'sp_tag_Update_WF_AVG_HIS_3M_Y0_SI_unit',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	select @debug=debug from fnc_debug('FC')

	declare @Monthfc				nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from V_FC_FM_Table

	declare @FC_FM_Original			nvarchar(100) = ''
	select @FC_FM_Original = 'FC_FM_Original_'+@Division+@Monthfc	

	if @n_continue = 1
	begin
		--//update ave year - 0
		declare @listcolumn_month_avg_BW_Y0 nvarchar(max) = ''
		select @listcolumn_month_avg_BW_Y0 = ListColumn from fn_FC_GetColHeader_Historical(@FM_KEY,'si',92)-->AVG BW-->Y0
		--select listcolumn_month_avg_BW_Y0 = ListColumn from fn_FC_GetColHeader_Historical('202408','si',92)-->AVG BW-->Y0
		
		declare @listcolumn_month_avg_FW_Y0 nvarchar(max) = ''
		select @listcolumn_month_avg_FW_Y0 = ListColumn from fn_FC_GetColHeader_Historical(@FM_KEY,'si',91)-->AVG FW -->Y0			
		
		--//update cal eve group
		select @sql =
		'update '+@FC_FM_Original+'   
		set   
			[AVE P3M Y0] = si.[AVE P3M Y0],
			[AVE F3M Y0] = si.[AVE F3M Y0] 
		from '+@FC_FM_Original+' f     
		inner join     
		(     
			select      
				[Product Type],   
				[SUB GROUP/ Brand],    
				Channel,    
				[Time series],
				[AVE P3M Y0] = '+@listcolumn_month_avg_BW_Y0+',
				[AVE F3M Y0] = '+@listcolumn_month_avg_FW_Y0+' 
			from '+@FC_FM_Original+'     
			where 
				Channel <> ''O+O'' 
			and [Time series] not in(''6. Total Qty'')
		) as si on      
			si.[Product Type] = f.[Product Type]   
		and si.[SUB GROUP/ Brand] = f.[SUB GROUP/ Brand]   
		and si.channel = f.channel 
		and si.[Time series] = f.[Time series] ' 

		if @debug>0
		begin
			select @sql '@sql Update total qty AVE P3M Y0'
		end
		execute(@sql)

		--//update cal eve group %
		select @sql =
		'update '+@FC_FM_Original+'   
		set     
			[%F3M Y0/ P3M Y0] = si.[%F3M Y0/ P3M Y0]
		from '+@FC_FM_Original+' f     
		inner join     
		(     
			select      
				[Product Type],   
				[SUB GROUP/ Brand],    
				Channel,    
				[Time series],
				[%F3M Y0/ P3M Y0] = cast(case when [AVE P3M Y0] = 0 then 0.00 else ([AVE F3M Y0]*1.00/[AVE P3M Y0]) end as numeric(18,2))						
			from '+@FC_FM_Original+'     
			where 
				Channel <> ''O+O'' 
			and [Time series] not in(''6. Total Qty'')
		) as si on      
			si.[Product Type] = f.[Product Type]   
		and si.[SUB GROUP/ Brand] = f.[SUB GROUP/ Brand]   
		and si.channel = f.channel 
		and si.[Time series] = f.[Time series] ' 

		if @debug>0
		begin
			select @sql '@sql Update total qty AVE P3M Y0 %'
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