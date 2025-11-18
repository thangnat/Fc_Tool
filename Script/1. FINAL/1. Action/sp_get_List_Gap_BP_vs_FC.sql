/*  
 exec sp_get_List_Gap_BP_vs_FC 'CPD','UNIT','OFFLINE','MINUS','=1875','ALL'  
 exec sp_get_List_Gap_BP_vs_FC 'CPD','unit','all','MINUS','=1875','ALL'  
*/  
  
ALTER pROC sp_get_List_Gap_BP_vs_FC  
	 @Division			nvarchar(3),  
	 @Type				nvarchar(10),--//unit/%  
	 @Channel			Nvarchar(10),--//ONLINE/OFFLINE/ALL  
	 @ABS				nvarchar(10),--//PLUS/MINUS/ALL  
	 @condition_value	nvarchar(50),--//luon la so duong, co the co ky tu >,<,<>,>=,<=  
	 @StickAll			nvarchar(500)--//ALL/list month  
As  
	declare @condition_value_tmp nvarchar(50) = ''  
	declare @condition_value_special nvarchar(50) = ''  
	declare @condition_value_ok nvarchar(50) = ''  
	declare @sql nvarchar(max)=''  
	declare @debug int=0  
	declare @abs_ok nvarchar(10)=''  
	declare @abs_ok2 nvarchar(10)=''  
	select @abs_ok = case   
						  when @ABS='all' then 'ABS'   
						  else ''  
					end  
	select @abs_ok2 = case when @ABS='MINUS' then '-' else '' end  
	select @condition_value_tmp = replace(replace(replace(replace(REPLACE(@condition_value,'>',''),'>=',''),'<',''),'<=',''),'=','')  
	select @condition_value_special = left(@condition_value,len(@condition_value)-len(@condition_value_tmp))  
	select @condition_value_ok=@condition_value_special+@abs_ok2+@condition_value_tmp  
	--select @condition_value_ok  
  
	if @Type='unit'  
	begin  
		select @sql='  
		select  
			/*f.id,  
			F.[SUB GROUP/ Brand],*/  
			[GAP BP]=CASE WHEN ISNULL(X.[SUB GROUP/ Brand],'''')='''' THEN 0 ELSE 1 END  
		from FC_FM_Original_'+@Division+' F  
		LEFT JOIN  
		(  
			select DISTINCT   
				[SUB GROUP/ Brand]   
			from FC_FM_Original_'+@Division+'  
			where   
				[Time series]=''8. BP vs FC (u)''  
			AND Channel IN(select value from string_split('+case when @Channel='ALL' then '''OFFLINE,ONLINE,O+O''' else ''''+@Channel+'''' end+','',''))  
			and   
			(  
				'+@abs_ok+'([Y0 (u) M1]) '+@condition_value_ok+' OR  
				'+@abs_ok+'([Y0 (u) M2])'+@condition_value_ok+' OR  
				'+@abs_ok+'([Y0 (u) M3])'+@condition_value_ok+' OR  
				'+@abs_ok+'([Y0 (u) M4])'+@condition_value_ok+' OR  
				'+@abs_ok+'([Y0 (u) M5])'+@condition_value_ok+' OR  
				'+@abs_ok+'([Y0 (u) M6])'+@condition_value_ok+' OR  
				'+@abs_ok+'([Y0 (u) M7])'+@condition_value_ok+' OR  
				'+@abs_ok+'([Y0 (u) M8])'+@condition_value_ok+' OR  
				'+@abs_ok+'([Y0 (u) M9])'+@condition_value_ok+' OR  
				'+@abs_ok+'([Y0 (u) M10])'+@condition_value_ok+' OR  
				'+@abs_ok+'([Y0 (u) M11])'+@condition_value_ok+' OR  
				'+@abs_ok+'([Y0 (u) M12])'+@condition_value_ok+' OR  
				'+@abs_ok+'([Y+1 (u) M1])'+@condition_value_ok+' OR  
				'+@abs_ok+'([Y+1 (u) M2])'+@condition_value_ok+' OR  
				'+@abs_ok+'([Y+1 (u) M3])'+@condition_value_ok+' OR  
				'+@abs_ok+'([Y+1 (u) M4])'+@condition_value_ok+' OR  
				'+@abs_ok+'([Y+1 (u) M5])'+@condition_value_ok+' OR  
				'+@abs_ok+'([Y+1 (u) M6])'+@condition_value_ok+' OR  
				'+@abs_ok+'([Y+1 (u) M7])'+@condition_value_ok+' OR  
				'+@abs_ok+'([Y+1 (u) M8])'+@condition_value_ok+' OR  
				'+@abs_ok+'([Y+1 (u) M9])'+@condition_value_ok+' OR  
				'+@abs_ok+'([Y+1 (u) M10])'+@condition_value_ok+' OR  
				'+@abs_ok+'([Y+1 (u) M11])'+@condition_value_ok+' OR  
				'+@abs_ok+'([Y+1 (u) M12])'+@condition_value_ok+'  
			)  
		) AS X ON X.[SUB GROUP/ Brand] =F.[SUB GROUP/ Brand]   
		/*and F.[Time series] in(''6. Total Qty'',''7. BP Unit'',''8. BP vs FC (u)'')*/  
		order by F.id ASC '  
	end  
	else  
	begin  
		select @sql='  
		select  
			/*f.id,  
			F.[SUB GROUP/ Brand],*/  
			[GAP BP]=CASE WHEN ISNULL(X.[SUB GROUP/ Brand],'''')='''' THEN 0 ELSE 1 END  
		from FC_FM_Original_'+@Division+' f  
		LEFT JOIN  
		(  
			select DISTINCT   
				[SUB GROUP/ Brand]   
			from FC_FM_Original_'+@Division+' F  
			where   
				[Time series]=''9. BP vs FC (%)''  
				AND Channel IN(select value from string_split('+case when @Channel='ALL' then '''OFFLINE,ONLINE,O+O''' else ''''+@Channel+'''' end+','',''))  
				and   
				(  
					'+@abs_ok+'([Y0 (u) M1]) '+@condition_value_ok+' OR  
					'+@abs_ok+'([Y0 (u) M2])'+@condition_value_ok+' OR  
					'+@abs_ok+'([Y0 (u) M3])'+@condition_value_ok+' OR  
					'+@abs_ok+'([Y0 (u) M4])'+@condition_value_ok+' OR  
					'+@abs_ok+'([Y0 (u) M5])'+@condition_value_ok+' OR  
					'+@abs_ok+'([Y0 (u) M6])'+@condition_value_ok+' OR  
					'+@abs_ok+'([Y0 (u) M7])'+@condition_value_ok+' OR  
					'+@abs_ok+'([Y0 (u) M8])'+@condition_value_ok+' OR  
					'+@abs_ok+'([Y0 (u) M9])'+@condition_value_ok+' OR  
					'+@abs_ok+'([Y0 (u) M10])'+@condition_value_ok+' OR  
					'+@abs_ok+'([Y0 (u) M11])'+@condition_value_ok+' OR  
					'+@abs_ok+'([Y0 (u) M12])'+@condition_value_ok+' OR  
					'+@abs_ok+'([Y+1 (u) M1])'+@condition_value_ok+' OR  
					'+@abs_ok+'([Y+1 (u) M2])'+@condition_value_ok+' OR  
					'+@abs_ok+'([Y+1 (u) M3])'+@condition_value_ok+' OR  
					'+@abs_ok+'([Y+1 (u) M4])'+@condition_value_ok+' OR  
					'+@abs_ok+'([Y+1 (u) M5])'+@condition_value_ok+' OR  
					'+@abs_ok+'([Y+1 (u) M6])'+@condition_value_ok+' OR  
					'+@abs_ok+'([Y+1 (u) M7])'+@condition_value_ok+' OR  
					'+@abs_ok+'([Y+1 (u) M8])'+@condition_value_ok+' OR  
					'+@abs_ok+'([Y+1 (u) M9])'+@condition_value_ok+' OR  
					'+@abs_ok+'([Y+1 (u) M10])'+@condition_value_ok+' OR  
					'+@abs_ok+'([Y+1 (u) M11])'+@condition_value_ok+' OR  
					'+@abs_ok+'([Y+1 (u) M12])'+@condition_value_ok+'  
				)  
		) AS X ON X.[SUB GROUP/ Brand] =F.[SUB GROUP/ Brand]   
		/*WHERE F.[SUB GROUP/ Brand] =''BC AA SALICYLIC GEL WASH 120ML''*/  
		/*and F.[Time series] in(''6. Total Qty'',''7. BP Unit'',''9. BP vs FC (%)'')*/  
		order by F.id ASC '  
	end  
	if @debug>0  
	begin  
		select @sql '@sql'  
	end  
	execute(@sql)  