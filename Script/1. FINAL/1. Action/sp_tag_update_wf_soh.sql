/*
	declare 
		@b_Success				Int,
		@c_errmsg				Nvarchar(250)

	exec sp_tag_update_wf_soh 'LDB','',@b_Success OUT, @c_errmsg OUT

	select @b_Success b_Success, @c_errmsg c_errmsg
*/

Alter Proc sp_tag_update_wf_soh
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
		@sp_name = 'sp_tag_update_wf_soh',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	select @debug=debug from fnc_debug('FC')
	if @FM_KEY=''
	begin
		select @FM_KEY=format(getdate(),'yyyyMM')
	end
	declare @Monthfc				nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from V_FC_FM_Table
	declare @FC_FM_Original			nvarchar(100) = ''
	select @FC_FM_Original = 'FC_FM_Original_'+@Division+@Monthfc

	if @n_continue=1
	begin
		if not exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID(@FC_FM_Original) AND type in (N'U')
		)
		begin
			select @n_continue=3,@c_errmsg='period key not contains table to Update.../'
		end
	end
	if @n_continue = 1
	begin
		select @sql=
		'update '+@FC_FM_Original+'
			set [SOH]=0
		where Channel IN(''ONLINE'',''OFFLINE'') '

		if @debug>0
		begin
			select @sql '@sql set zero'
		end
		execute(@sql)

		--//Update SOH
		select @sql = 
		'Update '+@FC_FM_Original+'
			set SOH = isnull(s.TotalQty,0)
		from '+@FC_FM_Original+' f
		inner join SOH_FINAL_'+@Division+@Monthfc+' s on 
			s.[Product Type] = f.[Product Type] 
		and s.[SUB GROUP/ Brand] = f.[SUB GROUP/ Brand] 
		And s.Channel = f.Channel 
		and s.[Time series] = f.[Time series]
		where f.[Time series] in(''1. Baseline Qty'',''3. Promo Qty(BOM)'') '

		if @debug>0
		begin
			select @sql '@sql Update SOH'
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