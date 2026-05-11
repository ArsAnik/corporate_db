CREATE INDEX idx_clients_registration_date ON clients (registration_date);

CREATE INDEX idx_issued_loans_client_id ON issued_loans (client_id);
CREATE INDEX idx_issued_loans_loan_id ON issued_loans (loan_id);
CREATE INDEX idx_issued_loans_status ON issued_loans (status);
CREATE INDEX idx_issued_loans_client_status ON issued_loans (client_id, status);
CREATE UNIQUE INDEX udx_issued_loans_client_loan_date ON issued_loans (client_id, loan_id, start_date);

CREATE INDEX idx_payments_loan_id ON payments (issued_loan_id);
CREATE INDEX idx_payments_due_date ON payments (due_date);
CREATE UNIQUE INDEX udx_payments_loan_due_date ON payments (issued_loan_id, due_date);

CREATE INDEX idx_employment_income ON client_employment (monthly_income);

CREATE INDEX idx_guarantors_guarantor_id ON loan_guarantors (guarantor_id);