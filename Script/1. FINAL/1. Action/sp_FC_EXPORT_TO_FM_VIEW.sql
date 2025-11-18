/*
	exec sp_FC_EXPORT_TO_FM_VIEW 'CPD','202406','OFFLINE','Baseline Qty',''

	select * from tmp_spectrum
*/


Alter Proc sp_FC_EXPORT_TO_FM_VIEW
	@Division		nvarchar(3),
	@FM_KEY			nvarchar(6),
	@Channel		nvarchar(10),
	@Timeseries		Nvarchar(30),
	@subgrp			nvarchar(500)
with encryption
As
begin
	declare 
		@debug				int=0,
		@sql				nvarchar(max) = '', 
		@year				nvarchar(4) = '', 
		@month				nvarchar(2) = '',
		@EventDescription	nvarchar(20) = '',
		@listColum			nvarchar(max) = '',
		@Timeseries_ok		nvarchar(20) = '',
		@Spectrum			int = 0,
		@n_continue			Int=1,
		@c_errmsg			nvarchar(250)=''

	declare 
		@b_Success1			Int,
		@c_errmsg1			Nvarchar(250)
	
	if @n_continue=1
	begin
		exec sp_FC_EXPORT_TO_FM @Division,@FM_KEY,@Channel,@Timeseries,@subgrp
	end
	select * from tmp_spectrum
end