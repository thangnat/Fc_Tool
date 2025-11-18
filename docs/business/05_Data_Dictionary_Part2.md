# Data Dictionary Part 2 - SI Calculations, Inventory & Analysis

## 📌 Continued from Part 1

This document covers Groups 10-12 of the Working File structure:
- GROUP 10: Sell-In Calculations
- GROUP 11: Inventory & Actuals
- GROUP 12: Analysis & Flags

---

## GROUP 10: Sell-In Calculations (90 columns)

### Overview
Group này chứa các columns tính toán tổng Sell-In cho từng loại forecast component.

---

### 10.1 SI_Promo_Single_{YYYYMM}

**Column Pattern:** `SI_Promo_Single_YYYYMM`
**Number of Columns:** 18
**Data Type:** Numeric (Integer)
**Format:** Whole numbers
**Nullable:** No (default 0)

**Definition:**
Tổng Sell-In forecast cho promotional single products (Offline + Online combined).

**Source:**
- System: Calculated field
- Stored Procedure: sp_tag_add_FC_SI_Group_FC_SI_Promo_Single_New
- Input: FC_Promo_Single_Offline + FC_Promo_Single_Online

**Calculation:**
```
SI_Promo_Single_YYYYMM =
  FC_Promo_Single_Offline_YYYYMM +
  FC_Promo_Single_Online_YYYYMM
```

**Example:**
```
Product: 12345678
Period: 202502 (Valentine promo)

FC_Promo_Single_Offline_202502: 1,200 units
FC_Promo_Single_Online_202502: 300 units
─────────────────────────────────────────
SI_Promo_Single_202502: 1,500 units
```

**Sample Data:**
```
Month          | Offline | Online | SI Total | Notes
───────────────┼─────────┼────────┼──────────┼─────────────────
SI_Promo_..._202501| 0  | 0      | 0        | No promo
SI_Promo_..._202502|1,200| 300    | 1,500    | Valentine
SI_Promo_..._202503| 0  | 0      | 0        | No promo
SI_Promo_..._202504| 150| 50     | 200      | Minor promo
```

**Business Rules:**
- Auto-calculated (read-only for users)
- Updates when Offline or Online components change
- Zero if no promotional activity
- Part of Total_FC_SI calculation

**Visual Indicator:**
- Cell Background: Light orange (calculated SI)
- Font: Regular black
- Formula: =FC_Promo_Offline + FC_Promo_Online

**Related Fields:**
- FC_Promo_Single_Offline_{YYYYMM}
- FC_Promo_Single_Online_{YYYYMM}
- Total_FC_SI_{YYYYMM}

---

### 10.2 SI_FOC_{YYYYMM}

**Column Pattern:** `SI_FOC_YYYYMM`
**Number of Columns:** 18
**Data Type:** Numeric (Integer)
**Format:** Whole numbers
**Nullable:** No (default 0)

**Definition:**
Tổng Sell-In cho Free of Charge products (samples, GWP, giveaways).

**Source:**
- System: Calculated field
- Stored Procedure: sp_tag_add_FC_SI_Group_FC_SI_FOC
- Input: FC_FOC_{YYYYMM}

**Calculation:**
```
SI_FOC_YYYYMM = FC_FOC_YYYYMM
(Usually 1:1 mapping unless special aggregation)
```

**Example:**
```
Product: Sample_001 (Perfume Sample 5ml)
Period: 202502 (Valentine GWP)

FC_FOC_202502: 10,000 samples
SI_FOC_202502: 10,000 units

Cost impact: 10,000 * Unit_Cost
Revenue impact: 0 VND (free)
Marketing expense allocation: Campaign budget
```

**Sample Data:**
```
Month          | FOC Qty  | Campaign
───────────────┼──────────┼─────────────────────────
SI_FOC_202501  | 0        | No campaign
SI_FOC_202502  | 10,000   | Valentine GWP
SI_FOC_202503  | 0        | No campaign
SI_FOC_202504  | 2,000    | Store opening events
```

**Accounting Impact:**
```
FOC units do NOT count toward revenue forecast
BUT count toward:
- Production volume
- Inventory planning
- Cost of goods sold (COGS)
- Marketing expense
```

**Related Fields:**
- FC_FOC_{YYYYMM}
- Total_FC_SI_{YYYYMM}
- Product_Type (usually 'FOC')

---

### 10.3 SI_Launch_Single_{YYYYMM}

**Column Pattern:** `SI_Launch_Single_YYYYMM`
**Number of Columns:** 18
**Data Type:** Numeric (Integer)
**Format:** Whole numbers
**Nullable:** No (default 0)

**Definition:**
Tổng Sell-In cho new launch single products.

**Source:**
- System: Calculated field
- Stored Procedure: sp_tag_add_FC_SI_Group_FC_SI_Launch_Single
- Input: FC_Launch_Single_{YYYYMM}

**Calculation:**
```
SI_Launch_Single_YYYYMM = FC_Launch_Single_YYYYMM
(Direct mapping)
```

**Example:**
```
Product: 99887766 (New Lipstick XYZ)
Launch: Feb 2025

Launch Curve:
SI_Launch_Single_202502: 2,500 (M1 - Pipeline + Initial)
SI_Launch_Single_202503: 1,200 (M2 - Ramp-up)
SI_Launch_Single_202504: 1,500 (M3 - Growth)
SI_Launch_Single_202505: 1,800 (M4 - Peak)
SI_Launch_Single_202506: 1,500 (M5 - Steady)
SI_Launch_Single_202507: 1,500 (M6+ - Normalized)
```

**Post-Launch Transition:**
```
After 6-12 months, product transitions from Launch to Regular:
- Product_Type changes: NPD → Regular
- Forecast method changes: Launch curve → Statistical baseline
- SI_Launch becomes 0
- Baseline forecast takes over
```

**Sample Data:**
```
Month          | SI_Launch | Phase        | Total Products
───────────────┼───────────┼──────────────┼────────────────
SI_Launch_202502| 15,000  | 6 products   | Launch month
SI_Launch_202503| 8,000   | 4 ramp-up    | Mixed phase
SI_Launch_202504| 5,000   | 2 active     | Declining
```

**Related Fields:**
- FC_Launch_Single_{YYYYMM}
- Product_Type ('NPD')
- Status ('New')

---

### 10.4 SI_Promo_BOM_{YYYYMM}

**Column Pattern:** `SI_Promo_BOM_YYYYMM`
**Number of Columns:** 18
**Data Type:** Numeric (Integer)
**Format:** Whole numbers
**Nullable:** No (default 0)

**Definition:**
Tổng Sell-In requirement cho component products dùng trong promotional BOMs.

**Source:**
- System: Calculated field
- Stored Procedure: sp_tag_add_FC_SI_Group_FC_SI_Promo_Bom / sp_tag_add_FC_SI_Group_FC_SI_Promo_Bom_New
- Input: FC_Promo_BOM_Component_{YYYYMM}
- Aggregation: Sum of all BOM requirements for the product

**Calculation:**
```
SI_Promo_BOM_YYYYMM = FC_Promo_BOM_Component_YYYYMM

For products in multiple BOMs:
SI_Promo_BOM = SUM(All BOM requirements)
```

**Example:**
```
Product: 11111111 (Lipstick Red)
Month: 202501

Used in 3 different BOMs:
1. Tết Box: 3,000 sets * 1 lipstick = 3,000 units
2. Gift Set A: 1,000 sets * 1 lipstick = 1,000 units
3. Trial Kit: 500 sets * 2 lipsticks = 1,000 units

SI_Promo_BOM_202501 = 3,000 + 1,000 + 1,000 = 5,000 units
```

**Total SI Impact:**
```
Product: 11111111 (Lipstick Red)
Month: 202501

Baseline SI: 1,000 units (regular sales)
Promo Single SI: 200 units (individual promo)
Promo BOM SI: 5,000 units (used in sets)
Launch SI: 0
FOC SI: 100 units
OPTIMUS SI: 0
────────────────────────────────────
Total SI: 6,300 units
```

**Version Note:**
- **Legacy version:** Includes all channels
- **New version:** OFFLINE only (current standard)
- Configured via V_FC_NEW_CONFIG_BOM_HEADER

**Related Fields:**
- FC_Promo_BOM_Component_{YYYYMM}
- Total_FC_SI_{YYYYMM}

---

### 10.5 SI_OPTIMUS_{YYYYMM}

**Column Pattern:** `SI_OPTIMUS_YYYYMM`
**Number of Columns:** 18
**Data Type:** Numeric (Integer)
**Format:** Whole numbers
**Nullable:** No (default 0)

**Definition:**
Sell-In calculated từ OPTIMUS Sell-Out forecast (duplicate của FC_SI_OPTIMUS, khác column group).

**Source:**
- System: Same as FC_SI_OPTIMUS
- Stored Procedure: sp_tag_add_FC_SI_Group_FC_SO_OPTIMUS
- Calculation: SO_Forecast + Inventory_Change

**Note:**
Đây là duplicate data của FC_SI_OPTIMUS_{YYYYMM} (Group 8).
Tồn tại ở 2 groups khác nhau để phục vụ:
- Group 8: Forecast input perspective
- Group 10: SI calculation rollup perspective

**Calculation:**
```
SI_OPTIMUS_YYYYMM = FC_SI_OPTIMUS_YYYYMM
(Same value, different grouping)
```

**Related Fields:**
- FC_SI_OPTIMUS_{YYYYMM} (same data)
- Total_FC_SI_{YYYYMM}

---

### 10.6 Total_FC_SI_{YYYYMM}

**Column Pattern:** `Total_FC_SI_YYYYMM`
**Number of Columns:** 18
**Data Type:** Numeric (Decimal)
**Format:** Decimal (2 places)
**Nullable:** No (default 0)

**Definition:**
**TỔNG FORECAST SELL-IN** - Đây là con số quan trọng nhất, là tổng của tất cả các components.

**Source:**
- System: Calculated field
- Stored Procedure: sp_calculate_total
- Calculation: Sum of all SI components

**Complete Formula:**
```
Total_FC_SI_YYYYMM =
  FC_Baseline_YYYYMM +
  SI_Promo_Single_YYYYMM +
  SI_FOC_YYYYMM +
  SI_Launch_Single_YYYYMM +
  SI_Promo_BOM_YYYYMM +
  SI_OPTIMUS_YYYYMM

Note: Depends on configuration, some products may use:
- Baseline (for regular products)
- OR OPTIMUS (if OPTIMUS-driven)
- Not both simultaneously for same product
```

**Detailed Example:**
```
Product: 12345678 (Shampoo ABC)
Month: 202502

Component Breakdown:
├─ Baseline: 1,100 units
├─ Promo Single:
│  ├─ Offline: 1,200
│  └─ Online: 300
│  └─ Total: 1,500 units
├─ FOC: 100 units
├─ Launch: 0 units (not a new launch)
├─ Promo BOM: 300 units (used in Valentine set)
└─ OPTIMUS: 0 units (uses baseline instead)

Calculation:
Total_FC_SI_202502 = 1,100 + 1,500 + 100 + 0 + 300 + 0
                    = 3,000 units

Comparison:
Budget_202502: 1,150 units
Gap: 3,000 - 1,150 = +1,850 units (+160.9%)
Explanation: Valentine promotional campaign
```

**Sample Data (Division rollup):**
```
Month          | Total_SI  | vs Budget | Gap %  | Status
───────────────┼───────────┼───────────┼────────┼────────────
Total_202501   | 125,000   | 110,000   | +13.6% | Above budget
Total_202502   | 145,000   | 115,000   | +26.1% | High (promo)
Total_202503   | 105,000   | 100,000   | +5.0%  | Aligned
Total_202504   | 108,000   | 105,000   | +2.9%  | On track
```

**Visual Indicator:**
- Cell Background: **Bold orange** (key metric)
- Font: **Bold black**
- Border: **Double thick**
- Often has conditional formatting:
  - Green if within ±10% of budget
  - Yellow if ±10-20% of budget
  - Red if >±20% of budget

**Business Importance:**
- **Input for Supply Planning** - Production schedule
- **Revenue Forecast** - Finance projection
- **Performance Target** - Sales team goals
- **Budget Comparison** - Gap analysis
- **Approval Workflow** - Management review

**Validation Rules:**
```
1. Must be >= 0
2. Large variance vs budget requires explanation
3. Large variance vs last year requires analysis
4. Sum of products = Division total
5. Reconciles with other planning systems
```

**Related Fields:**
- All SI component columns
- Budget_{YYYYMM}
- Gap_FC_vs_Budget_{YYYYMM}

---

## GROUP 11: Inventory & Actuals

### 11.1 SOH_{YYYYMM}

**Column Pattern:** `SOH_YYYYMM` (Stock-On-Hand)
**Number of Columns:** 18
**Data Type:** Numeric (Integer)
**Format:** Whole numbers
**Nullable:** No (default 0)

**Definition:**
Số lượng tồn kho available (unrestricted - reserved) tại warehouse/plant.

**Source:**
- System: SAP ERP
- Transaction: MB52 / MMBE (Stock Overview)
- Stored Procedure: sp_tag_gen_soh
- Update Frequency: Daily or Weekly

**Calculation:**
```
SOH = Unrestricted_Stock - Reserved_Stock

Where:
Unrestricted_Stock = Stock có thể bán/ship
Reserved_Stock = Đã order nhưng chưa ship
```

**Example:**
```
Product: 12345678
Date: 01-Feb-2025

SAP Stock Overview:
├─ Unrestricted: 5,000 units
├─ Blocked (QC): 200 units
├─ In Quality Inspection: 100 units
├─ Reserved for orders: 800 units
└─ In Transit (GIT): 500 units (separate column)

Calculation:
SOH_202502 = 5,000 - 800 = 4,200 units available
```

**Sample Data:**
```
Month     | SOH     | Monthly_FC | DOS    | Status
──────────┼─────────┼────────────┼────────┼────────────────
SOH_202501| 4,200   | 1,200      | 3.5    | Healthy
SOH_202502| 3,500   | 3,000      | 1.2    | Low (promo)
SOH_202503| 2,000   | 1,100      | 1.8    | Adequate
SOH_202504| 1,500   | 1,000      | 1.5    | Normal
```

**Key Metrics:**

**DOS (Days of Supply):**
```
DOS = (SOH / Monthly_Forecast) * 30 days

Example:
SOH: 3,000 units
Monthly forecast: 2,000 units
DOS = (3,000 / 2,000) * 30 = 45 days

Interpretation:
< 30 days: Low stock
30-60 days: Healthy
60-90 days: High
> 90 days: Excess (SLOB risk)
```

**Stock Coverage:**
```
Coverage = SOH / Avg_Monthly_Sales

Example:
SOH: 4,200 units
Avg monthly sales: 1,200 units
Coverage = 4,200 / 1,200 = 3.5 months

Target:
- Fast-moving: 1-2 months
- Regular: 2-3 months
- Slow-moving: 3-6 months (max)
```

**Business Rules:**
- Refreshed regularly (daily/weekly)
- Negative SOH = system error (investigate)
- Very high SOH = SLOB risk
- Very low SOH = stock-out risk

**Related Fields:**
- GIT_{YYYYMM} (goods in transit)
- Total_FC_SI_{YYYYMM} (demand)
- SLOB_Flag (risk indicator)

---

### 11.2 GIT_{YYYYMM}

**Column Pattern:** `GIT_YYYYMM` (Goods-In-Transit)
**Number of Columns:** 18
**Data Type:** Numeric (Integer)
**Format:** Whole numbers
**Nullable:** No (default 0)

**Definition:**
Số lượng hàng đã ship nhưng chưa đến warehouse/điểm bán.

**Source:**
- System: SAP ERP
- Transaction: Shipment tracking, PO in-transit
- Stored Procedure: sp_FC_GIT_New
- Update Frequency: Daily or Weekly

**Components:**
```
GIT includes:
├─ Plant to DC transfer (domestic)
├─ International imports (sea/air freight)
├─ DC to DC transfer
└─ In-transit to customers (some cases)
```

**Calculation Example:**
```
Product: 12345678
Date: 01-Feb-2025

In-transit shipments:
1. Plant VN01 → DC Hanoi: 300 units (ETA: 3 days)
2. Import from France: 1,000 units (ETA: 25 days)
3. DC HCM → DC Danang: 200 units (ETA: 2 days)

GIT_202502 = 300 + 1,000 + 200 = 1,500 units
```

**Sample Data:**
```
Month     | GIT   | SOH   | Total_Stock | Lead_Time
──────────┼───────┼───────┼─────────────┼───────────────
GIT_202501| 500   | 4,200 | 4,700       | 5-7 days avg
GIT_202502| 1,500 | 3,500 | 5,000       | 20 days (import)
GIT_202503| 300   | 2,000 | 2,300       | 3 days
```

**Lead Time Impact:**
```
Shipment Type     | Lead Time  | Impact on GIT
──────────────────┼────────────┼────────────────────
Domestic transfer | 2-5 days   | Low GIT value
Regional import   | 7-14 days  | Medium GIT
Intercontinental  | 20-45 days | High GIT value
Air freight       | 3-7 days   | Medium-Low GIT
Sea freight       | 30-45 days | Very High GIT
```

**Business Use:**
```
Total Available Inventory = SOH + GIT

Example:
SOH: 2,000 units
GIT: 1,500 units (arriving in 5 days)
Total available: 3,500 units

If forecast next week: 800 units
→ Sufficient stock (3,500 > 800)
```

**Related Fields:**
- SOH_{YYYYMM}
- Total_FC_SI_{YYYYMM}

---

### 11.3 MTD_SI_{YYYYMM}

**Column Pattern:** `MTD_SI_YYYYMM` (Month-To-Date Sell-In)
**Number of Columns:** 18 (but only current month is populated)
**Data Type:** Numeric (Integer)
**Format:** Whole numbers
**Nullable:** Yes (future months blank)

**Definition:**
Actual Sell-In từ đầu tháng đến ngày hiện tại (running total).

**Source:**
- System: SAP ERP
- Transaction: Daily sales/shipment transactions
- Stored Procedure: sp_tag_update_wf_mtd_si_NEW
- Update Frequency: Daily

**Calculation:**
```
MTD_SI_YYYYMM = SUM(Daily_SI)
WHERE Invoice_Date >= First_Day_of_Month
  AND Invoice_Date <= Current_Date
  AND Product = {Product_Code}
```

**Example:**
```
Product: 12345678
Current Date: 15-Feb-2025
Month: 202502

Daily Sell-In:
Feb 01: 35 units
Feb 02: 40 units
Feb 03: 38 units
...
Feb 14: 42 units
Feb 15: 35 units (today)

MTD_SI_202502 = Sum(Feb 01 to Feb 15) = 565 units

Full month forecast: 1,200 units
Days elapsed: 15/28 = 53.6%
Expected MTD: 1,200 * 53.6% = 643 units
Actual MTD: 565 units
Variance: 565 - 643 = -78 units (-12.1% behind)
```

**Sample Data:**
```
Date     | MTD_SI  | Forecast | % Month | % Achieve | Status
─────────┼─────────┼──────────┼─────────┼───────────┼─────────────
Feb 05   | 180     | 1,200    | 18%     | 15%       | Behind
Feb 10   | 380     | 1,200    | 36%     | 32%       | Behind
Feb 15   | 565     | 1,200    | 54%     | 47%       | Behind
Feb 20   | 780     | 1,200    | 71%     | 65%       | Catching up
Feb 25   | 1,020   | 1,200    | 89%     | 85%       | On track
Feb 28   | 1,150   | 1,200    | 100%    | 96%       | Nearly achieved
```

**Achievement Calculation:**
```
% Achievement = (MTD_SI / Full_Month_Forecast) * 100%

Target: Should be close to % of month elapsed
Example at Day 15 of 28-day month:
Expected %: 15/28 = 53.6%
Actual %: 565/1200 = 47.1%
Gap: -6.5 percentage points
```

**Business Use:**
- **Daily tracking** - Am I on track?
- **Early warning** - Will we miss forecast?
- **Action trigger** - Need promotional push?
- **Forecast adjustment** - Update remainder of month

**Forecast Revision:**
```
If MTD significantly behind, may need to revise full month:

Day 15 Analysis:
MTD Actual: 565 units
Expected: 643 units
Behind by: 12%

Forecast remainder (16 days):
Original: 635 units
Adjusted (12% haircut): 635 * 0.88 = 559 units

Revised full month: 565 + 559 = 1,124 units
(vs original 1,200)
```

**Related Fields:**
- Total_FC_SI_{YYYYMM} (full month forecast)
- Actual_{YYYYMM} (will become this after month close)

---

## GROUP 12: Analysis & Flags

### 12.1 Risk_Flag_{YYYYMM}

**Column Pattern:** `Risk_Flag_YYYYMM`
**Number of Columns:** 18
**Data Type:** Text (String)
**Format:** Predefined values
**Nullable:** Yes

**Definition:**
Cờ cảnh báo forecast risk level dựa trên variance analysis.

**Source:**
- System: Calculated field
- Stored Procedure: sp_fc_fm_risk_3M
- Calculation: Rule-based on multiple criteria
- Update: Auto-calculated when WF generated/updated

**Valid Values:**
```
Value        | Color  | Meaning
─────────────┼────────┼────────────────────────────────────
HIGH         | Red    | High forecast risk - needs review
MEDIUM       | Yellow | Medium risk - monitor closely
LOW          | Green  | Low risk - acceptable variance
NONE / Blank | -      | No significant risk detected
```

**Risk Criteria:**

**HIGH Risk Triggers:**
```
1. Forecast > 200% of historical average
   Example: Avg = 1,000, FC = 2,500 (+150%)

2. Forecast > 150% of budget
   Example: Budget = 1,000, FC = 1,800 (+80%)

3. New launch with very high pipeline fill
   Example: FC_M1 = 10,000 (unusual volume)

4. Large promotional uplift without justification
   Example: Promo uplift = +300% vs baseline

5. Negative forecast (error)
   Example: FC = -100 (system error)
```

**MEDIUM Risk Triggers:**
```
1. Forecast 120-200% of historical
   Example: Avg = 1,000, FC = 1,500 (+50%)

2. Forecast 110-150% of budget
   Example: Budget = 1,000, FC = 1,300 (+30%)

3. Large month-to-month variance
   Example: M1 = 1,000, M2 = 2,000 (+100%)

4. Discontinued product with forecast > 0
   Example: Status = Discontinue, but FC = 500
```

**LOW Risk:**
```
Forecast within normal ranges:
- 80-120% of historical average
- 90-110% of budget
- Stable month-to-month trend
- Reasonable promotional uplifts
```

**Example Calculations:**
```
Product: 12345678
Month: 202502

Historical Average (6M): 1,100 units
Budget: 1,150 units
Forecast: 2,500 units

Analysis:
├─ vs Historical: 2,500 / 1,100 = 227% (HIGH trigger)
├─ vs Budget: 2,500 / 1,150 = 217% (HIGH trigger)
└─ M-o-M variance: Feb vs Jan = 2,500 / 1,200 = 208%

Risk_Flag_202502 = HIGH

Reason: Valentine promotional campaign
Expected uplift: +120% during promo period
Justification required: Yes
```

**Sample Data:**
```
Product  | Month      | Forecast | Budget | Risk  | Reason
─────────┼────────────┼──────────┼────────┼───────┼──────────────────
12345678 | 202501     | 1,200    | 1,150  | LOW   | Normal
12345678 | 202502     | 2,500    | 1,150  | HIGH  | Valentine promo
12345678 | 202503     | 1,100    | 1,000  | LOW   | Back to normal
23456789 | 202502     | 5,000    | 2,000  | HIGH  | New launch M1
34567890 | 202503     | 800      | 1,500  | MEDIUM| Declining trend
```

**Action Required by Risk Level:**
```
HIGH:
→ Must add comment with explanation
→ May require manager approval
→ Finance review for budget impact
→ Supply planning contingency

MEDIUM:
→ Recommended to add comment
→ Monitor closely
→ Ready to adjust if needed

LOW:
→ No action required
→ Standard tracking
```

**Related Fields:**
- Total_FC_SI_{YYYYMM}
- Budget_{YYYYMM}
- Actual historical columns

---

### 12.2 SLOB_Flag

**Column Name:** `SLOB_Flag` (Slow & Obsolete)
**Number of Columns:** 1 (product-level, not monthly)
**Data Type:** Text (String)
**Format:** YES / NO
**Nullable:** No (default NO)

**Definition:**
Cờ đánh dấu sản phẩm có rủi ro slow-moving hoặc obsolete.

**Source:**
- System: Calculated field
- Stored Procedure: sp_tag_update_slob_wf
- Calculation: Rule-based on DOS, forecast, status
- Update: Monthly

**SLOB Criteria:**
```
Product is flagged SLOB if ANY of:

1. DOS (Days of Supply) > 180 days
   SOH / Avg_Monthly_Forecast * 30 > 180

2. Monthly Forecast < 10 units
   (Very low demand)

3. Product Status = 'Discontinue'
   (Being phased out)

4. No sales for last 3+ months
   Actual_M1 = 0 AND Actual_M2 = 0 AND Actual_M3 = 0

5. SOH > 12 months of forecast
   SOH / Forecast > 12
```

**Example 1: High DOS**
```
Product: 45678901 (Old Cream ABC)
Current SOH: 6,000 units
Monthly forecast: 100 units
DOS = (6,000 / 100) * 30 = 1,800 days (60 months!)

SLOB_Flag = YES
Reason: Extremely high DOS (>180 days threshold)
Action: Clearance sale, discontinue, or NPD replacement
```

**Example 2: Discontinue Status**
```
Product: 56789012 (Seasonal Product 2023)
Status: Discontinue
SOH: 500 units
Forecast: 0 units

SLOB_Flag = YES
Reason: Discontinue status
Action: Rundown plan, clear remaining stock
```

**Example 3: Low Movement**
```
Product: 67890123 (Niche Product)
Monthly forecast: 5 units (very low)
Last 3 months actual: [3, 2, 4]

SLOB_Flag = YES
Reason: Forecast < 10 units threshold
Action: Consider discontinue or regional focus
```

**Sample Data:**
```
Product  | SOH   | Forecast | DOS   | Status      | SLOB | Action
─────────┼───────┼──────────┼───────┼─────────────┼──────┼─────────────────
12345678 | 2,000 | 1,200    | 50    | Active      | NO   | -
45678901 | 6,000 | 100      | 1,800 | Active      | YES  | Clearance
56789012 | 500   | 0        | N/A   | Discontinue | YES  | Rundown
67890123 | 300   | 5        | 1,800 | Active      | YES  | Review
78901234 | 0     | 0        | N/A   | Inactive    | NO   | Archived
```

**Financial Impact:**
```
SLOB inventory has several impacts:

1. Carrying Cost:
   - Warehouse space
   - Handling
   - Insurance

2. Obsolescence Risk:
   - Expiry
   - Damage
   - Out of fashion

3. Cash Flow:
   - Cash tied up in dead stock
   - Write-off potential

4. P&L Impact:
   - Inventory provision
   - Disposal cost
   - Clearance discounts
```

**Action Plan for SLOB:**
```
SLOB_Flag = YES → Trigger actions:

Step 1: Root Cause Analysis
- Why is it SLOB?
- Over-forecasted?
- Cannibalization by new product?
- Market shift?

Step 2: Determine Fate
Option A: Clearance Sale
- Deep discount to move stock
- Bundle with popular products
- Donate to charity

Option B: Discontinue
- Stop production
- Rundown plan
- Clear remaining inventory

Option C: Repositioning
- New marketing angle
- Different channel focus
- Export to other markets

Step 3: Prevent Future SLOB
- Improve forecast accuracy
- Better new launch planning
- Faster discontinuation decisions
```

**SLOB Tracking Metrics:**
```
Monthly SLOB Report:
┌────────────────────────────────────────────┐
│ Division SLOB Summary - Feb 2025           │
├────────────────────────────────────────────┤
│ Total Products: 1,245                      │
│ SLOB Products: 85 (6.8%)                   │
│                                            │
│ SLOB Inventory Value:                      │
│ ├─ High DOS: 45 products (2.5B VND)       │
│ ├─ Discontinue: 25 products (800M VND)    │
│ ├─ Low Movement: 15 products (300M VND)   │
│ └─ Total: 3.6B VND (12% of total inv)     │
│                                            │
│ Actions Planned:                           │
│ ├─ Clearance Sale: 30 products            │
│ ├─ Discontinue: 40 products                │
│ └─ Under Review: 15 products               │
└────────────────────────────────────────────┘
```

**Related Fields:**
- SOH (inventory level)
- Total_FC_SI (forecast)
- Status (product status)
- DOS calculation (derived)

---

### 12.3 Gap_FC_vs_Budget_{YYYYMM}

**Column Pattern:** `Gap_FC_vs_Budget_YYYYMM`
**Number of Columns:** 18
**Data Type:** Numeric (Integer)
**Format:** Whole numbers (can be negative)
**Nullable:** No (default 0)

**Definition:**
Variance giữa Total Forecast Sell-In và Budget (FC - Budget).

**Source:**
- System: Calculated field
- Formula: Total_FC_SI - Budget
- Purpose: Gap analysis, variance explanation

**Calculation:**
```
Gap_FC_vs_Budget_YYYYMM =
  Total_FC_SI_YYYYMM - Budget_YYYYMM

Positive (+): Forecast > Budget (over budget)
Negative (-): Forecast < Budget (under budget)
Zero (0): Aligned
```

**Example 1: Positive Gap (Over Budget)**
```
Product: 12345678
Month: 202502

Total_FC_SI_202502: 2,500 units
Budget_202502: 1,150 units
─────────────────────────────────
Gap: 2,500 - 1,150 = +1,350 units

Gap %: (1,350 / 1,150) * 100% = +117.4%

Reason: Valentine promotional campaign
Expected: Temporary spike, will normalize M+1
Action: Explain to Finance, ensure supply ready
```

**Example 2: Negative Gap (Under Budget)**
```
Product: 23456789
Month: 202504

Total_FC_SI_202504: 800 units
Budget_202504: 1,200 units
─────────────────────────────────
Gap: 800 - 1,200 = -400 units

Gap %: (-400 / 1,200) * 100% = -33.3%

Reason: Product declining, cannibalized by new SKU
Expected: Downward trend continues
Action: Revise budget downward for remainder of year
```

**Sample Data:**
```
Month      | Forecast | Budget | Gap     | Gap %   | Status
───────────┼──────────┼────────┼─────────┼─────────┼──────────────
202501     | 1,200    | 1,150  | +50     | +4.3%   | Aligned
202502     | 2,500    | 1,150  | +1,350  | +117.4% | Over (promo)
202503     | 1,100    | 1,000  | +100    | +10.0%  | Slight over
202504     | 800      | 1,200  | -400    | -33.3%  | Under
202505     | 1,050    | 1,000  | +50     | +5.0%   | Aligned
```

**Gap Categorization:**
```
Gap %           | Category      | Action Required
────────────────┼───────────────┼─────────────────────────────
-10% to +10%    | ALIGNED       | None (acceptable variance)
+10% to +20%    | SLIGHT OVER   | Monitor, brief explanation
-10% to -20%    | SLIGHT UNDER  | Monitor, brief explanation
+20% to +50%    | OVER          | Detailed explanation required
-20% to -50%    | UNDER         | Detailed explanation required
> +50%          | SIGNIFICANT   | Management review + approval
< -50%          | SIGNIFICANT   | Management review + approval
```

**Division-Level Gap Analysis:**
```
CPD Division - Feb 2025 Gap Summary:
┌──────────────────────────────────────────────────┐
│ Category         | FC      | Budget  | Gap      │
├──────────────────┼─────────┼─────────┼──────────┤
│ Hair Care        | 65,000  | 55,000  | +10,000  │
│ Skin Care        | 35,000  | 30,000  | +5,000   │
│ Make-up          | 40,000  | 35,000  | +5,000   │
│ Fragrance        | 5,000   | 5,000   | 0        │
├──────────────────┼─────────┼─────────┼──────────┤
│ TOTAL            | 145,000 | 125,000 | +20,000  │
│                  |         |         | (+16%)   │
└──────────────────────────────────────────────────┘

Overall: 16% over budget
Main driver: Hair Care promo campaigns
Action: Finance alignment meeting scheduled
```

**Gap Explanation Template:**
```
For products with |Gap| > 20%:

Product: {Product_Code} - {Product_Name}
Period: {YYYYMM}
Forecast: {FC_SI} units
Budget: {Budget} units
Gap: {Gap} units ({Gap_%}%)

Reason for Variance:
[ ] Promotional campaign (details: ...)
[ ] New product launch
[ ] Market opportunity
[ ] Competitive response
[ ] Budget was set conservatively
[ ] Product declining faster than budget
[ ] Cannibalization by new SKU
[ ] Market headwind
[ ] Other: ...

Corrective Action:
[ ] One-time variance, will normalize
[ ] Request budget revision for year
[ ] Adjust supply plan accordingly
[ ] Review pricing strategy
[ ] Other: ...

Approved by: {Manager} Date: {Date}
```

**Monthly Gap Trend:**
```
Track gap trend across months:

Product: 12345678

Month  | FC    | Budget | Gap   | Gap % | Trend
───────┼───────┼────────┼───────┼───────┼────────────
202501 | 1,200 | 1,150  | +50   | +4%   | Aligned
202502 | 2,500 | 1,150  | +1,350| +117% | Spike (promo)
202503 | 1,100 | 1,000  | +100  | +10%  | Normalized
202504 | 1,000 | 1,050  | -50   | -5%   | Aligned
202505 | 1,050 | 1,000  | +50   | +5%   | Stable

Interpretation:
- Feb spike due to Valentine promo (expected)
- Returned to normal in Mar
- Overall trending aligned with budget
- No structural issue
```

**Financial Planning Impact:**
```
Revenue Impact of Gap:

Product: 12345678
ASP (Average Selling Price): 50,000 VND
Gap (units): +1,350

Revenue Gap = 1,350 * 50,000 = 67,500,000 VND

Division Level:
Total Gap: +20,000 units
ASP: 45,000 VND
Revenue Gap: +900,000,000 VND (~$38k USD)

→ Finance needs to revise revenue forecast
→ May impact P&L, targets, bonuses
```

**Related Fields:**
- Total_FC_SI_{YYYYMM}
- Budget_{YYYYMM}
- Risk_Flag_{YYYYMM}

---

## 📊 Summary Statistics

### Working File Column Count by Group

```
Group                        | Columns | % of Total
─────────────────────────────┼─────────┼───────────
1. Product Information       | 10      | 2.6%
2. Historical Actuals        | 24      | 6.2%
3. Baseline Forecast         | 18      | 4.6%
4. Promotional Forecasts     | 36      | 9.2%
5. New Launch Forecasts      | 18      | 4.6%
6. FOC Forecasts             | 18      | 4.6%
7. Promo BOM Forecasts       | 18      | 4.6%
8. OPTIMUS Sell-In           | 18      | 4.6%
9. Budget Data               | 54      | 13.8%
10. SI Calculations          | 90      | 23.1%
11. Inventory & Actuals      | 54      | 13.8%
12. Analysis & Flags         | 36      | 9.2%
─────────────────────────────┼─────────┼───────────
TOTAL                        | 390+    | 100%
```

### Data Sources Summary

```
Source System        | Groups Affected           | Update Frequency
─────────────────────┼───────────────────────────┼─────────────────
SAP ERP              | 2, 11                     | Daily/Monthly
OPTIMUS              | 8, 10                     | Weekly
FM Excel Files       | 4, 5, 6, 7                | Monthly/As-needed
Finance System       | 9                         | Annually
Product Master       | 1                         | As-needed
Forecasting Tool     | 3, 10, 12                 | On WF generation
```

### Editability Summary

```
Type                 | Groups        | User Can Edit?
─────────────────────┼───────────────┼────────────────────────
Master Data          | 1             | ❌ No (read-only)
Historical Actuals   | 2             | ❌ No (SAP source)
Baseline Forecast    | 3             | ⚠️ Yes (with caution)
Promo/Launch/FOC     | 4, 5, 6, 7    | ✅ Yes (business input)
Budget               | 9             | ❌ No (Finance owns)
Calculated SI        | 10            | ❌ No (formula)
Inventory/MTD        | 11            | ❌ No (SAP source)
Flags                | 12            | ❌ No (auto-calculated)
```

---

## 📋 Field Usage Examples

### Complete Product Example

**Product:** 12345678 - L'Oréal Paris Shampoo Smooth & Shine 400ml
**Period:** Feb 2025 (202502)
**Division:** CPD
**Category:** Hair Care → Shampoo

```
┌─────────────────────────────────────────────────────────┐
│ GROUP 1: PRODUCT INFORMATION                            │
├─────────────────────────────────────────────────────────┤
│ Product_Code: 12345678                                  │
│ Product_Name: L'Oréal Paris Shampoo Smooth & Shine 400ml│
│ Brand: L'Oréal Paris                                    │
│ Category: Hair Care                                     │
│ Sub_Category: Shampoo                                   │
│ Division: CPD                                           │
│ Product_Type: Regular                                   │
│ Unit_of_Measure: EA                                     │
│ Status: Active                                          │
│ Packaging: 400ml bottle                                 │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ GROUP 2: HISTORICAL (Last 6 months sample)              │
├─────────────────────────────────────────────────────────┤
│ Actual_202309: 1,000 units                              │
│ Actual_202310: 1,050 units                              │
│ Actual_202311: 1,100 units                              │
│ Actual_202312: 1,080 units                              │
│ Actual_202501: 1,200 units                              │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ GROUP 3: BASELINE FORECAST                              │
├─────────────────────────────────────────────────────────┤
│ FC_Baseline_202502: 1,100 units                         │
│ (Statistical model: 6M avg * trend * seasonality)       │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ GROUP 4: PROMOTIONAL                                    │
├─────────────────────────────────────────────────────────┤
│ FC_Promo_Single_Offline_202502: 1,200 units            │
│ FC_Promo_Single_Online_202502: 300 units               │
│ (Valentine promo: Buy 1 Get 1, 14 days)                 │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ GROUP 5: NEW LAUNCH                                     │
├─────────────────────────────────────────────────────────┤
│ FC_Launch_Single_202502: 0 units                        │
│ (Not a new launch product)                              │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ GROUP 6: FOC                                            │
├─────────────────────────────────────────────────────────┤
│ FC_FOC_202502: 100 units                                │
│ (Sample sachets for counter sampling)                   │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ GROUP 7: PROMO BOM                                      │
├─────────────────────────────────────────────────────────┤
│ FC_Promo_BOM_Component_202502: 300 units               │
│ (Used in "Valentine Hair Care Set")                     │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ GROUP 8: OPTIMUS                                        │
├─────────────────────────────────────────────────────────┤
│ FC_SI_OPTIMUS_202502: 0 units                           │
│ (Uses baseline instead, not OPTIMUS-driven)             │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ GROUP 9: BUDGET                                         │
├─────────────────────────────────────────────────────────┤
│ Budget_202502: 1,150 units                              │
│ Pre_Budget_202502: 1,200 units                          │
│ Budget_Trend_202502: 1,080 units                        │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ GROUP 10: SI CALCULATIONS                               │
├─────────────────────────────────────────────────────────┤
│ SI_Promo_Single_202502: 1,500 (1,200+300)              │
│ SI_FOC_202502: 100                                      │
│ SI_Launch_Single_202502: 0                              │
│ SI_Promo_BOM_202502: 300                                │
│ SI_OPTIMUS_202502: 0                                    │
│ ───────────────────────────────────────────             │
│ Total_FC_SI_202502: 3,000 units                         │
│ (Baseline 1,100 + Promo 1,500 + FOC 100 + BOM 300)     │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ GROUP 11: INVENTORY & ACTUALS                           │
├─────────────────────────────────────────────────────────┤
│ SOH_202502: 3,500 units                                 │
│ GIT_202502: 500 units                                   │
│ MTD_SI_202502: 565 units (as of Day 15)                │
│ DOS: 35 days (healthy)                                  │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ GROUP 12: ANALYSIS                                      │
├─────────────────────────────────────────────────────────┤
│ Risk_Flag_202502: HIGH                                  │
│ (FC 161% above budget due to promo)                     │
│                                                         │
│ SLOB_Flag: NO                                           │
│ (DOS = 35 days, healthy range)                          │
│                                                         │
│ Gap_FC_vs_Budget_202502: +1,850 units (+160.9%)        │
│ Explanation: Valentine promotional campaign            │
│ Expected to normalize in Mar                            │
└─────────────────────────────────────────────────────────┘
```

---

## 📘 Document Information

**Title:** Data Dictionary Part 2 - Forecasting Tool Working File
**Version:** 1.0
**Date:** 2025-11-18
**Owner:** L'Oréal Vietnam Demand Planning Team
**Coverage:** Groups 10-12 (SI Calculations, Inventory, Analysis)
**Total Fields Documented (Part 1 + 2):** 390+ fields

**Related Documents:**
- Part 1: Groups 1-9 (Product Info, Historical, Forecast Inputs, Budget)
- Data Source & Mapping Guide
- Business Process Flow
- User Guide

**For Support:** dp.support@loreal.com
