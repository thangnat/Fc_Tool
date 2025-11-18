/*  
	exec sp_FC_GetData_AdjustBom_New2 'CPD','202409','BC ANTI ACNE SERUM 7.5ML PLV'
	--XVN00297,XVN00349,XVN00298
*/  
--select * from FC_BomHeader_CPD
Alter Proc sp_FC_GetData_AdjustBom_New2  
	@Division		nvarchar(3),  
	@FM_KEY			nvarchar(6),
	--@Channel		Nvarchar(10),
	@Searchvalue   nvarchar(1000)  
As  
begin  
	declare @debug int=0
	declare @sql nvarchar(max) = ''  
	declare @sql1 nvarchar(max)=''
	declare @listcolumn_Current nvarchar(max) = ''  
	declare @listcolumn_plus nvarchar(max) = ''  
	declare @listcolumn_plus2 nvarchar(max) = ''  
  
	SELECT @listcolumn_Current = ListColumn FROM fn_FC_GetColheader_Current(@FM_Key,'1. Baseline Qty','f')  
	--SELECT listcolumn_Current = ListColumn FROM fn_FC_GetColheader_Current('202405','1. Baseline Qty','f')  
	SELECT @listcolumn_plus = ListColumn FROM fn_FC_GetColheader_Current(@FM_Key,'1. Baseline Qty_+','x')  
	--SELECT listcolumn_plus = ListColumn FROM fn_FC_GetColheader_Current('202405','1. Baseline Qty_+','x')  
	SELECT @listcolumn_plus2 = ListColumn FROM fn_FC_GetColheader_Current(@FM_Key,'1. Baseline Qty_+','f')  
	--SELECT listcolumn_plus2 = ListColumn FROM fn_FC_GetColheader_Current('202405','1. Baseline Qty_+','f')  
	declare @ListColumn_Pass nvarchar(max) = ''  
	select @ListColumn_Pass = ListColumn from fn_FC_GetColHeader_Historical(@FM_Key,'f',12)  
	--select ListColumn_Pass = ListColumn from fn_FC_GetColHeader_Historical('202403','f',12)  
	--select @sql='select * from FC_BomHeader_'+@Division
	
	select @debug=debug from fnc_debug('FC')

	declare @Monthfc				nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from V_FC_FM_Table
	
	select @sql =  
		'select
			[Bundle Code] = f.[SAP Code],  
			[Bundle name] = f.[Bundle name],  
			Channel = f.Channel,'  
			+@ListColumn_Pass+','  
			+@listcolumn_Current+'  
		from FC_BomHeader_'+@Division+@Monthfc+' f '
		+case
			when len(@Searchvalue)=0 then ''
			when substring(@Searchvalue,2,2) = 'VN' then
				'where f.[Sap Code] IN(select value from string_split('''+@Searchvalue+''','','')) '
			else
				'where f.[Sap Code] IN
				(
					select Distinct
						f1.[Sap Code]
					from FC_BomHeader_'+@Division+@Monthfc+' f1
					inner join  
					(  
						select   
							z1.*  
						from V_ZMR32 z1
						inner join SC1.dbo.MM_ZMR54OLD_Stg m on m.[EAN / UPC]=z1.Barcode_Component
						where m.[Item Category Group]<>''LUMF''
						and z1.Division='''+@Division+'''
						and ISNULL(z1.Barcode_Bom,'''')<>''''
					) z on f1.[SAP Code] = z.Material_Bom
					inner join
					(  
						select DISTINCT     
							Barcode,
							[SUB GROUP/ Brand],
							[Item Category Group]
						from fnc_SubGroupMaster('''+@Division+''',''full'')    
						where [Item Category Group] NOT IN(''LUMF'')      
					) as s on s.Barcode = z.Barcode_Component 
					where s.[SUB GROUP/ Brand] in(select value from string_split('''+@Searchvalue+''','',''))
				)'
			end
			--and f1.Channel IN('''+@Channel+''')
			--select value from string_split('',',')

		if @debug >0  
		begin  
			select @sql '@sql get data'  
		end  
		execute(@sql)  
  
end