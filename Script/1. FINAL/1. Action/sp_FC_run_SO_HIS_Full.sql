/*
	exec sp_run_SO_HIS_Full 'CPD','2022-01-01','2024-08-01'
*/

Alter proc sp_FC_run_SO_HIS_Full
	@Division			nvarchar(3),
	@StartDate			DATE,
	@EndDate			DATE
As
BEGIN
	declare @debug			INT=0
	--DECLARE @StartDate DATE = '2022-10-01' 
	--DECLARE @EndDate DATE = '2024-08-01'
	WHILE @StartDate <= @EndDate 
	BEGIN 
	DECLARE @YearMonth VARCHAR(6) = format(@StartDate,'yyyyMM')
	DECLARE @b_Success INT,
			@c_errmsg NVARCHAR(250)
		--select @YearMonth '@YearMonth'
		EXEC sp_FC_SO_HIS_FINAL @Division,@YearMonth, @b_Success OUT, @c_errmsg OUT
	
		SELECT @b_Success AS b_Success, @c_errmsg AS c_errmsg

		SET @StartDate = DATEADD(MONTH, 1, @StartDate)
	END
	if @debug>0
	begin
		select distinct periodkey 
		from FC_CPD_SO_HIS_FINAL (NOLOCK) 
		order by periodkey asc
	end
END