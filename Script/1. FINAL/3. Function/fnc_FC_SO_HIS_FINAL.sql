/*
	SELECT * FROM fnc_FC_SO_HIS_FINAL('LLD')
*/

Alter function fnc_FC_SO_HIS_FINAL--NO USE
(
	@division		nvarchar(3)
)
returns @tmp table
(
	[SO Forecasting lines] nvarchar(300) null,
	PeriodKey nvarchar(6) null,
	BundleType nvarchar(10) null,
	Division nvarchar(3) null,
	[Sales Org] nvarchar(4) null,
	[SUB GROUP/ Brand] nvarchar(300) null,
	[Product Type] nvarchar(50) null,
	Channel nvarchar(10) null,
	OpenStock numeric(18,3) null,
	OpenStockValue numeric(18,3) null,
	SellIn numeric(18,3) null,
	SellInValue numeric(18,3) null,
	SellOut numeric(18,3) null,
	SellOutValue numeric(18,3) null,
	EndStock numeric(18,3) null,
	EndStockValue numeric(18,3) null,
	[Time series] nvarchar(50) null,
	[Year] nvarchar(4) null,
	[Month] nvarchar(2) null,
	[Signature] nvarchar(50) null,
	[CAT/Axe] nvarchar(100) null,
	[SUB CAT/ Sub Axe] nvarchar(100) null,
	[Product status] nvarchar(50) null,
	HERO nvarchar(10) null
)
with encryption
As
begin
	if @division = 'CPD'
	begin
		insert into @tmp
		select
			[SO Forecasting lines] = o.[Forecasting lines],
			PeriodKey,
			BundleType,
			Division,
			[Sales Org],
			[SUB GROUP/ Brand] = s.[SUB GROUP/ Brand],
			[Product Type],
			Channel,
			OpenStock,
			OpenStockValue,
			SellIn,
			SellInValue,
			SellOut,
			SellOutValue,
			EndStock,
			EndStockValue,
			[Time series],
			[Year] = left(PeriodKey,4),
			[Month] = right(PeriodKey,2),
			s.[Signature],
			s.[CAT/Axe],
			s.[SUB CAT/ Sub Axe],
			[Product status] = s.[Product status],
			HERO = sb.Hero
		from FC_CPD_SO_HIS_FINAL h
		inner join 
		(
			select DISTINCT
				Barcode,
				[Signature],
				[CAT/Axe],
				[SUB CAT/ Sub Axe],
				[SUB GROUP/ Brand],
				[Product status]				
			from fnc_SubGroupMaster(@division,'full')
			WHERE [Item Category Group] <> 'LUMF' --or ([Item Category Group] = 'LUMF' and Barcode = '8935274636421')
		) s on s.Barcode = h.Barcode
		left join 
		(
			select DISTINCT 
				[SUB GROUP/ Brand],
				[Forecasting lines]
			from fnc_FC_SO_OPTIMUS_MAPPING_SUBGRP(@division)
		) o on o.[SUB GROUP/ Brand] = s.[SUB GROUP/ Brand]
		left join V_FC_MMDOWNLOAD_SORTBY_CPD sb on sb.[SUB GROUP/ Brand] = s.[SUB GROUP/ Brand]
	end
	else if @division = 'LLD'
	begin
		insert into @tmp
		select
			[SO Forecasting lines] = o.[Forecasting lines],
			PeriodKey,
			BundleType,
			Division,
			[Sales Org],
			[SUB GROUP/ Brand] = s.[SUB GROUP/ Brand],
			[Product Type],
			Channel,
			OpenStock,
			OpenStockValue,
			SellIn,
			SellInValue,
			SellOut,
			SellOutValue,
			EndStock,
			EndStockValue,
			[Time series],
			[Year] = left(PeriodKey,4),
			[Month] = right(PeriodKey,2),
			s.[Signature],
			s.[CAT/Axe],
			s.[SUB CAT/ Sub Axe],
			[Product status] = s.[Product status],
			HERO = sb.Hero
		from FC_LLD_SO_HIS_FINAL h
		inner join 
		(
			select DISTINCT
				Barcode,
				[Signature],
				[CAT/Axe],
				[SUB CAT/ Sub Axe],
				[SUB GROUP/ Brand],
				[Product status]
			from fnc_SubGroupMaster('LLD','full')
			WHERE [Item Category Group] <> 'LUMF' --or ([Item Category Group] = 'LUMF' and Barcode = '8935274636421')
		) s on s.Barcode = h.Barcode
		left join 
		(
			select DISTINCT 
				[SUB GROUP/ Brand],
				[Forecasting lines]
			from fnc_FC_SO_OPTIMUS_MAPPING_SUBGRP('LLD')
		) o on o.[SUB GROUP/ Brand] = s.[SUB GROUP/ Brand]
		left join V_FC_MMDOWNLOAD_SORTBY_LLD sb on sb.[SUB GROUP/ Brand] = s.[SUB GROUP/ Brand]
	end
	RETURN	
end