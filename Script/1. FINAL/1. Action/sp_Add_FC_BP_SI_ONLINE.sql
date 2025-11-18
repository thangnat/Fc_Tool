/*
	Declare
		@b_Success			Numeric(18,0),
		@c_errmsg			Nvarchar(250)

	exec sp_Add_FC_BP_SI_ONLINE 'CPD','202411',@b_Success OUT,@c_errmsg OUT

	select @b_Success b_Success,@c_errmsg c_errmsg

	select  * from FC_BP_SI_ONLINE_CPD 
	where [SUB GROUP/ Brand]='AGE REWIND CONCEALER'
*/

Alter proc sp_Add_FC_BP_SI_ONLINE
	@Division		nvarchar(3),
	@FM_KEY			nvarchar(6),
	@b_Success		Numeric(18,0)				OUTPUT,     
	@c_errmsg		Nvarchar(250)	OUTPUT
	with encryption
As
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRY
	DECLARE   
		 @debug					Numeric(18,0)=0
		,@sp_name				Nvarchar(100)
		,@n_continue			Numeric(18,0)
		,@USERS					Nvarchar(50)
		,@MODIFILED				Datetime
		,@n_err					Numeric(18,0)
		,@sql					nvarchar(max) = ''
		,@DbName NVARCHAR(20)

	declare 
		@b_Success1				Numeric(18,0),
		@c_errmsg1				Nvarchar(250)

	SELECT	
		@n_continue=1, 
		@b_success=0,
		@n_err=0,
		@c_errmsg='', 
		@sp_name = 'sp_Add_FC_BP_SI_ONLINE',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()		
		
	select @debug=debug from fnc_debug('FC')

	declare @Monthfc				nvarchar(20)=''
	select @Monthfc=replace([Month FC],'_@Month_FC','_'+@FM_Key) from V_FC_FM_Table

	declare @Tablename				nvarchar(200) = ''
	select @Tablename = 'FC_BP_SI_ONLINE_'+@Division+@Monthfc

	-- Get the environment configuration
	SELECT @DbName = CASE 
		WHEN Value = 'Production' THEN 'master.dbo'
		ELSE 'master_UAT'
	END
	FROM EnvironmentConfig
	WHERE Name = 'Current_Environment'

	if @n_continue=1
	begin
		if @Division IN('CPD')
		begin
			--add tmp file
			IF @DbName = 'master.dbo'
				exec link_37.master.dbo.sp_add_BP_SI_ONLINE_Tmp @Division,@FM_KEY, @b_Success1 OUT, @c_errmsg1 OUT
			ELSE
				exec link_37.master_UAT.dbo.sp_add_BP_SI_ONLINE_Tmp @Division,@FM_KEY, @b_Success1 OUT, @c_errmsg1 OUT

			if @b_Success1=0
			begin
				select @n_continue = 3, @c_errmsg = @c_errmsg1
			end
		end
	end	
	if @n_continue=1
	begin
		if @Division IN('CPD','LDB')
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
					select @sql 'Drop table'
				end
				execute(@sql)
			end
		end
	end
	begin tran
	if @n_continue=1
	begin
		if @Division='CPD'
		begin
			select @sql='
			select 
				Filename=t.[Filename],
				[Product Type]=s.[Product Type],
				[SUB GROUP/ Brand]=s.[SUB GROUP/ Brand],
				[Channel]=''ONLINE'',
				[Time series]=''7. BP Unit'',
				[Y0 (u) M1]=sum(cast(replace(replace(t.[Y0 (u) M1],'','',''''),''-'',''0'') as float)),
				[Y0 (u) M2]=sum(cast(replace(replace(t.[Y0 (u) M2],'','',''''),''-'',''0'') as float)),
				[Y0 (u) M3]=sum(cast(replace(replace(t.[Y0 (u) M3],'','',''''),''-'',''0'') as float)),
				[Y0 (u) M4]=sum(cast(replace(replace(t.[Y0 (u) M4],'','',''''),''-'',''0'') as float)),
				[Y0 (u) M5]=sum(cast(replace(replace(t.[Y0 (u) M5],'','',''''),''-'',''0'') as float)),
				[Y0 (u) M6]=sum(cast(replace(replace(t.[Y0 (u) M6],'','',''''),''-'',''0'') as float)),
				[Y0 (u) M7]=sum(cast(replace(replace(t.[Y0 (u) M7],'','',''''),''-'',''0'') as float)),
				[Y0 (u) M8]=sum(cast(replace(replace(t.[Y0 (u) M8],'','',''''),''-'',''0'') as float)),
				[Y0 (u) M9]=sum(cast(replace(replace(t.[Y0 (u) M9],'','',''''),''-'',''0'') as float)),
				[Y0 (u) M10]=sum(cast(replace(replace(t.[Y0 (u) M10],'','',''''),''-'',''0'') as float)),
				[Y0 (u) M11]=sum(cast(replace(replace(t.[Y0 (u) M11],'','',''''),''-'',''0'') as float)),
				[Y0 (u) M12]=sum(cast(replace(replace(t.[Y0 (u) M12],'','',''''),''-'',''0'') as float)),
				[Y+1 (u) M1]=sum(cast(replace(replace(t.[Y+1 (u) M1],'','',''''),''-'',''0'') as float)),
				[Y+1 (u) M2]=sum(cast(replace(replace(t.[Y+1 (u) M2],'','',''''),''-'',''0'') as float)),
				[Y+1 (u) M3]=sum(cast(replace(replace(t.[Y+1 (u) M3],'','',''''),''-'',''0'') as float)),
				[Y+1 (u) M4]=sum(cast(replace(replace(t.[Y+1 (u) M4],'','',''''),''-'',''0'') as float)),
				[Y+1 (u) M5]=sum(cast(replace(replace(t.[Y+1 (u) M5],'','',''''),''-'',''0'') as float)),
				[Y+1 (u) M6]=sum(cast(replace(replace(t.[Y+1 (u) M6],'','',''''),''-'',''0'') as float)),
				[Y+1 (u) M7]=sum(cast(replace(replace(t.[Y+1 (u) M7],'','',''''),''-'',''0'') as float)),
				[Y+1 (u) M8]=sum(cast(replace(replace(t.[Y+1 (u) M8],'','',''''),''-'',''0'') as float)),
				[Y+1 (u) M9]=sum(cast(replace(replace(t.[Y+1 (u) M9],'','',''''),''-'',''0'') as float)),
				[Y+1 (u) M10]=sum(cast(replace(replace(t.[Y+1 (u) M10],'','',''''),''-'',''0'') as float)),
				[Y+1 (u) M11]=sum(cast(replace(replace(t.[Y+1 (u) M11],'','',''''),''-'',''0'') as float)),
				[Y+1 (u) M12]=sum(cast(replace(replace(t.[Y+1 (u) M12],'','',''''),''-'',''0'') as float))
				INTO '+@Tablename+'
			from '+@DbName+'.FC_BP_SI_ONLINE_'+@Division+@Monthfc+'_Tmp t
			inner join
			(
				select DISTINCT
					[Barcode],
					[SUB GROUP/ Brand],
					[Product Type]
				from fnc_SubGroupMaster('''+@Division+''','''')
			) s on s.Barcode = t.ean
			Group by
				t.[Filename],
				s.[SUB GROUP/ Brand],
				s.[Product Type] '

			if @debug>0
			begin
				select @sql 'insert file tmp'
			end
			execute(@sql)
			
		end
		else if @Division='LDB'
		begin
			declare @listcolumn_bundle nvarchar(max)=''
			SELECT @listcolumn_bundle=ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'3. Promo Qty(BOM)','')
			--SELECT listcolumn_bundle=ListColumn FROM fn_FC_GetColheader_Current('202406','3. Promo Qty(BOM)','')
			
			declare @listcolumn_normal nvarchar(max)=''
			SELECT @listcolumn_normal=ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'updateForecast','t')
			--SELECT listcolumn_normal=ListColumn FROM fn_FC_GetColheader_Current('202406','updateForecast','t')
			
			declare @listcolumn_sum nvarchar(max)=''
			SELECT @listcolumn_sum=ListColumn FROM fn_FC_GetColheader_Current(@FM_KEY,'6. Total Qty','x1')
			--SELECT listcolumn_sum=ListColumn FROM fn_FC_GetColheader_Current('202406','updateForecast','t')

			select @sql='
			select
				[FileName]=x1.[FileName],
				[Barcode]=x1.[Barcode],
				[Material]=x1.[Material],
				[Product Type]=x1.[Product Type],
				[SUB GROUP/ Brand]=s.[SUB GROUP/ Brand],
				[Channel]=x1.[Channel],
				[Time series]=x1.[Time series],
				'+@listcolumn_sum+'
				Numeric(18,0)O '+@Tablename+'
			from
			(
				select 
					[FileName]='''',
					[Barcode]=m.[EAN / UPC],
					[Material]=t.Material,
					[Product Type]=t.[Product Type],
					[SUB GROUP/ Brand]=t.[SUB GROUP/ Brand],
					[Channel]=t.Channel,
					[Time series]=t.[Time series],'+
					@listcolumn_normal+'
				from '+@DbName+'.FC_SI_OPTIMUS_NORMAL_'+@Division+@Monthfc+'_Tmp_OK t
				inner join
				(
					select DISTINCT
						[EAN / UPC],
						[Material]
					from SC1.dbo.MM_ZMR54OLD_Stg (NOLOCK)
					where [Sales  Org]=''V400''
				) m on m.Material=t.Material
				where Channel=''ONLINE''
				Union all
				select
					*
				from
				(
					select
						[FileName]=t.[FileName],
						Barcode=z.Barcode_Component,
						Material=z.Material_Component,
						[Product Type]=t.[Product Type],
						[SUB GROUP/ Brand]=t.[SUB GROUP/ Brand],
						[Channel]=t.Channel,
						[Time series]=t.[Time series],
						'+@listcolumn_bundle+'
					from '+@DbName+'.FC_SI_OPTIMUS_bundle_'+@Division+@Monthfc+'_Tmp_OK t
					inner join
					(
						select DISTINCT
							[EAN / UPC],
							[Material]
						from SC1.dbo.MM_ZMR54OLD_Stg (NOLOCK)
						where [Sales  Org]=''V400''
					) m on m.Material=t.Material
					inner join
					(
						select
							Barcode_Bom,
							Barcode_Component,
							Material_Bom,
							Material_Component,
							CQty=Qty
						from V_ZMR32
						where Division='''+@Division+'''
					) z on z.Barcode_Bom=m.[EAN / UPC]
					where Channel=''ONLINE''
					group by
						t.[FileName],
						z.Material_Component,
						z.Barcode_Component,
						t.[Product Type],
						t.[SUB GROUP/ Brand],
						t.Channel,
						t.[Time series]
				) as b
			) as x1
			left join
			(
				select distinct
					Barcode,
					[SUB GROUP/ Brand]
				from fnc_SubGroupMaster('''+@Division+''',''full'')
			) s on s.Barcode=x1.[Barcode]
			group by
				x1.[FileName],
				x1.[Barcode],
				x1.[Material],
				x1.[Product Type],
				s.[SUB GROUP/ Brand],
				x1.[Channel],
				x1.[Time series] '

			if @debug>0
			begin
				select @sql 'SI LDB combine Normal+Bundle'
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