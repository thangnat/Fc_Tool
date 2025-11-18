/*
	Declare 
		@b_Success		Int,
		@c_errmsg		Nvarchar(250)

	exec sp_get_List_subgrp_Changed 'CPD','202407','Show_Total_Selected',@b_Success OUT,@c_errmsg OUT

	select @b_Success b_Success,@c_errmsg c_errmsg
*/

Alter Proc sp_get_List_subgrp_Changed
	@Division				nvarchar(3),
	@FM_KEY					nvarchar(6),
	@Type					nvarchar(50),--//Show_Total_Selected/Show_All_Selected
	@b_Success				Int				OUTPUT,     
	@c_errmsg				Nvarchar(250)	OUTPUT
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
		@sp_name = 'sp_get_List_subgrp_Changed',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()
	
	select @debug=debug from fnc_debug('FC')
	--select @debug=1

	declare @Monthfc				nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from V_FC_FM_Table

	declare @Tablename_original				nvarchar(200) = ''
	select @Tablename_original ='FC_FM_Original_'+@division+@Monthfc

	declare @tablename0 nvarchar(100)=''
	select @tablename0='fc_list_forecasting_line_update_'+HOST_NAME()

	if @debug>0
	begin
		select 'get list subgrp changed',@tablename0 '@tablename0',@Tablename_original '@Tablename_original'
	end
	if @n_continue=1
	begin
		declare @Total_list_change nvarchar(max)=''
		SELECT @Total_list_change=ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'Total_list_change','f')
		--SELECT Total_list_change=ListColumn FROM fn_FC_GetColheader_Current('202407','Total_list_change','f')

		declare @total_sum_list nvarchar(max)=''
		SELECT @total_sum_list=ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'BomheaderQty','f')
		--SELECT total_sum_list=ListColumn FROM fn_FC_GetColheader_Current('202407','BomheaderQty','f')

		declare @listcolumn_plus nvarchar(max)=''
		SELECT @listcolumn_plus=ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'1. Baseline Qty_+','f')
		--SELECT listcolumn_plus=ListColumn FROM fn_FC_GetColheader_Current('202407','1. Baseline Qty_+','f')
	end
	
	if @debug>0
	begin
		select 'create table subgrp changed',@n_continue '@n_continue'
	end
	if @n_continue=1
	begin
		if exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID(@tablename0) AND type in (N'U')
		)
		begin
			select @sql='Drop table '+@tablename0

			if @debug>0
			begin
				select @sql 'Drop table fc_list_forecasting_line_update_'
			end
			execute(@sql)
		end
		
		if @Type='Show_Total_Selected'
		begin
			select @sql=
			'select
				[SUB GROUP/ Brand],
				[Channel]
				into '+@tablename0+'
			from
			(
				select
					 f.[SUB GROUP/ Brand]
					,f.[Channel],'+
					@Total_list_change+'
				from
				(
					select
						*
					from
					(
						select
							[SUB GROUP/ Brand],
							[Channel],'+
							@total_sum_list+'
						from '+@Tablename_original+' f
						where 
							[Time series] IN(''1. Baseline Qty'',''2. Promo Qty(Single)'',''4. Launch Qty'',''3. Promo Qty(BOM)'')
						/*and [SUB GROUP/ Brand]=''GLYCO BRIT SERUM 7.5ML PLV YSM2''*/
						and [Channel] NOT IN(''O+O'')
						and [Product type]=''YFG''
						/*and 
						(
							'+@listcolumn_plus+'
						)<>0*/ '
			select @sql1=
						'group by
							[SUB GROUP/ Brand],
							[Channel]
						union all
						select
							[SUB GROUP/ Brand],
							[Channel],'+
							@total_sum_list+'
						from '+@Tablename_original+' f
						where 
							[Time series] IN(''1. Baseline Qty'',''2. Promo Qty(Single)'',''4. Launch Qty'',''3. Promo Qty(BOM)'',''5. FOC Qty'')
						/*and [SUB GROUP/ Brand]=''GLYCO BRIT SERUM 7.5ML PLV YSM2''*/
						and [Channel] NOT IN(''O+O'')
						and [Product type]<>''YFG''
						/*and 
						(
							'+@listcolumn_plus+'
						)<>0*/
						group by
							[SUB GROUP/ Brand],
							[Channel]
					) as f1
		
				)  f
				inner join
				(
					select
						*
					from '+@Tablename_original+'_Tmp f
					where 
						[Time series]=''6. Total Qty''
					/*and (
							'+@listcolumn_plus+'
						)<>0*/
				) t on t.[SUB GROUP/ Brand]=f.[SUB GROUP/ Brand] and t.Channel=f.Channel
			) as x
			/*where 
			[SUB GROUP/ Brand]=''REVITALIFT NIGHT CREAM 50ML''and
			(
				'+replace(@listcolumn_plus,'f.','x.')+'
			)<>0*/ '

			if @debug>0
			begin
				select @sql+@sql1 'Get list subgrp changed',len(@sql) 'len_sql',len(@sql1) 'len_sql1'
			end
			execute(@sql+@sql1)
		end
		
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