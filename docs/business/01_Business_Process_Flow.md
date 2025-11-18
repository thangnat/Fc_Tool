# Quy Trình Tạo Working File - Business Process Flow

## 📌 Giới Thiệu

Tài liệu này mô tả quy trình tạo Working File (WF) trong hệ thống Forecasting Tool của L'Oréal Vietnam. Đây là quy trình tự động hóa chính để tạo ra file dự báo hàng tháng cho các bộ phận Demand Planning.

**Đối tượng:** Demand Planning Team, Budget Planning Team, Sales Analytics Team
**Tần suất:** Hàng tháng, theo chu kỳ dự báo
**Thời gian thực hiện:** 15-45 phút tùy theo Division và khối lượng dữ liệu

---

## 🎯 Mục Đích Chính

Tạo một Working File hoàn chỉnh bao gồm:
- ✅ Dự báo baseline dựa trên lịch sử
- ✅ Dữ liệu Budget và Pre-Budget
- ✅ Kế hoạch sản phẩm mới (New Launch)
- ✅ Kế hoạch khuyến mãi (Promo)
- ✅ Sản phẩm tặng kèm (FOC - Free of Charge)
- ✅ Tồn kho hiện tại (SOH)
- ✅ Hàng đang trên đường (GIT)
- ✅ Dữ liệu Sell-Out từ OPTIMUS

---

## 📋 Điều Kiện Tiên Quyết

Trước khi chạy quy trình tạo Working File, cần đảm bảo:

### 1. Period Status (Trạng thái kỳ dự báo)
- Kỳ dự báo phải được mở cho Division tương ứng
- Ví dụ: Muốn tạo WF cho CPD tháng 202502 → Period 202502 phải có `[Open CPD] = 1`

### 2. Historical Data (Dữ liệu lịch sử)
- Dữ liệu actual từ SAP đã được import
- Dữ liệu Sell-In lịch sử đầy đủ cho ít nhất 24 tháng

### 3. Master Data (Dữ liệu chính)
- Product Master đã được cập nhật
- BOM structures đã được định nghĩa
- Category và Brand mapping đã được thiết lập

### 4. Configuration (Cấu hình)
- Các bảng cấu hình đã được setup đúng
- Function activation đã được config

---

## 🔄 Tổng Quan Quy Trình

```
┌─────────────────────────────────────────────────────────────┐
│                     BẮT ĐẦU QUY TRÌNH                       │
│              Tạo Working File cho Division                  │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│  GIAI ĐOẠN 1: Kiểm Tra & Khởi Tạo                          │
│  • Kiểm tra period có mở không?                             │
│  • Backup WF cũ (nếu có)                                    │
│  • Tạo bảng theo dõi trạng thái                             │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│  GIAI ĐOẠN 2: Chuẩn Bị Dữ Liệu Master                      │
│  • Khởi tạo BFL Master (danh sách sản phẩm)                 │
│  • Tạo baseline forecast từ lịch sử                         │
│  • Xử lý sản phẩm non-modeling                              │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│  GIAI ĐOẠN 3: Tạo Working File Chính                       │
│  • Tạo bảng FC_FM_Original_{Division}_{YYYYMM}             │
│  • Consolidate tất cả dữ liệu baseline                      │
│  • Setup cấu trúc các cột tháng                             │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│  GIAI ĐOẠN 4: Tích Hợp Sell-Out                            │
│  • Import forecast Sell-Out từ OPTIMUS                      │
│  • Tạo BOM headers cho Sell-Out                             │
│  • Tính toán GIT (Goods-In-Transit)                         │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│  GIAI ĐOẠN 5: Cập Nhật Tồn Kho & Lịch Sử                   │
│  • Cập nhật SOH (Stock-On-Hand) hiện tại                    │
│  • Cập nhật MTD SI (Month-To-Date Sell-In)                  │
│  • Cập nhật 24 tháng actual từ SAP                          │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│  GIAI ĐOẠN 6: Import Forecast từ FM                        │
│  • Promo Single (khuyến mãi sản phẩm đơn)                   │
│  • New Launch (sản phẩm mới ra mắt)                         │
│  • FOC (sản phẩm tặng kèm)                                  │
│  • Promo BOM Component (combo khuyến mãi)                   │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│  GIAI ĐOẠN 7: Tích Hợp Budget                              │
│  • Budget (ngân sách chính thức)                            │
│  • Pre-Budget (ngân sách sơ bộ)                             │
│  • Budget Trend (xu hướng ngân sách)                        │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│  GIAI ĐOẠN 8: Tính Toán Sell-In                            │
│  • Tính Sell-In cho Promo Single                            │
│  • Tính Sell-In từ Sell-Out OPTIMUS                         │
│  • Tính Sell-In cho FOC                                     │
│  • Tính Sell-In cho New Launch                              │
│  • Tính Sell-In cho Promo BOM                               │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│  GIAI ĐOẠN 9: Tạo Final Working File                       │
│  • Tạo cấu trúc WF lần đầu                                  │
│  • Build WF đầy đủ với tất cả dữ liệu                       │
│  • Tạo bảng phụ (FC_MCSI - Multi-Channel)                   │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│  GIAI ĐOẠN 10: Tính Toán Bổ Sung                           │
│  • Đánh giá Risk 3 tháng                                    │
│  • Cập nhật SLOB (Slow & Obsolete)                          │
│  • Finalize dữ liệu 24 tháng lịch sử                        │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│  GIAI ĐOẠN 11: Tính Tổng Cuối Cùng                         │
│  • Tính tổng theo hàng (sum across months)                  │
│  • Tính tổng theo cột (sum across products)                 │
│  • Validate tính toán                                       │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                 HOÀN TẤT - WORKING FILE                     │
│              Sẵn sàng export sang Excel                     │
└─────────────────────────────────────────────────────────────┘
```

---

## 📊 Chi Tiết Các Bước Xử Lý

### GIAI ĐOẠN 1: Kiểm Tra & Khởi Tạo

#### Bước 0: Kiểm Tra Period Status
**Mục đích:** Đảm bảo period được phép tạo forecast

**Thực hiện:**
- Hệ thống kiểm tra bảng cấu hình Period
- Xác nhận flag "Open" cho Division tương ứng
- Nếu Period bị khóa → Dừng quy trình và báo lỗi

**Ví dụ:**
```
Division: CPD
Period: 202502
Check: [Open CPD] = 1?
→ Nếu YES: Tiếp tục
→ Nếu NO: "Period 202502 had been blocked for CPD"
```

---

### GIAI ĐOẠN 2: Chuẩn Bị Dữ Liệu Master

#### Bước 1: Khởi Tạo BFL Master
**Tên nghiệp vụ:** Add BFL Master
**Tag:** `tag_add_BFL_Master`

**Mục đích:** Tạo danh sách sản phẩm cơ bản cần dự báo

**Dữ liệu đầu vào:**
- Product Master (danh sách sản phẩm)
- Category & Brand mapping
- Division assignment

**Xử lý:**
1. Lấy tất cả sản phẩm active của Division
2. Gán category, brand, product hierarchy
3. Tạo bảng BFL Master với cấu trúc chuẩn

**Kết quả:**
- Bảng `FC_BFL_Master` được tạo/cập nhật
- Là foundation cho tất cả các bước tiếp theo

---

#### Bước 2: Tạo Baseline Forecast
**Tên nghiệp vụ:** Generate Baseline Sell-In
**Tag:** `tag_gen_FM_FC_SI_BASELINE`

**Mục đích:** Tạo dự báo cơ bản dựa trên lịch sử bán hàng

**Dữ liệu đầu vào:**
- Dữ liệu Sell-In lịch sử (6-24 tháng)
- Historical actuals từ SAP
- Trend analysis data

**Xử lý:**
1. **Phân tích xu hướng:**
   - Tính average của 3/6/12 tháng gần nhất
   - Xác định growth trend
   - Điều chỉnh theo mùa vụ (seasonality)

2. **Tính baseline:**
   - Áp dụng statistical model
   - Adjust theo trend
   - Tạo forecast cho từng tháng

3. **Output:**
   - Baseline forecast cho 18 tháng tới
   - Phân bổ theo product/month

**Ví dụ minh họa:**
```
Sản phẩm: Shampoo ABC
Lịch sử 6 tháng: [100, 105, 110, 108, 112, 115] units
Average: 108 units
Growth trend: +2% per month
→ Baseline M+1: 115 * 1.02 = 117 units
→ Baseline M+2: 117 * 1.02 = 119 units
```

---

#### Bước 3: Xử Lý Non-Modeling Products
**Tên nghiệp vụ:** Generate FM Non-Modeling
**Tag:** `tag_gen_fm_non_modeling`

**Mục đích:** Xử lý sản phẩm không phù hợp với statistical model

**Dữ liệu đầu vào:**
- Sản phẩm được đánh dấu "non-modeling"
- Manual forecast input (nếu có)
- Last month actual

**Các loại Non-Modeling:**
1. **Sản phẩm mới:** Chưa đủ lịch sử
2. **Sản phẩm discontinue:** Sắp ngừng kinh doanh
3. **Sản phẩm seasonal:** Chỉ bán vào mùa cụ thể
4. **Sản phẩm project-based:** Theo dự án riêng

**Xử lý:**
- Dùng logic carryforward (lấy tháng trước)
- Hoặc manual override từ planner
- Không áp dụng statistical model

---

### GIAI ĐOẠN 3: Tạo Working File Chính

#### Bước 4: Tạo FC_FM_Original Table
**Tên nghiệp vụ:** Create FC_FM_Original
**Tag:** `tag_create_FC_FM_Original`

**Mục đích:** Tạo bảng chính chứa tất cả dữ liệu forecast

**Tên bảng được tạo:**
```
FC_FM_Original_CPD_202502  (cho CPD, tháng 202502)
FC_FM_Original_LDB_202502  (cho LDB, tháng 202502)
FC_FM_Original_PPD_202502  (cho PPD, tháng 202502)
```

**Cấu trúc bảng bao gồm:**

**Cột định danh:**
- Product Code
- Product Name
- Brand
- Category
- Sub-Category

**Cột dữ liệu lịch sử:** (24 tháng)
- Actual_202301, Actual_202302, ... Actual_202412

**Cột dữ liệu dự báo:** (18 tháng)
- FC_202501, FC_202502, ... FC_202618

**Cột Sell-In breakdown:**
- SI_Promo_Single (Sell-In khuyến mãi đơn)
- SI_Promo_BOM (Sell-In combo khuyến mãi)
- SI_FOC (Sell-In tặng kèm)
- SI_Launch (Sell-In sản phẩm mới)
- SI_OPTIMUS (Sell-In từ Sell-Out)

**Cột Budget:**
- Budget_202501, Budget_202502, ...
- Pre_Budget_202501, Pre_Budget_202502, ...
- Budget_Trend_202501, Budget_Trend_202502, ...

**Cột tồn kho:**
- SOH (Stock On Hand)
- GIT (Goods In Transit)
- MTD_SI (Month-To-Date Sell-In)

**Cột phân tích:**
- Risk_Flag (Cờ rủi ro)
- SLOB_Flag (Cờ hàng tồn kho chậm)
- Forecast_Type (Loại dự báo)

**Xử lý:**
1. Drop bảng cũ nếu tồn tại
2. Create bảng mới với structure đầy đủ
3. Insert dữ liệu baseline từ Bước 2
4. Insert dữ liệu non-modeling từ Bước 3
5. Initialize các cột còn lại = 0 hoặc NULL

---

### GIAI ĐOẠN 4: Tích Hợp Sell-Out Data

#### Bước 5: Generate BOM Header Sell-Out
**Tên nghiệp vụ:** Generate BOM Header SO OPTIMUS
**Tag:** `tag_Gen_Bomheader_SO_OPTIMUS`

**Mục đích:** Import dự báo Sell-Out từ hệ thống OPTIMUS và chuyển sang Sell-In

**Background:**
- **Sell-Out:** Bán ra từ cửa hàng đến consumer
- **Sell-In:** Bán từ L'Oréal vào cửa hàng/distributor
- **Conversion:** Cần chuyển đổi Sell-Out thành Sell-In để lập kế hoạch supply

**Dữ liệu đầu vào:**
- OPTIMUS Sell-Out forecast
- BOM structures
- Conversion ratios

**Xử lý:**
1. **Import Sell-Out forecast:**
   - Lấy dữ liệu từ OPTIMUS system
   - Forecast Sell-Out theo channel/store

2. **Calculate conversion:**
   ```
   Sell-In = Sell-Out + Inventory_Build - Inventory_Drawdown

   Ví dụ:
   Sell-Out forecast: 1000 units
   Target inventory increase: +100 units
   → Sell-In need: 1000 + 100 = 1100 units
   ```

3. **Create BOM headers:**
   - Tạo structure cho promotional packs
   - Link components với finished goods

---

#### Bước 6: Tính Toán GIT
**Tên nghiệp vụ:** Generate GIT
**Tag:** `tag_gen_git`

**Mục đích:** Tính hàng đang trên đường (Goods-In-Transit)

**Định nghĩa GIT:**
- Hàng đã được ship từ plant/warehouse
- Nhưng chưa đến điểm bán
- Đang trên đường vận chuyển

**Dữ liệu đầu vào:**
- Shipment schedule
- Lead time by product/route
- In-transit inventory

**Công thức:**
```
GIT = Shipments_Pending + International_Shipments + Warehouse_Transfers

Ví dụ:
- Shipment từ plant: 500 units (lead time 5 days)
- Import từ nước ngoài: 300 units (lead time 30 days)
- Transfer giữa kho: 200 units (lead time 2 days)
→ Total GIT: 1000 units
```

**Tại sao quan trọng:**
- Ảnh hưởng đến available inventory
- Affect forecast accuracy
- Planning production & shipment

---

### GIAI ĐOẠN 5: Cập Nhật Tồn Kho & Lịch Sử

#### Bước 7: Update SOH, MTD, GIT
**Tên nghiệp vụ:** Generate SOH MTD GIT
**Tag:** `tag_gen_soh_mtd_git`

**Gồm 4 sub-processes:**

**7a. Update SOH (Stock-On-Hand)**
**Mục đích:** Cập nhật tồn kho hiện tại

**Dữ liệu đầu vào:**
- Real-time inventory từ SAP/WMS
- Warehouse stock levels
- Reserved inventory

**Xử lý:**
```
SOH = Physical_Inventory - Reserved_Stock

Ví dụ:
Physical stock: 1500 units
Reserved for orders: 300 units
→ Available SOH: 1200 units
```

---

**7b. Create Historical SI View**
**Mục đích:** Tạo view lịch sử Sell-In

**Xử lý:**
- Tạo view: `{Division}_{FM_KEY}_His_SI_Single_Final`
- Chứa historical Sell-In data
- Dùng cho comparison và analysis

---

**7c. Update MTD SI (Month-To-Date Sell-In)**
**Mục đích:** Cập nhật actual Sell-In của tháng hiện tại

**Dữ liệu đầu vào:**
- Daily sales transactions
- Shipment actuals từ SAP

**Ví dụ:**
```
Tháng hiện tại: 202502 (February 2025)
Hôm nay: 15/02/2025
MTD SI = Sum of actual Sell-In from 01/02 to 15/02

Product A:
- Week 1: 250 units
- Week 2: 280 units
→ MTD: 530 units (vs forecast 600 units)
```

**Tại sao quan trọng:**
- Theo dõi performance vs forecast
- Adjust forecast cho remainder of month
- Early warning nếu under/over forecast

---

**7d. Re-calculate GIT**
**Mục đích:** Tính lại GIT với inventory mới nhất

---

#### Bước 8: Update SIT (Sell-In-Trade)
**Tên nghiệp vụ:** Update WF SIT
**Tag:** `tag_gen_update_sit`

**Mục đích:** Cập nhật Sell-In qua kênh Trade (distributor)

**Background:**
- **Trade channel:** Bán qua distributor
- **Direct channel:** Bán trực tiếp cho retailer
- SIT là component quan trọng của total Sell-In

**Dữ liệu đầu vào:**
- Trade sales forecast
- Distributor orders
- Trade marketing programs

---

#### Bước 9: Update 24 Months Historical Actual
**Tên nghiệp vụ:** Update WF ZV14 02 Year Actual
**Tag:** `tag_update_wf_zv14_02_year_actual`

**Mục đích:** Cập nhật 24 tháng dữ liệu actual từ SAP

**Dữ liệu đầu vào:**
- SAP Transaction ZV14_02 (invoice data)
- Actual sales từ 2 năm gần nhất
- Verified historical data

**Xử lý:**
1. **Extract từ SAP:**
   - Query ZV14_02 transaction
   - Get actual sales by month/product
   - Period: (Current month - 24) to (Current month - 1)

2. **Update Working File:**
   ```
   Tháng hiện tại: 202502
   Update period: 202302 to 202501 (24 months)

   Ví dụ cho Product A:
   - Actual_202302: 1000 units (từ SAP)
   - Actual_202303: 1050 units (từ SAP)
   - ...
   - Actual_202501: 1200 units (từ SAP)
   ```

3. **Replace estimates:**
   - Thay thế bất kỳ estimated actuals
   - Đảm bảo data integrity
   - Lock historical baseline

**Tại sao quan trọng:**
- Historical actuals là foundation của forecast
- Accuracy của baseline phụ thuộc vào actuals
- Dùng cho performance tracking

---

### GIAI ĐOẠN 6: Import Forecast từ FM (Forecast Model)

#### Bước 10: Update Promo Single Forecast
**Tên nghiệp vụ:** Update WF Promo Single Unit
**Tag:** `tag_update_wf_promo_single_unit_only_offline`

**Mục đích:** Import forecast khuyến mãi cho sản phẩm đơn

**Định nghĩa:**
- **Promo Single:** Sản phẩm đơn lẻ có chương trình khuyến mãi
- **Ví dụ:** Shampoo 400ml giảm 20%, Lipstick mua 1 tặng 1

**Dữ liệu đầu vào:**
- Marketing promotional calendar
- Promo mechanics (discount %, BOGO, etc.)
- Expected uplift from promo

**Channels:**
- OFFLINE: Siêu thị, cửa hàng truyền thống
- ONLINE: E-commerce, Lazada, Shopee

**Ví dụ:**
```
Product: Shampoo ABC 400ml
Normal forecast (no promo): 1000 units/month
Promo period: Feb 2025
Promo mechanic: 20% discount
Expected uplift: +50%
→ Promo forecast: 1000 * 1.5 = 1500 units

Offline: 1200 units (80%)
Online: 300 units (20%)
```

---

#### Bước 11: Update New Launch Forecast
**Tên nghiệp vụ:** Update WF New Launch Unit
**Tag:** `tag_update_wf_new_launch_unit_only_offline`

**Mục đích:** Import forecast cho sản phẩm mới ra mắt

**Dữ liệu đầu vào:**
- New product launch plan
- Launch timeline
- Marketing investment
- Expected market share

**Launch curve:**
```
Month 1 (Launch): Pipeline fill + Initial demand
Month 2-3: Ramp-up period
Month 4+: Steady state

Ví dụ:
New Lipstick XYZ launch 202502:
- M1 (Feb): 2000 units (pipeline fill: 1500, sell-out: 500)
- M2 (Mar): 1500 units (ramp-up)
- M3 (Apr): 1200 units (approaching steady)
- M4+ (May+): 1000 units (steady state)
```

**Components:**
1. **Pipeline fill:** Số lượng đầu tiên để fill vào kênh phân phối
2. **Sell-out forecast:** Dự kiến bán ra consumer
3. **Replenishment:** Bổ sung sau launch

---

#### Bước 12: Update FOC Forecast
**Tên nghiệp vụ:** Update WF FOC Unit
**Tag:** `tag_update_wf_foc_unit_only_offline`

**Mục đích:** Import forecast sản phẩm tặng kèm

**Định nghĩa FOC (Free of Charge):**
- Sản phẩm tặng miễn phí cho consumer
- GWP (Gift With Purchase)
- Sampling programs
- Promotional giveaways

**Dữ liệu đầu vào:**
- Promotional calendar
- GWP mechanics
- Sampling plan
- Event schedule

**Ví dụ:**
```
Campaign: Valentine 2025
Mechanic: Mua son từ 500k tặng sample nước hoa 5ml
Expected participants: 10,000 customers
→ FOC forecast: 10,000 units of perfume sample

Distribution:
- Offline stores: 8,000 units
- Online: 2,000 units
```

**Phân loại FOC:**
1. **Miniature/Sample:** Size nhỏ để thử nghiệm
2. **Full-size GWP:** Sản phẩm full-size tặng kèm
3. **Event giveaway:** Tặng tại sự kiện
4. **Staff allocation:** Phân bổ cho nhân viên

---

#### Bước 13: Update Promo BOM Component
**Tên nghiệp vụ:** Update WF Promo BOM Component
**Tag:** `tag_update_wf_promo_bom_component_unit`

**Mục đích:** Import forecast cho component của combo/set khuyến mãi

**Định nghĩa:**
- **Promo BOM:** Bill of Materials cho promotional pack
- **Component:** Các sản phẩm đơn lẻ tạo nên combo

**Ví dụ:**
```
Promo BOM: "Beauty Box Tết 2025"
Components:
├─ Lipstick A: 1 unit
├─ Mascara B: 1 unit
├─ Serum C: 1 unit
└─ Gift box: 1 unit

Forecast for Beauty Box: 5,000 sets
→ Component forecast:
   - Lipstick A: 5,000 units
   - Mascara B: 5,000 units
   - Serum C: 5,000 units
   - Gift box: 5,000 units
```

**Xử lý:**
1. Lấy BOM structure
2. Explode BOM sang components
3. Calculate component requirements
4. Update Working File

---

### GIAI ĐOẠN 7: Tích Hợp Budget Data

#### Bước 14: Generate Budget
**Tên nghiệp vụ:** Generate Budget
**Tag:** `tag_gen_budget_budget`

**Mục đích:** Import annual budget đã được approve

**Dữ liệu đầu vào:**
- Annual budget từ Finance
- Board-approved figures
- Budget allocation by month

**Xử lý:**
```
Annual Budget for Product A: 12,000 units
Allocation by month (có thể không đều):

Jan: 1,200 units (10%) - Tết period
Feb: 900 units (7.5%)
Mar: 1,000 units (8.3%)
...
Dec: 1,100 units (9.2%)

Update vào Budget columns của Working File
```

**So sánh:**
- **Forecast:** Dự báo của Demand Planning team
- **Budget:** Commitment với Finance/Board
- **Gap:** Forecast - Budget (quan trọng để track)

---

#### Bước 15: Generate Pre-Budget
**Tên nghiệp vụ:** Generate Pre-Budget
**Tag:** `tag_gen_budget_pre_budget`

**Mục đích:** Import pre-budget (ngân sách sơ bộ)

**Background:**
- Pre-Budget được tạo trước Annual Budget chính thức
- Là draft version để discussion
- Dùng để so sánh với Budget chính thức sau này

---

#### Bước 16: Generate Budget Trend
**Tên nghiệp vụ:** Generate Budget Trend
**Tag:** `tag_gen_budget_trend`

**Mục đích:** Tạo budget projection dựa trên trend

**Công thức:**
```
Budget Trend = Historical Average * Growth Rate

Ví dụ:
Product A - Last year average: 1000 units/month
Target growth: +10%
→ Budget Trend: 1000 * 1.1 = 1100 units/month
```

**Use case:**
- Alternative scenario planning
- Quick budget estimate
- Benchmark vs actual Budget

---

### GIAI ĐOẠN 8: Tính Toán Sell-In Groups

Giai đoạn này tính toán tổng Sell-In cho từng nhóm sản phẩm.

#### Bước 17: Calculate SI Promo Single
**Tên nghiệp vụ:** Add FC SI Group Promo Single
**Tag:** `tag_add_FC_SI_Group_FC_SI_Promo_Single`

**Mục đích:** Tính tổng Sell-In cho promotional single products

**Xử lý:**
```
Input:
- Offline promo forecast: 1,200 units
- Online promo forecast: 300 units

Calculation:
SI_Promo_Single = Offline + Online = 1,500 units

Update cột SI_Promo_Single trong WF
```

---

#### Bước 18: Calculate SI from OPTIMUS
**Tên nghiệp vụ:** Add FC SI Group SO OPTIMUS
**Tag:** `tag_add_FC_SI_Group_FC_SO_OPTIMUS`

**Mục đích:** Tính Sell-In từ Sell-Out OPTIMUS forecast

**Note:** Chỉ chạy nếu `@run_optimus = 1` (config trong system)

**Conversion logic:**
```
Sell-In = Sell-Out + Inventory_Change

Ví dụ:
Sell-Out forecast: 2,000 units
Target inventory increase: +200 units
→ Sell-In: 2,000 + 200 = 2,200 units
```

---

#### Bước 19: Calculate SI FOC
**Tên nghiệp vụ:** Add FC SI Group FOC
**Tag:** `tag_add_FC_SI_Group_FC_SI_FOC`

**Mục đích:** Tính tổng Sell-In cho FOC products

---

#### Bước 20: Calculate SI New Launch
**Tên nghiệp vụ:** Add FC SI Group Launch Single
**Tag:** `tag_add_FC_SI_Group_FC_SI_Launch_Single`

**Mục đích:** Tính tổng Sell-In cho new launch products

---

#### Bước 21: Calculate SI Promo BOM
**Tên nghiệp vụ:** Add FC SI Group Promo BOM
**Tag:** `tag_add_FC_SI_Group_FC_SI_Promo_Bom`

**Mục đích:** Tính tổng Sell-In cho promo BOM products

**Note:** Có 2 versions:
- Legacy version: Tính tất cả channels
- New version: CHỈ tính OFFLINE

Version được config trong `V_FC_NEW_CONFIG_BOM_HEADER`

---

#### Bước 22: Update BP Unit
**Tên nghiệp vụ:** Update BP Unit
**Tag:** `tag_update_BP_unit`

**Mục đích:** Cập nhật Budget Planning unit calculations

**Note:** Hiện tại CHỈ chạy cho CPD division

---

### GIAI ĐOẠN 9: Tạo Final Working File

#### Bước 23: Create WF First Time
**Tên nghiệp vụ:** Create WF First Time
**Tag:** `tag_Create_WF_FirstTime`

**Mục đích:** Tạo cấu trúc Working File lần đầu

**Chỉ chạy khi:** `@TypeView = ''` (full generation mode)

**Xử lý:**
- Setup column structure
- Define data types
- Initialize formulas

---

#### Bước 24: Create Full WF
**Tên nghiệp vụ:** Create FM WF Full
**Tag:** `tag_fc_create_fm_WF_full`

**Mục đích:** Build Working File đầy đủ với tất cả dữ liệu

**Chỉ chạy khi:** `@TypeView = ''` (full generation mode)

**Consolidated data includes:**
- ✅ Historical actuals (24 months)
- ✅ Baseline forecast
- ✅ Promotional forecasts
- ✅ New launch forecasts
- ✅ FOC forecasts
- ✅ Budget data
- ✅ Inventory data (SOH, GIT)
- ✅ MTD actuals
- ✅ All Sell-In breakdowns

**Output:**
- Complete Working File sẵn sàng export sang Excel
- Tất cả columns đã được calculated
- Ready for review và adjustments

---

### GIAI ĐOẠN 10: Tính Toán Bổ Sung

#### Bước 25: Create FC_MCSI
**Tên nghiệp vụ:** Create FC MCSI
**Tag:** `sp_create_FC_MCSI`

**Mục đích:** Tạo bảng Multi-Channel Sell-In breakdown

**Channels:**
- Modern Trade (MT)
- General Trade (GT)
- E-commerce
- Direct sales
- ...

**Ví dụ:**
```
Total SI forecast: 10,000 units
Breakdown by channel:
├─ MT: 5,000 units (50%)
├─ GT: 3,000 units (30%)
├─ E-com: 1,500 units (15%)
└─ Direct: 500 units (5%)
```

---

#### Bước 26: Update 02 Years Historical
**Tên nghiệp vụ:** Update WF Pass 02 Years
**Tag:** `tag_update_wf_pass_02_years`

**Mục đích:** Finalize 24 months historical data

**Xử lý:**
- Apply final corrections
- Validate data quality
- Lock historical baseline

---

#### Bước 27: Calculate 3M Risk
**Tên nghiệp vụ:** FC FM Risk 3M
**Tag:** `tag_fc_fm_risk_3M`

**Mục đích:** Đánh giá risk cho 3 tháng tới

**Risk indicators:**
1. **High forecast:** Forecast cao bất thường
2. **Low forecast:** Forecast thấp bất thường
3. **High volatility:** Biến động lớn giữa các tháng
4. **New launch risk:** Launch không như kỳ vọng

**Ví dụ:**
```
Product A:
- Average forecast: 1,000 units/month
- M+1 forecast: 2,500 units (+150%)
→ Risk Flag: HIGH FORECAST
→ Reason: Có chương trình promo lớn

Product B:
- Historical: Stable 500 units/month
- M+1 forecast: 100 units (-80%)
→ Risk Flag: LOW FORECAST
→ Reason: Product discontinue
```

---

#### Bước 28: Update SLOB
**Tên nghiệp vụ:** Update SLOB WF
**Tag:** `sp_tag_update_slob_wf`

**Mục đích:** Cập nhật SLOB (Slow & Obsolete) indicators

**Định nghĩa SLOB:**
- **Slow-moving:** Sản phẩm bán chậm
- **Obsolete:** Sản phẩm lỗi thời, sắp ngừng

**Criteria:**
```
SLOB if:
1. Forecast < 10 units/month
2. Inventory > 6 months forecast
3. Days of supply > 180 days
4. Product in discontinue list
```

**Ví dụ:**
```
Product: Old Cream ABC
Current SOH: 3,000 units
Monthly forecast: 50 units
→ DOS (Days of Supply): 3000/50 = 60 months
→ SLOB Flag: YES
→ Action needed: Clearance sale, NPD, discontinue
```

---

### GIAI ĐOẠN 11: Tính Tổng Cuối Cùng

#### Bước 29: Calculate All Totals
**Tên nghiệp vụ:** Calculate Total
**Tag:** `tag_sp_calculate_total`

**Mục đích:** Tính tất cả các tổng cuối cùng

**Calculations:**

**1. Row totals (Tổng theo hàng):**
```
Product A total = Sum of all months
= Jan + Feb + Mar + ... + Dec
```

**2. Column totals (Tổng theo cột):**
```
Jan total = Sum of all products in Jan
= Product_A_Jan + Product_B_Jan + ...
```

**3. Grand total:**
```
Grand Total = Sum of all products, all months
```

**4. Subtotals:**
```
By Brand:
- Brand X total
- Brand Y total

By Category:
- Category A total
- Category B total
```

**Validation:**
```
Check: Row totals = Column totals = Grand total
If mismatch → Error alert
```

---

## 🎯 Kết Quả Cuối Cùng

Sau khi hoàn tất tất cả 29 bước, bạn có:

### Working File Hoàn Chỉnh

**Bảng chính:** `FC_FM_Original_{Division}_{YYYYMM}`

**Chứa:**
- ✅ 24 tháng historical actuals
- ✅ 18 tháng forecast
- ✅ Budget, Pre-Budget, Budget Trend
- ✅ All Sell-In breakdowns
- ✅ Inventory data (SOH, GIT, MTD)
- ✅ Risk indicators
- ✅ SLOB flags
- ✅ All totals calculated

### Bảng Phụ

- **FC_MCSI:** Multi-channel breakdown
- **FC_Table_Status:** Execution status log
- **Historical SI View:** Historical Sell-In reference

### Ready For

1. **Export to Excel** - Cho Demand Planners review
2. **Gap Analysis** - So sánh Forecast vs Budget
3. **Approval Workflow** - Submit cho management
4. **Supply Planning** - Input cho production planning
5. **Financial Planning** - Revenue projection

---

## 📊 Các Chế Độ Chạy (Execution Modes)

### Mode 1: Full Generation (`@TypeView = ''`)
**Khi nào dùng:** Tạo WF lần đầu cho tháng mới

**Chạy tất cả 29 bước**

**Thời gian:** 30-45 phút

---

### Mode 2: Partial (`@TypeView = 'partial'`)
**Khi nào dùng:** Chỉ update một số components cụ thể

**Chạy:** Các steps được config trong partial mode

**Ví dụ use case:**
- Chỉ update promotional forecast
- Chỉ update budget
- Chỉ update inventory

**Thời gian:** 5-15 phút

---

### Mode 3: Value (`@TypeView = 'value'`)
**Khi nào dùng:** Chạy value-based calculations

**Thời gian:** 5-10 phút

---

### Mode 4: Re-Gen (`@TypeView = 're-gen'`)
**Khi nào dùng:** Re-generate based on selected functions

**User select:** Chọn steps muốn chạy lại

**Thời gian:** Tùy theo số steps được chọn

---

## ⚠️ Xử Lý Lỗi

### Error Tracking
Mỗi step được monitor:
- Success/Failure status
- Error message (nếu có)
- Execution time
- Logged vào `FC_Table_Status`

### Resilient Execution
- Nếu 1 step fails → Execution tiếp tục
- Error được log
- `@errorTotal` counter tăng
- User được thông báo steps nào failed

### Final Status
```
If @errorTotal = 0:
  → SUCCESS - All steps completed
Else:
  → PARTIAL SUCCESS - Some steps failed
  → Check FC_Table_Status for details
```

---

## 📈 Performance Tips

### Để tối ưu thời gian chạy:

1. **Run during off-peak hours**
   - Tránh giờ cao điểm database
   - Preferably overnight hoặc weekend

2. **Ensure data ready**
   - Historical data đã import
   - Master data updated
   - No missing configurations

3. **Monitor regularly**
   - Check FC_Table_Status trong quá trình chạy
   - Identify bottlenecks
   - Optimize slow steps

4. **Use partial mode**
   - Khi chỉ cần update một phần
   - Tiết kiệm thời gian

---

## 🔍 Câu Hỏi Thường Gặp (FAQ)

### Q1: Tại sao Working File của tôi không được tạo?
**A:** Kiểm tra:
- Period có được mở không? (Check V_FC_FORECAST_PERIOD)
- Có lỗi nào trong FC_Table_Status không?
- Historical data đã được import chưa?

### Q2: Forecast quá cao/thấp bất thường?
**A:**
- Check Risk_Flag column
- Review input data (promo, launch plans)
- Validate historical actuals

### Q3: Làm sao update chỉ promotional forecast?
**A:** Dùng Partial mode với tag `tag_update_wf_promo_single_unit_only_offline`

### Q4: Budget và Forecast không match?
**A:** Normal - đây là Gap cần theo dõi và explain

### Q5: SLOB products có nên forecast không?
**A:**
- Nếu discontinue → Forecast = 0
- Nếu clearance → Forecast dựa trên clearance plan
- Nếu still active → Check why SLOB và adjust

---

## 📞 Hỗ Trợ

Nếu gặp vấn đề khi chạy Working File generation:

1. **Check logs:**
   - FC_Table_Status table
   - System log files

2. **Contact:**
   - Demand Planning Team Lead
   - IT Support Team
   - System Administrator

3. **Provide information:**
   - Division
   - FM_KEY (period)
   - Error message
   - Screenshot FC_Table_Status

---

**Document Version:** 1.0
**Last Updated:** 2025-11-18
**Owner:** L'Oréal Vietnam Demand Planning Team
