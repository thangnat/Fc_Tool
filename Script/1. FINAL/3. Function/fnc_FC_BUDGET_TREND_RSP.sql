/*
	select * from fnc_FC_BUDGET_TREND_RSP('CPD','202412','T','T1')
	where [SUB GROUP/ Brand]='MCLR WTR REFRESHING 400ML'
*/

Alter function fnc_FC_BUDGET_TREND_RSP
(
	@division			nvarchar(3),
	@FM_KEY				nvarchar(6),
	@TableName			nvarchar(20),
	@Type				nvarchar(10)
)
returns @tablefinal TABLE
(
	ID							int default 0 not null,
	[Filename]					nvarchar(500) null,
	[FM_KEY]					nvarchar(6) null,
	[Type]						nvarchar(10) null,
	[Version]					nvarchar(4) null,
	[Ref Code]					nvarchar(50) null,
	[SUB GROUP/ Brand]			nvarchar(500) null,
	[Time series]				nvarchar(20) null,
	[M1 RSP]					numeric(18,0) default 0,
	[M2 RSP]					numeric(18,0) default 0,
	[M3 RSP]					numeric(18,0) default 0,
	[M4 RSP]					numeric(18,0) default 0,
	[M5 RSP]					numeric(18,0) default 0,
	[M6 RSP]					numeric(18,0) default 0,
	[M7 RSP]					numeric(18,0) default 0,
	[M8 RSP]					numeric(18,0) default 0,
	[M9 RSP]					numeric(18,0) default 0,
	[M10 RSP]					numeric(18,0) default 0,
	[M11 RSP]					numeric(18,0) default 0,
	[M12 RSP]					numeric(18,0) default 0
)
As
begin
	declare @tableTmp TABLE
	(
		ID							int default 0 not null,
		[Filename]					nvarchar(500) null,
		[FM_KEY]					nvarchar(6) null,
		[Type]						nvarchar(10) null,
		[Version]					nvarchar(4) null,	
		[Ref Code]					nvarchar(50) null,
		[SUB-GROUP]					nvarchar(500) null,
		[Time series]				nvarchar(20) null,
		[M1 RSP]					numeric(18,0) default 0,
		[M2 RSP]					numeric(18,0) default 0,
		[M3 RSP]					numeric(18,0) default 0,
		[M4 RSP]					numeric(18,0) default 0,
		[M5 RSP]					numeric(18,0) default 0,
		[M6 RSP]					numeric(18,0) default 0,
		[M7 RSP]					numeric(18,0) default 0,
		[M8 RSP]					numeric(18,0) default 0,
		[M9 RSP]					numeric(18,0) default 0,
		[M10 RSP]					numeric(18,0) default 0,
		[M11 RSP]					numeric(18,0) default 0,
		[M12 RSP]					numeric(18,0) default 0
	)
	if @division IN('CPD')
	begin
		if @TableName='B'
		begin
			insert into @tableTmp
			SELECT
				*
			FROM
			(
				select 
					ID = ROW_NUMBER() over(partition by [SUB-GROUP] order by [SUB-GROUP] asc),
					[Filename],
					[FM_KEY],
					[Type],
					[Version],
					[Ref Code],
					[SUB-GROUP]=[SUB-GROUP],
					[Time series],
					[M1 RSP],
					[M2 RSP],
					[M3 RSP],
					[M4 RSP],
					[M5 RSP],
					[M6 RSP],
					[M7 RSP],
					[M8 RSP],
					[M9 RSP],
					[M10 RSP],
					[M11 RSP],
					[M12 RSP]
				from FC_Budget_RSP_CPD
				where
					FM_KEY=@FM_KEY
				and [Type]=@Type
				and ISNULL([Version],'')<>''
			) as x
			where ID=1
		end
		else if @TableName='PB'
		begin
			insert into @tableTmp
			SELECT
				*
			FROM
			(
				select 
					ID = ROW_NUMBER() over(partition by [SUB-GROUP] order by [SUB-GROUP] asc),
					[Filename],
					[FM_KEY],
					[Type],
					[Version],
					[Ref Code],
					[SUB-GROUP]=[SUB-GROUP],
					[Time series],
					[M1 RSP],
					[M2 RSP],
					[M3 RSP],
					[M4 RSP],
					[M5 RSP],
					[M6 RSP],
					[M7 RSP],
					[M8 RSP],
					[M9 RSP],
					[M10 RSP],
					[M11 RSP],
					[M12 RSP]
				from FC_Pre_Budget_RSP_CPD
				where
					FM_KEY=@FM_KEY
				and [Type]=@Type
				and ISNULL([Version],'')<>''
			) as x
			where ID=1
		end
		else if @TableName='T'
		begin
			insert into @tableTmp
			SELECT
				*
			FROM
			(
				select 
					ID = ROW_NUMBER() over(partition by [SUB-GROUP] order by [SUB-GROUP] asc),
					[Filename],
					[FM_KEY],
					[Type],
					[Version],
					[Ref Code],
					[SUB-GROUP]=[SUB-GROUP],
					[Time series],
					[M1 RSP],
					[M2 RSP],
					[M3 RSP],
					[M4 RSP],
					[M5 RSP],
					[M6 RSP],
					[M7 RSP],
					[M8 RSP],
					[M9 RSP],
					[M10 RSP],
					[M11 RSP],
					[M12 RSP]
				from FC_Trend_RSP_CPD
				where
					FM_KEY=@FM_KEY
				and [Type]=@Type
				and ISNULL([Version],'')<>''
			) as x
			where ID=1
		end
	end
	else if @division IN('LDB')
	begin
		if @TableName='B'
		begin
			insert into @tableTmp
			SELECT
				*
			FROM
			(
				select 
					ID = ROW_NUMBER() over(partition by [SUB-GROUP] order by [SUB-GROUP] asc),
					[Filename],
					[FM_KEY],
					[Type],
					[Version],
					[Ref Code],
					[SUB-GROUP]=[SUB-GROUP],
					[Time series],
					[M1 RSP],
					[M2 RSP],
					[M3 RSP],
					[M4 RSP],
					[M5 RSP],
					[M6 RSP],
					[M7 RSP],
					[M8 RSP],
					[M9 RSP],
					[M10 RSP],
					[M11 RSP],
					[M12 RSP]
				from FC_Budget_RSP_LDB
				where
					FM_KEY=@FM_KEY
				and [Type]=@Type
				and ISNULL([Version],'')<>''
			) as x
			where ID=1
		end
		else if @TableName='PB'
		begin
			insert into @tableTmp
			SELECT
				*
			FROM
			(
				select 
					ID = ROW_NUMBER() over(partition by [SUB-GROUP] order by [SUB-GROUP] asc),
					[Filename],
					[FM_KEY],
					[Type],
					[Version],
					[Ref Code],
					[SUB-GROUP]=[SUB-GROUP],
					[Time series],
					[M1 RSP],
					[M2 RSP],
					[M3 RSP],
					[M4 RSP],
					[M5 RSP],
					[M6 RSP],
					[M7 RSP],
					[M8 RSP],
					[M9 RSP],
					[M10 RSP],
					[M11 RSP],
					[M12 RSP]
				from FC_Pre_Budget_RSP_LDB
				where
					FM_KEY=@FM_KEY
				and [Type]=@Type
				and ISNULL([Version],'')<>''
			) as x
			where ID=1
		end
		else if @TableName='T'
		begin
			insert into @tableTmp
			SELECT
				*
			FROM
			(
				select 
					ID = ROW_NUMBER() over(partition by [SUB-GROUP] order by [SUB-GROUP] asc),
					[Filename],
					[FM_KEY],
					[Type],
					[Version],
					[Ref Code],
					[SUB-GROUP]=[SUB-GROUP],
					[Time series],
					[M1 RSP],
					[M2 RSP],
					[M3 RSP],
					[M4 RSP],
					[M5 RSP],
					[M6 RSP],
					[M7 RSP],
					[M8 RSP],
					[M9 RSP],
					[M10 RSP],
					[M11 RSP],
					[M12 RSP]
				from FC_Trend_RSP_LDB
				where
					FM_KEY=@FM_KEY
				and [Type]=@Type
				and ISNULL([Version],'')<>''
			) as x
			where ID=1
		end
	end
	else if @division IN('LLD')
	begin
		if @TableName='B'
		begin
			insert into @tableTmp
			SELECT
				*
			FROM
			(
				select 
					ID = ROW_NUMBER() over(partition by [SUB-GROUP] order by [SUB-GROUP] asc),
					[Filename],
					[FM_KEY],
					[Type],
					[Version],
					[Ref Code],
					[SUB-GROUP]=[SUB-GROUP],
					[Time series],
					[M1 RSP],
					[M2 RSP],
					[M3 RSP],
					[M4 RSP],
					[M5 RSP],
					[M6 RSP],
					[M7 RSP],
					[M8 RSP],
					[M9 RSP],
					[M10 RSP],
					[M11 RSP],
					[M12 RSP]
				from FC_Budget_RSP_LLD
				where
					FM_KEY=@FM_KEY
				and [Type]=@Type
				and ISNULL([Version],'')<>''
			) as x
			where ID=1
		end
		else if @TableName='PB'
		begin
			insert into @tableTmp
			SELECT
				*
			FROM
			(
				select 
					ID = ROW_NUMBER() over(partition by [SUB-GROUP] order by [SUB-GROUP] asc),
					[Filename],
					[FM_KEY],
					[Type],
					[Version],
					[Ref Code],
					[SUB-GROUP]=[SUB-GROUP],
					[Time series],
					[M1 RSP],
					[M2 RSP],
					[M3 RSP],
					[M4 RSP],
					[M5 RSP],
					[M6 RSP],
					[M7 RSP],
					[M8 RSP],
					[M9 RSP],
					[M10 RSP],
					[M11 RSP],
					[M12 RSP]
				from FC_Pre_Budget_RSP_LLD
				where
					FM_KEY=@FM_KEY
				and [Type]=@Type
				and ISNULL([Version],'')<>''
			) as x
			where ID=1
		end
		else if @TableName='T'
		begin
			insert into @tableTmp
			SELECT
				*
			FROM
			(
				select 
					ID = ROW_NUMBER() over(partition by [SUB-GROUP] order by [SUB-GROUP] asc),
					[Filename],
					[FM_KEY],
					[Type],
					[Version],
					[Ref Code],
					[SUB-GROUP]=[SUB-GROUP],
					[Time series],
					[M1 RSP],
					[M2 RSP],
					[M3 RSP],
					[M4 RSP],
					[M5 RSP],
					[M6 RSP],
					[M7 RSP],
					[M8 RSP],
					[M9 RSP],
					[M10 RSP],
					[M11 RSP],
					[M12 RSP]
				from FC_Trend_RSP_LLD
				where
					FM_KEY=@FM_KEY
				and [Type]=@Type
				and ISNULL([Version],'')<>''
			) as x
			where ID=1
		end
	end
	else if @division IN('PPD')
	begin
		if @TableName='B'
		begin
			insert into @tableTmp
			SELECT
				*
			FROM
			(
				select 
					ID = ROW_NUMBER() over(partition by [SUB-GROUP] order by [SUB-GROUP] asc),
					[Filename],
					[FM_KEY],
					[Type],
					[Version],
					[Ref Code],
					[SUB-GROUP]=[SUB-GROUP],
					[Time series],
					[M1 RSP],
					[M2 RSP],
					[M3 RSP],
					[M4 RSP],
					[M5 RSP],
					[M6 RSP],
					[M7 RSP],
					[M8 RSP],
					[M9 RSP],
					[M10 RSP],
					[M11 RSP],
					[M12 RSP]
				from FC_Budget_RSP_PPD
				where
					FM_KEY=@FM_KEY
				and [Type]=@Type
				and ISNULL([Version],'')<>''
			) as x
			where ID=1
		end
		else if @TableName='PB'
		begin
			insert into @tableTmp
			SELECT
				*
			FROM
			(
				select 
					ID = ROW_NUMBER() over(partition by [SUB-GROUP] order by [SUB-GROUP] asc),
					[Filename],
					[FM_KEY],
					[Type],
					[Version],
					[Ref Code],
					[SUB-GROUP]=[SUB-GROUP],
					[Time series],
					[M1 RSP],
					[M2 RSP],
					[M3 RSP],
					[M4 RSP],
					[M5 RSP],
					[M6 RSP],
					[M7 RSP],
					[M8 RSP],
					[M9 RSP],
					[M10 RSP],
					[M11 RSP],
					[M12 RSP]
				from FC_Pre_Budget_RSP_PPD
				where
					FM_KEY=@FM_KEY
				and [Type]=@Type
				and ISNULL([Version],'')<>''
			) as x
			where ID=1
		end
		else if @TableName='T'
		begin
			insert into @tableTmp
			SELECT
				*
			FROM
			(
				select 
					ID = ROW_NUMBER() over(partition by [SUB-GROUP] order by [SUB-GROUP] asc),
					[Filename],
					[FM_KEY],
					[Type],
					[Version],
					[Ref Code],
					[SUB-GROUP]=[SUB-GROUP],
					[Time series],
					[M1 RSP],
					[M2 RSP],
					[M3 RSP],
					[M4 RSP],
					[M5 RSP],
					[M6 RSP],
					[M7 RSP],
					[M8 RSP],
					[M9 RSP],
					[M10 RSP],
					[M11 RSP],
					[M12 RSP]
				from FC_Trend_RSP_PPD
				where
					FM_KEY=@FM_KEY
				and [Type]=@Type
				and ISNULL([Version],'')<>''
			) as x
			where ID=1
		end
	end
	--else if @division IN('LLD')
	--begin
	--	if @TableName='B'
	--	begin
	--		insert into @tableTmp
	--		select 
	--			*
	--		from
	--		(
	--			SELECT
	--				*
	--			FROM
	--			(
	--				select 
	--					ID = ROW_NUMBER() over(partition by [SUB-GROUP] order by [SUB-GROUP] asc),
	--					[Filename],
	--					[FM_KEY]=substring([filename],12,6),
	--					[Type]='B0',
	--					[Version]=cast(substring([filename],12,4) as int),
	--					[ref co],
	--					[SUB-GROUP]=s.[SUB-GROUP],
	--					[Time series]='1. Baseline Qty',
	--					[M1 RSP]=[B_Y0_M1],
	--					[M2 RSP]=[B_Y0_M2],
	--					[M3 RSP]=[B_Y0_M3],
	--					[M4 RSP]=[B_Y0_M4],
	--					[M5 RSP]=[B_Y0_M5],
	--					[M6 RSP]=[B_Y0_M6],
	--					[M7 RSP]=[B_Y0_M7],
	--					[M8 RSP]=[B_Y0_M8],
	--					[M9 RSP]=[B_Y0_M9],
	--					[M10 RSP]=[B_Y0_M10],
	--					[M11 RSP]=[B_Y0_M11],
	--					[M12 RSP]=[B_Y0_M12]
	--				from (select * from FC_BFL_Master_LLD) r
	--				cross join(select value from string_split('ONLINE,OFFLINE',',')) c
	--				inner join
	--				(
	--					select DISTINCT 
	--						[EAN Code],
	--						[SUB-GROUP]=[BFL Name] 
	--					from FC_BFL_Master_LLD
	--				) s on s.[EAN Code]=r.[EAN Code]
	--				where
	--					substring([filename],12,6)=@FM_KEY
	--			) as x
	--			where ID=1
	--			union all
	--			select
	--				*
	--			from
	--			(
	--				select 
	--					ID = ROW_NUMBER() over(partition by [SUB-GROUP] order by [SUB-GROUP] asc),
	--					[Filename],
	--					[FM_KEY]=substring([filename],12,6),
	--					[Type]='B1',
	--					[Version]=cast(substring([filename],12,4) as int)+1,						
	--					[SUB-GROUP]=s.[SUB-GROUP],
	--					[Time series]='1. Baseline Qty',
	--					[M1 RSP]=[B_Y+1_M1],
	--					[M2 RSP]=[B_Y+1_M2],
	--					[M3 RSP]=[B_Y+1_M3],
	--					[M4 RSP]=[B_Y+1_M4],
	--					[M5 RSP]=[B_Y+1_M5],
	--					[M6 RSP]=[B_Y+1_M6],
	--					[M7 RSP]=[B_Y+1_M7],
	--					[M8 RSP]=[B_Y+1_M8],
	--					[M9 RSP]=[B_Y+1_M9],
	--					[M10 RSP]=[B_Y+1_M10],
	--					[M11 RSP]=[B_Y+1_M11],
	--					[M12 RSP]=[B_Y+1_M12]
	--				from (select * from FC_BFL_Master_LLD) r
	--				cross join(select value from string_split('ONLINE,OFFLINE',',')) c
	--				inner join
	--				(
	--					select DISTINCT 
	--						[EAN Code],
	--						[SUB-GROUP]=[BFL Name] 
	--					from FC_BFL_Master_LLD
	--				) s on s.[EAN Code]=r.[EAN Code]
	--				where
	--					substring([filename],12,6)=@FM_KEY
	--			) as x1
	--			where ID=1
	--		) as x2
	--	end
	--	else if @TableName='PB'
	--	begin
	--		insert into @tableTmp
	--		select
	--			*
	--		from
	--		(
	--			select 
	--				ID = ROW_NUMBER() over(partition by [SUB-GROUP] order by [SUB-GROUP] asc),
	--				[Filename],
	--				[FM_KEY]=substring([filename],12,6),
	--				[Type]='B1',
	--				[Version]=cast(substring([filename],12,4) as int)+1,
	--				[SUB-GROUP]=s.[SUB-GROUP],
	--				[Time series]='1. Baseline Qty',
	--				[M1 RSP]=[PB_Y+1_M1],
	--				[M2 RSP]=[PB_Y+1_M2],
	--				[M3 RSP]=[PB_Y+1_M3],
	--				[M4 RSP]=[PB_Y+1_M4],
	--				[M5 RSP]=[PB_Y+1_M5],
	--				[M6 RSP]=[PB_Y+1_M6],
	--				[M7 RSP]=[PB_Y+1_M7],
	--				[M8 RSP]=[PB_Y+1_M8],
	--				[M9 RSP]=[PB_Y+1_M9],
	--				[M10 RSP]=[PB_Y+1_M10],
	--				[M11 RSP]=[PB_Y+1_M11],
	--				[M12 RSP]=[PB_Y+1_M12]
	--			from (select * from FC_BFL_Master_LLD) r
	--			--cross join(select value from string_split('ONLINE,OFFLINE',',')) c
	--			inner join
	--			(
	--				select DISTINCT 
	--					[EAN Code],
	--					[SUB-GROUP]=[BFL Name] 
	--				from FC_BFL_Master_LLD
	--			) s on s.[EAN Code]=r.[EAN Code]
	--			where
	--				substring([filename],12,6)=@FM_KEY
	--		) as x1
	--		where ID=1
	--	end
	--	else if @TableName='T'
	--	begin
	--		insert into @tableTmp
	--		SELECT
	--			*
	--		FROM
	--		(
	--			select 
	--				ID = ROW_NUMBER() over(partition by [SUB-GROUP] order by [SUB-GROUP] asc),
	--				[Filename],
	--				[FM_KEY]=[Year]+[Month],
	--				[Type],
	--				[Version]=[YEAR],
	--				[SUB-GROUP]=s.[SUB-GROUP],
	--				[Time series]='1. Baseline Qty',
	--				[M1 RSP]=[T_Y0_M1],
	--				[M2 RSP]=[T_Y0_M2],
	--				[M3 RSP]=[T_Y0_M3],
	--				[M4 RSP]=[T_Y0_M4],
	--				[M5 RSP]=[T_Y0_M5],
	--				[M6 RSP]=[T_Y0_M6],
	--				[M7 RSP]=[T_Y0_M7],
	--				[M8 RSP]=[T_Y0_M8],
	--				[M9 RSP]=[T_Y0_M9],
	--				[M10 RSP]=[T_Y0_M10],
	--				[M11 RSP]=[T_Y0_M11],
	--				[M12 RSP]=[T_Y0_M12]
	--			from FC_Trend_RSP_LLD r
	--			--cross join(select value from string_split('ONLINE,OFFLINE',',')) c
	--			inner join
	--			(
	--				select DISTINCT 
	--					[EAN Code],
	--					[SUB-GROUP]=[BFL Name] 
	--				from FC_BFL_Master_LLD
	--			) s on s.[EAN Code]=r.[EAN Code]
	--			where
	--				[Year]+[Month]=@FM_KEY
	--		) as x
	--		where ID=1
	--	end
	--end
	--else if @division IN('LDB')
	--begin
	--	if @TableName='B'
	--	begin
	--		insert into @tableTmp
	--		select 
	--			*
	--		from
	--		(
	--			SELECT
	--				*
	--			FROM
	--			(
	--				select 
	--					ID = ROW_NUMBER() over(partition by [SUB-GROUP] order by [SUB-GROUP] asc),
	--					[Filename],
	--					[FM_KEY]=substring([filename],12,6),
	--					[Type]='B0',
	--					[Version]=cast(substring([filename],12,4) as int),
	--					[SUB-GROUP]=s.[SUB-GROUP],
	--					[Time series]='1. Baseline Qty',
	--					[M1 RSP]=[B_Y0_M1],
	--					[M2 RSP]=[B_Y0_M2],
	--					[M3 RSP]=[B_Y0_M3],
	--					[M4 RSP]=[B_Y0_M4],
	--					[M5 RSP]=[B_Y0_M5],
	--					[M6 RSP]=[B_Y0_M6],
	--					[M7 RSP]=[B_Y0_M7],
	--					[M8 RSP]=[B_Y0_M8],
	--					[M9 RSP]=[B_Y0_M9],
	--					[M10 RSP]=[B_Y0_M10],
	--					[M11 RSP]=[B_Y0_M11],
	--					[M12 RSP]=[B_Y0_M12]
	--				from (select * from FC_BFL_Master_LDB) r
	--				--cross join(select value from string_split('ONLINE,OFFLINE',',')) c
	--				inner join
	--				(
	--					select DISTINCT 
	--						[EAN Code],
	--						[SUB-GROUP]=[BFL Name] 
	--					from FC_BFL_Master_LDB
	--				) s on s.[EAN Code]=r.[EAN Code]
	--				where
	--					substring([filename],12,6)=@FM_KEY
	--			) as x
	--			where ID=1
	--			union all
	--			select
	--				*
	--			from
	--			(
	--				select 
	--					ID = ROW_NUMBER() over(partition by [SUB-GROUP] order by [SUB-GROUP] asc),
	--					[Filename],
	--					[FM_KEY]=substring([filename],12,6),
	--					[Type]='B1',
	--					[Version]=cast(substring([filename],12,4) as int)+1,						
	--					[SUB-GROUP]=s.[SUB-GROUP],
	--					[Time series]='1. Baseline Qty',
	--					[M1 RSP]=[B_Y+1_M1],
	--					[M2 RSP]=[B_Y+1_M2],
	--					[M3 RSP]=[B_Y+1_M3],
	--					[M4 RSP]=[B_Y+1_M4],
	--					[M5 RSP]=[B_Y+1_M5],
	--					[M6 RSP]=[B_Y+1_M6],
	--					[M7 RSP]=[B_Y+1_M7],
	--					[M8 RSP]=[B_Y+1_M8],
	--					[M9 RSP]=[B_Y+1_M9],
	--					[M10 RSP]=[B_Y+1_M10],
	--					[M11 RSP]=[B_Y+1_M11],
	--					[M12 RSP]=[B_Y+1_M12]
	--				from (select * from FC_BFL_Master_LDB) r
	--				--cross join(select value from string_split('ONLINE,OFFLINE',',')) c
	--				inner join
	--				(
	--					select DISTINCT 
	--						[EAN Code],
	--						[SUB-GROUP]=[BFL Name] 
	--					from FC_BFL_Master_LDB
	--				) s on s.[EAN Code]=r.[EAN Code]
	--				where
	--					substring([filename],12,6)=@FM_KEY
	--			) as x1
	--			where ID=1
	--		) as x2
	--	end
	--	else if @TableName='PB'
	--	begin
	--		insert into @tableTmp
	--		select
	--			*
	--		from
	--		(
	--			select 
	--				ID = ROW_NUMBER() over(partition by [SUB-GROUP] order by [SUB-GROUP] asc),
	--				[Filename],
	--				[FM_KEY]=substring([filename],12,6),
	--				[Type]='B1',
	--				[Version]=cast(substring([filename],12,4) as int)+1,
	--				[SUB-GROUP]=s.[SUB-GROUP],
	--				[Time series]='1. Baseline Qty',
	--				[M1 RSP]=[PB_Y+1_M1],
	--				[M2 RSP]=[PB_Y+1_M2],
	--				[M3 RSP]=[PB_Y+1_M3],
	--				[M4 RSP]=[PB_Y+1_M4],
	--				[M5 RSP]=[PB_Y+1_M5],
	--				[M6 RSP]=[PB_Y+1_M6],
	--				[M7 RSP]=[PB_Y+1_M7],
	--				[M8 RSP]=[PB_Y+1_M8],
	--				[M9 RSP]=[PB_Y+1_M9],
	--				[M10 RSP]=[PB_Y+1_M10],
	--				[M11 RSP]=[PB_Y+1_M11],
	--				[M12 RSP]=[PB_Y+1_M12]
	--			from (select * from FC_BFL_Master_LDB) r
	--			--cross join(select value from string_split('ONLINE,OFFLINE',',')) c
	--			inner join
	--			(
	--				select DISTINCT 
	--					[EAN Code],
	--					[SUB-GROUP]=[BFL Name] 
	--				from FC_BFL_Master_LDB
	--			) s on s.[EAN Code]=r.[EAN Code]
	--			where
	--				substring([filename],12,6)=@FM_KEY
	--		) as x1
	--		where ID=1
	--	end
	--	else if @TableName='T'
	--	begin
	--		insert into @tableTmp
	--		SELECT
	--			*
	--		FROM
	--		(
	--			select 
	--				ID = ROW_NUMBER() over(partition by [SUB-GROUP] order by [SUB-GROUP] asc),
	--				[Filename],
	--				[FM_KEY]=[Year]+[Month],
	--				[Type],
	--				[Version]=[YEAR],
	--				[SUB-GROUP]=s.[SUB-GROUP],
	--				[Time series]='1. Baseline Qty',
	--				[M1 RSP]=[T_Y0_M1],
	--				[M2 RSP]=[T_Y0_M2],
	--				[M3 RSP]=[T_Y0_M3],
	--				[M4 RSP]=[T_Y0_M4],
	--				[M5 RSP]=[T_Y0_M5],
	--				[M6 RSP]=[T_Y0_M6],
	--				[M7 RSP]=[T_Y0_M7],
	--				[M8 RSP]=[T_Y0_M8],
	--				[M9 RSP]=[T_Y0_M9],
	--				[M10 RSP]=[T_Y0_M10],
	--				[M11 RSP]=[T_Y0_M11],
	--				[M12 RSP]=[T_Y0_M12]
	--			from FC_Trend_RSP_LDB r
	--			--cross join(select value from string_split('ONLINE,OFFLINE',',')) c
	--			inner join
	--			(
	--				select DISTINCT 
	--					[EAN Code],
	--					[SUB-GROUP]=[BFL Name] 
	--				from FC_BFL_Master_LDB
	--			) s on s.[EAN Code]=r.[EAN Code]
	--			where
	--				[Year]+[Month]=@FM_KEY
	--		) as x
	--		where ID=1
	--	end
	--end

	insert into @tablefinal
	select * from @tableTmp
	return
end
