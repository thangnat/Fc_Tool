/*
exec sp_add_FC_SI_Promo_Bom_Tmp 'LLD','SI_PROMO_BOM.xlsx'

select *
from FC_SI_Promo_Bom_Tmp

*/
Create or Alter proc sp_add_FC_SI_Promo_Bom_Tmp
	@Division			nvarchar(3),
	@filename			nvarchar(500)
	with encryption
As
	declare @tablename nvarchar(100) = ''
	declare @sql nvarchar(max) = ''
	select @tablename = 'FC_SI_Promo_Bom_'+@Division+'_Tmp'

	if exists(SELECT * 
		FROM sys.objects 
		WHERE object_id = OBJECT_ID(@tablename) AND type in (N'U')
	)
	begin
		select @sql ='drop table '+@tablename
		execute(@sql)
	end

	select @sql =
	'select
		Filename = '''+@filename+''',
		*
		INTO '+@tablename+'
	From OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',
					''Excel 12.0; HDR=YES; IMEX=1;Database=\\10.240.65.43\loreal\10_PUBLIC\03_SAPData\SC_IMPORT\Pending\FORECAST\'+@Division+'\SELL_IN\'+@filename+''',
					''SELECT * FROM [Sheet1$]'')'

	--select @sql '@sql'
	execute(@sql)