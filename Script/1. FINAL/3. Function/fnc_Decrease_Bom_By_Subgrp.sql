/*
	select * from fnc_Decrease_Bom_By_Subgrp(1000)

	select tablename = 'Final-decrease',* 
	from FC_SUBGRP_CHANGE_QTY_FINAL
*/

Alter function fnc_Decrease_Bom_By_Subgrp
(
	@QtyGap_Decrease int
)
returns @tmpFinal TABLE 
(
	id				int identity(1,1), 
	Material_Bom	nvarchar(20),
	CurrentQty		int,
	AllocateQty		int,
	QtyNeedtochangeBom int
)
with encryption
As
begin
	--declare @QtyGap_Decrease int = 1000
	declare @currentrow int = 1, @totalrow int = 0

	select @totalrow = isnull(count(*),0) from FC_SUBGRP_CHANGE_QTY_FINAL
	--select tablename = 'Final-decrease',* 
	--from FC_SUBGRP_CHANGE_QTY_FINAL
	declare @allocateQty int = 0
	while (@currentrow<=@totalrow)
	begin
		declare @material_bom nvarchar(20)='',@currentqty int = 0,@QtyneedtochangeBom int = 0, @mainQty int = 0, @TranslateneedQtyChange int = 0
		select @material_bom = material_bom, @currentqty = currentqty*mainqty, @mainQty = mainQty from FC_SUBGRP_CHANGE_QTY_FINAL where priority = @currentrow
		--select @TranslateneedQtyChange = @QtyGap_Decrease/@mainQty
		--select @allocateQty '@allocateQty',@QtyGap_Decrease '@QtyGap_Decrease'
		if (@allocateQty)>=@QtyGap_Decrease
		begin
			return
		end
		else
		begin
			if @currentqty>=(@QtyGap_Decrease-@allocateQty)
			begin
				select @QtyneedtochangeBom = (@QtyGap_Decrease-@allocateQty)/@mainQty
				select @allocateQty = (@allocateQty+(@QtyGap_Decrease-@allocateQty))
			
			end
			else
			begin
				select @QtyneedtochangeBom = @currentqty/@mainQty
				select @allocateQty = (@allocateQty+@QtyneedtochangeBom*@mainQty)
			end
			--select @allocateQty = @allocateQty*@mainQty
			--select @QtyneedtochangeBom = @allocateQty
		end
		insert into @tmpFinal(Material_Bom,CurrentQty,AllocateQty,QtyNeedtochangeBom)
		select @material_bom '@material_bom', @currentqty/@mainQty '@currentqty', @allocateQty '@allocateQty', @QtyneedtochangeBom*-1 '@QtyneedtochangeBom'
		select @currentrow = @currentrow +1
	end
	--select * from @tmpFinal
	return
end

