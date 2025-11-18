/*
	Declare 
		@b_Success		Int,
		@c_errmsg		Nvarchar(250)

	exec sp_fc_Get_spectrum_standard 'CPD','202407','1. baseline Qty',@b_Success OUT, @c_errmsg OUT

	select @b_Success b_Success, @c_errmsg c_errmsg

	select * from fc_spectrum_standard_CPD
*/

Alter proc sp_fc_Get_spectrum_standard
	@division		nvarchar(3),
	@FM_KEY			nvarchar(6),
	@timeseries		nvarchar(20),
	@b_Success		Int				OUTPUT,     
	@c_errmsg		Nvarchar(250)	OUTPUT
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
		,@SalesOrg				nvarchar(4) = ''
		,@sql					nvarchar(max) = ''
			
	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_fc_Get_spectrum_standard',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	select @debug=debug from fnc_Debug('FC')
	--select @debug=1

	declare @Monthfc				nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from V_FC_FM_Table

	--select * from fnc_FC_CountryStatus_Config('CPD') where Channel = @channel and [Time series] = @timeseries
	declare @tablename				nvarchar(100) = ''
	select @tablename  ='fc_spectrum_standard_'+@division
	
	declare @listcolumn nvarchar(max) = ''
	SELECT @listcolumn = ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'fc_spectrum_2','x')
	--SELECT listcolumn = ListColumn FROM fn_FC_GetColheader_Current('202407','fc_spectrum_2','x')
	if @debug>0
	begin
		select @listcolumn '@listcolumn'
	end

	--select @listcolumn = 
	--	'[Y0 (u) M5] = sum([Y0 (u) M5]),
	--	[Y0 (u) M6] = sum([Y0 (u) M6]),
	--	[Y0 (u) M7] = sum([Y0 (u) M7]),
	--	[Y0 (u) M8] = sum([Y0 (u) M8]),
	--	[Y0 (u) M9] = sum([Y0 (u) M9]),
	--	[Y0 (u) M10] = sum([Y0 (u) M10]),
	--	[Y0 (u) M11] = sum([Y0 (u) M11]),
	--	[Y0 (u) M12] = sum([Y0 (u) M12]),
	--	[Y+1 (u) M1] = sum([Y+1 (u) M1]),
	--	[Y+1 (u) M2] = sum([Y+1 (u) M2]),
	--	[Y+1 (u) M3] = sum([Y+1 (u) M3]),
	--	[Y+1 (u) M4] = sum([Y+1 (u) M4]),
	--	[Y+1 (u) M5] = sum([Y+1 (u) M5]),
	--	[Y+1 (u) M6] = sum([Y+1 (u) M6]),
	--	[Y+1 (u) M7] = sum([Y+1 (u) M7]),
	--	[Y+1 (u) M8] = sum([Y+1 (u) M8]),
	--	[Y+1 (u) M9] = sum([Y+1 (u) M9]),
	--	[Y+1 (u) M10] = sum([Y+1 (u) M10]),
	--	[Y+1 (u) M11] = sum([Y+1 (u) M11]),
	--	[Y+1 (u) M12] = sum([Y+1 (u) M12]),
	--	[Y+2 (u) M1] = sum([Y+2 (u) M1]),
	--	[Y+2 (u) M2] = sum([Y+2 (u) M2]),
	--	[Y+2 (u) M3] = sum([Y+2 (u) M3]),
	--	[Y+2 (u) M4] = sum([Y+2 (u) M4]) '
	if @debug>0
	begin
		select 'create table fc_spectrum_standard_'
	end
	if @n_continue=1
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
				select @sql 'Drop table'
			end
			execute(@sql)
		end
		select @sql = '
		select
			[SUB GROUP/ Brand]=x.[Forecasting Line],
			Channel=x.Channel,
			[Time series]='''+@timeseries+''','
			+@listcolumn+'
			INTO '+@tablename+'
		from FC_Spectrum_'+@division+' x
		where
		x.[Country Status] in
		(
			select value from string_split((
			select DISTINCT
				[List Country status]		
			from fnc_FC_CountryStatus_Config('''+@division+''')
			where [Time series] = '''+@timeseries+'''),'','')
		)
		group by
			x.[Forecasting Line],
			x.Channel '

		/*spt.[Forecasting Line] = ''A'' and */
		if @debug>0
		begin
			select @sql 'Create table'
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
