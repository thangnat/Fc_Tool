/*
	select * from V_FC_CPD_2_SO_FORECAST_202409
*/

Alter View V_FC_CPD_SO_FORECAST
WITH ENCRYPTION
As
select 
	[SO Forecasting lines] = isnull(o.[Forecasting lines],''),
	[Year] = x.[Year],
	[Month] = x.[Month],
	[Signature]=S.[Signature],
	[Channel]= case when x.Channel = 'E-commerce' then 'ONLINE' else 'OFFLINE' end,
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
	--single
	select
		Channel,
		[Forecasting Line]=so.[Forecasting Line],
		[Year],
		[Month],
		[Sell-Out Units] = sum(cast(isnull([Sell-Out Units],'0') as numeric(18,0))),
		[GROSS SELL-OUT VALUE] = sum(cast(isnull([Gross Sell-OUT Value],'0') as numeric(18,0)))
	from FC_SO_OPTIMUS_NORMAL_CPD so
	group by
		so.Channel,
		so.[Forecasting Line],
		so.[Year],
		so.[Month]
	union all
	--bundle
	select
		Channel,
		[Forecasting Line]=s.[SUB GROUP/ Brand],
		[Year],
		[Month],
		[Sell-Out Units]=sum([Sell-Out Units]),
		[GROSS SELL-OUT VALUE]=sum([GROSS SELL-OUT VALUE] )
	from
	(
		select
			Channel,
			[Sap Code],
			[Year],
			[Month],
			[Sell-Out Units] = sum(cast(isnull([Sell-Out Units],'0') as numeric(18,0))),
			[GROSS SELL-OUT VALUE] = sum(cast(isnull([Gross Sell-OUT Value],'0') as numeric(18,0)))
		from FC_SO_OPTIMUS_Promo_Bom_cpd_OK bso
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
		WHERE Division = 'CPD'
	) Z ON Z.Material_Bom =bso.[Sap Code]
	inner join 
	(
		select DISTINCT
			Material,
			[SUB GROUP/ Brand],
			[Item Category Group]
		from fnc_SubGroupMaster('CPD','')
		where [Item Category Group]<>'LUMF'
	) as s on s.Material = z.Material_Component
	group by
		Channel,
		s.[SUB GROUP/ Brand],
		[Year],
		[Month]
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
	from fnc_SubGroupMaster('CPD','full')
) s on s.[SUB GROUP/ Brand] =  x.[Forecasting Line]
inner join
(
	select distinct 
		[SUB GROUP/ Brand],
		[Forecasting lines] 
	from fnc_FC_SO_OPTIMUS_MAPPING_SUBGRP('CPD') 
) o on o.[SUB GROUP/ Brand] = s.[SUB GROUP/ Brand]
where isnull(x.[YEAR],'') <>'' and isnull(S.[Signature],'')<>''