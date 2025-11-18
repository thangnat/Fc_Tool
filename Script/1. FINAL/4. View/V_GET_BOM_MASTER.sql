/*
SELECT * FROM V_GET_BOM_MASTER
*/
ALTER VIEW V_GET_BOM_MASTER
with encryption
AS
SELECT
	Division,
	[BOM Material],
	[Material Desc(Header)],
	[Components],
	[Material Desc(Components)],
	Quantity,
	CHANNEL,
	Subgroup
FROM
(
	SELECT
		Division = MM.Division,
		[BOM Material] = B.Material,
		[Material Desc(Header)] = mm.[Material Description (Eng)],
		[Components] = b.Component,
		[Material Desc(Components)] = MMC.[Material Description (Eng)],
		Quantity = b.Quantity,
		CHANNEL = 'ONLINE',
		Subgroup = ''
	FROM SC1.dbo.ZMR32 B
	INNER JOIN SC1.dbo.MM_ZMR54OLD MM ON MM.Material = B.Material
	INNER JOIN SC1.dbo.MM_ZMR54OLD MMC ON MMC.Material = B.Component
	UNION ALL
	SELECT
		Division = MM.Division,
		[BOM Material] = B.Material,
		[Material Desc(Header)] = mm.[Material Description (Eng)],
		[Components] = b.Component,
		[Material Desc(Components)] = MMC.[Material Description (Eng)],
		Quantity = b.Quantity,
		CHANNEL = 'OFFLINE',
		Subgroup = ''
	FROM SC1.dbo.ZMR32 B
	INNER JOIN SC1.dbo.MM_ZMR54OLD MM ON MM.Material = B.Material
	INNER JOIN SC1.dbo.MM_ZMR54OLD MMC ON MMC.Material = B.Component
) AS X
--where X.[BOM Material] = 'EVN20005'

--select * from SC1.dbo.MM_ZMR54OLD where Material = 'EVN20005'
--select * from SC1.dbo.ZMR32 where Material = 'EVN20005'