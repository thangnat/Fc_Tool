declare @sql nvarchar(max)=''
declare @listcolumn nvarchar(max)=''
declare @Division nvarchar(3)='CPD'
declare @FM_KEY nvarchar(6)='202411'
declare @FunctionName nvarchar(50)=''
declare @Type nvarchar(50)=''
declare @foldername nvarchar(50)='B'
declare @tablename nvarchar(200)='FC_Budget_'+@division++'_'+@fm_key

declare @ListColumn_Current_plus	nvarchar(max) = ''
SELECT @ListColumn_Current_plus = ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'1. Baseline Qty_+','')
--SELECT ListColumn_Current_plus = ListColumn FROM fn_FC_GetColheader_Current('202410','1. Baseline Qty_+','f')

declare @ListColumn_Current	nvarchar(max) = ''
SELECT @ListColumn_Current = ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'UploadFM_2','f')
--SELECT ListColumn_Current = ListColumn FROM fn_FC_GetColheader_Current('202410','UploadFM_2','f')

declare @ListColumn_Current_validate_RSP_text	nvarchar(max) = ''
SELECT @ListColumn_Current_validate_RSP_text=ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'validate_rsp_text','')
--SELECT ListColumn_Current_validate_RSP_text=ListColumn FROM fn_FC_GetColheader_Current('202407','validate_rsp_text','')

declare @ListColumn_Current_sum			nvarchar(max) = ''
SELECT @ListColumn_Current_sum = ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'1. Baseline Qty','')
--SELECT ListColumn_Current_sum = ListColumn FROM fn_FC_GetColheader_Current('202410','1. Baseline Qty','')

declare @ListColumn_Current_validate_RSP	nvarchar(max) = ''
SELECT @ListColumn_Current_validate_RSP=ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'validate_rsp','x')
--SELECT ListColumn_Current_validate_RSP=ListColumn FROM fn_FC_GetColheader_Current('202410','validate_rsp','x')

--select top 1 * from fc_validate_mismatch

declare @tablename_tmp		nvarchar(50)= ''
		
if @foldername= 'B'
begin
	select @tablename_tmp = 'FC_Budget_'+@Division+'_Tmp'
end
else if @foldername = 'PB'
begin
	select @tablename_tmp = 'FC_Pre_Budget_'+@Division+'_Tmp'	
end
else if @foldername = 'T'
begin
	select @tablename_tmp = 'FC_Trend_'+@Division+'_Tmp'	
end
--select @tablename_tmp '@tablename_tmp'

select @sql=
'select
	[Division]='''+@Division+''',
	[FM_KEY]='''+@FM_KEY+''',
	[Function Name]='''',
	[Type Name]='''',
	[SUB GROUP/ Brand]=[SUB-GROUP],
	[Channel],
	[Time series],
	[EAN Code]=[EAN],
	[SKU Code]='''',
	[M1]=sum([M1]),
	[M2]=sum([M2]),
	[M3]=sum([M3]),
	[M4]=sum([M4]),
	[M5]=sum([M5]),
	[M6]=sum([M6]),
	[M7]=sum([M7]),
	[M8]=sum([M8]),
	[M9]=sum([M9]),
	[M10]=sum([M10]),
	[M11]=sum([M11]),
	[M12]=sum([M12])
from '+@tablename+'
where isnull([SUB-GROUP],'''')=''''
group by
	[Channel],
	[SUB-GROUP],
	[Time series],
	[EAN] '
select @sql
execute(@sql)