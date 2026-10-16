-- ============================================================
-- FinNova EWS & Collection Analytics
-- File: 07_analytical_views.sql
-- Purpose: 5 reusable SQL views consumed by Power BI
-- These views encapsulate the analytical logic so Power BI
-- simply reads from clean, pre-aggregated views
-- Author: Saurabh Kumar Pandey
-- ============================================================

-- ============================================================
-- VIEW 1: vw_collection_performance
-- Activity-level collection data with full customer and EWS context
-- Used by: Collection Overview page, account detail table
-- ============================================================

CREATE OR REPLACE VIEW vw_collection_performance AS
SELECT
    r.repayment_id,
    r.loan_id,
    l.loan_product,
    l.sanction_amount,
    l.risk_grade,
    c.customer_id,
    c.customer_name,
    c.city,
    c.state,
    c.customer_segment,
    c.employment_type,
    r.due_date,
    r.payment_date,
    r.due_amount                                                             AS total_promised,
    r.paid_amount                                                            AS total_collected,
    (r.due_amount - r.paid_amount)                                          AS total_uncollected,
    r.dpd,
    CASE
        WHEN r.dpd BETWEEN 1  AND 30 THEN '1-30 DPD'
        WHEN r.dpd BETWEEN 31 AND 60 THEN '31-60 DPD'
        WHEN r.dpd BETWEEN 61 AND 90 THEN '61-90 DPD'
        ELSE 'Other'
    END                                                                      AS dpd_bucket,
    r.payment_status,
    r.bounce_flag,
    r.partial_payment_flag,
    ROUND(r.paid_amount / NULLIF(r.due_amount, 0) * 100, 2)                AS realization_pct,
    e.ews_level,
    e.risk_score,
    e.risk_band,
    e.collection_priority,
    e.recommended_action
FROM repayment r
JOIN loan l     ON r.loan_id     = l.loan_id
JOIN customer c ON l.customer_id = c.customer_id
JOIN (
    SELECT DISTINCT ON (loan_id)
        loan_id, ews_level, risk_score, risk_band, collection_priority, recommended_action
    FROM ews
    ORDER BY loan_id, ews_month DESC
) e ON r.loan_id = e.loan_id
WHERE r.paid_amount < r.due_amount
  AND r.loan_id IN (SELECT DISTINCT loan_id FROM collection_activity);

-- ============================================================
-- VIEW 2: vw_collection_priority
-- One row per loan — the account-level priority queue
-- Used by: Executive Command Center, Priority Queue table
-- Design: MAX(DPD) ensures each loan appears only once
-- ============================================================

CREATE OR REPLACE VIEW vw_collection_priority AS
SELECT
    l.loan_id,
    l.loan_product,
    l.sanction_amount,
    c.customer_id,
    c.customer_name,
    c.city,
    c.state,
    e.ews_level,
    e.risk_score,
    e.risk_band,
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
    SELECT DISTINCT ON (loan_id)
        loan_id, ews_level, risk_score, risk_band, collection_priority, recommended_action
    FROM ews
    ORDER BY loan_id, ews_month DESC
) e ON l.loan_id = e.loan_id
WHERE r.paid_amount < r.due_amount
  AND l.loan_id IN (SELECT DISTINCT loan_id FROM collection_activity)
GROUP BY
    l.loan_id, l.loan_product, l.sanction_amount,
    c.customer_id, c.customer_name, c.city, c.state,
    e.ews_level, e.risk_score, e.risk_band, e.collection_priority, e.recommended_action;

-- ============================================================
-- VIEW 3: vw_collection_kpis
-- Headline KPI metrics for dashboard cards
-- Used by: All 5 pages (KPI card measures)
-- ============================================================

CREATE OR REPLACE VIEW vw_collection_kpis AS
SELECT
    COUNT(DISTINCT r.loan_id)                                                AS active_collection_accounts,
    COUNT(r.repayment_id)                                                    AS delinquent_events,
    SUM(r.due_amount)                                                        AS total_promised,
    SUM(r.paid_amount)                                                       AS total_collected,
    SUM(r.due_amount - r.paid_amount)                                        AS total_uncollected,
    ROUND(
        SUM(r.paid_amount) / NULLIF(SUM(r.due_amount), 0) * 100
    , 2)                                                                     AS overall_realization_pct,
    ROUND(
        SUM(r.paid_amount) / NULLIF(COUNT(DISTINCT r.loan_id), 0)
    , 2)                                                                     AS avg_collected_per_account,
    SUM(CASE WHEN r.dpd >= 60 THEN (r.due_amount - r.paid_amount) ELSE 0 END)
                                                                             AS at_risk_exposure_60plus,
    COUNT(DISTINCT CASE WHEN e.risk_band = 'Critical' THEN r.loan_id END)   AS critical_risk_accounts
FROM repayment r
JOIN (
    SELECT DISTINCT ON (loan_id)
        loan_id, risk_band
    FROM ews
    ORDER BY loan_id, ews_month DESC
) e ON r.loan_id = e.loan_id
WHERE r.paid_amount < r.due_amount
  AND r.loan_id IN (SELECT DISTINCT loan_id FROM collection_activity);

-- ============================================================
-- VIEW 4: vw_collection_channel
-- Phone Call vs Field Visit performance
-- Used by: Collection Overview, Executive Command Center
-- ============================================================

CREATE OR REPLACE VIEW vw_collection_channel AS
SELECT
    CASE
        WHEN ca.contact_type IN ('Call', 'SMS', 'WhatsApp') THEN 'Phone Call'
        WHEN ca.contact_type = 'Field Visit'                THEN 'Field Visit'
        ELSE ca.contact_type
    END                                                                      AS channel,
    COUNT(DISTINCT r.loan_id)                                                AS unique_accounts,
    SUM(r.due_amount)                                                        AS total_promised,
    SUM(r.paid_amount)                                                       AS total_collected,
    SUM(r.due_amount - r.paid_amount)                                        AS total_uncollected,
    ROUND(
        SUM(r.paid_amount) / NULLIF(SUM(r.due_amount), 0) * 100
    , 2)                                                                     AS channel_realization_pct
FROM collection_activity ca
JOIN loan l     ON ca.loan_id  = l.loan_id
JOIN repayment r ON r.loan_id  = l.loan_id
WHERE r.paid_amount < r.due_amount
  AND ca.contact_status = 'Connected'
GROUP BY channel;

-- ============================================================
-- VIEW 5: vw_collection_dpd
-- Collection performance broken down by DPD bucket
-- Used by: Collection Overview DPD chart, Geographic Atlas
-- ============================================================

CREATE OR REPLACE VIEW vw_collection_dpd AS
SELECT
    CASE
        WHEN r.dpd BETWEEN 1  AND 30 THEN '1-30 DPD'
        WHEN r.dpd BETWEEN 31 AND 60 THEN '31-60 DPD'
        WHEN r.dpd BETWEEN 61 AND 90 THEN '61-90 DPD'
        ELSE 'Other'
    END                                                                      AS dpd_bucket,
    c.city,
    COUNT(DISTINCT r.loan_id)                                                AS unique_accounts,
    SUM(r.due_amount)                                                        AS total_promised,
    SUM(r.paid_amount)                                                       AS total_collected,
    SUM(r.due_amount - r.paid_amount)                                        AS total_uncollected,
    ROUND(
        SUM(r.paid_amount) / NULLIF(SUM(r.due_amount), 0) * 100
    , 2)                                                                     AS realization_pct
FROM repayment r
JOIN loan l     ON r.loan_id     = l.loan_id
JOIN customer c ON l.customer_id = c.customer_id
WHERE r.paid_amount < r.due_amount
  AND r.loan_id IN (SELECT DISTINCT loan_id FROM collection_activity)
GROUP BY dpd_bucket, c.city
ORDER BY dpd_bucket, realization_pct ASC;

-- ============================================================
-- Verify all 5 views were created successfully
-- ============================================================

SELECT table_name AS view_name,
       'View created successfully' AS status
FROM information_schema.views
WHERE table_schema = 'public'
  AND table_name IN (
      'vw_collection_performance',
      'vw_collection_priority',
      'vw_collection_kpis',
      'vw_collection_channel',
      'vw_collection_dpd'
  )
ORDER BY table_name;

-- ============================================================
-- Quick validation: Check row counts in each view
-- ============================================================

SELECT 'vw_collection_performance' AS view_name, COUNT(*) AS row_count FROM vw_collection_performance
UNION ALL
SELECT 'vw_collection_priority',    COUNT(*) FROM vw_collection_priority
UNION ALL
SELECT 'vw_collection_kpis',        COUNT(*) FROM vw_collection_kpis
UNION ALL
SELECT 'vw_collection_channel',     COUNT(*) FROM vw_collection_channel
UNION ALL
SELECT 'vw_collection_dpd',         COUNT(*) FROM vw_collection_dpd;
