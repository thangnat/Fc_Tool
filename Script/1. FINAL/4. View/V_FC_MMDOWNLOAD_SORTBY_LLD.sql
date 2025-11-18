/*
	select * 
	from V_FC_MMDOWNLOAD_SORTBY_LLD
	where Active = 1
	where [SUB GROUP/ Brand] = 'All Hours Hyper Finish R24'
*/
/*
select [Sub-group FC],* from FC_MasterFile_CPD_MM_Master where [Sub-group FC] ='MCLR WTR CRYSTAL 95ML PLV'
select * from FC_MasterFile_CPD_MM_Master where [Type] = 'PLV' order by [Sub-group FC] asc
*/

Alter View V_FC_MMDOWNLOAD_SORTBY_LLD
As
select
	*
from
(
	Select 
		[STT] = ROW_NUMBER() over( partition by s.[SUB GROUP/ Brand] order by [Material Type] asc,[Dchain Specs Status] asc,Hero Asc),
		[BFL Code],
		[SUB GROUP/ Brand]=s.[SUB GROUP/ Brand],
		[CAT/Axe] = s.[CAT/Axe],
		[SUB CAT/ Sub Axe] = s.Franchise,--s.[SUB CAT/ Sub Axe],
		[GROUP/ Class] = s.[GROUP/ Class],
		[Product status]=isnull(s.[Product status],''),
		[Material Type],
		[Dchain Specs Status],
		[Hero],
		[Axe]=s.Axe,
		[Brand]=s.Brand,
		[Sub Brand],
		[Franchise],
		[Sub Franchise],
		[Signature]=s.[Signature],
		[Active]
	from fnc_MM_ZMR54OLD_Stg('LLD') m
	left join 
	(
		select distinct
			Active = (select top 1 Active from FC_BFL_Master_LLD (NOLOCK) where [BFL Name] =s.[BFL Name] order by Active desc),
			[BFL Code],
			[SUB GROUP/ Brand] = [BFL Name],
			[EAN code],
			[Signature],		
			[CAT/Axe] = Axe,
			[SUB CAT/ Sub Axe] = [Sub Axe],
			[GROUP/ Class] = Brand,
			Axe,
			Brand,
			[Sub Brand],
			Franchise,
			[Sub Franchise],
			Hero = (select top 1 Hero from FC_BFL_Master_LLD (NOLOCK) where [BFL Name] =s.[BFL Name] AND ISNULL(Hero,'')<>'' order by Hero asc),
			[Product status] = isnull((select top 1 [Product Status] from FC_BFL_Master_LLD (NOLOCK) where [BFL Name] =s.[BFL Name] AND ISNULL([Product Status],'')<>'' order by [Product Status] asc),'')
		from FC_BFL_Master_LLD s (NOLOCK)	
		where FM_KEY=(select top 1 FM_KEY from FC_ComputerName (NOLOCK) where [ComputerName]=HOST_NAME())
	) s on s.[EAN code] = m.[EAN / UPC]
) as x
where STT = 1 and ISNULL([SUB GROUP/ Brand],'')<>''