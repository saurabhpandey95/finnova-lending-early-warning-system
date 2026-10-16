FinNova EWS & Collection Analytics
End-to-End FinTech Decision Intelligence | Excel → PostgreSQL/SQL → Power BI
![Project Banner](screenshots/banner_placeholder.png)
> **From overdue reporting to collection prioritization** — A portfolio analytics project that structures lending data, builds a SQL analytical layer, and delivers five interactive Power BI dashboards for collection monitoring, early warning risk, and NPA prevention.
---
![Tools](https://img.shields.io/badge/Tools-Excel%20%7C%20PostgreSQL%20%7C%20Power%20BI-blue)
![Domain](https://img.shields.io/badge/Domain-BFSI%20%7C%20FinTech%20%7C%20Lending-green)
![Status](https://img.shields.io/badge/Status-Portfolio%20Project-orange)
![Tables](https://img.shields.io/badge/Core%20Tables-6-lightblue)
![Dashboard Pages](https://img.shields.io/badge/Dashboard%20Pages-5-purple)
---
Table of Contents
Project Overview
Business Problem
Solution Architecture
Tools & Technologies
Dataset Description
Project Workflow
Step-by-Step Implementation
SQL Queries & Business Logic
Power BI Dashboard Showcase
Key Business Insights
Skills Demonstrated
Business Value
Limitations & Future Improvements
How to Run or Explore
Resume & LinkedIn Content
Project Structure
---
1. Project Overview
FinNova EWS & Collection Analytics is an end-to-end FinTech data analytics project that converts raw lending, repayment, borrower-behaviour, early-warning, and collection data into an interactive decision-support system.
The project demonstrates a complete analytics pipeline across three technology layers:
Layer	Technology	Responsibility
01	Microsoft Excel	Source data design — lending records, repayments, borrower behaviour, and collection activity
02	PostgreSQL / SQL	Data quality checks, account-level aggregation, KPI calculation, reusable analytical views
03	Power BI Desktop	Five interactive dashboard pages for collection monitoring, risk analysis, and executive reporting
Data Scope: 20 customers · 25 loans · 20 repayment records · 10 monthly-behaviour records · 10 EWS records · 10 raw collection activities
Analytical Focus: Moving from descriptive overdue reporting to account-level collection prioritisation using DPD ageing, EWS risk scores, risk bands, recovery performance, and collection priority flags.
> ⚠️ **Disclaimer:** This is an independent portfolio analytics project built on a synthetic sample dataset. It does not represent data from any real financial institution. The RBI/IRACP view demonstrates a project-style regulatory classification framework and is not intended for compliance use.
---
2. Business Problem
In retail and MSME lending, collection teams face a critical operational challenge: which accounts should they act on today, and in what order?
Without structured analytics, teams rely on simple overdue lists sorted by days past due (DPD). This approach misses important signals — an account with a high bounce rate, declining payment ratio, and a worsening EWS signal is a higher priority than DPD alone reveals.
The specific problems this project addresses:
Lenders cannot quickly identify which accounts are approaching NPA (Non-Performing Asset) status
Collection teams lack a structured priority queue combining DPD, risk score, and recovery performance
Portfolio managers have no real-time view of recovery shortfall, at-risk exposure, or write-off risk
Geographic concentration of NPA risk is not visible without a structured analytical layer
Regulatory asset classification (RBI IRACP framework) is typically tracked manually and inconsistently
FinNova EWS & Collection Analytics converts raw operational data into a decision-support layer that answers five business questions:
How much is being recovered — and which channels and DPD bands perform best?
Which accounts show worsening risk signals and need immediate collection action?
Where is the recovery shortfall, at-risk exposure, and what does the priority queue look like?
Which cities concentrate the most NPA exposure and weak realization?
How do active loans map onto the RBI IRACP asset classification framework?
---
3. Solution Architecture
```
┌─────────────────────────────────────────────────────────────────┐
│                    FINNOVA ANALYTICS PIPELINE                    │
│                                                                   │
│   ┌──────────────┐    ┌──────────────────┐    ┌──────────────┐  │
│   │   LAYER 01   │    │    LAYER 02       │    │   LAYER 03   │  │
│   │              │    │                   │    │              │  │
│   │  Excel       │───▶│  PostgreSQL / SQL │───▶│  Power BI   │  │
│   │              │    │                   │    │              │  │
│   │ • 6 sheets   │    │ • Quality checks  │    │ • 5 pages   │  │
│   │ • 95 records │    │ • Aggregation     │    │ • KPIs      │  │
│   │ • Source     │    │ • 5 SQL views     │    │ • Filters   │  │
│   │   structure  │    │ • KPI layer       │    │ • Slicers   │  │
│   └──────────────┘    └──────────────────┘    └──────────────┘  │
│                                                                   │
│   Source Data     →   Analytical Layer    →   Decision Support   │
└─────────────────────────────────────────────────────────────────┘
```
Key Design Principle: Account-level priority logic aggregates multiple collection events per loan into a single priority row using `MAX(DPD)` and aggregate collection performance — preventing duplicate account priorities in the dashboard.
---
4. Tools & Technologies
Category	Tool / Technology	How It Was Used
Spreadsheet & Source Data	Microsoft Excel	Data design for 6 core tables; EWS risk scoring; collection activity records
Database	PostgreSQL	Relational database for all 6 tables; data quality validation
Query Language	SQL (PostgreSQL dialect)	Data quality checks, KPI queries, channel/DPD analysis, account priority logic, reusable views
Business Intelligence	Power BI Desktop	Data model, relationships, DAX measures, 5 interactive dashboard pages
Data Modelling	Star schema design	Fact tables (repayment, collection) linked to customer and loan dimensions
Regulatory Reference	RBI IRACP Framework	Asset classification and provisioning logic for the compliance demo page
Version Control	Git / GitHub	Repository hosting and portfolio presentation
SQL Concepts Applied: `GROUP BY`, `COUNT DISTINCT`, `SUM`, `AVG`, `MAX`, `CASE WHEN`, `NULLIF`, `COALESCE`, `ROUND`, `LEFT JOIN`, `DISTINCT ON`, `CREATE OR REPLACE VIEW`, `ORDER BY`
---
5. Dataset Description
The source Excel workbook (`FinNova_EWS_Decision_Intelligence.xlsx`) contains six worksheets that map directly to the six PostgreSQL tables.
Table 1: `customer` — 20 Records
Stores borrower master information.
Column	Data Type	Description
`customer_id`	VARCHAR	Primary key — unique borrower ID (CUST00001–CUST00020)
`customer_name`	VARCHAR	Anonymised customer name
`age`	INTEGER	Borrower age (24–55 in this sample)
`gender`	VARCHAR	Male / Female
`employment_type`	VARCHAR	Salaried / Self-Employed / Business Owner
`monthly_income`	NUMERIC	Monthly income in INR (₹29,000–₹2,60,000)
`city`	VARCHAR	City of residence (Lucknow, Delhi, Jaipur, Mumbai, Ahmedabad, etc.)
`state`	VARCHAR	State of residence
`customer_segment`	VARCHAR	Mass / Emerging Affluent / Affluent
`customer_since`	DATE	Customer onboarding date
Table 2: `loan` — 25 Records
Stores loan/account-level information linked to customers.
Column	Data Type	Description
`loan_id`	VARCHAR	Primary key — unique loan ID (LN000001–LN000025)
`customer_id`	VARCHAR	Foreign key → customer table
`loan_product`	VARCHAR	Personal Loan / Consumer Durable / MSME Business Loan
`loan_purpose`	VARCHAR	Personal / Education / Electronics / Working Capital / Business Expansion / Medical / Home Improvement
`disbursement_date`	DATE	Loan disbursement date
`sanction_amount`	NUMERIC	Sanctioned loan amount (₹55,000–₹30,00,000)
`interest_rate`	DECIMAL	Annual interest rate (13.25%–17.25%)
`tenure_months`	INTEGER	Loan tenure in months (12–60)
`emi_amount`	NUMERIC	Calculated EMI amount
`outstanding_amount`	NUMERIC	Current outstanding balance
`loan_status`	VARCHAR	Active / Closed
`risk_grade`	VARCHAR	A / B / C
Table 3: `repayment` — 20 Records
Tracks individual EMI repayment events including delinquency details.
Column	Data Type	Description
`repayment_id`	VARCHAR	Primary key (RP000001–RP000020)
`loan_id`	VARCHAR	Foreign key → loan table
`due_date`	DATE	EMI due date
`payment_date`	DATE	Actual payment date
`due_amount`	NUMERIC	EMI amount due
`paid_amount`	NUMERIC	Amount actually paid
`dpd`	INTEGER	Days Past Due at payment (0–78 in this sample)
`payment_status`	VARCHAR	Paid / Partial
`bounce_flag`	INTEGER	1 = bounce occurred, 0 = no bounce
`partial_payment_flag`	INTEGER	1 = partial payment, 0 = full payment
Key loans in analytical layer:
`LN000002` (Customer 00001) — 1–30 DPD range
`LN000004` (Customer 00003) — 31–60 DPD range
`LN000007` (Customer 00005) — 61–90 DPD range (top priority account)
Table 4: `monthly_behaviour` — 10 Records
Captures monthly borrower-level behaviour signals used for EWS scoring.
Column	Data Type	Description
`behaviour_id`	VARCHAR	Primary key (BH000001–BH000010)
`loan_id`	VARCHAR	Foreign key → loan table
`behaviour_month`	VARCHAR	Month of observation (YYYY-MM)
`max_dpd`	INTEGER	Maximum DPD in the month
`avg_dpd`	DECIMAL	Average DPD in the month
`payment_ratio`	DECIMAL	Paid amount ÷ due amount (0–1 scale)
`bounce_count`	INTEGER	Number of bounces in the month
`partial_payment_count`	INTEGER	Number of partial payments
`dpd_trend`	VARCHAR	Stable / Deteriorating
`risk_signal`	VARCHAR	Normal / Watch / Early Warning / High Risk / Severe Risk
Table 5: `ews` — 10 Records
The Early Warning System scoring table — the analytical core of risk identification.
Column	Data Type	Description
`ews_id`	VARCHAR	Primary key (EWS000001–EWS000010)
`loan_id`	VARCHAR	Foreign key → loan table
`ews_month`	VARCHAR	Observation month
`dpd_signal`	INTEGER	1 = DPD signal triggered, 0 = no signal
`payment_signal`	INTEGER	1 = payment stress detected
`bounce_signal`	INTEGER	1 = bounce occurred
`partial_payment_signal`	INTEGER	1 = partial payment pattern
`trend_signal`	INTEGER	1 = deteriorating trend
`total_signals`	INTEGER	Count of triggered signals (0–5)
`ews_level`	VARCHAR	Normal / Watch / Early Warning / High Risk
`risk_score`	INTEGER	Weighted risk score (0–100)
`risk_band`	VARCHAR	Low / Moderate / High / Critical
`collection_priority`	VARCHAR	P1 – Immediate / P2 – High / P3 – Monitor / P4 – Routine
`recommended_action`	VARCHAR	Immediate Collection Call / Priority Follow-up / Monitor / Routine Monitoring
`risk_reason`	VARCHAR	Business rationale for the risk level
`action_reason`	VARCHAR	Operational reason for the recommended action
EWS Risk Score Logic: The risk score is a weighted combination of five binary signals — DPD, payment stress, bounce activity, partial-payment pattern, and deteriorating trend. A score of 100 (all five signals triggered) corresponds to `Critical` risk band and `P1 – Immediate` collection priority.
Table 6: `collection_activity` — 10 Records
Tracks collection team interactions with borrowers.
Column	Data Type	Description
`collection_id`	VARCHAR	Primary key (COL000001–COL000010)
`loan_id`	VARCHAR	Foreign key → loan table
`collection_date`	DATE	Date of collection activity
`contact_type`	VARCHAR	Call / Field Visit / WhatsApp / SMS
`contact_status`	VARCHAR	Connected / No Answer / No Response
`promise_to_pay`	VARCHAR	Yes / No — whether borrower committed to payment
`promised_amount`	NUMERIC	Amount promised by borrower during contact
`collected_amount`	NUMERIC	Amount actually collected
`collector_remark`	VARCHAR	Collector's operational note
> **Data Layer Note:** The analytical layer uses repayment due amounts as "promised" and paid amounts as "collected" for the 3 active collection loans (LN000002, LN000004, LN000007). This produces the dashboard totals of ₹1,67,077 promised and ₹99,000 collected, which differs from raw collection_activity promised amounts (₹55,500 across 6 activities with non-zero amounts). The analytical layer provides a more accurate picture of actual recovery performance.
---
6. Project Workflow
```
PHASE 1: DATA DESIGN (Excel)
─────────────────────────────
1. Designed 6 Excel worksheets mirroring the relational schema
2. Created customer master, loan records, repayment history
3. Designed monthly behaviour tracking columns (DPD trend, payment ratio, bounce count)
4. Built EWS scoring table with 5 binary signals and weighted risk score
5. Created collection activity records with channel, status, and recovery data
6. Validated referential integrity across all sheets before SQL import

PHASE 2: SQL ANALYTICAL LAYER (PostgreSQL)
───────────────────────────────────────────
7.  Created database and 6 core tables with correct data types
8.  Imported Excel data into PostgreSQL tables
9.  Ran 5 orphan-record checks (0 orphans found — data is clean)
10. Ran duplicate and financial integrity checks (0 issues found)
11. Calculated Collection Realization % using NULLIF to prevent divide-by-zero
12. Computed overall KPI summary (5 activities, ₹1,67,077 promised, 59.25% realization)
13. Grouped by loan_id for account-level performance
14. Joined collection_activity with latest EWS records using DISTINCT ON
15. Compared Phone Call vs Field Visit channel performance
16. Analysed collection performance by DPD bucket
17. Built account-level priority logic using MAX(DPD) to prevent duplicates
18. Saved 5 reusable analytical views for Power BI

PHASE 3: POWER BI DASHBOARD (Power BI Desktop)
────────────────────────────────────────────────
19. Connected Power BI to PostgreSQL analytical views
20. Built data model with relationships across 6 tables
21. Created DAX measures for KPIs (Realization %, Recovery Gap, Portfolio Health Score)
22. Designed 5 interactive dashboard pages with slicers, filters, and drill-throughs
23. Validated all visual metrics against SQL view outputs
```
---
7. Step-by-Step Implementation
7.1 Excel Data Preparation
The Excel workbook serves as the structured source layer. Key design decisions:
Customer_Segment classifies borrowers as Mass / Emerging Affluent / Affluent based on monthly income
Risk_Grade (A/B/C) on the loan table provides initial underwriting risk signal
DPD_Trend (`Stable` / `Deteriorating`) in monthly_behaviour provides a directional signal
EWS binary signals (0/1 flags for DPD, payment, bounce, partial payment, trend) are summed into `Total_Signals` and converted to a weighted `Risk_Score`
Collection_Activity captures both attempted contacts (SMS, no-answer calls) and successful recoveries
7.2 Database Setup
```sql
-- Create the PostgreSQL database
CREATE DATABASE finnova_ews;

-- Connect and create core tables
-- See: sql/01_database_setup.sql for complete DDL
```
The six tables follow a hub-and-spoke structure:
Hub: `customer` (master) → `loan` (account)
Spokes: `repayment`, `monthly_behaviour`, `ews`, `collection_activity` (all link via `loan_id`)
7.3 Data Quality Checks
All five parent-child relationship checks returned 0 orphan records, confirming that:
Every repayment record links to a valid loan
Every monthly behaviour record links to a valid loan
Every EWS record links to a valid loan
Every collection activity links to a valid loan
Every loan links to a valid customer
Additional checks confirmed 0 duplicate collection IDs and 0 invalid financial amounts (no negative values, no collected > promised).
7.4 Core KPI: Collection Realization %
```sql
-- Realization % formula applied throughout the analytical layer
ROUND(
    SUM(r.paid_amount) / NULLIF(SUM(r.due_amount), 0) * 100,
    2
) AS realization_pct
```
Why `NULLIF(..., 0)`? PostgreSQL throws a division-by-zero error if the denominator is zero. `NULLIF` converts 0 to NULL, making the division return NULL instead of crashing — a critical production-safe pattern.
7.5 Account-Level Priority Logic (Preventing Duplicate Rows)
An early version of the priority query grouped by collection event, causing the same loan to appear multiple times in the dashboard. The corrected approach:
```sql
-- Correct: group at loan level, use MAX(DPD) for the worst current delinquency
SELECT
    l.loan_id,
    c.customer_name,
    e.risk_score,
    e.risk_band,
    e.collection_priority,
    MAX(r.dpd)                                          AS max_dpd,
    SUM(r.due_amount - r.paid_amount)                   AS total_uncollected,
    ROUND(SUM(r.paid_amount) / NULLIF(SUM(r.due_amount), 0) * 100, 2) AS realization_pct
FROM loan l
JOIN customer c     ON l.customer_id    = c.customer_id
JOIN repayment r    ON l.loan_id        = r.loan_id
JOIN (
    -- Latest EWS record per loan
    SELECT DISTINCT ON (loan_id)
        loan_id, risk_score, risk_band, collection_priority
    FROM ews
    ORDER BY loan_id, ews_month DESC
) e ON l.loan_id = e.loan_id
WHERE r.paid_amount < r.due_amount   -- Only delinquent repayments
GROUP BY l.loan_id, c.customer_name, e.risk_score, e.risk_band, e.collection_priority
ORDER BY e.risk_score DESC, max_dpd DESC;
```
Result:
Loan	Customer	Max DPD	Risk Score	Uncollected	Realization
LN000007	Customer 00005	78	100	₹44,636	52.83%
LN000004	Customer 00003	52	100	₹22,098	67.07%
LN000002	Customer 00001	12	85	₹1,343	74.86%
7.6 Channel Analysis
```sql
-- Collection performance by contact channel
SELECT
    CASE
        WHEN ca.contact_type IN ('Call', 'SMS', 'WhatsApp') THEN 'Phone Call'
        WHEN ca.contact_type = 'Field Visit'                THEN 'Field Visit'
        ELSE ca.contact_type
    END                                                              AS channel,
    SUM(r.due_amount)                                                AS total_promised,
    SUM(r.paid_amount)                                               AS total_collected,
    ROUND(SUM(r.paid_amount) / NULLIF(SUM(r.due_amount), 0) * 100, 2) AS realization_pct
FROM collection_activity ca
JOIN loan l         ON ca.loan_id  = l.loan_id
JOIN repayment r    ON l.loan_id   = r.loan_id
WHERE r.paid_amount < r.due_amount
GROUP BY channel
ORDER BY realization_pct DESC;
```
> **Channel Mapping Note:** The source Excel has four contact types (Call, Field Visit, SMS, WhatsApp). For dashboard clarity, Call/SMS/WhatsApp are consolidated into **Phone Call** and Field Visit remains as-is. This is documented here for traceability.
7.7 Five Reusable SQL Views
```sql
-- Five analytical views created for Power BI consumption
CREATE OR REPLACE VIEW vw_collection_performance  AS ...;  -- Activity-level with EWS context
CREATE OR REPLACE VIEW vw_collection_priority     AS ...;  -- One row per loan, account-level
CREATE OR REPLACE VIEW vw_collection_kpis         AS ...;  -- Dashboard headline KPIs
CREATE OR REPLACE VIEW vw_collection_channel      AS ...;  -- Phone Call vs Field Visit
CREATE OR REPLACE VIEW vw_collection_dpd          AS ...;  -- Performance by DPD bucket
```
See `sql/07_analytical_views.sql` for complete view definitions.
7.8 Power BI Data Model
Power BI connects directly to the five PostgreSQL analytical views. Key model features:
Relationships: loan_id and customer_id as the join keys across all tables
Slicers: DPD Bucket, Risk Band, Collection Priority, Contact Type, City
Cross-filtering: All visuals on each page respond to slicer selections
DAX Measures: Portfolio Health Score, Realization %, Recovery Gap, Write-off Risk Score
---
8. SQL Queries & Business Logic
8.1 Key SQL Files
File	Purpose
`sql/01_database_setup.sql`	Create database, all 6 tables with PKs and FKs
`sql/02_data_quality.sql`	Orphan checks, duplicate checks, financial validation
`sql/03_collection_kpis.sql`	Overall KPIs: count, promised, collected, realization
`sql/04_performance_by_loan.sql`	Account-level collection grouping
`sql/05_ews_analysis.sql`	Connect EWS risk to collection performance
`sql/06_channel_dpd_analysis.sql`	Channel efficiency and DPD bucket breakdown
`sql/07_analytical_views.sql`	All 5 reusable views for Power BI
8.2 Key SQL Concepts Used
Concept	Business Purpose
`GROUP BY loan_id`	Aggregate multiple collection events to one account row
`COUNT(DISTINCT loan_id)`	Count unique accounts, not activities
`MAX(dpd)`	Capture worst delinquency across all events for an account
`DISTINCT ON (loan_id)`	Get the most recent EWS record per loan
`NULLIF(expr, 0)`	Prevent division-by-zero in realization %
`COALESCE(expr, 0)`	Replace NULL with 0 for clean aggregation
`CASE WHEN dpd BETWEEN 1 AND 30 THEN '1-30 DPD'`	Create DPD bucket categories
`CREATE OR REPLACE VIEW`	Save reusable logic for Power BI import
`LEFT JOIN ... WHERE IS NULL`	Identify orphan records in data quality checks
`ROUND(..., 2)`	Keep two decimal places for financial metrics
---
9. Power BI Dashboard Showcase
The final Power BI file (`finnova_ews.pbix`) contains five interactive analytical pages.
> 📌 **Screenshots Setup:** After uploading this repository to GitHub, add your dashboard screenshots to the `screenshots/` folder and replace the placeholder paths below.
---
Page 1: Collection Overview
Business Question: How much is being recovered — and which channels and DPD bands perform best?
```markdown
![Collection Overview](screenshots/01_collection_overview.png)
```
Key Visuals:
Total Promised vs Total Collected (card KPIs)
Collection Realization % by DPD Bucket (grouped bar)
Collection Performance by Channel — Phone Call vs Field Visit (bar)
Portfolio Risk Band Split (pie: P1 Immediate / P2 High / P3 Monitor / P4 Routine)
Active Account Collection Detail (table with customer, DPD, loan, collected, promised, realization)
Dashboard Metrics Displayed:
Total Promised: ₹1,67,077
Total Collected: ₹99,000
Collection Realization: 59.25%
---
Page 2: Early Warning and Risk Analysis
Business Question: Which accounts show worsening risk signals and need immediate collection action?
```markdown
![Early Warning and Risk Analysis](screenshots/02_ews_risk_analysis.png)
```
Key Visuals:
Loans by EWS Level (High Risk / Early Warning / Normal / Watch)
DPD Bucket Analysis — Promise vs Recovery Rate (clustered bar)
Loan Count by Risk Severity (0–100 score bands)
Geographic Loan Concentration by City (horizontal bar)
Accounts by Collection Action (Immediate / Priority / Monitor / Routine)
EWS Alert Level Distribution (100% stacked bar)
Portfolio Health Score card: 83.90
Write-off Risk Score card: 12.90
---
Page 3: Executive Command Center
Business Question: Where is the recovery shortfall, at-risk exposure, and what does today's priority queue look like?
```markdown
![Executive Command Center](screenshots/03_executive_command_center.png)
```
Key Visuals:
Portfolio Health Score: 83.90
Recovery Shortfall: ₹68.08K
At-Risk Portfolio: ₹44.64K
Write-off Risk: 12.90
Total Recovered: ₹99.00K
Portfolio Risk Distribution (donut: Critical 40%, Low 40%, High 10%, Moderate 10%)
Uncollected Amount by DPD Bucket (bar: 1-30: ₹10K · 31-60: ₹14K · 61-90: ₹45K)
Channel Recovery Efficiency (bar: Phone Call 68% · Field Visit 50%)
Priority Collection Queue — Today's Action List (table with P1 accounts)
---
Page 4: Geographic Risk Atlas
Business Question: Which cities concentrate the most NPA exposure and have the weakest collection realization?
```markdown
![Geographic Risk Atlas](screenshots/04_geographic_risk_atlas.png)
```
Key Visuals:
Loan Count by City — Critical Risk accounts (Ahmedabad: 2 · Jaipur: 2 · Lucknow: 1)
Collection Realization Rate by City (Lucknow 74.86% · Jaipur 67.07% · Ahmedabad 52.83%)
Uncollected Exposure by City
DPD Aging Profile by City (stacked horizontal bar)
City selector slicer (Ahmedabad / Jaipur / Lucknow)
---
Page 5: RBI Compliance — IRACP View
Business Question: How do active loans map to the RBI IRACP asset classification and provisioning framework?
```markdown
![RBI Compliance IRACP View](screenshots/05_rbi_iracp_view.png)
```
Key Visuals:
Asset Classification Cards: Standard (0–90 DPD) ✅ · Sub-Standard (90–180 DPD) ⚠️ · Doubtful (180–360 DPD) 🔴 · Loss Assets ⛔
IRACP Loan Classification Register (table)
RBI Required Provisioning Amount by DPD Bucket (bar)
Regulatory provisioning schedule (10% → 20% → 50% → 100%)
> ⚠️ **Important:** This page demonstrates a project-style asset classification framework based on RBI IRACP norms. It uses simplified demo logic on a synthetic dataset and is **not** intended for compliance reporting. Always validate against the current RBI Master Circular before any real-world use.
---
10. Key Business Insights
All findings below are from the project's analytical layer (3 active collection accounts, 5 delinquent repayment events). They are sample results, not production metrics.
Insight 1: Overall Collection Performance — 59.25% Realization
Out of ₹1,67,077 promised across three collection accounts, ₹99,000 was collected, leaving ₹68,077 uncollected. This 59.25% realization rate is the portfolio baseline — with two accounts in the 60–90 DPD range, the recovery risk is concentrated.
Insight 2: Realization Declines Sharply with DPD Age
The data shows a clear inverse relationship between DPD band and collection effectiveness:
DPD Bucket	Promised	Collected	Realization	Gap vs 1–30 DPD
1–30 DPD	₹38,892	₹29,000	74.57%	—
31–60 DPD	₹33,549	₹20,000	59.61%	−14.96 pp
61–90 DPD	₹94,636	₹50,000	52.83%	−21.74 pp
Interpretation: For every additional month a loan ages in delinquency, realization drops significantly. Early intervention (at 1–30 DPD) is 21.74 percentage points more effective than waiting until the 61–90 DPD stage — validating the EWS system's purpose.
Insight 3: LN000007 is the Top Immediate Priority
Loan LN000007 (Customer 00005, Ahmedabad) presents the most acute collection challenge:
Signal	Value
Maximum DPD	78 days
EWS Risk Score	100 / 100 (all five signals triggered)
Risk Band	Critical
Collection Priority	P1 – Immediate
Total Uncollected	₹44,636
Realization Rate	52.83%
Loan Type	MSME Business Loan — Business Expansion
Sanction Amount	₹20,00,000
Recommended Action: Immediate Collection Call + repayment context review + targeted follow-up plan.
Insight 4: Phone Call Outperforms Field Visit in This Sample
Channel	Promised	Collected	Realization
Phone Call	₹86,210	₹59,000	68.44%
Field Visit	₹80,867	₹40,000	49.46%
Phone call contacts achieved 18.98 percentage points higher realization in this sample. This could guide channel prioritisation for low-to-medium DPD accounts — though a larger sample would be needed to generalise this finding.
Insight 5: Geographic Risk is Concentrated in Ahmedabad
Among the three active collection cities, Ahmedabad has the highest exposure and the lowest realization:
2 critical-risk loans
1 account in 61–90 DPD bucket
₹44.64K at-risk exposure
52.83% realization rate
Lucknow performs best (74.86%) while Jaipur sits in the middle (67.07%).
Insight 6: Portfolio Health Score of 83.90
The Portfolio Health Score of 83.90 (out of 100) and Write-off Risk Score of 12.90 reflect that 40% of the active collection portfolio is classified as Critical risk band, though total recovery is still above 50%. The 83.90 health score is a composite measure incorporating recovery rate, DPD ageing, and EWS signals.
---
11. Skills Demonstrated
Technical Skills
Skill	Evidence in Project
SQL — Data Quality	5 orphan-record checks, duplicate checks, financial validation
SQL — Aggregation	GROUP BY loan/channel/DPD, COUNT DISTINCT, SUM, AVG, MAX
SQL — Analytical Patterns	NULLIF, COALESCE, CASE WHEN, DISTINCT ON, window logic
SQL — Views	5 reusable CREATE OR REPLACE VIEW definitions
Excel — Data Design	6-table relational schema designed in Excel workbooks
Excel — EWS Scoring	Weighted 5-signal risk score built in Excel before SQL import
Power BI — Data Model	6-table star schema, relationships, cross-filtering
Power BI — DAX	Portfolio Health Score, Realization %, Recovery Gap measures
Power BI — Visualisations	5 pages, KPI cards, bar/donut/stacked charts, slicers, tables
Data Reconciliation	Identified and documented raw-vs-analytical layer discrepancies
Business / Domain Skills
Skill	Evidence
BFSI Domain Knowledge	DPD, NPA, IRACP, EWS, provisioning, risk band logic
Collection Analytics	Priority queue design, channel efficiency, realization %
Risk Scoring	Weighted signal model (DPD + payment + bounce + partial + trend)
Regulatory Awareness	RBI IRACP asset classification framework (demo layer)
KPI Design	Portfolio Health Score, Write-off Risk, Recovery Shortfall, At-Risk Exposure
Executive Communication	5-page dashboard covering operations → risk → executive → geography → compliance
Data Documentation	QA findings, source traceability, methodology notes
Soft Skills Demonstrated
End-to-end project ownership from data design to final dashboard
Attention to data quality — identified and documented source vs analytical layer differences
Business communication — translated technical findings into actionable collection insights
Self-directed learning — built BFSI domain knowledge independently during MBA programme
---
12. Business Value
Who Would Use This Dashboard?
Stakeholder	Dashboard Page	Use Case
Collection Agent	Collection Overview	Check today's priority accounts and which channel to use
Collection Manager	Executive Command Center	Monitor recovery shortfall and portfolio health daily
Risk Analyst	Early Warning & Risk Analysis	Identify accounts showing EWS signals before they become NPAs
Branch / Regional Head	Geographic Risk Atlas	Understand city-wise exposure concentration
Compliance / Finance	RBI Compliance — IRACP View	Track asset classification status (demo framework)
Real-World Relevance to BFSI / FinTech
In a real NBFC or retail bank lending operation:
This analytics layer can reduce collection cost-per-rupee-recovered by targeting the right accounts with the right channel at the right DPD stage
EWS signals caught at the 1–30 DPD stage (74.57% realization) could prevent accounts from deteriorating to 61–90 DPD (52.83% realization) — a 21.74 pp improvement in recovery effectiveness
A structured collection priority queue replaces ad-hoc overdue lists, making collector time more efficient
Account-level logic ensures each account appears once in the priority queue — preventing duplicate work
Transferable Analytical Framework
The three-layer pipeline (Excel source → SQL analytical layer → Power BI decision layer) is the standard analytics architecture used in MIS reporting, lending operations, and credit risk teams across Indian BFSI organisations. This project demonstrates practical familiarity with each layer.
---
13. Limitations & Future Improvements
Current Limitations
Limitation	Detail
Sample size	20 customers, 3 active collection accounts — findings are illustrative, not statistically conclusive
Static data	No live data connection; dashboard shows a point-in-time snapshot
Channel mapping	4 source channels consolidated to 2 in dashboards; WhatsApp and SMS not separately analysed
No date dimension	Formal calendar table not built; time-based analysis is limited to month labels
Simplified IRACP	Provisioning rates are demo approximations; not validated against current RBI circulars
No roll-rate analysis	Migration of accounts between DPD bands over time is not tracked
KPI consistency	Critical accounts count differs between SQL notes (3) and some dashboard visuals (5); standardisation needed
Recommended Future Enhancements
Phase 1 — Govern:
Build KPI dictionary and data dictionary documenting every measure definition
Create source-to-visual lineage documentation (which SQL view feeds which visual)
Standardise critical-risk KPI using unique current accounts + latest EWS record
Validate IRACP provisioning rates against current RBI Master Circular
Phase 2 — Deepen:
Add a formal date dimension table for time-series analysis
Build monthly risk migration tracking (roll-rate: how many accounts moved from 1–30 to 31–60 DPD?)
Add cure-rate analysis (accounts that recovered from delinquency)
Track Promise-to-Pay fulfillment rate (did the borrower keep their commitment?)
Phase 3 — Operationalise:
Collector productivity metrics (calls per day, recovery per agent)
Automated Power BI refresh via PostgreSQL connection or dataflow
Add "Interactive Portfolio Health" label instead of "Real-time" for static datasets
Repeatable QA check scripts for each data refresh cycle
---
14. How to Run or Explore
Option A: Explore the Power BI Dashboard (Easiest)
Download `finnova_ews.pbix` from this repository
Open in Power BI Desktop (free download at powerbi.microsoft.com)
If prompted, click "Transform Data" to review the data model, or "Close & Apply" to go directly to dashboards
Use the page navigation buttons at the bottom to move between the 5 dashboard pages
Use the slicers (DPD Bucket, Risk Band, Contact Type, City) to filter the visuals
Option B: Run the SQL Layer (Intermediate)
Prerequisites:
PostgreSQL 14 or higher installed (postgresql.org)
pgAdmin 4 (optional, for GUI access)
Steps:
```bash
# 1. Create the database
psql -U postgres -c "CREATE DATABASE finnova_ews;"

# 2. Connect to the new database
psql -U postgres -d finnova_ews

# 3. Run the table creation script
\i sql/01_database_setup.sql

# 4. Import data from Excel (or run the INSERT statements in the setup file)
# Load data from: data/FinNova_EWS_Decision_Intelligence.xlsx

# 5. Run data quality checks
\i sql/02_data_quality.sql

# 6. Run KPI and analysis queries
\i sql/03_collection_kpis.sql
\i sql/04_performance_by_loan.sql
\i sql/05_ews_analysis.sql
\i sql/06_channel_dpd_analysis.sql

# 7. Create the analytical views
\i sql/07_analytical_views.sql

# 8. Verify all views
SELECT * FROM vw_collection_kpis;
SELECT * FROM vw_collection_priority;
SELECT * FROM vw_collection_channel;
SELECT * FROM vw_collection_dpd;
```
Option C: Explore the Excel Workbook
Download `data/FinNova_EWS_Decision_Intelligence.xlsx`
Open in Microsoft Excel
Review the 6 sheets: Customer, Loan, Repayment, Monthly_Behaviour, EWS, Collection_Activity
The EWS sheet contains the complete risk scoring logic with all 5 signal columns
Option D: Read the Project Report
Download `docs/FinNova_EWS_Project_Report.pdf` for the complete project methodology
Download `docs/FinNova_Executive_Presentation.pdf` for the slide-deck summary
---
15. Resume & LinkedIn Content
Resume Project Entry
```
FinNova EWS & Collection Analytics | End-to-End FinTech Data Analytics Project
Tools: Microsoft Excel · PostgreSQL / SQL · Power BI Desktop
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
• Designed a 6-table relational schema in Excel (20 customers, 25 loans, 95+ records) to
  model a retail and MSME lending portfolio with EWS risk scoring and collection tracking
• Built a PostgreSQL analytical layer with 5 reusable SQL views, data quality checks
  (0 orphan records), and account-level collection priority logic using MAX(DPD) aggregation
• Developed 5 Power BI dashboard pages covering collection performance, early warning risk,
  executive KPIs, geographic exposure, and RBI IRACP-style asset classification
• Identified a 21.74 pp realization gap between 1–30 DPD (74.57%) and 61–90 DPD (52.83%)
  accounts, demonstrating the business case for early EWS-driven collection intervention
• Flagged LN000007 as top-priority account with DPD 78, risk score 100, and ₹44,636
  uncollected — translating multi-signal EWS data into an actionable collection priority
```
LinkedIn Project Description
```
🔷 FinNova EWS & Collection Analytics — FinTech Decision Intelligence Portfolio Project

An end-to-end data analytics project connecting raw lending data, SQL analytical views,
and Power BI decision dashboards for loan collection management and NPA prevention.

📊 What I built:
• Excel: 6-table relational schema — customer, loan, repayment, behaviour, EWS, collection
• PostgreSQL/SQL: Data quality checks, KPI aggregation, 5 reusable analytical views
• Power BI: 5 interactive pages — Collection Overview · Early Warning & Risk · Executive
  Command Center · Geographic Risk Atlas · RBI Compliance — IRACP View

💡 Key insights from the analytical layer:
• Overall realization: 59.25% (₹99K collected vs ₹1.67L promised)
• DPD vs Realization: 1–30 DPD at 74.57%, 61–90 DPD at 52.83% — a 21.74 pp gap
• Top priority account: LN000007 with DPD 78, risk score 100, ₹44,636 uncollected
• Phone Call outperformed Field Visit by 18.98 pp in this sample (68.44% vs 49.46%)

🛠 Tech stack: Excel · PostgreSQL · SQL · Power BI Desktop · DAX
🎯 Domain: BFSI · Lending · Credit Risk · Collection Analytics · NPA Management

🔗 GitHub: [your-github-link-here]
```
LinkedIn Announcement Post
```
📊 Excited to share my latest data analytics portfolio project — FinNova EWS & Collection
Analytics!

I built a complete end-to-end FinTech analytics system from scratch:

🔹 Excel → designed a 6-table lending data model with EWS risk scoring
🔹 PostgreSQL/SQL → data quality checks, KPI analysis, 5 reusable views
🔹 Power BI → 5 interactive dashboards for collection, risk, executive, and compliance

💡 The headline finding? Early intervention matters more than most people realise.
In this project's data, realization drops by 21.74 percentage points from early (1–30 DPD)
to severely delinquent (61–90 DPD) accounts. That's the entire business case for an Early
Warning System.

This project gave me hands-on experience with:
✅ BFSI domain concepts — DPD, NPA, EWS, IRACP, collection priority
✅ SQL analytical patterns — account-level aggregation, DISTINCT ON, NULLIF, views
✅ Power BI design — 5-page dashboard, DAX measures, slicers, cross-filtering

Check it out on GitHub 👉 [your-github-link]

#DataAnalytics #FinTech #BFSI #SQL #PowerBI #DataPortfolio #LoanAnalytics #CreditRisk
```
Short Interview Explanation
> "FinNova is an end-to-end FinTech analytics project. I started by designing a six-table lending database in Excel covering customers, loans, repayments, monthly behaviour, early warning signals, and collection activity. I then moved the data into PostgreSQL where I ran data quality checks and built five reusable analytical views using SQL aggregation, GROUP BY, NULLIF for safe division, and DISTINCT ON for the latest EWS record per account. Finally, I connected those views to Power BI and built five dashboard pages answering different business questions — from daily collection priorities to executive portfolio health to a demo RBI compliance view. The main analytical insight is a 21.74 percentage-point drop in collection realization between early-stage (1–30 DPD) and severely delinquent (61–90 DPD) accounts, which demonstrates why early warning systems have real business value."
GitHub Repository Description
```
End-to-end FinTech analytics project: Excel data design → PostgreSQL/SQL analytical 
layer → Power BI decision dashboards for loan collection, EWS risk scoring, 
and NPA prevention | BFSI Portfolio | 6 tables · 5 SQL views · 5 dashboard pages
```
Recruiter Search Keywords
`Data Analyst` · `Power BI Developer` · `SQL Analyst` · `Business Intelligence` · `MIS Reporting` · `BFSI Analytics` · `FinTech Data Analyst` · `Loan Analytics` · `Credit Risk Analytics` · `Collection Analytics` · `NPA Analytics` · `EWS Early Warning System` · `Portfolio Risk Monitoring` · `DPD Analysis` · `PostgreSQL` · `DAX` · `Banking Analytics` · `Financial Data Analyst` · `Entry Level Data Analyst`
---
16. Project Structure
```
finnova-ews-collection-analytics/
│
├── README.md                                  ← This file
├── LICENSE                                    ← MIT License
│
├── data/
│   └── FinNova_EWS_Decision_Intelligence.xlsx ← Source dataset (6 sheets, 95+ records)
│
├── sql/
│   ├── 01_database_setup.sql                  ← Create database and 6 core tables
│   ├── 02_data_quality.sql                    ← Orphan checks, duplicate checks, validation
│   ← 03_collection_kpis.sql                   ← Overall KPI queries
│   ├── 04_performance_by_loan.sql             ← Account-level collection analysis
│   ├── 05_ews_analysis.sql                    ← EWS + collection join queries
│   ├── 06_channel_dpd_analysis.sql            ← Channel and DPD bucket breakdown
│   └── 07_analytical_views.sql               ← 5 reusable views for Power BI
│
├── powerbi/
│   └── finnova_ews.pbix                       ← Power BI Desktop file (5 dashboard pages)
│
├── screenshots/
│   ├── 01_collection_overview.png             ← Dashboard screenshot — add after upload
│   ├── 02_ews_risk_analysis.png
│   ├── 03_executive_command_center.png
│   ├── 04_geographic_risk_atlas.png
│   └── 05_rbi_iracp_view.png
│
└── docs/
    ├── FinNova_EWS_Project_Report.pdf         ← Full project methodology report
    ├── FinNova_Executive_Presentation.pdf     ← Executive slide deck (13 slides)
    ├── FinNova_SQL_Notes_Step_by_Step.docx    ← SQL revision notes with explanations
    └── data_dictionary.md                     ← Column definitions for all 6 tables
```
---
Author
Saurabh Kumar Pandey
MBA (IT & FinTech) Candidate | Manipal University Jaipur
Data Analytics | Power BI | SQL | BFSI Domain
LinkedIn: www.linkedin.com/in/saurabh-kumar-pandey-it-fintech · GitHub: https://github.com/saurabhpandey95
---
> *This is an independent portfolio project built to demonstrate practical data analytics skills for BFSI, FinTech, MIS, and Business Intelligence roles. All data is synthetic. No real customer, loan, or financial institution data was used.*
