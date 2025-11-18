/*
	Declare
		@b_Success			Int,
		@c_errmsg			Nvarchar(250)

	exec sp_add_FC_Spectrum 'CPD','202407',@b_Success OUT,@c_errmsg OUT

	select @b_Success b_Success,@c_errmsg c_errmsg

	select * from FC_Spectrum_LLD
	select * from FC_Spectrum_CPD
	select * from FC_Spectrum_LDB
*/
Alter proc sp_add_FC_Spectrum
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
			,@fm_file_name			nvarchar(100) =''
			,@DbName NVARCHAR(20)

	-- Get the environment configuration
	SELECT @DbName = CASE 
		WHEN Value = 'Production' THEN 'master.dbo'
		ELSE 'master_UAT'
	END
	FROM EnvironmentConfig
	WHERE Name = 'Current_Environment'

	select @fm_file_name = @Division+'_SPECTRUM_'+@FM_Key+'.xlsx'
	SELECT	@n_continue=1, 
			@b_success=0,
			@n_err=0,
			@c_errmsg='', 
			@sp_name = 'sp_add_FC_Spectrum',
			@USERS = SUSER_NAME(),
			@MODIFILED = GETDATE()

	declare @sql nvarchar(max) = ''
	--declare @result nvarchar(MAX) = ''
	declare @tablename nvarchar(200) = ''
	declare @tablename_tmp nvarchar(200) = ''
	select 
		@tablename = 'FC_Spectrum_'+@Division,
		@tablename_tmp = 'FC_Spectrum_'+@Division+'_tmp'
	--SELECT @result = ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'SP','sp')
	--SELECT result = ListColumn FROM fn_FC_GetColheader_Current('202405','SP','sp')
	declare
		@b_Success1			Int,
		@c_errmsg1			Nvarchar(250)

	if @n_continue = 1
	begin
		if @Division NOT IN('LDB')
		begin
			--//add tmp table
			IF @DbName = 'master.dbo'
				exec link_37.master.dbo.sp_add_FC_Spectrum_Tmp @Division,@fm_file_name,@b_Success1 OUT, @c_errmsg1 OUT
			ELSE
				exec link_37.master_UAT.dbo.sp_add_FC_Spectrum_Tmp @Division,@fm_file_name,@b_Success1 OUT, @c_errmsg1 OUT

			if @b_Success1 = 0
			begin
				select @n_continue = 3, @c_errmsg = @c_errmsg1
			end
		end
	end
	BEGIN TRAN
	if @n_continue = 1
	begin
		declare @listcolumn1 nvarchar(max) = ''
		declare @listcolumn2 nvarchar(max) = ''
		declare @listcolumn3 nvarchar(max) = ''
		declare @listcolumn4 nvarchar(max) = ''

		SELECT @listcolumn1 = ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'fc_spectrum_1','b1')
		--SELECT listcolumn1 = ListColumn FROM fn_FC_GetColheader_Current('202405','fc_spectrum_1','b1')
		SELECT @listcolumn2 = ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'fc_spectrum_2','x')
		--SELECT listcolumn2 = ListColumn FROM fn_FC_GetColheader_Current('202405','fc_spectrum_2','x')
		SELECT @listcolumn3 = ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'fc_spectrum_3','x')
		--SELECT listcolumn3 = ListColumn FROM fn_FC_GetColheader_Current('202405','fc_spectrum_3','x')
		SELECT @listcolumn4 = ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'fc_spectrum_4','x')
		--SELECT listcolumn4 = ListColumn FROM fn_FC_GetColheader_Current('202406','fc_spectrum_4','x')

		if exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID(@tablename) AND type in (N'U')
		)
		begin
			select @sql = 'drop table '+@tablename--FC_SpectrumL_Tmp
			execute(@sql)
		end

		--select @sql = 
		--'Select 
		--	Filename = '''+@fm_file_name+''', 
		--	Channel,
		--	Subgroup,
		--	BFL,
		--	EAN,
		--	[Sap Code],'
		--	+@result 
		--	+'INTO '+@tablename
		--	+' from link_37.master.dbo.'+@tablename_tmp +' sp'
		if @Division = 'CPD1'
		begin
			select @sql = 
			'select
				Filename = '''+@fm_file_name+''', 
				Channel = CASE WHEN RIGHT([FM Customer Level 3 ],5) = ''F0001'' THEN ''OFFLINE'' ELSE ''ONLINE'' END,
				[SKU],'
				+@listcolumn2+'
				INTO '+@tablename+'
			from
			(
				select
					[SKU],
					[FM Customer Level 3 ],'
					+@listcolumn1
				+'from '+@DbName+'.'+@tablename_tmp+'
			) as x
			group by
				SKU,[FM Customer Level 3 ] '
		end
		else if @Division = 'CPD'
		begin
			select @sql = 
			'select
				Filename = '''+@fm_file_name+''', 
				*
				INTO '+@tablename+'
			from
			(
				select
					[Channel],
					[Forecasting Line],
					[EAN],
					[SKU]=[SAP Code],
					[Description],
					[Country Status]=[FM Status],
					[MMPP]='''', '
					+@listcolumn3
				+'from '+@DbName+'.'+@tablename_tmp+
			') x'
		end
		else if @Division = 'LLD'
		begin
			select @sql = 
			'select
				Filename = '''+@fm_file_name+''', 
				*
				INTO '+@tablename+'
			from
			(
				select
					[Channel],
					[Forecasting Line],
					[EAN],
					[SKU]=[SAP Code],
					[Description],
					[Country Status]=[FM Status],
					[MMPP]='''', '
					+@listcolumn3
				+'from '+@DbName+'.'+@tablename_tmp+
			') x'
		end
		else if @Division = 'LDB'
		begin
			select @sql = 
			'select
				Filename = '''', 
				*
				INTO '+@tablename+'
			from
			(
				select
					[Channel]=c.Channel,
					[Forecasting Line]=s.[SUB GROUP/ Brand],
					[EAN]=s.Barcode,
					[SKU]=s.Material,
					[Description]=s.[Bundle name],
					[Country Status]='''',
					[MMPP]='''', '
					+@listcolumn4+'
				from fnc_SubGroupMaster(''LDB'','''') s
				cross join 
				(
					select
						*
					from V_FC_Channel
					where Channel not in(''FOC'')
				) as c
			) x'
			/*[FM Status]*/
		end
		/*where sku = ''G4063600''*/
		if @debug>0
		begin
			SELECT @sql '@sql'
		end
		execute(@sql)

		select @n_err = @@ERROR
		if @n_err<>0
		begin				
			select @n_continue = 3
			select @n_err=60002
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