/*
	declare 
		@b_Success				Int,
		@c_errmsg				Nvarchar(250)

	exec sp_tag_update_wf_git 'LDB','202412',@b_Success OUT, @c_errmsg OUT

	select @b_Success b_Success, @c_errmsg c_errmsg
*/

Alter Proc sp_tag_update_wf_git
	@Division				nvarchar(3),
	@FM_KEY					nvarchar(6),
	@b_Success				Int				OUTPUT,     
	@c_errmsg				Nvarchar(250)	OUTPUT
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
		@sp_name = 'sp_tag_update_wf_git',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()
	
	select @debug=debug from fnc_debug('FC')
	--select @debug=1

	declare @Monthfc				nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from V_FC_FM_Table

	declare @FC_FM_Original			nvarchar(100) = ''
	select @FC_FM_Original = 'FC_FM_Original_'+@Division+@Monthfc

	declare @list_signature nvarchar(500)=''
	declare @Type_View nvarchar(20)=''

	if @debug>0
	begin
		select 'get signature run'
	end
	if @n_continue=1
	begin
		select 
			@list_signature=[List_Signature],
			@Type_View=[type_View] 
		from fnc_get_List_Signature('tag_gen_git')
		--and Tag_name='tag_gen_git'

		if @list_signature is null
		begin
			select @list_signature=''
		end
		if @Type_View is null
		begin
			select @Type_View=''
		end
	end
	if @n_continue=1
	begin
		if @Type_View='re-gen'
		begin
			if @list_signature=''
			begin
					select @n_continue = 3
				select @n_err=60001
				select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +':Signature should be not null./ ('+@sp_name+')'
			end
		end
	end	

	if @debug>0
	begin
		select @FC_FM_Original '@FC_FM_Original'
	end
	if @n_continue = 1
	begin
		if @debug>0
		begin
			select 'Set zero'
		end
		if @Type_View=''
		begin
			select @sql=
			'update '+@FC_FM_Original+'
			set 
				[GIT M0] = 0,
				[GIT M1] = 0,
				[GIT M2] = 0,
				[GIT M3] = 0,
				[Total GIT]=0 
			where [Channel] IN(''ONLINE'',''OFFLINE'',''O+O'')'
		end
		else
		begin
			select @sql=
			'update '+@FC_FM_Original+'
			set 
				[GIT M0] = 0,
				[GIT M1] = 0,
				[GIT M2] = 0,
				[GIT M3] = 0,
				[Total GIT]=0 
			where 
				[Channel] IN(''ONLINE'',''OFFLINE'',''O+O'')
			and [Signature] IN(select value from string_split('''+@list_signature+''','',''))'
		end
		
		if @debug>0
		begin
			select @sql 'SET ZERO'
		end
		execute(@sql)

		if @debug>0
		begin
			select @sql 'UPDATE GIT'
		end
		if @Type_View=''
		begin
			select @sql = 
			'Update '+@FC_FM_Original+'
			SET
				 [GIT M0] = x.[GIT M0]
				,[GIT M1] = x.[GIT M1]
				,[GIT M2] = x.[GIT M2]
				,[GIT M3] = x.[GIT M3]
				,[Total GIT] = x.[GIT M0]+x.[GIT M1]+x.[GIT M2]+x.[GIT M3]
			from '+@FC_FM_Original+' f1
			inner join
			(
				select
					f.[Product Type],
					f.[SUB GROUP/ Brand],
					f.[Channel],
					f.[Time series],
					[GIT M0] = isnull(g.[GIT M0],0),
					[GIT M1] = isnull(g.[GIT M1],0),
					[GIT M2] = isnull(g.[GIT M2],0),
					[GIT M3] = isnull(g.[GIT M3],0)
				from '+@FC_FM_Original+' f
				left join FC_GIT_FINAL_'+@Division+@Monthfc+' g on 
						g.[SUB GROUP/ Brand] = f.[SUB GROUP/ Brand] 
					and g.[Product Type] = f.[Product Type] 
					and f.Channel = g.channel 
				where Right(f.[Time series],9) = ''Total Qty''
			) as x on 
					x.[SUB GROUP/ Brand] = f1.[SUB GROUP/ Brand] 
				and x.[Product Type] = f1.[Product Type] 
				and x.[Channel] = f1.[Channel]
			where right(f1.[Time series],9) = ''Total Qty'' '
		end
		else
		begin
			select @sql = 
			'Update '+@FC_FM_Original+'
			SET
				 [GIT M0] = x.[GIT M0]
				,[GIT M1] = x.[GIT M1]
				,[GIT M2] = x.[GIT M2]
				,[GIT M3] = x.[GIT M3]
				,[Total GIT] = x.[GIT M0]+x.[GIT M1]+x.[GIT M2]+x.[GIT M3]
			from '+@FC_FM_Original+' f1
			inner join
			(
				select
					f.[Product Type],
					f.[SUB GROUP/ Brand],
					f.[Channel],
					f.[Time series],
					[GIT M0] = isnull(g.[GIT M0],0),
					[GIT M1] = isnull(g.[GIT M1],0),
					[GIT M2] = isnull(g.[GIT M2],0),
					[GIT M3] = isnull(g.[GIT M3],0)
				from '+@FC_FM_Original+' f
				left join FC_GIT_FINAL_'+@Division+@Monthfc+' g on 
						g.[SUB GROUP/ Brand] = f.[SUB GROUP/ Brand] 
					and g.[Product Type] = f.[Product Type] 
					and f.Channel = g.channel 
				where Right(f.[Time series],9) = ''Total Qty''
			) as x on 
					x.[SUB GROUP/ Brand] = f1.[SUB GROUP/ Brand] 
				and x.[Product Type] = f1.[Product Type] 
				and x.[Channel] = f1.[Channel]
			where 
				right(f1.[Time series],9) = ''Total Qty''
			and f1.[Signature] IN(select value from string_split('''+@list_signature+''','',''))'
		end

		if @debug>0
		begin
			select @sql 'UPDATE GIT'
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