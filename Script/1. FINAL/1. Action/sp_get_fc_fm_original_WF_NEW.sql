/*
	exec sp_get_fc_fm_original_WF_NEW 'CPD','202508','partial'
*/
Alter proc sp_get_fc_fm_original_WF_NEW
	@Division		nvarchar(3),
	@FM_KEY			nvarchar(6),
	@Type			nvarchar(10)--//partial/fc
As
begin
	declare @debug					int=0
	declare @sql					nvarchar(max)=''
	declare @sql2					nvarchar(max)=''
	declare @hostname				nvarchar(50)=''
	select @hostname=host_name()--'VNCORPVNWKS0895'
	
	select @debug=debug from fnc_debug('FC')
	--select @debug=1

	declare @Monthfc				nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from V_FC_FM_Table
	
	declare @tablename		nvarchar(200)=''
	select @tablename='FC_FM_Original_'+@Division+@Monthfc
	
	declare @host_name_admin nvarchar(50)=''
	select @host_name_admin='VNCORPVNWKS0850A'

	if @debug>0
	begin
		select @tablename '@tablename'
	end

	if not exists(select 1 from HOST_NAME_FILTER_WF where Allow_Show=1
		and [HOST_NAME]=@hostname )
	begin
		select @sql=
		'INSERT INTO HOST_NAME_FILTER_WF
			select 
			[HOST_NAME]='''+@hostname+''',
			[List Group Column],
			[List Column],
			[Allow_Show]=1,
			[STT]=[STT]		
		from V_FC_WF_FILTER_CONFIG 
		order by STT asc '

		if @debug>0
		begin
			select @sql  'insert new filter'
		end
		execute(@sql)
	end
	
	if @Type='Partial'
	begin
		declare @listcolumn_partial		nvarchar(max)=''
		declare @listcolumn_partial2	nvarchar(max)=''
		declare @tmp_list_column_parital table (id int identity(1,1), ListGroupColumn nvarchar(200) null,ColumnName nvarchar(max) null)
		declare @currentrow int=1, @totalrows int=0		

		insert into @tmp_list_column_parital(ListGroupColumn,ColumnName)
		SELECT
			[List Group Column],
			[List Column]
		FROM HOST_NAME_FILTER_WF 
		where Allow_Show=1
		and [HOST_NAME]=@hostname
		order by STT asc

		select @totalrows=ISNULL(count(*),0) from @tmp_list_column_parital
		if @debug>0
		begin
			select @totalrows '@totalrows'
		end
		while (@currentrow<=@totalrows)
		begin
			declare @columnName	nvarchar(max)=''
			declare @GroupColumn	nvarchar(max)=''
			select 
				@columnName=isnull(ColumnName,''),
				@GroupColumn=ListGroupColumn 
			from @tmp_list_column_parital 
			where id=@currentrow

			if @Division='LLD1'
			begin
				if @GroupColumn='Risk'
				begin
					select @columnName=''	
				end
			end

			if @listcolumn_partial=''
			begin
				select @listcolumn_partial=@columnName
			end
			else
			begin
				if len(@listcolumn_partial+case when @columnName<>'' then ',' else '' end+@columnName)>4000
				begin
					if len(@listcolumn_partial2)=0
					begin
						select @listcolumn_partial2=@columnName
					end
					else
					begin
						select @listcolumn_partial2=@listcolumn_partial2+case when @columnName<>'' then ',' else '' end+@columnName
					end
					
				end
				else
				begin
					if host_name() NOT IN(@host_name_admin)
					begin
						if @GroupColumn='SLOB'
						begin
							select @columnName=@columnName+',[SLOB VALUE]=CAST(CASE WHEN [SLOB]>0 THEN (F.[SLOB]*slv.[AVERAGE])/1000000 ELSE 0 END AS NUMERIC(18,1))'
						end
					end
					select @listcolumn_partial=@listcolumn_partial+case when @columnName<>'' then ',' else '' end+@columnName
				end
			end	

			select @currentrow=@currentrow+1
		end
		if @debug>0
		begin
			select @listcolumn_partial,@listcolumn_partial2
		end
		if len(@listcolumn_partial2)>0
		begin
			select @sql=
			'select
				[ID],'+@listcolumn_partial
			
			select @sql2=','+@listcolumn_partial2+'
			from '+@tablename+' f
			'+
			case 
				when host_name() NOT IN(@host_name_admin) then 
				'left join
				(
					select 
						[Subgrp]=[SUB GROUP/ Brand],
						[AVERAGE]=ISNULL([AVERAGE],0)
					from FC_SLOB_MAP_PRICE
					where 
						[Division]='''+@Division+'''
					and [FM_KEY]='''+@FM_KEY+'''
				) slv on slv.[Subgrp]=f.[SUB GROUP/ Brand] '
				else
					''
			end+'
			where 
				[FM_KEY]='''+@FM_KEY+'''
			and f.[SUB GROUP/ Brand]<>''''
			order by id asc '
		end
		else
		begin
			select @sql=
			'select
				[ID],'+@listcolumn_partial+
			'from '+@tablename+' f
			'+
			case 
				when host_name() NOT IN(@host_name_admin) then 
				'left join
				(
					select 
						[Subgrp]=[SUB GROUP/ Brand],
						[AVERAGE]=ISNULL([AVERAGE],0)
					from FC_SLOB_MAP_PRICE
					where 
						[Division]='''+@Division+'''
					and [FM_KEY]='''+@FM_KEY+'''
				) slv on slv.[Subgrp]=f.[SUB GROUP/ Brand] '
				else
					''
			end+'
			where 
				[FM_KEY]='''+@FM_KEY+'''
			and f.[SUB GROUP/ Brand]<>''''
			order by id asc '
		end
	end
	else if @Type='fc'
	begin
		declare @listcolumn_fc			nvarchar(max)=''
		SELECT @listcolumn_fc = ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'UploadFM_2','f')
		--SELECT listcolumn_fc = ListColumn FROM fn_FC_GetColheader_Current('202407','UploadFM_2','f')

		declare @listcolumn_fc_value	nvarchar(max)=''
		SELECT @listcolumn_fc_value = ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'wf_copy_fc','f')
		--SELECT listcolumn_fc_value = ListColumn FROM fn_FC_GetColheader_Current('202407','wf_copy_fc','f')

		select @sql='
		select
			'+@listcolumn_fc+','
			+@listcolumn_fc_value+'
		from '+@tablename+' f
		where FM_KEY='''+@FM_KEY+'''
		and f.[SUB GROUP/ Brand]<>''''
		order by id asc'
	end
	if @debug>0
	begin
		select @sql+@sql2 '@sql',len(@sql) '@sql len',len(@sql2) '@sql2 len'
	end
	execute(@sql+@sql2)
end