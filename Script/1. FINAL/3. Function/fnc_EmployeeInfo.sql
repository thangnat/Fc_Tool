/*
	select * from fnc_EmployeeInfo('oanh.tran','') where active = 1
	
	
	select top 1 MaNV,MatMa,TenNV from fnc_EmployeeInfo('ngocchau.truongthi','')

*/

Alter function fnc_EmployeeInfo(@username nvarchar(20),@division nvarchar(3))
	returns table
	with encryption
As
return
select 
	m.MaNV,
	m.MatMa,
	M.TenNV,
	m.NgaySinh,
	f.division,
	f.Filename,
	f.fmkey,
	f.fmkey_new,
	Active = case when f.division = Isnull(M.Division,'') then 1 else 0 end
from DM_NhanVien m
cross join 
(
	select
		*
	from V_FC_CONFIG_TOOL_NAME
) f
where m.MaNV = @username
and (@division = '' or f.Division = @division)