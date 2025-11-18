/*
	sp_Get_request_compare_Gap 0
*/

Alter proc sp_Get_request_compare_Gap
	@All			int
As
select
	--[Channel] =c.[value],
	x.*
from
(
	select
		[Y0 M1]=cast(@all as bit),
		[Y0 M2]=cast(@all as bit),
		[Y0 M3]=cast(@all as bit),
		[Y0 M4]=cast(@all as bit),
		[Y0 M5]=cast(@all as bit),
		[Y0 M6]=cast(@all as bit),
		[Y0 M7]=cast(@all as bit),
		[Y0 M8]=cast(@all as bit),
		[Y0 M9]=cast(@all as bit),
		[Y0 M10]=cast(@all as bit),
		[Y0 M11]=cast(@all as bit),
		[Y0 M12]=cast(@all as bit),
		[Y+1 M1]=cast(@all as bit),
		[Y+1 M2]=cast(@all as bit),
		[Y+1 M3]=cast(@all as bit),
		[Y+1 M4]=cast(@all as bit),
		[Y+1 M5]=cast(@all as bit),
		[Y+1 M6]=cast(@all as bit),
		[Y+1 M7]=cast(@all as bit),
		[Y+1 M8]=cast(@all as bit),
		[Y+1 M9]=cast(@all as bit),
		[Y+1 M10]=cast(@all as bit),
		[Y+1 M11]=cast(@all as bit),
		[Y+1 M12]=cast(@all as bit)
) as x
