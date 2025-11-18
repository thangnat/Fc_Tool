/*
	exec sp_Get_Function_Active_By_PC_nEW 'CPD','202502',''

	select * from FC_FUNCTION_ACTIVE_VNCORPVNWKS0850

	select distinct [Signature] from FC_FM_Original_CPD_202407
*/

Alter proc sp_Get_Function_Active_By_PC_New
	@Division				nvarchar(3),
	@FM_KEY					Nvarchar(6),
	@Selected				nvarchar(3)--//ALL,''
As
begin
	declare @debug			int=0
	declare @sql			nvarchar(max)=''
	declare @tablename		nvarchar(200)=''
	declare @hostname		nvarchar(50)=host_name()
	declare @USERS			Nvarchar(50)=SUSER_NAME()
	--select @hostname='VNCORPVNWKS1119'
	select @tablename='[FC_FUNCTION_ACTIVE_'+@hostname + ']'
	--select tablename='FC_FUNCTION_ACTIVE_'+HOST_NAME()
	
	declare @FM_KEY_Tmp nvarchar(6)=''
	select @FM_KEY_Tmp=format(DATEADD(MM,-1,getdate()),'yyyyMM')
	
	if @debug>0
	begin
		select 'drop table before run'
	end
	if exists
	(
		SELECT * 
		FROM sys.objects 
		WHERE object_id = OBJECT_ID(@tablename) AND type in (N'U')
	)
	begin
		select @sql='drop table '+@tablename

		if @debug>0
		begin
			select @sql '@sql drop table FC_FUNCTION_ACTIVE_'
		end
		execute(@sql)
	end
	if @debug>0
	begin
		select 'insert table'
	end	
	--//create new table
	if @USERS NOT IN('admin123')
	begin
		declare @list_signature		nvarchar(500)=''
		declare @table_tmp_pc		nvarchar(100)=''
		
		declare @tmpsignature table(id int identity(1,1), [Signature] nvarchar(50) null)
		
		if not exists
		(
			select 1
			from fnc_SubGroupMaster(@Division,'full') 
			where ISNULL([Signature],'')<>''
		)
		begin
			update FC_ComputerName
			set 
				UserID=@USERS,
				FM_KEY=@FM_KEY_Tmp
			where ComputerName=HOST_NAME()
		end

		if @Division ='LLD'
		begin
			insert into @tmpsignature
			(
				[Signature]
			)
			select distinct 
				[Signature] 
			from FC_BFL_Master_LLD
			where isnull([Signature],'')<>''

			--select DISTINCT
			--	[Signature]
			--from fnc_SubGroupMaster(@division,'full') 
			--where ISNULL([Signature],'')<>''
		end
		else if @Division ='CPD'
		begin
			insert into @tmpsignature
			(
				[Signature]
			)
			select distinct 
				[Signature] 
			from FC_BFL_Master_CPD
			where isnull([Signature],'')<>''
		end
		else if @Division ='PPD'
		begin
			insert into @tmpsignature
			(
				[Signature]
			)
			select distinct 
				[Signature] 
			from FC_BFL_Master_PPD
			where isnull([Signature],'')<>''
		end
		else if @Division ='LDB'
		begin
			insert into @tmpsignature
			(
				[Signature]
			)
			select distinct 
				[Signature] 
			from FC_BFL_Master_LDB
			where isnull([Signature],'')<>''
		end
		
		update FC_ComputerName
		set 
			UserID=@USERS,
			FM_KEY=@FM_KEY
		where ComputerName=HOST_NAME()

		declare @currentrow int=1,@totalrows int=0
		select @totalrows=isnull(count(*),0) from @tmpsignature

		while (@currentrow<=@totalrows)
		begin
			declare @signature nvarchar(50)=''
			select @signature=[Signature] from @tmpsignature where id=@currentrow

			if len(@list_signature)=0
			begin
				select @list_signature='['+@signature+']=cast('''+case when @Selected='ALL' then '1' else '0' end+''' as bit)'
			end
			else
			begin
				select @list_signature=@list_signature+',['+@signature+']=cast('''+case when @Selected='ALL' then '1' else '0' end+''' as bit)'
			end

			select @currentrow=@currentrow+1
		end
		if @debug>0
		begin
			select @list_signature '@list_signature'
		end

		select @sql='
		select 
			[Selected]=cast('''+case when @Selected='ALL' then '1' else '0' end+''' as BIT),
			[ID],
			[Tag_name],
			[Generated Data]=[Caption],
			[Active],
			[STT]'+case when len(@list_signature)>0 then ',' else '' end+@list_signature+'
			INTO '+@tablename+'
		from fnc_TypeView('''',''a'','''') 
		where [Tag_name] NOT IN(''tag_create_FC_FM_Original'')
		order by STT ASC '
		--'+@list_signature+'
		if @debug>0
		begin
			select @sql 'Insert table'
		end
		execute(@sql)
	end
	
	if @debug>0
	begin
		select 'selected table just created'
	end
	--//select table output
	select @sql=
	'select 
		*
	from '+@tablename+'
	order by STT ASC '

	if @debug>0
	begin
		select @sql 'select table'
	end
	execute(@sql)
end

