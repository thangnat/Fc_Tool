/*
	declare 
		@b_Success		Int,
		@c_errmsg		Nvarchar(250)

	exec sp_SO_HIS_validate_mismatch 'PPD','202410',@b_Success OUT, @c_errmsg OUT

	select @b_Success b_Success, @c_errmsg c_errmsg

	select * from fc_validate_mismatch_si_his_fc
*/

Alter proc sp_SO_HIS_validate_mismatch
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
		,@sql1					nvarchar(max) = ''
		,@sql2					nvarchar(max) = ''

	declare 
		@b_Success1				Int,
		@c_errmsg1				Nvarchar(250)

	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_SO_HIS_validate_mismatch',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	select @debug=debug from fnc_Debug('FC')	
	--select @debug=1

	declare @Monthfc			nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from V_FC_FM_Table

	declare @list_product_type	nvarchar(20)=''
	declare @ColumnRelationShip nvarchar(20)=''
	declare @ColumnCompare		nvarchar(50)=''
	declare @FunctionName		nvarchar(50)='SO_HIS'
	declare @Type				nvarchar(50)='MasterData'

	declare @table_Name		nvarchar(300)=''
	select @table_Name='fc_validate_mismatch_si_his_fc'

	declare @list_column_so_his nvarchar(max)=''
	select @list_column_so_his=ListColumn from fn_FC_GetColHeader_Historical(@FM_KEY,'si',102)
	--select list_column_so_his=ListColumn from fn_FC_GetColHeader_Historical('202407','si',102)

	declare @listcolumn_set_0 nvarchar(max)=''
	SELECT @listcolumn_set_0=ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'ErrorAlert_set0','')
	--SELECT listcolumn_set_0=ListColumn FROM fn_FC_GetColheader_Current('202407','ErrorAlert_set0','')

	if @debug>0
	begin
		select 'SO HIS vs MasterData'
	end
	if @n_continue=1
	begin
		select @FunctionName='SO_HIS',@Type='MasterData'
		
		select @sql=
		'Delete '+@table_Name+' 
		where 
			[Division]='''+@Division+''' 
		and [FM_KEY]='''+@FM_KEY+'''
		and [Function Name]='''+@FunctionName+'''
		and [Type Name]='''+@Type+''' '

		if @debug>0
		begin
			select 'Delete table Name'
		end
		execute(@sql)

		select @sql=
		'INSERT INTO '+@table_Name+'
		select 
			*
		from
		(
			select
				[Division],
				[FM_KEY],
				[Function Name],
				[Type Name],
				[SUB GROUP/ Brand],
				[Channel],
				[Time series],
				[EAN Code],
				[SKU Code],'+
				@list_column_so_his+','+@listcolumn_set_0+'
			from
			(
				SELECT
					[Division],
					[FM_KEY]='''+@FM_KEY+''',
					[Function Name]='''+@FunctionName+''',
					[Type Name]='''+@Type+''',
					[SUB GROUP/ Brand]=isnull(s.[SUB GROUP/ Brand],''''),
					[Channel],
					[Time series],
					[EAN Code]=ISNULL(f.Barcode,''''),
					[SKU Code]='''',
					[PeriodKey],
					[Pass Column Header] = (
												select replace([Pass],''@'',cast((cast(left([PeriodKey],4) as int)-year(getdate())) as nvarchar(2))) 
												from V_FC_MONTH_MASTER 
												where Month_number=cast(cast(right([PeriodKey],2) as int) as int)
											),
					[SellOut]
				FROM FC_'+@Division+'_SO_HIS_FINAL f
				left join
				(
					select DISTINCT
						[FM_KEY],
						[Barcode],
						[SUB GROUP/ Brand]
					from fnc_SubGroupMaster('''+@division+''',''full'')
					where [Item Category Group]<>''LUMF''
				) s on s.Barcode=f.Barcode
				where 
					ISNULL(s.[SUB GROUP/ Brand],'''')=''''
				and [SellOut]<>0
			) as x
			group by
				[Division],
				[FM_KEY],
				[Function Name],
				[Type Name],
				[SUB GROUP/ Brand],
				[Channel],
				[Time series],
				[EAN Code],
				[SKU Code]
		) as x
		where 
		(
			[Y-2 (u) M1]+[Y-2 (u) M2]+[Y-2 (u) M3]+[Y-2 (u) M4]+[Y-2 (u) M5]+[Y-2 (u) M6]+[Y-2 (u) M7]+[Y-2 (u) M8]+[Y-2 (u) M9]+[Y-2 (u) M10]+[Y-2 (u) M11]+[Y-2 (u) M12]+
			[Y-1 (u) M1]+[Y-1 (u) M2]+[Y-1 (u) M3]+[Y-1 (u) M4]+[Y-1 (u) M5]+[Y-1 (u) M6]+[Y-1 (u) M7]+[Y-1 (u) M8]+[Y-1 (u) M9]+[Y-1 (u) M10]+[Y-1 (u) M11]+[Y-1 (u) M12]+
			[Y0 (u) M1]+[Y0 (u) M2]+[Y0 (u) M3]+[Y0 (u) M4]+[Y0 (u) M5]+[Y0 (u) M6]+[Y0 (u) M7]+[Y0 (u) M8]+[Y0 (u) M9]+[Y0 (u) M10]+[Y0 (u) M11]+[Y0 (u) M12]+
			[Y+1 (u) M1]+[Y+1 (u) M2]+[Y+1 (u) M3]+[Y+1 (u) M4]+[Y+1 (u) M5]+[Y+1 (u) M6]+[Y+1 (u) M7]+[Y+1 (u) M8]+[Y+1 (u) M9]+[Y+1 (u) M10]+[Y+1 (u) M11]+[Y+1 (u) M12]
		)<>0'

		if @debug>0
		begin
			select @sql '@sql insert data'
		end
		execute(@sql)
	end

	if @debug>0
	begin
		select 'Udpate Missing Masterdata'
	end
	if @n_continue=1
	begin
		if exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID(@table_Name) AND type in (N'U')
		)
		begin
			if exists
			(
				SELECT 1
				FROM fc_validate_mismatch_si_his_fc f
				where 
					[Division]=@Division
				and [FM_KEY]=@FM_KEY
			)
			begin
				update fc_error_alert
				set 
					[Status]=isnull([Status],0)+1
				where 
					[Error Name]='Missing Master Data'
				and [Division]=@Division
				and [FM_KEY]=@FM_KEY

				select @n_err = @@ERROR
				if @n_err<>0
				begin				
					select @n_continue = 3
					select @n_err=60002
					select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +ERROR_MESSAGE()+'./ ('+@sp_name+')'
				end
			end
		end
	end

	--if @debug>0
	--begin
	--	select 'Udpate Missing BOM_vs_masterbom,BOM_vs_masterdata'
	--end
	--if @n_continue=1
	--begin
	--	if exists(select 1 from fnc_fc_validate_mismatch(@Division,@FM_KEY,@FunctionName,'BOM_vs_masterbom,BOM_vs_masterdata'))
	--	begin
	--		update fc_error_alert
	--		set 
	--			[Status]=isnull([Status],0)+1
	--		where 
	--			[Error Name]='Missing BOM'
	--		and [Division]=@Division
	--		and [FM_KEY]=@FM_KEY

	--		select @n_err = @@ERROR
	--		if @n_err<>0
	--		begin				
	--			select @n_continue = 3
	--			select @n_err=60002
	--			select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +ERROR_MESSAGE()+'./ ('+@sp_name+')'
	--		end
	--	end
	--end

	--if @debug>0
	--begin
	--	select 'Udpate Missing RSP'
	--end
	--if @n_continue=1
	--begin
	--	if exists(select 1 from fnc_fc_validate_mismatch(@Division,@FM_KEY,@FunctionName,'RSP'))
	--	begin
	--		update fc_error_alert
	--		set 
	--			[Status]=isnull([Status],0)+1
	--		where 
	--			[Error Name]='Missing RSP'
	--		and [Division]=@Division
	--		and [FM_KEY]=@FM_KEY

	--		select @n_err = @@ERROR
	--		if @n_err<>0
	--		begin				
	--			select @n_continue = 3
	--			select @n_err=60002
	--			select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +ERROR_MESSAGE()+'./ ('+@sp_name+')'
	--		end
	--	end
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