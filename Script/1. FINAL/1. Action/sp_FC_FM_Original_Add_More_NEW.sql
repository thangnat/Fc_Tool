/*
	Declare
		@b_Success			Int,
		@c_errmsg			Nvarchar(250)

	exec sp_FC_FM_Original_Add_More_NEW 'CPD','202407',1,@b_Success OUT,@c_errmsg OUT

	select @b_Success b_Success,@c_errmsg c_errmsg

	select * from FC_FM_Original_Add_More_CPD_202410 order by ID asc
*/
Alter Proc sp_FC_FM_Original_Add_More_NEW
	@Division			nvarchar(3),
	@FM_Key				Nvarchar(6),
	@Allow_Import_main	INT,
	@b_Success			Int				OUT,
	@c_errmsg			Nvarchar(250)	OUT
	with encryption
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
		,@full					nvarchar(4) = ''

	declare 
		@b_Success1				Int,
		@c_errmsg1				Nvarchar(250)

	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_FC_FM_Original_Add_More_NEW',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	select @debug=debug from fnc_debug('FC')
	--select @debug=1

	declare @Monthfc			nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from V_FC_FM_Table	

	declare @table_name nvarchar(100) = ''
	select @table_name = 'FC_FM_Original_Add_More_'+@Division+@Monthfc

	declare @table_Original nvarchar(100) = ''
	select @table_Original = 'FC_FM_Original_'+@Division+@Monthfc

	if @debug>0
	begin
		select 'check permission'
	end
	if @n_continue=1
	begin
		if @Division NOT IN('LLD','LDB','CPD','PPD')
		begin
			select @n_continue=3, @c_errmsg='Not permission'
		end
	end
	if @debug>0
	begin
		select 'check no raws'
	end
	if @n_continue=1
	begin
		if not exists(select 1 from FC_FM_SUbgrp_Selected where [Division]=@Division)
		begin
			select @n_continue=3, @c_errmsg='No rows to add more.../'
		end
	end
	if @debug>0
	begin
		select 'backup Data'
	end
	if @n_continue=1
	begin
		if exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID('FC_FM_Original_'+@Division+@Monthfc) AND type in (N'U')
		)
		begin
			exec sp_Backup_WF_before_Save @Division,@FM_KEY,'ALL',@b_Success1 OUT,@c_errmsg1 OUT
			if @b_Success1=0
			begin
				select @n_continue=3,@c_errmsg=@c_errmsg1
			end
		end
	end

	BEGIN TRAN
	if @debug>0
	begin
		select 'insert table maxx_id'
	end
	if @n_continue=1
	begin
		if exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID('FC_FM_MAX_ID') AND type in (N'U')
		)
		begin
			select @sql='delete FC_FM_MAX_ID where [Division]='''+@Division+''' and [FM_KEY]='''+@FM_Key+''' '

			if @debug>0
			begin
				select @sql 'delete table max id'
			end
			execute(@sql)

			if @debug>0
			begin
				select 'insert table max id'
			end
			select @sql=
			'INSERT INTO FC_FM_MAX_ID
			select 
				[Division]='''+@Division+''',
				[FM_KEY],
				[Max_ID]=isnull(max(ID),0)
			from '+@table_Original+'
			group by
				FM_KEY'

			if @debug>0
			begin
				select @sql 'insert table max id'
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
			select @sql=
			'select 
				[Division]='''+@Division+''',
				[FM_KEY],
				[Max_ID]=isnull(max(ID),0)
				INTO FC_FM_MAX_ID
			from '+@table_Original+'
			group by
				FM_KEY'

			if @debug>0
			begin
				select @sql 'Create new table max id'
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
		select 'check max id'
	end
	if @n_continue=1
	begin
		declare @max_id nvarchar(10)=''

		select @max_id=cast([Max_ID] as nvarchar(10)) from FC_FM_MAX_ID where [Division]=@Division and [FM_KEY]=@FM_Key

		if @max_id is null
		begin
			select @max_id=0
		end
		if @max_id=0
		begin
			select @n_continue=3,@c_errmsg='No rows to process...'
		end
	end
	if @debug>0
	begin
		select 'Processing create tmp table'
	end
	if @n_continue =1
	begin
		declare @year0 nvarchar(4) = '',@year1 nvarchar(4) = ''
		select @year0 = left(@FM_Key,4)--cast(year(getdate()) as nvarchar(4))
		select @year1 = cast((cast(@year0 as int)+1) as nvarchar(4))

		declare @tmp_channel table 
		(
			channel nvarchar(7)
		)
		insert into @tmp_channel(channel) values('ONLINE'),('OFFLINE')

		declare @ListColumn_Pass		nvarchar(max) = ''
		select @ListColumn_Pass = ListColumn from fn_FC_GetColHeader_Historical(@FM_Key,'y',0)
		--select ListColumn_Pass = ListColumn from fn_FC_GetColHeader_Historical('202404','y',0)
		declare @ListColumn_Pass_value	nvarchar(max) = ''
		select @ListColumn_Pass_value = ListColumn from fn_FC_GetColHeader_Historical(@FM_Key,'si',86)-->A
		--select ListColumn_Pass_value = ListColumn from fn_FC_GetColHeader_Historical('202404','si',86)-->A
		declare @ListColumn_Current	nvarchar(max) = ''
		SELECT @ListColumn_Current = ListColumn FROM fn_FC_GetColheader_Current(@FM_Key,'FM_Original','y')
		--SELECT ListColumn_Current = ListColumn FROM fn_FC_GetColheader_Current('202404','1. Baseline Qty_0','y')
		declare @ListColumn_Current_Value	nvarchar(max) = ''
		select @ListColumn_Current_Value = ListColumn FROM fn_FC_GetColheader_Current(@FM_Key,'Current_A_WF_VALUE','si')
		--select ListColumn_Current_Value = ListColumn FROM fn_FC_GetColheader_Current('202404','Current_A_WF_VALUE','si')
		declare @listversionM_minus_1	nvarchar(max) = ''
		select @listversionM_minus_1 = ListColumn FROM fn_FC_GetColheader_Current(@FM_Key,'A_Version_M-1','si')		
		--select listversionM_minus_1 = ListColumn FROM fn_FC_GetColheader_Current('202404','A_Version_M-1','si')		
		declare @listversionM_minus_1_Value	nvarchar(max) = ''
		select @listversionM_minus_1_Value = ListColumn FROM fn_FC_GetColheader_Current(@FM_Key,'A_Version_M-1_Value','si')
		--select listversionM_minus_1_Value = ListColumn FROM fn_FC_GetColheader_Current('202404','A_Version_M-1_Value','si')
		
		declare @ListBudget			nvarchar(max) = ''
		SELECT @ListBudget = ListColumn FROM fn_FC_GetColheader_Current_BT(@FM_Key,'','B',1)
		--SELECT ListBudget = ListColumn FROM fn_FC_GetColheader_Current_BT('202403','','B',2)
		declare @ListBudget_Value		nvarchar(max) = ''
		SELECT @ListBudget_Value = ListColumn FROM fn_FC_GetColheader_Current_BT(@FM_Key,'','B',21)
		--SELECT ListBudget_Value = ListColumn FROM fn_FC_GetColheader_Current_BT('202403','','B',21)
		declare @ListPre_Budget		nvarchar(max) = ''
		SELECT @ListPre_Budget = ListColumn FROM fn_FC_GetColheader_Current_BT(@FM_Key,'','PB',1)
		--SELECT ListPre_Budget = ListColumn FROM fn_FC_GetColheader_Current_BT('202403','','PB',2)
		declare @ListPre_Budget_Value	nvarchar(max) = ''
		SELECT @ListPre_Budget_Value = ListColumn FROM fn_FC_GetColheader_Current_BT(@FM_Key,'','PB',21)
		--SELECT ListPre_Budget_Value = ListColumn FROM fn_FC_GetColheader_Current_BT('202403','','PB',21)
		declare @listTrend				nvarchar(max) = ''
		SELECT @listTrend = ListColumn FROM fn_FC_GetColheader_Current_BT(@FM_Key,'','T',1)
		--SELECT listTrend = ListColumn FROM fn_FC_GetColheader_Current_BT('202403','','T',1)
		declare @listTrend_Value		nvarchar(max) = ''
		SELECT @listTrend_Value = ListColumn FROM fn_FC_GetColheader_Current_BT(@FM_Key,'','T',21)
		--SELECT listTrend_Value = ListColumn FROM fn_FC_GetColheader_Current_BT('202403','','T',21)

		if exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID(@table_name) AND type in (N'U')
		)
		begin
			select @sql = 'drop table '+@table_name
			if @debug >0
			begin
				select @sql '@sql'
			end
			execute(@sql)
		end
		
		select @sql=
		'select
			id=cast('+@max_id+' as bigint)+row_number() over 
			(
				order by 
					[SUB GROUP/ Brand] asc,
					[Channel] asc,       
					cast(case     
					when left([Time series],1)<>''7'' then replace(left([Time series],3),''.'','''')      
					else left([Time series],3)      
					end as numeric(18,1)) asc,
					case when left([Time series],1)=''0'' then cast(case     
					when left(replace([Time series],''0. O+O: '',''''),1)<>''7'' then replace(left(replace([Time series],''0. O+O: '',''''),3),''.'','''')      
					else left(replace([Time series],''0. O+O: '',''''),3)      
					end as numeric(18,1)) else 999999 end asc
			),
			FM_KEY = '''+@FM_Key+''',
				*
			INTO '+@table_name+'
		from
		(
			select
				x2.*,'
				+@ListColumn_Pass+','				
				+@ListColumn_Current+','
				+@listversionM_minus_1+','				
				+@ListBudget+','				
				+@ListPre_Budget+','
				+@listTrend +','
				+@ListColumn_Pass_value+','
				+@ListColumn_Current_Value+','
				+@listversionM_minus_1_Value+','
				+@ListBudget_Value+','
				+@ListPre_Budget_Value+','
				+@listTrend_Value 
			+'from
			(
				select
					x.*		
				from
				(
					Select distinct
						[Product type]=s.[Type],
						[Signature]=s.[Signature],
						[CAT/Axe]=s.[CAT/Axe],
						[SUB CAT/ Sub Axe]=s.[SUB CAT/ Sub Axe],
						[GROUP/ Class]=s.[GROUP/ Class],
						[Ref. Code]=s.[Ref. Code],
						[SUB GROUP/ Brand]=s.[SUB GROUP/ Brand],
						[HERO]=s.[HERO],
						[Channel]=case when left(t.MAP,7)=''0. O+O:'' and c.Channel=''OFFLINE'' then ''O+O'' else c.Channel end,
						[Product status]=S.[Product status],
						[Time series]=case when (c.Channel=''ONLINE'' and left(t.MAP,3) IN(''7.1'',''7.2'')) 
											OR(c.Channel=''ONLINE'' and left(t.MAP,7)=''0. O+O:'') then ''7. IGNORE'' else t.MAP end,
						[SIT]=0,
						[SIT Day]=0,
						[SOH]=0,
						[MTD SI]=0,
						[Total GIT]=0,
						[GIT M0]=0,
						[GIT M1]=0,
						[GIT M2]=0,
						[GIT M3]=0,'+
						case 
							when @Division IN('CPD','LDB','LLD','PPD') then
								'[Risk (u) M0]=0,
								[Risk (u) M1]=0,
								[Risk (u) M2]=0,
								[Risk (u) M3]=0,
								[Total risk (u)]=0,
								[Risk (val) M0]=cast(0 as numeric(18,0)),
								[Risk (val) M1]=cast(0 as numeric(18,0)),
								[Risk (val) M2]=cast(0 as numeric(18,0)),
								[Risk (val) M3]=cast(0 as numeric(18,0)),
								[Total risk (val)]=cast(0 as numeric(18,0)),' 
							else 
								'' 
						end+'
						[AVE P3M Y-1]=0,
						[AVE F3M Y-1]=0,
						[AVE P3M Y0]=0,
						[AVE F3M Y0]=0,
						[%F3M Y0/ P3M Y0]=cast(''0.00'' as numeric(18,2)),
						[%F3M Y-1/ P3M Y-1]=cast(''0.00'' as numeric(18,2)),
						[SLOB]=0
					From fnc_SubGroupMaster('''+@Division+''',''full'') s
					Left join 
					(
						select DISTINCT
							[SUB GROUP/ Brand]
						from '+@table_Original+' (NOLOCK)
					) f on f.[SUB GROUP/ Brand]=s.[SUB GROUP/ Brand]
					cross join 
					(
						select 
							[TimeSeries],
							[MAP]
						from V_FC_TIME_SERIES
						where '+@Division+'=1
					) t
					cross join 
					(
						select 
							*
						from V_FC_Channel 
						WHERE CHANNEL NOT IN(''FOC'')
					) c
					where s.[Material Type] '
											+case 
												when @Division IN('LLD','PPD','LDB') then 'in(''YFG'') ' 
												else 'in(''YFG'',''YSM2'') ' 
											end+'
					and s.[Item Category Group]<>''LUMF''
					and ISNULL(f.[SUB GROUP/ Brand],'''')=''''
					'+case 
						when exists(select 1 from FC_FM_SUbgrp_Selected where [Division]=@Division) then
							'and ISNULL(s.[SUB GROUP/ Brand],'''') IN
							(
								select DISTINCT
									[SUB GROUP/ Brand]
								from FC_FM_SUbgrp_Selected
								where [Division]='''+@Division+'''
							) '
						else ' ' 
					end+'
					group by
						s.[Type],
						s.[Signature],
						s.[CAT/Axe],
						s.[SUB CAT/ Sub Axe],
						s.[GROUP/ Class],
						s.[SUB GROUP/ Brand],
						s.[HERO],
						c.[Channel],
						s.[Product status],
						t.[MAP],
						s.[Ref. Code]
				) as x
				where [Time series] NOT IN(''7. IGNORE'')
			) as x2
		) as x3 '

		if @debug >0
		begin
			select @sql '@sql insert table name: = FC_FM_Original'
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
	if @debug>0
	begin
		select 'delete FC_FM_SUbgrp_Selected by division'
	end
	if @n_continue=1
	begin
		delete FC_FM_SUbgrp_Selected where [Division]=@Division

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
		select 'create index'
	end
	if @n_continue=9
	begin
		--//create index
		select @sql = 'CREATE CLUSTERED INDEX Idx_'+@table_name+'_ClusteredIndex_Subgrp
						ON dbo.'+@table_name+'([SUB GROUP/ Brand])'
		if @debug >0
		begin
			select @sql 'Create Index table'
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
	if @debug>0
	begin
		select 'replace O+O'
	end
	if @n_continue=1
	begin
		--//update channel O+O replcae '0. O+O'
		select @sql = 
		'Update '+@table_name+'  
			set [Time series]=replace([Time series],''0. O+O: '','''')	
		WHERE Channel = ''O+O'' '

		if @debug>0
		begin
			select @sql '@SQL replace([Time series],''0. O+O: '','''')	 '
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
	if @debug>0
	begin
		select 'Insert into main table WF'
	end
	if @n_continue=1
	begin
		if @Allow_Import_main=1
		begin
			select @sql=
			'insert into '+@table_Original+'
			select * from '+@table_name

			if @debug>0
			begin
				select @sql 'Insert more'
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
		select 'Create View WF to CT&P'
	end
	if @n_continue=1
	begin
		if @Allow_Import_main=1
		begin
			exec sp_create_View_FC_FM_Original @Division,@FM_Key
		end
	end
	if @debug>0
	begin
		select 'Clear data FC_FM_SUbgrp_Selected'
	end
	if @n_continue=1
	begin
		select @sql='delete FC_FM_SUbgrp_Selected where [Division]='''+@Division+''' '
		if @debug>0
		begin
			select @sql 'Clear data FC_FM_SUbgrp_Selected by division'
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


