/*
	exec sp_getlistfiles '\\10.240.65.43\SC_IMPORT\Pending\FORECAST\LDB\OPTIMUS\','OLD'

	select * from LDB_ListFile_Optimus
*/

Alter proc sp_getlistfiles
	@path			nvarchar(1000),
	@Folder_ignore	nvarchar(50)
	with encryption
As
begin
	--create TABLE LDB_ListFile_Optimus
	--(
	--	[id]		int identity(1,1),
	--	[filename]	nvarchar(500) null
	--)
	declare @path_ok nvarchar(1000)=''
	declare @sql nvarchar(max)=''
	declare @debug int=1
	select @path_ok='dir /B '+@path

	--declare @path nvarchar(max)='\\10.240.65.43\loreal\10_PUBLIC\03_SAPData\SC_IMPORT\Pending\FORECAST\LDB\SELL_IN\OPTIMUS\'
	declare @tmplistfile0 table (id int identity(1,1), filename nvarchar(500) null)
	--declare @tmplistfile table (id int identity(1,1), filename nvarchar(500) null)

	insert into @tmplistfile0(filename)
	EXEC xp_cmdshell @path_ok;--'dir /B "\\10.240.65.43\loreal\10_PUBLIC\03_SAPData\SC_IMPORT\Pending\FORECAST\LDB\SELL_IN\OPTIMUS\"';
	--EXEC xp_cmdshell 'dir /B "\\10.240.65.43\loreal\10_PUBLIC\03_SAPData\SC_IMPORT\Pending\FORECAST\LDB\SELL_IN\"';

	truncate table LDB_ListFile_Optimus

	insert into LDB_ListFile_Optimus
	(
		filename
	) 
	select filename 
	from @tmplistfile0 
	where 
		filename is not null 
	and filename not in(select value from string_split(@Folder_ignore,','))

	--select tablename = '@tmplistfile',* from LDB_ListFile_Optimus
end