
/*
	exec sp_set_FMKEY 'hoaiphuong.ho','202502',0,''
	select * from FC_ComputerName

	Declare
		@b_Success			Int,
		@c_errmsg			Nvarchar(250)

	exec sp_fc_add_fnc_SubGroupMasterFull 'CPD','202502',@b_Success OUT,@c_errmsg OUT

	select @b_Success b_Success,@c_errmsg c_errmsg

	select
		Distinct computerName,FM_KEY,DIvision 
	from fnc_SubGroupMaster_Full_LDB
	where ComputerName=host_name()

	/*drop table fnc_SubGroupMaster_Full_LLD*/
*/

ALter Proc sp_fc_add_fnc_SubGroupMasterFull
	@Division		Nvarchar(3),
	@FM_KEY			nvarchar(6),
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
		,@sql1					nvarchar(max)=''
			
	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_fc_add_fnc_SubGroupMasterFull',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	select @debug=debug from fnc_debug('FC')
	select @debug=1

	declare @tablename nvarchar(100)=''
	select @tablename='fnc_SubGroupMaster_Full_'+@Division

	if @n_continue=1
	begin
		if exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID(@tablename) AND type in (N'U')
		)
		begin
			select @sql='delete '+@Tablename+' where [FM_KEY]='''+@FM_KEY+''' '
			if @debug>0
			begin
				select @sql 'delete table'
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
			select @sql=
			'Create table '+@tablename+'
			(			
				[ComputerName]			nvarchar(50) NULL,
				[Division]				nvarchar(3) null,
				[FM_KEY]				nvarchar(6) null,
				[Sales Org]				nvarchar(4) null,
				[Barcode]				nvarchar(50) null,
				[Material]				nvarchar(50) null,
				[Bundle name]			nvarchar(500) null,
				[Material Type]			nvarchar(10) null,
				[Ref. Code]				nvarchar(30) null,
				[SUB GROUP/ Brand]		nvarchar(500) null,
				[% Ratio]				INT null,
				[CAT/Axe]				nvarchar(300) null,
				[SUB CAT/ Sub Axe]		nvarchar(300) null,
				[GROUP/ Class]			nvarchar(300) null,
				[HERO]					nvarchar(60) null,
				[Product status]		nvarchar(50) null,
				[Signature]				nvarchar(100) null,
				[Type]					nvarchar(10) null,
				[Product Type]			nvarchar(10) null,
				[Dchain]				nvarchar(50) null,
				[Item Category Group]	nvarchar(10) null,
				[Active]				INT default 0,
				[Y-2 (u) M1]			Numeric(18,0) default 0,
				[Y-2 (u) M2]			Numeric(18,0) default 0,
				[Y-2 (u) M3]			Numeric(18,0) default 0,
				[Y-2 (u) M4]			Numeric(18,0) default 0,
				[Y-2 (u) M5]			Numeric(18,0) default 0,
				[Y-2 (u) M6]			Numeric(18,0) default 0,
				[Y-2 (u) M7]			Numeric(18,0) default 0,
				[Y-2 (u) M8]			Numeric(18,0) default 0,
				[Y-2 (u) M9]			Numeric(18,0) default 0,
				[Y-2 (u) M10]			Numeric(18,0) default 0,
				[Y-2 (u) M11]			Numeric(18,0) default 0,
				[Y-2 (u) M12]			Numeric(18,0) default 0,
				[Y-1 (u) M1]			Numeric(18,0) default 0,
				[Y-1 (u) M2]			Numeric(18,0) default 0,
				[Y-1 (u) M3]			Numeric(18,0) default 0,
				[Y-1 (u) M4]			Numeric(18,0) default 0,
				[Y-1 (u) M5]			Numeric(18,0) default 0,
				[Y-1 (u) M6]			Numeric(18,0) default 0,
				[Y-1 (u) M7]			Numeric(18,0) default 0,
				[Y-1 (u) M8]			Numeric(18,0) default 0,
				[Y-1 (u) M9]			Numeric(18,0) default 0,
				[Y-1 (u) M10]			Numeric(18,0) default 0,
				[Y-1 (u) M11]			Numeric(18,0) default 0,
				[Y-1 (u) M12]			Numeric(18,0) default 0,
				[Y0 (u) M1]				Numeric(18,0) default 0,
				[Y0 (u) M2]				Numeric(18,0) default 0,
				[Y0 (u) M3]				Numeric(18,0) default 0,
				[Y0 (u) M4]				Numeric(18,0) default 0,
				[Y0 (u) M5]				Numeric(18,0) default 0,
				[Y0 (u) M6]				Numeric(18,0) default 0,
				[Y0 (u) M7]				Numeric(18,0) default 0,
				[Y0 (u) M8]				Numeric(18,0) default 0,
				[Y0 (u) M9]				Numeric(18,0) default 0,
				[Y0 (u) M10]			Numeric(18,0) default 0,
				[Y0 (u) M11]			Numeric(18,0) default 0,
				[Y0 (u) M12]			Numeric(18,0) default 0,
				[Y+1 (u) M1]			Numeric(18,0) default 0,
				[Y+1 (u) M2]			Numeric(18,0) default 0,
				[Y+1 (u) M3]			Numeric(18,0) default 0,
				[Y+1 (u) M4]			Numeric(18,0) default 0,
				[Y+1 (u) M5]			Numeric(18,0) default 0,
				[Y+1 (u) M6]			Numeric(18,0) default 0,
				[Y+1 (u) M7]			Numeric(18,0) default 0,
				[Y+1 (u) M8]			Numeric(18,0) default 0,
				[Y+1 (u) M9]			Numeric(18,0) default 0,
				[Y+1 (u) M10]			Numeric(18,0) default 0,
				[Y+1 (u) M11]			Numeric(18,0) default 0,
				[Y+1 (u) M12]			Numeric(18,0) default 0,'
	select @sql1='
				[B_Y0_M1]				Numeric(18,0) default 0,
				[B_Y0_M2]				Numeric(18,0) default 0,
				[B_Y0_M3]				Numeric(18,0) default 0,
				[B_Y0_M4]				Numeric(18,0) default 0,
				[B_Y0_M5]				Numeric(18,0) default 0,
				[B_Y0_M6]				Numeric(18,0) default 0,
				[B_Y0_M7]				Numeric(18,0) default 0,
				[B_Y0_M8]				Numeric(18,0) default 0,
				[B_Y0_M9]				Numeric(18,0) default 0,
				[B_Y0_M10]				Numeric(18,0) default 0,
				[B_Y0_M11]				Numeric(18,0) default 0,
				[B_Y0_M12]				Numeric(18,0) default 0,
				[B_Y+1_M1]				Numeric(18,0) default 0,
				[B_Y+1_M2]				Numeric(18,0) default 0,
				[B_Y+1_M3]				Numeric(18,0) default 0,
				[B_Y+1_M4]				Numeric(18,0) default 0,
				[B_Y+1_M5]				Numeric(18,0) default 0,
				[B_Y+1_M6]				Numeric(18,0) default 0,
				[B_Y+1_M7]				Numeric(18,0) default 0,
				[B_Y+1_M8]				Numeric(18,0) default 0,
				[B_Y+1_M9]				Numeric(18,0) default 0,
				[B_Y+1_M10]				Numeric(18,0) default 0,
				[B_Y+1_M11]				Numeric(18,0) default 0,
				[B_Y+1_M12]				Numeric(18,0) default 0,
				[PB_Y+1_M1]				Numeric(18,0) default 0,
				[PB_Y+1_M2]				Numeric(18,0) default 0,
				[PB_Y+1_M3]				Numeric(18,0) default 0,
				[PB_Y+1_M4]				Numeric(18,0) default 0,
				[PB_Y+1_M5]				Numeric(18,0) default 0,
				[PB_Y+1_M6]				Numeric(18,0) default 0,
				[PB_Y+1_M7]				Numeric(18,0) default 0,
				[PB_Y+1_M8]				Numeric(18,0) default 0,
				[PB_Y+1_M9]				Numeric(18,0) default 0,
				[PB_Y+1_M10]			Numeric(18,0) default 0,
				[PB_Y+1_M11]			Numeric(18,0) default 0,
				[PB_Y+1_M12]			Numeric(18,0) default 0,
				[T1_Y0_M1]				Numeric(18,0) default 0,
				[T1_Y0_M2]				Numeric(18,0) default 0,
				[T1_Y0_M3]				Numeric(18,0) default 0,
				[T1_Y0_M4]				Numeric(18,0) default 0,
				[T1_Y0_M5]				Numeric(18,0) default 0,
				[T1_Y0_M6]				Numeric(18,0) default 0,
				[T1_Y0_M7]				Numeric(18,0) default 0,
				[T1_Y0_M8]				Numeric(18,0) default 0,
				[T1_Y0_M9]				Numeric(18,0) default 0,
				[T1_Y0_M10]				Numeric(18,0) default 0,
				[T1_Y0_M11]				Numeric(18,0) default 0,
				[T1_Y0_M12]				Numeric(18,0) default 0,
				[T2_Y0_M1]				Numeric(18,0) default 0,
				[T2_Y0_M2]				Numeric(18,0) default 0,
				[T2_Y0_M3]				Numeric(18,0) default 0,
				[T2_Y0_M4]				Numeric(18,0) default 0,
				[T2_Y0_M5]				Numeric(18,0) default 0,
				[T2_Y0_M6]				Numeric(18,0) default 0,
				[T2_Y0_M7]				Numeric(18,0) default 0,
				[T2_Y0_M8]				Numeric(18,0) default 0,
				[T2_Y0_M9]				Numeric(18,0) default 0,
				[T2_Y0_M10]				Numeric(18,0) default 0,
				[T2_Y0_M11]				Numeric(18,0) default 0,
				[T2_Y0_M12]				Numeric(18,0) default 0,
				[T3_Y0_M1]				Numeric(18,0) default 0,
				[T3_Y0_M2]				Numeric(18,0) default 0,
				[T3_Y0_M3]				Numeric(18,0) default 0,
				[T3_Y0_M4]				Numeric(18,0) default 0,
				[T3_Y0_M5]				Numeric(18,0) default 0,
				[T3_Y0_M6]				Numeric(18,0) default 0,
				[T3_Y0_M7]				Numeric(18,0) default 0,
				[T3_Y0_M8]				Numeric(18,0) default 0,
				[T3_Y0_M9]				Numeric(18,0) default 0,
				[T3_Y0_M10]				Numeric(18,0) default 0,
				[T3_Y0_M11]				Numeric(18,0) default 0,
				[T3_Y0_M12]				Numeric(18,0) default 0
			)'
			if @debug>0
			begin
				select @sql+@sql1 'Create table'
			end
			execute(@sql+@sql1)

			select @n_err = @@ERROR
			if @n_err<>0
			begin
				select @n_continue = 3
				--select @n_err=60003
				select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +ERROR_MESSAGE()+'./ ('+@sp_name+')'
			end
		end
	end
	if @debug>0
	begin
		select 'Insert data into table BFL Master final'
	end
	if @n_continue = 1
	begin
		select @sql=
		'INSERT INTO '+@tablename+'
		Select
			[ComputerName]='''+HOST_NAME()+''',
			*
		from fnc_SubGroupMasterFull('''+@Division+''',''full'') '

		if @debug>0
		begin
			select @sql 'Insert table'
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