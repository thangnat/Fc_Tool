# Chi Tiết Nguồn Dữ Liệu Theo Division

## 📋 Mục Lục

1. [Giới Thiệu](#1-giới-thiệu)
2. [Cấu Trúc Dữ Liệu Chung](#2-cấu-trúc-dữ-liệu-chung)
3. [CPD Division](#3-cpd-division)
4. [LDB Division](#4-ldb-division)
5. [LLD Division](#5-lld-division)
6. [Calculation Fields](#6-calculation-fields)
7. [Complete Matrix](#7-complete-mapping-matrix)

---

## 1. Giới Thiệu

Tài liệu này mô tả **chi tiết nguồn dữ liệu** cho từng field trong hệ thống Forecasting Tool, phân chia theo:
- **Division**: CPD, LDB, LLD
- **Data Type**: Historical (quá khứ) vs Forecast (dự báo)
- **Business Type**: Sell-In (SI) vs Sell-Out (SO)
- **Measure Type**: Unit vs Value

---

## 2. Cấu Trúc Dữ Liệu Chung

### 2.1. Phân Loại Dữ Liệu

```
Division (CPD / LDB / LLD)
│
├─ HISTORICAL (Quá khứ - Read Only)
│  ├─ Sell-Out (SO) - Bán từ retailers → end customers
│  │  ├─ Unit (số lượng)
│  │  └─ Value (giá trị)
│  │
│  └─ Sell-In (SI) - Bán từ L'Oréal → retailers
│     ├─ Unit (số lượng)
│     └─ Value (giá trị)
│
└─ FORECAST (Dự báo - Editable)
   ├─ Sell-Out (SO) - Dự báo SO
   │  ├─ Unit
   │  └─ Value
   │
   └─ Sell-In (SI) - Dự báo SI
      ├─ Unit
      └─ Value
```

### 2.2. Nguồn Files

**Tất cả stored procedures và views nằm trong:**
```
./Script/1. FINAL/0. link_37/          ← Import procedures
./Script/1. FINAL/1. Action/           ← Processing procedures
./Script/1. FINAL/3. Function/         ← Business logic functions
./Script/1. FINAL/4. View/             ← Data views
```

---

## 3. CPD Division

### 3.1. HISTORICAL DATA

#### 3.1.1. Historical Sell-Out (SO) - Unit

**Nguồn Dữ Liệu:**

| Source | File/Procedure | Table | Path |
|--------|----------------|-------|------|
| **Optimus System** | `sp_add_FC_SO_OPTIMUS_NORMAL_Tmp.sql` | `FC_SO_OPTIMUS_NORMAL_CPD` | `\Pending\OPTIMUS\SELL OUT NORMAL\CPD\` |
| **Processed** | `sp_Run_SO_HIS_FULL.sql` | `FC_CPD_SO_HIS_FINAL` | - |
| **Final View** | `fnc_FC_SO_HIS_FINAL('CPD')` | Function output | - |

**Rule Mapping:**

```sql
-- From sp_Run_SO_HIS_FULL
-- Step 1: Import từ Optimus Excel files
EXEC sp_add_FC_SO_OPTIMUS_NORMAL_Tmp
    @Division = 'CPD',
    @filename = 'SELLOUT_CPD_YYYYMMDD.xlsx'

-- Step 2: Process và aggregate
INSERT INTO FC_CPD_SO_HIS_FINAL
SELECT
    Barcode,
    PeriodKey = CONCAT(YEAR([Date]), RIGHT('0' + CAST(MONTH([Date]) AS VARCHAR), 2)),
    Channel = CASE
        WHEN Customer_Channel IN ('GT', 'MT', 'PHARMA') THEN 'OFFLINE'
        WHEN Customer_Channel = 'ONLINE' THEN 'ONLINE'
        ELSE 'OFFLINE'
    END,
    SellOut = SUM([Quantity Unit]),  ← SO Unit
    SellOutValue = SUM([Quantity Value]),
    ...
FROM FC_SO_OPTIMUS_NORMAL_CPD
WHERE Division = 'CPD'
  AND [Date] >= DATEADD(MONTH, -24, GETDATE())  ← Last 24 months
GROUP BY Barcode, YEAR([Date]), MONTH([Date]), Channel
```

**Filters:**
- ✅ Division = 'CPD'
- ✅ Date range: Last 24 months (Y-2, Y-1, past Y0)
- ✅ Status = Active products only
- ✅ Exclude: Internal transfers, returns

**Output Columns:**
- `[Y-2 (u) M1]` to `[Y-2 (u) M12]` ← Unit data for 2 years ago
- `[Y-1 (u) M1]` to `[Y-1 (u) M12]` ← Unit data for last year
- `[Y0 (u) M1]` to `[Y0 (u) Mcurrent]` ← Unit data for current year (past months)

**Example:**
```
Barcode: 3600542410311
Period: 202401 (Jan 2024)
Channel: OFFLINE
SellOut: 1500 units
→ Mapped to WF column: [Y-1 (u) M1] = 1500
```

---

#### 3.1.2. Historical Sell-Out (SO) - Value

**Nguồn Dữ Liệu:**

Same source as Unit, but using Value fields.

**Rule Mapping:**

```sql
SELECT
    ...
    SellOut = SUM([Quantity Unit]),
    SellOutValue = SUM([Quantity Value])  ← SO Value (VND)
FROM FC_SO_OPTIMUS_NORMAL_CPD
```

**Calculation:**
```
Value = Unit × Price
Price = From price list or actual transaction price
Currency: VND (Vietnamese Dong)
```

**Output Columns:**
- `[(Value)_Y-2 (u) M1]` to `[(Value)_Y-2 (u) M12]`
- `[(Value)_Y-1 (u) M1]` to `[(Value)_Y-1 (u) M12]`
- `[(Value)_Y0 (u) M1]` to `[(Value)_Y0 (u) Mcurrent]`

---

#### 3.1.3. Historical Sell-In (SI) - Unit

**Nguồn Dữ Liệu:**

| Source | File/Procedure | Table | Path |
|--------|----------------|-------|------|
| **SAP ZV14** | `sp_add_FC_SI_OPTIMUS_NORMAL_Tmp.sql` | `FC_SI_OPTIMUS_NORMAL_CPD` | `\Pending\ZV14\CPD\` |
| **Processed** | Views: `V_CPD_His_SI_*` | Multiple SI views | - |

**Rule Mapping:**

```sql
-- Import from SAP ZV14
EXEC sp_add_FC_SI_OPTIMUS_NORMAL_Tmp
    @Division = 'CPD',
    @filename = 'ZV14_CPD_YYYYMMDD.xlsx'

-- Process SI historical
SELECT
    Material,
    PeriodKey = FORMAT(Delivery_Date, 'yyyyMM'),
    Channel = CASE
        WHEN Customer_Type IN ('GT', 'MT') THEN 'OFFLINE'
        WHEN Customer_Type = 'ONLINE' THEN 'ONLINE'
    END,
    SellIn_Unit = SUM(Delivery_Quantity)  ← SI Unit
FROM FC_SI_OPTIMUS_NORMAL_CPD
WHERE Order_Status = 'C'  ← Completed only
  AND Order_Type NOT IN ('ZRET', 'ZCAN')  ← Exclude returns/cancelled
GROUP BY Material, FORMAT(Delivery_Date, 'yyyyMM'), Channel
```

**Filters:**
- ✅ Order_Status = 'C' (Completed)
- ✅ Order_Type ≠ Return/Cancelled
- ✅ Division = 'CPD'
- ✅ Delivery_Date trong last 24 months

**Special Rules CPD:**
- **Single products**: Direct SI from ZV14
- **BOM products**: SI = Sum of component SI
- **FOC (Free of Charge)**: Tách riêng time series `5. FOC Qty`

---

#### 3.1.4. Historical Sell-In (SI) - Value

**Nguồn Dữ Liệu:**

Same source, using value fields from ZV14.

**Rule Mapping:**

```sql
SELECT
    SellIn_Unit = SUM(Delivery_Quantity),
    SellIn_Value = SUM(Delivery_Quantity * Unit_Price)  ← SI Value
FROM FC_SI_OPTIMUS_NORMAL_CPD
```

**Price Source:**
- Standard price from SAP material master
- Or actual transaction price from order
- Currency: VND

---

### 3.2. FORECAST DATA (CPD)

#### 3.2.1. Forecast Sell-Out - Unit

**Nguồn Dữ Liệu:**

| Source | Type | Description |
|--------|------|-------------|
| **User Input** | Manual | Demand planner nhập trong WF Excel |
| **M-1 Reference** | Historical | Forecast tháng trước (reference) |
| **Baseline** | Calculated | Based on historical trends |

**Rules:**

CPD không forecast SO trực tiếp. Forecast chủ yếu là SI (Sell-In).

**Output Columns:**
- Chủ yếu là SI forecast columns
- SO forecast (nếu có) từ calculations

---

#### 3.2.2. Forecast Sell-In - Unit (CPD MAIN FORECAST)

**Nguồn Dữ Liệu:**

| Source | File/Procedure | Description |
|--------|----------------|-------------|
| **FM File** | `sp_add_FC_FM_Tmp` | FM forecast from Excel |
| **User WF Input** | Excel WF sheet | Manual forecast input |
| **BOM Explosion** | `sp_Update_Bom_Header_New` | Bundle → Components |

**Rule Mapping:**

```sql
-- Import FM forecast
EXEC sp_add_FC_FM_Tmp
    @Division = 'CPD',
    @FM_KEY = '202501',  -- Jan 2025
    @filename = 'CPD_FM_202501.xlsx'

-- Structure in FM file:
SELECT
    [SKU Code],  -- Spectrum code
    [SUB GROUP/ Brand],
    [Channel],
    [Time series],  -- Baseline, Promo, Launch, FOC, Total
    [Y0 (u) M1] through [Y0 (u) M12],  ← Forecast Unit Y0
    [Y+1 (u) M1] through [Y+1 (u) M12]  ← Forecast Unit Y+1
FROM FC_FM_CPD_202501_Tmp
```

**Time Series trong CPD:**

| Time Series | Source | Rule |
|-------------|--------|------|
| **1. Baseline Qty** | User input | Regular sales forecast |
| **2. Promo Qty** | User input + Promo Calendar | Promotional incremental |
| **4. Launch Qty** | User input | New product launch (first 3 months) |
| **5. FOC Qty** | User input | Free of charge forecast |
| **6. Total Qty** | Calculated | = 1 + 2 + 4 + 5 |

**BOM Explosion:**
```sql
-- If product is Bundle
IF EXISTS (SELECT 1 FROM FC_BOM_Header WHERE Bundle_Spectrum = @Material)
BEGIN
    -- Explode bundle forecast to components
    INSERT INTO FC_FM_Original_CPD (...)
    SELECT
        Component_Spectrum,
        Bundle_Forecast_Qty * Component_Qty_Per_Bundle
    FROM FC_BOM_Header
    WHERE Bundle_Spectrum = @Material
END
```

**Output Columns:**
- `[Y0 (u) M1]` to `[Y0 (u) M12]` ← Editable forecast Y0
- `[Y+1 (u) M1]` to `[Y+1 (u) M12]` ← Editable forecast Y+1

---

### 3.3. CPD-Specific Features

**3.3.1. BOM (Bill of Materials)**

CPD có nhiều bundle products:
- Gift sets
- Promo packs
- Multi-product bundles

**Process:**
1. User forecast bundle quantity
2. System explodes to components using BOM
3. Component forecast = Direct + From BOM

**3.3.2. FOC (Free of Charge)**

CPD tracks FOC separately:
- Samples for marketing
- Gift with purchase
- Trade promotions

---

## 4. LDB Division

### 4.1. HISTORICAL DATA

#### 4.1.1. Historical Sell-Out (SO) - Unit

**Nguồn Dữ Liệu:**

| Source | File/Procedure | Table | Special |
|--------|----------------|-------|---------|
| **Optimus** | `sp_add_FC_SO_OPTIMUS_NORMAL_LDB_Tmp.sql` | `FC_SO_OPTIMUS_NORMAL_LDB` | LDB-specific |
| **Conversion** | `sp_fc_convert_SO_LDB_SO.sql` | `FC_LDB_SO_HIS_FINAL` | **Special conversion** |

**⭐ LDB SPECIAL RULES:**

```sql
-- LDB có conversion procedure riêng
EXEC sp_fc_convert_SO_LDB_SO
    @Division = 'LDB'

-- Conversion logic:
SELECT
    Material,
    PeriodKey,
    -- LDB có category-specific conversions
    CASE Category
        WHEN 'Dermatology' THEN SellOut * Conversion_Factor_Dermo
        WHEN 'Professional' THEN SellOut * Conversion_Factor_Pro
        ELSE SellOut
    END AS Converted_SellOut
FROM Raw_SO_Data
```

**LDB Categories:**
- Dermatology (La Roche-Posay, Vichy, CeraVe)
- Professional (Kérastase, Redken)
- Each category có conversion rules riêng

**Filters:**
- ✅ Same general filters as CPD
- ✅ **Plus**: Category-specific validations
- ✅ **Plus**: Professional channel rules

---

#### 4.1.2. Historical Sell-In (SI) - Unit

**Nguồn Dữ Liệu:**

| Source | File/Procedure | Special |
|--------|----------------|---------|
| **ZV14** | `sp_add_FC_SI_OPTIMUS_NORMAL_Tmp` | Standard |
| **Conversion** | `sp_fc_convert_SO_LDB_SI.sql` | **LDB-specific conversion** |

**LDB SI Conversion:**

```sql
EXEC sp_fc_convert_SO_LDB_SI
    @Division = 'LDB'

-- Conversion includes:
-- 1. Professional product allocations
-- 2. Salon vs Retail split
-- 3. Dermatology channel specifics
```

**LDB Channels:**
- **Pharma**: Pharmacies (main channel for dermo)
- **Salon**: Professional salons (for hair care)
- **Retail**: General retail (limited)
- **Online**: E-commerce

---

### 4.2. FORECAST DATA (LDB)

#### 4.2.1. Forecast Sell-In - Unit

**Nguồn Dữ Liệu:**

| Source | Description |
|--------|-------------|
| **FM File** | Standard FM import |
| **SI Template** | `sp_add_FC_SI_Template_Tmp` - LDB uses SI template |

**LDB-Specific Rules:**

```sql
-- LDB forecast by channel
Channel Rules:
├─ PHARMA (60-70% of LDB)
│  └─ Focus on dermatology brands
├─ SALON (20-30% of LDB)
│  └─ Professional hair care
└─ RETAIL/ONLINE (10-20%)
```

**LDB Time Series:**

Same as CPD but with different emphasis:
- **Baseline**: Larger proportion (stable dermo sales)
- **Promo**: Smaller (less promotions in pharma)
- **Launch**: Significant (new dermo products)
- **FOC**: Medical samples

---

## 5. LLD Division

### 5.1. HISTORICAL DATA

#### 5.1.1. Historical Sell-Out (SO) - Unit

**Nguồn Dữ Liệu:**

| Source | File/Procedure | Table |
|--------|----------------|-------|
| **Optimus** | `sp_add_FC_SO_OPTIMUS_NORMAL_Tmp` | `FC_SO_OPTIMUS_NORMAL_LLD` |
| **Processed** | Standard | `FC_LLD_SO_HIS_FINAL` |
| **Final** | `fnc_FC_SO_HIS_FINAL('LLD')` | Function output |

**LLD Rules:**

```sql
-- LLD (Luxury) has simpler structure than CPD/LDB
SELECT
    Material,
    PeriodKey,
    Channel,
    SellOut_Unit = SUM(Quantity)
FROM FC_SO_OPTIMUS_NORMAL_LLD
WHERE Division = 'LLD'
  -- LLD specific: High-value, low-volume
  AND Unit_Price > 500000  -- Example threshold for luxury
GROUP BY Material, PeriodKey, Channel
```

**LLD Characteristics:**
- High unit price, low volume
- Premium channels focus
- Less promotional activity
- Strong brand focus (YSL, Lancôme, Armani, etc.)

---

#### 5.1.2. Historical Sell-In (SI) - Unit

**Nguồn Dữ Liệu:**

Standard ZV14 import, no special conversion for LLD.

```sql
EXEC sp_add_FC_SI_OPTIMUS_NORMAL_Tmp
    @Division = 'LLD',
    @filename = 'ZV14_LLD_YYYYMMDD.xlsx'
```

**LLD SI Rules:**
- Direct from ZV14
- Focus on premium channels
- High-value orders
- Strict quality control

---

### 5.2. FORECAST DATA (LLD)

#### 5.2.1. Forecast Baseline - LLD SPECIFIC

**⭐ Nguồn Dữ Liệu:**

| Source | File/Procedure | Description |
|--------|----------------|-------------|
| **FM (FuturMaster)** | `sp_add_FC_FM_Tmp` | Main forecast from FuturMaster tool |
| **FM Non-Modeling** | `sp_add_FC_FM_Non_Modeling_Tmp` | Manual adjustments outside model |

**LLD Baseline Mapping:**

```sql
-- LLD uses 2 sources for Baseline
-- 1. FM (FuturMaster) - Modeling-based forecast
EXEC sp_add_FC_FM_Tmp
    @Division = 'LLD',
    @FM_KEY = '202501',
    @filename = 'LLD_FM_202501.xlsx'

-- 2. FM Non-Modeling - Manual adjustments
EXEC sp_add_FC_FM_Non_Modeling_Tmp
    @Division = 'LLD',
    @FM_KEY = '202501',
    @filename = 'LLD_FM_Non_Modeling_202501.xlsx'

-- Combine both sources
INSERT INTO FC_FM_Original_LLD
SELECT
    ...,
    Baseline_Unit =
        ISNULL(FM_Modeling.Baseline, 0) +  ← From FuturMaster model
        ISNULL(FM_Non_Modeling.Baseline, 0)  ← Manual adjustments
FROM ...
```

**Rule:**
```
LLD Baseline = FM (Modeling) + FM Non-Modeling (Manual Adjustments)

Where:
- FM (Modeling): Statistical forecast from FuturMaster tool
- FM Non-Modeling: Expert adjustments for:
  * New launches not in model
  * Market events
  * Strategic decisions
```

**Example:**
```
Product: YSL Lipstick
Period: Y0_M3 (Mar 2025)

FM (Modeling) forecast: 500 units (based on trends)
FM Non-Modeling adjustment: +100 units (new campaign)
-----------------------
Total Baseline: 600 units
```

---

#### 5.2.2. LLD Time Series

| Time Series | LLD Source | Notes |
|-------------|------------|-------|
| **1. Baseline Qty** | FM + FM Non-Modeling | **Main forecast method** |
| **2. Promo Qty** | User input (limited) | Less promo in luxury |
| **4. Launch Qty** | FM Non-Modeling mainly | New luxury products |
| **5. FOC Qty** | User input | Samples, gifts |
| **6. Total Qty** | Calculated | Sum of all |

---

## 6. Calculation Fields

### 6.1. SOH (Stock on Hand)

**Nguồn Dữ Liệu:**

| Source | File/Procedure | Table | Update Frequency |
|--------|----------------|-------|------------------|
| **SAP ZMR32** | `sp_create_SOH_FINAL.sql` | `V_SOH_RAW` | Daily |
| **Processed** | Multiple procedures | `FC_SOH_FINAL` | Daily |

**Rule Mapping:**

```sql
-- Daily import from SAP
-- Source: ZMR32 report from SAP

SELECT
    Material,
    Plant,
    Storage_Location,
    Batch,
    SOH_Quantity = SUM(Stock_Quantity),  ← Unit
    SOH_Value = SUM(Stock_Value)  ← Value (VND)
FROM SAP_ZMR32_Import
WHERE Stock_Type IN ('UNRESTRICTED', 'QUALITY_INSPECTION')
  -- Exclude blocked stock
  AND Stock_Type NOT IN ('BLOCKED', 'RETURNS')
GROUP BY Material, Plant, Storage_Location, Batch

-- Aggregate to Sub_Group level for WF
SELECT
    sm.Sub_Group,
    SOH_Total = SUM(soh.SOH_Quantity)
FROM SOH_Detail soh
INNER JOIN fnc_SubGroupMaster(@Division, 'full') sm
    ON soh.Material = sm.Spectrum
GROUP BY sm.Sub_Group
```

**Filters:**
- ✅ Stock Type = Unrestricted or Quality Inspection
- ❌ Exclude: Blocked stock, Returns, Transit stock
- ✅ Current stock only (not historical)

**Output:**
- WF Column: `[SOH]` (单独列)
- Unit: Units (pieces, bottles, etc.)
- Aggregation: By Sub_Group

**Example:**
```
Sub_Group: LOP Revitalift Cream

Material 1 (50ml): 10000 units
Material 2 (30ml): 5000 units
Material 3 (100ml): 3000 units
------------------------
SOH (WF): 18000 units (total for Sub_Group)
```

---

### 6.2. SIT (Stock in Transit)

**Nguồn Dữ Liệu:**

Calculated field, not direct source.

**Rule:**

```sql
-- Formula
SIT = SOH - GIT_M0

Where:
- SOH: Stock on Hand (current physical stock)
- GIT_M0: Goods in Transit arriving this month
```

**Procedure:**

```sql
-- From sp_tag_update_wf_sit_NEW
UPDATE wf
SET wf.SIT =
    ISNULL(soh.SOH_Quantity, 0) -
    ISNULL(git.GIT_M0, 0)
FROM FC_FM_Original_{Division} wf
LEFT JOIN SOH_Summary soh ON wf.[SUB GROUP/ Brand] = soh.Sub_Group
LEFT JOIN GIT_Summary git ON wf.[SUB GROUP/ Brand] = git.Sub_Group
```

**Purpose:**
- SIT = "Available stock" after deducting incoming goods
- Used for stock coverage calculation
- Important for supply planning

**Output:**
- WF Column: `[SIT]`
- Can be negative if GIT > SOH (rare case)

---

### 6.3. GIT (Goods in Transit)

**Nguồn Dữ Liệu:**

| Source | File/Procedure | Table | Update Frequency |
|--------|----------------|-------|------------------|
| **SAP GIT Report** | `sp_add_FC_GIT_Tmp.sql` | `FC_GIT` | Daily |
| **Processed** | `sp_FC_GIT_New.sql` | GIT processed | Daily |

**Rule Mapping:**

```sql
-- Import from SAP GIT report
EXEC sp_add_FC_GIT_Tmp
    @Division = @Division,
    @filename = 'GIT_YYYYMMDD.xlsx'

-- Structure
SELECT
    Material,
    Division,
    GIT_M0 = SUM(CASE WHEN Arrival_Month = CURRENT_MONTH THEN Quantity ELSE 0 END),
    GIT_M1 = SUM(CASE WHEN Arrival_Month = CURRENT_MONTH + 1 THEN Quantity ELSE 0 END),
    GIT_M2 = SUM(CASE WHEN Arrival_Month = CURRENT_MONTH + 2 THEN Quantity ELSE 0 END),
    GIT_M3 = SUM(CASE WHEN Arrival_Month = CURRENT_MONTH + 3 THEN Quantity ELSE 0 END)
FROM FC_GIT_Import
GROUP BY Material, Division
```

**GIT Periods:**
- **GIT M0**: Arriving current month
- **GIT M1**: Arriving next month
- **GIT M2**: Arriving in 2 months
- **GIT M3**: Arriving in 3 months

**Output Columns:**
- `[GIT M0]`, `[GIT M1]`, `[GIT M2]`, `[GIT M3]`
- `[Total GIT]` = Sum of M0-M3

**Example:**
```
Product: LOP UV Perfect
Current month: January 2025

GIT M0 (Jan): 2000 units (arriving this month)
GIT M1 (Feb): 1500 units
GIT M2 (Mar): 1000 units
GIT M3 (Apr): 500 units
-----------------
Total GIT: 5000 units
```

---

### 6.4. Risk & SLOB

#### 6.4.1. SLOB (Slow-moving/Obsolete)

**Nguồn Dữ Liệu:**

Calculated field.

**Rule:**

```sql
-- From sp_tag_update_slob_wf
-- Formula
Stock_Coverage_Months = SOH / AVE_P3M

SLOB_Risk =
    CASE
        WHEN AVE_P3M = 0 AND SOH > 0 THEN 'DEAD_STOCK'
        WHEN Stock_Coverage_Months > 3 THEN 'HIGH'
        WHEN Stock_Coverage_Months > 2 THEN 'MEDIUM'
        ELSE 'LOW'
    END

Where:
- AVE_P3M = Average SO of previous 3 months
```

**Procedure:**

```sql
UPDATE wf
SET
    wf.Stock_Coverage =
        CASE
            WHEN wf.[AVE P3M Y0] > 0
            THEN wf.SOH / wf.[AVE P3M Y0]
            ELSE 999
        END,
    wf.SLOB =
        CASE
            WHEN wf.[AVE P3M Y0] = 0 AND wf.SOH > 0 THEN 'DEAD_STOCK'
            WHEN wf.SOH / NULLIF(wf.[AVE P3M Y0], 0) > 3 THEN 'HIGH'
            WHEN wf.SOH / NULLIF(wf.[AVE P3M Y0], 0) > 2 THEN 'MEDIUM'
            ELSE 'LOW'
        END
FROM FC_FM_Original_{Division} wf
```

**Output:**
- WF Column: `[SLOB]` (text: HIGH/MEDIUM/LOW/DEAD_STOCK)
- Basis: Stock coverage calculation

**Example:**
```
SOH: 15000 units
AVE P3M: 2000 units/month

Stock Coverage = 15000 / 2000 = 7.5 months
SLOB Risk: HIGH  ← Over 3 months

Action needed: Reduce orders, run promotions
```

---

#### 6.4.2. 3-Month Risk

**Rule:**

```sql
-- Compare Forecast next 3M vs Historical previous 3M
Risk_Status =
    CASE
        WHEN AVE_F3M < AVE_P3M * 0.7 THEN 'HIGH_DECLINE'  -- Down >30%
        WHEN AVE_F3M > AVE_P3M * 1.3 THEN 'HIGH_GROWTH'   -- Up >30%
        ELSE 'NORMAL'
    END

Where:
- AVE_P3M: Average previous 3 months (actual)
- AVE_F3M: Average forecast 3 months
```

**Purpose:**
- Identify risky forecast changes
- Flag for review if variance > ±30%

---

### 6.5. MTD SI (Month-to-Date Sell-In)

**Nguồn Dữ Liệu:**

| Source | Update | Description |
|--------|--------|-------------|
| **ZV14 Daily** | Daily | Current month SI accumulation |

**Rule:**

```sql
-- From sp_tag_update_wf_mtd_si_NEW
SELECT
    Material,
    MTD_SI = SUM(Delivery_Quantity)
FROM FC_SI_OPTIMUS_NORMAL_{Division}
WHERE YEAR(Delivery_Date) = YEAR(GETDATE())
  AND MONTH(Delivery_Date) = MONTH(GETDATE())
  -- From start of month to today
  AND Delivery_Date <= GETDATE()
  AND Order_Status = 'C'
GROUP BY Material
```

**Output:**
- WF Column: `[MTD SI]`
- Updates daily as new orders complete
- Used for in-month tracking

**Example:**
```
Current date: Jan 15, 2025
Month forecast: 10000 units

MTD SI (Jan 1-15): 4500 units
Expected MTD (50% of month): 5000 units (10000 × 15/30)
Status: Slightly behind (-10%)
```

---

### 6.6. AVE P3M & AVE F3M

#### AVE P3M (Average Previous 3 Months)

**Rule:**

```sql
-- From calculation
SELECT
    Sub_Group,
    AVE_P3M_Y0 = AVG(Monthly_SO)
FROM (
    SELECT
        Sub_Group,
        Period,
        SUM(SellOut) AS Monthly_SO,
        ROW_NUMBER() OVER (PARTITION BY Sub_Group ORDER BY Period DESC) AS rn
    FROM Historical_SO
    WHERE Period < CURRENT_PERIOD
) AS Last3M
WHERE rn <= 3
GROUP BY Sub_Group
```

**Example:**
```
Current: Jan 2025
Previous 3 months:
- Dec 2024: 8000 units
- Nov 2024: 7500 units
- Oct 2024: 7800 units

AVE P3M = (8000 + 7500 + 7800) / 3 = 7767 units
```

#### AVE F3M (Average Forecast 3 Months)

**Rule:**

```sql
-- Next 3 months forecast average
SELECT
    Sub_Group,
    AVE_F3M_Y0 = AVG(Monthly_Forecast)
FROM (
    SELECT
        Sub_Group,
        Period,
        Forecast_Qty AS Monthly_Forecast,
        ROW_NUMBER() OVER (PARTITION BY Sub_Group ORDER BY Period ASC) AS rn
    FROM Forecast_Data
    WHERE Period >= CURRENT_PERIOD
) AS Next3M
WHERE rn <= 3
GROUP BY Sub_Group
```

---

## 7. Complete Mapping Matrix

### 7.1. Division Comparison

| Data Type | CPD | LDB | LLD |
|-----------|-----|-----|-----|
| **SO Historical Source** | Optimus Standard | Optimus + Conversion (`sp_fc_convert_SO_LDB_SO`) | Optimus Standard |
| **SI Historical Source** | ZV14 Standard | ZV14 + Conversion (`sp_fc_convert_SO_LDB_SI`) | ZV14 Standard |
| **Forecast Main Source** | FM + User Input | FM + SI Template | **FM + FM Non-Modeling** |
| **BOM Complexity** | High (many bundles) | Medium | Low |
| **Promo Activity** | High | Low (pharma restrictions) | Low (luxury positioning) |
| **Main Channel** | MT/GT (Retail) | Pharma/Salon | Premium Retail/Online |

### 7.2. File Import Summary

| Division | Historical SO | Historical SI | Forecast | Special |
|----------|---------------|---------------|----------|---------|
| **CPD** | `sp_add_FC_SO_OPTIMUS_NORMAL_Tmp` | `sp_add_FC_SI_OPTIMUS_NORMAL_Tmp` | `sp_add_FC_FM_Tmp` | BOM heavy |
| **LDB** | `sp_add_FC_SO_OPTIMUS_NORMAL_LDB_Tmp` + Conversion | `sp_add_FC_SI_OPTIMUS_NORMAL_Tmp` + Conversion | `sp_add_FC_FM_Tmp` + SI Template | Category conversion |
| **LLD** | `sp_add_FC_SO_OPTIMUS_NORMAL_Tmp` | `sp_add_FC_SI_OPTIMUS_NORMAL_Tmp` | `sp_add_FC_FM_Tmp` + **FM Non-Modeling** | Dual forecast source |

### 7.3. Column Type Summary

| Column Pattern | Data Type | Source | Editable | Example |
|----------------|-----------|--------|----------|---------|
| `[Y-2 (u) M*]` | Historical SO Unit | Optimus | No (Read-only) | [Y-2 (u) M1] = 1500 |
| `[Y-1 (u) M*]` | Historical SO Unit | Optimus | No | [Y-1 (u) M6] = 1800 |
| `[Y0 (u) M*]` | Historical/Forecast Unit | Optimus + FM | Mixed | Past: No, Future: Yes |
| `[Y+1 (u) M*]` | Forecast Unit | FM + User | Yes | [Y+1 (u) M3] = 2000 |
| `[(Value)_Y-2 (u) M*]` | Historical SO Value | Optimus | No | [(Value)_Y-2 (u) M1] = 45M VND |
| `[(Value)_Y0 (u) M*]` | Historical/Forecast Value | Calculated | Mixed | Unit × Price |
| `[B_Y0_M*]` | Budget Unit | Finance upload | No | [B_Y0_M1] = 1900 |
| `[(Value)_B_Y0_M*]` | Budget Value | Finance upload | No | [(Value)_B_Y0_M1] = 57M VND |
| `[SOH]` | Stock on Hand | ZMR32 Daily | No | SOH = 18000 |
| `[GIT M0]` | Goods in Transit M0 | GIT Daily | No | GIT M0 = 2000 |
| `[SIT]` | Stock in Transit | Calculated | No | SIT = SOH - GIT M0 |
| `[SLOB]` | Risk Level | Calculated | No | SLOB = HIGH |
| `[MTD SI]` | Month-to-Date SI | ZV14 Daily | No | MTD SI = 4500 |
| `[AVE P3M Y0]` | Avg Previous 3M | Calculated | No | AVE P3M = 7767 |
| `[AVE F3M Y0]` | Avg Forecast 3M | Calculated | No | AVE F3M = 8900 |

---

## 8. Division-Specific Notes

### CPD Notes

✅ **Strengths:**
- Comprehensive BOM system
- High promo activity
- Detailed time series breakdown

⚠️ **Complexity:**
- Many bundle products
- Complex BOM explosions
- High FOC volume

### LDB Notes

✅ **Strengths:**
- Category-specific logic
- Professional channel focus
- Stable demand patterns

⚠️ **Special Requirements:**
- Conversion procedures mandatory
- Pharma channel compliance
- Salon allocation rules

### LLD Notes

✅ **Strengths:**
- Dual forecast sources (FM + FM Non-Modeling)
- Flexibility for luxury market
- Brand-focused approach

⚠️ **Special Requirements:**
- **Must use both FM sources for Baseline**
- Manual adjustments critical
- Premium channel focus

---

## 9. Quick Reference

### Finding Data Source for a Field

**Question: "Column X lấy từ đâu?"**

**Answer Steps:**
1. Identify column pattern (e.g., `[Y-1 (u) M3]`)
2. Check Section 7.3 (Column Type Summary)
3. Find Division (CPD/LDB/LLD)
4. Go to specific Division section
5. Check Historical vs Forecast
6. See detailed mapping rules

**Example:**
```
Q: LLD Baseline forecast (Y0_M3) lấy từ đâu?

Steps:
1. Column: [Y0 (u) M3] → Forecast Unit
2. Division: LLD
3. Go to Section 5.2.1 (LLD Forecast Baseline)
4. Answer: FM (Modeling) + FM Non-Modeling

Sources:
- sp_add_FC_FM_Tmp ('LLD', '202501', 'LLD_FM_202501.xlsx')
- sp_add_FC_FM_Non_Modeling_Tmp ('LLD', '202501', 'LLD_FM_Non_Modeling_202501.xlsx')

Rule: Baseline = FM + FM Non-Modeling
```

---

**Document Version:** 2.0 (Division-Specific)
**Last Updated:** 2025-11-18
**Maintained by:** Technical Team

**Related Documents:**
- [DATA_FLOW_OVERVIEW.md](./DATA_FLOW_OVERVIEW.md) - Tổng quan hệ thống
- [INPUT_DATA_SPECIFICATION.md](./INPUT_DATA_SPECIFICATION.md) - Chi tiết inputs
- [BUSINESS_LOGIC_FLOW.md](./BUSINESS_LOGIC_FLOW.md) - Business logic
- [OUTPUT_SPECIFICATION.md](./OUTPUT_SPECIFICATION.md) - Outputs
- [README.md](./README.md) - Documentation index
