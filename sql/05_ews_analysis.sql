-- ============================================================
-- FinNova EWS & Collection Analytics
-- File: 05_ews_analysis.sql
-- Purpose: Early Warning System analysis and risk scoring
-- Connects EWS signals to loan and collection data
-- Author: Saurabh Kumar Pandey
-- ============================================================

-- ============================================================
-- QUERY 1: EWS Signal Summary by Loan
-- Shows how many signals each loan triggered and the resulting score
-- ============================================================

SELECT
    e.loan_id,
    c.customer_name,
    c.city,
    e.ews_month,
    e.dpd_signal,
    e.payment_signal,
    e.bounce_signal,
    e.partial_payment_signal,
    e.trend_signal,
    e.total_signals,
    e.risk_score,
    e.risk_band,
    e.ews_level,
    e.collection_priority,
    e.recommended_action
FROM ews e
JOIN loan l     ON e.loan_id     = l.loan_id
JOIN customer c ON l.customer_id = c.customer_id
ORDER BY e.risk_score DESC, e.ews_month DESC;

-- ============================================================
-- QUERY 2: Latest EWS Record Per Loan (Current Risk Status)
-- Uses DISTINCT ON to get one row per loan — the most recent EWS entry
-- This is the correct way to show current risk without duplicates
-- ============================================================

SELECT DISTINCT ON (e.loan_id)
    e.loan_id,
    c.customer_name,
    c.city,
    e.ews_month                AS latest_ews_month,
    e.risk_score,
    e.risk_band,
    e.ews_level,
    e.collection_priority,
    e.recommended_action,
    e.total_signals
FROM ews e
JOIN loan l     ON e.loan_id     = l.loan_id
JOIN customer c ON l.customer_id = c.customer_id
ORDER BY e.loan_id, e.ews_month DESC;

-- Expected: 4 unique loans with EWS records (LN000001 x2, LN000002 x3, LN000004 x4, LN000007 x1)
-- DISTINCT ON keeps only the most recent entry per loan

-- ============================================================
-- QUERY 3: EWS Level Distribution
-- Counts how many loans fall into each risk category
-- ============================================================

SELECT
    e.ews_level,
    e.risk_band,
    e.collection_priority,
    COUNT(DISTINCT e.loan_id)   AS unique_loans,
    COUNT(e.ews_id)             AS total_ews_records,
    AVG(e.risk_score)           AS avg_risk_score,
    MAX(e.risk_score)           AS max_risk_score
FROM ews e
GROUP BY e.ews_level, e.risk_band, e.collection_priority
ORDER BY max_risk_score DESC;

-- ============================================================
-- QUERY 4: EWS + Collection Performance Combined
-- Joins the latest EWS record with actual repayment performance
-- This is the analytical core of the Early Warning system
-- ============================================================

SELECT
    e.loan_id,
    c.customer_name,
    c.city,
    e.ews_level,
    e.risk_score,
    e.risk_band,
    e.collection_priority,
    mb.dpd_trend,
    mb.payment_ratio,
    mb.bounce_count,
    MAX(r.dpd)                                                              AS current_max_dpd,
    SUM(r.due_amount - r.paid_amount)                                       AS total_uncollected,
    ROUND(SUM(r.paid_amount) / NULLIF(SUM(r.due_amount), 0) * 100, 2)     AS realization_pct,
    CASE
        WHEN MAX(r.dpd) >= 60 THEN 'Imminent NPA — Immediate Action'
        WHEN MAX(r.dpd) >= 30 THEN 'High Priority — Escalate Collection'
        WHEN MAX(r.dpd) >= 1  THEN 'Early Intervention — Proactive Contact'
        ELSE 'Monitor'
    END                                                                     AS business_action
FROM (
    -- Latest EWS per loan
    SELECT DISTINCT ON (loan_id)
        loan_id, ews_level, risk_score, risk_band, collection_priority, ews_month
    FROM ews
    ORDER BY loan_id, ews_month DESC
) e
JOIN loan l             ON e.loan_id     = l.loan_id
JOIN customer c         ON l.customer_id = c.customer_id
JOIN repayment r        ON l.loan_id     = r.loan_id
LEFT JOIN (
    -- Latest monthly behaviour per loan
    SELECT DISTINCT ON (loan_id)
        loan_id, dpd_trend, payment_ratio, bounce_count
    FROM monthly_behaviour
    ORDER BY loan_id, behaviour_month DESC
) mb ON l.loan_id = mb.loan_id
WHERE r.paid_amount < r.due_amount
  AND l.loan_id IN (SELECT DISTINCT loan_id FROM collection_activity)
GROUP BY
    e.loan_id, c.customer_name, c.city, e.ews_level, e.risk_score,
    e.risk_band, e.collection_priority, mb.dpd_trend, mb.payment_ratio, mb.bounce_count
ORDER BY e.risk_score DESC, current_max_dpd DESC;

-- ============================================================
-- QUERY 5: EWS Risk Score Breakdown
-- Shows which signals contributed to the risk score
-- Useful for understanding WHY a loan has a high risk score
-- ============================================================

SELECT
    e.loan_id,
    c.customer_name,
    e.ews_month,
    e.risk_score,
    e.risk_band,
    CASE WHEN e.dpd_signal              = 1 THEN 'DPD ≥ 1'             ELSE 'No DPD Signal'    END  AS dpd_signal_status,
    CASE WHEN e.payment_signal          = 1 THEN 'Payment Stress'      ELSE 'Payment OK'       END  AS payment_signal_status,
    CASE WHEN e.bounce_signal           = 1 THEN 'Bounce Occurred'     ELSE 'No Bounce'        END  AS bounce_signal_status,
    CASE WHEN e.partial_payment_signal  = 1 THEN 'Partial Pattern'     ELSE 'Full Payments'    END  AS partial_signal_status,
    CASE WHEN e.trend_signal            = 1 THEN 'Deteriorating Trend' ELSE 'Stable Trend'     END  AS trend_signal_status,
    e.total_signals                                                       AS total_signals_triggered,
    e.risk_reason,
    e.action_reason
FROM ews e
JOIN loan l     ON e.loan_id     = l.loan_id
JOIN customer c ON l.customer_id = c.customer_id
WHERE e.risk_score >= 50   -- Focus on moderate to high risk accounts
ORDER BY e.risk_score DESC, e.ews_month DESC;

-- ============================================================
-- QUERY 6: Monthly Behaviour Trend Analysis
-- Shows how borrower behaviour evolved month by month
-- ============================================================

SELECT
    mb.loan_id,
    c.customer_name,
    mb.behaviour_month,
    mb.max_dpd,
    mb.payment_ratio,
    mb.bounce_count,
    mb.partial_payment_count,
    mb.dpd_trend,
    mb.risk_signal,
    LAG(mb.max_dpd) OVER (PARTITION BY mb.loan_id ORDER BY mb.behaviour_month)
                                                            AS prev_month_dpd,
    mb.max_dpd - COALESCE(
        LAG(mb.max_dpd) OVER (PARTITION BY mb.loan_id ORDER BY mb.behaviour_month), 0
    )                                                       AS dpd_change_vs_prev_month
FROM monthly_behaviour mb
JOIN loan l     ON mb.loan_id    = l.loan_id
JOIN customer c ON l.customer_id = c.customer_id
ORDER BY mb.loan_id, mb.behaviour_month;

-- This shows how quickly DPD escalated for LN000004 and LN000007
