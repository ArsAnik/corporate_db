CREATE INDEX idx_issued_loans_start_date ON issued_loans (start_date);

CREATE INDEX idx_payments_overdue ON payments (issued_loan_id, due_date, scheduled_amount) WHERE payment_date IS NULL;