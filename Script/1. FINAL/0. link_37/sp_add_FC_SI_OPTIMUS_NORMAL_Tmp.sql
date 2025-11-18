/*
	declare 
		@b_Success			Int,
		@c_errmsg			Nvarchar(250)

	exec sp_add_FC_SI_OPTIMUS_NORMAL_Tmp 'LDB','202408','Medical_CRV_FC_SO_OPTIMUS_NORMAL_202408.xlsx',@b_Success OUT,@c_errmsg OUT

	select @b_Success b_Success,@c_errmsg c_errmsg

	select * from FC_SI_OPTIMUS_NORMAL_LDB_Tmp where selected=1

	select * from FC_SI_OPTIMUS_NORMAL_LDB_Tmp
	where isnull([F2],'')<>''

*/
Create or Alter proc sp_add_FC_SI_OPTIMUS_NORMAL_Tmp
	@Division			Nvarchar(3),
	@FM_KEY				nvarchar(6),
	@Filename			nvarchar(1000),
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
		,@currentrows			int=1
		,@totalrows				int=0

	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_add_FC_SI_OPTIMUS_NORMAL_Tmp',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()
	declare @SharefolderPath nvarchar(500)
	select @SharefolderPath = Value from [SC2].[dbo].[EnvironmentConfig] where Name = 'Sharefolder_SAP_Dir'

	declare @tablename  nvarchar(100) = '',@sql nvarchar(max) = ''
	select @tablename = 'FC_SI_OPTIMUS_NORMAL_'+@Division+'_Tmp'
	declare @Full_name nvarchar(500) = ''
	select @Full_name = @SharefolderPath +'\Pending\FORECAST\'+@Division+'\OPTIMUS\'+@filename

	declare 
		@b_Success1			Int = 0,
		@c_errmsg1			Nvarchar(250) = ''

	--select @Filename '@Filename'
	if (select dbo.fn_FileExists(@Full_name)) = 1
	begin
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
				select @sql '@sql 1.1.1'
			end
			execute(@sql)
		end

		select @sql=
		'select
			[Selected]=case when [Key Name Brand]=[Brand] and [Key Name Sub]=[Sub-Channel] then 1 else 0 end,
			*
			INTO '+@tablename+'
		from
		(
			select 
				[Key Name Sub]=left([Key name],CHARINDEX(''_'',[Filename],0)-1),
				[Key Name Brand]=substring([Key Name],CHARINDEX(''_'',[Filename],0)+1,len([Key name])),
				* 
			from 
			(
				select
					[Filename],
					[Key name]=left([Filename],len([Filename])-len(''_FC_SO_OPTIMUS_NORMAL'')-12),
					[Brand],
					[Sap Code],
					[Product Type],
					[Channel],
					[Sub-Channel],
					[Sub-Channel2]=case 
									when [Channel]<>''ONLINE'' then
										case
											when [Sub-Channel]=''Medical'' then ''MEDICAL'' 
											else ''OFFLINE'' 
										end
									else ''ONLINE''
								end,
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
				from
				(
					select
						[Filename]='''+@Filename+''',
						[Brand]=[F1],
						[Sap Code]=[F4],
						[Product Type]=[F8],
						[Channel]=case when [F16]=''Ecom'' then ''ONLINE'' else ''OFFLINE'' end,
						[Sub-Channel]=[F16],
						[Y0 (u) M1]=[530],
						[Y0 (u) M2]=[531],
						[Y0 (u) M3]=[532],
						[Y0 (u) M4]=[533],
						[Y0 (u) M5]=[534],
						[Y0 (u) M6]=[66],
						[Y0 (u) M7]=[76],
						[Y0 (u) M8]=[86],
						[Y0 (u) M9]=[96],
						[Y0 (u) M10]=[106],
						[Y0 (u) M11]=[116],
						[Y0 (u) M12]=[126],
						[Y+1 (u) M1]=[535],
						[Y+1 (u) M2]=[536],
						[Y+1 (u) M3]=[537],
						[Y+1 (u) M4]=[538],
						[Y+1 (u) M5]=[539],
						[Y+1 (u) M6]=[67],
						[Y+1 (u) M7]=[77],
						[Y+1 (u) M8]=[87],
						[Y+1 (u) M9]=[97],
						[Y+1 (u) M10]=[107],
						[Y+1 (u) M11]=[117],
						[Y+1 (u) M12]=[127]
					From OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',
						''Excel 12.0; HDR=YES; IMEX=1;Database='+@Full_name+''',
						''SELECT * FROM [FC Total$]'')
				) as x
				where [Sub-Channel]<>''Total ACD''
				and Isnull([Brand],'''')<>''''
				and [Sap Code]<>''Active code''
			) as x1
		) as x2'


		if @debug>0
		begin
			select @sql '@sql 1.1.2'
		end

		execute(@sql)
	end
	else
	begin
		select @n_continue =3, @c_errmsg = 'No files.../'
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