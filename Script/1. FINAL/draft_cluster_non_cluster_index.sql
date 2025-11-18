
--check cluster index
select * 
INTO FC_FM_Original_CPD_202412_ClusteredIndex 
from FC_FM_Original_CPD_202412
GO

CREATE CLUSTERED INDEX Idx_FC_FM_Original_CPD_202412_ClusteredIndex_SUB_GROUP_Brand
ON FC_FM_Original_CPD_202412_ClusteredIndex([SUB GROUP/ Brand])
GO


--check non cluster index
select * 
INTO FC_FM_Original_CPD_202412_NonClusteredIndex
from FC_FM_Original_CPD_202412
GO
CREATE INDEX Idx_FC_FM_Original_CPD_202412_NonClusteredIndex_SUB_GROUP_Brand
ON FC_FM_Original_CPD_202412_NonClusteredIndex([SUB GROUP/ Brand])
GO

