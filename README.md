## Question 1

### Approach  
I used Common Table Expressions (CTEs) to first identify customers with active savings and investment plans.  

The first CTE queries the `savings_savingsaccount` table to identify funded regular savings plans (`is_regular_savings = 1` with `confirmed_amount > 0`), grouping by customer to count plans and sum deposits. Similarly, the second CTE identifies funded investment plans (`is_a_fund = 1`). By joining these CTEs with the `users_customuser` table, I ensure only customers with both plan types are included.  

Next, I calculated the total combined deposits, convert kobo to naira (dividing by 100), and round to two decimal places for clarity. Finally, I sort by total deposits in descending order to prioritize high-value customers.  

### Challenges  
1. I was initially confused about which "amount" column to use, but the hint mentioned that "confirmed_amount is the field for value of inflow". Since inflow means deposits here, and the question refers to "total deposits", I concluded that the confirmed_amount in the savings_savingsaccount table is most appropriate for calculating total deposits.

---

## Question 2

### Approach  
I created a CTE to count monthly transactions per customer by joining the savings account table with the users table. Then, I calculated the average monthly transactions per customer in a second CTE.  

Next, I categorized users into High, Medium, or Low frequency using a CASE statement based on their average transaction counts. Finally, I aggregated results by frequency category to show customer counts and average transactions per month.  

### Challenges  
1. Initially, I used `savings_savingsaccount.id`, but after reviewing the question, I realized I needed data from two tables, so I switched to `users_customuser.id`.  

2. Setting the frequency ranges was simplified to:  
```sql
CASE
    WHEN avg_txn_per_month >= 10 THEN 'High Frequency'
    WHEN avg_txn_per_month >= 3 THEN 'Medium Frequency'
    ELSE 'Low Frequency'
END
```  
This is equivalent to:  
```sql
CASE
    WHEN avg_txn_per_month >= 10 THEN 'High Frequency'
    WHEN avg_txn_per_month >= 3 AND avg_txn_per_month < 10 THEN 'Medium Frequency'
    ELSE 'Low Frequency'
END
```  
Because the CASE statement evaluates conditions in order, once `≥10` is caught as "High", the next condition (`≥3`) automatically implies `<10`.

---

## Question 3

### Approach  
First, I selected `plan_id`, `owner_id`, and account type using:  
```sql
WHEN p.is_a_fund = 1 THEN 'Investment' 
WHEN p.is_regular_savings = 1 THEN 'Savings'
```  

I extracted the most recent transaction date with `MAX(s.transaction_date) AS last_transaction_date` from the `savings_savingsaccount` table. Then, I calculated days since the last transaction using `DATEDIFF` from the current date to determine inactivity days.  

I used LEFT JOINs with the `savings_savingsaccount` table to find inflow transactions (`confirmed_amount > 0`), ensuring only money coming into accounts was considered, as mentioned in the scenario.  

I filtered for active (non-deleted/archived) savings and investment accounts from the `plans_plan` table. The query groups results by account and uses a HAVING clause to retain only accounts where the last inflow transaction occurred more than one year ago (365 days).  

### Challenges  
1. Initially, I missed filtering for active accounts, but the task specified "all active accounts," so I added the necessary condition.  

2. The question mentions "accounts with no inflow," which in the scenario refers to deposits. However, the task says "transactions." I chose to strictly follow the scenario and used `confirmed_amount` to identify inflows rather than the generic `amount` column.

---

## Question 4

### Approach  
I focused on retrieving the customer ID and concatenating the name. Then, I calculated tenure in months using `GREATEST` to ensure a minimum of 1 month, as directed by the task.  

The CLV calculation is implemented step-by-step (explained in the Challenges section). After performing the calculations, I joined the tables accordingly and ordered the results by estimated CLV.  

### Challenges  
1. Initially, I summed total transactions instead of counting them until I reviewed the expected output again.  

2. The `amount_withdrawn` column was hard to locate because the `withdrawals_withdrawal` table wasn't mentioned in the task. I needed it to determine inflow (`confirmed_amount`) and outflow (`amount_withdrawn`) for calculating action value per transaction.  

3. Setting up the CLV calculation to match the question's format required careful implementation:  

## Counting transactions:

```sql
COUNT(DISTINCT COALESCE(s.id, w.id)) AS total_transactions
```
This line counts the distinct transaction IDs across both savings accounts and withdrawals.

## Summing transaction values:

```sql
SUM(COALESCE(s.confirmed_amount, 0) + COALESCE(w.amount_withdrawn, 0))
``` 
This adds up all the transaction values (both savings and withdrawals).


## Dividing the sum by count to get average value:

```sql
SUM(COALESCE(s.confirmed_amount, 0) + COALESCE(w.amount_withdrawn, 0)) / 
NULLIF(COUNT(DISTINCT COALESCE(s.id, w.id)), 0)
```
This calculates the average transaction value by dividing the total sum by the count of transactions.

## Applying the 0.1% rate to this average:

```sql
(SUM(COALESCE(s.confirmed_amount, 0) + COALESCE(w.amount_withdrawn, 0)) / 100 * 0.001 / 
NULLIF(COUNT(DISTINCT COALESCE(s.id, w.id)), 0))
```
The /100 converts from kobo to the main currency unit, and the * 0.001 applies the 0.1% profit rate.

## Using NULLIF to prevent division by zero:

```sql
NULLIF(COUNT(DISTINCT COALESCE(s.id, w.id)), 0)
```
This prevents division by zero for customers with no transactions.


## This calculation follows the formula in the instructions:

CLV = (total_transactions / tenure) * 12 * avg_profit_per_transaction

Where:
total_transactions = COUNT(DISTINCT COALESCE(s.id, w.id))
tenure = GREATEST(TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()), 1)
avg_profit_per_transaction = (SUM of transaction values / COUNT of transactions) * 0.1%.

--- 
