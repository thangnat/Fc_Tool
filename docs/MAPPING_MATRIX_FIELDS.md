# Complete Mapping Matrix - Field Details

## 📋 Mục Lục

1. [Historical Columns](#1-historical-columns)
2. [Forecast Columns](#2-forecast-columns)
3. [Stock Fields](#3-stock-fields)
4. [Risk Fields](#4-risk-fields)
5. [Average Fields](#5-average-fields)
6. [Budget Fields](#6-budget-fields)
7. [Version Fields](#7-version-fields)
8. [MTD Fields](#8-mtd-fields)

---

## 1. Historical Columns

### 1.1. [Y-2 (u) M1-M12] - Historical SO Unit (2 Years Ago)

**Full Name:** Year Minus 2, Unit, Month 1-12

**Data Type:** Integer (units)

**Source:** Optimus SO data (2 years ago)

**Procedure Chain:**
```
sp_add_FC_SO_OPTIMUS_NORMAL_Tmp
  → sp_Run_SO_HIS_FULL (or equivalent)
  → FC_{Division}_SO_HIS_FINAL
  → fnc_FC_SO_HIS_FINAL(Division)
  → V_FC_FM_Original_{Division}
```

**Update Frequency:** Weekly

**Editable:** ❌ No (read-only historical)

**Example:**
```
Current Year: 2025
Y-2 = 2023

[Y-2 (u) M6] = June 2023 Sell-Out units
```

**Usage:**
- Year-over-year trend analysis
- Seasonality patterns
- Long-term growth calculations

---

### 1.2. [(Value)_Y-2 (u) M1-M12] - Historical SO Value

**Data Type:** Decimal (VND)

**Source:** Optimus SO data (Value = Unit × Price)

**Calculation:**
```
Value = Unit × Unit_Price

Where Unit_Price from:
- Optimus SO file (actual transaction prices)
- Or calculated from Revenue / Quantity
```

**Example:**
```
[Y-2 (u) M6] = 10000 units
Unit Price = 250,000 VND
[(Value)_Y-2 (u) M6] = 10000 × 250,000 = 2,500,000,000 VND
```

---

### 1.3. [Y-1 (u) M1-M12] - Historical SO (Last Year)

**Full Name:** Year Minus 1, Unit, Month 1-12

Same structure as Y-2, but for last year.

**Example:**
```
Current Year: 2025
Y-1 = 2024

[Y-1 (u) M6] = June 2024 Sell-Out units
```

---

### 1.4. [Y0 (u) M1-Mcurrent] - Historical SO (Current Year, Past Months)

**Full Name:** Year 0 (Current), Unit, Month 1 to Current Month

**Mixed Column:** Y0 contains both historical (past) and forecast (future)

```
If Month <= Current Month:
   → Historical data (from Optimus SO)
   
If Month > Current Month:
   → Forecast data (from FM + User input)
```

**Example (Current month = March 2025):**
```
[Y0 (u) M1] = Jan 2025 → Historical ✅
[Y0 (u) M2] = Feb 2025 → Historical ✅
[Y0 (u) M3] = Mar 2025 → Historical (partial) + Forecast (rest of month)
[Y0 (u) M4] = Apr 2025 → Forecast ✅
...
[Y0 (u) M12] = Dec 2025 → Forecast ✅
```

---

## 2. Forecast Columns

### 2.1. [Y0 (u) M*] - Forecast (Future Months of Current Year)

**Data Type:** Integer (units)

**Source:**
- FM file (primary)
- FM Non-Modeling (LLD only)
- User edits in WF

**Procedure Chain:**
```
sp_add_FC_FM_Tmp
  → [LLD only: sp_add_FC_FM_Non_Modeling_Tmp]
  → sp_FC_FM_Original_NEW_FINAL
  → FC_FM_Original_{Division}
  → V_FC_FM_Original_{Division}
```

**Update Frequency:**
- Monthly (FM import)
- Daily (user edits)

**Editable:** ✅ Yes (for future months, by time series)

**Time Series Split:**

For each Sub_Group + Channel, forecast split into:
- 1. Baseline Qty ← Editable
- 2. Promo Qty ← Editable
- 4. Launch Qty ← Editable
- 5. FOC Qty ← Editable
- 6. Total Qty ← Calculated (1+2+4+5)

**Example:**
```
Product: L'Oréal UV Perfect
Channel: OFFLINE
[Y0 (u) M6] = June 2025

Time Series Breakdown:
- 1. Baseline Qty: 10000
- 2. Promo Qty: 3000
- 4. Launch Qty: 0
- 5. FOC Qty: 2000
- 6. Total Qty: 15000 ← Sum
```

---

### 2.2. [Y+1 (u) M1-M12] - Forecast (Next Year)

**Full Name:** Year Plus 1, Unit, Month 1-12

Same structure and source as Y0 forecast, but for next year.

**Example:**
```
Current Year: 2025
Y+1 = 2026

[Y+1 (u) M3] = March 2026 forecast
```

**Usage:**
- Long-term planning
- Budget preparation (Y+1 often aligns with BP cycle)
- Capacity planning

---

### 2.3. [(Value)_Y0/Y+1 (u) M*] - Forecast Value

**Data Type:** Decimal (VND)

**Source:** **Calculated** (not direct input)

**Procedure:** `sp_tag_update_wf_calculation_fc_unit_Refresh_All`

**Formula:**
```
Forecast Value = Forecast Unit × Standard Price

Where Standard Price from:
- Product master data (RSP or Standard Cost)
- Price list table (FC_Price_List)
- Latest actual price from historical data
```

**Calculation Steps:**
```sql
-- Procedure: sp_tag_update_wf_fc_02_years_Timeseries_value

UPDATE FC_FM_Original_{Division}
SET [(Value)_Y0 (u) M3] =
    [Y0 (u) M3] * ISNULL(price.Standard_Price, 0)
FROM FC_FM_Original_{Division} wf
LEFT JOIN FC_Price_List price
    ON wf.[Ref. Code] = price.Spectrum
WHERE wf.[Time series] IN ('1. Baseline Qty', '2. Promo Qty', '4. Launch Qty', '5. FOC Qty', '6. Total Qty')
```

**Editable:** ❌ No (auto-calculated from unit × price)

**Update Triggers:**
- After unit forecast updates
- After price list updates
- On demand via refresh procedures

---

## 3. Stock Fields

### 3.1. [SOH] - Stock on Hand

**Full Name:** Stock on Hand (Current Physical Stock)

**Data Type:** Integer (units)

**Source:** SAP ZMR32 Report (daily)

**Procedure Chain:**
```
SAP ZMR32 Export (daily)
  → sp_add_SOH_Tmp (import)
  → sp_Create_SOH_FINAL (aggregate)
  → V_SOH_RAW (raw view)
  → FC_SOH_FINAL (aggregated table)
  → sp_tag_update_wf_soh (update WF)
  → FC_FM_Original_{Division}.[SOH]
```

**SQL Logic:**
```sql
-- Import from SAP
INSERT INTO FC_SOH_RAW
SELECT
    Material,
    Plant,
    Storage_Location,
    Batch,
    Stock_Quantity,
    Stock_Value,
    Stock_Type
FROM SAP_ZMR32_Export
WHERE Stock_Type IN ('UNRESTRICTED', 'QUALITY_INSPECTION')
  AND Stock_Type NOT IN ('BLOCKED', 'RETURNS', 'IN_TRANSIT')

-- Aggregate to Sub_Group
INSERT INTO FC_SOH_FINAL
SELECT
    sm.Sub_Group,
    SOH_Total = SUM(soh.Stock_Quantity)
FROM FC_SOH_RAW soh
INNER JOIN fnc_SubGroupMaster(@Division, 'full') sm
    ON soh.Material = sm.Spectrum
WHERE sm.Status = 'Active'
GROUP BY sm.Sub_Group

-- Update WF
UPDATE wf
SET wf.[SOH] = soh.SOH_Total
FROM FC_FM_Original_{Division} wf
INNER JOIN FC_SOH_FINAL soh
    ON wf.[SUB GROUP/ Brand] = soh.Sub_Group
WHERE wf.[Time series] = '6. Total Qty'  -- Only Total row
  AND wf.Channel IN ('O+O', 'OFFLINE+ONLINE')  -- Aggregate channel
```

**Filters:**
- ✅ Stock_Type = 'UNRESTRICTED' or 'QUALITY_INSPECTION'
- ❌ Exclude: 'BLOCKED', 'RETURNS', 'IN_TRANSIT'

**Update Frequency:** Daily (morning)

**Editable:** ❌ No (from SAP)

**Usage:**
- Stock coverage calculation (SOH / AVE_P3M)
- SLOB risk assessment
- Supply planning input (SIT calculation)

**Example:**
```
Sub Group: LOP Revitalift Cream

Material Breakdown:
- LOP Revitalift 50ml: 10000 units
- LOP Revitalift 30ml: 5000 units
- LOP Revitalift 100ml: 3000 units

[SOH] = 18000 units (total for Sub_Group)
```

---

### 3.2. [GIT M0-M3] - Goods in Transit

**Full Name:** Goods in Transit, Month 0 to Month 3

**Data Type:** Integer (units)

**Source:** SAP GIT Report (daily)

**Columns:**
- `[GIT M0]` = Arriving current month
- `[GIT M1]` = Arriving next month (M+1)
- `[GIT M2]` = Arriving in 2 months (M+2)
- `[GIT M3]` = Arriving in 3 months (M+3)
- `[Total GIT]` = Sum of M0+M1+M2+M3

**Procedure Chain:**
```
SAP GIT Report Export (daily)
  → sp_add_FC_GIT_Tmp (import)
  → sp_FC_GIT_New (process & aggregate)
  → FC_GIT (table)
  → sp_tag_update_wf_git (update WF)
  → FC_FM_Original_{Division}.[GIT M*]
```

**SQL Logic:**
```sql
-- Process GIT by arrival month
INSERT INTO FC_GIT
SELECT
    Material,
    Division,
    GIT_M0 = SUM(CASE WHEN DATEDIFF(MONTH, GETDATE(), Arrival_Date) = 0 THEN Quantity ELSE 0 END),
    GIT_M1 = SUM(CASE WHEN DATEDIFF(MONTH, GETDATE(), Arrival_Date) = 1 THEN Quantity ELSE 0 END),
    GIT_M2 = SUM(CASE WHEN DATEDIFF(MONTH, GETDATE(), Arrival_Date) = 2 THEN Quantity ELSE 0 END),
    GIT_M3 = SUM(CASE WHEN DATEDIFF(MONTH, GETDATE(), Arrival_Date) = 3 THEN Quantity ELSE 0 END),
    Total_GIT = SUM(Quantity)
FROM FC_GIT_Import
WHERE Arrival_Date >= GETDATE()
  AND Arrival_Date <= DATEADD(MONTH, 3, GETDATE())
GROUP BY Material, Division
```

**Update Frequency:** Daily

**Editable:** ❌ No (from SAP)

**Usage:**
- SIT calculation (SOH - GIT_M0)
- Supply visibility (incoming goods)
- Stock projection (future availability)

**Example:**
```
Current Date: 2025-03-15

Product: L'Oréal UV Perfect
[GIT M0] = 2000 (arriving Mar 15-31)
[GIT M1] = 1500 (arriving April)
[GIT M2] = 1000 (arriving May)
[GIT M3] = 500 (arriving June)
[Total GIT] = 5000 units
```

---

### 3.3. [SIT] - Stock in Transit

**Full Name:** Stock in Transit (Available Stock after GIT deduction)

**Data Type:** Integer (units)

**Source:** **Calculated**

**Formula:**
```
SIT = SOH - GIT_M0

Interpretation:
- SOH: Current physical stock
- GIT_M0: Goods arriving this month (already in pipeline)
- SIT: "True available" stock (after deducting confirmed incoming)
```

**Procedure:** `sp_tag_update_wf_sit_NEW`

```sql
UPDATE wf
SET wf.[SIT] = 
    ISNULL(soh.[SOH], 0) - 
    ISNULL(git.[GIT M0], 0)
FROM FC_FM_Original_{Division} wf
LEFT JOIN FC_SOH_FINAL soh
    ON wf.[SUB GROUP/ Brand] = soh.Sub_Group
LEFT JOIN FC_GIT git
    ON wf.[SUB GROUP/ Brand] = git.Sub_Group
WHERE wf.[Time series] = '6. Total Qty'
  AND wf.Channel IN ('O+O', 'OFFLINE+ONLINE')
```

**Update Frequency:** Daily

**Editable:** ❌ No (calculated)

**Can Be Negative:** Yes (if GIT_M0 > SOH, means more coming than current stock)

**Example:**
```
[SOH] = 18000
[GIT M0] = 2000
[SIT] = 18000 - 2000 = 16000

Interpretation: 16000 units "truly available" (after accounting for incoming 2000)
```

---

### 3.4. [SIT Day] - SIT in Days Coverage

**Full Name:** Stock in Transit coverage in days

**Data Type:** Decimal (days)

**Source:** **Calculated**

**Formula:**
```
SIT Day = SIT / AVE_P3M × 30

Where:
- SIT: Stock in Transit (units)
- AVE_P3M: Average Previous 3 Months sales (units/month)
- 30: Days per month (approximation)
```

**Procedure:** `sp_tag_update_wf_sit_day`

```sql
UPDATE wf
SET wf.[SIT Day] = 
    CASE 
        WHEN ISNULL(wf.[AVE P3M Y0], 0) > 0 THEN
            wf.[SIT] / wf.[AVE P3M Y0] * 30
        ELSE
            999  -- Infinite coverage (no sales)
    END
FROM FC_FM_Original_{Division} wf
```

**Update Frequency:** Daily

**Editable:** ❌ No (calculated)

**Usage:**
- Stock coverage in days (more intuitive than units)
- Supply planning (how many days of stock left)
- Reorder point calculations

**Example:**
```
[SIT] = 16000 units
[AVE P3M Y0] = 8000 units/month
[SIT Day] = 16000 / 8000 × 30 = 60 days

Interpretation: Current stock covers 60 days of average sales
```

---

## 4. Risk Fields

### 4.1. [SLOB] - Slow-moving/Obsolete Risk

**Full Name:** Slow-moving and Obsolete Stock Risk Level

**Data Type:** Text ('HIGH', 'MEDIUM', 'LOW', 'DEAD_STOCK')

**Source:** **Calculated**

**Formula:**
```
Step 1: Calculate Stock Coverage
Stock_Coverage_Months = SOH / AVE_P3M

Step 2: Determine Risk Level
IF AVE_P3M = 0 AND SOH > 0 THEN
    SLOB = 'DEAD_STOCK'  (No sales, but stock exists)
ELSE IF Stock_Coverage > 3 THEN
    SLOB = 'HIGH'  (Over 3 months of stock)
ELSE IF Stock_Coverage > 2 THEN
    SLOB = 'MEDIUM'  (2-3 months of stock)
ELSE
    SLOB = 'LOW'  (Under 2 months)
END
```

**Procedure:** `sp_tag_update_slob_wf`

```sql
UPDATE wf
SET wf.[SLOB] =
    CASE
        WHEN ISNULL(wf.[AVE P3M Y0], 0) = 0 AND ISNULL(wf.[SOH], 0) > 0 THEN 
            'DEAD_STOCK'
        WHEN ISNULL(wf.[SOH], 0) / NULLIF(wf.[AVE P3M Y0], 0) > 3 THEN 
            'HIGH'
        WHEN ISNULL(wf.[SOH], 0) / NULLIF(wf.[AVE P3M Y0], 0) > 2 THEN 
            'MEDIUM'
        ELSE 
            'LOW'
    END
FROM FC_FM_Original_{Division} wf
WHERE wf.[Time series] = '6. Total Qty'
```

**Update Frequency:** Daily (after SOH, AVE_P3M updates)

**Editable:** ❌ No (calculated)

**Usage:**
- Inventory risk management
- Identify slow-moving SKUs
- Markdown/clearance planning
- Production adjustment decisions

**Example:**
```
Scenario 1: Normal stock
[SOH] = 15000
[AVE P3M Y0] = 7500 units/month
Stock Coverage = 15000/7500 = 2 months
[SLOB] = 'LOW' ✅ (under 3 months)

Scenario 2: Overstocked
[SOH] = 30000
[AVE P3M Y0] = 7500
Stock Coverage = 30000/7500 = 4 months
[SLOB] = 'HIGH' ⚠️ (over 3 months)
Action: Reduce orders, run promotions

Scenario 3: Dead stock
[SOH] = 5000
[AVE P3M Y0] = 0 (no sales last 3 months)
[SLOB] = 'DEAD_STOCK' 🚨
Action: Markdown, clearance, or write-off
```

---

### 4.2. [Risk (u) M0-M3] & [Risk (val) M0-M3] - Forecast Risk

**Full Name:** Forecast Risk for next 3 months (Unit and Value)

**Data Type:** Integer (units) or Decimal (VND)

**Source:** **Calculated**

**Purpose:** Identify risky forecast changes (too high growth or decline vs historical)

**Formula:**
```
Risk = Forecast - Historical_Baseline

Where:
- Forecast: Next 3 months forecast average
- Historical_Baseline: Previous 3 months actual average

Risk Flag:
IF Forecast < Historical × 0.7 THEN 'HIGH_DECLINE' (down >30%)
IF Forecast > Historical × 1.3 THEN 'HIGH_GROWTH' (up >30%)
ELSE 'NORMAL'
```

**Procedure:** `sp_fc_fm_risk_3M`

```sql
-- Calculate for M0 (current month)
UPDATE wf
SET wf.[Risk (u) M0] =
    wf.[Y0 (u) M_current] -  -- Forecast
    wf.[AVE P3M Y0]  -- Historical baseline

-- Flag high risk
UPDATE wf
SET wf.Risk_Flag_M0 =
    CASE
        WHEN wf.[Y0 (u) M_current] < wf.[AVE P3M Y0] * 0.7 THEN 'HIGH_DECLINE'
        WHEN wf.[Y0 (u) M_current] > wf.[AVE P3M Y0] * 1.3 THEN 'HIGH_GROWTH'
        ELSE 'NORMAL'
    END
```

**Update Frequency:** After forecast updates

**Editable:** ❌ No (calculated)

**Usage:**
- Forecast validation (flag unrealistic forecasts)
- Risk review meetings
- Demand planner review queue
- Capacity planning alerts

**Example:**
```
[AVE P3M Y0] = 10000 units/month (historical average)

Scenario 1: High growth forecast
[Y0 (u) M_current] = 15000 (current month forecast)
[Risk (u) M0] = 15000 - 10000 = +5000
Risk Flag = 'HIGH_GROWTH' (+50% vs historical)
Review: Why such high forecast? Campaign? Launch?

Scenario 2: High decline forecast
[Y0 (u) M_current] = 6000
[Risk (u) M0] = 6000 - 10000 = -4000
Risk Flag = 'HIGH_DECLINE' (-40% vs historical)
Review: Why low forecast? Competition? Discontinuation?

Scenario 3: Normal variance
[Y0 (u) M_current] = 11000
[Risk (u) M0] = 11000 - 10000 = +1000
Risk Flag = 'NORMAL' (+10% is acceptable)
```

---

## 5. Average Fields

### 5.1. [AVE P3M Y-1] - Average Previous 3 Months (Last Year)

**Full Name:** Average of Previous 3 Months, Year Minus 1

**Data Type:** Decimal (units/month)

**Source:** **Calculated** from historical SO

**Formula:**
```
AVE P3M Y-1 = Average of last 3 completed months of Y-1

Example (Current = Mar 2025):
Y-1 = 2024
Last 3 months of 2024: Oct, Nov, Dec

AVE P3M Y-1 = ([Y-1 (u) M10] + [Y-1 (u) M11] + [Y-1 (u) M12]) / 3
```

**Procedure:** `sp_tag_Update_WF_AVG_HIS_3M_Y_MINUS_1_SI_unit`

**Update Frequency:** Monthly (when new historical month completes)

**Editable:** ❌ No (calculated from historical)

**Usage:**
- Year-over-year growth comparison
- Seasonality analysis
- Budget planning baseline

---

### 5.2. [AVE P3M Y0] - Average Previous 3 Months (Current Year)

**Full Name:** Average of Previous 3 Months, Year 0 (Current Year)

**Formula:**
```
AVE P3M Y0 = Average of last 3 completed months (rolling)

Example (Current = Mar 15, 2025):
Last 3 completed months: Dec 2024, Jan 2025, Feb 2025

AVE P3M Y0 = ([Y0 (u) M12_of_Y-1] + [Y0 (u) M1] + [Y0 (u) M2]) / 3

Note: Crosses year boundary (uses Y-1 M12 if needed)
```

**Procedure:** `sp_tag_Update_WF_AVG_HIS_3M_Y0_SI_unit`

**Update Frequency:** Monthly (rolls forward as months complete)

**Editable:** ❌ No (calculated)

**Usage:**
- **SLOB calculation** (Stock Coverage = SOH / AVE_P3M)
- Recent trend analysis
- Forecast baseline comparison

---

### 5.3. [AVE F3M Y-1] & [AVE F3M Y0] - Average Forecast 3 Months

**Full Name:** Average of Forecast next 3 Months

**Formula:**
```
AVE F3M Y0 = Average of next 3 months forecast

Example (Current = Mar 2025):
Next 3 months: Apr, May, Jun

AVE F3M Y0 = ([Y0 (u) M4] + [Y0 (u) M5] + [Y0 (u) M6]) / 3
```

**Update Frequency:** After forecast updates

**Editable:** ❌ No (calculated from forecast)

**Usage:**
- Compare to AVE_P3M (forecast vs historical trend)
- Risk assessment (is forecast realistic?)
- Capacity planning (expected next 3M demand)

---

### 5.4. [%F3M Y0/ P3M Y0] - Growth Percentage

**Full Name:** Forecast 3M vs Previous 3M Growth %

**Formula:**
```
%F3M Y0/ P3M Y0 = (AVE F3M Y0 / AVE P3M Y0 - 1) × 100%

Example:
AVE P3M Y0 = 10000 (historical average)
AVE F3M Y0 = 12000 (forecast average)
%F3M Y0/ P3M Y0 = (12000/10000 - 1) × 100% = +20%
```

**Procedure:** `sp_fc_fm_risk_3M`

**Usage:**
- Quick growth assessment
- Forecast reasonableness check
- Risk flagging (>±30% = review needed)

**Example:**
```
Scenario 1: Growth
AVE P3M = 10000, AVE F3M = 13000
Growth % = +30% → Flag for review

Scenario 2: Decline
AVE P3M = 10000, AVE F3M = 7000
Growth % = -30% → Flag for review

Scenario 3: Stable
AVE P3M = 10000, AVE F3M = 10500
Growth % = +5% → Normal
```

---

## 6. Budget Fields

### 6.1. [B_Y0_M*] & [B_Y+1_M*] - Budget Unit

**Full Name:** Budget (BP), Year 0/+1, Month 1-12

**Data Type:** Integer (units)

**Source:** Finance Budget Planning (BP) file

**Procedure Chain:**
```
Finance BP File (annual)
  → sp_add_FC_Budget (import)
  → FC_Budget_Master (table)
  → sp_tag_gen_budget_budget_New (process)
  → sp_tag_update_wf_budget_unit (update WF)
  → FC_FM_Original_{Division}.[B_Y*_M*]
```

**Update Frequency:** Annually (before BP cycle, typically Oct-Nov for next year)

**Editable:** ❌ No (from Finance, read-only for Demand Planning)

**Usage:**
- Budget vs Forecast gap analysis
- Finance alignment
- Performance tracking (Actual vs Budget)

---

### 6.2. [(Value)_B_Y0_M*] - Budget Value

**Formula:**
```
Budget Value = Budget Unit × Standard Price
```

**Procedure:** `sp_tag_update_wf_budget_value`

**Editable:** ❌ No (calculated)

---

### 6.3. [PB_Y+1_M*] - Pre-Budget

**Full Name:** Pre-Budget (preliminary budget), Year +1

**Source:** Finance Pre-Budget file (earlier in planning cycle)

**Procedure:** `sp_tag_gen_budget_pre_budget_new`

**Usage:**
- Preliminary planning before final BP
- Early forecast alignment
- Budget draft reviews

---

### 6.4. [T1_Y0_M*], [T2_Y0_M*], [T3_Y0_M*] - Trend

**Full Name:** Trend 1, 2, 3 (rolling forecasts from Finance)

**Source:** Finance Trend files (quarterly rolling forecasts)

**Procedure:** `sp_tag_gen_budget_trend_new`

**Usage:**
- Finance rolling forecast
- Mid-year budget reforecast
- Performance projection updates

**Example:**
```
T1 (Q1 Trend): Feb forecast for full year
T2 (Q2 Trend): May forecast for rest of year
T3 (Q3 Trend): Aug forecast for rest of year
```

---

## 7. Version Fields

### 7.1. [(m-1)_Y0 (u) M*] - Previous Month Version (M-1)

**Full Name:** Month Minus 1 version of forecast

**Data Type:** Integer (units)

**Purpose:** Version control - keep last month's forecast for comparison

**Procedure:** `sp_Backup_WF_before_Save`

```sql
-- Before saving new forecast, backup current as M-1
INSERT INTO FC_FM_Original_{Division}_M1_Backup
SELECT * FROM FC_FM_Original_{Division}

-- In WF view, show M-1 version
UPDATE wf
SET wf.[(m-1)_Y0 (u) M3] = m1.[Y0 (u) M3]
FROM FC_FM_Original_{Division} wf
INNER JOIN FC_FM_Original_{Division}_M1_Backup m1
    ON wf.[SUB GROUP/ Brand] = m1.[SUB GROUP/ Brand]
   AND wf.Channel = m1.Channel
   AND wf.[Time series] = m1.[Time series]
```

**Update Frequency:** Monthly (before new FM cycle)

**Editable:** ❌ No (historical backup)

**Usage:**
- Compare current vs last month forecast
- Track forecast changes
- Audit trail (who changed what)
- Forecast accuracy analysis

**Example:**
```
Current Month: March 2025 FM Cycle

For [Y0 (u) M6] (Jun 2025):
Current forecast: 12000
[(m-1)_Y0 (u) M6]: 11000 (from Feb cycle)

Change: +1000 units (+9%)
Reason: Updated campaign information
```

---

### 7.2. [(m-1)_Y+1 (u) M*] - M-1 Version for Y+1

Same as above, but for next year forecast.

---

## 8. MTD Fields

### 8.1. [MTD SI] - Month-to-Date Sell-In

**Full Name:** Month-to-Date Sell-In (accumulated SI for current month)

**Data Type:** Integer (units)

**Source:** SAP ZV14 (daily, current month only)

**Procedure:** `sp_tag_update_wf_mtd_si_NEW`

```sql
UPDATE wf
SET wf.[MTD SI] = mtd.MTD_Total
FROM FC_FM_Original_{Division} wf
INNER JOIN (
    SELECT
        Sub_Group,
        MTD_Total = SUM(Delivery_Quantity)
    FROM FC_SI_OPTIMUS_NORMAL_{Division}
    WHERE YEAR(Delivery_Date) = YEAR(GETDATE())
      AND MONTH(Delivery_Date) = MONTH(GETDATE())
      AND Delivery_Date <= GETDATE()  ← Up to today
      AND Order_Status = 'C'
    GROUP BY Sub_Group
) mtd ON wf.[SUB GROUP/ Brand] = mtd.Sub_Group
WHERE wf.[Time series] = '6. Total Qty'
```

**Update Frequency:** Daily (accumulates throughout month)

**Editable:** ❌ No (from SAP)

**Usage:**
- In-month tracking (are we on track?)
- Daily sales monitoring
- Month-end forecast adjustment
- Performance alerts

**Example:**
```
Current Date: Mar 15, 2025
Month: March (31 days)
Progress: 15/31 = 48% of month

Product: L'Oréal UV Perfect
[MTD SI] = 4500 units (Jan 1-15)

Monthly Forecast: 10000 units
Expected MTD (linear): 10000 × 48% = 4800 units

Actual: 4500
Status: Slightly behind (-300, -6%)

Action: Monitor closely, may need to adjust forecast
```

---

**Document Version:** 1.0
**Last Updated:** 2025-11-19
**Related:** [MAPPING_MATRIX_OVERVIEW.md](./MAPPING_MATRIX_OVERVIEW.md)
