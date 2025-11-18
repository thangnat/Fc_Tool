/*
	SELECT * FROM fn_FC_GetColheader_Forecast('202402','si')
*/
Alter Function fn_FC_GetColheader_Forecast
(
	@FM_KEY			Nvarchar(6),
	@Alias			nvarchar(10)
)
returns @tmpFinal TABLE 
(
	id				int identity(1,1), 
	[ListColumn]	nvarchar(max)
)
with encryption
As
begin
	declare 
		 @debug					int = 1
		,@Current_key			date = cast(left(@FM_KEY,4)+'-'+substring(@FM_KEY,5,2)+'-01' as date)
		,@currentYear			nvarchar(4) = ''
		,@sql					nvarchar(max) = ''
		,@rowcount1				int = 0
		,@result				nvarchar(MAX) = ''
		,@result2				nvarchar(max) = ''
		,@result0				nvarchar(MAX) = ''

	declare @tmp table
	(
		id				int identity(1,1),
		[Month_Desc]	nvarchar(20)
	)
	
	select @currentYear = year(@Current_key)
	if MONTH(DATEADD(MM,-1,@Current_key))=12
	begin
		insert into @tmp
		(	
			Month_Desc
		)
		select		
			Month_Desc = [Current]
		from V_Month_Master		
	end
	else
	begin
		insert into @tmp
		(			
			Month_Desc
		)
		select		
			Month_Desc = [Current]
		from V_Month_Master
		where Month_Number>MONTH(DATEADD(MM,-1,@Current_key))
	end

	insert into @tmp
	(	
		Month_Desc
	)
	select
		Month_Desc = [Current]
	from V_Month_Master

	select @rowcount1 = isnull(count(*),0) from @tmp
	if @rowcount1 <17
	begin
		insert into @tmp
		(
			Month_Desc
		)
		select 
			Month_Desc = [Current]
		from V_Month_Master		
	end
	
	declare @totalrow int = 0, @currentrow int = 1
	select @totalrow = count(*) from @tmp

	while (@currentrow <=@totalrow)
	begin
		declare @Current nvarchar(20), @Current_year nvarchar(4),@current_year_final nvarchar(2) = ''
		
		select @Current_year = year(DATEADD(MM,(@currentrow-1),@Current_key))
		select @current_year_final =case when (@Current_year-year(@Current_key)) <>0 then '+' else '' end +cast((@Current_year-year(@Current_key)) as nvarchar(1))
		select @Current = replace([Month_Desc],'@',@current_year_final) from @tmp where id = @currentrow		

		if len(@result)=0
		begin
			select @result = '['+@Current+'] = ISNULL('+@Alias+'.['+@Current+'],0)'
		end
		else
		begin
			select @result =@result+',['+@Current+'] = ISNULL('+@Alias+'.['+@Current+'],0)'			
		end
		
		select @currentrow = @currentrow + 1
	end
	insert into @tmpFinal(ListColumn) values(@result)
	return
end