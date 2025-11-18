--select * from FC_LIST_BOM_HEADER_ONLINE_LDB
/*
	exec sp_Get_Bom_raw_Component 'LDB','202407','bom_template'

	SELECT * FROM Bom_raw_Component_LDB
*/

Alter proc sp_Get_Bom_raw_Component
	@Division	nvarchar(3),
	@FM_Key		nvarchar(6),
	@TableName	nvarchar(20)
	with encryption
As
begin
	declare @debug		int=0
	declare @tablename_Bom_raw_Component	nvarchar(200)=''
	declare @TableName_ok nvarchar(200)=''
	select @debug=isnull(Debug,0) from fnc_debug('FC')

	declare @sql nvarchar(max)=''
	select @tablename_Bom_raw_Component = 'Bom_raw_Component_'+@Division
	/*FC_LIST_BOM_HEADER_ONLINE_LDB,FC_LIST_BOM_HEADER_OFFLINE_LDB,FC_SI_Promo_Bom_LDB   */

	declare @listcolumn nvarchar(max)=''
	select @listcolumn=ListColumn from fn_FC_GetColheader_Current(@FM_Key,'3. Promo Qty(BOM)','x')
	--select listcolumn = ListColumn from fn_FC_GetColheader_Current('202407','3. Promo Qty(BOM)','x')
	
	select @TableName_ok=case 
							when @TableName='FM_BOM_ONLINE' then 'FC_LIST_BOM_HEADER_ONLINE_'+@Division
							when @TableName='FM_BOM_OFFLINE' then 'FC_LIST_BOM_HEADER_OFFLINE_'+@Division
							when @TableName='BOM_TEMPLATE' then 'FC_SI_Promo_Bom_'+@Division
						end
	select @debug=debug from fnc_Debug('FC')

	if exists
	(
		SELECT * 
		FROM sys.objects 
		WHERE object_id = OBJECT_ID(@tablename_Bom_raw_Component) AND type in (N'U')
	)
	begin
		select @sql = 'drop table '+@tablename_Bom_raw_Component
		if @debug>0
		begin
			select @sql '@sql drop table bom raw'
		end
		execute(@sql)
	end
	select @sql='
	select    
		[SUB GROUP/ Brand] = [SUB GROUP/ Brand New],   
		Channel=[Channel],    
		[Product Type] = [Type],   
		[Time series] = ''3. Promo Qty(BOM)'',
		'+@listcolumn+'
		INTO '+@tablename_Bom_raw_Component+'   
	from    
	(    
		select		
			s.[Type],    
			[SUB GROUP/ Brand New] = s.[SUB GROUP/ Brand],
			zmr.Material_Component,   
			CQty = zmr.Qty,  
			b.*       
		from     
		(    
			select
				*     
			from '+@TableName_ok+'
		) b    
		inner join   
		(    
			select * from V_ZMR32   
		) zmr on zmr.Material_Bom = b.[Bundle Code]  
		inner join    
		(    
			select distinct 
				Material,
				[Signature],
				[SUB GROUP/ Brand],
				[Type]=[Product Type]
			from fnc_SubGroupMaster('''+@Division+''',''full'')   
		) s on s.[Material] = zmr.Material_Component   
	) as x   
	group by
		[SUB GROUP/ Brand New],   
		Channel,  
		[Type]    '
	--order by     [SUB GROUP/ Brand] asc,     Channel asc
	if @debug>0
	begin
		select @sql 'Create table bom raw'
	end
	execute(@sql)
end