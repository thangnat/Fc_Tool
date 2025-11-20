# Complete Mapping Matrix - CPD Division

## 📋 Mục Lục

1. [CPD Overview](#1-cpd-overview)
2. [Historical SO Mapping](#2-historical-so-mapping)
3. [Historical SI Mapping](#3-historical-si-mapping)
4. [Forecast Mapping](#4-forecast-mapping)
5. [Time Series Detail](#5-time-series-detail)
6. [BOM Processing](#6-bom-processing)
7. [Complete Field Matrix](#7-complete-field-matrix)

---

## 1. CPD Overview

### 1.1. CPD Characteristics

**CPD** = Consumer Products Division

**Product Categories:**
- Skincare (L'Oréal Paris, Garnier, etc.)
- Haircare (mass market)
- Makeup (mass market)
- Men's grooming

**Business Characteristics:**
- High volume, lower price point
- Heavy promotional activity
- Complex BOM structure (gift sets, bundles)
- Multiple channels (GT, MT, Pharma, Online)
- High FOC usage (samples, GWP)

**Data Volume:**
- ~500+ SKUs active
- ~50+ Sub Groups
- 24 months historical + 24 months forecast
- Multiple time series per SKU

---

## 2. Historical SO Mapping

### 2.1. Historical SO - Unit

**Target Columns in WF:**
```
[Y-2 (u) M1] through [Y-2 (u) M12]  ← 2 years ago
[Y-1 (u) M1] through [Y-1 (u) M12]  ← Last year
[Y0 (u) M1] through [Y0 (u) Mcurrent]  ← Current year (past months only)
```

**Complete Data Flow:**

```
SOURCE: Optimus System
├─ Raw Files: \\10.38.17.21\File Exchange FC\Pending\OPTIMUS\SELL OUT NORMAL\CPD\
├─ File Pattern: SELLOUT_CPD_YYYYMMDD.xlsx
├─ Sheet: SO Data
├─ Columns: Date, Barcode, Customer_Channel, Quantity Unit, Quantity Value, Customer, Province
└─ Update Frequency: Weekly (every Monday)

↓ IMPORT PROCEDURE

sp_add_FC_SO_OPTIMUS_NORMAL_Tmp
├─ Location: ./Script/1. FINAL/0. link_37/sp_add_FC_SO_OPTIMUS_NORMAL_Tmp.sql
├─ Parameters:
│   @Division = 'CPD'
│   @filename = 'SELLOUT_CPD_20241118.xlsx'
│   @path = '\\10.38.17.21\File Exchange FC\Pending\OPTIMUS\SELL OUT NORMAL\CPD\'
├─ Target Table: FC_SO_OPTIMUS_NORMAL_CPD (temporary)
└─ Logic:
    - Read Excel via OPENROWSET
    - Insert into temp table
    - Validate data (date range, barcode format)
    - Log import status

↓ PROCESSING PROCEDURE

sp_Run_SO_HIS_FULL
├─ Location: ./Script/1. FINAL/1. Action/sp_Run_SO_HIS_FULL.sql (not found, likely in Action folder)
├─ Processing Steps:
│   1. Channel Mapping
│   2. Product Hierarchy Join (Barcode → Spectrum → Sub_Group)
│   3. Period Calculation (Date → YYYYMM)
│   4. Aggregation by Sub_Group + Channel + Period
│   5. Time Series assignment (all → "6. Total Qty")
└─ Target Table: FC_CPD_SO_HIS_FINAL

SQL Logic:
INSERT INTO FC_CPD_SO_HIS_FINAL
SELECT
    sm.Sub_Group,
    sm.Spectrum,
    PeriodKey = CONCAT(YEAR(so.[Date]), RIGHT('0' + CAST(MONTH(so.[Date]) AS VARCHAR), 2)),
    Channel = CASE
        WHEN so.Customer_Channel IN ('GT', 'MT', 'PHARMA') THEN 'OFFLINE'
        WHEN so.Customer_Channel = 'ONLINE' THEN 'ONLINE'
        ELSE 'OFFLINE'
    END,
    Time_Series = '6. Total Qty',  ← Historical SO always "Total"
    SellOut_Unit = SUM(so.[Quantity Unit]),
    SellOut_Value = SUM(so.[Quantity Value])
FROM FC_SO_OPTIMUS_NORMAL_CPD so
INNER JOIN fnc_SubGroupMaster('CPD', 'full') sm
    ON so.Barcode = sm.Barcode
WHERE so.[Date] >= DATEADD(MONTH, -24, GETDATE())  ← Last 24 months
  AND so.Division = 'CPD'
  AND sm.Status = 'Active'
GROUP BY sm.Sub_Group, sm.Spectrum, YEAR(so.[Date]), MONTH(so.[Date]), Channel

↓ VIEW/FUNCTION

fnc_FC_SO_HIS_FINAL('CPD')
├─ Location: ./Script/1. FINAL/3. Function/fnc_FC_SO_HIS_FINAL.sql
├─ Purpose: Pivot historical data to column format
├─ Input: FC_CPD_SO_HIS_FINAL
└─ Output: Columns [Y-2 (u) M*], [Y-1 (u) M*], [Y0 (u) M*]

↓ FINAL VIEW

V_FC_FM_Original_CPD
├─ Location: ./Script/1. FINAL/4. View/V_FC_FM_Original_CPD.sql
├─ Joins: Historical SO + Historical SI + Forecast + Stock + Budget
└─ Output: Complete WF structure

↓ WORKING FILE (Excel)
```

**Channel Mapping Detail:**

| Raw Customer_Channel | Mapped to System Channel | Business Meaning |
|----------------------|-------------------------|------------------|
| GT | OFFLINE | General Trade (mom & pop stores) |
| MT | OFFLINE | Modern Trade (supermarkets, hypermarkets) |
| PHARMA | OFFLINE | Pharmacies |
| ONLINE | ONLINE | E-commerce platforms |
| E-COMMERCE | ONLINE | Direct online sales |
| (null) | OFFLINE | Default to offline |

**Filters Applied:**

```sql
-- Date filter
AND so.[Date] >= DATEADD(MONTH, -24, GETDATE())  ← Keep last 24 months

-- Status filter
AND sm.Status = 'Active'  ← Only active products

-- Exclude filters
AND so.Order_Type NOT IN ('RETURN', 'CANCELLED')  ← Exclude returns/cancellations
AND so.Quantity_Unit > 0  ← Exclude zero/negative quantities

-- Division filter
AND so.Division = 'CPD'
```

**Example Trace:**

```
User sees in WF:
Sub_Group: LOP Revitalift Cream
Channel: OFFLINE
Time series: 6. Total Qty
[Y-1 (u) M6] = 15000 units

Trace:
1. Y-1 M6 = June of last year (e.g., 202406 if current is 2025)
2. Query fnc_FC_SO_HIS_FINAL('CPD'):
   WHERE Sub_Group = 'LOP Revitalift Cream'
     AND Channel = 'OFFLINE'
     AND Time_Series = '6. Total Qty'
   Returns: [Y-1 (u) M6] = 15000

3. Query FC_CPD_SO_HIS_FINAL:
   WHERE Sub_Group = 'LOP Revitalift Cream'
     AND Channel = 'OFFLINE'
     AND PeriodKey = '202406'
   Returns: SellOut_Unit = 15000

4. Query FC_SO_OPTIMUS_NORMAL_CPD:
   WHERE Barcode IN (SELECT Barcode FROM SubGroupMaster WHERE Sub_Group = 'LOP Revitalift Cream')
     AND YEAR(Date) = 2024 AND MONTH(Date) = 6
     AND Customer_Channel IN ('GT', 'MT', 'PHARMA')
   Returns: SUM(Quantity Unit) = 15000
   
5. Source File: SELLOUT_CPD_20240630.xlsx
   Contains raw transaction data for June 2024
```

### 2.2. Historical SO - Value

**Target Columns in WF:**
```
[(Value)_Y-2 (u) M1] through [(Value)_Y-2 (u) M12]
[(Value)_Y-1 (u) M1] through [(Value)_Y-1 (u) M12]
[(Value)_Y0 (u) M1] through [(Value)_Y0 (u) Mcurrent]
```

**Same data flow as Unit, but using Value fields:**

```sql
SELECT
    ...
    SellOut_Value = SUM(so.[Quantity Value])  ← Value in VND
FROM FC_SO_OPTIMUS_NORMAL_CPD so
```

**Value Calculation in Source:**
```
Quantity Value = Quantity Unit × Unit Price

Where:
- Unit Price: From price list or actual transaction price
- Currency: VND (Vietnamese Dong)
- Includes: Discounts, promotions (net price)
```

**Example:**
```
Product: L'Oréal UV Perfect SPF50+ 30ml
Unit: 100 bottles
Unit Price: 250,000 VND/bottle
Value: 100 × 250,000 = 25,000,000 VND

WF Column:
[Y-1 (u) M6] = 100 (units)
[(Value)_Y-1 (u) M6] = 25,000,000 (VND)
```

---

## 3. Historical SI Mapping

### 3.1. Historical SI - Unit

**Target Columns:**
- Same period structure as SO (Y-2, Y-1, Y0)
- But data comes from ZV14 (SAP Sell-In report)

**Complete Data Flow:**

```
SOURCE: SAP ZV14 Report
├─ Raw Files: \\10.38.17.21\File Exchange FC\Pending\ZV14\CPD\
├─ File Pattern: ZV14_CPD_YYYYMMDD.xlsx
├─ SAP Transaction: ZV14
├─ Columns: Material, Delivery_Date, Customer, Order_Number, Order_Type, Delivery_Quantity, Unit_Price
└─ Update Frequency: Daily

↓ IMPORT PROCEDURE

sp_add_FC_SI_OPTIMUS_NORMAL_Tmp
├─ Parameters:
│   @Division = 'CPD'
│   @filename = 'ZV14_CPD_20241118.xlsx'
├─ Target Table: FC_SI_OPTIMUS_NORMAL_CPD
└─ Logic: Import from SAP export file

SQL Logic:
INSERT INTO FC_SI_OPTIMUS_NORMAL_CPD
SELECT
    Material,
    Delivery_Date,
    Customer,
    Order_Number,
    Order_Type,
    Order_Status,
    Delivery_Quantity,
    Unit_Price,
    PeriodKey = FORMAT(Delivery_Date, 'yyyyMM'),
    Channel = CASE
        WHEN Customer_Type IN ('GT', 'MT') THEN 'OFFLINE'
        WHEN Customer_Type = 'ONLINE' THEN 'ONLINE'
        ELSE 'OFFLINE'
    END
FROM SAP_ZV14_Import
WHERE Division = 'CPD'
  AND Order_Status = 'C'  ← Completed orders only
  AND Order_Type NOT IN ('ZRET', 'ZCAN', 'ZINT')  ← Exclude returns, cancellations, internal transfers
  AND Delivery_Date >= DATEADD(MONTH, -24, GETDATE())

↓ VIEWS

Multiple SI views depending on product type:
├─ V_CPD_His_SI_Single: Single products (non-BOM)
├─ V_CPD_His_SI_BOM: BOM/Bundle products
├─ V_CPD_His_SI_SingleBomcomponent: Components of BOM
├─ V_CPD_His_SI_FOC_TO_VP: Free of charge to VP
├─ V_CPD_His_SI_*_FDR: With FDR adjustments
└─ V_CPD_His_SI_*_MTD: Month-to-date versions

↓ AGGREGATION

Views join with product hierarchy and aggregate to Sub_Group level

↓ WORKING FILE
```

**BOM Handling for SI:**

CPD has complex BOM logic:

```sql
-- Single Product SI
SELECT
    sm.Sub_Group,
    PeriodKey,
    Channel,
    SI_Unit = SUM(Delivery_Quantity)
FROM FC_SI_OPTIMUS_NORMAL_CPD si
INNER JOIN fnc_SubGroupMaster('CPD', 'full') sm
    ON si.Material = sm.Spectrum
WHERE sm.Product_Type = 'Single'  ← Not a bundle
GROUP BY sm.Sub_Group, PeriodKey, Channel

-- BOM Product SI (Bundle)
-- If Bundle sold: Add to Bundle Sub_Group
-- AND explode to component Sub_Groups based on BOM
SELECT
    bom.Component_Sub_Group,
    si.PeriodKey,
    si.Channel,
    SI_Unit_From_BOM = SUM(si.Delivery_Quantity * bom.Component_Qty_Per_Bundle)
FROM FC_SI_OPTIMUS_NORMAL_CPD si
INNER JOIN FC_BOM_Header bom
    ON si.Material = bom.Bundle_Spectrum
GROUP BY bom.Component_Sub_Group, si.PeriodKey, si.Channel

-- Total SI = Direct SI + SI from BOM
```

**Example:**

```
Scenario: Gift Set sold

Product: "L'Oréal Youth Code Gift Set"
Spectrum: 3600523456789 (Bundle)
Quantity Sold: 100 sets

BOM Structure:
├─ Youth Code Serum 30ml (Spectrum: 3600523111111) → Qty per bundle: 1
├─ Youth Code Day Cream 50ml (Spectrum: 3600523222222) → Qty per bundle: 1
└─ Youth Code Night Cream 50ml (Spectrum: 3600523333333) → Qty per bundle: 1

SI Impact:
1. Gift Set Sub_Group: +100 units (bundle itself)
2. Serum Sub_Group: +100 units (exploded from BOM)
3. Day Cream Sub_Group: +100 units (exploded from BOM)
4. Night Cream Sub_Group: +100 units (exploded from BOM)

Working File Shows:
Row 1: Gift Set → [Y0 (u) M3] = 100
Row 2: Serum → [Y0 (u) M3] = 100 (from BOM) + Direct Sales
Row 3: Day Cream → [Y0 (u) M3] = 100 (from BOM) + Direct Sales
Row 4: Night Cream → [Y0 (u) M3] = 100 (from BOM) + Direct Sales
```

---

## 4. Forecast Mapping

### 4.1. Forecast Main Source: FM File

**Target Columns:**
```
[Y0 (u) M_future] through [Y0 (u) M12]  ← Current year future months
[Y+1 (u) M1] through [Y+1 (u) M12]  ← Next year
```

**Data Flow:**

```
SOURCE: FM (FuturMaster) Excel File
├─ File Location: \\10.38.17.21\File Exchange FC\Pending\FM\CPD\
├─ File Pattern: CPD_FM_YYYYMM.xlsx
├─ Generated By: Demand Planning team using FuturMaster tool
├─ Sheet: FM Data
├─ Columns:
│   - SKU Code (Spectrum)
│   - SUB GROUP/ Brand
│   - Channel
│   - Time series
│   - [Y0 (u) M1] through [Y0 (u) M12]
│   - [Y+1 (u) M1] through [Y+1 (u) M12]
└─ Update Frequency: Monthly (before FM cycle)

↓ IMPORT

sp_add_FC_FM_Tmp
├─ Location: ./Script/1. FINAL/0. link_37/sp_add_FC_FM_Tmp.sql
├─ Parameters:
│   @Division = 'CPD'
│   @FM_KEY = '202501'  ← Format: YYYYMM
│   @filename = 'CPD_FM_202501.xlsx'
├─ Target Table: FC_FM_CPD_202501_Tmp (temporary, one per FM cycle)
└─ Logic: Import all rows from FM file

↓ PROCESSING

sp_FC_FM_Original_NEW
├─ Procedure: Insert FM data into main table
├─ BOM Processing: sp_Update_Bom_Header_New
│   - Explode bundle forecast to components
│   - Add component forecast to existing
├─ Target Table: FC_FM_Original_CPD
└─ Logic:
    - Copy FM data for single products
    - Explode BOM products to components
    - Aggregate multiple sources (FM + adjustments)

↓ USER EDITS

Users can edit forecast in WF Excel:
├─ Direct edits to cells
├─ Upload back via sp_FC_FM_WF_Upload
└─ Version control: M-1 version saved before updates

↓ CALCULATIONS

sp_calculate_total
├─ Calculates: 6. Total Qty = 1. Baseline + 2. Promo + 4. Launch + 5. FOC
├─ For each Sub_Group + Channel + Period
└─ Updates: [Y0 (u) M*] and [Y+1 (u) M*] Total rows

↓ WORKING FILE VIEW

V_FC_FM_Original_CPD
└─ Shows all time series, all periods, all channels
```

---

## 5. Time Series Detail

CPD uses 5 time series (skipping #3 for historical reasons):

### 5.1. Time Series Breakdown

| # | Time Series Name | Purpose | Source | Editable |
|---|------------------|---------|--------|----------|
| **1** | **Baseline Qty** | Regular sales forecast | FM file + User input | ✅ Yes |
| **2** | **Promo Qty** | Promotional incremental sales | User input + Promo calendar | ✅ Yes |
| **4** | **Launch Qty** | New product launch volume (first 3 months) | User input | ✅ Yes |
| **5** | **FOC Qty** | Free of charge (samples, GWP) | User input | ✅ Yes |
| **6** | **Total Qty** | Sum of all above | **Calculated** = 1+2+4+5 | ❌ No (auto) |

### 5.2. 1. Baseline Qty Mapping

**Source:** FM File (primary) + User adjustments

```sql
-- From FM import
INSERT INTO FC_FM_Original_CPD (...)
SELECT
    [SUB GROUP/ Brand],
    [Channel],
    Time_Series = '1. Baseline Qty',
    [Y0 (u) M1] = fm.[Y0 (u) M1],
    [Y0 (u) M2] = fm.[Y0 (u) M2],
    ...
FROM FC_FM_CPD_202501_Tmp fm
WHERE fm.[Time series] = '1. Baseline Qty'
```

**User Can Edit:**
- Yes, in WF Excel
- Changes saved to FC_FM_Original_CPD
- M-1 version kept for comparison

**Example:**
```
FM File shows:
Product: L'Oréal UV Perfect
Channel: OFFLINE
Time series: 1. Baseline Qty
[Y0 (u) M3] = 10000 (from FM model)

User edits in WF:
[Y0 (u) M3] = 12000 (adjusted based on promotion plan)

System saves:
- Current: 12000
- M-1 version: 10000 (for audit trail)
```

### 5.3. 2. Promo Qty Mapping

**Source:** User input (manual forecast of promotional incremental)

**Definition:**
- **NOT** total promo sales
- Only **incremental** sales due to promotion
- Baseline + Promo = Total expected during promo period

**Procedures:**

```
Input Methods:
1. Direct input in WF Excel
2. Import from Promo Calendar file
   sp_tag_update_wf_promo_single_unit_only_offline
   sp_tag_update_wf_promo_bom_component_unit

Processing:
sp_tag_add_FC_SI_Group_FC_SI_Promo_Single_New
├─ Read promo calendar
├─ Calculate expected promo lift
└─ Populate Promo Qty rows
```

**Example:**
```
Normal Baseline (no promo): 10000 units/month

March Promotion: 20% off
Expected Promo Lift: +30% incremental

Forecast:
[Y0 (u) M3] for "1. Baseline Qty" = 10000
[Y0 (u) M3] for "2. Promo Qty" = 3000  ← 30% incremental
[Y0 (u) M3] for "6. Total Qty" = 13000  ← Sum

Interpretation:
- Without promo: 10000 expected
- With promo: 13000 expected
- Promo incremental: +3000
```

### 5.4. 4. Launch Qty Mapping

**Source:** User input (new product launch forecast)

**Definition:**
- Forecast for **new product launches**
- Typically first 3 months after launch
- After 3 months, moves to Baseline

**Usage:**
```
Month 1 (Launch): High Launch Qty, Low Baseline
Month 2: Medium Launch Qty, Growing Baseline
Month 3: Low Launch Qty, Higher Baseline
Month 4+: Zero Launch Qty, All in Baseline
```

**Procedure:**
```
sp_tag_update_wf_new_launch_unit_only_offline
├─ Input: Launch plan from Marketing
├─ Identify: New SKUs (Product_Status = 'NEW')
├─ Populate: Launch Qty for first 3 months
└─ Update: Launch Date in master data
```

**Example:**
```
New Product: L'Oréal Revitalift Laser X3 (Launch Mar 2025)

[Y0 (u) M3] Mar:
- 1. Baseline Qty: 1000 (initial distribution)
- 4. Launch Qty: 5000 (launch push)
- 6. Total Qty: 6000

[Y0 (u) M4] Apr:
- 1. Baseline Qty: 2000 (growing repeat)
- 4. Launch Qty: 3000 (continued launch support)
- 6. Total Qty: 5000

[Y0 (u) M5] May:
- 1. Baseline Qty: 3000 (stabilizing)
- 4. Launch Qty: 1000 (final launch push)
- 6. Total Qty: 4000

[Y0 (u) M6] Jun:
- 1. Baseline Qty: 4000 (all regular now)
- 4. Launch Qty: 0 (launch complete)
- 6. Total Qty: 4000
```

### 5.5. 5. FOC Qty Mapping

**Source:** User input (Free of Charge forecast)

**Definition:**
- Free samples for marketing
- Gift with purchase (GWP)
- Trade promotions (free goods)
- **Not invoiced** but impacts supply planning

**Procedures:**
```
sp_tag_update_wf_foc_unit_only_offline
└─ Input from FOC plan

sp_tag_add_FC_SI_Group_FC_SI_FOC
└─ Process FOC forecast
```

**Example:**
```
Product: L'Oréal Revitalift Sample 5ml

Regular Product: Not sold separately
FOC Usage: Given as samples in stores, GWP for Revitalift 50ml

[Y0 (u) M3]:
- 1. Baseline Qty: 0 (not sold)
- 5. FOC Qty: 50000 (samples distributed)
- 6. Total Qty: 50000

Supply Impact:
- Need to produce 50000 samples
- No revenue but cost and supply chain impact
```

### 5.6. 6. Total Qty Calculation

**Source:** Calculated (not editable)

**Formula:**
```
6. Total Qty = 1. Baseline Qty + 2. Promo Qty + 4. Launch Qty + 5. FOC Qty
```

**Procedure:**
```
sp_calculate_total
├─ Runs after any time series update
├─ For each Sub_Group + Channel + Period:
│   Total = Baseline + Promo + Launch + FOC
└─ Updates: Time Series "6. Total Qty" rows
```

**Example:**
```
Product: L'Oréal UV Perfect
Channel: OFFLINE
Period: [Y0 (u) M3]

Time Series Values:
1. Baseline Qty:  10000
2. Promo Qty:      3000
4. Launch Qty:        0
5. FOC Qty:        2000
─────────────────────────
6. Total Qty:     15000  ← Auto calculated
```

**Special Case: O+O (Offline + Online)**

Total also includes channel aggregation:

```
OFFLINE:
- 1. Baseline Qty: 10000
- 2. Promo Qty: 3000
- 6. Total Qty: 13000

ONLINE:
- 1. Baseline Qty: 2000
- 2. Promo Qty: 500
- 6. Total Qty: 2500

O+O (Combined):
- 1. Baseline Qty: 12000  ← 10000 + 2000
- 2. Promo Qty: 3500  ← 3000 + 500
- 6. Total Qty: 15500  ← 13000 + 2500
```

---

## 6. BOM Processing

### 6.1. BOM Structure

CPD has extensive BOM (Bill of Materials) for bundles:

**BOM Tables:**
```
FC_BOM_Header
├─ Bundle_Spectrum (parent product code)
├─ Component_Spectrum (component product code)
├─ Component_Qty_Per_Bundle (quantity of component in 1 bundle)
├─ Bundle_Sub_Group
├─ Component_Sub_Group
└─ Active_Status

Example:
Bundle: "L'Oréal Youth Code Gift Set" (Spectrum: 360052BUNDLE)
├─ Component 1: Serum 30ml (Spectrum: 360052SERUM1) → Qty: 1
├─ Component 2: Day Cream 50ml (Spectrum: 360052CREAM1) → Qty: 1
└─ Component 3: Night Cream 50ml (Spectrum: 360052CREAM2) → Qty: 1
```

### 6.2. BOM Explosion for Forecast

**Procedure:** `sp_Update_Bom_Header_New`

**Logic:**

```sql
-- When user forecasts a bundle
-- Step 1: User inputs bundle forecast
UPDATE FC_FM_Original_CPD
SET [Y0 (u) M3] = 1000  ← User forecasts 1000 gift sets
WHERE [SUB GROUP/ Brand] = 'Youth Code Gift Set'
  AND [Time series] = '1. Baseline Qty'
  AND Channel = 'OFFLINE'

-- Step 2: System explodes to components
EXEC sp_Update_Bom_Header_New
    @Division = 'CPD',
    @FM_KEY = '202501'

-- Step 3: Add component forecast
INSERT INTO FC_FM_Original_CPD (...)
SELECT
    Component_Sub_Group,
    Channel,
    Time_Series = '1. Baseline Qty',
    [Y0 (u) M3] = Bundle_Forecast * Component_Qty_Per_Bundle
FROM FC_BOM_Header bom
INNER JOIN FC_FM_Original_CPD bundle
    ON bom.Bundle_Sub_Group = bundle.[SUB GROUP/ Brand]
WHERE bundle.[Y0 (u) M3] > 0
  AND bom.Active_Status = 'Y'

-- Step 4: Component total = Direct forecast + From BOM
UPDATE component
SET component.[Y0 (u) M3] =
    ISNULL(component.Direct_Forecast, 0) +  ← User direct input
    ISNULL(component.From_BOM_Forecast, 0)  ← Exploded from bundles
FROM FC_FM_Original_CPD component
```

**Example Scenario:**

```
Setup:
Bundle: Youth Code Gift Set
├─ Direct forecast: 1000 sets
└─ Components (qty per bundle = 1 each):
    ├─ Serum (direct forecast: 500)
    ├─ Day Cream (direct forecast: 800)
    └─ Night Cream (direct forecast: 600)

BOM Explosion:
Bundle: 1000 sets
→ Explodes to:
    - Serum: +1000 (from BOM)
    - Day Cream: +1000 (from BOM)
    - Night Cream: +1000 (from BOM)

Final Forecast (Component view):
- Serum: 500 (direct) + 1000 (from BOM) = 1500
- Day Cream: 800 (direct) + 1000 (from BOM) = 1800
- Night Cream: 600 (direct) + 1000 (from BOM) = 1600

Working File Shows:
Row 1: Youth Code Gift Set
  - [Y0 (u) M3] = 1000
  - Product Type = "BOM" or "Bundle"

Row 2: Youth Code Serum
  - [Y0 (u) M3] = 1500
  - Product Type = "Single + BOM Component"

Row 3: Youth Code Day Cream
  - [Y0 (u) M3] = 1800
  - Product Type = "Single + BOM Component"

Row 4: Youth Code Night Cream
  - [Y0 (u) M3] = 1600
  - Product Type = "Single + BOM Component"
```

### 6.3. BOM Views

Multiple views handle BOM complexity:

```
V_CPD_His_SI_Single
└─ Products sold as singles only (no BOM impact)

V_CPD_His_SI_BOM
└─ Bundle products (parent level)

V_CPD_His_SI_SingleBomcomponent
└─ Components: Direct sales + Exploded from bundles

V_FC_SI_Bomheader_Forecast_CPD
└─ Forecast view with BOM logic
```

---

## 7. Complete Field Matrix

### 7.1. WF Column → Source Matrix

| WF Column Pattern | Data Type | Source | Import Proc | Final Table/View | Update Frequency | Editable |
|-------------------|-----------|--------|-------------|------------------|------------------|----------|
| `[Y-2 (u) M*]` | Historical SO Unit | Optimus SO | sp_add_FC_SO_OPTIMUS_NORMAL_Tmp | FC_CPD_SO_HIS_FINAL | Weekly | ❌ No |
| `[(Value)_Y-2 (u) M*]` | Historical SO Value | Optimus SO | sp_add_FC_SO_OPTIMUS_NORMAL_Tmp | FC_CPD_SO_HIS_FINAL | Weekly | ❌ No |
| `[Y-1 (u) M*]` | Historical SO Unit | Optimus SO | sp_add_FC_SO_OPTIMUS_NORMAL_Tmp | FC_CPD_SO_HIS_FINAL | Weekly | ❌ No |
| `[(Value)_Y-1 (u) M*]` | Historical SO Value | Optimus SO | sp_add_FC_SO_OPTIMUS_NORMAL_Tmp | FC_CPD_SO_HIS_FINAL | Weekly | ❌ No |
| `[Y0 (u) M*]` (past) | Historical SO Unit | Optimus SO | sp_add_FC_SO_OPTIMUS_NORMAL_Tmp | FC_CPD_SO_HIS_FINAL | Weekly | ❌ No |
| `[Y0 (u) M*]` (future) | Forecast SI Unit | FM File + User | sp_add_FC_FM_Tmp | FC_FM_Original_CPD | Monthly + Daily edits | ✅ Yes |
| `[Y+1 (u) M*]` | Forecast SI Unit | FM File + User | sp_add_FC_FM_Tmp | FC_FM_Original_CPD | Monthly + Daily edits | ✅ Yes |
| `[(Value)_Y0 (u) M*]` (future) | Forecast SI Value | Calculated | sp_tag_update_wf_total_value_New | FC_FM_Original_CPD | After unit updates | ❌ No (auto) |
| `[(Value)_Y+1 (u) M*]` | Forecast SI Value | Calculated | sp_tag_update_wf_total_value_New | FC_FM_Original_CPD | After unit updates | ❌ No (auto) |
| `[(m-1)_Y0 (u) M*]` | Previous month version | Last month WF | sp_Backup_WF_before_Save | FC_FM_Original_CPD_Backup | Monthly | ❌ No |
| `[(m-1)_Y+1 (u) M*]` | Previous month version | Last month WF | sp_Backup_WF_before_Save | FC_FM_Original_CPD_Backup | Monthly | ❌ No |
| `[SOH]` | Stock on Hand | SAP ZMR32 | sp_Create_SOH_FINAL | FC_SOH_FINAL | Daily | ❌ No |
| `[GIT M0]` | Goods in Transit M0 | SAP GIT Report | sp_FC_GIT_New | FC_GIT | Daily | ❌ No |
| `[GIT M1]` | Goods in Transit M1 | SAP GIT Report | sp_FC_GIT_New | FC_GIT | Daily | ❌ No |
| `[GIT M2]` | Goods in Transit M2 | SAP GIT Report | sp_FC_GIT_New | FC_GIT | Daily | ❌ No |
| `[GIT M3]` | Goods in Transit M3 | SAP GIT Report | sp_FC_GIT_New | FC_GIT | Daily | ❌ No |
| `[Total GIT]` | Sum of GIT M0-M3 | Calculated | sp_FC_GIT_New | FC_GIT | Daily | ❌ No |
| `[SIT]` | Stock in Transit | Calculated | sp_tag_update_wf_sit_NEW | FC_FM_Original_CPD | Daily | ❌ No |
| `[SIT Day]` | SIT in days coverage | Calculated | sp_tag_update_wf_sit_day | FC_FM_Original_CPD | Daily | ❌ No |
| `[MTD SI]` | Month-to-Date SI | SAP ZV14 (daily) | sp_tag_update_wf_mtd_si_NEW | FC_SI_OPTIMUS_NORMAL_CPD | Daily | ❌ No |
| `[SLOB]` | Slow-moving risk | Calculated | sp_tag_update_slob_wf | FC_FM_Original_CPD | Daily | ❌ No |
| `[AVE P3M Y-1]` | Avg previous 3M Y-1 | Calculated | sp_tag_Update_WF_AVG_HIS_3M_Y_MINUS_1_SI_unit | FC_FM_Original_CPD | Weekly | ❌ No |
| `[AVE F3M Y-1]` | Avg forecast 3M Y-1 | Calculated | (in total calculations) | FC_FM_Original_CPD | After forecast updates | ❌ No |
| `[AVE P3M Y0]` | Avg previous 3M Y0 | Calculated | sp_tag_Update_WF_AVG_HIS_3M_Y0_SI_unit | FC_FM_Original_CPD | Weekly | ❌ No |
| `[AVE F3M Y0]` | Avg forecast 3M Y0 | Calculated | (in total calculations) | FC_FM_Original_CPD | After forecast updates | ❌ No |
| `[%F3M Y0/ P3M Y0]` | Growth % | Calculated | sp_fc_fm_risk_3M | FC_FM_Original_CPD | After forecast updates | ❌ No |
| `[B_Y0_M*]` | Budget Unit | Finance BP file | sp_tag_gen_budget_budget_New | FC_FM_Original_CPD | Annually (before BP cycle) | ❌ No |
| `[B_Y+1_M*]` | Budget Unit | Finance BP file | sp_tag_gen_budget_budget_New | FC_FM_Original_CPD | Annually | ❌ No |
| `[(Value)_B_Y0_M*]` | Budget Value | Finance BP file | sp_tag_update_wf_budget_value | FC_FM_Original_CPD | Annually | ❌ No |
| `[(Value)_B_Y+1_M*]` | Budget Value | Finance BP file | sp_tag_update_wf_budget_value | FC_FM_Original_CPD | Annually | ❌ No |
| `[PB_Y+1_M*]` | Pre-Budget Unit | Finance Pre-BP | sp_tag_gen_budget_pre_budget_new | FC_FM_Original_CPD | Annually | ❌ No |
| `[(Value)_PB_Y+1_M*]` | Pre-Budget Value | Finance Pre-BP | sp_tag_update_wf_pre_budget_value | FC_FM_Original_CPD | Annually | ❌ No |
| `[T1_Y0_M*]` | Trend 1 Unit | Finance Trend file | sp_tag_gen_budget_trend_new | FC_FM_Original_CPD | Quarterly | ❌ No |
| `[T2_Y0_M*]` | Trend 2 Unit | Finance Trend file | sp_tag_gen_budget_trend_new | FC_FM_Original_CPD | Quarterly | ❌ No |
| `[T3_Y0_M*]` | Trend 3 Unit | Finance Trend file | sp_tag_gen_budget_trend_new | FC_FM_Original_CPD | Quarterly | ❌ No |
| `[Risk (u) M0-M3]` | Risk Unit | Calculated | sp_fc_fm_risk_3M | FC_FM_Original_CPD | After forecast updates | ❌ No |
| `[Risk (val) M0-M3]` | Risk Value | Calculated | sp_fc_fm_risk_3M | FC_FM_Original_CPD | After forecast updates | ❌ No |

### 7.2. Time Series → Source Matrix

For each Time Series row, sources differ:

| Time Series | Historical Source | Forecast Source | Editable | Notes |
|-------------|------------------|-----------------|----------|-------|
| **1. Baseline Qty** | N/A (historical is Total) | FM file + User input | ✅ Yes | Main forecast input |
| **2. Promo Qty** | N/A | User input + Promo calendar | ✅ Yes | Promotional incremental |
| **4. Launch Qty** | N/A | User input + Launch plan | ✅ Yes | New product launch (first 3M) |
| **5. FOC Qty** | N/A | User input + FOC plan | ✅ Yes | Free of charge forecast |
| **6. Total Qty** | Optimus SO (all historical) | Calculated: 1+2+4+5 | ❌ No (auto) | Sum of all time series |

**Note:** Historical data only has "6. Total Qty" because we don't split historical actuals into Baseline/Promo/Launch/FOC.

### 7.3. Channel → Source Matrix

| Channel in WF | Historical SO Source Channels | Historical SI Source | Forecast Source |
|---------------|------------------------------|---------------------|-----------------|
| **OFFLINE** | GT, MT, PHARMA | Same | FM file + User (OFFLINE row) |
| **ONLINE** | ONLINE, E-COMMERCE | Same | FM file + User (ONLINE row) |
| **O+O** | ALL (aggregate) | ALL | Calculated: OFFLINE + ONLINE |

---

## 8. CPD-Specific Procedures Summary

### 8.1. Import Procedures (0. link_37/)

| Procedure | Purpose | Input | Output | Frequency |
|-----------|---------|-------|--------|-----------|
| sp_add_FC_SO_OPTIMUS_NORMAL_Tmp | Import SO from Optimus | SELLOUT_CPD_YYYYMMDD.xlsx | FC_SO_OPTIMUS_NORMAL_CPD | Weekly |
| sp_add_FC_SI_OPTIMUS_NORMAL_Tmp | Import SI from ZV14 | ZV14_CPD_YYYYMMDD.xlsx | FC_SI_OPTIMUS_NORMAL_CPD | Daily |
| sp_add_FC_FM_Tmp | Import FM forecast | CPD_FM_YYYYMM.xlsx | FC_FM_CPD_YYYYMM_Tmp | Monthly |
| sp_add_FC_GIT_Tmp | Import GIT data | GIT_CPD_YYYYMMDD.xlsx | FC_GIT | Daily |
| sp_add_MasterFile_CPD_Tmp | Import master data | Various master files | FC_Spectrum, FC_BOM_Header, etc. | As needed |

### 8.2. Processing Procedures (1. Action/)

| Procedure | Purpose | Trigger | Output |
|-----------|---------|---------|--------|
| sp_FC_SO_HIS_FINAL | Process historical SO | After SO import | FC_CPD_SO_HIS_FINAL |
| sp_Create_V_His_SI_Final_NEW | Create SI historical views | After SI import | V_CPD_His_SI_* views |
| sp_FC_FM_Original_NEW_FINAL | Process FM forecast | After FM import | FC_FM_Original_CPD |
| sp_Update_Bom_Header_New | BOM explosion | After FM import | FC_FM_Original_CPD (components updated) |
| sp_calculate_total | Calculate Total Qty | After time series updates | FC_FM_Original_CPD (Total rows) |
| sp_tag_update_wf_total_unit_new | Aggregate O+O | After all updates | FC_FM_Original_CPD (O+O rows) |
| sp_tag_update_slob_wf | Calculate SLOB risk | Daily | FC_FM_Original_CPD (SLOB column) |
| sp_FC_GIT_New | Process GIT data | After GIT import | FC_GIT (M0-M3 breakdown) |
| sp_Create_SOH_FINAL | Process SOH data | Daily | FC_SOH_FINAL |
| sp_tag_update_wf_sit_NEW | Calculate SIT | Daily | FC_FM_Original_CPD (SIT column) |

### 8.3. View/Function (3. Function/, 4. View/)

| Object | Type | Purpose | Output |
|--------|------|---------|--------|
| fnc_FC_SO_HIS_FINAL | Function | Pivot historical SO to columns | Column format for WF |
| fnc_SubGroupMaster | Function | Product hierarchy lookup | Sub_Group mapping |
| V_FC_FM_Original_CPD | View | Complete WF structure | All columns for Excel export |
| V_CPD_His_SI_Single | View | Historical SI for single products | SI data (non-BOM) |
| V_CPD_His_SI_BOM | View | Historical SI for bundles | SI data (BOM parents) |
| V_CPD_His_SI_SingleBomcomponent | View | SI including BOM explosion | SI data (with BOM impact) |

---

**Document Version:** 1.0
**Last Updated:** 2025-11-19
**Related:** [MAPPING_MATRIX_OVERVIEW.md](./MAPPING_MATRIX_OVERVIEW.md)
