/*
	Declare 
		@b_Success		Int,
		@c_errmsg		Nvarchar(250)

	exec sp_Create_Subgroup_Available 'LLD','202411',@b_Success OUT,@c_errmsg OUT
	
	select @b_Success b_Success,@c_errmsg c_errmsg

	select * from FC_LLD_202411_SUBGROUP_AVAILABLE
*/

Alter Proc sp_Create_Subgroup_Available
	@Division				nvarchar(3),
	@FM_KEY					Nvarchar(6),
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
		,@sql					nvarchar(max)=''
			
	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_Create_Subgroup_Available',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	select @debug=debug from fnc_debug('FC')
	--select @debug=1

	declare @Monthfc				nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from V_FC_FM_Table

	declare @tableName	 nvarchar(200)=''
	select @tableName='FC_FM_Original_'+@Division+@Monthfc

	declare @table_subgroup nvarchar(200)=''
	select @table_subgroup='FC_'+@Division+@Monthfc+'_SUBGROUP_AVAILABLE'

	--if @n_continue = 1
	--begin
	--	if not exists(select 1 from VShipmentSelectedChange (nolock) where ID = @ID_Process)
	--	begin
	--		select @n_continue = 3
	--		select @n_err=60001
	--		select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +':ID ['+cast(@ID_Process as nvarchar)+'] update invalid./ ('+@sp_name+')'
	--	end
	--end
	if @n_continue = 1
	begin
		if exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID(@table_subgroup) AND type in (N'U')
		)
		begin
			select @sql='drop table '+@table_subgroup
			if @debug>0
			begin
				select 'drop table subgroup'
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
	end
	if @n_continue=1
	begin
		select @sql=
		'select DISTINCT
			[SUB GROUP/ Brand]
			INTO '+@table_subgroup+'
		from '+@tableName+'
		where 
		(
			[Y-2 (u) M1]+[Y-2 (u) M2]+[Y-2 (u) M3]+[Y-2 (u) M4]+[Y-2 (u) M5]+[Y-2 (u) M6]+[Y-2 (u) M7]+[Y-2 (u) M8]+[Y-2 (u) M9]+[Y-2 (u) M10]+[Y-2 (u) M11]+[Y-2 (u) M12]+
			[Y-1 (u) M1]+[Y-1 (u) M2]+[Y-1 (u) M3]+[Y-1 (u) M4]+[Y-1 (u) M5]+[Y-1 (u) M6]+[Y-1 (u) M7]+[Y-1 (u) M8]+[Y-1 (u) M9]+[Y-1 (u) M10]+[Y-1 (u) M11]+[Y-1 (u) M12]+
			[Y0 (u) M1]+[Y0 (u) M2]+[Y0 (u) M3]+[Y0 (u) M4]+[Y0 (u) M5]+[Y0 (u) M6]+[Y0 (u) M7]+[Y0 (u) M8]+[Y0 (u) M9]+[Y0 (u) M10]+[Y0 (u) M11]+[Y0 (u) M12]+
			[Y+1 (u) M1]+[Y+1 (u) M2]+[Y+1 (u) M3]+[Y+1 (u) M4]+[Y+1 (u) M5]+[Y+1 (u) M6]+[Y+1 (u) M7]+[Y+1 (u) M8]+[Y+1 (u) M9]+[Y+1 (u) M10]+[Y+1 (u) M11]+[Y+1 (u) M12]
		)<>0 '
		if @debug>0
		begin
			select 'Insert table'
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