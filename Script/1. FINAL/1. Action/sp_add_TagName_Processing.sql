/*
	Declare 
		@b_Success		Int,
		@c_errmsg		Nvarchar(250)

	exec sp_add_TagName_Processing 'LDB','tag_gen_budget_trend',@b_Success OUT,@c_errmsg OUT

	select @b_Success b_Success,@c_errmsg c_errmsg

	select * from FC_Tag_Name_Processing_LDB
*/

Alter Proc sp_add_TagName_Processing
	@Division				nvarchar(3),
	@Tag_name				nvarchar(500),
	@b_Success				Int				OUTPUT,     
	@c_errmsg				Nvarchar(250)	OUTPUT
As
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRAN
BEGIN TRY
	DECLARE 
		 @Debug					INT=0
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
		@sp_name = 'sp_add_TagName_Processing',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	select @debug=debug from fnc_debug('FC')
	--select @debug=1

	if @Debug>0
	begin
		select 'create tag name Processing'
	end
	if @n_continue=1
	begin		
		declare @table_BFL_Master_Processing nvarchar(100)=''
		select @table_BFL_Master_Processing='FC_Tag_Name_Processing_'+@division

		if exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID(@table_BFL_Master_Processing) AND type in (N'U')
		)
		begin
			select @sql ='drop table '+@table_BFL_Master_Processing
			if @debug>0
			begin
				select @sql 'drop table FC_Tag_Name_Processing '				
			end
			execute(@sql)
		end
		select @sql=
		'select
			[Tag Name]='''+@Tag_name+''',
			[Status]=Value
			INTO ' +@table_BFL_Master_Processing+'
		from string_split(''1'','','') '

		if @debug>0
		begin
			select @sql 'Insert table FC_Tag_Name_Processing'
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