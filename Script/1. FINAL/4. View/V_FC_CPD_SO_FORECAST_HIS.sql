/*
	select * from V_FC_CPD_SO_FORECAST_HIS
*/

ALTER View V_FC_CPD_SO_FORECAST_HIS
WITH ENCRYPTION
As
select 
	[SO Forecasting lines] = isnull(o.[Forecasting lines],''),
	[Year] = SO.[Year],
	[Month] = SO.[Month],
	[Signature]=S.[Signature],
	[Channel]= case when SO.Channel = 'E-commerce' then 'ONLINE' else 'OFFLINE' end,
	[CAT/Axe] = s.[CAT/Axe],
	[SUB CAT/ Sub Axe] = s.[SUB CAT/ Sub Axe],
	[GROUP/ Class] = s.[GROUP/ Class],
	[SUB GROUP/ Brand] = s.[SUB GROUP/ Brand],
	[Product status] = isnull(s.[Product status],''),
	HERO = s.HERO,
	[Sell-Out Units] = cast(isnull([Sell-Out Units],'0') as numeric(18,0)),
	[GROSS SELL-OUT VALUE] = cast(isnull([Gross Sell-OUT Value],'0') as numeric(18,0)) 
from FC_SO_OPTIMUS_NORMAL_CPD_HIS so
left join
(
	select distinct 
		[SUB GROUP/ Brand],
		[Forecasting lines] 
	from fnc_FC_SO_OPTIMUS_MAPPING_SUBGRP('CPD') 
) o on o.[Forecasting lines] = so.[Forecasting Line]
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
) s on s.[SUB GROUP/ Brand] =  o.[SUB GROUP/ Brand]
where isnull(so.[YEAR],'') <>'' and isnull(S.[Signature],'')<>''