/*
	select * from V_FC_CPD_SO_Normal_Forecast_FINAL 
	where periodkey is null
*/
Alter View V_FC_CPD_SO_Normal_Forecast_FINAL
with encryption
As
select
	PeriodKey = cast([Year] as nvarchar(4))
				+(
					select right('00'+Month_Number,2) 
					from V_FC_MONTH_MASTER 
					where Month_Desc = case 
											when n.[month] = 'Jul' then 'July' 
											when n.Month = 'sep' then 'sept' 
											when n.Month = 'Jun' then 'June' 
											else n.[Month] 
										end
				),
	[Year],
	[Month],
	Division = 'CPD',
	BundleType = 'Single',
	[Sales Org] = 'V200',
	[Signature] = s.[Signature],
	[CAT/Axe] = s.[CAT/Axe],
	[SUB CAT/ Sub Axe] = s.[SUB CAT/ Sub Axe],
	[Product Type] = s.[Product Type],
	[SUB GROUP/ Brand] = m.[SUB GROUP/ Brand],
	[Forecasting Line] = n.[Forecasting Line],
	Channel = case when n.Channel = 'E-commerce' then 'ONLINE' else 'OFFLINE' end,
	[Time series] = '1. Baseline Qty',
	[Sell-Out Units] = cast(isnull(n.[Sell-Out Units],0) as numeric(18,0)),
	[Sell-Out Value] = cast(isnull(n.[GROSS SELL-OUT VALUE],0) as numeric(18,0))
from FC_SO_OPTIMUS_NORMAL n
inner join 
(
	select distinct
		CAT,
		[SUB CAT],

		[SUB GROUP/ Brand] = [SUB GROUP],
		[Forecasting lines]
	from FC_SO_OPTIMUS_MAPPING_SUBGRP
	--where [HERO Y22] in('SUPER HERO','HERO')
) m on m.[Forecasting lines] = n.[Forecasting Line]
inner join 
(
	select distinct
		[SUB GROUP/ Brand],
		[Product Type],
		[Signature],
		HERO,
		[CAT/Axe],
		[SUB CAT/ Sub Axe],
		[GROUP/ Class]
	from fnc_SubGroupMaster('CPD','full')
	where [Product Type] in('YFG','YSM2')
) s on s.[SUB GROUP/ Brand] = m.[SUB GROUP/ Brand]
where [Sell-Out Units]>0
--AND [Year] =2024 AND [Month] NOT IN('Jan','Feb')
union all
select
	PeriodKey = cast(([Year]+1) as nvarchar(4))
	+(
		select right('00'+Month_Number,2) 
		from V_FC_MONTH_MASTER 
		where Month_Desc = case 
								when n.[month] = 'Jul' then 'July' 
								when n.[Month] = 'sep' then 'sept' 
								when n.[Month] = 'Jun' then 'June' 
								else n.[Month] 
							end
	),
	[Year]= [Year]+1,
	[Month],
	Division = 'CPD',
	BundleType = 'Single',
	[Sales Org] = 'V200',
	[Signature] = s.[Signature],
	[CAT/Axe] = s.[CAT/Axe],
	[SUB CAT/ Sub Axe] = s.[SUB CAT/ Sub Axe],
	[Product Type] = s.[Product Type],
	[SUB GROUP/ Brand] = m.[SUB GROUP/ Brand],
	[Forecasting Line] = n.[Forecasting Line],
	Channel = case when n.Channel = 'E-commerce' then 'ONLINE' else 'OFFLINE' end,
	[Time series] = '1. Baseline Qty',
	[Sell-Out Units] = cast(isnull(n.[Sell-Out Units],0) as numeric(18,0))*1.1,
	[Sell-Out Value] = cast(isnull(n.[GROSS SELL-OUT VALUE],0) as numeric(18,0))*1.1
from FC_SO_OPTIMUS_NORMAL n
inner join 
(
	select distinct
		[SUB GROUP/ Brand] = [SUB GROUP],
		[Forecasting lines]
	from FC_SO_OPTIMUS_MAPPING_SUBGRP
) m on m.[Forecasting lines] = n.[Forecasting Line]
inner join 
(
	select distinct
		[SUB GROUP/ Brand],
		[Product Type],
		[Signature],
		HERO,
		[CAT/Axe],
		[SUB CAT/ Sub Axe],
		[GROUP/ Class]
	from fnc_SubGroupMaster('CPD','full')
	where [Product Type] in('YFG','YSM2')
) s on s.[SUB GROUP/ Brand] = m.[SUB GROUP/ Brand]
where [Sell-Out Units]>0
