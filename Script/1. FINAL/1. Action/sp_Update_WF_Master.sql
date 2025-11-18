/*
	declare 
		@b_Success				Int	,
		@c_errmsg				Nvarchar(250)

	exec sp_Update_WF_Master 'CPD','202411',@b_Success OUT,@c_errmsg OUT

	select @b_Success b_Success,@c_errmsg c_errmsg
*/

Alter Proc sp_Update_WF_Master
	@Division		nvarchar(3),
	@FM_Key			Nvarchar(6),
	@b_Success		Int				OUTPUT,     
	@c_errmsg		Nvarchar(250)	OUTPUT
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
		@sp_name = 'sp_Update_WF_Master',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	select @debug=debug from fnc_debug('FC')
	--select @debug=1
	
	declare @Monthfc				nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from V_FC_FM_Table

	declare @table_FC_FM_Original nvarchar(200)=''
	select @table_FC_FM_Original='FC_FM_Original_'+@Division+@Monthfc

	if @n_continue = 1
	begin
		if exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID(@table_FC_FM_Original) AND type in (N'U')
		)
		begin
			select @sql=
			'Update '+@table_FC_FM_Original+'
			SET
				[Product type]=ISNULL(s.[Product type],f.[Product type]),
				[Signature]=ISNULL(s.[Signature],f.[Signature]),
				[CAT/Axe]=ISNULL(s.[CAT/Axe],f.[CAT/Axe]),
				[SUB CAT/ Sub Axe]=ISNULL(s.[SUB CAT/ Sub Axe],f.[SUB CAT/ Sub Axe]),
				[GROUP/ Class]=ISNULL(s.[GROUP/ Class],f.[GROUP/ Class]),
				[Ref. Code]=ISNULL(s.[Ref. Code],f.[Ref. Code]),
				[HERO]=ISNULL(s.[HERO],f.[HERO]),
				[Product status]=ISNULL(S.[Product status],f.[Product status])
			From '+@table_FC_FM_Original+' f
			Inner Join
			(
				select DISTINCT
					[Product type],
					[Signature],
					[CAT/Axe],
					[SUB CAT/ Sub Axe],
					[GROUP/ Class],
					[Ref. Code],
					[HERO],
					[Product status],
					[SUB GROUP/ Brand]
				from fnc_SubGroupMaster('''+@Division+''',''full'') 
			) s On s.[SUB GROUP/ Brand]=f.[SUB GROUP/ Brand] '

			if @debug>0
			begin
				select @sql 'Update data'
			end
			EXECUTE(@sql)

			select @n_err = @@ERROR
			if @n_err<>0
			begin
				select @n_continue = 3
				--select @n_err=60003
				select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +ERROR_MESSAGE()+'./ ('+@sp_name+')'
			end
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