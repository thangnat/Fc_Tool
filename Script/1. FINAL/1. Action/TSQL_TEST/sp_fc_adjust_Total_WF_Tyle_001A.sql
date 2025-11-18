declare @channel nvarchar(10)='OFFLINE'
declare @subgrp nvarchar(500)='MCLR WTR REFRESHING 400ML'

select     
	[SUB GROUP/ Brand]=f.[SUB GROUP/ Brand],
	[Channel]=f.[Channel],
	[Time series]=f.[Time series],
	[Y0 (u) M10]=isnull(f.[Y0 (u) M10],0),
	[Y0 (u) M11]=isnull(f.[Y0 (u) M11],0),
	[Y0 (u) M12]=isnull(f.[Y0 (u) M12],0),
	[Y+1 (u) M1]=isnull(f.[Y+1 (u) M1],0),
	[Y+1 (u) M2]=isnull(f.[Y+1 (u) M2],0),
	[Y+1 (u) M3]=isnull(f.[Y+1 (u) M3],0),
	[Y+1 (u) M4]=isnull(f.[Y+1 (u) M4],0),
	[Y+1 (u) M5]=isnull(f.[Y+1 (u) M5],0),
	[Y+1 (u) M6]=isnull(f.[Y+1 (u) M6],0),
	[Y+1 (u) M7]=isnull(f.[Y+1 (u) M7],0),
	[Y+1 (u) M8]=isnull(f.[Y+1 (u) M8],0),
	[Y+1 (u) M9]=isnull(f.[Y+1 (u) M9],0),
	[Y+1 (u) M10]=isnull(f.[Y+1 (u) M10],0),
	[Y+1 (u) M11]=isnull(f.[Y+1 (u) M11],0),
	[Y+1 (u) M12]=isnull(f.[Y+1 (u) M12],0)   
	INTO FC_TYLE_Tmp_VNCORPVNWKS1154   
	--drop table FC_TYLE_Tmp_VNCORPVNWKS1154
from FC_FM_Original_CPD_202410 f1  
inner join   
(      
	/*cal total x %*/  
	select        
		fm.[SUB GROUP/ Brand],
		fm.Channel,fm.[Time series],
		[Y0 (u) M10]=CAST(ad.[Y0 (u) M10]*fm.[Y0 (u) M10] as INT),
		[Y0 (u) M11]=CAST(ad.[Y0 (u) M11]*fm.[Y0 (u) M11] as INT),
		[Y0 (u) M12]=CAST(ad.[Y0 (u) M12]*fm.[Y0 (u) M12] as INT),
		[Y+1 (u) M1]=CAST(ad.[Y+1 (u) M1]*fm.[Y+1 (u) M1] as INT),
		[Y+1 (u) M2]=CAST(ad.[Y+1 (u) M2]*fm.[Y+1 (u) M2] as INT),
		[Y+1 (u) M3]=CAST(ad.[Y+1 (u) M3]*fm.[Y+1 (u) M3] as INT),
		[Y+1 (u) M4]=CAST(ad.[Y+1 (u) M4]*fm.[Y+1 (u) M4] as INT),
		[Y+1 (u) M5]=CAST(ad.[Y+1 (u) M5]*fm.[Y+1 (u) M5] as INT),
		[Y+1 (u) M6]=CAST(ad.[Y+1 (u) M6]*fm.[Y+1 (u) M6] as INT),
		[Y+1 (u) M7]=CAST(ad.[Y+1 (u) M7]*fm.[Y+1 (u) M7] as INT),
		[Y+1 (u) M8]=CAST(ad.[Y+1 (u) M8]*fm.[Y+1 (u) M8] as INT),
		[Y+1 (u) M9]=CAST(ad.[Y+1 (u) M9]*fm.[Y+1 (u) M9] as INT),
		[Y+1 (u) M10]=CAST(ad.[Y+1 (u) M10]*fm.[Y+1 (u) M10] as INT),
		[Y+1 (u) M11]=CAST(ad.[Y+1 (u) M11]*fm.[Y+1 (u) M11] as INT),
		[Y+1 (u) M12]=CAST(ad.[Y+1 (u) M12]*fm.[Y+1 (u) M12] as INT)
	from   
	(   
		/*--//get pecent %: for each item /total*/   
		select       
			a.[SUB GROUP/ Brand],
			a.Channel,
			a.[Time series], 
			[Y0 (u) M10]=case when t.[Y0 (u) M10]>0 then a.[Y0 (u) M10]*1.0/t.[Y0 (u) M10] else 0 end,
			[Y0 (u) M11]=case when t.[Y0 (u) M11]>0 then a.[Y0 (u) M11]*1.0/t.[Y0 (u) M11] else 0 end,
			[Y0 (u) M12]=case when t.[Y0 (u) M12]>0 then a.[Y0 (u) M12]*1.0/t.[Y0 (u) M12] else 0 end,
			[Y+1 (u) M1]=case when t.[Y+1 (u) M1]>0 then a.[Y+1 (u) M1]*1.0/t.[Y+1 (u) M1] else 0 end,
			[Y+1 (u) M2]=case when t.[Y+1 (u) M2]>0 then a.[Y+1 (u) M2]*1.0/t.[Y+1 (u) M2] else 0 end,
			[Y+1 (u) M3]=case when t.[Y+1 (u) M3]>0 then a.[Y+1 (u) M3]*1.0/t.[Y+1 (u) M3] else 0 end,
			[Y+1 (u) M4]=case when t.[Y+1 (u) M4]>0 then a.[Y+1 (u) M4]*1.0/t.[Y+1 (u) M4] else 0 end,
			[Y+1 (u) M5]=case when t.[Y+1 (u) M5]>0 then a.[Y+1 (u) M5]*1.0/t.[Y+1 (u) M5] else 0 end,
			[Y+1 (u) M6]=case when t.[Y+1 (u) M6]>0 then a.[Y+1 (u) M6]*1.0/t.[Y+1 (u) M6] else 0 end,
			[Y+1 (u) M7]=case when t.[Y+1 (u) M7]>0 then a.[Y+1 (u) M7]*1.0/t.[Y+1 (u) M7] else 0 end,
			[Y+1 (u) M8]=case when t.[Y+1 (u) M8]>0 then a.[Y+1 (u) M8]*1.0/t.[Y+1 (u) M8] else 0 end,
			[Y+1 (u) M9]=case when t.[Y+1 (u) M9]>0 then a.[Y+1 (u) M9]*1.0/t.[Y+1 (u) M9] else 0 end,
			[Y+1 (u) M10]=case when t.[Y+1 (u) M10]>0 then a.[Y+1 (u) M10]*1.0/t.[Y+1 (u) M10] else 0 end,
			[Y+1 (u) M11]=case when t.[Y+1 (u) M11]>0 then a.[Y+1 (u) M11]*1.0/t.[Y+1 (u) M11] else 0 end,
			[Y+1 (u) M12]=case when t.[Y+1 (u) M12]>0 then a.[Y+1 (u) M12]*1.0/t.[Y+1 (u) M12] else 0 end     
		from      
		(   
			/*get for each item first table FM original*/     
			select      
				[SUB GROUP/ Brand]    
				,[Channel]       
				,[Time series], 
				[Y0 (u) M10]=isnull(f.[Y0 (u) M10],0),[Y0 (u) M11]=isnull(f.[Y0 (u) M11],0),[Y0 (u) M12]=isnull(f.[Y0 (u) M12],0),
				[Y+1 (u) M1]=isnull(f.[Y+1 (u) M1],0),[Y+1 (u) M2]=isnull(f.[Y+1 (u) M2],0),[Y+1 (u) M3]=isnull(f.[Y+1 (u) M3],0),
				[Y+1 (u) M4]=isnull(f.[Y+1 (u) M4],0),[Y+1 (u) M5]=isnull(f.[Y+1 (u) M5],0),[Y+1 (u) M6]=isnull(f.[Y+1 (u) M6],0),
				[Y+1 (u) M7]=isnull(f.[Y+1 (u) M7],0),[Y+1 (u) M8]=isnull(f.[Y+1 (u) M8],0),[Y+1 (u) M9]=isnull(f.[Y+1 (u) M9],0),
				[Y+1 (u) M10]=isnull(f.[Y+1 (u) M10],0),[Y+1 (u) M11]=isnull(f.[Y+1 (u) M11],0),[Y+1 (u) M12]=isnull(f.[Y+1 (u) M12],0)    
			from FM_Original_Full_Adj_CPD_202410 f     
			where    
				cast(replace(left([Time series],2),'.','') as int) IN(1,2,4)  
			and f.[SUB GROUP/ Brand] IN(select distinct [SUB GROUP/ Brand] from fc_list_forecasting_line_update_VNCORPVNWKS1154)
		) a      
		left JOIN   
		(       
			/*sum total list column first table FM Original*/     
			select       
				[SUB GROUP/ Brand]      
				,[Channel],
				[Y0 (u) M10]=sum(ISNULL(f.[Y0 (u) M10],0)),[Y0 (u) M11]=sum(ISNULL(f.[Y0 (u) M11],0)),[Y0 (u) M12]=sum(ISNULL(f.[Y0 (u) M12],0)),
				[Y+1 (u) M1]=sum(ISNULL(f.[Y+1 (u) M1],0)),[Y+1 (u) M2]=sum(ISNULL(f.[Y+1 (u) M2],0)),[Y+1 (u) M3]=sum(ISNULL(f.[Y+1 (u) M3],0)),
				[Y+1 (u) M4]=sum(ISNULL(f.[Y+1 (u) M4],0)),[Y+1 (u) M5]=sum(ISNULL(f.[Y+1 (u) M5],0)),[Y+1 (u) M6]=sum(ISNULL(f.[Y+1 (u) M6],0)),
				[Y+1 (u) M7]=sum(ISNULL(f.[Y+1 (u) M7],0)),[Y+1 (u) M8]=sum(ISNULL(f.[Y+1 (u) M8],0)),[Y+1 (u) M9]=sum(ISNULL(f.[Y+1 (u) M9],0)),
				[Y+1 (u) M10]=sum(ISNULL(f.[Y+1 (u) M10],0)),[Y+1 (u) M11]=sum(ISNULL(f.[Y+1 (u) M11],0)),[Y+1 (u) M12]=sum(ISNULL(f.[Y+1 (u) M12],0))   
			from FM_Original_Full_Adj_CPD_202410 f    
			where       
				cast(replace(left([Time series],2),'.','') as int) IN(1,2,4)      
			and f.[SUB GROUP/ Brand] IN(select distinct [SUB GROUP/ Brand] from fc_list_forecasting_line_update_VNCORPVNWKS1154)  
			group by     
				[SUB GROUP/ Brand],      
				[Channel]      
		) t ON T.[SUB GROUP/ Brand]=a.[SUB GROUP/ Brand] and t.Channel=a.Channel   
		where cast(replace(left(a.[Time series],2),'.','') as int) IN(1,2,4)   
		and a.[SUB GROUP/ Brand]=@subgrp
		and a.Channel=@channel
	) fm      
	left join    
	(        
		/*exclude bom*/      
		select      
			t.[SUB GROUP/ Brand]      
			,t.[Channel]     
			,[Time series], 
			[Y0 (u) M10]=isnull(t.[Y0 (u) M10],0)-isnull(t1.[Y0 (u) M10],0),[Y0 (u) M11]=isnull(t.[Y0 (u) M11],0)-isnull(t1.[Y0 (u) M11],0),
			[Y0 (u) M12]=isnull(t.[Y0 (u) M12],0)-isnull(t1.[Y0 (u) M12],0),[Y+1 (u) M1]=isnull(t.[Y+1 (u) M1],0)-isnull(t1.[Y+1 (u) M1],0),
			[Y+1 (u) M2]=isnull(t.[Y+1 (u) M2],0)-isnull(t1.[Y+1 (u) M2],0),[Y+1 (u) M3]=isnull(t.[Y+1 (u) M3],0)-isnull(t1.[Y+1 (u) M3],0),
			[Y+1 (u) M4]=isnull(t.[Y+1 (u) M4],0)-isnull(t1.[Y+1 (u) M4],0),[Y+1 (u) M5]=isnull(t.[Y+1 (u) M5],0)-isnull(t1.[Y+1 (u) M5],0),
			[Y+1 (u) M6]=isnull(t.[Y+1 (u) M6],0)-isnull(t1.[Y+1 (u) M6],0),[Y+1 (u) M7]=isnull(t.[Y+1 (u) M7],0)-isnull(t1.[Y+1 (u) M7],0),
			[Y+1 (u) M8]=isnull(t.[Y+1 (u) M8],0)-isnull(t1.[Y+1 (u) M8],0),[Y+1 (u) M9]=isnull(t.[Y+1 (u) M9],0)-isnull(t1.[Y+1 (u) M9],0),
			[Y+1 (u) M10]=isnull(t.[Y+1 (u) M10],0)-isnull(t1.[Y+1 (u) M10],0),[Y+1 (u) M11]=isnull(t.[Y+1 (u) M11],0)-isnull(t1.[Y+1 (u) M11],0),
			[Y+1 (u) M12]=isnull(t.[Y+1 (u) M12],0)-isnull(t1.[Y+1 (u) M12],0)  
		from FC_FM_Original_CPD_202410_Tmp t    
		left join    
		(  
			select      
				[SUB GROUP/ Brand]   
				,[Channel],
				[Y0 (u) M10]=isnull(f.[Y0 (u) M10],0),[Y0 (u) M11]=isnull(f.[Y0 (u) M11],0),[Y0 (u) M12]=isnull(f.[Y0 (u) M12],0),
				[Y+1 (u) M1]=isnull(f.[Y+1 (u) M1],0),[Y+1 (u) M2]=isnull(f.[Y+1 (u) M2],0),[Y+1 (u) M3]=isnull(f.[Y+1 (u) M3],0),
				[Y+1 (u) M4]=isnull(f.[Y+1 (u) M4],0),[Y+1 (u) M5]=isnull(f.[Y+1 (u) M5],0),[Y+1 (u) M6]=isnull(f.[Y+1 (u) M6],0),
				[Y+1 (u) M7]=isnull(f.[Y+1 (u) M7],0),[Y+1 (u) M8]=isnull(f.[Y+1 (u) M8],0),[Y+1 (u) M9]=isnull(f.[Y+1 (u) M9],0),
				[Y+1 (u) M10]=isnull(f.[Y+1 (u) M10],0),[Y+1 (u) M11]=isnull(f.[Y+1 (u) M11],0),[Y+1 (u) M12]=isnull(f.[Y+1 (u) M12],0)     
			from FC_FM_Original_CPD_202410 f     
			where            
				[Time series]='3. Promo Qty(BOM)'     
			and f.[SUB GROUP/ Brand] IN(select distinct [SUB GROUP/ Brand] from fc_list_forecasting_line_update_VNCORPVNWKS1154)   
		) t1 on t1.[SUB GROUP/ Brand] = t.[SUB GROUP/ Brand] and t1.Channel=t.Channel  
		where           
			t.[Time series]='6. Total Qty'   
		and t.[SUB GROUP/ Brand] IN(select distinct [SUB GROUP/ Brand] from fc_list_forecasting_line_update_VNCORPVNWKS1154)  
		and t.[SUB GROUP/ Brand]=@subgrp
		and t.Channel=@channel
	) ad on ad.[SUB GROUP/ Brand]=fm.[SUB GROUP/ Brand] and ad.Channel=fm.Channel   
) as f on f.[SUB GROUP/ Brand]=f1.[SUB GROUP/ Brand] and f.Channel=f1.Channel and f.[Time series]=f1.[Time series]   
where      
	cast(replace(left(f.[Time series],2),'.','') as int) IN(1,2,4)   
and f.Channel NOT IN('O+O')  
and f.[SUB GROUP/ Brand] IN(select distinct [SUB GROUP/ Brand] from fc_list_forecasting_line_update_VNCORPVNWKS1154)  
--and trim(f.[SUB GROUP/ Brand])+'*'+trim(F.CHANNEL) NOT IN    
--(      
--	select DISTINCT   
--		trim([SUB GROUP/ Brand])+'*'+trim(Channel)     
--	from fc_config_wf_total_custom    
--	WHERE    
--		[Division]='CPD'    
--	and [FM_KEY]='202410'    
--) 
and f.[SUB GROUP/ Brand]=@subgrp
and f.Channel=@channel