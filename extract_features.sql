SELECT
    il.id AS loan_uuid,
    EXTRACT(YEAR FROM age(c.birth_date)) AS client_age,
    ce.monthly_income,
    ROUND(EXTRACT(EPOCH FROM (CURRENT_DATE - ce.employment_start))/ 86400.0, 1) AS employment_days,
    il.interest_rate,
    il.amount,
    il.term_months,
    COALESCE(ps.n_paid, 0) AS n_paid,
    COALESCE(ps.paid_ratio, 0) AS paid_ratio,
    CASE WHEN il.status IN ('overdue', 'restruct') THEN 1 ELSE 0 END AS y_problem
FROM issued_loans      il
JOIN clients            c  ON c.id         = il.client_id
JOIN client_employment ce  ON ce.client_id = c.id
LEFT JOIN (
    SELECT
        issued_loan_id,
        COUNT(*) FILTER (
            WHERE payment_date IS NOT NULL AND actual_amount > 0
        ) AS n_paid,
        (COUNT(*) FILTER (
            WHERE payment_date IS NOT NULL AND actual_amount > 0
        ) / NULLIF(COUNT(*), 0)) AS paid_ratio
    FROM payments
) ps ON ps.issued_loan_id = il.id;