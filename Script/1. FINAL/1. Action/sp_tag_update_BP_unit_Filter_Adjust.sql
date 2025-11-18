/*
	Declare 
		@b_Success				Int,
		@c_errmsg				Nvarchar(250)

	exec sp_tag_update_BP_unit_Filter_Adjust 'CPD','202408',@b_Success OUT, @c_errmsg OUT

	select @b_Success b_Success, @c_errmsg c_errmsg
*/

Alter Proc sp_tag_update_BP_unit_Filter_Adjust
	@Division		nvarchar(3),
	@FM_KEY			nvarchar(6),
	@b_Success		Int				OUTPUT,     
	@c_errmsg		Nvarchar(250)	OUTPUT
As
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
			
	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_tag_update_BP_unit',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	select @debug=debug from fnc_debug('FC')

	declare @Monthfc				nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from V_FC_FM_Table

	declare @FC_FM_Original			nvarchar(100) = ''
	select @FC_FM_Original = 'FC_FM_Original_'+@Division+@Monthfc

	declare @list_set_zero nvarchar(max)=''
	SELECT @list_set_zero=ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'Set_0','b')
	--SELECT list_set_zero=ListColumn FROM fn_FC_GetColheader_Current('202406','Set_0','b')

	--select 'OK 1.1.1.1'
	begin tran
	if @n_continue = 1
	begin
		if @debug>0
		begin		
			select '@n_continue 1.10B'=@n_continue,tablename = 'Update BP unit'
		end
		--//Update new Launch Forecast
		declare @listcol_BP nvarchar(max) = ''
		declare @listcol_BP_GAP_Unit nvarchar(max) = ''
		declare @listcol_BP_GAP_Percent nvarchar(max) = ''

		declare @listcolumn_full nvarchar(max) = ''
		SELECT @listcolumn_full = ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'FM_OriginalwfFull','si')
		--SELECT listcolumn_full = ListColumn FROM fn_FC_GetColheader_Current('202406','FM_OriginalwfFull','si')

		SELECT @listcol_BP = ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'updateForecast','si')
		--SELECT listcol_BP = ListColumn FROM fn_FC_GetColheader_Current('202407','updateForecast','si')

		SELECT @listcol_BP_GAP_Unit = ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'update_bp_gap_u','si')
		--SELECT listcol_BP_GAP_Unit = ListColumn FROM fn_FC_GetColheader_Current('202406','update_bp_gap_u','')

		SELECT @listcol_BP_GAP_Percent = ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'update_bp_gap_%','si')
		--SELECT listcol_BP_GAP_Percent = ListColumn FROM fn_FC_GetColheader_Current('202406','update_bp_gap_%','si')

		if @Division<>'LDB'
		begin
			select @sql=
			'update '+@FC_FM_Original
			+' set '+@list_set_zero
			+' where [Time series] IN(''7. BP Unit'')'
			if @debug>0
			begin
				select @sql '@sql set zero <> LDB'
			end
			execute(@sql)
		end
		else
		begin
			select @sql=
			'update '+@FC_FM_Original
			+' set '+@list_set_zero
			+' where [Time series] IN(''7. BP Unit'',''7.1. BP Unit Offline'',''7.2. BP Unit Medical'')'

			if @debug>0
			begin
				select @sql '@sql set zero LDB'
			end
			execute(@sql)
		end
		--//ONLINE
		if @Division<>'LDB'
		begin
			select @sql = 
			'update '+@FC_FM_Original+'
			set '+@listcol_BP+'
			from '+@FC_FM_Original+' f
			Inner join 
			(
				SELECT
					*
				FROM FC_BP_SI_ONLINE_'+@Division+@Monthfc+' si
			) si on 
				si.[Product Type]=f.[Product Type]
			and si.[SUB GROUP/ Brand]=f.[SUB GROUP/ Brand]
			and si.Channel=f.[Channel]
			and f.[Time series]=''7. BP Unit''
			and f.Channel=''ONLINE'' '

			if @debug>0
			begin
				select @sql '@sql Update bp online'
			end
			execute(@sql)
		end
		else
		begin

			select @sql = 
			'update '+@FC_FM_Original+'
			set '+@listcol_BP+'
			from '+@FC_FM_Original+' f
			Inner join 
			(
				SELECT
					*
				FROM FC_BP_SI_ONLINE_'+@Division+@Monthfc+' si
			) si on 
				si.[Product Type]=f.[Product Type]
			and si.[SUB GROUP/ Brand]=f.[SUB GROUP/ Brand]
			and si.Channel=f.[Channel]
			and f.[Time series] IN(''7.1. BP Unit Offline'',''7.2. BP Unit Medical'')
			and f.Channel=''ONLINE'' '

			if @debug>0
			begin
				select @sql '@sql Update bp online'
			end
			execute(@sql)
		end

		--//OFFLINE
		if @Division<>'LDB'
		begin
			select @sql = 
			'update '+@FC_FM_Original+'
			set '+@listcol_BP+'
			from '+@FC_FM_Original+' f
			Inner join 
			(
				SELECT
					*
				FROM FC_BP_SI_OFFLINE_'+@Division+@Monthfc+' si
			) si on 
				si.[Product Type]=f.[Product Type]
			and si.[SUB GROUP/ Brand]=f.[SUB GROUP/ Brand]
			and si.Channel=f.[Channel]
			and f.[Time series]=''7. BP Unit''
			and f.Channel=''OFFLINE'' '

			if @debug>0
			begin
				select @sql '@sql Update bp offline'
			end
			execute(@sql)
		end
		else
		begin
			--//offline normal
			select @sql = 
			'update '+@FC_FM_Original+'
			set '+@listcol_BP+'
			from '+@FC_FM_Original+' f
			Inner join 
			(
				SELECT
					*
				FROM FC_BP_SI_OFFLINE_'+@Division+@Monthfc+'
				where [Time series] IN(''7.1. BP Unit Offline'')
			) si on 
				si.[Product Type]=f.[Product Type]
			and si.[SUB GROUP/ Brand]=f.[SUB GROUP/ Brand]
			and si.Channel=f.[Channel]
			and si.[Time series]=f.[Time series]
			and f.Channel=''OFFLINE'' '

			if @debug>0
			begin
				select @sql '@sql Update bp offline normal'
			end
			execute(@sql)

			--//offline medical
			select @sql = 
			'update '+@FC_FM_Original+'
			set '+@listcol_BP+'
			from '+@FC_FM_Original+' f
			Inner join 
			(
				SELECT
					*
				FROM FC_BP_SI_OFFLINE_'+@Division+@Monthfc+' 
				where [Time series] IN(''7.2. BP Unit Medical'')
			) si on 
				si.[Product Type]=f.[Product Type]
			and si.[SUB GROUP/ Brand]=f.[SUB GROUP/ Brand]
			and si.Channel=f.[Channel]
			and si.[Time series]=f.[Time series]
			and f.Channel=''OFFLINE'' '

			if @debug>0
			begin
				select @sql '@sql Update bp offline medical'
			end
			execute(@sql)

			--//total: offline medical+offline normal
			select @sql = 
			'update '+@FC_FM_Original+'
			set '+@listcol_BP+'
			from '+@FC_FM_Original+' f
			Inner join 
			(
				SELECT
					[Product Type],   
					[SUB GROUP/ Brand],   
					[Channel],'
					+@listcolumn_full+'
				FROM '+@FC_FM_Original+' si
				where 
					Channel=''OFFLINE'' 
				and [Time series] IN(''7.1. BP Unit Offline'',''7.2. BP Unit Medical'')
				group by
					[Product Type],   
					[SUB GROUP/ Brand],   
					[Channel]
			) si on 
				si.[Product Type]=f.[Product Type]
			and si.[SUB GROUP/ Brand]=f.[SUB GROUP/ Brand]
			and si.Channel=f.[Channel]
			and f.[Time series] IN(''7. BP Unit'')
			and f.Channel=''OFFLINE'' '

			if @debug>0
			begin
				select @sql '@sql Update bp offline total'
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
	--bp data
	if @n_continue=1
	begin
		--//gap unit
		select @sql = 
		'update '+@FC_FM_Original+'
		set
			'+@listcol_BP+'
		from '+@FC_FM_Original+' f
		inner join
		(
			select 
				f.[Product Type],   
				f.[SUB GROUP/ Brand],  
				f.[Channel],    
				[Time series]=''8. BP vs FC (u)'','
				+@listcol_BP_GAP_Unit+'
			from 
			(
				select
					[Product Type],   
					[SUB GROUP/ Brand],   
					[Channel],   
					[Time series],'
					+@listcol_BP+'
				from '+@FC_FM_Original+' si
				where Channel<>''O+O''
				and [Time series]=''6. Total Qty''
			) f  
			left join    
			(  
				SELECT  
					[Product Type],   
					[SUB GROUP/ Brand],   
					[Channel],   
					[Time series], '   
					+@listcol_BP+'
				FROM '+@FC_FM_Original+' si   
				where [Channel]<>''O+O''   
				and [Time series]=''7. BP Unit'' 
			) bp on 
				bp.[Product Type]=f.[Product Type]   
			and bp.[SUB GROUP/ Brand]=f.[SUB GROUP/ Brand]  
			and bp.Channel=f.[Channel]
			and f.[Channel]<>''O+O''
		) as si on 
			si.Channel = f.Channel
		and si.[SUB GROUP/ Brand]=f.[SUB GROUP/ Brand]
		and si.[Product type]=f.[Product type]
		and f.[Time series]=''8. BP vs FC (u)'' '
		/*and f.[SUB GROUP/ Brand]=''AGE REWIND CONCEALER''*/

		if @debug>0
		begin
			select @sql '@sql Update bp vs fc gap unit'
		end
		execute(@sql)

		--//gap %
		select @sql = 
		'update '+@FC_FM_Original+'
		set
			'+@listcol_BP+'
		from '+@FC_FM_Original+' f
		inner join
		(
			select 
				f.[Product Type],   
				f.[SUB GROUP/ Brand],  
				f.[Channel],    
				[Time series]=''9. BP vs FC (%)'','
				+@listcol_BP_GAP_Percent+'
			from 
			(
				select
					[Product Type],   
					[SUB GROUP/ Brand],   
					[Channel],   
					[Time series],'
					+@listcol_BP+'
				from '+@FC_FM_Original+' si
				where [Time series]=''6. Total Qty''
				and Channel<>''O+O''
			) f  
			left join    
			(  
				SELECT  
					[Product Type],   
					[SUB GROUP/ Brand],   
					[Channel],   
					[Time series], '   
					+@listcol_BP+'
				FROM '+@FC_FM_Original+' si   
				where [Channel]<>''O+O''   
				and [Time series]=''8. BP vs FC (u)'' 
			) bp on 
				bp.[Product Type]=f.[Product Type]   
			and bp.[SUB GROUP/ Brand]=f.[SUB GROUP/ Brand]  
			and bp.Channel=f.[Channel]
			and f.[Channel]<>''O+O''
		) as si on 
			si.Channel = f.Channel
		and si.[SUB GROUP/ Brand]=f.[SUB GROUP/ Brand]
		and si.[Product type]=f.[Product type]
		and f.[Time series]=''9. BP vs FC (%)'' '

		if @debug>0
		begin
			select @sql '@sql Update bp vs fc gap %'
		end
		execute(@sql)
	end
	--fm data
	if @n_continue=1
	begin
		--//gap FM unit
		select @sql = 
		'update '+@FC_FM_Original+'
		set
			'+@listcol_BP+'
		from '+@FC_FM_Original+' f
		inner join
		(
			select 
				f.[Product Type],   
				f.[SUB GROUP/ Brand],  
				f.[Channel],    
				[Time series]=''11. FM vs FC (u)'','
				+@listcol_BP_GAP_Unit+'
			from 
			(
				select
					[Product Type],   
					[SUB GROUP/ Brand],   
					[Channel],   
					[Time series],'
					+@listcol_BP+'
				from '+@FC_FM_Original+' si
				where [Time series]=''1. Baseline Qty''
				and Channel<>''O+O''
			) f  
			left join    
			(  
				SELECT  
					[Product Type],   
					[SUB GROUP/ Brand],   
					[Channel],   
					[Time series], '   
					+@listcol_BP+'
				FROM '+@FC_FM_Original+' si 
				where [Channel]<>''O+O''   
				and [Time series]=''10. Original FM (u)'' 
			) bp on 
				bp.[Product Type]=f.[Product Type]   
			and bp.[SUB GROUP/ Brand]=f.[SUB GROUP/ Brand]  
			and bp.Channel=f.[Channel]
			and f.[Channel]<>''O+O''
		) as si on 
			si.Channel = f.Channel
		and si.[SUB GROUP/ Brand]=f.[SUB GROUP/ Brand]
		and si.[Product type]=f.[Product type]
		and f.[Time series]=''11. FM vs FC (u)'' '
		/*and f.[SUB GROUP/ Brand]=''AGE REWIND CONCEALER''*/

		if @debug>0
		begin
			select @sql '@sql Update fm vs fc gap unit'
		end
		execute(@sql)
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