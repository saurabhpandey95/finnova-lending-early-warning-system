-- ============================================================
-- FinNova EWS & Collection Analytics
-- File: 01_database_setup.sql
-- Purpose: Create database and all 6 core tables
-- Author: Saurabh Kumar Pandey
-- ============================================================

-- Step 1: Create the database (run this outside the database)
-- CREATE DATABASE finnova_ews;
-- \c finnova_ews

-- ============================================================
-- TABLE 1: customer
-- Stores borrower master information
-- Primary key: customer_id
-- ============================================================

CREATE TABLE IF NOT EXISTS customer (
    customer_id       VARCHAR(10)  PRIMARY KEY,
    customer_name     VARCHAR(100) NOT NULL,
    age               INTEGER,
    gender            VARCHAR(10),
    employment_type   VARCHAR(30),   -- Salaried / Self-Employed / Business Owner
    monthly_income    NUMERIC(12,2),
    city              VARCHAR(50),
    state             VARCHAR(50),
    customer_segment  VARCHAR(30),   -- Mass / Emerging Affluent / Affluent
    customer_since    DATE
);

-- ============================================================
-- TABLE 2: loan
-- Stores loan / account-level information
-- Primary key: loan_id | Foreign key: customer_id
-- ============================================================

CREATE TABLE IF NOT EXISTS loan (
    loan_id            VARCHAR(10)  PRIMARY KEY,
    customer_id        VARCHAR(10)  NOT NULL REFERENCES customer(customer_id),
    loan_product       VARCHAR(50),   -- Personal Loan / Consumer Durable / MSME Business Loan
    loan_purpose       VARCHAR(50),
    disbursement_date  DATE,
    sanction_amount    NUMERIC(14,2),
    interest_rate      NUMERIC(6,4),  -- stored as decimal (e.g. 0.1450 = 14.50%)
    tenure_months      INTEGER,
    emi_amount         NUMERIC(12,4),
    outstanding_amount NUMERIC(14,2),
    loan_status        VARCHAR(10),   -- Active / Closed
    risk_grade         VARCHAR(2)     -- A / B / C
);

-- ============================================================
-- TABLE 3: repayment
-- Tracks individual EMI repayment events and delinquency
-- Primary key: repayment_id | Foreign key: loan_id
-- ============================================================

CREATE TABLE IF NOT EXISTS repayment (
    repayment_id          VARCHAR(10)  PRIMARY KEY,
    loan_id               VARCHAR(10)  NOT NULL REFERENCES loan(loan_id),
    due_date              DATE,
    payment_date          DATE,
    due_amount            NUMERIC(12,2),
    paid_amount           NUMERIC(12,2),
    dpd                   INTEGER,      -- Days Past Due at time of payment
    payment_status        VARCHAR(10),  -- Paid / Partial
    bounce_flag           INTEGER,      -- 1 = bounce, 0 = no bounce
    partial_payment_flag  INTEGER       -- 1 = partial, 0 = full
);

-- ============================================================
-- TABLE 4: monthly_behaviour
-- Captures monthly borrower-level behaviour signals for EWS
-- Primary key: behaviour_id | Foreign key: loan_id
-- ============================================================

CREATE TABLE IF NOT EXISTS monthly_behaviour (
    behaviour_id           VARCHAR(10)  PRIMARY KEY,
    loan_id                VARCHAR(10)  NOT NULL REFERENCES loan(loan_id),
    behaviour_month        VARCHAR(7),  -- YYYY-MM format
    max_dpd                INTEGER,
    avg_dpd                NUMERIC(6,2),
    payment_ratio          NUMERIC(4,2), -- 0.00 to 1.00 (paid / due)
    bounce_count           INTEGER,
    partial_payment_count  INTEGER,
    dpd_trend              VARCHAR(20),  -- Stable / Deteriorating
    risk_signal            VARCHAR(20)   -- Normal / Watch / Early Warning / High Risk / Severe Risk
);

-- ============================================================
-- TABLE 5: ews
-- Early Warning System scoring table
-- Primary key: ews_id | Foreign key: loan_id
-- ============================================================

CREATE TABLE IF NOT EXISTS ews (
    ews_id                   VARCHAR(10)   PRIMARY KEY,
    loan_id                  VARCHAR(10)   NOT NULL REFERENCES loan(loan_id),
    ews_month                VARCHAR(7),   -- YYYY-MM format
    dpd_signal               INTEGER,      -- 1 = triggered, 0 = not triggered
    payment_signal           INTEGER,
    bounce_signal            INTEGER,
    partial_payment_signal   INTEGER,
    trend_signal             INTEGER,
    total_signals            INTEGER,      -- Sum of all 5 signal flags (0–5)
    ews_level                VARCHAR(20),  -- Normal / Watch / Early Warning / High Risk
    risk_score               INTEGER,      -- Weighted score 0–100
    risk_band                VARCHAR(20),  -- Low / Moderate / High / Critical
    collection_priority      VARCHAR(25),  -- P1 – Immediate / P2 – High / P3 – Monitor / P4 – Routine
    recommended_action       VARCHAR(60),
    risk_reason              VARCHAR(100),
    action_reason            VARCHAR(150)
);

-- ============================================================
-- TABLE 6: collection_activity
-- Tracks collection team interactions with borrowers
-- Primary key: collection_id | Foreign key: loan_id
-- ============================================================

CREATE TABLE IF NOT EXISTS collection_activity (
    collection_id     VARCHAR(10)  PRIMARY KEY,
    loan_id           VARCHAR(10)  NOT NULL REFERENCES loan(loan_id),
    collection_date   DATE,
    contact_type      VARCHAR(20),  -- Call / Field Visit / WhatsApp / SMS
    contact_status    VARCHAR(20),  -- Connected / No Answer / No Response
    promise_to_pay    VARCHAR(5),   -- Yes / No
    promised_amount   NUMERIC(12,2) DEFAULT 0,
    collected_amount  NUMERIC(12,2) DEFAULT 0,
    collector_remark  VARCHAR(200)
);

-- ============================================================
-- Verify all tables were created
-- ============================================================

SELECT table_name, 
       (SELECT COUNT(*) FROM information_schema.columns 
        WHERE table_name = t.table_name 
          AND table_schema = 'public') AS column_count
FROM information_schema.tables t
WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- Expected output:
-- collection_activity  | 9
-- customer             | 10
-- ews                  | 16
-- loan                 | 12
-- monthly_behaviour    | 10
-- repayment            | 10
