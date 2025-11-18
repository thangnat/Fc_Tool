/*
	select * from V_FC_LLD_SO_HIS_FINAL_TEST
	select * from FC_LLD_SO_HIS_202201
	where isnull([SUB GROUP/ Brand],'') ='' and periodkey = '202301'
*/

Alter View V_FC_LLD_SO_HIS_FINAL_TEST
with encryption
As
select
	[Ref. Code],
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
		[Ref. Code]=ms.[Ref. Code],
		[SO Forecasting lines]=o.[Forecasting lines],
		[PeriodKey],
		[BundleType],
		[Division],
		[GROUP/ Class]=isnull(ff.[GROUP/ Class],s.[GROUP/ Class]),--[Group],
		[Cluster],
		[Sales Org],
		[Product Type]=s.[Product Type],
		[Signature]=isnull(ff.[Signature],s.[Signature]),
		[CAT/Axe]=isnull(ff.[CAT/Axe],s.[CAT/Axe]),
		[SUB CAT/ Sub Axe]=isnull(ff.[SUB CAT/ Sub Axe],s.[SUB CAT/ Sub Axe]),
		[SUB GROUP/ Brand]=isnull(ff.[SUB GROUP/ Brand],s.[SUB GROUP/ Brand]),
		[Product status]=isnull(ff.[Product status],s.[Product status]),
		[Channel]=case when [Channel]='OFLINE' then 'OFFLINE' else [Channel] end,
		[HERO]=isnull(ff.[Hero],s.[Hero]),
		[Time series],
		[Year]=left(PeriodKey,4),
		[Month]=right(PeriodKey,2),
		[OpenStock],
		[OpenStockValue],
		[SellIn],
		[SellInValue],
		[SellOut],
		[SellOutValue],
		[EndStock],
		[EndStockValue]
	from FC_LLD_SO_HIS_FINAL h
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
		from fnc_SubGroupMaster('LLD','full' )
	) s on s.Barcode = h.Barcode
	left join 
	(
		select distinct 
			[SUB GROUP/ Brand],
			[Forecasting lines]
		from FC_SO_OPTIMUS_MAPPING_SUBGRP_LLD
		where FM_KEY=(select top 1 FM_KEY from FC_ComputerName (NOLOCK) where [ComputerName]=HOST_NAME())
	) o on o.[SUB GROUP/ Brand] = s.[SUB GROUP/ Brand]
	inner join
	(
		select DISTINCT
			[FM_KEY],
			[Ref. Code],
			[SUB GROUP/ Brand]
		from fnc_SubGroupMaster('LLD','full')
	) ms on ms.[SUB GROUP/ Brand]=s.[SUB GROUP/ Brand]--left(ms.FM_KEY,6)=left(h.PeriodKey,6) and 
	left join
	(
		select DISTINCT
			[FM_KEY],
			[ref. Code],
			[SUB GROUP/ Brand],
			[Signature],
			[CAT/Axe],
			[SUB CAT/ Sub Axe],
			[GROUP/ Class],
			[Product status],
			[Hero],
			[% Ratio]
		from fnc_SubGroupMaster('LLD','full')
	) ff on ff.[Ref. Code]=ms.[Ref. Code]
	where (OpenStockValue+h.SellInValue+SellOutValue+EndStockValue)<>0
) as x

