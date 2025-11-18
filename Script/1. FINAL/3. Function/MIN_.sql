/*
	select dbo.MIN_('-2,-1,1,2,3,4,5',0)
	select dbo.MIN_(-5,1)
*/
Alter function MIN_(@array nvarchar(max),@Type_number int)
	returns nvarchar(10)
as
begin
	declare @result_string nvarchar(50)=''
	declare @result_number int=0
	declare @result int=0

	--//eclare @array nvarchar(max)='1,2,3s,4'
	if @Type_number=1
	begin
		select @result_number=case when cast(@array as int)>0 then 0 else cast(@array as int) end
	end
	else
	begin
		select @result_string=min(value) from (select value=cast(value as int) from string_split(@array,',')) as x
	end
	if @Type_number=1
	begin
		select @result=@result_number
	end
	else
	begin
		select @result=@result_string
	end
	return @result
end
/*
	declare @array nvarchar(max)='1,2,3,4,-1'

	select min(value) from (select value=cast(value as int) from string_split(@array,',')) as x	--order by value asc
*/
