/*
	select
		* 
	from V_FC_MMDOWNLOAD_SORTBY_CPD 
	where [SUB GROUP/ Brand] = 'LAYER IT ALL PALETTE'
*/

Alter View V_FC_MMDOWNLOAD_SORTBY_CPD
As
select
	*
from
(
	Select 
		[STT] = ROW_NUMBER() over( partition by s.[SUB GROUP/ Brand] order by m.[Material Type] asc,s.[Product status] asc,HERO Asc),--[Dchain Specs Status] asc),
		[Signature] = isnull(s.[Signature],''),
		[SUB GROUP/ Brand] = s.[SUB GROUP/ Brand],
		[CAT/Axe] = isnull(s.[CAT/Axe],''),
		[SUB CAT/ Sub Axe] = isnull(s.[SUB CAT/ Sub Axe],''),
		[GROUP/ Class] = isnull(s.[GROUP/ Class],''),
		[Product status] = isnull(s.[Product status],''),
		[Material Type]=case when s.HERO='PLV' then 'PLV' else isnull(s.[Material Type],m.[Material Type]) end,
		[Dchain Specs Status] = isnull(m.[Dchain Specs Status],'0'),
		[HERO] = isnull(s.HERO,''),
		[Active] = isnull(s.Active,0)
	from 
	(
		select DISTINCT 
			[SUB GROUP/ Brand]=[Sub-group FC],
			[EAN (VALUE)],
			[Signature],
			[HERO]=[Type],
			[CAT/Axe]=[Category],
			[SUB CAT/ Sub Axe]=[Sub-Category],
			[GROUP/ Class]=[Group],
			[Product status]=[Sub Groub Status],
			[Material Type],
			[Active]=cast('1' as int)
		from FC_BFL_Master_CPD (NOLOCK)
		where FM_KEY=(select top 1 FM_KEY from FC_ComputerName (NOLOCK) where [ComputerName]=HOST_NAME())
	) s 
	left join
	(
		select 
			[EAN / UPC],
			[Material Type],
			[Dchain Specs Status]
		from fnc_MM_ZMR54OLD_Stg('CPD')
		union all
		select 
			[EAN / UPC]=isnull([EAN (VALUE)],''),
			[Material Type]=isnull([Material Type],''),
			[Dchain Specs Status]=isnull([Dchain 02],'')
		from FC_BFL_Master_CPD (NOLOCK)
		where 
			FM_KEY=(select top 1 FM_KEY from FC_ComputerName (NOLOCK) where [ComputerName]=HOST_NAME())	
		and left(Material,3)='DUM'
	) m on s.[EAN (VALUE)] = m.[EAN / UPC]
) as x
where STT = 1