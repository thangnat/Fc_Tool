/*
select * from V_SOH_RAW
sp_helptext V_SOH_RAW
*/
ALTER View V_SOH_RAW
with encryption
As
with cte1 as
(
	select
		SubGrp,
		Material,
		TotalQty = sum(Unrestricted+[Stock in transfer]+[In Quality Insp.]+[Restricted-Use Stock]+Blocked+[Returns])
	from
	(
		select
			[Product Type],
			--[],
			SubGrp = s.[SUB GROUP/ Brand],
			Material = z.Material,
			Unrestricted = cast(replace(case when right(Unrestricted,1)='-' then '-'+REPLACE(Unrestricted,'-','') else  Unrestricted end,',','') as int),
			[Stock in transfer] = cast(replace(case when right([Stock in transfer],1)='-' then '-'+REPLACE([Stock in transfer],'-','') else  [Stock in transfer] end,',','') as int),
			[In Quality Insp.] = cast(replace(case when right([In Quality Insp.],1)='-' then '-'+REPLACE([In Quality Insp.],'-','') else  [In Quality Insp.] end,',','') as int),
			[Restricted-Use Stock] = cast(replace(case when right([Restricted-Use Stock],1)='-' then '-'+REPLACE([Restricted-Use Stock],'-','') else  [Restricted-Use Stock] end,',','') as int),
			Blocked = cast(replace(case when right(Blocked,1)='-' then '-'+REPLACE(Blocked,'-','') else  Blocked end,',','') as int),
			[Returns] = cast(replace(case when right([Returns],1)='-' then '-'+REPLACE([Returns],'-','') else  [Returns] end,',','') as int)
		from SC1.dbo.STOCK_ZMB52 z (NOLOCK)
		left join (select distinct [Product Type],[SUB GROUP/ Brand],Material from fnc_SubGroupMaster('full')) s on s.Material = z.Material
		left join SC1.dbo.MM_ZMR54OLD m (NOLOCK) on m.Material = z.Material
		left join FC_MasterFile_CPD_Customer_Master c(NOLOCK) on right('0000000000'+c.[Node 5],10) = right('0000000000'+isnull(z.Customer,''),10)
		--where 
	) as x
	group by
		SubGrp,
		Material
)
select * from cte1 where ISNULL(SubGrp,'')<>''
