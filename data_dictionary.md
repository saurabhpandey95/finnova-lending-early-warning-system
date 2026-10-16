# FinNova EWS & Collection Analytics — Data Dictionary

Complete column definitions for all 6 core tables.

---

## Table: `customer` (20 records)

| Column | Type | Description | Sample Values |
|--------|------|-------------|---------------|
| `customer_id` | VARCHAR(10) | Unique borrower identifier | CUST00001 – CUST00020 |
| `customer_name` | VARCHAR(100) | Anonymised customer display name | Customer 00001 |
| `age` | INTEGER | Borrower age at time of data capture | 24 – 55 |
| `gender` | VARCHAR(10) | Male / Female | Male, Female |
| `employment_type` | VARCHAR(30) | Type of employment | Salaried, Self-Employed, Business Owner |
| `monthly_income` | NUMERIC(12,2) | Monthly gross income in INR | ₹29,000 – ₹2,60,000 |
| `city` | VARCHAR(50) | City of residence | Lucknow, Delhi, Jaipur, Mumbai, Ahmedabad, etc. |
| `state` | VARCHAR(50) | State of residence | Uttar Pradesh, Rajasthan, Gujarat, etc. |
| `customer_segment` | VARCHAR(30) | Income-based segment classification | Mass, Emerging Affluent, Affluent |
| `customer_since` | DATE | Date customer was onboarded | 2020 – 2025 |

**Segment Logic:**
- **Mass:** Monthly income < ₹50,000
- **Emerging Affluent:** Monthly income ₹50,000 – ₹1,00,000
- **Affluent:** Monthly income > ₹1,00,000

---

## Table: `loan` (25 records)

| Column | Type | Description | Sample Values |
|--------|------|-------------|---------------|
| `loan_id` | VARCHAR(10) | Unique loan identifier | LN000001 – LN000025 |
| `customer_id` | VARCHAR(10) | FK → customer.customer_id | CUST00001 – CUST00020 |
| `loan_product` | VARCHAR(50) | Loan product category | Personal Loan, Consumer Durable, MSME Business Loan |
| `loan_purpose` | VARCHAR(50) | Stated purpose at disbursement | Personal, Education, Electronics, Working Capital, Business Expansion, Medical, Home Improvement |
| `disbursement_date` | DATE | Loan disbursement date | 2021 – 2025 |
| `sanction_amount` | NUMERIC(14,2) | Total sanctioned amount in INR | ₹55,000 – ₹30,00,000 |
| `interest_rate` | NUMERIC(6,4) | Annual interest rate (decimal) | 0.1325 – 0.1725 (13.25% – 17.25%) |
| `tenure_months` | INTEGER | Loan repayment term in months | 12 – 60 |
| `emi_amount` | NUMERIC(12,4) | Calculated monthly EMI amount | ₹4,425 – ₹68,644 |
| `outstanding_amount` | NUMERIC(14,2) | Current outstanding principal balance | Varies |
| `loan_status` | VARCHAR(10) | Current status of the loan | Active, Closed |
| `risk_grade` | VARCHAR(2) | Underwriting risk grade assigned at origination | A (low risk), B (medium), C (high) |

---

## Table: `repayment` (20 records)

| Column | Type | Description | Sample Values |
|--------|------|-------------|---------------|
| `repayment_id` | VARCHAR(10) | Unique repayment event ID | RP000001 – RP000020 |
| `loan_id` | VARCHAR(10) | FK → loan.loan_id | LN000001 – LN000007 |
| `due_date` | DATE | EMI scheduled due date | — |
| `payment_date` | DATE | Actual date payment was received | — |
| `due_amount` | NUMERIC(12,2) | EMI amount due for this period | ₹5,343 – ₹47,318 |
| `paid_amount` | NUMERIC(12,2) | Amount actually paid | ₹4,000 – ₹47,318 |
| `dpd` | INTEGER | Days Past Due at time of payment | 0 – 78 |
| `payment_status` | VARCHAR(10) | Payment outcome | Paid (full, possibly late), Partial |
| `bounce_flag` | INTEGER | 1 = payment instrument bounced; 0 = no bounce | 0, 1 |
| `partial_payment_flag` | INTEGER | 1 = partial payment made; 0 = full payment | 0, 1 |

**Key Relationships:**
- `DPD = payment_date − due_date` (when positive)
- `DPD = 0` means paid on or before the due date
- `bounce_flag = 1` and `partial_payment_flag = 0` means bounce followed by eventual full payment
- `partial_payment_flag = 1` means less than the full EMI was received

---

## Table: `monthly_behaviour` (10 records)

| Column | Type | Description | Sample Values |
|--------|------|-------------|---------------|
| `behaviour_id` | VARCHAR(10) | Unique behaviour record ID | BH000001 – BH000010 |
| `loan_id` | VARCHAR(10) | FK → loan.loan_id | LN000001, LN000002, LN000004, LN000007 |
| `behaviour_month` | VARCHAR(7) | Observation month (YYYY-MM) | 2024-02 – 2024-12 |
| `max_dpd` | INTEGER | Maximum DPD recorded in the month | 0 – 78 |
| `avg_dpd` | NUMERIC(6,2) | Average DPD across all events in the month | 0 – 78 |
| `payment_ratio` | NUMERIC(4,2) | Paid ÷ Due for the month (0.00 – 1.00) | 0.42 – 1.00 |
| `bounce_count` | INTEGER | Number of bounce events in the month | 0 – 1 |
| `partial_payment_count` | INTEGER | Number of partial payments in the month | 0 – 1 |
| `dpd_trend` | VARCHAR(20) | DPD directional movement vs prior month | Stable, Deteriorating |
| `risk_signal` | VARCHAR(20) | Derived risk classification | Normal, Watch, Early Warning, High Risk, Severe Risk |

---

## Table: `ews` (10 records)

| Column | Type | Description | Sample Values |
|--------|------|-------------|---------------|
| `ews_id` | VARCHAR(10) | Unique EWS record ID | EWS000001 – EWS000010 |
| `loan_id` | VARCHAR(10) | FK → loan.loan_id | LN000001, LN000002, LN000004, LN000007 |
| `ews_month` | VARCHAR(7) | Month of EWS assessment (YYYY-MM) | 2024-02 – 2024-12 |
| `dpd_signal` | INTEGER | 1 = DPD ≥ 1 triggered; 0 = no signal | 0, 1 |
| `payment_signal` | INTEGER | 1 = payment stress detected | 0, 1 |
| `bounce_signal` | INTEGER | 1 = bounce event occurred | 0, 1 |
| `partial_payment_signal` | INTEGER | 1 = partial payment pattern detected | 0, 1 |
| `trend_signal` | INTEGER | 1 = deteriorating DPD trend | 0, 1 |
| `total_signals` | INTEGER | Sum of all 5 binary signal flags | 0 – 5 |
| `ews_level` | VARCHAR(20) | Derived EWS classification | Normal, Watch, Early Warning, High Risk |
| `risk_score` | INTEGER | Weighted composite risk score | 0 – 100 |
| `risk_band` | VARCHAR(20) | Risk category based on risk_score | Low, Moderate, High, Critical |
| `collection_priority` | VARCHAR(25) | Recommended collection urgency | P1 – Immediate, P2 – High, P3 – Monitor, P4 – Routine |
| `recommended_action` | VARCHAR(60) | Specific collection action recommended | Immediate Collection Call, Priority Follow-up, Monitor, Routine Monitoring |
| `risk_reason` | VARCHAR(100) | Business justification for the risk level | — |
| `action_reason` | VARCHAR(150) | Operational justification for the action | — |

**EWS Risk Score Logic:**

| total_signals | risk_score | risk_band | collection_priority |
|--------------|-----------|-----------|-------------------|
| 0 | 0 | Low | P4 – Routine |
| 1 | 20 | Low | P4 – Routine |
| 2 | 50 | Moderate | P3 – Monitor |
| 3 | 65 | High | P2 – High |
| 4 | 85 | Critical | P1 – Immediate |
| 5 | 100 | Critical | P1 – Immediate |

---

## Table: `collection_activity` (10 records)

| Column | Type | Description | Sample Values |
|--------|------|-------------|---------------|
| `collection_id` | VARCHAR(10) | Unique collection activity ID | COL000001 – COL000010 |
| `loan_id` | VARCHAR(10) | FK → loan.loan_id | LN000001, LN000002, LN000004, LN000007 |
| `collection_date` | DATE | Date the collection activity occurred | — |
| `contact_type` | VARCHAR(20) | Method of contact used | Call, Field Visit, WhatsApp, SMS |
| `contact_status` | VARCHAR(20) | Outcome of the contact attempt | Connected, No Answer, No Response |
| `promise_to_pay` | VARCHAR(5) | Whether the borrower committed to payment | Yes, No |
| `promised_amount` | NUMERIC(12,2) | Amount the borrower promised to pay | ₹0 – ₹15,000 |
| `collected_amount` | NUMERIC(12,2) | Amount actually collected during this activity | ₹0 – ₹8,000 |
| `collector_remark` | VARCHAR(200) | Operational note from the collection agent | Free text |

**Channel Mapping (Source → Dashboard):**

| Source (Excel) | Dashboard Display | Rationale |
|---------------|------------------|-----------|
| Call | Phone Call | Direct phone contact |
| SMS | Phone Call | Phone-based outreach |
| WhatsApp | Phone Call | Phone-based messaging |
| Field Visit | Field Visit | In-person contact |

---

## Key KPI Definitions

| KPI | Formula | Displayed On |
|-----|---------|-------------|
| **Collection Realization %** | `Collected ÷ Promised × 100` | All pages |
| **Recovery Gap / Shortfall** | `Total Promised − Total Collected` | Executive Command Center |
| **At-Risk Portfolio** | `Sum of uncollected for 60+ DPD accounts` | Executive Command Center |
| **Portfolio Health Score** | Composite of realization %, DPD ageing, EWS signals | Executive Command Center, EWS page |
| **Write-off Risk Score** | Weighted risk of portfolio reaching loss-asset status | Executive Command Center, EWS page |

---

## Source Traceability Note

The dashboard's promised/collected amounts (₹1,67,077 / ₹99,000) differ from the raw collection_activity totals (₹55,500 / ₹35,500) because:

1. The analytical layer uses **repayment.due_amount** as "promised" (the EMI contractually owed)
2. The raw collection_activity.promised_amount captures what borrowers verbally committed to during collection calls
3. The analytical layer correctly reflects the full EMI obligation outstanding — a more accurate measure of recovery performance

This is documented as required in the project QA findings.
