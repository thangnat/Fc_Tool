# Logic Nghiệp Vụ - Business Logic Flow

## 1. Tổng Quan Business Logic

Hệ thống Forecasting Tool thực hiện các tính toán nghiệp vụ phức tạp để hỗ trợ quyết định về dự báo bán hàng, quản lý tồn kho, và phân tích gap giữa Budget và Forecast.

```
┌─────────────────────────────────────────────────────────────────┐
│                   BUSINESS LOGIC LAYERS                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Layer 1: FORECAST CALCULATION                                  │
│  ├─ Total Qty = Baseline + Promo + Launch + FOC                │
│  ├─ O+O = ONLINE + OFFLINE                                      │
│  └─ BOM Explosion (Bundle → Components)                         │
│                                                                  │
│  Layer 2: STOCK PROJECTION                                      │
│  ├─ Available Stock = SOH - GIT                                 │
│  ├─ Projected Stock = SOH + SI - SO                            │
│  └─ Stock Coverage (months)                                     │
│                                                                  │
│  Layer 3: RISK ASSESSMENT                                       │
│  ├─ SLOB Detection (Slow-moving/Obsolete)                      │
│  ├─ 3-Month Risk (AVE F3M vs AVE P3M)                          │
│  └─ Stock-out Risk                                              │
│                                                                  │
│  Layer 4: BUDGET ANALYSIS                                       │
│  ├─ BP Gap % = (Forecast - Budget) / Budget × 100             │
│  ├─ Variance Analysis (Absolute & Percentage)                  │
│  └─ Trend Comparison (T1, T2, T3)                              │
│                                                                  │
│  Layer 5: PERFORMANCE METRICS                                   │
│  ├─ Forecast Accuracy (M-1 vs Actual)                          │
│  ├─ MTD Performance (Month-to-Date)                            │
│  └─ YTD Performance (Year-to-Date)                             │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. Layer 1: Forecast Calculation

### 2.1. Total Quantity Calculation

**Business Rule:**
```
Total Qty = Baseline Qty + Promo Qty + Launch Qty + FOC Qty
```

**Rationale:**
- **Baseline Qty:** Doanh số thường xuyên (BAU - Business As Usual)
- **Promo Qty:** Doanh số tăng thêm từ hoạt động khuyến mãi
- **Launch Qty:** Doanh số từ sản phẩm mới (3 tháng đầu)
- **FOC Qty:** Hàng tặng kèm (Free of Charge)

**SQL Implementation:**
```sql
-- From sp_tag_update_wf_calculation_fc_unit_Refresh_All
UPDATE wf
SET wf.[Total_Qty] =
    ISNULL(wf.[Baseline_Qty], 0) +
    ISNULL(wf.[Promo_Qty], 0) +
    ISNULL(wf.[Launch_Qty], 0) +
    ISNULL(wf.[FOC_Qty], 0)
FROM WF_Master wf
WHERE wf.Time_Series = '6. Total Qty'
```

**Validation:**
```sql
-- Check Total Qty integrity
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
        WHEN ABS(Total_Qty - (Baseline_Qty + Promo_Qty + Launch_Qty + FOC_Qty)) > 1
        THEN 'ERROR'
        ELSE 'OK'
    END AS Validation_Status
FROM WF_Calculation_View
WHERE Validation_Status = 'ERROR'
```

### 2.2. Channel Aggregation (O+O)

**Business Rule:**
```
O+O (Online + Offline) = ONLINE Qty + OFFLINE Qty
```

**Purpose:**
- Xem tổng forecast cho tất cả channels
- So sánh với Budget (thường Budget là tổng O+O)
- Phân bổ forecast giữa ONLINE và OFFLINE

**SQL Implementation:**
```sql
-- From sp_tag_update_wf_calculation_fc_unit_Refresh_All
INSERT INTO WF_Master (Division, Sub_Group, Channel, Time_Series, Period, Quantity)
SELECT
    Division,
    Sub_Group,
    'O+O' AS Channel,
    Time_Series,
    Period,
    SUM(Quantity) AS OO_Quantity
FROM WF_Master
WHERE Channel IN ('ONLINE', 'OFFLINE')
  AND Division = @Division
  AND FM_KEY = @FM_KEY
GROUP BY Division, Sub_Group, Time_Series, Period
```

**Channel Split Logic:**
```sql
-- Calculate channel split %
WITH Channel_Split AS (
    SELECT
        Sub_Group,
        Channel,
        Period,
        SUM(Quantity) AS Channel_Qty,
        SUM(SUM(Quantity)) OVER (PARTITION BY Sub_Group, Period) AS Total_Qty,
        CAST(SUM(Quantity) AS FLOAT) /
            NULLIF(SUM(SUM(Quantity)) OVER (PARTITION BY Sub_Group, Period), 0) AS Split_Pct
    FROM WF_Master
    WHERE Channel IN ('ONLINE', 'OFFLINE')
      AND Time_Series = '6. Total Qty'
    GROUP BY Sub_Group, Channel, Period
)
SELECT
    Sub_Group,
    Period,
    MAX(CASE WHEN Channel = 'ONLINE' THEN Split_Pct ELSE 0 END) AS Online_Pct,
    MAX(CASE WHEN Channel = 'OFFLINE' THEN Split_Pct ELSE 0 END) AS Offline_Pct
FROM Channel_Split
GROUP BY Sub_Group, Period
```

**Example:**
```
Sub Group: LOP Revitalift Cream
Period: Y0_M1

ONLINE:  5000 units
OFFLINE: 8000 units
-----------------------
O+O:    13000 units (auto-calculated)

Channel Split:
ONLINE:  38.5% (5000/13000)
OFFLINE: 61.5% (8000/13000)
```

### 2.3. BOM Explosion Logic

**Business Rule:**
```
When forecasting a Bundle:
1. Forecast the Bundle quantity
2. Explode into Component quantities
3. Component Qty = Bundle Qty × BOM Quantity Per Bundle
4. Add to Component's direct forecast
```

**SQL Implementation:**
```sql
-- From sp_Update_Bom_Header_New
-- Step 1: Get bundle forecasts
WITH Bundle_Forecast AS (
    SELECT
        wf.Spectrum AS Bundle_Spectrum,
        wf.Sub_Group AS Bundle_Sub_Group,
        wf.Channel,
        wf.Time_Series,
        wf.Period,
        wf.Quantity AS Bundle_Qty
    FROM WF_Master wf
    INNER JOIN Spectrum_Master sm ON wf.Spectrum = sm.Spectrum
    WHERE sm.Product_Type = 'Bundle'
      AND wf.Division = @Division
      AND wf.FM_KEY = @FM_KEY
),
-- Step 2: Join with BOM to get components
BOM_Explosion AS (
    SELECT
        bf.Bundle_Spectrum,
        bf.Bundle_Sub_Group,
        bom.Component_Spectrum,
        comp.Sub_Group AS Component_Sub_Group,
        bf.Channel,
        bf.Time_Series,
        bf.Period,
        bf.Bundle_Qty,
        bom.Quantity_Per_Bundle,
        bf.Bundle_Qty * bom.Quantity_Per_Bundle AS Component_Qty
    FROM Bundle_Forecast bf
    INNER JOIN FC_BOM_Header bom ON bf.Bundle_Spectrum = bom.Bundle_Spectrum
    INNER JOIN Spectrum_Master comp ON bom.Component_Spectrum = comp.Spectrum
    WHERE bom.Status = 'ACTIVE'
      AND bf.Period BETWEEN bom.Valid_From AND ISNULL(bom.Valid_To, '9999-12-31')
)
-- Step 3: Insert component forecasts
INSERT INTO WF_Master (Division, Spectrum, Sub_Group, Channel, Time_Series, Period, Quantity, Source)
SELECT
    @Division,
    Component_Spectrum,
    Component_Sub_Group,
    Channel,
    Time_Series,
    Period,
    SUM(Component_Qty),
    'BOM_Explosion'
FROM BOM_Explosion
GROUP BY Component_Spectrum, Component_Sub_Group, Channel, Time_Series, Period

-- Step 4: Update total component forecast (Direct + BOM)
UPDATE wf
SET wf.Quantity = wf.Quantity + ISNULL(bom_exp.BOM_Qty, 0)
FROM WF_Master wf
LEFT JOIN (
    SELECT Component_Sub_Group, Channel, Time_Series, Period, SUM(Component_Qty) AS BOM_Qty
    FROM BOM_Explosion
    GROUP BY Component_Sub_Group, Channel, Time_Series, Period
) bom_exp ON wf.Sub_Group = bom_exp.Component_Sub_Group
         AND wf.Channel = bom_exp.Channel
         AND wf.Time_Series = bom_exp.Time_Series
         AND wf.Period = bom_exp.Period
WHERE wf.Source = 'Direct'
```

**Example:**
```
Bundle: LOP Gift Set 2025
Forecast: 1000 units (ONLINE, Y0_M1)

BOM Configuration:
├─ LOP Revitalift Cream 50ml × 1
├─ LOP Revitalift Serum 30ml × 1
└─ LOP Tote Bag × 1

BOM Explosion Result:
1. LOP Revitalift Cream
   - Direct Forecast: 5000
   - BOM Forecast: 1000
   - Total: 6000 units

2. LOP Revitalift Serum
   - Direct Forecast: 3000
   - BOM Forecast: 1000
   - Total: 4000 units

3. LOP Tote Bag
   - Direct Forecast: 0
   - BOM Forecast: 1000
   - Total: 1000 units
```

### 2.4. Unit Adjustment

**Business Rule:**
```
Adjusted Qty = Base Qty × (1 + Adjustment %)
```

**Purpose:**
- Điều chỉnh forecast theo factors (seasonality, market trends, etc.)
- Apply adjustment % lên base forecast

**SQL Implementation:**
```sql
-- From sp_tag_update_wf_fc_adjust_unit
UPDATE wf
SET wf.Adjusted_Qty = wf.Base_Qty * (1 + ISNULL(adj.Adjustment_Pct, 0) / 100.0)
FROM WF_Master wf
LEFT JOIN FC_Adjustment adj ON wf.Sub_Group = adj.Sub_Group
                            AND wf.Channel = adj.Channel
                            AND wf.Period = adj.Period
WHERE wf.Division = @Division
  AND wf.FM_KEY = @FM_KEY
```

**Example:**
```
Base Forecast: 10000 units
Adjustment %: +15% (seasonal uplift for Tet)
Adjusted Forecast: 10000 × 1.15 = 11500 units
```

---

## 3. Layer 2: Stock Projection

### 3.1. Available Stock Calculation

**Business Rule:**
```
Available Stock = Stock on Hand (SOH) - Goods in Transit (GIT)
```

**Rationale:**
- SOH: Total stock in warehouse
- GIT: Stock đang trên đường (chưa về kho) → phải trừ ra
- Available Stock: Stock thực sự có thể bán

**SQL Implementation:**
```sql
-- Calculate Available Stock
SELECT
    s.Material,
    s.Division,
    SUM(s.SOH_Qty) AS SOH,
    ISNULL(SUM(g.GIT_M0), 0) AS GIT,
    SUM(s.SOH_Qty) - ISNULL(SUM(g.GIT_M0), 0) AS Available_Stock
FROM Stock_ZMR32 s
LEFT JOIN GIT_Data g ON s.Material = g.Material
WHERE s.Division = @Division
GROUP BY s.Material, s.Division
```

### 3.2. Projected Stock

**Business Rule:**
```
Projected Stock (End of Month) = Beginning Stock + Planned SI - Planned SO

Where:
- Beginning Stock = Current SOH + GIT
- Planned SI (Sell-In) = Forecast (this system) or PO from suppliers
- Planned SO (Sell-Out) = Demand forecast
```

**SQL Implementation:**
```sql
-- From sp_tag_update_slob_wf
WITH Stock_Projection AS (
    SELECT
        sm.Sub_Group,
        sm.Spectrum,
        ISNULL(soh.SOH_Qty, 0) AS Beginning_SOH,
        ISNULL(git.GIT_M0, 0) AS GIT,
        ISNULL(soh.SOH_Qty, 0) + ISNULL(git.GIT_M0, 0) AS Beginning_Stock,

        -- Planned SI (từ forecast hoặc PO)
        ISNULL(fc_si.Forecast_SI_Qty, 0) AS Planned_SI,

        -- Planned SO (từ SO forecast)
        ISNULL(fc_so.Forecast_SO_Qty, 0) AS Planned_SO,

        -- Projected end stock
        ISNULL(soh.SOH_Qty, 0) + ISNULL(git.GIT_M0, 0) +
        ISNULL(fc_si.Forecast_SI_Qty, 0) -
        ISNULL(fc_so.Forecast_SO_Qty, 0) AS Projected_End_Stock,

        -- Stock coverage (months)
        CASE
            WHEN ISNULL(fc_so.Forecast_SO_Qty, 0) > 0
            THEN (ISNULL(soh.SOH_Qty, 0) + ISNULL(git.GIT_M0, 0)) /
                 NULLIF(ISNULL(fc_so.Forecast_SO_Qty, 0), 0)
            ELSE 999
        END AS Stock_Coverage_Months

    FROM Spectrum_Master sm
    LEFT JOIN Stock_ZMR32 soh ON sm.Spectrum = soh.Material
    LEFT JOIN GIT_Data git ON sm.Spectrum = git.Material
    LEFT JOIN (
        SELECT Spectrum, SUM(Quantity) AS Forecast_SI_Qty
        FROM WF_Master
        WHERE Time_Series = '6. Total Qty' AND Period = @Current_Period
        GROUP BY Spectrum
    ) fc_si ON sm.Spectrum = fc_si.Spectrum
    LEFT JOIN (
        SELECT Spectrum, SUM(SO_Qty) AS Forecast_SO_Qty
        FROM SO_Forecast
        WHERE Period = @Current_Period
        GROUP BY Spectrum
    ) fc_so ON sm.Spectrum = fc_so.Spectrum
    WHERE sm.Division = @Division
      AND sm.Status = 'ACTIVE'
)
SELECT * FROM Stock_Projection
```

**Example:**
```
Product: LOP Revitalift Cream
Current Month: January 2025

Beginning SOH: 10000 units
GIT M0: 2000 units
Beginning Stock: 12000 units

Planned SI (Forecast): 8000 units
Planned SO (Demand): 10000 units

Projected End Stock = 12000 + 8000 - 10000 = 10000 units

Stock Coverage = 12000 / 10000 = 1.2 months
```

### 3.3. Multi-Month Stock Projection

**Business Rule:**
```
For each month (M0, M1, M2, ...):
Stock_M{n} = Stock_M{n-1} + SI_M{n} - SO_M{n} + GIT_M{n}
```

**SQL Implementation:**
```sql
-- Recursive stock projection for 12 months
WITH RECURSIVE Stock_Projection AS (
    -- Base case: M0 (current month)
    SELECT
        Spectrum,
        0 AS Month_Offset,
        SOH + GIT_M0 AS Stock,
        SI_M0,
        SO_M0,
        SOH + GIT_M0 + SI_M0 - SO_M0 AS Projected_Stock
    FROM Stock_Base

    UNION ALL

    -- Recursive case: M1, M2, ...
    SELECT
        sp.Spectrum,
        sp.Month_Offset + 1,
        sp.Projected_Stock AS Stock,
        fc.SI_Qty,
        fc.SO_Qty,
        sp.Projected_Stock + fc.SI_Qty - fc.SO_Qty AS Projected_Stock
    FROM Stock_Projection sp
    INNER JOIN Forecast_Data fc ON sp.Spectrum = fc.Spectrum
                                AND fc.Month_Offset = sp.Month_Offset + 1
    WHERE sp.Month_Offset < 12
)
SELECT * FROM Stock_Projection
ORDER BY Spectrum, Month_Offset
```

**Example Output:**
```
Product: LOP Revitalift Cream

Month | Beginning | SI    | SO    | Projected End | Coverage
------|-----------|-------|-------|---------------|----------
M0    | 12000     | 8000  | 10000 | 10000         | 1.2
M1    | 10000     | 8000  | 11000 | 7000          | 0.9
M2    | 7000      | 10000 | 12000 | 5000          | 0.6
M3    | 5000      | 12000 | 13000 | 4000          | 0.4 ⚠️ LOW
```

---

## 4. Layer 3: Risk Assessment

### 4.1. SLOB Detection (Slow-moving/Obsolete)

**Business Rule:**
```
SLOB Risk Level:
- HIGH: Stock Coverage > 3 months
- MEDIUM: Stock Coverage > 2 months
- LOW: Stock Coverage <= 2 months

Where:
Stock Coverage = Current Stock / Average Monthly SO (last 3 months)
```

**SQL Implementation:**
```sql
-- From sp_tag_update_slob_wf
WITH SLOB_Analysis AS (
    SELECT
        sm.Spectrum,
        sm.Sub_Group,
        sm.Division,

        -- Current stock
        ISNULL(soh.SOH_Qty, 0) AS Current_SOH,

        -- Average SO last 3 months
        AVG(so.SO_Qty) AS AVE_P3M_SO,

        -- Stock coverage
        CASE
            WHEN AVG(so.SO_Qty) > 0
            THEN ISNULL(soh.SOH_Qty, 0) / NULLIF(AVG(so.SO_Qty), 0)
            ELSE 999
        END AS Stock_Coverage_Months,

        -- SLOB risk level
        CASE
            WHEN AVG(so.SO_Qty) = 0 AND ISNULL(soh.SOH_Qty, 0) > 0 THEN 'DEAD_STOCK'
            WHEN ISNULL(soh.SOH_Qty, 0) / NULLIF(AVG(so.SO_Qty), 0) > 3 THEN 'HIGH'
            WHEN ISNULL(soh.SOH_Qty, 0) / NULLIF(AVG(so.SO_Qty), 0) > 2 THEN 'MEDIUM'
            ELSE 'LOW'
        END AS SLOB_Risk

    FROM Spectrum_Master sm
    LEFT JOIN Stock_ZMR32 soh ON sm.Spectrum = soh.Material
    LEFT JOIN (
        SELECT
            Material,
            SO_Qty,
            ROW_NUMBER() OVER (PARTITION BY Material ORDER BY Month DESC) AS rn
        FROM Historical_SO
        WHERE Month >= DATEADD(MONTH, -3, GETDATE())
    ) so ON sm.Spectrum = so.Material AND so.rn <= 3
    WHERE sm.Division = @Division
      AND sm.Status = 'ACTIVE'
    GROUP BY sm.Spectrum, sm.Sub_Group, sm.Division, soh.SOH_Qty
)
-- Update WF with SLOB flag
UPDATE wf
SET wf.SLOB_Risk = s.SLOB_Risk,
    wf.Stock_Coverage = s.Stock_Coverage_Months
FROM WF_Master wf
INNER JOIN SLOB_Analysis s ON wf.Spectrum = s.Spectrum
WHERE wf.Division = @Division
  AND wf.FM_KEY = @FM_KEY
```

**SLOB Actions:**

| Risk Level | Stock Coverage | Action |
|------------|----------------|--------|
| **DEAD_STOCK** | No sales last 3M | Liquidate, donate, or destroy |
| **HIGH** | > 3 months | Stop ordering, run promos to clear |
| **MEDIUM** | 2-3 months | Reduce order, monitor closely |
| **LOW** | < 2 months | Normal operation |

**Example:**
```
Product: LOP Old Product Line
Current Stock: 15000 units
AVE P3M SO: 2000 units/month

Stock Coverage = 15000 / 2000 = 7.5 months
SLOB Risk: HIGH ⚠️

Recommended Action:
- Stop new orders
- Run clearance promo (e.g., 30% off)
- Target: Clear in 3 months
```

### 4.2. 3-Month Risk Assessment

**Business Rule:**
```
3M Risk Assessment:
Compare Forecast next 3 months (AVE F3M) vs Historical last 3 months (AVE P3M)

Risk Level:
- HIGH: AVE F3M < AVE P3M × 0.7 (forecast down >30%)
- MEDIUM: AVE F3M between AVE P3M × 0.7 and AVE P3M × 1.3
- LOW: AVE F3M > AVE P3M × 1.3 (forecast up >30%)

Purpose: Detect risky forecast changes
```

**SQL Implementation:**
```sql
-- From sp_fc_fm_risk_3M
WITH Risk_Analysis AS (
    SELECT
        sm.Spectrum,
        sm.Sub_Group,
        sm.Division,

        -- Average Previous 3 Months (actual)
        AVG(his.SO_Qty) AS AVE_P3M,

        -- Average Forecast 3 Months (forecast)
        AVG(fc.Forecast_Qty) AS AVE_F3M,

        -- Variance
        AVG(fc.Forecast_Qty) - AVG(his.SO_Qty) AS Variance,

        -- Variance %
        CASE
            WHEN AVG(his.SO_Qty) > 0
            THEN (AVG(fc.Forecast_Qty) - AVG(his.SO_Qty)) / NULLIF(AVG(his.SO_Qty), 0) * 100
            ELSE NULL
        END AS Variance_Pct,

        -- Risk Level
        CASE
            WHEN AVG(fc.Forecast_Qty) < AVG(his.SO_Qty) * 0.7 THEN 'HIGH_DECLINE'
            WHEN AVG(fc.Forecast_Qty) > AVG(his.SO_Qty) * 1.3 THEN 'HIGH_GROWTH'
            ELSE 'NORMAL'
        END AS Risk_Level

    FROM Spectrum_Master sm
    LEFT JOIN (
        SELECT Material, AVG(SO_Qty) AS SO_Qty
        FROM Historical_SO
        WHERE Month >= DATEADD(MONTH, -3, GETDATE())
        GROUP BY Material
    ) his ON sm.Spectrum = his.Material
    LEFT JOIN (
        SELECT Spectrum, AVG(Quantity) AS Forecast_Qty
        FROM WF_Master
        WHERE Period IN (@M1, @M2, @M3)  -- Next 3 months
          AND Time_Series = '6. Total Qty'
        GROUP BY Spectrum
    ) fc ON sm.Spectrum = fc.Spectrum
    WHERE sm.Division = @Division
      AND sm.Status = 'ACTIVE'
    GROUP BY sm.Spectrum, sm.Sub_Group, sm.Division
)
-- Flag high risk items
SELECT *
FROM Risk_Analysis
WHERE Risk_Level IN ('HIGH_DECLINE', 'HIGH_GROWTH')
ORDER BY ABS(Variance_Pct) DESC
```

**Example:**
```
Product: LOP Revitalift Cream

AVE P3M (Oct-Dec 2024): 10000 units/month
AVE F3M (Jan-Mar 2025): 6000 units/month

Variance: 6000 - 10000 = -4000 units
Variance %: -40%
Risk Level: HIGH_DECLINE ⚠️

Reason to investigate:
- Market shrinking?
- Competitor impact?
- Forecast too conservative?
- Actual historical data issue?
```

### 4.3. Stock-out Risk

**Business Rule:**
```
Stock-out Risk:
If Projected Stock < Safety Stock for any month in next 3 months → At Risk

Where:
Safety Stock = Average SO × Lead Time (in months)
Lead Time = Typical time from order to delivery (e.g., 1-2 months)
```

**SQL Implementation:**
```sql
-- Calculate stock-out risk
WITH Stockout_Risk AS (
    SELECT
        sp.Spectrum,
        sp.Sub_Group,
        sp.Month_Offset,
        sp.Projected_Stock,

        -- Safety stock = AVE SO × Lead time
        AVG(so.SO_Qty) * @Lead_Time_Months AS Safety_Stock,

        -- Stock-out risk
        CASE
            WHEN sp.Projected_Stock < AVG(so.SO_Qty) * @Lead_Time_Months THEN 'AT_RISK'
            ELSE 'OK'
        END AS Stockout_Risk

    FROM Stock_Projection sp
    LEFT JOIN Historical_SO so ON sp.Spectrum = so.Material
    WHERE sp.Month_Offset BETWEEN 0 AND 3
    GROUP BY sp.Spectrum, sp.Sub_Group, sp.Month_Offset, sp.Projected_Stock
)
SELECT *
FROM Stockout_Risk
WHERE Stockout_Risk = 'AT_RISK'
ORDER BY Spectrum, Month_Offset
```

**Example:**
```
Product: LOP Revitalift Cream
Lead Time: 2 months
AVE SO: 10000 units/month
Safety Stock: 20000 units

Month | Projected Stock | Safety Stock | Risk
------|-----------------|--------------|------
M0    | 25000           | 20000        | OK
M1    | 22000           | 20000        | OK
M2    | 18000           | 20000        | AT_RISK ⚠️
M3    | 15000           | 20000        | AT_RISK ⚠️

Action: Increase SI forecast for M2 and M3
```

---

## 5. Layer 4: Budget Analysis

### 5.1. Budget Gap Calculation

**Business Rule:**
```
BP Gap % = (Forecast - Budget) / Budget × 100

Where:
- Forecast = Total Qty from WF (6. Total Qty, O+O channel)
- Budget = Budget data from Finance

Interpretation:
- Positive gap: Forecast > Budget (over-performing)
- Negative gap: Forecast < Budget (under-performing)
- Alert threshold: ±20%
```

**SQL Implementation:**
```sql
-- From sp_Check_GAP_NEW
WITH Gap_Analysis AS (
    SELECT
        fc.Division,
        fc.Sub_Group,
        fc.Period,

        -- Budget
        bdg.Budget_Qty,

        -- Forecast (O+O Total)
        fc.Forecast_Qty,

        -- Absolute Gap
        fc.Forecast_Qty - bdg.Budget_Qty AS Gap_Abs,

        -- Gap %
        CASE
            WHEN bdg.Budget_Qty > 0
            THEN (fc.Forecast_Qty - bdg.Budget_Qty) / NULLIF(bdg.Budget_Qty, 0) * 100
            ELSE NULL
        END AS Gap_Pct,

        -- Status
        CASE
            WHEN ABS((fc.Forecast_Qty - bdg.Budget_Qty) / NULLIF(bdg.Budget_Qty, 0) * 100) > 20
            THEN 'ALERT'
            ELSE 'OK'
        END AS Gap_Status

    FROM (
        SELECT Division, Sub_Group, Period, SUM(Quantity) AS Forecast_Qty
        FROM WF_Master
        WHERE Channel = 'O+O'
          AND Time_Series = '6. Total Qty'
        GROUP BY Division, Sub_Group, Period
    ) fc
    INNER JOIN FC_Budget bdg ON fc.Division = bdg.Division
                             AND fc.Sub_Group = bdg.Sub_Group
                             AND fc.Period = bdg.Period
)
SELECT *
FROM Gap_Analysis
WHERE Gap_Status = 'ALERT'
ORDER BY ABS(Gap_Pct) DESC
```

**Gap Threshold Actions:**

| Gap % Range | Status | Action |
|-------------|--------|--------|
| > +20% | Over Budget (Alert) | Verify forecast, check capacity, update budget |
| +10% to +20% | Slightly Over | Monitor, may need budget revision |
| -10% to +10% | On Track | No action needed |
| -20% to -10% | Slightly Under | Review forecast assumptions |
| < -20% | Under Budget (Alert) | Investigate gap, revise forecast or budget |

**Example:**
```
Sub Group: LOP Revitalift Cream
Period: Y0_M1

Budget: 100000 units
Forecast: 85000 units

Gap (Abs): 85000 - 100000 = -15000 units
Gap %: -15%
Status: Slightly Under (Monitor)

Period: Y0_M6

Budget: 120000 units
Forecast: 150000 units

Gap (Abs): 150000 - 120000 = +30000 units
Gap %: +25%
Status: Over Budget ALERT ⚠️

Action Required:
- Verify forecast (promo, launch, market growth?)
- Check production capacity
- Update budget if justified
```

### 5.2. Cumulative Gap Analysis

**Business Rule:**
```
Cumulative Gap (YTD) = SUM(Forecast - Budget) for periods YTD
Cumulative Gap % = SUM(Forecast - Budget) / SUM(Budget) × 100
```

**SQL Implementation:**
```sql
-- Cumulative gap YTD
WITH Monthly_Gap AS (
    SELECT
        Sub_Group,
        Period,
        Forecast_Qty,
        Budget_Qty,
        Forecast_Qty - Budget_Qty AS Monthly_Gap
    FROM Gap_Analysis
    WHERE YEAR(Period) = YEAR(@Current_Date)
      AND Period <= @Current_Date
),
Cumulative_Gap AS (
    SELECT
        Sub_Group,
        Period,
        Monthly_Gap,
        SUM(Monthly_Gap) OVER (PARTITION BY Sub_Group ORDER BY Period) AS Cumulative_Gap,
        SUM(Forecast_Qty) OVER (PARTITION BY Sub_Group ORDER BY Period) AS Cumulative_Forecast,
        SUM(Budget_Qty) OVER (PARTITION BY Sub_Group ORDER BY Period) AS Cumulative_Budget,
        SUM(Forecast_Qty) OVER (PARTITION BY Sub_Group ORDER BY Period) /
            NULLIF(SUM(Budget_Qty) OVER (PARTITION BY Sub_Group ORDER BY Period), 0) * 100 - 100
            AS Cumulative_Gap_Pct
    FROM Monthly_Gap
)
SELECT * FROM Cumulative_Gap
ORDER BY Sub_Group, Period
```

**Example:**
```
Sub Group: LOP Revitalift Cream
YTD: Jan - Jun 2025

Month | Budget  | Forecast | Monthly Gap | Cumulative Gap | Cum Gap %
------|---------|----------|-------------|----------------|----------
Jan   | 100000  | 95000    | -5000       | -5000          | -5.0%
Feb   | 100000  | 98000    | -2000       | -7000          | -3.6%
Mar   | 110000  | 115000   | +5000       | -2000          | -0.9%
Apr   | 120000  | 125000   | +5000       | +3000          | +0.7%
May   | 130000  | 140000   | +10000      | +13000         | +2.4%
Jun   | 140000  | 150000   | +10000      | +23000         | +3.8%

YTD Total:
Budget: 700000
Forecast: 723000
Cumulative Gap: +23000 (+3.8%)
```

### 5.3. Trend Comparison (T1, T2, T3)

**Business Rule:**
```
Compare Forecast vs Multiple Budget Scenarios:
- Budget (B): Official budget from Finance
- Pre-Budget (PB): Draft budget
- Trend 1 (T1): Conservative scenario
- Trend 2 (T2): Base scenario
- Trend 3 (T3): Optimistic scenario
```

**SQL Implementation:**
```sql
-- Multi-scenario comparison
SELECT
    fc.Sub_Group,
    fc.Period,
    fc.Forecast_Qty AS Forecast,
    b.Budget_Qty AS Budget,
    pb.PreBudget_Qty AS Pre_Budget,
    t1.Trend1_Qty AS Trend_1,
    t2.Trend2_Qty AS Trend_2,
    t3.Trend3_Qty AS Trend_3,

    -- Gaps
    fc.Forecast_Qty - b.Budget_Qty AS Gap_vs_Budget,
    fc.Forecast_Qty - t1.Trend1_Qty AS Gap_vs_T1,
    fc.Forecast_Qty - t2.Trend2_Qty AS Gap_vs_T2,
    fc.Forecast_Qty - t3.Trend3_Qty AS Gap_vs_T3,

    -- Closest scenario
    CASE
        WHEN ABS(fc.Forecast_Qty - t1.Trend1_Qty) <
             ABS(fc.Forecast_Qty - t2.Trend2_Qty) AND
             ABS(fc.Forecast_Qty - t1.Trend1_Qty) <
             ABS(fc.Forecast_Qty - t3.Trend3_Qty)
        THEN 'T1 (Conservative)'
        WHEN ABS(fc.Forecast_Qty - t3.Trend3_Qty) <
             ABS(fc.Forecast_Qty - t2.Trend2_Qty)
        THEN 'T3 (Optimistic)'
        ELSE 'T2 (Base)'
    END AS Closest_Scenario

FROM Forecast_Data fc
LEFT JOIN Budget_Data b ON fc.Sub_Group = b.Sub_Group AND fc.Period = b.Period
LEFT JOIN PreBudget_Data pb ON fc.Sub_Group = pb.Sub_Group AND fc.Period = pb.Period
LEFT JOIN Trend1_Data t1 ON fc.Sub_Group = t1.Sub_Group AND fc.Period = t1.Period
LEFT JOIN Trend2_Data t2 ON fc.Sub_Group = t2.Sub_Group AND fc.Period = t2.Period
LEFT JOIN Trend3_Data t3 ON fc.Sub_Group = t3.Sub_Group AND fc.Period = t3.Period
```

**Example:**
```
Sub Group: LOP Revitalift Cream
Period: Y0_M1

Forecast: 125000
Budget: 120000 (+4.2%)
Pre-Budget: 115000 (+8.7%)
T1 (Conservative): 110000 (+13.6%)
T2 (Base): 125000 (0%)
T3 (Optimistic): 140000 (-10.7%)

Closest Scenario: T2 (Base) ✅

Interpretation: Forecast aligns with base scenario
```

---

## 6. Layer 5: Performance Metrics

### 6.1. Forecast Accuracy

**Business Rule:**
```
Forecast Accuracy = 100% - |Actual - Forecast| / Actual × 100

Compare:
- M-1 Forecast (last month's final forecast)
- Actual (actual SO data)

Target Accuracy: >90%
```

**SQL Implementation:**
```sql
-- Forecast accuracy analysis
WITH Accuracy_Analysis AS (
    SELECT
        fc.Sub_Group,
        fc.Period,
        fc.M1_Forecast AS Forecast,  -- M-1 forecast
        act.Actual_SO AS Actual,

        -- Absolute error
        ABS(act.Actual_SO - fc.M1_Forecast) AS Abs_Error,

        -- MAPE (Mean Absolute Percentage Error)
        ABS(act.Actual_SO - fc.M1_Forecast) / NULLIF(act.Actual_SO, 0) * 100 AS MAPE,

        -- Accuracy
        100 - (ABS(act.Actual_SO - fc.M1_Forecast) / NULLIF(act.Actual_SO, 0) * 100) AS Accuracy,

        -- Bias (over/under forecast)
        CASE
            WHEN fc.M1_Forecast > act.Actual_SO THEN 'OVER_FORECAST'
            WHEN fc.M1_Forecast < act.Actual_SO THEN 'UNDER_FORECAST'
            ELSE 'ACCURATE'
        END AS Bias

    FROM (
        SELECT Sub_Group, Period, SUM(Quantity) AS M1_Forecast
        FROM FC_FM_History
        WHERE Source = 'M-1'
          AND Channel = 'O+O'
          AND Time_Series = '6. Total Qty'
        GROUP BY Sub_Group, Period
    ) fc
    INNER JOIN (
        SELECT
            sm.Sub_Group,
            DATEFROMPARTS(YEAR(so.Month), MONTH(so.Month), 1) AS Period,
            SUM(so.SO_Qty) AS Actual_SO
        FROM Historical_SO so
        INNER JOIN Spectrum_Master sm ON so.Material = sm.Spectrum
        GROUP BY sm.Sub_Group, YEAR(so.Month), MONTH(so.Month)
    ) act ON fc.Sub_Group = act.Sub_Group AND fc.Period = act.Period
)
SELECT
    Sub_Group,
    AVG(Accuracy) AS Avg_Accuracy,
    AVG(MAPE) AS Avg_MAPE,
    COUNT(*) AS Periods_Count,
    SUM(CASE WHEN Bias = 'OVER_FORECAST' THEN 1 ELSE 0 END) AS Over_Forecast_Count,
    SUM(CASE WHEN Bias = 'UNDER_FORECAST' THEN 1 ELSE 0 END) AS Under_Forecast_Count
FROM Accuracy_Analysis
GROUP BY Sub_Group
ORDER BY Avg_Accuracy DESC
```

**Example:**
```
Sub Group: LOP Revitalift Cream
Period: Jan 2025

M-1 Forecast (Dec): 100000 units
Actual SO (Jan): 95000 units

Abs Error: 5000 units
MAPE: 5.26%
Accuracy: 94.74% ✅ (>90% target)
Bias: OVER_FORECAST (forecasted too high by 5%)
```

### 6.2. MTD (Month-to-Date) Performance

**Business Rule:**
```
MTD Performance % = MTD Actual / Monthly Forecast × 100

Purpose: Track in-month performance to predict final month result

If Day 15 of month:
Expected MTD % = 15/30 = 50%
If Actual MTD% < 50% → May miss forecast
```

**SQL Implementation:**
```sql
-- MTD Performance tracking
WITH MTD_Performance AS (
    SELECT
        sm.Sub_Group,
        sm.Division,

        -- Monthly forecast
        fc.Monthly_Forecast,

        -- MTD Actual (from latest SO data)
        ISNULL(SUM(so.SO_Qty), 0) AS MTD_Actual,

        -- Days elapsed in month
        DAY(GETDATE()) AS Days_Elapsed,
        DAY(EOMONTH(GETDATE())) AS Days_In_Month,

        -- Expected MTD% based on days elapsed
        CAST(DAY(GETDATE()) AS FLOAT) / DAY(EOMONTH(GETDATE())) * 100 AS Expected_MTD_Pct,

        -- Actual MTD%
        ISNULL(SUM(so.SO_Qty), 0) / NULLIF(fc.Monthly_Forecast, 0) * 100 AS Actual_MTD_Pct,

        -- Performance vs expected
        (ISNULL(SUM(so.SO_Qty), 0) / NULLIF(fc.Monthly_Forecast, 0) * 100) -
        (CAST(DAY(GETDATE()) AS FLOAT) / DAY(EOMONTH(GETDATE())) * 100) AS Performance_vs_Expected

    FROM Spectrum_Master sm
    INNER JOIN (
        SELECT Sub_Group, SUM(Quantity) AS Monthly_Forecast
        FROM WF_Master
        WHERE Period = DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)
          AND Channel = 'O+O'
          AND Time_Series = '6. Total Qty'
        GROUP BY Sub_Group
    ) fc ON sm.Sub_Group = fc.Sub_Group
    LEFT JOIN Historical_SO so ON sm.Spectrum = so.Material
                                AND YEAR(so.Month) = YEAR(GETDATE())
                                AND MONTH(so.Month) = MONTH(GETDATE())
    WHERE sm.Division = @Division
    GROUP BY sm.Sub_Group, sm.Division, fc.Monthly_Forecast
)
SELECT
    *,
    CASE
        WHEN Performance_vs_Expected > 10 THEN 'AHEAD'
        WHEN Performance_vs_Expected < -10 THEN 'BEHIND'
        ELSE 'ON_TRACK'
    END AS Status
FROM MTD_Performance
ORDER BY Performance_vs_Expected
```

**Example:**
```
Sub Group: LOP Revitalift Cream
Period: January 2025
Today: Jan 15 (50% of month elapsed)

Monthly Forecast: 100000 units
MTD Actual: 45000 units

Expected MTD%: 50%
Actual MTD%: 45%
Performance vs Expected: -5%
Status: BEHIND ⚠️

Projected Final: 45000 / 0.5 = 90000 units (90% of forecast)

Action: Investigate shortfall, push sales efforts
```

### 6.3. YTD (Year-to-Date) Performance

**Business Rule:**
```
YTD Performance % = YTD Actual / YTD Forecast × 100

Rolling 12-month performance tracking
```

**SQL Implementation:**
```sql
-- YTD Performance
WITH YTD_Performance AS (
    SELECT
        sm.Sub_Group,
        sm.Division,

        -- YTD Forecast
        SUM(fc.Forecast_Qty) AS YTD_Forecast,

        -- YTD Actual
        SUM(act.Actual_SO) AS YTD_Actual,

        -- YTD Variance
        SUM(act.Actual_SO) - SUM(fc.Forecast_Qty) AS YTD_Variance,

        -- YTD Performance %
        SUM(act.Actual_SO) / NULLIF(SUM(fc.Forecast_Qty), 0) * 100 AS YTD_Performance_Pct

    FROM Spectrum_Master sm
    INNER JOIN (
        SELECT Sub_Group, Period, SUM(Quantity) AS Forecast_Qty
        FROM WF_Master
        WHERE YEAR(Period) = YEAR(GETDATE())
          AND Period <= DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)
          AND Channel = 'O+O'
          AND Time_Series = '6. Total Qty'
        GROUP BY Sub_Group, Period
    ) fc ON sm.Sub_Group = fc.Sub_Group
    LEFT JOIN (
        SELECT
            sm2.Sub_Group,
            DATEFROMPARTS(YEAR(so.Month), MONTH(so.Month), 1) AS Period,
            SUM(so.SO_Qty) AS Actual_SO
        FROM Historical_SO so
        INNER JOIN Spectrum_Master sm2 ON so.Material = sm2.Spectrum
        WHERE YEAR(so.Month) = YEAR(GETDATE())
        GROUP BY sm2.Sub_Group, YEAR(so.Month), MONTH(so.Month)
    ) act ON sm.Sub_Group = act.Sub_Group AND fc.Period = act.Period
    WHERE sm.Division = @Division
    GROUP BY sm.Sub_Group, sm.Division
)
SELECT
    *,
    CASE
        WHEN YTD_Performance_Pct >= 100 THEN 'MEETING_TARGET'
        WHEN YTD_Performance_Pct >= 95 THEN 'CLOSE_TO_TARGET'
        WHEN YTD_Performance_Pct >= 90 THEN 'BELOW_TARGET'
        ELSE 'SIGNIFICANTLY_BELOW'
    END AS Status
FROM YTD_Performance
ORDER BY YTD_Performance_Pct DESC
```

**Example:**
```
Sub Group: LOP Revitalift Cream
YTD: Jan - Jun 2025

YTD Forecast: 700000 units
YTD Actual: 685000 units
YTD Variance: -15000 units
YTD Performance: 97.9%
Status: CLOSE_TO_TARGET ✅

By Month:
Jan: 95000 / 100000 = 95%
Feb: 98000 / 100000 = 98%
Mar: 115000 / 110000 = 105% ✅
Apr: 125000 / 120000 = 104% ✅
May: 140000 / 130000 = 108% ✅
Jun: 112000 / 140000 = 80% ⚠️ (underperformed in June)
```

---

## 7. Business Logic Execution Flow

### 7.1. WF Generation (First Time)

**Process Flow:**
```
1. User clicks "Generate WF" in Excel Add-in
   ↓
2. Validate permissions (sp_Check_User_Permission)
   ↓
3. Load Spectrum Master → Sub_Group list
   ↓
4. Load Historical data (24 months)
   - SO from Historical_SO
   - SI from ZV14
   - Stock from ZMR32
   - GIT from GIT_Data
   ↓
5. Load Budget data
   ↓
6. Load M-1 forecast (if exists)
   ↓
7. Create WF structure (all Sub_Groups × Channels × Time_Series × Periods)
   ↓
8. Calculate baseline metrics (AVE P3M, etc.)
   ↓
9. Apply BOM explosion (if bundles exist)
   ↓
10. Calculate O+O aggregation
    ↓
11. Calculate Budget Gap
    ↓
12. Generate WF Excel sheet
    ↓
13. User edits forecast
    ↓
14. Save back to SQL
    ↓
15. Recalculate all metrics
```

**Key Stored Procedures:**
```sql
EXEC sp_Generate_WF_First_Time
    @Division = 'CPD',
    @FM_KEY = 'CPD_2025_01',
    @UserID = 'demand.planner1'

-- Internally calls:
-- 1. sp_Update_WF_Master (create columns)
-- 2. fnc_FC_FM_Original (load data)
-- 3. sp_tag_update_wf_calculation_fc_unit_Refresh_All (calculations)
-- 4. sp_Update_Bom_Header_New (BOM)
-- 5. sp_Check_GAP_NEW (gap analysis)
-- 6. sp_fc_fm_risk_3M (risk assessment)
-- 7. sp_tag_update_slob_wf (SLOB analysis)
```

### 7.2. WF Refresh (Update)

**Process Flow:**
```
1. User clicks "Refresh WF"
   ↓
2. Import WF from Excel to SQL (cls_function.Import_ExcelFile_New)
   ↓
3. Validate data integrity
   ↓
4. Recalculate Total Qty (sp_tag_update_wf_calculation_fc_unit_Refresh_All)
   ↓
5. Recalculate O+O
   ↓
6. Apply BOM explosion (sp_Update_Bom_Header_New)
   ↓
7. Recalculate Budget Gap (sp_Check_GAP_NEW)
   ↓
8. Recalculate Risk metrics (sp_fc_fm_risk_3M, sp_tag_update_slob_wf)
   ↓
9. Update Excel WF sheet with calculated values
   ↓
10. Show alerts if any issues
```

### 7.3. FM Export

**Process Flow:**
```
1. User clicks "Export to FM"
   ↓
2. Select time series to export (Baseline, Promo, Launch, FOC, Total)
   ↓
3. Select channels (ONLINE, OFFLINE, O+O)
   ↓
4. sp_FC_EXPORT_TO_FM_VIEW generates export view
   - Map Sub_Group → Spectrum
   - Pivot periods to columns
   - Apply filters
   ↓
5. Export to Excel template (FrmExportFMFull.cs)
   - {Division}_FM_{FMKEY}.xlsx
   ↓
6. Save to network share
   ↓
7. SAP team uploads to SAP
```

---

## 8. Calculation Dependencies

**Dependency Chart:**
```
Raw Data (SO, SI, Stock, GIT, Budget)
↓
Product Hierarchy Mapping (Spectrum → Sub_Group)
↓
Historical Aggregation (AVE P3M, etc.)
↓
User Forecast Input (Baseline, Promo, Launch, FOC)
↓
Total Qty Calculation (Sum of time series)
↓
BOM Explosion (Bundle → Components)
↓
Channel Aggregation (O+O = ONLINE + OFFLINE)
↓
Stock Projection (SOH + SI - SO)
↓
Risk Assessment (SLOB, 3M Risk, Stock-out)
↓
Budget Gap Analysis (Forecast vs Budget)
↓
Performance Metrics (Accuracy, MTD, YTD)
↓
Final WF Output + FM Export
```

**Calculation Order Importance:**
- Total Qty MUST be calculated before BOM explosion (uses Total Qty)
- BOM explosion MUST be done before O+O aggregation (BOM creates new rows)
- O+O MUST be calculated before Budget Gap (Budget is O+O level)
- Stock projection requires both Forecast (SI) and Demand (SO)

---

**Document Version:** 1.0
**Last Updated:** 2025-11-18
**Maintained by:** Technical Team
