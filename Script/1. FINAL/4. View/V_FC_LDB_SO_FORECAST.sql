/*
	select * from V_FC_LDB_SO_FORECAST order by [year] asc, [month] asc
*/

Alter View V_FC_LDB_SO_FORECAST
WITH ENCRYPTION
As
select
	[SO Forecasting lines],
	[Year],
	[Month],
	[Signature],
	[Channel],--=case when Category='ONLINE' then 'ONLINE' else 'OFFLINE' end ,
	[CAT/Axe],
	[SUB CAT/ Sub Axe],
	[GROUP/ Class],
	[SUB GROUP/ Brand],
	[Product status],
	[HERO],
	[Sell-Out Units],
	[GROSS SELL-OUT VALUE]
from FC_LDB_SO_FORECAST_202408
--where isnull([Signature],'')<>''
--select
--	[SO Forecasting lines],
--	[Year],
--	[Month],
--	[Signature],
--	[Channel],
--	[CAT/Axe],
--	[SUB CAT/ Sub Axe],
--	[GROUP/ Class],
--	[SUB GROUP/ Brand],
--	[Product status],
--	[HERO],
--	[Sell-Out Units]=sum([Sell-Out Units]),
--	[GROSS SELL-OUT VALUE]=sum([GROSS SELL-OUT VALUE])
--from
--(
--	select
--		[SO Forecasting lines],
--		[Year],
--		[Month]=case when [Month]='July' then 'Jul' else [Month] end,
--		[Signature],
--		[Channel],
--		[CAT/Axe],
--		[SUB CAT/ Sub Axe],
--		[GROUP/ Class],
--		[SUB GROUP/ Brand],
--		[Product status],
--		[HERO],
--		[Sell-Out Units],
--		[GROSS SELL-OUT VALUE]
--	from FC_LDB_SO_FORECAST
--) as x
--group by
--	[SO Forecasting lines],
--	[Year],
--	[Month],
--	[Signature],
--	[Channel],
--	[CAT/Axe],
--	[SUB CAT/ Sub Axe],
--	[GROUP/ Class],
--	[SUB GROUP/ Brand],
--	[Product status],
--	[HERO]
--select

--	[SO Forecasting lines],
--	[Year],
--	[Month],
--	[Signature],
--	[Channel],
--	[CAT/Axe],
--	[SUB CAT/ Sub Axe],
--	[GROUP/ Class],
--	[SUB GROUP/ Brand],
--	[Product status],
--	HERO,
--	[Sell-Out Units],
--	[GROSS SELL-OUT VALUE]=[Sell-Out Units]*(select dbo.fnc_Get_RSP_LDB('LDB',xx.[SUB GROUP/ Brand],xx.[Sell-Out Units],xx.[Year],xx.[Month]))
--	--select * from FC_BFL_Master_LDB where [EAN code]='3337871330552'
--	--select * from fnc_SubGroupMaster('LDB','full') where Barcode='3337871330552'
--from
--(
--	select
--		[SO Forecasting lines] = isnull(o.[Forecasting lines],''),
--		[Year] = X.[Year],
--		[Month] = X.[Month],
--		[Signature]=S.[Signature],
--		[Channel]= X.Channel,
--		[CAT/Axe] = s.[CAT/Axe],
--		[SUB CAT/ Sub Axe] = s.[SUB CAT/ Sub Axe],
--		[GROUP/ Class] = s.[GROUP/ Class],
--		[SUB GROUP/ Brand] = s.[SUB GROUP/ Brand],
--		[Product status],
--		HERO,
--		[Sell-Out Units] = cast(isnull([Sell-Out Units],'0') as numeric(18,0)),
--		[GROSS SELL-OUT VALUE]=0
--	from
--	(
--		select
--			[Forecasting Line]=so.[Forecasting Line],
--			Channel = SO.Channel,
--			[Year] = SO.[Year],
--			[Month] = SO.[Month],
--			[Sell-Out Units] = sum(cast(isnull(so.[Sell-Out Units],'0') as numeric(18,0))),
--			[GROSS SELL-OUT VALUE] = sum(cast(isnull(so.[Gross Sell-OUT Value],'0') as numeric(18,0)))
--		from FC_SO_OPTIMUS_NORMAL_LDB so
--		group by
--			so.[Forecasting Line],
--			SO.Channel,
--			SO.[Year],
--			SO.[Month]
--		union all
--		select
--			[Forecasting Line]=mm.[SUB GROUP/ Brand],
--			Channel=BSO.Channel,
--			[Year] = bso.[Year],
--			[Month] = bso.[Month],		
--			[Sell-Out Units],
--			[GROSS SELL-OUT VALUE]
--		from
--		(
--			select
--				Channel=BSO.Channel,
--				[Sap Code]=BSO.[Sap Code],
--				[Year] = bso.[Year],
--				[Month] = bso.[Month],		
--				[Sell-Out Units] = sum(cast(isnull(bso.[Sell-Out Units],'0') as numeric(18,0))),
--				[GROSS SELL-OUT VALUE] = sum(cast(isnull(bso.[Gross Sell-OUT Value],'0') as numeric(18,0)))
--			from FC_SO_OPTIMUS_Promo_Bom_LDB_OK bso
--			group by
--				BSO.Channel,
--				BSO.[Sap Code],
--				bSO.[Year],
--				bSO.[Month]
--		) as bso
--		left join
--		(
--			select distinct
--				[EAN / UPC],
--				Material
--			from SC1.dbo.MM_ZMR54OLD_Stg (NOLOCK)
--		) m on m.Material=bso.[Sap Code]
--		LEFT JOIN
--		(
--			SELECT DISTINCT
--				Barcode_Bom,
--				Barcode_Component
--			FROM V_ZMR32
--			WHERE Division = 'LDB'
--		) z on z.Barcode_Bom = m.[EAN / UPC]
--		inner join 
--		(
--			select DISTINCT
--				[SUB GROUP/ Brand],
--				[EAN / UPC]
--			from fnc_MM_ZMR54OLD_Stg('LDB')
--			where STT = 1
--		) mm on mm.[EAN / UPC] = z.Barcode_Component
--	) as x
--	inner join
--	(
--		select distinct
--			[Signature],
--			[CAT/Axe],
--			[SUB CAT/ Sub Axe],
--			[GROUP/ Class],
--			[SUB GROUP/ Brand],
--			[Product status],
--			HERO
--		from fnc_SubGroupMaster('LDB',(select case when [Only run active] = '1' then '' else 'full' end from V_FC_SUBGROUP_ACTIVE))
--	) s on s.[SUB GROUP/ Brand] = x.[Forecasting Line]
--	left join
--	(
--		select distinct 
--			[SUB GROUP/ Brand],
--			[Forecasting lines] 
--		from fnc_FC_SO_OPTIMUS_MAPPING_SUBGRP('LDB') 
--	) o on o.[SUB GROUP/ Brand] = s.[SUB GROUP/ Brand]
--) as xx