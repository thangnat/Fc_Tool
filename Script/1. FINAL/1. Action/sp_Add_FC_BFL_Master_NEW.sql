/*
	Declare
		@b_Success			Int,
		@c_errmsg			Nvarchar(250)

	exec sp_Add_FC_BFL_Master_NEW 'CPD','202502',@b_Success OUT,@c_errmsg OUT

	select @b_Success b_Success,@c_errmsg c_errmsg

	select * from FC_BFL_Master_LLD where [FM_KEY]='202502'
	select * from FC_MasterFile_PPD_Customer_Master where [FM_KEY]='202410'
*/


Alter proc sp_Add_FC_BFL_Master_NEW
	@Division		nvarchar(3),
	@FM_KEY			nvarchar(6),
	@b_Success		Int				OUTPUT,     
	@c_errmsg		Nvarchar(250)	OUTPUT
	with encryption
As
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRY
	DECLARE   
		 @debug					int=0
		,@sp_name				Nvarchar(100)
		,@n_continue			Int
		,@USERS					Nvarchar(50)
		,@MODIFILED				Datetime
		,@n_err					int
		,@sql					nvarchar(max) = ''

	declare 
		@b_Success1				Int,
		@c_errmsg1				Nvarchar(250)

	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_Add_FC_BFL_Master',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()		
	
	declare 
		@Month			nvarchar(2)='',
		@Type			nvarchar(2)='',
		@OnlyTrend		int=0,
		@Active			int=1

	select @debug=debug from fnc_debug('FC')
	--select @debug=1
	
	declare @Monthfc				nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from V_FC_FM_Table

	declare @tableWF nvarchar(200)=''
	select @tableWF='FC_FM_Original_'+@Division+@Monthfc

	if @debug>0
	begin
		select 'create table master fulll'
	end
	if @n_continue=1
	begin
		exec sp_fc_add_fnc_SubGroupMasterFull_New @Division,@FM_KEY,@b_Success1 OUT,@c_errmsg1 OUT
		if @b_Success1=0
		begin
			select @n_continue = 3, @c_errmsg = @c_errmsg1
		end	
	end

	if @debug>0
	begin
		select 'Import BFL Master'
	end
	if @n_continue =1
	begin
		exec sp_Add_FC_BFL_Master @Division,@FM_KEY,@Month,@Type,@OnlyTrend,@b_Success1 OUT,@c_errmsg1 OUT

		if @b_Success1=0
		begin
			select @n_continue = 3, @c_errmsg = @c_errmsg1
		end		
	end

	if @debug>0
	begin
		select 'create table master fulll 2'
	end
	if @n_continue=1
	begin
		exec sp_fc_add_fnc_SubGroupMasterFull_New @Division,@FM_KEY,@b_Success1 OUT,@c_errmsg1 OUT
		if @b_Success1=0
		begin
			select @n_continue = 3, @c_errmsg = @c_errmsg1
		end	
	end

	if @debug>0
	begin
		select 'Import sp_tag_gen_SUBGROUP_VLOOKUP'
	end
	if @n_continue=1
	begin
		exec sp_tag_gen_SUBGROUP_VLOOKUP @Division,@Active,@b_Success1 OUT,@c_errmsg1 OUT
		
		if @b_Success1=0
		begin
			select @n_continue = 3, @c_errmsg = @c_errmsg1
		end	
	end
	if @debug>0
	begin
		select 'Import sp_add_Customer_Master'
	end
	if @n_continue=1
	begin
		exec sp_add_Customer_Master @Division,@FM_KEY,@b_Success1 OUT,@c_errmsg1 OUT
		
		if @b_Success1=0
		begin
			select @n_continue = 3, @c_errmsg = @c_errmsg1
		end	
	end
	

	if @debug>0
	begin
		select 'update value wf fc SI'
	end
	if @n_continue=1
	begin
		if exists
		(
			SELECT * 
			FROM sys.objects 
			WHERE object_id = OBJECT_ID(@tableWF) AND type in (N'U')
		)
		begin
			exec sp_Update_Value_WF_After_Update_Price @Division,@FM_KEY,'ALL',1,@b_Success1 OUT,@c_errmsg1 OUT
		
			if @b_Success1=0
			begin
				select @n_continue = 3, @c_errmsg = @c_errmsg1
			end
		end
	end
	if @debug>0
	begin
		select 'Create sp_Create_SLOB_MAP_PRICE'
	end
	if @n_continue=1
	begin
		exec sp_Create_SLOB_MAP_PRICE @Division,@FM_KEY,@b_Success1 OUT,@c_errmsg1 OUT
		if @b_Success1=0
		begin
			select @n_continue = 3, @c_errmsg = @c_errmsg1
		end
	end
	if @debug>0
	begin
		select 'update value wf fc so'
	end
	if @n_continue=1
	begin
		if @Division='LDB'
		begin
			declare @table_name_fc_so nvarchar(200)=''
			select @table_name_fc_so='FC_SO_FORECAST_'+@Division+@Monthfc

			if exists
			(
				SELECT * 
				FROM sys.objects 
				WHERE object_id = OBJECT_ID(@table_name_fc_so) AND type in (N'U')
			)
			begin
				exec sp_Create_FC_LDB_SO_FORECAST @Division,@FM_KEY,'OPTIMUS', @b_Success1 OUT,@c_errmsg1 OUT
		
				if @b_Success1=0
				begin
					select @n_continue = 1, @c_errmsg = @c_errmsg1
				end
			end
		end
	end
	if @debug>0
	begin
		select 'sp_FC_FM_Original_Add_More_NEW'
	end
	if @n_continue=9
	begin
		exec sp_FC_FM_Original_Add_More_NEW @Division, @FM_KEY, '1', @b_Success1 OUT,@c_errmsg1 OUT
		
		if @b_Success1=0
		begin
			select @n_continue=1, @c_errmsg = @c_errmsg1
		end
	end
	if @debug>0
	begin
		select 'sp_Update_WF_Master'
	end
	if @n_continue=1
	begin
		exec sp_Update_WF_Master @Division, @FM_KEY, @b_Success1 OUT,@c_errmsg1 OUT
		
		if @b_Success1=0
		begin
			select @n_continue=1, @c_errmsg = @c_errmsg1
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