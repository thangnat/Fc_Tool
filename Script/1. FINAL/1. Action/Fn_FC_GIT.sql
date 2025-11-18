/*
	select * from Fn_FC_GIT('LLD','202408') order by [SUB GROUP/ Brand] asc
*/
Alter Function Fn_FC_GIT
(
	@division as nvarchar(3),
	@FM_KEY	as nvarchar(6)
)
returns @tmpFinal TABLE 
(
	id				int identity(1,1), 
	[Product Type]	nvarchar(10),
	[Sales Org]		nvarchar(4),
	[SUB GROUP/ Brand]		nvarchar(100),
	Channel			nvarchar(7),
	[GIT M0]		int,
	[GIT M1]		Int,
	[GIT M2]		int,
	[GIT M3]		int
)
with encryption
As
Begin
	declare @CurrentMonth	int = 0
	--select @CurrentMonth = left(

	declare @full nvarchar(4) = ''
	select @full = case when [Only run active]=1 then '' else '' end from v_FC_SUBGROUP_ACTIVE
	--select @full '@full'
	declare @tmp TABLE 
	(
		id				int identity(1,1), 
		[Month]			Int
	)
	declare @tmp1 TABLE 
	(
		id				int identity(1,1), 
		[Month_Desc]	nvarchar(2),
		[Month]			Int
	)
	declare @start_month int = 0
	SELECT @start_month = cast(right(@FM_KEY,2) as int)
	declare @Total_Month int = 0
	SELECT @Total_Month=@start_month+4-1
	--SELECT @start_month '@start_month',@Total_Month '@Total_Month'

	while (@start_month<=@Total_Month)
	begin
		insert into @tmp
		(
			[Month]
		)
		select @start_month

		select @start_month=@start_month+1
		--SELECT @start_month '@start_month'
	end

	insert into @tmp1
	(
		[Month_Desc],
		[Month]
	)
	select
		[Month_Desc] = 'M'+cast((id -1) as nvarchar(2)),
		[Month] = t.[Month]
	from @tmp t

	insert into @tmpFinal
	(
		[Product Type],
		[Sales Org],
		[SUB GROUP/ Brand],
		Channel,
		[GIT M0],
		[GIT M1],
		[GIT M2],
		[GIT M3]
	)
	select
		*
	from
	(
		select
			[Product Type],
			[Sales Org],
			[SUB GROUP/ Brand] = x.[SUB GROUP/ Brand],
			Channel = 'OFFLINE',
			[GIT M0] = sum(case t.[Month_Desc] when 'M0' then TotalQty else 0 end),
			[GIT M1] = sum(case t.[Month_Desc] when 'M1' then TotalQty else 0 end),
			[GIT M2] = sum(case t.[Month_Desc] when 'M2' then TotalQty else 0 end),
			[GIT M3] = sum(case t.[Month_Desc] when 'M3' then TotalQty else 0 end)
		from @tmp1 t
		left join
		(
			select
				[Product Type],
				[Sales Org],
				[SUB GROUP/ Brand],
				[Month],
				[TotalQty] = sum(isnull([TotalQty],0))
			from
			(
				select
					[Product Type] = s.[Product Type],
					[Sales Org] = s.[Sales Org],
					[SUB GROUP/ Brand] = s.[SUB GROUP/ Brand],				
					[Month] = Month(cast([Deliv# date(From/to)] as date)),
					[TotalQty] = [Delivery quantity]
				from FC_GIT_CPD g (NOLOCK)
				inner join 
				(
					select DISTINCT
						Material,
						Barcode = [EAN / UPC]
					from SC1.dbo.MM_ZMR54OLD_Stg (NOLOCK)
				) m on m.Material = g.Material
				inner join 
				(
					select DISTINCT 
						[Product Type],[Type],Barcode,[Sales Org],[SUB GROUP/ Brand] 
					from fnc_SubGroupMaster(@division,@full)
				) s on s.Barcode = m.Barcode
				where Month(cast([Deliv# date(From/to)] as date))>=cast(right(@FM_KEY,2) as int)
				--and m.Material = 'G0749604'
				union All
				select
					[Product Type] = s.[Product Type],
					[Sales Org] = s.[Sales Org],
					[SUB GROUP/ Brand] = s.[SUB GROUP/ Brand],				
					[Month] = month(cast((left(@FM_KEY,4)+'-'+right(@FM_KEY,2)+'-01') as date)),
					[TotalQty] = [Delivery quantity]
				from FC_GIT_CPD g (NOLOCK)
				inner join 
				(
					select DISTINCT
						Material,
						Barcode = [EAN / UPC]
					from SC1.dbo.MM_ZMR54OLD_stg (NOLOCK)
				) m on m.Material = g.Material
				inner join 
				(
					select DISTINCT 
						[Product Type],[Type],Barcode,[Sales Org],[SUB GROUP/ Brand] 
					from fnc_SubGroupMaster(@division,@full)
				) s on s.Barcode = m.Barcode
				where Month(cast([Deliv# date(From/to)] as date))<cast(right(@FM_KEY,2) as int)
				--and m.Material='G0749604'
				--//LDB----------------------------------------------------------------------------
				union all
				select
					[Product Type] = s.[Product Type],
					[Sales Org] = s.[Sales Org],
					[SUB GROUP/ Brand] = s.[SUB GROUP/ Brand],				
					[Month] = Month(cast([Deliv# date(From/to)] as date)),
					[TotalQty] = [Delivery quantity]
				from FC_GIT_LDB g (NOLOCK)
				inner join 
				(
					select DISTINCT
						Material,
						Barcode = [EAN / UPC]
					from SC1.dbo.MM_ZMR54OLD_Stg (NOLOCK)
				) m on m.Material = g.Material
				inner join 
				(
					select DISTINCT 
						[Product Type],[Type],Barcode,[Sales Org],[SUB GROUP/ Brand] 
					from fnc_SubGroupMaster(@division,@full)
				) s on s.Barcode = m.Barcode
				where Month(cast([Deliv# date(From/to)] as date))>=cast(right(@FM_KEY,2) as int)
				--and m.Material = 'G0749604'
				union All
				select
					[Product Type] = s.[Product Type],
					[Sales Org] = s.[Sales Org],
					[SUB GROUP/ Brand] = s.[SUB GROUP/ Brand],				
					[Month] = month(cast((left(@FM_KEY,4)+'-'+right(@FM_KEY,2)+'-01') as date)),
					[TotalQty] = [Delivery quantity]
				from FC_GIT_LDB g (NOLOCK)
				inner join 
				(
					select DISTINCT
						Material,
						Barcode = [EAN / UPC]
					from SC1.dbo.MM_ZMR54OLD_stg (NOLOCK)
				) m on m.Material = g.Material
				inner join 
				(
					select DISTINCT 
						[Product Type],[Type],Barcode,[Sales Org],[SUB GROUP/ Brand] 
					from fnc_SubGroupMaster(@division,@full)
				) s on s.Barcode = m.Barcode
				where Month(cast([Deliv# date(From/to)] as date))<cast(right(@FM_KEY,2) as int)
				--and m.Material='G0749604'
			) as x1
			group by
				[Product Type],
				[Sales Org],
				[SUB GROUP/ Brand],
				[Month]
		) as x on x.[Month] = t.[Month]
		group by
			x.[Product Type],
			x.[Sales Org],
			x.[SUB GROUP/ Brand]
		union all
		--//LLD
		SELECT
			[Product Type],
			[Sales Org],
			[SUB GROUP/ Brand],
			Channel,
			[GIT M0] = SUM(ISNULL([GIT M0],0)),
			[GIT M1] = SUM(ISNULL([GIT M1],0)),
			[GIT M2] = SUM(ISNULL([GIT M2],0)),
			[GIT M3] = SUM(ISNULL([GIT M3],0))
		FROM
		(
			select
				[Product Type] = s.[Product Type],
				[Sales Org] = s.[Sales Org],
				[SUB GROUP/ Brand] = s.[SUB GROUP/ Brand],
				Channel = 'OFFLINE',			
				[GIT M0] = CAST(isnull(REPLACE([M0],',',''),0) AS INT),
				[GIT M1] = CASt(isnull(REPLACE([M1],',',''),0) AS INT),
				[GIT M2] = CAST(isnull(REPLACE([M2],',',''),0) AS INT),
				[GIT M3] = CAST(isnull(REPLACE([M3],',',''),0) AS INT)
			from FC_GIT_LLD g
			inner join 
			(
				select DISTINCT
					Material,
					Barcode = [EAN / UPC]
				from SC1.dbo.MM_ZMR54OLD (NOLOCK)
			) m on m.Material = g.[SAP Code]
			inner join 
			(
				select DISTINCT 
					[Product Type],[Type],Barcode,[Sales Org],[SUB GROUP/ Brand] 
				from fnc_SubGroupMaster(@division,@full)
			) s on s.Barcode = M.Barcode
		) AS Y
		GROUP BY
			[Product Type],
			[Sales Org],
			[SUB GROUP/ Brand],
			Channel
	) as w
	where isnull(w.[SUB GROUP/ Brand],'')<>''
	Return
end
