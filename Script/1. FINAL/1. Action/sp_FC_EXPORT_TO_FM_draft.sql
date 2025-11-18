/*
	exec sp_FC_EXPORT_TO_FM_draft '202405'
*/

Alter proc sp_FC_EXPORT_TO_FM_draft
	@FM_KEY			nvarchar(6)
	with encryption
As
	--select * 
	--from FC_Spectrum_CPD
	--where SKU in('G4635600','G4516000')
	--select 
	--	[Bundle name] 
	--from fnc_SubGroupMaster('CPD','')

	declare 
		@sql nvarchar(max) = '',
		@division nvarchar(3) = 'CPD',
		@timeseries nvarchar(20) = '1. Baseline Qty',
		@listcolumn		nvarchar(max) = '',
		@listcolumn_spt		nvarchar(max) = '',
		@listcolumn_check		nvarchar(max) = ''
	
	SELECT @listcolumn = ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'UploadFM_3','f')
	--SELECT listcolumn = ListColumn FROM fn_FC_GetColheader_Current('202405','UploadFM_3','f')
	SELECT @listcolumn_spt = ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'UploadFM_4','spt')
	--SELECT listcolumn_spt = ListColumn FROM fn_FC_GetColheader_Current('202405','UploadFM_4','spt')
	SELECT @listcolumn_check = ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'UploadFM_5','x')
	--SELECT listcolumn_check = ListColumn FROM fn_FC_GetColheader_Current('202405','UploadFM_5','x')
	--sum subgroup
	select @sql =
	'select
		x.*, 
		('+@listcolumn_check+')-
		CONVERT(DECIMAL(10,0),round(('
		+@listcolumn_check+'),0, 1)) as test,
		('+@listcolumn_check+')-
		CONVERT(DECIMAL(10,0),round(('
		+@listcolumn_check+'),0, 1)) as test2,
		case when ('+@listcolumn_check+')-
		CONVERT(DECIMAL(10,0),round(('
		+@listcolumn_check+'),0, 1))>0 and ('+@listcolumn_check+')-
		CONVERT(DECIMAL(10,0),round(('
		+@listcolumn_check+'),0, 1))<1 then ''Wrong'' else ''True'' end as [Check] 
	from
	(
		select
			f.[SUB GROUP/ Brand],
			f.channel,'
			+@listcolumn_spt+'
		from FC_FM_Original_CPD f
		inner join fnc_SubGroupMaster('''+@division+''','''') s on s.[SUB GROUP/ Brand] = f.[SUB GROUP/ Brand]
		inner join FC_Spectrum_CPD spt on spt .SKU = s.Material and spt.Channel = f.Channel
		where [Time series] = '''+@timeseries+'''
		and f.Channel not in(''O+O'')
		and f.[SUB GROUP/ Brand] = ''BROW ART PRO''
		group by f.[SUB GROUP/ Brand], f.channel
	) as x'
	--select @sql
	execute(@sql)
	--return
	--export code
	select @sql =
	'select
		/*f.[SUB GROUP/ Brand],*/
		s.Material,
		s.[Product Type],
		f.channel,'
		+@listcolumn+'
	from FC_FM_Original_CPD f
	inner join fnc_SubGroupMaster('''+@division+''','''') s on s.[SUB GROUP/ Brand] = f.[SUB GROUP/ Brand]
	inner join FC_Spectrum_CPD spt on spt .SKU = s.Material and spt.Channel = f.Channel
	where [Time series] = '''+@timeseries+'''
	and f.Channel not in(''O+O'')
	and f.[SUB GROUP/ Brand] = ''BROW ART PRO'' '
	--select @sql
	execute(@sql)