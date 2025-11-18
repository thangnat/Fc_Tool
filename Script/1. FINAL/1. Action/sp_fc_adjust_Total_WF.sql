/*
	Declare 
		@b_Success		Int,
		@c_errmsg		Nvarchar(250)

	exec sp_fc_adjust_Total_WF 'CPD','202407',@b_Success OUT,@c_errmsg OUT

	select @b_Success b_Success,@c_errmsg c_errmsg
*/

Alter proc sp_fc_adjust_Total_WF
	@division		nvarchar(3),
	@FM_KEY			nvarchar(6),
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
		,@sql					nvarchar(max) = ''

	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_fc_adjust_Total_WF',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()		

	select @debug=debug from fnc_debug('FC')
	select @debug=1
	declare @Monthfc				nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from V_FC_FM_Table


	if @n_continue=1
	begin
		declare @subgrp nvarchar(500)=''
		select @subgrp=''--'AGE REWIND CONCEALER'		

		declare @Tablename_original				nvarchar(200) = ''
		select @Tablename_original ='FC_FM_Original_'+@division+@Monthfc

		declare @Tablename				nvarchar(200) = ''
		select @Tablename ='FM_Original_Full_Adj_'+@division+@Monthfc
	
		declare @listcolumn_backup nvarchar(max)=''
		SELECT @listcolumn_backup=ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'updateForecast','x')
		--SELECT listcolumn_update=ListColumn FROM fn_FC_GetColheader_Current('202408','updateForecast','x')
	
		declare @listcolumn_update_tyle1 nvarchar(max)=''
		SELECT @listcolumn_update_tyle1=ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'updatetotalfct1','f')
		--SELECT listcolumn_update_tyle1=ListColumn FROM fn_FC_GetColheader_Current('202408','updatetotalfct1','f')
	
		declare @listcolumn_update_tyle2 nvarchar(max)=''
		SELECT @listcolumn_update_tyle2=ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'updatetotalfct2','f')
		--SELECT listcolumn_update_tyle2=ListColumn FROM fn_FC_GetColheader_Current('202408','updatetotalfct2','f')
	
		declare @listcolumn_update_custom nvarchar(max)=''
		SELECT @listcolumn_update_custom=ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'updatetotalfcc','f')
		--SELECT listcolumn_update_custom=ListColumn FROM fn_FC_GetColheader_Current('202406','updatetotalfcc','f')

		declare @listcolumn_fcpercentline nvarchar(max)=''
		SELECT @listcolumn_fcpercentline=ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'fcpercentline','x')
		--SELECT listcolumn_fcpercentline=ListColumn FROM fn_FC_GetColheader_Current('202408','fcpercentline','x')
	end

	if @n_continue=9
	begin
		--//update wf custom
		select @sql=
		'Update '+@Tablename_original+'
		set '
			/*tablename=''Update wf custom'',
			[SUB GROUP/ Brand]=t.[SUB GROUP/ Brand],
			Channel=t.Channel,
			[Time series]=t.[Time series],*/
			+@listcolumn_backup+'
		from '+@Tablename_original+' f
		inner join
		(
			select
				tablename=''Update wf custom'',
				[SUB GROUP/ Brand]=t.[SUB GROUP/ Brand],
				Channel=t.Channel,
				[Time series]=p.[Time series],'
				+@listcolumn_update_custom+'
			from
			(
				select 
					*
				from '+@Tablename_original+'_Tmp
				where 
					(len('''+@subgrp+''')=0 OR [SUB GROUP/ Brand]='''+@subgrp+''')
				and [Time series] =''6. Total Qty''
			) t
			inner join
			(
				select  DISTINCT
					[SUB GROUP/ Brand]=trim([SUB GROUP/ Brand]),     
					Channel=trim(Channel),    
					[Time series]=trim([Time series]),    
					[Percent]    
				from fc_config_wf_total_custom 
				where 
					Division='''+@division+''' 
				and (len('''+@subgrp+''')=0 OR trim([SUB GROUP/ Brand])='''+@subgrp+''')
			) p on 
				p.[SUB GROUP/ Brand]=t.[SUB GROUP/ Brand] 
			and p.Channel=t.Channel 
			where 
				(len('''+@subgrp+''')=0 OR t.[SUB GROUP/ Brand]='''+@subgrp+''')
			and t.[Time series] not in(''3. Promo Qty(BOM)'',''5. FOC Qty'') 
		) as 
			x on x.[SUB GROUP/ Brand]=f.[SUB GROUP/ Brand]
		and x.Channel = f.channel
		and x.[Time series]=f.[Time series] '
		/*order by
			t.[SUB GROUP/ Brand] asc,
			t.Channel asc,
			t.[Time series] asc '*/

		if @debug>0
		begin
			select @sql
		end
		--execute(@sql)
	end
	if @n_continue=9
	begin
		--//update wf ty le
		select @sql='
		update '+@Tablename_original+'
		set '
			/*[SUB GROUP/ Brand]=f.[SUB GROUP/ Brand],
			Channel=f.Channel,
			[Time series]=f.[Time series],*/
			+@listcolumn_backup+'
		from '+@Tablename_original+' f
		inner join
		(
			select
				fm.[SUB GROUP/ Brand],
				fm.Channel,
				fm.[Time series],'
				+@listcolumn_update_tyle1+'
			from
			(
				select
					a.[SUB GROUP/ Brand],
					a.Channel,
					a.[Time series],'+
					@listcolumn_fcpercentline+'
				from '+@Tablename+' a
				INNER JOIN
				(
					select
						*
					from '+@Tablename+'
					where 
						(len('''+@subgrp+''')=0 OR [SUB GROUP/ Brand]='''+@subgrp+''')
					and [Time series] IN(''6. Total Qty'')
					and (
							[Y0 (u) M1]+[Y0 (u) M2]+[Y0 (u) M3]+[Y0 (u) M4]+[Y0 (u) M5]+[Y0 (u) M6]+[Y0 (u) M7]+[Y0 (u) M8]+[Y0 (u) M9]+[Y0 (u) M10]+[Y0 (u) M11]+[Y0 (u) M12]
							+[Y+1 (u) M1]+[Y+1 (u) M2]+[Y+1 (u) M3]+[Y+1 (u) M4]+[Y+1 (u) M5]+[Y+1 (u) M6]+[Y+1 (u) M7]+[Y+1 (u) M8]+[Y+1 (u) M9]+[Y+1 (u) M10]+[Y+1 (u) M11]+[Y+1 (u) M12]
						)<>0
				) T ON T.[SUB GROUP/ Brand]=a.[SUB GROUP/ Brand] and t.Channel=a.Channel
				where 
					(len('''+@subgrp+''')=0 OR a.[SUB GROUP/ Brand]='''+@subgrp+''')
				and a.[Time series] NOT IN(''6. Total Qty'')
			) fm
			inner join
			(
				select 
					*
				from '+@Tablename_original+'_Tmp
				where 
					[Time series]=''6. Total Qty''
				and (len('''+@subgrp+''')=0 OR [SUB GROUP/ Brand]='''+@subgrp+''')
				and (
						[Y0 (u) M1]+[Y0 (u) M2]+[Y0 (u) M3]+[Y0 (u) M4]+[Y0 (u) M5]+[Y0 (u) M6]+[Y0 (u) M7]+[Y0 (u) M8]+[Y0 (u) M9]+[Y0 (u) M10]+[Y0 (u) M11]+[Y0 (u) M12]
						+[Y+1 (u) M1]+[Y+1 (u) M2]+[Y+1 (u) M3]+[Y+1 (u) M4]+[Y+1 (u) M5]+[Y+1 (u) M6]+[Y+1 (u) M7]+[Y+1 (u) M8]+[Y+1 (u) M9]+[Y+1 (u) M10]+[Y+1 (u) M11]+[Y+1 (u) M12]
					)<>0
			) ad on ad.[SUB GROUP/ Brand]=fm.[SUB GROUP/ Brand] and ad.Channel=fm.Channel /*and ad.[Time series]=fm.[Time series]*/
		) as x on x.[SUB GROUP/ Brand]=f.[SUB GROUP/ Brand] and x.Channel=f.Channel and x.[Time series]=f.[Time series]
		where
			 trim(f.[SUB GROUP/ Brand])+''*''+trim(F.CHANNEL) NOT IN
			(
				select DISTINCT
					trim([SUB GROUP/ Brand])+''*''+trim(Channel)
				from fc_config_wf_total_custom
				WHERE division='''+@division+'''
			)
		and (len('''+@subgrp+''')=0 OR f.[SUB GROUP/ Brand]='''+@subgrp+''')
		and f.Channel NOT IN(''O+O'')
		and f.[Time series] IN(''1. Baseline Qty'',''2. Promo Qty(Single)'',''4. Launch Qty'')
		and (
				f.[Y0 (u) M1]+f.[Y0 (u) M2]+f.[Y0 (u) M3]+f.[Y0 (u) M4]+f.[Y0 (u) M5]+f.[Y0 (u) M6]+f.[Y0 (u) M7]+f.[Y0 (u) M8]+f.[Y0 (u) M9]+f.[Y0 (u) M10]+f.[Y0 (u) M11]+f.[Y0 (u) M12]
				+f.[Y+1 (u) M1]+f.[Y+1 (u) M2]+f.[Y+1 (u) M3]+f.[Y+1 (u) M4]+f.[Y+1 (u) M5]+f.[Y+1 (u) M6]+f.[Y+1 (u) M7]+f.[Y+1 (u) M8]+f.[Y+1 (u) M9]+f.[Y+1 (u) M10]+f.[Y+1 (u) M11]+f.[Y+1 (u) M12]
			)<>0'
		--and f.[SUB GROUP/ Brand]=''AGE REWIND CONCEALER'' '
		/*order by
			f.[SUB GROUP/ Brand] asc,
			f.Channel asc,
			f.[Time series] asc '*/

		if @debug>0
		begin
			select @sql
		end
		--execute(@sql)
	end
	--if @n_continue=1
	--begin
		
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