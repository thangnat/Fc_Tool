/*
	select format(dbo.fnc_Get_RSP_LDB('LDB','SKN MOS HYDRATING B5 30ML EU',980,'2025','Jan'),'#,##0')
	select * from fnc_SubGroupMaster_RSP('LDB','full') where [SUB GROUP/ Brand]='1APAC EFFACL DUO(+) CR T7.5ML FR EN'
*/
Alter function fnc_Get_RSP_LDB(@division nvarchar(3),@subgrp nvarchar(300),@unit numeric(18,0),@year nvarchar(4),@month nvarchar(5))
	returns numeric(18,0)
As
begin
	declare @FM_KEY nvarchar(6)=''
	select @FM_KEY=FM_KEY from FC_ComputerName where ComputerName=HOST_NAME()
	--declare @division nvarchar(3)='LDB',@subgrp nvarchar(300)='1APAC EFFACL DUO(+) CR T7.5ML FR EN',@unit numeric(18,0)=1000,@year nvarchar(4)='2025',@month nvarchar(5)='Jun'
	declare @ColumnName nvarchar(20)=''
	--Create table FC_LDB_SO_RSP (id int identity(1,1),monthdesc nvarchar(10), [Month Name] nvarchar(10))
	declare @result nvarchar(20)
	--insert into FC_LDB_SO_RSP
	--(
	--	monthdesc,
	--	[Month Name]
	--)
	--values('Jan','M1'),('Feb','M2'),('Mar','M3'),('Apr','M4'),('May','M5'),('Jun','M6'),('Jul','M7'),('Aug','M8'),('Sep','M9'),('Oct','M10'),('Nov','M11'),('Dec','M12')
	--select * from @tmp

	select @ColumnName=case when cast(@year as int)=year(getdate()) then '[Y0 (u) ' else '[Y+1 (u) ' end+(select [Month Name] 
	from FC_LDB_SO_RSP where monthdesc=@month)+']'

	--select * from FC_LDB_SO_RSP
	--select @ColumnName '@ColumnName',len_ColumnName=len(@ColumnName)
	--select @result=cast(1000*[Y0 (u) M1] as numeric(18,0)) from fnc_SubGroupMaster_RSP('LDB','full') where [SUB GROUP/ Brand]='1APAC EFFACL DUO(+) CR T7.5ML FR EN'
	--select @result '@result',@ColumnName '@ColumnName'
	
	if @ColumnName='[Y0 (u) M1]'
	begin
		--select '1.1'
		--select result=cast(375*[Y0 (u) M1] as numeric(18,0)) from fnc_SubGroupMaster_RSP('LDB','full') where [SUB GROUP/ Brand]='SKN MOS HYDRATING B5 30ML EU'
		select @result=cast(1000*[Y0 (u) M1] as numeric(18,0)) from FC_BFL_Master_LDB where FM_KEY=@FM_KEY and [BFL Name]=@subgrp
	end
	else if @ColumnName='[Y0 (u) M2]'
	begin
		select @result=cast(@unit*[Y0 (u) M2] as numeric(18,0)) from FC_BFL_Master_LDB where FM_KEY=@FM_KEY and  [BFL Name]=@subgrp
	end
	else if @ColumnName='[Y0 (u) M3]'
	begin
		select @result=cast(@unit*[Y0 (u) M3] as numeric(18,0)) from FC_BFL_Master_LDB where FM_KEY=@FM_KEY and  [BFL Name]=@subgrp
	end
	else if @ColumnName='[Y0 (u) M4]'
	begin
		select @result=cast(@unit*[Y0 (u) M4] as numeric(18,0)) from FC_BFL_Master_LDB where FM_KEY=@FM_KEY and  [BFL Name]=@subgrp
	end
	else if @ColumnName='[Y0 (u) M5]'
	begin
		select @result=cast(@unit*[Y0 (u) M5] as numeric(18,0)) from FC_BFL_Master_LDB where FM_KEY=@FM_KEY and  [BFL Name]=@subgrp
	end
	else if @ColumnName='[Y0 (u) M6]'
	begin
		select @result=cast(@unit*[Y0 (u) M6] as numeric(18,0)) from FC_BFL_Master_LDB where FM_KEY=@FM_KEY and  [BFL Name]=@subgrp
	end
	else if @ColumnName='[Y0 (u) M7]'
	begin
		select @result=cast(@unit*[Y0 (u) M7] as numeric(18,0)) from FC_BFL_Master_LDB where FM_KEY=@FM_KEY and  [BFL Name]=@subgrp
	end
	else if @ColumnName='[Y0 (u) M8]'
	begin
		select @result=cast(@unit*[Y0 (u) M8] as numeric(18,0)) from FC_BFL_Master_LDB where FM_KEY=@FM_KEY and  [BFL Name]=@subgrp
	end
	else if @ColumnName='[Y0 (u) M9]'
	begin
		select @result=cast(@unit*[Y0 (u) M9] as numeric(18,0)) from FC_BFL_Master_LDB where FM_KEY=@FM_KEY and  [BFL Name]=@subgrp
	end
	else if @ColumnName='[Y0 (u) M10]'
	begin
		select @result=cast(@unit*[Y0 (u) M10] as numeric(18,0)) from FC_BFL_Master_LDB where FM_KEY=@FM_KEY and  [BFL Name]=@subgrp
	end
	else if @ColumnName='[Y0 (u) M11]'
	begin
		select @result=cast(@unit*[Y0 (u) M11] as numeric(18,0)) from FC_BFL_Master_LDB where FM_KEY=@FM_KEY and  [BFL Name]=@subgrp
	end
	else if @ColumnName='[Y0 (u) M12]'
	begin
		select @result=cast(@unit*[Y0 (u) M12] as numeric(18,0)) from FC_BFL_Master_LDB where FM_KEY=@FM_KEY and  [BFL Name]=@subgrp
	end
	else if @ColumnName='[Y+1 (u) M1]'
	begin
		select @result=cast(@unit*[Y+1 (u) M1] as numeric(18,0)) from FC_BFL_Master_LDB where FM_KEY=@FM_KEY and  [BFL Name]=@subgrp
	end
	else if @ColumnName='[Y+1 (u) M2]'
	begin
		select @result=cast(@unit*[Y+1 (u) M2] as numeric(18,0)) from FC_BFL_Master_LDB where FM_KEY=@FM_KEY and  [BFL Name]=@subgrp
	end
	else if @ColumnName='[Y+1 (u) M3]'
	begin
		select @result=cast(@unit*[Y+1 (u) M3] as numeric(18,0)) from FC_BFL_Master_LDB where FM_KEY=@FM_KEY and  [BFL Name]=@subgrp
	end
	else if @ColumnName='[Y+1 (u) M4]'
	begin
		select @result=cast(@unit*[Y+1 (u) M4] as numeric(18,0)) from FC_BFL_Master_LDB where FM_KEY=@FM_KEY and  [BFL Name]=@subgrp
	end
	else if @ColumnName='[Y+1 (u) M5]'
	begin
		select @result=cast(@unit*[Y+1 (u) M5] as numeric(18,0)) from FC_BFL_Master_LDB where FM_KEY=@FM_KEY and  [BFL Name]=@subgrp
	end
	else if @ColumnName='[Y+1 (u) M6]'
	begin
		--select @ColumnName from fnc_SubGroupMaster_RSP(@Division,'full') where [SUB GROUP/ Brand]=@subgrp
		select @result=cast(@unit*[Y+1 (u) M6] as numeric(18,0)) from FC_BFL_Master_LDB where FM_KEY=@FM_KEY and  [BFL Name]=@subgrp
	end
	--select @result '@result'
	else if @ColumnName='[Y+1 (u) M7]'
	begin
		select @result=cast(@unit*[Y+1 (u) M7] as numeric(18,0)) from FC_BFL_Master_LDB where FM_KEY=@FM_KEY and  [BFL Name]=@subgrp
	end
	else if @ColumnName='[Y+1 (u) M8]'
	begin
		select @result=cast(@unit*[Y+1 (u) M8] as numeric(18,0)) from FC_BFL_Master_LDB where FM_KEY=@FM_KEY and  [BFL Name]=@subgrp
	end
	else if @ColumnName='[Y+1 (u) M9]'
	begin
		select @result=cast(@unit*[Y+1 (u) M9] as numeric(18,0)) from FC_BFL_Master_LDB where FM_KEY=@FM_KEY and  [BFL Name]=@subgrp
	end
	else if @ColumnName='[Y+1 (u) M10]'
	begin
		select @result=cast(@unit*[Y+1 (u) M10] as numeric(18,0)) from FC_BFL_Master_LDB where FM_KEY=@FM_KEY and  [BFL Name]=@subgrp
	end
	else if @ColumnName='[Y+1 (u) M11]'
	begin
		select @result=cast(@unit*[Y+1 (u) M11] as numeric(18,0)) from FC_BFL_Master_LDB where FM_KEY=@FM_KEY and  [BFL Name]=@subgrp
	end
	else if @ColumnName='[Y+1 (u) M12]'
	begin
		select @result=cast(@unit*[Y+1 (u) M12] as numeric(18,0)) from FC_BFL_Master_LDB where FM_KEY=@FM_KEY and  [BFL Name]=@subgrp
	end
	--select @result '@result'
	return @result
end
   