/*
	select * from fnc_get_List_Signature('tag_add_FC_SI_Group_FC_SI_FOC')
*/

Alter function fnc_get_List_Signature(@tag_name nvarchar(500))
	returns table
As
return
	select 
		--[Tag_name]=f.Tag_name,
		List_Signature=replace(isnull(f.[List_Signature],''),'''',''''''),
		Type_View=isnull(f.[Type_View],'')
	from FC_FUNCTION_ACTIVE_FINAL f
	where [host_name]=host_name()
	and Tag_name=@tag_name