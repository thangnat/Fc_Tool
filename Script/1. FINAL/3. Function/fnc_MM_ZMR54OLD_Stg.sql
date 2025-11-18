/*
	select * 
	from fnc_MM_ZMR54OLD_Stg('ldb') 
	where [EAN / UPC]='8935274670159'
	and STT = 1
*/

Alter function fnc_MM_ZMR54OLD_Stg(@Division nvarchar(3))
	RETURNS TABLE
	with encryption
as
	return
	select
		*
	from
	(
		select			
			STT = ROW_NUMBER() over(partition by m.[EAN / UPC] order by m.[EAN / UPC] asc, cast(left(ms.value,1) as int) asc,m.[Creation Date] asc),
			[Sales  Org] = m.[Sales  Org],
			[Signature] = m.[Signature Description],
			[SUB GROUP/ Brand] = m.[Material Description (Eng)],
			[CAT/Axe] = case 
							when m.[Signature Description] = 'CeraVe' then m.[SubBrand Description] 
							else m.[Brand Description] 
						end,
			[SUB CAT/ Sub Axe] = isnull(m.[Brand Description],''),
			[GROUP/ Class] = isnull(m.[SubBrand Description],''),
			[Material Type] = isnull(m.[Material Type],''),
			[EAN / UPC] = isnull(m.[EAN / UPC],''),
			[Sap Code] = Isnull(m.Material,''),
			[Dchain Specs Status] = m.[MMPP Status],
			[Item Category Group] = m.[Item Category Group],
			[Product status] = case [MMPP Status]
									--when '20' then 'NEW Code'
									--when '30' then 'RE NO'
									when '40' then 'New Launch'
									when '45' then 'New Launch'
									when '50' then 'On Going'
									when '60' then 'TBDC'
									when '70' then 'TBDC'
									when '80' then 'DC'
									when '90' then 'DC'
									when '95' then 'Cancel'
									else ''
								end
		from SC1.dbo.MM_ZMR54OLD_Stg m
		left join
		(
			select value from string_split('1.50,2.60,3.40,4.45,5.65,6.70,7.80,8.90,9.95',',')
		) ms on substring(ms.value,3,2)=m.[MMPP Status]
		where m.[Sales  Org] = case
									when @Division = 'LDB' then 'V400' 
									else '' 
								end
		and ISNULL(m.[EAN / UPC],'')<>''
		and m.[MMPP Status]>=40
		--and m.[Item Category Group] <>'LUMF'
		and m.[Material Type] IN('YFG')
		--union all
		--select			
		--	STT = ROW_NUMBER() over(partition by m.[EAN / UPC] order by m.[EAN / UPC] asc, cast(m.[Dchain Specs Status] as int) asc,m.[Creation Date] desc),
		--	[Sales  Org] = m.[Sales  Org],
		--	[Signature] = m.[Signature],
		--	[SUB GROUP/ Brand] = m.[Material Description (Eng)],
		--	[CAT/Axe] = case 
		--					when m.[Signature Description] = 'CeraVe' then m.[SubBrand Description] 
		--					else m.[Brand Description] 
		--				end,
		--	[SUB CAT/ Sub Axe] = isnull(m.[Brand Description],''),
		--	[GROUP/ Class] = isnull(m.[SubBrand Description],''),
		--	[Material Type] = isnull(m.[Material Type],''),
		--	[EAN / UPC] = isnull(m.[EAN / UPC],''),
		--	[Sap Code] = Isnull(m.Material,''),
		--	[Dchain Specs Status] = m.[Dchain Specs Status],
		--	[Item Category Group] = m.[Item Category Group],
		--	[Product status] = case [Dchain Specs Status]
		--							when '20' then 'NEW Code'
		--							when '30' then 'RE NO'
		--							when '40' then 'New Launch'
		--							when '50' then 'On Going'
		--							when '60' then 'TBDC'
		--							when '70' then 'DC'
		--							when '80' then 'DC'
		--							when '90' then 'DC'
		--							else ''
		--						end
		--from SC1.dbo.MM_ZMR54OLD_Stg m
		--where m.[Sales  Org] = case
		--							when @Division = 'LDB' then 'V400' 
		--							else '' 
		--						end
		--and ISNULL(m.[EAN / UPC],'')<>''
		--and m.[Dchain Specs Status]>=40
		--and m.[Item Category Group] ='LUMF'
		--and m.[Material Type] IN('YFG')
		union all
		select
			STT = ROW_NUMBER() over(partition by m.[EAN / UPC] order by m.[EAN / UPC] asc, cast(m.[Dchain Specs Status] as int) asc,m.[Creation Date] desc),
			[Sales  Org] = m.[Sales  Org],
			[Signature] = m.[Signature],
			[SUB GROUP/ Brand] = '',
			[CAT/Axe] = '',
			[SUB CAT/ Sub Axe] = '',
			[GROUP/ Class] = '',
			[Material Type]=[Material Type],
			[EAN / UPC] = isnull(m.[EAN / UPC],''),
			[Sap Coe] = Isnull(m.Material,''),
			[Dchain Specs Status] = m.[Dchain Specs Status],
			[Item Category Group] = m.[Item Category Group],
			[Product status] = case [Dchain Specs Status]
									when '20' then '0.NEW Code'
									when '30' then '3.Reno'
									when '40' then '2.New Launch'
									when '50' then '1.On Going'
									when '60' then '4.TBDC'
									when '70' then '5.DC'
									when '80' then '5.DC'
									when '90' then '5.DC'
									else ''
								end
		from SC1.dbo.MM_ZMR54OLD_Stg m
		where m.[Sales  Org] = case 
									when @Division = 'CPD' then 'V200' 
									when @Division = 'PPD' then 'V300'
									else ''
								end
		and ISNULL(m.[EAN / UPC],'')<>''
		union all
		select
			STT = ROW_NUMBER() over(partition by m.[EAN / UPC] order by m.[EAN / UPC] asc, cast(m.[Dchain Specs Status] as int) asc,m.[Creation Date] desc),
			[Sales  Org] = m.[Sales  Org],
			[Signature] = m.[Signature],
			[SUB GROUP/ Brand] = '',
			[CAT/Axe] = '',
			[SUB CAT/ Sub Axe] = '',
			[GROUP/ Class] = '',
			[Material Type] = [Material Type],
			[EAN / UPC] = isnull(m.[EAN / UPC],''),
			[Sap Coe] = Isnull(m.Material,''),
			[Dchain Specs Status] = m.[Dchain Specs Status],
			[Item Category Group] = m.[Item Category Group],
			[Product status] = case [Dchain Specs Status]
									when '20' then '0.NEW Code'
									when '30' then '3.Reno'
									when '40' then '2.New Launch'
									when '50' then '1.On Going'
									when '60' then '4.TBDC'
									when '70' then '5.DC'
									when '80' then '5.DC'
									when '90' then '5.DC'
									else ''
								end
		from SC1.dbo.MM_ZMR54OLD_Stg m
		where m.[Sales  Org] = case 
									when @Division = 'LLD' then 'V100' 
									else ''
								end
		and ISNULL(m.[EAN / UPC],'')<>''
	) as x
	--order by m.[EAN / UPC] asc, m.[Dchain Specs Status] asc

