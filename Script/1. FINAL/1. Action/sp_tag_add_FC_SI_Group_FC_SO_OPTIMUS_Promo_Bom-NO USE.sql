/*
	declare 
		@b_Success		Int,
		@c_errmsg		Nvarchar(250)

	exec sp_tag_add_FC_SI_Group_FC_SO_OPTIMUS_Promo_Bom 'LDB','202407',@b_Success OUT,@c_errmsg OUT

	select @b_Success b_Success,@c_errmsg c_errmsg

	SELECT * FROM FC_SO_OPTIMUS_Promo_Bom_LDB
*/

Alter Proc sp_tag_add_FC_SI_Group_FC_SO_OPTIMUS_Promo_Bom
	@Division				nvarchar(3),
	@FM_KEY					nvarchar(6),
	@b_Success				Int				OUTPUT,     
	@c_errmsg				Nvarchar(250)	OUTPUT
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
			
	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_tag_add_FC_SI_Group_FC_SO_OPTIMUS_Promo_Bom',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	select @debug=debug from fnc_debug('FC')

	declare 
		@b_Success1				Int,
		@c_errmsg1				Nvarchar(250)
	declare @tablename nvarchar(200) = ''
	select @tablename = 'FC_SO_OPTIMUS_Promo_Bom_'+@Division

	if @n_continue = 1
	begin
		if exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID(@tablename) AND type in (N'U')
		)
		begin
			select @sql = 'drop table '+@tablename
			if @debug>0
			begin
				select @sql '@sql 1.1.1'
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
	if @n_continue = 1
	begin		
		declare @tabletype nvarchar(100)=''
		select @tabletype=case when @Division='LDB' then 'OPTIMUS' else 'FC_SO_OPTIMUS_Promo_Bom' end

		exec sp_add_FC_SI_Group @Division,@FM_KEY,@tabletype,@b_Success1 OUT,@c_errmsg1 OUT
		if @b_Success1 = 0
		begin
			select @n_continue = 3, @c_errmsg = @c_errmsg1
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