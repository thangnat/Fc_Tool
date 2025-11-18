/*
	select * 
	from V_FC_CPD_SO_HIS_FINAL_NEW 
	where left(periodkey,4) = '2024'-- and [SUB GROUP/ Brand] = 'AGE REWIND CONCEALER' --AND tYPE = 'HIS'
	order by cast(left(periodkey,4) as int) asc, cast(right(periodkey,2) as int) asc
*/

Alter view V_FC_CPD_SO_HIS_FINAL_NEW
with encryption
As
select
	--[Type] = x.Type,
	PeriodKey = x.PeriodKey,
	[SUB GROUP/ Brand] = x.[SUB GROUP/ Brand],
	[CAT/Axe] = s.[CAT/Axe],
	[SUB CAT/ Sub Axe] = s.[SUB CAT/ Sub Axe],
	[Signature] = s.[Signature],
	Channel = x.Channel,
	[Product Type] = x.[Product Type],
	SellOut = x.SellOut
from
(
	select 
		[Type] = 'HIS',
		PeriodKey,
		[SUB GROUP/ Brand] = SubGrp,
		Channel,
		[Product Type],
		SellOut = SellOut
	from FC_CPD_SO_HIS_FINAL
	--group by
	--	PeriodKey
	union all
	select 
		[Type] = 'Forecast',
		PeriodKey,
		[SUB GROUP/ Brand],
		Channel,
		[Product Type],
		SellOut = [Sell-Out Units]
	from V_FC_CPD_SO_Normal_Forecast_FINAL
	--group by
	--	PeriodKey
) as x
left join 
(
	select DISTINCT
		[SUB GROUP/ Brand],
		[CAT/Axe],
		[SUB CAT/ Sub Axe],
		[Signature]
	from fnc_SubGroupMaster('full')
) s on s.[SUB GROUP/ Brand] = x.[SUB GROUP/ Brand]
--cross join (select value from string_split('O+O,ONLINE,OFFLINE',',')) c
--group by
--	[Type],
--	PeriodKey