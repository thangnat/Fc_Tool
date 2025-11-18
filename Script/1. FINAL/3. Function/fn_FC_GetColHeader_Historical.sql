/*
	select * from fn_FC_GetColHeader_Historical('202407','si',102)
	select * from fn_FC_GetColHeader_Historical('202407','si',1000)
	select * from fn_FC_GetColHeader_Historical('202403','si',95)
	select * from fn_FC_GetColHeader_Historical('202402','si',93)-->AVG FW-->sisosit data
	select * from fn_FC_GetColHeader_Historical('202402','si',94)-->AVG BW -->sisosit data

	select * from fn_FC_GetColHeader_Historical('202402','si',92)-->AVG BW -->Y0
	select * from fn_FC_GetColHeader_Historical('202402','si',91)-->AVG FW -->Y0
	
	select * from fn_FC_GetColHeader_Historical('202402','si',90)-->AVG BW -->Y-1
	select * from fn_FC_GetColHeader_Historical('202402','si',89)-->AVG FW -->Y-1

	select * from fn_FC_GetColHeader_Historical('202403','si',86)-->A pass value =0
	select * from fn_FC_GetColHeader_Historical('202403','si',88)-->C pass value actual

	select * from fn_FC_GetColHeader_Historical('202404','si',97)-->B-->no need
*/
Alter function fn_FC_GetColHeader_Historical
(
	@FM_KEY		Nvarchar(6),
	@Alias		nvarchar(5),
	@Type		int
	/*
		0: = 0,set his qty = 0; 
		1: sum get his_quantity SINGLE,
		11: sum get his_quantity BOM,
		2: get column = column;
		22: get colimn unit * RSP(price)
		3: column header; 
		4: sum o+o detail
		9: sum get his_quantity SINGLE MTD
		99: sum get his_quantity BOM MTD
		98: get 3 month pass SO
		97: AVG of 98
		96: list periodkey of 97
		95: List FC SI 6M
		94: BW List month by current month on SISOSIT
		93: FW List month by current month on SISOSIT
		92: BW List month by current month on SellIn Y0
		91: FW List month by current month on SellIn Y0
		90: BW List month by current month on SellIn Y-1
		89: FW List month by current month on SellIn Y-1
		86: pass value = 0
		88: pass value actual
		85: m-1 value = 0
		87: m-1 value actual
		80: Backup Historical
		100: get list error alert
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
	@ForecastDate			date = '',
	@Frommonth				date = '',
	--@Tomonth				date = '',
	@totalmonth				int = 0,
	@currentMonthforcast	int = 0,
	@FirstMonthHis			int = 0,
	@FirstYearHis			int = 0,
	@month_desc_current		nvarchar(20) = '',
	@result					nvarchar(max) = ''
	
	select @currentMonthforcast = cast(right(@FM_KEY,2) as int)
	select @ForecastDate = cast(left(@FM_KEY,4)+'-'+cast(@currentMonthforcast as nvarchar(2))+'-01' as date)
	select @frommonth = cast(cast((cast(left(@FM_KEY,4) as int)-2) as nvarchar(4))+'-01-01' as date)
	select @FirstMonthHis = month(@Frommonth),@FirstYearHis = year(@Frommonth)
	
	--cast(format(dateadd(MM,-24,cast(left(@FM_KEY,4)+'-'+right(@FM_KEY,2)+'-01' as date)),'yyyy-MM-dd') as date)
	--select @Tomonth=eomonth(DATEADD(MM,-1,@ForecastDate),0)
	select @totalmonth = DATEDIFF(MM,@Frommonth,@ForecastDate)--month(@Frommonth)+24

	if @Type in(89,90,91,92,93,94)
	begin
		select @FirstMonthHis = 0,@totalmonth = 2
		select @month_desc_current = format(DATEADD(MM,@FirstMonthHis,@ForecastDate),'yyyyMM')
	end
	else if @Type in(96,97,98)
	begin
		select @FirstMonthHis = 0,@totalmonth = 2
		select @month_desc_current = format(DATEADD(MM,@FirstMonthHis,@ForecastDate),'yyyyMM')
	end
	else if @Type in(95,955)
	begin
		select @FirstMonthHis = 0,@totalmonth = 5
	end
	else if @Type in(80)--backup historical
	begin
		select @FirstMonthHis = 1,@totalmonth = 24
	end
	if @Type = 4444
	begin
		select @FirstMonthHis=13,@totalmonth = 24
	end
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
		if @Type IN(95,955)
		begin
			select @Current_year = year(DATEADD(MM,@FirstMonthHis+1,@frommonth))
		end
		else
		begin
			select @Current_year = year(DATEADD(MM,@FirstMonthHis-1,@frommonth))
		end
		select @current_year_final =@Current_year-year(@frommonth)-2
		
		--if @Type in(97,98)
		--begin
		--	select @month_desc = format(DATEADD(MM,-1*@FirstMonthHis,@ForecastDate),'yyyyMM')
		--end
		if @Type in(96,97,98)
		begin
			select @month_desc = format(DATEADD(MM,-1*(@FirstMonthHis+1),@ForecastDate),'yyyyMM')
		end
		else if @Type in(95,955,92,91,89,90)
		begin
			declare @month_raw nvarchar(6) = ''
			if @Type in(93,91,89)-->Forward
			begin
				select @month_raw = format(DATEADD(MM,@FirstMonthHis,@ForecastDate),'yyyyMM')
			end
			else if @Type in(94,92,90)-->pass
			begin
				select @month_raw = format(DATEADD(MM,-1*(@FirstMonthHis+1),@ForecastDate),'yyyyMM')
			end
			else if @Type IN(95,955)
			begin
				select @month_raw = format(DATEADD(MM,@FirstMonthHis+1,@ForecastDate),'yyyyMM')
			end
			else
			begin
				select @month_raw = format(DATEADD(MM,-1*(@FirstMonthHis+1),@ForecastDate),'yyyyMM')
			end
			select @StandardMonth = cast(right(@month_raw,2) as int)
			select @Current_year = cast(left(@month_raw,4) as int)
			if @Type in(89,90)
			begin
				select @current_year_final =@Current_year-year(@ForecastDate)-1
			end
			else
			begin
				select @current_year_final =@Current_year-year(@ForecastDate)
			end
			
			select @month_desc = replace([Pass],'@',case when @current_year_final>0 then '+'+@current_year_final else @current_year_final end) 
			from V_Month_Master 
			where Month_Number = @StandardMonth
		end
		else if @Type in(94)
		begin			
			select @month_desc = format(DATEADD(MM,-1*@FirstMonthHis,@ForecastDate),'yyyyMM')			
		end
		else if @Type in(93)
		begin						
			select @month_desc = format(DATEADD(MM,@FirstMonthHis+1,@ForecastDate),'yyyyMM')
		end
		--else if @Type in(92)
		--begin			
		--	select @month_desc = format(DATEADD(MM,-1*@FirstMonthHis,@ForecastDate),'yyyyMM')			
		--end
		--else if @Type in(91)
		--begin			
		--	select @month_desc = format(DATEADD(MM,@FirstMonthHis+1,@ForecastDate),'yyyyMM')			
		--end
		else
		begin
			select @month_desc = replace([Pass],'@',case when @current_year_final>0 then '+'+@current_year_final else @current_year_final end) 
			from V_Month_Master 
			where Month_Number = @StandardMonth
		end
		--//-------------------------------------------------------------------------------------------------------------------------
		if @Type = 89--FW
		begin
			if len(@result)=0
			begin
				select @result = '(['+@month_desc+']'
			end
			else
			begin
				select @result = @result+'+['+@month_desc+']'+case when @FirstMonthHis=2 then ')/3' else '' end
			end
		end
		if @Type = 80--backup historical
		begin
			if len(@result)=0
			begin
				select @result = '['+@month_desc+'] = '+@Alias+'.['+@month_desc+']'
			end
			else
			begin
				select @result = @result+',['+@month_desc+'] = '+@Alias+'.['+@month_desc+']'
			end
		end
		if @Type = 1000--phep cong
		begin
			if len(@result)=0
			begin
				select @result = @Alias+'.['+@month_desc+']'
			end
			else
			begin
				select @result = @result+'+'+@Alias+'.['+@month_desc+']'
			end
		end
		else if @Type = 90--BW
		begin
			if len(@result)=0
			begin
				select @result = '(['+@month_desc+']'
			end
			else
			begin
				select @result = @result+'+['+@month_desc+']'+case when @FirstMonthHis=2 then ')/3' else '' end
			end
		end
		else if @Type = 91--FW Y0
		begin
			if len(@result)=0
			begin
				select @result = '(['+@month_desc+']'
			end
			else
			begin
				select @result = @result+'+['+@month_desc+']'+case when @FirstMonthHis=2 then ')/3' else '' end
			end
		end
		else if @Type = 92--BW Y0
		begin
			if len(@result)=0
			begin
				select @result = '(['+@month_desc+']'
			end
			else
			begin
				select @result = @result+'+['+@month_desc+']'+case when @FirstMonthHis=2 then ')/3' else '' end
			end
		end
		else if @Type = 93--FW
		begin
			if len(@result)=0
			begin
				select @result = 'select isnull((select sum(EndStock) from FC_CPD_SO_HIS_FINAL where PeriodKey in('''+@month_desc_current+'''))/(select avg([sellOut]) from FC_CPD_SO_HIS_FINAL where PeriodKey in('''+@month_desc+''','
			end
			else
			begin
				select @result = @result+''''+@month_desc+''''+case when @FirstMonthHis=2 then '))*30,0)' else ',' end
			end
		end
		else if @Type = 94--BW
		begin
			if len(@result)=0
			begin
				select @result = 'select isnull((select sum(EndStock) from FC_CPD_SO_HIS_FINAL where PeriodKey in('''+@month_desc_current+'''))/(select avg([sellOut]) from FC_CPD_SO_HIS_FINAL where PeriodKey in('''+@month_desc+''','
			end
			else
			begin
				select @result = @result+''''+@month_desc+''''+case when @FirstMonthHis=2 then '))*30,0)' else ',' end
			end
		end
		else if @Type = 95-->list month fc si 6M
		begin
			if len(@result)=0
			begin
				select @result = '('+@Alias+'.['+@month_desc+']+'
			end
			else
			begin
				select @result = @result+''+@Alias+'.['+@month_desc+']'+case when @FirstMonthHis=5 then ')' else '+' end
			end
		end
		else if @Type = 955-->list month fc si 6M sum
		begin
			if len(@result)=0
			begin
				select @result = '['+@month_desc+']=sum(['+@month_desc+'])'
			end
			else
			begin
				select @result = @result+',['+@month_desc+']=sum(['+@month_desc+'])'
			end
		end
		if @Type = 999
		begin
			if len(@result)=0
			begin
				select @result = '['+@month_desc+']'
			end
			else
			begin
				select @result = @result+'+['+@month_desc+']'
			end
		end
		else if @Type = 0
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
		else if @Type = 2222
		begin
			if len(@result)=0
			begin
				select @result = '['+@month_desc+']= cast(''0'' as numeric(18,0)) '
			end
			else
			begin
				select @result = @result+',['+@month_desc+']=cast(''0'' as numeric(18,0)) '
			end
		end
		else if @Type = 22221
		begin
			if len(@result)=0
			begin
				select @result = '[(Value)_'+@month_desc+']= case when f.[Time series]=''3. Promo Qty(BOM)'' then  f.['+@month_desc+']*s.['+@month_desc+'] else 0 end'
			end
			else
			begin
				select @result = @result+',[(Value)_'+@month_desc+']= case when f.[Time series]=''3. Promo Qty(BOM)'' then  f.['+@month_desc+']*s.['+@month_desc+'] else 0 end'
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
		else if @Type = 2
		begin
			if len(@result)=0
			begin
				select @result = '['+@month_desc+']=cast(isnull('+@Alias+'.['+@month_desc+'],0) as int)'
			end
			else
			begin
				select @result = @result+',['+@month_desc+']=cast(isnull('+@Alias+'.['+@month_desc+'],0) as int)'
			end
		end
		else if @Type = 4444
		begin
			if len(@result)=0
			begin
				select @result = '['+@month_desc+']=cast(isnull('+@Alias+'.['+@month_desc+'],0) as int)'
			end
			else
			begin
				select @result = @result+',['+@month_desc+']=cast(isnull('+@Alias+'.['+@month_desc+'],0) as int)'
			end
		end
		else if @Type = 222212
		begin
			if len(@result)=0
			begin
				select @result = '[(Value)_'+@month_desc+']=isnull('+@Alias+'.['+@month_desc+'],0)'
			end
			else
			begin
				select @result = @result+',[(Value)_'+@month_desc+']=isnull('+@Alias+'.['+@month_desc+'],0)'
			end
		end
		else if @Type = 222213
		begin
			if len(@result)=0
			begin
				select @result = '[(Value)_'+@month_desc+']=case when f.[Time series] = ''1. Baseline Qty'' then isnull(t.[(Value)_'+@month_desc+'],0)-isnull(p.[(Value)_'+@month_desc+'],0) else 0 end'
			end
			else
			begin
				select @result = @result+',[(Value)_'+@month_desc+']=case when f.[Time series] = ''1. Baseline Qty'' then isnull(t.[(Value)_'+@month_desc+'],0)-isnull(p.[(Value)_'+@month_desc+'],0) else 0 end'
			end
		end
		else if @Type = 222--pass value
		begin
			if len(@result)=0
			begin
				select @result = '[(Value)_'+@month_desc+']=isnull('+@Alias+'.[(Value)_'+@month_desc+'],0)'
			end
			else
			begin
				select @result = @result+',[(Value)_'+@month_desc+']=isnull('+@Alias+'.[(Value)_'+@month_desc+'],0)'
			end
		end
		else if @Type = 22--RSP*unit
		begin
			if len(@result)=0
			begin
				select @result = '[(Value)_'+@month_desc+']=isnull('+@Alias+'.['+@month_desc+'],0)*isnull(s.['+@month_desc+'],0)'
			end
			else
			begin
				select @result = @result+',[(Value)_'+@month_desc+']=isnull('+@Alias+'.['+@month_desc+'],0)*isnull(s.['+@month_desc+'],0)'
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
		else if @Type = 444--pass value
		begin
			if len(@result)=0
			begin
				select @result = '[(Value)_'+@month_desc+']=sum(isnull([(Value)_'+@month_desc+'],0))'
			end
			else
			begin
				select @result = @result+',[(Value)_'+@month_desc+']=sum(isnull([(Value)_'+@month_desc+'],0))'
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
		else if @Type = 98
		begin
			if len(@result)=0
			begin
				select @result = '['+@month_desc+']=sum(case when h.[PeriodKey] = '''+@month_desc+''' then isnull(h.EndStock,0) else 0 end)'
			end
			else
			begin
				select @result = @result+',['+@month_desc+']=sum(case when h.[PeriodKey] = '''+@month_desc+''' then isnull(h.EndStock,0) else 0 end)'
			end
		end
		else if @Type = 97-->avg of 98
		begin
			if len(@result)=0
			begin
				select @result = '[AVG]=cast((['+@month_desc+']+'
			end
			else
			begin
				select @result = @result+'['+@month_desc+']'+case when @FirstMonthHis=2 then ')/3 as numeric(18,2))' else '+' end
			end
		end
		else if @Type = 96-->list periodkey where of 97
		begin
			if len(@result)=0
			begin
				select @result = '('''+@month_desc+''','
			end
			else
			begin
				select @result = @result+''''+@month_desc+''''+case when @FirstMonthHis=2 then ')' else ',' end
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
		else if @Type = 3112
		begin
			if len(@result)=0
			begin
				select @result = '['+@month_desc+']=sum(case when h.[Pass Column Header] = '''+@month_desc+''' then isnull(h.[Total Value],0) else 0 end)'
			end
			else
			begin
				select @result = @result+',['+@month_desc+']=sum(case when h.[Pass Column Header] = '''+@month_desc+''' then isnull(h.[Total Value],0) else 0 end)'
			end
		end
		else if @Type = 86
		begin
			if len(@result)=0
			begin
				select @result = '[(Value)_'+@month_desc+']=cast(0 as numeric(18,0))'
			end
			else
			begin
				select @result = @result+',[(Value)_'+@month_desc+']=cast(0 as numeric(18,0))'
			end
		end
		else if @Type = 88
		begin
			if len(@result)=0
			begin
				select @result = '[(Value)_'+@month_desc+']=case when f.[Time series] = ''3. Promo Qty(BOM)'' then isnull('+@Alias+'.[(Value)_'+@month_desc+'],0) else 0 end'
			end
			else
			begin
				select @result = @result+',[(Value)_'+@month_desc+']=case when f.[Time series] = ''3. Promo Qty(BOM)'' then isnull('+@Alias+'.[(Value)_'+@month_desc+'],0) else 0 end'
			end
		end
		else if @Type = 888
		begin
			if len(@result)=0
			begin
				select @result = '[(Value)_'+@month_desc+']=isnull('+@Alias+'.[(Value)_'+@month_desc+'],0)'
			end
			else
			begin
				select @result = @result+',[(Value)_'+@month_desc+']=isnull('+@Alias+'.[(Value)_'+@month_desc+'],0)'
			end
		end
		else if @Type = 85
		begin
			if len(@result)=0
			begin
				select @result = '[(Value)_'+@month_desc+']=cast(0 as numeric(18,0))'
			end
			else
			begin
				select @result = @result+',[(Value)_'+@month_desc+']=cast(0 as numeric(18,0))'
			end
		end
		else if @Type = 87
		begin
			if len(@result)=0
			begin
				select @result = '[(Value)_'+@month_desc+']=isnull('+@Alias+'.[(Value)_'+@month_desc+'],0)'
			end
			else
			begin
				select @result = @result+',[(Value)_'+@month_desc+']=isnull('+@Alias+'.[(Value)_'+@month_desc+'],0)'
			end
		end
		else if @Type=100
		begin
			if len(@result)=0
			begin
				select @result = '['+@month_desc+']	int default 0'
			end
			else
			begin
				select @result =@result+',['+@month_desc+']	int default 0'
			end
		end
		else if @Type=101
		begin
			if len(@result)=0
			begin
				select @result = '['+@month_desc+']=0'
			end
			else
			begin
				select @result =@result+',['+@month_desc+']=0'
			end
		end
		else if @Type=102--//get column so his: [SellOut]
		begin
			if len(@result)=0
			begin
				select @result = '['+@month_desc+']=sum(case when [Pass Column Header]='''+@month_desc+''' then SellOut else 0 end)'
			end
			else
			begin
				select @result =@result+',['+@month_desc+']=sum(case when [Pass Column Header]='''+@month_desc+''' then SellOut else 0 end)'
			end
		end
		select @FirstMonthHis=@FirstMonthHis+1
	end

	insert into @tmpFinal(ListColumn)
	select @result as ListColumn
	
	return
end