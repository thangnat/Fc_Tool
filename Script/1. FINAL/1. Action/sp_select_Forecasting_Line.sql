
/*
	declare
		@b_Success				Int,
		@c_errmsg				Nvarchar(250)
	

	exec sp_select_Forecasting_Line 'CPD','FIT ME FDT BOX 5ML PLV','s',@b_Success OUT,@c_errmsg OUT

	select @b_Success b_Success,@c_errmsg c_errmsg

	select * from FC_FM_SUbgrp_Selected
*/
Alter Proc sp_select_Forecasting_Line
	@Division				nvarchar(3),
	@Subgrp					nvarchar(500),
	@Type					nvarchar(1),--//s: source/d: destination
	@b_Success				Int				OUTPUT,     
	@c_errmsg				Nvarchar(250)	OUTPUT
As
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRAN
BEGIN TRY
	DECLARE   
		 @debug					INT=0
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
		@sp_name = 'sp_select_Forecasting_Line',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	declare @tableName nvarchar(300)='FC_FM_SUbgrp_Selected'

	if @n_continue = 1
	begin
		if @Type='s'
		begin
			if not exists
			(
				SELECT * 
				FROM sys.objects 
				WHERE object_id = OBJECT_ID(@tableName) AND type in (N'U')
			)
			begin
				select @sql=
				'create table '+@tableName+'
				(
					[Division]			nvarchar(3) null,
					[SUB GROUP/ Brand]	nvarchar(500) null
				) '
				if @debug>0
				begin
					select 'Create new table selected subgrp'
				end
				execute(@sql)

			end
			if not exists
			(
				select 1 from FC_FM_SUbgrp_Selected 
				where 
					[Division]=@Division 
				and [SUB GROUP/ Brand]=@Subgrp
			)
			begin
				select @sql=
				'insert into '+@tableName+
				' select 
					[Division]='''+@Division+''',
					[SUB GROUP/ Brand]='''+replace(@Subgrp,'''','''''')+''' '

				if @debug>0
				begin
					select @sql 'Insert table selected subgrp'
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
	end	
	if @n_continue=1
	begin
		if @Type='d'
		begin
			select @sql='delete '+@tableName+' where [SUB GROUP/ Brand]='''+replace(@Subgrp,'''','''''')+''' '
			if @debug>0
			begin
				select @sql 'Delete table selected subgrp'
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
   ROLLBACK
   DECLARE @ErrorMessage VARCHAR(2000)
   SELECT @ErrorMessage = 'Error: '+ ERROR_MESSAGE()
   RAISERROR(@ErrorMessage , 16, 1)
END CATCH