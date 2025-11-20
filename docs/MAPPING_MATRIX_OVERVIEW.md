# Complete Mapping Matrix - Tổng Quan

## 📋 Mục Lục

1. [Giới Thiệu](#1-giới-thiệu)
2. [Cấu Trúc Documentation](#2-cấu-trúc-documentation)
3. [Cách Sử Dụng](#3-cách-sử-dụng)
4. [Tổng Quan Mapping](#4-tổng-quan-mapping)
5. [Quick Reference](#5-quick-reference)

---

## 1. Giới Thiệu

Bộ tài liệu **Complete Mapping Matrix** cung cấp **chi tiết đầy đủ** về cách mỗi field trong Working File (WF) được mapping từ các nguồn dữ liệu khác nhau.

### Mục Đích

- **Truy xuất nguồn gốc dữ liệu**: Hiểu rõ mỗi giá trị trong WF đến từ đâu
- **Hiểu business rules**: Các quy tắc transformation và calculation
- **So sánh giữa các Division**: CPD vs LDB vs LLD differences
- **Troubleshooting**: Debug data issues và validate accuracy

### Phạm Vi

Tài liệu này cover:
- ✅ **3 Divisions**: CPD, LDB, LLD
- ✅ **Historical Data**: SO & SI (Unit & Value)
- ✅ **Forecast Data**: SO & SI (Unit & Value)
- ✅ **Time Series**: Baseline, Promo, Launch, FOC, Total
- ✅ **Channels**: OFFLINE, ONLINE, O+O
- ✅ **Calculation Fields**: SOH, GIT, SIT, SLOB, Risk, MTD, Averages
- ✅ **Budget Data**: BP, Pre-Budget, Trend
- ✅ **Version Control**: M-1 versions

---

## 2. Cấu Trúc Documentation

Bộ tài liệu được chia thành **6 files**:

### 📄 File Structure

```
docs/
├── MAPPING_MATRIX_OVERVIEW.md          ← File này (Tổng quan)
├── MAPPING_MATRIX_CPD.md               ← Chi tiết CPD Division
├── MAPPING_MATRIX_LDB.md               ← Chi tiết LDB Division
├── MAPPING_MATRIX_LLD.md               ← Chi tiết LLD Division
├── MAPPING_MATRIX_FIELDS.md            ← Chi tiết từng field type
└── MAPPING_MATRIX_COMPARISON.md        ← So sánh cross-division
```

### 📄 MAPPING_MATRIX_OVERVIEW.md (File này)

**Nội dung:**
- Tổng quan về hệ thống mapping
- Cách sử dụng các tài liệu
- Quick reference guide
- Glossary và FAQs

### 📄 MAPPING_MATRIX_CPD.md

**Nội dung:**
- Historical SO mapping (Unit & Value)
- Historical SI mapping (Unit & Value)
- Forecast mapping với Time Series breakdown
- BOM explosion rules
- Channel mapping (GT, MT, Pharma, Online)
- Promo và FOC handling
- Complete field-to-source matrix cho CPD

**Ví dụ:**
```
Column: [Y-1 (u) M3]
Division: CPD
Time Series: 1. Baseline Qty
Channel: OFFLINE

→ Source: Optimus SO data
→ Procedure: sp_add_FC_SO_OPTIMUS_NORMAL_Tmp
→ Processing: sp_Run_SO_HIS_FULL
→ Final Table: FC_CPD_SO_HIS_FINAL
→ Filter: Division='CPD', Channel='OFFLINE', Period='202303'
```

### 📄 MAPPING_MATRIX_LDB.md

**Nội dung:**
- LDB-specific conversion procedures
- Category-based mapping (Dermatology vs Professional)
- Channel mapping (Pharma, Salon, Retail, Online)
- SO conversion rules (`sp_fc_convert_SO_LDB_SO`)
- SI conversion rules (`sp_fc_convert_SO_LDB_SI`)
- Complete field-to-source matrix cho LDB

**Ví dụ:**
```
Column: [Y0 (u) M6]
Division: LDB
Time Series: 1. Baseline Qty
Channel: OFFLINE (Pharma)

→ Source: Optimus SO + Conversion
→ Procedure: sp_add_FC_SO_OPTIMUS_NORMAL_LDB_Tmp
→ Conversion: sp_fc_convert_SO_LDB_SO (Category-specific factors)
→ Category: Dermatology → Factor 1.05
→ Final Table: FC_LDB_SO_HIS_FINAL
```

### 📄 MAPPING_MATRIX_LLD.md

**Nội dung:**
- LLD dual-source baseline (FM + FM Non-Modeling)
- Luxury product characteristics
- Premium channel focus
- Forecast methodology differences
- Manual adjustment process
- Complete field-to-source matrix cho LLD

**Ví dụ:**
```
Column: [Y0 (u) M3]
Division: LLD
Time Series: 1. Baseline Qty
Channel: OFFLINE

→ Source 1: FM (FuturMaster Modeling) = 500 units
→ Procedure 1: sp_add_FC_FM_Tmp
→ Source 2: FM Non-Modeling (Manual) = +100 units
→ Procedure 2: sp_add_FC_FM_Non_Modeling_Tmp
→ Total Baseline: 600 units
→ Final Table: FC_FM_Original_LLD
```

### 📄 MAPPING_MATRIX_FIELDS.md

**Nội dung:**
- Chi tiết từng loại field trong WF
- Organized by field category:
  - **Historical columns** (`[Y-2 (u) M*]`, `[Y-1 (u) M*]`)
  - **Forecast columns** (`[Y0 (u) M*]`, `[Y+1 (u) M*]`)
  - **Value columns** (`[(Value)_Y-2 (u) M*]`)
  - **Stock fields** (`[SOH]`, `[GIT M0-M3]`, `[SIT]`)
  - **Risk fields** (`[SLOB]`, `[Risk (u) M0-M3]`)
  - **Average fields** (`[AVE P3M Y0]`, `[AVE F3M Y0]`)
  - **Budget fields** (`[B_Y0_M*]`, `[PB_Y+1_M*]`, `[T1-3_Y0_M*]`)
  - **Version fields** (`[(m-1)_Y0 (u) M*]`)
  - **MTD fields** (`[MTD SI]`)

**Ví dụ:**
```
Field Type: [SOH]
Full Name: Stock on Hand

Sources:
- SAP Report: ZMR32 (Daily)
- Import Proc: sp_add_SOH_Tmp
- Process Proc: sp_Create_SOH_FINAL
- Raw Table: V_SOH_RAW
- Final Table: FC_SOH_FINAL

Filters:
- Stock_Type IN ('UNRESTRICTED', 'QUALITY_INSPECTION')
- Stock_Type NOT IN ('BLOCKED', 'RETURNS')

Aggregation:
- Level: Sub_Group
- Measure: Quantity (units)

Update Frequency: Daily (morning)

Used In Calculations:
- SIT = SOH - GIT_M0
- SLOB = SOH / AVE_P3M
- Stock Coverage = SOH / AVE_P3M
```

### 📄 MAPPING_MATRIX_COMPARISON.md

**Nội dung:**
- Side-by-side comparison của 3 divisions
- Highlight differences và commonalities
- Decision tree: "Khi nào dùng rule nào?"
- Special cases và exceptions
- Cross-division impacts

**Ví dụ:**
```
Feature: Historical SO Import

CPD:
- Source: Optimus Standard
- Procedure: sp_add_FC_SO_OPTIMUS_NORMAL_Tmp
- Conversion: None
- Channels: GT, MT, PHARMA → OFFLINE; ONLINE → ONLINE
- BOM: Heavy (many bundles)

LDB:
- Source: Optimus + Conversion
- Procedure: sp_add_FC_SO_OPTIMUS_NORMAL_LDB_Tmp
- Conversion: sp_fc_convert_SO_LDB_SO (Category factors)
- Channels: Pharma → OFFLINE; Salon → OFFLINE; Online → ONLINE
- BOM: Medium

LLD:
- Source: Optimus Standard
- Procedure: sp_add_FC_SO_OPTIMUS_NORMAL_Tmp
- Conversion: None
- Channels: Premium Retail → OFFLINE; Online → ONLINE
- BOM: Low (mostly single products)
```

---

## 3. Cách Sử Dụng

### Kịch Bản 1: Tìm Nguồn Của Một Field Cụ Thể

**Câu hỏi:** "Column `[Y-1 (u) M6]` trong CPD WF lấy từ đâu?"

**Các bước:**

1. **Xác định Division**: CPD
2. **Xác định Field Type**:
   - `Y-1` → Historical data (năm trước)
   - `(u)` → Unit data
   - `M6` → Tháng 6
3. **Mở file**: `MAPPING_MATRIX_CPD.md`
4. **Tìm section**: "Historical SO - Unit"
5. **Đọc mapping details**:
   ```
   Source: Optimus SO data
   Procedure: sp_add_FC_SO_OPTIMUS_NORMAL_Tmp
   Table: FC_CPD_SO_HIS_FINAL
   Period: Y-1 M6 = June of last year
   ```

### Kịch Bản 2: So Sánh Cùng Field Giữa Các Division

**Câu hỏi:** "Tại sao LDB có thêm conversion mà CPD không?"

**Các bước:**

1. **Mở file**: `MAPPING_MATRIX_COMPARISON.md`
2. **Tìm section**: "Historical SO Import Comparison"
3. **Đọc so sánh**:
   ```
   CPD: Direct from Optimus (no conversion)
   → Consumer products: Standard retail flow

   LDB: Optimus + Conversion procedure
   → Professional/Dermatology: Different unit definitions
   → Salon products: Conversion factors by category
   → Pharma products: Regulatory requirements
   ```

### Kịch Bản 3: Hiểu Calculation Logic

**Câu hỏi:** "SLOB được tính như thế nào?"

**Các bước:**

1. **Mở file**: `MAPPING_MATRIX_FIELDS.md`
2. **Tìm section**: "Risk Fields → SLOB"
3. **Đọc formula**:
   ```
   SLOB Calculation:

   Step 1: Calculate Stock Coverage
   Stock_Coverage = SOH / AVE_P3M

   Step 2: Determine Risk Level
   IF AVE_P3M = 0 AND SOH > 0 THEN 'DEAD_STOCK'
   ELSE IF Stock_Coverage > 3 THEN 'HIGH'
   ELSE IF Stock_Coverage > 2 THEN 'MEDIUM'
   ELSE 'LOW'

   Example:
   SOH = 15000 units
   AVE_P3M = 2000 units/month
   Stock_Coverage = 15000/2000 = 7.5 months
   SLOB = 'HIGH' (over 3 months)
   ```

### Kịch Bản 4: Debug Data Issue

**Câu hỏi:** "Tại sao LLD Baseline forecast khác với FM file?"

**Các bước:**

1. **Mở file**: `MAPPING_MATRIX_LLD.md`
2. **Tìm section**: "Forecast Baseline - Dual Source"
3. **Kiểm tra logic**:
   ```
   LLD Baseline = FM + FM Non-Modeling

   Check 1: FM file imported?
   → sp_add_FC_FM_Tmp completed?

   Check 2: FM Non-Modeling file imported?
   → sp_add_FC_FM_Non_Modeling_Tmp completed?

   Check 3: Combine logic correct?
   → FC_FM_Original_LLD.Baseline =
      ISNULL(FM.Baseline, 0) +
      ISNULL(FM_Non_Modeling.Baseline, 0)
   ```

---

## 4. Tổng Quan Mapping

### 4.1. Data Flow Overview

```
INPUT SOURCES
│
├─ SAP Reports
│  ├─ ZV14 (Sell-In data)
│  ├─ ZMR32 (Stock on Hand)
│  └─ GIT Report (Goods in Transit)
│
├─ Optimus System
│  ├─ SO Normal (Sell-Out regular)
│  └─ SO Promo BOM (Sell-Out promotional)
│
├─ Excel Files
│  ├─ FM (FuturMaster forecast)
│  ├─ FM Non-Modeling (LLD manual)
│  ├─ Budget files (BP, Pre-Budget, Trend)
│  ├─ Master files (Spectrum, BFL, Customer)
│  └─ Config files (WF config, BOM)
│
└─ Database Tables
   ├─ Historical tables (SO_HIS_FINAL, SI tables)
   └─ Master tables (SubGroupMaster, Product hierarchy)

↓ PROCESSING LAYERS ↓

IMPORT LAYER (./Script/1. FINAL/0. link_37/)
├─ sp_add_FC_SO_OPTIMUS_NORMAL_Tmp
├─ sp_add_FC_SI_OPTIMUS_NORMAL_Tmp
├─ sp_add_FC_FM_Tmp
├─ sp_add_FC_FM_Non_Modeling_Tmp (LLD only)
├─ sp_add_FC_GIT_Tmp
└─ ... (30+ import procedures)

↓

TRANSFORMATION LAYER (./Script/1. FINAL/1. Action/)
├─ Division-specific conversions
│  ├─ sp_fc_convert_SO_LDB_SO (LDB only)
│  └─ sp_fc_convert_SO_LDB_SI (LDB only)
├─ Channel mapping
├─ Product hierarchy mapping
├─ Time period mapping
└─ BOM explosion
   ├─ sp_Update_Bom_Header_New
   └─ sp_Gen_BomHeader_Forecast_New

↓

CALCULATION LAYER (./Script/1. FINAL/1. Action/)
├─ Stock calculations
│  ├─ sp_Create_SOH_FINAL
│  ├─ sp_tag_update_wf_sit_NEW (SIT = SOH - GIT_M0)
│  └─ sp_FC_GIT_New
├─ Risk calculations
│  ├─ sp_tag_update_slob_wf
│  └─ sp_fc_fm_risk_3M
├─ Average calculations
│  ├─ sp_tag_Update_WF_AVG_HIS_3M_Y0_SI_unit (AVE P3M)
│  └─ (AVE F3M calculated)
├─ Budget calculations
│  ├─ sp_tag_gen_budget_budget_New
│  ├─ sp_tag_gen_budget_pre_budget_new
│  └─ sp_tag_gen_budget_trend_new
└─ Total calculations
   ├─ sp_tag_update_wf_total_unit_new (O+O aggregation)
   └─ sp_calculate_total (6. Total Qty = 1+2+4+5)

↓

AGGREGATION LAYER (./Script/1. FINAL/1. Action/)
├─ Time series aggregation
│  ├─ 1. Baseline Qty
│  ├─ 2. Promo Qty
│  ├─ 4. Launch Qty
│  ├─ 5. FOC Qty
│  └─ 6. Total Qty (sum)
├─ Channel aggregation
│  ├─ OFFLINE
│  ├─ ONLINE
│  └─ O+O (combined view)
└─ Division-level views
   ├─ V_FC_FM_Original_CPD
   ├─ V_FC_FM_Original_LDB (in Action folder)
   └─ V_FC_FM_Original_LLD

↓

OUTPUT (Working File - Excel)
├─ Historical columns (Y-2, Y-1, past Y0)
├─ Forecast columns (future Y0, Y+1)
├─ Value columns (Unit × Price)
├─ Stock columns (SOH, GIT, SIT)
├─ Risk columns (SLOB, Risk M0-M3)
├─ Average columns (AVE P3M, AVE F3M)
├─ Budget columns (BP, PB, Trend)
└─ Metadata (Product hierarchy, Channel, Time series)
```

### 4.2. Division-Specific Flows

#### CPD Flow

```
Optimus SO → sp_add_FC_SO_OPTIMUS_NORMAL_Tmp → FC_CPD_SO_HIS_FINAL
                                                         ↓
ZV14 SI → sp_add_FC_SI_OPTIMUS_NORMAL_Tmp → FC_SI_OPTIMUS_NORMAL_CPD
                                                         ↓
FM File → sp_add_FC_FM_Tmp → FC_FM_CPD_Tmp → BOM Explosion → FC_FM_Original_CPD
                                                                      ↓
                                              Join Historical + Forecast + Stock
                                                                      ↓
                                                    V_FC_FM_Original_CPD
                                                                      ↓
                                                      WF Excel Export
```

**CPD Special Features:**
- Heavy BOM processing (bundles, gift sets)
- High promo activity
- FOC tracking
- Multiple channels (GT, MT, Pharma, Online)

#### LDB Flow

```
Optimus SO → sp_add_FC_SO_OPTIMUS_NORMAL_LDB_Tmp → sp_fc_convert_SO_LDB_SO
                                                              ↓
                                                    FC_LDB_SO_HIS_FINAL
                                                              ↓
ZV14 SI → sp_add_FC_SI_OPTIMUS_NORMAL_Tmp → sp_fc_convert_SO_LDB_SI
                                                              ↓
                                                    FC_SI_OPTIMUS_NORMAL_LDB
                                                              ↓
FM File + SI Template → sp_add_FC_FM_Tmp → FC_FM_Original_LDB
                                                              ↓
                                              Join + Category Logic
                                                              ↓
                                                V_FC_FM_Original_LDB
                                                              ↓
                                                  WF Excel Export
```

**LDB Special Features:**
- Category-based conversion (Dermatology vs Professional)
- Channel-specific rules (Pharma, Salon)
- SI Template usage
- Lower promo activity

#### LLD Flow

```
Optimus SO → sp_add_FC_SO_OPTIMUS_NORMAL_Tmp → FC_LLD_SO_HIS_FINAL
                                                         ↓
ZV14 SI → sp_add_FC_SI_OPTIMUS_NORMAL_Tmp → FC_SI_OPTIMUS_NORMAL_LLD
                                                         ↓
FM File → sp_add_FC_FM_Tmp ────────┐
                                   ├→ Combine Baseline → FC_FM_Original_LLD
FM Non-Modeling → sp_add_FC_FM_Non_Modeling_Tmp ┘
                                                         ↓
                                    Join Historical + Dual Forecast + Stock
                                                         ↓
                                               V_FC_FM_Original_LLD
                                                         ↓
                                                 WF Excel Export
```

**LLD Special Features:**
- **Dual forecast source** (FM + FM Non-Modeling)
- Luxury product focus (high value, low volume)
- Manual adjustment capability
- Premium channel focus
- Less promo/FOC activity

### 4.3. Time Series Mapping

All divisions use the same time series structure:

| Time Series | Description | Source | Editable |
|-------------|-------------|--------|----------|
| **1. Baseline Qty** | Regular sales forecast | FM file / User input | Yes |
| **2. Promo Qty** | Promotional incremental | User input + Promo calendar | Yes |
| **4. Launch Qty** | New product launch (first 3M) | FM Non-Modeling / User input | Yes |
| **5. FOC Qty** | Free of charge | User input | Yes |
| **6. Total Qty** | Sum of all | Calculated: 1+2+4+5 | No (auto) |

**Division Differences:**

| Division | Baseline Source | Promo Emphasis | Launch Source | FOC Usage |
|----------|-----------------|----------------|---------------|-----------|
| **CPD** | FM + User | High | User input | High (samples, GWP) |
| **LDB** | FM + SI Template | Low (pharma rules) | FM Non-Modeling | Medium (medical samples) |
| **LLD** | **FM + FM Non-Modeling** | Very Low | FM Non-Modeling | Low (VIP gifts) |

### 4.4. Channel Mapping

#### CPD Channels

```
Raw Data Channel → System Channel
─────────────────────────────────
GT (General Trade) → OFFLINE
MT (Modern Trade) → OFFLINE
PHARMA → OFFLINE
ONLINE → ONLINE
E-commerce → ONLINE
```

#### LDB Channels

```
Raw Data Channel → System Channel → Notes
──────────────────────────────────────────
PHARMA → OFFLINE → Main channel for dermo (60-70%)
SALON → OFFLINE → Professional hair care (20-30%)
RETAIL → OFFLINE → Limited
ONLINE → ONLINE → Growing segment
```

#### LLD Channels

```
Raw Data Channel → System Channel → Notes
──────────────────────────────────────────
PREMIUM_RETAIL → OFFLINE → Department stores, luxury retailers
DUTY_FREE → OFFLINE → Airport, travel retail
ONLINE → ONLINE → Official brand sites, luxury e-comm
TRAVEL_RETAIL → OFFLINE → Special channel
```

### 4.5. Field Naming Convention

Understanding column names:

```
[Y-2 (u) M6]
 │  │  │  │
 │  │  │  └─ M6 = Month 6 (June)
 │  │  └──── (u) = Unit (quantity)
 │  └─────── -2 = 2 years ago (Y-2)
 └────────── Y = Year indicator

[(Value)_Y0 (u) M3]
   │     │  │  │
   │     │  │  └─ M3 = Month 3 (March)
   │     │  └──── (u) = Unit (but value column)
   │     └─────── Y0 = Current year
   └───────────── (Value) = Value column (VND)

[B_Y0_M6]
 │ │  │
 │ │  └─ M6 = Month 6
 │ └──── Y0 = Current year
 └────── B = Budget

[GIT M0]
  │  │
  │  └─ M0 = Current month
  └──── GIT = Goods in Transit

[AVE P3M Y0]
  │  │   │
  │  │   └─ Y0 = Current year
  │  └───── P3M = Previous 3 Months
  └──────── AVE = Average
```

**Pattern Summary:**

| Pattern | Meaning | Example |
|---------|---------|---------|
| `Y-2` | 2 years ago | 2023 if current is 2025 |
| `Y-1` | Last year | 2024 if current is 2025 |
| `Y0` | Current year | 2025 |
| `Y+1` | Next year | 2026 if current is 2025 |
| `(u)` | Unit measure | Quantity in pieces/bottles |
| `(Value)` | Value measure | VND (Vietnamese Dong) |
| `M1-M12` | Month number | M1=Jan, M12=Dec |
| `(m-1)` | Previous month version | Last month's forecast |
| `B_` | Budget | From finance BP file |
| `PB_` | Pre-Budget | Preliminary budget |
| `T1, T2, T3` | Trend versions | Trend 1, 2, 3 |
| `SOH` | Stock on Hand | Current physical stock |
| `GIT M0-M3` | Goods in Transit | M0=this month, M3=+3 months |
| `SIT` | Stock in Transit | SOH - GIT_M0 |
| `SLOB` | Slow-moving/Obsolete | Risk level: HIGH/MEDIUM/LOW |
| `MTD SI` | Month-to-Date Sell-In | Accumulated SI this month |
| `AVE P3M` | Average Previous 3M | Avg of last 3 months |
| `AVE F3M` | Average Forecast 3M | Avg of next 3 months |

---

## 5. Quick Reference

### 5.1. Tìm Nhanh Theo Division

**Câu hỏi: CPD field mapping?**
→ Mở `MAPPING_MATRIX_CPD.md`

**Câu hỏi: LDB conversion rules?**
→ Mở `MAPPING_MATRIX_LDB.md` → Section "Conversion Procedures"

**Câu hỏi: LLD dual baseline?**
→ Mở `MAPPING_MATRIX_LLD.md` → Section "Forecast Baseline - Dual Source"

### 5.2. Tìm Nhanh Theo Field Type

**Câu hỏi: SOH calculation?**
→ Mở `MAPPING_MATRIX_FIELDS.md` → Section "Stock Fields → SOH"

**Câu hỏi: SLOB logic?**
→ Mở `MAPPING_MATRIX_FIELDS.md` → Section "Risk Fields → SLOB"

**Câu hỏi: Historical columns?**
→ Mở `MAPPING_MATRIX_FIELDS.md` → Section "Historical Columns"

**Câu hỏi: Budget mapping?**
→ Mở `MAPPING_MATRIX_FIELDS.md` → Section "Budget Fields"

### 5.3. Tìm Nhanh So Sánh

**Câu hỏi: CPD vs LDB vs LLD differences?**
→ Mở `MAPPING_MATRIX_COMPARISON.md`

**Câu hỏi: Why LDB needs conversion?**
→ Mở `MAPPING_MATRIX_COMPARISON.md` → Section "Conversion Requirements"

**Câu hỏi: Channel mapping differences?**
→ Mở `MAPPING_MATRIX_COMPARISON.md` → Section "Channel Mapping Comparison"

### 5.4. Common Questions

**Q: Tại sao có cả Unit và Value columns?**

A:
- **Unit**: Số lượng sản phẩm (pieces, bottles, etc.)
- **Value**: Giá trị tiền tệ (VND)
- Value = Unit × Price
- Business cần cả 2 để:
  - Planning: Focus on Unit (volume)
  - Finance: Focus on Value (revenue)
  - Analysis: Compare both (price mix, value per unit)

**Q: OFFLINE vs ONLINE vs O+O là gì?**

A:
- **OFFLINE**: Physical retail channels (stores, pharmacies, salons)
- **ONLINE**: E-commerce channels (websites, apps, online marketplaces)
- **O+O**: Combined view (Offline + Online total)
- Why separate? Different demand patterns, pricing, promotions

**Q: Time series 1,2,4,5,6 - missing 3?**

A: Historical reasons:
- **1**: Baseline Qty
- **2**: Promo Qty
- **3**: (Deprecated - was used for something else before)
- **4**: Launch Qty
- **5**: FOC Qty
- **6**: Total Qty (sum of 1+2+4+5)

**Q: LLD tại sao có FM Non-Modeling?**

A: Luxury division characteristics:
- High-value, low-volume products
- Statistical models less accurate (small sample size)
- Expert judgment more important
- **FM (Modeling)**: Statistical baseline from FuturMaster
- **FM Non-Modeling**: Expert adjustments for:
  - New launches not in model
  - Market events (fashion shows, celebrity endorsements)
  - Strategic decisions (brand positioning changes)

**Q: BOM là gì và division nào dùng nhiều nhất?**

A:
- **BOM**: Bill of Materials (danh sách cấu thành)
- Bundle/Gift Set = Parent product
- Components = Individual products inside
- **CPD**: Heavy BOM usage (gift sets, promo packs, multi-product bundles)
- **LDB**: Medium BOM usage (some salon kits)
- **LLD**: Low BOM usage (mostly single luxury products)

Example:
```
Bundle: "L'Oreal Youth Code Gift Set" (1 set)
├─ Youth Code Serum 30ml (1 bottle)
├─ Youth Code Day Cream 50ml (1 jar)
└─ Youth Code Night Cream 50ml (1 jar)

Forecast: 100 sets
→ BOM Explosion:
  - 100 Serum bottles
  - 100 Day Cream jars
  - 100 Night Cream jars
```

**Q: M-1 version là gì?**

A:
- **M-1**: Month minus 1 (tháng trước)
- **Purpose**: Version control and comparison
- **Columns**: `[(m-1)_Y0 (u) M*]`
- **Usage**:
  - Compare current forecast vs last month's forecast
  - Track forecast changes month-over-month
  - Audit trail for demand planner decisions

**Q: MTD SI vs Historical SI khác gì?**

A:
- **MTD SI**: Month-to-Date Sell-In (current month, not complete)
  - Updates daily as orders complete
  - Example: Today is Jan 15 → MTD = Jan 1-15 total
  - Used for in-month tracking
- **Historical SI**: Completed months
  - Full month data
  - Example: December SI = Dec 1-31 total
  - Used for past analysis

---

## 6. Glossary

| Term | Vietnamese | Description |
|------|------------|-------------|
| **Division** | Bộ phận | CPD, LDB, LLD - L'Oréal business divisions |
| **Sell-Out (SO)** | Bán ra | Sales from retailers to consumers |
| **Sell-In (SI)** | Bán vào | Sales from L'Oréal to retailers |
| **FM** | - | FuturMaster (forecasting tool/file) |
| **WF** | - | Working File (Excel file for forecast input) |
| **Time Series** | Chuỗi thời gian | Baseline, Promo, Launch, FOC, Total |
| **BOM** | - | Bill of Materials (bundle components) |
| **SOH** | - | Stock on Hand (current physical stock) |
| **GIT** | - | Goods in Transit (incoming shipments) |
| **SIT** | - | Stock in Transit (SOH - GIT_M0) |
| **SLOB** | - | Slow-moving/Obsolete (risk level) |
| **MTD** | - | Month-to-Date (current month accumulation) |
| **AVE P3M** | - | Average Previous 3 Months |
| **AVE F3M** | - | Average Forecast 3 Months |
| **BP** | - | Budget Plan (from Finance) |
| **PB** | - | Pre-Budget (preliminary budget) |
| **M-1** | - | Previous month version |
| **Spectrum** | - | Product code (SAP material number) |
| **Sub Group** | Nhóm con | Product grouping level (brand/variant) |
| **O+O** | - | Offline + Online combined |
| **FOC** | - | Free of Charge (samples, gifts) |

---

## 7. FAQs

### Câu Hỏi Thường Gặp

**Q1: File nào tôi nên đọc đầu tiên?**

A: Depends on mục đích:
- **Tổng quan**: Đọc file này (OVERVIEW)
- **Hiểu một Division cụ thể**: Đọc file Division tương ứng (CPD/LDB/LLD)
- **Hiểu một field cụ thể**: Đọc FIELDS
- **So sánh divisions**: Đọc COMPARISON

**Q2: Làm sao biết một column là Historical hay Forecast?**

A: Dựa vào Year indicator:
- `Y-2`, `Y-1`: Historical (past years)
- `Y0`: Mixed (past months = Historical, future months = Forecast)
- `Y+1`: Forecast (next year)

**Q3: Tại sao có nhiều procedures cho cùng một task?**

A: Historical evolution:
- `_Old`, `_TEST`: Deprecated versions (keep for reference)
- `_New`, `_NEW`: Current versions
- `_DEV`, `_draft`: Development/testing versions
- No suffix: Original or stable version

**Q4: Database nào chứa dữ liệu này?**

A: SQL Server database (L'Oréal Forecast database)
- Tables: `FC_*` prefix (Forecast tables)
- Views: `V_*` prefix
- Functions: `fnc_*` prefix
- Stored Procedures: `sp_*` prefix

**Q5: Làm sao trace một giá trị cụ thể trong WF?**

A: Step-by-step tracing:

1. **Identify field details**:
   - Column name (e.g., `[Y-1 (u) M6]`)
   - Row details (Sub Group, Channel, Time Series)

2. **Find Division**: CPD/LDB/LLD

3. **Determine field type**: Historical SO/SI or Forecast

4. **Open relevant doc**: MAPPING_MATRIX_{Division}.md

5. **Find mapping section**: Historical SO - Unit section

6. **Trace source**:
   ```
   WF: [Y-1 (u) M6] = 1500
   ↓
   View: V_FC_FM_Original_CPD
   ↓
   Table: FC_CPD_SO_HIS_FINAL
   ↓
   Function: fnc_FC_SO_HIS_FINAL('CPD')
   ↓
   Raw Table: FC_SO_OPTIMUS_NORMAL_CPD
   ↓
   Import: sp_add_FC_SO_OPTIMUS_NORMAL_Tmp
   ↓
   Source File: SELLOUT_CPD_20240615.xlsx (Optimus)
   ```

7. **Verify with SQL**:
   ```sql
   -- Check final value
   SELECT [Y-1 (u) M6]
   FROM V_FC_FM_Original_CPD
   WHERE [SUB GROUP/ Brand] = 'Your Sub Group'
     AND [Channel] = 'OFFLINE'
     AND [Time series] = '6. Total Qty'

   -- Trace to source
   SELECT SUM(SellOut) AS Total
   FROM FC_CPD_SO_HIS_FINAL
   WHERE Sub_Group = 'Your Sub Group'
     AND Channel = 'OFFLINE'
     AND PeriodKey = '202406' -- Y-1 M6 = June of last year
   ```

---

## 8. Cập Nhật và Bảo Trì

**Document Version:** 1.0
**Last Updated:** 2025-11-19
**Maintained by:** Technical Team

### Change Log

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 1.0 | 2025-11-19 | Initial creation - Complete Mapping Matrix documentation suite | Technical Team |

### Related Documents

Core documentation:
- [DATA_FLOW_OVERVIEW.md](./DATA_FLOW_OVERVIEW.md) - System architecture
- [INPUT_DATA_SPECIFICATION.md](./INPUT_DATA_SPECIFICATION.md) - Input specifications
- [DATA_MAPPING_PROCESS.md](./DATA_MAPPING_PROCESS.md) - Mapping process
- [DATA_SOURCE_MAPPING.md](./DATA_SOURCE_MAPPING.md) - Division-specific sources
- [BUSINESS_LOGIC_FLOW.md](./BUSINESS_LOGIC_FLOW.md) - Business logic
- [OUTPUT_SPECIFICATION.md](./OUTPUT_SPECIFICATION.md) - Output specifications
- [README.md](./README.md) - Documentation index

Mapping Matrix suite:
- **MAPPING_MATRIX_OVERVIEW.md** ← This file
- [MAPPING_MATRIX_CPD.md](./MAPPING_MATRIX_CPD.md)
- [MAPPING_MATRIX_LDB.md](./MAPPING_MATRIX_LDB.md)
- [MAPPING_MATRIX_LLD.md](./MAPPING_MATRIX_LLD.md)
- [MAPPING_MATRIX_FIELDS.md](./MAPPING_MATRIX_FIELDS.md)
- [MAPPING_MATRIX_COMPARISON.md](./MAPPING_MATRIX_COMPARISON.md)

---

## 9. Liên Hệ và Hỗ Trợ

### Để được hỗ trợ:

**Technical Questions:**
- Database issues: DBA Team
- Procedure errors: Development Team
- Data accuracy: Data Quality Team

**Business Questions:**
- Forecast methodology: Demand Planning Team
- Budget alignment: Finance Team
- Division-specific rules: Division managers

**Documentation Issues:**
- Report errors or suggestions to: Technical Documentation Team
- Request updates: Submit via ticketing system

---

**Next Steps:**

- 📖 Read division-specific documents: [CPD](./MAPPING_MATRIX_CPD.md) | [LDB](./MAPPING_MATRIX_LDB.md) | [LLD](./MAPPING_MATRIX_LLD.md)
- 🔍 Explore field details: [MAPPING_MATRIX_FIELDS.md](./MAPPING_MATRIX_FIELDS.md)
- ⚖️ Compare divisions: [MAPPING_MATRIX_COMPARISON.md](./MAPPING_MATRIX_COMPARISON.md)
