/*
	Declare
		@b_Success			Int,
		@c_errmsg			Nvarchar(250)

	exec sp_add_FC_GIT_Tmp 'LDB','202502','GIT_202502.xlsx',@b_Success OUT,@c_errmsg OUT

	select @b_Success b_Success,@c_errmsg c_errmsg

	select * from FC_GIT_LDB_202502_Tmp
*/

Create or Alter proc sp_add_FC_GIT_Tmp
	@Division			nvarchar(3),
	@FM_KEY				nvarchar(6),
	@filename			nvarchar(500),
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

	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_add_FC_GIT_Tmp',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()
	declare @SharefolderPath nvarchar(500)
	select @SharefolderPath = Value from [SC2].[dbo].[EnvironmentConfig] where Name = 'Sharefolder_SAP_Dir'

	declare @Monthfc				nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from link_33.sc2.dbo.V_FC_FM_Table

	declare @tablename nvarchar(100) = ''
	select @tablename = 'FC_GIT_'+@Division+@Monthfc+'_Tmp'

	declare @tablename_LDB_More1 nvarchar(100) = ''
	declare @Filename_LDB_More nvarchar(500)=''
	declare @tablename_LDB_More nvarchar(100) = ''
	declare @Full_name nvarchar(500) = ''
	declare @Full_name_LDB_more nvarchar(500) = ''

	if @n_continue=9
	begin
		if @Division='LDB'
		begin
			select @tablename_LDB_More1 = 'FC_GIT_'+@Division+@Monthfc+'_More_Tmp1'
		end
		select @tablename_LDB_More = 'FC_GIT_'+@Division+@Monthfc+'_More_Tmp'
	end

	select @Filename_LDB_More=''
	if @Division IN('CPD')
	begin
		select @Full_name = @SharefolderPath +'\Pending\GIT_FC\'+@filename
	end
	else
	begin
		select @Full_name=@SharefolderPath +'\Pending\FORECAST\'+@Division+'\GIT\'+@filename
	end
	--else if @Division IN('LDB')
	--begin
	--	select @Full_name = @SharefolderPath +'\Pending\GIT_FC\'+@filename
	--	--select @Filename_LDB_More='GIT_'+@FM_KEY+'.xlsx'
	--end
	
	--if @Division='LDB'
	--begin
	--	select @Full_name_LDB_more = @SharefolderPath +'\Pending\FORECAST\'+@Division+'\GIT\'+@Filename_LDB_More
	--end
	if @debug>0
	begin
		select 'Import data CPD, LLD, PPD, LDB'
		select @Full_name '@Full_name'
	end
	if @n_continue=1
	begin
		if (select dbo.fn_FileExists(@Full_name)) = 1
		begin
			if @Division IN('CPD')--,'LDB')
			begin
				if exists
				(
					SELECT * 
					FROM sys.objects 
					WHERE object_id = OBJECT_ID(@tablename) AND type in (N'U')
				)
				begin
					select @sql ='drop table '+@tablename
					if @debug>0
					begin
						select @sql '@sql drop table'
					end
					execute(@sql)
				end

				select @sql =
				'select
					Filename = '''+@filename+''',
					*
					INTO '+@tablename+'
				From OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',
								''Excel 12.0; HDR=YES; IMEX=1;Database='+@Full_name+''',
								''SELECT * FROM [Sheet1$]'')'

				if @debug>0
				begin
					select @sql '@sql import data CPD, LDB'
				end
				execute(@sql)

				select @n_err = @@ERROR
				if @n_err<>0
				begin
					select @n_continue = 3
					--select @n_err=60003
					select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +ERROR_MESSAGE()+'./ ('+@sp_name+')'
				end
			end
			else if @Division in('LLD','PPD','LDB')
			begin
				if exists
				(
					SELECT * 
					FROM sys.objects 
					WHERE object_id = OBJECT_ID(@tablename) AND type in (N'U')
				)
				begin
					select @sql ='drop table '+@tablename
					if @debug>0
					begin
						select @sql '@sql drop table'
					end
					execute(@sql)
				end

				select @sql =
				'select
					Filename = '''+@filename+''',
					*
					INTO '+@tablename+'
				From OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',
								''Excel 12.0; HDR=YES; IMEX=1;Database='+@Full_name+''',
								''SELECT * FROM [GIT$] where ([M1]+[M2]+[M3]+[M4])<>0'')'

				if @debug>0
				begin
					select @sql '@sql import data'
				end
				execute(@sql)

				select @n_err = @@ERROR
				if @n_err<>0
				begin
					select @n_continue = 3
					--select @n_err=60003
					select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +ERROR_MESSAGE()+'./ ('+@sp_name+')'
				end
			end
		end
		else
		begin
			select @n_continue =3, @c_errmsg = 'No files.../'
		end
	end

	--if @debug>0
	--begin
	--	select 'Import data LDB more1'
	--end
	--if @n_continue=9
	--begin
	--	if (select dbo.fn_FileExists(@Full_name_LDB_more)) = 1
	--	begin
	--		if @Division='LDB'
	--		begin
	--			if exists
	--			(
	--				SELECT * 
	--				FROM sys.objects 
	--				WHERE object_id = OBJECT_ID(@tablename_LDB_More1) AND type in (N'U')
	--			)
	--			begin
	--				select @sql ='drop table '+@tablename_LDB_More1
	--				if @debug>0
	--				begin
	--					select @sql '@sql drop table more 1'
	--				end
	--				execute(@sql)
	--			end
	--			select @sql=
	--			'create table '+@tablename_LDB_More1+'
	--			(
	--				[Filename]			nvarchar(500) null,
	--				[SAP Code]			nvarchar(30) null,
	--				[EAN Code]			nvarchar(30) null,
	--				[Description]		nvarchar(500) null,
	--				[GIT M0]			nvarchar(20) default ''0'',
	--				[GIT M1]			nvarchar(20) default ''0'',
	--				[GIT M2]			nvarchar(20) default ''0'',
	--				[GIT M3]			nvarchar(20) default ''0''
	--			) '
	--			if @debug>0
	--			begin
	--				select @sql '@sql create table more'
	--			end
	--			execute(@sql)


	--			select @sql =

	--			'INSERT INTO '+@tablename_LDB_More1+'
	--			select
	--				Filename = '''+@Filename_LDB_More+''',
	--				*
	--			From OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',
	--							''Excel 12.0; HDR=YES; IMEX=1;Database='+@SharefolderPath +'\Pending\FORECAST\'+@Division+'\GIT\'+@Filename_LDB_More+''',
	--							''SELECT * FROM [Sheet1$]'')'

	--			if @debug>0
	--			begin
	--				select @sql '@sql import data LDB more1'
	--			end
	--			execute(@sql)

	--			select @n_err = @@ERROR
	--			if @n_err<>0
	--			begin
	--				select @n_continue = 3
	--				--select @n_err=60003
	--				select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +ERROR_MESSAGE()+'./ ('+@sp_name+')'
	--			end
	--		end
	--	end
	--	if @debug>0
	--	begin
	--		select 'Import data LDB more'
	--	end
	--	if @n_continue=9
	--	begin
	--		if @Division='LDB'
	--		begin
	--			--insert tmp table more
	--			if exists
	--			(
	--				SELECT * 
	--				FROM sys.objects 
	--				WHERE object_id = OBJECT_ID(@tablename_LDB_More) AND type in (N'U')
	--			)
	--			begin
	--				select @sql ='drop table '+@tablename_LDB_More
	--				if @debug>0
	--				begin
	--					select @sql '@sql drop table more'
	--				end
	--				execute(@sql)
	--			end
	--			select @sql=
	--			'create table '+@tablename_LDB_More+'
	--			(
	--				[Filename]			nvarchar(500) null,
	--				[SAP Code]			nvarchar(30) null,
	--				[EAN Code]			nvarchar(30) null,
	--				[Description]		nvarchar(500) null,
	--				[GIT M0]			numeric(18,0) default 0,
	--				[GIT M1]			numeric(18,0) default 0,
	--				[GIT M2]			numeric(18,0) default 0,
	--				[GIT M3]			numeric(18,0) default 0
	--			) '
	--			if @debug>0
	--			begin
	--				select @sql '@sql create table more'
	--			end
	--			execute(@sql)
			
			
	--			--select @tablename_LDB_More '@tablename_LDB_More', @tablename_LDB_More1 '@tablename_LDB_More1'
	--			select @sql=
	--			'INSERT INTO '+@tablename_LDB_More+'
	--			(
	--				[Filename],
	--				[SAP Code],
	--				[EAN Code],
	--				[Description],
	--				[GIT M0],
	--				[GIT M1],
	--				[GIT M2],
	--				[GIT M3]
	--			)
	--			select 
	--				[Filename],
	--				[SAP Code],
	--				[EAN Code],
	--				[Description],
	--				[GIT M0]=replace([GIT M0],'','',''''),
	--				[GIT M1]=replace([GIT M1],'','',''''),
	--				[GIT M2]=replace([GIT M2],'','',''''),
	--				[GIT M3]=replace([GIT M3],'','','''')
	--			from '+@tablename_LDB_More1+'
	--			where [sap Code]<>''SAP'' '

	--			if @debug>0
	--			begin
	--				select @sql '@sql import data LDB more'
	--			end
	--			execute(@sql)

	--			select @n_err = @@ERROR
	--			if @n_err<>0
	--			begin
	--				select @n_continue = 3
	--				--select @n_err=60003
	--				select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +ERROR_MESSAGE()+'./ ('+@sp_name+')'
	--			end
	--		end
	--	end
	--end

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