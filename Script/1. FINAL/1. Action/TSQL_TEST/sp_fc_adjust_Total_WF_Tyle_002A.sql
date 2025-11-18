declare @channel nvarchar(10)='OFFLINE'
declare @subgrp nvarchar(500)='MCLR WTR REFRESHING 400ML'

select
	x.[Product status],
	f.[SUB GROUP/ Brand],
	f.Channel,
	f.[Time series],
	[Y0 (u) M10] = ISNULL(x.[Y0 (u) M10],0)
	--[Y0 (u) M11] = ISNULL(x.[Y0 (u) M11],0),
	--[Y0 (u) M12] = ISNULL(x.[Y0 (u) M12],0),
	--[Y+1 (u) M1] = ISNULL(x.[Y+1 (u) M1],0),
	--[Y+1 (u) M2] = ISNULL(x.[Y+1 (u) M2],0),
	--[Y+1 (u) M3] = ISNULL(x.[Y+1 (u) M3],0),
	--[Y+1 (u) M4] = ISNULL(x.[Y+1 (u) M4],0),
	--[Y+1 (u) M5] = ISNULL(x.[Y+1 (u) M5],0),
	--[Y+1 (u) M6] = ISNULL(x.[Y+1 (u) M6],0),
	--[Y+1 (u) M7] = ISNULL(x.[Y+1 (u) M7],0),
	--[Y+1 (u) M8] = ISNULL(x.[Y+1 (u) M8],0),
	--[Y+1 (u) M9] = ISNULL(x.[Y+1 (u) M9],0),
	--[Y+1 (u) M10] = ISNULL(x.[Y+1 (u) M10],0),
	--[Y+1 (u) M11] = ISNULL(x.[Y+1 (u) M11],0),
	--[Y+1 (u) M12] = ISNULL(x.[Y+1 (u) M12],0)
from FC_FM_Original_CPD_202410 f  
Inner Join  
(    
	select   
		s.[Product status],
		[SUB GROUP/ Brand]=f.[SUB GROUP/ Brand]   
		,[Channel]=f.[Channel]     
		,[Time series]=f.[Time series], 
		--[f ]=sum(f.[Y0 (u) M10]),
		[Y0 (u) M10]=case when 
								(
									select 
										max([Y0 (u) M10])
									from FC_TYLE_Tmp_VNCORPVNWKS1154 
									where 
										[SUB GROUP/ Brand]=f.[SUB GROUP/ Brand]
									and [Channel]=f.[Channel] --and
									 --[SUB GROUP/ Brand]='AGE REWIND CONCEALER' and Channel='OFFLINE'
								)=sum(f.[Y0 (u) M10]) and case when sum(f.[Y0 (u) M10])=0 and ((charindex('On Going',s.[Product status])>0 and [Time series]='1. Baseline Qty') OR 
									(charindex('New Launch',s.[Product status])>0 and [Time series]='4. Launch Qty'))
								then 1 else 0 end>0
						then sum(f.[Y0 (u) M10]+t.[Y0 (u) M10]) else sum(f.[Y0 (u) M10]) end
	from FC_TYLE_Tmp_VNCORPVNWKS1154 f    
	left join
	(
		select distinct 
			[Product status],
			[SUB GROUP/ Brand]
		from fnc_SubGroupMaster('CPD','full')
	) s on s.[SUB GROUP/ Brand]=f.[SUB GROUP/ Brand]
	left join    
	(
		select 
			f1.[SUB GROUP/ Brand]    
			,f1.[Channel], 
			[Y0 (u) M10]=isnull(t1.[Y0 (u) M10],0)-sum(isnull(f1.[Y0 (u) M10],0)),
			[Y0 (u) M11]=isnull(t1.[Y0 (u) M11],0)-sum(isnull(f1.[Y0 (u) M11],0)),[Y0 (u) M12]=isnull(t1.[Y0 (u) M12],0)-sum(isnull(f1.[Y0 (u) M12],0)),
			[Y+1 (u) M1]=isnull(t1.[Y+1 (u) M1],0)-sum(isnull(f1.[Y+1 (u) M1],0)),[Y+1 (u) M2]=isnull(t1.[Y+1 (u) M2],0)-sum(isnull(f1.[Y+1 (u) M2],0)),
			[Y+1 (u) M3]=isnull(t1.[Y+1 (u) M3],0)-sum(isnull(f1.[Y+1 (u) M3],0)),[Y+1 (u) M4]=isnull(t1.[Y+1 (u) M4],0)-sum(isnull(f1.[Y+1 (u) M4],0)),
			[Y+1 (u) M5]=isnull(t1.[Y+1 (u) M5],0)-sum(isnull(f1.[Y+1 (u) M5],0)),[Y+1 (u) M6]=isnull(t1.[Y+1 (u) M6],0)-sum(isnull(f1.[Y+1 (u) M6],0)),
			[Y+1 (u) M7]=isnull(t1.[Y+1 (u) M7],0)-sum(isnull(f1.[Y+1 (u) M7],0)),[Y+1 (u) M8]=isnull(t1.[Y+1 (u) M8],0)-sum(isnull(f1.[Y+1 (u) M8],0)),
			[Y+1 (u) M9]=isnull(t1.[Y+1 (u) M9],0)-sum(isnull(f1.[Y+1 (u) M9],0)),[Y+1 (u) M10]=isnull(t1.[Y+1 (u) M10],0)-sum(isnull(f1.[Y+1 (u) M10],0)),
			[Y+1 (u) M11]=isnull(t1.[Y+1 (u) M11],0)-sum(isnull(f1.[Y+1 (u) M11],0)),[Y+1 (u) M12]=isnull(t1.[Y+1 (u) M12],0)-sum(isnull(f1.[Y+1 (u) M12],0))   
		from FC_TYLE_Tmp_VNCORPVNWKS1154 f1    
		left join  
		(   
			select        
				t.[SUB GROUP/ Brand],
				t.[Channel], 
				[Y0 (u) M10] = sum(isnull(t.[Y0 (u) M10],0)-isnull(t1.[Y0 (u) M10],0)),[Y0 (u) M11] = sum(isnull(t.[Y0 (u) M11],0)-isnull(t1.[Y0 (u) M11],0)),
				[Y0 (u) M12] = sum(isnull(t.[Y0 (u) M12],0)-isnull(t1.[Y0 (u) M12],0)),[Y+1 (u) M1] = sum(isnull(t.[Y+1 (u) M1],0)-isnull(t1.[Y+1 (u) M1],0)),
				[Y+1 (u) M2] = sum(isnull(t.[Y+1 (u) M2],0)-isnull(t1.[Y+1 (u) M2],0)),[Y+1 (u) M3] = sum(isnull(t.[Y+1 (u) M3],0)-isnull(t1.[Y+1 (u) M3],0)),
				[Y+1 (u) M4] = sum(isnull(t.[Y+1 (u) M4],0)-isnull(t1.[Y+1 (u) M4],0)),[Y+1 (u) M5] = sum(isnull(t.[Y+1 (u) M5],0)-isnull(t1.[Y+1 (u) M5],0)),
				[Y+1 (u) M6] = sum(isnull(t.[Y+1 (u) M6],0)-isnull(t1.[Y+1 (u) M6],0)),[Y+1 (u) M7] = sum(isnull(t.[Y+1 (u) M7],0)-isnull(t1.[Y+1 (u) M7],0)),
				[Y+1 (u) M8] = sum(isnull(t.[Y+1 (u) M8],0)-isnull(t1.[Y+1 (u) M8],0)),[Y+1 (u) M9] = sum(isnull(t.[Y+1 (u) M9],0)-isnull(t1.[Y+1 (u) M9],0)),
				[Y+1 (u) M10] = sum(isnull(t.[Y+1 (u) M10],0)-isnull(t1.[Y+1 (u) M10],0)),[Y+1 (u) M11] = sum(isnull(t.[Y+1 (u) M11],0)-isnull(t1.[Y+1 (u) M11],0)),
				[Y+1 (u) M12] = sum(isnull(t.[Y+1 (u) M12],0)-isnull(t1.[Y+1 (u) M12],0))    
			from (select * from FC_FM_Original_CPD_202410_Tmp) t    
			left join    
			(    
				select      
					[SUB GROUP/ Brand]     
					,[Channel], [Y0 (u) M10]=isnull(f.[Y0 (u) M10],0),[Y0 (u) M11]=isnull(f.[Y0 (u) M11],0),[Y0 (u) M12]=isnull(f.[Y0 (u) M12],0),[Y+1 (u) M1]=isnull(f.[Y+1 (u) M1],0),
					[Y+1 (u) M2]=isnull(f.[Y+1 (u) M2],0),[Y+1 (u) M3]=isnull(f.[Y+1 (u) M3],0),[Y+1 (u) M4]=isnull(f.[Y+1 (u) M4],0),[Y+1 (u) M5]=isnull(f.[Y+1 (u) M5],0),
					[Y+1 (u) M6]=isnull(f.[Y+1 (u) M6],0),[Y+1 (u) M7]=isnull(f.[Y+1 (u) M7],0),[Y+1 (u) M8]=isnull(f.[Y+1 (u) M8],0),[Y+1 (u) M9]=isnull(f.[Y+1 (u) M9],0),
					[Y+1 (u) M10]=isnull(f.[Y+1 (u) M10],0),[Y+1 (u) M11]=isnull(f.[Y+1 (u) M11],0),[Y+1 (u) M12]=isnull(f.[Y+1 (u) M12],0)     
				from FC_FM_Original_CPD_202410 f    
				where              
					[Time series]='3. Promo Qty(BOM)'  
					and [SUB GROUP/ Brand] IN(select distinct [SUB GROUP/ Brand] from fc_list_forecasting_line_update_VNCORPVNWKS1154)     
			) t1 on t1.[SUB GROUP/ Brand]=t.[SUB GROUP/ Brand] and t1.Channel=t.Channel    
			where         
					t.[Time series]='6. Total Qty'   
				and t.[SUB GROUP/ Brand] IN(select distinct [SUB GROUP/ Brand] from fc_list_forecasting_line_update_VNCORPVNWKS1154)     
				and t1.[SUB GROUP/ Brand]=@subgrp
			group by     
				t.[SUB GROUP/ Brand]    
				,t.[Channel]    
		) t1 on t1.[SUB GROUP/ Brand]=f1.[SUB GROUP/ Brand] and t1.Channel=f1.Channel  
		WHERE F1.[SUB GROUP/ Brand] IN
		(
			select distinct [SUB GROUP/ Brand] 
			from fc_list_forecasting_line_update_VNCORPVNWKS1154
		)  
		and f1.[SUB GROUP/ Brand]=@subgrp
		group by     
			f1.[SUB GROUP/ Brand],
			f1.[Channel], 
			t1.[Y0 (u) M10],t1.[Y0 (u) M11],t1.[Y0 (u) M12],t1.[Y+1 (u) M1],t1.[Y+1 (u) M2],t1.[Y+1 (u) M3],t1.[Y+1 (u) M4],
			t1.[Y+1 (u) M5],t1.[Y+1 (u) M6],t1.[Y+1 (u) M7],t1.[Y+1 (u) M8],
			t1.[Y+1 (u) M9],t1.[Y+1 (u) M10],t1.[Y+1 (u) M11],t1.[Y+1 (u) M12]    
	) t on t.[SUB GROUP/ Brand] = f.[SUB GROUP/ Brand] and t.Channel=f.Channel   
	where f.[SUB GROUP/ Brand] IN
	(
		select distinct
			[SUB GROUP/ Brand] 
		from fc_list_forecasting_line_update_VNCORPVNWKS1154
	)   
	group by     
		s.[Product status],
		 f.[SUB GROUP/ Brand],
		 f.[Channel]   
		,f.[Time series] 
) x On 
	x.[SUB GROUP/ Brand]=f.[SUB GROUP/ Brand] 
and x.[Channel]=f.[Channel] 
and x.[Time series]=f.[Time series] 
and x.[SUB GROUP/ Brand]=@subgrp