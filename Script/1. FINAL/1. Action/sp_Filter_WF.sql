/*
	exec sp_Filter_WF_NEW 'CPD','202502','VNCORPVNWKS1154'
	--exec sp_Filter_WF 'CPD','202502'
	SELECT * FROM HOST_NAME_FILTER_WF order by STT asc

	SELECT DISTINCT [HOST_NAME] FROM HOST_NAME_FILTER_WF

	select * from HOST_NAME_FILTER_WF
	--delete HOST_NAME_FILTER_WF where host_name='VNCORPVNWKS0850'
*/

Alter proc sp_Filter_WF_NEW
	@Division		nvarchar(3),
	@FM_KEY			nvarchar(6),
	@hostName_		nvarchar(50)
As
begin
	declare @debug		int=0
	declare @sql		nvarchar(max)=''
	declare @hostname nvarchar(50)=''--host_name()

	if @hostName_=''
	begin
		select @hostname=host_name()--'VNCORPVNWKS1119'
	end
	else
	begin
		select @hostname=@hostName_--'VNCORPVNWKS1154'--host_name()--'VNCORPVNWKS1119'
	end

	declare @tablename		nvarchar(200)=''
	select @tablename='HOST_NAME_FILTER_WF'--+@Division+'_'+@hostname

	if not exists
	(
		SELECT * 
		FROM sys.objects 
		WHERE object_id = OBJECT_ID(@tablename) AND type in (N'U')
	)
	begin
		select @sql=
		'select 
			[HOST_NAME]='''+@hostname+''',
			[List Group Column],
			[List Column],
			[Allow_Show]=1,
			[STT]=[STT]		
			INTO '+@tablename+'
		from V_FC_WF_FILTER_CONFIG 
		order by STT asc '

		if @debug>0
		begin
			select @sql  'insert new filter'
		end
		execute(@sql)
	end
	else
	begin
		if not exists(select 1 from HOST_NAME_FILTER_WF where [HOST_NAME]=@hostname)
		begin
			select @sql=
			'INSERT INTO '+@tablename+'
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
		--else
		--begin
		--	select @sql=
		--	'delete '+@tablename+' where [HOST_NAME]='''+@hostname+'''

		--	INSERT INTO '+@tablename+'
		--	 select 
		--		[HOST_NAME]='''+@hostname+''',
		--		[List Group Column],
		--		[List Column],
		--		[Allow_Show]=1,
		--		[STT]=[STT]		
		--	from V_FC_WF_FILTER_CONFIG 
		--	order by STT asc '

		--	if @debug>0
		--	begin
		--		select @sql  'insert new filter(delete before)'
		--	end
		--	execute(@sql)
		--end
	end
	
	select @sql=
	'SELECT
		[List Group Column],
		[List Column],
		[Allow_Show]
	FROM '+@tablename+' 
	WHERE [HOST_NAME]='''+@hostname+'''
	order by [STT] asc '
	if @debug>0
	begin
		select @sql  'select filter'
	end
	execute(@sql)
END

--//------------------------------------------------------------

Alter proc sp_Filter_WF
	@Division		nvarchar(3),
	@FM_KEY			nvarchar(6)
As
begin
	declare @debug		int=0
	declare @sql		nvarchar(max)=''
	declare @hostname nvarchar(50)=''--host_name()
	select @hostname=host_name()--'VNCORPVNWKS1119'
	--select @hostname='VNCORPVNWKS1154'--host_name()--'VNCORPVNWKS1119'

	declare @tablename		nvarchar(200)=''
	select @tablename='HOST_NAME_FILTER_WF'--+@Division+'_'+@hostname

	if not exists
	(
		SELECT * 
		FROM sys.objects 
		WHERE object_id = OBJECT_ID(@tablename) AND type in (N'U')
	)
	begin
		select @sql=
		'select 
			[HOST_NAME]='''+@hostname+''',
			[List Group Column],
			[List Column],
			[Allow_Show]=1,
			[STT]=[STT]		
			INTO '+@tablename+'
		from V_FC_WF_FILTER_CONFIG 
		order by STT asc '

		if @debug>0
		begin
			select @sql  'insert new filter'
		end
		execute(@sql)
	end
	else
	begin
		if not exists(select 1 from HOST_NAME_FILTER_WF where [HOST_NAME]=@hostname)
		begin
			select @sql=
			'INSERT INTO '+@tablename+'
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
		--else
		--begin
		--	select @sql=
		--	'delete '+@tablename+' where [HOST_NAME]='''+@hostname+'''

		--	INSERT INTO '+@tablename+'
		--	 select 
		--		[HOST_NAME]='''+@hostname+''',
		--		[List Group Column],
		--		[List Column],
		--		[Allow_Show]=1,
		--		[STT]=[STT]		
		--	from V_FC_WF_FILTER_CONFIG 
		--	order by STT asc '

		--	if @debug>0
		--	begin
		--		select @sql  'insert new filter(delete before)'
		--	end
		--	execute(@sql)
		--end
	end
	
	select @sql=
	'SELECT
		[List Group Column],
		[List Column],
		[Allow_Show]
	FROM '+@tablename+' 
	WHERE [HOST_NAME]='''+@hostname+'''
	order by [STT] asc '
	if @debug>0
	begin
		select @sql  'select filter'
	end
	execute(@sql)
end