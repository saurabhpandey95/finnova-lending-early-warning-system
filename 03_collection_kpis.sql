-- ============================================================
-- FinNova EWS & Collection Analytics
-- File: 03_collection_kpis.sql
-- Purpose: Calculate overall collection KPI summary
-- These are the headline dashboard numbers
-- Author: Saurabh Kumar Pandey
-- ============================================================

-- ============================================================
-- QUERY 1: Overall Collection KPIs
-- Source: Repayment table for loans with active collection activity
-- Uses: COUNT, SUM, NULLIF (division-by-zero protection), ROUND
-- Result: 5 activities | ₹1,67,077 promised | ₹99,000 collected
--         ₹68,077 uncollected | 59.25% overall realization
-- ============================================================

SELECT
    COUNT(DISTINCT r.loan_id)                                                AS active_collection_accounts,
    COUNT(r.repayment_id)                                                    AS delinquent_repayment_events,
    SUM(r.due_amount)                                                        AS total_promised,
    SUM(r.paid_amount)                                                       AS total_collected,
    SUM(r.due_amount - r.paid_amount)                                        AS total_uncollected,
    ROUND(
        SUM(r.paid_amount) / NULLIF(SUM(r.due_amount), 0) * 100
    , 2)                                                                     AS overall_realization_pct
FROM repayment r
WHERE r.paid_amount < r.due_amount   -- Only delinquent repayment records
  AND r.loan_id IN (
      SELECT DISTINCT loan_id FROM collection_activity
  );

-- Expected Results:
-- active_collection_accounts  : 3
-- delinquent_repayment_events : 5
-- total_promised              : 167,077
-- total_collected             : 99,000
-- total_uncollected           : 68,077
-- overall_realization_pct     : 59.25

-- ============================================================
-- QUERY 2: Portfolio-Level KPIs Including All Loans
-- Source: All repayment records (not just collection-active)
-- ============================================================

SELECT
    COUNT(DISTINCT l.loan_id)   AS total_active_loans,
    COUNT(DISTINCT l.customer_id) AS total_customers,
    COUNT(DISTINCT ca.loan_id)  AS loans_in_collection,
    COUNT(DISTINCT CASE WHEN e.risk_band = 'Critical' THEN e.loan_id END)
                                AS critical_risk_accounts,
    ROUND(AVG(e.risk_score), 2) AS avg_portfolio_risk_score
FROM loan l
LEFT JOIN collection_activity ca ON l.loan_id = ca.loan_id
LEFT JOIN (
    SELECT DISTINCT ON (loan_id)
        loan_id, risk_band, risk_score
    FROM ews
    ORDER BY loan_id, ews_month DESC
) e ON l.loan_id = e.loan_id
WHERE l.loan_status = 'Active';

-- ============================================================
-- QUERY 3: Recovery Gap and At-Risk Exposure
-- These KPIs appear on the Executive Command Center page
-- ============================================================

SELECT
    SUM(r.due_amount - r.paid_amount)               AS recovery_gap,
    SUM(CASE WHEN r.dpd >= 60 THEN (r.due_amount - r.paid_amount) ELSE 0 END)
                                                    AS at_risk_exposure_60plus_dpd,
    ROUND(
        SUM(r.paid_amount) / NULLIF(SUM(r.due_amount), 0) * 100
    , 2)                                            AS portfolio_realization_pct
FROM repayment r
WHERE r.paid_amount < r.due_amount
  AND r.loan_id IN (SELECT DISTINCT loan_id FROM collection_activity);

-- Expected:
-- recovery_gap                   : 68,077
-- at_risk_exposure_60plus_dpd    : 44,636  (LN000007 only — 61-90 DPD)
-- portfolio_realization_pct      : 59.25

-- ============================================================
-- QUERY 4: Average Collection Velocity
-- Average amount collected per account per collection event
-- ============================================================

SELECT
    COUNT(DISTINCT r.loan_id)                                               AS accounts,
    SUM(r.paid_amount)                                                      AS total_collected,
    ROUND(SUM(r.paid_amount) / NULLIF(COUNT(DISTINCT r.loan_id), 0), 2)   AS avg_collected_per_account
FROM repayment r
WHERE r.paid_amount < r.due_amount
  AND r.loan_id IN (SELECT DISTINCT loan_id FROM collection_activity);

-- Expected: avg_collected_per_account = 33,000 (approx ₹33K per account)

-- ============================================================
-- QUERY 5: NPA Proximity — Imminent NPA Exposure
-- Accounts in 60–90 DPD range are approaching NPA classification
-- ============================================================

SELECT
    r.loan_id,
    c.customer_name,
    c.city,
    MAX(r.dpd)                                AS max_dpd,
    SUM(r.due_amount - r.paid_amount)         AS uncollected_exposure,
    ROUND(SUM(r.paid_amount) / NULLIF(SUM(r.due_amount), 0) * 100, 2)
                                              AS realization_pct,
    'Imminent NPA Risk'                       AS risk_flag
FROM repayment r
JOIN loan l     ON r.loan_id     = l.loan_id
JOIN customer c ON l.customer_id = c.customer_id
WHERE r.paid_amount < r.due_amount
  AND r.dpd BETWEEN 60 AND 90
GROUP BY r.loan_id, c.customer_name, c.city
ORDER BY max_dpd DESC;

-- Expected: LN000007, Customer 00005, Ahmedabad, DPD 78, ₹44,636 uncollected
