/*
	declare 
		@b_Success				Int,
		@c_errmsg				Nvarchar(250)
	
	exec sp_add_fc_config_wf_total_custom 
	'CPD',
	'202407',
	'ONLINE,OFFLINE',
	'AQUAFUSION INVISIBLE SUNSCREEN 50ML',
	'1. Baseline Qty,2. Promo Qty(Single),4. Launch Qty',
	'100,0,0',
	'100,0,0',
	@b_Success OUT,
	@c_errmsg OUT

	select @b_Success b_Success, @c_errmsg c_errmsg

	/*
		delete fc_config_wf_total_custom
		select * from fc_config_wf_total_custom
		where [SUB GROUP/ Brand]='AGE REWIND CONCEALER'
		and channel='ONLINE'
	*/
*/

Alter Proc sp_add_fc_config_wf_total_custom
	@Division				nvarchar(3),
	@FM_KEY					nvarchar(6),
	@Channel				nvarchar(20),
	@Subgroup				nvarchar(500),
	@ListTimeseries			nvarchar(300),
	@ListPercent_online		nvarchar(300),
	@ListPercent_offline	nvarchar(300),
	@b_Success				Int				OUTPUT,     
	@c_errmsg				Nvarchar(1000)	OUTPUT
As
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRAN
BEGIN TRY
	DECLARE   
		 @sp_name				Nvarchar(100)
		,@n_continue			Int
		,@USERS					Nvarchar(50)
		,@MODIFILED				Datetime
		,@n_err					int
		,@Status_online			int=0
		,@Status_offline		int=0
		,@debug					int=0
			
	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_add_fc_config_wf_total_custom',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()
	
	declare @tmplist table
	(
		id					int,
		Division			nvarchar(3),
		FM_KEY				nvarchar(6),
		Channel				nvarchar(7),
		[SUB GROUP/ Brand]	nvarchar(500),
		[Time series]		nvarchar(50), 
		[Percent Online]	numeric(18,2) default 0,
		[Percent Offline]	numeric(18,2) default 0
	)
	declare @tmplist2_Online table
	(
		id					int identity(1,1),
		[Percent]	nvarchar(10)
	)
	declare @tmplist2_Offline table
	(
		id					int identity(1,1),
		[Percent]	nvarchar(10)
	)

	if @n_continue=1
	begin
		if @Channel=''
		begin
			delete fc_config_wf_total_custom
			where [SUB GROUP/ Brand]=@Subgroup

			select @n_err = @@ERROR
			if @n_err<>0
			begin
				select @n_continue = 3
				--select @n_err=60003
				select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +ERROR_MESSAGE()+'./ ('+@sp_name+')'
			end
		end
	end

	if @n_continue = 1
	begin
		if @Channel<>''
		begin
			insert into @tmplist
			(
				id,
				Division,
				FM_KEY,
				Channel,
				[SUB GROUP/ Brand],
				[Time series],
				[Percent Online],
				[Percent Offline]
			)
			select 
				id = ROW_NUMBER() over(partition by c.value order by c.value asc, t.value asc),
				Division=@Division,
				FM_KEY=@FM_KEY,
				Channel=c.value,
				[SUB GROUP/ Brand]=@Subgroup,
				[Time series]=t.value,
				[Percent Online]=0,
				[Percent Offline]=0
			from string_split(@ListTimeseries,',') t
			cross join
			(
				select
					value
				from string_split(@Channel,',')
			) c

			INSERT INTO @tmplist2_Online([Percent]) 
			select value from string_split(@ListPercent_online,',')
		
			INSERT INTO @tmplist2_Offline([Percent]) 
			select value from string_split(@ListPercent_offline,',')

			update @tmplist
			set 
				[Percent Online] = isnull(t2on.[Percent],0),
				[Percent Offline] = isnull(t2of.[Percent],0)
			from @tmplist t1
			inner join @tmplist2_Online t2on on t2on.id = t1.id
			inner join @tmplist2_Offline t2of on t2of.id = t1.id

			if @debug>0
			begin
				select * from @tmplist
			end
		end
	end
	
	if @n_continue=1
	begin
		if @Channel<>''
		begin
			select @Status_online=0
			select @Status_offline=0
			if @Channel='ONLINE,OFFLINE'
			begin
				select @Status_online=1
				select @Status_offline=1			
			end
			else
			begin
				if @Channel='ONLINE'
				begin
					select @Status_online=1
				end
				else if @Channel='OFFLINE'
				begin
					select @Status_offline=1
				end
			end
		end
	end

	if @debug>0
	begin
		select @n_continue '1.1.1'
	end
	if @n_continue =1
	begin
		if @Channel<>''
		begin
			if @Channel ='ONLINE,OFFLINE'
			begin
				if @debug>0
				begin
					select @n_continue '1.1.1A'
				end
				if (select
						sum([Percent Online])
					from @tmplist
					where Channel='ONLINE')<>100
				begin
					select @n_continue = 3
					select @n_err=60001
					select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +':Online percent for subgroup['+@Subgroup+'] # 100%./ ('+@sp_name+')'
				end
				if (select
						sum([Percent Offline])
					from @tmplist
					where Channel='OFFLINE')<>100
				begin
					select @n_continue = 3
					select @n_err=60001
					select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +':Offline percent for subgroup['+@Subgroup+'] # 100%./ ('+@sp_name+')'
				end
			end
			else if @Channel='ONLINE'
			begin
				if @debug>0
				begin
					select @n_continue '1.1.B'
				end
				if (select
						sum([Percent Online])
					from @tmplist
					where Channel='ONLINE')<>100
				begin
					select @n_continue = 3
					select @n_err=60001
					select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +':Online percent for subgroup['+@Subgroup+'] # 100%./ ('+@sp_name+')'
				end
			end
			else if @Channel='OFFLINE'
			begin
				if (select
						sum([Percent Offline])
					from @tmplist
					where Channel='OFFLINE')<>100
				begin
					select @n_continue = 3
					select @n_err=60001
					select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +':Offline percent for subgroup['+@Subgroup+'] # 100%./ ('+@sp_name+')'
				end
			end
		end
	end
	if @debug>0
	begin
		select @n_continue '1.1.3'
	end
	if @n_continue=1
	begin
		if @Channel<>''
		begin
			delete fc_config_wf_total_custom where [SUB GROUP/ Brand]=@Subgroup

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
		select @n_continue '1.1.4'
	end
	if @n_continue=1
	begin
		if @Channel<>''
		begin
			select @Status_online '@Status_online'
			if @Status_online=1
			begin
				insert into fc_config_wf_total_custom
				(
					[Division],
					[FM_KEY],
					[SUB GROUP/ Brand],
					[Channel],
					[Time series],
					[Percent]
				)
				select
					[Division],
					[FM_KEY],
					[SUB GROUP/ Brand],
					[Channel],
					[Time series],
					[Percent Online]
				from @tmplist
				where Channel='ONLINE'

				select @n_err = @@ERROR
				if @n_err<>0
				begin
					select @n_continue = 3
					--select @n_err=60003
					select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +ERROR_MESSAGE()+'./ ('+@sp_name+')'
				end
			end
		end
	end
	if @debug>0
	begin
		select @n_continue '1.1.5'
	end
	if @n_continue=1
	begin
		if @Channel<>''
		begin
			select @Status_offline '@Status_offline'
			if @Status_offline=1
			begin
				insert into fc_config_wf_total_custom
				(
					[Division],
					[FM_KEY],
					[SUB GROUP/ Brand],
					[Channel],
					[Time series],
					[Percent]
				)
				select
					[Division],
					[FM_KEY],
					[SUB GROUP/ Brand],
					[Channel],
					[Time series],
					[Percent Offline]
				from @tmplist
				where Channel='OFFLINE'

				select @n_err = @@ERROR
				if @n_err<>0
				begin
					select @n_continue = 3
					--select @n_err=60003
					select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +ERROR_MESSAGE()+'./ ('+@sp_name+')'
				end
			end
		end
	end
	if @debug>0
	begin
		select @n_continue '1.1.6'
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