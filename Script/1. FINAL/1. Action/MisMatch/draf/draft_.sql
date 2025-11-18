--table pass update
--single baseline
declare @sql nvarchar(max)=''
declare @sql1 nvarchar(max)=''
declare @FM_KEY nvarchar(6)='202407'
declare @Division nvarchar(3)='CPD'
declare @Column_LY_SINGLE		nvarchar(max) = ''
select @Column_LY_SINGLE = ListColumn from fn_FC_GetColHeader_Historical(@FM_KEY,'h',1)
--select Column_LY_SINGLE = ListColumn from fn_FC_GetColHeader_Historical('202407','h',1)

--select top 1 * from fc_validate_mismatch
--select * from fc_validate_mismatch2
declare @table_Alert2 nvarchar(200)=''
select @table_Alert2='fc_validate_mismatch2'
declare @FunctionName nvarchar(50)='FOC'
declare @Type nvarchar(50)='MasterData'
declare @ProductType	nvarchar(200) = ''
select @ProductType = case when  @Division = 'CPD' then '[Product Type] in(''YFG'',''YSM2'')' else '[Product Type] in(''YFG'')' end
	
declare @MaterialType_ZV14	nvarchar(200) = ''
select @MaterialType_ZV14 = case when @Division = 'CPD' then '[Material Type] in(''YFG'',''YSM2'')' else '[Material Type] in(''YFG'')' end

select @sql=
'select
	[Division]='''+@Division+''',
	[FM_KEY]='''+@FM_KEY+''',
	[Function Name]='''+@FunctionName+''',
	[Type Name]='''+@Type+''',
	/*[SUB GROUP/ Brand]='''',*/
	[SUB GROUP/ Brand]=s.[SUB GROUP/ Brand],
	[Channel],      
	[Time series]=''5. FOC Qty'',
	/*[Barcode],
	[Material],*/
	[EAN Code],
	[SKU Code],'+
	@Column_LY_SINGLE+'
from
(
	select
		[Year],
		[Month],				
		[Channel],
		/*[Barcode],
		x.[Material],*/
		[EAN Code]=[Barcode_Component],
		[SKU Code]=[Material_Component],
		[Pass Column Header]=(
									select replace([Pass],''@'',cast(([Year]-year(getdate())) as nvarchar(2))) 
									from V_FC_MONTH_MASTER 
									where Month_number = cast(x.[Month] as int)
								),'
	select @sql1='
		[HIS_QTY_SINGLE]=sum([DO Billed Quantity]*[Qty]*[ABS])
	from
	(
		select 
			[Year]=left(z.[Billing Doc Date],4),
			[Month]=substring(z.[Billing Doc Date],5,2),
			[Barcode]=Barcode_Original,
			[Material]=case when '''+@Division+'''<>''CPD'' then '''' else z.[Bill. Material] end,
			[DO Billed Quantity]=z.[DO Billed Quantity],
			[ABS],
			[Channel] 
		from V_'+@Division+'_FC_ZV14_Historical z
		inner join 
		(
			select distinct
				[Material]=case when '''+@Division+'''<>''CPD'' then '''' else [Material] end,
				[Barcode]=[EAN / UPC]
			from SC1.dbo.MM_ZMR54OLD_Stg
			where
				[Sales  Org]=case 
								when '''+@Division+'''=''LLD'' then ''V100'' 
								when '''+@Division+'''=''CPD'' then ''V200'' 
								when '''+@Division+'''=''PPD'' then ''V300'' 
								when '''+@Division+'''=''LDB'' then ''V400'' 
								else ''''
							end
			and [Item Category Group]=''LUMF''
		) s On s.[Barcode] = z.[Barcode_Original] '+case when @Division<>'CPD' then '' else ' and s.Material=z.[Bill. Material]' end+'
		where 
			[FOC TYPE]=''FDR''
		and Channel<>''FOC''
	) as x 
	Left join 
	(
		select 
			* 
		from V_ZMR32
		where [Division]='''+@Division+'''
	) zmr on zmr.[Barcode_Bom]=x.[Barcode] '+case when @Division<>'CPD' then '' else 'and zmr.[Material_Bom]=x.[Material]' end+'
	/*where ISNULL(zmr.[Material_Component],'''')=''''*/
	group by
		[Year],
		[Month],				
		[Channel],
		/*[Barcode],
		[Material],*/
		[Barcode_Component],
		[Material_Component]
) as h
left join 
(
	select DISTINCT 
		[SUB GROUP/ Brand],
		[Barcode],
		[Material]=case when '''+@Division+'''<>''CPD'' then '''' else [Material] end
	from fnc_SubGroupMaster('''+@Division+''',''full'')
	/*where '+@ProductType+'*/
) s On s.Barcode = h.[EAN Code] '+case when @Division<>'CPD' then '' else 'and s.Material=h.[SKU Code] ' end+'
where ISNULL(s.[SUB GROUP/ Brand],'''')=''''
group by	
	[SUB GROUP/ Brand],
	[Channel],
	[EAN Code], 
	[SKU Code] '
--+'group by
--	[Barcode],
--	[Material],
--	[Channel],
--	[EAN Code], 
--	[SKU Code]'

select len(@sql) len_sql, len(@sql1) len_sql1,@sql+@sql1
execute(@sql+@sql1)

--select [Material Type],[Item Category Group],* from SC1.dbo.MM_ZMR54OLD_Stg where Material='G4581501'
--select [Item Category Group],* from fnc_SubGroupMaster('CPD','full') where Material='G4581501'

--exec sp_set_FMKEY 'hoaiphuong.ho','202407',0,''

--select * from V_CPD_FC_ZV14_Historical where [Bill. Material]
--select Barcode_Component,Material_Component,* from V_ZMR32 where Material_Component='G3216002' and Material_Bom
--select @sql=
--'select
--	[SUB GROUP/ Brand]=s.[SUB GROUP/ Brand],
--	[Year],
--	[Month],				
--	[Channel],
--	[HIS_QTY_SINGLE]=0,
--	[HIS_QTY_SINGLE_FDR]=0,
--	[HIS_QTY_BOM]=0,
--	[HIS_QTY_BOM_FDR]=sum([DO Billed Quantity]*Qty*[ABS])	
--from
--(
--	select 
--		[Year] = left(z.[Billing Doc Date],4),
--		[Month] = substring(z.[Billing Doc Date],5,2),
--		[Barcode] = Barcode_Original,
--		[Material]=case when '''+@Division+'''<>''CPD'' then '''' else z.[Bill. Material] end,
--		[DO Billed Quantity] = z.[DO Billed Quantity],
--		[ABS],
--		[Channel]
--	from V_'+@Division+'_FC_ZV14_Historical z
--	inner join 
--	(
--		select distinct
--			[Material]=case when '''+@Division+'''<>''CPD'' then '''' else [Material] end,
--			[Barcode]=[EAN / UPC]
--		from SC1.dbo.MM_ZMR54OLD_Stg
--		where
--			[Sales  Org]=case 
--							when '''+@Division+'''=''LLD'' then ''V100'' 
--							when '''+@Division+'''=''CPD'' then ''V200'' 
--							when '''+@Division+'''=''PPD'' then ''V300'' 
--							when '''+@Division+'''=''LDB'' then ''V400'' 
--							else ''''
--						end
--		and '+@MaterialType_ZV14+' 
--	) s On s.[Barcode] = z.[Barcode_Original] '+case when @Division<>'CPD' then '' else ' and s.Material=z.[Bill. Material]' end+'
--	where 
--		[FOC TYPE]=''FDR''
--	and Channel <>''FOC''
--) as x
--Left join 
--(
--	select 
--		* 
--	from V_ZMR32
--	where [Division]='''+@Division+'''
--) zmr on zmr.Barcode_Bom=x.Barcode '+case when @Division<>'CPD' then '' else 'and zmr.Material_Bom=x.Material' end+'
--left join 
--(
--	select distinct 
--		[SUB GROUP/ Brand],
--		[Barcode],
--		[Material]=case when '''+@Division+'''<>''CPD'' then '''' else [Material] end
--	from fnc_SubGroupMaster('''+@Division+''',''full'')
--	where '+@ProductType+'
--) s On s.Barcode = zmr.Barcode_Component '+case when @Division<>'CPD' then '' else 'and s.Material=zmr.Material_Component' end+'
--where 
--	zmr.'+@MaterialType_ZV14+'
--and ISNULL([SUB GROUP/ Brand],'''')<>''''
--group by	
--	[SUB GROUP/ Brand],
--	[Year],
--	[Month],				
--	[Channel]'

----select @sql
--execute(@sql)


--select * from CPD_FC_SI_HIS
--select * from V_CPD_His_SI_Single
--select * from  CPD_202407_His_SI_FOC_FDR_Final
----FOC
--select * from CPD_202407_His_SI_FOC_FDR_Final
----BOM Promo

--select * from CPD_202407_His_SI_Bom_Final