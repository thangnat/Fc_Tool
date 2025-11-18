/*
	exec sp_GetFOC_Detail 'GLYCO BRIGHT DAY CRM 7.5ML TUBE PLV YSM2','OFFLINE','Y-2 (u) M9'
*/
Alter proc sp_GetFOC_Detail
	@Subgrp		nvarchar(200),
	@Channel	nvarchar(10),
	@MonthDesc	Nvarchar(13)
	with encryption
As
select
	SingleQty =  format(sum(SingleQty),'#,##0'),
	BomQty = format(sum(BomQty),'#,##0')
from
(
	select
		--Tablename,
		--[Time Series],
		--Channel,
		SingleQty = case when tablename = 'Single' then sum(HIS_QTY_FOC) else 0 end,
		BomQty = case when tablename = 'Bom Component' then sum(HIS_QTY_FOC) else 0 end
	from
	(
		select 
			Tablename = 'Single',
			SubGrp,
			[Year],
			[Month],
			Channel,
			[Pass Column Header],
			HIS_QTY_FOC = HIS_QTY_SINGLE_FDR,
			[Time Series],
			[Product Type]
		from V_His_SI_Single_FDR
		Union ALL
		select 
			Tablename = 'Bom Component',
			SubGrp,
			[Year],
			[Month],
			Channel,
			[Pass Column Header],
			HIS_QTY_FOC = HIS_QTY_BOM_FDR,
			[Time Series],
			[Product Type]
		from V_His_SI_Bom_FDR
		where HIS_QTY_BOM_FDR<>0
	) as x
	where [Pass Column Header] = @MonthDesc
	and SubGrp = @Subgrp
	and Channel = @Channel
	group by
		Tablename
		--[Time Series],
		--Channel
) as x1