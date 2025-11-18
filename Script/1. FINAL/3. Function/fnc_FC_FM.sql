/*
	select DISTINCT [TIME SERIES] from fnc_FC_FM('CPD')
*/

alter Function fnc_FC_FM(@division nvarchar(3))
returns table
with encryption
As
return
select
	*
from
(
	select
		*
	from
	(
		select Division = 'LLD',* from FC_FM_LLD where [Local Level] = 'offline' and [Time series] = 'Baseline Qty'
		union all
		select Division = 'LLD',* from FC_FM_LLD where [Local Level] = 'online'
	) as lld
	union all
	select
		*
	from
	(
		select Division = 'CPD',* from FC_FM_CPD where [Local Level] = 'offline' and [Time series] = 'Baseline Qty'
		union all
		select Division = 'CPD',* from FC_FM_CPD where [Local Level] = 'online'
	) as cpd
) as x
where Division=@division
