/*
	select * from V_FC_Cluster where Division='CPD'
*/
Alter View V_FC_Cluster
As
select
	ID,
	[Division],
	[Client Name],
	[Cluster]='Cluster '+cast([Cluster] as nvarchar(2))
from
(
	select
		ID,
		[Division]=isnull(Config1,''),
		[Client Name]=isnull(Config2,''),
		[Cluster]=isnull(Config3,''),
		[Active]=isnull(Config4,'')
	from SysConfigValue (NOLOCK)
	where ConfigHeaderID=68
) as x
where [Active]='1'
