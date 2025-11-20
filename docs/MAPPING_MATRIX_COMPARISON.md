# Complete Mapping Matrix - Division Comparison

## 📋 Mục Lục

1. [Overview Comparison](#1-overview-comparison)
2. [Data Source Comparison](#2-data-source-comparison)
3. [Processing Logic Comparison](#3-processing-logic-comparison)
4. [Time Series Comparison](#4-time-series-comparison)
5. [Channel Comparison](#5-channel-comparison)
6. [Special Features Comparison](#6-special-features-comparison)
7. [Decision Trees](#7-decision-trees)

---

## 1. Overview Comparison

### 1.1. Division Characteristics Matrix

| Characteristic | CPD | LDB | LLD |
|----------------|-----|-----|-----|
| **Full Name** | Consumer Products Division | Luxe Dermatologie et Beauté | Luxe Division |
| **Product Type** | Mass market beauty | Dermo + Professional | Prestige/luxury beauty |
| **Price Point** | Low-Medium | Medium-High | High |
| **Volume** | High | Medium | Low |
| **Typical Unit Price** | 50K-300K VND | 200K-800K VND | 500K-3M VND |
| **Active SKUs** | ~500+ | ~300+ | ~200+ |
| **Business Model** | Volume-driven | Stable demand | Value-driven |
| **Main Channels** | GT, MT, Pharma, Online | Pharma (60-70%), Salon (20-30%) | Premium Retail, Duty-Free |
| **Seasonality** | High (promotions) | Medium | Low (trend-driven) |
| **Promotional Activity** | High (20-25% of volume) | Low (5-10%) | Very Low (2-5%) |

### 1.2. Strategic Focus Comparison

**CPD:**
```
Focus: Volume growth, market penetration
Key Success Factors:
- Distribution breadth (everywhere!)
- Promotional efficiency
- SKU proliferation (variety)
- Price competitiveness

Challenges:
- High competition
- Price pressure
- Complex BOM management
- Promotional planning complexity
```

**LDB:**
```
Focus: Professional trust, medical credibility
Key Success Factors:
- Pharmacy/salon relationships
- Professional education
- Product efficacy
- Expert recommendations

Challenges:
- Regulatory compliance
- Professional channel management
- Category-specific handling
- Limited promotional tools
```

**LLD:**
```
Focus: Brand prestige, aspirational positioning
Key Success Factors:
- Brand equity maintenance
- Exclusive distribution
- Premium experience
- Innovation leadership

Challenges:
- Low volume forecasting
- Trend sensitivity
- Manual forecast adjustments
- Campaign dependency
```

---

## 2. Data Source Comparison

### 2.1. Historical SO (Sell-Out) Comparison

| Aspect | CPD | LDB | LLD |
|--------|-----|-----|-----|
| **Source** | Optimus SO | Optimus SO | Optimus SO |
| **Import Procedure** | sp_add_FC_SO_OPTIMUS_NORMAL_Tmp | sp_add_FC_SO_OPTIMUS_NORMAL_**LDB**_Tmp | sp_add_FC_SO_OPTIMUS_NORMAL_Tmp |
| **Conversion** | ❌ None | ✅ **sp_fc_convert_SO_LDB_SO** | ❌ None |
| **Why Conversion?** | N/A | Category-specific unit definitions | N/A |
| **Final Table** | FC_CPD_SO_HIS_FINAL | FC_LDB_SO_HIS_FINAL | FC_LLD_SO_HIS_FINAL |
| **Channel Mapping** | GT/MT/Pharma → OFFLINE | **Pharma/Salon** → OFFLINE | Premium Retail → OFFLINE |
| **Update Frequency** | Weekly | Weekly | Weekly |

**Key Takeaway:**
- **LDB is the ONLY division with SO conversion**
- CPD & LLD use standard unit definitions
- LDB needs conversion for Dermatology & Professional categories

### 2.2. Historical SI (Sell-In) Comparison

| Aspect | CPD | LDB | LLD |
|--------|-----|-----|-----|
| **Source** | SAP ZV14 | SAP ZV14 | SAP ZV14 |
| **Import Procedure** | sp_add_FC_SI_OPTIMUS_NORMAL_Tmp | sp_add_FC_SI_OPTIMUS_NORMAL_Tmp | sp_add_FC_SI_OPTIMUS_NORMAL_Tmp |
| **Conversion** | ❌ None | ✅ **sp_fc_convert_SO_LDB_SI** | ❌ None |
| **Why Conversion?** | N/A | Professional sizes, pharma packaging | N/A |
| **BOM Impact** | High (many bundles) | Medium | Low |
| **SI Views** | V_CPD_His_SI_* | V_LDB_His_SI_* | V_LLD_His_SI_* |

**Key Takeaway:**
- **LDB is the ONLY division with SI conversion**
- All use same ZV14 source, but LDB applies transformations
- CPD has most complex BOM (bundle) handling

### 2.3. Forecast Source Comparison

| Aspect | CPD | LDB | LLD |
|--------|-----|-----|-----|
| **Primary Source** | FM File | FM File | FM File |
| **Secondary Source** | ❌ None | SI Template | **FM Non-Modeling** |
| **Import Procedure 1** | sp_add_FC_FM_Tmp | sp_add_FC_FM_Tmp | sp_add_FC_FM_Tmp |
| **Import Procedure 2** | N/A | sp_add_FC_SI_Template_Tmp | **sp_add_FC_FM_Non_Modeling_Tmp** |
| **Merge Procedure** | N/A | (integrated) | **sp_tag_gen_fm_non_modeling_new** |
| **Baseline Calculation** | FM only | FM + SI Template guidance | **FM + FM Non-Modeling** |
| **Manual Adjustment Importance** | Medium | Low | **High (critical!)** |
| **Forecast Driver** | SO-driven (consumer demand) | SI-driven (supply planning) | **Campaign-driven (strategic)** |

**Key Differences:**

**CPD:**
```
Baseline = FM file
- Statistical forecast sufficient
- High volume, stable patterns
- User edits for exceptions
```

**LDB:**
```
Baseline = FM + SI Template input
- SI Template provides customer-level guidance
- Pharma/salon ordering patterns
- Less consumer-driven
```

**LLD:**
```
Baseline = FM (Modeling) + FM Non-Modeling (Manual)
- Statistical model insufficient for luxury
- Expert judgment critical
- Campaign/event-driven adjustments
- Formula: Total Baseline = Modeling + Non-Modeling
```

### 2.4. Stock & Calculation Fields Comparison

| Field | CPD | LDB | LLD | Notes |
|-------|-----|-----|-----|-------|
| **SOH** | ✅ Same | ✅ Same | ✅ Same | All from ZMR32, same logic |
| **GIT** | ✅ Same | ✅ Same | ✅ Same | All from GIT Report, same |
| **SIT** | ✅ Same | ✅ Same | ✅ Same | Formula: SOH - GIT_M0 |
| **SLOB** | ✅ Same | ✅ Same | ✅ Same | Formula: SOH / AVE_P3M |
| **MTD SI** | ✅ Same | ✅ Same | ✅ Same | All from ZV14 daily |
| **Budget** | ✅ Same | ✅ Same | ✅ Same | All from Finance BP |

**Key Takeaway:**
- **All calculation fields are IDENTICAL across divisions**
- Same formulas, same procedures
- Division differences are ONLY in SO/SI sourcing and forecasting

---

## 3. Processing Logic Comparison

### 3.1. BOM (Bill of Materials) Complexity

**CPD: HIGH Complexity**
```
Bundle Types:
- Gift sets (holiday, Mother's Day, etc.)
- Promo packs (buy 2 get 1 format)
- Multi-product bundles
- Trial kits

BOM Levels: Up to 3 levels deep

Example:
"L'Oréal Ultimate Gift Set" (Parent)
├─ "Revitalift Set" (Bundle 1)
│  ├─ Serum 30ml
│  ├─ Day Cream 50ml
│  └─ Night Cream 50ml
└─ "UV Perfect Set" (Bundle 2)
   ├─ UV Cream 30ml
   └─ Sunscreen Spray 50ml

Procedures:
- sp_Update_Bom_Header_New (complex explosion logic)
- sp_Gen_BomHeader_Forecast_New (multi-level)
- Multiple BOM views (V_CPD_His_SI_BOM, V_CPD_His_SI_SingleBomcomponent, etc.)

Forecast Impact:
- User forecasts bundle
- System explodes to all components
- Component forecast = Direct + From all parent bundles
```

**LDB: MEDIUM Complexity**
```
Bundle Types:
- Salon professional kits
- Dermo trial kits (limited)

BOM Levels: Usually 1 level

Example:
"Kérastase Resistance Treatment Kit"
├─ Bain 250ml
├─ Fondant 200ml
└─ Masque 200ml

Less complexity than CPD, simpler bundles
```

**LLD: LOW Complexity**
```
Bundle Types:
- Luxury gift sets (holiday, mainly)
- Mostly single prestige products

BOM Levels: 1 level, minimal

Example:
"Lancôme Rénergie Set" (rare)
├─ Serum 30ml
└─ Cream 50ml

Most LLD products sold individually
Bundles are exception, not norm
```

### 3.2. Conversion Logic Comparison

**CPD: NO Conversion**
```
✅ Direct from Optimus/ZV14
❌ No conversion procedures
✅ Standard unit definitions
```

**LDB: CONVERSION REQUIRED** ⭐
```
Why?
1. Dermatology Products:
   - Pharmacies report including testers
   - Medical sample distribution
   - Conversion Factor: 1.00-1.10

2. Professional Products:
   - Salon backbar sizes (1000ml) vs consumer (250ml)
   - Professional equivalents needed
   - Conversion Factor: Based on size ratio

Procedures:
- sp_fc_convert_SO_LDB_SO (SO conversion)
- sp_fc_convert_SO_LDB_SI (SI conversion)
- sp_fc_convert_SO_LDB (master procedure)

Conversion Tables:
- FC_LDB_Conversion_Factors (by Spectrum, Category)

Example:
Raw: 1000 bottles × 1000ml (salon size)
Converted: 4000 consumer equivalent units (250ml)
```

**LLD: NO Conversion**
```
✅ Direct from Optimus/ZV14
❌ No conversion procedures
✅ Luxury products in standard consumer units
```

### 3.3. Time Series Processing Comparison

All divisions use same 5 time series structure:

| Time Series | CPD % | LDB % | LLD % | Notes |
|-------------|-------|-------|-------|-------|
| **1. Baseline Qty** | 60-70% | 80-85% | 85-90% | Higher for stable divisions |
| **2. Promo Qty** | 20-25% | 5-10% | 2-5% | Lower for premium/regulated |
| **4. Launch Qty** | 10-15% | 10-15% | 10-15% | Similar across divisions |
| **5. FOC Qty** | 5-10% | 5% | 2-3% | Lowest for luxury |
| **6. Total Qty** | 100% | 100% | 100% | Calculated: 1+2+4+5 |

**CPD Time Series Emphasis:**
```
High Promo Activity:
- Weekly promotions
- Seasonal campaigns
- Buy-one-get-one
- Discount events

→ Promo Qty significant (20-25%)
```

**LDB Time Series Emphasis:**
```
Limited Promo Activity:
- Pharma regulations restrict promotions
- Salon professional pricing (no discounts)
- Education-focused, not price-focused

→ Promo Qty minimal (5-10%)
→ Baseline dominant (80-85%)
```

**LLD Time Series Emphasis:**
```
Minimal Promo Activity:
- Brand equity protection (no deep discounts)
- Exclusive positioning
- VIP events (not mass promos)

→ Promo Qty minimal (2-5%)
→ Baseline dominant (85-90%)
→ Launch important (prestige innovations)
```

---

## 4. Time Series Comparison

### 4.1. Baseline Qty Comparison

| Aspect | CPD | LDB | LLD |
|--------|-----|-----|-----|
| **Source** | FM File | FM File + SI Template | **FM + FM Non-Modeling** |
| **Driver** | Consumer demand | Supply chain planning | **Strategic/Campaign** |
| **Stability** | Medium | High | Low (event-driven) |
| **Forecast Method** | Statistical | Statistical + Customer orders | **Statistical + Expert judgment** |
| **Manual Adjustment** | Occasional | Rare | **Frequent (critical)** |
| **Percentage of Total** | 60-70% | 80-85% | 85-90% |

**Example Scenarios:**

**CPD Baseline:**
```
Product: L'Oréal UV Perfect 30ml
Historical: 10000 units/month average
FM Forecast: 11000 units (seasonal growth)
User Edit: 11000 (no change)
Final Baseline: 11000

Rationale: Statistical model sufficient
```

**LDB Baseline:**
```
Product: La Roche-Posay Effaclar Duo+ 40ml
Historical: 8000 units/month (stable)
FM Forecast: 8200 units
SI Template: 8500 units (pharmacy orders confirmed)
Final Baseline: 8500 (SI Template overrides)

Rationale: Customer orders more reliable than statistical
```

**LLD Baseline:**
```
Product: YSL Rouge Pur Couture Lipstick
Historical: 1000 units/month
FM (Modeling): 1000 units (trend continuation)
FM Non-Modeling: +800 units (campaign adjustment)
Final Baseline: 1800 units

Rationale: 
- March campaign launch (+500)
- Celebrity endorsement (+200)
- Store expansion (+100)
Expert judgment adds 800 units to statistical baseline
```

### 4.2. Promo Qty Comparison

**CPD: High Promo Activity**
```
Promo Types:
- Price discounts (20-50% off)
- BOGO (Buy One Get One)
- GWP (Gift with Purchase)
- Multi-buy (Buy 2, save 20%)
- Flash sales

Channels: All channels (GT, MT, Online)

Planning:
- Promo calendar (annual)
- Weekly promo updates
- SKU-level promo planning

Promo % of Total: 20-25%
```

**LDB: Limited Promo**
```
Promo Types:
- VIP loyalty programs (pharma)
- Salon professional programs
- Educational events (not price-based)
- Sample distribution (FOC, not promo)

Restrictions:
- Pharma regulations (medical products)
- Professional channel norms (no discounting)

Promo % of Total: 5-10%
```

**LLD: Minimal Promo**
```
Promo Types:
- Exclusive VIP events (invitation-only)
- Limited edition launches
- GWP (high-value, prestige gifts)
- Travel retail exclusives

Brand Protection:
- No deep discounts (damages brand)
- No mass promotions
- Scarcity over discount

Promo % of Total: 2-5%
```

---

## 5. Channel Comparison

### 5.1. Channel Distribution by Division

**CPD Channels:**
```
OFFLINE:
├─ GT (General Trade): 30-40% - Mom & pop stores, independents
├─ MT (Modern Trade): 40-50% - Supermarkets, hypermarkets (Big C, Lotte, etc.)
├─ PHARMA: 10-15% - Pharmacies (some overlap with LDB)
└─ Other Retail: 5% - Department stores, beauty stores

ONLINE: 10-15% - E-commerce (Lazada, Shopee, Tiki, brand sites)

Main Focus: GT + MT (mass distribution)
```

**LDB Channels:**
```
OFFLINE:
├─ **PHARMA: 60-70%** - Pharmacies (main dermo channel)
├─ **SALON: 20-30%** - Professional salons (hair care)
├─ RETAIL: 5-10% - Limited general retail
└─ Department Stores: 5% - Premium counters

ONLINE: 5-10% - E-commerce (growing)

Main Focus: Pharma + Salon (specialized)
```

**LLD Channels:**
```
OFFLINE:
├─ **Premium Retail: 50-60%** - Department stores (luxury counters)
├─ **Duty-Free: 20-30%** - Airport, travel retail
├─ Luxury Boutiques: 10-15% - Standalone brand stores
└─ High-end Department: 10% - Exclusive locations

ONLINE: 10-15% - Official brand sites, luxury e-comm

Main Focus: Premium Retail + Duty-Free (exclusive)
```

### 5.2. Channel Mapping Rules Comparison

| Raw Channel | CPD Mapping | LDB Mapping | LLD Mapping |
|-------------|-------------|-------------|-------------|
| **GT** | OFFLINE | (not applicable) | (not applicable) |
| **MT** | OFFLINE | (not applicable) | (not applicable) |
| **PHARMA** | OFFLINE | **OFFLINE (main)** | (rare) |
| **SALON** | (not applicable) | **OFFLINE (main)** | (not applicable) |
| **RETAIL** | OFFLINE | OFFLINE | (limited) |
| **PREMIUM_RETAIL** | (rare) | (rare) | **OFFLINE (main)** |
| **DUTY_FREE** | (rare) | (rare) | **OFFLINE (important)** |
| **ONLINE** | ONLINE | ONLINE | ONLINE |
| **E-COMMERCE** | ONLINE | ONLINE | ONLINE |

---

## 6. Special Features Comparison

### 6.1. Division-Specific Procedures

**CPD-Specific:**
```
❌ No CPD-specific procedures
✅ Uses all standard procedures
✅ Heavy BOM procedures (shared, but mainly used by CPD)

Note: CPD is the "standard" division, others deviate from it
```

**LDB-Specific:** ⭐
```
✅ sp_fc_convert_SO_LDB_SO (SO conversion)
✅ sp_fc_convert_SO_LDB_SI (SI conversion)
✅ sp_fc_convert_SO_LDB (master conversion)
✅ sp_add_FC_SO_OPTIMUS_NORMAL_LDB_Tmp (LDB import variant)
✅ sp_add_FC_SI_Template_Tmp (SI template, mainly LDB)

LDB-Specific Tables:
- FC_LDB_Conversion_Factors
- FC_LDB_SO_HIS_FINAL (after conversion)
- FC_LDB_SI_HIS_FINAL (after conversion)
```

**LLD-Specific:** ⭐
```
✅ sp_add_FC_FM_Non_Modeling_Tmp (Non-Modeling import)
✅ sp_tag_gen_fm_non_modeling_new (Merge FM + Non-Modeling)
✅ sp_tag_update_wf_FM_Non_Modeling_unit (Update WF)

LLD-Specific Tables:
- FC_FM_Non_Modeling_LLD_{FMKEY}_Tmp
- (Merged into FC_FM_Original_LLD)
```

### 6.2. Unique Characteristics Summary

| Feature | CPD | LDB | LLD |
|---------|-----|-----|-----|
| **Conversion Procedures** | ❌ | ✅ **YES** | ❌ |
| **Dual Forecast Sources** | ❌ | ✅ (FM + SI Template) | ✅ **(FM + FM Non-Modeling)** |
| **BOM Complexity** | ✅ **HIGH** | Medium | Low |
| **Manual Adjustments** | Medium | Low | ✅ **HIGH** |
| **Category-Specific Logic** | Product-based | ✅ **Category-based (Dermo/Pro)** | Brand-based |
| **Promotional Complexity** | ✅ **HIGH** | Low | Very Low |
| **Channel Specialization** | Mass distribution | ✅ **Pharma/Salon focus** | ✅ **Premium/Duty-Free** |
| **Forecast Driver** | Consumer SO | Supply SI | ✅ **Strategic Campaigns** |

---

## 7. Decision Trees

### 7.1. "Which Division is This Product?"

```
Decision Tree:

Is it a luxury brand? (YSL, Lancôme, Armani, etc.)
├─ YES → LLD
└─ NO ↓

Is it dermatological or professional hair care? (LRP, Vichy, Kérastase, etc.)
├─ YES → LDB
└─ NO → CPD (mass market beauty)
```

### 7.2. "Which Procedure Do I Need?"

**For Historical SO Import:**

```
Need to import SO data?
├─ Division = CPD → sp_add_FC_SO_OPTIMUS_NORMAL_Tmp
├─ Division = LDB → sp_add_FC_SO_OPTIMUS_NORMAL_LDB_Tmp + sp_fc_convert_SO_LDB_SO
└─ Division = LLD → sp_add_FC_SO_OPTIMUS_NORMAL_Tmp
```

**For Forecast Import:**

```
Need to import forecast?
├─ Division = CPD → sp_add_FC_FM_Tmp (FM file only)
├─ Division = LDB → sp_add_FC_FM_Tmp + sp_add_FC_SI_Template_Tmp
└─ Division = LLD → sp_add_FC_FM_Tmp + sp_add_FC_FM_Non_Modeling_Tmp + sp_tag_gen_fm_non_modeling_new
```

### 7.3. "Why is This Field Different Than Expected?"

**Field value doesn't match source file:**

```
Check Division:
├─ LDB? → Check if conversion applied
│  ├─ SO: sp_fc_convert_SO_LDB_SO applied?
│  └─ SI: sp_fc_convert_SO_LDB_SI applied?
│
├─ LLD Baseline? → Check if Non-Modeling added
│  └─ Baseline = FM + FM Non-Modeling
│
└─ CPD? → Check BOM explosion
   └─ Component forecast = Direct + From BOM
```

### 7.4. "Which File Do I Need to Update?"

**To change forecast:**

```
What do you want to change?

Baseline for CPD/LDB:
└─ Update FM file → Re-import

Baseline for LLD:
├─ Change statistical: Update FM file
└─ Change manual adjustment: Update FM Non-Modeling file

Promo/Launch/FOC:
└─ Edit directly in WF Excel → Upload

Historical data:
└─ Cannot change (read-only, fix source data)
```

---

## 8. Summary Matrix

### 8.1. Complete Division Comparison

| Aspect | CPD | LDB | LLD |
|--------|-----|-----|-----|
| **Position** | Mass market | Professional/Dermo | Prestige/Luxury |
| **Volume** | High | Medium | Low |
| **Price** | Low-Med | Med-High | High |
| **SO Source** | Optimus | Optimus + **Conversion** | Optimus |
| **SI Source** | ZV14 | ZV14 + **Conversion** | ZV14 |
| **Forecast Primary** | FM | FM | FM |
| **Forecast Secondary** | ❌ | SI Template | **FM Non-Modeling** |
| **Baseline Method** | Statistical | Statistical + Customer orders | **Statistical + Expert** |
| **BOM Complexity** | **HIGH** | Medium | Low |
| **Promo %** | **20-25%** | 5-10% | 2-5% |
| **Main Channel** | GT/MT | **Pharma/Salon** | **Premium/Duty-Free** |
| **Forecast Stability** | Medium | High | Low |
| **Manual Adjustment Need** | Medium | Low | **HIGH** |
| **Key Procedure** | (standard) | **sp_fc_convert_SO_LDB_*** | **sp_add_FC_FM_Non_Modeling_Tmp** |

### 8.2. When to Use Each Division's Approach

**Use CPD Approach When:**
- ✅ Mass market, high volume products
- ✅ Heavy promotional activity
- ✅ Complex bundle/gift set structure
- ✅ Multi-channel mass distribution
- ✅ Consumer-driven demand
- ✅ Statistical forecasting sufficient

**Use LDB Approach When:**
- ✅ Professional or medical products
- ✅ Channel-specific unit definitions
- ✅ Category-based business rules
- ✅ Regulatory considerations (pharma)
- ✅ Stable, professional-driven demand
- ✅ Customer order visibility important

**Use LLD Approach When:**
- ✅ Luxury/prestige products
- ✅ Low volume, high value
- ✅ Campaign/event-driven demand
- ✅ Expert judgment critical
- ✅ Statistical models insufficient
- ✅ Manual adjustments frequent
- ✅ Strategic/trend-sensitive forecasting

---

**Document Version:** 1.0
**Last Updated:** 2025-11-19
**Related:** [MAPPING_MATRIX_OVERVIEW.md](./MAPPING_MATRIX_OVERVIEW.md) | [MAPPING_MATRIX_CPD.md](./MAPPING_MATRIX_CPD.md) | [MAPPING_MATRIX_LDB.md](./MAPPING_MATRIX_LDB.md) | [MAPPING_MATRIX_LLD.md](./MAPPING_MATRIX_LLD.md)
