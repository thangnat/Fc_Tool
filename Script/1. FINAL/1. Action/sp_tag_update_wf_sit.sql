/*
	declare 
		@b_Success				Int,
		@c_errmsg				Nvarchar(250)

	exec sp_tag_update_wf_sit 'LLD','202411',@b_Success OUT, @c_errmsg OUT

	select @b_Success b_Success, @c_errmsg c_errmsg
*/

Alter Proc sp_tag_update_wf_sit
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
		@sp_name = 'sp_tag_update_wf_sit',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	select @debug=debug from fnc_debug('FC')

	declare @Monthfc				nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from V_FC_FM_Table

	declare @FC_FM_Original			nvarchar(100) = ''
	select @FC_FM_Original = 'FC_FM_Original_'+@Division+@Monthfc

	declare @periodkey		nvarchar(6) = ''
	select @periodkey = case when right(@FM_KEY,2)='01' then format(cast(left(@FM_KEY,4) as int)-1,'0000') else left(@FM_KEY,4) end+format(case when right(@FM_KEY,2)='01' then '12' else (cast(right(@FM_KEY,2) as int)-1) end,'00')
	
	if @debug>0
	begin
		select @periodkey '@periodkey'
	end

	if @n_continue=1
	begin
		SELECT @sql=
		'update '+@FC_FM_Original+'
			set [SIT]=0
		where CHANNEL IN(''ONLINE'',''OFFLINE'')'
		
		if @debug>0
		begin
			select @sql '@sql set zero'
		end
		execute(@sql)

		--//Update SIT
		select @sql = 
		'Update '+@FC_FM_Original+'
		set SIT=isnull(s.[EndStock],0)
		from '+@FC_FM_Original+' f  
		inner join 
		(	
			select
				[Product Type],
				[SUB GROUP/ Brand],
				[Channel],
				[Time series],
				[EndStock] = sum(isnull([EndStock],0))
			from V_FC_'+@Division+'_SO_HIS_FINAL
			where PeriodKey ='''+@periodkey+'''
			and Channel IN(''ONLINE'',''OFFLINE'')
			group by
				[Product Type],
				[SUB GROUP/ Brand],
				[Channel],
				[Time series]
		) s on 
			s.[Product Type] = f.[Product Type]
		and s.[SUB GROUP/ Brand] = f.[SUB GROUP/ Brand] 
		and s.Channel = f.Channel
		and s.[Time series] = f.[Time series] '

		if @debug>0
		begin
			select @sql '@sql update sit'
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