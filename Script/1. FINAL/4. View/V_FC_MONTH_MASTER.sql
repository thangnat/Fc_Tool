/*
select * from V_FC_MONTH_MASTER where Month_number = '1'
*/
Alter View V_FC_MONTH_MASTER
with encryption
As
select * from V_Month_Master