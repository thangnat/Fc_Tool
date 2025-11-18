/*
	Declare 
		@b_Success			Int,
		@c_errmsg			Nvarchar(250)

	exec sp_fc_convert_SO_LDB 'LDB','202409',0,@b_Success OUT, @c_errmsg OUT

	select @b_Success b_Success, @c_errmsg c_errmsg

	select * from FC_SO_OPTIMUS_NORMAL_LDB_202409_ALL_Tmp
	select * from FC_SO_OPTIMUS_NORMAL_LDB_ALL_Tmp
	--truncate table FC_SO_OPTIMUS_NORMAL_LDB_ALL_Tmp
	--where filename='Online_VIC_FC_SO_OPTIMUS_NORMAL_202407.xlsx'
	select * from FC_SO_OPTIMUS_bundle_LDB_Tmp_OK
	select * from FC_SO_OPTIMUS_NORMAL_LDB_Tmp_OK
*/

Create or Alter proc sp_fc_convert_SO_LDB
	@division			nvarchar(3),
	@FM_KEY				nvarchar(6),
	@AddMore			INT,
	@b_Success			Int				OUTPUT,     
	@c_errmsg			Nvarchar(250)	OUTPUT
	with encryption
As
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRY
	DECLARE   
		 @debug					int=1
		,@sp_name				Nvarchar(100)
		,@n_continue			Int
		,@USERS					Nvarchar(50)
		,@MODIFILED				Datetime
		,@n_err					int
		,@sql					nvarchar(max)=''

	declare 
		@b_Success1				Int,
		@c_errmsg1				Nvarchar(250)

	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_fc_convert_SO_LDB',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()
	declare @SharefolderPath nvarchar(500)
	select @SharefolderPath = Value from [SC2].[dbo].[EnvironmentConfig] where Name = 'Sharefolder_SAP_Dir'

	declare @startyear int = 0
	select @startyear = cast(left(@FM_KEY,4) as int)

	declare @Monthfc				nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from link_33.sc2.dbo.V_FC_FM_Table

	declare @FC_SO_OPTIMUS_NORMAL_LDB_Tmp			nvarchar(200)=''
	select @FC_SO_OPTIMUS_NORMAL_LDB_Tmp = 'FC_SO_OPTIMUS_NORMAL_'+@division+@Monthfc+'_Tmp'

	declare @FC_SO_OPTIMUS_NORMAL_LDB_ALL_Tmp		nvarchar(200)=''
	select @FC_SO_OPTIMUS_NORMAL_LDB_ALL_Tmp ='FC_SO_OPTIMUS_NORMAL_'+@division+@Monthfc+'_ALL_Tmp'

	--//get data from all files to  table FC_SO_OPTIMUS_NORMAL_LDB_ALL_Tmp
	if @debug>0
	begin
		select 'create table ALL'
	end
	declare @currentrows1 int = 1, @totalrows1 int =0
	IF @n_continue=1
	BEGIN
		declare @fullpath nvarchar(4000)=''
		select @fullpath=@SharefolderPath +'\Pending\FORECAST\LDB\OPTIMUS\'+@FM_KEY+'\'

		--exec link_33.sc2.dbo.sp_getlistfiles @fullpath,'OLD'
		exec sp_getlistfiles @fullpath,'OLD'
		--select @totalrows1=isnull(count(*),0) from link_33.sc2.dbo.LDB_ListFile_Optimus where CHARINDEX(@FM_KEY,[filename])>0
		select @totalrows1=isnull(count(*),0) from LDB_ListFile_Optimus where CHARINDEX(@FM_KEY,[filename])>0
		select @totalrows1 '@totalrows1'

		if @AddMore=0
		begin
			if exists
			(
				SELECT * 
				FROM sys.objects 
				WHERE object_id = OBJECT_ID(@FC_SO_OPTIMUS_NORMAL_LDB_ALL_Tmp) AND type in (N'U')
			)
			begin
				select @sql = 'drop table '+@FC_SO_OPTIMUS_NORMAL_LDB_ALL_Tmp
				if @debug>0
				begin
					select @sql '@sql drop table'
				end
				execute(@sql)
			end
			select @sql=
			'select top 1 * INTO '+@FC_SO_OPTIMUS_NORMAL_LDB_ALL_Tmp+' from FC_SO_OPTIMUS_NORMAL_LDB_ALL_Tmp
					
			truncate table '+@FC_SO_OPTIMUS_NORMAL_LDB_ALL_Tmp

			if @debug>0
			begin
				select @sql 'tao table ALL'
			end
			execute(@sql)
		end
		if @totalrows1>0
		begin
			if 
			(
				select cast(x.Run_Optimus as int) 
				from 
				(
					select Run_Optimus=isnull(Config23,'0') 
					from link_33.sc2.dbo.SysConfigValue 
					where ConfigHeaderID=48 and Config1='tag_add_FC_SI_Group_FC_SO_OPTIMUS'
				) as x
			)=1
			begin
				--exec link_33.sc2.dbo.sp_getlistfiles @fullpath,'OLD'
				exec sp_getlistfiles @fullpath,'OLD'
				--select * from link_33.sc2.dbo.LDB_ListFile_Optimus
				declare @result_error		nvarchar(max)=''
				--select * from FC_SO_OPTIMUS_NORMAL_LDB_ALL_Tmp
				
				while (@currentrows1<=@totalrows1)
				begin
					declare @filename_ok nvarchar(500)=''

					--select @filename_ok=[filename] 
					--from link_33.sc2.dbo.LDB_ListFile_Optimus 
					--where id=@currentrows1
					select @filename_ok=[filename] 
					from LDB_ListFile_Optimus 
					where id=@currentrows1

					if @debug>0
					begin
						select @filename_ok '@filename_ok'
					end

					exec sp_add_FC_SO_OPTIMUS_NORMAL_LDB_Tmp @Division,@FM_KEY,@filename_ok,@b_Success1 OUT,@c_errmsg1 OUT

					IF @b_Success1=0
					BEGIN
						--select 'error'
						SELECT @result_error=@result_error+@c_errmsg1
					END
					else
					begin
						--select * from FC_SO_OPTIMUS_NORMAL_LDB_ALL_Tmp
						select @sql=
						'insert into '+@FC_SO_OPTIMUS_NORMAL_LDB_ALL_Tmp+'
						select 
							*
						from '+@FC_SO_OPTIMUS_NORMAL_LDB_Tmp

						if @debug>0
						begin
							select @sql 'Insert into FC_SO_OPTIMUS_NORMAL_LDB_ALL_Tmp'
						end
						execute(@sql)
					end

					select @currentrows1=@currentrows1+1
				end

				if len(@result_error)>0
				begin
					SELECT @n_continue=1,@c_errmsg=@result_error
				END
			end
		end
	END
	--select @c_errmsg '@c_errmsg'
	if @n_continue=1
	begin
		if @totalrows1>0
		begin
			exec sp_fc_convert_SO_LDB_SO @division,@FM_KEY,@b_Success1 OUT, @c_errmsg1 OUT

			if @b_Success1=0
			begin
				select @n_continue=3,@c_errmsg=@c_errmsg1
			end
			IF @n_continue=9
			BEGIN
				exec sp_fc_convert_SO_LDB_SI @division,@FM_KEY,@b_Success1 OUT, @c_errmsg1 OUT

				if @b_Success1=0
				begin
					select @n_continue=3,@c_errmsg=@c_errmsg1
				end	
			END
		end
	END

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