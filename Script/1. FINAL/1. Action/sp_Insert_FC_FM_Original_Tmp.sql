CREATE OR ALTER PROCEDURE [dbo].[sp_Insert_FC_FM_Original_Tmp]
    @Division NVARCHAR(50),   -- ví dụ: 'LDB'
    @MonthFC CHAR(6)          -- ví dụ: '202505'
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @sql NVARCHAR(MAX);
    DECLARE @tableName NVARCHAR(200);
    DECLARE @sourceTableName NVARCHAR(200);
    
    -- Tạo tên bảng động
    SET @tableName = N'[dbo].[FC_FM_Original_' + @Division + '_' + @MonthFC + '_Tmp]';
    SET @sourceTableName = N'[dbo].[FC_FM_Original_' + @Division + '_' + @MonthFC + ']';
    
    -- Kiểm tra và tạo bảng nếu chưa tồn tại
    SET @sql = N'
    IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''' + @tableName + ''') AND type in (N''U''))
    BEGIN
        CREATE TABLE ' + @tableName + '
        (
            [id] INT,
            [Product type] NVARCHAR(100),
            [SUB GROUP/ Brand] NVARCHAR(100),
            [Channel] NVARCHAR(50),
            [Time series] NVARCHAR(100),
            [Y0 (u) M1] DECIMAL(18,2),
            [Y0 (u) M2] DECIMAL(18,2),
            [Y0 (u) M3] DECIMAL(18,2),
            [Y0 (u) M4] DECIMAL(18,2),
            [Y0 (u) M5] DECIMAL(18,2),
            [Y0 (u) M6] DECIMAL(18,2),
            [Y0 (u) M7] DECIMAL(18,2),
            [Y0 (u) M8] DECIMAL(18,2),
            [Y0 (u) M9] DECIMAL(18,2),
            [Y0 (u) M10] DECIMAL(18,2),
            [Y0 (u) M11] DECIMAL(18,2),
            [Y0 (u) M12] DECIMAL(18,2),
            [Y+1 (u) M1] DECIMAL(18,2),
            [Y+1 (u) M2] DECIMAL(18,2),
            [Y+1 (u) M3] DECIMAL(18,2),
            [Y+1 (u) M4] DECIMAL(18,2),
            [Y+1 (u) M5] DECIMAL(18,2),
            [Y+1 (u) M6] DECIMAL(18,2),
            [Y+1 (u) M7] DECIMAL(18,2),
            [Y+1 (u) M8] DECIMAL(18,2),
            [Y+1 (u) M9] DECIMAL(18,2),
            [Y+1 (u) M10] DECIMAL(18,2),
            [Y+1 (u) M11] DECIMAL(18,2),
            [Y+1 (u) M12] DECIMAL(18,2)
        );
    END
    ELSE
    BEGIN
        TRUNCATE TABLE ' + @tableName + ';
    END
    
    INSERT INTO ' + @tableName + '
    (
		[Id],
        [Product type],
        [SUB GROUP/ Brand],
        [Channel],
        [Time series],
        [Y0 (u) M1],
        [Y0 (u) M2],
        [Y0 (u) M3],
        [Y0 (u) M4],
        [Y0 (u) M5],
        [Y0 (u) M6],
        [Y0 (u) M7],
        [Y0 (u) M8],
        [Y0 (u) M9],
        [Y0 (u) M10],
        [Y0 (u) M11],
        [Y0 (u) M12],
        [Y+1 (u) M1],
        [Y+1 (u) M2],
        [Y+1 (u) M3],
        [Y+1 (u) M4],
        [Y+1 (u) M5],
        [Y+1 (u) M6],
        [Y+1 (u) M7],
        [Y+1 (u) M8],
        [Y+1 (u) M9],
        [Y+1 (u) M10],
        [Y+1 (u) M11],
        [Y+1 (u) M12]
    )
    SELECT
		[Id],
        [Product type],
        [SUB GROUP/ Brand],
        [Channel],
        [Time series],
        [Y0 (u) M1],
        [Y0 (u) M2],
        [Y0 (u) M3],
        [Y0 (u) M4],
        [Y0 (u) M5],
        [Y0 (u) M6],
        [Y0 (u) M7],
        [Y0 (u) M8],
        [Y0 (u) M9],
        [Y0 (u) M10],
        [Y0 (u) M11],
        [Y0 (u) M12],
        [Y+1 (u) M1],
        [Y+1 (u) M2],
        [Y+1 (u) M3],
        [Y+1 (u) M4],
        [Y+1 (u) M5],
        [Y+1 (u) M6],
        [Y+1 (u) M7],
        [Y+1 (u) M8],
        [Y+1 (u) M9],
        [Y+1 (u) M10],
        [Y+1 (u) M11],
        [Y+1 (u) M12]
    FROM ' + @sourceTableName + '
    WHERE [Time series] IN (''1. Baseline Qty'',''2. Promo Qty(Single)'',''3. Promo Qty(BOM)'',
                            ''4. Launch Qty'',''5. FOC Qty'',''6. Total Qty'')
      AND Channel <> ''O+O'';';
    
    EXEC sp_executesql @sql;
END