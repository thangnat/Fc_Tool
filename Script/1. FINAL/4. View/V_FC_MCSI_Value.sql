/*
	
	select * from V_FC_MCSI_Value
*/

Alter View V_FC_MCSI_Value
As
select 
	division = mc.division,
	[Sales org] = mc.[Sales org],
	Customer = Mc.Customer,
	[SUB GROUP/ Brand] = s.[SUB GROUP/ Brand],
	Channel = C.Channel,
	Material = Mc.Material,
	Barcode = mc.Barcode,
	[Year] = mc.[year],
	[Month] = mc.[month],
	[Month desc] = (
			select replace([Pass],'@',cast(([Year]-year(getdate())) as nvarchar(2))) 
			from V_FC_MONTH_MASTER 
			where Month_number = cast([Month] as int)
		),
	[Total value] = sum(mc.[Total value])
from FC_MCSI_LLD_OK mc
left join 
(
	select	
		[SUB GROUP/ Brand],
		Barcode
	from fnc_SubGroupMaster('lld','full')
)s on s.Barcode = mc.Barcode
left join 
(
	select * 
	from FC_MasterFile_LLD_Customer_Master (NOLOCK)
) c on RIGHT('0000000000'+c.[Node 5],10) = RIGHT('0000000000'+Mc.Customer,10)
group by
	mc.division,
	mc.[Sales org],
	Mc.Customer,
	s.[SUB GROUP/ Brand],
	C.Channel,
	Mc.Material,
	mc.Barcode,
	mc.[year],
	mc.[month]
--order by
--	mc.[year] asc,
--	mc.[month] asc