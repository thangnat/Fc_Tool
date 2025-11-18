# Fc_Tool - Forecasting Tool for L'Oréal Vietnam

## 📋 Mục Lục
- [Tổng Quan Dự Án](#-tổng-quan-dự-án)
- [Tính Năng Chính](#-tính-năng-chính)
- [Công Nghệ Sử Dụng](#-công-nghệ-sử-dụng)
- [Yêu Cầu Hệ Thống](#-yêu-cầu-hệ-thống)
- [Cấu Trúc Dự Án](#-cấu-trúc-dự-án)
- [Cài Đặt và Triển Khai](#-cài-đặt-và-triển-khai)
- [Cấu Trúc Database](#-cấu-trúc-database)
- [Hướng Dẫn Phát Triển](#-hướng-dẫn-phát-triển)
- [Các Module Chính](#-các-module-chính)
- [Troubleshooting](#-troubleshooting)

---

## 🎯 Tổng Quan Dự Án

**Fc_Tool (Forecasting Tool)** là một giải pháp dự báo bán hàng và lập kế hoạch nhu cầu (Demand Planning) được phát triển đặc biệt cho L'Oréal Việt Nam. Công cụ này tích hợp chặt chẽ với Microsoft Excel thông qua VSTO Add-in, cung cấp giao diện thân thiện và quy trình làm việc tự động hóa cho các hoạt động:

- 📊 **Dự báo bán hàng** (Sales Forecasting)
- 📦 **Quản lý BOM** (Bill of Materials)
- 💰 **Lập kế hoạch ngân sách** (Budget Planning)
- 📈 **Phân tích lịch sử** (Historical Data Analysis)
- 🔍 **Kiểm tra và validation dữ liệu**

### Đối tượng sử dụng
- **Demand Planning Team** - L'Oréal Vietnam
- **Budget Planning Team**
- **Sales Analytics Team**
- Các phòng ban liên quan đến dự báo và kế hoạch sản phẩm

### Divisions được hỗ trợ
- **CPD** - Consumer Products Division
- **LDB** - Luxury Division Brand
- **PPD** - Professional Products Division

---

## ✨ Tính Năng Chính

### 1. 📊 Excel Add-in (EXCEL_ADDINS)

#### Quản lý Dự báo (Forecasting Management)
- ✅ Tạo và quản lý **Working Files (WF)** theo từng division
- ✅ Sinh dự báo cho nhiều loại:
  - **Historical** - Dữ liệu lịch sử
  - **Forecast (FC)** - Dự báo chính
  - **M-1** - Dự báo tháng trước
  - **Budget** - Ngân sách
  - **Pre-Budget** - Ngân sách sơ bộ
  - **Trend** - Xu hướng
- ✅ Re-generate partial Working File
- ✅ Điều chỉnh dữ liệu theo period

#### Quản lý BOM (Bill of Materials)
- ✅ **Adjust BOM Header** - Điều chỉnh BOM header
- ✅ **Component BOM** - Quản lý component BOM
- ✅ **Forecast BOM Headers** - Dự báo BOM headers
- ✅ Tích hợp với master data từ Spectrum

#### Import/Export Dữ liệu
- ✅ **Import Historical Data** từ nhiều nguồn khác nhau
- ✅ **Export FM (Forecast Model)** ra Excel templates
- ✅ **Export Full FM** với đầy đủ thông tin
- ✅ Đồng bộ dữ liệu giữa SQL Server và MS Access
- ✅ Link với Spectrum master data

#### Kiểm tra và Validation
- ✅ **Mismatch Detection** - Phát hiện dữ liệu không khớp
- ✅ **Error Alerts** sau các process
- ✅ **Budget vs Forecast Gap Analysis**
- ✅ Validation rules cho data integrity

#### Giao diện và UX
- ✅ **Custom Excel Ribbon** với các công cụ chuyên dụng
- ✅ **Task Pane** để truy cập nhanh các chức năng
- ✅ **Filter capabilities** - Lọc dữ liệu theo nhiều tiêu chí
- ✅ **Show/Hide Forecast Lines** - Ẩn/hiện các dòng dự báo
- ✅ **Formula Bar Control**
- ✅ **BI File Review** - Xem lại các file BI

#### Quản lý Người dùng
- ✅ **User Authentication** - Xác thực người dùng
- ✅ **Role-based Permissions** - Phân quyền theo vai trò
- ✅ **Division-based Access Control** - Phân quyền theo division
- ✅ **Password Management** - Quản lý mật khẩu
- ✅ **User Action Logging** - Ghi log hành động

#### Version Control & Updates
- ✅ **Auto-update Version Checking**
- ✅ **Update Notification System**
- ✅ ClickOnce deployment
- ✅ Version: ver1000017 (Build 1.0.0.97)

### 2. 🖥️ Windows Forms Application (WinFormsApp2)

#### So sánh và Phân tích
- ✅ **BP vs DP Comparison** - So sánh Budget Planning vs Demand Planning
- ✅ **Gap Analysis** với DevExpress grid controls
- ✅ **Advanced Data Visualization**
- ✅ Highlight differences và discrepancies

#### Báo cáo (Reporting)
- ✅ **Generate Reports** - Tạo nhiều loại báo cáo
- ✅ **Data Export** - Export dữ liệu ra nhiều format
- ✅ **Custom Report Templates**

---

## 💻 Công Nghệ Sử Dụng

### Ngôn Ngữ Lập Trình
| Ngôn ngữ | Mục đích |
|----------|----------|
| **C#** | Ngôn ngữ chính cho business logic |
| **VB.NET** | Một số module legacy |
| **T-SQL** | Database stored procedures, functions, views |
| **VBA** | Excel macros (nếu có) |

### Frameworks & Libraries

#### .NET Framework
- **.NET Framework 4.7.2** - Excel Add-in project
- **.NET 6.0 Windows** - WinForms standalone app

#### Office Integration
- **VSTO (Visual Studio Tools for Office)** - Excel Add-in framework
- **Microsoft.Office.Interop.Excel 15.0** - Excel automation
- **Microsoft.Office.Core** - Office COM interop

#### UI Components
- **Windows Forms** - Desktop UI framework
- **DevExpress v22.1.3** - Advanced grid controls và UI components
- **SpreadsheetGear v9.2.59** - Excel file manipulation

#### Database
- **SQL Server** - Main database backend
- **System.Data.SqlClient** - SQL Server connectivity
- **Microsoft Access DAO 15.0** - Local database operations
- **Provider: Microsoft.ACE.OLEDB.12.0** - Access database engine

#### Other Libraries
- **System.Data.Linq** - LINQ to SQL
- **UIAutomationClient** - UI automation
- **Xamarin.FFImageLoading.Transformations** - Image processing

---

## 🔧 Yêu Cầu Hệ Thống

### Phần Mềm Cần Thiết
- **Operating System:** Windows 10 hoặc Windows 11 (64-bit)
- **Microsoft Office:** Excel 2013 trở lên (khuyến nghị Excel 2016+)
- **Microsoft .NET Framework:** 4.7.2 trở lên
- **.NET 6.0 Runtime** - Cho WinFormsApp2
- **Visual Studio 2010 Tools for Office Runtime** (VSTO Runtime)
- **SQL Server:** 2012 trở lên (hoặc kết nối đến SQL Server instance)
- **Microsoft Access Database Engine** (ACE OLEDB 12.0)

### Phần Cứng Khuyến Nghị
- **CPU:** Intel Core i5 hoặc tương đương
- **RAM:** Tối thiểu 8GB (khuyến nghị 16GB)
- **Disk Space:** 500MB cho application + database
- **Display:** 1920x1080 hoặc cao hơn

### Quyền Truy Cập
- Quyền cài đặt Excel Add-in
- Quyền kết nối SQL Server
- Quyền đọc/ghi Access database
- Network access đến SQL Server

---

## 📁 Cấu Trúc Dự Án

```
Fc_Tool/
│
├── 📂 EXCEL_ADDINS/                    # Excel Add-in Application (Main Project)
│   ├── EXCEL_ADDINS.sln               # Visual Studio Solution
│   └── EXCEL_ADDINS/
│       ├── 📂 Connection/             # Database Connection Layer
│       │   ├── Connection_SQL.cs      # SQL Server connection & operations
│       │   └── Connection_Access.cs   # MS Access connection & operations
│       │
│       ├── 📂 C#/                     # C# Components
│       │   └── iGrid Starter Sample.cs
│       │
│       ├── 📂 VB/                     # VB.NET Components (if any)
│       │
│       ├── 📂 Image/                  # UI Resources (Icons, Images)
│       │   ├── excel 64x64.png
│       │   ├── Login_32x32.png
│       │   ├── Update64x64.png
│       │   └── ... (various icons)
│       │
│       ├── 📂 Properties/             # Project Properties
│       │   ├── AssemblyInfo.cs
│       │   ├── Resources.resx
│       │   └── Settings.settings
│       │
│       ├── 📂 bin/Debug/              # Build Output
│       │   ├── FC_SysData.mdb         # Local Access Database
│       │   └── Extension/H2T.ini
│       │
│       ├── 📄 Core Files
│       │   ├── ThisAddIn.cs           # Add-in Entry Point
│       │   ├── Ribbon1.cs             # Excel Ribbon Customization
│       │   ├── UTaskPane.cs           # Custom Task Pane UI
│       │   ├── Program.cs             # Program Configuration
│       │   ├── Cls_Main.cs            # Main Business Logic
│       │   ├── Cls_BaseSys.cs         # System Base Classes
│       │   ├── cls_function.cs        # Utility Functions
│       │   ├── New_sp.cs              # Stored Procedure Wrapper
│       │   └── Function.cs            # General Functions
│       │
│       ├── 📄 Forms (Windows Forms)
│       │   ├── FrmAdjustBomHeader.cs
│       │   ├── FrmComponentBom.cs
│       │   ├── FrmExportFM.cs
│       │   ├── FrmExportFMFull.cs
│       │   ├── FrmFilter.cs
│       │   ├── FrmAlert.cs
│       │   ├── FrmProcessing.cs
│       │   ├── FrmRe_GenPartial_WF.cs
│       │   ├── FrmUpdate_Version.cs
│       │   ├── Frm_Add_New.cs
│       │   ├── Frm_ChangePassword.cs
│       │   └── frm_PeriodKey.cs
│       │
│       ├── 📄 Supporting Classes
│       │   ├── Info.cs
│       │   ├── mod_BaseSys.cs
│       │   ├── KeyboardHooking.cs
│       │   ├── SingleInstance.cs
│       │   ├── User32API.cs
│       │   └── ZZVISIBLE_FROM_EXCEL_CLASS.cs
│       │
│       └── 📄 Configuration Files
│           ├── app.config
│           ├── packages.config
│           ├── EXCEL_ADDINS_2_TemporaryKey.pfx
│           └── ThisAddIn.Designer.xml
│
├── 📂 WinFormsApp2/                   # Standalone Windows Forms Application
│   ├── WinFormsApp2.sln              # Visual Studio Solution (.NET 6.0)
│   └── WinFormsApp2/
│       ├── 📂 Connection/            # Database Connection
│       │   ├── Connection_SQL.cs
│       │   └── Connection_Access.cs
│       │
│       ├── 📂 Image/                 # UI Resources
│       │
│       ├── 📂 Properties/            # Project Properties
│       │   └── Resources.resx
│       │
│       ├── 📄 Main Forms
│       │   ├── Program.cs            # Application Entry Point
│       │   ├── Frm_Devexpress_Gridcontrol.cs  # BP vs DP Comparison
│       │   ├── FrmReport.cs          # Reporting Module
│       │   └── GridControl.cs        # Grid Components
│       │
│       └── 📄 Configuration
│           └── WinFormsApp2.csproj   # Project File (.NET 6.0)
│
├── 📂 Script/                         # Database Scripts (458 files total)
│   └── 📂 1. FINAL/                  # Production Scripts
│       ├── 📂 0. link_37/            # Import Stored Procedures
│       │   └── sp_importHistorical_*.sql
│       │
│       ├── 📂 1. Action/             # Action Scripts
│       │   ├── 📂 DEV/              # Development Scripts
│       │   ├── 📂 HIS/              # Historical Data Scripts
│       │   └── 📂 MisMatch/         # Data Validation Scripts
│       │
│       ├── 📂 2. Sp_View/           # Stored Procedures & Views
│       │   └── sp_*.sql, v_*.sql
│       │
│       ├── 📂 3. Function/          # SQL Functions
│       │   └── fn_*.sql
│       │
│       ├── 📂 4. View/              # Database Views
│       │   └── v_*.sql
│       │
│       └── 📂 5. Trigger/           # Database Triggers
│           └── tr_*.sql
│
└── 📄 README.md                      # This file

```

---

## 🚀 Cài Đặt và Triển Khai

### A. Cài Đặt SQL Server Database

#### Bước 1: Tạo Database
```sql
CREATE DATABASE FC_Database
GO

USE FC_Database
GO
```

#### Bước 2: Chạy Scripts theo thứ tự
```bash
# 1. Functions
Script/1. FINAL/3. Function/*.sql

# 2. Views
Script/1. FINAL/4. View/*.sql

# 3. Stored Procedures
Script/1. FINAL/2. Sp_View/*.sql

# 4. Triggers
Script/1. FINAL/5. Trigger/*.sql

# 5. Import Procedures
Script/1. FINAL/0. link_37/*.sql

# 6. Action Scripts (nếu cần)
Script/1. FINAL/1. Action/**/*.sql
```

#### Bước 3: Cấu hình Connection String
Cập nhật connection string trong các file config để trỏ đến SQL Server instance của bạn.

### B. Cài Đặt Excel Add-in (EXCEL_ADDINS)

#### Bước 1: Prerequisites
1. Cài đặt **.NET Framework 4.7.2** trở lên
2. Cài đặt **Visual Studio 2010 Tools for Office Runtime**
3. Cài đặt **Microsoft Office Excel** (2013 trở lên)

#### Bước 2: Build Project
```bash
# Mở Visual Studio
1. Mở solution: EXCEL_ADDINS/EXCEL_ADDINS.sln
2. Chọn Configuration: Release | AnyCPU
3. Build > Build Solution (Ctrl+Shift+B)
```

#### Bước 3: Deploy (ClickOnce)
```bash
# Publish Add-in
1. Right-click project > Publish
2. Publish Location: C:\Users\Public\Downloads\Application\FC\
3. Installation URL: (nếu deploy qua network)
4. Click "Finish" để publish
```

#### Bước 4: Cài Đặt trên Client
```bash
1. Truy cập: C:\Users\Public\Downloads\Application\FC\
2. Chạy file: setup.exe
3. Follow wizard để install
4. Excel sẽ tự động load add-in sau khi cài đặt
```

#### Bước 5: Verify Installation
1. Mở Excel
2. Kiểm tra tab **"FORECASTING TOOL"** hoặc tương tự trên Ribbon
3. Kiểm tra Task Pane xuất hiện bên phải
4. Login với credentials

### C. Cài Đặt WinFormsApp2

#### Bước 1: Prerequisites
1. Cài đặt **.NET 6.0 Desktop Runtime**
   ```bash
   # Download từ: https://dotnet.microsoft.com/download/dotnet/6.0
   ```

2. Cài đặt **DevExpress v22.1.3** (nếu chưa có license)

#### Bước 2: Build Project
```bash
# Mở Visual Studio 2022
1. Mở solution: WinFormsApp2/WinFormsApp2.sln
2. Restore NuGet packages
3. Build > Build Solution
```

#### Bước 3: Deploy
```bash
# Publish as Self-Contained
dotnet publish -c Release -r win-x64 --self-contained true

# Output sẽ ở: WinFormsApp2/bin/Release/net6.0-windows/win-x64/publish/
```

#### Bước 4: Distribute
Copy toàn bộ folder `publish/` đến máy client và chạy `WinFormsApp2.exe`

### D. Cấu Hình Access Database

#### FC_SysData.mdb
File Access database này được sử dụng như một cache/temporary storage.

**Location:** `EXCEL_ADDINS/bin/Debug/FC_SysData.mdb`

**Connection String:**
```
Provider=Microsoft.ACE.OLEDB.12.0;
Data Source=C:\Path\To\FC_SysData.mdb;
Jet OLEDB:Database Password=123
```

**Note:** Password của database là `123` (cân nhắc đổi trong production)

---

## 🗄️ Cấu Trúc Database

### SQL Server Tables (Ví dụ chính)

#### Master Data Tables
```sql
-- Product Master
tbl_Product_Master
  - ProductCode
  - ProductName
  - Division (CPD/LDB/PPD)
  - Category
  - ...

-- BOM Tables
tbl_BOM_Header
tbl_BOM_Component
tbl_Forecast_BOM_Header

-- User Management
tbl_Users
  - UserID
  - Username
  - Password (encrypted)
  - Division
  - Role
  - ...
```

#### Forecast Tables
```sql
-- Working Files
tbl_Working_File
  - WF_ID
  - Division
  - Period
  - Version
  - CreatedBy
  - CreatedDate
  - ...

-- Forecast Data
tbl_Forecast_Data
  - FC_ID
  - WF_ID
  - ProductCode
  - Period
  - Quantity
  - Type (Historical/Forecast/Budget/...)
  - ...

-- Historical Data
tbl_Historical_Data
```

### Stored Procedures (Ví dụ)

```sql
-- Import Operations
sp_importHistorical_CPD
sp_importHistorical_LDB
sp_importHistorical_PPD

-- Forecast Operations
sp_GenerateWorkingFile
sp_CalculateForecast
sp_ValidateData

-- BOM Operations
sp_AdjustBOMHeader
sp_UpdateComponentBOM

-- Validation
sp_CheckMismatch
sp_GapAnalysis
```

### Views (Ví dụ)

```sql
-- Reporting Views
v_Forecast_Summary
v_BOM_Details
v_Gap_Analysis
v_User_Actions

-- Encrypted Views (for security)
CREATE VIEW v_Sensitive_Data
WITH ENCRYPTION
AS
  SELECT ...
```

### Functions (Ví dụ)

```sql
fn_GetForecastByPeriod(@Period, @Division)
fn_CalculateGap(@Budget, @Forecast)
fn_ValidateProductCode(@ProductCode)
```

---

## 👨‍💻 Hướng Dẫn Phát Triển

### Clone Repository
```bash
git clone <repository-url>
cd Fc_Tool
```

### Setup Development Environment

#### Excel Add-in Development
```bash
# Requirements
- Visual Studio 2019/2022
- Office Developer Tools
- .NET Framework 4.7.2 SDK

# Open Solution
1. Open: EXCEL_ADDINS/EXCEL_ADDINS.sln
2. Set configuration: Debug | x64
3. F5 to run (Excel will launch automatically)
```

#### WinForms App Development
```bash
# Requirements
- Visual Studio 2022
- .NET 6.0 SDK
- DevExpress license (or trial)

# Open Solution
1. Open: WinFormsApp2/WinFormsApp2.sln
2. Restore NuGet packages
3. F5 to run
```

### Coding Standards

#### Naming Conventions
```csharp
// Classes: PascalCase
public class ConnectionSQL { }

// Methods: PascalCase
public void GenerateWorkingFile() { }

// Variables: camelCase
string productCode = "ABC123";

// Constants: UPPER_CASE
const string DEFAULT_DIVISION = "CPD";

// Private fields: _camelCase
private string _userName;

// Forms: Frm + PascalCase
public class FrmAdjustBomHeader : Form { }

// Stored Procedures: sp_ prefix
sp_GenerateWorkingFile

// Views: v_ prefix
v_Forecast_Summary

// Functions: fn_ prefix
fn_GetForecastByPeriod
```

#### Comments
```csharp
// Tiếng Việt OK cho business logic comments
// English OK cho technical comments

/// <summary>
/// Tạo Working File cho division được chọn
/// </summary>
/// <param name="division">CPD, LDB, hoặc PPD</param>
/// <returns>WF_ID của Working File mới tạo</returns>
public int GenerateWorkingFile(string division)
{
    // Implementation...
}
```

### Database Changes

#### Adding New Stored Procedure
```bash
1. Tạo file: Script/1. FINAL/2. Sp_View/sp_YourProcedureName.sql
2. Test trên DEV database
3. Update documentation
4. Commit cả script file
```

#### Adding New Table
```sql
-- 1. Create table script
CREATE TABLE tbl_NewTable (
    ID INT PRIMARY KEY IDENTITY(1,1),
    ...
)

-- 2. Add to version control
-- 3. Update database diagram (if any)
```

### Build and Test

#### Unit Testing (nếu có)
```bash
# Run tests
dotnet test

# With coverage
dotnet test /p:CollectCoverage=true
```

#### Manual Testing Checklist
- [ ] Login functionality
- [ ] Create Working File
- [ ] Import Historical Data
- [ ] Generate Forecast
- [ ] Export FM
- [ ] BOM adjustments
- [ ] Validation rules
- [ ] User permissions
- [ ] Auto-update version check

---

## 🧩 Các Module Chính

### 1. Connection Layer

#### Connection_SQL.cs
```csharp
// Handles SQL Server connections
- ExecuteQuery()
- ExecuteNonQuery()
- ExecuteScalar()
- BulkInsert()
- Transaction handling
```

#### Connection_Access.cs
```csharp
// Handles MS Access connections
- LocalDataSync()
- TemporaryStorage()
- CacheManagement()
```

### 2. Business Logic Layer

#### Cls_Main.cs
```csharp
// Core business operations
- Forecast generation
- Data validation
- BOM management
```

#### Cls_BaseSys.cs
```csharp
// System base functionality
- Logging
- Error handling
- Common utilities
```

### 3. UI Layer

#### Ribbon1.cs
```csharp
// Excel Ribbon customization
- Button click handlers
- Menu items
- Ribbon state management
```

#### UTaskPane.cs
```csharp
// Custom Task Pane
- Quick access buttons
- User info display
- Shortcuts
```

#### Forms (Frm_*.cs)
```csharp
// Windows Forms dialogs
- Data entry
- Configuration
- Reports
- Alerts
```

### 4. Data Access Layer

#### New_sp.cs
```csharp
// Stored Procedure wrapper
- Call stored procedures
- Parameter mapping
- Result handling
```

### 5. Utility Layer

#### cls_function.cs
```csharp
// Utility functions
- Date formatting
- String manipulation
- Data conversion
- Excel helpers
```

---

## 🛠️ Troubleshooting

### Common Issues

#### 1. Add-in không load trong Excel
**Triệu chứng:** Excel mở nhưng không thấy Ribbon tab của Fc_Tool

**Giải pháp:**
```bash
1. Kiểm tra Excel Trust Center Settings:
   File > Options > Trust Center > Trust Center Settings
   > Add-ins > Uncheck "Require Application Add-ins..."

2. Kiểm tra Disabled Items:
   File > Options > Add-ins > Manage: Disabled Items > Go
   > Enable EXCEL_ADDINS nếu có

3. Kiểm tra COM Add-ins:
   File > Options > Add-ins > Manage: COM Add-ins > Go
   > Check EXCEL_ADDINS

4. Repair installation:
   Control Panel > Programs > Forecasting Tool > Repair
```

#### 2. Lỗi kết nối SQL Server
**Triệu chứng:** "Cannot connect to SQL Server"

**Giải pháp:**
```bash
1. Kiểm tra SQL Server đang chạy:
   Services > SQL Server (instance name) > Running

2. Kiểm tra connection string trong app.config

3. Test connection:
   - SQL Server Management Studio
   - telnet <server> 1433

4. Kiểm tra firewall:
   - Port 1433 open
   - SQL Server Browser service running
```

#### 3. Access Database locked
**Triệu chứng:** "Could not use 'FC_SysData.mdb'; file already in use"

**Giải pháp:**
```bash
1. Đóng tất cả Excel instances
2. Delete file: FC_SysData.ldb (lock file)
3. Restart Excel
4. Kiểm tra permissions trên FC_SysData.mdb
```

#### 4. DevExpress licensing error (WinFormsApp2)
**Triệu chứng:** "DevExpress license not found"

**Giải pháp:**
```bash
1. Install DevExpress v22.1.3 với valid license
2. Rebuild solution
3. Hoặc remove DevExpress dependency nếu không cần
```

#### 5. Version mismatch
**Triệu chứng:** "Your version is outdated. Please update."

**Giải pháp:**
```bash
1. Uninstall current version:
   Control Panel > Programs > EXCEL_ADDINS > Uninstall

2. Download latest version từ:
   C:\Users\Public\Downloads\Application\FC\

3. Run setup.exe để cài đặt version mới
```

#### 6. Stored Procedure not found
**Triệu chứng:** "Could not find stored procedure 'sp_XXX'"

**Giải pháp:**
```sql
-- 1. Kiểm tra SP tồn tại
SELECT * FROM sys.procedures WHERE name = 'sp_XXX'

-- 2. Nếu không có, chạy script tương ứng từ:
Script/1. FINAL/2. Sp_View/sp_XXX.sql

-- 3. Refresh connection trong application
```

### Debug Mode

#### Enable Debug Logging
```csharp
// Trong app.config hoặc code
#if DEBUG
    LogLevel = LogLevel.Debug;
#endif
```

#### View Logs
```bash
Location: %APPDATA%\EXCEL_ADDINS\Logs\
Files: FC_Log_YYYYMMDD.txt
```

### Performance Issues

#### Excel lúc tăng
```bash
1. Giảm số rows hiển thị
2. Disable automatic calculation:
   Formulas > Calculation Options > Manual
3. Close unused workbooks
4. Increase Excel memory limit (if needed)
```

#### Database slow queries
```sql
-- Enable execution plan
SET SHOWPLAN_ALL ON

-- Check indexes
EXEC sp_helpindex 'table_name'

-- Rebuild indexes
ALTER INDEX ALL ON table_name REBUILD
```

---

## 📞 Hỗ Trợ và Liên Hệ

### Development Team
- **Publisher:** Forecasting Tool Team
- **Organization:** L'Oréal Vietnam

### Reporting Issues
```bash
# Log files location
%APPDATA%\EXCEL_ADDINS\Logs\

# Include in bug report:
1. Error message
2. Steps to reproduce
3. Screenshot
4. Log files
5. Excel version
6. Windows version
```

---

## 📝 Notes

### Security Considerations
- **Database Password:** Default Access DB password là `123` - NÊN ĐỔI trong production
- **SQL Injection:** Tất cả queries sử dụng parameterized commands
- **User Passwords:** Được encrypt trước khi lưu database
- **Connection Strings:** Không hardcode trong code, dùng config files

### Version History
```
Version 1.0.0.97 (Current)
- Initial release with core forecasting features
- Support for CPD, LDB, PPD divisions
- BOM management
- Budget vs Forecast gap analysis
```

### Future Enhancements
- [ ] Web-based interface (ASP.NET Core)
- [ ] Real-time collaboration
- [ ] Mobile app for approval workflows
- [ ] Advanced analytics with Power BI integration
- [ ] Machine learning forecast suggestions
- [ ] REST API for integration with other systems

---

## 📄 License

Proprietary software developed for L'Oréal Vietnam.
All rights reserved.

---

## 🙏 Acknowledgments

Developed specifically for L'Oréal Vietnam Demand Planning Team.

---

**Last Updated:** 2025-11-18
**Maintained By:** Forecasting Tool Development Team
