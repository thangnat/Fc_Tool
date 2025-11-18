/*
	Declare
		@b_Success			Int,
		@c_errmsg			Nvarchar(250)

	exec sp_Create_FC_SI_GROUP 'LDB','202502','FC_SI_FOC_SINGLE',@b_Success OUT,@c_errmsg OUT

	select @b_Success b_Success,@c_errmsg c_errmsg
	/*
	--//Type
	1. FC_SI_Promo_Bom
	2. FC_SO_OPTIMUS_Promo_Bom
	3. FC_SO_OPTIMUS_NORMAL
	7. OPTIMUS -->LDB 
	4. FC_SI_Promo_Single
	5. FC_SI_Launch_Single
	6. FC_SI_FOC
	
	*/
		select * from FC_SI_Promo_Bom_PPD_202410-->header
		select * from FC_SO_OPTIMUS_Promo_Bom_PPD_202410
		select * from FC_SO_OPTIMUS_NORMAL_CPD
		select * from FC_SI_Promo_Single_CPD
		select * from FC_SI_Launch_Single_CPD
		select * from FC_SI_FOC_LLD

		select * from FC_SO_OPTIMUS_Promo_Bom_LLD_202502
		select * from FC_SO_OPTIMUS_NORMAL_LLD_202502
*/

Alter proc sp_Create_FC_SI_GROUP
	@Division		nvarchar(3),
	@FM_KEY			Nvarchar(6),
	@TableName		Nvarchar(100),
	@b_Success		Int				OUTPUT,     
	@c_errmsg		Nvarchar(250)	OUTPUT
	with encryption
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
		,@DbName NVARCHAR(20)

	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_Create_FC_SI_GROUP',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	-- Get the environment configuration
	SELECT @DbName = CASE 
		WHEN Value = 'Production' THEN 'master.dbo'
		ELSE 'master_UAT'
	END
	FROM EnvironmentConfig
	WHERE Name = 'Current_Environment'

	declare
		 @fromdate				date
		,@todate				date

	declare	@full				Nvarchar(4) = 'full'	

	select @debug=debug from fnc_Debug('FC')
	--select @debug=1

	declare @Monthfc				nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from V_FC_FM_Table

	--select @full = 'full'--case when isnull([Only run active],0)=1 then '' else 'full' end from V_FC_SUBGROUP_ACTIVE	

	declare @SaleOrg				nvarchar(5) = ''
	select @SaleOrg = case
						when @Division = 'LLD' then 'V100'
						when @Division = 'CPD' then 'V200'
						when @Division = 'PPD' then 'V300'
						when @Division = 'LDB' then 'V400'
						else ''
					end

	declare @tablename_ok					nvarchar(100) = ''
	select @tablename_ok = CASE 
								WHEN @TableName='OPTIMUS' THEN 'FC_SO_OPTIMUS_NORMAL' 
								ELSE @TableName 
						END+'_'+@Division+@Monthfc
	if @debug>0
	begin
		select @tablename_ok '@tablename_ok'
	end

	declare @tablename_BUNDLE_OK		nvarchar(100) = ''
	SELECT @tablename_BUNDLE_OK = 'FC_SO_OPTIMUS_Promo_Bom_'+@Division+@Monthfc
	if @debug>0
	begin
		select @tablename_BUNDLE_OK '@tablename_BUNDLE_OK'
	end
	
	declare @listcolumn_plus nvarchar(max) = ''
	select @listcolumn_plus = ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'1. Baseline Qty_+','x')
	--select listcolumn_plus = ListColumn FROM fn_FC_GetColheader_Current('202406','1. Baseline Qty_+','b1')

	if @n_continue =1
	begin
		declare @table_tmp		nvarchar(100) = ''
		SELECT @table_tmp = @tablename_ok+'_Tmp'
		if @debug>0
		begin
			select @table_tmp '@table_tmp'
		end

		declare @tmp1 table(id int identity(1,1),Table_name nvarchar(50), Column_Name nvarchar(50))
		if @DbName = 'master.dbo'
			insert into @tmp1(Table_name,Column_Name)
			exec link_37.master.dbo.sp_getColumCount @table_tmp
		ELSE
			insert into @tmp1(Table_name,Column_Name)
			exec link_37.master_UAT.dbo.sp_getColumCount @table_tmp
		if @debug >0
		begin
			select tablename='@tmp1',* from @tmp1
		end

		BEGIN TRAN
		declare @result					nvarchar(max) = ''
		SELECT @result = ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'FOCColumn',',')
		--SELECT result = ListColumn FROM fn_FC_GetColheader_Current('202405','FOCColumn',',')
		
		declare @result_bom					nvarchar(max) = ''
		SELECT @result_bom = ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'BomColumn',',')
		--SELECT result_bom = ListColumn FROM fn_FC_GetColheader_Current('202405','BomColumn',',')		

		if @TableName ='OPTIMUS'
		BEGIN
			declare @listcolumn_optimus_plus nvarchar(max) = ''
			select @listcolumn_optimus_plus = ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'optimus_+','x')
			--select listcolumn_optimus_plus = ListColumn FROM fn_FC_GetColheader_Current('202408','optimus_+','x')

			declare @listcolumn_optimus_bundle nvarchar(max) = ''
			select @listcolumn_optimus_bundle = ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'optimus_Bundle','x')
			--select listcolumn_optimus_bundle = ListColumn FROM fn_FC_GetColheader_Current('202406','optimus_bundle','x')

			declare @listcolumn_optimus_normal nvarchar(max) = ''
			select @listcolumn_optimus_normal = ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'optimus_normal','x')
			--select listcolumn_optimus_normal = ListColumn FROM fn_FC_GetColheader_Current('202406','optimus_normal','x')

			declare @result_optimus nvarchar(max) = ''
			SELECT @result_optimus = ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'optimus',',')
			--SELECT result_optimus = ListColumn FROM fn_FC_GetColheader_Current('202408','optimus',',')

			IF @Division='LDB'
			begin
				if @n_continue=1
				begin
					--//normal
					if exists
					(
						SELECT * 
						FROM sys.objects 
						WHERE object_id = OBJECT_ID(@tablename_ok) AND type in (N'U')
					)
					begin
						select @sql  ='Drop table '+@tablename_ok
						if @debug>0
						begin
							select @sql '@sql drop table single optimus'
						end
						execute(@sql)
					end
			
					--/INSERT NORMAL
					select @sql =
					'select
						*
						INTO '+@tablename_ok+'
					from
					(
						Select
							FMKEY = '''+@FM_KEY+''',
							*
						from '+@DbName+'.'+@tablename_ok+'_Tmp_OK
						where [Sell-Out Units]<>0
					) as x '

					if @debug >0
					begin
						select @sql '@sql Insert single optimus'
					end
					execute(@sql)

					--//bundle
					if exists
					(
						SELECT * 
						FROM sys.objects 
						WHERE object_id = OBJECT_ID(@tablename_BUNDLE_OK) AND type in (N'U')
					)
					begin
						select @sql  ='drop table '+@tablename_BUNDLE_OK
						if @debug>0
						begin
							select @sql '@sql drop table bundle optimus'
						end
						execute(@sql)
					end

					/*INSERT BOM*/
					select @sql=
					'select
						*
						INTO '+@tablename_BUNDLE_OK+'
					from
					(
						select
							FM_KEY = '''+@FM_KEY+''',
							[Filename],
							[Signature] = t.[Signature],	
							[Bundle Code]=[Barcode],		
							[Product Type] = t.[Type],
							[Channel] = t.[Channel],
							Brand,
							Category,'
							+@result_optimus+'					
						from '+@DbName+'.'+@tablename_BUNDLE_OK+'_Tmp_OK t
					) as x
					where ('+@listcolumn_optimus_plus+')<>0'

					if @debug>0
					begin
						select @sql '@sql insert Bundle optimus'
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
			ELSE if @Division IN('CPD','LLD','PPD')
			BEGIN
				--NORMAL
				--drop table normal
				if exists
				(
					SELECT * 
					FROM sys.objects 
					WHERE object_id = OBJECT_ID(@tablename_ok) AND type in (N'U')
				)
				begin
					select @sql  ='Drop table '+@tablename_ok
					if @debug>0
					begin
						select @sql '@sql Drop table single optimus'
					end
					execute(@sql)
				end
				
				select @sql =
				'select
					*
					INTO '+@tablename_ok+'
				from
				(
					Select
						FMKEY = '''+@FM_KEY+''',
						*
					from '+@DbName+'.'+@tablename_ok+'_Tmp
				) as x '
				/*where ('+@listcolumn_plus+')<>0'*/
				if @debug >0
				begin
					select @sql '@sql Insert sinle optimus'
				end
				execute(@sql)
				
				--BUNDLE
				if exists
				(
					SELECT * 
					FROM sys.objects 
					WHERE object_id = OBJECT_ID(@tablename_BUNDLE_OK) AND type in (N'U')
				)
				begin
					select @sql  ='drop table '+@tablename_BUNDLE_OK
					if @debug>0
					begin
						select @sql '@sql Drop Bundle optimus'
					end
					execute(@sql)
				end
						
				select @sql =
				'select
					*
					INTO '+@tablename_BUNDLE_OK+'
				from
				(
					select
						FM_KEY = '''+@FM_KEY+''',
						[Filename],
						[Signature] = t.[Signature],	
						[Bundle Code],		
						[Product Type] = t.[Type],
						[Channel] = t.[Channel],'
						+@result_optimus+'					
					from '+@DbName+'.'+@tablename_BUNDLE_OK+'_Tmp t
				) as x
				/*where ('+@listcolumn_optimus_plus+')<>0*/ '

				if @debug>0
				begin
					select @sql '@sql Insert bundle optimus'
				end
				execute(@sql)

				select @n_err = @@ERROR
				if @n_err<>0
				begin
					select @n_continue = 3
					--select @n_err=60003
					select	@c_errmsg = 'NSQL'+CONVERT(char(5),@n_err) +ERROR_MESSAGE()+'./ ('+@sp_name+')'
				end				
			END
		END
		ELSE IF CHARINDEX('Bom',@tablename_ok,0)>0
		begin
			--select 'bom template'
			if exists
			(
				SELECT * 
				FROM sys.objects 
				WHERE object_id = OBJECT_ID(@tablename_ok) AND type in (N'U')
			)
			begin
				select @sql  ='drop table '+@tablename_ok
				if @debug>0
				begin
					select @sql '@sql Drop bundle promo bom'
				end
				execute(@sql)
			end

			select @sql =
			'select
				*
				INTO '+@tablename_ok+'
			from
			(
				select
					FM_KEY = '''+@FM_KEY+''',
					[Filename],
					[Signature] = t.[Signature],
					[Cat],		
					[Bundle Code],
					[Product Type] = t.[Type],
					[Channel] = t.[Channel],
					[Time series] = ''3. Promo Qty(BOM)'','
					+@result_bom+'
				from '+@DbName+'.'+@tablename_ok+'_Tmp t
			) as x
			where ('+@listcolumn_plus+')<>0'

			if @debug>0
			begin
				select @sql '@sql Insert promo bom'
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
		else
		begin
			select 'single template'
			if exists
			(
				SELECT * 
				FROM sys.objects 
				WHERE object_id = OBJECT_ID(@tablename_ok) AND type in (N'U')
			)
			begin
				select @sql  ='drop table '+@tablename_ok
				if @debug>0
				begin
					select @sql '@sql Drop sinle'
				end
				execute(@sql)
			end
		
			select @sql =
			'select
				*
				INTO '+@tablename_ok+' 
			from
			(
				select
					FM_KEY = '''+@FM_KEY+''',
					[Filename],
					[Signature] = s.[Signature],
					[Code],
					[Product Type] = t.[Type],
					[SubGrp] = t.[Forecasting Line],
					[Channel] = t.[Channel],
					[Time series] = t1.MAP,
					[Remark],
					'+@result+'
				from '+@DbName+'.'+@tablename_ok+'_Tmp t 
				Left join 
				(
					Select 
						* 
					from V_FC_TIME_SERIES
				) t1 on t1.TimeSeries = t.[Time Series]
				Left join 
				(
					select DISTINCT 
						[SUB GROUP/ Brand],
						[Signature],
						[TYPE] 
					from fnc_SubGroupMaster('''+@Division+''','''+@full+''')
				) s on s.[SUB GROUP/ Brand] = t.[Forecasting Line]
			) as x
			where ('+@listcolumn_plus+')<>0'		
			
			if @debug>0
			begin
				select @sql '@sql Insert single'
			end
			execute(@sql)
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