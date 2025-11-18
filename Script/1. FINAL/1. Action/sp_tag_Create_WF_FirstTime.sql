/*
	Declare 
		@b_Success		Int,
		@c_errmsg		Nvarchar(250)

	exec sp_tag_Create_WF_FirstTime 'CPD','202410',@b_Success OUT,@c_errmsg OUT

	select @b_Success b_Success,@c_errmsg c_errmsg

	select * from FM_Original_Full_Adj_CPD_202407
*/

Alter proc sp_tag_Create_WF_FirstTime
	@division		nvarchar(3),
	@FM_KEY			nvarchar(6),
	@b_Success		Int				OUTPUT,     
	@c_errmsg		Nvarchar(250)	OUTPUT
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
		@sp_name = 'sp_tag_Create_WF_FirstTime',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()		
		
	select @debug=debug from fnc_debug('FC')
	--select @debug=1

	declare @Monthfc				nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from V_FC_FM_Table

	declare @Tablename				nvarchar(200) = ''
	select @Tablename ='FM_Original_Full_Adj_'+@division+@Monthfc	

	if @n_continue=1
	begin
		if exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID(@tablename) AND type in (N'U')
		)
		begin
			select @sql = 'drop table '+@tablename
			if @debug>0
			begin
				select @sql '@sql drop table'
			end
			execute(@sql)
		end

		select @sql='
		select
			[SUB GROUP/ Brand],
			Channel,
			[Time series],
			[Y0 (u) M1],
			[Y0 (u) M2],
			[Y0 (u) M3],
			[Y0 (u) M4],
			[Y0 (u) M5],
			[Y0 (u) M6],
			[Y0 (u) M7],
			[Y0 (u) M8],
			[Y0 (u) M9],
			[Y0 (u) M10],
			[Y0 (u) M11],
			[Y0 (u) M12],
			[Y+1 (u) M1],
			[Y+1 (u) M2],
			[Y+1 (u) M3],
			[Y+1 (u) M4],
			[Y+1 (u) M5],
			[Y+1 (u) M6],
			[Y+1 (u) M7],
			[Y+1 (u) M8],
			[Y+1 (u) M9],
			[Y+1 (u) M10],
			[Y+1 (u) M11],
			[Y+1 (u) M12]
			INTO '+@Tablename+'
		from FC_FM_Original_'+@division+@Monthfc+'
		where 
			Channel NOT IN(''O+O'')
		and cast(replace(left([Time series],2),''.'','''') as int) between 1 and 6
		order by id asc '

		if @debug>0
		begin
			select @sql
		end
		execute(@sql)
		
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