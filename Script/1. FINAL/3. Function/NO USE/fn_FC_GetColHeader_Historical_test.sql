/*
	select * from fn_FC_GetColHeader_Historical_test('202403','si',4)
*/
Alter function fn_FC_GetColHeader_Historical_test
(
	@FM_KEY		Nvarchar(6),
	@Alias		nvarchar(5),
	@Type		int 
	/*
		0: = 0,set his qty = 0; 
		1: sum get his_quantity SINGLE,
		11: sum get his_quantity BOM,
		2: get column = column;
		3: column header; 
		4: sum o+o detail
		9: sum get his_quantity SINGLE MTD
		99: sum get his_quantity BOM MTD
	*/
)
returns @tmpFinal table
(
	id				int identity(1,1), 
	[ListColumn]	nvarchar(max)
)
with encryption
As
begin
declare
	@ForecastDate		date = '',
	@Frommonth			date = '',
	@Tomonth			date = '',
	@totalmonth			int = 0,
	@currentMonthforcast		int = 0,
	@FirstMonthHis		int = 0,
	@FirstYearHis		int = 0,
	@result				nvarchar(max) = ''
	

	select @currentMonthforcast = cast(right(@FM_KEY,2) as int)
	select @ForecastDate = cast(left(@FM_KEY,4)+'-'+cast(@currentMonthforcast as nvarchar(2))+'-01' as date)
	select @frommonth = cast(cast((cast(left(@FM_KEY,4) as int)-2) as nvarchar(4))+'-01-01' as date)
	select @FirstMonthHis = month(@Frommonth),@FirstYearHis = year(@Frommonth)
	--cast(format(dateadd(MM,-24,cast(left(@FM_KEY,4)+'-'+right(@FM_KEY,2)+'-01' as date)),'yyyy-MM-dd') as date)
	select @Tomonth=eomonth(DATEADD(MM,-1,@ForecastDate),0)
	select @totalmonth = DATEDIFF(MM,@Frommonth,@ForecastDate)--month(@Frommonth)+24

	while (@FirstMonthHis <=@totalmonth)
	begin
		declare @StandardMonth int = 0, @month_desc nvarchar(20) = '',@Current_year int,@current_year_final nvarchar(2) = ''
		if @FirstMonthHis>12
		begin
			select @StandardMonth = case when @FirstMonthHis%12 = 0 then 12 else @FirstMonthHis%12 end
		end
		else
		begin
			select @StandardMonth = @FirstMonthHis
		end
		
		select @Current_year = year(DATEADD(MM,@FirstMonthHis-1,@frommonth))
		select @current_year_final =@Current_year-year(@frommonth)-2
		select @month_desc = replace([Pass],'@',@current_year_final) from V_Month_Master where Month_Number = @StandardMonth
		
		if @Type = 0
		begin
			if len(@result)=0
			begin
				select @result = '['+@month_desc+']=0 '
			end
			else
			begin
				select @result = @result+',['+@month_desc+']=0'
			end
		end
		else if @Type = 1
		begin
			if len(@result)=0
			begin
				select @result = '['+@month_desc+']=sum(case when h.[Pass Column Header] = '''+@month_desc+''' then isnull(h.HIS_QTY_SINGLE,0) else 0 end)'
			end
			else
			begin
				select @result = @result+',['+@month_desc+']=sum(case when h.[Pass Column Header] = '''+@month_desc+''' then isnull(h.HIS_QTY_SINGLE,0) else 0 end)'
			end
		end
		else if @Type = 21
		begin
			if len(@result)=0
			begin
				select @result = '['+@month_desc+']=sum(case when h.[Pass Column Header] = '''+@month_desc+''' then isnull(h.HIS_QTY_FOC,0) else 0 end)'
			end
			else
			begin
				select @result = @result+',['+@month_desc+']=sum(case when h.[Pass Column Header] = '''+@month_desc+''' then isnull(h.HIS_QTY_FOC,0) else 0 end)'
			end
		end
		--else if @Type = 9
		--begin
		--	if len(@result)=0
		--	begin
		--		select @result = '['+@month_desc+']=sum(isnull(h.HIS_QTY_SINGLE,0))'
		--	end
		--	else
		--	begin
		--		select @result = @result+',['+@month_desc+']=sum(isnull(h.HIS_QTY_SINGLE,0))'
		--	end
		--end
		else if @Type = 11
		begin
			if len(@result)=0
			begin
				select @result = '['+@month_desc+']=sum(case when h.[Pass Column Header] = '''+@month_desc+''' then isnull(h.HIS_QTY_BOM,0) else 0 end)'
			end
			else
			begin
				select @result = @result+',['+@month_desc+']=sum(case when h.[Pass Column Header] = '''+@month_desc+''' then isnull(h.HIS_QTY_BOM,0) else 0 end)'
			end
		end
		--else if @Type = 211
		--begin
		--	if len(@result)=0
		--	begin
		--		select @result = '['+@month_desc+']=sum(case when h.[Pass Column Header] = '''+@month_desc+''' then isnull(h.HIS_QTY_BOM_FDR,0) else 0 end)'
		--	end
		--	else
		--	begin
		--		select @result = @result+',['+@month_desc+']=sum(case when h.[Pass Column Header] = '''+@month_desc+''' then isnull(h.HIS_QTY_BOM_FDR,0) else 0 end)'
		--	end
		--end
		--else if @Type = 99
		--begin
		--	if len(@result)=0
		--	begin
		--		select @result = '['+@month_desc+']=sum(isnull(h.HIS_QTY_BOM,0))'
		--	end
		--	else
		--	begin
		--		select @result = @result+',['+@month_desc+']=sum(isnull(h.HIS_QTY_BOM,0))'
		--	end
		--end
		else if @Type = 2
		begin
			if len(@result)=0
			begin
				select @result = '['+@month_desc+']=isnull('+@Alias+'.['+@month_desc+'],0)'
			end
			else
			begin
				select @result = @result+',['+@month_desc+']=isnull('+@Alias+'.['+@month_desc+'],0)'
			end
		end
		else if @Type = 3
		begin
			if len(@result)=0
			begin
				select @result = '['+@month_desc+']='+@Alias+'.['+@month_desc+']'
			end
			else
			begin
				select @result = @result+',['+@month_desc+']='+@Alias+'.['+@month_desc+']'
			end
		end
		else if @Type = 4
		begin
			if len(@result)=0
			begin
				select @result = '['+@month_desc+']=sum(isnull(['+@month_desc+'],0))'
			end
			else
			begin
				select @result = @result+',['+@month_desc+']=sum(isnull(['+@month_desc+'],0))'
			end
		end
		else if @Type = 12
		begin
			if len(@result)=0
			begin
				select @result = '['+@month_desc+']=isnull('+@Alias+'.['+@month_desc+'],0)'
			end
			else
			begin
				select @result = @result+',['+@month_desc+']=isnull('+@Alias+'.['+@month_desc+'],0)'
			end
		end
		else if @Type = 111
		begin
			if len(@result)=0
			begin
				select @result = '['+@month_desc+']=sum(case when h.[Pass Column Header] = '''+@month_desc+''' then isnull(h.HIS_QTY_BOM_HEADER,0) else 0 end)'
			end
			else
			begin
				select @result = @result+',['+@month_desc+']=sum(case when h.[Pass Column Header] = '''+@month_desc+''' then isnull(h.HIS_QTY_BOM_HEADER,0) else 0 end)'
			end
		end
		else if @Type = 2111
		begin
			if len(@result)=0
			begin
				select @result = '['+@month_desc+']=sum(case when h.[Pass Column Header] = '''+@month_desc+''' then isnull(h.HIS_QTY_BOM_HEADER_FDR,0) else 0 end)'
			end
			else
			begin
				select @result = @result+',['+@month_desc+']=sum(case when h.[Pass Column Header] = '''+@month_desc+''' then isnull(h.HIS_QTY_BOM_HEADER_FDR,0) else 0 end)'
			end
		end
		else if @Type = 3111
		begin
			if len(@result)=0
			begin
				select @result = '['+@month_desc+']=sum(case when h.[Pass Column Header] = '''+@month_desc+''' then isnull(h.HIS_QTY_FOC_TO_VP,0) else 0 end)'
			end
			else
			begin
				select @result = @result+',['+@month_desc+']=sum(case when h.[Pass Column Header] = '''+@month_desc+''' then isnull(h.HIS_QTY_FOC_TO_VP,0) else 0 end)'
			end
		end
		select @FirstMonthHis=@FirstMonthHis+1
	end

	insert into @tmpFinal(ListColumn)
	select @result as ListColumn
	
	return
end