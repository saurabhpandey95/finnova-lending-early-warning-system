# FinNova — Lending Early Warning System (EWS)

**FinTech | BFSI | Credit Risk Analytics | Collections Intelligence | Business Intelligence**

FinNova EWS is an end-to-end data analytics portfolio project built using Microsoft Excel, PostgreSQL, SQL, and Power BI. It analyzes borrower repayment behaviour, loan delinquency, collection performance, and early warning indicators using a simulated lending dataset.

The project demonstrates how data analytics can help identify potentially risky loan accounts, monitor collection efficiency, analyze recovery gaps, and prioritize accounts for further investigation.

> **Project Type:** Academic / Portfolio Project  
> **Domain:** FinTech, BFSI, Lending Operations, Credit Risk Analytics  
> **Tools:** Excel, PostgreSQL, SQL, Power BI, Power Query, DAX  
> **Project Status:** Completed analytical portfolio project; not a deployed production system.

---

## 1. Project Overview

The objective of FinNova EWS is to transform structured lending data into useful business insights through data preparation, SQL analysis, risk classification, and interactive dashboards.

### Project Workflow

Excel Data Preparation  
↓  
PostgreSQL Database  
↓  
SQL Data Validation and Analysis  
↓  
Reusable SQL Views  
↓  
Power BI Data Modeling and DAX  
↓  
Interactive Dashboards and Business Insights

### Project Highlights

- Organized six related datasets.
- Designed a PostgreSQL database structure.
- Documented a 15-step SQL analytical workflow.
- Documented five reusable SQL reporting views.
- Developed documented DAX measures and asset-classification logic.
- Created five Power BI dashboard pages.
- Implemented a rule-based Early Warning System using five risk signals.
- Analyzed collection performance, delinquency, risk exposure, and geographic patterns.

---

## 2. Business Problem

Lending institutions need to monitor repayment behaviour and identify accounts that may require early intervention.

Delayed payments, repeated payment failures, partial payments, and declining collection performance can make portfolio monitoring more difficult.

This project explores how Excel, SQL, and Power BI can help answer the following questions:

- Which accounts have higher delinquency?
- How much of the promised amount has been collected?
- Which DPD buckets show weaker collection performance?
- How does collection realization differ by contact channel?
- Which accounts have higher uncollected exposure?
- How can early warning indicators support collection prioritization?

---

## 3. Tools and Technologies

| Tool | Purpose |
|---|---|
| Microsoft Excel | Data preparation, formulas, and initial analysis |
| PostgreSQL | Relational database management |
| SQL | Data validation, joins, aggregations, KPI calculations, and views |
| Power Query | Data transformation and preparation |
| Power BI Desktop | Dashboard development and visualization |
| DAX | Measures, KPIs, and calculated columns |
| GitHub | Project documentation and portfolio presentation |

### Technical Skills Demonstrated

- Data cleaning and preparation
- Relational database concepts
- SQL joins and aggregations
- Data-quality validation
- KPI calculations
- Collection realization analysis
- Delinquency and DPD-bucket analysis
- Rule-based risk classification
- Power BI data modeling
- DAX measures and calculated columns
- Interactive dashboard design
- Business intelligence and data storytelling

---

## 4. Dataset Description

The project documentation describes six datasets.

| Dataset | Documented Records | Purpose |
|---|---:|---|
| Customer | 20 | Borrower information |
| Loan | 25 | Loan and account details |
| Repayment | 20 | Repayment status and delinquency |
| Monthly_Behaviour | 10 | Repayment behaviour indicators |
| EWS | 10 | Early warning assessments and risk classifications |
| Collection_Activity | 10 | Collection interactions and recovery outcomes |

The datasets represent a simulated portfolio and do not represent the actual customers or loan accounts of a financial institution.

**Data note:** The documentation lists 10 records in the Excel `Collection_Activity` dataset, while a documented SQL KPI result reports five collection activities. These counts should be reconciled against the source workbook and database before being treated as equivalent.

---

## 5. Excel Analysis

Excel was used as the initial data preparation and analysis layer.

### Activities

- Organized the six datasets.
- Reviewed columns, identifiers, and data types.
- Checked numeric and categorical fields.
- Documented formula-based calculations.
- Prepared data for database loading and further analysis.

### Excel Functions Documented

- `COUNTIF`
- `COUNTIFS`
- `SUMIF`
- `SUMIFS`
- `IF`
- `IFERROR`
- `XLOOKUP`
- `UNIQUE`
- `DATEDIF`
- `MAXIFS`

These functions support record counting, conditional calculations, lookups, and data analysis.

---

## 6. PostgreSQL and SQL Analysis

PostgreSQL was used to organize the datasets into related tables, while SQL was used to validate data and calculate analytical metrics.

### Database Tables

1. `customer`
2. `loan`
3. `repayment`
4. `monthly_behaviour`
5. `ews`
6. `collection_activity`

### SQL Analysis Performed

- Checked relationships between related tables.
- Tested for orphan records.
- Calculated total promised and collected amounts.
- Calculated uncollected amounts and collection realization.
- Compared collection performance by contact channel.
- Analyzed collection realization by DPD bucket.
- Reviewed account-level collection priorities.
- Analyzed early warning classifications.

The project documentation reports zero orphan records across the tested relationships.

### Documented SQL Views

Five reusable reporting views are documented:

1. `vw_collection_performance`
2. `vw_collection_priority`
3. `vw_collection_kpis`
4. `vw_collection_channel`
5. `vw_collection_dpd`

These views organize analytical results for reporting and Power BI consumption.

---

## 7. Early Warning System (EWS)

The project uses a documented rule-based approach to classify accounts according to five risk signals.

### Risk Signals

1. Days Past Due (DPD)
2. Payment ratio
3. Payment bounce
4. Partial payment
5. Deteriorating repayment trend

### Documented Classification

| Number of Signals | EWS Classification |
|---:|---|
| 0 | Normal |
| 1 | Watch |
| 2–3 | Early Warning |
| 4–5 | High Risk |

The classification helps organize accounts for monitoring and further investigation.

**Important:** This is a project-defined rule-based approach. It is not a validated predictive credit-risk model and should not be used independently to make real lending or collection decisions.

---

## 8. Power BI Dashboard Showcase

The Power BI report contains five pages covering collection performance, risk monitoring, executive reporting, geographic analysis, and asset-classification reporting.

### Dashboard 1: Collection Overview

Displays collection KPIs, promised and collected amounts, collection realization, recovery shortfall, DPD-bucket comparisons, and channel performance.

![Collection Overview](screenshots/01_Collection_Overview.png)

### Dashboard 2: Early Warning and Risk Analysis

Presents risk classifications, early warning indicators, DPD analysis, geographic concentration, and collection actions.

![Early Warning and Risk Analysis](screenshots/02_Early_Warning_Risk_Analysis.png)

### Dashboard 3: Executive Command Center

Provides a consolidated view of portfolio health, recovery shortfall, at-risk exposure, collection efficiency, and the priority collection queue.

![Executive Command Center](screenshots/03_Executive_Command_Center.png)

### Dashboard 4: Geographic Risk Atlas

Compares the sample portfolio across cities using collection realization, DPD ageing, and uncollected exposure.

![Geographic Risk Atlas](screenshots/04_Geographic_Risk_Atlas.png)

### Dashboard 5: RBI IRACP-Related Classification View

Displays the project's asset-classification categories and illustrative provisioning calculations by DPD bucket.

![RBI IRACP Compliance View](screenshots/05_RBI_IRACP_Compliance.png)

**Regulatory note:** This dashboard is an educational demonstration. Its classifications and calculations must be checked against applicable official RBI directions before any regulatory or business use. The project does not claim official RBI approval or certification.

---

## 9. Key Results and Business Insights

The documented dashboard displays the following sample results:

| Metric | Displayed Result |
|---|---:|
| Total Collected | ₹99,000 |
| Total Promised | ₹1,67,077 |
| Collection Realization | 59.25% |
| Promised-versus-Collected Shortfall | Approximately ₹68,077 |
| Portfolio Health / NPA Prevention Index | 83.90 |
| Write-off Risk Score | 12.90 |

Other displayed comparisons include:

| Metric | Displayed Result |
|---|---:|
| Phone Call Recovery Realization | Approximately 68% |
| Field Visit Recovery Realization | Approximately 50% |
| Collection Realization: 1–30 DPD | Approximately 75% |
| Collection Realization: 31–60 DPD | Approximately 60% |
| Collection Realization: 61–90 DPD | Approximately 53% |

These figures are reported outputs from the project's documentation and dashboards. The exact calculations should be verified against the underlying data and measures.

### Business Observations

**1. Collection gap**

The displayed collected amount is lower than the total promised amount. Reviewing uncollected balances can help identify accounts requiring follow-up.

**2. Channel performance**

Phone Call and Field Visit show different recovery realization in the sample report. Further analysis could compare their effectiveness, cost, and suitability for different account types.

**3. Delinquency analysis**

The displayed report shows lower collection realization in older DPD buckets. This can help analysts identify areas for additional account-level investigation.

**4. Risk-based prioritization**

The EWS classification can help organize accounts into monitoring groups, provided the underlying data and classification rules are validated.

**5. Geographic analysis**

City-level comparisons can help identify patterns that merit further investigation. Because the sample is small, these results should not be generalized to real lending markets.

These observations are exploratory. They do not establish causal relationships or guarantee improved collection outcomes.

---

## 10. Business Recommendations

Based on the sample analysis, a lending operations team could consider:

- Reviewing accounts with higher overdue amounts and uncollected exposure.
- Monitoring repayment behaviour and early warning signals regularly.
- Comparing collection performance across DPD buckets.
- Evaluating contact-channel outcomes before allocating collection resources.
- Investigating geographic differences using a larger dataset.
- Validating risk classifications before using them operationally.
- Reconciling source data and KPI calculations to ensure consistent reporting.

---

## 11. Skills Demonstrated

This project demonstrates practical exposure to:

- Excel-based data preparation
- PostgreSQL database organization
- SQL-based analysis and validation
- Collection KPI calculations
- Delinquency and recovery analysis
- Rule-based Early Warning System design
- Power Query transformations
- Power BI data modeling
- DAX calculations
- Interactive dashboard development
- Business intelligence reporting
- Analytical problem-solving
- Data-driven business interpretation

---

## 12. Repository Structure

```text
finnova-lending-early-warning-system/
│
├── README.md
├── data/
│   └── Excel dataset
├── sql/
│   └── SQL scripts and view definitions
├── powerbi/
│   └── Power BI report (.pbix)
├── screenshots/
│   ├── 01_Collection_Overview.png
│   ├── 02_Early_Warning_Risk_Analysis.png
│   ├── 03_Executive_Command_Center.png
│   ├── 04_Geographic_Risk_Atlas.png
│   └── 05_RBI_IRACP_Compliance.png
└── documentation/
    └── Project report and supporting notes
```

The data, SQL, Power BI, and documentation folders should contain the actual project files when uploaded. The folder names alone do not mean those files are included.

---

## 13. How to Explore the Project

1. Review the dashboard screenshots in the `screenshots` folder.
2. Examine the Excel workbook to understand the datasets.
3. Review the SQL scripts to follow the validation and analytical workflow.
4. Open the Power BI `.pbix` file in Power BI Desktop.
5. Explore the report pages, filters, KPIs, and visualizations.
6. Compare dashboard results with the source data and SQL calculations.

---

## 14. Project Limitations and Future Improvements

### Limitations

- The project uses a small simulated dataset.
- The EWS rules have not been validated against real repayment outcomes.
- Portfolio health and write-off risk scores are project-defined indicators.
- Regulatory classifications and provisioning calculations are illustrative.
- Some documented collection activity counts require reconciliation.
- The results should not be treated as representative of a real lender's portfolio.

### Future Improvements

- Reconcile dataset counts and dashboard calculations.
- Upload reproducible SQL setup and analysis scripts.
- Document each DAX measure and its business definition.
- Add a data dictionary and data-quality report.
- Validate regulatory calculations against applicable official requirements.
- Test the EWS rules against historical repayment outcomes.
- Add instructions for refreshing and reproducing the report.

---

## 15. Resume Project Description

**FinNova — Lending Early Warning System | Excel, PostgreSQL, SQL, Power BI**

- Developed a lending analytics portfolio project to examine delinquency, collection realization, recovery gaps, and early warning indicators using a simulated dataset.
- Used PostgreSQL and SQL to validate related records, calculate collection KPIs, and analyze performance by DPD bucket and contact channel.
- Created a five-page Power BI report using data modeling, Power Query, DAX, and interactive visualizations to communicate portfolio and collection insights.

---

## 16. Interview Explanation

“I built FinNova EWS as a portfolio project using Excel, PostgreSQL, SQL, and Power BI. I organized sample customer, loan, repayment, behavioural, EWS, and collection data. I used SQL to check data relationships and analyze collection performance and delinquency. Then I created five Power BI report pages to present portfolio KPIs, risk indicators, recovery gaps, and geographic patterns. The EWS uses documented rules to classify accounts based on warning signals. It is an educational project, not a production credit-risk system.”

---

## 17. Disclaimer

This repository is intended for educational and portfolio demonstration purposes only. The sample data and results do not represent actual lending activity. Risk scores, portfolio health indicators, classifications, and provisioning amounts are project-defined or illustrative unless independently validated.

This project is not financial, credit, legal, or regulatory advice. It does not claim official RBI approval or regulatory compliance.

---
