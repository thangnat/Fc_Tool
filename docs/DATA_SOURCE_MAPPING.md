# Chi Tiết Nguồn Dữ Liệu và Mapping Rules

## Mục Lục
1. [Time Series Mapping](#1-time-series-mapping)
2. [Channel Mapping](#2-channel-mapping)
3. [Period/Column Mapping](#3-periodcolumn-mapping)
4. [Calculation Fields Mapping](#4-calculation-fields-mapping)
5. [Budget Fields Mapping](#5-budget-fields-mapping)
6. [Master Data Fields Mapping](#6-master-data-fields-mapping)
7. [Complete Mapping Matrix](#7-complete-mapping-matrix)

---

## 1. Time Series Mapping

### 1.1. Baseline Qty (1. Baseline Qty)

**Nguồn dữ liệu chính:**

| Source | Table/File | Condition | Priority |
|--------|------------|-----------|----------|
| Historical SO | `Historical_SO` | `Order_Type = 'ZOR'` (Normal Order) | Primary for historical |
| User Input | `WF_Master` (Excel) | Manual forecast input | Primary for forecast |
| M-1 Forecast | `FC_FM_History` | Previous month forecast | Reference only |

**Mapping Logic:**

```sql
-- HISTORICAL DATA (Y-2, Y-1, past Y0)
-- Source: SAP Sell-Out data via Optimus
SELECT
    sm.Sub_Group,
    CASE
        WHEN cm.Channel IN ('GT', 'MT', 'PHARMA', 'SALON') THEN 'OFFLINE'
        WHEN cm.Channel = 'ONLINE' THEN 'ONLINE'
        ELSE 'OFFLINE'
    END AS Channel,
    '1. Baseline Qty' AS Time_Series,
    DATEFROMPARTS(YEAR(so.Month), MONTH(so.Month), 1) AS Period,
    SUM(so.SO_Qty) AS Quantity
FROM Historical_SO so
INNER JOIN Spectrum_Master sm ON so.Material = sm.Spectrum
INNER JOIN Customer_Master cm ON so.Customer_Code = cm.Customer_Code
WHERE so.Order_Type = 'ZOR'  -- Normal orders only
  AND so.Status = 'C'  -- Completed orders only
  AND sm.Division = @Division
  AND sm.Status = 'ACTIVE'
  -- Exclude promotional periods
  AND NOT EXISTS (
      SELECT 1 FROM Promo_Calendar pc
      WHERE pc.Sub_Group = sm.Sub_Group
        AND so.Month BETWEEN pc.Start_Date AND pc.End_Date
  )
GROUP BY sm.Sub_Group,
         CASE WHEN cm.Channel IN ('GT', 'MT', 'PHARMA', 'SALON') THEN 'OFFLINE'
              WHEN cm.Channel = 'ONLINE' THEN 'ONLINE'
              ELSE 'OFFLINE' END,
         YEAR(so.Month), MONTH(so.Month)
```

**Filtering Rules:**

✅ **Include:**
- Order_Type = 'ZOR' (Normal orders)
- Status = 'C' (Completed)
- Active products only
- Non-promotional periods

❌ **Exclude:**
- ZPROMO, ZLAUNCH, ZFOC orders
- Cancelled/returned orders (Status <> 'C')
- Promotional periods (có trong Promo_Calendar)
- Inactive products
- Internal transfers

**Example:**

```
Input (Historical_SO):
Material: 3600542410311
Customer: 1000123 (CO.OP MART → OFFLINE)
Order_Type: ZOR
Month: 2024-01-01
SO_Qty: 1500 units
Status: C

↓ Mapping ↓

Output (WF Historical):
Forecasting Line: LOP Revitalift Cream (from Spectrum_Master)
Channel: OFFLINE
Time series: 1. Baseline Qty
[Y-1 (u) M1]: 1500 (aggregated by Sub_Group + Channel + Month)
```

**Forecast Data (Current & Future):**

```
Source: User manual input in WF Excel sheet

User enters directly:
Forecasting Line: LOP Revitalift Cream
Channel: ONLINE
Time series: 1. Baseline Qty
[Y0 (u) M2]: 5000 (user forecast for Feb 2025)
[Y0 (u) M3]: 5200 (user forecast for Mar 2025)
...
```

---

### 1.2. Promo Qty (2. Promo Qty)

**Nguồn dữ liệu chính:**

| Source | Table/File | Condition | Priority |
|--------|------------|-----------|----------|
| Historical SO | `Historical_SO` | `Order_Type = 'ZPROMO'` OR in Promo_Calendar | Primary for historical |
| Promo Calendar | `Promo_Calendar` | Confirmed promos | Planning reference |
| User Input | `WF_Master` (Excel) | Manual promo forecast | Primary for forecast |

**Mapping Logic:**

```sql
-- HISTORICAL PROMO DATA
-- Method 1: By Order Type
SELECT
    sm.Sub_Group,
    CASE
        WHEN cm.Channel IN ('GT', 'MT', 'PHARMA', 'SALON') THEN 'OFFLINE'
        WHEN cm.Channel = 'ONLINE' THEN 'ONLINE'
        ELSE 'OFFLINE'
    END AS Channel,
    '2. Promo Qty' AS Time_Series,
    DATEFROMPARTS(YEAR(so.Month), MONTH(so.Month), 1) AS Period,
    SUM(so.SO_Qty) AS Quantity
FROM Historical_SO so
INNER JOIN Spectrum_Master sm ON so.Material = sm.Spectrum
INNER JOIN Customer_Master cm ON so.Customer_Code = cm.Customer_Code
WHERE so.Order_Type = 'ZPROMO'  -- Promo orders
  AND so.Status = 'C'
  AND sm.Division = @Division
  AND sm.Status = 'ACTIVE'
GROUP BY sm.Sub_Group,
         CASE WHEN cm.Channel IN ('GT', 'MT', 'PHARMA', 'SALON') THEN 'OFFLINE'
              WHEN cm.Channel = 'ONLINE' THEN 'ONLINE'
              ELSE 'OFFLINE' END,
         YEAR(so.Month), MONTH(so.Month)

UNION ALL

-- Method 2: By Promo Calendar (for ZOR orders during promo period)
SELECT
    sm.Sub_Group,
    CASE
        WHEN cm.Channel IN ('GT', 'MT', 'PHARMA', 'SALON') THEN 'OFFLINE'
        WHEN cm.Channel = 'ONLINE' THEN 'ONLINE'
        ELSE 'OFFLINE'
    END AS Channel,
    '2. Promo Qty' AS Time_Series,
    DATEFROMPARTS(YEAR(so.Month), MONTH(so.Month), 1) AS Period,
    SUM(so.SO_Qty) AS Quantity
FROM Historical_SO so
INNER JOIN Spectrum_Master sm ON so.Material = sm.Spectrum
INNER JOIN Customer_Master cm ON so.Customer_Code = cm.Customer_Code
INNER JOIN Promo_Calendar pc ON sm.Sub_Group = pc.Sub_Group
    AND so.Month BETWEEN pc.Start_Date AND pc.End_Date
WHERE so.Order_Type = 'ZOR'  -- Normal orders but in promo period
  AND so.Status = 'C'
  AND sm.Division = @Division
  AND pc.Status = 'CONFIRMED'
GROUP BY sm.Sub_Group,
         CASE WHEN cm.Channel IN ('GT', 'MT', 'PHARMA', 'SALON') THEN 'OFFLINE'
              WHEN cm.Channel = 'ONLINE' THEN 'ONLINE'
              ELSE 'OFFLINE' END,
         YEAR(so.Month), MONTH(so.Month)
```

**Filtering Rules:**

✅ **Include:**
- Order_Type = 'ZPROMO' (explicit promo orders)
- OR (Order_Type = 'ZOR' AND order date within Promo_Calendar period)
- Status = 'C' (Completed)
- Confirmed promotional campaigns only

❌ **Exclude:**
- Non-promo orders outside promo periods
- Test/trial promos (Status = 'DRAFT')

**Promo Calendar Reference:**

```sql
-- Promo Calendar table structure
CREATE TABLE Promo_Calendar (
    Promo_ID VARCHAR(20) PRIMARY KEY,
    Promo_Name NVARCHAR(200),
    Division VARCHAR(3),
    Sub_Group VARCHAR(100),
    Channel VARCHAR(20),  -- ONLINE, OFFLINE, or NULL (both)
    Start_Date DATE,
    End_Date DATE,
    Promo_Type VARCHAR(50),  -- Trade Promo, Consumer Promo, Flash Sale, etc.
    Expected_Uplift_Pct DECIMAL(5,2),  -- Expected sales uplift %
    Status VARCHAR(20)  -- DRAFT, CONFIRMED, COMPLETED, CANCELLED
)

-- Example records:
INSERT INTO Promo_Calendar VALUES
('PROMO_2025_01_TET', 'Tet Campaign 2025', 'CPD', 'LOP Revitalift Cream', NULL,
 '2025-01-15', '2025-02-15', 'Seasonal Campaign', 30.0, 'CONFIRMED'),
('PROMO_2025_02_FLASH', 'Shopee Flash Sale', 'CPD', 'LOP UV Perfect', 'ONLINE',
 '2025-02-08', '2025-02-10', 'Flash Sale', 50.0, 'CONFIRMED')
```

**Example:**

```
Scenario 1: Explicit Promo Order
Input (Historical_SO):
Material: 3600542410311
Customer: 1000123
Order_Type: ZPROMO  ← Direct promo order
Month: 2024-02-01
SO_Qty: 2000 units

↓ Mapping ↓

Output (WF Historical):
Forecasting Line: LOP Revitalift Cream
Channel: OFFLINE
Time series: 2. Promo Qty
[Y-1 (u) M2]: 2000


Scenario 2: Normal Order During Promo Period
Input (Historical_SO):
Material: 3600542410311
Order_Type: ZOR  ← Normal order
Month: 2024-02-05

Promo_Calendar:
Promo_ID: PROMO_2024_02_TET
Sub_Group: LOP Revitalift Cream
Start_Date: 2024-02-01
End_Date: 2024-02-29
Status: CONFIRMED

↓ Mapping ↓

Since order date (2024-02-05) falls within promo period:
Output (WF Historical):
Time series: 2. Promo Qty
[Y-1 (u) M2]: +sales (added to promo qty)
```

**Forecast Data:**

```
Source: Promo_Calendar + User adjustment

Step 1: System suggests promo forecast based on:
- Historical promo performance
- Expected_Uplift_Pct from Promo_Calendar
- Baseline forecast

Calculation:
Suggested_Promo_Qty = Baseline_Qty × (Expected_Uplift_Pct / 100)

Example:
Baseline Qty (Feb 2025): 10000 units
Expected Uplift: 30%
Suggested Promo Qty: 10000 × 0.3 = 3000 units

Step 2: User reviews and adjusts:
Forecasting Line: LOP Revitalift Cream
Channel: OFFLINE
Time series: 2. Promo Qty
[Y0 (u) M2]: 3500 (user adjusted from 3000 suggestion)
```

---

### 1.3. Launch Qty (4. Launch Qty)

**Nguồn dữ liệu chính:**

| Source | Table/File | Condition | Priority |
|--------|------------|-----------|----------|
| Historical SO | `Historical_SO` | `Order_Type = 'ZLAUNCH'` OR within 3M of Launch_Date | Primary for historical |
| Spectrum Master | `Spectrum_Master` | `Launch_Date` field | Launch period detection |
| User Input | `WF_Master` (Excel) | Manual launch forecast | Primary for forecast |

**Mapping Logic:**

```sql
-- HISTORICAL LAUNCH DATA
-- Method 1: By Order Type
SELECT
    sm.Sub_Group,
    CASE
        WHEN cm.Channel IN ('GT', 'MT', 'PHARMA', 'SALON') THEN 'OFFLINE'
        WHEN cm.Channel = 'ONLINE' THEN 'ONLINE'
        ELSE 'OFFLINE'
    END AS Channel,
    '4. Launch Qty' AS Time_Series,
    DATEFROMPARTS(YEAR(so.Month), MONTH(so.Month), 1) AS Period,
    SUM(so.SO_Qty) AS Quantity
FROM Historical_SO so
INNER JOIN Spectrum_Master sm ON so.Material = sm.Spectrum
INNER JOIN Customer_Master cm ON so.Customer_Code = cm.Customer_Code
WHERE so.Order_Type = 'ZLAUNCH'  -- Launch orders
  AND so.Status = 'C'
  AND sm.Division = @Division
GROUP BY sm.Sub_Group,
         CASE WHEN cm.Channel IN ('GT', 'MT', 'PHARMA', 'SALON') THEN 'OFFLINE'
              WHEN cm.Channel = 'ONLINE' THEN 'ONLINE'
              ELSE 'OFFLINE' END,
         YEAR(so.Month), MONTH(so.Month)

UNION ALL

-- Method 2: By Launch Date (first 3 months after launch)
SELECT
    sm.Sub_Group,
    CASE
        WHEN cm.Channel IN ('GT', 'MT', 'PHARMA', 'SALON') THEN 'OFFLINE'
        WHEN cm.Channel = 'ONLINE' THEN 'ONLINE'
        ELSE 'OFFLINE'
    END AS Channel,
    '4. Launch Qty' AS Time_Series,
    DATEFROMPARTS(YEAR(so.Month), MONTH(so.Month), 1) AS Period,
    SUM(so.SO_Qty) AS Quantity
FROM Historical_SO so
INNER JOIN Spectrum_Master sm ON so.Material = sm.Spectrum
INNER JOIN Customer_Master cm ON so.Customer_Code = cm.Customer_Code
WHERE so.Order_Type IN ('ZOR', 'ZPROMO')  -- Normal/Promo orders during launch period
  AND so.Status = 'C'
  AND sm.Launch_Date IS NOT NULL
  -- Within 3 months of launch
  AND so.Month >= sm.Launch_Date
  AND so.Month < DATEADD(MONTH, 3, sm.Launch_Date)
  AND sm.Division = @Division
GROUP BY sm.Sub_Group,
         CASE WHEN cm.Channel IN ('GT', 'MT', 'PHARMA', 'SALON') THEN 'OFFLINE'
              WHEN cm.Channel = 'ONLINE' THEN 'ONLINE'
              ELSE 'OFFLINE' END,
         YEAR(so.Month), MONTH(so.Month)
```

**Launch Period Rules:**

```
Launch Period = 3 months from Launch_Date

Example:
Product: LOP New Serum
Launch_Date: 2024-06-01

Launch Period:
- Month 1 (M0): Jun 2024 → 4. Launch Qty
- Month 2 (M1): Jul 2024 → 4. Launch Qty
- Month 3 (M2): Aug 2024 → 4. Launch Qty
- Month 4+ (M3+): Sep 2024 onwards → 1. Baseline Qty (graduated to baseline)
```

**Filtering Rules:**

✅ **Include:**
- Order_Type = 'ZLAUNCH' (explicit launch orders)
- OR within 3 months of Launch_Date (from Spectrum_Master)
- New products (Launch_Date within last 24 months)

❌ **Exclude:**
- Orders beyond 3-month launch window
- Products without Launch_Date (legacy products)

**Example:**

```
Scenario: New Product Launch

Spectrum_Master:
Spectrum: 3600542499999
Product_Name: LOP New Anti-Aging Serum 2025
Sub_Group: LOP New Serum
Launch_Date: 2025-01-15
Status: ACTIVE

Input (Historical_SO):
Material: 3600542499999
Month: 2025-02-01 (within 3 months of launch)
Order_Type: ZOR
SO_Qty: 800 units

↓ Mapping Logic ↓

Check launch period:
Launch_Date: 2025-01-15
Order_Month: 2025-02-01
Months_Since_Launch: 0 (same month as launch is M0)
→ Within launch period (< 3 months)

↓ Mapping ↓

Output (WF Historical):
Forecasting Line: LOP New Serum
Channel: OFFLINE
Time series: 4. Launch Qty  ← Mapped to Launch Qty
[Y0 (u) M2]: 800
```

**Forecast Data:**

```
Source: Launch Plan + User input

Launch Plan Table:
CREATE TABLE Launch_Plan (
    Launch_ID VARCHAR(20) PRIMARY KEY,
    Division VARCHAR(3),
    Sub_Group VARCHAR(100),
    Launch_Date DATE,
    Launch_Qty_M0 INT,  -- Expected qty month 0
    Launch_Qty_M1 INT,  -- Expected qty month 1
    Launch_Qty_M2 INT,  -- Expected qty month 2
    Channel_Split_Online_Pct DECIMAL(5,2)
)

Example:
INSERT INTO Launch_Plan VALUES
('LAUNCH_2025_NEW_SERUM', 'CPD', 'LOP New Serum', '2025-03-01',
 5000, 8000, 10000, 40.0)  -- 40% ONLINE, 60% OFFLINE

System suggestion for forecast:
Forecasting Line: LOP New Serum
Channel: ONLINE
Time series: 4. Launch Qty
[Y0 (u) M3]: 5000 × 40% = 2000  (M0, suggested)
[Y0 (u) M4]: 8000 × 40% = 3200  (M1, suggested)
[Y0 (u) M5]: 10000 × 40% = 4000 (M2, suggested)
[Y0 (u) M6]: 0 (M3+, no longer launch period)

User can adjust these suggestions
```

---

### 1.4. FOC Qty (5. FOC Qty - Free of Charge)

**Nguồn dữ liệu chính:**

| Source | Table/File | Condition | Priority |
|--------|------------|-----------|----------|
| Historical SO | `Historical_SO` | `Order_Type = 'ZFOC'` | Primary for historical |
| Promo Calendar | `Promo_Calendar` | FOC campaigns | Planning reference |
| User Input | `WF_Master` (Excel) | Manual FOC forecast | Primary for forecast |

**Mapping Logic:**

```sql
-- HISTORICAL FOC DATA
SELECT
    sm.Sub_Group,
    CASE
        WHEN cm.Channel IN ('GT', 'MT', 'PHARMA', 'SALON') THEN 'OFFLINE'
        WHEN cm.Channel = 'ONLINE' THEN 'ONLINE'
        ELSE 'OFFLINE'
    END AS Channel,
    '5. FOC Qty' AS Time_Series,
    DATEFROMPARTS(YEAR(so.Month), MONTH(so.Month), 1) AS Period,
    SUM(so.SO_Qty) AS Quantity
FROM Historical_SO so
INNER JOIN Spectrum_Master sm ON so.Material = sm.Spectrum
INNER JOIN Customer_Master cm ON so.Customer_Code = cm.Customer_Code
WHERE so.Order_Type = 'ZFOC'  -- FOC orders only
  AND so.Status = 'C'
  AND sm.Division = @Division
  AND sm.Status = 'ACTIVE'
GROUP BY sm.Sub_Group,
         CASE WHEN cm.Channel IN ('GT', 'MT', 'PHARMA', 'SALON') THEN 'OFFLINE'
              WHEN cm.Channel = 'ONLINE' THEN 'ONLINE'
              ELSE 'OFFLINE' END,
         YEAR(so.Month), MONTH(so.Month)
```

**Filtering Rules:**

✅ **Include:**
- Order_Type = 'ZFOC' (Free of Charge)
- Status = 'C' (Completed)
- Samples, gifts, promotional giveaways

❌ **Exclude:**
- Paid orders
- Internal stock movements

**FOC Types:**

| FOC Type | Description | Example |
|----------|-------------|---------|
| **Sampling** | Product samples for trial | LOP Sample 5ml |
| **Gift with Purchase** | Free product when buying | Buy 2 Get 1 Free |
| **Promotional Gift** | Marketing campaign giveaway | LOP Tote Bag (free) |
| **Trade FOC** | Free goods for retailers | Trade incentive stock |

**Example:**

```
Input (Historical_SO):
Material: 3600542410999 (LOP Sample 5ml)
Product_Type: Sample (from Spectrum_Master)
Customer: 2000456
Order_Type: ZFOC  ← Free of charge
Month: 2024-03-01
SO_Qty: 5000 units (samples)
Status: C

↓ Mapping ↓

Output (WF Historical):
Forecasting Line: LOP Revitalift Cream (main product line)
Channel: ONLINE
Time series: 5. FOC Qty
[Y-1 (u) M3]: 5000
```

**Forecast Data:**

```
Source: Marketing Campaign Plan + User input

FOC is typically planned based on:
1. Sampling campaigns (new product launches)
2. Gift with purchase promotions
3. Trade marketing activities

Example forecast:
Forecasting Line: LOP Revitalift Cream
Channel: OFFLINE
Time series: 5. FOC Qty

[Y0 (u) M3]: 2000  (Sampling campaign for new variant)
[Y0 (u) M6]: 3000  (Mid-year trade promotion - FOC for retailers)
[Y0 (u) M12]: 5000 (Year-end gift with purchase campaign)

Other months: 0 (no FOC planned)
```

---

### 1.5. Total Qty (6. Total Qty)

**Nguồn dữ liệu:**

| Source | Calculation | Priority |
|--------|-------------|----------|
| Auto-calculated | Sum of all time series | Always calculated |

**Mapping Logic:**

```sql
-- TOTAL QTY CALCULATION
-- Auto-calculated, not from input source
UPDATE wf
SET wf.Quantity =
    ISNULL(baseline.Quantity, 0) +
    ISNULL(promo.Quantity, 0) +
    ISNULL(launch.Quantity, 0) +
    ISNULL(foc.Quantity, 0)
FROM WF_Master wf
LEFT JOIN (
    SELECT Sub_Group, Channel, Period, Quantity
    FROM WF_Master
    WHERE Time_Series = '1. Baseline Qty'
) baseline ON wf.Sub_Group = baseline.Sub_Group
          AND wf.Channel = baseline.Channel
          AND wf.Period = baseline.Period
LEFT JOIN (
    SELECT Sub_Group, Channel, Period, Quantity
    FROM WF_Master
    WHERE Time_Series = '2. Promo Qty'
) promo ON wf.Sub_Group = promo.Sub_Group
       AND wf.Channel = promo.Channel
       AND wf.Period = promo.Period
LEFT JOIN (
    SELECT Sub_Group, Channel, Period, Quantity
    FROM WF_Master
    WHERE Time_Series = '4. Launch Qty'
) launch ON wf.Sub_Group = launch.Sub_Group
        AND wf.Channel = launch.Channel
        AND wf.Period = launch.Period
LEFT JOIN (
    SELECT Sub_Group, Channel, Period, Quantity
    FROM WF_Master
    WHERE Time_Series = '5. FOC Qty'
) foc ON wf.Sub_Group = foc.Sub_Group
     AND wf.Channel = foc.Channel
     AND wf.Period = foc.Period
WHERE wf.Time_Series = '6. Total Qty'
  AND wf.Division = @Division
  AND wf.FM_KEY = @FM_KEY
```

**Formula:**

```
Total Qty = Baseline Qty + Promo Qty + Launch Qty + FOC Qty
```

**Example:**

```
Forecasting Line: LOP Revitalift Cream
Channel: ONLINE
Period: Y0_M2 (Feb 2025)

1. Baseline Qty: 5000
2. Promo Qty:    1000 (Tet campaign)
4. Launch Qty:   0    (not a launch period)
5. FOC Qty:      500  (sampling)
────────────────────
6. Total Qty:    6500 (auto-calculated)
```

**Validation:**

```sql
-- Validation query to ensure Total Qty integrity
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
        WHEN Total_Qty = (Baseline_Qty + Promo_Qty + Launch_Qty + FOC_Qty)
        THEN 'OK'
        ELSE 'ERROR'
    END AS Validation_Status
FROM WF_Summary_View
WHERE Validation_Status = 'ERROR'
```

---

## 2. Channel Mapping

### 2.1. ONLINE Channel

**Nguồn dữ liệu:**

| Source | Table/File | Mapping Field | Rule |
|--------|------------|---------------|------|
| Customer Master | `Customer_Master` | `Channel` | `Channel = 'ONLINE'` |
| Historical SO | `Historical_SO` | `Customer_Code` | Join with Customer_Master |

**Mapping Logic:**

```sql
-- ONLINE Channel mapping
SELECT
    sm.Sub_Group,
    'ONLINE' AS Channel,
    Time_Series,
    Period,
    SUM(so.SO_Qty) AS Quantity
FROM Historical_SO so
INNER JOIN Spectrum_Master sm ON so.Material = sm.Spectrum
INNER JOIN Customer_Master cm ON so.Customer_Code = cm.Customer_Code
WHERE cm.Channel = 'ONLINE'  -- E-commerce customers
  AND cm.Active = 1
  AND sm.Division = @Division
GROUP BY sm.Sub_Group, Time_Series, Period
```

**Online Customer Types:**

| Customer Type | Customer Name Examples | Channel Code |
|---------------|------------------------|--------------|
| E-commerce Platforms | Shopee, Lazada, Tiki, Sendo | ONLINE |
| Brand Website | L'Oreal Vietnam Website | ONLINE |
| Social Commerce | Facebook Shop, Instagram Shop | ONLINE |
| Online Retailers | Guardian Online, Watsons Online | ONLINE |

**Example:**

```
Customer_Master:
Customer_Code: 2000456
Customer_Name: SHOPEE VIETNAM
Channel: ONLINE  ← Online customer
Active: 1

Historical_SO:
Material: 3600542410311
Customer_Code: 2000456  ← Links to SHOPEE
Order_Type: ZOR
Month: 2024-01-01
SO_Qty: 800 units

↓ Mapping ↓

Output (WF):
Forecasting Line: LOP Revitalift Cream
Channel: ONLINE  ← Mapped from Customer_Master
Time series: 1. Baseline Qty
[Y-1 (u) M1]: 800
```

---

### 2.2. OFFLINE Channel

**Nguồn dữ liệu:**

| Source | Table/File | Mapping Field | Rule |
|--------|------------|---------------|------|
| Customer Master | `Customer_Master` | `Channel` | `Channel IN ('GT', 'MT', 'PHARMA', 'SALON')` |
| Historical SO | `Historical_SO` | `Customer_Code` | Join with Customer_Master |

**Mapping Logic:**

```sql
-- OFFLINE Channel mapping
SELECT
    sm.Sub_Group,
    'OFFLINE' AS Channel,
    Time_Series,
    Period,
    SUM(so.SO_Qty) AS Quantity
FROM Historical_SO so
INNER JOIN Spectrum_Master sm ON so.Material = sm.Spectrum
INNER JOIN Customer_Master cm ON so.Customer_Code = cm.Customer_Code
WHERE cm.Channel IN ('GT', 'MT', 'PHARMA', 'SALON')  -- Physical stores
  AND cm.Active = 1
  AND sm.Division = @Division
GROUP BY sm.Sub_Group, Time_Series, Period
```

**Offline Channel Types:**

| Sub-Channel | Full Name | Customer Examples | Channel Code |
|-------------|-----------|-------------------|--------------|
| **GT** | General Trade | Small retailers, grocery stores | OFFLINE |
| **MT** | Modern Trade | CO.OP Mart, BigC, Lotte Mart, Vinmart | OFFLINE |
| **PHARMA** | Pharmacy | Guardian, Pharmacity, Medicare | OFFLINE |
| **SALON** | Professional Salon | Hair salons, beauty salons | OFFLINE |

**Example:**

```
Customer_Master:
Customer_Code: 1000123
Customer_Name: CO.OP MART HCM
Channel: MT  ← Modern Trade (physical store)
Active: 1

Historical_SO:
Material: 3600542410311
Customer_Code: 1000123  ← Links to CO.OP MART
Order_Type: ZOR
Month: 2024-01-01
SO_Qty: 1500 units

↓ Mapping ↓

Output (WF):
Forecasting Line: LOP Revitalift Cream
Channel: OFFLINE  ← Mapped from Customer_Master (MT → OFFLINE)
Time series: 1. Baseline Qty
[Y-1 (u) M1]: 1500
```

---

### 2.3. O+O Channel (Online + Offline)

**Nguồn dữ liệu:**

| Source | Calculation | Priority |
|--------|-------------|----------|
| Auto-calculated | Sum of ONLINE + OFFLINE | Always calculated |

**Mapping Logic:**

```sql
-- O+O Channel aggregation
INSERT INTO WF_Master (Division, Sub_Group, Channel, Time_Series, Period, Quantity, Source)
SELECT
    Division,
    Sub_Group,
    'O+O' AS Channel,
    Time_Series,
    Period,
    SUM(Quantity) AS Quantity,
    'Auto_Calculated' AS Source
FROM WF_Master
WHERE Channel IN ('ONLINE', 'OFFLINE')
  AND Division = @Division
  AND FM_KEY = @FM_KEY
GROUP BY Division, Sub_Group, Time_Series, Period
```

**Formula:**

```
O+O Qty = ONLINE Qty + OFFLINE Qty
```

**Example:**

```
Forecasting Line: LOP Revitalift Cream
Time series: 1. Baseline Qty
Period: Y0_M1 (Jan 2025)

ONLINE:  5000 units
OFFLINE: 8000 units
────────────────────
O+O:    13000 units (auto-calculated)

Channel Split:
ONLINE:  5000 / 13000 = 38.5%
OFFLINE: 8000 / 13000 = 61.5%
```

**Usage:**

O+O is used for:
- Budget comparison (Budget is usually at O+O level)
- Total market view
- FM Export (can export O+O consolidated)
- Executive reporting

---

## 3. Period/Column Mapping

### 3.1. Historical Periods (Y-2, Y-1, Past Y0)

**Nguồn dữ liệu:**

| Source | Table | Date Field | Period Range |
|--------|-------|------------|--------------|
| Historical SO | `Historical_SO` | `Month` | Last 24 months from FM_KEY |
| Historical SI | `Historical_SI` (ZV14) | `Delivery_Date` | Last 24 months |

**Mapping Logic:**

```sql
-- Historical period mapping
-- FM_KEY = CPD_2025_01 (January 2025)
-- Base date = 2025-01-01

DECLARE @FM_Date DATE = '2025-01-01'  -- From FM_KEY
DECLARE @BaseYear INT = YEAR(@FM_Date)

-- Y-2 columns (2023)
-- [Y-2 (u) M1] = Jan 2023, [Y-2 (u) M2] = Feb 2023, ...
SELECT
    Sub_Group,
    Channel,
    Time_Series,
    MONTH(Period) AS Month_Num,
    '[Y-2 (u) M' + CAST(MONTH(Period) AS VARCHAR) + ']' AS Column_Name,
    Quantity
FROM Historical_Data
WHERE YEAR(Period) = @BaseYear - 2  -- 2023

-- Y-1 columns (2024)
-- [Y-1 (u) M1] = Jan 2024, [Y-1 (u) M2] = Feb 2024, ...
SELECT
    Sub_Group,
    Channel,
    Time_Series,
    MONTH(Period) AS Month_Num,
    '[Y-1 (u) M' + CAST(MONTH(Period) AS VARCHAR) + ']' AS Column_Name,
    Quantity
FROM Historical_Data
WHERE YEAR(Period) = @BaseYear - 1  -- 2024

-- Y0 historical (Jan 2025 if FM is Jan 2025, nothing if FM is also Jan)
-- Past months of current year only
SELECT
    Sub_Group,
    Channel,
    Time_Series,
    MONTH(Period) AS Month_Num,
    '[Y0 (u) M' + CAST(MONTH(Period) AS VARCHAR) + ']' AS Column_Name,
    Quantity
FROM Historical_Data
WHERE YEAR(Period) = @BaseYear  -- 2025
  AND Period < @FM_Date  -- Before FM month
```

**Example:**

```
FM_KEY: CPD_2025_03 (March 2025)
FM_Date: 2025-03-01

Historical periods:
Y-2 (2023):
[Y-2 (u) M1]: Jan 2023 data
[Y-2 (u) M2]: Feb 2023 data
...
[Y-2 (u) M12]: Dec 2023 data

Y-1 (2024):
[Y-1 (u) M1]: Jan 2024 data
[Y-1 (u) M2]: Feb 2024 data
...
[Y-1 (u) M12]: Dec 2024 data

Y0 (2025, past months only):
[Y0 (u) M1]: Jan 2025 data (historical, completed)
[Y0 (u) M2]: Feb 2025 data (historical, completed)
[Y0 (u) M3]: (blank, current month - not historical yet)
```

**Data Source:**

```
Historical_SO table:
Material: 3600542410311
Month: 2024-01-01
SO_Qty: 1500

↓ When FM_KEY = CPD_2025_01 ↓

Mapped to column:
[Y-1 (u) M1]: 1500  (Jan 2024 is Y-1 relative to 2025)
```

---

### 3.2. Forecast Periods (Y0 Current+, Y+1)

**Nguồn dữ liệu:**

| Source | Table | Input Method |
|--------|-------|--------------|
| User Input | `WF_Master` (Excel) | Manual entry in green cells |
| M-1 Forecast | `FC_FM_History` | Previous month reference |
| System Suggestion | Calculated | Based on trends, seasonality |

**Mapping Logic:**

```sql
-- Forecast period mapping
-- FM_KEY = CPD_2025_01 (January 2025)

DECLARE @FM_Date DATE = '2025-01-01'
DECLARE @BaseYear INT = YEAR(@FM_Date)
DECLARE @CurrentMonth INT = MONTH(@FM_Date)

-- Y0 forecast columns (current month onwards)
-- [Y0 (u) M1], [Y0 (u) M2], ..., [Y0 (u) M12]
-- Editable from current month onwards

-- Y+1 forecast columns (next year)
-- [Y+1 (u) M1] = Jan 2026, [Y+1 (u) M2] = Feb 2026, ...
-- All editable
```

**Example:**

```
FM_KEY: CPD_2025_01 (January 2025)

Y0 Forecast (2025):
[Y0 (u) M1]: User input (Jan 2025) - editable (current month)
[Y0 (u) M2]: User input (Feb 2025) - editable
[Y0 (u) M3]: User input (Mar 2025) - editable
...
[Y0 (u) M12]: User input (Dec 2025) - editable

Y+1 Forecast (2026):
[Y+1 (u) M1]: User input (Jan 2026) - editable
[Y+1 (u) M2]: User input (Feb 2026) - editable
...
[Y+1 (u) M12]: User input (Dec 2026) - editable
```

**User Input in Excel:**

```
Forecasting Line: LOP Revitalift Cream
Channel: ONLINE
Time series: 1. Baseline Qty

User enters:
[Y0 (u) M2]: 5000  ← Feb 2025 forecast
[Y0 (u) M3]: 5200  ← Mar 2025 forecast
[Y0 (u) M4]: 5500  ← Apr 2025 forecast
...
```

---

## 4. Calculation Fields Mapping

### 4.1. AVE P3M (Average Previous 3 Months)

**Nguồn dữ liệu:**

| Source | Calculation | Period |
|--------|-------------|--------|
| Historical SO | Average of last 3 completed months | Rolling 3 months |

**Mapping Logic:**

```sql
-- AVE P3M calculation
WITH Last_3_Months AS (
    SELECT
        sm.Sub_Group,
        Channel,
        so.Month,
        SUM(so.SO_Qty) AS Monthly_Qty,
        ROW_NUMBER() OVER (PARTITION BY sm.Sub_Group, Channel
                          ORDER BY so.Month DESC) AS Month_Rank
    FROM Historical_SO so
    INNER JOIN Spectrum_Master sm ON so.Material = sm.Spectrum
    WHERE so.Month < @FM_Date  -- Completed months only
      AND so.Status = 'C'
    GROUP BY sm.Sub_Group, Channel, so.Month
)
SELECT
    Sub_Group,
    Channel,
    AVG(Monthly_Qty) AS AVE_P3M
FROM Last_3_Months
WHERE Month_Rank <= 3  -- Last 3 months
GROUP BY Sub_Group, Channel
```

**Example:**

```
FM_KEY: CPD_2025_01 (January 2025)
Current date: 2025-01-15

Last 3 completed months:
- Dec 2024: 8000 units
- Nov 2024: 7500 units
- Oct 2024: 7800 units

AVE P3M = (8000 + 7500 + 7800) / 3 = 7767 units

Output in WF:
Forecasting Line: LOP Revitalift Cream
Channel: ONLINE
AVE P3M: 7767
```

**Purpose:**
- Baseline reference for forecasting
- 3M Risk assessment comparison
- Trend analysis

---

### 4.2. AVE F3M (Average Forecast 3 Months)

**Nguồn dữ liệu:**

| Source | Calculation | Period |
|--------|-------------|--------|
| User Forecast | Average of next 3 forecast months | Forward looking 3 months |

**Mapping Logic:**

```sql
-- AVE F3M calculation
WITH Next_3_Months AS (
    SELECT
        Sub_Group,
        Channel,
        Period,
        Quantity AS Forecast_Qty,
        ROW_NUMBER() OVER (PARTITION BY Sub_Group, Channel
                          ORDER BY Period ASC) AS Month_Rank
    FROM WF_Master
    WHERE Period >= @FM_Date  -- Future months
      AND Time_Series = '6. Total Qty'
      AND Channel = 'O+O'
)
SELECT
    Sub_Group,
    Channel,
    AVG(Forecast_Qty) AS AVE_F3M
FROM Next_3_Months
WHERE Month_Rank <= 3  -- Next 3 months
GROUP BY Sub_Group, Channel
```

**Example:**

```
FM_KEY: CPD_2025_01 (January 2025)

Next 3 forecast months:
- Jan 2025 (Y0_M1): 8500 units (forecast)
- Feb 2025 (Y0_M2): 9000 units (forecast)
- Mar 2025 (Y0_M3): 9200 units (forecast)

AVE F3M = (8500 + 9000 + 9200) / 3 = 8900 units

Output in WF:
AVE F3M: 8900

Comparison:
AVE P3M: 7767
AVE F3M: 8900
Growth: +14.6%
```

---

### 4.3. SOH (Stock on Hand)

**Nguồn dữ liệu:**

| Source | Table | Field | Update Frequency |
|--------|-------|-------|------------------|
| SAP ZMR32 | `Stock_ZMR32` | `SOH_Qty` | Daily |

**Mapping Logic:**

```sql
-- SOH mapping
SELECT
    sm.Sub_Group,
    SUM(soh.Quantity) AS SOH_Qty
FROM Stock_ZMR32 soh
INNER JOIN Spectrum_Master sm ON soh.Material = sm.Spectrum
WHERE sm.Division = @Division
  AND sm.Status = 'ACTIVE'
  AND soh.Stock_Date = (SELECT MAX(Stock_Date) FROM Stock_ZMR32)  -- Latest stock
GROUP BY sm.Sub_Group
```

**Example:**

```
Stock_ZMR32 table:
Material: 3600542410311 (LOP Revitalift Cream 50ml)
Plant: 1000
Quantity: 10000 units
Stock_Date: 2025-01-15

Material: 3600542410328 (LOP Revitalift Cream 30ml)
Plant: 1000
Quantity: 5000 units
Stock_Date: 2025-01-15

↓ Aggregation by Sub_Group ↓

Output in WF:
Forecasting Line: LOP Revitalift Cream
SOH: 15000 units (10000 + 5000, aggregated from all SKUs in sub-group)
```

---

### 4.4. GIT (Goods in Transit)

**Nguồn dữ liệu:**

| Source | Table | Fields | Update Frequency |
|--------|-------|--------|------------------|
| SAP GIT Report | `GIT_Data` | `GIT_M0`, `GIT_M1`, `GIT_M2`, `GIT_M3` | Daily |

**Mapping Logic:**

```sql
-- GIT mapping
SELECT
    sm.Sub_Group,
    SUM(git.Quantity_M0) AS GIT_M0,
    SUM(git.Quantity_M1) AS GIT_M1,
    SUM(git.Quantity_M2) AS GIT_M2,
    SUM(git.Quantity_M3) AS GIT_M3
FROM GIT_Data git
INNER JOIN Spectrum_Master sm ON git.Material = sm.Spectrum
WHERE sm.Division = @Division
  AND git.Update_Date = (SELECT MAX(Update_Date) FROM GIT_Data)  -- Latest GIT
GROUP BY sm.Sub_Group
```

**Example:**

```
GIT_Data table:
Material: 3600542410311
Quantity_M0: 2000  ← In transit for current month
Quantity_M1: 1500  ← In transit for next month
Quantity_M2: 1000
Quantity_M3: 500
Update_Date: 2025-01-15

↓ Mapping ↓

Output in WF:
Forecasting Line: LOP Revitalift Cream
GIT M0: 2000
GIT M1: 1500
GIT M2: 1000
GIT M3: 500
```

---

### 4.5. SLOB Risk

**Nguồn dữ liệu:**

| Source | Calculation | Formula |
|--------|-------------|---------|
| SOH + AVE P3M | Stock coverage analysis | `SOH / AVE_P3M` |

**Mapping Logic:**

```sql
-- SLOB Risk calculation
SELECT
    Sub_Group,
    SOH,
    AVE_P3M,
    CASE
        WHEN AVE_P3M = 0 AND SOH > 0 THEN 'DEAD_STOCK'
        WHEN SOH / NULLIF(AVE_P3M, 0) > 3 THEN 'HIGH'
        WHEN SOH / NULLIF(AVE_P3M, 0) > 2 THEN 'MEDIUM'
        ELSE 'LOW'
    END AS SLOB_Risk,
    SOH / NULLIF(AVE_P3M, 0) AS Stock_Coverage_Months
FROM WF_Calculation_View
WHERE Division = @Division
```

**Example:**

```
Forecasting Line: LOP Revitalift Cream
SOH: 15000 units
AVE P3M: 2000 units/month

Stock Coverage = 15000 / 2000 = 7.5 months

SLOB Risk: HIGH  (> 3 months)

Interpretation:
At current sales rate (2000/month), stock will last 7.5 months
→ Slow-moving, consider clearance actions
```

---

### 4.6. BP Gap %

**Nguồn dữ liệu:**

| Source | Calculation | Formula |
|--------|-------------|---------|
| Forecast + Budget | Variance analysis | `(Forecast - Budget) / Budget × 100` |

**Mapping Logic:**

```sql
-- BP Gap % calculation
SELECT
    fc.Sub_Group,
    fc.Period,
    fc.Forecast_Qty,
    bdg.Budget_Qty,
    fc.Forecast_Qty - bdg.Budget_Qty AS Gap_Abs,
    (fc.Forecast_Qty - bdg.Budget_Qty) / NULLIF(bdg.Budget_Qty, 0) * 100 AS BP_Gap_Pct
FROM (
    SELECT Sub_Group, Period, SUM(Quantity) AS Forecast_Qty
    FROM WF_Master
    WHERE Channel = 'O+O' AND Time_Series = '6. Total Qty'
    GROUP BY Sub_Group, Period
) fc
INNER JOIN FC_Budget bdg ON fc.Sub_Group = bdg.Sub_Group
                         AND fc.Period = bdg.Period
```

**Example:**

```
Forecasting Line: LOP Revitalift Cream
Period: Y0_M2 (Feb 2025)

Budget: 10000 units
Forecast: 11500 units

Gap (Abs): 11500 - 10000 = +1500 units
BP Gap %: (1500 / 10000) × 100 = +15.0%

Output in WF:
BP Gap %: +15.0% (over budget)
```

---

## 5. Budget Fields Mapping

### 5.1. Budget (B_Y0, B_Y+1)

**Nguồn dữ liệu:**

| Source | Table/File | Upload By | Frequency |
|--------|------------|-----------|-----------|
| Finance Team | `FC_Budget` (Excel upload) | Finance | Yearly |

**Mapping Logic:**

```sql
-- Budget mapping
SELECT
    Division,
    Sub_Group,
    Channel,  -- Usually O+O level
    Period,
    Budget_Qty,
    Budget_Type,  -- 'Budget', 'Pre-Budget', 'Trend1', etc.
    Upload_Date,
    Upload_By
FROM FC_Budget
WHERE Division = @Division
  AND Budget_Type = 'Budget'  -- Official budget
  AND YEAR(Period) IN (@BaseYear, @BaseYear + 1)  -- Y0 and Y+1
```

**Column Mapping:**

```
Budget file columns:
[B_Y0_M1], [B_Y0_M2], ..., [B_Y0_M12]  ← Budget for current year
[B_Y+1_M1], [B_Y+1_M2], ..., [B_Y+1_M12]  ← Budget for next year
```

**Example:**

```
FC_Budget table:
Division: CPD
Sub_Group: LOP Revitalift Cream
Channel: O+O
Period: 2025-02-01
Budget_Qty: 10000
Budget_Type: Budget
Upload_Date: 2024-12-15
Upload_By: finance.user

↓ Mapping ↓

Output in WF:
Forecasting Line: LOP Revitalift Cream
Channel: O+O
[B_Y0_M2]: 10000  (Feb 2025 budget)
```

---

### 5.2. Pre-Budget (PB_Y+1)

**Nguồn dữ liệu:**

| Source | Table/File | Upload By | Frequency |
|--------|------------|-----------|-----------|
| Finance Team | `FC_Budget` | Finance | Yearly (draft) |

**Mapping Logic:**

```sql
-- Pre-Budget mapping
SELECT
    Division,
    Sub_Group,
    Channel,
    Period,
    Budget_Qty AS PreBudget_Qty,
    Upload_Date
FROM FC_Budget
WHERE Division = @Division
  AND Budget_Type = 'Pre-Budget'  -- Draft budget
  AND YEAR(Period) = @BaseYear + 1  -- Usually for Y+1 only
```

**Example:**

```
FC_Budget table:
Division: CPD
Sub_Group: LOP Revitalift Cream
Period: 2026-01-01
Budget_Qty: 11000
Budget_Type: Pre-Budget
Upload_Date: 2024-10-15

↓ Mapping ↓

Output in WF:
[PB_Y+1_M1]: 11000  (Jan 2026 pre-budget)
```

---

### 5.3. Trends (T1, T2, T3)

**Nguồn dữ liệu:**

| Source | Table/File | Scenarios | Purpose |
|--------|------------|-----------|---------|
| Finance/Planning | `FC_Budget` | Conservative / Base / Optimistic | Scenario planning |

**Mapping Logic:**

```sql
-- Trend scenarios mapping
SELECT
    Division,
    Sub_Group,
    Period,
    MAX(CASE WHEN Budget_Type = 'Trend1' THEN Budget_Qty END) AS T1_Qty,  -- Conservative
    MAX(CASE WHEN Budget_Type = 'Trend2' THEN Budget_Qty END) AS T2_Qty,  -- Base
    MAX(CASE WHEN Budget_Type = 'Trend3' THEN Budget_Qty END) AS T3_Qty   -- Optimistic
FROM FC_Budget
WHERE Division = @Division
  AND Budget_Type IN ('Trend1', 'Trend2', 'Trend3')
GROUP BY Division, Sub_Group, Period
```

**Scenarios:**

| Trend | Scenario | Typical % vs Budget | Use Case |
|-------|----------|---------------------|----------|
| **T1** | Conservative | -10% to -15% | Worst case scenario |
| **T2** | Base | ±5% | Most likely scenario |
| **T3** | Optimistic | +10% to +15% | Best case scenario |

**Example:**

```
FC_Budget table:
Sub_Group: LOP Revitalift Cream
Period: 2025-02-01

Budget_Type: Trend1 → Budget_Qty: 8500  (Conservative)
Budget_Type: Trend2 → Budget_Qty: 10000 (Base)
Budget_Type: Trend3 → Budget_Qty: 11500 (Optimistic)

↓ Mapping ↓

Output in WF:
[T1_Y0_M2]: 8500
[T2_Y0_M2]: 10000
[T3_Y0_M2]: 11500

Forecast comparison:
Forecast: 10200
Closest to: T2 (Base scenario)
```

---

## 6. Master Data Fields Mapping

### 6.1. Product Type

**Nguồn dữ liệu:**

| Source | Table | Field |
|--------|-------|-------|
| Spectrum Master | `Spectrum_Master` | `Product_Type` |

**Values:**

```sql
Product_Type IN ('Finished Good', 'Bundle', 'Promo Pack', 'Sample')
```

**Mapping:**

```
Spectrum_Master:
Spectrum: 3600542410311
Product_Type: Finished Good

↓ Display in WF ↓

Product type column: Finished Good
```

---

### 6.2. Forecasting Line (Sub Group)

**Nguồn dữ liệu:**

| Source | Table | Field |
|--------|-------|-------|
| Spectrum Master | `Spectrum_Master` | `Sub_Group` |

**Mapping:**

```sql
-- Sub_Group mapping
SELECT DISTINCT
    Sub_Group AS Forecasting_Line
FROM Spectrum_Master
WHERE Division = @Division
  AND Status = 'ACTIVE'
ORDER BY Sub_Group
```

**Example:**

```
Spectrum_Master:
Spectrum: 3600542410311
Product_Name: L'Oreal Paris Revitalift Cream 50ml
Brand: L'Oreal Paris
Sub_Brand: Revitalift
Sub_Group: LOP Revitalift Cream  ← Forecasting Line

↓ Display in WF ↓

Forecasting Line column: LOP Revitalift Cream
```

---

## 7. Complete Mapping Matrix

### 7.1. Field-to-Source Matrix

| WF Field | Primary Source | Secondary Source | Calculation | Editable | Color |
|----------|----------------|------------------|-------------|----------|-------|
| **Product type** | Spectrum_Master.Product_Type | - | - | No | White |
| **Forecasting Line** | Spectrum_Master.Sub_Group | - | - | No | White |
| **Channel** | Customer_Master.Channel → ONLINE/OFFLINE | - | - | No | White |
| **Channel (O+O)** | - | - | ONLINE + OFFLINE | No | White |
| **Time series** | Row label | - | - | No | White |
| **[Y-2 (u) M1-M12]** | Historical_SO (2 years ago) | - | - | No | Blue |
| **[Y-1 (u) M1-M12]** | Historical_SO (last year) | - | - | No | Blue |
| **[Y0 (u) M1-Mcurrent]** | Historical_SO (completed months) | - | - | No | Blue |
| **[Y0 (u) Mcurrent-M12]** | User Input (Excel) | M-1 Forecast | - | Yes | Green |
| **[Y+1 (u) M1-M12]** | User Input (Excel) | - | - | Yes | Green |
| **[B_Y0_M1-M12]** | FC_Budget (Budget_Type='Budget') | - | - | No | Yellow |
| **[B_Y+1_M1-M12]** | FC_Budget (Budget_Type='Budget') | - | - | No | Yellow |
| **[PB_Y+1_M1-M12]** | FC_Budget (Budget_Type='Pre-Budget') | - | - | No | Yellow |
| **[T1/T2/T3_Y0_M1-M12]** | FC_Budget (Budget_Type='Trend1/2/3') | - | - | No | Yellow |
| **[M-1_Y0_M1-M12]** | FC_FM_History (previous FM) | - | - | No | Gray |
| **AVE P3M** | - | - | AVG(last 3M actual) | No | Orange |
| **AVE F3M** | - | - | AVG(next 3M forecast) | No | Orange |
| **MTD SI** | Historical_SI (current month) | - | SUM(SI MTD) | No | Orange |
| **SOH** | Stock_ZMR32.Quantity | - | SUM by Sub_Group | No | Orange |
| **SIT** | - | - | SOH - GIT_M0 | No | Orange |
| **GIT M0-M3** | GIT_Data.Quantity_M0-M3 | - | SUM by Sub_Group | No | Orange |
| **SLOB Risk** | - | - | SOH / AVE_P3M | No | Orange |
| **BP Gap %** | - | - | (FC-BDG)/BDG×100 | No | Orange |

### 7.2. Time Series Source Matrix

| Time Series | Historical Source | Forecast Source | Key Filter | Order Type |
|-------------|-------------------|-----------------|------------|------------|
| **1. Baseline Qty** | Historical_SO | User Input | `Order_Type='ZOR'` AND not in promo period | ZOR |
| **2. Promo Qty** | Historical_SO | User Input + Promo_Calendar | `Order_Type='ZPROMO'` OR in promo period | ZPROMO |
| **4. Launch Qty** | Historical_SO | User Input + Launch_Plan | `Order_Type='ZLAUNCH'` OR within 3M of Launch_Date | ZLAUNCH |
| **5. FOC Qty** | Historical_SO | User Input | `Order_Type='ZFOC'` | ZFOC |
| **6. Total Qty** | - | Calculated | Sum of 1+2+4+5 | - |

### 7.3. Channel Source Matrix

| Channel | Source Filter | Customer Types | Examples |
|---------|---------------|----------------|----------|
| **ONLINE** | `Customer_Master.Channel='ONLINE'` | E-commerce, Social commerce | Shopee, Lazada, Tiki |
| **OFFLINE** | `Customer_Master.Channel IN ('GT','MT','PHARMA','SALON')` | Physical stores | CO.OP, BigC, Guardian |
| **O+O** | Calculated: ONLINE + OFFLINE | All channels | - |

---

## 8. Data Flow Examples

### Example 1: Complete Flow for Baseline Qty

```
┌─────────────────────────────────────────────────────────────┐
│ STEP 1: RAW DATA (SAP)                                      │
├─────────────────────────────────────────────────────────────┤
│ Historical_SO:                                               │
│ Material: 3600542410311                                     │
│ Customer_Code: 1000123                                      │
│ Order_Type: ZOR                                             │
│ Month: 2024-01-01                                           │
│ SO_Qty: 1500                                                │
│ Status: C                                                   │
└─────────────────────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────────────────────┐
│ STEP 2: MASTER DATA ENRICHMENT                              │
├─────────────────────────────────────────────────────────────┤
│ Spectrum_Master:                                            │
│ Spectrum: 3600542410311 → Sub_Group: "LOP Revitalift Cream"│
│ Product_Type: "Finished Good"                               │
│                                                              │
│ Customer_Master:                                            │
│ Customer_Code: 1000123 → Channel: "MT" → "OFFLINE"        │
└─────────────────────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────────────────────┐
│ STEP 3: TIME SERIES CLASSIFICATION                          │
├─────────────────────────────────────────────────────────────┤
│ Order_Type: ZOR                                             │
│ Check Promo_Calendar: Not in promo period                  │
│ → Time_Series: "1. Baseline Qty"                           │
└─────────────────────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────────────────────┐
│ STEP 4: PERIOD MAPPING                                      │
├─────────────────────────────────────────────────────────────┤
│ Month: 2024-01-01                                           │
│ FM_KEY: CPD_2025_01 (base year 2025)                       │
│ → Column: [Y-1 (u) M1] (Jan 2024 is Y-1 from 2025)        │
└─────────────────────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────────────────────┐
│ STEP 5: AGGREGATION                                         │
├─────────────────────────────────────────────────────────────┤
│ GROUP BY: Sub_Group + Channel + Time_Series + Period       │
│ SUM: SO_Qty                                                 │
└─────────────────────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────────────────────┐
│ STEP 6: OUTPUT TO WF                                        │
├─────────────────────────────────────────────────────────────┤
│ Product type: Finished Good                                 │
│ Forecasting Line: LOP Revitalift Cream                      │
│ Channel: OFFLINE                                            │
│ Time series: 1. Baseline Qty                                │
│ [Y-1 (u) M1]: 1500                                         │
└─────────────────────────────────────────────────────────────┘
```

### Example 2: Promo Qty with Calendar Check

```
┌─────────────────────────────────────────────────────────────┐
│ INPUT 1: Historical_SO                                      │
├─────────────────────────────────────────────────────────────┤
│ Material: 3600542410311                                     │
│ Order_Type: ZOR  ← Normal order                            │
│ Month: 2024-02-05                                           │
│ SO_Qty: 2500                                                │
└─────────────────────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────────────────────┐
│ INPUT 2: Promo_Calendar                                     │
├─────────────────────────────────────────────────────────────┤
│ Promo_ID: PROMO_2024_02_TET                                │
│ Sub_Group: LOP Revitalift Cream                             │
│ Start_Date: 2024-02-01                                      │
│ End_Date: 2024-02-29                                        │
│ Status: CONFIRMED                                           │
└─────────────────────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────────────────────┐
│ LOGIC: Check if order falls in promo period                │
├─────────────────────────────────────────────────────────────┤
│ Order_Date: 2024-02-05                                      │
│ Promo_Start: 2024-02-01                                     │
│ Promo_End: 2024-02-29                                       │
│ → YES, in promo period                                      │
│ → Override: Time_Series = "2. Promo Qty"                   │
└─────────────────────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────────────────────┐
│ OUTPUT TO WF                                                │
├─────────────────────────────────────────────────────────────┤
│ Forecasting Line: LOP Revitalift Cream                      │
│ Channel: OFFLINE                                            │
│ Time series: 2. Promo Qty  ← Classified as promo          │
│ [Y-1 (u) M2]: 2500                                         │
└─────────────────────────────────────────────────────────────┘
```

---

**Document Version:** 1.0
**Last Updated:** 2025-11-18
**Maintained by:** Technical Team

**Related Documents:**
- [DATA_FLOW_OVERVIEW.md](./DATA_FLOW_OVERVIEW.md) - Tổng quan luồng dữ liệu
- [INPUT_DATA_SPECIFICATION.md](./INPUT_DATA_SPECIFICATION.md) - Chi tiết input
- [DATA_MAPPING_PROCESS.md](./DATA_MAPPING_PROCESS.md) - Quy trình mapping
- [BUSINESS_LOGIC_FLOW.md](./BUSINESS_LOGIC_FLOW.md) - Logic nghiệp vụ
- [OUTPUT_SPECIFICATION.md](./OUTPUT_SPECIFICATION.md) - Kết quả output
