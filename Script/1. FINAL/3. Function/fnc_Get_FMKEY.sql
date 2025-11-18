/*
	select dbo.fnc_Get_FMKEY('VNCORPVNWKS0850')
*/

Alter function fnc_Get_FMKEY(@Hostname nvarchar(50))
	returns Nvarchar(6)
	with encryption
As
begin
	declare @FM_KEY nvarchar(6)=''
	declare @hostname_ok nvarchar(50)=''
	--select @hostname_ok=HOST_NAME()
	if @hostname=''
	begin
		select @hostname_ok=HOST_NAME()
	end
	else
	begin
		select @hostname_ok=@Hostname
	end
	select @FM_KEY=isnull(FM_KEY,'') from FC_ComputerName where ComputerName=@hostname_ok
	return @FM_KEY
end
