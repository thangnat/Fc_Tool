--exec sp_set_FMKEY 'hoaiphuong.ho','202407',0,''
declare @FM_KEY nvarchar(6)='202407'
declare @division nvarchar(3)='CPD'
declare @sql nvarchar(max)=''
declare @Foldername nvarchar(2)='T'

declare @table_budget		nvarchar(200)='fc_validate_mismatch_si_bud'
declare @FunctionName		nvarchar(50)=''
declare @Type				nvarchar(50)=''

declare @listA	nvarchar(max)
SELECT @listA=listcolumn FROM fn_FC_GetColheader_Current_BT(@FM_KEY,'','B',103)
--SELECT listA=listcolumn FROM fn_FC_GetColheader_Current_BT('202407','','B',103)
declare @listB	nvarchar(max)
SELECT @listB=listcolumn FROM fn_FC_GetColheader_Current_BT(@FM_KEY,'','B',1031)
--SELECT listB=listcolumn FROM fn_FC_GetColheader_Current_BT('202407','','B',1031)

declare @list_column_set0 nvarchar(max)=''
select @list_column_set0='[Y-2 (u) M1]=0,[Y-2 (u) M2]=0,[Y-2 (u) M3]=0,[Y-2 (u) M4]=0,[Y-2 (u) M5]=0,[Y-2 (u) M6]=0,
[Y-2 (u) M7]=0,[Y-2 (u) M8]=0,[Y-2 (u) M9]=0,[Y-2 (u) M10]=0,[Y-2 (u) M11]=0,[Y-2 (u) M12]=0,
[Y-1 (u) M1]=0,[Y-1 (u) M2]=0,[Y-1 (u) M3]=0,[Y-1 (u) M4]=0,[Y-1 (u) M5]=0,[Y-1 (u) M6]=0,
[Y-1 (u) M7]=0,[Y-1 (u) M8]=0,[Y-1 (u) M9]=0,[Y-1 (u) M10]=0,[Y-1 (u) M11]=0,[Y-1 (u) M12]=0'

select @FunctionName=case 
							when @Foldername='B' then 'Budget' 
							when @Foldername='PB' then 'Pre_Budget' 
							when @Foldername='T' then 'Trend' 
							else '' 
						end

select @table_budget='FC_'+case 
								when @Foldername='B' then 'Budget' 
								when @Foldername='PB' then 'Pre_Budget' 
								when @Foldername='T' then 'Trend' 
								else '' 
							end+'_'+@division++'_'+@fm_key
select @sql=
'select
	[Division]='''+@Division+''',
	[FM_KEY]='''+@FM_KEY+''',
	[Function Name]='''+@FunctionName+''',
	[Type Name]='''+@Type+''',
	[SUB GROUP/ Brand],
	[Channel],
	[Time series],
	[EAN Code],
	[SKU Code],'
	+@list_column_set0+','+@listB+'
from
(
	select
		[SUB GROUP/ Brand]=[SUB-GROUP],
		[Channel],
		[Time series],
		[EAN Code]=[EAN],
		[SKU Code]='''',
		[year],'+@listA+'
	from 
	(
		select 
			[Channel],
			[EAN],
			[SUB-GROUP],
			[Time series],
			[M1],
			[M2],
			[M3],
			[M4],
			[M5],
			[M6],
			[M7],
			[M8],
			[M9],
			[M10],
			[M11],
			[M12],
			[Year]=case when [version]=year(getdate()) then ''Y0'' else ''Y+1'' end
		from '+@table_budget+'
	) as x
	left join
	(
		select DISTINCT
			[SUB GROUP/ Brand]
		from fnc_SubGroupMaster('''+@division+''',''full'')
	) s on s.[SUB GROUP/ Brand]=x.[SUB-GROUP]
	where 
		isnull(s.[SUB GROUP/ Brand],'''')<>''''
) as x
group by
	[Channel],
	[SUB GROUP/ Brand],
	[Time series],
	[EAN Code],
	[SKU Code]'

--select @sql
execute(@sql)