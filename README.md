# finnova-lending-early-warning-system
FinTech lending analytics project using Excel, PostgreSQL, SQL, and Power BI to analyze borrower delinquency, collection performance, early warning signals, loan portfolio risk, and RBI IRACP-related reporting.
# FinNova — Lending Early Warning System (EWS)

### FinTech | Credit Risk Analytics | Collections Intelligence | Business Intelligence

An end-to-end data analytics project that uses Microsoft Excel,
PostgreSQL, SQL, and Power BI to analyze loan repayment behaviour,
collection efficiency, delinquency trends, and early warning signals
in a simulated lending portfolio.

The objective is to demonstrate how structured data analysis can help
identify potentially risky loan accounts, prioritize collection
activities, monitor portfolio performance, and support lending
operations.

> Project type: Portfolio / academic project
>
> Domain: FinTech, NBFC Lending, Credit Risk, Collections Analytics
>
> Tools: Microsoft Excel, PostgreSQL, SQL, Power BI, DAX
>
> Important: This is an analytical portfolio project, not a deployed
> production system used by a financial institution.

---

## Table of Contents

1. Project Overview
2. Business Problem
3. Project Objectives
4. Tools and Technologies
5. Dataset Description
6. Project Workflow
7. Excel Analysis
8. PostgreSQL Database Design
9. SQL Analysis and Queries
10. Early Warning System Methodology
11. Power BI Development
12. Dashboard Showcase
13. Key Business Insights
14. Business Recommendations
15. Skills Demonstrated
16. Business Value
17. Project Limitations
18. Future Improvements
19. How to Explore the Project
20. Repository Structure
21. Resume Project Entry
22. LinkedIn Project Description
23. Interview Explanation
24. Disclaimer

---

## 1. Project Overview

FinNova EWS is a lending analytics project designed to demonstrate
how financial and operational data can be transformed into actionable
business insights.

The project follows an end-to-end analytics workflow:

Excel data preparation
        ↓
PostgreSQL relational database
        ↓
SQL-based analysis
        ↓
Reusable analytical views
        ↓
Power BI data model and DAX
        ↓
Interactive dashboards and business insights

The analytical focus is on identifying early signs of borrower
delinquency, understanding collection performance, analyzing recovery
gaps, and organizing collection priorities.

The project includes:

- Six related database tables.
- A documented 15-step SQL analytical workflow.
- Five reusable PostgreSQL reporting views.
- Nine custom DAX measures.
- One documented calculated column for asset classification.
- Five Power BI dashboard pages.
- A rule-based Early Warning System using five risk signals.
- Portfolio, collection channel, delinquency, and geographic analysis.

The dataset documented for this project contains 20 customers,
25 loans, 20 repayment records, 10 monthly behaviour records,
10 EWS records, and 10 collection activity records.

These figures describe the documented sample dataset. They should
not be interpreted as representing a real financial institution's
portfolio.

---

## 2. Business Problem

Lending institutions need to identify deteriorating loan accounts
before repayment problems become more severe.

If collection teams rely only on overdue status or delayed manual
reporting, they may miss important warning signs such as:

- Increasing Days Past Due (DPD).
- Repeated payment failures or bounces.
- Partial or missed payments.
- Declining payment ratios.
- Deteriorating repayment behaviour.
- Low collection realization.
- Increasing uncollected amounts.

These indicators can help collection and risk teams determine which
accounts need closer monitoring or earlier intervention.

### Problem Statement

How can borrower repayment behaviour, collection activity, and
delinquency indicators be analyzed to identify potentially risky
accounts and improve collection prioritization?

### Project Approach

FinNova EWS combines structured borrower and loan data, SQL-based
analysis, rule-based risk classification, and Power BI reporting.

The resulting dashboards provide different analytical perspectives
for collection operations, risk monitoring, executive review,
geographic analysis, and asset-classification reporting.

---

## 3. Project Objectives

The main objectives are:

1. Organize borrower, loan, repayment, behavioural, EWS, and collection
   data into a structured analytical dataset.

2. Build a relational PostgreSQL database with primary-key and
   foreign-key relationships.

3. Validate data relationships and identify orphan records.

4. Calculate collection realization, recovery gaps, and
   channel-level collection performance.

5. Analyze collection performance across DPD buckets.

6. Implement a rule-based Early Warning System using five
   documented risk signals.

7. Create reusable SQL views for reporting and Power BI analysis.

8. Develop DAX measures for portfolio monitoring, collection
   efficiency, risk exposure, and asset classification.

9. Build five Power BI dashboard pages for different business users.

10. Convert analytical results into practical recommendations
    for lending operations and collection prioritization.

---

## 4. Tools and Technologies

| Tool | Application in the Project |
|---|---|
| Microsoft Excel | Dataset organization, data preparation, formulas, and initial analysis |
| PostgreSQL | Relational database design, data validation, and analytical queries |
| SQL | Joins, aggregations, conditional analysis, KPI calculations, and views |
| Power Query | Data type changes, value replacement, and column renaming |
| Power BI Desktop | Data modeling, report development, and visualization |
| DAX | Business measures and row-level asset classification |
| GitHub | Project documentation, source-code management, and portfolio presentation |

### Technical Concepts Demonstrated

- Relational database design.
- Primary and foreign keys.
- Data quality validation.
- LEFT JOIN and other relational joins.
- GROUP BY and aggregate functions.
- NULLIF and ROUND.
- PostgreSQL DISTINCT ON.
- Reusable SQL views.
- DAX measures and calculated columns.
- Filter context.
- KPI reporting.
- Rule-based risk scoring.
- Delinquency bucket analysis.
- Dashboard design for business stakeholders.

---

## 5. Dataset Description

The project documentation describes six datasets.

### 5.1 Customer

Purpose: Store borrower-level information.

Documented columns include:

- Customer_ID
- Name
- Age
- City
- Employment_Type
- Monthly_Income
- Segment

Documented record count: 20 customers.

### 5.2 Loan

Purpose: Store loan and account information.

Documented columns include:

- Loan_ID
- Customer_ID
- Product
- Sanction_Amount
- EMI
- Interest_Rate
- Risk_Grade

Documented record count: 25 loans.

Documented product categories:

- Personal Loan
- Consumer Durable Loan
- MSME Business Loan

### 5.3 Repayment

Purpose: Track repayment status and delinquency indicators.

Documented columns include:

- Repayment_ID
- Loan_ID
- DPD
- Payment_Status
- Bounce_Flag
- Partial_Payment_Flag

Documented record count: 20 records.

### 5.4 Monthly_Behaviour

Purpose: Analyze repayment behaviour over time.

Documented columns include:

- Loan_ID
- Max_DPD
- Avg_DPD
- Payment_Ratio
- Bounce_Count
- DPD_Trend
- Risk_Signal

Documented record count: 10 records.

### 5.5 EWS

Purpose: Store early warning assessments and risk classifications.

Documented columns include:

- Loan_ID
- EWS_Level
- Risk_Score
- Risk_Band
- Collection_Priority
- Total_Signals

The project documentation also references individual signal fields
and monthly assessment information.

Documented record count: 10 records.

### 5.6 Collection_Activity

Purpose: Analyze collection interactions and recovery outcomes.

Documented columns include:

- Collection_ID
- Loan_ID
- Contact_Type
- Promised_Amount
- Collected_Amount

The SQL documentation also references DPD bucket information.

Documented record count: 10 records in the Excel dataset.

### Dataset Summary

| Dataset | Documented Records | Analytical Purpose |
|---|---:|---|
| Customer | 20 | Borrower information |
| Loan | 25 | Loan and account details |
| Repayment | 20 | Repayment status and delinquency |
| Monthly_Behaviour | 10 | Behavioural indicators |
| EWS | 10 | Risk scores and early warnings |
| Collection_Activity | 10 | Collection performance |

The documentation's portfolio-level SQL result reports five collection
activities in its KPI output. The Excel dataset is documented as
containing ten collection activity records. These figures may reflect
a filtered or aggregated subset, but the precise reconciliation is
not established by the available documentation.

The underlying workbook should be checked before presenting both
counts as equivalent.

---

## 6. Project Workflow

### Phase 1: Data Preparation

Organize the six datasets and review their columns, business keys,
data types, and analytical purposes.

The project documentation identifies two formatting issues:

- Some disbursement dates are stored or displayed as Excel serial
  numbers.
- Interest rates are stored as decimal values and require percentage
  formatting for readability.

The documentation also identifies an empty Outstanding_Amount
column in the Loan sheet.

These issues should be addressed before the dataset is used for
additional financial analysis.

### Phase 2: Database Design

Create the six-table PostgreSQL database structure.

The documented relationships are:

- customer → loan
- loan → repayment
- loan → monthly_behaviour
- loan → ews
- loan → collection_activity

Foreign-key relationships connect the loan and customer records
to their associated analytical records.

### Phase 3: Data Quality Validation

Run relationship checks to identify records that reference
nonexistent parent records.

The project documentation reports zero orphan records across
the tested parent-child relationships.

### Phase 4: SQL Analysis

Use SQL to calculate:

- Collection realization percentages.
- Total promised and collected amounts.
- Uncollected amounts.
- Channel-level collection performance.
- DPD bucket performance.
- Latest EWS assessment per loan.
- Account-level collection priorities.

### Phase 5: Analytical Views

Create five reusable SQL views that provide prepared data for
Power BI reporting.

### Phase 6: Power BI Development

Connect Power BI Desktop to PostgreSQL, import the reporting views,
apply documented Power Query transformations, and configure
relationships using loan_id.

### Phase 7: Risk Scoring and Visualization

Use the documented EWS classifications and DAX calculations to
present portfolio health, risk exposure, collection efficiency,
geographic patterns, and asset-classification information.

### Phase 8: Business Recommendations

Interpret the results to identify collection gaps, compare channels,
and prioritize accounts requiring further investigation.

---

## 7. Excel Analysis

Excel is the initial data preparation and analysis layer.

### Documented Excel Activities

- Organizing the six datasets into separate sheets.
- Reviewing business identifiers.
- Reviewing numeric and categorical fields.
- Using lookup and conditional formulas.
- Calculating collection realization.
- Identifying high-DPD accounts.
- Summarizing collection activity.

### Formulas Documented in the Project

#### Count high-risk records

```excel
=COUNTIF(EWS!K2:K11,"High Risk")
