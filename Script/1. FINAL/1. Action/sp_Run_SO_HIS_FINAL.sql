/*
	Declare
		@b_Success			Int,
		@c_errmsg			Nvarchar(250)

	exec sp_Run_SO_HIS_FINAL 'LDB','202501',@b_Success OUT,@c_errmsg OUT

	select @b_Success b_Success,@c_errmsg c_errmsg

	select distinct
		periodkey 
	from FC_LDB_SO_HIS_FINAL (NOLOCK)
	order by periodkey asc
*/

Alter proc sp_Run_SO_HIS_FINAL
	@Division			nvarchar(3),
	--@FM_KEY				nvarchar(6),
	@periodkey			nvarchar(6),--//fill FM KEY, period key ok=month(FMKEY)-1
	@b_Success			Int				OUTPUT,     
	@c_errmsg			Nvarchar(250)	OUTPUT
As
SET NOCOUNT ON
SET XACT_ABORT ON
--BEGIN TRAN
BEGIN TRY
	DECLARE   
		 @debug					int=1
		,@sp_name				Nvarchar(100)
		,@n_continue			Int
		,@USERS					Nvarchar(50)
		,@MODIFILED				Datetime
		,@n_err					int
		,@status_login			nvarchar(2) = ''
		,@sql					nvarchar(max)=''

	declare 
		@b_Success1				Int,
		@c_errmsg1				Nvarchar(250)

	declare 
		@error_while			int=0,
		@error_message_while	nvarchar(1000)=''

	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_Run_SO_HIS_FINAL',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	declare @StartDate			date-- = '2024-09-01',
	declare @EndDate			date-- = '2024-09-01'

	declare @periodkey_ok			nvarchar(6)=''
	select @periodkey_ok=case 
							when RIGHT(@periodkey,2)='01' then 
								cast((cast(LEFT(@periodkey,4) as int)-1) as nvarchar(4)) 
							else 
								left(@periodkey,4)	
						end +format((cast(case 
											when RIGHT(@periodkey,2)='01' then '12' 
											else RIGHT(@periodkey,2) 
										end as int)-1),'00')
	select @periodkey_ok '@periodkey_ok'

	select @StartDate=cast(LEFT(@periodkey_ok,4)+'-'+right(@periodkey_ok,2)+'-01' as date)
	select @EndDate=cast(LEFT(@periodkey_ok,4)+'-'+right(@periodkey_ok,2)+'-01' as date)
	select @StartDate '@StartDate',@EndDate '@EndDate'

	declare @tmp table (id int identity(1,1), PeriodKey nvarchar(6),[Error message] nvarchar(1000))

	if @debug>0
	begin
		select 'Run by period'
	end
	if @n_continue=1
	begin
		WHILE @StartDate <= @EndDate
		BEGIN 
			DECLARE @YearMonth VARCHAR(6)=''
			select @YearMonth=format(@StartDate,'yyyyMM')				

				if @debug>0
				begin
					select @YearMonth '@YearMonth'
				end

				exec sp_FC_SO_HIS_FINAL @Division,@YearMonth,@b_Success1 OUT,@c_errmsg1 OUT

				SELECT @YearMonth '@YearMonth',@b_Success1 AS b_Success, @c_errmsg1 AS c_errmsg

				if @b_Success1=0
				begin
					insert into @tmp(PeriodKey,[Error message])
					select @periodkey_ok,@c_errmsg1
				end
			SET @StartDate = DATEADD(MONTH, 1, @StartDate)
		END
	end

	if @debug>0
	begin
		select 'Get all period'
	end
	if @n_continue=1
	begin
		if @Division='CPD'
		begin
			select
				PeriodKey=f.PeriodKey,
				[Error Message]=t.[Error message]
			from
			(
				select distinct 
					Periodkey
				from FC_CPD_SO_HIS_FINAL(NOLOCK)
				
			) as f
			left join
			(
				select 
					PeriodKey,
					[Error message] 
				from @tmp
			) t on t.PeriodKey=f.PeriodKey
			order by f.periodkey asc
		end
		if @Division='LLD'
		begin
			select
				PeriodKey=f.PeriodKey,
				[Error Message]=t.[Error message]
			from
			(
				select distinct 
					Periodkey
				from FC_LLD_SO_HIS_FINAL(NOLOCK)
				
			) as f
			left join
			(
				select 
					PeriodKey,
					[Error message] 
				from @tmp
			) t on t.PeriodKey=f.PeriodKey
			order by f.periodkey asc
		end
		if @Division='LDB'
		begin
			select
				PeriodKey=f.PeriodKey,
				[Error Message]=t.[Error message]
			from
			(
				select distinct 
					Periodkey
				from FC_LDB_SO_HIS_FINAL(NOLOCK)
				
			) as f
			left join
			(
				select 
					PeriodKey,
					[Error message] 
				from @tmp
			) t on t.PeriodKey=f.PeriodKey
			order by f.periodkey asc
		end
		if @Division='PPD'
		begin
			select
				PeriodKey=f.PeriodKey,
				[Error Message]=t.[Error message]
			from
			(
				select distinct 
					Periodkey
				from FC_PPD_SO_HIS_FINAL(NOLOCK)
				
			) as f
			left join
			(
				select 
					PeriodKey,
					[Error message] 
				from @tmp
			) t on t.PeriodKey=f.PeriodKey
			order by f.periodkey asc
		end
	end

	if @n_continue = 3
	begin
		--rollback
		select @b_Success = 0
	end
	else
	begin
		--Commit
		select @b_Success = 1, @c_errmsg = 'Successfully.../'
	end
END TRY
BEGIN CATCH
   --ROLLBACK
   DECLARE @ErrorMessage VARCHAR(2000)
   SELECT @ErrorMessage = 'Error: '+ ERROR_MESSAGE()
   RAISERROR(@ErrorMessage , 16, 1)
END CATCH