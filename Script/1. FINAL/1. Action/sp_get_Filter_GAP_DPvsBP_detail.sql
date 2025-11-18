/*
	exec sp_get_Filter_GAP_DPvsBP_detail 'CPD','202408',0,'GRN MCLR WTR PINK 400ML',1
*/
	
Alter proc sp_get_Filter_GAP_DPvsBP_detail
	@Division			nvarchar(3),
	@FM_KEY				nvarchar(6),
	@Header				nvarchar(1),
	@Subgrp				nvarchar(300),
	@CreateFilter		int
As
begin
	declare @debug				int=0
	declare @tableName			nvarchar(200)=''
	declare @sql				nvarchar(max)=''

	select @tableName='FC_FILTER_GAP_DPvsBP_'+@division+'_'+HOST_NAME()

	
	select @sql=
	'select * 
	from '+@tableName +' 
	where 
		[Forecasting Line]='''+@Subgrp+''' 
	order by ID asc '
	
	if @debug>0
	begin
		select @sql 'get data'
	end
	execute(@sql)
	/*len('''+@Subgrp+''')=0 OR */
	if @CreateFilter = 1
	begin
		exec sp_createDataSet 'sp_get_Filter_GAP_DPvsBP','dt_name'
	end
end
