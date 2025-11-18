# Quy Trình Mapping Dữ Liệu - Data Mapping Process

## 1. Tổng Quan Quy Trình Mapping

Quy trình mapping dữ liệu chuyển đổi dữ liệu từ nhiều nguồn khác nhau (SAP, Excel files, User input) thành format chuẩn trong Working File để phục vụ việc dự báo.

```
┌─────────────────────────────────────────────────────────────────┐
│                    INPUT SOURCES                                 │
├─────────────────────────────────────────────────────────────────┤
│  SAP Material Code     Excel Data        User Forecast          │
│  (3600542410311)      (Various formats)  (Manual input)         │
└──────────────────┬──────────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────────┐
│              STAGE 1: PRODUCT HIERARCHY MAPPING                  │
├─────────────────────────────────────────────────────────────────┤
│  SAP Material → Spectrum → BFL → Sub Group                      │
│  3600542410311 → Spectrum Master → LOP Revitalift Cream         │
└──────────────────┬──────────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────────┐
│              STAGE 2: CHANNEL MAPPING                            │
├─────────────────────────────────────────────────────────────────┤
│  Customer Code → Channel (GT/MT/ONLINE)                         │
│  1000123 → MT → OFFLINE                                         │
│  2000456 → E-COM → ONLINE                                       │
└──────────────────┬──────────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────────┐
│              STAGE 3: TIME SERIES MAPPING                        │
├─────────────────────────────────────────────────────────────────┤
│  Order Type → Time Series                                       │
│  ZOR → Baseline Qty                                             │
│  ZFOC → FOC Qty                                                 │
│  Launch Flag → Launch Qty                                       │
└──────────────────┬──────────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────────┐
│              STAGE 4: PERIOD MAPPING                             │
├─────────────────────────────────────────────────────────────────┤
│  Date → Year/Month → Column Name                                │
│  2025-01-15 → Y0_M1 → [Y0 (u) M1]                              │
│  2026-03-20 → Y1_M3 → [Y+1 (u) M3]                             │
└──────────────────┬──────────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────────┐
│              STAGE 5: AGGREGATION & CONSOLIDATION                │
├─────────────────────────────────────────────────────────────────┤
│  Group by: Sub_Group + Channel + Time_Series + Period           │
│  Sum: Quantities                                                │
│  Calculate: Totals, O+O, Gaps                                   │
└──────────────────┬──────────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────────┐
│                    WORKING FILE (WF)                             │
├─────────────────────────────────────────────────────────────────┤
│  Final consolidated view for forecasting                        │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. STAGE 1: Product Hierarchy Mapping

### 2.1. SAP Material → Spectrum

**Nguồn:** Spectrum Master file

**Function:** `fnc_SubGroupMaster()`

**Mapping Logic:**
```sql
-- From database function
SELECT
    sm.Spectrum,
    sm.Product_Type,
    sm.Category,
    sm.Sub_Category,
    sm.Brand,
    sm.Sub_Brand,
    sm.Sub_Group,
    sm.Channel AS Product_Channel
FROM Spectrum_Master sm
WHERE sm.Spectrum = @Material_Code
  AND sm.Division = @Division
  AND sm.Status = 'ACTIVE'
```

**Mapping Table:**
| SAP Material | Spectrum | Product Type | Sub Group | Brand |
|--------------|----------|--------------|-----------|-------|
| 3600542410311 | 3600542410311 | Finished Good | LOP Revitalift Cream | L'Oreal Paris |
| 3600542410328 | 3600542410328 | Finished Good | LOP Revitalift Serum | L'Oreal Paris |
| 3600542410399 | 3600542410399 | Bundle | LOP Gift Set 2025 | L'Oreal Paris |
| 3600541234567 | 3600541234567 | Promo Pack | LOP Promo Pack Q1 | L'Oreal Paris |

**Business Rules:**
1. **Direct Match:** SAP Material = Spectrum (trong hầu hết trường hợp)
2. **Status Check:** Chỉ mapping products có Status = 'ACTIVE'
3. **Division Filter:** Phải match Division (CPD, LDB, LLD)
4. **Hierarchy Level:** Sub_Group là level để forecast (không forecast ở SKU level)

**Error Handling:**
```csharp
// From cls_function.cs
if (spectrum == null || spectrum == "")
{
    LogError($"Material {materialCode} not found in Spectrum Master");
    return "UNMAPPED";
}
```

### 2.2. BFL Mapping

**Nguồn:** BFL Master file

**Purpose:** Map internal BFL code với Spectrum

**Mapping Logic:**
```sql
SELECT
    bfl.BFL_Code,
    bfl.Spectrum,
    bfl.Product_Name,
    bfl.EAN_Code,
    bfl.Is_Bundle,
    bfl.Unit_Per_Case
FROM BFL_Master bfl
WHERE bfl.Spectrum = @Spectrum
  AND bfl.Division = @Division
```

**Mapping Table:**
| BFL Code | Spectrum | Product Name | Is Bundle | Unit/Case |
|----------|----------|--------------|-----------|-----------|
| BFL_CPD_001 | 3600542410311 | LOP Revitalift Cream 50ml | 0 | 24 |
| BFL_CPD_002 | 3600542410328 | LOP Revitalift Serum 30ml | 0 | 36 |
| BFL_CPD_099 | 3600542410399 | LOP Gift Set 2025 | 1 | 12 |

**Usage:**
- Unit conversion: Units ↔ Cases
- Bundle identification
- EAN code for external systems

### 2.3. Product Type Mapping

**Product Types và cách xử lý:**

| Product Type | Forecast Logic | BOM Required | Example |
|--------------|----------------|--------------|---------|
| **Finished Good** | Direct forecast | No | LOP Revitalift Cream |
| **Bundle** | Bundle forecast + Component explosion | Yes | LOP Gift Set |
| **Promo Pack** | Promo time series | Optional | LOP Promo Q1 |
| **Sample** | FOC time series | No | LOP Sample 5ml |

**Code Implementation:**
```csharp
// From cls_function.cs
switch (productType)
{
    case "Finished Good":
        // Direct mapping to Sub_Group
        forecastLine = subGroup;
        break;

    case "Bundle":
        // Check BOM existence
        if (!HasBOM(spectrum))
        {
            throw new Exception($"Bundle {spectrum} missing BOM configuration");
        }
        forecastLine = subGroup;
        explodeBOM = true;
        break;

    case "Promo Pack":
        // Map to promo time series
        forecastLine = subGroup;
        timeSeries = "2. Promo Qty";
        break;

    case "Sample":
        // Map to FOC time series
        forecastLine = subGroup;
        timeSeries = "5. FOC Qty";
        break;
}
```

---

## 3. STAGE 2: Channel Mapping

### 3.1. Customer → Channel

**Nguồn:** Customer Master + SAP SO data

**Function:** Channel mapping logic

**Mapping Logic:**
```sql
SELECT
    c.Customer_Code,
    c.Customer_Name,
    c.Channel AS Customer_Channel,
    CASE
        WHEN c.Channel IN ('GT', 'MT', 'PHARMA', 'SALON') THEN 'OFFLINE'
        WHEN c.Channel = 'ONLINE' THEN 'ONLINE'
        ELSE 'OFFLINE'
    END AS Forecast_Channel
FROM Customer_Master c
WHERE c.Active = 1
  AND c.Division = @Division
```

**Channel Mapping Table:**

| Customer Channel | Forecast Channel | Description |
|------------------|------------------|-------------|
| GT (General Trade) | OFFLINE | Cửa hàng tạp hóa, siêu thị nhỏ |
| MT (Modern Trade) | OFFLINE | Siêu thị lớn (CO.OP, BigC, Lotte) |
| PHARMA | OFFLINE | Nhà thuốc, chuỗi Guardian |
| SALON | OFFLINE | Salon chuyên nghiệp |
| ONLINE | ONLINE | Shopee, Lazada, Tiki, Website |

**Business Rules:**
1. **Default to OFFLINE:** Nếu không xác định được → OFFLINE
2. **O+O Calculation:** ONLINE + OFFLINE = O+O (tổng tất cả channels)
3. **Channel-specific products:** Một số products chỉ bán ONLINE hoặc OFFLINE

**Example Mapping:**
```
Customer: CO.OP MART (Code: 1000123)
→ Customer_Channel: MT
→ Forecast_Channel: OFFLINE

Customer: SHOPEE VN (Code: 2000456)
→ Customer_Channel: ONLINE
→ Forecast_Channel: ONLINE
```

### 3.2. O+O (Online + Offline) Aggregation

**Formula:**
```
O+O Qty = ONLINE Qty + OFFLINE Qty
```

**SQL Implementation:**
```sql
-- From sp_tag_update_wf_calculation_fc_unit_Refresh_All
INSERT INTO WF_Temp (Sub_Group, Channel, Time_Series, Period, Quantity)
SELECT
    Sub_Group,
    'O+O' AS Channel,
    Time_Series,
    Period,
    SUM(Quantity) AS Quantity
FROM WF_Temp
WHERE Channel IN ('ONLINE', 'OFFLINE')
GROUP BY Sub_Group, Time_Series, Period
```

**WF Display:**
```
Sub Group: LOP Revitalift Cream
├─ ONLINE  - 1. Baseline Qty - 5000
├─ OFFLINE - 1. Baseline Qty - 8000
└─ O+O     - 1. Baseline Qty - 13000 (auto-calculated)
```

---

## 4. STAGE 3: Time Series Mapping

### 4.1. Order Type → Time Series

**Nguồn:** SAP ZV14 Order Type

**Mapping Table:**

| SAP Order Type | Time Series | Description | Example Use Case |
|----------------|-------------|-------------|------------------|
| ZOR (Normal Order) | 1. Baseline Qty | Đơn hàng thường | Regular orders |
| ZPROMO | 2. Promo Qty | Đơn khuyến mãi | Trade promo, consumer promo |
| ZLAUNCH | 4. Launch Qty | Sản phẩm mới | New product launch |
| ZFOC | 5. FOC Qty | Tặng kèm | Free samples, gifts |
| ZSP (Special) | 1. Baseline Qty | Đơn đặc biệt | Special projects |

**Mapping Logic:**
```sql
SELECT
    Material,
    Order_Type,
    CASE Order_Type
        WHEN 'ZOR' THEN '1. Baseline Qty'
        WHEN 'ZPROMO' THEN '2. Promo Qty'
        WHEN 'ZLAUNCH' THEN '4. Launch Qty'
        WHEN 'ZFOC' THEN '5. FOC Qty'
        WHEN 'ZSP' THEN '1. Baseline Qty'
        ELSE '1. Baseline Qty'
    END AS Time_Series,
    Quantity
FROM ZV14_Orders
WHERE Status = 'C'
```

### 4.2. Launch Detection

**Logic để xác định Launch Qty:**

**Method 1: Order Type Flag**
```sql
-- Direct from ZV14
WHERE Order_Type = 'ZLAUNCH'
```

**Method 2: Launch Date Range**
```sql
-- From Spectrum Master
SELECT
    s.Spectrum,
    s.Launch_Date,
    DATEADD(MONTH, 3, s.Launch_Date) AS Launch_End_Date
FROM Spectrum_Master s

-- Apply to forecast
WHERE Order_Date BETWEEN s.Launch_Date AND Launch_End_Date
  AND DATEDIFF(MONTH, s.Launch_Date, Order_Date) < 3
```

**Launch Period Rules:**
- **Launch Qty** chỉ áp dụng trong 3 tháng đầu sau Launch_Date
- Sau 3 tháng, chuyển sang Baseline Qty
- Launch products thường có higher forecast risk

**Example:**
```
Product: LOP New Serum
Launch Date: 2025-01-01

Month       | Time Series
------------|-------------
2025-01     | 4. Launch Qty
2025-02     | 4. Launch Qty
2025-03     | 4. Launch Qty
2025-04     | 1. Baseline Qty (switched)
```

### 4.3. Promo Period Mapping

**Nguồn:** Promo Calendar + ZV14 Order Type

**Promo Types:**
| Promo Type | Duration | Time Series | Example |
|------------|----------|-------------|---------|
| Trade Promo | 1 month | 2. Promo Qty | Volume discount for retailers |
| Consumer Promo | 2-4 weeks | 2. Promo Qty | Buy 1 Get 1, Discount |
| Seasonal Campaign | 1-3 months | 2. Promo Qty | Tet, Christmas |
| Flash Sale | 1-7 days | 2. Promo Qty | Online flash sale |

**Mapping Logic:**
```sql
-- From Promo Calendar
SELECT
    pc.Promo_ID,
    pc.Sub_Group,
    pc.Channel,
    pc.Start_Date,
    pc.End_Date,
    pc.Promo_Type
FROM Promo_Calendar pc
WHERE pc.Status = 'CONFIRMED'

-- Apply to forecast periods
WHERE Period_Date BETWEEN pc.Start_Date AND pc.End_Date
  AND Time_Series = '2. Promo Qty'
```

### 4.4. Total Qty Calculation

**Formula:**
```
6. Total Qty = 1. Baseline Qty + 2. Promo Qty + 4. Launch Qty + 5. FOC Qty
```

**SQL Implementation:**
```sql
-- From sp_tag_update_wf_calculation_fc_unit_Refresh_All
UPDATE wf
SET wf.Total_Qty =
    ISNULL(b.Baseline_Qty, 0) +
    ISNULL(p.Promo_Qty, 0) +
    ISNULL(l.Launch_Qty, 0) +
    ISNULL(f.FOC_Qty, 0)
FROM WF_Master wf
LEFT JOIN (SELECT Sub_Group, Channel, Period, Quantity AS Baseline_Qty
           FROM WF_Master WHERE Time_Series = '1. Baseline Qty') b
    ON wf.Sub_Group = b.Sub_Group AND wf.Channel = b.Channel AND wf.Period = b.Period
LEFT JOIN (SELECT Sub_Group, Channel, Period, Quantity AS Promo_Qty
           FROM WF_Master WHERE Time_Series = '2. Promo Qty') p
    ON wf.Sub_Group = p.Sub_Group AND wf.Channel = p.Channel AND wf.Period = p.Period
LEFT JOIN (SELECT Sub_Group, Channel, Period, Quantity AS Launch_Qty
           FROM WF_Master WHERE Time_Series = '4. Launch Qty') l
    ON wf.Sub_Group = l.Sub_Group AND wf.Channel = l.Channel AND wf.Period = l.Period
LEFT JOIN (SELECT Sub_Group, Channel, Period, Quantity AS FOC_Qty
           FROM WF_Master WHERE Time_Series = '5. FOC Qty') f
    ON wf.Sub_Group = f.Sub_Group AND wf.Channel = f.Channel AND wf.Period = f.Period
WHERE wf.Time_Series = '6. Total Qty'
```

**Example:**
```
Sub Group: LOP Revitalift Cream
Channel: ONLINE
Period: Y0_M1

1. Baseline Qty: 5000
2. Promo Qty:    1000
4. Launch Qty:   0
5. FOC Qty:      500
----------------------------
6. Total Qty:    6500 (auto-calculated)
```

---

## 5. STAGE 4: Period Mapping

### 5.1. Date → Period Name

**FM_KEY Format:** `{Division}_{YYYY}_{MM}`

Example: `CPD_2025_01` (CPD division, January 2025)

**Function:** `fnc_Get_FMKEY()`

**Mapping Logic:**
```sql
CREATE FUNCTION fnc_Get_FMKEY(@Date DATE, @Division VARCHAR(3))
RETURNS VARCHAR(20)
AS
BEGIN
    DECLARE @FMKEY VARCHAR(20)
    DECLARE @Year INT = YEAR(@Date)
    DECLARE @Month INT = MONTH(@Date)

    SET @FMKEY = @Division + '_' +
                 CAST(@Year AS VARCHAR(4)) + '_' +
                 RIGHT('0' + CAST(@Month AS VARCHAR(2)), 2)

    RETURN @FMKEY
END
```

**Example:**
```
Date: 2025-01-15
Division: CPD
→ FM_KEY: CPD_2025_01
```

### 5.2. Period → Column Name

**Base Date:** FM_KEY month (ví dụ: January 2025)

**Column Name Formula:**
```
Y0 = Current year (2025)
Y-1 = Previous year (2024)
Y-2 = 2 years ago (2023)
Y+1 = Next year (2026)

M1-M12 = Months 1-12

Column format: [Y{offset} (u) M{month}]
```

**Mapping Table:**

| Period Date | Year Offset | Month | Column Name | Type |
|-------------|-------------|-------|-------------|------|
| 2023-01-01 | Y-2 | M1 | [Y-2 (u) M1] | Historical |
| 2024-01-01 | Y-1 | M1 | [Y-1 (u) M1] | Historical |
| 2025-01-01 | Y0 | M1 | [Y0 (u) M1] | Current/Forecast |
| 2025-06-01 | Y0 | M6 | [Y0 (u) M6] | Forecast |
| 2026-01-01 | Y+1 | M1 | [Y+1 (u) M1] | Forecast |
| 2026-12-01 | Y+1 | M12 | [Y+1 (u) M12] | Forecast |

**SQL Implementation:**
```sql
-- From sp_Update_WF_Master
DECLARE @BaseYear INT = YEAR(@FM_Date)
DECLARE @CurrentMonth INT = MONTH(@FM_Date)

-- Generate Y0 columns
DECLARE @Month INT = 1
WHILE @Month <= 12
BEGIN
    DECLARE @ColName VARCHAR(50) = '[Y0 (u) M' + CAST(@Month AS VARCHAR(2)) + ']'

    -- Add column if not exists
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
                   WHERE TABLE_NAME = 'WF_Master' AND COLUMN_NAME = @ColName)
    BEGIN
        EXEC('ALTER TABLE WF_Master ADD ' + @ColName + ' INT NULL')
    END

    SET @Month = @Month + 1
END
```

### 5.3. Historical vs Forecast Period Split

**Current Month Logic:**
```
FM_KEY: CPD_2025_01 (January 2025)

Historical Periods (Read-only):
- Y-2: All months (2023-01 to 2023-12)
- Y-1: All months (2024-01 to 2024-12)
- Y0: Past months (2025-01 to current completed month)

Forecast Periods (Editable):
- Y0: Current month onwards (2025-01 onwards if FM = Jan 2025)
- Y+1: All months (2026-01 to 2026-12)
```

**Code Logic:**
```csharp
// From cls_function.cs
DateTime fmDate = GetFMDate(fmKey); // 2025-01-01
DateTime today = DateTime.Now;      // 2025-01-15

for (int month = 1; month <= 12; month++)
{
    DateTime periodDate = new DateTime(fmDate.Year, month, 1);

    string columnName = $"[Y0 (u) M{month}]";
    bool isHistorical = periodDate < today.Date;
    bool isEditable = !isHistorical;

    // Set column properties
    SetColumnReadOnly(columnName, isHistorical);
    SetColumnColor(columnName, isHistorical ? Color.LightBlue : Color.LightGreen);
}
```

### 5.4. Rolling Period Update

**Khi chuyển sang tháng mới:**

**Example: FM_KEY changes from CPD_2025_01 to CPD_2025_02**

**Actions:**
1. **Lock previous month forecast:**
   - Y0_M1 chuyển từ editable → read-only
   - Save as M-1 (reference forecast)

2. **Shift historical data:**
   - Load actual SO/SI data for completed month
   - Update [Y0 (u) M1] với actual data

3. **Update column headers:**
   - Recalculate year offsets nếu sang năm mới
   - Update color coding

**SQL Procedure:**
```sql
-- From sp_Update_WF_Master
EXEC sp_Update_WF_Master
    @Division = 'CPD',
    @Old_FMKEY = 'CPD_2025_01',
    @New_FMKEY = 'CPD_2025_02'

-- Actions:
-- 1. Archive old FM to FM_History table
-- 2. Update column definitions
-- 3. Load new historical data
-- 4. Unlock new forecast months
```

---

## 6. STAGE 5: Aggregation & Consolidation

### 6.1. Aggregation Levels

**Hierarchy:**
```
Division (CPD, LDB, LLD)
└─ Sub_Group (LOP Revitalift Cream)
   └─ Channel (ONLINE, OFFLINE, O+O)
      └─ Time_Series (Baseline, Promo, Launch, FOC, Total)
         └─ Period (Y-2_M1...Y+1_M12)
            └─ Quantity (SUM)
```

**SQL Aggregation:**
```sql
-- From fnc_FC_FM_Original
SELECT
    Division,
    Sub_Group,
    Channel,
    Time_Series,
    Period,
    SUM(Quantity) AS Total_Quantity
FROM (
    -- Historical SO
    SELECT Division, Sub_Group, Channel, '1. Baseline Qty' AS Time_Series,
           Period, SUM(SO_Qty) AS Quantity
    FROM Historical_SO
    GROUP BY Division, Sub_Group, Channel, Period

    UNION ALL

    -- Forecast input
    SELECT Division, Sub_Group, Channel, Time_Series, Period, Quantity
    FROM FC_FM_Input

    UNION ALL

    -- BOM explosion
    SELECT Division, Component_Sub_Group AS Sub_Group, Channel, Time_Series,
           Period, SUM(Bundle_Qty * BOM_Qty) AS Quantity
    FROM FC_BOM_Explosion
    GROUP BY Division, Component_Sub_Group, Channel, Time_Series, Period
) AS Combined
GROUP BY Division, Sub_Group, Channel, Time_Series, Period
```

### 6.2. BOM Explosion

**Purpose:** Explode bundle forecast thành component forecast

**Logic Flow:**
```
Step 1: Identify bundles
→ WHERE Product_Type = 'Bundle'

Step 2: Get BOM components
→ JOIN FC_BOM_Header ON Bundle_Spectrum

Step 3: Calculate component quantities
→ Component_Qty = Bundle_Qty × Quantity_Per_Bundle

Step 4: Aggregate with direct forecasts
→ Total_Component_Forecast = Direct_Forecast + BOM_Forecast
```

**SQL Implementation:**
```sql
-- From sp_Update_Bom_Header_New
WITH BOM_Explosion AS (
    SELECT
        bom.Bundle_Spectrum,
        bom.Component_Spectrum,
        bom.Quantity_Per_Bundle,
        fc.Sub_Group AS Bundle_Sub_Group,
        comp_spec.Sub_Group AS Component_Sub_Group,
        fc.Channel,
        fc.Time_Series,
        fc.Period,
        fc.Quantity AS Bundle_Qty,
        fc.Quantity * bom.Quantity_Per_Bundle AS Component_Qty
    FROM FC_FM_Original fc
    INNER JOIN FC_BOM_Header bom ON fc.Spectrum = bom.Bundle_Spectrum
    INNER JOIN Spectrum_Master comp_spec ON bom.Component_Spectrum = comp_spec.Spectrum
    WHERE fc.Product_Type = 'Bundle'
      AND bom.Status = 'ACTIVE'
      AND fc.Period BETWEEN bom.Valid_From AND bom.Valid_To
)
INSERT INTO FC_FM_Component (Sub_Group, Channel, Time_Series, Period, Quantity, Source)
SELECT
    Component_Sub_Group,
    Channel,
    Time_Series,
    Period,
    SUM(Component_Qty),
    'BOM_Explosion'
FROM BOM_Explosion
GROUP BY Component_Sub_Group, Channel, Time_Series, Period
```

**Example:**
```
Bundle Forecast:
- LOP Gift Set 2025
- Channel: ONLINE
- Period: Y0_M1
- Quantity: 1000 units

BOM Configuration:
- LOP Revitalift Cream × 1
- LOP Revitalift Serum × 1
- LOP Tote Bag × 1

Result (Component Forecast):
1. LOP Revitalift Cream
   - ONLINE, Y0_M1: +1000 (from BOM) + Direct Forecast

2. LOP Revitalift Serum
   - ONLINE, Y0_M1: +1000 (from BOM) + Direct Forecast

3. LOP Tote Bag
   - ONLINE, Y0_M1: +1000 (from BOM) + Direct Forecast
```

### 6.3. Data Consolidation

**Merge Multiple Sources:**
```sql
-- From sp_tag_update_wf_calculation_fc_unit_Refresh_All

-- 1. Historical Data (Y-2, Y-1, past Y0)
INSERT INTO WF_Consolidated
SELECT * FROM fnc_FC_SO_HIS_FINAL() -- Historical SO
UNION ALL
SELECT * FROM fnc_FC_SI_HIS_FINAL() -- Historical SI

-- 2. M-1 Forecast (previous month final forecast)
INSERT INTO WF_Consolidated
SELECT * FROM FC_FM_History WHERE FM_KEY = @Previous_FMKEY

-- 3. Current Forecast (user input + BOM)
INSERT INTO WF_Consolidated
SELECT * FROM FC_FM_Original WHERE FM_KEY = @Current_FMKEY

-- 4. Budget Data
INSERT INTO WF_Consolidated
SELECT * FROM FC_Budget WHERE Division = @Division

-- 5. Trend Data
INSERT INTO WF_Consolidated
SELECT * FROM FC_Trend WHERE Division = @Division
```

### 6.4. Pivot to WF Format

**Transform rows → columns:**

**Input (Normalized):**
```
Sub_Group            | Channel | Time_Series     | Period  | Quantity
---------------------|---------|-----------------|---------|----------
LOP Revitalift Cream | ONLINE  | 1. Baseline Qty | Y0_M1   | 5000
LOP Revitalift Cream | ONLINE  | 1. Baseline Qty | Y0_M2   | 5500
LOP Revitalift Cream | ONLINE  | 1. Baseline Qty | Y0_M3   | 6000
```

**Output (Pivot):**
```
Sub_Group            | Channel | Time_Series     | [Y0 M1] | [Y0 M2] | [Y0 M3] | ...
---------------------|---------|-----------------|---------|---------|---------|-----
LOP Revitalift Cream | ONLINE  | 1. Baseline Qty | 5000    | 5500    | 6000    | ...
```

**SQL Pivot:**
```sql
-- Dynamic pivot for WF columns
DECLARE @Columns NVARCHAR(MAX)
DECLARE @SQL NVARCHAR(MAX)

-- Get list of period columns
SELECT @Columns = STRING_AGG(QUOTENAME(Period), ',')
FROM (SELECT DISTINCT Period FROM FC_FM_Original) AS Periods

-- Build dynamic pivot query
SET @SQL = '
SELECT
    Sub_Group,
    Channel,
    Time_Series,
    ' + @Columns + '
FROM (
    SELECT Sub_Group, Channel, Time_Series, Period, Quantity
    FROM FC_FM_Original
) AS SourceData
PIVOT (
    SUM(Quantity)
    FOR Period IN (' + @Columns + ')
) AS PivotTable
'

EXEC sp_executesql @SQL
```

---

## 7. Validation & Data Quality

### 7.1. Referential Integrity Checks

**Product Validation:**
```sql
-- Check all materials exist in Spectrum Master
SELECT DISTINCT so.Material
FROM SO_Data so
LEFT JOIN Spectrum_Master sm ON so.Material = sm.Spectrum
WHERE sm.Spectrum IS NULL
```

**Customer Validation:**
```sql
-- Check all customers exist in Customer Master
SELECT DISTINCT so.Customer_Code
FROM SO_Data so
LEFT JOIN Customer_Master cm ON so.Customer_Code = cm.Customer_Code
WHERE cm.Customer_Code IS NULL
```

### 7.2. Data Completeness Checks

**Historical Data Gaps:**
```sql
-- Check for missing months in historical data
WITH Expected_Periods AS (
    SELECT
        DATEADD(MONTH, n, DATEADD(YEAR, -2, @FM_Date)) AS Period_Date
    FROM (SELECT TOP 24 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS n
          FROM sys.objects) AS Numbers
)
SELECT ep.Period_Date
FROM Expected_Periods ep
LEFT JOIN Historical_SO hso ON MONTH(hso.Month) = MONTH(ep.Period_Date)
                            AND YEAR(hso.Month) = YEAR(ep.Period_Date)
WHERE hso.Month IS NULL
ORDER BY ep.Period_Date
```

### 7.3. Business Logic Validation

**Total Qty Validation:**
```sql
-- Verify Total = Baseline + Promo + Launch + FOC
SELECT
    Sub_Group,
    Channel,
    Period,
    Baseline_Qty,
    Promo_Qty,
    Launch_Qty,
    FOC_Qty,
    Total_Qty,
    (Baseline_Qty + Promo_Qty + Launch_Qty + FOC_Qty) AS Calculated_Total,
    CASE
        WHEN Total_Qty <> (Baseline_Qty + Promo_Qty + Launch_Qty + FOC_Qty)
        THEN 'MISMATCH'
        ELSE 'OK'
    END AS Validation_Status
FROM WF_Master
WHERE Time_Series IN ('1. Baseline Qty', '2. Promo Qty', '4. Launch Qty', '5. FOC Qty', '6. Total Qty')
HAVING Validation_Status = 'MISMATCH'
```

**O+O Validation:**
```sql
-- Verify O+O = ONLINE + OFFLINE
SELECT
    Sub_Group,
    Time_Series,
    Period,
    SUM(CASE WHEN Channel = 'ONLINE' THEN Quantity ELSE 0 END) AS Online_Qty,
    SUM(CASE WHEN Channel = 'OFFLINE' THEN Quantity ELSE 0 END) AS Offline_Qty,
    SUM(CASE WHEN Channel = 'O+O' THEN Quantity ELSE 0 END) AS OO_Qty,
    SUM(CASE WHEN Channel IN ('ONLINE', 'OFFLINE') THEN Quantity ELSE 0 END) AS Calculated_OO
FROM WF_Master
GROUP BY Sub_Group, Time_Series, Period
HAVING OO_Qty <> Calculated_OO
```

---

## 8. Performance Optimization

### 8.1. Indexing Strategy

**Key Indexes:**
```sql
-- Primary mapping indexes
CREATE INDEX IX_Spectrum_Division ON Spectrum_Master(Spectrum, Division, Status)
CREATE INDEX IX_Customer_Channel ON Customer_Master(Customer_Code, Channel, Active)
CREATE INDEX IX_SO_Material_Date ON Historical_SO(Material, Month, Channel)

-- Aggregation indexes
CREATE INDEX IX_WF_SubGroup_Period ON WF_Master(Sub_Group, Channel, Time_Series, Period)
CREATE INDEX IX_BOM_Bundle ON FC_BOM_Header(Bundle_Spectrum, Status, Valid_From, Valid_To)
```

### 8.2. Temporary Table Strategy

**Staging Process:**
```sql
-- 1. Load to temp table
SELECT * INTO #SO_Temp FROM SO_Import

-- 2. Apply mappings in temp
UPDATE #SO_Temp
SET Sub_Group = sm.Sub_Group,
    Forecast_Channel = cm.Forecast_Channel
FROM #SO_Temp t
INNER JOIN Spectrum_Master sm ON t.Material = sm.Spectrum
INNER JOIN Customer_Master cm ON t.Customer_Code = cm.Customer_Code

-- 3. Bulk insert to permanent
INSERT INTO Historical_SO
SELECT * FROM #SO_Temp

-- 4. Cleanup
DROP TABLE #SO_Temp
```

### 8.3. Batch Processing

**Large Dataset Handling:**
```csharp
// From cls_function.cs - Import_ExcelFile_New
const int BATCH_SIZE = 10000;
int totalRows = dtExcel.Rows.Count;
int batches = (int)Math.Ceiling((double)totalRows / BATCH_SIZE);

for (int i = 0; i < batches; i++)
{
    int startRow = i * BATCH_SIZE;
    int endRow = Math.Min((i + 1) * BATCH_SIZE, totalRows);

    DataTable batch = dtExcel.AsEnumerable()
                             .Skip(startRow)
                             .Take(BATCH_SIZE)
                             .CopyToDataTable();

    using (SqlBulkCopy bulkCopy = new SqlBulkCopy(connectionString))
    {
        bulkCopy.DestinationTableName = "FC_FM_Original_Tmp";
        bulkCopy.BatchSize = BATCH_SIZE;
        bulkCopy.WriteToServer(batch);
    }

    // Progress update
    UpdateProgress((i + 1) * 100 / batches);
}
```

---

## 9. Error Handling & Logging

### 9.1. Mapping Errors

**Common Errors:**

| Error Code | Error Type | Action |
|------------|------------|--------|
| MAP_001 | Material not in Spectrum Master | Add to unmapped log, use "UNMAPPED" sub-group |
| MAP_002 | Customer not in Customer Master | Default to OFFLINE channel |
| MAP_003 | Invalid Order Type | Default to Baseline Qty |
| MAP_004 | BOM missing for Bundle | Alert user, skip BOM explosion |
| MAP_005 | Period outside forecast range | Skip, log warning |

**Error Logging:**
```sql
CREATE TABLE FC_Mapping_Error_Log (
    Error_ID INT IDENTITY PRIMARY KEY,
    Error_Code VARCHAR(20),
    Error_Type VARCHAR(50),
    Source_Table VARCHAR(100),
    Source_Key VARCHAR(100),
    Error_Message NVARCHAR(500),
    Error_Date DATETIME DEFAULT GETDATE(),
    Resolved BIT DEFAULT 0
)

-- Log mapping error
INSERT INTO FC_Mapping_Error_Log (Error_Code, Error_Type, Source_Table, Source_Key, Error_Message)
VALUES ('MAP_001', 'Material not found', 'SO_Import', @Material, 'Material ' + @Material + ' not in Spectrum Master')
```

### 9.2. Validation Alerts

**Alert Types:**
```sql
-- Critical: Stop processing
IF EXISTS (SELECT 1 FROM #MappingErrors WHERE Error_Type = 'CRITICAL')
BEGIN
    RAISERROR('Critical mapping errors found. Processing stopped.', 16, 1)
    RETURN
END

-- Warning: Log but continue
IF EXISTS (SELECT 1 FROM #MappingErrors WHERE Error_Type = 'WARNING')
BEGIN
    INSERT INTO FC_Processing_Log (Log_Type, Message)
    SELECT 'WARNING', Error_Message FROM #MappingErrors WHERE Error_Type = 'WARNING'
END
```

---

## 10. Mapping Verification Checklist

**Pre-Import Checklist:**
- [ ] Spectrum Master is up-to-date
- [ ] Customer Master is current
- [ ] BOM configurations are validated
- [ ] FM_KEY is correctly set
- [ ] Source files are in correct format

**Post-Mapping Checklist:**
- [ ] Row count matches (Input vs Output)
- [ ] All materials are mapped (check unmapped log)
- [ ] Total Qty = Sum of components
- [ ] O+O = ONLINE + OFFLINE
- [ ] No negative quantities
- [ ] Historical data is complete (24 months)
- [ ] Forecast periods are correct

**Validation Queries:**
```sql
-- 1. Check row counts
SELECT 'Input' AS Source, COUNT(*) AS Row_Count FROM SO_Import
UNION ALL
SELECT 'Output', COUNT(*) FROM WF_Master

-- 2. Check unmapped materials
SELECT DISTINCT Material FROM SO_Import
WHERE Material NOT IN (SELECT Spectrum FROM Spectrum_Master)

-- 3. Check data integrity
SELECT
    Sub_Group,
    Channel,
    Period,
    CASE
        WHEN Total_Qty <> (Baseline + Promo + Launch + FOC) THEN 'FAIL'
        ELSE 'PASS'
    END AS Total_Check
FROM WF_Summary
WHERE Total_Check = 'FAIL'
```

---

**Document Version:** 1.0
**Last Updated:** 2025-11-18
**Maintained by:** Technical Team
