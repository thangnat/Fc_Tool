/*
	exec sp_Create_Raw_vs_Convert_SOH_MTD_SI_FINAL 'LDB','202412','full'
*/
--select * from fnc_SubGroupMaster('LLD','full') where Barcode='4936968816017'
Alter proc sp_Create_Raw_vs_Convert_SOH_MTD_SI_FINAL
	@Division			nvarchar(3),
	@FM_Key				nvarchar(6),
	@Type				Nvarchar(4)--//full, active
	with encryption
As
	DECLARE   
		 @debug					int=0
		,@sp_name				Nvarchar(100)
		,@n_continue			Int
		,@USERS					Nvarchar(50)
		,@MODIFILED				Datetime
		,@n_err					int	
		,@sql					nvarchar(max) = ''
		,@sql1					nvarchar(max) = ''

	SELECT	
		@n_continue=1, 
		--@b_success=0,
		@n_err=0,
		--@c_errmsg='', 
		@sp_name = 'sp_Create_SOH_FINAL_TEST',
		@USERS = SUSER_NAME(),
		@MODIFILED = GETDATE()

	select @debug=debug from fnc_debug('FC')
	--select @debug=1


	declare @tmp table 
	(
		id int identity(1,1),
		[Type]					nvarchar(20) null,
		[Product Type]			nvarchar(20) null,
		[SUB GROUP/ Brand]		nvarchar(500) null,
		[Barcode_Original]		nvarchar(50) null,
		[Barcode]				nvarchar(50) null,
		[Channel]				nvarchar(20) null,
		[Time series]			nvarchar(50) null,
		[TotalQty]				INT default 0
	)

	insert into @tmp
	exec sp_Create_MTD_RAW_vs_Convert_FINAL @Division,@FM_Key,'full'

	insert into @tmp
	exec sp_Create_SOH_FINAL_TEST @Division,@FM_Key,'full'

	select * from @tmp