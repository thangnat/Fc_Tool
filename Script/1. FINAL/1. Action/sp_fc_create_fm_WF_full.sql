/*
	declare 
		@b_Success			Int,
		@c_errmsg			Nvarchar(250)

	exec sp_fc_create_fm_WF_full 'LLD','202410',@b_Success OUT, @c_errmsg OUT

	select @b_Success b_Success, @c_errmsg c_errmsg

	select * from fc_fm_wf_full_CPD_202407
*/
Alter proc sp_fc_create_fm_WF_full
	@Division		nvarchar(3),
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
		@sp_name = 'sp_fc_create_fm_WF_full',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	select @debug=debug from fnc_debug('FC')

	declare @Monthfc				nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from V_FC_FM_Table

	if @n_continue=1
	begin
		declare @tablename nvarchar(100)=''
		select @tablename='fc_fm_wf_full_'+@Division+@Monthfc

		declare @listcolumn nvarchar(max) = ''
		SELECT @listcolumn = ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'FM_OriginalFull','')
		--SELECT listcolumn = ListColumn FROM fn_FC_GetColheader_Current('202406','FM_OriginalFull','')
	
		declare @listcolumn2 nvarchar(max) = ''
		SELECT @listcolumn2 = ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'FM_OriginalFull','f')
		--SELECT listcolumn2 = ListColumn FROM fn_FC_GetColheader_Current('202405','FM_OriginalFull','f')
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
				select @sql '@sql drop table'
			end
			execute(@sql)
		end

		select @sql	='
		select
			*
			INTO '+@tablename+'
		from
		(
			select
				*
			from
			(
				select 
					[TableName] = ''FM1'',
					[SUB GROUP/ Brand] = s.[SUB GROUP/ Brand],
					[Channel] = f.[Local Level],
					[Time series] = t.MAP,
					[Country Status] = f.[Country Status],'
					+@listcolumn+'
				from FC_FM_'+@Division+@Monthfc+' f
				inner join 
				(
					SELECT DISTINCT
						[Material],
						[SUB GROUP/ Brand],
						[Item Category Group]
					From fnc_SubGroupMaster('''+@Division+''',''full'') 
				) s on s.Material = f.[SKU Code] 
				left join (select * from V_FC_TIME_SERIES) t on t.TimeSeries = f.[Time series]
				where 
					isnull(f.[Sku Code],'''')<>'''' 
				and f.[Local Level] = ''OFFLINE''
				and s.[Item Category Group]<>''LUMF''
				group by
					f.[Local Level],
					t.MAP,
					s.[SUB GROUP/ Brand],
					f.[Country Status]
				union all 
				select 
					[TableName] = ''FM1'',
					[SUB GROUP/ Brand] = s.[SUB GROUP/ Brand],
					[Channel] = f.[Local Level],
					[Time series] = t.MAP,
					[Country Status] = f.[Country Status],'
					+@listcolumn+'
				from FC_FM_'+@Division+@Monthfc+' f
				inner join 
				(
					select DISTINCT
						[Material],
						[SUB GROUP/ Brand],
						[Item Category Group]
					from fnc_SubGroupMaster('''+@Division+''',''full'')
				) s on s.Material = f.[SKU Code] 
				left join (select * from V_FC_TIME_SERIES) t on t.TimeSeries = f.[Time series]
				where 
					isnull(f.[Sku Code],'''')<>'''' 
				and t.map not in(''5. FOC Qty'',''6. Total Qty'',''3. Promo Qty(BOM)'')
				and f.[Local Level] = ''ONLINE''
				and s.[Item Category Group]<>''LUMF''
				group by
					f.[Local Level],
					t.MAP,
					s.[SUB GROUP/ Brand],
					f.[Country Status]
			) as x
		) as x1 '
		IF @debug>0
		BEGIN
			SELECT @sql '@sql insert table'
		END
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