/*	
	exec sp_getColumCount_New 'FC_FM_Non_Modeling_LLD_202411_Tmp'

	select @TotalColumn '@TotalColumn'

	select * from link_33.sc2.dbo.FC_TotalCOlumn_Tmp
*/

Create or Alter proc sp_getColumCount_New
	@tablename		nvarchar(100)
	with encryption
As
declare @TotalColumn	int = 0
select
	@TotalColumn = isnull(count(*),0)
from
(
	SELECT
		TABLE_NAME,
		COLUMN_NAME,
		[YEAR] = right(COLUMN_NAME,4),
		[MONTH] = case 
					when substring(COLUMN_NAME,1,len(COLUMN_NAME)-5) = 'Jan' then 1
					when substring(COLUMN_NAME,1,len(COLUMN_NAME)-5) = 'Feb' then 2
					when substring(COLUMN_NAME,1,len(COLUMN_NAME)-5) = 'Mar' then 3
					when substring(COLUMN_NAME,1,len(COLUMN_NAME)-5) = 'Apr' then 4
					when substring(COLUMN_NAME,1,len(COLUMN_NAME)-5) = 'May' then 5
					when substring(COLUMN_NAME,1,len(COLUMN_NAME)-5) = 'June' then 6
					when substring(COLUMN_NAME,1,len(COLUMN_NAME)-5) = 'July' then 7
					when substring(COLUMN_NAME,1,len(COLUMN_NAME)-5) = 'Aug' then 8
					when substring(COLUMN_NAME,1,len(COLUMN_NAME)-5) = 'Sept' then 9
					when substring(COLUMN_NAME,1,len(COLUMN_NAME)-5) = 'Oct' then 10
					when substring(COLUMN_NAME,1,len(COLUMN_NAME)-5) = 'Nov' then 11
					when substring(COLUMN_NAME,1,len(COLUMN_NAME)-5) = 'Dec' then 12
				end
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE table_catalog = 'master' -- the database
	   AND table_name = @tablename
	   and isnumeric(right(COLUMN_NAME,4))>0
) as x

--select @TotalColumn
--select * from link_33.SC2.dbo.FC_TotalCOlumn_Tmp

update link_33.SC2.dbo.FC_TotalCOlumn_Tmp
set TotalColumn = @TotalColumn
--where tablename = @tablename
--Order by
--	[YEAR] Asc,
--	[MONTH] asc

--select @TotalColumn '@TotalColumn'
--select substring('Apr 2025',1,len('Apr 2025')-5) 

--select *
--FROM INFORMATION_SCHEMA.COLUMNS
--WHERE table_catalog = 'master' -- the database
--	   AND table_name = 'FC_FM_LDB_Tmp'
--	   and isnumeric(right(COLUMN_NAME,4))>0