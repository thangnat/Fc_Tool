/*
	Declare
		@b_Success			Int,
		@c_errmsg			Nvarchar(250)

	exec sp_create_View_SO_FORECAST 'LDB','202501',@b_Success OUT,@c_errmsg OUT

	select @b_Success b_Success,@c_errmsg c_errmsg
	
	select * from V_FC_LDB_202501_SO_FORECAST
*/

Alter proc sp_create_View_SO_FORECAST
	@division		nvarchar(3),
	@FM_KEY			nvarchar(6),
	@b_Success		Int				OUTPUT,     
	@c_errmsg		Nvarchar(250)	OUTPUT
	with encryption
AS
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
		,@rowcount1				int = 0
			
	declare 
		@b_Success1				Int,
		@c_errmsg1				Nvarchar(250)

	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_create_View_SO_FORECAST',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	declare @sql1 nvarchar(max)=''
	declare @sql2 nvarchar(max)=''
	declare @sql3 nvarchar(max)=''

	select @debug=debug from fnc_debug('FC')
	--select @debug=1
	
	declare @Monthfc				nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from V_FC_FM_Table

	declare @view_name_raw		nvarchar(200)=''
	select @view_name_raw='V_FC_'+@division+@Monthfc+'_SO_FORECAST_RAW'

	declare @view_name		nvarchar(200)=''
	select @view_name='V_FC_'+@division+@Monthfc+'_SO_FORECAST'

	if @debug>0
	begin
		select @view_name_raw 'drop and create @view_name raw'
	end
	if @n_continue=1
	begin
		IF EXISTS(select * FROM sys.views where name =@view_name_raw)
		BEGIN
			select @sql='drop view '+@view_name_raw
			if @debug>0
			begin
				select @sql 'drop table'
			end
			execute(@sql)
		end
	end
	if @n_continue=1
	begin
		if @division='LDB'
		begin
			select @sql=
			'create view '+@view_name_raw+'
			As
			select
				[Table Name],
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
				[Brand],
				[Sell-Out Units]=sum([Sell-Out Units]),
				[GROSS SELL-OUT VALUE]=sum([GROSS SELL-OUT VALUE])
			from
			(
				select 
					[Table Name],
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
					[Brand],
					[Category],
					[Sell-Out Units]=cast(isnull([Sell-Out Units],''0'') as numeric(18,0)),
					[GROSS SELL-OUT VALUE]=cast(isnull([Gross Sell-OUT Value],''0'') as numeric(18,0)) 
				from FC_SO_FORECAST_'+@division+@Monthfc+'
			) as x
			group by
				[Table Name],
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
				[Brand] '
		end
		else if @division='CPD'
		begin
			select @sql=
			'create view '+@view_name_raw+'
			As
			select     
				[Client],    
				[Channel],     
				[Forecasting Line]=so.[Forecasting Line],     
				[Year],    
				[Month],   
				[Sell-Out Units]=sum(cast(isnull([Sell-Out Units],''0'') as numeric(18,0))),  
				[GROSS SELL-OUT VALUE]=sum(cast(isnull([Gross Sell-OUT Value],''0'') as numeric(18,0)))   
			from FC_SO_OPTIMUS_NORMAL_'+@division+@Monthfc+' so   
			group by    
				so.[Client],    
				so.[Channel], 
				so.[Forecasting Line],   
				so.[Year],    
				so.[Month]     
			union all
			select    
				[Client],     
				[Channel],    
				[Forecasting Line]=s.[SUB GROUP/ Brand],   
				[Year],    
				[Month],    
				[Sell-Out Units]=sum([Sell-Out Units]),    
				[GROSS SELL-OUT VALUE]=sum([GROSS SELL-OUT VALUE])    
			from   
			(    
				select      
					[Client]='''',     
					[Channel],       
					[Sap Code],     
					[Year],      
					[Month],     
					[Sell-Out Units] = sum(cast(isnull([Sell-Out Units],''0'') as numeric(18,0))),    
					[GROSS SELL-OUT VALUE] = sum(cast(isnull([Gross Sell-OUT Value],''0'') as numeric(18,0)))    
				from FC_SO_OPTIMUS_Promo_Bom_'+@division+@Monthfc+'_OK bso   
				group by     
					bso.Channel,    
					bso.[Sap Code], 
					bso.[Year],    
					bso.[Month]    
			) bso    
			LEFT JOIN   
			(      
				SELECT DISTINCT  
					Material_Bom,     
					Barcode_Bom,     
					Material_Component,    
					Barcode_Component   
				FROM V_ZMR32     
				WHERE [Division]='''+@division+'''
			) Z ON Z.Material_Bom=bso.[Sap Code]    
			inner join    
			(     
				select DISTINCT     
					[Material],        
					[SUB GROUP/ Brand],  
					[Item Category Group]    
				from fnc_SubGroupMaster('''+@division+''',''full'')   
				where [Item Category Group]<>''LUMF''   
			) as s on s.Material = z.Material_Component   
			group by     
				[Client],     
				[Channel],   
				s.[SUB GROUP/ Brand],  
				[Year],    
				[Month] '
		end
		else if @division='LLD'
		begin
			select @sql=
			'create view '+@view_name_raw+'
			As
			select
				[Year]=CAST(ISNULL([Year],''0'') AS INT),
				[Month]=CAST(ISNULL([Month],'''') AS nvarchar(10)),
				[Client]=ISNULL([Client],''''),
				[Signature]=ISNULL([Signature],''''),
				[Forecasting line]=ISNULL([Forecasting line],''''),
				[Channel]=ISNULL([Channel],''''),
				[Sell-Out Units]=CAST(ISNULL([Sell-Out Units],''0'') as numeric(18,0)),
				[GROSS SELL-OUT VALUE] = CAST(ISNULL([Gross Sell-OUT Value],''0'') as numeric(18,0)) 
			FROM FC_SO_OPTIMUS_NORMAL_'+@division+@Monthfc+' so'
		end
		else if @division='PPD'
		begin
			select @sql=
			'create view '+@view_name_raw+'
			As
			select
				[Year]=CAST(ISNULL([Year],''0'') AS INT),
				[Month]=CAST(ISNULL([Month],'''') AS nvarchar(10)),
				[Client]=ISNULL([Client],''''),
				[Signature]=ISNULL([Signature],''''),
				[Forecasting line]=ISNULL([Forecasting line],''''),
				[Channel]=ISNULL([Channel],''''),
				[Sell-Out Units]=CAST(ISNULL([Sell-Out Units],''0'') as numeric(18,0)),
				[GROSS SELL-OUT VALUE] = CAST(ISNULL([Gross Sell-OUT Value],''0'') as numeric(18,0)) 
			FROM FC_SO_OPTIMUS_NORMAL_'+@division+@Monthfc+' so'
		end

		if @debug>0
		begin
			select @sql 'Create View RAW'
		end
		execute(@sql)
	end

	if @debug>0
	begin
		select @view_name '@view_name'
	end
	IF EXISTS(select * FROM sys.views where name =@view_name)
	BEGIN
		select @sql='drop view '+@view_name
		if @debug>0
		begin
			select @sql 'drop table'
		end
		execute(@sql)
	end
	
	if @n_continue=1
	begin
		if @division='LDB'
		begin
			select @sql=
			'create view '+@view_name+'
			As
				select 
					[Cluster]=case when so.Channel=''OFFLINE'' then ''Cluster 2'' when so.channel=''ONLINE'' then ''Cluster 4'' else '''' end,
					[SO Forecasting lines] = isnull(o.[Forecasting lines],''''),
					[Year] = SO.[Year],
					[Month] = SO.[Month],
					[Signature]=S.[Signature],
					[Channel]= so.Channel,
					[CAT/Axe] = s.[CAT/Axe],
					[SUB CAT/ Sub Axe] = s.[SUB CAT/ Sub Axe],
					[GROUP/ Class] = s.[GROUP/ Class],
					[SUB GROUP/ Brand] = s.[SUB GROUP/ Brand],
					[Product status]=s.[Product status],
					[HERO]=s.HERO,
					[Sell-Out Units]=sum(cast(isnull([Sell-Out Units],''0'') as numeric(18,0))),
					[GROSS SELL-OUT VALUE]=sum(cast(isnull([Gross Sell-OUT Value],''0'') as numeric(18,0)))
				from '+@view_name_raw+' so
				left join
				(
					select distinct
						[Signature],
						[CAT/Axe],
						[SUB CAT/ Sub Axe],
						[GROUP/ Class],
						[SUB GROUP/ Brand],
						[Product status],
						HERO
					from fnc_SubGroupMaster('''+@division+''',''full'')
				) s on s.[SUB GROUP/ Brand] = so.[SUB GROUP/ Brand]
				left join
				(
					select distinct 
						[SUB GROUP/ Brand],
						[Forecasting lines] 
					from FC_SO_OPTIMUS_MAPPING_SUBGRP_'+@division+'
					where FM_KEY=(select top 1 FM_KEY from FC_ComputerName (NOLOCK) where [ComputerName]=HOST_NAME())
				) o on o.[SUB GROUP/ Brand] = s.[SUB GROUP/ Brand]
				/*left join
				(
					select DISTINCT
						[Client Name],
						[Cluster]
					from V_FC_Cluster 
					where Division='''+@division+'''
				) cl on cl.[Client Name]=so.[Client]*/
				where isnull(so.[YEAR],'''') <>''''
				and isnull(o.[Forecasting lines],'''')<>''''
				group by
					o.[Forecasting lines],
					SO.[Year],
					SO.[Month],
					S.[Signature],
					so.[Channel],
					s.[CAT/Axe],
					s.[SUB CAT/ Sub Axe],
					s.[GROUP/ Class],
					s.[SUB GROUP/ Brand],
					s.[Product status],
					s.[HERO] '
			end
		else if @division='CPD'
		begin
			select @sql=
			'create view '+@view_name+'
			As
			select 
				[Cluster]=cl.[Cluster],
				[SO Forecasting lines] = isnull(o.[Forecasting lines],''''),
				[Year] = x.[Year],
				[Month] = x.[Month],
				[Signature]=S.[Signature],
				[Channel]= case when x.Channel = ''E-commerce'' then ''ONLINE'' else ''OFFLINE'' end,
				[CAT/Axe] = s.[CAT/Axe],
				[SUB CAT/ Sub Axe] = s.[SUB CAT/ Sub Axe],
				[GROUP/ Class] = s.[GROUP/ Class],
				[SUB GROUP/ Brand] = s.[SUB GROUP/ Brand],
				[Product status],
				HERO,
				[Sell-Out Units] = [Sell-Out Units],
				[GROSS SELL-OUT VALUE]=[GROSS SELL-OUT VALUE]
			from 
			(
				select 
					*
				from '+@view_name_raw+'
			) as x
			left join
			(
				select distinct
					[Signature],
					[CAT/Axe],
					[SUB CAT/ Sub Axe],
					[GROUP/ Class],
					[SUB GROUP/ Brand],
					[Product status],
					HERO
				from fnc_SubGroupMaster('''+@division+''',''full'')
			) s on s.[SUB GROUP/ Brand] =  x.[Forecasting Line]
			left join
			(
				select distinct 
					[SUB GROUP/ Brand],
					[Forecasting lines] 
				from FC_SO_OPTIMUS_MAPPING_SUBGRP_'+@division+'
				where FM_KEY=(select top 1 FM_KEY from FC_ComputerName (NOLOCK) where [ComputerName]=HOST_NAME())
			) o on o.[SUB GROUP/ Brand] = s.[SUB GROUP/ Brand]
			left join
			(
				select DISTINCT
					[Client Name],
					[Cluster]
				from V_FC_Cluster 
				where Division='''+@division+'''
			) cl on cl.[Client Name]=x.[Client]
			where 
				isnull(x.[YEAR],'''') <>'''' 
			and isnull(S.[Signature],'''')<>'''' '
		end
		else if @division='LLD'
		begin
			select @sql=
			'create view '+@view_name+'
			As
			select
				[Cluster]=isnull(cl.[Cluster],''''),
				[SO Forecasting lines] = isnull(o.[Forecasting lines],''''),
				[Year] = SO.[Year],
				[Month] = SO.[Month],
				[Signature]=S.[Signature],
				[Channel]= so.Channel,
				[CAT/Axe] = s.[CAT/Axe],
				[SUB CAT/ Sub Axe] = s.[SUB CAT/ Sub Axe],
				[GROUP/ Class] = s.[GROUP/ Class],
				[SUB GROUP/ Brand] = s.[SUB GROUP/ Brand],
				[Product status],
				HERO,
				[Sell-Out Units] = cast(isnull([Sell-Out Units],''0'') as numeric(18,0)),
				[GROSS SELL-OUT VALUE] = cast(isnull([Gross Sell-OUT Value],''0'') as numeric(18,0)) 
			from '+@view_name_raw+' so
			left join
			(
				select distinct
					[Signature],
					[CAT/Axe],
					[SUB CAT/ Sub Axe],
					[GROUP/ Class],
					[SUB GROUP/ Brand],
					[Product status],
					HERO
				from fnc_SubGroupMaster('''+@division+''',''full'')
			) s on s.[SUB GROUP/ Brand] =  so.[Forecasting Line]
			left join
			(
				select distinct 
					[SUB GROUP/ Brand],
					[Forecasting lines] 
				from FC_SO_OPTIMUS_MAPPING_SUBGRP_'+@division+'
				where FM_KEY=(select top 1 FM_KEY from FC_ComputerName (NOLOCK) where [ComputerName]=HOST_NAME())
			) o on o.[SUB GROUP/ Brand] = s.[SUB GROUP/ Brand]
			left join
			(
				select DISTINCT
					[Client Name],
					[Cluster]
				from V_FC_Cluster 
				where Division='''+@division+'''
			) cl on cl.[Client Name]=so.[Client]
			where isnull(so.[YEAR],'''')<>'''' '
		end
		else if @division='PPD'
		begin
			select @sql=
			'create view '+@view_name+'
			As
			select
				[Cluster]=isnull(cl.[Cluster],''''),
				[SO Forecasting lines] = isnull(o.[Forecasting lines],''''),
				[Year] = SO.[Year],
				[Month] = SO.[Month],
				[Signature]=S.[Signature],
				[Channel]= so.Channel,
				[CAT/Axe] = s.[CAT/Axe],
				[SUB CAT/ Sub Axe] = s.[SUB CAT/ Sub Axe],
				[GROUP/ Class] = s.[GROUP/ Class],
				[SUB GROUP/ Brand] = s.[SUB GROUP/ Brand],
				[Product status],
				HERO,
				[Sell-Out Units] = cast(isnull([Sell-Out Units],''0'') as numeric(18,0)),
				[GROSS SELL-OUT VALUE] = cast(isnull([Gross Sell-OUT Value],''0'') as numeric(18,0)) 
			from '+@view_name_raw+' so
			left join
			(
				select distinct
					[Signature],
					[CAT/Axe],
					[SUB CAT/ Sub Axe],
					[GROUP/ Class],
					[SUB GROUP/ Brand],
					[Product status],
					HERO
				from fnc_SubGroupMaster('''+@division+''',''full'')
			) s on s.[SUB GROUP/ Brand] =  so.[Forecasting Line]
			left join
			(
				select distinct 
					[SUB GROUP/ Brand],
					[Forecasting lines] 
				from FC_SO_OPTIMUS_MAPPING_SUBGRP_'+@division+'
				where FM_KEY=(select top 1 FM_KEY from FC_ComputerName (NOLOCK) where [ComputerName]=HOST_NAME())
			) o on o.[SUB GROUP/ Brand] = s.[SUB GROUP/ Brand]
			left join
			(
				select DISTINCT
					[Client Name],
					[Cluster]
				from V_FC_Cluster 
				where Division='''+@division+'''
			) cl on cl.[Client Name]=so.[Client]
			where isnull(so.[YEAR],'''')<>'''' '
		end
		
		if @debug>0
		begin
			select @sql--, len(@sql2),len(@sql3)
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