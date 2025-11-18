/*
	Declare 
		@b_Success		Int,
		@c_errmsg		Nvarchar(250)

	exec sp_fc_adjust_Total_WF_Tyle 'CPD','202410',@b_Success OUT,@c_errmsg OUT

	select @b_Success b_Success,@c_errmsg c_errmsg
*/

Alter proc sp_fc_adjust_Total_WF_Tyle
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
		,@sql1					nvarchar(max)=''
		,@sql0					nvarchar(max) = ''
		,@host_name				nvarchar(50)=''--'VNCORPVNWKS1154'

	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_fc_adjust_Total_WF',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()		

	select @debug=debug from fnc_debug('FC')
	--select @debug=1
	
	declare @Monthfc				nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from V_FC_FM_Table

	declare @Tablename_original				nvarchar(200) = ''
	select @Tablename_original ='FC_FM_Original_'+@division+@Monthfc

	declare @tablename0 nvarchar(100)=''
	select @tablename0='fc_list_forecasting_line_update_'+case when @host_name='' then HOST_NAME() else @host_name end

	declare @table_tyle_tmp nvarchar(100)=''
	select @table_tyle_tmp='FC_TYLE_Tmp_'+case when @host_name='' then HOST_NAME() else @host_name end

	if @n_continue=1
	begin
		declare @Total_Sum_minus_bom nvarchar(max)=''
		SELECT @Total_Sum_minus_bom=ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'Total_Sum_minus_bom','f')
		--SELECT Total_Sum_minus_bom=ListColumn FROM fn_FC_GetColheader_Current('202407','Total_Sum_minus_bom','f')

		declare @Total_Listcolumn nvarchar(max)=''
		SELECT @Total_Listcolumn=ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'Total_Listcolumn','f')
		--SELECT Total_Listcolumn=ListColumn FROM fn_FC_GetColheader_Current('202407','Total_Listcolumn','f')

		declare @Total_remainder nvarchar(max)=''
		SELECT @Total_remainder=ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'Total_remainder','f')
		--SELECT Total_remainder=ListColumn FROM fn_FC_GetColheader_Current('202407','Total_remainder','f')

		declare @Total_Plus_remainder nvarchar(max)=''
		SELECT @Total_Plus_remainder=ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'Total_Plus_remainder',@host_name)
		--SELECT Total_Plus_remainder=ListColumn FROM fn_FC_GetColheader_Current('202407','Total_Plus_remainder','VNCORPVNWKS1154')

		declare @Total_Exclude_Bom nvarchar(max)=''
		SELECT @Total_Exclude_Bom=ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'Total_Exclude_Bom','f')
		--SELECT Total_Exclude_Bom=ListColumn FROM fn_FC_GetColheader_Current('202407','Total_Exclude_Bom','f')

		declare @total_sum_list nvarchar(max)=''
		SELECT @total_sum_list=ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'BomheaderQty','f')
		--SELECT total_sum_list=ListColumn FROM fn_FC_GetColheader_Current('202407','BomheaderQty','f')

		declare @Total_getpercent nvarchar(max)=''
		SELECT @Total_getpercent=ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'Total_getpercent','f')
		--SELECT Total_getpercent=ListColumn FROM fn_FC_GetColheader_Current('202407','Total_getpercent','f')

		declare @Total_x_total nvarchar(max)=''
		SELECT @Total_x_total=ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'Total_x_total','f')
		--SELECT Total_x_total=ListColumn FROM fn_FC_GetColheader_Current('202407','Total_x_total','f')

		declare @Total_groupbycalcol nvarchar(max)=''
		SELECT @Total_groupbycalcol=ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'Total_groupbycalcol','t1')
		--SELECT Total_groupbycalcol=ListColumn FROM fn_FC_GetColheader_Current('202407','Total_groupbycalcol','t1')

		declare @listcolumn_backup nvarchar(max)=''
		SELECT @listcolumn_backup=ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'updateForecast','x')
		--SELECT listcolumn_update=ListColumn FROM fn_FC_GetColheader_Current('202407','updateForecast','x')

		declare @listcolumn_plus nvarchar(max)=''
		SELECT @listcolumn_plus=ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'1. Baseline Qty_+','f')
		--SELECT listcolumn_plus=ListColumn FROM fn_FC_GetColheader_Current('202407','1. Baseline Qty_+','f')

		declare @Total_list_change nvarchar(max)=''
		SELECT @Total_list_change=ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'Total_list_change','f')
		--SELECT Total_list_change=ListColumn FROM fn_FC_GetColheader_Current('202407','Total_list_change','f')
	end

	if @n_continue=1
	begin
		if exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID(@table_tyle_tmp) AND type in (N'U')
		)
		begin
			select @sql='Drop table '+@table_tyle_tmp
			if @debug>0
			begin
				select @sql 'Drop table tyle tmp'
			end
			execute(@sql)
		end

		select @sql=
		'select
			 [SUB GROUP/ Brand]=f.[SUB GROUP/ Brand]
			,[Channel]=f.[Channel]
			,[Time series]=f.[Time series],'+
			@Total_Listcolumn+'
			INTO '+@table_tyle_tmp+'
		from '+@Tablename_original+' f1
		inner join   
		(   
			/*cal total x %*/
			select    
				 fm.[SUB GROUP/ Brand]  
				,fm.Channel
				,fm.[Time series], '+@Total_x_total+'
				/*,[Y0 (u) M7]=CAST(ad.[Y0 (u) M7]*fm.[Y0 (u) M7] as INT)*/
			from  
			(    
				/*--//get pecent %: for each item /total*/
				select   
					 a.[SUB GROUP/ Brand]
					,a.Channel
					,a.[Time series], '+
					@Total_getpercent+'
				from 
				(
					/*get for each item first table FM original*/
					select
						 [SUB GROUP/ Brand]
						,[Channel]
						,[Time series], '+@Total_Listcolumn+'
					from FM_Original_Full_Adj_'+@division+@Monthfc+' f
					where 
						cast(replace(left([Time series],2),''.'','''') as int) IN(1,2,4)
					and f.[SUB GROUP/ Brand] IN(select distinct [SUB GROUP/ Brand] from '+@tablename0+')
				) a   
				left JOIN    
				(      
					/*sum total list column first table FM Original*/
					select    
						 [SUB GROUP/ Brand]
						,[Channel], '+@total_sum_list+'
					from FM_Original_Full_Adj_'+@division+@Monthfc+' f
					where
						cast(replace(left([Time series],2),''.'','''') as int) IN(1,2,4)
					and f.[SUB GROUP/ Brand] IN(select distinct [SUB GROUP/ Brand] from '+@tablename0+')
					group by
						[SUB GROUP/ Brand],    
						[Channel]
				) t ON T.[SUB GROUP/ Brand]=a.[SUB GROUP/ Brand] and t.Channel=a.Channel
				where     
					cast(replace(left(a.[Time series],2),''.'','''') as int) IN(1,2,4)
			) fm   
			left join  
			(      
				/*exclude bom*/
				select 
					 t.[SUB GROUP/ Brand]
					,t.[Channel]
					,[Time series], '+@Total_Exclude_Bom+'
				from '+@Tablename_original+'_Tmp t
				left join
				(
					select 
						[SUB GROUP/ Brand]
						,[Channel], '+@Total_Listcolumn+'
					from '+@Tablename_original+' f
					where       
						[Time series]=''3. Promo Qty(BOM)''
					and f.[SUB GROUP/ Brand] IN(select distinct [SUB GROUP/ Brand] from '+@tablename0+')
				) t1 on t1.[SUB GROUP/ Brand] = t.[SUB GROUP/ Brand] and t1.Channel=t.Channel
				where       
					t.[Time series]=''6. Total Qty''
				and t.[SUB GROUP/ Brand] IN(select distinct [SUB GROUP/ Brand] from '+@tablename0+')
			) ad on ad.[SUB GROUP/ Brand]=fm.[SUB GROUP/ Brand] and ad.Channel=fm.Channel
		) as f on f.[SUB GROUP/ Brand]=f1.[SUB GROUP/ Brand] and f.Channel=f1.Channel and f.[Time series]=f1.[Time series]
		where  
			cast(replace(left(f1.[Time series],2),''.'','''') as int) IN(1,2,4)
		and f1.Channel NOT IN(''O+O'')
		and f1.[SUB GROUP/ Brand] IN(select distinct [SUB GROUP/ Brand] from '+@tablename0+')
		and trim(f1.[SUB GROUP/ Brand])+''*''+trim(F.CHANNEL) NOT IN   
		(    
			select DISTINCT     
				trim([SUB GROUP/ Brand])+''*''+trim(Channel)   
			from fc_config_wf_total_custom
			WHERE 
				[Division]='''+@division+'''
			and [FM_KEY]='''+@FM_KEY+'''
		) '

		if @debug>0
		begin
			select @sql 'Create new table_tyle_tmp'
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
	if @n_continue=1
	begin
		select @sql=
		'update '+@Tablename_original+'
			set '+
			@listcolumn_backup+'			
		from '+@Tablename_original+' f
		Inner Join
		(
			select
				 [SUB GROUP/ Brand]=f.[SUB GROUP/ Brand]
				,[Channel]=f.[Channel]
				,[Time series]=f.[Time series], '
				+@Total_Plus_remainder+'
			from '+@table_tyle_tmp+' f
			left join
			(
				select distinct 
					[Product status],
					[SUB GROUP/ Brand]
				from fnc_SubGroupMaster('''+@division+''',''full'')
			) s on s.[SUB GROUP/ Brand]=f.[SUB GROUP/ Brand]
			left join
			(
				select
					f1.[SUB GROUP/ Brand]
					,f1.[Channel], '+
					@Total_remainder+'
				from '+@table_tyle_tmp+' f1
				left join
				(
					select 
						t.[SUB GROUP/ Brand]
						,t.[Channel], '+
						@Total_Sum_minus_bom+'
					from '+@Tablename_original+'_Tmp t
					left join
					(
						select 
							[SUB GROUP/ Brand]
							,[Channel], '+@Total_Listcolumn+'
						from '+@Tablename_original+' f
						where       
							[Time series]=''3. Promo Qty(BOM)''
						and [SUB GROUP/ Brand] IN(select distinct [SUB GROUP/ Brand] from '+@tablename0+')
					) t1 on t1.[SUB GROUP/ Brand]=t.[SUB GROUP/ Brand] and t1.Channel=t.Channel
					where       
						t.[Time series]=''6. Total Qty''
					and t.[SUB GROUP/ Brand] IN(select distinct [SUB GROUP/ Brand] from '+@tablename0+')
					group by
						t.[SUB GROUP/ Brand]
						,t.[Channel]
				) t1 on t1.[SUB GROUP/ Brand]=f1.[SUB GROUP/ Brand] and t1.Channel=f1.Channel
				WHERE F1.[SUB GROUP/ Brand] IN(select distinct [SUB GROUP/ Brand] from '+@tablename0+')
				group by
					f1.[SUB GROUP/ Brand]
					,f1.[Channel], '+@Total_groupbycalcol+'
			) t on t.[SUB GROUP/ Brand] = f.[SUB GROUP/ Brand] and t.Channel=f.Channel
			where f.[SUB GROUP/ Brand] IN(select distinct [SUB GROUP/ Brand] from '+@tablename0+')
			group by
			 s.[Product status]
			,f.[SUB GROUP/ Brand]     
			,f.[Channel]
			,f.[Time series]
		) x On x.[SUB GROUP/ Brand]=f.[SUB GROUP/ Brand] and x.[Channel]=f.[Channel] and x.[Time series]=f.[Time series] '

		if @debug>0
		begin
			select @sql 'Update with case total'
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