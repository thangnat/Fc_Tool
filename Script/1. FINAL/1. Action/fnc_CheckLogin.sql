/*
	select * from fnc_CheckLogin('adminfc','12345')
	
	
	select MaNV,MatMa,TenNV from fnc_EmployeeInfo('oanh.tran','')
	0x81DC9BDB52D04DC20036DBD8313ED055
	0x81DC9BDB52D04DC20036DBD8313ED055

	select convert(varchar(50),HashBytes('MD5', '12345'),2)
*/

Alter function fnc_CheckLogin(@username nvarchar(50), @password varchar(20))
	returns table
	with encryption
As
return
select
	MaNV,
	TenNV,
	[Password],
	Convert_Password,
	Check_Status = case when [Password]=Convert_Password then 'OK' else '' end
from
(
	select 
		m.MaNV,
		[Password] = m.[Password],
		--Input_Password = @password,
		Convert_Password = convert(varchar(50),HashBytes('MD5', @password),2),
		M.TenNV
	from DM_NhanVien m
	where m.MaNV = @username
) as x