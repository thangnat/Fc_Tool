/*
	select * from V_FC_BOMHEADER_FORM_FILTER_CONFIG
*/
Alter View V_FC_BOMHEADER_FORM_FILTER_CONFIG
As
select
	ID = isnull(ID,0),
	FilterName = isnull(Config1,''),
	Show = cast(isnull(Config2,'0') as bit)
from sysconfigvalue (NOLOCK)
where ConfigheaderID = 53