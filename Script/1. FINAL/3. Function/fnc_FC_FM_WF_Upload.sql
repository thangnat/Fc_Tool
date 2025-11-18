/*
	select * from fnc_FC_FM_WF_Upload('CPD')
*/
Alter function fnc_FC_FM_WF_Upload
(
	@division		nvarchar(3) = ''
)
returns @tmp1 table
(
	Division	[nvarchar](3) null,
	--Spectrum	[INT] null,
	[Product type] [varchar](50) NULL,
	[Signature] [nvarchar](255) NULL,
	[CAT/Axe] [nvarchar](255) NULL,
	[SUB CAT/ Sub Axe] [nvarchar](255) NULL,
	[GROUP/ Class] [nvarchar](255) NULL,
	[Ref. Code] [nvarchar](20) NULL,
	[SUB GROUP/ Brand] [nvarchar](300) NULL,
	[Sap Code]		[Nvarchar](50) null,
	[HERO] [nvarchar](255) NULL,
	[Channel] [nvarchar](10) NOT NULL,
	[Product status] [nvarchar](255) NULL,
	[Time series] [nvarchar](30) NOT NULL,
	[Y0 (u) M1] [int] default 0,
	[Y0 (u) M2] [int] default 0,
	[Y0 (u) M3] [int] default 0,
	[Y0 (u) M4] [int] default 0,
	[Y0 (u) M5] [int] default 0,
	[Y0 (u) M6] [int] default 0,
	[Y0 (u) M7] [int] default 0,
	[Y0 (u) M8] [int] default 0,
	[Y0 (u) M9] [int] default 0,
	[Y0 (u) M10] [int] default 0,
	[Y0 (u) M11] [int] default 0,
	[Y0 (u) M12] [int] default 0,
	[Y+1 (u) M1] [int] default 0,
	[Y+1 (u) M2] [int] default 0,
	[Y+1 (u) M3] [int] default 0,
	[Y+1 (u) M4] [int] default 0,
	[Y+1 (u) M5] [int] default 0,
	[Y+1 (u) M6] [int] default 0,
	[Y+1 (u) M7] [int] default 0,
	[Y+1 (u) M8] [int] default 0,
	[Y+1 (u) M9] [int] default 0,
	[Y+1 (u) M10] [int] default 0,
	[Y+1 (u) M11] [int] default 0,
	[Y+1 (u) M12] [int] default 0
)
with encryption
As
begin
	declare @tmp table
	(
		Division	nvarchar(3),
		Channel		nvarchar(10),
		[Time series]	nvarchar(20),
		Spectrum		int default 0
	)
	insert into @tmp
	select * from V_FC_SPECTRUM_CONFIG

	declare 
		@sql			nvarchar(max) = '',
		@sql1			nvarchar(max) = '',
		@sql2			nvarchar(max) = '',
		@debug			int = 0

	if @division = 'CPD'
	begin
		INSERT INTO @tmp1
		select
			Division = @division,
			--Spectrum = case when [Time series] IN('1. Baseline Qty','2. Promo Qty(Single)') and Channel = 'OFFLINE' then 1 else 0 end,
			f.[Product type],
			f.[Signature],
			f.[CAT/Axe],
			f.[SUB CAT/ Sub Axe],
			f.[GROUP/ Class],
			f.[Ref. Code],
			f.[SUB GROUP/ Brand],
			[Sap Code] = spt.SKU,
			f.[HERO],
			f.[Channel],
			f.[Product status],
			f.[Time series],
			[Y0 (u) M1] = f.[Y0 (u) M1]*case when (select isnull([Spectrum],0) from @tmp where Division = @division and Channel = f.Channel and [Time series] = f.[Time series])=1 then spt.[Y0 (u) M1] else 1 end,
			[Y0 (u) M2] = f.[Y0 (u) M2]*case when (select isnull([Spectrum],0) from @tmp where Division = @division and Channel = f.Channel and [Time series] = f.[Time series])=1 then spt.[Y0 (u) M2] else 1 end,
			[Y0 (u) M3] = f.[Y0 (u) M3]*case when (select isnull([Spectrum],0) from @tmp where Division = @division and Channel = f.Channel and [Time series] = f.[Time series])=1 then spt.[Y0 (u) M3] else 1 end,
			[Y0 (u) M4] = f.[Y0 (u) M4]*case when (select isnull([Spectrum],0) from @tmp where Division = @division and Channel = f.Channel and [Time series] = f.[Time series])=1 then spt.[Y0 (u) M4] else 1 end,
			[Y0 (u) M5] = f.[Y0 (u) M5]*case when (select isnull([Spectrum],0) from @tmp where Division = @division and Channel = f.Channel and [Time series] = f.[Time series])=1 then spt.[Y0 (u) M5] else 1 end,
			[Y0 (u) M6] = f.[Y0 (u) M6]*case when (select isnull([Spectrum],0) from @tmp where Division = @division and Channel = f.Channel and [Time series] = f.[Time series])=1 then spt.[Y0 (u) M6] else 1 end,
			[Y0 (u) M7] = f.[Y0 (u) M7]*case when (select isnull([Spectrum],0) from @tmp where Division = @division and Channel = f.Channel and [Time series] = f.[Time series])=1 then spt.[Y0 (u) M7] else 1 end,
			[Y0 (u) M8] = f.[Y0 (u) M8]*case when (select isnull([Spectrum],0) from @tmp where Division = @division and Channel = f.Channel and [Time series] = f.[Time series])=1 then spt.[Y0 (u) M8] else 1 end,
			[Y0 (u) M9] = f.[Y0 (u) M9]*case when (select isnull([Spectrum],0) from @tmp where Division = @division and Channel = f.Channel and [Time series] = f.[Time series])=1 then spt.[Y0 (u) M9] else 1 end,
			[Y0 (u) M10] = f.[Y0 (u) M10]*case when (select isnull([Spectrum],0) from @tmp where Division = @division and Channel = f.Channel and [Time series] = f.[Time series])=1 then spt.[Y0 (u) M10] else 1 end,
			[Y0 (u) M11] = f.[Y0 (u) M11]*case when (select isnull([Spectrum],0) from @tmp where Division = @division and Channel = f.Channel and [Time series] = f.[Time series])=1 then spt.[Y0 (u) M11] else 1 end,
			[Y0 (u) M12] = f.[Y0 (u) M12]*case when (select isnull([Spectrum],0) from @tmp where Division = @division and Channel = f.Channel and [Time series] = f.[Time series])=1 then spt.[Y0 (u) M12] else 1 end,
			[Y+1 (u) M1] = f.[Y+1 (u) M1]*case when (select isnull([Spectrum],0) from @tmp where Division = @division and Channel = f.Channel and [Time series] = f.[Time series])=1 then spt.[Y+1 (u) M1] else 1 end,
			[Y+1 (u) M2] = f.[Y+1 (u) M2]*case when (select isnull([Spectrum],0) from @tmp where Division = @division and Channel = f.Channel and [Time series] = f.[Time series])=1 then spt.[Y+1 (u) M2] else 1 end,
			[Y+1 (u) M3] = f.[Y+1 (u) M3]*case when (select isnull([Spectrum],0) from @tmp where Division = @division and Channel = f.Channel and [Time series] = f.[Time series])=1 then spt.[Y+1 (u) M3] else 1 end,
			[Y+1 (u) M4] = f.[Y+1 (u) M4]*case when (select isnull([Spectrum],0) from @tmp where Division = @division and Channel = f.Channel and [Time series] = f.[Time series])=1 then spt.[Y+1 (u) M4] else 1 end,
			[Y+1 (u) M5] = f.[Y+1 (u) M5]*case when (select isnull([Spectrum],0) from @tmp where Division = @division and Channel = f.Channel and [Time series] = f.[Time series])=1 then spt.[Y+1 (u) M5] else 1 end,
			[Y+1 (u) M6] = f.[Y+1 (u) M6]*case when (select isnull([Spectrum],0) from @tmp where Division = @division and Channel = f.Channel and [Time series] = f.[Time series])=1 then spt.[Y+1 (u) M6] else 1 end,
			[Y+1 (u) M7] = f.[Y+1 (u) M7]*case when (select isnull([Spectrum],0) from @tmp where Division = @division and Channel = f.Channel and [Time series] = f.[Time series])=1 then spt.[Y+1 (u) M7] else 1 end,
			[Y+1 (u) M8] = f.[Y+1 (u) M8]*case when (select isnull([Spectrum],0) from @tmp where Division = @division and Channel = f.Channel and [Time series] = f.[Time series])=1 then spt.[Y+1 (u) M8] else 1 end,
			[Y+1 (u) M9] = f.[Y+1 (u) M9]*case when (select isnull([Spectrum],0) from @tmp where Division = @division and Channel = f.Channel and [Time series] = f.[Time series])=1 then spt.[Y+1 (u) M9] else 1 end,
			[Y+1 (u) M10] = f.[Y+1 (u) M10]*case when (select isnull([Spectrum],0) from @tmp where Division = @division and Channel = f.Channel and [Time series] = f.[Time series])=1 then spt.[Y+1 (u) M10] else 1 end,
			[Y+1 (u) M11] = f.[Y+1 (u) M11]*case when (select isnull([Spectrum],0) from @tmp where Division = @division and Channel = f.Channel and [Time series] = f.[Time series])=1 then spt.[Y+1 (u) M11] else 1 end,
			[Y+1 (u) M12] = f.[Y+1 (u) M12]*case when (select isnull([Spectrum],0) from @tmp where Division = @division and Channel = f.Channel and [Time series] = f.[Time series])=1 then spt.[Y+1 (u) M12] else 1 end
		from FC_FM_Original_CPD f (NOLOCK)
		inner join 
		(
			select
				s.[SUB GROUP/ Brand],
				sp.*
			from FC_Spectrum_CPD sp
			left join fnc_SubGroupMaster(@division,'') s on sp.SKU = s.Material
		) spt on spt.[SUB GROUP/ Brand] = f.[SUB GROUP/ Brand]
		where f.Channel NOT IN('O+O')
		and [Time series] NOT IN('6. Total Qty')
	end
	else if @division = 'LLD'
	begin
		INSERT INTO @tmp1
		select
			Division = @division,
			--Spectrum = case when [Time series] IN('1. Baseline Qty','2. Promo Qty(Single)') and Channel = 'OFFLINE' then 1 else 0 end,
			f.[Product type],
			f.[Signature],
			f.[CAT/Axe],
			f.[SUB CAT/ Sub Axe],
			f.[GROUP/ Class],
			f.[Ref. Code],
			f.[SUB GROUP/ Brand],
			[Sap Code] = spt.SKU,
			f.[HERO],
			f.[Channel],
			f.[Product status],
			f.[Time series],
			[Y0 (u) M1] = f.[Y0 (u) M1]*case when (select isnull([Spectrum],0) from @tmp where Division = @division and Channel = f.Channel and [Time series] = f.[Time series])=1 then spt.[Y0 (u) M1] else 1 end,
			[Y0 (u) M2] = f.[Y0 (u) M2]*case when (select isnull([Spectrum],0) from @tmp where Division = @division and Channel = f.Channel and [Time series] = f.[Time series])=1 then spt.[Y0 (u) M2] else 1 end,
			[Y0 (u) M3] = f.[Y0 (u) M3]*case when (select isnull([Spectrum],0) from @tmp where Division = @division and Channel = f.Channel and [Time series] = f.[Time series])=1 then spt.[Y0 (u) M3] else 1 end,
			[Y0 (u) M4] = f.[Y0 (u) M4]*case when (select isnull([Spectrum],0) from @tmp where Division = @division and Channel = f.Channel and [Time series] = f.[Time series])=1 then spt.[Y0 (u) M4] else 1 end,
			[Y0 (u) M5] = f.[Y0 (u) M5]*case when (select isnull([Spectrum],0) from @tmp where Division = @division and Channel = f.Channel and [Time series] = f.[Time series])=1 then spt.[Y0 (u) M5] else 1 end,
			[Y0 (u) M6] = f.[Y0 (u) M6]*case when (select isnull([Spectrum],0) from @tmp where Division = @division and Channel = f.Channel and [Time series] = f.[Time series])=1 then spt.[Y0 (u) M6] else 1 end,
			[Y0 (u) M7] = f.[Y0 (u) M7]*case when (select isnull([Spectrum],0) from @tmp where Division = @division and Channel = f.Channel and [Time series] = f.[Time series])=1 then spt.[Y0 (u) M7] else 1 end,
			[Y0 (u) M8] = f.[Y0 (u) M8]*case when (select isnull([Spectrum],0) from @tmp where Division = @division and Channel = f.Channel and [Time series] = f.[Time series])=1 then spt.[Y0 (u) M8] else 1 end,
			[Y0 (u) M9] = f.[Y0 (u) M9]*case when (select isnull([Spectrum],0) from @tmp where Division = @division and Channel = f.Channel and [Time series] = f.[Time series])=1 then spt.[Y0 (u) M9] else 1 end,
			[Y0 (u) M10] = f.[Y0 (u) M10]*case when (select isnull([Spectrum],0) from @tmp where Division = @division and Channel = f.Channel and [Time series] = f.[Time series])=1 then spt.[Y0 (u) M10] else 1 end,
			[Y0 (u) M11] = f.[Y0 (u) M11]*case when (select isnull([Spectrum],0) from @tmp where Division = @division and Channel = f.Channel and [Time series] = f.[Time series])=1 then spt.[Y0 (u) M11] else 1 end,
			[Y0 (u) M12] = f.[Y0 (u) M12]*case when (select isnull([Spectrum],0) from @tmp where Division = @division and Channel = f.Channel and [Time series] = f.[Time series])=1 then spt.[Y0 (u) M12] else 1 end,
			[Y+1 (u) M1] = f.[Y+1 (u) M1]*case when (select isnull([Spectrum],0) from @tmp where Division = @division and Channel = f.Channel and [Time series] = f.[Time series])=1 then spt.[Y+1 (u) M1] else 1 end,
			[Y+1 (u) M2] = f.[Y+1 (u) M2]*case when (select isnull([Spectrum],0) from @tmp where Division = @division and Channel = f.Channel and [Time series] = f.[Time series])=1 then spt.[Y+1 (u) M2] else 1 end,
			[Y+1 (u) M3] = f.[Y+1 (u) M3]*case when (select isnull([Spectrum],0) from @tmp where Division = @division and Channel = f.Channel and [Time series] = f.[Time series])=1 then spt.[Y+1 (u) M3] else 1 end,
			[Y+1 (u) M4] = f.[Y+1 (u) M4]*case when (select isnull([Spectrum],0) from @tmp where Division = @division and Channel = f.Channel and [Time series] = f.[Time series])=1 then spt.[Y+1 (u) M4] else 1 end,
			[Y+1 (u) M5] = f.[Y+1 (u) M5]*case when (select isnull([Spectrum],0) from @tmp where Division = @division and Channel = f.Channel and [Time series] = f.[Time series])=1 then spt.[Y+1 (u) M5] else 1 end,
			[Y+1 (u) M6] = f.[Y+1 (u) M6]*case when (select isnull([Spectrum],0) from @tmp where Division = @division and Channel = f.Channel and [Time series] = f.[Time series])=1 then spt.[Y+1 (u) M6] else 1 end,
			[Y+1 (u) M7] = f.[Y+1 (u) M7]*case when (select isnull([Spectrum],0) from @tmp where Division = @division and Channel = f.Channel and [Time series] = f.[Time series])=1 then spt.[Y+1 (u) M7] else 1 end,
			[Y+1 (u) M8] = f.[Y+1 (u) M8]*case when (select isnull([Spectrum],0) from @tmp where Division = @division and Channel = f.Channel and [Time series] = f.[Time series])=1 then spt.[Y+1 (u) M8] else 1 end,
			[Y+1 (u) M9] = f.[Y+1 (u) M9]*case when (select isnull([Spectrum],0) from @tmp where Division = @division and Channel = f.Channel and [Time series] = f.[Time series])=1 then spt.[Y+1 (u) M9] else 1 end,
			[Y+1 (u) M10] = f.[Y+1 (u) M10]*case when (select isnull([Spectrum],0) from @tmp where Division = @division and Channel = f.Channel and [Time series] = f.[Time series])=1 then spt.[Y+1 (u) M10] else 1 end,
			[Y+1 (u) M11] = f.[Y+1 (u) M11]*case when (select isnull([Spectrum],0) from @tmp where Division = @division and Channel = f.Channel and [Time series] = f.[Time series])=1 then spt.[Y+1 (u) M11] else 1 end,
			[Y+1 (u) M12] = f.[Y+1 (u) M12]*case when (select isnull([Spectrum],0) from @tmp where Division = @division and Channel = f.Channel and [Time series] = f.[Time series])=1 then spt.[Y+1 (u) M12] else 1 end
		from FC_FM_Original_CPD f (NOLOCK)
		inner join 
		(
			select
				s.[SUB GROUP/ Brand],
				sp.*
			from FC_Spectrum_CPD sp
			left join fnc_SubGroupMaster(@division,'') s on sp.SKU = s.Material
		) spt on spt.[SUB GROUP/ Brand] = f.[SUB GROUP/ Brand]
		where f.Channel NOT IN('O+O')
		and [Time series] NOT IN('6. Total Qty')
	end
	return
end
