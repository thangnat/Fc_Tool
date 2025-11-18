/*
	declare 
		@b_Success				Int,
		@c_errmsg				Nvarchar(250)

	exec sp_tag_update_wf_FM_Non_Modeling_unit 'LLD','202409',@b_Success OUT, @c_errmsg OUT

	select @b_Success b_Success, @c_errmsg c_errmsg
*/

Alter Proc sp_tag_update_wf_FM_Non_Modeling_unit
	@Division				nvarchar(3),
	@FM_KEY					nvarchar(6),
	@b_Success				Int				OUTPUT,     
	@c_errmsg				Nvarchar(250)	OUTPUT
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
		@sp_name = 'sp_tag_update_wf_FM_Non_Modeling_unit',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	select @debug=debug from fnc_Debug('FC')
	--select @debug=1

	declare @Monthfc				nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from V_FC_FM_Table
	
	declare @allow_set_zero			int=0
	
	declare @FC_FM_Original			nvarchar(100) = ''
	select @FC_FM_Original = 'FC_FM_Original_'+@Division+@Monthfc

	declare @list_signature nvarchar(500)=''
	declare @Type_View nvarchar(20)=''

	if @debug>0
	begin
		select 'get signature run'
	end
	if @n_continue=1
	begin
		select 
			@list_signature=[List_Signature],
			@Type_View=[type_View] 
		from fnc_get_List_Signature('tag_gen_fm_non_modeling')
		--and Tag_name='tag_gen_fm_non_modeling'

		if @list_signature is null
		begin
			select @list_signature=''
		end
		if @Type_View is null
		begin
			select @Type_View=''
		end
	end
	if @n_continue=1
	begin
		if @Type_View='re-gen'
		begin
			if @list_signature=''
			begin
					select @n_continue = 3
				select @n_err=60001
				select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +':Signature should be not null./ ('+@sp_name+')'
			end
		end
	end	

	if @n_continue = 1
	begin
		if @debug>0
		begin		
			select '@n_continue 1.10B'=@n_continue,tablename = 'Update FM Non Modeling Unit Forecast'
		end
		declare @ListColumn_set_zero	nvarchar(max) = ''
		SELECT @ListColumn_set_zero= ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'Set_0','')
		--SELECT ListColumn_set_zero=ListColumn FROM fn_FC_GetColheader_Current('202407','Set_0','')

		--//Update FM forecast
		declare @ListColumn_Sum	nvarchar(max) = ''
		SELECT @ListColumn_Sum = ListColumn FROM fn_FC_GetColheader_Current(@FM_Key,'NonModelling','si')
		--SELECT ListColumn_Sum = ListColumn FROM fn_FC_GetColheader_Current('202409','NonModelling','si')
		
		declare @ListColumn_Current	nvarchar(max) = ''
		SELECT @ListColumn_Current = ListColumn FROM fn_FC_GetColheader_Current(@FM_Key,'1. Baseline Qty','si')
		--SELECT ListColumn_Current = ListColumn FROM fn_FC_GetColheader_Current('202409','1. Baseline Qty','si')

		if @Division='LDB'
		begin
			if not exists(select * from FC_FM_Non_modeling_Final_LDB)
			begin
				select @allow_set_zero=0
			end
			else
			begin
				select @allow_set_zero=1
			end
		end
		else if @Division='LLD'
		begin
			if not exists(select * from FC_FM_Non_modeling_Final_LLD)
			begin
				select @allow_set_zero=0
			end
			else
			begin
				select @allow_set_zero=1
			end
		end
		if @Division='CPD'
		begin
			if not exists(select * from FC_FM_Non_modeling_Final_CPD)
			begin
				select @allow_set_zero=0
			end
			else
			begin
				select @allow_set_zero=1
			end
		end
		
		if @allow_set_zero>0
		begin
			if @debug>0
			begin
				select 'Set zero'
			end
			if @Type_View=''
			begin
				select @sql=
				'update FC_FM_Original_'+@Division+@Monthfc+'
					set '+@ListColumn_set_zero+'
				from FC_FM_Original_'+@Division+@Monthfc+' f
				inner join FC_FM_Non_Modeling_Final_'+@Division+@Monthfc+' f1
				on
					f.[Channel]=f1.[Local Level]
				and f.[SUB GROUP/ Brand]=f1.[SUB GROUP/ Brand]
				and f.[Time series]=f1.[Time series]
				where f.[Time series] '+case when @Division='LLD1' then 
								'IN(''1. Baseline Qty'',''2. Promo Qty(Single)'',''4. Launch Qty'',''5. FOC Qty'') and Channel IN(''ONLINE'',''OFFLINE'')'
							else
								'IN(''1. Baseline Qty'') AND Channel IN(''OFFLINE'') '
						end+''
			end
			else
			begin
				select @sql=
				'update FC_FM_Original_'+@Division+@Monthfc+'
					set '+@ListColumn_set_zero+'
				from FC_FM_Original_'+@Division+@Monthfc+' f
				inner join FC_FM_Non_Modeling_Final_'+@Division+@Monthfc+' f1 
				on 
					f.[Channel]=f1.[Local Level]
				and f.[SUB GROUP/ Brand]=f1.[SUB GROUP/ Brand]
				and f.[Time series]=f1.[Time series]
				where f.[Time series] '+case when @Division='LLD1' then 
								'IN(''1. Baseline Qty'',''2. Promo Qty(Single)'',''4. Launch Qty'',''5. FOC Qty'') 
								and f.[Channel] IN(''ONLINE'',''OFFLINE'')'
							else
								'IN(''1. Baseline Qty'') 
								and f.[Channel] IN(''OFFLINE'') 
								and f.[Signature] IN(select value from string_split('''+@list_signature+''','',''))'
						end+''
			end

			if @debug>0
			begin
				select @sql '@sql set zero'
			end
			execute(@sql)		

			if @debug>0
			begin
				select 'Update FM Forecast'
			end
			if @Type_View=''
			begin
				select @sql = 
				'update '+@FC_FM_Original+'
				set '+@ListColumn_Current+'
				from '+@FC_FM_Original+' f
				Inner JOIN 
				(
					select
						[SUB GROUP/ Brand],
						[Local Level],
						[Time series],'+
						@ListColumn_Sum+'
					from FC_FM_Non_modeling_Final_'+@Division+@Monthfc+' si
					group by
						[SUB GROUP/ Brand],
						[Local Level],
						[Time series]
				) si on 
					si.[SUB GROUP/ Brand] = f.[SUB GROUP/ Brand] 
				AND si.[Local Level] = f.[Channel] 
				and si.[Time series] = f.[Time series] 
				where f.[Time series] '+case when @Division='LLD1' then 
								'IN(''1. Baseline Qty'',''2. Promo Qty(Single)'',''4. Launch Qty'',''5. FOC Qty'') 
								and Channel IN(''ONLINE'',''OFFLINE'')'
							else
								'IN(''1. Baseline Qty'') AND Channel IN(''OFFLINE'') '
						end+''
			end
			else
			begin
				select @sql = 
				'update '+@FC_FM_Original+'
				set '+@ListColumn_Current+'
				from '+@FC_FM_Original+' f
				Inner JOIN 
				(
					select
						[SUB GROUP/ Brand],
						[Local Level],
						[Time series],'+
						@ListColumn_Sum+'
					from FC_FM_Non_modeling_Final_'+@Division+@Monthfc+' si
					group by
						[SUB GROUP/ Brand],
						[Local Level],
						[Time series]
				) si on 
					si.[SUB GROUP/ Brand] = f.[SUB GROUP/ Brand] 
				AND si.[Local Level] = f.[Channel] 
				and si.[Time series] = f.[Time series] 
				where f.[Time series] '+case when @Division='LLD1' then 
								'IN(''1. Baseline Qty'',''2. Promo Qty(Single)'',''4. Launch Qty'',''5. FOC Qty'') 
								and f.[Channel] IN(''ONLINE'',''OFFLINE'')'
							else
								'IN(''1. Baseline Qty'')
								and f.[Channel] IN(''OFFLINE'')
								and f.[Signature] IN(select value from string_split('''+@list_signature+''','',''))'
						end+''
			end

			if @debug>0
			begin
				select @sql 'Update FM Forecast'
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
	end	
	--select * from FC_REfresh_WF
	if @n_continue =1
	begin
		update FC_REfresh_WF 
		set [status] = 1 
		where TagName = 'tag_gen_fm_non_modeling'

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