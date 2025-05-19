WITH monthly_transactions AS (
    SELECT
		u.id AS user_id, #  savings_savingsaccount has id but id has to come from users_customuser, as directed in the question
        DATE_FORMAT(s.transaction_date, '%Y-%m') AS monthly_transaction,
        COUNT(*) AS transaction_count
    FROM
        savings_savingsaccount s
	JOIN
        users_customuser u ON s.owner_id = u.id
    GROUP BY
         u.id, monthly_transaction
#counts trasanction per month from savings table, groups by owner and months transactions
),

avg_monthly_transactions AS (
    SELECT
        user_id,
        AVG(transaction_count) AS avg_txn_per_month
    FROM
        monthly_transactions
    GROUP BY
        user_id
# the above query gets the average number of transactions per month for each customer.
),
categorized_users AS (
    SELECT
        user_id,
        avg_txn_per_month,
        CASE
            WHEN avg_txn_per_month >= 10 THEN 'High Frequency'
            WHEN avg_txn_per_month >= 3 THEN "Medium Frequency"
            ELSE 'Low Frequency'
        END AS frequency_category
    FROM
        avg_monthly_transactions
)
SELECT
    frequency_category,
    COUNT(user_id) AS customer_count,
    ROUND(AVG(avg_txn_per_month), 1) AS avg_transactions_per_month
FROM
    categorized_users
GROUP BY
    frequency_category
ORDER BY
    FIELD(frequency_category, 'High Frequency', 'Medium Frequency', 'Low Frequency');
