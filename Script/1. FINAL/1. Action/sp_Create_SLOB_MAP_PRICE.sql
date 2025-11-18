/*
	Declare
		@b_Success			Int,
		@c_errmsg			Nvarchar(250)

	exec sp_Create_SLOB_MAP_PRICE 'CPD','202407',@b_Success OUT,@c_errmsg OUT

	select @b_Success b_Success,@c_errmsg c_errmsg

	select * from FC_SLOB_MAP_PRICE
*/

Alter Proc sp_Create_SLOB_MAP_PRICE
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
		 @debug					INT=0
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
		@sp_name = 'sp_Create_SLOB_MAP_PRICE',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	declare @tablename nvarchar(300)=''
	select @tablename='FC_SLOB_MAP_PRICE'

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
			WHERE object_id = OBJECT_ID(@tablename) AND type in (N'U')
		)
		begin
			select @sql='delete '+@tablename+' where [Division]='''+@Division+''' and [FM_KEY]='''+@FM_KEY+''' '
			if @debug>0
			begin
				select @sql 'Delete table by Division & FM_KEY'
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
		else
		begin
			select @sql=
			'create table '+@tablename+
			'(
				[Division]			nvarchar(3) null,
				[FM_KEY]			nvarchar(6) null,
				[SUB GROUP/ Brand]	nvarchar(500) null,
				[AVERAGE]			numeric(18,0) default 0
			)'
			if @debug>0
			begin
				select @sql 'Create table by Division & FM_KEY'
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
		'INSERT INTO '+@tablename+'
		select
			[Division]='''+@Division+''',
			[FM_KEY]='''+@FM_KEY+''',
			* 
		from fnc_Get_MAP('''+@Division+''')'

		if @debug>0
		begin
			select @sql 'Insert table by Division & FM_KEY'
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