/*
	select * from fnc_FC_Signature('CPD')
*/

Alter Function fnc_FC_Signature(@division nvarchar(3))
returns @tablefinale TABLE
(
	[Signature]				nvarchar(100) null	
)
with encryption
As
begin
	insert into @tablefinale([Signature])
	select DISTINCT
		[Signature]	
	from fnc_SubGroupMaster(@division,'full')
	where isnull([Signature],'')<>''
	return
end