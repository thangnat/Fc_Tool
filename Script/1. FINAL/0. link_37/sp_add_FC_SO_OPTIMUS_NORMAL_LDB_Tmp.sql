/*
	declare 
		@b_Success			Int,
		@c_errmsg			Nvarchar(250)

	exec sp_add_FC_SO_OPTIMUS_NORMAL_LDB_Tmp 'LDB','202408','Offline_CRV_FC_SO_OPTIMUS_NORMAL_202408.xlsx',@b_Success OUT,@c_errmsg OUT

	select @b_Success b_Success,@c_errmsg c_errmsg

	select * from FC_SO_OPTIMUS_NORMAL_LDB_Tmp
	--drop table FC_SO_OPTIMUS_NORMAL_LDB_ALL_Tmp
*/
Create or Alter proc sp_add_FC_SO_OPTIMUS_NORMAL_LDB_Tmp
	@Division			Nvarchar(3),
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

	declare 
		@b_Success1				Int = 0,
		@c_errmsg1				Nvarchar(250) = ''

	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_add_FC_SO_OPTIMUS_NORMAL_LDB_Tmp',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()
	declare @SharefolderPath nvarchar(500)
	select @SharefolderPath = Value from [SC2].[dbo].[EnvironmentConfig] where Name = 'Sharefolder_SAP_Dir'

	declare @Monthfc				nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from link_33.sc2.dbo.V_FC_FM_Table

	declare @tablename  nvarchar(100) = ''
	select @tablename = 'FC_SO_OPTIMUS_NORMAL_'+@Division+@Monthfc+'_Tmp'
	
	declare @Full_name nvarchar(500) = ''
	select @Full_name = @SharefolderPath +'\Pending\FORECAST\'+@Division+'\OPTIMUS\'+@FM_KEY+'\'+@filename
	
	declare @filename2				nvarchar(200)=''
	select @filename2=left(@filename,len(@filename)-len('_FC_SO_OPTIMUS_NORMAL_'+@fm_key+'.xlsx'))
	
	declare @brand					nvarchar(10)=''
	select @Brand=substring(@filename2,charindex('_',@filename2,0)+1,len(@filename2)-charindex('_',@filename2,0))
	
	declare @Channel				nvarchar(10)=''
	select @Channel=left(@filename2,CHARINDEX('_',@filename2,0)-1)

	if @debug>0
	begin
		select @Full_name '@Full_name',@filename2 '@filename2',@Brand '@Brand',@Channel '@Channel'
	end

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
				select @sql '@sql drop table'
			end
			execute(@sql)
		end
		--select CHARINDEX
		select @sql =
		'select
			*
			INTO '+@tablename+'
		from
		(
			select
				Selected=case 
							when [F35]=''SO check stock'' then 1 
							when [F2]=''BFL Code'' then 1 
							when '''+case when @brand='SKC' then 'SKN' else @brand end+'''=[F1] and CHARINDEX(''ONLINE'','''+@filename+''')>0 and [F16]=''ECOM'' then 1
							when '''+case when @brand='SKC' then 'SKN' else @brand end+'''=[F1] and CHARINDEX(''MEDICAL'','''+@filename+''')>0 and [F16]=''MEDICAL'' then 1
							when '''+case when @brand='SKC' then 'SKN' else @brand end+'''=[F1] and CHARINDEX(''OFFLINE'','''+@filename+''')>0 and [F16] NOT IN(''ECOM'',''MEDICAL'',''OFFLINE'',''TOTAL ACD'') then 1
							else 0 
						end,
				Brand='''+@brand+''',
				Channel=case when [F16]=''Ecom'' then ''ONLINE'' else ''OFFLINE'' end,
				Channel2='''+@Channel+''',
				Filename = '''+@filename+''',
				*
			From OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',
							''Excel 12.0; HDR=YES; IMEX=1;Database='+@Full_name+''',
							''SELECT * FROM [FC Total$]'')
		) as x
		where [selected]=1'

		if @debug>0
		begin
			select @sql '@sql insert into tmp'
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