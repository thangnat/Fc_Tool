/*
	Declare
		@b_Success			Int,
		@c_errmsg			Nvarchar(250)

	exec sp_add_FC_Budget_Tmp 'CPD','202412','B',@b_Success OUT,@c_errmsg OUT

	select @b_Success b_Success,@c_errmsg c_errmsg


	select * from FC_BUDGET_CPD_Tmp
	select * from FC_PRE_BUDGET_CPD_Tmp
	select [M1_VALUE],* from FC_Trend_CPD_Tmp

*/
Create or Alter proc sp_add_FC_Budget_Tmp
	@Division			nvarchar(3),
	@FM_KEY				nvarchar(6),
	@Type				nvarchar(5),
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
		@sp_name = ' sp_add_FC_Budget_Tmp',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()
	declare @SharefolderPath nvarchar(500)
	select @SharefolderPath = Value from [SC2].[dbo].[EnvironmentConfig] where Name = 'Sharefolder_SAP_Dir'
	
	declare @Monthfc				nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from link_33.sc2.dbo.V_FC_FM_Table
	
	declare @tablename nvarchar(100) = ''

	declare @filename				nvarchar(500) = ''
	select @Filename = 'FC_Budget_Trend_'+@FM_KEY+'.xlsx'

	declare @Full_name nvarchar(500) = ''
	select @Full_name = @SharefolderPath +'\Pending\FORECAST\'+@Division+'\B_T\'+@filename
	--select @Full_name = '\\10.240.65.43\loreal\10_PUBLIC\03_SAPData\SC_IMPORT\Pending\FORECAST\Standard_Template\NEW_STANDARD\CPD\'+@filename

	if @n_continue = 1
	begin
		if (select dbo.fn_FileExists(@Full_name)) = 1
		begin
			if @Type = 'B'
			begin
				select @tablename = 'FC_Budget_'+@Division+'_Tmp'
				--select @tablename '@tablename'
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
						select @sql '@sql'
					end
					execute(@sql)
				end

				--select @sql =
				--'select
				--	Filename = '''+@filename+''',
				--	*
				--	INTO '+@tablename+'
				--From OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',
				--				''Excel 12.0; HDR=YES; IMEX=1;Database=\\10.240.65.43\loreal\10_PUBLIC\03_SAPData\SC_IMPORT\Pending\FORECAST\'+@Division+'\B_T\'+@filename+''',
				--				''SELECT * FROM [Bud$]'')'

				select @sql =
				'select
					Filename = '''+@filename+''',
					*
					INTO '+@tablename+'
				From OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',
								''Excel 12.0; HDR=YES; IMEX=1;Database='+@Full_name+''',
								''SELECT * FROM [Bud$]'')'
			end
			else if @Type = 'PB'
			begin
				select @tablename = 'FC_Pre_Budget_'+@Division+'_Tmp'
				--select @tablename '@tablename'
				if exists(SELECT * 
					FROM sys.objects 
					WHERE object_id = OBJECT_ID(@tablename) AND type in (N'U')
				)
				begin
					select @sql = 'drop table '+@tablename
					if @debug>0
					begin
						select @sql '@sql'
					end
					execute(@sql)
				end

				--select @sql =
				--'select
				--	Filename = '''+@filename+''',
				--	*
				--	INTO '+@tablename+'
				--From OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',
				--				''Excel 12.0; HDR=YES; IMEX=1;Database=\\10.240.65.43\loreal\10_PUBLIC\03_SAPData\SC_IMPORT\Pending\FORECAST\'+@Division+'\B_T\'+@filename+''',
				--				''SELECT * FROM [Pre$]'')'
				select @sql =
				'select
					Filename = '''+@filename+''',
					*
					INTO '+@tablename+'
				From OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',
								''Excel 12.0; HDR=YES; IMEX=1;Database='+@Full_name+''',
								''SELECT * FROM [Pre$]'')'
			end
			else if @Type = 'T'
			begin
				select @tablename = 'FC_Trend_'+@Division+'_Tmp'
				--select @tablename '@tablename'
				if exists(SELECT * 
					FROM sys.objects 
					WHERE object_id = OBJECT_ID(@tablename) AND type in (N'U')
				)
				begin
					select @sql = 'drop table '+@tablename
					if @debug>0
					begin
						select @sql '@sql'
					end
					execute(@sql)
				end

				--select @sql =
				--'select
				--	Filename = '''+@filename+''',
				--	*
				--	INTO '+@tablename+'
				--From OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',
				--				''Excel 12.0; HDR=YES; IMEX=1;Database=\\10.240.65.43\loreal\10_PUBLIC\03_SAPData\SC_IMPORT\Pending\FORECAST\'+@Division+'\B_T\'+@filename+''',
				--				''SELECT * FROM [Trend$]'')'
				select @sql =
				'select
					Filename = '''+@filename+''',
					*
					INTO '+@tablename+'
				From OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',
								''Excel 12.0; HDR=YES; IMEX=1;Database='+@Full_name+''',
								''SELECT * FROM [Trend$]'')'
			end
			if @debug>0
			begin
				select @sql '@sql'
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
		else
		begin
			select @n_continue =3, @c_errmsg = 'No files.../'
		end

		
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