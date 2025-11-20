# Complete Mapping Matrix - LLD Division

## 📋 Mục Lục

1. [LLD Overview](#1-lld-overview)
2. [LLD Dual-Source Baseline](#2-lld-dual-source-baseline)
3. [Historical Mapping](#3-historical-mapping)
4. [Forecast Mapping](#4-forecast-mapping)
5. [Complete Field Matrix](#5-complete-field-matrix)

---

## 1. LLD Overview

### 1.1. LLD Characteristics

**LLD** = Luxe Division / Division Luxe

**Product Brands:**
- **Luxury Skincare**: Lancôme, Helena Rubinstein
- **Luxury Makeup**: YSL Beauté, Armani, Urban Decay
- **Luxury Fragrance**: Selected prestige fragrances

**Business Characteristics:**
- **High unit price, low volume** (opposite of CPD)
- Premium/luxury positioning
- Exclusive distribution (department stores, luxury retail)
- Strong brand equity focus
- Less promotional activity (brand protection)
- **Manual forecast adjustments important** ← KEY DIFFERENCE

**Data Volume:**
- ~200+ SKUs active (fewer than CPD/LDB)
- ~30+ Sub Groups
- Higher value per SKU
- 24 months historical + 24 months forecast

---

## 2. LLD Dual-Source Baseline

### 2.1. Why LLD is Different

**Problem with Statistical Forecasting for Luxury:**

```
Luxury Product Challenges:
├─ Low volume → Small sample size for statistical models
├─ High variability → Influenced by marketing events, celebrity, trends
├─ Strategic decisions → Brand positioning changes not in historical data
├─ New launches → Limited historical reference
└─ Market events → Fashion shows, influencer impact, economic factors

Result: Pure statistical forecasting (FM) insufficient
```

**LLD Solution:** **Dual-Source Baseline**

### 2.2. Two Forecast Sources

#### Source 1: FM (FuturMaster - Modeling)

**What it is:**
- Statistical forecast from FuturMaster tool
- Based on historical trends
- Algorithmic prediction

**File:** `LLD_FM_YYYYMM.xlsx`

**Import:** `sp_add_FC_FM_Tmp (@Division = 'LLD')`

**Strengths:**
- Objective, data-driven
- Consistent methodology
- Good for stable products

**Weaknesses for Luxury:**
- Can't predict marketing campaigns
- Doesn't know fashion trends
- Misses strategic decisions

#### Source 2: FM Non-Modeling (Manual Adjustments)

**What it is:**
- Manual adjustments by experts
- Based on qualitative factors
- Expert judgment

**File:** `LLD_FM_Non_Modeling_YYYYMM.xlsx`

**Import:** `sp_add_FC_FM_Non_Modeling_Tmp (@Division = 'LLD')` ← **LLD-specific procedure**

**Strengths:**
- Includes market intelligence
- Reflects marketing plans
- Captures strategic changes

**Weaknesses:**
- Subjective
- Time-intensive
- Requires expertise

### 2.3. How Dual Sources Combine

**Formula:**

```
LLD Baseline = FM (Modeling) + FM Non-Modeling (Manual)

For each Sub_Group + Channel + Period:
    Total Baseline = Modeling_Forecast + Manual_Adjustment
```

**Data Flow:**

```
SOURCE 1: FM File
├─ Path: \\10.38.17.21\File Exchange FC\Pending\FM\LLD\
├─ File: LLD_FM_202501.xlsx
├─ Procedure: sp_add_FC_FM_Tmp
├─ Target: FC_FM_LLD_202501_Tmp
└─ Content: Statistical forecast

SOURCE 2: FM Non-Modeling File
├─ Path: \\10.38.17.21\File Exchange FC\Pending\FM\LLD\
├─ File: LLD_FM_Non_Modeling_202501.xlsx
├─ Procedure: sp_add_FC_FM_Non_Modeling_Tmp  ← **LLD-specific**
├─ Target: FC_FM_Non_Modeling_LLD_202501_Tmp
└─ Content: Manual adjustments

↓ MERGE PROCEDURE

sp_tag_gen_fm_non_modeling_new (@Division = 'LLD')
├─ Read both sources
├─ Match by Sub_Group + Channel + Period
├─ Sum: Modeling + Non-Modeling
└─ Update: FC_FM_Original_LLD

SQL Logic:
UPDATE wf
SET wf.[Y0 (u) M3] =
    ISNULL(fm.Modeling_Baseline, 0) +  ← From FuturMaster model
    ISNULL(nm.NonModeling_Baseline, 0)  ← From manual adjustments
FROM FC_FM_Original_LLD wf
LEFT JOIN FC_FM_LLD_202501_Tmp fm
    ON wf.[SUB GROUP/ Brand] = fm.[SUB GROUP/ Brand]
   AND wf.Channel = fm.Channel
   AND wf.[Time series] = '1. Baseline Qty'
LEFT JOIN FC_FM_Non_Modeling_LLD_202501_Tmp nm
    ON wf.[SUB GROUP/ Brand] = nm.[SUB GROUP/ Brand]
   AND wf.Channel = nm.Channel
   AND wf.[Time series] = '1. Baseline Qty'
WHERE wf.Division = 'LLD'

↓

V_FC_FM_Original_LLD
└─ Final view with combined baseline
```

### 2.4. FM Non-Modeling File Structure

**Excel Structure:**

```
Sheet: FM Non-Modeling Data

Columns:
├─ SKU Code (Spectrum)
├─ SUB GROUP/ Brand
├─ Channel
├─ Time series (always "1. Baseline Qty")
├─ [Y0 (u) M1] through [Y0 (u) M12]  ← Manual adjustments
├─ [Y+1 (u) M1] through [Y+1 (u) M12]
├─ Comments (optional: reason for adjustment)
└─ Adjustment_Type (Launch / Campaign / Strategic / Other)

Example Rows:

SKU Code    | SUB GROUP      | Channel | [Y0 (u) M3] | Comments
3600YSL123  | YSL Lipstick   | OFFLINE | +500       | New campaign launch
3600LAN456  | Lancôme Serum  | ONLINE  | +200       | Influencer partnership
3600ARM789  | Armani Foundation | OFFLINE | -100    | Shade discontinuation
```

**Procedure: sp_add_FC_FM_Non_Modeling_Tmp**

**Location:** `./Script/1. FINAL/0. link_37/sp_add_FC_FM_Non_Modeling_Tmp.sql`

```sql
CREATE PROCEDURE sp_add_FC_FM_Non_Modeling_Tmp
    @Division NVARCHAR(3),  -- 'LLD'
    @FM_KEY NVARCHAR(6),    -- '202501'
    @filename NVARCHAR(200) -- 'LLD_FM_Non_Modeling_202501.xlsx'
AS
BEGIN
    DECLARE @path NVARCHAR(500)
    DECLARE @tablename NVARCHAR(100)
    
    -- Set path
    SET @path = '\\10.38.17.21\File Exchange FC\Pending\FM\' + @Division + '\'
    
    -- Set target table name
    SET @tablename = 'FC_FM_Non_Modeling_' + @Division + '_' + @FM_KEY + '_Tmp'
    
    -- Import Excel file
    EXEC('
        INSERT INTO ' + @tablename + '
        SELECT *
        FROM OPENROWSET(
            ''Microsoft.ACE.OLEDB.12.0'',
            ''Excel 12.0;Database=' + @path + @filename + ';HDR=YES'',
            ''SELECT * FROM [FM Non-Modeling Data$]''
        )
    ')
    
    -- Log import
    INSERT INTO FC_Import_Log (Division, FM_KEY, Import_Type, Filename, Import_Date, Row_Count)
    SELECT @Division, @FM_KEY, 'FM_Non_Modeling', @filename, GETDATE(), @@ROWCOUNT
END
```

### 2.5. Example: LLD Baseline Calculation

**Scenario:** YSL Rouge Pur Couture Lipstick, March 2025 forecast

**Step 1: FM (Modeling) Forecast**

```
FuturMaster statistical forecast:
- Based on historical sales trend
- Considers seasonality
- Algorithm output: 1000 units

File: LLD_FM_202501.xlsx
Row: YSL Rouge Pur Couture | OFFLINE | 1. Baseline Qty | [Y0 (u) M3] = 1000
```

**Step 2: FM Non-Modeling (Manual) Adjustment**

```
Demand Planner assessment:
- New campaign launching in March: +500 units
- Celebrity endorsement: +200 units
- Store expansion (2 new counters): +100 units
- Total adjustment: +800 units

File: LLD_FM_Non_Modeling_202501.xlsx
Row: YSL Rouge Pur Couture | OFFLINE | 1. Baseline Qty | [Y0 (u) M3] = +800
Comments: "March campaign + celebrity + new stores"
```

**Step 3: Combined Baseline**

```
Procedure: sp_tag_gen_fm_non_modeling_new ('LLD', '202501')

Calculation:
LLD Baseline = FM + FM Non-Modeling
             = 1000 + 800
             = 1800 units

Working File Result:
Sub Group: YSL Rouge Pur Couture
Channel: OFFLINE
Time series: 1. Baseline Qty
[Y0 (u) M3] = 1800 units
```

**Step 4: View Previous Versions**

```
M-1 version (last month's forecast for March):
[(m-1)_Y0 (u) M3] = 1500

Comparison:
- Current: 1800
- M-1: 1500
- Change: +300 (+20%)
- Reason: Updated campaign information
```

### 2.6. When to Use Non-Modeling Adjustments

**Common Use Cases:**

| Situation | FM (Modeling) | FM Non-Modeling | Example |
|-----------|---------------|-----------------|---------|
| **New Product Launch** | 0 (no history) | Launch volume | +5000 first month |
| **Marketing Campaign** | Baseline only | Campaign lift | +30% incremental |
| **Celebrity/Influencer** | Can't predict | Expected impact | +500 units |
| **Strategic Price Change** | Uses old prices | New price impact | -200 (price increase) |
| **Distribution Expansion** | Old distribution | New doors impact | +1000 (10 new stores) |
| **Product Discontinuation** | Historical trend | Phase-out plan | -500 (winding down) |
| **Economic Event** | Historical economy | Current sentiment | -20% (recession) |
| **Competitive Launch** | Can't know | Expected impact | -300 (competitor) |
| **Fashion Trend Change** | Historical trends | Current trends | +40% (trending color) |

**Guidelines:**

```
Use FM Non-Modeling for:
✅ Information not in historical data
✅ Qualitative factors
✅ Strategic decisions
✅ Market intelligence
✅ Short-term events

Avoid FM Non-Modeling for:
❌ Regular seasonal patterns (FM handles this)
❌ Normal trend continuation (FM handles this)
❌ Random adjustments without reason
❌ Overriding FM without justification
```

---

## 3. Historical Mapping

### 3.1. Historical SO/SI (No Conversion)

LLD uses **standard** (no conversion like LDB):

**Historical SO:**
```
Source: Optimus SO
Import: sp_add_FC_SO_OPTIMUS_NORMAL_Tmp (@Division = 'LLD')
Table: FC_SO_OPTIMUS_NORMAL_LLD
Processing: sp_Run_SO_HIS_FULL (or equivalent)
Final: FC_LLD_SO_HIS_FINAL
View: fnc_FC_SO_HIS_FINAL('LLD')
```

**No conversion procedures** (unlike LDB)

**Historical SI:**
```
Source: SAP ZV14
Import: sp_add_FC_SI_OPTIMUS_NORMAL_Tmp (@Division = 'LLD')
Table: FC_SI_OPTIMUS_NORMAL_LLD
Views: V_LLD_His_SI_Single, V_LLD_His_SI_BOM, etc.
```

**Channel Mapping for LLD:**

| Raw Channel | System Channel | LLD Context |
|-------------|----------------|-------------|
| PREMIUM_RETAIL | OFFLINE | Department stores (main channel) |
| DUTY_FREE | OFFLINE | Airport/travel retail |
| LUXURY_RETAIL | OFFLINE | Standalone boutiques |
| ONLINE | ONLINE | Official sites, luxury e-comm |

### 3.2. LLD BOM (Minimal)

LLD has **minimal BOM**:
- Mostly single prestige products
- Occasional luxury gift sets (holiday season)
- Less complexity than CPD

---

## 4. Forecast Mapping

### 4.1. Complete Forecast Data Flow

```
SOURCE 1: FM (Modeling)
├─ File: LLD_FM_202501.xlsx
├─ Import: sp_add_FC_FM_Tmp
└─ Target: FC_FM_LLD_202501_Tmp

SOURCE 2: FM Non-Modeling
├─ File: LLD_FM_Non_Modeling_202501.xlsx
├─ Import: sp_add_FC_FM_Non_Modeling_Tmp  ← **LLD-specific**
└─ Target: FC_FM_Non_Modeling_LLD_202501_Tmp

↓ MERGE

sp_FC_FM_Original_NEW_FINAL (@Division = 'LLD')
├─ Step 1: Import FM (modeling)
├─ Step 2: Import FM Non-Modeling
├─ Step 3: Merge baselines (sp_tag_gen_fm_non_modeling_new)
│   → Baseline = Modeling + Non-Modeling
├─ Step 4: Add other time series (Promo, Launch, FOC)
├─ Step 5: Calculate totals (6. Total Qty = 1+2+4+5)
├─ Step 6: BOM explosion (minimal for LLD)
└─ Target: FC_FM_Original_LLD

↓ USER EDITS

Users can edit in WF Excel
└─ Upload: sp_FC_FM_WF_Upload

↓ AGGREGATION

sp_tag_update_wf_total_unit_new
└─ O+O aggregation (OFFLINE + ONLINE)

↓ FINAL VIEW

V_FC_FM_Original_LLD
└─ Complete WF structure
```

### 4.2. LLD Time Series Emphasis

| Time Series | LLD Usage | Notes |
|-------------|-----------|-------|
| **1. Baseline Qty** | **Primary (85-90%)** | **FM + FM Non-Modeling** |
| **2. Promo Qty** | **Very Low (2-5%)** | Limited promos (brand protection) |
| **4. Launch Qty** | **Medium (10-15%)** | Luxury launches, mostly in Non-Modeling |
| **5. FOC Qty** | **Very Low (2-3%)** | VIP gifts, influencer seeding |
| **6. Total Qty** | Calculated | Sum |

**LLD Promo Philosophy:**

```
Luxury brands rarely promote:
❌ No deep discounts (damages brand equity)
❌ No buy-one-get-one (cheapens perception)
❌ No mass promotions

Limited promotions:
✅ VIP events (exclusive, invitation-only)
✅ GWP (high-value gifts, not cheap add-ons)
✅ Limited editions (scarcity, not discount)
✅ Travel exclusives (duty-free sets)

Result: Promo Qty very low compared to CPD
```

---

## 5. Complete Field Matrix

### 5.1. LLD WF Column → Source Matrix

| WF Column Pattern | Data Type | Source | **LLD-Specific** | Editable |
|-------------------|-----------|--------|------------------|----------|
| `[Y-2 (u) M*]` | Historical SO | Optimus SO | No conversion | ❌ No |
| `[Y-1 (u) M*]` | Historical SO | Optimus SO | No conversion | ❌ No |
| `[Y0 (u) M*]` (past) | Historical SO | Optimus SO | No conversion | ❌ No |
| `[Y0 (u) M*]` (future) | **Forecast - Baseline** | **FM + FM Non-Modeling** | ✅ **Dual source** | ✅ Yes |
| `[Y+1 (u) M*]` | **Forecast - Baseline** | **FM + FM Non-Modeling** | ✅ **Dual source** | ✅ Yes |
| Other columns | Same as CPD | Same as CPD | Standard | Per CPD |

**Key LLD Difference:**

For "1. Baseline Qty" time series:
```
CPD: FM file only
LDB: FM file + SI Template
LLD: **FM file + FM Non-Modeling file** ← Unique to LLD
```

### 5.2. LLD-Specific Procedures

| Procedure | Purpose | LLD Usage |
|-----------|---------|-----------|
| **sp_add_FC_FM_Non_Modeling_Tmp** | Import FM Non-Modeling file | ✅ **LLD ONLY** (main usage) |
| **sp_tag_gen_fm_non_modeling_new** | Merge FM + FM Non-Modeling | ✅ Critical for LLD baseline |
| **sp_tag_update_wf_FM_Non_Modeling_unit** | Update WF with Non-Modeling data | ✅ LLD-specific |
| sp_add_FC_FM_Tmp | Import FM (modeling) | ❌ Standard (shared) |
| sp_FC_FM_Original_NEW_FINAL | Process forecast | ❌ Standard (but calls LLD-specific procs) |

### 5.3. LLD Views

Located in `./Script/1. FINAL/4. View/`:

```
V_FC_FM_Original_LLD.sql  ← Main WF view
V_LLD_His_SI_Single.sql
V_LLD_His_SI_BOM.sql
V_LLD_His_SI_Single_FDR.sql
V_LLD_His_SI_BOM_FDR.sql
V_LLD_His_SI_SingleBomcomponent.sql
V_LLD_His_SI_FOC_TO_VP.sql
V_FC_LLD_SO_HIS_FINAL.sql
V_LLD_FC_ZV14_Historical.sql
V_FC_SO_OPTIMUS_Bomheader_Forecast_LLD.sql
```

---

## 6. Example Trace: LLD Dual Source

**User Question:** "LLD, [Y0 (u) M3] của Lancôme Advanced Génifique Serum lấy từ đâu?"

**Trace Steps:**

```
1. Check WF:
   Sub Group: Lancôme Advanced Génifique Serum
   Channel: OFFLINE
   Time series: 1. Baseline Qty
   [Y0 (u) M3] = 3500 units

2. Query V_FC_FM_Original_LLD:
   SELECT [Y0 (u) M3]
   FROM V_FC_FM_Original_LLD
   WHERE [SUB GROUP/ Brand] = 'Lancôme Advanced Génifique Serum'
     AND Channel = 'OFFLINE'
     AND [Time series] = '1. Baseline Qty'
   Returns: 3500

3. Query FC_FM_Original_LLD (table):
   SELECT [Y0 (u) M3]
   FROM FC_FM_Original_LLD
   WHERE [SUB GROUP/ Brand] = 'Lancôme Advanced Génifique Serum'
     AND Channel = 'OFFLINE'
     AND [Time series] = '1. Baseline Qty'
   Returns: 3500

4. Decompose to sources:
   
   a) FM (Modeling) Source:
      SELECT [Y0 (u) M3] AS FM_Modeling
      FROM FC_FM_LLD_202501_Tmp
      WHERE [SUB GROUP/ Brand] = 'Lancôme Advanced Génifique Serum'
        AND Channel = 'OFFLINE'
        AND [Time series] = '1. Baseline Qty'
      Returns: 3000 units
      
      Source File: LLD_FM_202501.xlsx
      - Statistical forecast from FuturMaster
      - Based on historical trend
   
   b) FM Non-Modeling Source:
      SELECT [Y0 (u) M3] AS FM_Non_Modeling
      FROM FC_FM_Non_Modeling_LLD_202501_Tmp
      WHERE [SUB GROUP/ Brand] = 'Lancôme Advanced Génifique Serum'
        AND Channel = 'OFFLINE'
        AND [Time series] = '1. Baseline Qty'
      Returns: +500 units
      
      Source File: LLD_FM_Non_Modeling_202501.xlsx
      - Manual adjustment by Demand Planner
      - Comment: "March anniversary campaign + new counter opening"

5. Combined:
   LLD Baseline = FM + FM Non-Modeling
                = 3000 + 500
                = 3500 ✅ (matches WF)

6. Procedure Used:
   sp_tag_gen_fm_non_modeling_new ('LLD', '202501')
   - Merges both sources
   - Validates Sub Group + Channel match
   - Sums Modeling + Non-Modeling
   - Updates FC_FM_Original_LLD

7. User Edited?
   Check M-1 version:
   [(m-1)_Y0 (u) M3] = 3200
   
   Current: 3500
   M-1: 3200
   Change: +300
   
   Reason: Updated Non-Modeling adjustment (campaign details finalized)
```

---

## 7. LLD Summary

### Key Takeaways:

✅ **LLD uses dual-source baseline**: FM (Modeling) + FM Non-Modeling

✅ **FM Non-Modeling is critical** for luxury forecasting (market intelligence)

✅ **sp_add_FC_FM_Non_Modeling_Tmp**: LLD-specific import procedure

✅ **sp_tag_gen_fm_non_modeling_new**: Merges both sources

✅ **No conversion procedures** (unlike LDB)

✅ **Low BOM complexity** (mostly single prestige products)

✅ **Minimal promotions** (brand protection)

✅ **High manual adjustment** capability (expert judgment important)

### LLD vs CPD vs LDB:

| Feature | CPD | LDB | **LLD** |
|---------|-----|-----|---------|
| Baseline Source | FM only | FM + SI Template | **FM + FM Non-Modeling** |
| Conversion | None | ✅ Yes | None |
| BOM Complexity | High | Medium | **Low** |
| Promo Activity | High | Low | **Very Low** |
| Manual Adjustments | Medium | Low | **High (Non-Modeling)** |
| Forecast Driver | SO-driven | SI-driven | **Strategic/Campaign-driven** |
| Price Point | Low-Medium | Medium-High | **High** |
| Volume | High | Medium | **Low** |

### When LLD Approach Makes Sense:

```
✅ Luxury/prestige products
✅ High value, low volume
✅ Strategic marketing-driven demand
✅ Limited historical data (new luxury brands)
✅ Fashion/trend-sensitive products
✅ Expert judgment critical
✅ Campaign-driven sales
```

### LLD Workflow for Demand Planners:

```
1. Review FM (Modeling) forecast
   - Statistical baseline from FuturMaster

2. Assess market factors:
   - Marketing campaigns planned
   - Celebrity/influencer partnerships
   - Fashion trends
   - Competitor activity
   - Economic sentiment

3. Create FM Non-Modeling adjustments:
   - Document rationale
   - Quantify expected impact
   - Fill Non-Modeling file

4. Import both files:
   - sp_add_FC_FM_Tmp (modeling)
   - sp_add_FC_FM_Non_Modeling_Tmp (adjustments)

5. System merges:
   - sp_tag_gen_fm_non_modeling_new
   - Creates combined baseline

6. Review combined forecast:
   - Check reasonableness
   - Compare to M-1 version
   - Validate with business

7. Edit in WF if needed:
   - Fine-tune specific SKUs
   - Adjust channel split

8. Finalize and export
```

---

**Document Version:** 1.0
**Last Updated:** 2025-11-19
**Related:** [MAPPING_MATRIX_OVERVIEW.md](./MAPPING_MATRIX_OVERVIEW.md) | [MAPPING_MATRIX_CPD.md](./MAPPING_MATRIX_CPD.md) | [MAPPING_MATRIX_LDB.md](./MAPPING_MATRIX_LDB.md)
