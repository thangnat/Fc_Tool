/*
	select * from V_FC_LDB_SO_HIS_FINAL
*/

ALTER View V_FC_LDB_SO_HIS_FINAL
with encryption
As
select
	[SO Forecasting lines] = o.[Forecasting lines],
	PeriodKey,
	BundleType,
	Division,
	[GROUP/ Class]=[Group],
	[Cluster]=case when Channel='OFFLINE' then 'Cluster 2' when Channel='ONLINE' then 'Cluster 4' else '' end,
	[Sales Org],
	[SUB GROUP/ Brand] = s.[SUB GROUP/ Brand],
	[Product Type],
	Channel,
	OpenStock,
	OpenStockValue,
	SellIn,
	SellInValue,
	SellOut,
	SellOutValue,
	EndStock,
	EndStockValue,
	[Time series],
	[Year] = left(PeriodKey,4),
	[Month] = right(PeriodKey,2),
	s.[Signature],
	s.[CAT/Axe],
	s.[SUB CAT/ Sub Axe],
	[Product status] = s.[Product status],
	HERO = s.Hero
from FC_LDB_SO_HIS_FINAL h
left join 
(
	SELECT DISTINCT
		Barcode,
		[Signature],
		[CAT/Axe],
		[SUB CAT/ Sub Axe],
		[SUB GROUP/ Brand],
		[Product status],
		HERO
	from fnc_SubGroupMaster('LDB','full')
	WHERE [Item Category Group] <> 'LUMF' --or ([Item Category Group] = 'LUMF' and Barcode = '8935274636421')
) s on s.Barcode = h.Barcode
LEFT JOIN 
(
	select distinct 
		[SUB GROUP/ Brand],
		[Forecasting lines]
	from FC_SO_OPTIMUS_MAPPING_SUBGRP_LDB
	where FM_KEY=(select top 1 FM_KEY from FC_ComputerName (NOLOCK) where [ComputerName]=HOST_NAME())
) o on o.[SUB GROUP/ Brand] = s.[SUB GROUP/ Brand]
where (OpenStockValue+h.SellInValue+h.SellOutValue+EndStockValue)<>0
