CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE OR REPLACE PROCEDURE fill_database(count INT DEFAULT 1000000)
LANGUAGE plpgsql
AS $$
DECLARE
    loan_ids   UUID[];
BEGIN
    INSERT INTO loan(id, name, description, max_interest_rate, max_amount, max_term_months)
    SELECT
        gen_random_uuid(),
        'Продукт ' || i || ' ' || substring(md5(random()::text) from 1 for 8),
        'Описание: ' || substring(md5(random()::text) from 5 for 20),
        (random() * 50 + 5)::NUMERIC(5,2),
        (ARRAY[50000, 100000, 200000, 500000, 1000000, 5000000, 10000000])[floor(random() * 7 + 1)::INT],
        (ARRAY[6, 12, 24, 36, 60, 120, 180, 240, 300, 360])[floor(random() * 10 + 1)::INT]
    FROM generate_series(1, 10) AS i;

    SELECT ARRAY(SELECT id FROM loan) INTO loan_ids;

    INSERT INTO clients(id, name, gender, birth_date, registration_date)
    SELECT
        gen_random_uuid(),
        substring(md5(i::text) from 1 for 15),
        CASE WHEN random() < 0.5 THEN 'M' ELSE 'F' END,
        CURRENT_DATE - (interval '18 years' + random() * interval '82 years'),
        NOW() - (random() * interval '5 years')
    FROM generate_series(1, count) AS i;

    INSERT INTO client_employment(client_id, company_name, position, monthly_income, employment_start)
    SELECT
        id,
        'Компания ' || substring(md5(id::text) from 1 for 10),
        substring(md5(id::text) from 5 for 15),
        (floor(random() * 50 + 2) * 10000),
        CURRENT_DATE - (random() * interval '10 years')
    FROM clients;

    INSERT INTO issued_loans(id, client_id, loan_id, interest_rate, amount, term_months, start_date, end_date, status)
    SELECT
        gen_random_uuid(),
        c.id,
        loan_ids[(floor(random() * array_length(loan_ids, 1)) + 1)::INT],
        (random() * 50 + 5)::NUMERIC(5,2),
        (ARRAY[50000, 100000, 200000, 500000, 1000000, 5000000, 10000000])[floor(random() * 7 + 1)::INT],
        term_months,
        registration_date::DATE,
        registration_date::DATE + (interval '1 month' * term_months),
        (ARRAY['active','closed','overdue','restruct', 'rehabilitated'])[floor(random() * 5 + 1)::INT]
    FROM (
        SELECT
            c.id,
            c.registration_date,
            (ARRAY[6, 12, 24, 36, 60, 120, 180, 240, 300, 360])[floor(random() * 10 + 1)::INT] AS term_months
        FROM clients c
        WHERE random() < 0.6
    ) c;

    INSERT INTO payments(id, issued_loan_id, due_date, payment_date, scheduled_amount, actual_amount)
    SELECT
        gen_random_uuid(),
        il.id,
        il.start_date + (interval '1 month' * i),
        CASE WHEN random() < 0.9 THEN il.start_date + (interval '1 month' * i) ELSE NULL END,
        GREATEST((il.amount / il.term_months), 1),
        CASE WHEN random() < 0.9 THEN GREATEST((il.amount / il.term_months)::BIGINT, 1) ELSE 0 END
    FROM issued_loans il
    CROSS JOIN generate_series(1, 3) AS i;

    INSERT INTO loan_guarantors(loan_id, guarantor_id)
    SELECT
        il.id,
        g.id
    FROM issued_loans il
    JOIN LATERAL (
        SELECT c.id
        FROM clients c
        TABLESAMPLE BERNOULLI(0.01)
        WHERE c.id != il.client_id
        LIMIT 1
    ) g ON TRUE
    WHERE random() < 0.2
    ON CONFLICT DO NOTHING;

    RAISE NOTICE 'Заполнение данными завершено';

END $$;

CALL fill_database(1000000);