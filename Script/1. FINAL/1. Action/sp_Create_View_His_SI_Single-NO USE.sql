
Alter proc sp_Create_View_His_SI_Single--no use
	@division		nvarchar(3),
	@FM_Key			nvarchar(6),
	@b_Success		Int				OUTPUT,     
	@c_errmsg		Nvarchar(250)	OUTPUT
	WITH ENCRYPTION
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
		,@sql					nvarchar(max)=''

	Declare
		@b_Success1				Int,
		@c_errmsg1				Nvarchar(250)

	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_Create_View_His_SI_Single',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	select @debug=debug from fnc_Debug('FC')

	--declare @Monthfc		nvarchar(20)=''
	--select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from V_FC_FM_Table
	
	declare @table_name		nvarchar(200)=''
	select @table_name='V_'+@division+'_His_SI_Single'

	if @n_continue=1
	begin
		if exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID(@table_name) AND type in (N'U')
		)
		begin
			select @sql = 'drop table '+@table_name
			if @debug>0
			begin
				select @sql '@sql drop table'
			end
			execute(@sql)
		end

		select @sql=
		'select
			[SubGrp],
			[Year],
			[Month],
			[Channel] = Channel,
			[Pass Column Header],
			[HIS_QTY_SINGLE],
			[Time Series]= ''1. Baseline Qty'',
			[Product Type]

			INTO '+@table_name+'
		from
		(
			select
				[SubGrp],
				[Year],
				[Month],
				[Channel],
				[Pass Column Header] = (
											select replace([Pass],''@'',cast(([Year]-year(getdate())) as nvarchar(2))) 
											from V_FC_MONTH_MASTER 
											where Month_number = cast(H.[Month] as int)
										),
				HIS_QTY_SINGLE = sum(HIS_QTY_SINGLE),
				[Product Type]
			from '+@division+'_FC_SI_HIS H (NOLOCK)	
			group by
				[SubGrp],
				[Year],
				[Month],
				[Channel],
				[Product Type]
		) as x'
		if @debug>0
		begin
			select @sql 'Create view'
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
