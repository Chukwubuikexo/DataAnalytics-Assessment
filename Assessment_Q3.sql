SELECT 
    plans_plan.id AS plan_id,
    plans_plan.owner_id,
    CASE 
        WHEN plans_plan.is_a_fund = 1 THEN 'Investment'
        WHEN plans_plan.is_regular_savings = 1 THEN 'Savings'
    END AS type,
    MAX(s.transaction_date) AS last_transaction_date, # from avings_savingsaccount table
    DATEDIFF(CURRENT_DATE, MAX(s.transaction_date)) AS inactivity_days
FROM plans_plan
LEFT JOIN savings_savingsaccount s ON plans_plan.id = s.plan_id AND s.confirmed_amount > 0
WHERE 
    plans_plan.is_deleted = 0
    AND plans_plan.is_archived = 0
    AND (plans_plan.is_a_fund = 1 OR plans_plan.is_regular_savings = 1)
GROUP BY 
    plans_plan.id, 
    plans_plan.owner_id,
    plans_plan.is_a_fund,
    plans_plan.is_regular_savings
HAVING 
    MAX(s.transaction_date) < DATE_SUB(CURRENT_DATE, INTERVAL 1 YEAR ) #  this checks if the latest tansaction of the given account is older than 365 days.