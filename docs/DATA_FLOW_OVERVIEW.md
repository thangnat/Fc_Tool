# Tổng Quan Luồng Dữ Liệu - L'Oréal Forecasting Tool

## 1. Giới Thiệu Hệ Thống

**Hệ thống Forecasting Tool** là công cụ quản lý dự báo bán hàng của L'Oréal Vietnam, được xây dựng dưới dạng Excel Add-in kết hợp với ứng dụng Windows. Hệ thống quản lý dự báo bán hàng cho 3 divisions:
- **CPD** (Consumer Products Division)
- **LDB** (L'Oréal Dermatological Beauty)
- **LLD** (L'Oréal Luxe Division)

## 2. Sơ Đồ Tổng Quan Luồng Dữ Liệu

```
┌─────────────────────────────────────────────────────────────────────┐
│                         INPUT LAYER                                  │
│                         (Tầng Đầu Vào)                              │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌─────────────────┐    ┌──────────────────┐   ┌─────────────────┐│
│  │  SAP Data       │    │  Master Data     │   │  Working File   ││
│  │  (Network)      │    │  (Excel Files)   │   │  (User Input)   ││
│  ├─────────────────┤    ├──────────────────┤   ├─────────────────┤│
│  │ • SO/SI History │    │ • Spectrum Master│   │ • Manual        ││
│  │ • GIT Data      │    │ • BFL Master     │   │   Forecast      ││
│  │ • ZV14 Orders   │    │ • Customer Master│   │ • BOM Config    ││
│  │ • Budget Files  │    │ • FC Budget      │   │ • Adjustments   ││
│  └─────────────────┘    └──────────────────┘   └─────────────────┘│
│                                                                      │
└──────────────────────────────┬───────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    PROCESSING LAYER                                  │
│                  (Tầng Xử Lý Dữ Liệu)                               │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │         STAGE 1: DATA IMPORT & VALIDATION                    │  │
│  ├──────────────────────────────────────────────────────────────┤  │
│  │ • Excel → Access (OleDB Connection)                          │  │
│  │ • Access → SQL Server (SqlBulkCopy)                          │  │
│  │ • Load vào Temporary Tables (*_Tmp)                          │  │
│  │ • Validate format, permissions, duplicates                   │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                               ↓                                      │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │         STAGE 2: DATA TRANSFORMATION                         │  │
│  ├──────────────────────────────────────────────────────────────┤  │
│  │ • Mapping Spectrum codes                                     │  │
│  │ • Aggregate by Product Hierarchy (Sub Group/Brand)          │  │
│  │ • Calculate historical averages (AVE P3M)                    │  │
│  │ • Apply BOM configurations                                   │  │
│  │ • Channel aggregation (ONLINE + OFFLINE = O+O)              │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                               ↓                                      │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │         STAGE 3: BUSINESS LOGIC CALCULATION                  │  │
│  ├──────────────────────────────────────────────────────────────┤  │
│  │ • Total Qty = Baseline + Promo + Launch + FOC                │  │
│  │ • Budget Gap % = (Forecast - Budget) / Budget × 100          │  │
│  │ • Risk Assessment (3-month risk analysis)                    │  │
│  │ • SLOB Calculation (Slow-moving/Obsolete)                    │  │
│  │ • Stock projections (SOH + SI - SO)                          │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                               ↓                                      │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │         STAGE 4: DATA CONSOLIDATION                          │  │
│  ├──────────────────────────────────────────────────────────────┤  │
│  │ • Merge Historical + Forecast + Budget + Trends              │  │
│  │ • Apply filters and view options                             │  │
│  │ • Generate comparison reports (Budget vs Forecast)           │  │
│  │ • Prepare export format for SAP                              │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                      │
└──────────────────────────────┬───────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────────┐
│                        OUTPUT LAYER                                  │
│                       (Tầng Đầu Ra)                                 │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌──────────────────┐  ┌──────────────────┐  ┌─────────────────┐  │
│  │  Working File    │  │  FM Export       │  │  BI Reports     │  │
│  │  (Updated)       │  │  (SAP Upload)    │  │  (Analysis)     │  │
│  ├──────────────────┤  ├──────────────────┤  ├─────────────────┤  │
│  │ • WF Sheet       │  │ • FM Templates   │  │ • Dashboards    │  │
│  │ • BOM Header     │  │ • Time Series    │  │ • Pivot Tables  │  │
│  │ • Calculations   │  │ • Channel Split  │  │ • Gap Analysis  │  │
│  │ • Alerts         │  │ • Spectrum Match │  │ • Variance      │  │
│  └──────────────────┘  └──────────────────┘  └─────────────────┘  │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

## 3. Các Giai Đoạn Xử Lý Chính

### 3.1. Giai Đoạn 1: Import & Validation
**Mục đích:** Đưa dữ liệu từ Excel vào SQL Server

**Các bước thực hiện:**
1. Người dùng mở Working File (FC_WORKING_FILE.xlsm)
2. Excel Add-in đọc cấu hình từ sheet `SysConfig`
3. Import dữ liệu từ các sheet vào Access database (trung gian)
4. Bulk copy từ Access vào SQL Server (SC2 database)
5. Validate:
   - Kiểm tra quyền người dùng
   - Kiểm tra format dữ liệu
   - Kiểm tra duplicate records
   - So sánh số lượng rows (Excel vs SQL)

**Output:** Dữ liệu trong các bảng tạm (*_Tmp)

### 3.2. Giai Đoạn 2: Data Transformation
**Mục đích:** Chuẩn hóa và mapping dữ liệu

**Các bước thực hiện:**
1. **Spectrum Mapping:**
   - Map mã sản phẩm từ BFL Master sang Spectrum Master
   - Xác định Product Type, Sub Group, Brand

2. **Aggregation:**
   - Tổng hợp dữ liệu theo Product Hierarchy
   - Nhóm theo Channel (ONLINE, OFFLINE, O+O)
   - Tính toán theo Time Series (Baseline, Promo, Launch, FOC)

3. **Historical Processing:**
   - Xử lý dữ liệu Sell-In/Sell-Out lịch sử
   - Tính trung bình 3 tháng trước (AVE P3M)
   - Load dữ liệu M-1 (forecast tháng trước)

4. **BOM Application:**
   - Áp dụng Bill of Materials cho các bundle products
   - Tính toán component quantities
   - Update BOM Header Forecast

**Output:** Dữ liệu đã được chuẩn hóa trong các Function và View

### 3.3. Giai Đoạn 3: Business Logic Calculation
**Mục đích:** Tính toán các metrics nghiệp vụ

**Các công thức chính:**

```
Total Qty = Baseline Qty + Promo Qty + Launch Qty + FOC Qty

O+O Channel = ONLINE + OFFLINE

Budget Gap % = (Forecast - Budget) / Budget × 100

Unit with FC = Unit × (1 + Adjustment %)

Stock Projection = SOH + GIT + Planned SI - Planned SO

SLOB Risk = If (Stock > 3 months demand, HIGH, NORMAL)

3M Risk = If (AVE F3M < AVE P3M × Threshold, AT_RISK, OK)
```

**Stored Procedures sử dụng:**
- `sp_tag_update_wf_calculation_fc_unit_Refresh_All` - Tính toán tổng hợp
- `sp_Check_GAP_NEW` - Phân tích Budget Gap
- `sp_fc_fm_risk_3M` - Đánh giá risk 3 tháng
- `sp_tag_update_slob_wf` - Tính SLOB

**Output:** Dữ liệu đã có đầy đủ calculations

### 3.4. Giai Đoạn 4: Data Consolidation
**Mục đích:** Hợp nhất và chuẩn bị output

**Các bước thực hiện:**
1. **Merge Data Sources:**
   - Historical Data (Y-2, Y-1, Y0)
   - Current Forecast (Y0, Y+1)
   - Budget Data (B_Y0, B_Y+1)
   - Pre-Budget (PB_Y+1)
   - Trends (T1, T2, T3)

2. **Apply View Filters:**
   - All: Hiển thị tất cả dữ liệu
   - Total Only: Chỉ hiển thị Total Qty (ẩn các time series component)
   - BP vs FC: So sánh Budget Plan với Forecast

3. **Generate Outputs:**
   - Update WF sheet trong Working File
   - Tạo FM Export templates
   - Tạo BI Reports
   - Tạo Gap Analysis Reports

**Output:** Các file Excel và reports cuối cùng

## 4. Database Architecture

### 4.1. Cấu Trúc Database

**Server:** 10.240.65.33
**Database:** SC2
**Total Objects:** 458+ SQL scripts

**Các loại objects:**
- **Functions (fnc_\*):** 30+ functions để xử lý logic
- **Stored Procedures (sp_\*):** 200+ procedures cho các operations
- **Views (V_\*):** 150+ views để hiển thị dữ liệu
- **Triggers (ntr_\*):** 20+ triggers để audit và validate

### 4.2. Key Database Objects

**Core Functions:**
```sql
fnc_FC_FM_Original()          -- Main forecast data aggregation
fnc_SubGroupMaster()           -- Product hierarchy mapping
fnc_FC_SO_HIS_FINAL()          -- Historical sell-out processing
fnc_Get_FMKEY()                -- Generate Forecast Month Key
```

**Core Stored Procedures:**
```sql
sp_add_FC_FM_Tmp               -- Import forecast data
sp_Update_WF_Master            -- Update WF column structure
sp_FC_EXPORT_TO_FM_VIEW        -- Generate FM export
sp_Check_GAP_NEW               -- Budget gap analysis
```

**Core Views:**
```sql
V_FC_FM_Original_{Division}    -- Main forecast view per division
V_LLD_His_SI_*                 -- Historical sell-in views
V_FC_CONFIG_USER_ALLOW         -- User permission view
```

## 5. File Path Structure

### 5.1. Network Paths

**SAP Data Import Location:**
```
\\10.240.65.43\loreal\10_PUBLIC\03_SAPData\SC_IMPORT\Archive\
├── FORECAST/
│   ├── CPD/
│   ├── LDB/
│   └── LLD/
├── MASTER/
├── OPTIMUS/
└── ZV14/
```

**Working File Location:**
```
C:\Users\Public\Downloads\Application\FC\Extension\FILES\
└── FC_WORKING_FILE.xlsm
```

**FM Export Location:**
```
\\10.240.65.43\loreal\10_PUBLIC\03_SAPData\SC_IMPORT\Archive\
└── FORECAST\{Division}\FM_Template_Upload\FM_Final\
    └── {Division}_FM_{FMKEY}.xlsx
```

### 5.2. Excel Sheet Structure

**FC_WORKING_FILE.xlsm:**
- `SysConfig` - System configuration
- `WF` - Main working sheet
- `Bom Header Forecast` - BOM management
- Various calculation and reference sheets

## 6. Data Update Frequency

| Data Type | Update Frequency | Source |
|-----------|-----------------|--------|
| Sell-Out (SO) | Daily | Optimus system via SAP |
| Sell-In (SI) | Daily | SAP ZV14 reports |
| GIT (Goods in Transit) | Daily | SAP |
| Stock (SOH) | Daily | SAP ZMR32 |
| Budget | Yearly | Finance team (Excel upload) |
| Pre-Budget | Yearly | Finance team |
| Trends | Monthly | SAP/Analysis |
| Forecast | Monthly | Demand Planning team (WF) |
| BOM Configuration | As needed | Product team |

## 7. User Roles & Permissions

**Roles:**
1. **Admin** - Full access to all functions
2. **Demand Planner** - Create and update forecasts
3. **Viewer** - Read-only access
4. **Finance** - Budget management
5. **Product Manager** - BOM management

**Permission Table:** `V_FC_CONFIG_USER_ALLOW`

## 8. Version Control

**Version Check:**
- Stored in `V_FC_VERSION_EXE`
- Auto-update mechanism in Excel Add-in
- Notifies users of new versions
- Download link: Network share location

**Current Application Components:**
- **EXCEL_ADDINS.dll** - Main Excel Add-in
- **WinFormsApp2.exe** - Gap Analysis tool
- SQL Scripts - Database objects

## 9. Error Handling & Alerts

**Validation Alerts:**
- Row count mismatch (Excel vs SQL)
- Permission denied
- Duplicate data detection
- Risk warnings (SLOB, 3M Risk)
- Gap threshold exceeded

**Alert Display:**
- `FrmAlert` form in Excel Add-in
- Email notifications (if configured)
- Log files for audit

## 10. Performance Considerations

**Optimization Techniques:**
1. **Bulk Operations:**
   - SqlBulkCopy for large imports
   - Batch processing for calculations

2. **Temporary Tables:**
   - Use *_Tmp tables for staging
   - Truncate before reload

3. **Indexed Views:**
   - Pre-aggregated views for faster access
   - Indexed on key columns (Division, FMKEY, SubGroup)

4. **Transaction Management:**
   - Row-level locking mechanism
   - Prevent concurrent edits

**Typical Processing Times:**
- WF Generation (first time): 5-10 minutes
- WF Refresh (partial): 2-3 minutes
- FM Export: 1-2 minutes per time series
- Gap Analysis: < 1 minute

## 11. Integration Points

### 11.1. SAP Integration
**Import from SAP:**
- SO/SI historical data
- Order status (ZV14)
- Stock levels (ZMR32)
- GIT data

**Export to SAP:**
- FM (Forecast Month) uploads
- Format: Excel templates
- Upload schedule: Monthly

### 11.2. Optimus Integration
**Data received:**
- Sell-Out by customer
- Sell-Out by product
- Channel breakdown

### 11.3. Manual Integration
**Excel file uploads:**
- Master data files
- Budget files
- Ad-hoc adjustments

## 12. Disaster Recovery

**Backup Strategy:**
- SQL Server database backups (daily)
- Network share snapshots
- Version history in database
- Archive folders for FM exports

**Recovery Procedures:**
- Restore from *_Tmp tables
- Re-import from Excel archives
- Version rollback capability

---

**Document Version:** 1.0
**Last Updated:** 2025-11-18
**Maintained by:** Technical Team
