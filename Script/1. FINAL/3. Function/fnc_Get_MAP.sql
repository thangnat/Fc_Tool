/*
	select * from fnc_Get_MAP('cpd') WHERE [SUB GROUP/ Brand]='AGE REWIND CONCEALER'
*/

Alter function fnc_Get_MAP
(
	@Division nvarchar(3)
)
returns @tableFinal table
(
	[SUB GROUP/ Brand]	nvarchar(500) null,
	[AVERAGE]			numeric(18,0) default 0
)
with encryption
As
begin
	declare @saleorg nvarchar(4)=''
	select @saleorg=case 
						when @Division='LLD' then 'V100'
						when @Division='CPD' then 'V200'
						when @Division='PPD' then 'V300'
						when @Division='LDB' then 'V400'
						else ''
					end
	
	insert into @tableFinal([SUB GROUP/ Brand],[AVERAGE])
	select
		[SUB GROUP/ Brand],
		[AVERAGE]=cast(sum([MAP])/count([SUB GROUP/ Brand]) as numeric(18,0))
	from
	(
		select
			[SUB GROUP/ Brand]=s.[SUB GROUP/ Brand],
			[Barcode]=m.[EAN / UPC],
			[Material]=m.Material,
			[MAP]=sum(cast(MAP as numeric(18,0)))
		from
		(
			select distinct
				[SUB GROUP/ Brand],
				[Barcode],
				[Material]
			from fnc_SubGroupMaster(@Division,'full')
		) s
		left join SC1.dbo.MM_ZMR54OLD_Stg m on s.Material=m.Material
		where 
			[Sales  Org]=@saleorg
		and cast([MAP] as numeric)>0
		and ISNULL(s.[SUB GROUP/ Brand],'')<>''
		group by
			s.[SUB GROUP/ Brand],
			m.[EAN / UPC],
			m.[Material]
	) as x
	group by
		[SUB GROUP/ Brand]

	return
end