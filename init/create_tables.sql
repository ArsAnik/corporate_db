CREATE TABLE loan(
    id UUID PRIMARY KEY,
    name VARCHAR(200) NOT NULL UNIQUE,
    description TEXT,
    max_interest_rate NUMERIC(5,2) NOT NULL CHECK (max_interest_rate >= 0),
    max_amount BIGINT NOT NULL CHECK (max_amount > 0),
    max_term_months SMALLINT NOT NULL CHECK (max_term_months > 0)
);

CREATE TABLE clients(
    id UUID PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    gender CHAR(1)  NOT NULL CHECK (gender IN ('M', 'F')),
    birth_date DATE NOT NULL,
    registration_date TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE client_employment(
    client_id UUID PRIMARY KEY REFERENCES clients(id) ON DELETE CASCADE,
    company_name VARCHAR(200),
    position VARCHAR(200),
    monthly_income BIGINT NOT NULL CHECK (monthly_income >= 0),
    employment_start DATE
);

CREATE TABLE issued_loans(
    id UUID PRIMARY KEY,
    client_id UUID NOT NULL REFERENCES clients(id),
    loan_id UUID NOT NULL REFERENCES loan(id),
    interest_rate NUMERIC(5,2) NOT NULL CHECK (interest_rate >= 0),
    amount BIGINT CHECK (amount > 0),
    term_months SMALLINT NOT NULL CHECK (term_months > 0),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('active','closed','overdue','restruct', 'rehabilitated')),
    CONSTRAINT end_after_start CHECK (end_date > start_date)
);

CREATE TABLE payments(
    id UUID PRIMARY KEY,
    issued_loan_id UUID NOT NULL REFERENCES issued_loans(id),
    due_date DATE NOT NULL,
    payment_date DATE,
    scheduled_amount BIGINT NOT NULL CHECK (scheduled_amount > 0),
    actual_amount BIGINT CHECK (actual_amount >= 0)
);

CREATE TABLE loan_guarantors(
    loan_id UUID NOT NULL REFERENCES issued_loans(id),
    guarantor_id UUID NOT NULL REFERENCES clients(id),
    PRIMARY KEY (loan_id, guarantor_id)
);
