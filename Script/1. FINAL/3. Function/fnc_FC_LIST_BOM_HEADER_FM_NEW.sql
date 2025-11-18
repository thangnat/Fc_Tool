/*
	select * 
	from fnc_FC_LIST_BOM_HEADER_FM_NEW('CPD')
	where [sku code] = 'XVN00349'
*/
Create FUNCTION fnc_FC_LIST_BOM_HEADER_FM_NEW
(
	@Division		nvarchar(3)
)
RETURNS TABLE
with encryption
As
	RETURN
	SELECT
		*
	FROM
	(
		select * from FC_LIST_BOM_HEADER_ALL_CPD
		--Union All
		--select * from FC_LIST_BOM_HEADER_ALL_LLD
		--SELECT DISTINCT
		--	Division = 'CPD',
		--	Barcode = m.[EAN / UPC],
		--	F.*
		--from
		--(
		--	select
		--		*
		--	FROM FC_LIST_BOM_HEADER_OFFLINE_cpd
		--	union all
		--	select
		--		*
		--	FROM FC_LIST_BOM_HEADER_ONLINE_cpd		
		--) as f
		--inner join
		--(
		--	select distinct Material, [EAN / UPC] 
		--	from SC1.dbo.MM_ZMR54OLD (NOLOCK)
		--) m on m.Material = f.[Sku Code]
		----UNION ALL
		----SELECT DISTINCT
		----	[Sku Code]
		----FROM FC_LIST_BOM_HEADER_ONLINE_cpd
	) AS X
	WHERE Division = @Division