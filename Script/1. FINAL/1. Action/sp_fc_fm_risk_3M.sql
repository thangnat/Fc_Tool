/*
	declare
		@b_Success		Int,
		@c_errmsg		Nvarchar(250)

	exec sp_fc_fm_risk_3M 'CPD','202407',@b_Success OUT, @c_errmsg OUT

	select @b_Success b_Success, @c_errmsg c_errmsg

	select * from fc_risk_raw_LDB
*/


Alter proc sp_fc_fm_risk_3M
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
		,@sql					nvarchar(max)=''
			
	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_fc_fm_risk_3M',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()
	
	select @debug=debug from fnc_debug('FC')
	--select @debug=1

	declare @Monthfc				nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from V_FC_FM_Table

	declare @tablename			nvarchar(200)='fc_risk_raw_'
	select @tablename = @tablename+@Division+@Monthfc

	declare @FC_FM_Original		nvarchar(100)=''
	select @FC_FM_Original='FC_FM_Original_'+@Division+@Monthfc

	if @debug>0
	begin
		select 'calculate data stock risk'
	end
	if @n_continue=1
	begin
		declare @list_risk3M nvarchar(200)=''
		SELECT @list_risk3M=ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'risk3M','f')
		--SELECT list_risk3M=ListColumn FROM fn_FC_GetColheader_Current('202407','risk3M','f')

		declare @tmp table (id int identity(1,1),ColumnName nvarchar(20))
		insert into @tmp 
		select value from string_split(@list_risk3M,',')

		--select value from string_split('[Y0 (u) M7],[Y0 (u) M8],[Y0 (u) M9],[Y0 (u) M10]',',')
		--select * from @tmp		

		declare @column0 as nvarchar(20)=''
		declare @column1 as nvarchar(20)=''
		declare @column2 as nvarchar(20)=''
		declare @column3 as nvarchar(20)=''

		declare @column_v_0 as nvarchar(20)=''
		declare @column_v_1 as nvarchar(20)=''
		declare @column_v_2 as nvarchar(20)=''
		declare @column_v_3 as nvarchar(20)=''
		--//unit
		select @column0=ColumnName from @tmp where id=1
		select @column1=ColumnName from @tmp where id=2
		select @column2=ColumnName from @tmp where id=3
		select @column3=ColumnName from @tmp where id=4
		--//value
		select @column_v_0='v.'+ColumnName from @tmp where id=1
		select @column_v_1='v.'+ColumnName from @tmp where id=2
		select @column_v_2='v.'+ColumnName from @tmp where id=3
		select @column_v_3='v.'+ColumnName from @tmp where id=4

		--select @column0,@column1,@column2,@column3
		if exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID(@tablename) AND type in (N'U')
		)
		begin
			select @sql = 'drop table '+@tablename
			execute(@sql)
		end

		select @sql=
		'select
			x1.[Product type],
			x1.[SUB GROUP/ Brand],
			x1.Channel,
			x1.[Time series],
			[Risk (u) M0],
			[Risk (u) M1],
			[Risk (u) M2],
			[Risk (u) M3],
			[Total risk (u)]=([Risk (u) M0]+[Risk (u) M1]+[Risk (u) M2]+[Risk (u) M3]),
			[Risk (val) M0]=cast([Risk (u) M0]*'+@column_v_0+' as numeric(18,0)),
			[Risk (val) M1]=cast([Risk (u) M1]*'+@column_v_1+' as numeric(18,0)),
			[Risk (val) M2]=cast([Risk (u) M2]*'+@column_v_2+' as numeric(18,0)),
			[Risk (val) M3]=cast([Risk (u) M3]*'+@column_v_3+' as numeric(18,0)),
			[Total risk (val)]=cast(([Risk (u) M0]*'+@column_v_0+'+[Risk (u) M1]*'+@column_v_1+
									'+[Risk (u) M2]*'+@column_v_2+'+[Risk (u) M3]*'+@column_v_3+') as numeric(18,0))
			INTO '+@tablename+'
		from
		(
			select
				[Product type],
				[SUB GROUP/ Brand],
				Channel,
				[Time series],
				[Separate]=''  '',
				[Risk (u) M0]=cast(dbo.min_((SOH+[MTD SI]+[GIT M0])-'+@column0+',1) as int),
				[Risk (u) M1]=cast(dbo.min_(case when ((SOH+[MTD SI]+[GIT M0])-'+@column0+')<0 then 0 else (SOH+[MTD SI]+[GIT M0])-'+@column0+' end+[GIT M1]-'+@column1+',1) as int),
				[Risk (u) M2]=cast(dbo.min_(case 
							when (case when ((SOH+[MTD SI]+[GIT M0])-'+@column0+')<0 then 0 else (SOH+[MTD SI]+[GIT M0])-'+@column0+' end+[GIT M1]-'+@column1+')<0 then 0
							else
								case when ((SOH+[MTD SI]+[GIT M0])-'+@column0+')<0 then 0 else (SOH+[MTD SI]+[GIT M0])-'+@column0+' end+[GIT M1]-'+@column1+'
						end+[GIT M2]-'+@column2+',1) as int),
				[Risk (u) M3]=cast(dbo.min_(case when (case 
							when (case when ((SOH+[MTD SI]+[GIT M0])-'+@column0+')<0 then 0 else (SOH+[MTD SI]+[GIT M0])-'+@column0+' end+[GIT M1]-'+@column1+')<0 then 0
							else
								case when ((SOH+[MTD SI]+[GIT M0])-'+@column0+')<0 then 0 else (SOH+[MTD SI]+[GIT M0])-'+@column0+' end+[GIT M1]-'+@column1+'
						end+[GIT M2]-'+@column2+')<0 then 0
						else
							case 
							when (case when ((SOH+[MTD SI]+[GIT M0])-'+@column0+')<0 then 0 else (SOH+[MTD SI]+[GIT M0])-'+@column0+' end+[GIT M1]-'+@column1+')<0 then 0
							else
								case when ((SOH+[MTD SI]+[GIT M0])-'+@column0+')<0 then 0 else (SOH+[MTD SI]+[GIT M0])-'+@column0+' end+[GIT M1]-'+@column1+'
						end+[GIT M2]-'+@column2+'
					end+[GIT M3]-'+@column3+',1) as int),
				[Total risk (u)]=0
			from
			(
				select
					[Product type],
					[SUB GROUP/ Brand],
					Channel,
					[Time series],
					[SOH],
					[MTD SI],
					[GIT M0],
					[GIT M1],
					[GIT M2],
					[GIT M3],
					[Total GIT],
					'+@list_risk3M+'
				from '+@FC_FM_Original+' f
				where 
					[Channel]=''O+O'' 
				and [Time series]=''6. Total Qty''
			) as x
		) as x1
		inner join
		(
			select DISTINCT
				[SUB GROUP/ Brand],
				'+@list_risk3M+'
			from fnc_SubGroupMaster_RSP('''+@Division+''',''full'')
			where ('+replace(@list_risk3M,',','+')+')>0
		) v on v.[SUB GROUP/ Brand]=x1.[SUB GROUP/ Brand] '

		if @debug>0
		begin
			select @sql '@sql Insert table name'
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
		select 'set stock risk=0'
	end
	if @n_continue=1
	begin
		if @Division IN('CPD','LDB','LLD','PPD')
		begin
			select @sql =
			'Update '+@FC_FM_Original
			+' set 
				[Risk (u) M0]=0,
				[Risk (u) M1]=0,
				[Risk (u) M2]=0,
				[Risk (u) M3]=0,
				[Total risk (u)]=0,
				[Risk (val) M0]=0,
				[Risk (val) M1]=0,
				[Risk (val) M2]=0,
				[Risk (val) M3]=0,
				[Total risk (val)]=0
			'
			if @debug>0
			begin
				select @sql '@sql Set zero'
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
		select 'update stock risk into wf'
	end
	if @n_continue=1
	begin
		if @Division IN('CPD','LDB','LLD','PPD')
		begin
			select @sql=
			'update '+@FC_FM_Original+
			' set 
				[Risk (u) M0]=r.[Risk (u) M0],
				[Risk (u) M1]=r.[Risk (u) M1],
				[Risk (u) M2]=r.[Risk (u) M2],
				[Risk (u) M3]=r.[Risk (u) M3],
				[Total risk (u)]=r.[Total risk (u)],
				[Risk (val) M0]=r.[Risk (val) M0],
				[Risk (val) M1]=r.[Risk (val) M1],
				[Risk (val) M2]=r.[Risk (val) M2],
				[Risk (val) M3]=r.[Risk (val) M3],
				[Total risk (val)]=r.[Total risk (val)]
			from '+@FC_FM_Original+' f
			inner join
			(
				select * from '+@tablename+'
			) r on 
				/*r.[Product type]=f.[Product type]
			and */
				r.[SUB GROUP/ Brand]=f.[SUB GROUP/ Brand]
			and r.[Channel]=f.[Channel]
			and r.[Time series]=f.[Time series]
			where 
				f.[Channel] IN(''O+O'')
			and f.[Time series]=''6. Total Qty'' '

			if @debug>0
			begin
				select @sql '@sql Update risk into wf'
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