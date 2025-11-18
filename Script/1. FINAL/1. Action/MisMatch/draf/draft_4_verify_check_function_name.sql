select distinct [Function Name],[Type Name]
from fc_validate_mismatch_si_his_fc
where Division='PPD'
and FM_KEY='202410'


select * from fc_validate_mismatch_si_his_fc
where Division='PPD'
and FM_KEY='202410'
and [Function Name]='SI ACTUAL FOC BOM COMPONENT'

--select * from fnc_SubGroupMaster('PPD','full') where Barcode='3474636975457'
--select * from fnc_SubGroupMaster('PPD','full') where [SUB GROUP/ Brand]='Inoa Mocca Family 60 Gr T'

if @debug>0
begin
	select 'Mismatch'
end
if @n_continue=1
begin
	if @Division NOT IN('PPD1')
	begin
		exec sp_FM_validate_mismatch @Division,@FM_KEY,@b_Success1 OUT, @c_errmsg1 OUT

		if @b_Success1 = 0
		begin
			select @n_continue = 1, @c_errmsg = @c_errmsg1
		end
	END
end

if @debug>0
	begin
		select 'Mismatch'
	end
	if @n_continue=1
	begin
		if @Division NOT IN('PPD1')
		begin
			declare @Foldername		nvarchar(50)='B'

			exec sp_BUDGET_TREND_validate_mismatch @Division,@FM_KEY,@Foldername,@b_Success1 OUT, @c_errmsg1 OUT

			if @b_Success1 = 0
			begin
				select @n_continue = 1, @c_errmsg = @c_errmsg1
			end
		END
	end
