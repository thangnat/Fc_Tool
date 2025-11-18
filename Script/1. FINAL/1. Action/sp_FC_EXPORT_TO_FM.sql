/*
	exec sp_FC_EXPORT_TO_FM 'CPD','202407','OFFLINE','Baseline Qty',''

	select * from tmp_spectrum
*/


Alter Proc sp_FC_EXPORT_TO_FM
	@Division		nvarchar(3),
	@FM_KEY			nvarchar(6),
	@Channel		nvarchar(10),
	@Timeseries		Nvarchar(30),
	@subgrp			nvarchar(500)
with encryption
As
begin
	declare 
		@debug				int=0,
		@sql				nvarchar(max) = '', 
		@year				nvarchar(4) = '', 
		@month				nvarchar(2) = '',
		@EventDescription	nvarchar(20) = '',
		@listColum			nvarchar(max) = '',
		@Timeseries_ok		nvarchar(20) = '',
		@Spectrum			int = 0,
		@n_continue			Int=1,
		@c_errmsg			nvarchar(250)=''

	declare 
		@b_Success1			Int,
		@c_errmsg1			Nvarchar(250)

	--select @Timeseries_ok = @Timeseries
	select TOP 1
		@Timeseries_ok = MAP 
	from v_FC_TIME_SERIES 
	where TimeSeries = @Timeseries

	if @debug>0
	begin
		select @Timeseries_ok '@Timseries_ok'
	end
	/*
	select TOP 10
		*
	from v_FC_TIME_SERIES 
	where TimeSeries = @Timeseries
	*/
	--run fm original full
	if @n_continue=1
	begin
		exec sp_fc_Create_FM_Original_Full @Division,@FM_KEY,@Timeseries_ok,'',@b_Success1 OUT, @c_errmsg1 OUT
		if @b_Success1=0
		begin
			select @n_continue=3, @c_errmsg=@c_errmsg1
		end
	end
	--select @n_continue '@n_continue 1.1'
	--//run WF
	if @n_continue=1
	begin		
		exec sp_FC_FM_WF_Upload @Division,@FM_KEY,'',@Timeseries_ok,@b_Success1 OUT, @c_errmsg1 OUT
		if @b_Success1=0
		begin
			select @n_continue=3, @c_errmsg=@c_errmsg1
		end
	end
	--select @n_continue '@n_continue 1.2'
	if @n_continue=1
	begin
		select @year = left(@FM_KEY,4), @month = right(@FM_KEY,2)
		if @debug>0
		begin
			select @year '@year' 
		end
		select 
			@EventDescription = Month_Desc +' FC'
		from V_Month_Master 
		where Month_Number = cast(@month as int)

		if @debug>0
		begin
			select @EventDescription '@EventDescription'
		end
	end
	--select @n_continue '@n_continue 1.3'
	if @n_continue=1
	begin
		--if @Spectrum = 1
		--begin
		--	SELECT @listColum = ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'UploadFM',@Timeseries)
		--	--SELECT listColum = ListColumn FROM fn_FC_GetColheader_Current('202406','UploadFM','')
		--end
		--else
		--begin
			SELECT @listColum = ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'UploadFM','f')
			--SELECT listColum = ListColumn FROM fn_FC_GetColheader_Current('202406','UploadFM','f')
		--end
		if @debug>0
		begin
			SELECT @listColum '@listColum'
		end
	end
	--select @n_continue '@n_continue 1.4'
	--SELECT listColum = ListColumn FROM fn_FC_GetColheader_Current('202405','UploadFM','f')	
	--SELECT listColum = ListColumn FROM fn_FC_GetColheader_Current('202405','UploadFM','')
	--SELECT listColum = ListColumn FROM fn_FC_GetColheader_Current('202405','UploadFM_3','f')
	declare @tablename nvarchar(200)='tmp_spectrum'
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
			execute(@sql)
		end

		/*select @sql =
		'Create table '+@tablename+'
		(
			[Signature]				nvarchar(20) null,
			[Code]					nvarchar(20) not null,
			[Event Description]		nvarchar(20) null,
			[SKU]					nvarchar(20) not null,
			[SKU Descritpion]		nvarchar(500) null,
			[Customer level]		nvarchar(20) not null,
			[Year YYYY]				nvarchar(4) null,
			[Month MM]				nvarchar(2) null,
			[QTy M]					int default 0,
			[QTy M+1]				int default 0,
			[QTy M+2]				int default 0,
			[QTy M+3]				int default 0,
			[QTy M+4]				int default 0,
			[QTy M+5]				int default 0,
			[QTy M+6]				int default 0,
			[QTy M+7]				int default 0,
			[QTy M+8]				int default 0,
			[QTy M+9]				int default 0,
			[QTy M+10]				int default 0,
			[QTy M+11]				int default 0,
			[QTy M+12]				int default 0,
			[QTy M+13]				int default 0,
			[QTy M+14]				int default 0,
			[QTy M+15]				int default 0,
			[QTy M+16]				int default 0,
			[QTy M+17]				int default 0,
			[QTy M+18]				int default 0,
			[QTy M+19]				int default 0
		)
		ALTER TABLE '+@tablename+' ADD CONSTRAINT PK_'+@tablename+' PRIMARY KEY  ([Code],[SKU],[Customer level]) '
		if @debug>0
		begin
			select @sql '@create table '
		end
		execute(@sql)*/

		select @sql =
		'select		
			[Signature] = wf.[Signature],
			[Code] = ''FG'',
			[Event Description] ='''+@EventDescription+''',
			[SKU] = wf.[Sap Code],
			[SKU Descritpion] = wf.[Bundle name],
			[Customer level] =case when wf.[Channel] = ''OFFLINE'' then '''+@Division+'_VN_F0001'' else ''_VN_F0002'' end,
			[Year YYYY] = '''+@year+''',
			[Month MM] = cast('''+@month+''' as nvarchar(2)), '
			+@listColum+' 
			INTO '+@tablename+'
		from 
		(
			select 
				* 
			from FC_FM_WF_Upload_'+@Division+'
		) wf	
		Left join 
		(
			SELECT
				* 
			FROM FM_Original_Full_'+@Division+'
		) f on 
			f.[SUB GROUP/ Brand]=wf.[SUB GROUP/ Brand]
		and f.[Channel]=wf.Channel 
		and f.[Time series]=wf.[Time series]
		and f.[Sap Code]=wf.[Sap Code] 
		where 
			(len('''+@Channel+''')=0 OR wf.Channel = '''+@Channel+''')
		and (len('''+@subgrp+''')=0 OR wf.[SUB GROUP/ Brand] = '''+@subgrp+''') '
	

		if @debug>0
		begin
			select @sql '@sql 1.1.1',len_ = len(@sql)
		end
		execute(@sql)
	end
end