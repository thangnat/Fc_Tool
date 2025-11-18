/*
	Declare
		@b_Success			Int,
		@c_errmsg			Nvarchar(250)

	exec sp_Update_Filter_WF 'LDB','202409','Ref. Code,HERO,Channel,Product status,Time series,Y0 Unit,Y+1 Unit',@b_Success OUT,@c_errmsg OUT

	select @b_Success b_Success,@c_errmsg c_errmsg
*/

alter proc sp_Update_Filter_WF
	@Division		nvarchar(3),
	@FM_KEY			nvarchar(6),
	@ListColumn		nvarchar(max),
	@b_Success		Int				OUT,
	@c_errmsg		Nvarchar(250)	OUT
	--with encryption
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
		,@full					nvarchar(4) = ''
		,@Monthfc				nvarchar(20)=''
		,@Host_name				nvarchar(50)=HOST_NAME()
		,@ListColumn_ok			nvarchar(max)=''

	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_Update_Filter_WF',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	select @debug=debug from fnc_debug('FC')
	--select @debug=1

	declare @tablename nvarchar(200)=''
	select @tablename='HOST_NAME_FILTER_WF'
	--select @Host_name ='VNCORPVNWKS1094's
	--select host_name()
	select @ListColumn_ok=@ListColumn+',Product type,Forecasting Line,Channel,Time series'

	--select @ListColumn_ok '@ListColumn_ok'
	if @n_continue=1
	begin
		if @ListColumn='All'
		begin
			select @sql='
			update '+@tablename+' 
				set Allow_Show=1
			where [HOST_NAME]='''+@Host_name+''' '
		end
		else
		begin
			select @sql='
			update '+@tablename+' 
				set Allow_Show=0 
			where [HOST_NAME]='''+@Host_name+''' 
			and [List Group Column]<>''ID''

			update '+@tablename+' 
				set Allow_Show=1
			where 
				[HOST_NAME]='''+@Host_name+''' 
			and [List Group Column] in(select value from string_split('''+@ListColumn_ok+''','',''))
			and [List Group Column]<>''ID'' '
		end
		if @debug>0
		begin
			select @sql 'Update filter'
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