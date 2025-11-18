/*
	Declare
		@b_Success			Int,
		@c_errmsg			Nvarchar(250)

	exec sp_add_FC_SI_OPTIMUS_NORMAL 'LDB','202408',@b_Success OUT,@c_errmsg OUT

	select @b_Success b_Success,@c_errmsg c_errmsg

	select * from link_37.master.dbo.FC_SI_OPTIMUS_NORMAL_LDB_Tmp
	select * from FC_SI_OPTIMUS_NORMAL_LDB
*/

Alter proc sp_add_FC_SI_OPTIMUS_NORMAL
	@Division			nvarchar(3),
	@FM_KEY				Nvarchar(6),
	@b_Success			Int				OUTPUT,     
	@c_errmsg			Nvarchar(250)	OUTPUT
	with encryption
AS
SET NOCOUNT ON
SET XACT_ABORT ON
--BEGIN TRAN
BEGIN TRY
	DECLARE   
		 @debug					int=0
		,@sp_name				Nvarchar(100)
		,@n_continue			Int
		,@USERS					Nvarchar(50)
		,@MODIFILED				Datetime
		,@n_err					int
		,@TableName				nvarchar(100)='FC_SI_OPTIMUS_NORMAL_LDB'
		,@sql					nvarchar(max)=''
		,@DbName NVARCHAR(20)

	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_add_FC_SI_OPTIMUS_NORMAL',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	-- Get the environment configuration
	SELECT @DbName = CASE 
		WHEN Value = 'Production' THEN 'master.dbo'
		ELSE 'master_UAT'
	END
	FROM EnvironmentConfig
	WHERE Name = 'Current_Environment'

	declare @SharefolderPath nvarchar(500)
	select @SharefolderPath = Value from [SC2].[dbo].[EnvironmentConfig] where Name = 'Sharefolder_SAP_Dir'
	declare @FullPath nvarchar(500) = @SharefolderPath+'\Pending\FORECAST\LDB\SELL_IN\OPTIMUS\'
	declare 
		@b_Success1			Int,
		@c_errmsg1			Nvarchar(250)

	if @n_continue =1
	begin
		exec sp_getlistfiles @FullPath,'OLD'
		--select * from LDB_ListFile_Optimus
		IF @Division='LDB'
		BEGIN
			declare @currentrows int = 1, @totalrows int =0
			select @totalrows=isnull(count(*),0) from LDB_ListFile_Optimus
			declare @result_error		nvarchar(max)=''
			--select * from FC_SI_OPTIMUS_NORMAL_LDB_ALL_Tmp
			truncate table FC_SI_OPTIMUS_NORMAL_LDB_ALL_Tmp
			while (@currentrows<=@totalrows)
			begin
				declare @filename_ok nvarchar(500)=''
				select @filename_ok=[filename] from LDB_ListFile_Optimus where id=@currentrows

				if @debug>0
				begin
					select @filename_ok '@filename_ok'
				end
				
				if @DbName = 'master.dbo'
					exec link_37.master.dbo.sp_add_FC_SI_OPTIMUS_NORMAL_Tmp @Division,@FM_KEY,@filename_ok,@b_Success1 OUT,@c_errmsg1 OUT
				ELSE
					exec link_37.master_UAT.dbo.sp_add_FC_SI_OPTIMUS_NORMAL_Tmp @Division,@FM_KEY,@filename_ok,@b_Success1 OUT,@c_errmsg1 OUT

				IF @b_Success1=0
				BEGIN
					SELECT @result_error=@result_error+@c_errmsg1
				END
				else
				begin
					if @DbName = 'master.dbo'
						insert into FC_SI_OPTIMUS_NORMAL_LDB_ALL_Tmp
						select *
						from link_37.master.dbo.FC_SI_OPTIMUS_NORMAL_LDB_Tmp 
						where selected=1
					ELSE
						insert into FC_SI_OPTIMUS_NORMAL_LDB_ALL_Tmp
						select *
						from link_37.master_UAT.dbo.FC_SI_OPTIMUS_NORMAL_LDB_Tmp 
						where selected=1
				end

				select @currentrows=@currentrows+1
			end

			if len(@result_error)>0
			begin
				SELECT @n_continue=1,@c_errmsg=@result_error
			end	
		END
	END

	begin tran
	IF @n_continue=1
	BEGIN
		if exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID(@tablename) AND type in (N'U')
		)
		begin
			select @sql = 'truncate table '+@tablename
			if @debug>0
			begin
				select @sql '1.1.1.A'
			end
			execute(@sql)

			select @sql=
			'Insert into '+@TableName+'
			(
				[FileName],
				[Product Type],
				[SUB GROUP/ Brand],
				[Channel],
				[Time series],
				[Sub-Channel2],
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
				[FileName],
				[Product Type]=S.[Product Type],
				[SUB GROUP/ Brand]=s.[SUB GROUP/ Brand],
				[Channel],
				[Time series]=case when [Sub-Channel2]<>''MEDICAL'' then ''7.1. BP Unit Offline'' ELSE ''7.2. BP Unit Medical'' END,
				[Sub-Channel2],
				[Y0 (u) M1]=sum(case when [Y0 (u) M1]=''-'' then 0 else [Y0 (u) M1] end),
				[Y0 (u) M2]=sum(case when [Y0 (u) M2]=''-'' then 0 else [Y0 (u) M2] end),
				[Y0 (u) M3]=sum(case when [Y0 (u) M3]=''-'' then 0 else [Y0 (u) M3] end),
				[Y0 (u) M4]=sum(case when [Y0 (u) M4]=''-'' then 0 else [Y0 (u) M4] end),
				[Y0 (u) M5]=sum(case when [Y0 (u) M5]=''-'' then 0 else [Y0 (u) M5] end),
				[Y0 (u) M6]=sum(case when [Y0 (u) M6]=''-'' then 0 else [Y0 (u) M6] end),
				[Y0 (u) M7]=sum(case when [Y0 (u) M7]=''-'' then 0 else [Y0 (u) M7] end),
				[Y0 (u) M8]=sum(case when [Y0 (u) M8]=''-'' then 0 else [Y0 (u) M8] end),
				[Y0 (u) M9]=sum(case when [Y0 (u) M9]=''-'' then 0 else [Y0 (u) M9] end),
				[Y0 (u) M10]=sum(case when [Y0 (u) M10]=''-'' then 0 else [Y0 (u) M10] end),
				[Y0 (u) M11]=sum(case when [Y0 (u) M11]=''-'' then 0 else [Y0 (u) M11] end),
				[Y0 (u) M12]=sum(case when [Y0 (u) M12]=''-'' then 0 else [Y0 (u) M12] end),
				[Y+1 (u) M1]=sum(case when [Y+1 (u) M1]=''-'' then 0 else [Y+1 (u) M1] end),
				[Y+1 (u) M2]=sum(case when [Y+1 (u) M2]=''-'' then 0 else [Y+1 (u) M2] end),
				[Y+1 (u) M3]=sum(case when [Y+1 (u) M3]=''-'' then 0 else [Y+1 (u) M3] end),
				[Y+1 (u) M4]=sum(case when [Y+1 (u) M4]=''-'' then 0 else [Y+1 (u) M4] end),
				[Y+1 (u) M5]=sum(case when [Y+1 (u) M5]=''-'' then 0 else [Y+1 (u) M5] end),
				[Y+1 (u) M6]=sum(case when [Y+1 (u) M6]=''-'' then 0 else [Y+1 (u) M6] end),
				[Y+1 (u) M7]=sum(case when [Y+1 (u) M7]=''-'' then 0 else [Y+1 (u) M7] end),
				[Y+1 (u) M8]=sum(case when [Y+1 (u) M8]=''-'' then 0 else [Y+1 (u) M8] end),
				[Y+1 (u) M9]=sum(case when [Y+1 (u) M9]=''-'' then 0 else [Y+1 (u) M9] end),
				[Y+1 (u) M10]=sum(case when [Y+1 (u) M10]=''-'' then 0 else [Y+1 (u) M10] end),
				[Y+1 (u) M11]=sum(case when [Y+1 (u) M11]=''-'' then 0 else [Y+1 (u) M11] end),
				[Y+1 (u) M12]=sum(case when [Y+1 (u) M12]=''-'' then 0 else [Y+1 (u) M12] end)
			from FC_SI_OPTIMUS_NORMAL_LDB_ALL_Tmp f
			inner join
			(
				select DISTINCT
					[SUB GROUP/ Brand],
					[Product Type],
					Material
				from fnc_SubGroupMaster('''+@Division+''',''full'')
			) s on s.material=f.[Sap Code]
			group by	
				[Filename],
				s.[Product Type],
				[SUB GROUP/ Brand],
				[Channel],
				[Sub-Channel2] '
			
			--select DISTINCT
			--	[SUB GROUP/ Brand],
			--	Material
			--from fnc_SubGroupMaster('LDB','full')

			if @debug>0
			begin
				select @sql '1.1.1.B'
			end
			execute(@sql)
		end
		else
		begin
			select @sql=
			'select 
				[FileName],
				[Product Type]=S.[Product Type],
				[SUB GROUP/ Brand]=s.[SUB GROUP/ Brand],
				[Channel],
				[Time series]=case when [Sub-Channel2]<>''MEDICAL'' then ''7.1. BP Unit Offline'' ELSE ''7.2. BP Unit Medical'' END,	
				[Sub-Channel2],
				[Y0 (u) M1]=sum(case when [Y0 (u) M1]=''-'' then 0 else [Y0 (u) M1] end),
				[Y0 (u) M2]=sum(case when [Y0 (u) M2]=''-'' then 0 else [Y0 (u) M2] end),
				[Y0 (u) M3]=sum(case when [Y0 (u) M3]=''-'' then 0 else [Y0 (u) M3] end),
				[Y0 (u) M4]=sum(case when [Y0 (u) M4]=''-'' then 0 else [Y0 (u) M4] end),
				[Y0 (u) M5]=sum(case when [Y0 (u) M5]=''-'' then 0 else [Y0 (u) M5] end),
				[Y0 (u) M6]=sum(case when [Y0 (u) M6]=''-'' then 0 else [Y0 (u) M6] end),
				[Y0 (u) M7]=sum(case when [Y0 (u) M7]=''-'' then 0 else [Y0 (u) M7] end),
				[Y0 (u) M8]=sum(case when [Y0 (u) M8]=''-'' then 0 else [Y0 (u) M8] end),
				[Y0 (u) M9]=sum(case when [Y0 (u) M9]=''-'' then 0 else [Y0 (u) M9] end),
				[Y0 (u) M10]=sum(case when [Y0 (u) M10]=''-'' then 0 else [Y0 (u) M10] end),
				[Y0 (u) M11]=sum(case when [Y0 (u) M11]=''-'' then 0 else [Y0 (u) M11] end),
				[Y0 (u) M12]=sum(case when [Y0 (u) M12]=''-'' then 0 else [Y0 (u) M12] end),
				[Y+1 (u) M1]=sum(case when [Y+1 (u) M1]=''-'' then 0 else [Y+1 (u) M1] end),
				[Y+1 (u) M2]=sum(case when [Y+1 (u) M2]=''-'' then 0 else [Y+1 (u) M2] end),
				[Y+1 (u) M3]=sum(case when [Y+1 (u) M3]=''-'' then 0 else [Y+1 (u) M3] end),
				[Y+1 (u) M4]=sum(case when [Y+1 (u) M4]=''-'' then 0 else [Y+1 (u) M4] end),
				[Y+1 (u) M5]=sum(case when [Y+1 (u) M5]=''-'' then 0 else [Y+1 (u) M5] end),
				[Y+1 (u) M6]=sum(case when [Y+1 (u) M6]=''-'' then 0 else [Y+1 (u) M6] end),
				[Y+1 (u) M7]=sum(case when [Y+1 (u) M7]=''-'' then 0 else [Y+1 (u) M7] end),
				[Y+1 (u) M8]=sum(case when [Y+1 (u) M8]=''-'' then 0 else [Y+1 (u) M8] end),
				[Y+1 (u) M9]=sum(case when [Y+1 (u) M9]=''-'' then 0 else [Y+1 (u) M9] end),
				[Y+1 (u) M10]=sum(case when [Y+1 (u) M10]=''-'' then 0 else [Y+1 (u) M10] end),
				[Y+1 (u) M11]=sum(case when [Y+1 (u) M11]=''-'' then 0 else [Y+1 (u) M11] end),
				[Y+1 (u) M12]=sum(case when [Y+1 (u) M12]=''-'' then 0 else [Y+1 (u) M12] end)
				into '+@TableName+'
			from FC_SI_OPTIMUS_NORMAL_LDB_ALL_Tmp f
			inner join
			(
				select DISTINCT
					[SUB GROUP/ Brand],
					[Product Type],
					Material
				from fnc_SubGroupMaster('''+@Division+''',''full'')
			) s on s.material=f.[Sap Code]
			group by
				[Filename],
				s.[Product Type],
				[SUB GROUP/ Brand],
				[Channel],
				[Sub-Channel2] '
			if @debug>0
			begin
				select @sql '1.1.1C'
			end
			execute(@sql)
		end

		select @n_err = @@ERROR
		if @n_err<>0
		begin
			select @n_continue = 3
			--select @n_err=60003
			select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +ERROR_MESSAGE()+'./ ('+@sp_name+')'
		end
	end
	--if @n_continue=1
	--begin
	--	declare @list_set_zero nvarchar(max)=''
	--	declare @list_update nvarchar(max)=''

	--	SELECT @list_set_zero=ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'Set_0','b')
	--	--SELECT list_set_zero=ListColumn FROM fn_FC_GetColheader_Current('202407','Set_0','b')
	--	SELECT @list_update=ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'updateForecast','b')
	--	--SELECT list_update=ListColumn FROM fn_FC_GetColheader_Current('202406','updateForecast','o')

	--	--set zero
	--	update FC_FM_Original_LDB
	--	set [Y0 (u) M1]=''
	--	where Channel<>'O+O'
	--	and [Time series] IN('7.1. BP Unit Offline','7.2. BP Unit Medical')
		
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