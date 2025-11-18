/*
exec sp_add_FC_ZV14_Report_Tmp 'CPD','ZV14_02_SINGLE_Jan_2024.XLSX'

select *
from FC_CPD_ZV14_Report_Tmp
*/

Create or Alter proc sp_add_FC_ZV14_Report_Tmp
	@Dvision			nvarchar(3),
	@filename			nvarchar(500)
	with encryption
As
declare @tablename nvarchar(50) = 'FC_'+@Dvision+'_ZV14_Report_Tmp'
declare @sql nvarchar(max) = ''

declare @SharefolderPath nvarchar(500)
select @SharefolderPath = Value from [SC2].[dbo].[EnvironmentConfig] where Name = 'Sharefolder_SAP_Dir'

if exists(SELECT * 
	FROM sys.objects 
	WHERE object_id = OBJECT_ID(@tablename) AND type in (N'U'))
	select @sql = 'drop table '+@tablename
	execute(@sql)

select @sql =
'select
	Filename = '''+@filename+''',
	*
	INTO '+@tablename+'
From OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',
				''Excel 12.0; HDR=YES; IMEX=1;Database='+@SharefolderPath+'\Pending\FORECAST\ZV14\'+@filename+''',
				''SELECT * FROM [Sheet1$]'')'

--select @sql '@sql'

execute(@sql)