# Data Dictionary - Forecasting Tool Working File

## 📌 Giới Thiệu

Tài liệu này mô tả chi tiết **từng field/column** trong Working File của Forecasting Tool, bao gồm:
- Định nghĩa và ý nghĩa
- Nguồn dữ liệu
- Format và data type
- Business rules
- Ví dụ cụ thể

**Đối tượng:** Business Users, Data Analysts, IT Support

---

## 📊 Working File Structure Overview

Working File gồm **12 nhóm columns** chính:

```
┌────────────────────────────────────────────────────────────┐
│  GROUP 1: Product Information (10 columns)                 │
│  GROUP 2: Historical Actuals (24 columns)                  │
│  GROUP 3: Baseline Forecast (18 columns)                   │
│  GROUP 4: Promotional Forecasts (36 columns)               │
│  GROUP 5: New Launch Forecasts (18 columns)                │
│  GROUP 6: FOC Forecasts (18 columns)                       │
│  GROUP 7: Promo BOM Forecasts (18 columns)                 │
│  GROUP 8: OPTIMUS Sell-In (18 columns)                     │
│  GROUP 9: Budget Data (54 columns)                         │
│  GROUP 10: Sell-In Calculations (90 columns)               │
│  GROUP 11: Inventory & Actuals (54 columns)                │
│  GROUP 12: Analysis & Flags (36 columns)                   │
└────────────────────────────────────────────────────────────┘

Total: ~390 columns (varies by configuration)
```

---

## GROUP 1: Product Information

### 1.1 Product_Code

**Column Name:** `Product_Code`
**Column Position:** A
**Data Type:** Text (String)
**Length:** 8 characters
**Format:** Numeric string
**Nullable:** No (Required)

**Definition:**
Mã sản phẩm SAP duy nhất, identifier chính cho mỗi SKU.

**Source:**
- System: SAP Material Master
- Table: Product_Master
- Field: MATNR (Material Number)

**Business Rules:**
- Must be 8 digits
- Must exist in Product Master
- Unique per row
- No duplicates allowed in WF

**Valid Values:**
```
Format: ########
Example: 12345678
Range: 10000000 - 99999999
```

**Invalid Examples:**
```
❌ ABC12345 (contains letters)
❌ 123456 (too short)
❌ 123456789 (too long)
❌ (blank) (required field)
```

**Sample Data:**
```
12345678
23456789
34567890
45678901
```

**Related Fields:**
- Product_Name (Column B)
- Brand (Column C)
- Category (Column D)

---

### 1.2 Product_Name

**Column Name:** `Product_Name`
**Column Position:** B
**Data Type:** Text (String)
**Length:** Max 100 characters
**Format:** Free text
**Nullable:** No (Required)

**Definition:**
Tên đầy đủ của sản phẩm, bao gồm brand, variant, và size.

**Source:**
- System: SAP Material Master
- Table: Product_Master
- Field: MAKTX (Material Description)

**Business Rules:**
- Must not be blank
- Should include size/variant info
- Standard naming convention: [Brand] [Product Type] [Variant] [Size]

**Format Convention:**
```
Pattern: {Brand} {Product_Type} {Variant} {Size}
Example: L'Oréal Paris Shampoo Smooth & Shine 400ml
```

**Sample Data:**
```
L'Oréal Paris Shampoo Smooth & Shine 400ml
Garnier Micellar Water All Skin Types 400ml
Maybelline SuperStay Matte Ink Lipstick 5ml - Shade 20
Lancôme Advanced Génifique Serum 50ml
Kiehl's Ultra Facial Cream 50ml
```

**Related Fields:**
- Product_Code (Column A)
- Brand (Column C)
- Packaging (Column J)

---

### 1.3 Brand

**Column Name:** `Brand`
**Column Position:** C
**Data Type:** Text (String)
**Length:** Max 50 characters
**Format:** Predefined list
**Nullable:** No (Required)

**Definition:**
Thương hiệu của sản phẩm thuộc portfolio L'Oréal.

**Source:**
- System: SAP Material Master
- Table: Product_Master
- Field: Brand_Code → Brand_Master.Brand_Name

**Business Rules:**
- Must be from approved brand list
- One product = one brand only
- Brand must be active

**Valid Brand List (CPD Division):**
```
Consumer Products Division (CPD):
├─ L'Oréal Paris
├─ Garnier
├─ Maybelline
├─ Essie
└─ NYX Professional Makeup

Luxury Division (LDB):
├─ Lancôme
├─ Yves Saint Laurent
├─ Giorgio Armani
├─ Kiehl's
├─ Urban Decay
└─ Shu Uemura

Professional Products (PPD):
├─ L'Oréal Professionnel
├─ Kérastase
├─ Redken
└─ Matrix
```

**Sample Data:**
```
L'Oréal Paris
Garnier
Maybelline
Lancôme
Kiehl's
```

**Related Fields:**
- Division (Column F)
- Category (Column D)

---

### 1.4 Category

**Column Name:** `Category`
**Column Position:** D
**Data Type:** Text (String)
**Length:** Max 50 characters
**Format:** Predefined list
**Nullable:** No (Required)

**Definition:**
Danh mục sản phẩm cấp cao (product category).

**Source:**
- System: SAP Material Master
- Table: Product_Master
- Field: Category_Code → Category_Master.Category_Name

**Business Rules:**
- Must be from approved category list
- Category aligned with Division
- Hierarchical structure: Division → Category → Sub-Category

**Valid Category List:**
```
Hair Care:
├─ Shampoo
├─ Conditioner
├─ Hair Treatment
├─ Hair Styling
└─ Hair Color

Skin Care:
├─ Cleanser
├─ Toner
├─ Serum
├─ Moisturizer
├─ Sun Care
└─ Mask

Make-up:
├─ Face (Foundation, Powder, Concealer)
├─ Eyes (Eyeshadow, Mascara, Eyeliner)
├─ Lips (Lipstick, Lip Gloss, Lip Liner)
└─ Nails (Nail Polish, Nail Care)

Fragrance:
├─ Eau de Parfum
├─ Eau de Toilette
└─ Body Spray
```

**Sample Data:**
```
Hair Care
Skin Care
Make-up
Fragrance
```

**Related Fields:**
- Sub_Category (Column E)
- Division (Column F)

---

### 1.5 Sub_Category

**Column Name:** `Sub_Category`
**Column Position:** E
**Data Type:** Text (String)
**Length:** Max 50 characters
**Format:** Predefined list
**Nullable:** Yes (Optional)

**Definition:**
Danh mục sản phẩm chi tiết (sub-category) thuộc Category.

**Source:**
- System: SAP Material Master
- Table: Product_Master
- Field: Sub_Category_Code → Sub_Category_Master.Sub_Category_Name

**Business Rules:**
- Must be valid sub-category under parent Category
- Can be blank for products without sub-category
- Hierarchical: Category → Sub_Category

**Valid Sub-Category Examples:**
```
Category: Hair Care
├─ Sub-Category: Shampoo
├─ Sub-Category: Conditioner
├─ Sub-Category: Hair Mask
└─ Sub-Category: Hair Oil

Category: Make-up
├─ Sub-Category: Foundation
├─ Sub-Category: Lipstick
├─ Sub-Category: Mascara
└─ Sub-Category: Eyeshadow Palette
```

**Sample Data:**
```
Shampoo
Foundation
Lipstick
Serum
Moisturizer
```

**Related Fields:**
- Category (Column D)

---

### 1.6 Division

**Column Name:** `Division`
**Column Position:** F
**Data Type:** Text (String - Code)
**Length:** 3 characters
**Format:** Fixed code
**Nullable:** No (Required)

**Definition:**
Bộ phận kinh doanh quản lý sản phẩm.

**Source:**
- System: SAP Material Master
- Table: Product_Master
- Field: Division_Code

**Valid Values:**
```
Code | Full Name                        | Description
─────┼──────────────────────────────────┼─────────────────────────
CPD  | Consumer Products Division       | Mass market products
LDB  | Luxury Division Brand            | Luxury/Premium brands
PPD  | Professional Products Division   | Salon professional
LLD  | L'Oréal Luxe Division           | Ultra-premium luxury
```

**Business Rules:**
- Must be one of: CPD, LDB, PPD, LLD
- Division determines:
  - User access rights
  - Forecast approval workflow
  - Budget allocation
  - Reporting hierarchy

**Sample Data:**
```
CPD
LDB
PPD
```

**Related Fields:**
- Brand (Column C)
- Category (Column D)

---

### 1.7 Product_Type

**Column Name:** `Product_Type`
**Column Position:** G
**Data Type:** Text (String)
**Length:** Max 30 characters
**Format:** Predefined list
**Nullable:** No (Required)

**Definition:**
Phân loại sản phẩm theo lifecycle và business context.

**Source:**
- System: Product_Master / Manual classification
- Table: Product_Master
- Field: Product_Type_Code

**Valid Values:**
```
Type          | Description                           | Forecast Approach
──────────────┼───────────────────────────────────────┼──────────────────────
Regular       | Established product, ongoing sales    | Statistical baseline
NPD           | New Product Development (new launch)  | Launch curve model
Promo         | Promotional item/pack                 | Campaign-based
Promo_BOM     | Promotional kit/set (BOM)            | BOM explosion
FOC           | Free of Charge (samples, GWP)        | Campaign quantity
Discontinue   | Product being phased out             | Rundown plan
Seasonal      | Seasonal product (e.g., Tết edition) | Seasonal pattern
Project       | Project-specific (B2B, events)       | Project forecast
```

**Business Rules:**
- Regular products: Use historical baseline + adjustments
- NPD: Use launch plan, no historical
- Discontinue: Forecast = 0 or rundown plan
- FOC: No revenue, pure volume forecast

**Sample Data:**
```
Regular
NPD
Promo
FOC
Discontinue
```

**Related Fields:**
- Status (Column I)

---

### 1.8 Unit_of_Measure (UoM)

**Column Name:** `Unit_of_Measure`
**Column Position:** H
**Data Type:** Text (String - Code)
**Length:** 3 characters
**Format:** Fixed code
**Nullable:** No (Required)

**Definition:**
Đơn vị tính của sản phẩm, dùng cho tất cả số liệu forecast và actual.

**Source:**
- System: SAP Material Master
- Table: Product_Master
- Field: MEINS (Base Unit of Measure)

**Valid Values:**
```
Code | Full Name  | Usage
─────┼────────────┼─────────────────────────────────
EA   | Each       | Individual units (most common)
CS   | Case       | Cases (for bulk items)
KG   | Kilogram   | Weight-based (rare)
LTR  | Liter      | Volume-based (rare)
SET  | Set        | Multi-piece sets
```

**Business Rules:**
- 95%+ của products dùng "EA" (Each)
- Must be consistent across all columns
- Conversion từ CS → EA nếu cần: CS * Items_per_Case

**Sample Data:**
```
EA
EA
EA
CS
SET
```

**Related Fields:**
- All forecast và actual columns

---

### 1.9 Status

**Column Name:** `Status`
**Column Position:** I
**Data Type:** Text (String)
**Length:** Max 20 characters
**Format:** Predefined list
**Nullable:** No (Required)

**Definition:**
Trạng thái lifecycle của sản phẩm.

**Source:**
- System: Product_Master
- Table: Product_Master
- Field: Status_Code

**Valid Values:**
```
Status          | Description                    | Forecast Action
────────────────┼────────────────────────────────┼─────────────────────────
Active          | Active, ongoing sales          | Full forecast
New             | Newly launched (<6 months)     | Launch forecast
Discontinue     | Being phased out               | Rundown plan
Inactive        | No longer sold                 | Zero forecast
Blocked         | Temporarily blocked            | Zero forecast
Phase_Out_Plan  | Scheduled discontinuation      | Declining forecast
```

**Business Rules:**
- Active: Normal forecasting
- New: Use NPD launch model
- Discontinue/Inactive: Forecast = 0 or clearance qty
- Status change triggers forecast review

**Sample Data:**
```
Active
Active
New
Discontinue
Active
```

**Related Fields:**
- Product_Type (Column G)
- SLOB_Flag (analysis column)

---

### 1.10 Packaging

**Column Name:** `Packaging`
**Column Position:** J
**Data Type:** Text (String)
**Length:** Max 50 characters
**Format:** Free text (standardized)
**Nullable:** Yes (Optional)

**Definition:**
Mô tả quy cách đóng gói của sản phẩm (size, format, material).

**Source:**
- System: SAP Material Master
- Table: Product_Master
- Field: Packaging_Description

**Format Convention:**
```
Pattern: {Size}{Unit} {Container_Type}
Examples:
- 400ml bottle
- 50ml jar
- 5ml tube
- 100g bar
- 200ml pump bottle
```

**Sample Data:**
```
400ml bottle
50ml jar
30ml tube
150g tube
200ml pump dispenser
5ml lipstick
15ml nail polish bottle
1.5g lipstick
```

**Business Rules:**
- Should include size + container
- Helps identify SKU variants
- Used for shelf space planning

**Related Fields:**
- Product_Name (Column B)
- Sub_Category (Column E)

---

## GROUP 2: Historical Actuals (24 months)

### 2.1 Actual_{YYYYMM} Columns

**Column Pattern:** `Actual_YYYYMM`
**Number of Columns:** 24 (rolling 24 months)
**Data Type:** Numeric (Integer)
**Format:** Whole numbers
**Nullable:** Yes (can be 0 or blank for inactive periods)

**Definition:**
Số lượng actual Sell-In từ SAP cho từng tháng lịch sử.

**Example Columns (for Period 202502):**
```
Column K:  Actual_202302 (Feb 2023)
Column L:  Actual_202303 (Mar 2023)
Column M:  Actual_202304 (Apr 2023)
...
Column AG: Actual_202501 (Jan 2025)
```

**Source:**
- System: SAP ERP
- Transaction: ZV14_02 (Invoice data)
- Aggregation: Sum of daily invoices by Product + Month
- Update Frequency: Monthly (after month close)

**Business Rules:**
- Read-only (cannot be edited by users)
- Actuals từ SAP là source of truth
- Zero (0) = No sales that month
- Blank/NULL = Product not active in that period

**Data Calculation:**
```sql
Actual_YYYYMM = SUM(Invoice_Quantity)
WHERE Product_Code = {Product_Code}
  AND Invoice_Date BETWEEN '{YYYY-MM-01}' AND '{YYYY-MM-last_day}'
  AND Document_Type = 'Invoice'
  AND Reversal_Flag = 'N'
GROUP BY Product_Code
```

**Sample Data (Product 12345678):**
```
Month       | Actual Value | Comments
────────────┼──────────────┼─────────────────────────
Actual_202301 | 1,000      | Regular month
Actual_202302 | 1,500      | Tết period (high)
Actual_202303 | 800        | Post-Tết (low)
Actual_202304 | 1,100      | Back to normal
Actual_202305 | 1,050      | Normal
Actual_202306 | 1,200      | Promo month
```

**Visual Indicator:**
- Cell Background: Gray (indicates read-only)
- Font: Regular black
- No borders

**Usage:**
- Input cho baseline forecast calculation
- Performance tracking (Actual vs Forecast)
- Trend analysis
- Seasonality detection

**Related Fields:**
- FC_Baseline columns (forecast based on these actuals)
- MTD_SI (month-to-date current month)

---

## GROUP 3: Baseline Forecast (18 months)

### 3.1 FC_Baseline_{YYYYMM} Columns

**Column Pattern:** `FC_Baseline_YYYYMM`
**Number of Columns:** 18 (forecast horizon)
**Data Type:** Numeric (Decimal)
**Format:** Decimal (up to 2 places)
**Nullable:** No (default 0)

**Definition:**
Dự báo baseline tự động generate từ statistical model dựa trên historical trend.

**Example Columns (for Period 202502):**
```
Column AH: FC_Baseline_202502 (Feb 2025)
Column AI: FC_Baseline_202503 (Mar 2025)
Column AJ: FC_Baseline_202504 (Apr 2025)
...
Column AY: FC_Baseline_202619 (Jul 2026)
```

**Source:**
- System: Forecasting Tool
- Stored Procedure: sp_Sum_FC_FM_baseLine_new / sp_Sum_FC_FM_baseLine_new_2
- Input: Historical Actual columns (24 months)
- Calculation: Statistical model (moving average + trend + seasonality)

**Business Rules:**
- Auto-calculated, but CAN be manually overridden
- For Regular products only
- NPD/New products: Baseline = 0 (use Launch forecast instead)
- Discontinue products: Baseline = 0

**Calculation Logic:**
```
Baseline Formula (simplified):
FC_Baseline_M = (Avg_6M * Trend_Factor * Seasonality_Index)

Where:
- Avg_6M = Average of last 6 months actuals
- Trend_Factor = Growth rate from regression
- Seasonality_Index = Monthly index from historical pattern

Example:
Last 6 months: [1000, 1050, 1100, 1080, 1120, 1150]
Avg_6M = 1,083
Trend = +2% per month
Feb Seasonality Index = 0.95 (post-Tết dip)

FC_Baseline_202502 = 1,083 * 1.02 * 0.95 = 1,049 units
```

**Sample Data (Product 12345678 - Regular):**
```
Month             | Baseline | Rationale
──────────────────┼──────────┼──────────────────────────
FC_Baseline_202502| 1,049    | Post-Tết, adjusted down
FC_Baseline_202503| 1,104    | Normal growth
FC_Baseline_202504| 1,126    | Continued growth
FC_Baseline_202505| 1,149    | Trending up
FC_Baseline_202506| 1,172    | Summer season
```

**Visual Indicator:**
- Cell Background: Light blue (indicates editable)
- Font: Regular black
- Border: Thin

**Editability:**
- ✅ CAN edit manually if statistical model not suitable
- ⚠️ Must add comment if manual override
- ⚠️ Large changes (>50%) require approval

**Usage:**
- Foundation cho total SI forecast
- Comparison với budget
- Baseline cho promotional uplift calculation

**Related Fields:**
- Actual columns (input)
- Total_FC_SI columns (baseline is one component)

---

## GROUP 4: Promotional Forecasts

### 4.1 FC_Promo_Single_Offline_{YYYYMM}

**Column Pattern:** `FC_Promo_Single_Offline_YYYYMM`
**Number of Columns:** 18
**Data Type:** Numeric (Integer)
**Format:** Whole numbers
**Nullable:** Yes (default 0)

**Definition:**
Dự báo Sell-In cho promotional single products qua kênh OFFLINE (Modern Trade, General Trade, Traditional Trade).

**Source:**
- System: Forecast Model (FM) Excel files
- Input by: Marketing Team
- Import Process: sp_tag_update_wf_promo_single_unit_only_offline
- Update Frequency: Monthly or as promo plan changes

**Business Rules:**
- Only for products with active promotional campaigns
- Offline channels only (MT, GT, TT)
- Excludes online/e-commerce
- Incremental to baseline (promo uplift)

**Promo Types Included:**
```
- Price Discount (e.g., 20% off)
- Buy X Get Y (e.g., Buy 2 Get 1)
- Multi-buy (e.g., Buy 3 for 100k)
- Bundle offers
- Gift with Purchase (value GWP)
```

**Sample Data (Product 12345678 with Valentine Promo in Feb):**
```
Month             | Promo Offline | Promo Details
──────────────────┼───────────────┼─────────────────────────────
FC_Promo_..._202501| 0           | No promo
FC_Promo_..._202502| 1,200       | Valentine: Buy 1 Get 1, 14 days
FC_Promo_..._202503| 0           | No promo
FC_Promo_..._202504| 150         | Small discount promo
```

**Calculation Example:**
```
Base demand (no promo): 1,000 units
Promo mechanic: Buy 1 Get 1 Free
Duration: 14 days (50% of month)
Expected uplift: +120% during promo period
Participation: 60% of base customers

Incremental = 1,000 * 50% * 120% * 60% = 360 units
Promo forecast = 360 units (just the incremental)
Note: Some planners include base + incremental = 1,360
(Check FM file convention)
```

**Visual Indicator:**
- Cell Background: Light yellow (promotional data)
- Font: Regular black
- Border: Medium (if has value)

**Editability:**
- ✅ CAN edit
- ⚠️ Should align with Marketing promo plan
- ⚠️ Add comment if significantly different from FM input

**Related Fields:**
- FC_Promo_Single_Online (online channel equivalent)
- SI_Promo_Single (total promo SI calculation)

---

### 4.2 FC_Promo_Single_Online_{YYYYMM}

**Column Pattern:** `FC_Promo_Single_Online_YYYYMM`
**Number of Columns:** 18
**Data Type:** Numeric (Integer)
**Format:** Whole numbers
**Nullable:** Yes (default 0)

**Definition:**
Dự báo Sell-In promotional single products qua kênh ONLINE (E-commerce: Lazada, Shopee, Tiki, Official Website).

**Source:**
- System: Forecast Model (FM) Excel files
- Input by: E-commerce/Digital Marketing Team
- Import Process: sp_tag_update_wf_promo_single_unit_only_offline (same SP handles both)
- Update Frequency: Monthly

**Business Rules:**
- Online/E-commerce channels only
- Often has different promo mechanics than offline
- Can have flash sales, online-exclusive offers
- Typically 15-25% of total promo volume (growing trend)

**Online-Specific Promo Types:**
```
- Flash Sales (limited time, deep discount)
- Platform vouchers (Shopee 50k off)
- Livestream selling events
- Influencer collaborations
- Add-to-cart promotions
- Free shipping campaigns
```

**Sample Data:**
```
Month             | Online | Offline | Total | Online %
──────────────────┼────────┼─────────┼───────┼─────────
FC_Promo_..._202502| 300  | 1,200   | 1,500 | 20%
FC_Promo_..._202503| 0    | 0       | 0     | -
FC_Promo_..._202504| 50   | 150     | 200   | 25%
```

**Trend:**
- Online % growing year-over-year
- 2023: ~15% of total
- 2024: ~20% of total
- 2025 target: 25% of total

**Related Fields:**
- FC_Promo_Single_Offline
- SI_Promo_Single = Offline + Online

---

## GROUP 5: New Launch Forecasts

### 5.1 FC_Launch_Single_{YYYYMM}

**Column Pattern:** `FC_Launch_Single_YYYYMM`
**Number of Columns:** 18
**Data Type:** Numeric (Integer)
**Format:** Whole numbers
**Nullable:** Yes (0 for non-launch products)

**Definition:**
Dự báo Sell-In cho sản phẩm mới launch (NPD - New Product Development).

**Source:**
- System: FM Excel files
- Input by: NPD/Innovation Team
- Import Process: sp_tag_update_wf_new_launch_unit_only_offline
- Based on: Launch plan, market research, test market results

**Business Rules:**
- Only for NPD products (Product_Type = 'NPD')
- Includes both Offline + Online (combined)
- Follows launch curve pattern
- First month = Pipeline fill + Initial consumer demand

**Launch Curve Pattern:**
```
Phase           | Month    | Volume Pattern        | Example
────────────────┼──────────┼───────────────────────┼─────────
Pipeline Fill   | M1       | High (fill channels)  | 2,000
Initial Demand  | M1       | included above        |
Ramp-Up         | M2-M3    | Growing               | 1,200-1,500
Peak            | M4-M6    | Stabilizing           | 1,800-2,000
Steady State    | M7+      | Stable                | 1,500
```

**Sample Data (New Lipstick XYZ Launch Feb 2025):**
```
Month             | Launch Qty | Phase            | Notes
──────────────────┼────────────┼──────────────────┼─────────────────
FC_Launch_..._202502| 2,500   | Pipeline Fill    | Launch month
FC_Launch_..._202503| 1,200   | Ramp-up          | Building awareness
FC_Launch_..._202504| 1,500   | Growth           | Marketing push
FC_Launch_..._202505| 1,800   | Peak             | Full distribution
FC_Launch_..._202506| 1,500   | Steady           | Normalized
```

**Pipeline Fill Calculation:**
```
Pipeline Fill = Number_of_Doors * Minimum_Display_Qty

Example:
Distribution plan:
- Modern Trade doors: 500 stores
- GT doors: 1,000 stores
- Online warehouses: 3 warehouses

Minimum display:
- MT: 3 units per door = 500 * 3 = 1,500
- GT: 1 unit per door = 1,000 * 1 = 1,000
- Online: 500 units per warehouse = 3 * 500 = 1,500

Total Pipeline = 4,000 units
+ Safety stock: +500 units
+ Initial consumer demand: +500 units
= First month: 5,000 units
```

**Visual Indicator:**
- Cell Background: Light green (launch products)
- Font: Bold (for launch months)

**Related Fields:**
- Product_Type (must be 'NPD')
- SI_Launch_Single (SI calculation)
- Status (usually 'New')

---

## GROUP 6: FOC (Free of Charge) Forecasts

### 6.1 FC_FOC_{YYYYMM}

**Column Pattern:** `FC_FOC_YYYYMM`
**Number of Columns:** 18
**Data Type:** Numeric (Integer)
**Format:** Whole numbers
**Nullable:** Yes (default 0)

**Definition:**
Dự báo số lượng sản phẩm tặng miễn phí (samples, GWP, event giveaways).

**Source:**
- System: FM Excel files
- Input by: Marketing Team
- Import Process: sp_tag_update_wf_foc_unit_only_offline
- Based on: Campaign calendar, event schedule

**Business Rules:**
- FOC products do NOT generate revenue
- Still need forecast for:
  - Production planning
  - Inventory management
  - Cost allocation
- Includes: Samples, miniatures, GWP, event freebies

**FOC Types:**
```
Type                | Size       | Distribution Method    | Volume
────────────────────┼────────────┼────────────────────────┼────────────
Sample/Miniature    | 3-10ml     | Counter sampling       | High
GWP (Gift w/ Purch) | Full/Mini  | Purchase threshold     | Medium
Event Giveaway      | Varies     | Events, activations    | Medium
Staff Allocation    | Full size  | Employee benefit       | Low
Influencer Seeding  | Full size  | PR/Marketing           | Low
```

**Sample Data (Perfume Sample 5ml for Valentine):**
```
Month          | FOC Qty | Campaign
───────────────┼─────────┼────────────────────────────────
FC_FOC_202501  | 0       | No campaign
FC_FOC_202502  | 10,000  | Valentine GWP: Purchase >500k
FC_FOC_202503  | 0       | No campaign
FC_FOC_202504  | 2,000   | Store opening events
FC_FOC_202505  | 0       | No campaign
```

**GWP Calculation Example:**
```
Campaign: Valentine GWP
Mechanic: Buy lipstick >500k, get perfume sample 5ml
Expected participants: 15,000 customers
Take rate: 80% (customers who actually take gift)
Safety buffer: +10%

FOC forecast = 15,000 * 80% * 110% = 13,200 samples
Round to: 15,000 (for easier production lot size)
```

**Cost Accounting:**
- FOC has cost but no revenue
- Allocated to Marketing expense
- Tracked separately in P&L

**Related Fields:**
- SI_FOC (SI calculation for FOC)
- Product_Type (often 'FOC')

---

## GROUP 7: Promo BOM Component Forecasts

### 7.1 FC_Promo_BOM_Component_{YYYYMM}

**Column Pattern:** `FC_Promo_BOM_Component_YYYYMM`
**Number of Columns:** 18
**Data Type:** Numeric (Integer)
**Format:** Whole numbers
**Nullable:** Yes (default 0)

**Definition:**
Số lượng sản phẩm (component) cần để assemble promotional BOM/kits/sets.

**Source:**
- System: FM Promo BOM Plan + BOM Master Table
- Calculation: BOM Explosion process
- Import Process: sp_tag_update_wf_promo_bom_component_unit
- Logic: BOM_Header_Forecast * Component_Qty_per_BOM

**Business Rules:**
- Only populated for components used in promo BOMs
- Regular products can be both:
  - Sold individually (baseline)
  - AND component in BOM
- Total SI = Regular + BOM component requirement

**BOM Explosion Example:**
```
Promo BOM: "Tết Beauty Box 2025"
BOM Forecast: 3,000 sets

BOM Structure (from BOM_Master):
Component_SKU | Component_Name     | Qty_per_BOM
──────────────┼────────────────────┼────────────
11111111      | Lipstick Red       | 1
22222222      | Mascara Black      | 1
33333333      | Serum Gold         | 1
44444444      | Premium Box        | 1
55555555      | Tissue Paper       | 2

Component Forecast Calculation:
Lipstick (11111111): 3,000 * 1 = 3,000 units
Mascara (22222222): 3,000 * 1 = 3,000 units
Serum (33333333): 3,000 * 1 = 3,000 units
Box (44444444): 3,000 * 1 = 3,000 units
Tissue (55555555): 3,000 * 2 = 6,000 units

Working File Update:
Product 11111111:
  FC_Promo_BOM_Component_202501 = 3,000

Product 55555555:
  FC_Promo_BOM_Component_202501 = 6,000
```

**Sample Data (Lipstick as component):**
```
Product: 11111111 (Lipstick Red)

Month             | BOM Component | Individual Sales | Total
──────────────────┼───────────────┼──────────────────┼───────
FC_..._202501     | 3,000         | 1,000            | 4,000
FC_..._202502     | 0             | 1,500            | 1,500
FC_..._202503     | 5,000         | 1,200            | 6,200
  (Mother's Day set)
```

**Multiple BOMs:**
If một component thuộc nhiều BOMs:
```
Product: 11111111 (Lipstick)

BOM_1 "Tết Box": 3,000 sets * 1 = 3,000
BOM_2 "Valentine Set": 2,000 sets * 1 = 2,000
BOM_3 "Trial Kit": 1,000 sets * 2 = 2,000

Total FC_Promo_BOM_Component = 3,000 + 2,000 + 2,000 = 7,000
```

**Related Fields:**
- SI_Promo_BOM (SI calculation)
- BOM_Master table (external reference)

---

## GROUP 8: OPTIMUS Sell-In

### 8.1 FC_SI_OPTIMUS_{YYYYMM}

**Column Pattern:** `FC_SI_OPTIMUS_YYYYMM`
**Number of Columns:** 18
**Data Type:** Numeric (Integer)
**Format:** Whole numbers
**Nullable:** Yes (default 0)

**Definition:**
Sell-In forecast calculated từ Sell-Out forecast của OPTIMUS system, adjusted cho inventory build/drawdown.

**Source:**
- System: OPTIMUS (Sell-Out forecasting platform)
- Import Process: sp_tag_add_FC_SI_Group_FC_SO_OPTIMUS
- Calculation: SO_Forecast + Inventory_Change
- Update Frequency: Weekly or monthly

**Business Rules:**
- Only runs if system config: run_optimus = 1
- Not all products have OPTIMUS SO forecast
- Conversion từ SO → SI requires inventory planning

**SO to SI Conversion Logic:**
```
Formula:
SI = SO + (Target_Inventory - Current_Inventory)

Where:
- SO = Sell-Out forecast from OPTIMUS
- Target_Inventory = Desired channel inventory level
- Current_Inventory = Current channel stock
```

**Example 1: Building Inventory**
```
Product: 12345678
Period: 202502

OPTIMUS SO forecast: 2,000 units
Current channel inventory: 500 units
Target inventory (2 weeks cover): 800 units
Inventory build needed: 800 - 500 = +300 units

SI = 2,000 + 300 = 2,300 units

Working File:
FC_SI_OPTIMUS_202502 = 2,300
```

**Example 2: Drawing Down Inventory**
```
Product: 23456789
Period: 202503

SO forecast: 1,500 units
Current inventory: 1,200 units
Target inventory: 700 units
Inventory reduction: 700 - 1,200 = -500 units

SI = 1,500 - 500 = 1,000 units

Working File:
FC_SI_OPTIMUS_202503 = 1,000
```

**Sample Data:**
```
Month          | SO      | Inv_Change | SI      | Notes
───────────────┼─────────┼────────────┼─────────┼──────────────────
FC_SI_OPT_202502| 2,000 | +300       | 2,300   | Pre-stock for peak
FC_SI_OPT_202503| 1,800 | +100       | 1,900   | Maintain stock
FC_SI_OPT_202504| 1,500 | -200       | 1,300   | Reduce excess
```

**OPTIMUS Coverage:**
- Typically covers top-selling products
- ~60-70% of total volume
- Remaining products use baseline forecast

**Related Fields:**
- SI_OPTIMUS (same data, different column grouping)
- Total_FC_SI (OPTIMUS is one component)

---

## GROUP 9: Budget Data

### 9.1 Budget_{YYYYMM}

**Column Pattern:** `Budget_YYYYMM`
**Number of Columns:** 18
**Data Type:** Numeric (Integer)
**Format:** Whole numbers
**Nullable:** Yes (can be 0)

**Definition:**
Annual budget chính thức đã được Board of Directors phê duyệt, phân bổ theo tháng.

**Source:**
- System: Finance Budget System
- Input by: Finance Department
- Import Process: sp_tag_gen_budget_budget_New
- Approval: Board-approved, official commitment

**Business Rules:**
- Read-only for Demand Planners (reference only)
- Official commitment với Finance/Leadership
- Used for performance evaluation
- Fixed sau khi approved (rarely changed mid-year)

**Budget Allocation Methods:**
```
Method 1: Equal Distribution
Annual: 120,000 units
Monthly: 120,000 / 12 = 10,000 units/month

Method 2: Seasonal/Historical Pattern
Annual: 120,000 units
Q1 (Tết peak): 35% = 42,000
Q2: 25% = 30,000
Q3: 20% = 24,000
Q4: 20% = 24,000

Method 3: Growth-Based
Previous year monthly * Growth %
Jan 2024: 9,000 * 1.10 = 9,900
Feb 2024: 12,000 * 1.10 = 13,200 (Tết)
```

**Sample Data:**
```
Month          | Budget | Last Year | Growth
───────────────┼────────┼───────────┼────────
Budget_202501  | 15,000 | 13,500    | +11%
Budget_202502  | 14,000 | 12,800    | +9%
Budget_202503  | 11,000 | 10,000    | +10%
Budget_202504  | 10,000 | 9,200     | +9%
```

**Visual Indicator:**
- Cell Background: Yellow (indicates budget reference)
- Font: Regular black
- Border: Medium

**Gap Analysis:**
Key metric: Forecast vs Budget Gap
```
Gap = (Forecast - Budget) / Budget * 100%

Example:
Forecast: 16,000 units
Budget: 14,000 units
Gap: +2,000 units (+14.3%)

If Gap > ±20%: Requires explanation to Finance
```

**Related Fields:**
- Total_FC_SI (comparison)
- Gap_FC_vs_Budget (calculated gap)
- Pre_Budget (draft version)

---

### 9.2 Pre_Budget_{YYYYMM}

**Column Pattern:** `Pre_Budget_YYYYMM`
**Number of Columns:** 18
**Data Type:** Numeric (Integer)
**Format:** Whole numbers
**Nullable:** Yes

**Definition:**
Draft budget (preliminary budget) trước khi có official Budget approval.

**Source:**
- System: Finance Budget System
- Input by: Finance (draft phase)
- Import Process: sp_tag_gen_budget_pre_budget_new
- Status: Discussion version, not final

**Usage:**
- Early planning reference
- Comparison với Forecast during budget process
- Historical reference sau khi Budget chính thức

**Typical Timeline:**
```
Sep-Oct 2024: Pre-Budget for FY2025 created
Nov 2024: Discussions, adjustments
Dec 2024: Final Budget approved
Jan 2025+: Pre-Budget kept for reference only
```

**Sample Data:**
```
Month          | Pre_Budget | Final Budget | Change
───────────────┼────────────┼──────────────┼────────
Pre_Bud_202501 | 16,000     | 15,000       | -1,000
Pre_Bud_202502 | 15,000     | 14,000       | -1,000
Pre_Bud_202503 | 12,000     | 11,000       | -1,000
```

**Changes from Pre to Final:**
- Usually adjusted downward (conservative)
- Based on latest market intel
- Risk mitigation

**Related Fields:**
- Budget (final version)
- Budget_Trend (alternative view)

---

### 9.3 Budget_Trend_{YYYYMM}

**Column Pattern:** `Budget_Trend_YYYYMM`
**Number of Columns:** 18
**Data Type:** Numeric (Decimal)
**Format:** Decimal (2 places)
**Nullable:** Yes

**Definition:**
Budget projection dựa trên historical trend và statistical growth model.

**Source:**
- System: Forecasting Tool
- Calculation: sp_tag_gen_budget_trend_new
- Method: Historical average * Growth rate
- Purpose: Alternative scenario, quick estimate

**Calculation:**
```
Budget_Trend_M = Last_Year_Actual_M * (1 + Growth_Rate)

Where:
Growth_Rate = CAGR of last 2-3 years

Example:
Last year Feb actual: 13,000 units
3-year CAGR: +8%
Budget_Trend_202502 = 13,000 * 1.08 = 14,040 units
```

**Sample Data:**
```
Month          | Budget_Trend | Actual Budget | Variance
───────────────┼──────────────┼───────────────┼─────────
Bud_Trend_202501| 15,200     | 15,000        | +200
Bud_Trend_202502| 14,040     | 14,000        | +40
Bud_Trend_202503| 10,800     | 11,000        | -200
```

**Usage:**
- Benchmark vs official Budget
- Quick sanity check
- Alternative scenario planning
- Gap explanation (if trend ≠ budget, why?)

**Related Fields:**
- Budget (official)
- Pre_Budget (draft)

---

## 📄 Document Status

**Version:** 1.0 (Part 1 of 2)
**Last Updated:** 2025-11-18
**Coverage:** Groups 1-9 (Product Info through Budget)
**Remaining:** Groups 10-12 (SI Calculations, Inventory, Analysis)
**Total Fields Documented:** 150+ fields

**Next:** Part 2 will cover Groups 10-12

---

**For Support:** dp.support@loreal.com
