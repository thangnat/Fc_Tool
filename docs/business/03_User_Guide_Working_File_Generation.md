# User Guide - Working File Generation
## Hướng Dẫn Sử Dụng Cho Người Dùng

## 📌 Giới Thiệu

Tài liệu này hướng dẫn người dùng (Demand Planner, Budget Planner) cách tạo và quản lý Working File trong Forecasting Tool.

**Ai nên đọc tài liệu này:**
- Demand Planning Team members
- Budget Planning Team members
- Sales Analytics Team members
- Management team cần hiểu quy trình

---

## 🎯 Working File Là Gì?

### Định Nghĩa
**Working File (WF)** là file Excel chính chứa tất cả thông tin dự báo hàng tháng, bao gồm:
- Dữ liệu lịch sử 24 tháng
- Dự báo 18 tháng
- Budget và Pre-Budget
- Tồn kho hiện tại
- Các breakdown forecast

### Tại Sao Quan Trọng?
Working File là **single source of truth** cho:
- ✅ Demand Planning
- ✅ Supply Planning
- ✅ Financial Planning
- ✅ Sales Performance Tracking
- ✅ Budget vs Forecast Analysis

### Working File Được Dùng Để Làm Gì?
1. **Review và adjust forecast** - DP team review và điều chỉnh số liệu
2. **Submit for approval** - Gửi cho management phê duyệt
3. **Drive supply planning** - Input cho sản xuất và mua hàng
4. **Track performance** - So sánh actual vs forecast
5. **Financial projection** - Dự báo revenue cho Finance

---

## 🚀 Cách Tạo Working File Mới

### Prerequisites (Điều Kiện Tiên Quyết)

Trước khi tạo WF, đảm bảo:

#### ✅ Checklist 1: Period Must Be Open
```
❏ Kiểm tra period đã được mở cho Division của bạn
❏ Ví dụ: Tạo WF cho CPD tháng 202502
  → Check: Period 202502 có "Open CPD" = Yes
```

**Cách kiểm tra:**
1. Mở Forecasting Tool trong Excel
2. Vào menu: **Tools → Check Period Status**
3. Chọn Division và Period
4. Xem trạng thái: **Open** / **Closed**

❌ **Nếu Closed:** Liên hệ Demand Planning Lead để mở period

---

#### ✅ Checklist 2: Data Ready
```
❏ Historical data từ SAP đã được import (24 months)
❏ Product Master data đã được update
❏ Promotional plans đã được finalize
❏ New launch plans đã sẵn sàng
❏ Budget data đã được upload (nếu có)
```

---

### Bước 1: Mở Forecasting Tool

**1.1 Khởi động Excel và Tool**
```
1. Mở Microsoft Excel
2. Tool sẽ tự động load (nếu đã cài đặt)
3. Kiểm tra Ribbon tab "FORECASTING TOOL" xuất hiện
```

**1.2 Login**
```
1. Click "Login" button trên Ribbon
2. Nhập Username và Password
3. Click "OK"
```

❗ **Lưu ý:** Mỗi user chỉ có quyền với Division được assign
- User CPD: Chỉ tạo WF cho CPD
- User LDB: Chỉ tạo WF cho LDB
- ...

---

### Bước 2: Chọn Generate Working File

**2.1 Navigate to Function**
```
1. Click vào Ribbon tab "FORECASTING TOOL"
2. Click button "Generate Working File"
   Hoặc:
   Task Pane bên phải → Click "Create New WF"
```

**2.2 Dialog Box sẽ hiện ra**

---

### Bước 3: Nhập Parameters

**Dialog "Generate Working File" sẽ yêu cầu:**

#### Parameter 1: Division
```
Dropdown: Chọn Division
Options: CPD / LDB / PPD / LLD

Ví dụ: Chọn "CPD"
```

#### Parameter 2: Forecast Month (FM_KEY)
```
Format: YYYYMM
Example: 202502 (February 2025)

Cách nhập:
- Option 1: Type directly "202502"
- Option 2: Chọn từ calendar picker
```

#### Parameter 3: Generation Mode
```
Dropdown: Chọn mode
Options:
  - Full Generation (Tạo mới hoàn toàn)
  - Partial Update (Cập nhật một phần)
  - Value Update (Cập nhật giá trị)
  - Re-Generate (Tạo lại theo selection)

Recommendation:
- Tạo WF lần đầu cho tháng mới: Chọn "Full Generation"
- Update promotional data: Chọn "Partial Update"
- Update budget only: Chọn "Value Update"
```

---

### Bước 4: Click Generate

**4.1 Confirm Parameters**
```
Kiểm tra lại:
✓ Division: CPD
✓ Period: 202502
✓ Mode: Full Generation

→ Click "Generate" button
```

**4.2 Processing Screen**
```
Tool sẽ hiện màn hình progress:

┌────────────────────────────────────────┐
│  Generating Working File...            │
│                                        │
│  Division: CPD                         │
│  Period: 202502                        │
│                                        │
│  Progress:                             │
│  [████████░░░░░░░░░░] 40%             │
│                                        │
│  Current Step:                         │
│  → Generating baseline forecast...    │
│                                        │
│  Elapsed: 05:32                        │
│  Estimated remaining: 08:15            │
└────────────────────────────────────────┘
```

**Các steps sẽ hiển thị:**
1. Validating period...
2. Initializing BFL Master...
3. Generating baseline forecast...
4. Creating Working File table...
5. Importing promotional forecasts...
6. Updating inventory data...
7. Calculating totals...
8. Finalizing...

⏱️ **Thời gian:** Thường 15-45 phút tùy Division

---

### Bước 5: Review Kết Quả

**5.1 Success Message**
```
┌────────────────────────────────────────┐
│  ✓ Working File Generated Successfully │
│                                        │
│  Division: CPD                         │
│  Period: 202502                        │
│  Total Products: 1,245                 │
│                                        │
│  Working File Location:                │
│  C:\FC\WorkingFiles\CPD_202502.xlsx    │
│                                        │
│  [Open File]  [Close]                  │
└────────────────────────────────────────┘
```

**5.2 Click "Open File"**
Tool sẽ tự động mở Working File Excel

---

## 📊 Hiểu Cấu Trúc Working File

### Layout Overview

Working File có cấu trúc dạng table với:
- **Rows:** Mỗi row = 1 Product (SKU)
- **Columns:** Grouped theo loại thông tin

```
┌──────────────────────────────────────────────────────────┐
│ Product Info │ Historical │ Forecast │ Budget │ Inventory│
├──────────────┼────────────┼──────────┼────────┼──────────┤
│ SKU 12345678 │ 24 months  │ 18 months│ Budget │ SOH, GIT │
│ ...          │ ...        │ ...      │ ...    │ ...      │
└──────────────────────────────────────────────────────────┘
```

---

### Column Groups Chi Tiết

#### Group 1: Product Information (Cột A-J)
```
Column A: Product Code (Mã sản phẩm)
Column B: Product Name (Tên sản phẩm)
Column C: Brand (Thương hiệu)
Column D: Category (Danh mục)
Column E: Sub-Category (Danh mục phụ)
Column F: Division (CPD/LDB/PPD)
Column G: Product Type (Regular/NPD/Promo)
Column H: Unit of Measure (Đơn vị)
Column I: Status (Active/Discontinue)
Column J: Packaging (Quy cách)
```

**Ví dụ row:**
```
12345678 | Shampoo ABC 400ml | L'Oréal Paris | Hair Care |
Shampoo | CPD | Regular | EA | Active | 400ml bottle
```

---

#### Group 2: Historical Actuals (24 months)
```
Cấu trúc column:
Actual_YYYYMM

Ví dụ (cho period 202502):
Column K: Actual_202302 (Feb 2023)
Column L: Actual_202303 (Mar 2023)
...
Column AG: Actual_202501 (Jan 2025)
```

**Dữ liệu:**
- Actual sales từ SAP
- Monthly aggregation
- Unit: EA (Each) hoặc theo Product UoM

**Ví dụ:**
```
Product: 12345678
Actual_202401: 1,000 units
Actual_202402: 1,050 units
Actual_202403: 1,100 units
...
```

**❗ Lưu ý:**
- Màu cells: **Gray background** (read-only)
- Không được edit historical actuals
- Source of truth: SAP

---

#### Group 3: Baseline Forecast (18 months)
```
Cấu trúc column:
FC_Baseline_YYYYMM

Ví dụ:
Column AH: FC_Baseline_202502 (Feb 2025)
Column AI: FC_Baseline_202503 (Mar 2025)
...
Column AY: FC_Baseline_202619 (Jul 2026)
```

**Dữ liệu:**
- Statistical baseline từ historical trend
- Generated automatically
- Có thể manual override

**Màu cells:** **Light blue** (editable with caution)

---

#### Group 4: Promotional Forecasts

**Promo Single - Offline:**
```
Column: FC_Promo_Single_Offline_YYYYMM
Data: Promotional forecast cho offline channels
Source: Marketing promo plan
```

**Promo Single - Online:**
```
Column: FC_Promo_Single_Online_YYYYMM
Data: Promotional forecast cho online channels
Source: Marketing promo plan
```

**Ví dụ:**
```
Product: Lipstick ABC
Period: 202502 (Valentine promo)

FC_Promo_Single_Offline_202502: 1,200 units
FC_Promo_Single_Online_202502: 300 units
Total Promo: 1,500 units
```

---

#### Group 5: New Launch Forecasts
```
Column: FC_Launch_Single_YYYYMM
Data: New product launch forecast
Source: NPD launch plan
```

**Ví dụ:**
```
Product: New Serum XYZ (Launch Feb 2025)

FC_Launch_Single_202502: 2,000 (M1 - Pipeline fill)
FC_Launch_Single_202503: 1,200 (M2 - Ramp-up)
FC_Launch_Single_202504: 1,100 (M3)
FC_Launch_Single_202505: 1,000 (M4 - Steady state)
```

---

#### Group 6: FOC (Free of Charge)
```
Column: FC_FOC_YYYYMM
Data: Free samples, GWP forecast
Source: Marketing GWP plan
```

---

#### Group 7: Promo BOM Components
```
Column: FC_Promo_BOM_Component_YYYYMM
Data: Component requirements cho promo sets/kits
Source: Promo BOM explosion
```

**Ví dụ:**
```
Component: Lipstick A
Part of BOM: "Beauty Box Tết 2025"
BOM forecast: 3,000 sets
Component qty per set: 1

→ FC_Promo_BOM_Component_202501: 3,000 units
```

---

#### Group 8: OPTIMUS Sell-In
```
Column: FC_SI_OPTIMUS_YYYYMM
Data: Sell-In calculated from Sell-Out forecast
Source: OPTIMUS system
```

---

#### Group 9: Budget Columns

**Budget (Official):**
```
Column: Budget_YYYYMM
Data: Board-approved annual budget
Source: Finance
Màu: Yellow background (reference only)
```

**Pre-Budget:**
```
Column: Pre_Budget_YYYYMM
Data: Draft budget
```

**Budget Trend:**
```
Column: Budget_Trend_YYYYMM
Data: Trend-based budget projection
```

**Ví dụ:**
```
Product: 12345678
Period: 202502

Budget_202502: 1,150 units (official)
Pre_Budget_202502: 1,200 units (draft)
Budget_Trend_202502: 1,100 units (trend projection)
```

---

#### Group 10: Total Sell-In Calculations

**SI Breakdown:**
```
SI_Promo_Single_YYYYMM: Tổng Promo Single SI
SI_FOC_YYYYMM: Tổng FOC SI
SI_Launch_Single_YYYYMM: Tổng Launch SI
SI_Promo_BOM_YYYYMM: Tổng Promo BOM SI
SI_OPTIMUS_YYYYMM: Tổng OPTIMUS SI
```

**Total SI:**
```
Column: Total_FC_SI_YYYYMM
Formula: = Sum of all SI components
```

**Ví dụ:**
```
Period: 202502

SI_Promo_Single_202502: 200
SI_FOC_202502: 100
SI_Launch_Single_202502: 0
SI_Promo_BOM_202502: 300
SI_OPTIMUS_202502: 1,100
─────────────────────────
Total_FC_SI_202502: 1,700 units
```

---

#### Group 11: Inventory Data

**SOH (Stock-On-Hand):**
```
Column: SOH_YYYYMM
Data: Available inventory
Source: SAP real-time
Update: Daily/Weekly
```

**GIT (Goods-In-Transit):**
```
Column: GIT_YYYYMM
Data: Shipments on the way
Source: SAP shipment tracking
```

**MTD SI (Month-To-Date Sell-In):**
```
Column: MTD_SI_YYYYMM
Data: Actual SI from beginning of month to current date
Source: SAP daily transactions
```

**Ví dụ (as of 15-Feb-2025):**
```
Product: 12345678

SOH_202502: 2,200 units (in warehouse now)
GIT_202502: 500 units (arriving soon)
MTD_SI_202502: 565 units (sold 01-15 Feb)

Monthly forecast: 1,200 units
Expected MTD (50%): 600 units
Actual MTD: 565 units
→ Slightly behind forecast
```

---

#### Group 12: Analysis Columns

**Risk Flag:**
```
Column: Risk_Flag_YYYYMM
Values: HIGH / MEDIUM / LOW / NONE
Indicates: Forecast risk level
```

**Risk reasons:**
- High forecast (>200% vs historical)
- Low forecast (<50% vs historical)
- Large promotion
- New launch uncertainty

**SLOB Flag:**
```
Column: SLOB_Flag
Values: YES / NO
Indicates: Slow-moving/Obsolete risk
```

**SLOB criteria:**
- DOS (Days of Supply) > 180 days
- Forecast < 10 units/month
- Product discontinue

**Gap Analysis:**
```
Column: Gap_FC_vs_Budget_YYYYMM
Formula: = Total_FC_SI - Budget
Shows: Forecast-Budget variance
```

**Ví dụ:**
```
Forecast: 2,000 units
Budget: 1,500 units
Gap: +500 units (+33%)
→ Need explanation
```

---

## ✏️ Cách Adjust Forecast trong Working File

### Khi Nào Cần Adjust?

**Scenarios phổ biến:**

1. **Baseline quá cao/thấp**
   - Statistical model không capture được trend mới
   - Market condition thay đổi

2. **Promotional forecast cần điều chỉnh**
   - Promo mechanic thay đổi
   - Marketing investment tăng/giảm

3. **New launch revised**
   - Launch date thay đổi
   - Launch plan update

4. **Manual override cho special cases**
   - One-time orders
   - Project-based sales
   - Seasonal exceptions

---

### Bước Adjust Forecast

#### Step 1: Identify Cell to Adjust

**Ví dụ:** Muốn tăng promo forecast cho Product 12345678 tháng Feb

```
1. Tìm row của Product 12345678
2. Navigate đến column: FC_Promo_Single_Offline_202502
3. Current value: 1,200 units
```

---

#### Step 2: Enter New Value

```
1. Double-click vào cell
2. Enter new value: 1,500 units
3. Press Enter
```

❗ **Lưu ý:**
- **Editable columns:** Light blue hoặc white background
- **Read-only columns:** Gray background (không edit được)
- **Formula columns:** Sẽ tự động recalculate

---

#### Step 3: Add Comment (Khuyến nghị)

```
1. Right-click vào cell đã edit
2. Choose "Insert Comment"
3. Type explanation:
   "Increased promo investment from 1M to 1.5M VND.
    Expected uplift +25%"
4. Save comment
```

**Tại sao cần comment:**
- ✅ Explain rationale cho adjustment
- ✅ Audit trail
- ✅ Team collaboration
- ✅ Future reference

---

#### Step 4: Validate Impact

**Check automatic recalculations:**

```
Original:
FC_Promo_Single_Offline_202502: 1,200
FC_Promo_Single_Online_202502: 300
→ SI_Promo_Single_202502: 1,500
→ Total_FC_SI_202502: 2,200

After adjustment:
FC_Promo_Single_Offline_202502: 1,500 (changed)
FC_Promo_Single_Online_202502: 300
→ SI_Promo_Single_202502: 1,800 (auto updated)
→ Total_FC_SI_202502: 2,500 (auto updated)

Gap vs Budget:
Before: 2,200 - 1,150 = +1,050 (+91%)
After: 2,500 - 1,150 = +1,350 (+117%)
→ Gap increased
```

---

#### Step 5: Document Change

**Best practice:** Maintain a change log

```
Change Log (separate sheet or file):
Date       | Product  | Column        | Old    | New    | Reason            | User
2025-02-01 | 12345678 | Promo_Offline | 1,200  | 1,500  | Increased invest | John
                        202502
```

---

### Protected Cells (Không Được Chỉnh Sửa)

**Các columns KHÔNG nên edit:**

❌ **Historical Actuals**
- Actual_YYYYMM columns
- Source of truth: SAP
- Chỉ update qua data refresh

❌ **Calculated Totals**
- Total_FC_SI_YYYYMM
- SI_* summary columns
- Auto-calculated by formulas

❌ **Product Master Info**
- Product Code, Name, Brand, Category
- Maintained in Master Data table

❌ **System-Generated Flags**
- Risk_Flag
- SLOB_Flag
- Auto-calculated by rules

---

## 💾 Cách Save và Submit Working File

### Save Working File

**Option 1: Save Locally (Draft)**
```
1. Click Excel "Save" button (Ctrl+S)
2. File saved to local path
3. For draft/review purpose only
```

**Option 2: Save to Server (Submit)**
```
1. Forecasting Tool Ribbon → "Submit Working File"
2. Dialog appears:
   - Confirm Division: CPD
   - Confirm Period: 202502
   - Enter Comments: "Feb forecast - including Valentine promo"
3. Click "Submit"
4. File uploaded to central server
5. Notification sent to approvers
```

**❗ Important:**
- Local save: Chỉ bạn thấy được
- Server submit: Team và management có thể access
- Luôn Submit khi done với adjustments

---

### Version Control

**System tự động tạo versions:**

```
Version History:
v1.0 - 2025-02-01 10:00 - Initial generation (System)
v1.1 - 2025-02-01 14:30 - Promo adjustments (User: John)
v1.2 - 2025-02-02 09:00 - Launch plan update (User: Mary)
v1.3 - 2025-02-03 11:00 - Final review (User: David)
```

**Xem version history:**
```
Tool Ribbon → "Version History"
→ Chọn version để view/compare
```

---

## 📈 Review và Validation Checklist

### Pre-Submit Checklist

Trước khi submit WF, kiểm tra:

#### ✅ Data Quality
```
❏ No blank values trong key columns
❏ No negative forecasts (unless intentional)
❏ Historical actuals complete (24 months)
❏ Totals calculate correctly
```

#### ✅ Reasonableness
```
❏ Forecast within reasonable range (not >300% vs history)
❏ Large variances have comments/explanations
❏ New launches have proper launch curve
❏ Promo uplifts are reasonable
```

#### ✅ Budget Alignment
```
❏ Review Forecast vs Budget gaps
❏ Large gaps (>20%) have explanations
❏ Budget is latest approved version
```

#### ✅ Inventory Consistency
```
❏ SOH values are current
❏ GIT values are realistic
❏ MTD actuals reconcile với SAP
```

#### ✅ Completeness
```
❏ All products have forecast (even if 0)
❏ All promotional campaigns reflected
❏ All new launches included
❏ FOC/GWP accounted for
```

---

### Validation Tools

**Tool cung cấp validation functions:**

**1. Run Validation Check**
```
Tool Ribbon → "Validate Working File"
→ System runs automated checks
→ Report highlights issues:
  ✓ 1,200 products validated
  ✓ 0 errors found
  ⚠ 15 warnings (high forecast)
  ⚠ 5 products with large budget gap
```

**2. View Error Report**
```
Errors tab shows:
Product     | Issue              | Severity | Action
12345678    | Forecast too high  | Warning  | Add comment
23456789    | Missing budget     | Error    | Contact Finance
34567890    | Negative forecast  | Error    | Correct value
```

**3. Fix Issues**
```
Click on each error → Jump to cell → Fix → Re-validate
```

---

## 🔄 Update Working File (Partial Updates)

### Khi Nào Dùng Partial Update?

**Scenarios:**
- Chỉ cần update promotional forecast
- Budget data mới release
- Inventory refresh
- MTD actuals update mid-month

**Không cần:** Re-generate toàn bộ WF

---

### Cách Thực Hiện Partial Update

#### Step 1: Open Existing WF
```
Tool Ribbon → "Open Working File"
→ Select Division: CPD
→ Select Period: 202502
→ File opens
```

#### Step 2: Choose Update Function
```
Tool Ribbon → "Update Working File" → Dropdown:
  - Update Promotional Forecasts
  - Update Budget Data
  - Update Inventory (SOH/GIT)
  - Update MTD Actuals
  - Update New Launches
  - Update OPTIMUS SI
```

#### Step 3: Select Update Type
```
Ví dụ: Chọn "Update Promotional Forecasts"

Dialog appears:
✓ Update Promo Single Offline
✓ Update Promo Single Online
✓ Update Promo BOM Components
☐ Update FOC (no changes)

→ Click "Update"
```

#### Step 4: System Updates
```
Processing...
[████████████████████] 100%

Updated successfully:
- 45 products with promo changes
- 3 new promotional campaigns added
- Totals recalculated

→ Click "OK"
```

#### Step 5: Review và Save
```
Review updates → Save → Submit (if ready)
```

**⏱️ Thời gian:** Partial update thường 5-15 phút

---

## 📊 Working File Analysis

### Built-in Reports

**Tool cung cấp sẵn reports:**

#### 1. Forecast Summary Report
```
Tool Ribbon → "Reports" → "Forecast Summary"

Shows:
Division: CPD
Period: 202502

Total Forecast: 125,000 units
  By Product Type:
    - Regular: 80,000 (64%)
    - Promo: 30,000 (24%)
    - New Launch: 15,000 (12%)

  By Channel:
    - Offline: 100,000 (80%)
    - Online: 25,000 (20%)
```

#### 2. Budget Gap Analysis
```
Tool Ribbon → "Reports" → "Budget Gap"

Forecast vs Budget:
Total Forecast: 125,000 units
Total Budget: 110,000 units
Gap: +15,000 units (+13.6%)

Top 10 products with largest gap:
Product     | Forecast | Budget | Gap      | %
12345678    | 2,500    | 1,150  | +1,350   | +117%
23456789    | 1,800    | 1,500  | +300     | +20%
...
```

#### 3. Risk Dashboard
```
Tool Ribbon → "Reports" → "Risk Dashboard"

High Risk Products: 25
  - High Forecast Risk: 15
  - Low Forecast Risk: 5
  - SLOB Risk: 5

Medium Risk: 80
Low Risk: 1,095
```

---

### Export Reports

**Export to PowerPoint:**
```
Reports → Select Report → "Export to PPT"
→ Auto-generates presentation
→ Include charts and tables
→ Ready for management review
```

**Export to PDF:**
```
Reports → "Export to PDF"
→ Full Working File exported
→ Formatted for printing/sharing
```

---

## 🔍 Common User Scenarios

### Scenario 1: Tạo WF Tháng Mới (First Time)

**Context:** Đầu tháng Feb, cần tạo WF cho Feb forecast

**Steps:**
```
1. Login to Forecasting Tool
2. Check period 202502 is open
3. Ribbon → "Generate Working File"
4. Input:
   - Division: CPD
   - Period: 202502
   - Mode: Full Generation
5. Click "Generate"
6. Wait ~30 minutes
7. File opens automatically
8. Review baseline forecast
9. Add promotional adjustments
10. Save and Submit
```

**Timeline:** Day 1-2 of month

---

### Scenario 2: Update Promo Mid-Month

**Context:** Marketing thay đổi Valentine promo plan

**Steps:**
```
1. Open existing WF (CPD 202502)
2. Ribbon → "Update Working File"
3. Select: "Update Promotional Forecasts"
4. System re-imports latest promo data
5. Review changes (highlight cells show updates)
6. Add comments for major changes
7. Save and Re-submit
```

**Timeline:** Any time during month

---

### Scenario 3: Monthly Performance Review

**Context:** End of month, compare actual vs forecast

**Steps:**
```
1. Open WF for current month
2. Ribbon → "Reports" → "Performance Review"
3. System compares:
   - MTD Actual vs MTD Forecast
   - Full Month Actual vs Full Month Forecast
4. Review variances:
   - Products over-performing
   - Products under-performing
5. Document learnings
6. Adjust next month forecast accordingly
```

---

### Scenario 4: Budget Alignment Meeting

**Context:** Finance requests Forecast vs Budget explanation

**Steps:**
```
1. Open latest WF
2. Ribbon → "Reports" → "Budget Gap Analysis"
3. Filter: Show only gaps > 20%
4. Export to PowerPoint
5. Add comments for each large gap
6. Present to Finance team
7. Document agreed actions
```

---

## ⚠️ Troubleshooting - Common Issues

### Issue 1: Cannot Generate WF - Period Blocked

**Error Message:**
```
"Forecast Month 202502 had been blocked for CPD"
```

**Solution:**
1. Period chưa được mở
2. Liên hệ: Demand Planning Lead
3. Request: Open period 202502 for CPD
4. Wait for confirmation
5. Retry generation

---

### Issue 2: WF Generation Failed Mid-Process

**Error Message:**
```
"Error at step: Generate baseline forecast
Code: 600012"
```

**Solution:**
1. Check error log: Ribbon → "View Error Log"
2. Common causes:
   - Historical data missing
   - Master data issues
   - Database connection timeout
3. Action:
   - Kiểm tra historical data đã import chưa
   - Verify product master updated
   - Retry generation
4. If persists: Contact IT Support

---

### Issue 3: Forecast Values Look Wrong

**Problem:** Baseline forecast quá cao hoặc quá thấp

**Diagnosis:**
```
1. Check historical actuals:
   - Có đúng không?
   - Có outliers (giá trị bất thường) không?
2. Review baseline calculation:
   - Ribbon → "Show Calculation Details"
   - Xem formula và inputs
```

**Solution:**
```
Option 1: Fix historical data
- If actuals sai → Contact Data team để correct
- Re-generate WF

Option 2: Manual override
- If logic không phù hợp → Manual edit baseline
- Add comment giải thích
```

---

### Issue 4: Cannot Save/Submit WF

**Error:** "Failed to submit Working File"

**Causes & Solutions:**

**Cause 1: Validation errors**
```
Solution:
- Ribbon → "Validate Working File"
- Fix all errors
- Re-submit
```

**Cause 2: Network issues**
```
Solution:
- Check network connection
- Save locally first (Ctrl+S)
- Retry submit when connection stable
```

**Cause 3: Permission issues**
```
Solution:
- Verify you have submit permission
- Contact System Admin
```

---

### Issue 5: MTD Actuals Not Matching SAP

**Problem:** MTD_SI column ≠ SAP report

**Diagnosis:**
```
1. Check data refresh date:
   - WF shows: "Last updated: 2025-02-10"
   - SAP report date: 2025-02-15
   → WF data is old

2. Check data source:
   - WF pulls from staging table
   - SAP shows real-time
   → Timing difference
```

**Solution:**
```
Ribbon → "Refresh Inventory Data"
→ System pulls latest SOH/MTD/GIT
→ Verify numbers now match
```

---

## 📞 Support & Help

### Built-in Help

**Help Menu:**
```
Ribbon → "Help" button → Dropdown:
  - User Guide (this document)
  - Video Tutorials
  - FAQs
  - Contact Support
  - About (version info)
```

**Contextual Help:**
```
Hover mouse over any button → Tooltip appears
Example: Hover over "Generate Working File"
→ "Generate a new Working File for the selected
   division and period. This process takes 15-45
   minutes depending on data volume."
```

---

### Video Tutorials

**Available in Tool:**
```
Help → "Video Tutorials" → List:
  1. Getting Started (5 min)
  2. Generating Your First WF (10 min)
  3. Adjusting Forecasts (8 min)
  4. Understanding Budget Gaps (12 min)
  5. Partial Updates (6 min)
  6. Reports and Analysis (15 min)
```

---

### Contact Support

**For different issues:**

**Data Issues:**
- Historical data missing/wrong
- Master data problems
→ Contact: **Data Team** (data@loreal.com)

**Tool/System Issues:**
- Tool not loading
- Errors during generation
- Performance problems
→ Contact: **IT Support** (itsupport@loreal.com)

**Process/Business Questions:**
- How to interpret forecast
- Business logic clarification
- Approval workflow
→ Contact: **Demand Planning Lead** (dp.lead@loreal.com)

**Training Requests:**
- New user training
- Advanced features
- Best practices
→ Contact: **Training Team** (training@loreal.com)

---

## 📚 Best Practices

### Do's ✅

**1. Data Management**
- ✅ Always validate before submit
- ✅ Add comments for adjustments
- ✅ Keep change log
- ✅ Regular data refresh

**2. Forecast Quality**
- ✅ Review baseline reasonableness
- ✅ Cross-check with market trends
- ✅ Validate promotional uplifts
- ✅ Document assumptions

**3. Collaboration**
- ✅ Share insights with team
- ✅ Discuss large gaps with Finance
- ✅ Align with Marketing on promos
- ✅ Coordinate with Supply Planning

**4. Version Control**
- ✅ Submit regularly (don't wait too long)
- ✅ Meaningful version comments
- ✅ Track major changes
- ✅ Compare versions before approve

**5. Continuous Improvement**
- ✅ Review forecast accuracy monthly
- ✅ Learn from variances
- ✅ Adjust models based on learnings
- ✅ Share best practices

---

### Don'ts ❌

**1. Data Integrity**
- ❌ Don't edit historical actuals
- ❌ Don't delete products from WF
- ❌ Don't manually change calculated totals
- ❌ Don't ignore validation errors

**2. Process**
- ❌ Don't skip validation
- ❌ Don't submit without review
- ❌ Don't make major changes without documentation
- ❌ Don't work on outdated versions

**3. Forecast Quality**
- ❌ Don't accept unrealistic forecasts
- ❌ Don't ignore large budget gaps
- ❌ Don't forecast without checking SOH
- ❌ Don't copy previous month blindly

**4. Collaboration**
- ❌ Don't make changes without team awareness
- ❌ Don't submit without cross-functional check
- ❌ Don't ignore feedback from reviewers
- ❌ Don't work in silos

---

## 🎓 Training Resources

### Self-Paced Learning Path

**Week 1: Basics**
- Day 1-2: Understand WF structure
- Day 3-4: Practice generating WF
- Day 5: Learn validation tools

**Week 2: Advanced**
- Day 1-2: Partial updates
- Day 3-4: Forecast adjustments
- Day 5: Reports and analysis

**Week 3: Mastery**
- Day 1-3: Complex scenarios
- Day 4-5: Troubleshooting

### Certification

**Forecasting Tool User Certification:**
```
Level 1: Basic User
- Can generate WF
- Can make simple adjustments
- Understand key columns

Level 2: Advanced User
- Can perform partial updates
- Can run all reports
- Can troubleshoot common issues

Level 3: Power User
- Can train others
- Can customize reports
- Can optimize forecasts
```

**Request certification:** training@loreal.com

---

## 📝 Appendix

### Appendix A: Glossary of Terms

```
BFL: Base Forecast Line
BOM: Bill of Materials
CPD: Consumer Products Division
DOS: Days of Supply
FC: Forecast
FM: Forecast Model / Forecast Month
FOC: Free of Charge
GIT: Goods-In-Transit
GWP: Gift With Purchase
LDB: Luxury Division Brand
MTD: Month-To-Date
NPD: New Product Development
PPD: Professional Products Division
SI: Sell-In (from L'Oréal to distributor/retailer)
SLOB: Slow and Obsolete
SO: Sell-Out (from retailer to consumer)
SOH: Stock-On-Hand
WF: Working File
```

### Appendix B: Keyboard Shortcuts

```
Ctrl+S: Save WF locally
Ctrl+Shift+S: Submit WF to server
Ctrl+Shift+V: Validate WF
Ctrl+Shift+R: Refresh data
Ctrl+Shift+H: View version history
F1: Open Help
F5: Refresh current view
Alt+F: Open File menu
Alt+T: Open Tools menu
Alt+R: Open Reports menu
```

### Appendix C: Color Coding in WF

```
Gray background: Historical actuals (read-only)
Light blue: Editable forecast fields
Yellow: Budget data (reference)
White: General editable fields
Red text: Errors/Validation issues
Orange text: Warnings
Green highlight: Recently updated cells
```

---

**Document Version:** 1.0
**Last Updated:** 2025-11-18
**Owner:** L'Oréal Vietnam Demand Planning Team
**For Support:** dp.support@loreal.com
