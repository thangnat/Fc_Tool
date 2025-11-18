/*
	select * from V_FC_PPD_SO_HIS_FINAL
	select * from FC_LLD_SO_HIS_202201
	where isnull([SUB GROUP/ Brand],'') ='' and periodkey = '202301'
*/

Alter View V_FC_PPD_SO_HIS_FINAL
with encryption
As
select
	[SO Forecasting lines],
	PeriodKey,
	BundleType,
	Division,
	[GROUP/ Class],
	[Cluster],
	[Sales Org],
	[Product Type],
	[Signature],
	[CAT/Axe],
	[SUB CAT/ Sub Axe],
	[SUB GROUP/ Brand],
	[Product status],
	Channel,
	HERO,
	[Time series],
	[Year],
	[Month],
	OpenStock,
	OpenStockValue,
	SellIn,
	SellInValue,
	SellOut,
	SellOutValue,
	EndStock,
	EndStockValue
from
(
	select
		[SO Forecasting lines] = o.[Forecasting lines],
		PeriodKey,
		BundleType,
		Division,
		[GROUP/ Class]=[GROUP/ Class],--[Group],
		[Cluster],
		[Sales Org],
		[Product Type]=s.[Product Type],
		[Signature] = s.[Signature],
		[CAT/Axe] = s.[CAT/Axe],
		[SUB CAT/ Sub Axe] = s.[SUB CAT/ Sub Axe],
		[SUB GROUP/ Brand] = s.[SUB GROUP/ Brand],
		[Product status]=s.[Product status],
		Channel=case when Channel='OFLINE' then 'OFFLINE' else Channel end,
		HERO = s.Hero,
		[Time series],
		[Year] = left(PeriodKey,4),
		[Month] = right(PeriodKey,2),
		OpenStock,
		OpenStockValue,
		SellIn,
		SellInValue,
		SellOut,
		SellOutValue,
		EndStock,
		EndStockValue
	from FC_PPD_SO_HIS_FINAL h
	left join 
	(
		select DISTINCT
			[Signature],
			[GROUP/ Class],
			[CAT/Axe],
			[SUB CAT/ Sub Axe],
			[SUB GROUP/ Brand],
			[Barcode],
			[Product Type],
			[Product status],
			[HERO]
		from fnc_SubGroupMaster('PPD','full' )
	) s on s.Barcode = h.Barcode
	left join 
	(
		select distinct 
			[SUB GROUP/ Brand],
			[Forecasting lines]
		from FC_SO_OPTIMUS_MAPPING_SUBGRP_PPD
		where FM_KEY=(select top 1 FM_KEY from FC_ComputerName (NOLOCK) where [ComputerName]=HOST_NAME())
	) o on o.[SUB GROUP/ Brand] = s.[SUB GROUP/ Brand]
	where (OpenStockValue+h.SellInValue+SellOutValue+EndStockValue)<>0
) as x
--where  SellOut>0
--left join V_FC_MMDOWNLOAD_SORTBY_LLD sb on sb.[SUB GROUP/ Brand] = s.[SUB GROUP/ Brand]
--where h.barcode not in(select value from string_split('TUSU00018FOC,TUSU00021FOC,TUSU00022FOC,TUSU00001SG ',','))
