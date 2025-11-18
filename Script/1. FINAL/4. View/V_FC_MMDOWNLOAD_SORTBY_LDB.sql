/*
	select * 
	from V_FC_MMDOWNLOAD_SORTBY_LDB 
	
	
*/
--select * from fnc_SubGroupMaster('LDB','full') where [SUB GROUP/ Brand]='POCKET VISAGE 30ml EN/F/IT/SP'
--select * from SC1.dbo.MM_ZMR54OLD_Stg where [EAN / UPC]='30156449'

alter View V_FC_MMDOWNLOAD_SORTBY_LDB
As
select
	*
from
(
	Select 
		STT = m.STT,
		[Signature],
		[SUB GROUP/ Brand],
		[CAT/Axe],
		[SUB CAT/ Sub Axe],
		[GROUP/ Class],
		[Product status] = m.[Product Status],
		[Material Type],
		[Dchain Specs Status]=m.[Dchain Specs Status],
		[HERO] = isnull(s.HERO,''),
		Active = s.Active
	from 
	(
		select 
			*
		from fnc_MM_ZMR54OLD_Stg('LDB') 
		where STT=1
	) m
	inner join
	(
		select
			[EAN Code],
			HERO,
			Active
		from FC_BFL_Master_LDB
		where FM_KEY=(select top 1 FM_KEY from FC_ComputerName (NOLOCK) where [ComputerName]=HOST_NAME())
	) s on s.[EAN Code] = m.[EAN / UPC]
	Where m.STT=1
) as x
--where STT = 1