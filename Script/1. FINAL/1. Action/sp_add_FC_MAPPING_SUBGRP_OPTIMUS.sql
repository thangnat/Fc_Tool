/*
	Declare
		@b_Success			Int,
		@c_errmsg			Nvarchar(250)

	exec sp_add_FC_MAPPING_SUBGRP_OPTIMUS 'CPD','202412',@b_Success OUT,@c_errmsg OUT

	select @b_Success b_Success,@c_errmsg c_errmsg

	select * from FC_SO_OPTIMUS_MAPPING_SUBGRP_LDB where fm_key='202410'
*/
Alter proc sp_add_FC_MAPPING_SUBGRP_OPTIMUS
	@Division			nvarchar(3),
	@FM_KEY				Nvarchar(6),
	@b_Success			Int				OUTPUT,     
	@c_errmsg			Nvarchar(250)	OUTPUT
	WITH ENCRYPTION
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
		,@sql					nvarchar(max) = ''
	declare 
		@b_Success1				Int,
		@c_errmsg1				Nvarchar(250)

	DECLARE @DbName NVARCHAR(20)

	-- Get the environment configuration
	SELECT @DbName = CASE 
		WHEN Value = 'Production' THEN 'master.dbo'
		ELSE 'master_UAT'
	END
	FROM EnvironmentConfig
	WHERE Name = 'Current_Environment'

	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_add_FC_MAPPING_SUBGRP_OPTIMUS',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	select @debug=debug from fnc_debug('FC')
	--select @debug=1

	if @n_continue = 1
	begin
		if @Division IN('CPD')
		begin
			IF @DbName = 'master.dbo'
				exec link_37.master.dbo.sp_add_FC_MAPPING_SUBGRP_OPTIMUS_Tmp @Division,@FM_KEY, @b_Success1 OUT, @c_errmsg1 OUT
			ELSE
				exec link_37.master_UAT.dbo.sp_add_FC_MAPPING_SUBGRP_OPTIMUS_Tmp @Division,@FM_KEY, @b_Success1 OUT, @c_errmsg1 OUT

			if @b_Success1=0
			begin
				select @n_continue = 3, @c_errmsg = @c_errmsg1
			end
		end
	end

	BEGIN TRAN
	if @n_continue =1
	begin
		declare @tablename		nvarchar(100)=''
		select @tablename='FC_SO_OPTIMUS_MAPPING_SUBGRP_'+@Division

		if exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID(@tablename) AND type in (N'U')
		)
		begin
			select @sql='Delete '+@tablename+' where [FM_KEY]='''+@FM_KEY+''' '
			if @debug>0
			begin
				select @sql 'delete table'
			end
			execute(@sql)
		end
		else
		begin
			select @sql=
			'create table '+@tablename+'
			(
				[ComputerName]			nvarchar(50) null,
				[FM_KEY]				nvarchar(6) null,
				[SUB GROUP/ Brand]		nvarchar(500) null,
				[Forecasting lines]		nvarchar(500) null
			) '
			if @debug>0
			begin
				select @sql 'CREATE table'
			end
			execute(@sql)
		end
		
		if @Division IN('CPD')
		begin
			select @sql=
			'INSERT INTO '+@tablename+'
			Select	
				[ComputerName]='''+HOST_NAME()+''',
				[FM_KEY] = '''+@FM_KEY+''',
				[SUB GROUP/ Brand]=[SUB GROUP],
				[Forecasting lines]=[Forecasting lines]
			from '+@DbName+'.FC_MAPPING_SUBGRP_OPTIMUS_Tmp '
		end
		else if @Division IN('LLD','PPD')
		begin
			SELECT @sql=
			'INSERT INTO '+@tablename+'
			select DISTINCT
				[ComputerName]='''+HOST_NAME()+''',
				[FM_KEY]=m.[FM_KEY],				
				[SUB GROUP/ Brand] = m.[SUB GROUP/ Brand],
				[Forecasting lines] = m.[SUB GROUP/ Brand]
			from fnc_SubGroupMaster_Full_'+@Division+' m
			where ISNULL(m.[SUB GROUP/ Brand],'''')<>'''' '
		end
		else if @Division IN('LDB')
		begin
			SELECT @sql=
			'INSERT INTO '+@tablename+'
			select DISTINCT
				[ComputerName]='''+HOST_NAME()+''',
				[FM_KEY]=m.[FM_KEY],				
				[SUB GROUP/ Brand] = m.[SUB GROUP/ Brand],
				[Forecasting lines] = m.[SUB GROUP/ Brand]
			from fnc_SubGroupMaster_Full_'+@Division+' m
			where ISNULL(m.[SUB GROUP/ Brand],'''')<>'''' '
		end
		
		if @debug>0
		begin
			select @sql 'Insert into table'
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