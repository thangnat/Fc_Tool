# Complete Mapping Matrix - LDB Division

## 📋 Mục Lục

1. [LDB Overview](#1-ldb-overview)
2. [LDB-Specific Conversions](#2-ldb-specific-conversions)
3. [Historical SO Mapping](#3-historical-so-mapping)
4. [Historical SI Mapping](#4-historical-si-mapping)
5. [Forecast Mapping](#5-forecast-mapping)
6. [Complete Field Matrix](#6-complete-field-matrix)

---

## 1. LDB Overview

### 1.1. LDB Characteristics

**LDB** = Dermatological Beauty / Luxe Dermatologie et Beauté

**Product Categories:**
- **Dermatology (Dermo)**: La Roche-Posay, Vichy, CeraVe, SkinCeuticals
- **Professional Hair**: Kérastase, Redken, Matrix

**Business Characteristics:**
- Medium-to-high price point
- Stable demand (less seasonal than CPD)
- Low promotional activity (pharma/salon regulations)
- Specific channel focus (Pharma 60-70%, Salon 20-30%)
- **Category-specific conversion rules** ← KEY DIFFERENCE

**Data Volume:**
- ~300+ SKUs active
- ~40+ Sub Groups
- 24 months historical + 24 months forecast

---

## 2. LDB-Specific Conversions

### 2.1. Why LDB Needs Conversion

**Problem:**
Different business units report in different unit definitions:
- **Dermatology products**: Pharmacies report in consumer units
- **Professional products**: Salons report in professional sizes (often larger)
- **SAP vs Optimus**: Different unit definitions

**Solution:**
LDB has **conversion procedures** to standardize units.

### 2.2. SO Conversion: sp_fc_convert_SO_LDB_SO

**Purpose:** Convert Sell-Out data to standard units

**Location:** `./Script/1. FINAL/0. link_37/sp_fc_convert_SO_LDB_SO.sql`

**Data Flow:**

```
SOURCE: Optimus SO (Raw)
├─ File: SELLOUT_LDB_YYYYMMDD.xlsx
└─ Import: sp_add_FC_SO_OPTIMUS_NORMAL_LDB_Tmp
    ↓
    Target: FC_SO_OPTIMUS_NORMAL_LDB (raw units)

↓ CONVERSION

sp_fc_convert_SO_LDB_SO (@Division = 'LDB')
├─ Read: FC_SO_OPTIMUS_NORMAL_LDB
├─ Lookup: Conversion factors by Category
├─ Apply: Category-specific conversion
└─ Output: FC_LDB_SO_HIS_FINAL (standardized units)

SQL Logic:
INSERT INTO FC_LDB_SO_HIS_FINAL
SELECT
    sm.Sub_Group,
    PeriodKey,
    Channel,
    -- Category-based conversion
    SellOut_Unit_Converted = 
        CASE sm.Category
            WHEN 'Dermatology' THEN 
                raw.SellOut_Unit * cf.Dermo_Conversion_Factor
            WHEN 'Professional' THEN 
                raw.SellOut_Unit * cf.Pro_Conversion_Factor
            WHEN 'Active_Cosmetics' THEN
                raw.SellOut_Unit * cf.Active_Conversion_Factor
            ELSE 
                raw.SellOut_Unit  -- No conversion
        END
FROM FC_SO_OPTIMUS_NORMAL_LDB raw
INNER JOIN fnc_SubGroupMaster('LDB', 'full') sm
    ON raw.Barcode = sm.Barcode
LEFT JOIN FC_LDB_Conversion_Factors cf
    ON sm.Spectrum = cf.Spectrum
WHERE raw.Division = 'LDB'
```

**Example Conversion:**

```
Product: La Roche-Posay Effaclar Duo+ 40ml
Category: Dermatology
Raw SO from Optimus: 1000 units

Conversion Factor: 1.05 (5% adjustment)
Reason: Pharmacy reporting includes testers, samples

Converted SO: 1000 × 1.05 = 1050 units

WF Shows: [Y-1 (u) M6] = 1050 (after conversion)
```

**Conversion Factors Table:**

| Category | Typical Factor | Reason |
|----------|---------------|--------|
| Dermatology | 1.00 - 1.10 | Pharmacy reporting adjustments |
| Professional (Salon) | 0.90 - 1.00 | Professional sizes vs consumer units |
| Active Cosmetics | 1.00 | Standard |

### 2.3. SI Conversion: sp_fc_convert_SO_LDB_SI

**Purpose:** Convert Sell-In data to standard units

**Location:** `./Script/1. FINAL/0. link_37/sp_fc_convert_SO_LDB_SI.sql`

**Data Flow:**

```
SOURCE: SAP ZV14 (Raw)
├─ File: ZV14_LDB_YYYYMMDD.xlsx
└─ Import: sp_add_FC_SI_OPTIMUS_NORMAL_Tmp
    ↓
    Target: FC_SI_OPTIMUS_NORMAL_LDB (raw units)

↓ CONVERSION

sp_fc_convert_SO_LDB_SI (@Division = 'LDB')
├─ Read: FC_SI_OPTIMUS_NORMAL_LDB
├─ Lookup: Conversion factors + Channel rules
├─ Apply: Category + Channel specific conversion
└─ Output: FC_LDB_SI_HIS_FINAL (standardized units)

SQL Logic:
INSERT INTO FC_LDB_SI_HIS_FINAL
SELECT
    sm.Sub_Group,
    PeriodKey,
    Channel = CASE
        WHEN raw.Customer_Type = 'PHARMA' THEN 'OFFLINE'
        WHEN raw.Customer_Type = 'SALON' THEN 'OFFLINE'
        WHEN raw.Customer_Type = 'ONLINE' THEN 'ONLINE'
        ELSE 'OFFLINE'
    END,
    -- Conversion with channel consideration
    SellIn_Unit_Converted = 
        CASE 
            WHEN sm.Category = 'Professional' AND raw.Customer_Type = 'SALON' THEN
                raw.Delivery_Quantity * cf.Salon_Pro_Factor
            WHEN sm.Category = 'Dermatology' AND raw.Customer_Type = 'PHARMA' THEN
                raw.Delivery_Quantity * cf.Pharma_Dermo_Factor
            ELSE
                raw.Delivery_Quantity
        END
FROM FC_SI_OPTIMUS_NORMAL_LDB raw
INNER JOIN fnc_SubGroupMaster('LDB', 'full') sm
    ON raw.Material = sm.Spectrum
LEFT JOIN FC_LDB_Conversion_Factors cf
    ON sm.Spectrum = cf.Spectrum
WHERE raw.Order_Status = 'C'
  AND raw.Order_Type NOT IN ('ZRET', 'ZCAN')
```

**Example:**

```
Product: Kérastase Résistance Shampoo 500ml (Professional size)
Channel: Salon
Raw SI: 200 bottles (500ml each)

Conversion to Consumer Equivalent:
- 500ml (pro) = 2 × 250ml (consumer standard)
- Factor: 2.0

Converted SI: 200 × 2.0 = 400 consumer equivalent units

WF Shows: [Y0 (u) M3] = 400 (standardized units)

Reason: Supply planning uses consumer equivalent for consistency
```

### 2.4. Combined Conversion: sp_fc_convert_SO_LDB

**Purpose:** Run both SO and SI conversions in sequence

**Location:** `./Script/1. FINAL/0. link_37/sp_fc_convert_SO_LDB.sql`

```sql
-- Master conversion procedure
EXEC sp_fc_convert_SO_LDB
    @Division = 'LDB'

-- Internally calls:
-- 1. sp_fc_convert_SO_LDB_SO (SO conversion)
-- 2. sp_fc_convert_SO_LDB_SI (SI conversion)
-- 3. Validation checks
-- 4. Log conversion results
```

---

## 3. Historical SO Mapping

### 3.1. Historical SO - Unit (with Conversion)

**Complete Data Flow:**

```
SOURCE: Optimus LDB
├─ Path: \\10.38.17.21\File Exchange FC\Pending\OPTIMUS\SELL OUT NORMAL\LDB\
├─ File: SELLOUT_LDB_YYYYMMDD.xlsx
└─ Frequency: Weekly

↓ IMPORT

sp_add_FC_SO_OPTIMUS_NORMAL_LDB_Tmp
├─ Special LDB version (note: _LDB_Tmp suffix)
├─ Target: FC_SO_OPTIMUS_NORMAL_LDB
└─ Columns: Date, Barcode, Customer_Channel, Customer_Type, Category, Quantity_Unit, Quantity_Value

↓ CONVERSION (LDB-specific step)

sp_fc_convert_SO_LDB_SO
├─ Apply category-based conversion factors
├─ Map channels (Pharma, Salon → OFFLINE)
└─ Target: FC_LDB_SO_HIS_FINAL (converted units)

↓ AGGREGATION

Aggregate by Sub_Group + Channel + Period

↓ VIEW

fnc_FC_SO_HIS_FINAL('LDB')
└─ Pivot to columns: [Y-2 (u) M*], [Y-1 (u) M*], [Y0 (u) M*]

↓ WORKING FILE

V_FC_FM_Original_LDB (in Action folder, not View folder)
```

**LDB Channel Mapping:**

| Raw Customer_Type | System Channel | Business Context |
|-------------------|----------------|------------------|
| PHARMA | OFFLINE | Pharmacies (main dermo channel, 60-70%) |
| SALON | OFFLINE | Professional salons (hair care, 20-30%) |
| RETAIL | OFFLINE | General retail (limited, 5-10%) |
| ONLINE | ONLINE | E-commerce (growing, ~10%) |

**LDB-Specific Filters:**

```sql
-- Standard filters (like CPD)
AND so.[Date] >= DATEADD(MONTH, -24, GETDATE())
AND sm.Status = 'Active'

-- LDB-specific filters
AND so.Customer_Type IN ('PHARMA', 'SALON', 'RETAIL', 'ONLINE')  ← Valid channels
AND sm.Category IN ('Dermatology', 'Professional', 'Active_Cosmetics')  ← Valid categories

-- Pharma-specific
AND (Customer_Type != 'PHARMA' OR Prescription_Flag = 'N')  ← Exclude prescription drugs

-- Salon-specific
AND (Customer_Type != 'SALON' OR Professional_License = 'Y')  ← Only licensed salons
```

### 3.2. Historical SO - Value (with Conversion)

Same conversion logic applies to Value fields:

```sql
SellOut_Value_Converted = 
    SellOut_Value * Conversion_Factor

-- Example:
-- Raw Value: 25,000,000 VND
-- Conversion Factor: 1.05
-- Converted: 26,250,000 VND
```

---

## 4. Historical SI Mapping

### 4.1. Historical SI - Unit (with Conversion)

**Data Flow:**

```
SOURCE: SAP ZV14 (LDB)
├─ Path: \\10.38.17.21\File Exchange FC\Pending\ZV14\LDB\
├─ File: ZV14_LDB_YYYYMMDD.xlsx
└─ Frequency: Daily

↓ IMPORT

sp_add_FC_SI_OPTIMUS_NORMAL_Tmp (@Division = 'LDB')
├─ Target: FC_SI_OPTIMUS_NORMAL_LDB
└─ Note: Same import proc as CPD, but different target table

↓ CONVERSION (LDB-specific step)

sp_fc_convert_SO_LDB_SI
├─ Apply category + channel conversion
├─ Salon professional size adjustments
├─ Pharma packaging adjustments
└─ Target: FC_LDB_SI_HIS_FINAL

↓ VIEWS

V_LDB_His_SI_Single, V_LDB_His_SI_BOM, etc.
└─ Similar structure to CPD, but with LDB data

↓ WORKING FILE

V_FC_FM_Original_LDB
```

**LDB SI Special Logic:**

```sql
-- Professional products to salons
CASE 
    WHEN Category = 'Professional' AND Customer_Type = 'SALON' THEN
        -- Professional sizes (e.g., 1000ml)
        -- Convert to consumer equivalent (e.g., 250ml)
        Delivery_Quantity * Professional_Size_Factor
        
-- Dermatology to pharmacies
    WHEN Category = 'Dermatology' AND Customer_Type = 'PHARMA' THEN
        -- Pharmacy-specific packaging adjustments
        Delivery_Quantity * Pharma_Pack_Factor
        
-- Standard retail
    ELSE
        Delivery_Quantity  -- No conversion
END
```

**Example:**

```
Product: Kérastase Resistance Bain 1000ml (Salon backbar size)
SI to Salon: 50 bottles (1000ml each)

Consumer Equivalent:
- 1000ml = 4 × 250ml (standard consumer size)
- Factor: 4.0

Converted SI: 50 × 4.0 = 200 consumer equivalent units

WF Historical SI: [Y-1 (u) M6] = 200 units

Supply Planning Impact:
- Forecast in consumer units
- Production converts back to actual pack sizes
- Salon orders planned in backbar sizes
```

### 4.2. LDB BOM Processing

LDB has **less BOM complexity** than CPD:
- Fewer bundle/gift set products
- Mainly salon kits (e.g., "Kérastase Treatment Kit")
- Some dermo trial kits

BOM processing uses same procedures as CPD:
- `sp_Update_Bom_Header_New`
- `sp_Gen_BomHeader_Forecast_New`

But with lower volume and impact.

---

## 5. Forecast Mapping

### 5.1. Forecast Sources for LDB

LDB uses **2 main forecast sources**:

#### Source 1: FM File (Standard)

```
File: LDB_FM_YYYYMM.xlsx
Import: sp_add_FC_FM_Tmp (@Division = 'LDB')
Target: FC_FM_LDB_YYYYMM_Tmp → FC_FM_Original_LDB
```

Same structure as CPD FM file.

#### Source 2: SI Template (LDB-specific)

```
File: LDB_SI_Template_YYYYMM.xlsx
Import: sp_add_FC_SI_Template_Tmp (@Division = 'LDB')
Purpose: Pre-filled SI forecast template
Target: FC_FM_Original_LDB (merged with FM data)
```

**Why SI Template?**

LDB focuses more on **Sell-In planning** than Sell-Out:
- Pharma channel: Stable demand, focus on supply to pharmacies
- Salon channel: Professional ordering patterns, less consumer-driven
- Less promotional activity → more predictable SI

**SI Template Usage:**

```
1. Finance/Supply Planning creates SI Template
   - Based on customer orders
   - Salon booking patterns
   - Pharma replenishment cycles

2. Template includes:
   - Customer-level forecast (which pharmacies/salons)
   - Channel split (Pharma vs Salon)
   - Regional allocation

3. Import merges with FM forecast:
   - FM provides SO forecast (consumer demand)
   - SI Template provides SI forecast (supply plan)
   - System reconciles differences
```

### 5.2. LDB Time Series

Same 5 time series as CPD, but different emphasis:

| Time Series | LDB Emphasis | Notes |
|-------------|--------------|-------|
| **1. Baseline Qty** | **High (80-85%)** | Stable base business (less seasonal) |
| **2. Promo Qty** | **Low (5-10%)** | Limited promos (pharma regulations, salon norms) |
| **4. Launch Qty** | **Medium (10-15%)** | Innovation important, but controlled launches |
| **5. FOC Qty** | **Low (5%)** | Medical samples (dermo), salon trial kits |
| **6. Total Qty** | Calculated | Sum |

**LDB Promo Restrictions:**

```
Dermatology (Pharma channel):
- Limited promotional activity (medical product regulations)
- No deep discounting
- Focus on education, sampling

Professional (Salon channel):
- Professional pricing (no consumer promotions)
- Salon loyalty programs (not reflected in promo qty)
- Training events, not price promotions
```

### 5.3. LDB Forecast Processing

```
FM File Import → FC_FM_LDB_Tmp
    +
SI Template Import → FC_SI_Template_LDB_Tmp
    ↓
sp_FC_FM_Original_NEW_FINAL (@Division = 'LDB')
├─ Merge FM + SI Template
├─ Apply conversion factors to forecast
├─ BOM explosion (limited)
└─ Target: FC_FM_Original_LDB

↓

Channel + Time Series aggregation

↓

V_FC_FM_Original_LDB (in ./Script/1. FINAL/1. Action/ folder)
```

**Forecast Conversion:**

Just like historical, forecast also converted:

```sql
-- If user forecasts in consumer units
-- But supply planning needs professional sizes
UPDATE FC_FM_Original_LDB
SET [Y0 (u) M3] = [Y0 (u) M3] / Professional_Size_Factor
WHERE Product_Type = 'Professional'
  AND Channel = 'OFFLINE'  -- Salon
  AND Planning_Unit = 'Professional_Size'

-- Example:
-- Consumer equivalent forecast: 400 units (250ml)
-- Convert to salon size: 400 / 4 = 100 bottles (1000ml)
```

---

## 6. Complete Field Matrix

### 6.1. LDB WF Column → Source Matrix

Same column structure as CPD, but with key differences:

| WF Column Pattern | Data Type | Source | **LDB-Specific Processing** | Update Freq |
|-------------------|-----------|--------|---------------------------|-------------|
| `[Y-2 (u) M*]` | Historical SO Unit | Optimus SO | **+ sp_fc_convert_SO_LDB_SO** | Weekly |
| `[Y-1 (u) M*]` | Historical SO Unit | Optimus SO | **+ sp_fc_convert_SO_LDB_SO** | Weekly |
| `[Y0 (u) M*]` (past) | Historical SO Unit | Optimus SO | **+ sp_fc_convert_SO_LDB_SO** | Weekly |
| `[Y0 (u) M*]` (future) | Forecast SI Unit | **FM + SI Template** | **+ Conversion to forecast** | Monthly |
| `[Y+1 (u) M*]` | Forecast SI Unit | **FM + SI Template** | **+ Conversion to forecast** | Monthly |
| Other fields | Same as CPD | Same as CPD | Same | Same |

**Key LDB Differences:**

1. **Conversion Procedures:**
   - Historical: `sp_fc_convert_SO_LDB_SO` and `sp_fc_convert_SO_LDB_SI`
   - Forecast: Conversion factors applied during planning

2. **SI Template:**
   - Additional forecast input source
   - Imported via `sp_add_FC_SI_Template_Tmp`
   - Merged with FM data

3. **Category-Specific Logic:**
   - Dermatology vs Professional handling
   - Different conversion factors per category

4. **Channel Focus:**
   - PHARMA (60-70% of volume)
   - SALON (20-30% of volume)
   - Different demand patterns per channel

### 6.2. LDB Time Series → Source Comparison

| Time Series | CPD (Consumer) | **LDB (Dermo/Pro)** |
|-------------|----------------|-------------------|
| Baseline % | 60-70% | **80-85%** (more stable) |
| Promo % | 20-25% | **5-10%** (restricted) |
| Launch % | 10-15% | **10-15%** (similar) |
| FOC % | 5-10% | **5%** (medical samples only) |

### 6.3. LDB-Specific Procedures

| Procedure | Purpose | LDB-Specific |
|-----------|---------|--------------|
| **sp_add_FC_SO_OPTIMUS_NORMAL_LDB_Tmp** | Import LDB SO | ✅ LDB-specific version |
| **sp_fc_convert_SO_LDB_SO** | Convert SO units | ✅ **LDB ONLY** |
| **sp_fc_convert_SO_LDB_SI** | Convert SI units | ✅ **LDB ONLY** |
| **sp_fc_convert_SO_LDB** | Master conversion | ✅ **LDB ONLY** |
| **sp_add_FC_SI_Template_Tmp** | Import SI Template | ✅ Used mainly by LDB |
| sp_add_FC_FM_Tmp | Import FM | ❌ Standard (shared) |
| sp_Update_Bom_Header_New | BOM explosion | ❌ Standard (but less BOM in LDB) |

### 6.4. LDB Views

Located in `./Script/1. FINAL/4. View/`:

```
V_LDB_His_SI_Single.sql
V_LDB_His_SI_BOM.sql
V_LDB_His_SI_Single_FDR.sql
V_LDB_His_SI_BOM_FDR.sql
V_LDB_His_SI_SingleBomcomponent.sql
V_LDB_His_SI_SingleBomcomponent_FDR.sql
V_LDB_His_SI_FOC_TO_VP.sql
V_FC_LDB_SO_FORECAST.sql
V_FC_LDB_SO_HIS_FINAL.sql
V_LDB_FC_ZV14_Historical.sql
```

**Note:** V_FC_FM_Original_LDB is in Action folder, not View folder (unusual but intentional).

---

## 7. Example Trace: LDB Field to Source

**User Question:** "LDB, column [Y-1 (u) M6] cho La Roche-Posay Effaclar Duo+ lấy từ đâu?"

**Trace Steps:**

```
1. Identify Field:
   - Column: [Y-1 (u) M6]
   - Division: LDB
   - Product: La Roche-Posay Effaclar Duo+
   - Category: Dermatology
   - Period: Y-1 M6 = June of last year (e.g., 202406)

2. Check WF:
   Sub Group: LRP Effaclar
   Channel: OFFLINE
   Time series: 6. Total Qty
   [Y-1 (u) M6] = 5250 units (converted)

3. Query V_FC_FM_Original_LDB (or equivalent view):
   SELECT [Y-1 (u) M6]
   FROM V_FC_FM_Original_LDB
   WHERE [SUB GROUP/ Brand] = 'LRP Effaclar'
     AND Channel = 'OFFLINE'
     AND [Time series] = '6. Total Qty'
   Returns: 5250

4. Query FC_LDB_SO_HIS_FINAL (converted table):
   SELECT SellOut_Unit_Converted
   FROM FC_LDB_SO_HIS_FINAL
   WHERE Sub_Group = 'LRP Effaclar'
     AND PeriodKey = '202406'
     AND Channel = 'OFFLINE'
   Returns: 5250

5. Query FC_SO_OPTIMUS_NORMAL_LDB (raw table):
   SELECT SUM(Quantity_Unit) AS Raw_SO
   FROM FC_SO_OPTIMUS_NORMAL_LDB
   WHERE Barcode IN (SELECT Barcode FROM SubGroupMaster WHERE Sub_Group = 'LRP Effaclar')
     AND YEAR([Date]) = 2024 AND MONTH([Date]) = 6
     AND Customer_Type = 'PHARMA'
   Returns: 5000 units (raw, before conversion)

6. Conversion Check:
   sp_fc_convert_SO_LDB_SO applied:
   - Category: Dermatology
   - Conversion Factor: 1.05
   - Raw: 5000
   - Converted: 5000 × 1.05 = 5250 ✅ (matches WF)

7. Source File:
   SELLOUT_LDB_20240630.xlsx
   - From Optimus system
   - Imported weekly
   - Contains raw SO data from pharmacies

8. Conversion Reason:
   - Pharmacies report units including testers
   - 5% adjustment factor applied
   - Standardizes to saleable units
```

---

## 8. LDB Summary

### Key Takeaways:

✅ **LDB has category-specific conversion procedures** (main difference from CPD/LLD)

✅ **Two forecast sources:** FM file + SI Template

✅ **Channel focus:** Pharma (60-70%), Salon (20-30%)

✅ **Less promotional:** Stable baseline, limited promo activity

✅ **Professional vs Dermatology:** Different conversion rules by category

✅ **Conversion applies to:** Historical SO, Historical SI, and Forecast planning

### LDB vs CPD Quick Compare:

| Feature | CPD | LDB |
|---------|-----|-----|
| Conversion Procedures | ❌ None | ✅ **sp_fc_convert_SO_LDB_SO/SI** |
| Forecast Sources | FM only | **FM + SI Template** |
| BOM Complexity | High | Medium-Low |
| Promo Activity | High | Low |
| Main Channels | GT/MT/Pharma | **Pharma/Salon** |
| Category Logic | Product-based | **Category-based (Dermo/Pro)** |

---

**Document Version:** 1.0
**Last Updated:** 2025-11-19
**Related:** [MAPPING_MATRIX_OVERVIEW.md](./MAPPING_MATRIX_OVERVIEW.md) | [MAPPING_MATRIX_CPD.md](./MAPPING_MATRIX_CPD.md)
