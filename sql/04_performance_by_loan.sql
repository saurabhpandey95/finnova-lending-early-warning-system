-- ============================================================
-- FinNova EWS & Collection Analytics
-- File: 04_performance_by_loan.sql
-- Purpose: Account-level collection performance and priority
-- Key design: GROUP BY loan_id with MAX(DPD) to prevent duplicate rows
-- Author: Saurabh Kumar Pandey
-- ============================================================

-- ============================================================
-- QUERY 1: Collection Performance by Loan (Basic)
-- Groups multiple repayment events per loan into one account row
-- Why GROUP BY: Same loan may have multiple delinquent EMIs
-- ============================================================

SELECT
    r.loan_id,
    COUNT(r.repayment_id)                                                    AS repayment_events,
    MAX(r.dpd)                                                               AS max_dpd,
    SUM(r.due_amount)                                                        AS total_promised,
    SUM(r.paid_amount)                                                       AS total_collected,
    SUM(r.due_amount - r.paid_amount)                                        AS total_uncollected,
    ROUND(
        SUM(r.paid_amount) / NULLIF(SUM(r.due_amount), 0) * 100
    , 2)                                                                     AS realization_pct
FROM repayment r
WHERE r.paid_amount < r.due_amount
  AND r.loan_id IN (SELECT DISTINCT loan_id FROM collection_activity)
GROUP BY r.loan_id
ORDER BY realization_pct ASC;

-- Expected Results:
-- LN000007 | 2 events | Max DPD 78 | ₹94,636 promised | ₹50,000 collected | ₹44,636 uncollected | 52.83%
-- LN000004 | 2 events | Max DPD 52 | ₹67,098 promised | ₹45,000 collected | ₹22,098 uncollected | 67.07%
-- LN000002 | 1 event  | Max DPD 12 | ₹5,343  promised | ₹4,000  collected | ₹1,343  uncollected | 74.86%

-- ============================================================
-- QUERY 2: Full Account-Level Priority View
-- Joins loan, customer, and latest EWS record
-- This is the foundation for the Priority Collection Queue
-- ============================================================

SELECT
    l.loan_id,
    c.customer_name,
    c.city,
    l.loan_product,
    l.sanction_amount,
    e.risk_score,
    e.risk_band,
    e.ews_level,
    e.collection_priority,
    e.recommended_action,
    MAX(r.dpd)                                                               AS max_dpd,
    CASE
        WHEN MAX(r.dpd) BETWEEN 1  AND 30 THEN '1-30 DPD'
        WHEN MAX(r.dpd) BETWEEN 31 AND 60 THEN '31-60 DPD'
        WHEN MAX(r.dpd) BETWEEN 61 AND 90 THEN '61-90 DPD'
        ELSE 'Other'
    END                                                                      AS dpd_bucket,
    SUM(r.due_amount)                                                        AS total_promised,
    SUM(r.paid_amount)                                                       AS total_collected,
    SUM(r.due_amount - r.paid_amount)                                        AS total_uncollected,
    ROUND(
        SUM(r.paid_amount) / NULLIF(SUM(r.due_amount), 0) * 100
    , 2)                                                                     AS realization_pct
FROM loan l
JOIN customer c ON l.customer_id = c.customer_id
JOIN repayment r ON l.loan_id = r.loan_id
JOIN (
    -- Subquery: Get the LATEST EWS record per loan
    -- DISTINCT ON keeps only the first row per loan_id after ORDER BY
    -- This prevents the same loan appearing multiple times from multiple EWS months
    SELECT DISTINCT ON (loan_id)
        loan_id,
        risk_score,
        risk_band,
        ews_level,
        collection_priority,
        recommended_action
    FROM ews
    ORDER BY loan_id, ews_month DESC
) e ON l.loan_id = e.loan_id
WHERE r.paid_amount < r.due_amount
  AND l.loan_id IN (SELECT DISTINCT loan_id FROM collection_activity)
GROUP BY
    l.loan_id, c.customer_name, c.city, l.loan_product, l.sanction_amount,
    e.risk_score, e.risk_band, e.ews_level, e.collection_priority, e.recommended_action
ORDER BY e.risk_score DESC, max_dpd DESC;

-- Expected Priority Order:
-- 1. LN000007 | Customer 00005 | Ahmedabad | DPD 78 | Risk 100 | Critical | P1 Immediate
-- 2. LN000004 | Customer 00003 | Jaipur    | DPD 52 | Risk 100 | Critical | P1 Immediate
-- 3. LN000002 | Customer 00001 | Lucknow   | DPD 12 | Risk  85 | Critical | P1 Immediate

-- ============================================================
-- QUERY 3: DPD Bucket Classification
-- Shows which DPD band each account falls into
-- CASE WHEN creates the category label used in dashboard slicers
-- ============================================================

SELECT
    CASE
        WHEN r.dpd BETWEEN 1  AND 30 THEN '1-30 DPD'
        WHEN r.dpd BETWEEN 31 AND 60 THEN '31-60 DPD'
        WHEN r.dpd BETWEEN 61 AND 90 THEN '61-90 DPD'
        WHEN r.dpd = 0               THEN 'Current (0 DPD)'
        ELSE 'Severely Delinquent (90+ DPD)'
    END                                AS dpd_bucket,
    COUNT(DISTINCT r.loan_id)          AS unique_accounts,
    COUNT(r.repayment_id)              AS repayment_events,
    SUM(r.due_amount - r.paid_amount)  AS total_uncollected
FROM repayment r
WHERE r.paid_amount < r.due_amount
GROUP BY dpd_bucket
ORDER BY MIN(r.dpd) ASC;

-- ============================================================
-- QUERY 4: Loan-Level Realization with DPD History
-- Shows the progression of DPD and payments for each collection loan
-- ============================================================

SELECT
    r.repayment_id,
    r.loan_id,
    c.customer_name,
    r.due_date,
    r.payment_date,
    r.due_amount,
    r.paid_amount,
    r.dpd,
    r.payment_status,
    r.bounce_flag,
    r.partial_payment_flag,
    ROUND(r.paid_amount / NULLIF(r.due_amount, 0) * 100, 2) AS event_realization_pct
FROM repayment r
JOIN loan l     ON r.loan_id     = l.loan_id
JOIN customer c ON l.customer_id = c.customer_id
WHERE r.loan_id IN (SELECT DISTINCT loan_id FROM collection_activity)
ORDER BY r.loan_id, r.due_date;
