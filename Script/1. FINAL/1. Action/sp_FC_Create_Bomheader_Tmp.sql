/*
	declare 
		@b_Success		Int,
		@c_errmsg		Nvarchar(250)

	exec sp_FC_Create_Bomheader_Tmp 'CPD',@b_Success OUT,@c_errmsg OUT

	select @b_Success b_Success,@c_errmsg c_errmsg
*/

Alter Proc sp_FC_Create_Bomheader_Tmp
	@Division		nvarchar(3),
	@b_Success		Int				OUTPUT,     
	@c_errmsg		Nvarchar(250)	OUTPUT
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
		,@table_name			nvarchar(200) = ''
			
	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_FC_Create_Bomheader_Tmp',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE(),
		@table_name = 'FC_BomHeader_'+@Division+'_Update_Tmp'


	if @debug>0
	begin
		select @table_name '@table_name'
	end
	if @n_continue = 1
	begin
		if exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID(@table_name) AND type in (N'U')
		)
		begin
			select @sql = 'drop table '+@table_name
			if @debug >0
			begin
				select @sql = '@sql 1.1.1'
			end
			execute(@sql)
		end
	end
	if @n_continue = 1
	begin
		select @sql =
		'select 
			*
			INTO '+@table_name+'
		from FC_BomHeader_'+@Division

		if @debug >0
		begin
			select @sql = '@sql 1.1.2'
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