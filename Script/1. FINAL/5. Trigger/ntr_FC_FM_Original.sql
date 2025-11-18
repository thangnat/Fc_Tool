Alter  TRIGGER ntr_FC_FM_Original
ON  dbo.FC_FM_Original_LLD
FOR INSERT,UPDATE
AS
BEGIN TRAN
	IF @@ROWCOUNT = 0
	BEGIN
		RETURN
	END
	DECLARE @b_debug int
	SELECT @b_debug = 0
	DECLARE
			    @b_Success            int       -- Populated by calls to stored procedures - was the proc successful?
	,         @n_err                int       -- Error number returned by stored procedure or this trigger
	,         @n_err2               int       -- For Additional Error Detection
	,         @c_errmsg             char(250) -- Error message returned by stored procedure or this trigger
	,         @n_continue int                 
	,         @n_starttcnt          int       -- Holds the current transaction count
	,         @c_preprocess         char(250) -- preprocess
	,         @c_pstprocess         char(250) -- post process
	,         @n_cnt                int
	SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT

	IF @n_continue = 1 or @n_continue = 2
	BEGIN
		DECLARE 
			@subgrp nvarchar(500) = '',
			@OldQty		int = 0, 
			@newQty int = 0, 
			@Channel nvarchar(7) = '',
			@Timeseries	nvarchar(20) = ''
		declare @listcolumn_current nvarchar(max) = '',@FM_Key nvarchar(6) = '',@sql nvarchar(max) = ''
		declare @listcolumn_current_update nvarchar(max) = ''
		select @FM_Key = format(getdate(),'yyyyMM')
		SELECT @listcolumn_current_update = ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'updateForecast','si')
		--SELECT listcolumn_current_update = ListColumn FROM fn_FC_GetColheader_Current('202404','updateForecast','si')
		select @listcolumn_current = ListColumn FROM fn_FC_GetColheader_Current(@FM_Key,'6. Total Qty','')
		--select listcolumn_current = ListColumn FROM fn_FC_GetColheader_Current('202404','6. Total Qty','')

		select @sql = 
		'update FC_FM_Original_LLD
		set '+@listcolumn_current_update+'
		from FC_FM_Original_LLD f
		inner join
		(
			select
				[Product Type],
				[SUB GROUP/ Brand],
				Channel,
				'+@listcolumn_current+'
			from FC_FM_Original_LLD
			where [Time series] <> ''6. Total Qty'' and [Product Type] = ''YFG'' 
				group by
					[Product Type],
					[SUB GROUP/ Brand],
					Channel
		) as si on 
					si.[Product Type] = f.[Product Type] 
				and si.[SUB GROUP/ Brand] = f.[SUB GROUP/ Brand] 
				and si.channel = f.channel
			where f.[Time Series] = ''6. Total Qty'' and f.[Product Type] = ''YFG'' '
		--select @sql
		execute(@sql)

		SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
		IF @n_err <> 0
		BEGIN
			SELECT @n_continue = 3
			SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 63318  
			-- Should Be Set To The SQL Errmessage but I don't know how to do so.
			SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update trigger On FC_FM_Original_LLD Failed. (ntr_FC_FM_Original)' + ' ( ' + ' SQLSvr MESSAGE=' + LTRIM(RTRIM(@c_errmsg)) + ' )'
		END
	END
	
	IF @n_continue = 3  -- Error Occured - Process And Return
	BEGIN
		ROLLBACK TRAN
		--IF @@TRANCOUNT = 1 AND @@TRANCOUNT >= @n_starttcnt
		--BEGIN
		--	ROLLBACK TRAN
		--END
		--ELSE
		--BEGIN
		--	WHILE @@TRANCOUNT > @n_starttcnt
		--	BEGIN
		--		COMMIT TRAN
		--	END
		--END
		--RAISERROR(@c_errmsg , 16, 1)
		--RETURN
	END
	ELSE
	BEGIN	
		COMMIT TRAN
		--WHILE @@TRANCOUNT > @n_starttcnt
		--BEGIN
		--	COMMIT TRAN
		--END
		--RETURN
	END
