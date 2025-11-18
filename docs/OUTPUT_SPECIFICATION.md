# Đặc Tả Kết Quả Đầu Ra - Output Specification

## 1. Tổng Quan Output

Hệ thống Forecasting Tool tạo ra nhiều loại output khác nhau phục vụ cho các mục đích khác nhau: dự báo, phân tích, export SAP, và báo cáo.

```
┌─────────────────────────────────────────────────────────────────┐
│                        OUTPUT TYPES                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. WORKING FILE (WF) - Excel                                   │
│     └─ Main forecasting tool for users                          │
│                                                                  │
│  2. FM EXPORT - Excel Templates                                 │
│     └─ SAP upload format                                        │
│                                                                  │
│  3. BI REPORTS - Excel Dashboards                               │
│     └─ Analysis and visualization                               │
│                                                                  │
│  4. GAP ANALYSIS - WinForms Application                         │
│     └─ Budget vs Forecast comparison                            │
│                                                                  │
│  5. DATABASE TABLES - SQL Server                                │
│     └─ Permanent storage and audit trail                        │
│                                                                  │
│  6. ALERTS & NOTIFICATIONS                                      │
│     └─ Warnings and error messages                              │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. Output Type 1: Working File (WF)

### 2.1. File Information

**File Name:**
```
FC_WORKING_FILE.xlsm
```

**Location:**
```
C:\Users\Public\Downloads\Application\FC\Extension\FILES\FC_WORKING_FILE.xlsm
```

**File Type:** Excel Macro-Enabled Workbook (.xlsm)

**Purpose:**
- Main interface for demand planners to create and edit forecasts
- Combines historical data, forecast inputs, budget, and calculations
- Central hub for all forecasting activities

### 2.2. Sheet Structure

#### Sheet: WF (Working File)

**Layout:**
```
┌─────────────────────────────────────────────────────────────────────────────┐
│ Product type | Forecasting Line | Channel | Time series | [Columns...] │
├─────────────────────────────────────────────────────────────────────────────┤
│ Historical Y-2 (Blue - Read-only)                                           │
│ [Y-2 (u) M1] | [Y-2 (u) M2] | ... | [Y-2 (u) M12]                         │
├─────────────────────────────────────────────────────────────────────────────┤
│ Historical Y-1 (Blue - Read-only)                                           │
│ [Y-1 (u) M1] | [Y-1 (u) M2] | ... | [Y-1 (u) M12]                         │
├─────────────────────────────────────────────────────────────────────────────┤
│ Historical Y0 (Blue - Read-only, past months only)                          │
│ [Y0 (u) M1] | [Y0 (u) M2] | ... | [Y0 (u) Mcurrent]                       │
├─────────────────────────────────────────────────────────────────────────────┤
│ Forecast Y0 (Green - Editable)                                              │
│ [Y0 (u) Mcurrent] | [Y0 (u) Mcurrent+1] | ... | [Y0 (u) M12]              │
├─────────────────────────────────────────────────────────────────────────────┤
│ Forecast Y+1 (Green - Editable)                                             │
│ [Y+1 (u) M1] | [Y+1 (u) M2] | ... | [Y+1 (u) M12]                         │
├─────────────────────────────────────────────────────────────────────────────┤
│ Budget Y0 (Yellow - Read-only)                                              │
│ [B_Y0_M1] | [B_Y0_M2] | ... | [B_Y0_M12]                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│ Budget Y+1 (Yellow - Read-only)                                             │
│ [B_Y+1_M1] | [B_Y+1_M2] | ... | [B_Y+1_M12]                                │
├─────────────────────────────────────────────────────────────────────────────┤
│ Pre-Budget Y+1 (Yellow - Read-only)                                         │
│ [PB_Y+1_M1] | [PB_Y+1_M2] | ... | [PB_Y+1_M12]                             │
├─────────────────────────────────────────────────────────────────────────────┤
│ Trends (Yellow - Read-only)                                                 │
│ [T1_Y0_M1] | [T2_Y0_M1] | [T3_Y0_M1] | ... (for each month)                │
├─────────────────────────────────────────────────────────────────────────────┤
│ M-1 Forecast (Gray - Read-only, reference from previous month)             │
│ [M-1_Y0_M1] | [M-1_Y0_M2] | ... | [M-1_Y0_M12]                             │
├─────────────────────────────────────────────────────────────────────────────┤
│ Calculations (Orange - Auto-calculated)                                     │
│ AVE P3M | AVE F3M | MTD SI | SOH | GIT M0-M3 | SLOB | BP Gap %             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2.3. Column Definitions

**Fixed Columns:**

| Column Name | Type | Description | Example |
|-------------|------|-------------|---------|
| Product type | VARCHAR | Type of product | Finished Good, Bundle, Promo Pack |
| Forecasting Line | VARCHAR | Sub Group from Spectrum Master | LOP Revitalift Cream |
| Channel | VARCHAR | Sales channel | ONLINE, OFFLINE, O+O |
| Time series | VARCHAR | Forecast component | 1. Baseline Qty, 2. Promo Qty, etc. |

**Dynamic Columns (Historical):**

Format: `[Y{offset} (u) M{month}]`

Example for FM_KEY = CPD_2025_01:
```
[Y-2 (u) M1] = January 2023
[Y-1 (u) M1] = January 2024
[Y0 (u) M1] = January 2025
```

**Data Type:** INTEGER (units)

**Color Coding:** 🟦 Blue (read-only)

**Dynamic Columns (Forecast):**

Format: `[Y{offset} (u) M{month}]`

Example:
```
[Y0 (u) M1] through [Y0 (u) M12] = 2025
[Y+1 (u) M1] through [Y+1 (u) M12] = 2026
```

**Data Type:** INTEGER (units)

**Color Coding:** 🟩 Green (editable)

**Budget Columns:**

Format: `[B_Y{offset}_M{month}]` or `[PB_Y{offset}_M{month}]` or `[T{n}_Y{offset}_M{month}]`

Example:
```
[B_Y0_M1] = Budget January 2025
[PB_Y+1_M1] = Pre-Budget January 2026
[T1_Y0_M1] = Trend 1 January 2025
```

**Data Type:** INTEGER (units)

**Color Coding:** 🟨 Yellow (read-only)

**Calculation Columns:**

| Column Name | Type | Formula | Description |
|-------------|------|---------|-------------|
| AVE P3M | INT | AVG(last 3 months actual) | Average previous 3 months |
| AVE F3M | INT | AVG(next 3 months forecast) | Average forecast 3 months |
| MTD SI | INT | SUM(SI this month so far) | Month-to-date sell-in |
| SOH | INT | From ZMR32 | Stock on hand |
| SIT | INT | SOH - GIT_M0 | Stock in transit deducted |
| GIT M0 | INT | From GIT data | Goods in transit M0 |
| GIT M1 | INT | From GIT data | Goods in transit M1 |
| GIT M2 | INT | From GIT data | Goods in transit M2 |
| GIT M3 | INT | From GIT data | Goods in transit M3 |
| SLOB Risk | VARCHAR | HIGH/MEDIUM/LOW | Slow-moving risk flag |
| BP Gap % | DECIMAL | (Forecast-Budget)/Budget×100 | Budget gap percentage |

**Color Coding:** 🟧 Orange (auto-calculated)

### 2.4. Row Structure

**Rows per Sub_Group:**

For each Sub_Group, there are rows for each Channel × Time_Series combination:

```
Example: LOP Revitalift Cream

Row 1:  ONLINE  | 1. Baseline Qty
Row 2:  ONLINE  | 2. Promo Qty
Row 3:  ONLINE  | 4. Launch Qty
Row 4:  ONLINE  | 5. FOC Qty
Row 5:  ONLINE  | 6. Total Qty (calculated)
Row 6:  OFFLINE | 1. Baseline Qty
Row 7:  OFFLINE | 2. Promo Qty
Row 8:  OFFLINE | 4. Launch Qty
Row 9:  OFFLINE | 5. FOC Qty
Row 10: OFFLINE | 6. Total Qty (calculated)
Row 11: O+O     | 1. Baseline Qty (calculated)
Row 12: O+O     | 2. Promo Qty (calculated)
Row 13: O+O     | 4. Launch Qty (calculated)
Row 14: O+O     | 5. FOC Qty (calculated)
Row 15: O+O     | 6. Total Qty (calculated)
```

**Total Rows:**
```
Number of Sub_Groups × 3 Channels × 5 Time_Series = Total Rows

Example:
50 Sub_Groups × 3 × 5 = 750 rows
```

### 2.5. Sample Data

**Example Row:**
```
Product type:        Finished Good
Forecasting Line:    LOP Revitalift Cream
Channel:             ONLINE
Time series:         1. Baseline Qty

Historical:
[Y-2 (u) M1]: 4000
[Y-2 (u) M2]: 4200
...
[Y-1 (u) M1]: 4500
[Y-1 (u) M2]: 4600
...
[Y0 (u) M1]: 4800 (actual)
[Y0 (u) M2]: (blank - current month)

Forecast (Editable):
[Y0 (u) M2]: 5000 (user input)
[Y0 (u) M3]: 5200 (user input)
...
[Y+1 (u) M1]: 5500 (user input)
...

Budget:
[B_Y0_M1]: 4700
[B_Y0_M2]: 4900
...

Calculations:
AVE P3M: 4600
AVE F3M: 5100
SOH: 15000
SLOB Risk: LOW
BP Gap %: 2.04%
```

### 2.6. View Filters

**Filter Options (Custom Task Pane):**

| Filter | Description | What's Hidden |
|--------|-------------|---------------|
| **All** | Show all data | Nothing (default view) |
| **Total Only** | Show only Total Qty rows | Hide Baseline, Promo, Launch, FOC rows |
| **BP vs FC** | Show Budget vs Forecast comparison | Hide detailed time series |

**Implementation:**
```csharp
// From UTaskPane.cs
private void btnFilterAll_Click(object sender, EventArgs e)
{
    // Show all rows
    foreach (Excel.Range row in worksheet.UsedRange.Rows)
    {
        row.Hidden = false;
    }
}

private void btnFilterTotalOnly_Click(object sender, EventArgs e)
{
    // Hide rows where Time_Series <> "6. Total Qty"
    foreach (Excel.Range row in worksheet.UsedRange.Rows)
    {
        if (row.Cells[4].Value != "6. Total Qty") // Column 4 = Time series
        {
            row.Hidden = true;
        }
    }
}
```

---

## 3. Output Type 2: FM Export

### 3.1. File Information

**File Name Format:**
```
{Division}_FM_{FMKEY}.xlsx
```

**Examples:**
```
CPD_FM_CPD_2025_01.xlsx
LDB_FM_LDB_2025_02.xlsx
LLD_FM_LLD_2025_03.xlsx
```

**Location:**
```
\\10.240.65.43\loreal\10_PUBLIC\03_SAPData\SC_IMPORT\Archive\FORECAST\{Division}\FM_Template_Upload\FM_Final\
```

**File Type:** Excel Workbook (.xlsx)

**Purpose:**
- Export forecast data in SAP-compatible format
- Upload to SAP for demand planning and MRP
- Archive of final forecast for each month

### 3.2. Export Options

**Time Series Selection:**

Users can select which time series to export:

- [ ] 1. Baseline Qty
- [ ] 2. Promo Qty
- [ ] 4. Launch Qty
- [ ] 5. FOC Qty
- [x] 6. Total Qty (default, always exported)

**Channel Selection:**

- [ ] ONLINE only
- [ ] OFFLINE only
- [x] O+O (both channels combined, default)

**Export Procedure:**
```sql
-- From sp_FC_EXPORT_TO_FM_VIEW
EXEC sp_FC_EXPORT_TO_FM_VIEW
    @Division = 'CPD',
    @FM_KEY = 'CPD_2025_01',
    @Time_Series = '6. Total Qty',
    @Channel = 'O+O',
    @Output_Path = '\\10.240.65.43\loreal\...\CPD_FM_CPD_2025_01.xlsx'
```

### 3.3. FM Template Structure

**Sheet Name:** FM_Data

**Column Structure:**

| Column Name | Type | Description | Example |
|-------------|------|-------------|---------|
| Spectrum | VARCHAR(18) | SAP Material Code | 3600542410311 |
| Material_Description | VARCHAR(200) | Product name | L'Oreal Paris Revitalift Cream 50ml |
| Division | VARCHAR(3) | Division | CPD |
| Sub_Group | VARCHAR(100) | Forecast line | LOP Revitalift Cream |
| Channel | VARCHAR(20) | Channel | O+O |
| Time_Series | VARCHAR(20) | Time series type | 6. Total Qty |
| Y0_M1 | INT | Forecast month 1 | 5000 |
| Y0_M2 | INT | Forecast month 2 | 5200 |
| ... | ... | ... | ... |
| Y0_M12 | INT | Forecast month 12 | 8000 |
| Y1_M1 | INT | Forecast Y+1 M1 | 6000 |
| ... | ... | ... | ... |
| Y1_M12 | INT | Forecast Y+1 M12 | 9000 |
| Created_Date | DATETIME | Export date | 2025-01-15 10:30:00 |
| Created_By | VARCHAR(50) | User who exported | demand.planner1 |

**Data Transformation:**

```
WF Format (Sub_Group aggregated):
LOP Revitalift Cream | ONLINE | 6. Total Qty | 5000 | 5200 | ...

↓ Explode to Spectrum level ↓

FM Format (Spectrum detailed):
3600542410311 | LOP Revitalift Cream 50ml | CPD | LOP Revitalift Cream | O+O | 6. Total Qty | 5000 | 5200 | ...
3600542410328 | LOP Revitalift Cream 30ml | CPD | LOP Revitalift Cream | O+O | 6. Total Qty | 2000 | 2100 | ...
```

**Spectrum Split Logic:**
```sql
-- Distribute Sub_Group forecast to individual Spectrums
-- Based on historical sales mix

WITH Historical_Mix AS (
    SELECT
        sm.Spectrum,
        sm.Sub_Group,
        SUM(so.SO_Qty) AS Historical_Qty,
        SUM(SUM(so.SO_Qty)) OVER (PARTITION BY sm.Sub_Group) AS Sub_Group_Total,
        CAST(SUM(so.SO_Qty) AS FLOAT) /
            SUM(SUM(so.SO_Qty)) OVER (PARTITION BY sm.Sub_Group) AS Split_Pct
    FROM Historical_SO so
    INNER JOIN Spectrum_Master sm ON so.Material = sm.Spectrum
    WHERE so.Month >= DATEADD(MONTH, -3, GETDATE())
    GROUP BY sm.Spectrum, sm.Sub_Group
),
Spectrum_Forecast AS (
    SELECT
        hm.Spectrum,
        fc.Sub_Group,
        fc.Period,
        fc.Forecast_Qty,
        hm.Split_Pct,
        fc.Forecast_Qty * hm.Split_Pct AS Spectrum_Forecast_Qty
    FROM WF_Master fc
    INNER JOIN Historical_Mix hm ON fc.Sub_Group = hm.Sub_Group
    WHERE fc.Channel = 'O+O'
      AND fc.Time_Series = '6. Total Qty'
)
SELECT * FROM Spectrum_Forecast
```

### 3.4. Sample FM Export

**Example:**
```
Spectrum      | Material_Description       | Sub_Group            | Y0_M1 | Y0_M2 | Y0_M3
--------------|----------------------------|----------------------|-------|-------|-------
3600542410311 | LOP Revitalift Cream 50ml  | LOP Revitalift Cream | 3000  | 3100  | 3200
3600542410328 | LOP Revitalift Cream 30ml  | LOP Revitalift Cream | 2000  | 2100  | 2200
3600542410335 | LOP Revitalift Serum 30ml  | LOP Revitalift Serum | 2500  | 2600  | 2700
...
```

### 3.5. Export Process

**User Workflow:**
```
1. Open Working File
2. Click "Export to FM" in Custom Task Pane
3. FrmExportFMFull form opens
4. Select options:
   - Time Series: [x] 6. Total Qty
   - Channel: [x] O+O
5. Click "Export"
6. Progress bar shows export status
7. Confirmation message with file path
8. File saved to network share
```

**Code Flow:**
```csharp
// From FrmExportFMFull.cs
private void btnExport_Click(object sender, EventArgs e)
{
    string division = txtDivision.Text; // CPD
    string fmKey = txtFMKey.Text; // CPD_2025_01
    string timeSeries = cboTimeSeries.SelectedItem.ToString(); // 6. Total Qty
    string channel = cboChannel.SelectedItem.ToString(); // O+O

    string outputPath = $@"\\10.240.65.43\loreal\10_PUBLIC\03_SAPData\SC_IMPORT\Archive\FORECAST\{division}\FM_Template_Upload\FM_Final\{division}_FM_{fmKey}.xlsx";

    // Call stored procedure to generate FM view
    Connection_SQL.ExecuteStoredProcedure("sp_FC_EXPORT_TO_FM_VIEW",
        new SqlParameter("@Division", division),
        new SqlParameter("@FM_KEY", fmKey),
        new SqlParameter("@Time_Series", timeSeries),
        new SqlParameter("@Channel", channel));

    // Export to Excel
    DataTable dtFM = Connection_SQL.GetDataTable("SELECT * FROM V_FM_Export_Final");
    ExportToExcel(dtFM, outputPath);

    MessageBox.Show($"FM Export completed successfully!\nFile: {outputPath}");
}
```

---

## 4. Output Type 3: BI Reports

### 4.1. File Information

**File Name:**
```
FC_BI_User_{Division}.xlsm
```

**Examples:**
```
FC_BI_User_CPD.xlsm
FC_BI_User_LDB.xlsm
FC_BI_User_LLD.xlsm
```

**Location:**
```
C:\Users\Public\Downloads\Application\FC\Extension\FILES\BI_Reports\
```

**File Type:** Excel Macro-Enabled Workbook (.xlsm)

**Purpose:**
- Interactive dashboards for analysis
- Pivot tables and charts
- Linked to WF data

### 4.2. Dashboard Components

**Sheet 1: Summary Dashboard**

**KPIs:**
- Total Forecast (Y0, Y+1)
- Budget vs Forecast Gap %
- YTD Performance %
- Top 10 Products by volume

**Charts:**
- Forecast vs Budget trend (line chart)
- Channel split (pie chart)
- Sub_Group ranking (bar chart)
- Risk alerts (traffic light)

**Sheet 2: Detailed Analysis**

**Pivot Tables:**
- Forecast by Sub_Group, Channel, Month
- Budget Gap analysis
- Historical vs Forecast comparison

**Slicers:**
- Division
- Sub_Group
- Channel
- Time period

**Sheet 3: Performance Metrics**

**Tables:**
- Forecast Accuracy (M-1 vs Actual)
- MTD Performance
- YTD Performance
- SLOB items list
- High risk items (3M Risk)

**Sheet 4: Trend Analysis**

**Charts:**
- Rolling 12-month trend
- Seasonality patterns
- Growth rates
- Channel shift over time

### 4.3. Data Connection

**Connection Type:** Excel Data Model (Power Pivot)

**Data Sources:**
1. SQL Server connection to WF_Master table
2. Refresh on open (optional)
3. Manual refresh via "Refresh All" button

**Connection String:**
```
Provider=SQLOLEDB;Data Source=10.240.65.33;Initial Catalog=SC2;User ID={user};Password={password}
```

### 4.4. Sample BI Report

**Summary Dashboard View:**
```
┌─────────────────────────────────────────────────────────────────┐
│              L'Oréal CPD Forecast Dashboard                     │
│                 FM: CPD_2025_01 (January 2025)                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  KPIs:                                                          │
│  ┌────────────┬────────────┬────────────┬────────────┐        │
│  │ Y0 Forecast│ Y1 Forecast│ BP Gap %   │ YTD Perf % │        │
│  │ 5.2M units │ 6.1M units │ +3.5%      │ 98.2%      │        │
│  └────────────┴────────────┴────────────┴────────────┘        │
│                                                                  │
│  Forecast vs Budget Trend:                                      │
│  [Line Chart: Monthly forecast vs budget for 12 months]        │
│                                                                  │
│  Channel Split (Y0):                                            │
│  [Pie Chart: ONLINE 35%, OFFLINE 65%]                          │
│                                                                  │
│  Top 10 Products by Volume:                                     │
│  [Bar Chart: LOP Revitalift, LOP UV Perfect, etc.]            │
│                                                                  │
│  Risk Alerts:                                                   │
│  🔴 High SLOB: 12 items                                         │
│  🟡 3M Risk: 8 items                                            │
│  🟢 Stock-out: 0 items                                          │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 5. Output Type 4: Gap Analysis Report

### 5.1. Application Information

**Application Name:** WinFormsApp2.exe

**Launch Method:**
```
WinFormsApp2.exe "D:CPD,F:CPD_2025_01,U:demand.planner1,L:Compare,S:10.240.65.33,A:SC2"
```

**Parameters:**
- D: Division (CPD, LDB, LLD)
- F: FM_KEY
- U: UserID
- L: Launch mode (Compare)
- S: Server
- A: Database (Application)

**Purpose:**
- Compare Budget vs Demand Plan (Forecast)
- Line-by-line variance analysis
- Interactive grid with filtering and sorting

### 5.2. Grid Structure

**DevExpress GridControl Columns:**

| Column Name | Type | Description | Example |
|-------------|------|-------------|---------|
| Sub_Group | String | Product line | LOP Revitalift Cream |
| Channel | String | Channel | ONLINE / OFFLINE / O+O |
| Budget_Y0_Total | Int | Total Budget Y0 | 100000 |
| Forecast_Y0_Total | Int | Total Forecast Y0 | 105000 |
| Variance_Abs | Int | Absolute variance | 5000 |
| Variance_Pct | Decimal | Variance % | 5.0% |
| Budget_Y1_Total | Int | Total Budget Y+1 | 120000 |
| Forecast_Y1_Total | Int | Total Forecast Y+1 | 130000 |
| Monthly Columns | Int | Budget and Forecast by month | See below |

**Monthly Columns (Expandable):**
```
Budget_Y0_M1, Forecast_Y0_M1, Variance_M1
Budget_Y0_M2, Forecast_Y0_M2, Variance_M2
...
Budget_Y0_M12, Forecast_Y0_M12, Variance_M12
```

### 5.3. Features

**Grid Features:**
- ✅ Sorting by any column
- ✅ Filtering (auto-filter rows)
- ✅ Grouping by Sub_Group or Channel
- ✅ Export to Excel
- ✅ Conditional formatting (variance > 20% highlighted in red)
- ✅ Summary row (totals at bottom)

**User Actions:**
```csharp
// From Frm_Devexpress_Gridcontrol.cs

// Load data
private void LoadGapAnalysis()
{
    DataTable dt = Connection_SQL.GetDataTable(
        "SELECT * FROM V_Gap_Analysis WHERE Division = @Division AND FM_KEY = @FM_KEY",
        new SqlParameter("@Division", division),
        new SqlParameter("@FM_KEY", fmKey)
    );

    gridControl1.DataSource = dt;

    // Apply conditional formatting
    gridView1.OptionsFormatCondition.HighlightRow = true;
    FormatConditionRuleValue rule = new FormatConditionRuleValue();
    rule.Condition = FormatCondition.Greater;
    rule.Value1 = 20; // Variance % > 20%
    rule.Appearance.BackColor = Color.Red;
    rule.Appearance.ForeColor = Color.White;
    gridView1.FormatConditions.Add(rule);
}

// Export to Excel
private void btnExport_Click(object sender, EventArgs e)
{
    SaveFileDialog saveDialog = new SaveFileDialog();
    saveDialog.Filter = "Excel files (*.xlsx)|*.xlsx";
    saveDialog.FileName = $"Gap_Analysis_{division}_{fmKey}.xlsx";

    if (saveDialog.ShowDialog() == DialogResult.OK)
    {
        gridView1.ExportToXlsx(saveDialog.FileName);
        MessageBox.Show("Export completed!");
    }
}
```

### 5.4. Sample Gap Analysis Output

**Grid View:**
```
Sub_Group            | Channel | Budget Y0 | Forecast Y0 | Variance | Var %
---------------------|---------|-----------|-------------|----------|-------
LOP Revitalift Cream | O+O     | 1000000   | 1050000     | +50000   | +5.0%
LOP UV Perfect       | O+O     | 800000    | 750000      | -50000   | -6.3%
LOP Age Perfect      | O+O     | 600000    | 750000      | +150000  | +25.0% 🔴
...

Summary Row:
TOTAL                | O+O     | 10000000  | 10350000    | +350000  | +3.5%
```

---

## 6. Output Type 5: Database Tables

### 6.1. Permanent Tables

**Main Forecast Table:**
```sql
FC_FM_{Division}_{FMKEY}
```

**Example:**
```
FC_FM_CPD_CPD_2025_01
```

**Columns:**
| Column Name | Type | Description |
|-------------|------|-------------|
| ID | INT IDENTITY | Primary key |
| Division | VARCHAR(3) | Division |
| FM_KEY | VARCHAR(20) | Forecast month key |
| Spectrum | VARCHAR(18) | Material code |
| Sub_Group | VARCHAR(100) | Forecast line |
| Channel | VARCHAR(20) | Channel |
| Time_Series | VARCHAR(20) | Time series type |
| Period | DATE | Period (YYYY-MM-01) |
| Quantity | INT | Forecast quantity |
| Source | VARCHAR(20) | Direct / BOM_Explosion |
| Created_Date | DATETIME | Creation timestamp |
| Created_By | VARCHAR(50) | User who created |
| Modified_Date | DATETIME | Last modification |
| Modified_By | VARCHAR(50) | User who modified |
| Locked | BIT | Locked flag (1 = locked) |

**Indexes:**
```sql
CREATE INDEX IX_FC_FM_Division_FMKEY ON FC_FM_CPD_CPD_2025_01(Division, FM_KEY)
CREATE INDEX IX_FC_FM_SubGroup ON FC_FM_CPD_CPD_2025_01(Sub_Group, Channel, Period)
CREATE INDEX IX_FC_FM_Spectrum ON FC_FM_CPD_CPD_2025_01(Spectrum, Period)
```

**BOM Table:**
```sql
FC_BOM_{Division}_{FMKEY}
```

**Columns:**
| Column Name | Type | Description |
|-------------|------|-------------|
| ID | INT IDENTITY | Primary key |
| Division | VARCHAR(3) | Division |
| FM_KEY | VARCHAR(20) | Forecast month key |
| Bundle_Spectrum | VARCHAR(18) | Bundle material code |
| Component_Spectrum | VARCHAR(18) | Component material code |
| Quantity_Per_Bundle | DECIMAL(10,2) | Quantity per bundle |
| Valid_From | DATE | Valid from date |
| Valid_To | DATE | Valid to date |
| Status | VARCHAR(10) | ACTIVE / INACTIVE |
| Created_Date | DATETIME | Creation timestamp |
| Created_By | VARCHAR(50) | User who created |

### 6.2. Archive Tables

**FM History:**
```sql
FC_FM_History
```

**Purpose:** Archive all previous FM versions for audit trail

**Columns:**
- All columns from FC_FM table
- Plus: Archive_Date, Archive_Reason

**Retention:** Keep all historical FMs (no deletion)

**Query Example:**
```sql
-- Get M-1 forecast (previous month final)
SELECT *
FROM FC_FM_History
WHERE Division = 'CPD'
  AND FM_KEY = 'CPD_2024_12' -- Previous month
  AND Channel = 'O+O'
  AND Time_Series = '6. Total Qty'
ORDER BY Sub_Group, Period
```

### 6.3. Audit Tables

**User Action Log:**
```sql
FC_User_Action_Log
```

**Columns:**
| Column Name | Type | Description |
|-------------|------|-------------|
| Log_ID | INT IDENTITY | Primary key |
| User_ID | VARCHAR(50) | User who performed action |
| Action_Type | VARCHAR(50) | Generate_WF, Refresh_WF, Export_FM, etc. |
| Division | VARCHAR(3) | Division |
| FM_KEY | VARCHAR(20) | FM key |
| Action_Date | DATETIME | Timestamp |
| Details | NVARCHAR(MAX) | Action details (JSON) |
| Success | BIT | Success flag |
| Error_Message | NVARCHAR(500) | Error message if failed |

**Sample Data:**
```sql
Log_ID: 1001
User_ID: demand.planner1
Action_Type: Generate_WF
Division: CPD
FM_KEY: CPD_2025_01
Action_Date: 2025-01-15 09:30:00
Details: {"rows_generated": 750, "duration_seconds": 45}
Success: 1
Error_Message: NULL
```

**Data Change Log:**
```sql
FC_Data_Change_Log
```

**Columns:**
| Column Name | Type | Description |
|-------------|------|-------------|
| Change_ID | INT IDENTITY | Primary key |
| Table_Name | VARCHAR(100) | Table affected |
| Record_ID | INT | Record ID |
| Field_Name | VARCHAR(50) | Field changed |
| Old_Value | NVARCHAR(MAX) | Old value |
| New_Value | NVARCHAR(MAX) | New value |
| Changed_By | VARCHAR(50) | User |
| Changed_Date | DATETIME | Timestamp |

**Trigger Implementation:**
```sql
-- From ntr_FC_FM_Original.sql
CREATE TRIGGER ntr_FC_FM_Original_Update
ON FC_FM_Original
AFTER UPDATE
AS
BEGIN
    INSERT INTO FC_Data_Change_Log (Table_Name, Record_ID, Field_Name, Old_Value, New_Value, Changed_By, Changed_Date)
    SELECT
        'FC_FM_Original',
        d.ID,
        'Quantity',
        CAST(d.Quantity AS NVARCHAR),
        CAST(i.Quantity AS NVARCHAR),
        SYSTEM_USER,
        GETDATE()
    FROM deleted d
    INNER JOIN inserted i ON d.ID = i.ID
    WHERE d.Quantity <> i.Quantity
END
```

---

## 7. Output Type 6: Alerts & Notifications

### 7.1. Alert Types

**Validation Alerts:**

| Alert Type | Severity | Description | Example |
|------------|----------|-------------|---------|
| Row Count Mismatch | ERROR | Excel rows ≠ SQL rows | Excel: 1000, SQL: 995 |
| Missing Required Field | ERROR | Required field is NULL | Sub_Group is NULL |
| Duplicate Record | WARNING | Duplicate key found | Same Sub_Group+Channel+Period |
| Permission Denied | ERROR | User lacks permission | User not allowed to edit |

**Business Logic Alerts:**

| Alert Type | Severity | Description | Threshold |
|------------|----------|-------------|-----------|
| High SLOB Risk | WARNING | Stock coverage > 3 months | SLOB_Risk = HIGH |
| 3M Risk Decline | WARNING | Forecast down >30% vs history | AVE_F3M < AVE_P3M × 0.7 |
| Budget Gap Exceeded | WARNING | Gap > threshold | |BP Gap %| > 20% |
| Stock-out Risk | WARNING | Projected stock < safety | Projected_Stock < Safety_Stock |
| Forecast Accuracy Low | INFO | Accuracy < 90% | Accuracy < 90% |

**System Alerts:**

| Alert Type | Severity | Description |
|------------|----------|-------------|
| Network Path Unavailable | ERROR | Cannot access network share |
| Database Connection Failed | ERROR | Cannot connect to SQL Server |
| File Locked | WARNING | File is locked by another user |
| Version Update Available | INFO | New version of add-in available |

### 7.2. Alert Display

**FrmAlert Form:**

```csharp
// From FrmAlert.cs
public partial class FrmAlert : Form
{
    public void ShowAlert(string alertType, string message, List<string> details)
    {
        lblAlertType.Text = alertType;
        lblMessage.Text = message;

        foreach (string detail in details)
        {
            listBoxDetails.Items.Add(detail);
        }

        // Set icon based on severity
        switch (alertType)
        {
            case "ERROR":
                pictureBoxIcon.Image = Properties.Resources.ErrorIcon;
                this.BackColor = Color.LightCoral;
                break;
            case "WARNING":
                pictureBoxIcon.Image = Properties.Resources.WarningIcon;
                this.BackColor = Color.LightYellow;
                break;
            case "INFO":
                pictureBoxIcon.Image = Properties.Resources.InfoIcon;
                this.BackColor = Color.LightBlue;
                break;
        }

        this.ShowDialog();
    }
}
```

**Sample Alert:**
```
┌─────────────────────────────────────────────────────────┐
│ ⚠️ WARNING: High SLOB Risk Detected                    │
├─────────────────────────────────────────────────────────┤
│                                                          │
│ 12 items have stock coverage > 3 months                │
│                                                          │
│ Details:                                                 │
│ • LOP Old Product A: 7.5 months coverage               │
│ • LOP Old Product B: 5.2 months coverage               │
│ • LOP Old Product C: 4.8 months coverage               │
│ ...                                                      │
│                                                          │
│ Recommended Action:                                     │
│ • Review forecast for these items                       │
│ • Consider clearance promotions                         │
│ • Stop new orders until stock normalizes               │
│                                                          │
│ [ View Details ] [ Ignore ] [ Take Action ]            │
└─────────────────────────────────────────────────────────┘
```

### 7.3. Email Notifications (Optional)

**Configuration:**
```sql
-- Email notification settings
CREATE TABLE FC_Email_Config (
    Config_ID INT IDENTITY PRIMARY KEY,
    Notification_Type VARCHAR(50),
    Recipient_Email VARCHAR(200),
    CC_Email VARCHAR(200),
    Enabled BIT DEFAULT 1
)

-- Sample config
INSERT INTO FC_Email_Config (Notification_Type, Recipient_Email, Enabled)
VALUES
('SLOB_Risk_High', 'inventory.manager@loreal.com', 1),
('Budget_Gap_Alert', 'finance.manager@loreal.com', 1),
('FM_Export_Complete', 'demand.planning@loreal.com', 1)
```

**Email Template:**
```
Subject: [FC Alert] High SLOB Risk - CPD Division

Dear Inventory Manager,

This is an automated alert from the Forecasting Tool.

Alert Type: High SLOB Risk
Division: CPD
FM Key: CPD_2025_01
Date: 2025-01-15

Summary:
12 items have stock coverage > 3 months, indicating slow-moving inventory.

Top Items:
1. LOP Old Product A: 7.5 months (15,000 units SOH)
2. LOP Old Product B: 5.2 months (10,400 units SOH)
3. LOP Old Product C: 4.8 months (9,600 units SOH)

Please review and take appropriate action.

For details, open the WF file: \\...\FC_WORKING_FILE.xlsm

Best regards,
Forecasting Tool (Automated)
```

---

## 8. Output Validation & Quality Checks

### 8.1. Pre-Output Validation

**Checklist before generating outputs:**

```sql
-- Validation stored procedure
CREATE PROCEDURE sp_Validate_Before_Output
    @Division VARCHAR(3),
    @FM_KEY VARCHAR(20)
AS
BEGIN
    DECLARE @ErrorCount INT = 0
    DECLARE @Errors TABLE (Error_Type VARCHAR(100), Error_Message NVARCHAR(500))

    -- Check 1: Total Qty integrity
    INSERT INTO @Errors
    SELECT 'Total_Qty_Mismatch',
           'Sub_Group: ' + Sub_Group + ', Period: ' + CAST(Period AS VARCHAR)
    FROM WF_Master
    WHERE Total_Qty <> (Baseline_Qty + Promo_Qty + Launch_Qty + FOC_Qty)
      AND Division = @Division AND FM_KEY = @FM_KEY

    -- Check 2: O+O integrity
    INSERT INTO @Errors
    SELECT 'OO_Mismatch',
           'Sub_Group: ' + Sub_Group + ', Period: ' + CAST(Period AS VARCHAR)
    FROM V_OO_Validation
    WHERE OO_Qty <> (Online_Qty + Offline_Qty)
      AND Division = @Division AND FM_KEY = @FM_KEY

    -- Check 3: Negative quantities
    INSERT INTO @Errors
    SELECT 'Negative_Qty',
           'Sub_Group: ' + Sub_Group + ', Quantity: ' + CAST(Quantity AS VARCHAR)
    FROM WF_Master
    WHERE Quantity < 0
      AND Division = @Division AND FM_KEY = @FM_KEY

    -- Check 4: Missing Budget data
    INSERT INTO @Errors
    SELECT 'Missing_Budget',
           'Sub_Group: ' + Sub_Group
    FROM WF_Master wf
    LEFT JOIN FC_Budget bdg ON wf.Sub_Group = bdg.Sub_Group
    WHERE bdg.Sub_Group IS NULL
      AND wf.Division = @Division AND wf.FM_KEY = @FM_KEY

    -- Return results
    SELECT @ErrorCount = COUNT(*) FROM @Errors

    IF @ErrorCount > 0
    BEGIN
        SELECT * FROM @Errors
        RAISERROR('Validation failed. %d errors found.', 16, 1, @ErrorCount)
    END
    ELSE
    BEGIN
        PRINT 'Validation passed. Ready to generate outputs.'
    END
END
```

### 8.2. Post-Output Verification

**Verification steps after output generation:**

1. **File Existence Check:**
```csharp
if (!File.Exists(outputPath))
{
    throw new Exception($"Output file not created: {outputPath}");
}
```

2. **File Size Check:**
```csharp
FileInfo fileInfo = new FileInfo(outputPath);
if (fileInfo.Length < 10000) // Less than 10KB
{
    MessageBox.Show("Warning: Output file is suspiciously small. Please verify.");
}
```

3. **Row Count Check:**
```sql
-- Compare row counts
DECLARE @ExcelRows INT = (SELECT COUNT(*) FROM Excel_Import_Temp)
DECLARE @SQLRows INT = (SELECT COUNT(*) FROM WF_Master WHERE FM_KEY = @FM_KEY)

IF @ExcelRows <> @SQLRows
BEGIN
    RAISERROR('Row count mismatch: Excel=%d, SQL=%d', 16, 1, @ExcelRows, @SQLRows)
END
```

4. **Data Integrity Check:**
```sql
-- Sum check (total quantities should match)
DECLARE @WF_Total BIGINT = (SELECT SUM(Quantity) FROM WF_Master WHERE FM_KEY = @FM_KEY AND Time_Series = '6. Total Qty' AND Channel = 'O+O')
DECLARE @FM_Total BIGINT = (SELECT SUM(Y0_M1 + Y0_M2 + ... + Y0_M12) FROM FM_Export)

IF ABS(@WF_Total - @FM_Total) > 100 -- Allow small rounding difference
BEGIN
    RAISERROR('Total quantity mismatch between WF and FM export', 16, 1)
END
```

---

## 9. Output Usage Guide

### 9.1. For Demand Planners

**Working File (WF):**
1. Open FC_WORKING_FILE.xlsm
2. Review historical data (blue columns)
3. Enter forecast in green columns
4. Check alerts (SLOB, 3M Risk, BP Gap)
5. Save and Refresh to update calculations
6. Review BI report for analysis

**Best Practices:**
- ✅ Update forecast monthly
- ✅ Review Budget Gap (target: ±10%)
- ✅ Address SLOB items
- ✅ Document assumptions (use comments)
- ✅ Compare with M-1 forecast

### 9.2. For Finance Team

**Budget vs Forecast Gap:**
1. Open Gap Analysis tool (WinFormsApp2)
2. Review variances > 20%
3. Discuss with demand planners
4. Decide: Update budget or adjust forecast
5. Document decisions

**BI Reports:**
1. Open FC_BI_User_{Division}.xlsm
2. Review YTD performance
3. Check forecast accuracy trends
4. Export summary for management

### 9.3. For Supply Chain

**FM Export:**
1. Receive FM export file from network share
2. Validate data (spot checks)
3. Upload to SAP
4. Verify upload success
5. Run MRP

**Stock Analysis:**
1. Review SLOB report from WF
2. Identify slow-moving items
3. Plan clearance actions
4. Monitor stock coverage

### 9.4. For Management

**BI Dashboards:**
1. Review summary KPIs
2. Check Budget vs Forecast trends
3. Monitor channel performance
4. Identify risks and opportunities

**Monthly Reports:**
1. YTD performance summary
2. Budget gap analysis
3. Forecast accuracy metrics
4. Risk items (SLOB, Stock-out)

---

## 10. Output Archival & Retention

### 10.1. Archival Policy

**FM Exports:**
- Retention: Permanent (all FM exports kept indefinitely)
- Location: `...\FM_Template_Upload\Archive\{Year}\{Month}\`
- Naming: `{Division}_FM_{FMKEY}_archived_{YYYYMMDD}.xlsx`

**Working Files:**
- Retention: Last 12 months in active folder, older moved to archive
- Location: `...\WF_Archive\{Year}\`
- Naming: `FC_WORKING_FILE_{Division}_{FMKEY}_archived.xlsm`

**Database Tables:**
- FM Tables: Keep all (FC_FM_History table)
- BOM Tables: Keep all
- Audit Logs: Keep 3 years, then archive to separate database

### 10.2. Backup Schedule

**Daily Backups:**
- SQL Server database (full backup)
- Network share (incremental backup)

**Weekly Backups:**
- Excel files
- Application binaries

**Monthly Backups:**
- Full system backup (database + files + applications)
- Offsite backup copy

---

**Document Version:** 1.0
**Last Updated:** 2025-11-18
**Maintained by:** Technical Team
