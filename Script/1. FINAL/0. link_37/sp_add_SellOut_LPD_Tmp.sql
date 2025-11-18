/*
	exec sp_add_SellOut_LPD_Tmp 'data_2025_01_07T101118.363.xlsx'

	select *
	from LPD_Sell_Out_Tmp where filename='data_2024_11_05T160921_089.xlsx'

	select * from Link_33.sc2.dbo.LPD_Sell_Out where filename='data_2025_01_07T101118.363.xlsx'
*/

Create or Alter proc sp_add_SellOut_LPD_Tmp
	@filename			nvarchar(500)
	with encryption
As
declare @SharefolderPath nvarchar(500)
select @SharefolderPath = Value from [SC2].[dbo].[EnvironmentConfig] where Name = 'Sharefolder_SAP_Dir'

if exists(SELECT * 
	FROM sys.objects 
	WHERE object_id = OBJECT_ID('LPD_Sell_Out_Tmp') AND type in (N'U'))
	drop table LPD_Sell_Out_Tmp

declare @sql nvarchar(max) = ''
select @sql =
'select
	Filename = '''+@filename+''',
	*
	INTO LPD_Sell_Out_Tmp
From OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',
				''Excel 12.0; HDR=YES; IMEX=1;Database='+@SharefolderPath +'\Pending\SELL_OUT\LPD\'+@filename+''',
				''SELECT * FROM [Export$]'')'

--select @sql '@sql'
execute(@sql)

Insert into Link_33.sc2.dbo.LPD_Sell_Out
(
	[Filename],
	[Year],
	[Month Year],
	[Date],
	[Brand Hierarchy - Brand],
	[Brand Hierarchy - Channel],
	[Brand Hierarchy - Store],
	[Franchise - EAN / UPC],
	[Franchise - Material Description (Eng)],
	[Revenue],
	[Units]
)
select
	[Filename],
	[Year],
	[Month Year],
	[Date],
	[Brand Hierarchy - Brand],
	[Brand Hierarchy - Channel],
	[Brand Hierarchy - Store],
	[Franchise - EAN / UPC],
	[Franchise - Material Description (Eng)],
	[Revenue],
	[Units]
from LPD_Sell_Out_Tmp