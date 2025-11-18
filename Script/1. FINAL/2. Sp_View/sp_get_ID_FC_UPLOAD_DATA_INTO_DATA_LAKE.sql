/*
	Declare
		@b_Success			Int,
		@c_errmsg			Nvarchar(250)

	exec sp_get_ID_FC_UPLOAD_DATA_INTO_DATA_LAKE '202403','','2430,2432,2433',@b_Success OUT,@c_errmsg OUT

	select @b_Success b_Success,@c_errmsg c_errmsg
	
*/

Alter proc sp_get_ID_FC_UPLOAD_DATA_INTO_DATA_LAKE
	@FM_KEY			nvarchar(6),
	@GuidID			nvarchar(50),
	@listID			nvarchar(500),
	@b_Success		Int				OUTPUT,     
	@c_errmsg		Nvarchar(250)	OUTPUT
	with encryption
As
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRAN
BEGIN TRY
	DECLARE   
		 @debug					int = 1
		,@sp_name				Nvarchar(100)
		,@n_continue			Int
		,@USERS					Nvarchar(50)
		,@MODIFILED				Datetime
		,@n_err					int
	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_get_ID_FC_UPLOAD_DATA_INTO_DATA_LAKE',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	declare @tmp table (ID int identity(1,1), ID_Raw int,[Task Upload] nvarchar(300), [Action Name] nvarchar(max))

	if @n_continue = 1
	begin
		if len(@listID)>0
		begin
			insert into @tmp
			(
				ID_Raw,
				[Task Upload],
				[Action Name]
			)
			select
				ID,
				[Task Upload],
				[Action Name] = replace([action name],'@FM_KEY',@FM_KEY)
			from V_FC_UPLOAD_DATA_INTO_DATA_LAKE --order by STT
			where ID in(select value from string_split(@listID,','))
		end
		select * from @tmp
		declare @totalrows int = 0, @currentrow int = 1
		select @totalrows = isnull(count(*),0) from @tmp

	end
	if @n_continue = 1
	begin
		while (@currentrow <=@totalrows)
		begin
			declare @sqlscript nvarchar(max) = ''
			select @sqlscript = [Action Name] from @tmp where id = @currentrow

			select @sqlscript = replace(REPLACE(@sqlscript,'@FM_KEY',@FM_KEY),'@GuidID',@GuidID)

			if @debug>0
			begin
				select @sqlscript '@sqlscript'
			end
			if len(@sqlscript)>0
			begin
				execute(@sqlscript)
			end

			select @currentrow = @currentrow +1
		end


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