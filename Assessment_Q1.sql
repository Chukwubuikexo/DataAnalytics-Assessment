WITH customers_on_savings_plan AS (
    SELECT 
        s.owner_id AS customer_id,
        COUNT(*) AS savings_count,
        SUM(s.confirmed_amount) AS total_savings_deposits # hint says confirmed_amount is the field for value of inflow (deposit), hence i am usings it to calcualte total deposits
    FROM 
        savings_savingsaccount s
    JOIN 
        plans_plan p ON s.plan_id = p.id
    WHERE 
        s.confirmed_amount > 0
        AND p.is_regular_savings = 1 # hints says this column carries customers on savings plan 
    GROUP BY 
        s.owner_id
), 
 
customers_on_investments_plan AS (
    SELECT 
        s.owner_id AS customer_id,
        COUNT(*) AS investment_count,
        SUM(s.confirmed_amount) AS total_investment_deposits # i used confimed amount instead of amount as hint says " confirmed_amount is the field for value of inflow (deposit)"
    FROM 
        savings_savingsaccount s
    JOIN 
        plans_plan p ON s.plan_id = p.id
    WHERE 
        s.confirmed_amount > 0
        AND p.is_a_fund = 1  # hints says this column carries customers on investment plan 
    GROUP BY 
        s.owner_id
)

SELECT 
    u.id AS owner_id,
    CONCAT(u.first_name, ' ', u.last_name) AS name,
    s.savings_count,
    i.investment_count,
    ROUND((s.total_savings_deposits + i.total_investment_deposits) / 100.0, 2) AS total_deposits #divide by hundred (as all amount are in kobo, and i need to get it to naira, as 100 kobo = 1 naira) and round to two to match expected output
FROM 
    users_customuser u
JOIN 
    customers_on_savings_plan s ON u.id = s.customer_id
JOIN 
    customers_on_investments_plan i ON u.id = i.customer_id
ORDER BY 
    total_deposits DESC;