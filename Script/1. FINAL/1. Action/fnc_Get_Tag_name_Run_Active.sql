/*
	select * from fnc_Get_Tag_name_Run_Active('CPD')
*/

Alter function fnc_Get_Tag_name_Run_Active(@Division nvarchar(3))
	returns table
As
return 
	select
		tag_name
	from
	(
		select  [Division]='CPD',tag_name=isnull([tag name],'') from FC_Tag_name_Processing_CPD
		Union all
		select  [Division]='LDB',tag_name=isnull([tag name],'') from FC_Tag_name_Processing_LDB
		union all
		select  [Division]='LLD',tag_name=isnull([tag name],'') from FC_Tag_name_Processing_LLD
	) as x
	where [Division]=@Division

