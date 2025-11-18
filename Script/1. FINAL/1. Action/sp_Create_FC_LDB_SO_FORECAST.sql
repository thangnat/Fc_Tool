/*
	declare
		@b_Success			Int,
		@c_errmsg			Nvarchar(250)

	exec sp_Create_FC_LDB_SO_FORECAST 'LDB','202502','OPTIMUS', @b_Success OUT,@c_errmsg OUT

	select @b_Success b_Success,@c_errmsg c_errmsg

	select * from FC_SO_FORECAST_LDB_202410
*/

Alter proc sp_Create_FC_LDB_SO_FORECAST
	@Division			nvarchar(3),
	@FM_KEY				nvarchar(6),
	@TableName			Nvarchar(50),
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
		,@sql					nvarchar(max)=''
	declare 
		@b_Success1				Int,
		@c_errmsg1				Nvarchar(250)

	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_Create_FC_LDB_SO_FORECAST',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	select @debug=debug from fnc_Debug('FC')
	select @debug=1

	declare @Monthfc				nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from V_FC_FM_Table
	
	declare @TableName_OK nvarchar(200)=''
	select @TableName_OK='FC_SO_FORECAST_'+@Division+@Monthfc

	if @n_continue=1
	begin
		if @Division='LDB' and @TableName='OPTIMUS'
		begin
			SELECT @n_continue=1
		end
		ELSE
		BEGIN
			select @n_continue=3,@c_errmsg=N'This Function only run for LDB & type=OPTIMUS('+@sp_name+')'
		END
	end
	if @n_continue=1
	begin
		if exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID(@TableName_OK) AND type in (N'U')
		)
		begin
			select @sql='drop table '+@TableName_OK
			if @debug>0
			begin
				select @sql 'Drop table'
			end
			execute(@sql)
		end

		select @sql=
		'select
			[Table Name],
			[SO Forecasting lines],
			[Year],
			[Month],
			[Signature],
			[Channel],
			[CAT/Axe],
			[SUB CAT/ Sub Axe],
			[GROUP/ Class],
			[SUB GROUP/ Brand],
			[Product status],
			[HERO],
			[brand],
			[Category],
			[Sell-Out Units]=[Sell-Out Units],
			[GROSS SELL-OUT VALUE]=[Sell-Out Units]*isnull((select dbo.fnc_Get_RSP_LDB_2('''+@division+''',xx.[SUB GROUP/ Brand],xx.[Year],xx.[Month])),0)
			INTO '+@TableName_OK+'
		from
		(
			select
				[Table Name],
				[SO Forecasting lines] = isnull(o.[Forecasting lines],''''),
				[Brand],
				[Category],
				[Year] = X.[Year],
				[Month] = X.[Month],
				[Signature]=S.[Signature],
				[Channel]= X.Channel,
				[CAT/Axe] = s.[CAT/Axe],
				[SUB CAT/ Sub Axe] = s.[SUB CAT/ Sub Axe],
				[GROUP/ Class] = s.[GROUP/ Class],
				[SUB GROUP/ Brand] = s.[SUB GROUP/ Brand],
				[Product status],
				[HERO],
				[Sell-Out Units]=cast(isnull([Sell-Out Units],''0'') as numeric(18,0)),
				[GROSS SELL-OUT VALUE]=0
			from
			(
				select
					[Table Name]=''Single'',
					[Forecasting Line]=isnull(so.[Forecasting Line],''''),
					[Brand],
					[Category],
					[Channel] = SO.Channel,
					[Year] = SO.[Year],
					[Month] = SO.[Month],
					[barcode]=[barcode],
					[Sell-Out Units]=sum(cast(isnull(so.[Sell-Out Units],''0'') as numeric(18,0))),
					[GROSS SELL-OUT VALUE]=0
				from FC_SO_OPTIMUS_NORMAL_'+@Division+@Monthfc+' so
				group by
					so.[Forecasting Line],
					SO.[Channel],
					SO.[Year],
					SO.[Month],
					[Brand],
					[Category],
					[Barcode]
				union all
				select
					[Table Name]=''BOM'',
					[Forecasting Line]=isnull(mm.[SUB GROUP/ Brand],''''),
					[Brand],
					[Category],
					[Channel]=BSO.Channel,
					[Year] = bso.[Year],
					[Month] = bso.[Month],
					[Barcode]=z.Barcode_Component,
					[Sell-Out Units]=sum(cast(isnull(bso.[Sell-Out Units],''0'') as numeric(18,0))*CQty),
					[GROSS SELL-OUT VALUE]=0
				from FC_SO_OPTIMUS_Promo_Bom_'+@division+@Monthfc+'_OK bso
				inner JOIN
				(
					SELECT DISTINCT
						Barcode_Bom=Barcode_Bom,
						Barcode_Component=Barcode_Component,
						CQty=Qty
					FROM V_ZMR32
					WHERE Division = '''+@division+'''
					and [Material Type]=''YFG''
				) z on z.Barcode_Bom = bso.Barcode
				left join 
				(
					select DISTINCT
						[SUB GROUP/ Brand],
						Barcode
					from fnc_SubGroupMaster('''+@division+''',''full'')
					where [Item Category Group]<>''LUMF''
				) mm on mm.Barcode = z.Barcode_Component
				group by
					BSO.Channel,
					z.Barcode_Component,
					bSO.[Year],
					bSO.[Month],
					bso.brand,
					bso.Category,
					mm.[SUB GROUP/ Brand]
			) as x
			left join
			(
				select DISTINCT
					[Signature],
					[CAT/Axe],
					[SUB CAT/ Sub Axe],
					[GROUP/ Class],
					[SUB GROUP/ Brand],
					[Product status],
					[HERO],
					[Barcode]
				from fnc_SubGroupMaster('''+@division+''',''full'')
				where Barcode NOT IN
				(
					''3337871325572'',
					''3337871324681'',
					''3337872414084'',
					''3433422405318''
				)
			) s on s.Barcode=x.barcode/*s.[SUB GROUP/ Brand]=x.[Forecasting Line]*/
			left join
			(
				select DISTINCT 
					[SUB GROUP/ Brand],
					[Forecasting lines] 
				from FC_SO_OPTIMUS_MAPPING_SUBGRP_'+@division+'
			) o on o.[SUB GROUP/ Brand]=s.[SUB GROUP/ Brand]
		) as xx '

		if @debug>0
		begin
			select @sql 'Insert FC_SO_FORECAST'
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
	if @n_continue=1
	begin
		exec sp_create_View_SO_FORECAST @Division,@FM_KEY,@b_Success1 OUT,@c_errmsg1 OUT
		
		if @b_Success1=0
		begin
			select @n_continue = 1, @c_errmsg = @c_errmsg1
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