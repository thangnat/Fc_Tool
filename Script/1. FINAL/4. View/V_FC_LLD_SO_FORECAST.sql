/*
	select * from V_FC_LLD_SO_FORECAST
*/

Alter View V_FC_LLD_SO_FORECAST
WITH ENCRYPTION
As
select 
	[SO Forecasting lines] = isnull(o.[Forecasting lines],''),
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
	[Sell-Out Units] = cast(isnull([Sell-Out Units],'0') as numeric(18,0)),
	[GROSS SELL-OUT VALUE] = cast(isnull([Gross Sell-OUT Value],'0') as numeric(18,0)) 
from FC_SO_OPTIMUS_NORMAL_LLD so
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
	from fnc_SubGroupMaster('LLD',(select case when [Only run active] = '1' then '' else 'full' end from V_FC_SUBGROUP_ACTIVE))
) s on s.[SUB GROUP/ Brand] =  so.[Forecasting Line]
left join
(
	select distinct 
		[SUB GROUP/ Brand],
		[Forecasting lines] 
	from fnc_FC_SO_OPTIMUS_MAPPING_SUBGRP('lld') 
) o on o.[SUB GROUP/ Brand] = s.[SUB GROUP/ Brand]
where isnull(so.[YEAR],'') <>'' --AND ISNULL(s.[Signature],'')<>''