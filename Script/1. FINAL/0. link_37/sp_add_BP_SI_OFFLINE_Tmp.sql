
/*
	declare 
		@b_Success			Int,
		@c_errmsg			Nvarchar(250)
		
	exec sp_add_BP_SI_OFFLINE_Tmp 'CPD','202410',@b_Success OUT, @c_errmsg OUT

	select @b_Success b_Success, @c_errmsg c_errmsg

	select * from FC_BP_SI_OFFLINE_CPD_Tmp where [sub-group]='MAGNUM'
	select * from FC_BP_SI_OFFLINE_CPD_Tmp_raw
*/
Create or Alter proc sp_add_BP_SI_OFFLINE_Tmp
	@Division			nvarchar(3),
	@FM_KEY				nvarchar(6),
	@b_Success			Int				OUTPUT,     
	@c_errmsg			Nvarchar(250)	OUTPUT
	with encryption
As
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRAN
BEGIN TRY
	DECLARE   
		 @debug					int=0
		,@sp_name				Nvarchar(100)
		,@n_continue			Int
		,@USERS					Nvarchar(50)
		,@MODIFILED				Datetime
		,@n_err					int
		,@sql					nvarchar(max) = ''
		,@sql1					nvarchar(max) = ''

	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_add_BP_SI_OFFLINE_Tmp',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()
	declare @SharefolderPath nvarchar(500)
	select @SharefolderPath = Value from [SC2].[dbo].[EnvironmentConfig] where Name = 'Sharefolder_SAP_Dir'

	declare @Monthfc				nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from link_33.sc2.dbo.V_FC_FM_Table

	declare @filename				nvarchar(500) = ''
	select @filename = 'BP_OFFLINE_'+@FM_KEY+'.xlsx'

	declare @tablename_tmp nvarchar(200) = ''
	select @tablename_tmp = 'FC_BP_SI_OFFLINE_'+@Division+@Monthfc+'_Tmp_raw'
	
	declare @tablename nvarchar(200) = ''
	select @tablename = 'FC_BP_SI_OFFLINE_'+@Division+@Monthfc+'_Tmp'

	declare @Full_name nvarchar(500) = ''
	select @Full_name = @SharefolderPath +'\Pending\FORECAST\'+@Division+'\BP_SI\OFFLINE\'+@filename

	if @n_continue = 1
	begin
		if (select dbo.fn_FileExists(@Full_name)) = 1
		begin
			if exists
			(
				SELECT * 
				FROM sys.objects 
				WHERE object_id = OBJECT_ID(@tablename_tmp) AND type in (N'U')
			)
			begin				
				select @sql = 'drop table '+@tablename_tmp
				if @debug>0
				begin
					select @sql 'Drop raw'
				end
				execute(@sql)
			end

			if exists
			(
				SELECT * 
				FROM sys.objects 
				WHERE object_id = OBJECT_ID(@tablename) AND type in (N'U')
			)
			begin				
				select @sql = 'drop table '+@tablename
				if @debug>0
				begin
					select @sql 'Drop table tmp'
				end
				execute(@sql)
			end
			select @sql='
			create table '+@tablename+'
			(
				[Filename]				nvarchar(500) null,
				[sub-group]				nvarchar(100) null,
				[Channel]				nvarchar(10) null,
				[Y0 (u) M1]				nvarchar(50) null,
				[Y0 (u) M2]				nvarchar(50) null,
				[Y0 (u) M3]				nvarchar(50) null,
				[Y0 (u) M4]				nvarchar(50) null,
				[Y0 (u) M5]				nvarchar(50) null,
				[Y0 (u) M6]				nvarchar(50) null,
				[Y0 (u) M7]				nvarchar(50) null,
				[Y0 (u) M8]				nvarchar(50) null,
				[Y0 (u) M9]				nvarchar(50) null,
				[Y0 (u) M10]			nvarchar(50) null,
				[Y0 (u) M11]			nvarchar(50) null,
				[Y0 (u) M12]			nvarchar(50) null,
				[Y+1 (u) M1]			nvarchar(50) null,
				[Y+1 (u) M2]			nvarchar(50) null,
				[Y+1 (u) M3]			nvarchar(50) null,
				[Y+1 (u) M4]			nvarchar(50) null,
				[Y+1 (u) M5]			nvarchar(50) null,
				[Y+1 (u) M6]			nvarchar(50) null,
				[Y+1 (u) M7]			nvarchar(50) null,
				[Y+1 (u) M8]			nvarchar(50) null,
				[Y+1 (u) M9]			nvarchar(50) null,
				[Y+1 (u) M10]			nvarchar(50) null,
				[Y+1 (u) M11]			nvarchar(50) null,
				[Y+1 (u) M12]			nvarchar(50) null
			)'			
				 
			if @debug>0
			begin
				select @sql 'create table tmp'
			end
			execute(@sql)
			
			select @sql =
			'select
				Filename = '''+@filename+''',
				*
				INTO '+@tablename_tmp+'
			From OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',
							''Excel 12.0; HDR=YES; IMEX=1;Database='+@Full_name+''',
							''SELECT * FROM [O+O FC$] where [F8]=''''OFFLINE'''' '')'
			if @debug>0
			begin
				select @sql 'insert table tmp raw'
			end
			execute(@sql)
		end
		else
		begin
			select @n_continue =3, @c_errmsg = 'No files.../'
		end
	end
	if @n_continue=1
	begin
		select @sql='
		insert into '+@tablename+'
		(
			[Filename],
			[sub-group],
			[Channel],
			[Y0 (u) M1],
			[Y0 (u) M2],
			[Y0 (u) M3],
			[Y0 (u) M4],
			[Y0 (u) M5],
			[Y0 (u) M6],
			[Y0 (u) M7],
			[Y0 (u) M8],
			[Y0 (u) M9],
			[Y0 (u) M10],
			[Y0 (u) M11],
			[Y0 (u) M12],
			[Y+1 (u) M1],
			[Y+1 (u) M2],
			[Y+1 (u) M3],
			[Y+1 (u) M4],
			[Y+1 (u) M5],
			[Y+1 (u) M6],
			[Y+1 (u) M7],
			[Y+1 (u) M8],
			[Y+1 (u) M9],
			[Y+1 (u) M10],
			[Y+1 (u) M11],
			[Y+1 (u) M12]
		)
		select
			[Filename]=[Filename],
			[sub-group]=[F6],
			[Channel]=[F8],
			[Y0 (u) M1]=case when charindex(''('',isnull([F96],0))>0 then ''-''+isnull(replace(replace([F96],''('',''''),'')'',''''),0) else isnull(replace([F96],''-'',''0''),0) end,
			[Y0 (u) M2]=case when charindex(''('',isnull([F97],0))>0 then ''-''+isnull(replace(replace([F97],''('',''''),'')'',''''),0) else isnull(replace([F97],''-'',''0''),0) end,
			[Y0 (u) M3]=case when charindex(''('',isnull([F98],0))>0 then ''-''+isnull(replace(replace([F98],''('',''''),'')'',''''),0) else isnull(replace([F98],''-'',''0''),0) end,
			[Y0 (u) M4]=case when charindex(''('',isnull([F99],0))>0 then ''-''+isnull(replace(replace([F99],''('',''''),'')'',''''),0) else isnull(replace([F99],''-'',''0''),0) end,
			[Y0 (u) M5]=case when charindex(''('',isnull([F100],0))>0 then ''-''+isnull(replace(replace([F100],''('',''''),'')'',''''),0) else isnull(replace([F100],''-'',''0''),0) end,
			[Y0 (u) M6]=case when charindex(''('',isnull([F101],0))>0 then ''-''+isnull(replace(replace([F101],''('',''''),'')'',''''),0) else isnull(replace([F101],''-'',''0''),0) end,
			[Y0 (u) M7]=case when charindex(''('',isnull([F102],0))>0 then ''-''+isnull(replace(replace([F102],''('',''''),'')'',''''),0) else isnull(replace([F102],''-'',''0''),0) end,
			[Y0 (u) M8]=case when charindex(''('',isnull([F103],0))>0 then ''-''+isnull(replace(replace([F103],''('',''''),'')'',''''),0) else isnull(replace([F103],''-'',''0''),0) end,
			[Y0 (u) M9]=case when charindex(''('',isnull([F104],0))>0 then ''-''+isnull(replace(replace([F104],''('',''''),'')'',''''),0) else isnull(replace([F104],''-'',''0''),0) end,
			[Y0 (u) M10]=case when charindex(''('',isnull([F105],0))>0 then ''-''+isnull(replace(replace([F105],''('',''''),'')'',''''),0) else isnull(replace([F105],''-'',''0''),0) end,
			[Y0 (u) M11]=case when charindex(''('',isnull([F106],0))>0 then ''-''+isnull(replace(replace([F106],''('',''''),'')'',''''),0) else isnull(replace([F106],''-'',''0''),0) end,
			[Y0 (u) M12]=case when charindex(''('',isnull([F107],0))>0 then ''-''+isnull(replace(replace([F107],''('',''''),'')'',''''),0) else isnull(replace([F107],''-'',''0''),0) end,'
	select @sql1='			
			[Y+1 (u) M1]=case when charindex(''('',isnull([9#2%],0))>0 then ''-''+isnull(replace(replace([9#2%],''('',''''),'')'',''''),0) else isnull(replace([9#2%],''-'',''0''),0) end,
			[Y+1 (u) M2]=case when charindex(''('',isnull([7#3%],0))>0 then ''-''+isnull(replace(replace([7#3%],''('',''''),'')'',''''),0) else isnull(replace([7#3%],''-'',''0''),0) end,
			[Y+1 (u) M3]=case when charindex(''('',isnull([8#4%],0))>0 then ''-''+isnull(replace(replace([8#4%],''('',''''),'')'',''''),0) else isnull(replace([8#4%],''-'',''0''),0) end,
			[Y+1 (u) M4]=case when charindex(''('',isnull([7#4%],0))>0 then ''-''+isnull(replace(replace([7#4%],''('',''''),'')'',''''),0) else isnull(replace([7#4%],''-'',''0''),0) end,
			[Y+1 (u) M5]=case when charindex(''('',isnull([7#9%],0))>0 then ''-''+isnull(replace(replace([7#9%],''('',''''),'')'',''''),0) else isnull(replace([7#9%],''-'',''0''),0) end,			
			[Y+1 (u) M6]=case when charindex(''('',isnull([8#2%],0))>0 then ''-''+isnull(replace(replace([8#2%],''('',''''),'')'',''''),0) else isnull(replace([8#2%],''-'',''0''),0) end,
			[Y+1 (u) M7]=case when charindex(''('',isnull([7#1%],0))>0 then ''-''+isnull(replace(replace([7#1%],''('',''''),'')'',''''),0) else isnull(replace([7#1%],''-'',''0''),0) end,
			[Y+1 (u) M8]=case when charindex(''('',isnull([7#8%],0))>0 then ''-''+isnull(replace(replace([7#8%],''('',''''),'')'',''''),0) else isnull(replace([7#8%],''-'',''0''),0) end,
			[Y+1 (u) M9]=case when charindex(''('',isnull([8#1%],0))>0 then ''-''+isnull(replace(replace([8#1%],''('',''''),'')'',''''),0) else isnull(replace([8#1%],''-'',''0''),0) end,
			[Y+1 (u) M10]=case when charindex(''('',isnull([8#9%],0))>0 then ''-''+isnull(replace(replace([8#9%],''('',''''),'')'',''''),0) else isnull(replace([8#9%],''-'',''0''),0) end,
			[Y+1 (u) M11]=case when charindex(''('',isnull([8#9%1],0))>0 then ''-''+isnull(replace(replace([8#9%1],''('',''''),'')'',''''),0) else isnull(replace([8#9%1],''-'',''0''),0) end,
			[Y+1 (u) M12]=case when charindex(''('',isnull([10#9%],0))>0 then ''-''+isnull(replace(replace([10#9%],''('',''''),'')'',''''),0) else isnull(replace([10#9%],''-'',''0''),0) end
		from '+@tablename_tmp+'
		where isnull([F1],'''')<>'''' 
		and left(isnull([F96],''''),9)<>''Q_Y_M0 FC''
		and [F6]<>''SUB GROUP'' '

--		select CHARINDEX('h','phuong')
		if @debug>0
		begin
			select @sql+@sql1 'insert table tmp'
		end
		execute(@sql+@sql1)
	end

	if @n_continue = 3
	begin
		rollback
		select @b_Success = 0
	end
	else
	begin
		Commit
		select @b_Success = 1, @c_errmsg = 'Successfully.../'
	end
END TRY
BEGIN CATCH
   ROLLBACK
   DECLARE @ErrorMessage VARCHAR(2000)
   SELECT @ErrorMessage = 'Error: '+ ERROR_MESSAGE()
   RAISERROR(@ErrorMessage , 16, 1)
END CATCH