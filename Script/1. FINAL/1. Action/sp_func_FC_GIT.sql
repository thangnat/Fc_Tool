/*
	Declare 
		@b_Success		Int,
		@c_errmsg		Nvarchar(250)

	exec sp_func_FC_GIT 'LDB','202502',@b_Success OUT,@c_errmsg OUT

	select @b_Success b_Success,@c_errmsg c_errmsg
*/
Alter proc sp_func_FC_GIT
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
		,@sql1					nvarchar(max) = ''

	Declare
		@b_Success1				Int,
		@c_errmsg1				Nvarchar(250)
		
	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_func_FC_GIT',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()
	
	select @debug=debug from fnc_debug('FC')
	--select @debug=1

	declare @Monthfc				nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from V_FC_FM_Table

	declare @tableName			nvarchar(500)=''
	select @tableName='FC_GIT_FINAL_'+@division+@Monthfc+'_Tmp'

	declare @tableName1			nvarchar(500)=''
	select @tableName1='FC_GIT_FINAL_'+@division+@Monthfc+'_Tmp1'
	
	declare @tableName_TMP0		nvarchar(500)='FC_GIT_FINAL_'+@division+@Monthfc+'_month_Tmp0'
	declare @tableName_TMP1		nvarchar(500)='FC_GIT_FINAL_'+@division+@Monthfc+'_month_Tmp1'

	declare @CurrentMonth	int = 0
	
	if @debug>0
	begin
		select 'Drop table @tableName_TMP0'
	end
	if @n_continue=1
	begin
		if exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID(@tableName_TMP0) AND type in (N'U')
		)
		begin
			select @sql ='drop table '+@tableName_TMP0
			if @debug>0
			begin
				select @sql '@sql drop table tmp0'
			end
			execute(@sql)
		end
		if @debug>0
		begin
			select 'create @tableName_TMP0'
		end
		select @sql=
		'create TABLE '+@tableName_TMP0+'
		(
			id				int identity(1,1), 
			[Month]			Int
		)'

		if @debug>0
		begin
			select @sql 'create table tmp0'
		end
		execute(@sql)

		select @sql='
		declare @start_month int = 0
		SELECT @start_month = cast(right('''+@FM_KEY+''',2) as int)
		declare @Total_Month int = 0
		SELECT @Total_Month=@start_month+4-1

		while (@start_month<=@Total_Month)
		begin
			insert into '+@tableName_TMP0+'
			(
				[Month]
			)
			select @start_month

			select @start_month=@start_month+1
		end '

		if @debug>0
		begin
			select 'import tmp0'
		end
		execute(@sql)
	
		--select @sql='select tablename=''@tableName_TMP0'',* from '+@tableName_TMP0
		--execute(@sql)

		select @n_err = @@ERROR
		if @n_err<>0
		begin
			select @n_continue = 3
			--select @n_err=60003
			select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +ERROR_MESSAGE()+'./ ('+@sp_name+')'
		end
	end
	
	if @debug>0
	begin
		select 'drop @tableName_TMP1'
	end
	if @n_continue=1
	begin
		if exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID(@tableName_TMP1) AND type in (N'U')
		)
		begin
			select @sql ='drop table '+@tableName_TMP1
			if @debug>0
			begin
				select @sql '@sql drop table tmp1'
			end
			execute(@sql)
		end
		if @debug>0
		begin
			select 'create table @tableName_TMP1'
		end
		SELECT @sql=
		'create TABLE '+@tableName_TMP1+'
		(
			id				int identity(1,1), 
			[Month_Desc]	nvarchar(2),
			[Month]			Int
		)'
		if @debug>0
		begin
			select @sql 'create tmp1'
		end
		execute(@sql)

		if @debug>0
		begin
			select 'import @tableName_TMP1'
		end
		select @sql='
		insert into '+@tableName_TMP1+'
		(
			[Month_Desc],
			[Month]
		)
		select
			[Month_Desc] = ''M''+cast((id -1) as nvarchar(2)),
			[Month] = t.[Month]
		from '+@tableName_TMP0+' t '

		if @debug>0
		begin
			select @sql 'import tmp1'
		end
		execute(@sql)

		--select @sql='select tablename=''@tableName_TMP1'',* from '+@tableName_TMP1
		--execute(@sql)

		select @n_err = @@ERROR
		if @n_err<>0
		begin
			select @n_continue = 3
			--select @n_err=60003
			select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +ERROR_MESSAGE()+'./ ('+@sp_name+')'
		end
	end

	if @debug>0
	begin
		select 'drop and create table @tableName CPD, LLD, tableName-->LDB'
	end
	if @n_continue=1
	begin
		if @division='LDB123'
		begin
			if @debug>0
			begin
				select 'drop table @tableName1'
			end
			if exists
			(
				SELECT * 
				FROM sys.objects 
				WHERE object_id = OBJECT_ID(@tableName1) AND type in (N'U')
			)
			begin
				select @sql ='drop table '+@tableName1
				if @debug>0
				begin
					select @sql '@sql drop tablename1'
				end
				execute(@sql)
			end
			if @debug>0
			begin
				select 'create table @tableName1'
			end
			select @sql=
			'create TABLE '+@tableName1+'  
			(
				id					int identity(1,1), 
				[Product Type]		nvarchar(10),
				[Sales Org]			nvarchar(4),
				[SUB GROUP/ Brand]	nvarchar(100),
				Channel				nvarchar(7),
				[GIT M0]			int,
				[GIT M1]			Int,
				[GIT M2]			int,
				[GIT M3]			int
			)'
			if @debug>0
			begin
				select 'create table tablename1 LDB'
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
		else
		begin
			if @debug>0
			begin
				select 'drop table @tableName'
			end
			if exists
			(
				SELECT * 
				FROM sys.objects 
				WHERE object_id = OBJECT_ID(@tableName) AND type in (N'U')
			)
			begin
				select @sql ='drop table '+@tableName
				if @debug>0
				begin
					select @sql '@sql drop tablename'
				end
				execute(@sql)
			end

			if @debug>0
			begin
				select 'Create table @tableName'
			end
			select @sql=
			'create TABLE '+@tableName+'  
			(
				[id]				int identity(1,1), 
				[Product Type]		nvarchar(10),
				[Sales Org]			nvarchar(4),
				[SUB GROUP/ Brand]	nvarchar(100),
				Channel				nvarchar(7),
				[GIT M0]			int,
				[GIT M1]			Int,
				[GIT M2]			int,
				[GIT M3]			int
			)'
			if @debug>0
			begin
				select @sql 'create table tablename'
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
	
	if @debug>0
	begin
		select 'import table @tableName -->CPD, LLD, tableName1-->LDB'
	end
	if @n_continue=1
	begin
		if @division='LDB123'
		begin
			select @sql=
			'insert into '+@tableName1+'
			(
				[Product Type],
				[Sales Org],
				[SUB GROUP/ Brand],
				Channel,
				[GIT M0],
				[GIT M1],
				[GIT M2],
				[GIT M3]
			)
			'+case 
				when @division='LDB' then
				'select
					*
				from FC_GIT_More_LDB'+@Monthfc+'
				union All' 
				else '' 
			end+'
			select
				*
			from
			(
				select
					[Product Type],
					[Sales Org],
					[SUB GROUP/ Brand] = x.[SUB GROUP/ Brand],
					Channel = ''OFFLINE'',
					[GIT M0] = sum(case t.[Month_Desc] when ''M0'' then TotalQty else 0 end),
					[GIT M1] = sum(case t.[Month_Desc] when ''M1'' then TotalQty else 0 end),
					[GIT M2] = sum(case t.[Month_Desc] when ''M2'' then TotalQty else 0 end),
					[GIT M3] = sum(case t.[Month_Desc] when ''M3'' then TotalQty else 0 end)
				from 
				(
					select
						id,
						Month_Desc,
						[Month]=case when [Month]>12 then [Month]-12 else [Month] end
						,[Year]=case when [Month_Desc]<>''M0'' and [month]>12 then (year(getdate()))+1 else year(getdate()) end
					from '+@tableName_TMP1+'
				) t
				left join
				(
					select
						[Product Type],
						[Sales Org],
						[SUB GROUP/ Brand],
						[Month],
						[Year],
						[TotalQty] = sum(isnull([TotalQty],0))
					from
					(		
						/*--//LDB----------------------------------------------------------------------------*/
						select
							[Product Type] = s.[Product Type],
							[Sales Org] = s.[Sales Org],
							[SUB GROUP/ Brand] = s.[SUB GROUP/ Brand],				
							[Month] = Month(cast([Deliv# date(From/to)] as date)),
							[Year] = Year(cast([Deliv# date(From/to)] as date)),
							[TotalQty] = [Delivery quantity]
						from FC_GIT_'+@division+@Monthfc+' g (NOLOCK)
						inner join 
						(
							select DISTINCT
								Material,
								Barcode = [EAN / UPC]
							from SC1.dbo.MM_ZMR54OLD_Stg (NOLOCK)
						) m on m.Material = g.Material
						inner join 
						(
							select DISTINCT 
								[Product Type],
								[Type],Barcode,
								[Sales Org],
								[SUB GROUP/ Brand] 
							from fnc_SubGroupMaster('''+@division+''',''full'')
						) s on s.Barcode = m.Barcode
						where 
							cast(format(cast([Deliv# date(From/to)] as date),''yyyyMM'') as numeric)>=cast('''+@FM_KEY+''' as numeric)
						union All
						select
							[Product Type] = s.[Product Type],
							[Sales Org] = s.[Sales Org],
							[SUB GROUP/ Brand] = s.[SUB GROUP/ Brand],				
							[Month] = month(cast((left('''+@FM_KEY+''',4)+''-''+right('''+@FM_KEY+''',2)+''-01'') as date)),
							[Year] = Year(cast((left('''+@FM_KEY+''',4)+''-''+right('''+@FM_KEY+''',2)+''-01'') as date)),
							[TotalQty] = [Delivery quantity]
						from FC_GIT_'+@division+@Monthfc+' g (NOLOCK)
						inner join 
						(
							select DISTINCT
								Material,
								Barcode = [EAN / UPC]
							from SC1.dbo.MM_ZMR54OLD_stg (NOLOCK)
						) m on m.Material = g.Material
						inner join 
						(
							select DISTINCT 
								[Product Type],[Type],Barcode,[Sales Org],[SUB GROUP/ Brand] 
							from fnc_SubGroupMaster('''+@division+''',''full'')
						) s on s.Barcode = m.Barcode
						where 
							cast(format(cast([Deliv# date(From/to)] as date),''yyyyMM'') as numeric)<cast('''+@FM_KEY+''' as numeric)
					) as x1
					group by
						[Product Type],
						[Sales Org],
						[SUB GROUP/ Brand],
						[Month],
						[Year]
				) as x on x.[Month] = t.[Month] and x.[Year]=t.[Year]
				group by
					x.[Product Type],
					x.[Sales Org],
					x.[SUB GROUP/ Brand] 
			) as w
			where isnull(w.[SUB GROUP/ Brand],'''')<>'''' '

			if @debug>0
			begin
				select @sql 'import fc git'
			end
			execute(@sql)

			--select @sql='select tablename=''@tableName1'', * from '+@tableName1
			--execute(@sql)

			select @n_err = @@ERROR
			if @n_err<>0
			begin
				select @n_continue = 3
				--select @n_err=60003
				select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +ERROR_MESSAGE()+'./ ('+@sp_name+')'
			end
		end
		else if @division='CPD'
		begin
			select @sql='
			insert into '+@tableName+'
			(
				[Product Type],
				[Sales Org],
				[SUB GROUP/ Brand],
				Channel,
				[GIT M0],
				[GIT M1],
				[GIT M2],
				[GIT M3]
			)
			select
				*
			from
			(
				select
					[Product Type],
					[Sales Org],
					[SUB GROUP/ Brand] = x.[SUB GROUP/ Brand],
					Channel = ''OFFLINE'',
					[GIT M0] = sum(case t.[Month_Desc] when ''M0'' then TotalQty else 0 end),
					[GIT M1] = sum(case t.[Month_Desc] when ''M1'' then TotalQty else 0 end),
					[GIT M2] = sum(case t.[Month_Desc] when ''M2'' then TotalQty else 0 end),
					[GIT M3] = sum(case t.[Month_Desc] when ''M3'' then TotalQty else 0 end)
				from 
				(
					select 
						id,
						Month_Desc,
						[Month]=case when [Month]>12 then [Month]-12 else [Month] end
						,[Year]=case when [Month_Desc]<>''M0'' and [month]>12 then (year(getdate()))+1 else year(getdate()) end
					from '+@tableName_TMP1+'
				) t
				left join
				(
					select
						[Product Type],
						[Sales Org],
						[SUB GROUP/ Brand],
						[Month],
						[Year],
						[TotalQty] = sum(isnull([TotalQty],0))
					from
					(
						select
							[Product Type] = s.[Product Type],
							[Sales Org] = s.[Sales Org],
							[SUB GROUP/ Brand] = s.[SUB GROUP/ Brand],				
							[Month] = Month(cast([Deliv# date(From/to)] as date)),
							[Year] = year(cast([Deliv# date(From/to)] as date)),
							[TotalQty] = [Delivery quantity]
						from FC_GIT_'+@division+@Monthfc+' g (NOLOCK)
						inner join 
						(
							select DISTINCT
								Material,
								Barcode = [EAN / UPC]
							from SC1.dbo.MM_ZMR54OLD_Stg (NOLOCK)
						) m on m.Material = g.Material
						inner join 
						(
							select DISTINCT 
								[Product Type],[Type],Barcode,[Sales Org],[SUB GROUP/ Brand] 
							from fnc_SubGroupMaster('''+@division+''',''full'')
						) s on s.Barcode = m.Barcode
						where 
							cast(format(cast([Deliv# date(From/to)] as date),''yyyyMM'') as numeric)>=cast('''+@FM_KEY+''' as numeric)
						union All
						select
							[Product Type] = s.[Product Type],
							[Sales Org] = s.[Sales Org],
							[SUB GROUP/ Brand] = s.[SUB GROUP/ Brand],				
							[Month] = month(cast((left('''+@FM_KEY+''',4)+''-''+right('''+@FM_KEY+''',2)+''-01'') as date)),
							[Year] = Year(cast((left('''+@FM_KEY+''',4)+''-''+right('''+@FM_KEY+''',2)+''-01'') as date)),
							[TotalQty] = [Delivery quantity]
						from FC_GIT_'+@division+@Monthfc+' g (NOLOCK)
						inner join 
						(
							select DISTINCT
								Material,
								Barcode = [EAN / UPC]
							from SC1.dbo.MM_ZMR54OLD_stg (NOLOCK)
						) m on m.Material = g.Material
						inner join 
						(
							select DISTINCT 
								[Product Type],[Type],Barcode,[Sales Org],[SUB GROUP/ Brand] 
							from fnc_SubGroupMaster('''+@division+''',''full'')
						) s on s.Barcode = m.Barcode
						where 
							cast(format(cast([Deliv# date(From/to)] as date),''yyyyMM'') as numeric)<cast('''+@FM_KEY+''' as numeric) 
					) as x1
					group by
						[Product Type],
						[Sales Org],
						[SUB GROUP/ Brand],
						[Month],
						[Year]
				) as x on x.[Month] = t.[Month] and x.[Year]=t.[Year]
				group by
					x.[Product Type],
					x.[Sales Org],
					x.[SUB GROUP/ Brand] 
			) as w
			where isnull(w.[SUB GROUP/ Brand],'''')<>'''' '

			if @debug>0
			begin
				select @sql 'import fc git'
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
		else if @division IN('LLD','PPD','LDB')
		begin			
			select @sql='
			insert into '+@tableName+'
			(
				[Product Type],
				[Sales Org],
				[SUB GROUP/ Brand],
				Channel,
				[GIT M0],
				[GIT M1],
				[GIT M2],
				[GIT M3]
			)
			select
				*
			from
			(
				/*--//LLD*/
				SELECT
					[Product Type],
					[Sales Org],
					[SUB GROUP/ Brand],
					Channel,
					[GIT M0] = SUM(ISNULL([GIT M0],0)),
					[GIT M1] = SUM(ISNULL([GIT M1],0)),
					[GIT M2] = SUM(ISNULL([GIT M2],0)),
					[GIT M3] = SUM(ISNULL([GIT M3],0))
				FROM
				(
					select
						[Product Type] = s.[Product Type],
						[Sales Org] = s.[Sales Org],
						[SUB GROUP/ Brand] = s.[SUB GROUP/ Brand],
						Channel = ''OFFLINE'',			
						[GIT M0] = CAST(isnull(REPLACE([M0],'','',''''),0) AS INT),
						[GIT M1] = CASt(isnull(REPLACE([M1],'','',''''),0) AS INT),
						[GIT M2] = CAST(isnull(REPLACE([M2],'','',''''),0) AS INT),
						[GIT M3] = CAST(isnull(REPLACE([M3],'','',''''),0) AS INT)
					from FC_GIT_'+@division+@Monthfc+' g
					inner join 
					(
						select DISTINCT
							Material,
							Barcode = [EAN / UPC]
						from SC1.dbo.MM_ZMR54OLD (NOLOCK)
					) m on m.Material = g.[Material]
					inner join 
					(
						select DISTINCT 
							[Product Type],[Type],Barcode,[Sales Org],[SUB GROUP/ Brand] 
						from fnc_SubGroupMaster('''+@division+''',''full'')
					) s on s.Barcode = M.Barcode
				) AS Y
				GROUP BY
					[Product Type],
					[Sales Org],
					[SUB GROUP/ Brand],
					Channel
			) as w
			where isnull(w.[SUB GROUP/ Brand],'''')<>'''' '

			if @debug>0
			begin
				select @sql 'import fc git'
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
	
	--if @debug>0
	--begin
	--	select 'import table @tableName-->LDB'
	--end
	--if @n_continue=1
	--begin
	--	if @division='LDB'
	--	begin
	--		if @debug>0
	--		begin
	--			select 'Drop table @tableName-->LDB'
	--		end
	--		if exists
	--		(
	--			SELECT * 
	--			FROM sys.objects 
	--			WHERE object_id = OBJECT_ID(@tableName) AND type in (N'U')
	--		)
	--		begin
	--			select @sql ='drop table '+@tableName
	--			if @debug>0
	--			begin
	--				select @sql '@sql drop tablename'
	--			end
	--			execute(@sql)
	--		end
	--		if @debug>0
	--		begin
	--			select 'Create table @tableName-->LDB'
	--		end
	--		select @sql=
	--		'Create TABLE '+@tableName+'  
	--		(
	--			id					int identity(1,1), 
	--			[Product Type]		nvarchar(10),
	--			[Sales Org]			nvarchar(4),
	--			[SUB GROUP/ Brand]	nvarchar(100),
	--			[Channel]			nvarchar(7),
	--			[GIT M0]			int,
	--			[GIT M1]			Int,
	--			[GIT M2]			int,
	--			[GIT M3]			int
	--		)'
	--		if @debug>0
	--		begin
	--			select 'import table @tableName-->LDB'
	--		end
	--		execute(@sql)

	--		select @sql=
	--		'insert into '+@tableName+'
	--		select
	--			[Product Type],
	--			[Sales Org],
	--			[SUB GROUP/ Brand],
	--			[Channel],
	--			[GIT M0]=sum([GIT M0]),
	--			[GIT M1]=sum([GIT M1]),
	--			[GIT M2]=sum([GIT M2]),
	--			[GIT M3]=sum([GIT M3])
	--		from '+@tableName1+'
	--		group by
	--			[Product Type],
	--			[Sales Org],
	--			[SUB GROUP/ Brand],
	--			[Channel] '
		
	--		if @debug>0
	--		begin
	--			select @sql '@sql insert tablename main'
	--		end
	--		execute(@sql)

	--		select @n_err = @@ERROR
	--		if @n_err<>0
	--		begin
	--			select @n_continue = 3
	--			--select @n_err=60003
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
   select @n_continue = 3
   ROLLBACK
   DECLARE @ErrorMessage VARCHAR(2000)
   SELECT @ErrorMessage = 'Error: '+ ERROR_MESSAGE()
   RAISERROR(@ErrorMessage , 16, 1)
END CATCH

