# L'Oréal Forecasting Tool - Tài Liệu Hướng Dẫn

## 📋 Mục Lục

- [Giới Thiệu](#giới-thiệu)
- [Cấu Trúc Tài Liệu](#cấu-trúc-tài-liệu)
- [Hướng Dẫn Đọc Tài Liệu](#hướng-dẫn-đọc-tài-liệu)
- [Quick Reference](#quick-reference)
- [Glossary](#glossary)
- [FAQs](#faqs)

---

## Giới Thiệu

Bộ tài liệu này mô tả chi tiết **luồng dữ liệu business** của hệ thống **L'Oréal Forecasting Tool** - công cụ quản lý dự báo bán hàng cho L'Oréal Vietnam.

### Mục Đích Tài Liệu

✅ Hiểu rõ **nguồn dữ liệu đầu vào** và format
✅ Nắm vững **quy trình mapping** và transformation
✅ Hiểu **logic nghiệp vụ** và các công thức tính toán
✅ Biết cách sử dụng các **outputs** được tạo ra
✅ Tra cứu nhanh **nguồn gốc** của mỗi field trong hệ thống

### Đối Tượng Người Đọc

👥 **Demand Planners**: Người sử dụng hệ thống để dự báo
👥 **IT Team**: Developers, Database Admins, Support
👥 **Finance Team**: Quản lý budget và phân tích gaps
👥 **Supply Chain**: Sử dụng forecast cho planning
👥 **Management**: Hiểu tổng quan hệ thống

---

## Cấu Trúc Tài Liệu

### 📚 Danh Sách Tài Liệu

Bộ tài liệu gồm **6 files chính**, được sắp xếp theo thứ tự logic của luồng dữ liệu:

| # | File | Nội Dung | Dung Lượng | Đọc Trong |
|---|------|----------|------------|-----------|
| 1 | [**DATA_FLOW_OVERVIEW.md**](./DATA_FLOW_OVERVIEW.md) | Tổng quan luồng dữ liệu end-to-end | 18 KB | 15 phút |
| 2 | [**INPUT_DATA_SPECIFICATION.md**](./INPUT_DATA_SPECIFICATION.md) | Chi tiết các nguồn dữ liệu đầu vào | 20 KB | 20 phút |
| 3 | [**DATA_SOURCE_MAPPING.md**](./DATA_SOURCE_MAPPING.md) | Mapping từng field với nguồn dữ liệu | 35 KB | 25 phút |
| 4 | [**DATA_MAPPING_PROCESS.md**](./DATA_MAPPING_PROCESS.md) | Quy trình mapping chi tiết | 32 KB | 25 phút |
| 5 | [**BUSINESS_LOGIC_FLOW.md**](./BUSINESS_LOGIC_FLOW.md) | Logic nghiệp vụ và tính toán | 37 KB | 30 phút |
| 6 | [**OUTPUT_SPECIFICATION.md**](./OUTPUT_SPECIFICATION.md) | Đặc tả kết quả đầu ra | 40 KB | 30 phút |

**Tổng cộng**: ~180 KB, ~145 phút đọc (2.5 giờ)

---

### 📖 1. DATA_FLOW_OVERVIEW.md

**Tổng quan về luồng dữ liệu từ đầu đến cuối**

#### Nội dung chính:
- ✅ Kiến trúc hệ thống 3 tầng (Input → Processing → Output)
- ✅ 4 giai đoạn xử lý dữ liệu (Import, Transformation, Calculation, Consolidation)
- ✅ Cấu trúc database (458+ SQL scripts)
- ✅ Network paths và file locations
- ✅ Tần suất cập nhật dữ liệu
- ✅ Version control và disaster recovery

#### Khi nào đọc:
- 🎯 **Đầu tiên**: Để hiểu tổng quan hệ thống
- 🎯 **Onboarding**: Team member mới tham gia
- 🎯 **System design**: Khi cần thiết kế tính năng mới

#### Key Diagrams:
```
Input Layer → Processing Layer → Output Layer
     ↓              ↓                ↓
SAP/Excel    SQL Processing    WF/FM/BI Reports
```

---

### 📖 2. INPUT_DATA_SPECIFICATION.md

**Chi tiết về tất cả các nguồn dữ liệu đầu vào**

#### Nội dung chính:

**A. SAP Data**
- ✅ Sell-Out (SO) - Dữ liệu bán ra từ Optimus
- ✅ Sell-In (SI) - Dữ liệu đặt hàng từ ZV14
- ✅ GIT (Goods in Transit) - Hàng đang trên đường
- ✅ Stock (ZMR32) - Tồn kho

**B. Master Data Files**
- ✅ Spectrum Master - Product hierarchy
- ✅ BFL Master - Bill of Formula List
- ✅ Customer Master - Thông tin khách hàng
- ✅ FC Budget - Dữ liệu budget

**C. Working File**
- ✅ Cấu trúc sheet SysConfig, WF, BOM Header
- ✅ Column definitions và data types
- ✅ Validation rules

#### Khi nào đọc:
- 🎯 **Troubleshooting**: Khi có lỗi import data
- 🎯 **Data validation**: Kiểm tra tính đúng đắn của input
- 🎯 **New data source**: Khi thêm nguồn dữ liệu mới

#### Quick Reference:
```
SAP Data Path: \\10.240.65.43\loreal\10_PUBLIC\03_SAPData\SC_IMPORT\Archive\
WF Location: C:\Users\Public\Downloads\Application\FC\Extension\FILES\
```

---

### 📖 3. DATA_SOURCE_MAPPING.md ⭐ NEW

**Chi tiết nguồn dữ liệu cho TỪNG field trong hệ thống**

#### Nội dung chính:

**A. Time Series Mapping**
- ✅ **1. Baseline Qty**: Lấy từ đâu? Filter gì? (Historical_SO với Order_Type='ZOR')
- ✅ **2. Promo Qty**: Lấy từ đâu? (ZPROMO orders + Promo_Calendar)
- ✅ **4. Launch Qty**: Lấy từ đâu? (ZLAUNCH + Launch_Date logic)
- ✅ **5. FOC Qty**: Lấy từ đâu? (ZFOC orders)
- ✅ **6. Total Qty**: Công thức tính (Sum của 1+2+4+5)

**B. Channel Mapping**
- ✅ **ONLINE**: Từ Customer_Master.Channel = 'ONLINE'
- ✅ **OFFLINE**: Từ GT/MT/PHARMA/SALON → OFFLINE
- ✅ **O+O**: ONLINE + OFFLINE (calculated)

**C. Calculation Fields**
- ✅ **AVE P3M**: Average previous 3 months (từ Historical_SO)
- ✅ **AVE F3M**: Average forecast 3 months (từ User Input)
- ✅ **SOH**: Stock on Hand (từ ZMR32)
- ✅ **GIT M0-M3**: Goods in Transit (từ GIT_Data)
- ✅ **SLOB Risk**: SOH / AVE_P3M (calculated)
- ✅ **BP Gap %**: (Forecast - Budget) / Budget × 100

**D. Complete Mapping Matrix**
- ✅ Bảng tra cứu: Field → Source → Filter → Example

#### Khi nào đọc:
- 🎯 **QUAN TRỌNG NHẤT**: Khi cần biết 1 field cụ thể lấy từ đâu
- 🎯 **Daily use**: Tra cứu nhanh nguồn dữ liệu
- 🎯 **Debugging**: Tìm hiểu tại sao số liệu không đúng

#### Example Use Cases:
```
Q: "Baseline Qty" trong WF lấy từ đâu?
A: Xem section 1.1 → Historical_SO table, Order_Type='ZOR',
   loại trừ promo periods

Q: "SLOB Risk" được tính như thế nào?
A: Xem section 4.5 → SOH / AVE_P3M,
   HIGH nếu > 3 months coverage
```

---

### 📖 4. DATA_MAPPING_PROCESS.md

**Quy trình mapping dữ liệu qua 5 stages**

#### Nội dung chính:

**Stage 1: Product Hierarchy Mapping**
- ✅ SAP Material → Spectrum → Sub Group
- ✅ BFL mapping
- ✅ Product Type logic

**Stage 2: Channel Mapping**
- ✅ Customer → Channel (ONLINE/OFFLINE)
- ✅ O+O aggregation logic

**Stage 3: Time Series Mapping**
- ✅ Order Type → Time Series
- ✅ Launch detection (3-month rule)
- ✅ Promo period logic

**Stage 4: Period Mapping**
- ✅ Date → Period Name (Y-2, Y-1, Y0, Y+1)
- ✅ Column name generation
- ✅ Rolling period update

**Stage 5: Aggregation & Consolidation**
- ✅ BOM explosion
- ✅ Data aggregation
- ✅ Pivot to WF format

#### Khi nào đọc:
- 🎯 **Deep dive**: Hiểu chi tiết từng bước mapping
- 🎯 **Process improvement**: Tối ưu hóa quy trình
- 🎯 **Audit**: Kiểm tra tính chính xác của mapping

#### Key SQL Queries:
- 50+ SQL examples cho các mapping operations
- Validation queries
- Performance optimization tips

---

### 📖 5. BUSINESS_LOGIC_FLOW.md

**Logic nghiệp vụ và công thức tính toán**

#### Nội dung chính:

**Layer 1: Forecast Calculation**
- ✅ Total Qty = Baseline + Promo + Launch + FOC
- ✅ O+O = ONLINE + OFFLINE
- ✅ BOM Explosion logic

**Layer 2: Stock Projection**
- ✅ Available Stock = SOH - GIT
- ✅ Projected Stock = SOH + SI - SO
- ✅ Stock Coverage (months)

**Layer 3: Risk Assessment**
- ✅ SLOB Detection (>3 months coverage)
- ✅ 3M Risk (Forecast vs Historical)
- ✅ Stock-out Risk

**Layer 4: Budget Analysis**
- ✅ BP Gap % calculation
- ✅ Cumulative YTD gap
- ✅ Trend comparison (T1/T2/T3)

**Layer 5: Performance Metrics**
- ✅ Forecast Accuracy (M-1 vs Actual)
- ✅ MTD Performance
- ✅ YTD Performance

#### Khi nào đọc:
- 🎯 **Business questions**: "Tại sao số này được tính như vậy?"
- 🎯 **Formula verification**: Kiểm tra công thức
- 🎯 **KPI definition**: Hiểu cách tính các metrics

#### Key Formulas:
```
Total Qty = Baseline + Promo + Launch + FOC
BP Gap % = (Forecast - Budget) / Budget × 100
SLOB Risk = HIGH if Stock_Coverage > 3 months
Forecast Accuracy = 100% - |Actual - Forecast| / Actual × 100
```

---

### 📖 6. OUTPUT_SPECIFICATION.md

**Đặc tả chi tiết các outputs của hệ thống**

#### Nội dung chính:

**Output Type 1: Working File (WF)**
- ✅ Excel structure (sheets, columns)
- ✅ Color coding (Blue/Green/Yellow/Orange)
- ✅ View filters (All/Total Only/BP vs FC)
- ✅ Row structure

**Output Type 2: FM Export**
- ✅ SAP upload format
- ✅ Spectrum-level explosion
- ✅ Export process

**Output Type 3: BI Reports**
- ✅ Dashboard components
- ✅ KPIs and charts
- ✅ Data connections

**Output Type 4: Gap Analysis**
- ✅ WinForms application
- ✅ DevExpress grid
- ✅ Variance analysis

**Output Type 5: Database Tables**
- ✅ Permanent tables (FC_FM_*)
- ✅ Archive tables
- ✅ Audit logs

**Output Type 6: Alerts & Notifications**
- ✅ Validation alerts
- ✅ Business logic alerts
- ✅ System alerts

#### Khi nào đọc:
- 🎯 **Report creation**: Tạo reports mới
- 🎯 **Export troubleshooting**: Lỗi khi export
- 🎯 **User training**: Hướng dẫn sử dụng outputs

---

## Hướng Dẫn Đọc Tài Liệu

### 🎯 Theo Vai Trò (Role)

#### 👤 Demand Planner (Người Dự Báo)

**Reading Path:**
```
1. DATA_FLOW_OVERVIEW.md (Sections 1-3)
   → Hiểu tổng quan hệ thống

2. DATA_SOURCE_MAPPING.md (Sections 1-2)
   → Hiểu Time Series và Channel

3. OUTPUT_SPECIFICATION.md (Section 2: Working File)
   → Học cách sử dụng WF

4. BUSINESS_LOGIC_FLOW.md (Sections 1, 4)
   → Hiểu cách tính Total Qty và BP Gap
```

**Focus on:**
- ✅ Time Series definitions (Baseline, Promo, Launch, FOC)
- ✅ Channel logic (ONLINE, OFFLINE, O+O)
- ✅ WF Excel structure và color coding
- ✅ Budget Gap analysis
- ✅ SLOB và Risk alerts

**Time needed:** ~1 hour

---

#### 👤 IT Developer / Database Admin

**Reading Path:**
```
1. DATA_FLOW_OVERVIEW.md (All sections)
   → Architecture overview

2. INPUT_DATA_SPECIFICATION.md (All sections)
   → Input data structures

3. DATA_MAPPING_PROCESS.md (All sections)
   → Detailed mapping logic

4. BUSINESS_LOGIC_FLOW.md (All sections)
   → Business calculations

5. DATA_SOURCE_MAPPING.md (Section 7: Complete Matrix)
   → Field-to-source reference

6. OUTPUT_SPECIFICATION.md (Sections 5: Database)
   → Table structures
```

**Focus on:**
- ✅ Database schema (458+ SQL files)
- ✅ Stored procedures và functions
- ✅ Mapping SQL queries
- ✅ Performance optimization
- ✅ Error handling
- ✅ Audit trails

**Time needed:** ~2.5 hours (full read)

---

#### 👤 Finance Team

**Reading Path:**
```
1. DATA_FLOW_OVERVIEW.md (Sections 1-3)
   → System overview

2. DATA_SOURCE_MAPPING.md (Section 5: Budget Fields)
   → Budget, Pre-Budget, Trends

3. BUSINESS_LOGIC_FLOW.md (Section 4: Budget Analysis)
   → BP Gap calculation

4. OUTPUT_SPECIFICATION.md (Section 4: Gap Analysis)
   → Budget vs Forecast reports
```

**Focus on:**
- ✅ Budget upload process
- ✅ BP Gap % calculation
- ✅ Variance analysis
- ✅ Trend scenarios (T1, T2, T3)
- ✅ Gap Analysis tool usage

**Time needed:** ~45 minutes

---

#### 👤 Supply Chain / Inventory Manager

**Reading Path:**
```
1. DATA_FLOW_OVERVIEW.md (Sections 1-3)
   → System overview

2. DATA_SOURCE_MAPPING.md (Section 4: Calculation Fields)
   → SOH, GIT, SLOB

3. BUSINESS_LOGIC_FLOW.md (Sections 2-3)
   → Stock Projection & Risk Assessment

4. OUTPUT_SPECIFICATION.md (Section 2: FM Export)
   → SAP upload files
```

**Focus on:**
- ✅ Stock on Hand (SOH) data source
- ✅ Goods in Transit (GIT)
- ✅ SLOB detection (slow-moving items)
- ✅ Stock Coverage calculation
- ✅ FM Export to SAP

**Time needed:** ~45 minutes

---

#### 👤 Management / Executive

**Reading Path:**
```
1. DATA_FLOW_OVERVIEW.md (Sections 1-2, 12)
   → High-level overview

2. BUSINESS_LOGIC_FLOW.md (Section 4-5)
   → Budget Analysis & Performance Metrics

3. OUTPUT_SPECIFICATION.md (Section 3: BI Reports)
   → Dashboards and KPIs
```

**Focus on:**
- ✅ System capabilities
- ✅ KPIs and metrics
- ✅ Budget vs Forecast gaps
- ✅ Forecast accuracy
- ✅ BI dashboards

**Time needed:** ~30 minutes

---

### 🎯 Theo Tình Huống (Use Case)

#### 🔍 "Tôi muốn biết field X lấy từ đâu?"

**→ ĐỌC: [DATA_SOURCE_MAPPING.md](./DATA_SOURCE_MAPPING.md)**

**Steps:**
1. Mở file DATA_SOURCE_MAPPING.md
2. Tìm field trong Section 7: Complete Mapping Matrix
3. Xem cột "Primary Source" và "Secondary Source"
4. Đọc section chi tiết tương ứng để hiểu filtering rules

**Example:**
```
Q: "Baseline Qty" lấy từ đâu?
A: Section 1.1 → Historical_SO, Order_Type='ZOR', exclude promo
```

---

#### 🔍 "Tôi muốn hiểu cách tính một công thức?"

**→ ĐỌC: [BUSINESS_LOGIC_FLOW.md](./BUSINESS_LOGIC_FLOW.md)**

**Steps:**
1. Mở file BUSINESS_LOGIC_FLOW.md
2. Tìm formula trong các Layer 1-5
3. Xem Business Rule và SQL Implementation
4. Kiểm tra Example để hiểu rõ hơn

**Example:**
```
Q: "BP Gap %" được tính như thế nào?
A: Section 4.1 → (Forecast - Budget) / Budget × 100
   Xem SQL code và example
```

---

#### 🔍 "Tôi gặp lỗi khi import dữ liệu"

**→ ĐỌC: [INPUT_DATA_SPECIFICATION.md](./INPUT_DATA_SPECIFICATION.md)**

**Steps:**
1. Section 5: Data Validation Rules
2. Section 7: Data Quality Checks
3. Section 8: Sample Data Examples
4. Kiểm tra format và required fields

---

#### 🔍 "Tôi cần export FM file cho SAP"

**→ ĐỌC: [OUTPUT_SPECIFICATION.md](./OUTPUT_SPECIFICATION.md)**

**Steps:**
1. Section 3: Output Type 2 - FM Export
2. Đọc về Export Options và Template Structure
3. Xem Export Process và Example
4. Check file location và naming convention

---

#### 🔍 "Tôi muốn hiểu toàn bộ luồng từ đầu đến cuối"

**→ ĐỌC theo thứ tự:**

```
1. DATA_FLOW_OVERVIEW.md
   ↓
2. INPUT_DATA_SPECIFICATION.md
   ↓
3. DATA_MAPPING_PROCESS.md
   ↓
4. BUSINESS_LOGIC_FLOW.md
   ↓
5. OUTPUT_SPECIFICATION.md
   ↓
6. DATA_SOURCE_MAPPING.md (for reference)
```

**Time needed:** ~2.5 hours

---

## Quick Reference

### 📊 Key Formulas

| Formula | Description | Location |
|---------|-------------|----------|
| `Total Qty = Baseline + Promo + Launch + FOC` | Total forecast quantity | [BUSINESS_LOGIC_FLOW.md](./BUSINESS_LOGIC_FLOW.md#21-total-quantity-calculation) |
| `O+O = ONLINE + OFFLINE` | Channel aggregation | [BUSINESS_LOGIC_FLOW.md](./BUSINESS_LOGIC_FLOW.md#22-channel-aggregation-oo) |
| `BP Gap % = (FC - BDG) / BDG × 100` | Budget gap percentage | [BUSINESS_LOGIC_FLOW.md](./BUSINESS_LOGIC_FLOW.md#51-budget-gap-calculation) |
| `Stock Coverage = SOH / AVE_P3M` | Months of stock coverage | [BUSINESS_LOGIC_FLOW.md](./BUSINESS_LOGIC_FLOW.md#32-projected-stock) |
| `SLOB Risk = HIGH if Coverage > 3M` | Slow-moving detection | [BUSINESS_LOGIC_FLOW.md](./BUSINESS_LOGIC_FLOW.md#41-slob-detection) |
| `Forecast Accuracy = 100% - |Actual-FC|/Actual × 100` | Forecast accuracy % | [BUSINESS_LOGIC_FLOW.md](./BUSINESS_LOGIC_FLOW.md#61-forecast-accuracy) |

### 📁 Important File Paths

| Type | Path | Details |
|------|------|---------|
| **SAP Data** | `\\10.240.65.43\loreal\10_PUBLIC\03_SAPData\SC_IMPORT\Archive\` | [INPUT_DATA_SPECIFICATION.md](./INPUT_DATA_SPECIFICATION.md#21-vị-trí-network-path) |
| **Working File** | `C:\Users\Public\Downloads\Application\FC\Extension\FILES\FC_WORKING_FILE.xlsm` | [OUTPUT_SPECIFICATION.md](./OUTPUT_SPECIFICATION.md#21-file-information) |
| **FM Export** | `\\...\FORECAST\{Division}\FM_Template_Upload\FM_Final\` | [OUTPUT_SPECIFICATION.md](./OUTPUT_SPECIFICATION.md#31-file-information) |
| **Master Data** | `C:\Users\Public\Downloads\Application\FC\Extension\MASTER\` | [INPUT_DATA_SPECIFICATION.md](./INPUT_DATA_SPECIFICATION.md#31-spectrum-master) |

### 🗄️ Key Database Objects

| Object Type | Count | Examples | Details |
|-------------|-------|----------|---------|
| **Functions** | 30+ | `fnc_FC_FM_Original()`, `fnc_SubGroupMaster()` | [DATA_FLOW_OVERVIEW.md](./DATA_FLOW_OVERVIEW.md#42-key-database-objects) |
| **Stored Procedures** | 200+ | `sp_Update_WF_Master`, `sp_Check_GAP_NEW` | [DATA_FLOW_OVERVIEW.md](./DATA_FLOW_OVERVIEW.md#42-key-database-objects) |
| **Views** | 150+ | `V_FC_FM_Original_{Division}` | [DATA_FLOW_OVERVIEW.md](./DATA_FLOW_OVERVIEW.md#42-key-database-objects) |
| **Triggers** | 20+ | `ntr_FC_FM_Original` | [DATA_FLOW_OVERVIEW.md](./DATA_FLOW_OVERVIEW.md#42-key-database-objects) |

### 🔑 Key Concepts

| Concept | Definition | Learn More |
|---------|------------|------------|
| **Sub Group** | Aggregation level for forecasting (e.g., "LOP Revitalift Cream") | [DATA_SOURCE_MAPPING.md](./DATA_SOURCE_MAPPING.md#62-forecasting-line-sub-group) |
| **Time Series** | Forecast components: Baseline, Promo, Launch, FOC, Total | [DATA_SOURCE_MAPPING.md](./DATA_SOURCE_MAPPING.md#1-time-series-mapping) |
| **FM_KEY** | Forecast Month Key (e.g., CPD_2025_01) | [DATA_MAPPING_PROCESS.md](./DATA_MAPPING_PROCESS.md#51-date--period-name) |
| **O+O** | Online + Offline (total across all channels) | [DATA_SOURCE_MAPPING.md](./DATA_SOURCE_MAPPING.md#23-oo-channel-online--offline) |
| **SLOB** | Slow-moving/Obsolete inventory (>3 months coverage) | [BUSINESS_LOGIC_FLOW.md](./BUSINESS_LOGIC_FLOW.md#41-slob-detection) |
| **M-1** | Previous month's final forecast (reference) | [INPUT_DATA_SPECIFICATION.md](./INPUT_DATA_SPECIFICATION.md#35-fc-fm-forecast-month---historical) |
| **BOM** | Bill of Materials (bundle composition) | [DATA_MAPPING_PROCESS.md](./DATA_MAPPING_PROCESS.md#62-bom-explosion) |

---

## Glossary

### A-C

| Term | Full Name | Definition |
|------|-----------|------------|
| **AVE F3M** | Average Forecast 3 Months | Average forecast for next 3 months |
| **AVE P3M** | Average Previous 3 Months | Average actual sales for last 3 months |
| **BFL** | Bill of Formula List | Internal product master list |
| **BOM** | Bill of Materials | Bundle component structure |
| **BP Gap %** | Budget Plan Gap % | Variance between forecast and budget |
| **CPD** | Consumer Products Division | One of L'Oréal divisions |

### D-G

| Term | Full Name | Definition |
|------|-----------|------------|
| **FM** | Forecast Month | Monthly forecast export to SAP |
| **FM_KEY** | Forecast Month Key | Identifier for forecast period (e.g., CPD_2025_01) |
| **FOC** | Free of Charge | Samples, gifts, promotional giveaways |
| **GIT** | Goods In Transit | Stock on the way, not yet in warehouse |
| **GT** | General Trade | Small retailers, traditional trade |

### H-O

| Term | Full Name | Definition |
|------|-----------|------------|
| **LDB** | L'Oréal Dermatological Beauty | One of L'Oréal divisions |
| **LLD** | L'Oréal Luxe Division | One of L'Oréal divisions |
| **M-1** | Minus 1 Month | Previous month's final forecast |
| **MT** | Modern Trade | Supermarkets, hypermarkets |
| **MTD** | Month-to-Date | From start of month to current date |
| **O+O** | Online + Offline | Total across all sales channels |

### P-Z

| Term | Full Name | Definition |
|------|-----------|------------|
| **SAP** | SAP System | Enterprise resource planning system |
| **SI** | Sell-In | Orders from L'Oréal to customers |
| **SIT** | Stock In Transit | Stock after deducting GIT |
| **SLOB** | Slow-moving/Obsolete | Inventory with >3 months coverage |
| **SO** | Sell-Out | Sales from customers to end consumers |
| **SOH** | Stock On Hand | Current stock in warehouse |
| **Spectrum** | Spectrum Code | SAP material code |
| **Sub Group** | Sub Group | Product aggregation level for forecasting |
| **WF** | Working File | Main Excel file for forecasting |
| **YTD** | Year-to-Date | From start of year to current date |
| **ZV14** | SAP ZV14 Report | SAP order status report |
| **ZMR32** | SAP ZMR32 Report | SAP stock report |

---

## FAQs

### ❓ General Questions

**Q1: Tài liệu này dành cho ai?**

**A:** Tài liệu phục vụ nhiều đối tượng:
- Demand Planners (người sử dụng hàng ngày)
- IT Team (developers, DBAs, support)
- Finance Team (budget management)
- Supply Chain Team (inventory planning)
- Management (overview và KPIs)

Mỗi đối tượng có [reading path](#-theo-vai-trò-role) riêng.

---

**Q2: Tôi nên đọc tài liệu nào trước?**

**A:** Tùy mục đích:
- **Hiểu tổng quan**: Đọc [DATA_FLOW_OVERVIEW.md](./DATA_FLOW_OVERVIEW.md) trước
- **Tra cứu field**: Đọc [DATA_SOURCE_MAPPING.md](./DATA_SOURCE_MAPPING.md)
- **Troubleshoot lỗi**: Đọc [INPUT_DATA_SPECIFICATION.md](./INPUT_DATA_SPECIFICATION.md)
- **Hiểu logic tính toán**: Đọc [BUSINESS_LOGIC_FLOW.md](./BUSINESS_LOGIC_FLOW.md)

Xem [Hướng Dẫn Đọc Tài Liệu](#hướng-dẫn-đọc-tài-liệu) cho chi tiết.

---

**Q3: Tài liệu có được update không?**

**A:** Có. Mỗi file có **Document Version** và **Last Updated** ở cuối.
- Version hiện tại: 1.0
- Last Updated: 2025-11-18

Khi có thay đổi hệ thống, tài liệu sẽ được cập nhật.

---

### ❓ Data Source Questions

**Q4: Làm sao biết một field trong WF lấy từ đâu?**

**A:** Sử dụng [DATA_SOURCE_MAPPING.md](./DATA_SOURCE_MAPPING.md):
1. Mở file
2. Tìm field trong **Section 7: Complete Mapping Matrix**
3. Xem cột "Primary Source"
4. Đọc section chi tiết để hiểu filtering rules

**Example:**
```
Field: "Baseline Qty"
→ Section 1.1
→ Source: Historical_SO table
→ Filter: Order_Type='ZOR', exclude promo periods
```

---

**Q5: Promo Qty và Baseline Qty khác nhau như thế nào?**

**A:** Xem [DATA_SOURCE_MAPPING.md Section 1](./DATA_SOURCE_MAPPING.md#1-time-series-mapping):

| Time Series | Source Filter | Example |
|-------------|---------------|---------|
| **Baseline Qty** | `Order_Type='ZOR'` AND not in promo period | Regular sales |
| **Promo Qty** | `Order_Type='ZPROMO'` OR in Promo_Calendar | Promotional sales |

---

**Q6: ONLINE và OFFLINE channel được phân biệt thế nào?**

**A:** Dựa vào Customer_Master table:

```sql
-- ONLINE
WHERE Customer_Master.Channel = 'ONLINE'
Examples: Shopee, Lazada, Tiki

-- OFFLINE
WHERE Customer_Master.Channel IN ('GT', 'MT', 'PHARMA', 'SALON')
Examples: CO.OP Mart, BigC, Guardian
```

Xem [DATA_SOURCE_MAPPING.md Section 2](./DATA_SOURCE_MAPPING.md#2-channel-mapping).

---

### ❓ Calculation Questions

**Q7: Total Qty được tính như thế nào?**

**A:** Formula:
```
Total Qty = Baseline Qty + Promo Qty + Launch Qty + FOC Qty
```

Chi tiết tại [BUSINESS_LOGIC_FLOW.md Section 2.1](./BUSINESS_LOGIC_FLOW.md#21-total-quantity-calculation).

---

**Q8: SLOB Risk là gì và được tính thế nào?**

**A:** SLOB = Slow-moving/Obsolete inventory

**Formula:**
```
Stock Coverage = SOH / AVE_P3M

SLOB Risk:
- HIGH: Coverage > 3 months
- MEDIUM: Coverage 2-3 months
- LOW: Coverage < 2 months
```

Chi tiết tại [BUSINESS_LOGIC_FLOW.md Section 4.1](./BUSINESS_LOGIC_FLOW.md#41-slob-detection).

---

**Q9: BP Gap % là gì?**

**A:** Budget Plan Gap % - Variance giữa Forecast và Budget

**Formula:**
```
BP Gap % = (Forecast - Budget) / Budget × 100

Example:
Budget: 10000
Forecast: 11500
Gap %: (11500 - 10000) / 10000 × 100 = +15%
```

Chi tiết tại [BUSINESS_LOGIC_FLOW.md Section 5.1](./BUSINESS_LOGIC_FLOW.md#51-budget-gap-calculation).

---

### ❓ Technical Questions

**Q10: Database có bao nhiêu objects?**

**A:** Total: **458+ SQL objects**

Breakdown:
- Functions: 30+
- Stored Procedures: 200+
- Views: 150+
- Triggers: 20+

Xem [DATA_FLOW_OVERVIEW.md Section 4](./DATA_FLOW_OVERVIEW.md#41-cấu-trúc-database).

---

**Q11: Làm sao để debug SQL mapping?**

**A:**
1. Đọc [DATA_MAPPING_PROCESS.md](./DATA_MAPPING_PROCESS.md) để hiểu logic
2. Sử dụng validation queries trong **Section 7.1-7.3**
3. Check error log trong `FC_Mapping_Error_Log` table
4. Xem section **9. Error Handling & Logging**

---

**Q12: Performance optimization tips?**

**A:** Xem [DATA_MAPPING_PROCESS.md Section 8](./DATA_MAPPING_PROCESS.md#8-performance-optimization):
- Indexing strategy
- Temporary table usage
- Batch processing (10,000 rows/batch)
- Bulk operations với SqlBulkCopy

---

### ❓ Output Questions

**Q13: Làm sao export FM file cho SAP?**

**A:**
1. Mở Working File
2. Click "Export to FM" in Task Pane
3. Select Time Series và Channel
4. File được tạo tại: `\\...\FM_Template_Upload\FM_Final\`

Chi tiết tại [OUTPUT_SPECIFICATION.md Section 3](./OUTPUT_SPECIFICATION.md#3-output-type-2-fm-export).

---

**Q14: WF Excel có những sheet nào?**

**A:** Main sheets:
- **SysConfig**: System configuration
- **WF**: Main working sheet (forecast input)
- **Bom Header Forecast**: BOM management

Chi tiết tại [OUTPUT_SPECIFICATION.md Section 2.2](./OUTPUT_SPECIFICATION.md#22-sheet-structure).

---

**Q15: Các cột trong WF có màu gì và ý nghĩa?**

**A:** Color coding:
- 🟦 **Blue**: Historical data (read-only)
- 🟩 **Green**: Forecast (editable)
- 🟨 **Yellow**: Budget (read-only)
- 🟧 **Orange**: Calculations (auto)
- ⬜ **White**: Fixed columns (labels)

Xem [OUTPUT_SPECIFICATION.md Section 2.3](./OUTPUT_SPECIFICATION.md#23-column-definitions).

---

## 📞 Support & Feedback

### Need Help?

- 📧 **Technical Support**: IT.Support@loreal.com
- 📧 **Business Questions**: Demand.Planning@loreal.com
- 📧 **Documentation**: [Create an issue](../../issues)

### Found an Error?

Nếu phát hiện lỗi trong tài liệu:
1. [Create a GitHub issue](../../issues/new)
2. Hoặc email: Documentation.Team@loreal.com
3. Ghi rõ: File name, section, error description

### Suggestions?

Góp ý cải thiện tài liệu:
- [Submit a pull request](../../pulls)
- Email suggestions to: Documentation.Team@loreal.com

---

## 📝 Document Maintenance

### Version History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 1.0 | 2025-11-18 | Initial release - All 6 documents | Technical Team |

### Review Schedule

- **Monthly**: Check for accuracy with system updates
- **Quarterly**: Major review and updates
- **Yearly**: Complete documentation overhaul

### Contributors

- Technical Team - L'Oréal Vietnam IT
- Demand Planning Team
- Finance Team
- Documentation maintained by: IT.Documentation@loreal.com

---

## 📚 Additional Resources

### Related Systems

- **SAP Documentation**: [Internal SAP Wiki](http://internal.wiki/sap)
- **Optimus System**: [Optimus User Guide](http://internal.wiki/optimus)
- **BI Tools**: [Power BI Reports](http://internal.wiki/bi)

### Training Materials

- **Demand Planner Training**: [Training Portal](http://training.loreal.com/fc-tool)
- **IT Support Guides**: [Support Wiki](http://support.loreal.com/fc-tool)
- **Video Tutorials**: [YouTube Playlist](http://youtube.com/loreal-fc-tool)

### External References

- **Excel VBA Documentation**: [Microsoft Docs](https://docs.microsoft.com/en-us/office/vba/api/overview/excel)
- **SQL Server Documentation**: [Microsoft Docs](https://docs.microsoft.com/en-us/sql/)
- **DevExpress WinForms**: [DevExpress Docs](https://docs.devexpress.com/WindowsForms/)

---

**Happy Reading! 📖**

*For questions or feedback, please contact the Documentation Team.*

**Last Updated**: 2025-11-18
**Version**: 1.0
**Maintained by**: L'Oréal Vietnam IT Team
