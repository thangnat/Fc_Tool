/*
	select * from fnc_SubGroupMaster('LLD','full')
*/
Alter function fnc_SubGroupMaster
(
	@Division	Nvarchar(3),
	@Type		nvarchar(4)
)
returns @tablefinale TABLE
(
	[SO Forecasting lines]	nvarchar(500) null,
	[Division]				nvarchar(3) null,
	[FM_KEY]				nvarchar(6) null,
	[Sales Org]				nvarchar(4) null,
	[Barcode]				nvarchar(50) null,
	[Material]				nvarchar(50) null,
	[Bundle name]			nvarchar(500) null,
	[Material Type]			nvarchar(10) null,
	[Ref. Code]				nvarchar(30) null,
	[SUB GROUP/ Brand]		nvarchar(500) null,
	[% Ratio]				INT null,
	[CAT/Axe]				nvarchar(300) null,
	[SUB CAT/ Sub Axe]		nvarchar(300) null,
	[GROUP/ Class]			nvarchar(300) null,
	[HERO]					nvarchar(60) null,
	[Product status]		nvarchar(50) null,
	[Signature]				nvarchar(100) null,
	[Type]					nvarchar(10) null,
	[Product Type]			nvarchar(10) null,
	[Dchain]				nvarchar(50) null,
	[Item Category Group]	nvarchar(10) null,
	[Active]				INT default 0
)
with encryption
As
begin
	--declare @FM_KEY nvarchar(6)=''
	--select FM_KEY =format(dateadd(M,-1,getdate(),'')--isnull(FM_KEY,'') from FC_ComputerName where ComputerName=HOST_NAME()

	declare @tableTmp TABLE
	(
		[SO Forecasting lines]	nvarchar(500) null,
		[Division]				nvarchar(3) null,
		[FM_KEY]				nvarchar(6) null,
		[Sales Org]				nvarchar(4) null,
		[Barcode]				nvarchar(50) null,
		[Material]				nvarchar(50) null,
		[Bundle name]			nvarchar(500) null,
		[Material Type]			nvarchar(10) null,
		[Ref. Code]				nvarchar(30) null,
		[SUB GROUP/ Brand]		nvarchar(500) null,
		[% Ratio]				INT null,
		[CAT/Axe]				nvarchar(300) null,
		[SUB CAT/ Sub Axe]		nvarchar(300) null,
		[GROUP/ Class]			nvarchar(300) null,
		[HERO]					nvarchar(60) null,
		[Product status]		nvarchar(50) null,
		[Signature]				nvarchar(100) null,
		[Type]					nvarchar(10) null,
		[Product Type]			nvarchar(10) null,
		[Dchain]				nvarchar(50) null,
		[Item Category Group]	nvarchar(10) null,
		[Active]				INT default 0
	)
	if @Division='CPD'
	begin
		INSERT INTO @tableTmp
		select DISTINCT
			[SO Forecasting lines]=o.[Forecasting lines],
			[Division],
			[FM_KEY],
			[Sales Org],
			[Barcode],
			[Material],
			[Bundle name],
			[Material Type],
			[Ref. Code],
			[SUB GROUP/ Brand]=s.[SUB GROUP/ Brand],
			[% Ratio]=s.[% Ratio],
			[CAT/Axe],
			[SUB CAT/ Sub Axe],
			[GROUP/ Class],
			[HERO],
			[Product status] = s.[Product status],
			[Signature],
			[Type],
			[Product Type],
			[Dchain],
			[Item Category Group],
			[Active]
		from 
		(
			select * 
			from fnc_SubGroupMaster_Full_CPD
			where FM_KEY=(select top 1 FM_KEY from FC_ComputerName (NOLOCK) where [ComputerName]=HOST_NAME())
		) s
		left join 
		(
			select DISTINCT
				[SUB GROUP/ Brand],
				[Forecasting lines]
			from FC_SO_OPTIMUS_MAPPING_SUBGRP_CPD
			where FM_KEY=(select top 1 FM_KEY from FC_ComputerName (NOLOCK) where [ComputerName]=HOST_NAME())
		) o on o.[SUB GROUP/ Brand] = s.[SUB GROUP/ Brand]
	end
	else if @Division='LLD'
	begin
		INSERT INTO @tableTmp
		select DISTINCT
			[SO Forecasting lines]=o.[Forecasting lines],
			[Division],
			[FM_KEY],
			[Sales Org],
			[Barcode],
			[Material],
			[Bundle name],
			[Material Type],
			[Ref. Code],
			[SUB GROUP/ Brand]=s.[SUB GROUP/ Brand],
			[% Ratio]=s.[% Ratio],
			[CAT/Axe],
			[SUB CAT/ Sub Axe],
			[GROUP/ Class],
			[HERO],
			[Product status] = s.[Product status],
			[Signature],
			[Type],
			[Product Type],
			[Dchain],
			[Item Category Group],
			[Active]
		from 
		(
			select *--distinct FM_KEY
			from fnc_SubGroupMaster_Full_LLD
			where FM_KEY=(select top 1 FM_KEY from FC_ComputerName (NOLOCK) where [ComputerName]=HOST_NAME())
		) s
		left join 
		(
			select DISTINCT
				[SUB GROUP/ Brand],
				[Forecasting lines]
			from FC_SO_OPTIMUS_MAPPING_SUBGRP_LLD
			where FM_KEY=(select top 1 FM_KEY from FC_ComputerName (NOLOCK) where [ComputerName]=HOST_NAME())
		) o on o.[SUB GROUP/ Brand] = s.[SUB GROUP/ Brand]
	end
	else if @Division='PPD'
	begin
		INSERT INTO @tableTmp
		select DISTINCT
			[SO Forecasting lines]=o.[Forecasting lines],
			[Division],
			[FM_KEY],
			[Sales Org],
			[Barcode],
			[Material],
			[Bundle name],
			[Material Type],
			[Ref. Code],
			[SUB GROUP/ Brand]=s.[SUB GROUP/ Brand],
			[% Ratio]=s.[% Ratio],
			[CAT/Axe],
			[SUB CAT/ Sub Axe],
			[GROUP/ Class],
			[HERO],
			[Product status] = s.[Product status],
			[Signature],
			[Type],
			[Product Type],
			[Dchain],
			[Item Category Group],
			[Active]
		from 
		(
			select --distinct FM_KEY
				*
			from fnc_SubGroupMaster_Full_PPD
			where FM_KEY=(select top 1 FM_KEY from FC_ComputerName (NOLOCK) where [ComputerName]=HOST_NAME())
		) s
		left join 
		(
			select DISTINCT
				[SUB GROUP/ Brand],
				[Forecasting lines]
			from FC_SO_OPTIMUS_MAPPING_SUBGRP_PPD
			where FM_KEY=(select top 1 FM_KEY from FC_ComputerName (NOLOCK) where [ComputerName]=HOST_NAME())
		) o on o.[SUB GROUP/ Brand] = s.[SUB GROUP/ Brand]
	end
	else if @Division='LDB'
	begin
		INSERT INTO @tableTmp
		select DISTINCT
			[SO Forecasting lines]=o.[Forecasting lines],
			[Division],
			[FM_KEY],
			[Sales Org],
			[Barcode],
			[Material],
			[Bundle name],
			[Material Type],
			[Ref. Code],
			[SUB GROUP/ Brand]=s.[SUB GROUP/ Brand],
			[% Ratio]=s.[% Ratio],
			[CAT/Axe],
			[SUB CAT/ Sub Axe],
			[GROUP/ Class],
			[HERO],
			[Product status] = case when Barcode='3337875546430' then 'On Going' else s.[Product status] end,
			[Signature],
			[Type],
			[Product Type],
			[Dchain],
			[Item Category Group],
			[Active]
		from 
		(
			select * 
			from fnc_SubGroupMaster_Full_LDB
			where FM_KEY=(select top 1 FM_KEY from FC_ComputerName (NOLOCK) where [ComputerName]=HOST_NAME())
			and Barcode NOT IN
			(
				'3337871325572',
				'3337871324681',
				'3337872414084',
				'3433422405318'
			)
		) s
		left join 
		(
			select DISTINCT
				[SUB GROUP/ Brand],
				[Forecasting lines]
			from FC_SO_OPTIMUS_MAPPING_SUBGRP_LDB
			where FM_KEY=(select top 1 FM_KEY from FC_ComputerName (NOLOCK) where [ComputerName]=HOST_NAME())
		) o on o.[SUB GROUP/ Brand] = s.[SUB GROUP/ Brand]
	end
	
	insert into @tablefinale
	select * from @tableTmp
	return
end
