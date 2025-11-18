/*
	declare
		@b_Success			Int,
		@c_errmsg			Nvarchar(250)

	exec sp_create_bomheader_from_ZV14 'CPD','20220101','20240630',@b_Success OUT,@c_errmsg OUT

	select @b_Success b_Success,@c_errmsg c_errmsg
	
	SELECT distinct Barcode FROM FC_CPD_LIST_ZV14_BOM_HEADER
*/
ALTER PROC sp_create_bomheader_from_ZV14
	@Division			Nvarchar(3),
	@fromdate			nvarchar(8),
	@todate				nvarchar(8),
	@b_Success			Int				OUTPUT,     
	@c_errmsg			Nvarchar(250)	OUTPUT
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
		@sp_name = 'sp_Add_ZV14_Forecast',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	select @debug=debug from fnc_Debug('FC')

	declare @tablename nvarchar(100) = ''
	declare @saleOrg nvarchar(4) = ''

	select @saleOrg = case 
						when @Division = 'LLD' then 'V100'
						when @Division = 'CPD' then 'V200'
						when @Division = 'PPD' then 'V300'
						when @Division = 'LDB' then 'V400'
						else ''
					end
	if @n_continue=1
	begin
		select @tablename = 'FC_'+@Division+'_LIST_ZV14_BOM_HEADER'
		if exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID(@tablename) AND type in (N'U')
		)
		begin
			select @sql ='drop table '+@tablename--FC_LIST_ZV14_BOM_HEADER
			execute(@sql)
		end
		--z.[Bill. Material]
		select @sql =
		'SELECT DISTINCT	
			Barcode = z.[International Article Number (EAN/UPC)]
			INTO '+@tablename+'
		FROM ZV14 Z (NOLOCK)
		inner join 
		(
			select DISTINCT
				[Item Category Group],
				[EAN / UPC],
				Material
			from SC1.dbo.MM_ZMR54OLD_Stg (NOLOCK)
			where [Sales  Org] = '''+@saleOrg+''' 
			'+case when @Division = 'LLD' then 'and left([Material],3) not in(''TVN'',''TSV'') ' else '' end+'
		) m on m.[EAN / UPC] = z.[International Article Number (EAN/UPC)] and m.Material = z.[Bill. Material]
		WHERE Active = 1 
		and [Sales Organization] = '''+@saleOrg+''' 
		AND cast(z.[Billing Doc Date] as bigint) between cast('+@fromdate+' as bigint) and cast('+@todate+' as bigint) 
		and m.[Item Category Group] = ''LUMF'' '

		if @debug>0
		begin
			select @sql '@sql 1.1'
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