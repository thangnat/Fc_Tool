/*
	exec sp_FC_FDR_FOC_TO_VP '202402'
*/
Alter proc sp_FC_FDR_FOC_TO_VP
	@FM_KEY		nvarchar(6)
	with encryption
As
declare 
	@ListColumn_Pass		nvarchar(max) = '',
	@sql					nvarchar(max) = ''

select
	@ListColumn_Pass = ListColumn
from fn_FC_GetColHeader_Historical(@FM_Key,'y',2)

select @sql = 
'select
	[Product type],
	[SUB GROUP/ Brand],
	[SAP Code],'
	+@ListColumn_Pass+'
from His_SI_FDR_FOC_TO_VP_Final y
where isnull([Sap code],'''') <>'''' '

execute(@sql)

--select * from FC_FDR_FOC_TO_VP
/*FC_FDR_FOC_TO_VP*/
