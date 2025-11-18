/*
	Declare 
		@b_Success			Int,
		@c_errmsg			Nvarchar(250)

	exec sp_fc_convert_so_optimus_case1 'LDB','202409',@b_Success OUT, @c_errmsg OUT

	select @b_Success b_Success, @c_errmsg c_errmsg

	select * from FC_SO_OPTIMUS_Promo_Bom_LDB_202409_OK
*/
alter proc sp_fc_convert_so_optimus_case1
	@Division			nvarchar(3),
	@FM_KEY				nvarchar(6),
	@b_Success			Int				OUTPUT,     
	@c_errmsg			Nvarchar(250)	OUTPUT
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
		@sp_name = 'sp_fc_convert_so_optimus_case1',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	select @debug=debug from fnc_Debug('FC')

	declare @Monthfc				nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from V_FC_FM_Table

	declare @tablename nvarchar(100) = ''
	select @tablename  ='FC_SO_OPTIMUS_Promo_Bom_'+@Division+@Monthfc+'_OK'

	if @debug>0
	begin
		select @tablename '@tablename'
	end

	if @n_continue =1
	begin
		declare @tmp table (ID int identity(1,1),[year] int default 0,[Month] int default 0,Month_Desc nvarchar(5),Pass nvarchar(11))
		insert into @tmp([Year],[Month],Month_Desc,Pass)
		select
			*
		from
		(
			select [Year]=YEAR(GETDATE()),Month_Number,Month_Desc,Pass=replace(Pass,'@','0') from V_Month_Master 
			union all
			select [year]=YEAR(GETDATE()) + 1,Month_Number,Month_Desc,Pass=replace(Pass,'@','+1') from V_Month_Master
		) as x

		IF @debug>0
		BEGIN
			select * from @tmp
		END
		declare @totalrows int = 0, @currentrow int = 1
		select @totalrows = isnull(count(*),0) from @tmp
	end
	if @n_continue =1
	begin
		if exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID(@tablename) AND type in (N'U')
		)
		begin
			select @sql  ='Drop table '+@tablename
			if @debug>0
			begin
				select @sql 'drop table'
			end
			execute(@sql)
		end
		select @sql = 
				'Create table '+@tablename+
				'(
					[Channel]				nvarchar(10) NULL,
					'+case 
						when @Division='LDB' then 
							'[Barcode]' 
						else 
							'[Sap Code]' 
					end +' nvarchar(30) NULL,
					[Year]					nvarchar(4) NULL,
					[Month]					nvarchar(5) NULL,
					'+case 
						when @Division='LDB' then 
						'[Brand]				nvarchar(20) NULL,
						[Category]				nvarchar(20) NULL,' 
						else '' 
					end+'
					[Sell-Out Units]		int default 0,
					[GROSS SELL-OUT VALUE]	int default 0
				)
				
				select * from '+@tablename
		if @debug>0
		begin
			select @sql 'create table bom CONVERT'
		end
		execute(@sql)

		select @n_err = @@ERROR
		if @n_err<>0
		begin				
			select @n_continue = 3
			select @n_err=60002
			select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +ERROR_MESSAGE()+'./ ('+@sp_name+')'
		end
	end

	if @n_continue = 1
	begin
		while (@currentrow<=@totalrows)
		begin
			declare @year nvarchar(4) ='', @month nvarchar(5)='',@columnName nvarchar(11) = ''
			select 
				@year = [year],
				@month = [Month_Desc],
				@columnName = [Pass]
			from @tmp 
			where id = @currentrow
	
			select @sql = '
			INSERT INTO '+@tablename+'
			select
				[Channel],
				'+case when @Division='LDB' then '[Bundle Code]=[Bundle Code]' else '[Sap Code]=[Bundle Code]' end+',
				[Year]='''+@year+''',
				[Month]='''+case 
								when @month='July' then 'Jul' 
								when @month='June' then 'Jun' 
								when @month='Sept' then 'Sep' 
								else @month end+''',
				'+case when @Division='LDB' then '[Brand],[Category],' else '' end +'
				[Sell-Out Units] = sum(['+@columnName+']),
				[GROSS SELL-OUT VALUE] = 0
			from FC_SO_OPTIMUS_Promo_Bom_'+@Division+@Monthfc+' bso
			where ['+@columnName+']>0
			group by
				[Channel],
				[Bundle Code]'+case when @Division='LDB' then ',[Brand],[Category]' else '' end+' '

			--select @sql
			if @debug>0
			begin
				select @sql 'Insert into table bom convert'
			end
			execute(@sql)

			select @currentrow = @currentrow+1
		end

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