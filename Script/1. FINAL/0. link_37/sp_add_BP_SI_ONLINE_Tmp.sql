/*
	declare 
		@b_Success			Int,
		@c_errmsg			Nvarchar(250)
		
		exec sp_add_BP_SI_ONLINE_Tmp 'CPD','202408',@b_Success OUT, @c_errmsg OUT

	select @b_Success b_Success, @c_errmsg c_errmsg

	select * from FC_BP_SI_ONLINE_CPD_Tmp
*/
Create or Alter proc sp_add_BP_SI_ONLINE_Tmp
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

	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_add_BP_SI_ONLINE_Tmp',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()
	declare @SharefolderPath nvarchar(500)
	select @SharefolderPath = Value from [SC2].[dbo].[EnvironmentConfig] where Name = 'Sharefolder_SAP_Dir'

	declare @Monthfc				nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from link_33.sc2.dbo.V_FC_FM_Table

	declare @filename				nvarchar(500) = ''
	select @filename = 'BP_ONLINE_'+@FM_KEY+'.xlsx'

	declare @tablename_tmp nvarchar(200) = ''
	select @tablename_tmp = 'FC_BP_SI_ONLINE_'+@Division+@Monthfc+'_Tmp_raw'
	
	declare @tablename nvarchar(200) = ''
	select @tablename = 'FC_BP_SI_ONLINE_'+@Division+@Monthfc+'_Tmp'

	declare @Full_name nvarchar(500) = ''
	select @Full_name = @SharefolderPath +'\Pending\FORECAST\'+@Division+'\BP_SI\ONLINE\'+@filename

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
					select @sql 'drop table tmp'
				end
				execute(@sql)
			end
			select @sql='
			create table '+@tablename+'
			(
				[Filename]				nvarchar(500) null,
				[platform]				nvarchar(50) null,
				[brand]					nvarchar(50) null,
				[category]				nvarchar(50) null,
				[sub-category]			nvarchar(50) null,
				[group]					nvarchar(50) null,
				[sub-group]				nvarchar(50) null,
				[material_des]			nvarchar(50) null,
				[ean]					nvarchar(30) null,
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
			) '
				
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
							''SELECT * FROM [submit fc$]'')'
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
			[platform],
			[brand],
			[category],
			[sub-category],
			[group],
			[sub-group],
			[material_des],
			[ean],
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
			[platform]=[mtd],
			[brand]=[F2],
			[category]=[F3],
			[sub-category]=[F4],
			[group]=[F5],
			[sub-group]=[F6],
			[material_des]=[F7],
			[ean]=[F8],
			[Y0 (u) M1]=isnull([F9],0),
			[Y0 (u) M2]=isnull([F10],0),
			[Y0 (u) M3]=isnull([F11],0),
			[Y0 (u) M4]=isnull([F12],0),
			[Y0 (u) M5]=isnull([F13],0),
			[Y0 (u) M6]=isnull([F14],0),
			[Y0 (u) M7]=isnull([F15],0),
			[Y0 (u) M8]=isnull([F16],0),
			[Y0 (u) M9]=isnull([F17],0),
			[Y0 (u) M10]=isnull([F18],0),
			[Y0 (u) M11]=isnull([F19],0),
			[Y0 (u) M12]=isnull([F20],0),
			[Y+1 (u) M1]=isnull([F21],0),
			[Y+1 (u) M2]=isnull([F22],0),
			[Y+1 (u) M3]=isnull([F23],0),
			[Y+1 (u) M4]=isnull([F24],0),
			[Y+1 (u) M5]=isnull([F25],0),
			[Y+1 (u) M6]=isnull([F26],0),
			[Y+1 (u) M7]=isnull([F27],0),
			[Y+1 (u) M8]=isnull([F28],0),
			[Y+1 (u) M9]=isnull([F29],0),
			[Y+1 (u) M10]=isnull([F30],0),
			[Y+1 (u) M11]=isnull([F31],0),
			[Y+1 (u) M12]=isnull([F32],0)
		from '+@tablename_tmp+'
		where isnull([F2],'''')<>'''' 
		and [mtd] <>''platform'' '

		if @debug>0
		begin
			select @sql 'insert table tmp'
		end
		execute(@sql)
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