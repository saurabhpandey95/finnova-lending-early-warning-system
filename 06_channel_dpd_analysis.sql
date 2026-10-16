-- ============================================================
-- FinNova EWS & Collection Analytics
-- File: 06_channel_dpd_analysis.sql
-- Purpose: Collection performance by contact channel and DPD bucket
-- Author: Saurabh Kumar Pandey
-- ============================================================

-- ============================================================
-- QUERY 1: Collection Performance by Contact Channel
-- Phone Call vs Field Visit
--
-- Channel Mapping Applied:
--   Source (Excel)  → Dashboard Display
--   Call            → Phone Call
--   SMS             → Phone Call
--   WhatsApp        → Phone Call
--   Field Visit     → Field Visit
--
-- Why this mapping? SMS and WhatsApp are phone-based channels;
-- consolidating them with Call gives a meaningful Phone vs Field split.
-- ============================================================

SELECT
    CASE
        WHEN ca.contact_type IN ('Call', 'SMS', 'WhatsApp') THEN 'Phone Call'
        WHEN ca.contact_type = 'Field Visit'                THEN 'Field Visit'
        ELSE ca.contact_type
    END                                                                      AS channel,
    COUNT(DISTINCT ca.loan_id)                                               AS unique_accounts,
    COUNT(ca.collection_id)                                                  AS total_contacts,
    SUM(r.due_amount)                                                        AS total_promised,
    SUM(r.paid_amount)                                                       AS total_collected,
    ROUND(
        SUM(r.paid_amount) / NULLIF(SUM(r.due_amount), 0) * 100
    , 2)                                                                     AS channel_realization_pct
FROM collection_activity ca
JOIN loan l     ON ca.loan_id    = l.loan_id
JOIN repayment r ON r.loan_id   = l.loan_id
WHERE r.paid_amount < r.due_amount
  AND ca.contact_status = 'Connected'  -- Only count successful contacts
GROUP BY channel
ORDER BY channel_realization_pct DESC;

-- Expected Results:
-- Phone Call  | 68.44% realization
-- Field Visit | 49.46% realization

-- ============================================================
-- QUERY 2: Raw Channel Analysis (Before Mapping)
-- Shows all 4 original contact types from the source data
-- ============================================================

SELECT
    ca.contact_type,
    COUNT(ca.collection_id)                AS total_activities,
    SUM(CASE WHEN ca.contact_status = 'Connected' THEN 1 ELSE 0 END)
                                           AS connected_count,
    SUM(ca.promised_amount)                AS raw_promised_amount,
    SUM(ca.collected_amount)               AS raw_collected_amount,
    ROUND(
        SUM(ca.collected_amount) / NULLIF(SUM(ca.promised_amount), 0) * 100
    , 2)                                   AS raw_realization_pct
FROM collection_activity ca
GROUP BY ca.contact_type
ORDER BY raw_realization_pct DESC NULLS LAST;

-- Note: raw_promised_amount uses collection_activity.promised_amount
-- (not the repayment-based analytical-layer amounts used in the dashboard)

-- ============================================================
-- QUERY 3: Collection Performance by DPD Bucket
-- Shows realization rate at each stage of delinquency
-- Key insight: Realization falls as DPD increases
-- ============================================================

SELECT
    CASE
        WHEN r.dpd BETWEEN 1  AND 30 THEN '1-30 DPD'
        WHEN r.dpd BETWEEN 31 AND 60 THEN '31-60 DPD'
        WHEN r.dpd BETWEEN 61 AND 90 THEN '61-90 DPD'
        ELSE 'Other'
    END                                                                      AS dpd_bucket,
    COUNT(DISTINCT r.loan_id)                                                AS unique_accounts,
    SUM(r.due_amount)                                                        AS total_promised,
    SUM(r.paid_amount)                                                       AS total_collected,
    SUM(r.due_amount - r.paid_amount)                                        AS total_uncollected,
    ROUND(
        SUM(r.paid_amount) / NULLIF(SUM(r.due_amount), 0) * 100
    , 2)                                                                     AS realization_pct
FROM repayment r
WHERE r.paid_amount < r.due_amount
  AND r.loan_id IN (SELECT DISTINCT loan_id FROM collection_activity)
GROUP BY dpd_bucket
ORDER BY MIN(r.dpd) ASC;

-- Expected Results:
-- 1-30 DPD  | ₹38,892 promised | ₹29,000 collected | 74.57% realization
-- 31-60 DPD | ₹33,549 promised | ₹20,000 collected | 59.61% realization
-- 61-90 DPD | ₹94,636 promised | ₹50,000 collected | 52.83% realization

-- ============================================================
-- QUERY 4: DPD Gap Analysis
-- Quantifies the realization gap between DPD bands
-- Used for the key insight: 21.74 pp gap between 1-30 and 61-90 DPD
-- ============================================================

WITH dpd_performance AS (
    SELECT
        CASE
            WHEN r.dpd BETWEEN 1  AND 30 THEN '1-30 DPD'
            WHEN r.dpd BETWEEN 31 AND 60 THEN '31-60 DPD'
            WHEN r.dpd BETWEEN 61 AND 90 THEN '61-90 DPD'
        END                                                                  AS dpd_bucket,
        ROUND(
            SUM(r.paid_amount) / NULLIF(SUM(r.due_amount), 0) * 100
        , 2)                                                                 AS realization_pct
    FROM repayment r
    WHERE r.paid_amount < r.due_amount
      AND r.loan_id IN (SELECT DISTINCT loan_id FROM collection_activity)
    GROUP BY dpd_bucket
)
SELECT
    dpd_bucket,
    realization_pct,
    ROUND(
        realization_pct - FIRST_VALUE(realization_pct)
            OVER (ORDER BY realization_pct DESC)
    , 2)                                                                     AS gap_vs_best_band
FROM dpd_performance
ORDER BY realization_pct DESC;

-- Expected gap: 74.57% - 52.83% = 21.74 percentage points
-- This gap quantifies the cost of delayed collection intervention

-- ============================================================
-- QUERY 5: Geographic Collection Performance
-- Collection realization and exposure by city
-- ============================================================

SELECT
    c.city,
    c.state,
    COUNT(DISTINCT l.loan_id)                                                AS active_loans,
    MAX(r.dpd)                                                               AS max_dpd_in_city,
    SUM(r.due_amount)                                                        AS total_promised,
    SUM(r.paid_amount)                                                       AS total_collected,
    SUM(r.due_amount - r.paid_amount)                                        AS total_uncollected,
    ROUND(
        SUM(r.paid_amount) / NULLIF(SUM(r.due_amount), 0) * 100
    , 2)                                                                     AS city_realization_pct
FROM repayment r
JOIN loan l     ON r.loan_id     = l.loan_id
JOIN customer c ON l.customer_id = c.customer_id
WHERE r.paid_amount < r.due_amount
  AND l.loan_id IN (SELECT DISTINCT loan_id FROM collection_activity)
GROUP BY c.city, c.state
ORDER BY city_realization_pct ASC;

-- Expected:
-- Ahmedabad | Gujarat    | 1 loan | DPD 78 | ₹44,636 uncollected | 52.83%
-- Jaipur    | Rajasthan  | 1 loan | DPD 52 | ₹22,098 uncollected | 67.07%
-- Lucknow   | UP         | 1 loan | DPD 12 | ₹1,343  uncollected | 74.86%

-- ============================================================
-- QUERY 6: Promise-to-Pay Fulfilment Rate
-- Measures how reliably borrowers kept their payment commitments
-- ============================================================

SELECT
    ca.promise_to_pay,
    COUNT(ca.collection_id)                 AS total_contacts,
    SUM(ca.promised_amount)                 AS total_amount_promised,
    SUM(ca.collected_amount)                AS total_amount_collected,
    ROUND(
        SUM(ca.collected_amount) / NULLIF(SUM(ca.promised_amount), 0) * 100
    , 2)                                    AS fulfillment_rate_pct
FROM collection_activity ca
WHERE ca.promise_to_pay = 'Yes'
GROUP BY ca.promise_to_pay;
