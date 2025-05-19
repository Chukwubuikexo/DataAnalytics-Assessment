SELECT
    u.id AS customer_id,
    CONCAT(u.first_name, ' ', u.last_name) AS name,
    GREATEST(TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()), 1) AS tenure_months, # i am using GREATEST to enforce the minimum of i month as stipulated in the task
    COUNT(DISTINCT COALESCE(s.id, w.id)) AS total_transactions, 
    ROUND(
        (COUNT(DISTINCT COALESCE(s.id, w.id)) / GREATEST(TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()), 1)) 
        * 12 
        * (SUM(COALESCE(s.confirmed_amount, 0) + COALESCE(w.amount_withdrawn, 0)) / 100 * 0.001 / 
           NULLIF(COUNT(DISTINCT COALESCE(s.id, w.id)), 0)),
        2
    ) AS estimated_clv
FROM
    users_customuser u
LEFT JOIN
    savings_savingsaccount s ON u.id = s.owner_id
LEFT JOIN
    withdrawals_withdrawal w ON u.id = w.owner_id 
GROUP BY
    u.id, u.first_name, u.last_name, u.date_joined
ORDER BY
    estimated_clv DESC;