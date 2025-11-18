# Đặc Tả Dữ Liệu Đầu Vào - Input Data Specification

## 1. Tổng Quan

Hệ thống Forecasting Tool nhận dữ liệu từ 3 nguồn chính:
1. **SAP Data** - Dữ liệu từ hệ thống SAP qua network share
2. **Master Data Files** - Các file Excel master data
3. **Working File** - File làm việc của người dùng

---

## 2. SAP Data (Network Share)

### 2.1. Vị Trí Network Path

**Base Path:**
```
\\10.240.65.43\loreal\10_PUBLIC\03_SAPData\SC_IMPORT\Archive\
```

### 2.2. Sell-Out Data (SO) - Từ Optimus

**Path:**
```
Archive\OPTIMUS\SELL OUT NORMAL\{Division}\
```

**File naming convention:**
```
SELLOUT_{Division}_{YYYYMMDD}.xlsx
```

**Example:**
```
SELLOUT_CPD_20250115.xlsx
SELLOUT_LDB_20250115.xlsx
SELLOUT_LLD_20250115.xlsx
```

**Sheet structure:**
```
Sheet: "Data"
```

**Columns:**
| Column Name | Data Type | Description | Example |
|-------------|-----------|-------------|---------|
| Material | VARCHAR(18) | Mã sản phẩm SAP | 3600542410311 |
| Material Description | VARCHAR(100) | Tên sản phẩm | L'Oreal Paris Revitalift... |
| Customer Code | VARCHAR(10) | Mã khách hàng | 1000123 |
| Customer Name | VARCHAR(100) | Tên khách hàng | CO.OP MART |
| Channel | VARCHAR(20) | Kênh bán hàng | OFFLINE / ONLINE |
| Month | DATE | Tháng dữ liệu | 2025-01-01 |
| Quantity | INT | Số lượng bán ra | 1500 |
| Value | DECIMAL(18,2) | Giá trị bán | 45000000.00 |
| Division | VARCHAR(3) | Division | CPD |

**Business Rules:**
- Dữ liệu được cập nhật hàng ngày
- Chỉ lấy dữ liệu từ 24 tháng trở lại đây
- Aggregate theo Material + Month
- Filter theo Division

**SQL Import Procedure:**
```sql
EXEC sp_add_FC_SO_OPTIMUS_NORMAL_Tmp
    @Division = 'CPD',
    @FilePath = '\\10.240.65.43\loreal\...\SELLOUT_CPD_20250115.xlsx'
```

### 2.3. Sell-In Data (SI) - Từ SAP ZV14

**Path:**
```
Archive\ZV14\{Division}\
```

**File naming convention:**
```
ZV14_{Division}_{YYYYMMDD}.xlsx
```

**Sheet structure:**
```
Sheet: "ZV14"
```

**Columns:**
| Column Name | Data Type | Description | Example |
|-------------|-----------|-------------|---------|
| Material | VARCHAR(18) | Mã sản phẩm | 3600542410311 |
| Customer | VARCHAR(10) | Mã khách hàng | 1000123 |
| Sales Order | VARCHAR(10) | Số đơn hàng | 4500012345 |
| Order Type | VARCHAR(4) | Loại đơn | ZOR |
| Order Date | DATE | Ngày đặt hàng | 2025-01-15 |
| Delivery Date | DATE | Ngày giao hàng | 2025-01-20 |
| Order Quantity | INT | Số lượng đặt | 2000 |
| Delivery Quantity | INT | Số lượng giao | 1800 |
| Backorder Quantity | INT | Số lượng backorder | 200 |
| Status | VARCHAR(1) | Trạng thái | C (Completed) |

**Order Types:**
- **ZOR** - Normal Order
- **ZFOC** - Free of Charge (FOC)
- **ZSP** - Special Order
- **ZRT** - Return

**Business Rules:**
- Chỉ tính order có Status = 'C' (Completed) cho historical
- Tính Delivery Quantity (không phải Order Quantity)
- Aggregate theo Material + Delivery Date month
- Filter backorder riêng để theo dõi

### 2.4. GIT (Goods In Transit)

**Path:**
```
Archive\GIT\
```

**File naming convention:**
```
GIT_{YYYYMMDD}.xlsx
```

**Sheet structure:**
```
Sheet: "GIT_Data"
```

**Columns:**
| Column Name | Data Type | Description | Example |
|-------------|-----------|-------------|---------|
| Material | VARCHAR(18) | Mã sản phẩm | 3600542410311 |
| Division | VARCHAR(3) | Division | CPD |
| Quantity_M0 | INT | GIT tháng hiện tại | 500 |
| Quantity_M1 | INT | GIT tháng sau | 300 |
| Quantity_M2 | INT | GIT tháng +2 | 100 |
| Quantity_M3 | INT | GIT tháng +3 | 0 |
| Update_Date | DATETIME | Ngày cập nhật | 2025-01-15 10:30:00 |

**Business Rules:**
- M0 = Tháng hiện tại (hàng đang trên đường)
- M1 = Tháng sau
- M2, M3 = Các tháng tiếp theo
- GIT được trừ vào Stock On Hand để tính Available Stock

### 2.5. Stock On Hand (SOH) - ZMR32

**Path:**
```
Archive\ZMR32\
```

**File naming convention:**
```
ZMR32_{YYYYMMDD}.xlsx
```

**Sheet structure:**
```
Sheet: "Stock"
```

**Columns:**
| Column Name | Data Type | Description | Example |
|-------------|-----------|-------------|---------|
| Material | VARCHAR(18) | Mã sản phẩm | 3600542410311 |
| Plant | VARCHAR(4) | Nhà máy/Kho | 1000 |
| Storage_Location | VARCHAR(4) | Vị trí kho | 0001 |
| Batch | VARCHAR(10) | Số lô | LOT123 |
| Quantity | INT | Số lượng tồn | 5000 |
| Unit | VARCHAR(3) | Đơn vị | EA |
| Value | DECIMAL(18,2) | Giá trị tồn kho | 150000000.00 |
| Aging_Days | INT | Số ngày tồn | 45 |
| Expiry_Date | DATE | Ngày hết hạn | 2026-12-31 |

**Business Rules:**
- Aggregate theo Material (tổng tất cả Plant + Storage Location)
- Kiểm tra Aging_Days > 90 → Cảnh báo SLOB
- Trừ GIT để có Available Stock
- Formula: `Available_Stock = SOH - GIT_M0`

---

## 3. Master Data Files

### 3.1. Spectrum Master

**Path:**
```
C:\Users\Public\Downloads\Application\FC\Extension\MASTER\
```

**File name:**
```
Spectrum_Master_{Division}.xlsx
```

**Sheet structure:**
```
Sheet: "Spectrum"
```

**Columns:**
| Column Name | Data Type | Description | Example |
|-------------|-----------|-------------|---------|
| Spectrum | VARCHAR(18) | Mã Spectrum (SAP code) | 3600542410311 |
| Product_Type | VARCHAR(50) | Loại sản phẩm | Finished Good |
| Category | VARCHAR(50) | Danh mục | Skin Care |
| Sub_Category | VARCHAR(50) | Danh mục con | Anti-Aging |
| Brand | VARCHAR(50) | Thương hiệu | L'Oreal Paris |
| Sub_Brand | VARCHAR(50) | Sub Brand | Revitalift |
| Sub_Group | VARCHAR(100) | Nhóm forecast | LOP Revitalift Cream |
| Size | VARCHAR(20) | Kích thước | 50ml |
| Pack_Type | VARCHAR(20) | Loại đóng gói | Jar |
| Launch_Date | DATE | Ngày ra mắt | 2023-06-01 |
| Status | VARCHAR(10) | Trạng thái | ACTIVE |
| Channel | VARCHAR(20) | Kênh phân phối | ALL / ONLINE / OFFLINE |

**Product Types:**
- **Finished Good (FG)** - Sản phẩm thành phẩm bán lẻ
- **Bundle** - Combo/set sản phẩm (có BOM)
- **Promo Pack** - Gói khuyến mãi
- **Sample** - Sản phẩm mẫu (FOC)

**Business Rules:**
- Spectrum là unique key
- Status = 'ACTIVE' mới được forecast
- Sub_Group là level để forecast (aggregation level)
- Launch_Date dùng để xác định Launch Quantity period

**Mapping Logic:**
```
SAP Material Code → Spectrum Master → Sub_Group
→ Aggregate forecast by Sub_Group
```

### 3.2. BFL Master (Bill of Formula List)

**File name:**
```
BFL_Master_{Division}.xlsx
```

**Sheet structure:**
```
Sheet: "BFL"
```

**Columns:**
| Column Name | Data Type | Description | Example |
|-------------|-----------|-------------|---------|
| BFL_Code | VARCHAR(18) | Mã BFL | BFL_CPD_001 |
| Spectrum | VARCHAR(18) | Mã Spectrum | 3600542410311 |
| Product_Name | VARCHAR(200) | Tên sản phẩm | L'Oreal Paris Revitalift... |
| EAN_Code | VARCHAR(13) | Mã vạch | 3600542410311 |
| Is_Bundle | BIT | Có phải bundle không | 0/1 |
| Unit_Per_Case | INT | Số unit/thùng | 24 |
| Case_Per_Pallet | INT | Số thùng/pallet | 48 |
| Weight_Kg | DECIMAL(10,2) | Trọng lượng (kg) | 0.15 |
| Volume_L | DECIMAL(10,2) | Thể tích (L) | 0.05 |

**Business Rules:**
- Link giữa internal BFL code và SAP Spectrum
- Unit_Per_Case dùng để convert forecast (unit → case)
- Is_Bundle = 1 → Phải có BOM configuration

### 3.3. Customer Master

**File name:**
```
Customer_Master.xlsx
```

**Sheet structure:**
```
Sheet: "Customer"
```

**Columns:**
| Column Name | Data Type | Description | Example |
|-------------|-----------|-------------|---------|
| Customer_Code | VARCHAR(10) | Mã khách hàng | 1000123 |
| Customer_Name | VARCHAR(100) | Tên khách hàng | CO.OP MART |
| Channel | VARCHAR(20) | Kênh | GT / MT / ONLINE |
| Region | VARCHAR(50) | Vùng miền | South |
| City | VARCHAR(50) | Thành phố | Ho Chi Minh |
| Customer_Type | VARCHAR(20) | Loại KH | Retailer / Distributor |
| Credit_Limit | DECIMAL(18,2) | Hạn mức công nợ | 500000000.00 |
| Payment_Term | VARCHAR(20) | Điều kiện thanh toán | Net 30 |
| Active | BIT | Hoạt động | 1/0 |

**Channel Types:**
- **GT** (General Trade) - Bán lẻ truyền thống
- **MT** (Modern Trade) - Siêu thị hiện đại (CO.OP, BigC, Lotte...)
- **ONLINE** - Thương mại điện tử (Shopee, Lazada, Tiki...)
- **PHARMA** - Nhà thuốc
- **SALON** - Salon chuyên nghiệp

**Business Rules:**
- Aggregate SO theo Channel
- Filter Active = 1 customers
- Payment_Term ảnh hưởng đến GIT calculation

### 3.4. FC Budget

**Path:**
```
Archive\FORECAST\{Division}\BUDGET\
```

**File name:**
```
FC_Budget_{Division}_{Year}.xlsx
```

**Sheet structure:**
```
Sheet: "Budget"
```

**Columns:**
| Column Name | Data Type | Description | Example |
|-------------|-----------|-------------|---------|
| Division | VARCHAR(3) | Division | CPD |
| Sub_Group | VARCHAR(100) | Nhóm forecast | LOP Revitalift Cream |
| Channel | VARCHAR(20) | Kênh | ONLINE / OFFLINE |
| B_Y0_M1 | INT | Budget Y0 tháng 1 | 10000 |
| B_Y0_M2 | INT | Budget Y0 tháng 2 | 12000 |
| ... | ... | ... | ... |
| B_Y0_M12 | INT | Budget Y0 tháng 12 | 15000 |
| B_Y1_M1 | INT | Budget Y+1 tháng 1 | 11000 |
| ... | ... | ... | ... |
| B_Y1_M12 | INT | Budget Y+1 tháng 12 | 16000 |
| Update_By | VARCHAR(50) | Người cập nhật | finance.user |
| Update_Date | DATETIME | Ngày cập nhật | 2025-01-10 |

**Business Rules:**
- Budget được upload 1 lần/năm bởi Finance team
- Y0 = Năm hiện tại, Y1 = Năm sau
- Phải match với Sub_Group trong Spectrum Master
- Budget dùng để so sánh với Forecast (Gap Analysis)

**Budget Types:**
- **Budget (B)** - Budget chính thức
- **Pre-Budget (PB)** - Budget dự kiến (draft)
- **Trend (T1, T2, T3)** - Các scenarios khác nhau

### 3.5. FC FM (Forecast Month) - Historical

**Path:**
```
Archive\FORECAST\{Division}\FM_HISTORY\
```

**File name:**
```
{Division}_FM_{FMKEY}.xlsx
```

**FMKEY Format:**
```
CPD_2024_12  (Division_Year_Month)
```

**Sheet structure:**
```
Sheet: "FM_Data"
```

**Columns:**
| Column Name | Data Type | Description | Example |
|-------------|-----------|-------------|---------|
| Spectrum | VARCHAR(18) | Mã Spectrum | 3600542410311 |
| Sub_Group | VARCHAR(100) | Nhóm forecast | LOP Revitalift Cream |
| Channel | VARCHAR(20) | Kênh | ONLINE |
| Time_Series | VARCHAR(20) | Loại time series | 1. Baseline Qty |
| Y0_M1 | INT | Forecast tháng 1 | 5000 |
| Y0_M2 | INT | Forecast tháng 2 | 5500 |
| ... | ... | ... | ... |
| Y0_M12 | INT | Forecast tháng 12 | 8000 |
| Y1_M1 | INT | Forecast Y+1 M1 | 6000 |
| ... | ... | ... | ... |
| Y1_M12 | INT | Forecast Y+1 M12 | 9000 |

**Time Series Types:**
- **1. Baseline Qty** - Doanh số cơ bản
- **2. Promo Qty** - Doanh số từ khuyến mãi
- **4. Launch Qty** - Doanh số từ sản phẩm mới
- **5. FOC Qty** - Free of Charge (tặng kèm)
- **6. Total Qty** - Tổng (1+2+4+5)

**Business Rules:**
- M-1 FM = FM của tháng trước (dùng làm reference)
- Load vào WF để so sánh với forecast mới
- Historical FM được archive và không thay đổi

---

## 4. Working File (User Input)

### 4.1. File Location

**Path:**
```
C:\Users\Public\Downloads\Application\FC\Extension\FILES\FC_WORKING_FILE.xlsm
```

### 4.2. Sheet: SysConfig

**Mục đích:** Lưu cấu hình hệ thống

**Columns:**
| Setting Name | Value | Description |
|--------------|-------|-------------|
| Division | CPD | Division đang làm việc |
| FM_KEY | CPD_2025_01 | Forecast Month Key |
| UserID | demand.planner1 | User đăng nhập |
| Server | 10.240.65.33 | SQL Server address |
| Database | SC2 | Database name |
| Version | 2.5.3 | Phiên bản add-in |
| Last_Update | 2025-01-15 | Lần cập nhật cuối |

**Business Rules:**
- SysConfig được đọc khi mở file
- FM_KEY auto-generate theo format: {Division}_{YYYY}_{MM}
- UserID dùng để check permissions

### 4.3. Sheet: WF (Working File)

**Mục đích:** Sheet chính để forecast

**Column Structure:**
```
Fixed Columns:
- Product type
- Forecasting Line (SUB GROUP/Brand)
- Channel (ONLINE, OFFLINE, O+O)
- Time series (1. Baseline Qty, 2. Promo Qty, 4. Launch Qty, 5. FOC Qty, 6. Total Qty)

Dynamic Columns (tùy theo FM_KEY):
Historical Y-2:
- [Y-2 (u) M1], [Y-2 (u) M2], ..., [Y-2 (u) M12]

Historical Y-1:
- [Y-1 (u) M1], [Y-1 (u) M2], ..., [Y-1 (u) M12]

Historical Y0:
- [Y0 (u) M1], [Y0 (u) M2], ..., [Y0 (u) M12]

Forecast Y0:
- [Y0 (u) M1], [Y0 (u) M2], ..., [Y0 (u) M12]

Forecast Y+1:
- [Y+1 (u) M1], [Y+1 (u) M2], ..., [Y+1 (u) M12]

Budget:
- [B_Y0_M1], [B_Y0_M2], ..., [B_Y0_M12]
- [B_Y+1_M1], [B_Y+1_M2], ..., [B_Y+1_M12]

Pre-Budget:
- [PB_Y+1_M1], [PB_Y+1_M2], ..., [PB_Y+1_M12]

Trends:
- [T1_Y0_M1], [T2_Y0_M1], [T3_Y0_M1], ... (cho mỗi tháng)

M-1 (Previous Month Forecast):
- [M-1_Y0_M1], [M-1_Y0_M2], ..., [M-1_Y0_M12]

Calculation Columns:
- AVE P3M (Average Previous 3 Months)
- AVE F3M (Average Forecast 3 Months)
- MTD SI (Month-to-Date Sell-In)
- SOH (Stock on Hand)
- SIT (Stock in Transit)
- GIT M0, M1, M2, M3
- SLOB Risk
- BP Gap %
```

**Data Types:**
- Product type: VARCHAR
- Forecasting Line: VARCHAR (Sub_Group from Spectrum)
- Channel: VARCHAR (ONLINE, OFFLINE, O+O)
- Time series: VARCHAR
- Numeric columns: INTEGER (quantities in units)

**Sample Row:**
```
Product type: Finished Good
Forecasting Line: LOP Revitalift Cream
Channel: ONLINE
Time series: 1. Baseline Qty
[Y0 (u) M1]: 5000
[Y0 (u) M2]: 5500
...
```

**Business Rules:**
- Mỗi row là 1 combination: Sub_Group + Channel + Time_Series
- User chỉ edit các cột Forecast (Y0, Y+1)
- Historical columns là read-only (auto-filled from SQL)
- Budget columns là read-only (from Finance)
- Calculation columns auto-update

**Color Coding:**
- 🟦 Blue header: Historical data (read-only)
- 🟩 Green header: Forecast (editable)
- 🟨 Yellow header: Budget (read-only)
- 🟧 Orange header: Calculations (auto)

### 4.4. Sheet: Bom Header Forecast

**Mục đích:** Quản lý BOM cho bundle products

**Columns:**
| Column Name | Data Type | Description | Example |
|-------------|-----------|-------------|---------|
| Bundle_Spectrum | VARCHAR(18) | Mã bundle | 3600542410399 |
| Bundle_Name | VARCHAR(200) | Tên bundle | LOP Gift Set 2025 |
| Component_Spectrum | VARCHAR(18) | Mã thành phần | 3600542410311 |
| Component_Name | VARCHAR(200) | Tên thành phần | LOP Revitalift Cream 50ml |
| Quantity_Per_Bundle | DECIMAL(10,2) | Số lượng/bundle | 2.00 |
| Valid_From | DATE | Hiệu lực từ | 2025-01-01 |
| Valid_To | DATE | Hiệu lực đến | 2025-12-31 |
| Status | VARCHAR(10) | Trạng thái | ACTIVE |

**Business Rules:**
- 1 Bundle có nhiều Components
- Quantity_Per_Bundle dùng để explode forecast
- Formula: `Component_Forecast = Bundle_Forecast × Quantity_Per_Bundle`
- Valid_From/To để quản lý BOM theo thời gian (seasonal bundles)

**Example BOM:**
```
Bundle: "LOP Gift Set 2025" (1 bundle)
├─ LOP Revitalift Cream 50ml × 1
├─ LOP Revitalift Serum 30ml × 1
└─ LOP Tote Bag × 1

If forecast Bundle = 1000 units
→ Revitalift Cream forecast += 1000
→ Revitalift Serum forecast += 1000
→ Tote Bag forecast += 1000
```

---

## 5. Data Validation Rules

### 5.1. General Validation

**All Input Files:**
- ✅ File phải tồn tại và accessible
- ✅ Format phải đúng (xlsx, xlsm)
- ✅ Sheet name phải đúng
- ✅ Required columns phải có đầy đủ
- ✅ Data types phải match specification

**Excel Import Validation:**
```csharp
// From cls_function.cs
if (dt_xlsm.Rows.Count == 0)
{
    throw new Exception("No data found in Excel file");
}

if (rowsImported != expectedRows)
{
    MessageBox.Show($"Row count mismatch: Excel={expectedRows}, SQL={rowsImported}");
}
```

### 5.2. Business Validation

**Spectrum Validation:**
- Spectrum phải tồn tại trong Spectrum_Master
- Status = 'ACTIVE'
- Division phải match

**Customer Validation:**
- Customer_Code phải tồn tại trong Customer_Master
- Active = 1

**Date Validation:**
- Dates phải trong range 24 months
- Forecast dates phải >= current month
- Historical dates phải < current month

**Quantity Validation:**
- Quantities >= 0
- Total Qty = Baseline + Promo + Launch + FOC
- Budget Gap % threshold: ±20% warning

### 5.3. Permission Validation

**User Permissions:**
```sql
SELECT * FROM V_FC_CONFIG_USER_ALLOW
WHERE UserID = @UserID
  AND Division = @Division
  AND Module = @Module
  AND Allow = 1
```

**Module Permissions:**
- **WF_EDIT** - Edit forecast trong WF
- **WF_GENERATE** - Generate WF mới
- **BOM_EDIT** - Sửa BOM
- **FM_EXPORT** - Export FM
- **BUDGET_UPLOAD** - Upload budget

---

## 6. Data Import Frequency & Schedule

### 6.1. Daily Imports

**Time:** 06:00 AM (Vietnam Time)

**Data:**
- Sell-Out (Optimus) - Latest day
- Sell-In (ZV14) - Latest day
- Stock (ZMR32) - Current stock
- GIT - Current GIT

**Process:**
- Auto-import via scheduled task
- Validation & load to SQL
- Update WF historical columns
- Send notification if errors

### 6.2. Monthly Imports

**Time:** 1st day of month

**Data:**
- Budget (if new year/budget revision)
- Spectrum Master (new products)
- BFL Master (new SKUs)

**Process:**
- Manual upload by Admin/Finance
- Full validation
- Backup old data
- Load new data
- Notify users

### 6.3. Ad-hoc Imports

**Trigger:** User request

**Data:**
- BOM updates
- Customer Master updates
- Forecast adjustments

**Process:**
- User uploads via Excel Add-in
- Validation
- Temp table staging
- Review & approve
- Permanent table update

---

## 7. Data Quality Checks

### 7.1. Automated Checks

**Daily Checks:**
- [ ] File existence check
- [ ] Row count validation (Excel vs SQL)
- [ ] Null value check in required fields
- [ ] Data type validation
- [ ] Duplicate detection
- [ ] Referential integrity (Foreign Keys)

**Weekly Checks:**
- [ ] Historical data completeness (last 24 months)
- [ ] Spectrum master sync with SAP
- [ ] Customer master active status
- [ ] BOM configuration validity

### 7.2. Manual Reviews

**Monthly Reviews:**
- [ ] Budget vs Forecast variance (>20% gap)
- [ ] SLOB items review
- [ ] 3-month risk items review
- [ ] Inactive products with forecast
- [ ] Missing historical data

### 7.3. Error Handling

**Import Errors:**
```
Error Code | Description | Action
-----------|-------------|--------
ERR_001    | File not found | Check network path
ERR_002    | Invalid format | Check Excel structure
ERR_003    | Row count mismatch | Re-import
ERR_004    | Permission denied | Check user access
ERR_005    | Duplicate key | Check data for duplicates
ERR_006    | Foreign key violation | Check master data
```

---

## 8. Sample Data Examples

### 8.1. Sell-Out Sample

```
Material          | Customer  | Channel | Month      | Quantity
------------------|-----------|---------|------------|----------
3600542410311    | 1000123   | OFFLINE | 2025-01-01 | 1500
3600542410311    | 1000456   | ONLINE  | 2025-01-01 | 800
3600542410328    | 1000123   | OFFLINE | 2025-01-01 | 2000
```

### 8.2. WF Sample

```
Forecasting Line       | Channel | Time series      | Y0_M1 | Y0_M2 | Y0_M3
-----------------------|---------|------------------|-------|-------|-------
LOP Revitalift Cream   | ONLINE  | 1. Baseline Qty  | 5000  | 5500  | 6000
LOP Revitalift Cream   | ONLINE  | 2. Promo Qty     | 1000  | 0     | 2000
LOP Revitalift Cream   | ONLINE  | 6. Total Qty     | 6000  | 5500  | 8000
LOP Revitalift Cream   | OFFLINE | 1. Baseline Qty  | 8000  | 8500  | 9000
```

### 8.3. BOM Sample

```
Bundle              | Component            | Qty/Bundle
--------------------|----------------------|-----------
LOP Gift Set 2025   | LOP Revitalift Cream | 1
LOP Gift Set 2025   | LOP Revitalift Serum | 1
LOP Gift Set 2025   | LOP Tote Bag         | 1
```

---

**Document Version:** 1.0
**Last Updated:** 2025-11-18
**Maintained by:** Technical Team
