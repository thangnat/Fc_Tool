/*
	select * from fnc_SubGroupMasterFull('LDB','202409','full')
	where [SUB GROUP/ Brand]='SKN COR TRIPLE LIPID 48ML EU'
*/
Alter function fnc_SubGroupMasterFull
(
	@Division	Nvarchar(3),
	@FM_KEY		nvarchar(6),
	@Type		nvarchar(4)
)
returns TABLE
with encryption
As
	return
	SELECT	
		[Division] = 'CPD',
		[Sales Org] = 'V200',
		[Barcode] = [EAN (VALUE)],
		[Material] = isnull(s.Material,''),
		[Bundle name] = m.[Material Description (Eng)],
		[Material Type] = s1.[Material Type],
		[Ref. Code] ='',
		[SUB GROUP/ Brand] = [Sub-group FC],
		[CAT/Axe] = s1.[CAT/Axe],
		[SUB CAT/ Sub Axe] = s1.[SUB CAT/ Sub Axe],
		[GROUP/ Class] = s1.[GROUP/ Class],
		[HERO] =s1.HERO,
		[Product status] = s1.[Product status],
		[Signature] = s1.[Signature],
		[Type] = s1.[Material Type],
		[Product Type] = s1.[Material Type],
		[Dchain] = s1.[Dchain Specs Status],
		[Item Category Group] = m.[Item Category Group],
		[Active] = isnull(s.Active,0),
		--//lAST YEAR - 2---------------------------------------
		[Y-2 (u) M1] = cast(replace(replace([LY-2_ RSP_Jan],',',''),'-','0') as numeric(18,0)),
		[Y-2 (u) M2] = cast(replace(replace([LY-2_ RSP_Feb],',',''),'-','0') as numeric(18,0)),
		[Y-2 (u) M3] = cast(replace(replace([LY-2_ RSP_Mar],',',''),'-','0') as numeric(18,0)),
		[Y-2 (u) M4] = cast(replace(replace([LY-2_ RSP_Apr],',',''),'-','0') as numeric(18,0)),
		[Y-2 (u) M5] = cast(replace(replace([LY-2_ RSP_May],',',''),'-','0') as numeric(18,0)),
		[Y-2 (u) M6] = cast(replace(replace([LY-2_ RSP_Jun],',',''),'-','0') as numeric(18,0)),
		[Y-2 (u) M7] = cast(replace(replace([LY-2_ RSP_Jul],',',''),'-','0') as numeric(18,0)),
		[Y-2 (u) M8] = cast(replace(replace([LY-2_ RSP_Aug],',',''),'-','0') as numeric(18,0)),
		[Y-2 (u) M9] = cast(replace(replace([LY-2_ RSP_Sep],',',''),'-','0') as numeric(18,0)),
		[Y-2 (u) M10] = cast(replace(replace([LY-2_ RSP_Oct],',',''),'-','0') as numeric(18,0)),
		[Y-2 (u) M11] = cast(replace(replace([LY-2_ RSP_Nov],',',''),'-','0') as numeric(18,0)),
		[Y-2 (u) M12] = cast(replace(replace([LY-2_ RSP_Dec],',',''),'-','0') as numeric(18,0)),
		--//LAST YEAR - 1---------------------------------------
		[Y-1 (u) M1] = cast(replace(replace([LY-1_ RSP_Jan],',',''),'-','0') as numeric(18,0)),
		[Y-1 (u) M2] = cast(replace(replace([LY-1_ RSP_Feb],',',''),'-','0') as numeric(18,0)),
		[Y-1 (u) M3] = cast(replace(replace([LY-1_ RSP_Mar],',',''),'-','0') as numeric(18,0)),
		[Y-1 (u) M4] = cast(replace(replace([LY-1_ RSP_Apr],',',''),'-','0') as numeric(18,0)),
		[Y-1 (u) M5] = cast(replace(replace([LY-1_ RSP_May],',',''),'-','0') as numeric(18,0)),
		[Y-1 (u) M6] = cast(replace(replace([LY-1_ RSP_Jun],',',''),'-','0') as numeric(18,0)),
		[Y-1 (u) M7] = cast(replace(replace([LY-1_ RSP_Jul],',',''),'-','0') as numeric(18,0)),
		[Y-1 (u) M8] = cast(replace(replace([LY-1_ RSP_Aug],',',''),'-','0') as numeric(18,0)),
		[Y-1 (u) M9] = cast(replace(replace([LY-1_ RSP_Sep],',',''),'-','0') as numeric(18,0)),
		[Y-1 (u) M10] = cast(replace(replace([LY-1_ RSP_Oct],',',''),'-','0') as numeric(18,0)),
		[Y-1 (u) M11] = cast(replace(replace([LY-1_ RSP_Nov],',',''),'-','0') as numeric(18,0)),
		[Y-1 (u) M12] = cast(replace(replace([LY-1_ RSP_Dec],',',''),'-','0') as numeric(18,0)),
		--/-------------------------------
		[Y0 (u) M1] = cast(replace(replace([CY_ RSP_Jan],',',''),'-','0') as numeric(18,0)),
		[Y0 (u) M2] = cast(replace(replace([CY_ RSP_Feb],',',''),'-','0') as numeric(18,0)),
		[Y0 (u) M3] = cast(replace(replace([CY_ RSP_Mar],',',''),'-','0') as numeric(18,0)),
		[Y0 (u) M4] = cast(replace(replace([CY_ RSP_Apr],',',''),'-','0') as numeric(18,0)),
		[Y0 (u) M5] = cast(replace(replace([CY_ RSP_May],',',''),'-','0') as numeric(18,0)),
		[Y0 (u) M6] = cast(replace(replace([CY_ RSP_Jun],',',''),'-','0') as numeric(18,0)),
		[Y0 (u) M7] = cast(replace(replace([CY_ RSP_Jul],',',''),'-','0') as numeric(18,0)),
		[Y0 (u) M8] = cast(replace(replace([CY_ RSP_Aug],',',''),'-','0') as numeric(18,0)),
		[Y0 (u) M9] = cast(replace(replace([CY_ RSP_Sep],',',''),'-','0') as numeric(18,0)),
		[Y0 (u) M10] = cast(replace(replace([CY_ RSP_Oct],',',''),'-','0') as numeric(18,0)),
		[Y0 (u) M11] = cast(replace(replace([CY_ RSP_Nov],',',''),'-','0') as numeric(18,0)),
		[Y0 (u) M12] = cast(replace(replace([CY_ RSP_Dec],',',''),'-','0') as numeric(18,0)),
		--//-----------------------------------
		[Y+1 (u) M1] = cast(replace(replace([NY__ RSP_Jan],',',''),'-','0') as numeric(18,0)),
		[Y+1 (u) M2] = cast(replace(replace([NY__ RSP_Feb],',',''),'-','0') as numeric(18,0)),
		[Y+1 (u) M3] = cast(replace(replace([NY__ RSP_Mar],',',''),'-','0') as numeric(18,0)),
		[Y+1 (u) M4] = cast(replace(replace([NY__ RSP_Apr],',',''),'-','0') as numeric(18,0)),
		[Y+1 (u) M5] = cast(replace(replace([NY__ RSP_May],',',''),'-','0') as numeric(18,0)),
		[Y+1 (u) M6] = cast(replace(replace([NY__ RSP_Jun],',',''),'-','0') as numeric(18,0)),
		[Y+1 (u) M7] = cast(replace(replace([NY__ RSP_Jul],',',''),'-','0') as numeric(18,0)),
		[Y+1 (u) M8] = cast(replace(replace([NY__ RSP_Aug],',',''),'-','0') as numeric(18,0)),
		[Y+1 (u) M9] = cast(replace(replace([NY__ RSP_Sep],',',''),'-','0') as numeric(18,0)),
		[Y+1 (u) M10] = cast(replace(replace([NY__ RSP_Oct],',',''),'-','0') as numeric(18,0)),
		[Y+1 (u) M11] = cast(replace(replace([NY__ RSP_Nov],',',''),'-','0') as numeric(18,0)),
		[Y+1 (u) M12] = cast(replace(replace([NY__ RSP_Dec],',',''),'-','0') as numeric(18,0))
		--//budget Y0-----------------------------------
		,[B_Y0_M1] = cast(replace(replace(isnull(bd0.[M1 RSP],0),',',''),'-','0') as numeric(18,0)),
		[B_Y0_M2] = cast(replace(replace(isnull(bd0.[M2 RSP],0),',',''),'-','0') as numeric(18,0)),
		[B_Y0_M3] = cast(replace(replace(isnull(bd0.[M3 RSP],0),',',''),'-','0') as numeric(18,0)),
		[B_Y0_M4] = cast(replace(replace(isnull(bd0.[M4 RSP],0),',',''),'-','0') as numeric(18,0)),
		[B_Y0_M5] = cast(replace(replace(isnull(bd0.[M5 RSP],0),',',''),'-','0') as numeric(18,0)),
		[B_Y0_M6] = cast(replace(replace(isnull(bd0.[M6 RSP],0),',',''),'-','0') as numeric(18,0)),
		[B_Y0_M7] = cast(replace(replace(isnull(bd0.[M7 RSP],0),',',''),'-','0') as numeric(18,0)),
		[B_Y0_M8] = cast(replace(replace(isnull(bd0.[M8 RSP],0),',',''),'-','0') as numeric(18,0)),
		[B_Y0_M9] = cast(replace(replace(isnull(bd0.[M9 RSP],0),',',''),'-','0') as numeric(18,0)),
		[B_Y0_M10] = cast(replace(replace(isnull(bd0.[M10 RSP],0),',',''),'-','0') as numeric(18,0)),
		[B_Y0_M11] = cast(replace(replace(isnull(bd0.[M11 RSP],0),',',''),'-','0') as numeric(18,0)),
		[B_Y0_M12] = cast(replace(replace(isnull(bd0.[M12 RSP],0),',',''),'-','0') as numeric(18,0)),
		--//budget Y+1-----------------------------------
		[B_Y+1_M1] = cast(replace(replace(isnull(bd1.[M1 RSP],0),',',''),'-','0') as numeric(18,0)),
		[B_Y+1_M2] = cast(replace(replace(isnull(bd1.[M2 RSP],0),',',''),'-','0') as numeric(18,0)),
		[B_Y+1_M3] = cast(replace(replace(isnull(bd1.[M3 RSP],0),',',''),'-','0') as numeric(18,0)),
		[B_Y+1_M4] = cast(replace(replace(isnull(bd1.[M4 RSP],0),',',''),'-','0') as numeric(18,0)),
		[B_Y+1_M5] = cast(replace(replace(isnull(bd1.[M5 RSP],0),',',''),'-','0') as numeric(18,0)),
		[B_Y+1_M6] = cast(replace(replace(isnull(bd1.[M6 RSP],0),',',''),'-','0') as numeric(18,0)),
		[B_Y+1_M7] = cast(replace(replace(isnull(bd1.[M7 RSP],0),',',''),'-','0') as numeric(18,0)),
		[B_Y+1_M8] = cast(replace(replace(isnull(bd1.[M8 RSP],0),',',''),'-','0') as numeric(18,0)),
		[B_Y+1_M9] = cast(replace(replace(isnull(bd1.[M9 RSP],0),',',''),'-','0') as numeric(18,0)),
		[B_Y+1_M10] = cast(replace(replace(isnull(bd1.[M10 RSP],0),',',''),'-','0') as numeric(18,0)),
		[B_Y+1_M11] = cast(replace(replace(isnull(bd1.[M11 RSP],0),',',''),'-','0') as numeric(18,0)),
		[B_Y+1_M12] = cast(replace(replace(isnull(bd1.[M12 RSP],0),',',''),'-','0') as numeric(18,0)),
		--//Pre-budget Y+1-----------------------------------
		[PB_Y+1_M1] = cast(replace(replace(isnull(pbd.[M1 RSP],0),',',''),'-','0') as numeric(18,0)),
		[PB_Y+1_M2] = cast(replace(replace(isnull(pbd.[M2 RSP],0),',',''),'-','0') as numeric(18,0)),
		[PB_Y+1_M3] = cast(replace(replace(isnull(pbd.[M3 RSP],0),',',''),'-','0') as numeric(18,0)),
		[PB_Y+1_M4] = cast(replace(replace(isnull(pbd.[M4 RSP],0),',',''),'-','0') as numeric(18,0)),
		[PB_Y+1_M5] = cast(replace(replace(isnull(pbd.[M5 RSP],0),',',''),'-','0') as numeric(18,0)),
		[PB_Y+1_M6] = cast(replace(replace(isnull(pbd.[M6 RSP],0),',',''),'-','0') as numeric(18,0)),
		[PB_Y+1_M7] = cast(replace(replace(isnull(pbd.[M7 RSP],0),',',''),'-','0') as numeric(18,0)),
		[PB_Y+1_M8] = cast(replace(replace(isnull(pbd.[M8 RSP],0),',',''),'-','0') as numeric(18,0)),
		[PB_Y+1_M9] = cast(replace(replace(isnull(pbd.[M9 RSP],0),',',''),'-','0') as numeric(18,0)),
		[PB_Y+1_M10] = cast(replace(replace(isnull(pbd.[M10 RSP],0),',',''),'-','0') as numeric(18,0)),
		[PB_Y+1_M11] = cast(replace(replace(isnull(pbd.[M11 RSP],0),',',''),'-','0') as numeric(18,0)),
		[PB_Y+1_M12] = cast(replace(replace(isnull(pbd.[M12 RSP],0),',',''),'-','0') as numeric(18,0)),
		----//Tren 3 Y0-----------------------------------
		[T1_Y0_M1] = cast(replace(replace(isnull(trd1.[M1 RSP],0),',',''),'-','0') as numeric(18,0)),
		[T1_Y0_M2] = cast(replace(replace(isnull(trd1.[M2 RSP],0),',',''),'-','0') as numeric(18,0)),
		[T1_Y0_M3] = cast(replace(replace(isnull(trd1.[M3 RSP],0),',',''),'-','0') as numeric(18,0)),
		[T1_Y0_M4] = cast(replace(replace(isnull(trd1.[M4 RSP],0),',',''),'-','0') as numeric(18,0)),
		[T1_Y0_M5] = cast(replace(replace(isnull(trd1.[M5 RSP],0),',',''),'-','0') as numeric(18,0)),
		[T1_Y0_M6] = cast(replace(replace(isnull(trd1.[M6 RSP],0),',',''),'-','0') as numeric(18,0)),
		[T1_Y0_M7] = cast(replace(replace(isnull(trd1.[M7 RSP],0),',',''),'-','0') as numeric(18,0)),
		[T1_Y0_M8] = cast(replace(replace(isnull(trd1.[M8 RSP],0),',',''),'-','0') as numeric(18,0)),
		[T1_Y0_M9] = cast(replace(replace(isnull(trd1.[M9 RSP],0),',',''),'-','0') as numeric(18,0)),
		[T1_Y0_M10] = cast(replace(replace(isnull(trd1.[M10 RSP],0),',',''),'-','0') as numeric(18,0)),
		[T1_Y0_M11] = cast(replace(replace(isnull(trd1.[M11 RSP],0),',',''),'-','0') as numeric(18,0)),
		[T1_Y0_M12] = cast(replace(replace(isnull(trd1.[M12 RSP],0),',',''),'-','0') as numeric(18,0)),
		----//Tren 5 Y0-----------------------------------
		[T2_Y0_M1] = cast(replace(replace(isnull(trd2.[M1 RSP],0),',',''),'-','0') as numeric(18,0)),
		[T2_Y0_M2] = cast(replace(replace(isnull(trd2.[M2 RSP],0),',',''),'-','0') as numeric(18,0)),
		[T2_Y0_M3] = cast(replace(replace(isnull(trd2.[M3 RSP],0),',',''),'-','0') as numeric(18,0)),
		[T2_Y0_M4] = cast(replace(replace(isnull(trd2.[M4 RSP],0),',',''),'-','0') as numeric(18,0)),
		[T2_Y0_M5] = cast(replace(replace(isnull(trd2.[M5 RSP],0),',',''),'-','0') as numeric(18,0)),
		[T2_Y0_M6] = cast(replace(replace(isnull(trd2.[M6 RSP],0),',',''),'-','0') as numeric(18,0)),
		[T2_Y0_M7] = cast(replace(replace(isnull(trd2.[M7 RSP],0),',',''),'-','0') as numeric(18,0)),
		[T2_Y0_M8] = cast(replace(replace(isnull(trd2.[M8 RSP],0),',',''),'-','0') as numeric(18,0)),
		[T2_Y0_M9] = cast(replace(replace(isnull(trd2.[M9 RSP],0),',',''),'-','0') as numeric(18,0)),
		[T2_Y0_M10] = cast(replace(replace(isnull(trd2.[M10 RSP],0),',',''),'-','0') as numeric(18,0)),
		[T2_Y0_M11] = cast(replace(replace(isnull(trd2.[M11 RSP],0),',',''),'-','0') as numeric(18,0)),
		[T2_Y0_M12] = cast(replace(replace(isnull(trd2.[M12 RSP],0),',',''),'-','0') as numeric(18,0)),
		----//Tren 7 Y0-----------------------------------
		[T3_Y0_M1] = cast(replace(replace(isnull(trd3.[M1 RSP],0),',',''),'-','0') as numeric(18,0)),
		[T3_Y0_M2] = cast(replace(replace(isnull(trd3.[M2 RSP],0),',',''),'-','0') as numeric(18,0)),
		[T3_Y0_M3] = cast(replace(replace(isnull(trd3.[M3 RSP],0),',',''),'-','0') as numeric(18,0)),
		[T3_Y0_M4] = cast(replace(replace(isnull(trd3.[M4 RSP],0),',',''),'-','0') as numeric(18,0)),
		[T3_Y0_M5] = cast(replace(replace(isnull(trd3.[M5 RSP],0),',',''),'-','0') as numeric(18,0)),
		[T3_Y0_M6] = cast(replace(replace(isnull(trd3.[M6 RSP],0),',',''),'-','0') as numeric(18,0)),
		[T3_Y0_M7] = cast(replace(replace(isnull(trd3.[M7 RSP],0),',',''),'-','0') as numeric(18,0)),
		[T3_Y0_M8] = cast(replace(replace(isnull(trd3.[M8 RSP],0),',',''),'-','0') as numeric(18,0)),
		[T3_Y0_M9] = cast(replace(replace(isnull(trd3.[M9 RSP],0),',',''),'-','0') as numeric(18,0)),
		[T3_Y0_M10] = cast(replace(replace(isnull(trd3.[M10 RSP],0),',',''),'-','0') as numeric(18,0)),
		[T3_Y0_M11] = cast(replace(replace(isnull(trd3.[M11 RSP],0),',',''),'-','0') as numeric(18,0)),
		[T3_Y0_M12] = cast(replace(replace(isnull(trd3.[M12 RSP],0),',',''),'-','0') as numeric(18,0))
	FROM 
	(
		select distinct 
			Division = 'CPD',
			*
			--[Active] = cast([Active] as int)
		from FC_BFL_Master_CPD (NOLOCK) 
		WHERE [Bundle/Single] <>'VIRTUAL BUNDLE'
		--and Material='DUM_PP209037'
		--and cast([Active] as int)>0
	) s
	inner join 
	(
		select distinct 
			Division = 'CPD',
			[Sales  Org],
			[Item Category Group],
			[EAN / UPC],
			[Material Description (Eng)],
			[Material Type],
			Material
		from SC1.dbo.MM_ZMR54OLD_Stg (NOLOCK)
		where [Sales  Org] =  'V200'
		union all
		select distinct 
			Division = 'CPD',
			[Sales  Org]='V200',
			[Item Category Group]='NORM',
			[EAN / UPC]=isnull([EAN (VALUE)],''),
			[Material Description (Eng)]=isnull([Material Description (Eng)],''),
			[Material Type]=isnull([Material Type],''),
			Material
		from FC_BFL_Master_CPD (NOLOCK)
		where left(Material,3)='DUM'
	) m on m.[EAN / UPC] = s.[EAN (VALUE)] and s.Material = m.Material and m.Division = s.Division
	left join
	(
		select 
			Division = 'CPD',
			* 
		from V_FC_MMDOWNLOAD_SORTBY_CPD
	) s1 on s1.[SUB GROUP/ Brand] = s.[Sub-group FC] and s1.Division = s.Division
	left join
	(
		select * from fnc_FC_BUDGET_TREND_RSP(@Division,@FM_KEY,'B') where [Type]='B0'
		--SELECT
		--	*
		--FROM
		--(
		--	select 
		--		STT = ROW_NUMBER() over(partition by [SUB-GROUP] order by [SUB-GROUP] asc),
		--		*
		--	from FC_Budget_CPD
		--	where Type='B0'
		--) as x
		--where STT=1
	) bd0 on bd0.[SUB GROUP/ Brand]=s.[Sub-group FC]
	left join
	(
		select * from fnc_FC_BUDGET_TREND_RSP(@Division,@FM_KEY,'B') where [Type]='B1'
		--SELECT
		--	*
		--FROM
		--(
		--	select 
		--		STT = ROW_NUMBER() over(partition by [SUB-GROUP] order by [SUB-GROUP] asc),
		--		*
		--	from FC_Budget_CPD
		--	where Type='B1'
		--) as x
		--where STT=1
	) bd1 on bd1.[SUB GROUP/ Brand]=s.[Sub-group FC]
	left join
	(
		select * from fnc_FC_BUDGET_TREND_RSP(@Division,@FM_KEY,'PB') where [Type]='PB1'
		--SELECT
		--	*
		--FROM
		--(
		--	select 
		--		STT = ROW_NUMBER() over(partition by [SUB-GROUP] order by [SUB-GROUP] asc),
		--		*
		--	from FC_Pre_Budget_CPD
		--) as x
		--where STT=1
	) pbd on pbd.[SUB GROUP/ Brand]=s.[Sub-group FC]
	left join
	(
		select * from fnc_FC_BUDGET_TREND_RSP(@Division,@FM_KEY,'T') where [Type]='T1'
		--SELECT
		--	*
		--FROM
		--(
		--	select 
		--		STT = ROW_NUMBER() over(partition by [SUB-GROUP] order by [SUB-GROUP] asc),
		--		*
		--	from FC_Trend_RSP_CPD
		--	where
		--		FM_KEY=@FM_KEY
		--	and [Type]='T1'
		--	and ISNULL([Version],'')<>''
		--) as x
		--where STT=1
	) trd1 on trd1.[SUB GROUP/ Brand]=s.[Sub-group FC]
	left join
	(
		select * from fnc_FC_BUDGET_TREND_RSP(@Division,@FM_KEY,'T') where [Type]='T2'
		--SELECT
		--	*
		--FROM
		--(
		--	select 
		--		STT = ROW_NUMBER() over(partition by [SUB-GROUP] order by [SUB-GROUP] asc),
		--		*
		--	from FC_Trend_RSP_CPD
		--	where Type='T2'
		--) as x
		--where STT=1
	) trd2 on trd2.[SUB GROUP/ Brand]=s.[Sub-group FC]-- and trd2.CHANNEL=s.chan
	left join
	(
		select * from fnc_FC_BUDGET_TREND_RSP(@Division,@FM_KEY,'T') where [Type]='T3'
		--SELECT
		--	*
		--FROM
		--(
		--	select 
		--		STT = ROW_NUMBER() over(partition by [SUB-GROUP] order by [SUB-GROUP] asc),
		--		*
		--	from FC_Trend_CPD
		--	where Type='T3'
		--) as x
		--where STT=1
	) trd3 on trd3.[SUB GROUP/ Brand]=s.[Sub-group FC]
	where 
		m.[Sales  Org] =  'V200'
	and
	(
		isnull(s.Active,0) = 1 or LEN(@Type)>0
	)
	and s.Division = @Division
	--//LLD
	UNION ALL
	SELECT	
		[Division] = 'LLD',
		[Sales Org] = 'V100',
		[Barcode] = S.[EAN code],
		[Material] = isnull(S.[SKU Code],''),
		[Bundle name] = isnull([SKU Name],''),
		[Material Type] = m.[Material Type],				
		[Ref. Code] = s1.[BFL Code],
		[SUB GROUP/ Brand] = s.[BFL Name],
		[CAT/Axe] = s1.[Axe],
		[SUB CAT/ Sub Axe] = s1.[SUB CAT/ Sub Axe],
		[GROUP/ Class] = s1.[Sub Brand],
		[HERO] = s1.[Hero],
		[Product status] = s1.[Product status],
		[Signature] = s1.[Signature],
		[Type] = isnull(m.[Material Type],''),
		[Product Type] = isnull(m.[Material Type],''),
		[Dchain]= m.[Dchain Specs Status],
		[Item Category Group] = m.[Item Category Group],
		Active = isnull(s.Active,0),
		--//lAST YEAR - 2---------------------------------------
		[Y-2 (u) M1] = cast(isnull([Y0 (u) M1],1) as numeric(18,0)),
		[Y-2 (u) M2] = cast(isnull([Y0 (u) M1],1) as numeric(18,0)),
		[Y-2 (u) M3] = cast(isnull([Y0 (u) M1],1) as numeric(18,0)),
		[Y-2 (u) M4] = cast(isnull([Y0 (u) M1],1) as numeric(18,0)),
		[Y-2 (u) M5] = cast(isnull([Y0 (u) M1],1) as numeric(18,0)),
		[Y-2 (u) M6] = cast(isnull([Y0 (u) M1],1) as numeric(18,0)),
		[Y-2 (u) M7] = cast(isnull([Y0 (u) M1],1) as numeric(18,0)),
		[Y-2 (u) M8] = cast(isnull([Y0 (u) M1],1) as numeric(18,0)),
		[Y-2 (u) M9] = cast(isnull([Y0 (u) M1],1) as numeric(18,0)),
		[Y-2 (u) M10] = cast(isnull([Y0 (u) M1],1) as numeric(18,0)),
		[Y-2 (u) M11] = cast(isnull([Y0 (u) M1],1) as numeric(18,0)),
		[Y-2 (u) M12] = cast(isnull([Y0 (u) M1],1) as numeric(18,0)),
		--//LAST YEAR - 1---------------------------------------
		[Y-1 (u) M1] = cast(isnull([Y0 (u) M1],1) as numeric(18,0)),
		[Y-1 (u) M2] = cast(isnull([Y0 (u) M1],1) as numeric(18,0)),
		[Y-1 (u) M3] = cast(isnull([Y0 (u) M1],1) as numeric(18,0)),
		[Y-1 (u) M4] = cast(isnull([Y0 (u) M1],1) as numeric(18,0)),
		[Y-1 (u) M5] = cast(isnull([Y0 (u) M1],1) as numeric(18,0)),
		[Y-1 (u) M6] = cast(isnull([Y0 (u) M1],1) as numeric(18,0)),
		[Y-1 (u) M7] = cast(isnull([Y0 (u) M1],1) as numeric(18,0)),
		[Y-1 (u) M8] = cast(isnull([Y0 (u) M1],1) as numeric(18,0)),
		[Y-1 (u) M9] = cast(isnull([Y0 (u) M1],1) as numeric(18,0)),
		[Y-1 (u) M10] = cast(isnull([Y0 (u) M1],1) as numeric(18,0)),
		[Y-1 (u) M11] = cast(isnull([Y0 (u) M1],1) as numeric(18,0)),
		[Y-1 (u) M12] = cast(isnull([Y0 (u) M1],1) as numeric(18,0)),
		--/-------------------------------
		[Y0 (u) M1] = isnull([Y0 (u) M1],1),
		[Y0 (u) M2] = isnull([Y0 (u) M2],1),
		[Y0 (u) M3] = isnull([Y0 (u) M3],1),
		[Y0 (u) M4] = isnull([Y0 (u) M4],1),
		[Y0 (u) M5] = isnull([Y0 (u) M5],1),
		[Y0 (u) M6] = isnull([Y0 (u) M6],1),
		[Y0 (u) M7] = isnull([Y0 (u) M7],1),
		[Y0 (u) M8] = isnull([Y0 (u) M8],1),
		[Y0 (u) M9] = isnull([Y0 (u) M9],1),
		[Y0 (u) M10] = isnull([Y0 (u) M10],1),
		[Y0 (u) M11] = isnull([Y0 (u) M11],1),
		[Y0 (u) M12] = isnull([Y0 (u) M12],1),
		--//-----------------------------------
		[Y+1 (u) M1] = isnull([Y+1 (u) M1],1),
		[Y+1 (u) M2] = isnull([Y+1 (u) M2],1),
		[Y+1 (u) M3] = isnull([Y+1 (u) M3],1),
		[Y+1 (u) M4] = isnull([Y+1 (u) M4],1),
		[Y+1 (u) M5] = isnull([Y+1 (u) M5],1),
		[Y+1 (u) M6] = isnull([Y+1 (u) M6],1),
		[Y+1 (u) M7] = isnull([Y+1 (u) M7],1),
		[Y+1 (u) M8] = isnull([Y+1 (u) M8],1),
		[Y+1 (u) M9] = isnull([Y+1 (u) M9],1),
		[Y+1 (u) M10] = isnull([Y+1 (u) M10],1),
		[Y+1 (u) M11] = isnull([Y+1 (u) M11],1),
		[Y+1 (u) M12] = isnull([Y+1 (u) M12],1),
		--//budget Y0-----------------------------------
		[B_Y0_M1] = isnull([B_Y0_M1],1),
		[B_Y0_M2] = isnull([B_Y0_M2],1),
		[B_Y0_M3] = isnull([B_Y0_M3],1),
		[B_Y0_M4] = isnull([B_Y0_M4],1),
		[B_Y0_M5] = isnull([B_Y0_M5],1),
		[B_Y0_M6] = isnull([B_Y0_M6],1),
		[B_Y0_M7] = isnull([B_Y0_M7],1),
		[B_Y0_M8] = isnull([B_Y0_M8],1),
		[B_Y0_M9] = isnull([B_Y0_M9],1),
		[B_Y0_M10] = isnull([B_Y0_M10],1),
		[B_Y0_M11] = isnull([B_Y0_M11],1),
		[B_Y0_M12] = isnull([B_Y0_M12],1),
		--//budget Y+1-----------------------------------
		[B_Y+1_M1] = isnull([B_Y+1_M1],1),
		[B_Y+1_M2] = isnull([B_Y+1_M2],1),
		[B_Y+1_M3] = isnull([B_Y+1_M3],1),
		[B_Y+1_M4] = isnull([B_Y+1_M4],1),
		[B_Y+1_M5] = isnull([B_Y+1_M5],1),
		[B_Y+1_M6] = isnull([B_Y+1_M6],1),
		[B_Y+1_M7] = isnull([B_Y+1_M7],1),
		[B_Y+1_M8] = isnull([B_Y+1_M8],1),
		[B_Y+1_M9] = isnull([B_Y+1_M9],1),
		[B_Y+1_M10] = isnull([B_Y+1_M10],1),
		[B_Y+1_M11] = isnull([B_Y+1_M11],1),
		[B_Y+1_M12] = isnull([B_Y+1_M12],1),
		--//Pre-budget Y+1-----------------------------------
		[PB_Y+1_M1] = isnull([PB_Y+1_M1],1),
		[PB_Y+1_M2] = isnull([PB_Y+1_M2],1),
		[PB_Y+1_M3] = isnull([PB_Y+1_M3],1),
		[PB_Y+1_M4] = isnull([PB_Y+1_M4],1),
		[PB_Y+1_M5] = isnull([PB_Y+1_M5],1),
		[PB_Y+1_M6] = isnull([PB_Y+1_M6],1),
		[PB_Y+1_M7] = isnull([PB_Y+1_M7],1),
		[PB_Y+1_M8] = isnull([PB_Y+1_M8],1),
		[PB_Y+1_M9] = isnull([PB_Y+1_M9],1),
		[PB_Y+1_M10] = isnull([PB_Y+1_M10],1),
		[PB_Y+1_M11] = isnull([PB_Y+1_M11],1),
		[PB_Y+1_M12] = isnull([PB_Y+1_M12],1),
		--//Tren 3 Y0------------------------
		[T1_Y0_M1] = isnull([T_Y0_M1],1),
		[T1_Y0_M2] = isnull([T_Y0_M2],1),
		[T1_Y0_M3] = isnull([T_Y0_M3],1),
		[T1_Y0_M4] = isnull([T_Y0_M4],1),
		[T1_Y0_M5] = isnull([T_Y0_M5],1),
		[T1_Y0_M6] = isnull([T_Y0_M6],1),
		[T1_Y0_M7] = isnull([T_Y0_M7],1),
		[T1_Y0_M8] = isnull([T_Y0_M8],1),
		[T1_Y0_M9] = isnull([T_Y0_M9],1),
		[T1_Y0_M10] = isnull([T_Y0_M10],1),
		[T1_Y0_M11] = isnull([T_Y0_M11],1),
		[T1_Y0_M12] = isnull([T_Y0_M12],1),
		--//Tren 5 Y0-------------------------
		[T2_Y0_M1] = isnull([T_Y0_M1],1),
		[T2_Y0_M2] = isnull([T_Y0_M2],1),
		[T2_Y0_M3] = isnull([T_Y0_M3],1),
		[T2_Y0_M4] = isnull([T_Y0_M4],1),
		[T2_Y0_M5] = isnull([T_Y0_M5],1),
		[T2_Y0_M6] = isnull([T_Y0_M6],1),
		[T2_Y0_M7] = isnull([T_Y0_M7],1),
		[T2_Y0_M8] = isnull([T_Y0_M8],1),
		[T2_Y0_M9] = isnull([T_Y0_M9],1),
		[T2_Y0_M10] = isnull([T_Y0_M10],1),
		[T2_Y0_M11] = isnull([T_Y0_M11],1),
		[T2_Y0_M12] = isnull([T_Y0_M12],1),
		--//Tren 7 Y0-------------------------
		[T3_Y0_M1] = isnull([T_Y0_M1],1),
		[T3_Y0_M2] = isnull([T_Y0_M2],1),
		[T3_Y0_M3] = isnull([T_Y0_M3],1),
		[T3_Y0_M4] = isnull([T_Y0_M4],1),
		[T3_Y0_M5] = isnull([T_Y0_M5],1),
		[T3_Y0_M6] = isnull([T_Y0_M6],1),
		[T3_Y0_M7] = isnull([T_Y0_M7],1),
		[T3_Y0_M8] = isnull([T_Y0_M8],1),
		[T3_Y0_M9] = isnull([T_Y0_M9],1),
		[T3_Y0_M10] = isnull([T_Y0_M10],1),
		[T3_Y0_M11] = isnull([T_Y0_M11],1),
		[T3_Y0_M12] = isnull([T_Y0_M12],1)
	FROM 
	(
		select 
			Division = 'LLD',
			*
		from FC_BFL_Master_LLD (NOLOCK)
	) s
	inner join 
	(
		select
			Division = 'LLD',
			[Sales  Org],
			[Dchain Specs Status],
			[Item Category Group],
			[EAN / UPC]
			,Material
			,[Material Type]
		from SC1.dbo.MM_ZMR54OLD_Stg (NOLOCK)
		where 
			[Sales  Org] =  'V100'
		and left(Material,3) not in('TSV')--'TVN',
		and [EAN / UPC] not in('TUSU00001SG ','','TUSU00018FOC','TUSU00021FOC','TUSU00022FOC')
		and [Material Type] IN('YFG')
	) m on m.[EAN / UPC] = s.[EAN code] and m.Material = s.[SKU Code] and m.Division = s.Division
	left join
	(
		select 
			Division = 'LLD',
			* 
		from FC_MMDOWNLOAD_SORTBY_LLD 
		where active IN(select value from string_split(case when @Type = 'full' then '1,0' else '1' end,','))
	) s1 on s1.[SUB GROUP/ Brand] = s.[BFL Name] and s1.Division = s.Division
	--LEFT JOIN (SELECT Division = 'LLD',* FROM FC_BFL_RSP_Trend_LLD WHERE [Type] = 'T1') T1 ON T1.[EAN code] = S.[EAN code] AND T1.[SKU Code] = S.[SKU Code] and T1.Division = s.Division
	--LEFT JOIN (SELECT Division = 'LLD',* FROM FC_BFL_RSP_Trend_LLD WHERE [Type] = 'T2') T2 ON T2.[EAN code] = S.[EAN code] AND T2.[SKU Code] = S.[SKU Code] and T2.Division = s.Division
	--LEFT JOIN (SELECT Division = 'LLD',* FROM FC_BFL_RSP_Trend_LLD WHERE [Type] = 'T3') T3 ON T3.[EAN code] = S.[EAN code] AND T3.[SKU Code] = S.[SKU Code] and t3.Division = s.Division
	where 
		m.[Sales  Org] = 'V100'
	and m.[Material Type] = 'YFG'
	and (isnull(s.Active,0) = 1 OR len(@Type) >0)
	and s.Division = @Division
	--//LDB
	UNION ALL
	SELECT	
		[Division] = 'LDB',
		[Sales Org] = 'V400',
		[Barcode] = s.[EAN code],
		[Material] = isnull(s.[SKU Code],''),
		[Bundle name] = isnull(s.[SKU Name],''),
		[Material Type] = s.[Product Type],				
		[Ref. Code] = s.[EAN code],
		[SUB GROUP/ Brand] = s.[BFL Name],
		[CAT/Axe] = s.[Axe],
		[SUB CAT/ Sub Axe] = s.[Sub Axe],
		[GROUP/ Class] = s.[Sub Brand],
		[HERO] = s.[Hero],
		[Product status] = s.[Product status],
		[Signature] = s.[Signature],
		[Type] = isnull(s.[Product Type],''),
		[Product Type] = isnull(s.[Product Type],''),
		[Dchain]= s.[Dchain Specs Status],
		[Item Category Group] = s.[Item Category Group],
		Active = 1,--isnull(s.Active,0),
		--//lAST YEAR - 2---------------------------------------
		[Y-2 (u) M1] = isnull([Y-2 (u) M1],1),
		[Y-2 (u) M2] = isnull([Y-2 (u) M2],1),
		[Y-2 (u) M3] = isnull([Y-2 (u) M3],1),
		[Y-2 (u) M4] = isnull([Y-2 (u) M4],1),
		[Y-2 (u) M5] = isnull([Y-2 (u) M5],1),
		[Y-2 (u) M6] = isnull([Y-2 (u) M6],1),
		[Y-2 (u) M7] = isnull([Y-2 (u) M7],1),
		[Y-2 (u) M8] = isnull([Y-2 (u) M8],1),
		[Y-2 (u) M9] = isnull([Y-2 (u) M9],1),
		[Y-2 (u) M10] = isnull([Y-2 (u) M10],1),
		[Y-2 (u) M11] = isnull([Y-2 (u) M11],1),
		[Y-2 (u) M12] = isnull([Y-2 (u) M12],1),
		--//LAST YEAR - 1---------------------------------------
		[Y-1 (u) M1] = isnull([Y-1 (u) M1],1),
		[Y-1 (u) M2] = isnull([Y-1 (u) M2],1),
		[Y-1 (u) M3] = isnull([Y-1 (u) M3],1),
		[Y-1 (u) M4] = isnull([Y-1 (u) M4],1),
		[Y-1 (u) M5] = isnull([Y-1 (u) M5],1),
		[Y-1 (u) M6] = isnull([Y-1 (u) M6],1),
		[Y-1 (u) M7] = isnull([Y-1 (u) M7],1),
		[Y-1 (u) M8] = isnull([Y-1 (u) M8],1),
		[Y-1 (u) M9] = isnull([Y-1 (u) M9],1),
		[Y-1 (u) M10] = isnull([Y-1 (u) M10],1),
		[Y-1 (u) M11] = isnull([Y-1 (u) M11],1),
		[Y-1 (u) M12] = isnull([Y-1 (u) M12],1),
		--/-------------------------------
		[Y0 (u) M1] = isnull([Y0 (u) M1],1),
		[Y0 (u) M2] = isnull([Y0 (u) M2],1),
		[Y0 (u) M3] = isnull([Y0 (u) M3],1),
		[Y0 (u) M4] = isnull([Y0 (u) M4],1),
		[Y0 (u) M5] = isnull([Y0 (u) M5],1),
		[Y0 (u) M6] = isnull([Y0 (u) M6],1),
		[Y0 (u) M7] = isnull([Y0 (u) M7],1),
		[Y0 (u) M8] = isnull([Y0 (u) M8],1),
		[Y0 (u) M9] = isnull([Y0 (u) M9],1),
		[Y0 (u) M10] = isnull([Y0 (u) M10],1),
		[Y0 (u) M11] = isnull([Y0 (u) M11],1),
		[Y0 (u) M12] = isnull([Y0 (u) M12],1),
		--//-----------------------------------
		[Y+1 (u) M1] = isnull([Y+1 (u) M1],1),
		[Y+1 (u) M2] = isnull([Y+1 (u) M2],1),
		[Y+1 (u) M3] = isnull([Y+1 (u) M3],1),
		[Y+1 (u) M4] = isnull([Y+1 (u) M4],1),
		[Y+1 (u) M5] = isnull([Y+1 (u) M5],1),
		[Y+1 (u) M6] = isnull([Y+1 (u) M6],1),
		[Y+1 (u) M7] = isnull([Y+1 (u) M7],1),
		[Y+1 (u) M8] = isnull([Y+1 (u) M8],1),
		[Y+1 (u) M9] = isnull([Y+1 (u) M9],1),
		[Y+1 (u) M10] = isnull([Y+1 (u) M10],1),
		[Y+1 (u) M11] = isnull([Y+1 (u) M11],1),
		[Y+1 (u) M12] = isnull([Y+1 (u) M12],1),
		--//budget Y0--------------------
		[B_Y0_M1] = isnull([B_Y0_M1],1),
		[B_Y0_M2] = isnull([B_Y0_M2],1),
		[B_Y0_M3] = isnull([B_Y0_M3],1),
		[B_Y0_M4] = isnull([B_Y0_M4],1),
		[B_Y0_M5] = isnull([B_Y0_M5],1),
		[B_Y0_M6] = isnull([B_Y0_M6],1),
		[B_Y0_M7] = isnull([B_Y0_M7],1),
		[B_Y0_M8] = isnull([B_Y0_M8],1),
		[B_Y0_M9] = isnull([B_Y0_M9],1),
		[B_Y0_M10] = isnull([B_Y0_M10],1),
		[B_Y0_M11] = isnull([B_Y0_M11],1),
		[B_Y0_M12] = isnull([B_Y0_M12],1),
		--//budget Y+1---------------------
		[B_Y+1_M1] = isnull([B_Y+1_M1],1),
		[B_Y+1_M2] = isnull([B_Y+1_M2],1),
		[B_Y+1_M3] = isnull([B_Y+1_M3],1),
		[B_Y+1_M4] = isnull([B_Y+1_M4],1),
		[B_Y+1_M5] = isnull([B_Y+1_M5],1),
		[B_Y+1_M6] = isnull([B_Y+1_M6],1),
		[B_Y+1_M7] = isnull([B_Y+1_M7],1),
		[B_Y+1_M8] = isnull([B_Y+1_M8],1),
		[B_Y+1_M9] = isnull([B_Y+1_M9],1),
		[B_Y+1_M10] = isnull([B_Y+1_M10],1),
		[B_Y+1_M11] = isnull([B_Y+1_M11],1),
		[B_Y+1_M12] = isnull([B_Y+1_M12],1),
		--//Pre-budget Y+1------------------
		[PB_Y+1_M1] = isnull([PB_Y+1_M1],1),
		[PB_Y+1_M2] = isnull([PB_Y+1_M2],1),
		[PB_Y+1_M3] = isnull([PB_Y+1_M3],1),
		[PB_Y+1_M4] = isnull([PB_Y+1_M4],1),
		[PB_Y+1_M5] = isnull([PB_Y+1_M5],1),
		[PB_Y+1_M6] = isnull([PB_Y+1_M6],1),
		[PB_Y+1_M7] = isnull([PB_Y+1_M7],1),
		[PB_Y+1_M8] = isnull([PB_Y+1_M8],1),
		[PB_Y+1_M9] = isnull([PB_Y+1_M9],1),
		[PB_Y+1_M10] = isnull([PB_Y+1_M10],1),
		[PB_Y+1_M11] = isnull([PB_Y+1_M11],1),
		[PB_Y+1_M12] = isnull([PB_Y+1_M12],1),
		--//Trend 3 Y0------------------------
		[T1_Y0_M1] = isnull([T_Y0_M1],1),
		[T1_Y0_M2] = isnull([T_Y0_M2],1),
		[T1_Y0_M3] = isnull([T_Y0_M3],1),
		[T1_Y0_M4] = isnull([T_Y0_M4],1),
		[T1_Y0_M5] = isnull([T_Y0_M5],1),
		[T1_Y0_M6] = isnull([T_Y0_M6],1),
		[T1_Y0_M7] = isnull([T_Y0_M7],1),
		[T1_Y0_M8] = isnull([T_Y0_M8],1),
		[T1_Y0_M9] = isnull([T_Y0_M9],1),
		[T1_Y0_M10] = isnull([T_Y0_M10],1),
		[T1_Y0_M11] = isnull([T_Y0_M11],1),
		[T1_Y0_M12] = isnull([T_Y0_M12],1),
		--//Trend 5 Y0-------------------------
		[T2_Y0_M1] = isnull([T_Y0_M1],1),
		[T2_Y0_M2] = isnull([T_Y0_M2],1),
		[T2_Y0_M3] = isnull([T_Y0_M3],1),
		[T2_Y0_M4] = isnull([T_Y0_M4],1),
		[T2_Y0_M5] = isnull([T_Y0_M5],1),
		[T2_Y0_M6] = isnull([T_Y0_M6],1),
		[T2_Y0_M7] = isnull([T_Y0_M7],1),
		[T2_Y0_M8] = isnull([T_Y0_M8],1),
		[T2_Y0_M9] = isnull([T_Y0_M9],1),
		[T2_Y0_M10] = isnull([T_Y0_M10],1),
		[T2_Y0_M11] = isnull([T_Y0_M11],1),
		[T2_Y0_M12] = isnull([T_Y0_M12],1),
		--//Trend 7 Y0-------------------------
		[T3_Y0_M1] = isnull([T_Y0_M1],1),
		[T3_Y0_M2] = isnull([T_Y0_M2],1),
		[T3_Y0_M3] = isnull([T_Y0_M3],1),
		[T3_Y0_M4] = isnull([T_Y0_M4],1),
		[T3_Y0_M5] = isnull([T_Y0_M5],1),
		[T3_Y0_M6] = isnull([T_Y0_M6],1),
		[T3_Y0_M7] = isnull([T_Y0_M7],1),
		[T3_Y0_M8] = isnull([T_Y0_M8],1),
		[T3_Y0_M9] = isnull([T_Y0_M9],1),
		[T3_Y0_M10] = isnull([T_Y0_M10],1),
		[T3_Y0_M11] = isnull([T_Y0_M11],1),
		[T3_Y0_M12] = isnull([T_Y0_M12],1)
	FROM 
	(
		select 
			Division = 'LDB',
			* 
		from FC_BFL_Master_LDB (NOLOCK)
	) s
	--LEFT JOIN (SELECT Division = 'LDB',* FROM FC_BFL_RSP_Trend_LDB WHERE [Type] = 'T1') T1 ON T1.[EAN code] = S.[EAN code] and T1.Division = s.Division --AND T1.[SKU Code] = S.[SKU Code]
	--LEFT JOIN (SELECT Division = 'LDB',* FROM FC_BFL_RSP_Trend_LDB WHERE [Type] = 'T2') T2 ON T2.[EAN code] = S.[EAN code] and T2.Division = s.Division--AND T2.[SKU Code] = S.[SKU Code] 
	--LEFT JOIN (SELECT Division = 'LDB',* FROM FC_BFL_RSP_Trend_LDB WHERE [Type] = 'T3') T3 ON T3.[EAN code] = S.[EAN code] and t3.Division = s.Division--AND T3.[SKU Code] = S.[SKU Code] 
	where s.Division = @Division


	--SELECT Division = 'LDB',* FROM FC_BFL_RSP_Trend_LDB WHERE [Type] = 'T2' and [EAN code] = '30106659'
	--select * from FC_FM_Original_LDB where [Ref. Code] = '30106659'

