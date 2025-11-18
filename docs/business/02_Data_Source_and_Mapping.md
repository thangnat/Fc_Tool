# Data Source & Mapping Guide - Forecasting Tool

## 📌 Giới Thiệu

Tài liệu này giải thích chi tiết nguồn dữ liệu và cách mapping/chuyển đổi dữ liệu trong quy trình tạo Working File của Forecasting Tool.

**Đối tượng:** Business Users, Demand Planners, Data Analysts

**Mục đích:**
- Hiểu rõ dữ liệu đến từ đâu
- Cách dữ liệu được transform và map
- Mối quan hệ giữa các nguồn dữ liệu
- Data quality và validation

---

## 🗺️ Tổng Quan Nguồn Dữ Liệu

### Sơ Đồ Data Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    NGUỒN DỮ LIỆU CHÍNH                      │
└─────────────────────────────────────────────────────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
        ↓                   ↓                   ↓
┌──────────────┐   ┌──────────────┐   ┌──────────────┐
│  SAP / ERP   │   │  OPTIMUS     │   │  Manual      │
│  (Actuals)   │   │  (Sell-Out)  │   │  (Forecast   │
│              │   │              │   │   Model)     │
└──────────────┘   └──────────────┘   └──────────────┘
        │                   │                   │
        └───────────────────┼───────────────────┘
                            ↓
                ┌───────────────────────┐
                │  FORECASTING TOOL     │
                │  Data Processing      │
                └───────────────────────┘
                            ↓
        ┌───────────────────┼───────────────────┐
        │                   │                   │
        ↓                   ↓                   ↓
┌──────────────┐   ┌──────────────┐   ┌──────────────┐
│  Historical  │   │  Baseline    │   │  Final WF    │
│  Data        │   │  Forecast    │   │  (Output)    │
└──────────────┘   └──────────────┘   └──────────────┘
```

---

## 📊 Chi Tiết Từng Nguồn Dữ Liệu

### 1. SAP/ERP System

**Mô tả:** Hệ thống quản lý tài nguyên doanh nghiệp chính của L'Oréal

**Data extracted:**

#### 1.1 Historical Actuals (Dữ liệu Thực Tế Lịch Sử)

**Transaction:** ZV14_02 (SAP Invoice Data)

**Thông tin bao gồm:**
```
┌─────────────────────┬──────────────────┬────────────────────┐
│ Field               │ Description      │ Example            │
├─────────────────────┼──────────────────┼────────────────────┤
│ Product Code        │ Mã sản phẩm      │ 12345678           │
│ Product Name        │ Tên sản phẩm     │ Shampoo ABC 400ml  │
│ Invoice Date        │ Ngày hóa đơn     │ 2024-01-15         │
│ Invoice Number      │ Số hóa đơn       │ INV2024010001      │
│ Quantity            │ Số lượng         │ 1000 units         │
│ Value               │ Giá trị          │ 500,000 VND        │
│ Customer Code       │ Mã khách hàng    │ CUST001            │
│ Distribution Channel│ Kênh phân phối   │ Modern Trade       │
│ Division            │ Bộ phận          │ CPD                │
│ Plant               │ Nhà máy          │ VN01               │
└─────────────────────┴──────────────────┴────────────────────┘
```

**Extraction period:** 24 tháng lịch sử (từ Current Month - 24 đến Current Month - 1)

**Frequency:** Hàng tháng

**Data transformation:**
```
SAP Raw Data (Daily invoices)
    ↓
Aggregate by: Product + Month
    ↓
Monthly Actual Sell-In
    ↓
Load vào Working File Historical columns
```

**Ví dụ mapping:**
```sql
SAP Data:
Product: 12345678 "Shampoo ABC"
Jan 2024 daily invoices: [50, 45, 60, 55, ... ]
→ Sum = 1,523 units

Working File:
Product: 12345678
Column: Actual_202401
Value: 1,523 units
```

---

#### 1.2 Current Inventory (Tồn Kho Hiện Tại)

**Transaction:** MB52 / MMBE (Stock Overview)

**Thông tin bao gồm:**
```
┌─────────────────────┬──────────────────┬────────────────────┐
│ Field               │ Description      │ Example            │
├─────────────────────┼──────────────────┼────────────────────┤
│ Material            │ Mã vật tư        │ 12345678           │
│ Plant               │ Nhà máy          │ VN01               │
│ Storage Location    │ Kho              │ WH01               │
│ Unrestricted Stock  │ Tồn kho tự do    │ 5,000 units        │
│ Blocked Stock       │ Tồn kho khóa     │ 200 units          │
│ In Quality          │ Đang kiểm tra    │ 100 units          │
│ In Transit          │ Đang vận chuyển  │ 300 units          │
│ Reserved            │ Đã đặt chỗ       │ 800 units          │
└─────────────────────┴──────────────────┴────────────────────┘
```

**Data transformation:**
```
SOH (Stock-On-Hand) = Unrestricted - Reserved

Ví dụ:
Unrestricted: 5,000 units
Reserved: 800 units
→ SOH Available: 4,200 units
```

**GIT (Goods-In-Transit):**
```
GIT từ SAP = In Transit field + International shipments

Calculation:
Internal transfer: 300 units
International import: 1,000 units
→ Total GIT: 1,300 units
```

---

#### 1.3 MTD Actuals (Month-To-Date)

**Source:** Daily sales transactions từ SAP

**Thông tin:**
```
Current Month: February 2025
Today: 15/02/2025

Product A MTD:
Week 1 (01-07 Feb): 250 units
Week 2 (08-14 Feb): 280 units
15 Feb: 35 units
→ MTD Total: 565 units

Update vào WF column: MTD_SI_202502
```

**Use case:**
```
Monthly Forecast: 1,200 units
MTD Actual (15/02): 565 units
Days elapsed: 15/28 = 53.6%
Expected MTD: 1,200 * 53.6% = 643 units
Variance: 565 - 643 = -78 units (underperfoming)
```

---

### 2. OPTIMUS System

**Mô tả:** Hệ thống dự báo Sell-Out (bán ra từ retailer tới consumer)

**Data provided:**

#### 2.1 Sell-Out Forecast

**Thông tin bao gồm:**
```
┌─────────────────────┬──────────────────┬────────────────────┐
│ Field               │ Description      │ Example            │
├─────────────────────┼──────────────────┼────────────────────┤
│ Product SKU         │ Mã sản phẩm      │ 12345678           │
│ Store/Channel       │ Cửa hàng/Kênh    │ BigC, Shopee       │
│ Forecast Month      │ Tháng dự báo     │ 202502             │
│ SO Forecast         │ Dự báo Sell-Out  │ 2,000 units        │
│ Confidence Level    │ Mức độ tin cậy   │ High / Med / Low   │
└─────────────────────┴──────────────────┴────────────────────┘
```

**Conversion từ Sell-Out sang Sell-In:**

```
Formula:
Sell-In = Sell-Out + Planned_Inventory_Build - Planned_Inventory_Drawdown

Ví dụ 1: Building Inventory
Sell-Out forecast: 2,000 units
Current channel inventory: 500 units
Target channel inventory: 800 units
→ Inventory build needed: +300 units
→ Sell-In: 2,000 + 300 = 2,300 units

Ví dụ 2: Drawing Down Inventory
Sell-Out forecast: 1,500 units
Current channel inventory: 1,000 units
Target channel inventory: 600 units
→ Inventory drawdown: -400 units
→ Sell-In: 1,500 - 400 = 1,100 units
```

**Data mapping:**
```
OPTIMUS Data:
Product: 12345678
Month: 202502
SO Forecast: 2,000 units
Inventory adjustment: +300 units

Working File:
Product: 12345678
Column: FC_SI_OPTIMUS_202502
Value: 2,300 units
```

---

### 3. Manual Forecast Model (FM)

**Mô tả:** Excel/files chứa forecast manual từ Marketing, Demand Planning teams

**Categories:**

#### 3.1 Promotional Forecast

**File location:** Thường là Excel files từ Marketing team

**Thông tin:**
```
┌─────────────────────┬──────────────────┬────────────────────┐
│ Field               │ Description      │ Example            │
├─────────────────────┼──────────────────┼────────────────────┤
│ Promo Name          │ Tên chương trình │ Valentine 2025     │
│ Product SKU         │ Mã sản phẩm      │ 12345678           │
│ Promo Period        │ Thời gian KM     │ 01-14 Feb 2025     │
│ Promo Mechanic      │ Cơ chế KM        │ Buy 1 Get 1        │
│ Expected Uplift     │ Uplift dự kiến   │ +50%               │
│ Offline Forecast    │ Dự báo offline   │ 1,200 units        │
│ Online Forecast     │ Dự báo online    │ 300 units          │
└─────────────────────┴──────────────────┴────────────────────┘
```

**Calculation logic:**
```
Base forecast (no promo): 1,000 units
Promo uplift: +50%
→ Promo forecast: 1,000 * 1.5 = 1,500 units

Channel split:
Offline (80%): 1,200 units
Online (20%): 300 units
```

**Mapping to Working File:**
```
Source (FM Excel):
Row: Product 12345678 - Valentine Promo
Offline: 1,200
Online: 300

Target (Working File):
Column: FC_Promo_Single_Offline_202502 = 1,200
Column: FC_Promo_Single_Online_202502 = 300
Column: SI_Promo_Single_202502 = 1,500 (Total)
```

---

#### 3.2 New Launch Forecast

**Thông tin:**
```
┌─────────────────────┬──────────────────┬────────────────────┐
│ Field               │ Description      │ Example            │
├─────────────────────┼──────────────────┼────────────────────┤
│ Launch Product      │ Sản phẩm mới     │ Lipstick XYZ       │
│ Launch Date         │ Ngày ra mắt      │ 01-Feb-2025        │
│ Launch Month        │ Tháng launch     │ 202502             │
│ Pipeline Fill       │ Fill kênh đầu    │ 1,500 units        │
│ Consumer Sell-Out M1│ SO tháng 1       │ 500 units          │
│ Ramp-up M2          │ Tăng trưởng M2   │ 1,200 units        │
│ Steady State M4+    │ Ổn định từ M4    │ 1,000 units        │
└─────────────────────┴──────────────────┴────────────────────┘
```

**Launch Curve Model:**
```
Month 1 (Launch): Pipeline Fill + Initial SO
202502: 1,500 + 500 = 2,000 units

Month 2 (Ramp-up):
202503: 1,200 units

Month 3 (Approaching steady):
202504: 1,100 units

Month 4+ (Steady state):
202505 onwards: 1,000 units/month
```

**Mapping:**
```
FM Data → WF Columns:
Launch M1: FC_Launch_Single_202502 = 2,000
Launch M2: FC_Launch_Single_202503 = 1,200
Launch M3: FC_Launch_Single_202504 = 1,100
Launch M4+: FC_Launch_Single_202505+ = 1,000
```

---

#### 3.3 FOC (Free of Charge) Forecast

**Thông tin:**
```
┌─────────────────────┬──────────────────┬────────────────────┐
│ Field               │ Description      │ Example            │
├─────────────────────┼──────────────────┼────────────────────┤
│ Campaign Name       │ Tên chiến dịch   │ Valentine GWP      │
│ FOC Product         │ SP tặng kèm      │ Perfume Sample 5ml │
│ Main Product        │ SP chính         │ Lipstick range     │
│ GWP Mechanic        │ Cơ chế tặng      │ Purchase >500k     │
│ Expected Quantity   │ SL dự kiến       │ 10,000 samples     │
│ Period              │ Thời gian        │ 01-14 Feb          │
└─────────────────────┴──────────────────┴────────────────────┘
```

**Calculation:**
```
Campaign: Valentine GWP
Main product sales forecast: 12,000 units
Conversion rate: 80% (customers qualify for GWP)
Take rate: 95% (customers actually take GWP)
→ FOC needed: 12,000 * 80% * 95% = 9,120 samples

Round up for safety stock: 10,000 samples
```

**Mapping:**
```
FM:
FOC Product: Sample_001
Quantity: 10,000

Working File:
Product: Sample_001
Column: FC_FOC_202502 = 10,000
Column: SI_FOC_202502 = 10,000
```

---

#### 3.4 Promo BOM Forecast

**Thông tin:**
```
BOM Structure:
┌──────────────────────────────────────────────────┐
│ Promo BOM: "Beauty Gift Set Tết 2025"           │
│ BOM Code: SET_TET_2025                           │
│ Forecast: 5,000 sets                             │
│                                                  │
│ Components:                                      │
│ ├─ Lipstick Red 01    : 1 unit  → 5,000 units  │
│ ├─ Mascara Black 02   : 1 unit  → 5,000 units  │
│ ├─ Serum Anti-Age 03  : 1 unit  → 5,000 units  │
│ └─ Gift Box Premium   : 1 unit  → 5,000 units  │
└──────────────────────────────────────────────────┘
```

**BOM Explosion (Mapping):**
```
Input (FM):
BOM Header: SET_TET_2025
Forecast: 5,000 sets
Period: 202501

BOM Structure Table:
BOM Code    | Component  | Qty per Set
SET_TET_2025| Lipstick01 | 1
SET_TET_2025| Mascara02  | 1
SET_TET_2025| Serum03    | 1
SET_TET_2025| GiftBox    | 1

Output (Working File):
Product: Lipstick01
Column: FC_Promo_BOM_Component_202501 = 5,000

Product: Mascara02
Column: FC_Promo_BOM_Component_202501 = 5,000

Product: Serum03
Column: FC_Promo_BOM_Component_202501 = 5,000

Product: GiftBox
Column: FC_Promo_BOM_Component_202501 = 5,000
```

**Complex BOM example:**
```
BOM: "Family Pack"
Forecast: 2,000 packs

Components:
├─ Shampoo 400ml      : 2 units → 4,000 units
├─ Conditioner 400ml  : 2 units → 4,000 units
├─ Hair Mask 200ml    : 1 unit  → 2,000 units
└─ Promotional Flyer  : 1 unit  → 2,000 units
```

---

### 4. Budget Data (Finance System)

**Mô tả:** Annual budget từ Finance Department

**Thông tin:**
```
┌─────────────────────┬──────────────────┬────────────────────┐
│ Field               │ Description      │ Example            │
├─────────────────────┼──────────────────┼────────────────────┤
│ Product/SKU         │ Mã sản phẩm      │ 12345678           │
│ Annual Budget       │ Ngân sách năm    │ 120,000 units      │
│ Budget Type         │ Loại budget      │ Budget/Pre/Trend   │
│ Monthly Allocation  │ Phân bổ tháng    │ See below          │
│ Value Budget        │ Ngân sách giá trị│ 6,000,000,000 VND  │
└─────────────────────┴──────────────────┴────────────────────┘
```

**Monthly Allocation Methods:**

**Method 1: Equal Distribution**
```
Annual Budget: 120,000 units
→ Monthly: 120,000 / 12 = 10,000 units/month

Jan: 10,000
Feb: 10,000
...
Dec: 10,000
```

**Method 2: Seasonal Allocation**
```
Annual Budget: 120,000 units
Allocation by season:

Q1 (High season): 35% → 42,000 units
├─ Jan: 15,000 (Tết)
├─ Feb: 14,000
└─ Mar: 13,000

Q2 (Normal): 25% → 30,000 units
├─ Apr: 10,000
├─ May: 10,000
└─ Jun: 10,000

Q3 (Low): 20% → 24,000 units
├─ Jul: 8,000
├─ Aug: 8,000
└─ Sep: 8,000

Q4 (High): 20% → 24,000 units
├─ Oct: 8,000
├─ Nov: 8,000
└─ Dec: 8,000 (Christmas)
```

**Mapping to Working File:**
```
Source (Finance Budget File):
Product: 12345678
Year: 2025
Budget values: [15000, 14000, 13000, ...]

Target (Working File):
Product: 12345678
Budget_202501: 15,000
Budget_202502: 14,000
Budget_202503: 13,000
...
```

**3 Types of Budget:**

**1. Budget (Official):**
- Board-approved figures
- Official commitment
- Used for performance tracking

**2. Pre-Budget:**
- Draft version
- Discussion purpose
- Before final approval

**3. Budget Trend:**
- Statistical projection
- Based on historical growth
- Alternative scenario

---

### 5. Master Data Tables

**Mô tả:** Các bảng chứa thông tin chuẩn về sản phẩm, category, brand...

#### 5.1 Product Master

**Thông tin:**
```
┌─────────────────────┬──────────────────┬────────────────────┐
│ Field               │ Description      │ Example            │
├─────────────────────┼──────────────────┼────────────────────┤
│ Product Code        │ Mã sản phẩm      │ 12345678           │
│ Product Name        │ Tên sản phẩm     │ Shampoo ABC 400ml  │
│ Brand               │ Thương hiệu      │ L'Oréal Paris      │
│ Category            │ Danh mục         │ Hair Care          │
│ Sub-Category        │ Danh mục phụ     │ Shampoo            │
│ Division            │ Bộ phận          │ CPD                │
│ Product Type        │ Loại SP          │ Regular/NPD/Promo  │
│ Status              │ Trạng thái       │ Active/Discontinue │
│ Unit of Measure     │ Đơn vị           │ EA (Each)          │
│ Launch Date         │ Ngày ra mắt      │ 2020-01-15         │
│ Packaging           │ Quy cách         │ 400ml bottle       │
└─────────────────────┴──────────────────┴────────────────────┘
```

**Usage trong Working File:**
```
Product Master → BFL Master → Working File structure

Each row in WF represents one Product Code
Attributes from Master Data populate info columns
```

---

#### 5.2 BOM Structure Master

**Thông tin:**
```
┌─────────────────────┬──────────────────┬────────────────────┐
│ Field               │ Description      │ Example            │
├─────────────────────┼──────────────────┼────────────────────┤
│ BOM Header          │ Mã combo/set     │ SET_TET_2025       │
│ Component           │ Component SKU    │ 12345678           │
│ Quantity per BOM    │ Số lượng/set     │ 1.0                │
│ Component Type      │ Loại component   │ Finished Goods/PKG │
│ BOM Type            │ Loại BOM         │ Promo/Regular      │
│ Valid From          │ Hiệu lực từ      │ 2025-01-01         │
│ Valid To            │ Hiệu lực đến     │ 2025-01-31         │
└─────────────────────┴──────────────────┴────────────────────┘
```

**BOM Explosion Process:**
```
Step 1: Get BOM Header forecast
BOM: SET_TET_2025 = 5,000 sets

Step 2: Query BOM Structure
Components of SET_TET_2025:
- 12345678 (Lipstick): Qty = 1
- 23456789 (Mascara): Qty = 1
- 34567890 (Serum): Qty = 1

Step 3: Calculate Component Requirements
Lipstick (12345678): 5,000 * 1 = 5,000 units
Mascara (23456789): 5,000 * 1 = 5,000 units
Serum (34567890): 5,000 * 1 = 5,000 units

Step 4: Update Working File
Each component gets forecast added to FC_Promo_BOM_Component column
```

---

## 🔄 Data Transformation & Mapping Examples

### Example 1: Complete Flow for a Regular Product

**Product:** Shampoo ABC 400ml (SKU: 12345678)
**Division:** CPD
**Period:** February 2025 (202502)

```
STEP 1: Historical Data (từ SAP)
─────────────────────────────────
Source: SAP ZV14_02
Period: Jan 2023 - Jan 2025 (24 months)

Raw Data:
202301: 1,000 units (actual)
202302: 1,050 units
...
202501: 1,200 units

→ Map to WF columns:
Actual_202301: 1,000
Actual_202302: 1,050
...
Actual_202501: 1,200

─────────────────────────────────
STEP 2: Baseline Forecast
─────────────────────────────────
Input: Historical actuals above
Calculation:
- Last 6 months average: 1,150 units
- Growth trend: +2% per month
- Seasonality adjustment: Feb is -5% (post-Tết)

Baseline Feb: 1,150 * 1.02 * 0.95 = 1,113 units
Baseline Mar: 1,150 * 1.04 * 1.00 = 1,196 units

→ Map to WF:
FC_Baseline_202502: 1,113
FC_Baseline_202503: 1,196

─────────────────────────────────
STEP 3: Promotional Forecast (từ FM)
─────────────────────────────────
Source: Marketing Promo Plan Excel
Campaign: Valentine 2025 (Feb)
Mechanic: 20% discount
Incremental forecast: +200 units

→ Map to WF:
FC_Promo_Single_Offline_202502: 180 units
FC_Promo_Single_Online_202502: 20 units
Total Promo: 200 units

─────────────────────────────────
STEP 4: Inventory Data (từ SAP)
─────────────────────────────────
Source: SAP MB52
As of: 01-Feb-2025

Unrestricted Stock: 2,500 units
Reserved: 300 units
→ SOH: 2,200 units

In Transit: 500 units
→ GIT: 500 units

MTD SI (as of 15-Feb): 565 units
→ MTD_SI_202502: 565

→ Map to WF:
SOH_202502: 2,200
GIT_202502: 500
MTD_SI_202502: 565

─────────────────────────────────
STEP 5: Budget Data (từ Finance)
─────────────────────────────────
Source: FY2025 Annual Budget File
Annual Budget: 13,800 units
Feb Allocation: 1,150 units (8.33%)

→ Map to WF:
Budget_202502: 1,150

─────────────────────────────────
STEP 6: OPTIMUS Sell-Out (từ OPTIMUS)
─────────────────────────────────
Source: OPTIMUS SO forecast
Feb SO forecast: 1,000 units
Channel inventory build: +100 units
SI from SO: 1,000 + 100 = 1,100 units

→ Map to WF:
FC_SI_OPTIMUS_202502: 1,100

─────────────────────────────────
STEP 7: Final Calculations
─────────────────────────────────
Total SI Forecast for Feb 2025:
= Baseline + Promo + OPTIMUS + FOC + Launch
= 1,113 + 200 + 1,100 + 0 + 0
= 2,413 units

Total_FC_SI_202502: 2,413

Gap Analysis:
Forecast: 2,413 units
Budget: 1,150 units
Gap: +1,263 units (+109.8%)
→ Forecast is significantly higher than budget
→ Need explanation: Promo uplift + OPTIMUS expansion
```

---

### Example 2: New Launch Product Complete Flow

**Product:** New Lipstick XYZ (SKU: 99887766)
**Division:** LDB
**Launch Date:** 01-Feb-2025

```
STEP 1: Historical Data
─────────────────────────────────
N/A - This is a new product
No historical actuals

→ WF Historical columns = NULL or 0

─────────────────────────────────
STEP 2: Baseline Forecast
─────────────────────────────────
N/A - Cannot use statistical model
Product flagged as "non-modeling"

→ FC_Baseline = 0 (Will use launch forecast instead)

─────────────────────────────────
STEP 3: Launch Forecast (từ FM)
─────────────────────────────────
Source: NPD Launch Plan Excel

Launch Plan:
Month 1 (Feb 2025):
- Pipeline fill: 1,500 units
- Initial consumer SO: 500 units
- Total M1: 2,000 units

Month 2 (Mar 2025):
- Ramp-up: 1,200 units

Month 3 (Apr 2025):
- Approaching steady: 1,100 units

Month 4+ (May onwards):
- Steady state: 1,000 units/month

→ Map to WF:
FC_Launch_Single_202502: 2,000
FC_Launch_Single_202503: 1,200
FC_Launch_Single_202504: 1,100
FC_Launch_Single_202505: 1,000
FC_Launch_Single_202506: 1,000
...

─────────────────────────────────
STEP 4: Inventory Data
─────────────────────────────────
Pre-launch (end of Jan):
SOH: 2,000 units (pre-build for launch)
GIT: 500 units (shipment on the way)
MTD_SI: 0 (not yet launched)

→ Map to WF:
SOH_202501: 2,000
GIT_202501: 500
MTD_SI_202502: 0 (will update mid-Feb)

─────────────────────────────────
STEP 5: Budget Data
─────────────────────────────────
New product Budget:
Year 1 total: 15,000 units
Feb (launch): 2,000 units
Mar-Dec: ~1,200 units/month average

→ Map to WF:
Budget_202502: 2,000
Budget_202503: 1,200
...

─────────────────────────────────
STEP 6: Final SI Calculation
─────────────────────────────────
Feb 2025 Total SI:
= Launch forecast
= 2,000 units

SI_Launch_Single_202502: 2,000
Total_FC_SI_202502: 2,000

Budget comparison:
Forecast: 2,000
Budget: 2,000
Gap: 0 (aligned!)
```

---

### Example 3: Promotional BOM Complete Flow

**Promo Set:** "Tết Gift Box 2025" (BOM Code: TET_BOX_2025)
**Period:** January 2025 (202501)

```
STEP 1: Promo BOM Forecast (từ FM)
─────────────────────────────────
Source: Promo Plan Excel
Campaign: Tết 2025
BOM Forecast: 3,000 sets

→ Initial input:
BOM: TET_BOX_2025
Forecast: 3,000 sets
Period: 202501

─────────────────────────────────
STEP 2: BOM Structure Lookup
─────────────────────────────────
Query BOM Master Table:

BOM_Header   | Component_SKU | Qty_per_BOM | Component_Name
TET_BOX_2025 | 11111111      | 1           | Lipstick Red
TET_BOX_2025 | 22222222      | 1           | Mascara Black
TET_BOX_2025 | 33333333      | 1           | Serum Gold
TET_BOX_2025 | 44444444      | 1           | Premium Box
TET_BOX_2025 | 55555555      | 2           | Tissue Paper

─────────────────────────────────
STEP 3: BOM Explosion Calculation
─────────────────────────────────
BOM forecast: 3,000 sets

Component Requirements:
Lipstick (11111111): 3,000 * 1 = 3,000 units
Mascara (22222222): 3,000 * 1 = 3,000 units
Serum (33333333): 3,000 * 1 = 3,000 units
Box (44444444): 3,000 * 1 = 3,000 units
Tissue (55555555): 3,000 * 2 = 6,000 units

─────────────────────────────────
STEP 4: Map to Working File
─────────────────────────────────
For each component, update WF:

Product: 11111111 (Lipstick)
FC_Promo_BOM_Component_202501: +3,000

Product: 22222222 (Mascara)
FC_Promo_BOM_Component_202501: +3,000

Product: 33333333 (Serum)
FC_Promo_BOM_Component_202501: +3,000

Product: 44444444 (Box)
FC_Promo_BOM_Component_202501: +3,000

Product: 55555555 (Tissue)
FC_Promo_BOM_Component_202501: +6,000

─────────────────────────────────
STEP 5: Total SI Calculation (for each component)
─────────────────────────────────
Example for Lipstick (11111111):

Regular forecast: 1,000 units
Promo Single: 200 units
Promo BOM: 3,000 units (from set above)
FOC: 100 units

Total SI = 1,000 + 200 + 3,000 + 100 = 4,300 units

SI_Regular_202501: 1,000
SI_Promo_Single_202501: 200
SI_Promo_BOM_202501: 3,000
SI_FOC_202501: 100
─────────────────────────
Total_SI_202501: 4,300
```

---

## 📋 Data Quality & Validation

### Validation Rules

#### 1. Historical Data Validation

**Rule 1: No negative values**
```
IF Actual < 0 THEN
  FLAG as ERROR
  Message: "Negative actual value not allowed"
```

**Rule 2: Large variance check**
```
IF ABS(Current_Month - Previous_Month) / Previous_Month > 100% THEN
  FLAG as WARNING
  Message: "Actual changed >100% vs previous month"
```

**Rule 3: Completeness check**
```
Required: 24 months of historical data
IF Missing months > 0 THEN
  FLAG as WARNING
  Message: "Incomplete historical data"
```

---

#### 2. Forecast Validation

**Rule 1: Forecast > 0**
```
IF Forecast < 0 THEN
  FLAG as ERROR
  Message: "Negative forecast not allowed"
```

**Rule 2: Realistic forecast range**
```
Upper_Limit = Historical_Average * 3
Lower_Limit = 0

IF Forecast > Upper_Limit THEN
  FLAG as WARNING
  Message: "Forecast unusually high"
```

**Rule 3: Budget vs Forecast gap**
```
Gap = (Forecast - Budget) / Budget

IF ABS(Gap) > 20% THEN
  FLAG as WARNING
  Message: "Large gap between Forecast and Budget"
  Require: Explanation
```

---

#### 3. BOM Validation

**Rule 1: BOM structure exists**
```
IF BOM_Header has no components THEN
  FLAG as ERROR
  Message: "BOM structure not defined"
```

**Rule 2: Component availability**
```
FOR each component:
  IF Component NOT in Product Master THEN
    FLAG as ERROR
    Message: "Component SKU not found in master"
```

---

#### 4. Inventory Validation

**Rule 1: SOH consistency**
```
IF SOH < 0 THEN
  FLAG as ERROR
  Message: "Negative stock not allowed"
```

**Rule 2: Days of Supply**
```
DOS = SOH / Average_Monthly_Forecast

IF DOS > 12 months THEN
  FLAG as WARNING
  Message: "Excessive inventory - SLOB risk"
```

---

## 🔍 Data Lineage (Truy Xuất Nguồn Gốc)

### Ví dụ: Trace một giá trị trong Working File

**Question:** Giá trị 2,413 units trong Total_FC_SI_202502 của Product 12345678 đến từ đâu?

**Answer (Data Lineage):**

```
Total_FC_SI_202502 = 2,413 units
│
├─ Component 1: Baseline = 1,113 units
│  └─ Source: sp_Sum_FC_FM_baseLine_new
│     └─ Input: Historical actuals từ SAP ZV14_02
│        └─ Raw data: Jan 2023 - Jan 2025 (24 months)
│
├─ Component 2: Promo Single = 200 units
│  └─ Source: sp_tag_update_wf_promo_single_unit_only_offline
│     └─ Input: FM Promo Plan Excel
│        └─ Campaign: Valentine 2025
│           ├─ Offline: 180 units
│           └─ Online: 20 units
│
├─ Component 3: OPTIMUS SI = 1,100 units
│  └─ Source: sp_tag_add_FC_SI_Group_FC_SO_OPTIMUS
│     └─ Input: OPTIMUS Sell-Out forecast
│        └─ Calculation: SO (1,000) + Inventory Build (100)
│
├─ Component 4: FOC = 0 units
│  └─ Source: sp_tag_update_wf_foc_unit_only_offline
│     └─ Input: No FOC campaign for this product in Feb
│
└─ Component 5: New Launch = 0 units
   └─ Source: sp_tag_update_wf_new_launch_unit_only_offline
      └─ Input: Not a new launch product

Calculation:
1,113 + 200 + 1,100 + 0 + 0 = 2,413 ✓
```

---

## 📊 Common Data Mapping Scenarios

### Scenario 1: Sản phẩm Regular (không có promo, không mới)

```
Data Flow:
SAP Historical → Baseline Forecast → Working File

Columns populated:
- Historical columns (24 months)
- Baseline forecast columns (18 months)
- Budget columns
- SOH, GIT, MTD
- Total SI = Baseline only
```

---

### Scenario 2: Sản phẩm có Promo trong tháng

```
Data Flow:
SAP Historical → Baseline Forecast
FM Promo Plan → Promo Forecast
                     ↓
               Working File

Columns populated:
- Historical columns
- Baseline forecast
- Promo Single forecast (Offline + Online)
- Budget columns
- SOH, GIT, MTD
- Total SI = Baseline + Promo Single
```

---

### Scenario 3: Sản phẩm New Launch

```
Data Flow:
FM Launch Plan → Launch Forecast → Working File

Columns populated:
- Historical = NULL/0 (no history)
- Baseline = 0 (non-modeling)
- Launch forecast (with launch curve)
- Budget columns
- SOH (pre-build), GIT
- Total SI = Launch forecast only
```

---

### Scenario 4: Component của Promo BOM

```
Data Flow:
FM Promo BOM Plan → BOM Explosion
                         ↓
                   Component Requirements
                         ↓
                   Working File

Columns populated:
- Historical (if existing product)
- Baseline (if regular sales also)
- Promo BOM Component forecast
- Budget
- Total SI = Baseline + Promo Single + Promo BOM Component + ...
```

---

### Scenario 5: FOC/GWP Product

```
Data Flow:
FM GWP Plan → FOC Forecast → Working File

Columns populated:
- Historical = usually 0 (FOC items rarely have SI history)
- Baseline = 0
- FOC forecast
- Total SI = FOC only (no revenue)
```

---

## 🎯 Best Practices

### 1. Data Input

**Do:**
- ✅ Cung cấp đầy đủ 24 tháng historical data
- ✅ Update Master Data trước khi run WF generation
- ✅ Validate FM input files trước khi import
- ✅ Đảm bảo BOM structures đã được định nghĩa

**Don't:**
- ❌ Import dữ liệu chưa được kiểm tra
- ❌ Sử dụng data với lỗi hoặc outliers
- ❌ Skip validation steps

---

### 2. Data Mapping

**Do:**
- ✅ Hiểu rõ nguồn của mỗi column trong WF
- ✅ Document các transformation logic
- ✅ Maintain data lineage
- ✅ Version control cho FM input files

**Don't:**
- ❌ Manually override data mà không document
- ❌ Ignore validation warnings
- ❌ Mix data từ nhiều periods

---

### 3. Data Quality

**Do:**
- ✅ Regular data quality checks
- ✅ Reconcile SAP vs WF totals
- ✅ Review outliers và anomalies
- ✅ Validate calculations

**Don't:**
- ❌ Accept data với errors
- ❌ Skip reconciliation
- ❌ Ignore data quality metrics

---

## 🔧 Troubleshooting Data Issues

### Issue 1: Historical data missing

**Symptom:** Some months show 0 or NULL in historical columns

**Root cause:**
- SAP data not extracted for those months
- Product was not active in those periods
- Data extraction job failed

**Solution:**
1. Check SAP for data availability
2. Run manual extraction for missing periods
3. If product inactive → Leave as 0
4. Document gaps in data quality report

---

### Issue 2: Forecast mismatch vs FM input

**Symptom:** WF forecast ≠ FM input file

**Root cause:**
- Data transformation errors
- Mapping logic issues
- FM file version mismatch
- BOM explosion errors

**Solution:**
1. Trace data lineage (see section above)
2. Check transformation stored procedures
3. Validate FM file is correct version
4. Re-run specific step if needed

---

### Issue 3: Budget data not loading

**Symptom:** Budget columns are blank

**Root cause:**
- Budget file not uploaded
- File format incorrect
- Period mismatch
- Product code mismatch

**Solution:**
1. Verify budget file exists
2. Check file format matches template
3. Validate period alignment
4. Check product codes match Master

---

### Issue 4: BOM explosion incorrect

**Symptom:** Component forecast ≠ Expected

**Root cause:**
- BOM structure wrong
- Qty per BOM incorrect
- Multiple BOMs for same component
- Timing mismatch

**Solution:**
1. Check BOM Master table
2. Validate component quantities
3. Review BOM effective dates
4. Re-run BOM explosion step

---

## 📞 Support

For data-related questions:
- **Data quality issues:** Contact Data Team
- **SAP data:** Contact SAP Support
- **FM files:** Contact Demand Planning Lead
- **OPTIMUS data:** Contact Sales Analytics
- **Budget data:** Contact Finance Team

---

**Document Version:** 1.0
**Last Updated:** 2025-11-18
**Owner:** L'Oréal Vietnam Demand Planning Team
