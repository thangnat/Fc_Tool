/*
	SELECT * FROM fn_FC_GetColheader_Current_BT_TEST('202402','','T',2)
*/
Alter Function fn_FC_GetColheader_Current_BT_TEST
(
	@FM_KEY			Nvarchar(6),
	@Alias			nvarchar(5),
	@Table			nvarchar(20),--//B/PB/T
	@Type			int
	/*
		1=0
		2=colum
		3: get column header
		4: O+O sum detail
	*/
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
		 @debug					int = 0 
		,@currentYear			nvarchar(4) = ''
		,@sql					nvarchar(max) = ''
		,@rowcount1				int = 0
		,@result				nvarchar(MAX) = ''
		,@result2				nvarchar(max) = ''
		,@result0				nvarchar(MAX) = ''

	declare @tmpTrend table
	(
		id				int identity(1,1),
		TrendName		nvarchar(5)
	)
	insert into @tmpTrend(TrendName) select TrendName from V_FC_Trend_Config

	declare @tmp table
	(
		id				int identity(1,1), 
		[Month_Number]	int,
		[Month_Desc]	nvarchar(20),
		[Type]			nvarchar(5)
	)
	if @Table = 'B'
	begin
		insert into @tmp
		(			
			Month_Number,
			Month_Desc,
			[Type]
		)
		select		
			[Month_Number],
			Month_Desc = replace(Budget,'@','0'),
			[Type] = 'b0'
		from V_Month_Master
		union all
		select		
			[Month_Number],
			Month_Desc = replace(Budget,'@','+1'),
			[Type] = 'b1'
		from V_Month_Master
	end
	else if @Table = 'PB'
	begin
		insert into @tmp
		(			
			Month_Number,
			Month_Desc,
			[Type]
		)
		select		
			[Month_Number],
			Month_Desc = replace(PreBudget,'@','+1'),
			[Type] = 'pb1'
		from V_Month_Master
	end
	else if @Table = 'T'
	begin
		declare @currentrowTrend int = 1, @totalrowTrend int = 0
		select @totalrowTrend = isnull(count(*),0) from @tmpTrend

		while (@currentrowTrend<=@totalrowTrend)
		begin
			declare @trendname nvarchar(5) = ''
			select @trendname = TrendName from @tmpTrend where id = @currentrowTrend

			insert into @tmp
			(			
				Month_Number,
				Month_Desc,
				[Type]
			)
			select		
				[Month_Number],
				Month_Desc = replace(Trend,'@',@trendname),
				[Type] = 'T'+@trendname
			from V_Month_Master

			select @currentrowTrend = @currentrowTrend + 1
		end
	end
	--select * from @tmp

	declare 
		@totalrow		int =0, 
		@currentrow		int = 1

	select @totalrow = case 
							when @Table = 'T' then @totalrowTrend*12  
							when @Table = 'PB' then 12
							when @Table = 'B' then 24
							else 0
					   end

	while (@currentrow <=@totalrow)
	begin
		declare 
			@column_name		nvarchar(20),
			@current_month		int = 0,
			@Type_				nvarchar(5) = ''

		select 
			@column_name = Month_Desc,
			@current_month = [Month_Number],
			@Type_ = [Type] 
		from @tmp 
		where id = @currentrow

		if @Type =1
		begin
			if len(@result)=0
			begin
				select @result = '['+@column_name+'] = 0'
			end
			else
			begin
				select @result =@result+',['+@column_name+'] = 0'
			end
		end
		else if @Type =2
		begin
			if len(@result)=0
			begin
				select @result = '['+@column_name+'] = ROUND(isnull('+@Type_+'.[M'+cast((@current_month-1) as nvarchar(2))+'],0),0)'
			end
			else
			begin
				select @result =@result+',['+@column_name+'] = ROUND(isnull('+@Type_+'.[M'+cast((@current_month-1) as nvarchar(2))+'],0),0)'
			end
		end
		else if @Type =3--//sum column
		begin
			if len(@result)=0
			begin
				select @result = '['+@column_name+'] = isnull('+@Alias+'.['+@column_name+'],0)'
			end
			else
			begin
				select @result =@result+',['+@column_name+'] = isnull('+@Alias+'.['+@column_name+'],0)'
			end
		end
		else if @Type =4--//get column O+O
		begin
			if len(@result)=0
			begin
				select @result = '['+@column_name+'] = sum(isnull(['+@column_name+'],0))'
			end
			else
			begin
				select @result =@result+',['+@column_name+'] = sum(isnull(['+@column_name+'],0))'
			end
		end
		
		select @currentrow = @currentrow + 1
	end
	insert into @tmpFinal(ListColumn) values(@result)
	return
end