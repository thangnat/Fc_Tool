/*
	declare 
		@b_Success				Int	,
		@c_errmsg				Nvarchar(250)

	exec sp_Backup_WF_before_Save 'LDB','202410','ALL',@b_Success OUT,@c_errmsg OUT

	select @b_Success b_Success,@c_errmsg c_errmsg
*/

Alter Proc sp_Backup_WF_before_Save
	@Division		nvarchar(3),
	@FM_Key			Nvarchar(6),
	@Type			Nvarchar(10),--//ALL,''
	@b_Success		Int				OUTPUT,     
	@c_errmsg		Nvarchar(250)	OUTPUT
As
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRAN
BEGIN TRY
	DECLARE   
		 @debug					INT=0
		,@sp_name				Nvarchar(100)
		,@n_continue			Int
		,@USERS					Nvarchar(50)
		,@MODIFILED				Datetime
		,@n_err					int
		,@sql					nvarchar(max)=''
		,@DbName NVARCHAR(20)
			
	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_Backup_WF_before_Save',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	select @debug=debug from fnc_debug('FC')
	--select @debug=1
	declare @Monthfc				nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from V_FC_FM_Table

	declare @table_FC_FM_Original nvarchar(200)=''
	select @table_FC_FM_Original='FC_FM_Original_'+@Division+@Monthfc
	
	-- Get the environment configuration
	SELECT @DbName = CASE 
		WHEN Value = 'Production' THEN 'master.dbo'
		ELSE 'master_UAT'
	END
	FROM EnvironmentConfig
	WHERE Name = 'Current_Environment'

	if @n_continue = 1
	begin
		if @Type='ALL'
		begin
			if exists
			(
				SELECT 
					* 
				FROM master.sys.objects
				WHERE [type] in (N'U') and object_id = OBJECT_ID(@DbName+'.FC_FM_Original_'+@Division)
			)
			begin
				select @sql=
				'INSERT INTO '+@DbName+'.FC_FM_Original_'+@Division+'
				select 
					[USERID]=SUSER_NAME(),
					[Backup_Time]=getdate(),
					*
				from '+@table_FC_FM_Original
			end
			else
			begin
				select @sql=
				'select 
					[USERID]=SUSER_NAME(),
					[Backup_Time]=getdate(),
					* 
					INTO '+@DbName+'.FC_FM_Original_'+@Division+' 
				from '+@table_FC_FM_Original
			end
			if @debug>0
			begin
				select @sql 'Backup WF ALL'
			end
			execute(@sql)
		end
		else
		begin
			declare @listcolum nvarchar(max)=''
			SELECT @listcolum=ListColumn FROM fn_FC_GetColheader_Current(@FM_Key,'1. Baseline Qty','f')
			--SELECT listcolum=ListColumn FROM fn_FC_GetColheader_Current('202410','1. Baseline Qty','f')

			if exists
			(
				SELECT 
					* 
				FROM master.sys.objects
				WHERE [type] in (N'U') and object_id = OBJECT_ID(@DbName+'.FC_FM_Original_'+@Division+'_FC')
			)
			begin
				select @sql=
				'INSERT INTO '+@DbName+'.FC_FM_Original_'+@Division+'_FC
				Select 
					 [USERID]=SUSER_NAME()
					,[Backup_Time]=getdate()
					,[FM_KEY]
					,[Product type]
					,[Signature]
					,[CAT/Axe]
					,[SUB CAT/ Sub Axe]
					,[GROUP/ Class]
					,[Ref. Code]
					,[SUB GROUP/ Brand]
					,[HERO]
					,[Channel]
					,[Product status]
					,[Time series],
					[Y0 (u) M1] = cast(isnull(f.[Y0 (u) M1],0) as int),
					 [Y0 (u) M2] = cast(isnull(f.[Y0 (u) M2],0) as int),
					 [Y0 (u) M3] = cast(isnull(f.[Y0 (u) M3],0) as int),
					 [Y0 (u) M4] = cast(isnull(f.[Y0 (u) M4],0) as int),
					 [Y0 (u) M5] = cast(isnull(f.[Y0 (u) M5],0) as int),
					 [Y0 (u) M6] = cast(isnull(f.[Y0 (u) M6],0) as int),
					 [Y0 (u) M7] = cast(isnull(f.[Y0 (u) M7],0) as int),
					 [Y0 (u) M8] = cast(isnull(f.[Y0 (u) M8],0) as int),
					 [Y0 (u) M9] = cast(isnull(f.[Y0 (u) M9],0) as int),
					 [Y0 (u) M10] = cast(isnull(f.[Y0 (u) M10],0) as int) ,
					 [Y0 (u) M11] = cast(isnull(f.[Y0 (u) M11],0) as int) ,
					 [Y0 (u) M12] = cast(isnull(f.[Y0 (u) M12],0) as int) ,
					 [Y+1 (u) M1] = cast(isnull(f.[Y+1 (u) M1],0) as int) ,
					 [Y+1 (u) M2] = cast(isnull(f.[Y+1 (u) M2],0) as int) ,
					 [Y+1 (u) M3] = cast(isnull(f.[Y+1 (u) M3],0) as int) ,
					 [Y+1 (u) M4] = cast(isnull(f.[Y+1 (u) M4],0) as int) ,
					 [Y+1 (u) M5] = cast(isnull(f.[Y+1 (u) M5],0) as int) ,
					 [Y+1 (u) M6] = cast(isnull(f.[Y+1 (u) M6],0) as int) ,
					 [Y+1 (u) M7] = cast(isnull(f.[Y+1 (u) M7],0) as int) ,
					 [Y+1 (u) M8] = cast(isnull(f.[Y+1 (u) M8],0) as int) ,
					 [Y+1 (u) M9] = cast(isnull(f.[Y+1 (u) M9],0) as int) ,
					 [Y+1 (u) M10] = cast(isnull(f.[Y+1 (u) M10],0) as int),
					 [Y+1 (u) M11] = cast(isnull(f.[Y+1 (u) M11],0) as int),
					 [Y+1 (u) M12] = cast(isnull(f.[Y+1 (u) M12],0) as int)
				from '+@table_FC_FM_Original+' f
				where 
					[Channel] IN(''ONLINE'',''OFFLINE'') 
				and [Time series] IN(select value from string_split(''1. Baseline Qty,2. Promo Qty(Single),4. Launch Qty,5. FOC Qty,3. Promo Qty(BOM)'','','')) '
			end
			else
			begin
				select @sql=
				'Select 
					 [USERID]=SUSER_NAME()
					,[Backup_Time]=getdate()
					,[FM_KEY]
					,[Product type]
					,[Signature]
					,[CAT/Axe]
					,[SUB CAT/ Sub Axe]
					,[GROUP/ Class]
					,[Ref. Code]
					,[SUB GROUP/ Brand]
					,[HERO]
					,[Channel]
					,[Product status]
					,[Time series],
					[Y0 (u) M1] = cast(isnull(f.[Y0 (u) M1],0) as int),
					 [Y0 (u) M2] = cast(isnull(f.[Y0 (u) M2],0) as int),
					 [Y0 (u) M3] = cast(isnull(f.[Y0 (u) M3],0) as int),
					 [Y0 (u) M4] = cast(isnull(f.[Y0 (u) M4],0) as int),
					 [Y0 (u) M5] = cast(isnull(f.[Y0 (u) M5],0) as int),
					 [Y0 (u) M6] = cast(isnull(f.[Y0 (u) M6],0) as int),
					 [Y0 (u) M7] = cast(isnull(f.[Y0 (u) M7],0) as int),
					 [Y0 (u) M8] = cast(isnull(f.[Y0 (u) M8],0) as int),
					 [Y0 (u) M9] = cast(isnull(f.[Y0 (u) M9],0) as int),
					 [Y0 (u) M10] = cast(isnull(f.[Y0 (u) M10],0) as int) ,
					 [Y0 (u) M11] = cast(isnull(f.[Y0 (u) M11],0) as int) ,
					 [Y0 (u) M12] = cast(isnull(f.[Y0 (u) M12],0) as int) ,
					 [Y+1 (u) M1] = cast(isnull(f.[Y+1 (u) M1],0) as int) ,
					 [Y+1 (u) M2] = cast(isnull(f.[Y+1 (u) M2],0) as int) ,
					 [Y+1 (u) M3] = cast(isnull(f.[Y+1 (u) M3],0) as int) ,
					 [Y+1 (u) M4] = cast(isnull(f.[Y+1 (u) M4],0) as int) ,
					 [Y+1 (u) M5] = cast(isnull(f.[Y+1 (u) M5],0) as int) ,
					 [Y+1 (u) M6] = cast(isnull(f.[Y+1 (u) M6],0) as int) ,
					 [Y+1 (u) M7] = cast(isnull(f.[Y+1 (u) M7],0) as int) ,
					 [Y+1 (u) M8] = cast(isnull(f.[Y+1 (u) M8],0) as int) ,
					 [Y+1 (u) M9] = cast(isnull(f.[Y+1 (u) M9],0) as int) ,
					 [Y+1 (u) M10] = cast(isnull(f.[Y+1 (u) M10],0) as int),
					 [Y+1 (u) M11] = cast(isnull(f.[Y+1 (u) M11],0) as int),
					 [Y+1 (u) M12] = cast(isnull(f.[Y+1 (u) M12],0) as int)
					INTO '+@DbName+'.FC_FM_Original_'+@Division+'_FC 
				from '+@table_FC_FM_Original+' f
				where 
					[Channel] IN(''ONLINE'',''OFFLINE'') 
				and [Time series] IN(select value from string_split(''1. Baseline Qty,2. Promo Qty(Single),4. Launch Qty,5. FOC Qty,3. Promo Qty(BOM)'','','')) '
			end

			if @debug>0
			begin
				select @sql 'Backup WF FC'
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