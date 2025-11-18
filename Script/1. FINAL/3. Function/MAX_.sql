/*
	select dbo.Max_('-2,-1,1,2,3,4,5')
*/
Alter function MAX_(@array nvarchar(max))
	returns nvarchar(10)
as
begin
	declare @result nvarchar(50)=''
	--//eclare @array nvarchar(max)='1,2,3,4'

	select @result=max(value) from (select value=cast(value as int) from string_split(@array,',')) as x

	return @result
end
/*
	declare @array nvarchar(max)='1,2,3,4,-1'

	select min(value) from (select value=cast(value as int) from string_split(@array,',')) as x	--order by value asc
*/