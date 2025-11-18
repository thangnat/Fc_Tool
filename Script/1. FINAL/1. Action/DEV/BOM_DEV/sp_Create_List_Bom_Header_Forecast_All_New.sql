/*
	declare 
		@b_Success				Int,    
		@c_errmsg				Nvarchar(250)

	exec sp_Create_List_Bom_Header_Forecast_All_New 'CPD','202407','ALL',@b_Success OUT, @c_errmsg OUT

	select @b_Success b_Success, @c_errmsg c_errmsg

	select * from FC_LIST_BOM_HEADER_ALL_CPD_202407
*/

Alter Proc sp_Create_List_Bom_Header_Forecast_All_New
	@Division				nvarchar(3),
	@FM_KEY					nvarchar(6),
	@Channel				nvarchar(10),--//ALL,ONLINE,OFFLINE
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
		,@sql					nvarchar(max) = ''
			
	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_Create_List_Bom_Header_Forecast_All_New',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	select @debug=debug from fnc_Debug('FC')

	declare @Monthfc				nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from V_FC_FM_Table

	declare @tablename nvarchar(200) = ''
	select @tablename = 'FC_LIST_BOM_HEADER_ALL_'+@Division+@Monthfc
	
	declare @ListColumn_Current nvarchar(max) = ''
	SELECT @ListColumn_Current = ListColumn FROM fn_FC_GetColheader_Current(@FM_Key,'1. Baseline Qty','b')
	--SELECT ListColumn_Current = ListColumn FROM fn_FC_GetColheader_Current('202407','1. Baseline Qty','b')

	declare @listcolum_cong_fc	nvarchar(max)=''
	select @listcolum_cong_fc=ListColumn from fn_FC_GetColheader_Current(@FM_Key,'1. Baseline qty_+','x')
	--select listcolum_cong_fc=ListColumn from fn_FC_GetColheader_Current('202407','1. Baseline qty_+','x')

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
			if @debug >0
			begin
				select @sql '@sql DROP TABLE'
			end
			execute(@sql)
		end

		if @Channel='ALL'
		begin
			select @sql = 
			'select 
				Division = '''+@Division+''',
				*
				INTO '+@tablename+'
			from
			(
				select 
					*
				from FC_LIST_BOM_HEADER_ONLINE_'+@Division+@Monthfc+'
				union all
				select
					[Bundle Code]=[Bundle Code],
					[Channel]=Channel,
					[TIME SERIES Original] = [Time series],
					[Time series] = [Time series],'
					+@ListColumn_Current+'
				from FC_SI_Promo_Bom_'+@Division+@Monthfc+' b
			) As x 
			where ('+@listcolum_cong_fc+')<>0 '
		end
		else if @Channel='ONLINE'
		begin
			select @sql = 
			'select 
				Division = '''+@Division+''',
				*
				INTO '+@tablename+'
			from
			(
				select 
					*
				from FC_LIST_BOM_HEADER_ONLINE_'+@Division+@Monthfc+'
			) As x 
			where ('+@listcolum_cong_fc+')<>0 '
		end
		else if @Channel='OFFLINE'
		begin
			select @sql = 
			'select 
				Division = '''+@Division+''',
				*
				INTO '+@tablename+'
			from
			(
				select
					[Bundle Code]=[Bundle Code],
					[Channel]=Channel,
					[TIME SERIES Original] = [Time series],
					[Time series] = [Time series],'
					+@ListColumn_Current+'
				from FC_SI_Promo_Bom_'+@Division+@Monthfc+' b
			) As x 
			where ('+@listcolum_cong_fc+')<>0 '
		end
		
		if @debug>0
		begin
			select @sql '@sql Insert table'
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