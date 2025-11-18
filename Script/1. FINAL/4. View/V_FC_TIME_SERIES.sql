/*
	select * from V_FC_TIME_SERIES Order by STT asc
*/

Alter view V_FC_TIME_SERIES
with encryption
As
select
	STT,
	TimeSeries,
	MAP,
	LLD,
	CPD,
	PPD,
	LDB
from
(
	select
		STT=cast(case 
					when left(isnull(Config2,''),1)<>'7' then replace(left(isnull(Config2,''),3),'.','') 
					else left(isnull(Config2,''),3) 
				end as numeric(18,1)),
		TimeSeries=Isnull(Config1,''),
		MAP=isnull(Config2,''),
		LLD=ISNULL(config5,''),
		CPD=ISNULL(config6,''),
		PPD=ISNULL(config7,''),
		LDB=ISNULL(config8,'')
	from SysConfigValue (NOLOCK)
	where ConfigHeaderID = 29
	and isnull(Config4,'0') ='1'
) as x
--order by STT asc
