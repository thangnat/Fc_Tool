/*
	declare 
		@b_Success		Int,     
		@c_errmsg		Nvarchar(250)

	exec sp_FC_Backup_RSP 'CPD',2024,@b_Success OUT,@c_errmsg OUT

	select @b_Success b_Success,@c_errmsg c_errmsg
	--select * from FC_RSP_CPD_2022_2023
*/

Alter proc sp_FC_Backup_RSP
	@Division			nvarchar(3),
	@CurrentYear		nvarchar(4),
	@b_Success			Int				OUTPUT,     
	@c_errmsg			Nvarchar(250)	OUTPUT
	with encryption
As
SET NOCOUNT ON
SET XACT_ABORT ON
begin tran
BEGIN TRY
	DECLARE   
		 @debug					int = 1
		,@sp_name				Nvarchar(100)
		,@n_continue			Int
		,@USERS					Nvarchar(50)
		,@MODIFILED				Datetime
		,@n_err					int
		,@sql					nvarchar(max) = ''
		,@Tablename				nvarchar(200) = ''		
		,@partial_TableName		nvarchar(10) = ''

	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_FC_Backup_RSP',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()	

	select @partial_TableName = format((cast(left(@CurrentYear,4) as int)-2),'0000')+'_'+format((cast(left(@CurrentYear,4) as int)-1),'0000')
	declare @listcolum nvarchar(max) = ''
	select @tablename = 'FC_RSP_'+@Division+'_'+@partial_TableName
	select @listcolum = ListColumn from fn_FC_GetColHeader_Historical('202405','f',80)

	if @debug>0
	begin
		select @tablename '@tablename'
	end
	if @n_continue = 1
	begin
		if exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID(@tablename) AND type in (N'U')
		)
		begin
			select @sql = 'drop table '+@tablename
			execute(@sql)
		end

		select @sql = 
		'select 
			STT,
			Division,
			[Sales Org],
			[SUB GROUP/ Brand],'
			+@listcolum+'
			INTO '+@Tablename+'
		from fnc_SubGroupMaster_RSP('''+@Division+''','''') f'
		if @debug>0
		begin
			select @sql '@sql 1.1.2'
		end
		execute(@sql)

		select @n_err = @@ERROR
		if @n_err<>0
		begin				
			select @n_continue = 3
			select @n_err=60002
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

--select * from FC_FM_Original_CPD where [SUB GROUP/ Brand]
