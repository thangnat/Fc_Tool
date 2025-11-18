/*
	declare 
		@b_Success				Int,
		@c_errmsg				Nvarchar(250)

	exec sp_tag_update_wf_sit_day 'LLD','202410',@b_Success OUT, @c_errmsg OUT

	select @b_Success b_Success, @c_errmsg c_errmsg
*/

Alter Proc sp_tag_update_wf_sit_day
	@Division				nvarchar(3),
	@FM_KEY					nvarchar(6),
	@b_Success				Int				OUTPUT,     
	@c_errmsg				Nvarchar(250)	OUTPUT
	with encryption
As
SET NOCOUNT ON
SET XACT_ABORT ON
--BEGIN TRAN
BEGIN TRY
	DECLARE  
		 @debug					int=0
		,@sp_name				Nvarchar(100)
		,@n_continue			Int
		,@USERS					Nvarchar(50)
		,@MODIFILED				Datetime
		,@n_err					int
		,@sql					nvarchar(max) = ''

	DECLARE 
		@b_Success1				Int=0,
		@c_errmsg1				Nvarchar(250)=''
			
	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_tag_update_wf_sit_day',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	select @debug=debug from fnc_debug('FC')

	declare @Monthfc				nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from V_FC_FM_Table

	declare @FC_FM_Original			nvarchar(100) = ''
	select @FC_FM_Original = 'FC_FM_Original_'+@Division+@Monthfc

	if @debug>0
	begin
		select @FC_FM_Original '@FC_FM_Original'
	end

	IF @n_continue=1
	BEGIN
		exec sp_FC_SO_HIS_FINAL_AVG @Division,@FM_KEY, @b_Success1 OUT,@c_errmsg1 OUT

		IF @b_Success1=0
		BEGIN
			SELECT @n_continue=3,@c_errmsg=@c_errmsg1
		END
	END

	BEGIN TRAN
	if @n_continue = 1
	begin
		--//Update SIT
		select @sql = 
		'Update '+@FC_FM_Original+'
		set 
			[SIT Day] = case when s.[AVG] >0 then isnull((f.SIT/s.AVG)*30,0) else 0 end
		from '+@FC_FM_Original+' f  
		inner join 
		(
			select * 
			from FC_SO_HIS_FINAL_AVG_'+@Division+@Monthfc+'
			where Channel is not null	
		) s on 
			s.[Product Type] = f.[Product Type]
		and s.[SUB GROUP/ Brand]  = f.[SUB GROUP/ Brand] 
		and s.Channel = f.Channel
		where f.[Time series] = ''1. Baseline Qty'' '

		if @debug>0
		begin
			select @sql '@sql update SIT Day'
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