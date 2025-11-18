/*
	select ActionName =Tag_name,* from fnc_TypeView('','a','') order by STT asc
*/
Alter function fnc_TypeView
(
	@Typeview		nvarchar(20),
	@level			Nvarchar(1),
	@tag_name		nvarchar(200)
)--//level = p: parent, c: child
	returns table
	with encryption
As
return
select
	[ID],
	[Tag_name],
	[Caption],
	[Active],
	[BeginTran],
	[STT],
	[Alias Error Name]
from
(
	select 
		[ID],
		[Tablename] = '',
		[Tag_name],
		[Caption],
		[Active] = case when (cast(GEN as int)+BOM+[PARTIAL]+[VALUE])>0 then 1 else 0 end,
		[BeginTran],
		[STT],
		[Alias Error Name]
	from V_FC_WF_FUNCTION_ACTIVE_NEW
	where 
		GEN>0 
	and (@tag_name ='' or tag_name = @tag_name)
	and case when @level = 'a' then 1 when @level = 'p' then Parent when @level = 'c' then Child end > 0
	and case when @level = 'c' then 1 else IsAction end >0
	--union All
	--select 
	--	ID,
	--	Tablename = 'RE-GEN',
	--	Tag_name,
	--	[Active] = case when (cast(GEN as int)+BOM+[PARTIAL]+[VALUE])>0 then 1 else 0 end,
	--	BeginTran,
	--	STT
	--from V_FC_WF_FUNCTION_ACTIVE_NEW
	--where 
	--	[Re-Gen]>0 
	--and (@tag_name ='' or tag_name = @tag_name)
	--and case when @level = 'a' then 1 when @level = 'p' then Parent when @level = 'c' then Child end > 0
	--and case when @level = 'c' then 1 else IsAction end >0
) as x
where Tablename = @Typeview
	
