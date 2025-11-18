/*
	select * from fnc_FC_SO_OPTIMUS_MAPPING_SUBGRP('CPD')
*/

Alter function fnc_FC_SO_OPTIMUS_MAPPING_SUBGRP--No use
(
	@division		nvarchar(3)
)
returns @tablefinal table
(
	[SUB GROUP/ Brand]		nvarchar(500) null,
	[Forecasting lines]		nvarchar(500) null
)
with encryption
As
return
select
	*
from
(
	select DISTINCT
		[Division]='CPD',
		[SUB GROUP/ Brand] = m.[SUB GROUP],
		[Forecasting lines]
	from select * from FC_SO_OPTIMUS_MAPPING_SUBGRP m
	where isnull(Active,0) = 1
	union all
	
) as x
where Division=@division