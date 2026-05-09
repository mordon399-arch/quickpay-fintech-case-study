-- Q1: Count transactions by status
SELECT status_clean, COUNT(*) AS transaction_count 
FROM cleaned_transactions 
GROUP BY status_clean; [cite: 13]

-- Q2: Calculate total captured GMV by merchant
SELECT merchant_name_clean, SUM(amount_usd) AS total_captured_gmv 
FROM cleaned_transactions 
WHERE status_clean = 'captured' 
GROUP BY merchant_name_clean; [cite: 13]

-- Q3: Show top 10 merchants by captured GMV
SELECT merchant_name_clean, SUM(amount_usd) AS total_captured_gmv 
FROM cleaned_transactions 
WHERE status_clean = 'captured' 
GROUP BY merchant_name_clean 
ORDER BY total_captured_gmv DESC 
LIMIT 10; [cite: 13]

-- Q4: Show daily GMV and successful transaction count
SELECT transaction_date, SUM(amount_usd) AS daily_gmv, 
       COUNT(CASE WHEN status_clean = 'captured' THEN 1 END) AS successful_tx_count
FROM cleaned_transactions 
GROUP BY transaction_date 
ORDER BY transaction_date; [cite: 13]

-- Q5: Find merchants with chargeback ratio above 1%
SELECT merchant_name_clean, 
       COUNT(CASE WHEN status_clean = 'chargeback' THEN 1 END) * 100.0 / COUNT(*) AS chargeback_ratio
FROM cleaned_transactions 
GROUP BY merchant_name_clean 
HAVING chargeback_ratio > 1; [cite: 13]

-- Q6: Find regions with average risk score above 50 and more than 20 transactions
SELECT gateway_region_clean, AVG(risk_score_clean) AS avg_risk_score, COUNT(*) AS txn_count
FROM cleaned_transactions 
GROUP BY gateway_region_clean 
HAVING avg_risk_score > 50 AND txn_count > 20; [cite: 13]

-- Q7: Find users with 3 or more failed or chargeback transactions on the same day
SELECT user_id, transaction_date, COUNT(*) AS failed_count
FROM cleaned_transactions 
WHERE status_clean IN ('failed', 'chargeback')
GROUP BY user_id, transaction_date 
HAVING failed_count >= 3; [cite: 13]

-- Q8: Show chargeback count, unique affected users, and chargeback amount by merchant
SELECT merchant_name_clean, 
       COUNT(CASE WHEN status_clean = 'chargeback' THEN 1 END) AS chargeback_count,
       COUNT(DISTINCT CASE WHEN status_clean = 'chargeback' THEN user_id END) AS unique_users,
       SUM(CASE WHEN status_clean = 'chargeback' THEN amount_usd ELSE 0 END) AS total_chargeback_amount
FROM cleaned_transactions 
GROUP BY merchant_name_clean; [cite: 13]