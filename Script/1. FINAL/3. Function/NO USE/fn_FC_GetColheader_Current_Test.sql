/*
	SELECT * FROM fn_FC_GetColheader_Current_Test('202412','updateForecast','si')
	SELECT * FROM fn_FC_GetColheader_Current_Test('202403','updateForecast','si')
*/
Alter Function fn_FC_GetColheader_Current_Test
(
	@FM_KEY			Nvarchar(6),
	@TimeSeries		nvarchar(20),
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
	declare @debug int = 1
	declare		
		 @ForecastDate			date = ''		
		,@currentMonthforcast	int = 0
		,@sql					nvarchar(max) = ''
		,@rowcount1				int = 0
		,@result				nvarchar(MAX) = ''
		,@result2				nvarchar(max) = ''
		,@result0				nvarchar(MAX) = ''
		,@Startmonth			int = 0
		,@Frommonth				date
		,@totalrow				int = 0		

	declare @tmp table
	(
		id				int identity(1,1), 
		[Month_Desc]	nvarchar(20)
	)
	select @currentMonthforcast = cast(right(@FM_KEY,2) as int)
	select @ForecastDate = cast(left(@FM_KEY,4)+'-'+cast(@currentMonthforcast as nvarchar(2))+'-01' as date)
	select @totalrow = 24

	if @TimeSeries = 'FM_Tmp'
	begin
		insert into @tmp
		(	
			Month_Desc
		)
		select
			Month_Desc = Month_Desc
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
	end
	while (@currentMonthforcast <=@totalrow)
	begin
		declare 
			@Current nvarchar(20),
			@Current_year nvarchar(4),
			@current_year_final nvarchar(2) = ''

		declare @StandardMonth int = 0
		if @currentMonthforcast>12
		begin
			select @StandardMonth = case when @currentMonthforcast%12 = 0 then 12 else @currentMonthforcast%12 end
		end
		else
		begin
			select @StandardMonth = @currentMonthforcast
		end
		select @Current_year = year(DATEADD(MM,(@currentMonthforcast-cast(right(@FM_KEY,2) as int)),@ForecastDate))
		select @current_year_final =case 
										when (@Current_year-year(@ForecastDate)) <>0 then 
											'+' 
										else '' 
									end + cast((@Current_year-year(@ForecastDate)) as nvarchar(1))
		select @Current = replace([Month_Desc],'@',@current_year_final) 
		from @tmp 
		where id = @StandardMonth

	
		if @TimeSeries = '3. Promo Qty(BOM)'
		begin
			if len(@result)=0
			begin
				select @result = '['+@Current+'] = sum(CQty*['+@Current+'])'
			end
			else
			begin
				select @result =@result+',['+@Current+'] = sum(CQty*['+@Current+'])'			
			end
		end
		else if @TimeSeries = '1. Baseline Qty'
		begin
			if len(@Alias)>0
			begin
				if len(@result)=0
				begin
					select @result = '['+@Current+'] = isnull('+@Alias+'.['+@Current+'],0) '			
				end
				else
				begin
					select @result =@result+',['+@Current+'] = isnull('+@Alias+'.['+@Current+'],0) '			
				end
			end
			else
			begin
				if len(@result)=0
				begin
					select @result = '['+@Current+'] = sum(ISNULL(Col'+right('00'+cast((@currentMonthforcast-@Startmonth+1) as nvarchar),2)+',0))'			
				end
				else
				begin
					select @result =@result+',['+@Current+'] = sum(ISNULL(Col'+right('00'+cast((@currentMonthforcast-@Startmonth+1) as nvarchar),2)+',0))'			
				end
			end
		end
		else if @TimeSeries = '6. Total Qty'
		begin
			if len(@result)=0
			begin
				select @result = '['+@Current+'] = sum(ISNULL(['+@Current+'],0))'
			end
			else
			begin
				select @result =@result+',['+@Current+'] = sum(ISNULL(['+@Current+'],0))'
			end
		end
		else if @TimeSeries = 'updateForecast'
		begin
			if len(@result)=0
			begin
				select @result = '['+@Current+'] = ISNULL('+@Alias+'.['+@Current+'],0)'
			end
			else
			begin
				select @result =@result+',['+@Current+'] = ISNULL('+@Alias+'.['+@Current+'],0)'			
			end
		end
		else if @TimeSeries = 'SumColumn'
		begin
			if len(@result)=0
			begin
				select @result = '['+@Current+'] = sum(['+@Current+'])'
			end
			else
			begin
				select @result =@result+''+@Alias+'['+@Current+'] = sum(['+@Current+'])'
			end
		end
		else if @TimeSeries = 'FM_Tmp'
		begin
			if len(@result)=0
			begin
				select @result = 'isnull(['+@Current+' '+@Current_year+'],0)'
			end
			else
			begin
				select @result =@result+',isnull(['+@Current+' '+@Current_year+'],0)'
			end
		end
		else if @TimeSeries = 'FM'
		begin
			if len(@result)=0
			begin
				select @result = '[Col'+format((@currentMonthforcast-@Startmonth+1),'00')+']'
			end
			else
			begin
				select @result =@result+',[Col'+format((@currentMonthforcast-@Startmonth+1),'00')+']'
			end
		end
		else if @TimeSeries = 'SIColumTemplate'
		begin
			if len(@result)=0
			begin
				select @result = '[M'+format((@currentMonthforcast-@Startmonth),'0')+'] = 0'
			end
			else
			begin
				select @result =@result+',[M'+format((@currentMonthforcast-@Startmonth),'0')+'] = 0'
			end
		end
		else if @TimeSeries = 'FOCColumn'
		begin
			if len(@result)=0
			begin
				select @result = '['+@Current+'] = [M'+format((@currentMonthforcast-@Startmonth),'0')+']'
			end
			else
			begin
				select @result =@result+',['+@Current+'] = [M'+format((@currentMonthforcast-@Startmonth),'0')+']'
			end
		end
		else if @TimeSeries = 'NewCol'
		begin
			if len(@result)=0
			begin
				select @result = '['+@Current+'] = 0'
			end
			else
			begin
				select @result =@result+',['+@Current+'] = 0'
			end
		end
		else if @TimeSeries = 'BomheaderQty'
		begin
			if len(@result)=0
			begin
				select @result = '['+@Current+'] = sum(ISNULL('+@Alias+'.['+@Current+'],0))'
			end
			else
			begin
				select @result =@result+',['+@Current+'] = sum(ISNULL('+@Alias+'.['+@Current+'],0))'
			end
		end
		select @currentMonthforcast = @currentMonthforcast + 1
	end
	insert into @tmpFinal(ListColumn) values(@result)
	return
end