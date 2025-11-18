/*
	select * from fnc_FC_CPD_SO_HIS_FINAL('202402') where subgrp = 'AGE REWIND CONCEALER'
*/

Alter function fnc_FC_CPD_SO_HIS_FINAL
(
	@FM_KEY		Nvarchar(6)
)
returns @tmpFinal table
(
	[PeriodKey] [nvarchar](255) NULL,				
	[Division] [nvarchar](4) NULL,
	[BundleType] [varchar](13) NOT NULL,
	[Sales Org] [nvarchar](255) NULL,
	[SubGrp] [nvarchar](255) NULL,
	[Product Type] [varchar](4) NOT NULL,
	[Channel] [nvarchar](20) NULL,
	[Time series] [varchar](17) NOT NULL,
	[OpenStock] [float] default 0,
	[OpenStockValue] Numeric(18,3) default 0,
	[SellIn] [float] default 0,
	[SellInValue] Numeric(18,3) default 0,
	[SellOut] [float] default 0,
	[SellOutValue] Numeric(18,3) default 0,
	[Adjust] [float] default 0,
	[AdjustValue] Numeric(18,3) default 0,
	[EndStock] [float] default 0,
	[EndStockValue] Numeric(18,3) default 0
)
with encryption
As
Begin
	declare 
		--@fm_key nvarchar(6) = '202402',
		@foracastDate date ='',
		@pass_periodKey nvarchar(6) = ''

	select @foracastDate = cast(left(@fm_key,4)+'-'+right(@fm_key,2)+'-01' as date)
	--select @foracastDate as '@foracastDate'
	select @pass_periodKey = format(DATEADD(MM,-1,@foracastDate),'yyyyMM')
	--select @pass_periodKey

	insert into @tmpFinal
	select * 
	from FC_CPD_SO_HIS_FINAL
	where PeriodKey = @pass_periodKey
	return
end