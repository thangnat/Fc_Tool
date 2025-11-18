/*
	select * from fnc_get_genarated_status('LDB')
*/
Alter function fnc_get_genarated_status(@Division nvarchar(3))
returns @tablefinale TABLE
(
	[ID]				int identity(1,1),
	[Tag Name]			nvarchar(300),
	[Action Name]		nvarchar(10),
	[Generated Data]	nvarchar(300),
	[Gen Status]		nvarchar(200),
	[Error message]		nvarchar(50),
	[Add Date]			datetime,
	[Alias Error Name]	nvarchar(50)
)
with encryption
As
begin
	declare @patchkey nvarchar(50) = ''

	select top 1 
		@patchkey = Patchkey 
	from FC_Table_Status 
	where 
		Division = @Division
	order by 
		adddate desc


	insert into @tablefinale
	(
		[Tag Name],
		[Generated Data],
		[Gen Status],
		[Error message],
		[Action Name],
		[Add Date],
		[Alias Error Name]
	)
	select
		[Tag Name],
		[Generated Data],
		[Gen Status],
		[Error message],
		[Action Name],
		[Add Date],
		[Alias Error Name]
	from
	(
		select 
			[STT]=s.STT,
			[Tag Name]=s.Tag_name,
			[Generated Data]=tv.Caption,
			[Gen Status]=s.ErrorMessage,
			[Error message]='',
			[Action Name]=s.ActionName,
			[Add Date]=s.AddDate,
			[Alias Error Name]=tv.[Alias Error Name]
		from (select * from FC_Table_Status) s
		inner join 
		(
			select
				*
			from fnc_TypeView('','a','')
		) tv on tv.Tag_name=s.Tag_name
		where 
			Division = @Division
		and Patchkey = @patchkey
		and s.Tag_name NOT IN('tag_create_FC_FM_Original')
	) as x
	order by STT asc
		
	return
end