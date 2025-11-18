/*
	select dbo.fn_FileExists('\\10.240.65.43\SC_IMPORT\Pending\FORECAST\CPD\B_T\FC_Budget_Trend_202501.xlsx')

	declare @result INT
	EXEC master.dbo.xp_fileexist '\\10.240.65.43\loreal\10_PUBLIC\03_SAPData\SC_IMPORT\Pending\FORECAST\CPD\MasterFile\BFL_MASTER_202501.xlsx', @result OUTPUT

	select @result '@result'
*/

Create or Alter FUNCTION fn_FileExists(@path varchar(8000))
RETURNS nvarchar(50)
AS
BEGIN
     DECLARE @result INT
     EXEC master.dbo.xp_fileexist @path, @result OUTPUT
	 --select @result='1'
     RETURN cast(@result as bit)
	--DECLARE @File_Exists INT;
	--EXEC Master.dbo.xp_fileexist 
	--	'\\10.240.65.43\loreal\10_PUBLIC\03_SAPData\SC_IMPORT\Pending\FORECAST\CPD\MasterFile\BFL_MASTER_202501.xlsx', @File_Exists OUT;

	--SELECT @result=CASE @File_Exists
	--		WHEN 1
	--		THEN 'File Exists'
	--		WHEN 0
	--		THEN 'File Not Exists'
	--	END-- AS Result;
	--return cast('1' as bit)--@result
END
GO