/*
	exec sp_get_List_Gap_Percent 'CPD'
*/

ALTER pROC sp_get_List_Gap_Percent
	@Division	nvarchar(3)
As
declare @condition_value nvarchar(50) = '>=80'
declare @sql nvarchar(max)=''
declare @debug int=0

select @sql='
select
	[SUB GROUP/ Brand],
	[Channel],
	[Time series],
	[Y0 (u) M6]=case when [Time series]=''9. BP vs FC (%)'' then format([Y0 (u) M6],''#,##0'')+''%'' else format([Y0 (u) M6],''#,##0'')  end,
	[Y0 (u) M7]=case when [Time series]=''9. BP vs FC (%)'' then format([Y0 (u) M7],''#,##0'')+''%'' else format([Y0 (u) M7],''#,##0'') end,
	[Y0 (u) M8]=case when [Time series]=''9. BP vs FC (%)'' then format([Y0 (u) M8],''#,##0'')+''%'' else format([Y0 (u) M8],''#,##0'') end,
	[Y0 (u) M9]=case when [Time series]=''9. BP vs FC (%)'' then format([Y0 (u) M9],''#,##0'')+''%'' else format([Y0 (u) M9],''#,##0'') end,
	[Y0 (u) M10]=case when [Time series]=''9. BP vs FC (%)'' then format([Y0 (u) M10],''#,##0'')+''%'' else format([Y0 (u) M10],''#,##0'') end,
	[Y0 (u) M11]=case when [Time series]=''9. BP vs FC (%)'' then format([Y0 (u) M11],''#,##0'')+''%'' else format([Y0 (u) M11],''#,##0'') end,
	[Y0 (u) M12]=case when [Time series]=''9. BP vs FC (%)'' then format([Y0 (u) M12],''#,##0'')+''%'' else format([Y0 (u) M12],''#,##0'') end,
	[Y+1 (u) M1]=case when [Time series]=''9. BP vs FC (%)'' then format([Y+1 (u) M1],''#,##0'')+''%'' else format([Y+1 (u) M1],''#,##0'') end,
	[Y+1 (u) M2]=case when [Time series]=''9. BP vs FC (%)'' then format([Y+1 (u) M2],''#,##0'')+''%'' else format([Y+1 (u) M2],''#,##0'') end,
	[Y+1 (u) M3]=case when [Time series]=''9. BP vs FC (%)'' then format([Y+1 (u) M3],''#,##0'')+''%'' else format([Y+1 (u) M3],''#,##0'') end,
	[Y+1 (u) M4]=case when [Time series]=''9. BP vs FC (%)'' then format([Y+1 (u) M4],''#,##0'')+''%'' else format([Y+1 (u) M4],''#,##0'') end,
	[Y+1 (u) M5]=case when [Time series]=''9. BP vs FC (%)'' then format([Y+1 (u) M5],''#,##0'')+''%'' else format([Y+1 (u) M5],''#,##0'') end,
	[Y+1 (u) M6]=case when [Time series]=''9. BP vs FC (%)'' then format([Y+1 (u) M6],''#,##0'')+''%'' else format([Y+1 (u) M6],''#,##0'') end,
	[Y+1 (u) M7]=case when [Time series]=''9. BP vs FC (%)'' then format([Y+1 (u) M7],''#,##0'')+''%'' else format([Y+1 (u) M7],''#,##0'') end,
	[Y+1 (u) M8]=case when [Time series]=''9. BP vs FC (%)'' then format([Y+1 (u) M8],''#,##0'')+''%'' else format([Y+1 (u) M8],''#,##0'') end,
	[Y+1 (u) M9]=case when [Time series]=''9. BP vs FC (%)'' then format([Y+1 (u) M9],''#,##0'')+''%'' else format([Y+1 (u) M9],''#,##0'') end,
	[Y+1 (u) M10]=case when [Time series]=''9. BP vs FC (%)'' then format([Y+1 (u) M10],''#,##0'')+''%'' else format([Y+1 (u) M10],''#,##0'') end,
	[Y+1 (u) M11]=case when [Time series]=''9. BP vs FC (%)'' then format([Y+1 (u) M11],''#,##0'')+''%'' else format([Y+1 (u) M11],''#,##0'') end,
	[Y+1 (u) M12]=case when [Time series]=''9. BP vs FC (%)'' then format([Y+1 (u) M12],''#,##0'')+''%'' else format([Y+1 (u) M12],''#,##0'') end
from FC_FM_Original_'+@Division+'
where [SUB GROUP/ Brand] IN
(
	select DISTINCT 
		[SUB GROUP/ Brand] 
	from FC_FM_Original_'+@Division+'
	where 
		[Time series]=''9. BP vs FC (%)''
	and 
	(
		ABS([Y0 (u) M1]) '+@condition_value+' OR
		ABS([Y0 (u) M2])'+@condition_value+' OR
		ABS([Y0 (u) M3])'+@condition_value+' OR
		ABS([Y0 (u) M4])'+@condition_value+' OR
		ABS([Y0 (u) M5])'+@condition_value+' OR
		ABS([Y0 (u) M6])'+@condition_value+' OR
		ABS([Y0 (u) M7])'+@condition_value+' OR
		ABS([Y0 (u) M8])'+@condition_value+' OR
		ABS([Y0 (u) M9])'+@condition_value+' OR
		ABS([Y0 (u) M10])'+@condition_value+' OR
		ABS([Y0 (u) M11])'+@condition_value+' OR
		ABS([Y0 (u) M12])'+@condition_value+' OR
		ABS([Y+1 (u) M1])'+@condition_value+' OR
		ABS([Y+1 (u) M2])'+@condition_value+' OR
		ABS([Y+1 (u) M3])'+@condition_value+' OR
		ABS([Y+1 (u) M4])'+@condition_value+' OR
		ABS([Y+1 (u) M5])'+@condition_value+' OR
		ABS([Y+1 (u) M6])'+@condition_value+' OR
		ABS([Y+1 (u) M7])'+@condition_value+' OR
		ABS([Y+1 (u) M8])'+@condition_value+' OR
		ABS([Y+1 (u) M9])'+@condition_value+' OR
		ABS([Y+1 (u) M10])'+@condition_value+' OR
		ABS([Y+1 (u) M11])'+@condition_value+' OR
		ABS([Y+1 (u) M12])'+@condition_value+'
	)
)
and [Time series] in(''6. Total Qty'',''7. BP Unit'',''9. BP vs FC (%)'')
order by id '
if @debug>0
begin
	select @sql '@sql'
end
execute(@sql)
/*and [Time series] in(select value from string_split('6. Total Qty,7. BP Unit,8. BP vs FC (u),9. BP vs FC (%)',','))*/