# 99 - Appendix: Data Dictionary and Canonical Data Model

**Document Version**: 1.0
**Last Updated**: 2025-01-29
**Owner**: Finance Director + IT Manager
**Classification**: Technical Reference

---

## Executive Summary

This document defines the **canonical data model** for Odoo 18 CE financial close operations, establishing `account.move.line` (journal item) as the single source of truth for all financial transactions. The data model follows a **layered architecture (L0-L9)** mapping Odoo's ERP entities to analytical/BI structures optimized for reporting and compliance.

**Core Design Principles**:
- **Single Source of Truth**: All financial reporting derives from `account.move.line` table
- **Star Schema Design**: Fact tables (transactions) surrounded by dimension tables (accounts, partners, periods)
- **OCA Extension Mapping**: Clear documentation of which OCA modules extend base Odoo tables
- **Audit Trail Completeness**: Every transaction traceable to originating document and responsible user
- **BI/ETL Optimization**: Pre-aggregated views and materialized tables for analytics performance

**Primary Use Cases**:
1. **Financial Close Teams**: Understand data relationships for reconciliations and variance analysis
2. **BI/Analytics Developers**: Design dashboards and reports with correct data lineage
3. **External Auditors**: Navigate data model for audit sampling and testing
4. **System Integrators**: Map external system data to Odoo canonical structure

---

## 1. Layered Data Architecture (L0-L9)

### 1.1 Layer Definitions

```
L0: RAW TRANSACTIONAL DATA (Odoo Base Tables)
   → account.move, account.move.line, account.payment
   → Immutable after posting, audit trail preserved

L1: MASTER DATA (Reference Tables)
   → account.account, res.partner, product.product
   → Slowly changing dimensions (SCD Type 2 for historical tracking)

L2: CLASSIFICATION & HIERARCHY (Grouping Tables)
   → account.group, product.category, res.partner.category
   → Hierarchical structures for rollup reporting

L3: TEMPORAL DIMENSIONS (Period Tables)
   → account.fiscal.year, account.period, date_dimension
   → Calendar intelligence (fiscal periods, BIR deadlines)

L4: DERIVED ATTRIBUTES (Computed Fields)
   → account.move.line.computed (materialized view)
   → Pre-calculated balances, exchange rates, aging buckets

L5: AGGREGATED FACTS (Summary Tables)
   → account.financial.report.line, account.trial.balance
   → Pre-aggregated balances for performance (refreshed daily)

L6: RECONCILIATION STATE (Matching Tables)
   → account.partial.reconcile, account.bank.statement.line
   → Links between AR/AP transactions and payments

L7: ANALYTICAL DIMENSIONS (Cost Accounting)
   → account.analytic.account, account.analytic.line
   → Project, department, cost center tracking

L8: COMPLIANCE & AUDIT (BIR/Tax Tables)
   → l10n.ph.bir.1601c, l10n.ph.bir.2550q
   → Tax return data, withholding tax registers

L9: EXTERNAL INTEGRATIONS (ETL Staging)
   → scout.etl_queue, scout.bronze_transactions
   → External system data before Odoo import
```

### 1.2 Data Flow and Lineage

```
SOURCE DOCUMENTS (Purchase Order, Sales Order, Expense Claim)
   ↓ (Create)
L0: account.move (Invoice/Bill/Payment)
   ↓ (Post)
L0: account.move.line (Journal Items - CANONICAL FACT TABLE)
   ↓ (Enrich with)
L1: account.account (Chart of Accounts)
L1: res.partner (Customer/Vendor)
L3: account.fiscal.year (Period)
L7: account.analytic.account (Cost Center)
   ↓ (Match with)
L6: account.partial.reconcile (Payment Application)
   ↓ (Aggregate to)
L5: account.trial.balance (Summary by Account)
L5: account.financial.report.line (Financial Statements)
   ↓ (Report via)
BI/ANALYTICS LAYER (Apache Superset, Tableau, Excel)
```

---

## 2. Canonical Fact Table: `account.move.line`

### 2.1 Table Purpose and Scope

**Purpose**: Single source of truth for all financial transactions (journal entries, invoices, payments, accruals)

**Scope**: Every debit and credit in the general ledger represented as a row in this table

**Cardinality**: Millions of rows (grows continuously with business activity)

**Primary Key**: `id` (BIGSERIAL)

**Business Key**: `(move_id, account_id, partner_id, date)` (functional uniqueness not enforced, multiple lines allowed per combination)

### 2.2 Core Schema (Odoo Base Fields)

```sql
CREATE TABLE account_move_line (
  -- Identity
  id BIGSERIAL PRIMARY KEY,
  move_id BIGINT NOT NULL REFERENCES account_move ON DELETE CASCADE,
  company_id BIGINT NOT NULL REFERENCES res_company ON DELETE RESTRICT,

  -- Financial Dimensions
  account_id BIGINT NOT NULL REFERENCES account_account ON DELETE RESTRICT,
  partner_id BIGINT REFERENCES res_partner ON DELETE RESTRICT,
  currency_id BIGINT REFERENCES res_currency ON DELETE RESTRICT,

  -- Temporal Dimensions
  date DATE NOT NULL,  -- Accounting date (may differ from invoice date)
  date_maturity DATE,  -- Due date for AR/AP

  -- Monetary Amounts (Base Currency)
  debit NUMERIC(16,2) DEFAULT 0.00 CHECK (debit >= 0),
  credit NUMERIC(16,2) DEFAULT 0.00 CHECK (credit >= 0),
  balance NUMERIC(16,2) GENERATED ALWAYS AS (debit - credit) STORED,

  -- Monetary Amounts (Foreign Currency)
  amount_currency NUMERIC(16,2),  -- Original transaction currency amount
  amount_residual NUMERIC(16,2),  -- Unpaid balance (for AR/AP)
  amount_residual_currency NUMERIC(16,2),  -- Unpaid balance in foreign currency

  -- Reconciliation State
  reconciled BOOLEAN DEFAULT FALSE,
  full_reconcile_id BIGINT REFERENCES account_full_reconcile ON DELETE SET NULL,
  matching_number TEXT,  -- Group reconciled lines

  -- Analytics
  analytic_account_id BIGINT REFERENCES account_analytic_account ON DELETE SET NULL,
  analytic_tag_ids BIGINT[],  -- Array of analytic tag IDs (many-to-many via array)

  -- Descriptive
  name TEXT,  -- Line description/memo
  ref TEXT,  -- Document reference (invoice number, check number)

  -- Tax Information
  tax_line_id BIGINT REFERENCES account_tax ON DELETE RESTRICT,  -- If line represents tax
  tax_ids BIGINT[],  -- Taxes applied to this line (for base amount lines)
  tax_exigible BOOLEAN DEFAULT TRUE,  -- Tax due immediately (vs. cash basis)

  -- Product Information (if line related to goods/services)
  product_id BIGINT REFERENCES product_product ON DELETE RESTRICT,
  product_uom_id BIGINT REFERENCES uom_uom ON DELETE RESTRICT,
  quantity NUMERIC(16,4),
  price_unit NUMERIC(16,4),
  discount NUMERIC(5,2),  -- Percentage

  -- Audit Trail
  create_date TIMESTAMP DEFAULT NOW(),
  create_uid BIGINT REFERENCES res_users,
  write_date TIMESTAMP DEFAULT NOW(),
  write_uid BIGINT REFERENCES res_users,

  -- Computed/Indexed Fields
  account_internal_type TEXT,  -- Denormalized from account.account (receivable, payable, liquidity, other)
  journal_id BIGINT NOT NULL REFERENCES account_journal ON DELETE RESTRICT,

  -- Constraints
  CONSTRAINT debit_credit_not_both CHECK (debit = 0 OR credit = 0),  -- Line cannot have both debit and credit
  CONSTRAINT amount_currency_check CHECK (
    (currency_id IS NULL AND amount_currency IS NULL) OR
    (currency_id IS NOT NULL AND amount_currency IS NOT NULL)
  )
);

-- Indexes for Performance
CREATE INDEX idx_aml_move_id ON account_move_line(move_id);
CREATE INDEX idx_aml_account_id ON account_move_line(account_id);
CREATE INDEX idx_aml_partner_id ON account_move_line(partner_id) WHERE partner_id IS NOT NULL;
CREATE INDEX idx_aml_date ON account_move_line(date);
CREATE INDEX idx_aml_reconciled ON account_move_line(reconciled) WHERE reconciled = FALSE;
CREATE INDEX idx_aml_balance ON account_move_line(balance) WHERE balance != 0;
CREATE INDEX idx_aml_company_date ON account_move_line(company_id, date);
```

### 2.3 OCA Extension Fields (Common Add-ons)

**From `account_financial_report` (OCA)**:
```sql
ALTER TABLE account_move_line ADD COLUMN IF NOT EXISTS
  report_group_id BIGINT REFERENCES account_group;  -- Link to financial statement grouping
```

**From `account_reconcile_oca` (OCA)**:
```sql
ALTER TABLE account_move_line ADD COLUMN IF NOT EXISTS
  reconcile_model_id BIGINT REFERENCES account_reconcile_model;  -- Automated matching rule used
```

**From `account_payment_term_extension` (OCA)**:
```sql
ALTER TABLE account_move_line ADD COLUMN IF NOT EXISTS
  payment_term_line_id BIGINT REFERENCES account_payment_term_line;  -- Payment schedule installment
```

**From `l10n_ph_bir` (Philippine BIR Compliance)**:
```sql
ALTER TABLE account_move_line ADD COLUMN IF NOT EXISTS
  bir_atc_code TEXT,  -- BIR Alphanumeric Tax Code (e.g., WI010 for professional fees)
  withholding_tax_rate NUMERIC(5,2),  -- CWT rate applied (1%, 2%, 5%, 10%, 15%)
  bir_tax_base NUMERIC(16,2);  -- Base amount for tax calculation
```

**From `analytic_tag_dimension` (OCA)**:
```sql
ALTER TABLE account_move_line ADD COLUMN IF NOT EXISTS
  analytic_dimension_1 BIGINT REFERENCES analytic_dimension,  -- Custom dimension (e.g., Project Phase)
  analytic_dimension_2 BIGINT REFERENCES analytic_dimension;  -- Custom dimension (e.g., Funding Source)
```

### 2.4 Computed/Materialized View: `account_move_line_computed`

**Purpose**: Pre-calculate expensive joins and computations for analytics performance

```sql
CREATE MATERIALIZED VIEW account_move_line_computed AS
SELECT
  aml.id,
  aml.move_id,
  aml.company_id,
  aml.account_id,
  aml.partner_id,
  aml.date,
  aml.debit,
  aml.credit,
  aml.balance,
  aml.amount_currency,
  aml.currency_id,
  aml.reconciled,
  aml.analytic_account_id,

  -- Enriched from account.move (parent)
  am.name AS move_name,
  am.state AS move_state,  -- draft, posted, cancel
  am.move_type AS move_type,  -- entry, out_invoice, in_invoice, out_refund, in_refund, out_receipt, in_receipt
  am.ref AS move_ref,
  am.invoice_date,
  am.invoice_payment_term_id,

  -- Enriched from account.account
  aa.code AS account_code,
  aa.name AS account_name,
  aa.user_type_id AS account_type_id,
  aa.internal_type AS account_internal_type,  -- receivable, payable, liquidity, other
  aa.reconcile AS account_reconcilable,
  aa.deprecated AS account_deprecated,

  -- Enriched from res.partner
  rp.name AS partner_name,
  rp.vat AS partner_vat,
  rp.ref AS partner_ref,
  rp.company_type AS partner_type,  -- person, company

  -- Enriched from account.journal
  aj.name AS journal_name,
  aj.code AS journal_code,
  aj.type AS journal_type,  -- sale, purchase, cash, bank, general

  -- Enriched from account.fiscal.year
  EXTRACT(YEAR FROM aml.date) AS fiscal_year,
  EXTRACT(QUARTER FROM aml.date) AS fiscal_quarter,
  EXTRACT(MONTH FROM aml.date) AS fiscal_month,

  -- Aging Calculation (as of view refresh date)
  CURRENT_DATE - aml.date AS age_days,
  CASE
    WHEN aml.reconciled THEN 'Reconciled'
    WHEN CURRENT_DATE - aml.date <= 30 THEN 'Current'
    WHEN CURRENT_DATE - aml.date BETWEEN 31 AND 60 THEN '31-60 Days'
    WHEN CURRENT_DATE - aml.date BETWEEN 61 AND 90 THEN '61-90 Days'
    WHEN CURRENT_DATE - aml.date > 90 THEN '90+ Days'
  END AS aging_bucket,

  -- Reconciliation Status
  CASE
    WHEN aml.reconciled THEN 'Fully Reconciled'
    WHEN aml.amount_residual = 0 THEN 'Fully Paid'
    WHEN aml.amount_residual > 0 AND aml.amount_residual < ABS(aml.balance) THEN 'Partially Paid'
    WHEN aml.amount_residual = ABS(aml.balance) THEN 'Unpaid'
    ELSE 'Unknown'
  END AS payment_status,

  -- Audit Trail
  aml.create_date,
  aml.create_uid,
  cu.login AS created_by,
  aml.write_date,
  aml.write_uid,
  wu.login AS updated_by

FROM account_move_line aml
  INNER JOIN account_move am ON aml.move_id = am.id
  INNER JOIN account_account aa ON aml.account_id = aa.id
  LEFT JOIN res_partner rp ON aml.partner_id = rp.id
  INNER JOIN account_journal aj ON aml.journal_id = aj.id
  LEFT JOIN res_users cu ON aml.create_uid = cu.id
  LEFT JOIN res_users wu ON aml.write_uid = wu.id
WHERE am.state = 'posted';  -- Only posted (finalized) entries

-- Indexes on Materialized View
CREATE INDEX idx_amlc_account_id ON account_move_line_computed(account_id);
CREATE INDEX idx_amlc_partner_id ON account_move_line_computed(partner_id);
CREATE INDEX idx_amlc_date ON account_move_line_computed(date);
CREATE INDEX idx_amlc_fiscal_year ON account_move_line_computed(fiscal_year);
CREATE INDEX idx_amlc_aging_bucket ON account_move_line_computed(aging_bucket);
CREATE INDEX idx_amlc_payment_status ON account_move_line_computed(payment_status);

-- Refresh Strategy (daily at 2 AM)
-- Option 1: Full refresh (safe but slower)
REFRESH MATERIALIZED VIEW account_move_line_computed;

-- Option 2: Concurrent refresh (faster, allows reads during refresh)
REFRESH MATERIALIZED VIEW CONCURRENTLY account_move_line_computed;
```

---

## 3. Master Data Tables (L1)

### 3.1 Chart of Accounts: `account.account`

**Purpose**: Define general ledger accounts (assets, liabilities, equity, revenue, expenses)

**Cardinality**: 100-500 accounts (relatively static)

**Schema**:
```sql
CREATE TABLE account_account (
  id BIGSERIAL PRIMARY KEY,
  company_id BIGINT NOT NULL REFERENCES res_company ON DELETE RESTRICT,

  -- Account Identity
  code VARCHAR(64) NOT NULL,  -- Account number (e.g., "1010", "5100")
  name VARCHAR(256) NOT NULL,  -- Account name (e.g., "Cash - Operating Account")

  -- Account Classification
  user_type_id BIGINT NOT NULL REFERENCES account_account_type ON DELETE RESTRICT,  -- Links to financial report category
  internal_type VARCHAR(32),  -- receivable, payable, liquidity, other
  internal_group VARCHAR(32),  -- off_balance, equity, asset, liability, income, expense

  -- Hierarchy
  group_id BIGINT REFERENCES account_group ON DELETE SET NULL,  -- Parent group for rollup
  root_id BIGINT REFERENCES account_account ON DELETE SET NULL,  -- Top-level parent

  -- Behavior Flags
  reconcile BOOLEAN DEFAULT FALSE,  -- Allow reconciliation (AR/AP/Bank)
  deprecated BOOLEAN DEFAULT FALSE,  -- Inactive account (hide from selection)

  -- Tax Defaults
  tax_ids BIGINT[],  -- Default taxes for this account

  -- Currency
  currency_id BIGINT REFERENCES res_currency ON DELETE RESTRICT,  -- Force specific currency (optional)

  -- Audit
  create_date TIMESTAMP DEFAULT NOW(),
  write_date TIMESTAMP DEFAULT NOW(),

  CONSTRAINT unique_account_code_company UNIQUE (code, company_id)
);

-- OCA Extension: Financial Report Mapping
ALTER TABLE account_account ADD COLUMN IF NOT EXISTS
  financial_report_line_id BIGINT REFERENCES account_financial_report_line;
```

**Key Relationships**:
- 1 account → many `account.move.line` (all transactions in this account)
- 1 account → 1 `account.account.type` (classification for reporting)
- 1 account → 1 `account.group` (optional grouping for hierarchy)

### 3.2 Partners (Customers/Vendors): `res.partner`

**Purpose**: Unified contact registry (customers, vendors, employees, contacts)

**Cardinality**: 1,000-10,000 partners (actively growing)

**Schema**:
```sql
CREATE TABLE res_partner (
  id BIGSERIAL PRIMARY KEY,
  company_id BIGINT REFERENCES res_company ON DELETE RESTRICT,  -- NULL for shared partners

  -- Partner Identity
  name VARCHAR(256) NOT NULL,
  ref VARCHAR(64),  -- Internal reference code
  vat VARCHAR(32),  -- Tax ID / VAT number

  -- Partner Type
  company_type VARCHAR(32),  -- person, company
  is_company BOOLEAN DEFAULT FALSE,
  parent_id BIGINT REFERENCES res_partner ON DELETE SET NULL,  -- Parent company (for contacts)

  -- Classification
  customer_rank INTEGER DEFAULT 0,  -- Number of sales invoices (0 = not a customer)
  supplier_rank INTEGER DEFAULT 0,  -- Number of purchase bills (0 = not a vendor)

  -- Financial Accounts
  property_account_receivable_id BIGINT REFERENCES account_account,  -- Default AR account
  property_account_payable_id BIGINT REFERENCES account_account,  -- Default AP account
  property_payment_term_id BIGINT REFERENCES account_payment_term,  -- Default payment terms
  property_supplier_payment_term_id BIGINT REFERENCES account_payment_term,

  -- Contact Information
  email VARCHAR(256),
  phone VARCHAR(64),
  mobile VARCHAR(64),
  website VARCHAR(256),

  -- Address
  street VARCHAR(256),
  street2 VARCHAR(256),
  city VARCHAR(128),
  state_id BIGINT REFERENCES res_country_state,
  zip VARCHAR(24),
  country_id BIGINT REFERENCES res_country,

  -- Business
  industry_id BIGINT REFERENCES res_partner_industry,
  category_id BIGINT[],  -- Array of category IDs (tags)

  -- Flags
  active BOOLEAN DEFAULT TRUE,

  -- Audit
  create_date TIMESTAMP DEFAULT NOW(),
  write_date TIMESTAMP DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_partner_customer_rank ON res_partner(customer_rank) WHERE customer_rank > 0;
CREATE INDEX idx_partner_supplier_rank ON res_partner(supplier_rank) WHERE supplier_rank > 0;
CREATE INDEX idx_partner_vat ON res_partner(vat) WHERE vat IS NOT NULL;
```

**OCA Extension**: Multi-company partner reconciliation
```sql
ALTER TABLE res_partner ADD COLUMN IF NOT EXISTS
  inter_company_trade_account_id BIGINT REFERENCES account_account;  -- Intercompany clearing account
```

### 3.3 Products: `product.product`

**Purpose**: Goods and services sold/purchased (only relevant for expense/revenue lines with product tracking)

**Cardinality**: 100-10,000 products (depending on business)

**Schema**:
```sql
CREATE TABLE product_product (
  id BIGSERIAL PRIMARY KEY,
  product_tmpl_id BIGINT NOT NULL REFERENCES product_template ON DELETE CASCADE,

  -- Product Identity
  default_code VARCHAR(64),  -- SKU / Product Code
  barcode VARCHAR(64),

  -- Attributes (variants)
  -- (Handled via product_template_attribute_value relation)

  -- Financial Accounts
  property_account_income_id BIGINT REFERENCES account_account,  -- Revenue account
  property_account_expense_id BIGINT REFERENCES account_account,  -- Expense/COGS account

  -- Flags
  active BOOLEAN DEFAULT TRUE,

  CONSTRAINT unique_product_default_code UNIQUE (default_code) WHERE default_code IS NOT NULL
);

CREATE TABLE product_template (
  id BIGSERIAL PRIMARY KEY,

  -- Product Master Data
  name VARCHAR(256) NOT NULL,
  description TEXT,
  type VARCHAR(32),  -- consu (consumable), service, product (storable)

  -- Category
  categ_id BIGINT NOT NULL REFERENCES product_category ON DELETE RESTRICT,

  -- Pricing
  list_price NUMERIC(16,2),  -- Sale price
  standard_price NUMERIC(16,2),  -- Cost price

  -- Unit of Measure
  uom_id BIGINT NOT NULL REFERENCES uom_uom,
  uom_po_id BIGINT NOT NULL REFERENCES uom_uom,

  -- Tax Defaults
  taxes_id BIGINT[],  -- Sales taxes
  supplier_taxes_id BIGINT[],  -- Purchase taxes

  -- Flags
  active BOOLEAN DEFAULT TRUE,
  sale_ok BOOLEAN DEFAULT TRUE,
  purchase_ok BOOLEAN DEFAULT TRUE
);
```

---

## 4. Temporal Dimensions (L3)

### 4.1 Fiscal Year and Periods: `account.fiscal.year`

**Purpose**: Define fiscal year boundaries for period locking and reporting

**Schema**:
```sql
CREATE TABLE account_fiscal_year (
  id BIGSERIAL PRIMARY KEY,
  company_id BIGINT NOT NULL REFERENCES res_company ON DELETE RESTRICT,

  name VARCHAR(64) NOT NULL,  -- E.g., "FY 2025"
  date_from DATE NOT NULL,
  date_to DATE NOT NULL,

  CONSTRAINT unique_fiscal_year_company UNIQUE (name, company_id),
  CONSTRAINT valid_date_range CHECK (date_to > date_from)
);
```

**Note**: Odoo 18 uses **fiscal year-based locking** (not individual periods). Lock dates stored in `res.company`:
```sql
ALTER TABLE res_company ADD COLUMN IF NOT EXISTS
  fiscalyear_lock_date DATE,  -- Transactions before this date cannot be modified
  period_lock_date DATE,  -- Transactions before this date cannot be modified (except by Advisors group)
  tax_lock_date DATE;  -- Tax-related transactions cannot be modified before this date
```

### 4.2 Date Dimension (BI Helper Table)

**Purpose**: Calendar intelligence for BI reporting (fiscal periods, BIR deadlines, holidays)

**Schema**:
```sql
CREATE TABLE date_dimension (
  date_key DATE PRIMARY KEY,

  -- Calendar Attributes
  year INTEGER,
  quarter INTEGER,
  month INTEGER,
  day INTEGER,
  day_of_week INTEGER,  -- 1=Monday, 7=Sunday
  day_of_year INTEGER,
  week_of_year INTEGER,

  -- Fiscal Attributes (assuming Jan 1 fiscal year start)
  fiscal_year INTEGER,
  fiscal_quarter INTEGER,
  fiscal_month INTEGER,
  fiscal_period TEXT,  -- E.g., "2025-01" for January 2025

  -- Business Day Flags
  is_weekday BOOLEAN,
  is_weekend BOOLEAN,
  is_holiday BOOLEAN,  -- Philippine holidays
  is_working_day BOOLEAN,  -- weekday AND NOT holiday

  -- BIR Filing Deadlines
  is_bir_1601c_deadline BOOLEAN,  -- 10th of month
  is_bir_2550q_deadline BOOLEAN,  -- 60 days after quarter end

  -- Relative Periods (for variance analysis)
  prior_day DATE,
  prior_week_same_day DATE,
  prior_month_same_day DATE,
  prior_year_same_day DATE,

  -- Month Attributes
  month_name VARCHAR(32),
  month_start_date DATE,
  month_end_date DATE,
  days_in_month INTEGER,

  -- Quarter Attributes
  quarter_name VARCHAR(32),  -- E.g., "Q1 2025"
  quarter_start_date DATE,
  quarter_end_date DATE
);

-- Generate Date Dimension for 10 years (2020-2030)
INSERT INTO date_dimension (date_key, year, quarter, month, day, ...)
SELECT
  d::DATE AS date_key,
  EXTRACT(YEAR FROM d)::INTEGER AS year,
  EXTRACT(QUARTER FROM d)::INTEGER AS quarter,
  EXTRACT(MONTH FROM d)::INTEGER AS month,
  EXTRACT(DAY FROM d)::INTEGER AS day,
  EXTRACT(ISODOW FROM d)::INTEGER AS day_of_week,
  EXTRACT(DOY FROM d)::INTEGER AS day_of_year,
  EXTRACT(WEEK FROM d)::INTEGER AS week_of_year,
  -- ... (compute all attributes)
FROM generate_series('2020-01-01'::DATE, '2030-12-31'::DATE, '1 day'::INTERVAL) AS d;
```

---

## 5. Star Schema Design for BI/Analytics

### 5.1 Fact Table: `fact_gl_transaction`

**Purpose**: Denormalized fact table optimized for analytics (pre-joined with dimensions)

**ETL Frequency**: Daily (incremental load of new/modified `account.move.line` records)

**Schema**:
```sql
CREATE TABLE fact_gl_transaction (
  -- Fact Identity
  fact_id BIGSERIAL PRIMARY KEY,
  move_line_id BIGINT NOT NULL UNIQUE REFERENCES account_move_line,  -- Link back to source

  -- Dimension Foreign Keys
  account_key INTEGER NOT NULL REFERENCES dim_account(account_key),
  partner_key INTEGER REFERENCES dim_partner(partner_key),
  date_key DATE NOT NULL REFERENCES date_dimension(date_key),
  journal_key INTEGER NOT NULL REFERENCES dim_journal(journal_key),
  company_key INTEGER NOT NULL REFERENCES dim_company(company_key),
  analytic_account_key INTEGER REFERENCES dim_analytic_account(analytic_account_key),
  product_key INTEGER REFERENCES dim_product(product_key),

  -- Measures (Additive)
  debit_amount NUMERIC(16,2) DEFAULT 0.00,
  credit_amount NUMERIC(16,2) DEFAULT 0.00,
  balance_amount NUMERIC(16,2),
  amount_currency NUMERIC(16,2),
  amount_residual NUMERIC(16,2),  -- Unpaid balance

  -- Non-Additive Measures
  quantity NUMERIC(16,4),
  price_unit NUMERIC(16,4),

  -- Degenerate Dimensions (low-cardinality attributes stored in fact)
  move_state VARCHAR(32),  -- draft, posted, cancel
  move_type VARCHAR(32),  -- entry, out_invoice, in_invoice, etc.
  reconciled BOOLEAN,

  -- Descriptive Attributes
  move_name VARCHAR(64),
  line_name TEXT,
  reference VARCHAR(64),

  -- ETL Metadata
  etl_load_date TIMESTAMP DEFAULT NOW(),
  etl_batch_id BIGINT,

  -- Indexes
  CREATE INDEX idx_fact_account_key ON fact_gl_transaction(account_key);
  CREATE INDEX idx_fact_partner_key ON fact_gl_transaction(partner_key);
  CREATE INDEX idx_fact_date_key ON fact_gl_transaction(date_key);
  CREATE INDEX idx_fact_company_date ON fact_gl_transaction(company_key, date_key);
);
```

### 5.2 Dimension Tables

#### 5.2.1 `dim_account` (Account Dimension)

```sql
CREATE TABLE dim_account (
  account_key SERIAL PRIMARY KEY,  -- Surrogate key
  account_id BIGINT NOT NULL UNIQUE,  -- Odoo natural key

  -- SCD Type 2 Attributes (track history)
  effective_date DATE NOT NULL DEFAULT CURRENT_DATE,
  expiry_date DATE DEFAULT '9999-12-31',
  is_current BOOLEAN DEFAULT TRUE,

  -- Account Attributes
  account_code VARCHAR(64),
  account_name VARCHAR(256),
  account_type VARCHAR(64),
  internal_type VARCHAR(32),
  internal_group VARCHAR(32),

  -- Hierarchy Attributes
  account_group_code VARCHAR(64),
  account_group_name VARCHAR(256),
  account_level_1 VARCHAR(256),  -- Top level (e.g., "Assets")
  account_level_2 VARCHAR(256),  -- Second level (e.g., "Current Assets")
  account_level_3 VARCHAR(256),  -- Third level (e.g., "Cash and Cash Equivalents")

  -- Flags
  is_reconcilable BOOLEAN,
  is_deprecated BOOLEAN,

  -- ETL Metadata
  etl_load_date TIMESTAMP DEFAULT NOW()
);
```

#### 5.2.2 `dim_partner` (Customer/Vendor Dimension)

```sql
CREATE TABLE dim_partner (
  partner_key SERIAL PRIMARY KEY,
  partner_id BIGINT NOT NULL UNIQUE,

  -- SCD Type 2
  effective_date DATE NOT NULL DEFAULT CURRENT_DATE,
  expiry_date DATE DEFAULT '9999-12-31',
  is_current BOOLEAN DEFAULT TRUE,

  -- Partner Attributes
  partner_name VARCHAR(256),
  partner_ref VARCHAR(64),
  partner_vat VARCHAR(32),
  partner_type VARCHAR(32),  -- person, company

  -- Classification
  is_customer BOOLEAN,
  is_supplier BOOLEAN,
  is_employee BOOLEAN,

  -- Contact
  email VARCHAR(256),
  phone VARCHAR(64),
  city VARCHAR(128),
  country VARCHAR(64),

  -- Business
  industry VARCHAR(128),

  -- ETL Metadata
  etl_load_date TIMESTAMP DEFAULT NOW()
);
```

#### 5.2.3 `dim_journal` (Journal Dimension)

```sql
CREATE TABLE dim_journal (
  journal_key SERIAL PRIMARY KEY,
  journal_id BIGINT NOT NULL UNIQUE,

  -- Journal Attributes
  journal_code VARCHAR(16),
  journal_name VARCHAR(128),
  journal_type VARCHAR(32),  -- sale, purchase, cash, bank, general

  -- Flags
  is_default_journal BOOLEAN,

  -- ETL Metadata
  etl_load_date TIMESTAMP DEFAULT NOW()
);
```

#### 5.2.4 `dim_company` (Multi-Company Dimension)

```sql
CREATE TABLE dim_company (
  company_key SERIAL PRIMARY KEY,
  company_id BIGINT NOT NULL UNIQUE,

  -- Company Attributes
  company_name VARCHAR(256),
  company_code VARCHAR(16),
  company_vat VARCHAR(32),
  company_currency VARCHAR(3),

  -- Hierarchy (if holding company structure)
  parent_company_name VARCHAR(256),

  -- ETL Metadata
  etl_load_date TIMESTAMP DEFAULT NOW()
);
```

### 5.3 ETL Process: Odoo → Star Schema

**ETL Tool**: n8n workflow or custom Python script (using Supabase RPC)

**ETL Steps**:
1. **Extract**: Query `account.move.line` for new/modified records (incremental based on `write_date`)
2. **Transform**:
   - Join with dimension tables (`account.account`, `res.partner`, etc.)
   - Lookup dimension surrogate keys (or create new dimension records if needed)
   - Apply business rules (e.g., classify move types, compute aging buckets)
3. **Load**:
   - Insert/update `fact_gl_transaction` table
   - Update ETL metadata (batch ID, load timestamp)
4. **Validate**:
   - Reconcile fact table totals to Odoo trial balance
   - Alert if variance >₱1,000 (indicates ETL error)

**ETL Schedule**: Daily at 3 AM (after Odoo close operations complete)

---

## 6. Reconciliation Data Model (L6)

### 6.1 Partial Reconcile: `account.partial.reconcile`

**Purpose**: Link AR/AP transactions to payments (many-to-many relationship)

**Schema**:
```sql
CREATE TABLE account_partial_reconcile (
  id BIGSERIAL PRIMARY KEY,
  company_id BIGINT NOT NULL REFERENCES res_company,

  -- Reconciled Lines
  debit_move_id BIGINT NOT NULL REFERENCES account_move_line,  -- Invoice or credit memo
  credit_move_id BIGINT NOT NULL REFERENCES account_move_line,  -- Payment or debit memo

  -- Reconciliation Amounts
  amount NUMERIC(16,2) NOT NULL,  -- Amount reconciled (in company currency)
  amount_currency NUMERIC(16,2),  -- Amount in foreign currency (if applicable)

  -- Full Reconcile (when invoice fully paid)
  full_reconcile_id BIGINT REFERENCES account_full_reconcile ON DELETE SET NULL,

  -- Audit
  create_date TIMESTAMP DEFAULT NOW(),
  create_uid BIGINT REFERENCES res_users
);
```

**Example Reconciliation**:
```
Invoice (account.move.line): Debit AR ₱100,000 (debit_move_id = 12345)
Payment (account.move.line): Credit AR ₱100,000 (credit_move_id = 67890)

Partial Reconcile Record:
  debit_move_id = 12345
  credit_move_id = 67890
  amount = ₱100,000
  full_reconcile_id = 111 (created when invoice fully paid)
```

### 6.2 Full Reconcile: `account.full.reconcile`

**Purpose**: Group all partial reconciles when transaction fully cleared

**Schema**:
```sql
CREATE TABLE account_full_reconcile (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(64),  -- Auto-generated reconciliation number (e.g., "FULL/2025/0001")

  -- Reconciled Lines (many-to-many via account.partial.reconcile)
  -- Sum of partial reconciles should equal zero (fully reconciled)

  -- Audit
  create_date TIMESTAMP DEFAULT NOW(),
  create_uid BIGINT REFERENCES res_users
);
```

**Query: Outstanding AR Balance per Customer**:
```sql
SELECT
  rp.name AS customer_name,
  SUM(aml.amount_residual) AS outstanding_balance,
  COUNT(*) AS open_invoice_count
FROM account_move_line aml
  INNER JOIN res_partner rp ON aml.partner_id = rp.id
  INNER JOIN account_account aa ON aml.account_id = aa.id
WHERE aa.internal_type = 'receivable'
  AND aml.reconciled = FALSE
  AND aml.amount_residual > 0
GROUP BY rp.id, rp.name
ORDER BY outstanding_balance DESC;
```

---

## 7. Analytical Dimensions (L7)

### 7.1 Analytic Accounts: `account.analytic.account`

**Purpose**: Cost center, project, department tracking (orthogonal to chart of accounts)

**Schema**:
```sql
CREATE TABLE account_analytic_account (
  id BIGSERIAL PRIMARY KEY,
  company_id BIGINT REFERENCES res_company,

  -- Analytic Account Identity
  name VARCHAR(256) NOT NULL,
  code VARCHAR(64),

  -- Hierarchy
  parent_id BIGINT REFERENCES account_analytic_account ON DELETE SET NULL,

  -- Classification
  plan_id BIGINT REFERENCES account_analytic_plan,  -- E.g., "Projects", "Departments"

  -- Flags
  active BOOLEAN DEFAULT TRUE,

  -- Partner (if project-based)
  partner_id BIGINT REFERENCES res_partner
);
```

**Usage**: Tag `account.move.line` with `analytic_account_id` for multi-dimensional reporting

**Example**: Revenue by Product Line and Geographic Region
- GL Account: "4000 - Product Sales" (revenue account)
- Analytic Account 1: "Product Line A" (analytic_account_id)
- Analytic Account 2: "Region - NCR" (via analytic tags)

### 7.2 Analytic Tags: `account.analytic.tag`

**Purpose**: Additional flexible tagging (many-to-many with journal lines)

**Schema**:
```sql
CREATE TABLE account_analytic_tag (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(128) NOT NULL,
  color INTEGER,  -- UI color coding
  active BOOLEAN DEFAULT TRUE
);

-- Many-to-many relation (account.move.line stores tag IDs as array)
-- account_move_line.analytic_tag_ids BIGINT[]
```

**Use Cases**:
- Geographic regions (NCR, Luzon, Visayas, Mindanao)
- Funding sources (Government, Private, Self-funded)
- Project phases (Planning, Execution, Closeout)

---

## 8. BIR Compliance Data Model (L8)

### 8.1 BIR Form 1601-C: `l10n.ph.bir.1601c`

**Purpose**: Monthly withholding tax return data (creditable withholding tax on compensation)

**Schema**:
```sql
CREATE TABLE l10n_ph_bir_1601c (
  id BIGSERIAL PRIMARY KEY,
  company_id BIGINT NOT NULL REFERENCES res_company,

  -- Filing Period
  period_month INTEGER NOT NULL CHECK (period_month BETWEEN 1 AND 12),
  period_year INTEGER NOT NULL,

  -- Tax Computation
  total_compensation NUMERIC(16,2),  -- Gross compensation paid
  total_non_taxable NUMERIC(16,2),  -- De minimis, 13th month (up to ₱90,000)
  total_taxable_compensation NUMERIC(16,2),  -- Total - Non-taxable
  total_tax_withheld NUMERIC(16,2),  -- Total withholding tax remitted

  -- Tax Due
  tax_withheld_current_remittance NUMERIC(16,2),  -- Amount due this month

  -- Filing Status
  state VARCHAR(32),  -- draft, submitted, filed
  filing_date DATE,
  filing_reference VARCHAR(64),  -- eFPS confirmation number

  -- Supporting Data (JSON for flexibility)
  employee_details JSONB,  -- Array of {employee_id, name, tin, gross, tax_withheld}

  -- Audit
  create_date TIMESTAMP DEFAULT NOW(),
  write_date TIMESTAMP DEFAULT NOW(),

  CONSTRAINT unique_1601c_period UNIQUE (company_id, period_year, period_month)
);
```

**Supporting Table**: `l10n.ph.bir.withholding.line` (detail per employee)
```sql
CREATE TABLE l10n_ph_bir_withholding_line (
  id BIGSERIAL PRIMARY KEY,
  bir_1601c_id BIGINT NOT NULL REFERENCES l10n_ph_bir_1601c ON DELETE CASCADE,

  -- Employee
  employee_id BIGINT NOT NULL REFERENCES hr_employee,
  employee_name VARCHAR(256),
  employee_tin VARCHAR(32),

  -- Compensation
  gross_compensation NUMERIC(16,2),
  non_taxable_compensation NUMERIC(16,2),
  taxable_compensation NUMERIC(16,2),

  -- Tax
  tax_withheld NUMERIC(16,2),

  -- Link to Payslip
  payslip_id BIGINT REFERENCES hr_payslip
);
```

### 8.2 BIR Form 2550Q: `l10n.ph.bir.2550q`

**Purpose**: Quarterly VAT return

**Schema**:
```sql
CREATE TABLE l10n_ph_bir_2550q (
  id BIGSERIAL PRIMARY KEY,
  company_id BIGINT NOT NULL REFERENCES res_company,

  -- Filing Period
  period_quarter INTEGER NOT NULL CHECK (period_quarter BETWEEN 1 AND 4),
  period_year INTEGER NOT NULL,

  -- Sales
  vatable_sales NUMERIC(16,2),
  vat_exempt_sales NUMERIC(16,2),
  zero_rated_sales NUMERIC(16,2),

  -- Output VAT
  output_vat NUMERIC(16,2),  -- vatable_sales × 12%

  -- Purchases
  domestic_purchases NUMERIC(16,2),
  import_purchases NUMERIC(16,2),

  -- Input VAT
  input_vat NUMERIC(16,2),

  -- VAT Payable/Excess
  vat_payable NUMERIC(16,2),  -- output_vat - input_vat (if positive)
  vat_excess NUMERIC(16,2),  -- input_vat - output_vat (if negative, carried forward)

  -- Filing Status
  state VARCHAR(32),
  filing_date DATE,
  filing_reference VARCHAR(64),

  -- Audit
  create_date TIMESTAMP DEFAULT NOW(),
  write_date TIMESTAMP DEFAULT NOW(),

  CONSTRAINT unique_2550q_period UNIQUE (company_id, period_year, period_quarter)
);
```

---

## 9. External Integration Staging (L9)

### 9.1 Scout ETL Queue: `scout.etl_queue`

**Purpose**: Track ETL jobs for external data import (Google Drive exports, Excel cross-tabs)

**Schema**:
```sql
CREATE TABLE scout.etl_queue (
  id BIGSERIAL PRIMARY KEY,

  -- Job Identity
  job_name VARCHAR(128) NOT NULL,  -- E.g., "scout_transaction_import"
  job_type VARCHAR(64),  -- extract, transform, load

  -- Source
  source_system VARCHAR(64),  -- google_drive, excel, api
  source_file_path TEXT,
  source_file_hash VARCHAR(64),  -- Detect duplicate imports

  -- Target
  target_schema VARCHAR(64),  -- scout, public
  target_table VARCHAR(128),

  -- Status
  status VARCHAR(32) DEFAULT 'pending',  -- pending, running, completed, failed
  started_at TIMESTAMP,
  completed_at TIMESTAMP,

  -- Metrics
  records_extracted INTEGER,
  records_loaded INTEGER,
  records_failed INTEGER,

  -- Error Handling
  error_message TEXT,
  error_details JSONB,

  -- Audit
  created_at TIMESTAMP DEFAULT NOW(),
  created_by UUID REFERENCES auth.users
);
```

### 9.2 Bronze Layer: `scout.bronze_transactions`

**Purpose**: Raw extracted data before transformation (immutable staging)

**Schema**:
```sql
CREATE TABLE scout.bronze_transactions (
  id BIGSERIAL PRIMARY KEY,
  etl_job_id BIGINT NOT NULL REFERENCES scout.etl_queue,

  -- Source Metadata
  source_row_number INTEGER,
  source_file_name TEXT,

  -- Raw Data (JSON for flexibility)
  raw_data JSONB NOT NULL,  -- Original row as JSON (preserves all columns)

  -- ETL Metadata
  extracted_at TIMESTAMP DEFAULT NOW(),
  data_quality_score NUMERIC(3,2),  -- 0.00-1.00 (1.00 = perfect quality)

  CONSTRAINT unique_bronze_source_row UNIQUE (etl_job_id, source_row_number)
);
```

### 9.3 Silver Layer: `scout.silver_transactions`

**Purpose**: Cleaned and normalized data (type-converted, null-handled, duplicates removed)

**Schema**:
```sql
CREATE TABLE scout.silver_transactions (
  id BIGSERIAL PRIMARY KEY,
  bronze_id BIGINT NOT NULL REFERENCES scout.bronze_transactions,

  -- Standardized Columns (mapped from bronze.raw_data)
  transaction_date DATE NOT NULL,
  transaction_type VARCHAR(64),
  amount NUMERIC(16,2),
  currency VARCHAR(3) DEFAULT 'PHP',
  description TEXT,

  -- Matched Entities (links to Odoo master data)
  partner_id BIGINT REFERENCES res_partner,
  product_id BIGINT REFERENCES product_product,
  account_id BIGINT REFERENCES account_account,

  -- Data Quality Flags
  is_duplicate BOOLEAN DEFAULT FALSE,
  is_anomaly BOOLEAN DEFAULT FALSE,  -- Statistical outlier
  confidence_level NUMERIC(3,2),  -- Fuzzy matching confidence

  -- ETL Metadata
  transformed_at TIMESTAMP DEFAULT NOW()
);
```

### 9.4 Gold Layer: `scout.gold_expense_summary`

**Purpose**: Business-ready aggregated data (pre-computed metrics for dashboards)

**Schema**:
```sql
CREATE TABLE scout.gold_expense_summary (
  id BIGSERIAL PRIMARY KEY,

  -- Dimensions
  fiscal_period TEXT NOT NULL,  -- "2025-01"
  expense_category VARCHAR(128),
  agency_name VARCHAR(128),

  -- Measures
  total_expense NUMERIC(16,2),
  transaction_count INTEGER,
  average_expense NUMERIC(16,2),

  -- Data Lineage
  source_transaction_ids BIGINT[],  -- Array of silver_transaction IDs

  -- ETL Metadata
  aggregated_at TIMESTAMP DEFAULT NOW(),

  CONSTRAINT unique_gold_expense_period_category UNIQUE (fiscal_period, expense_category, agency_name)
);
```

---

## 10. OCA Module Extension Mapping

### 10.1 Financial Reporting Extensions

**Module**: `account_financial_report` (OCA)

**Extended Tables**:
- `account.account` → adds `financial_report_line_id` (link to report template)
- `account.move.line` → adds computed fields for report grouping

**New Tables**:
```sql
CREATE TABLE account_financial_report (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(128) NOT NULL,
  report_type VARCHAR(32),  -- balance_sheet, income_statement, cash_flow
  company_id BIGINT REFERENCES res_company
);

CREATE TABLE account_financial_report_line (
  id BIGSERIAL PRIMARY KEY,
  report_id BIGINT NOT NULL REFERENCES account_financial_report ON DELETE CASCADE,

  -- Line Identity
  name VARCHAR(256) NOT NULL,
  code VARCHAR(64),
  sequence INTEGER,

  -- Grouping
  parent_id BIGINT REFERENCES account_financial_report_line ON DELETE CASCADE,
  level INTEGER,

  -- Account Selection
  account_ids BIGINT[],  -- Array of account IDs to include
  account_group_id BIGINT REFERENCES account_group,

  -- Calculation
  formulas JSONB,  -- JSON formulas for computed lines (e.g., "Total Assets = Current + Non-Current")

  -- Display
  hide_if_zero BOOLEAN DEFAULT FALSE,
  bold BOOLEAN DEFAULT FALSE
);
```

### 10.2 Philippine BIR Localization

**Module**: `l10n_ph_bir` (Philippine localization)

**Extended Tables**:
- `account.move.line` → adds `bir_atc_code`, `withholding_tax_rate`, `bir_tax_base`
- `res.partner` → adds `bir_registered`, `bir_rdo_code`

**New Tables**: (See section 8.1, 8.2 for BIR form tables)

### 10.3 Multi-Company Reconciliation

**Module**: `account_reconcile_oca`

**Extended Tables**:
- `account.move.line` → adds `reconcile_model_id` (automated matching rule)

**New Tables**:
```sql
CREATE TABLE account_reconcile_model (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(128) NOT NULL,
  company_id BIGINT REFERENCES res_company,

  -- Matching Rules
  rule_type VARCHAR(32),  -- invoice_matching, payment_matching, bank_statement_matching
  match_journal_ids BIGINT[],
  match_nature VARCHAR(32),  -- debit, credit, both
  match_amount VARCHAR(32),  -- lower, greater, between
  match_amount_min NUMERIC(16,2),
  match_amount_max NUMERIC(16,2),

  -- Auto-Actions
  auto_reconcile BOOLEAN DEFAULT FALSE,

  -- Sequence
  sequence INTEGER
);
```

---

## 11. Query Examples and Analytics Patterns

### 11.1 Trial Balance Query

```sql
-- Monthly Trial Balance
SELECT
  aa.code AS account_code,
  aa.name AS account_name,
  SUM(aml.debit) AS total_debit,
  SUM(aml.credit) AS total_credit,
  SUM(aml.balance) AS net_balance
FROM account_move_line aml
  INNER JOIN account_account aa ON aml.account_id = aa.id
  INNER JOIN account_move am ON aml.move_id = am.id
WHERE am.state = 'posted'
  AND am.company_id = 1  -- Specific company
  AND aml.date BETWEEN '2025-01-01' AND '2025-01-31'
GROUP BY aa.code, aa.name
ORDER BY aa.code;
```

### 11.2 AR Aging Report

```sql
-- AR Aging Report (as of specific date)
SELECT
  rp.name AS customer_name,
  SUM(CASE WHEN CURRENT_DATE - aml.date <= 30 THEN aml.amount_residual ELSE 0 END) AS current,
  SUM(CASE WHEN CURRENT_DATE - aml.date BETWEEN 31 AND 60 THEN aml.amount_residual ELSE 0 END) AS days_31_60,
  SUM(CASE WHEN CURRENT_DATE - aml.date BETWEEN 61 AND 90 THEN aml.amount_residual ELSE 0 END) AS days_61_90,
  SUM(CASE WHEN CURRENT_DATE - aml.date > 90 THEN aml.amount_residual ELSE 0 END) AS days_90_plus,
  SUM(aml.amount_residual) AS total_outstanding
FROM account_move_line aml
  INNER JOIN res_partner rp ON aml.partner_id = rp.id
  INNER JOIN account_account aa ON aml.account_id = aa.id
  INNER JOIN account_move am ON aml.move_id = am.id
WHERE aa.internal_type = 'receivable'
  AND am.state = 'posted'
  AND aml.reconciled = FALSE
  AND aml.amount_residual > 0
  AND am.company_id = 1
GROUP BY rp.name
ORDER BY total_outstanding DESC;
```

### 11.3 Income Statement (P&L)

```sql
-- Income Statement (for specific period)
WITH pl_accounts AS (
  SELECT
    aa.id AS account_id,
    aa.code,
    aa.name,
    aa.internal_group,  -- income, expense
    SUM(aml.credit - aml.debit) AS net_amount  -- Revenue = Credit - Debit, Expense = Debit - Credit
  FROM account_account aa
    LEFT JOIN account_move_line aml ON aa.id = aml.account_id
    LEFT JOIN account_move am ON aml.move_id = am.id
  WHERE aa.internal_group IN ('income', 'expense')
    AND am.state = 'posted'
    AND aml.date BETWEEN '2025-01-01' AND '2025-01-31'
    AND am.company_id = 1
  GROUP BY aa.id, aa.code, aa.name, aa.internal_group
)
SELECT
  CASE
    WHEN internal_group = 'income' THEN 'REVENUE'
    WHEN internal_group = 'expense' THEN 'EXPENSES'
  END AS section,
  code,
  name,
  net_amount
FROM pl_accounts
ORDER BY internal_group DESC, code;

-- Calculate Net Income
SELECT
  SUM(CASE WHEN internal_group = 'income' THEN net_amount ELSE 0 END) -
  SUM(CASE WHEN internal_group = 'expense' THEN net_amount ELSE 0 END) AS net_income
FROM pl_accounts;
```

### 11.4 Cash Flow Statement (Direct Method)

```sql
-- Cash Flow Statement (simplified direct method)
SELECT
  CASE
    WHEN aa.code LIKE '1010%' THEN 'Operating Activities'  -- Cash receipts/payments
    WHEN aa.code LIKE '1020%' THEN 'Investing Activities'  -- Asset purchases/disposals
    WHEN aa.code LIKE '2010%' THEN 'Financing Activities'  -- Debt/equity transactions
  END AS cash_flow_category,
  SUM(aml.debit - aml.credit) AS net_cash_flow
FROM account_move_line aml
  INNER JOIN account_account aa ON aml.account_id = aa.id
  INNER JOIN account_move am ON aml.move_id = am.id
WHERE aa.internal_type = 'liquidity'  -- Cash and bank accounts
  AND am.state = 'posted'
  AND aml.date BETWEEN '2025-01-01' AND '2025-01-31'
  AND am.company_id = 1
GROUP BY cash_flow_category
ORDER BY cash_flow_category;
```

---

## 12. Data Governance and Quality

### 12.1 Data Quality Metrics

**Tracked Metrics** (stored in `data_quality_metrics` table):
```sql
CREATE TABLE data_quality_metrics (
  id BIGSERIAL PRIMARY KEY,
  metric_name VARCHAR(128) NOT NULL,
  metric_value NUMERIC(16,4),
  metric_threshold NUMERIC(16,4),  -- Alert if value exceeds/falls below threshold
  metric_date DATE NOT NULL DEFAULT CURRENT_DATE,

  -- Context
  table_name VARCHAR(128),
  company_id BIGINT REFERENCES res_company,

  -- Status
  status VARCHAR(32),  -- pass, fail, warning

  created_at TIMESTAMP DEFAULT NOW()
);

-- Example metrics:
INSERT INTO data_quality_metrics (metric_name, metric_value, metric_threshold, table_name, status)
VALUES
  ('trial_balance_variance', 0.00, 0.01, 'account_move_line', 'pass'),  -- Variance from balanced trial balance
  ('unreconciled_bank_balance', 15000.00, 10000.00, 'account_move_line', 'warning'),  -- Outstanding bank reconciling items
  ('null_partner_pct', 0.05, 0.10, 'account_move_line', 'pass'),  -- % of lines missing partner (for AR/AP)
  ('duplicate_invoice_count', 0, 1, 'account_move', 'pass');  -- Duplicate invoices detected
```

### 12.2 Data Lineage Tracking

**Purpose**: Trace data from source system → Bronze → Silver → Gold → BI Report

**Implementation**:
- Each ETL layer includes `source_id` or `parent_id` foreign key to prior layer
- ETL jobs logged in `scout.etl_queue` with timestamps and record counts
- Audit trail preserved in `account.move.line` (immutable after posting)

**Query: Trace Transaction Lineage**:
```sql
-- Start with Gold layer expense summary
SELECT
  ges.fiscal_period,
  ges.expense_category,
  ges.total_expense,

  -- Trace to Silver
  st.transaction_date,
  st.description,
  st.amount,

  -- Trace to Bronze
  bt.raw_data,
  bt.source_file_name,

  -- Trace to ETL Job
  eq.job_name,
  eq.started_at,
  eq.completed_at
FROM scout.gold_expense_summary ges
  CROSS JOIN UNNEST(ges.source_transaction_ids) AS silver_id
  INNER JOIN scout.silver_transactions st ON st.id = silver_id
  INNER JOIN scout.bronze_transactions bt ON st.bronze_id = bt.id
  INNER JOIN scout.etl_queue eq ON bt.etl_job_id = eq.id
WHERE ges.fiscal_period = '2025-01'
  AND ges.expense_category = 'Professional Fees';
```

### 12.3 Data Retention Policies

| Table | Retention Period | Archive Strategy | Justification |
|-------|------------------|------------------|---------------|
| `account.move.line` | 10 years (online) + permanent (archive) | Annual export to secure storage after 10 years | BIR statute of limitations (10 years) |
| `account.move` | 10 years (online) + permanent (archive) | Linked to `account.move.line` retention | BIR compliance |
| `account.partial.reconcile` | 7 years (online) + permanent (archive) | Export after 7 years | Audit requirement (7 years) |
| `scout.bronze_transactions` | 2 years (online) + 5 years (archive) | Move to cold storage after 2 years | Silver layer is canonical, bronze is staging |
| `scout.silver_transactions` | 10 years (online) + permanent (archive) | Annual export after 10 years | Primary analytical source |
| `scout.gold_expense_summary` | 10 years (online) | Refresh daily, archive annually | Derived from silver, can be regenerated |
| `data_quality_metrics` | 1 year (online) + 3 years (archive) | Aggregate to monthly summaries after 1 year | Operational metrics, not regulatory |

---

## 13. Appendix

### 13.1 Complete Entity Relationship Diagram (ERD)

```
┌─────────────────────┐
│   account.move      │ (Invoice/Bill/Payment)
│  ─────────────────  │
│ * id (PK)           │
│ * name              │◄─────────┐
│ * state             │          │
│ * move_type         │          │
│ * company_id (FK)   │          │
└─────────────────────┘          │
          │                      │
          │ 1:N                  │ N:1
          ▼                      │
┌─────────────────────┐          │
│ account.move.line   │ (CANONICAL FACT TABLE)
│  ─────────────────  │          │
│ * id (PK)           │          │
│ * move_id (FK) ─────┼──────────┘
│ * account_id (FK) ──┼──────────┐
│ * partner_id (FK) ──┼─────┐    │
│ * date              │     │    │
│ * debit             │     │    │
│ * credit            │     │    │
│ * balance           │     │    │
│ * reconciled        │     │    │
│ * analytic_acct_id ─┼─┐   │    │
└─────────────────────┘ │   │    │
          │             │   │    │
          │ N:1         │   │    │
          ▼             │   │    │
┌─────────────────────┐ │   │    │
│  account.account    │ │   │    │
│  ─────────────────  │ │   │    │
│ * id (PK) ◄─────────┼─┼───┼────┘
│ * code              │ │   │
│ * name              │ │   │
│ * internal_type     │ │   │
│ * reconcile         │ │   │
│ * group_id (FK) ────┼─┼─┐ │
└─────────────────────┘ │ │ │
                        │ │ │
          ┌─────────────┘ │ │
          │ N:1           │ │
          ▼               │ │
┌─────────────────────┐   │ │
│ account.analytic.   │   │ │
│       account       │   │ │
│  ─────────────────  │   │ │
│ * id (PK)           │   │ │
│ * name              │   │ │
│ * code              │   │ │
└─────────────────────┘   │ │
                          │ │
          ┌───────────────┘ │
          │ N:1             │
          ▼                 │
┌─────────────────────┐     │
│   res.partner       │     │
│  ─────────────────  │     │
│ * id (PK)           │     │
│ * name              │     │
│ * vat               │     │
│ * customer_rank     │     │
│ * supplier_rank     │     │
└─────────────────────┘     │
                            │
          ┌─────────────────┘
          │ N:1
          ▼
┌─────────────────────┐
│  account.group      │ (Hierarchy)
│  ─────────────────  │
│ * id (PK)           │
│ * name              │
│ * parent_id (FK) ───┼──┐ (self-referencing)
└─────────────────────┘  │
          ▲               │
          └───────────────┘
```

### 13.2 SQL DDL for Complete Star Schema

**(Complete DDL available in separate file: `star_schema_ddl.sql` - see project repository)**

**Key Tables**:
- Fact: `fact_gl_transaction`
- Dimensions: `dim_account`, `dim_partner`, `dim_date`, `dim_journal`, `dim_company`, `dim_analytic_account`, `dim_product`

### 13.3 Glossary of Terms

- **Canonical Fact Table**: Single authoritative source for transaction data (`account.move.line`)
- **Degenerate Dimension**: Low-cardinality attribute stored in fact table (e.g., `move_state`, `reconciled`)
- **Materialized View**: Pre-computed query result stored as table (refreshed periodically for performance)
- **Slowly Changing Dimension (SCD)**: Dimension table tracking historical changes (Type 2: new row per change)
- **Star Schema**: Fact table surrounded by dimension tables (optimized for BI queries)
- **Surrogate Key**: Auto-generated integer key (vs. natural key from source system)

### 13.4 Related Documents

- `03-roles-and-sod-matrix.md` - Data access control and RLS policies
- `04-close-calendar-and-phases.md` - Data reconciliation workflows
- `11-change-management.md` - Schema change governance

### 13.5 Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-01-29 | Finance Director + IT Manager | Initial data dictionary and canonical model creation |

---

**Document Classification**: Technical Reference
**Review Frequency**: Quarterly (or upon schema changes)
**Next Review Date**: 2025-04-30
**Approver**: Finance Director + IT Manager (signatures required)

**End of Document**