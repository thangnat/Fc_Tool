/*
	SELECT * FROM fn_FC_GetColheader_Current_BT('202412','','t',5)
	SELECT * FROM fn_FC_GetColheader_Current_BT('202403','f','T',23)
*/
Alter Function fn_FC_GetColheader_Current_BT
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
		22: RSP
		5: get column header Trend
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

		--set 0 unit
		if @Type =1
		begin
			if len(@result)=0
			begin
				select @result = '['+@column_name+']=cast(''0'' as int)'
			end
			else
			begin
				select @result =@result+',['+@column_name+']=cast(''0'' as int)'
			end
		end
		else if @Type = 2
		begin
			if len(@result)=0
			begin
				select @result = '['+@column_name+']=ROUND(isnull('+@Type_+'.[M'+cast((@current_month) as nvarchar(2))+'],0),0)'
			end
			else
			begin
				select @result =@result+',['+@column_name+']=ROUND(isnull('+@Type_+'.[M'+cast((@current_month) as nvarchar(2))+'],0),0)'
			end
		end
		else if @Type =21--//set 0 RSP-->0
		begin
			if len(@result)=0
			begin
				select @result = '[(Value)_'+@column_name+']=cast(0 as numeric(18,0))'
			end
			else
			begin
				select @result =@result+',[(Value)_'+@column_name+']=cast(0 as numeric(18,0))'
			end
		end
		--else if @Type =22--//RSP
		--begin
		--	if len(@result)=0
		--	begin
		--		select @result = '[(Value)_'+@column_name+']=isnull('+@Alias+'.['+@column_name+'],0)*isnull(s.['+@column_name+'],0)'
		--	end
		--	else
		--	begin
		--		select @result =@result+',[(Value)_'+@column_name+']=isnull('+@Alias+'.['+@column_name+'],0)*isnull(s.['+@column_name+'],0)'
		--	end
		--end
		else if @Type =22--//RSP
		begin
			if len(@result)=0
			begin
				select @result = '[(Value)_'+@column_name+']=isnull(s.['+@column_name+'],0)'
			end
			else
			begin
				select @result =@result+',[(Value)_'+@column_name+']=isnull(s.['+@column_name+'],0)'
			end
		end
		--else if @Type =23--//RSP-->update WF
		--begin
		--	if len(@result)=0
		--	begin
		--		select @result = '[(Value)_'+@column_name+']=isnull('+@Alias+'.[(Value)_'+@column_name+'],0)'
		--	end
		--	else
		--	begin
		--		select @result =@result+',[(Value)_'+@column_name+']=isnull('+@Alias+'.[(Value)_'+@column_name+'],0)'
		--	end
		--end
		else if @Type =23--//RSP-->update WF
		begin
			if len(@result)=0
			begin
				select @result = '[(Value)_'+@column_name+']=isnull('+@Alias+'.[(Value)_'+@column_name+'],0)*case when ['+@column_name+']<>0 then 1 else 0 end '
			end
			else
			begin
				select @result =@result+',[(Value)_'+@column_name+']=isnull('+@Alias+'.[(Value)_'+@column_name+'],0)*case when ['+@column_name+']<>0 then 1 else 0 end '
			end
		end
		else if @Type =3--//sum column
		begin
			if len(@result)=0
			begin
				select @result = '['+@column_name+']=isnull('+@Alias+'.['+@column_name+'],0)'
			end
			else
			begin
				select @result =@result+',['+@column_name+']=isnull('+@Alias+'.['+@column_name+'],0)'
			end
		end
		else if @Type =4--//get column O+O & total
		begin
			if len(@result)=0
			begin
				select @result = '['+@column_name+']=sum(isnull(['+@column_name+'],0))'
			end
			else
			begin
				select @result =@result+',['+@column_name+']=sum(isnull(['+@column_name+'],0))'
			end
		end
		else if @Type =5--//get column header trend
		begin
			select @result='[T_Y0_M1]=0,[T_Y0_M2]=0,[T_Y0_M3]=0,[T_Y0_M4]=0,[T_Y0_M5]=0,[T_Y0_M6]=0,[T_Y0_M7]=0,[T_Y0_M8]=0,[T_Y0_M9]=0,[T_Y0_M10]=0,[T_Y0_M11]=0,[T_Y0_M12]=0'
		end
		--if @Type=555
		--begin
		--	if len(@result)=0
		--	begin
		--		select @result = '['+@column_name+']=0'
		--	end
		--	else
		--	begin
		--		select @result =@result+',['+@column_name+']=0'
		--	end
		--end
		--else if @Type =55--//get column header trend
		--begin
		--	select @result='[T_Y0_M1]+[T_Y0_M2]+[T_Y0_M3]+[T_Y0_M4]+[T_Y0_M5]+[T_Y0_M6]+[T_Y0_M7]+[T_Y0_M8]+[T_Y0_M9]+[T_Y0_M10]+[T_Y0_M11]+[T_Y0_M12]'
		--end
		else if @Type =41--//get column O+O & total value
		begin
			if len(@result)=0
			begin
				select @result = '[(Value)_'+@column_name+']=sum(isnull([(Value)_'+@column_name+'],0))'
			end
			else
			begin
				select @result =@result+',[(Value)_'+@column_name+']=sum(isnull([(Value)_'+@column_name+'],0))'
			end
		end
		else if @Type=103--//get column budget,pre_budget,trend
		begin
			if len(@result)=0
			begin
				select @result = '['+@column_name+']=case when [M'+cast(@current_month as nvarchar(2))+']<>0 then [M'+cast(@current_month as nvarchar(2))+'] else 0 end'
			end
			else
			begin
				select @result =@result+',['+@column_name+']=case when [M'+cast(@current_month as nvarchar(2))+']<>0 then [M'+cast(@current_month as nvarchar(2))+'] else 0 end'
			end
		end
		else if @Type=1031--//get column budget,pre_budget,trend header column final
		begin
			if len(@result)=0
			begin
				select @result = '['+@column_name+']=sum(case when charindex([Year],'''+@column_name+''')>0 then ['+@column_name+'] else 0 end)'
			end
			else
			begin
				select @result =@result+',['+@column_name+']=sum(case when charindex([Year],'''+@column_name+''')>0 then ['+@column_name+'] else 0 end)'
			end
		end

		select @currentrow = @currentrow + 1
	end
	insert into @tmpFinal(ListColumn) values(@result)
	return
end

