--- Table"persons"
CREATE TABLE persons (
 person_id serial NOT NULL
);
COMMENT ON COLUMN persons.person_id IS 'COMMENT XXX';
ALTER TABLE ONLY persons ADD CONSTRAINT m_persons_pkey PRIMARY KEY (person_id);
COMMENT ON TABLE persons IS 'xxx';
ALTER TABLE public.persons OWNER TO postgres;

--- Table"debtors"
CREATE TABLE debtors (
 debtor_id serial NOT NULL
, name character varying(45) NOT NULL
, phone_number character varying(45) NOT NULL
, address character varying(45) NOT NULL
, dead integer NOT NULL
, created_at timestamp with time zone NOT NULL
, updated_at timestamp with time zone NOT NULL
, person_id integer NOT NULL
);
COMMENT ON COLUMN debtors.debtor_id IS 'COMMENT XXX';
ALTER TABLE ONLY debtors ADD CONSTRAINT m_debtors_name_uq UNIQUE (name,phone_number,address);
COMMENT ON COLUMN debtors.name IS '';
ALTER TABLE ONLY debtors ADD CONSTRAINT m_debtors_phone_number_uq UNIQUE (name,phone_number,address);
COMMENT ON COLUMN debtors.phone_number IS '';
ALTER TABLE ONLY debtors ADD CONSTRAINT m_debtors_address_uq UNIQUE (name,phone_number,address);
COMMENT ON COLUMN debtors.address IS '';
COMMENT ON COLUMN debtors.dead IS '';
COMMENT ON COLUMN debtors.created_at IS '';
COMMENT ON COLUMN debtors.updated_at IS '';
ALTER TABLE ONLY debtors ADD CONSTRAINT fk_debtors_person_id FOREIGN KEY (person_id) REFERENCES persons(id);
COMMENT ON COLUMN debtors.person_id IS '';
ALTER TABLE ONLY debtors ADD CONSTRAINT m_debtors_pkey PRIMARY KEY (debtor_id);
COMMENT ON TABLE debtors IS 'xxx';
ALTER TABLE public.debtors OWNER TO postgres;

--- Table"operators"
CREATE TABLE operators (
 operator_id serial NOT NULL
, name character varying(45) NOT NULL
, phone_number character varying(45) NOT NULL
, password character varying(45) NOT NULL
, created_at timestamp with time zone NOT NULL
, updated_at timestamp with time zone NOT NULL
);
COMMENT ON COLUMN operators.operator_id IS 'COMMENT XXX';
ALTER TABLE ONLY operators ADD CONSTRAINT m_operators_name_uq UNIQUE (name,phone_number);
COMMENT ON COLUMN operators.name IS '';
ALTER TABLE ONLY operators ADD CONSTRAINT m_operators_phone_number_uq UNIQUE (name,phone_number);
COMMENT ON COLUMN operators.phone_number IS '';
COMMENT ON COLUMN operators.password IS '';
COMMENT ON COLUMN operators.created_at IS '';
COMMENT ON COLUMN operators.updated_at IS '';
ALTER TABLE ONLY operators ADD CONSTRAINT m_operators_pkey PRIMARY KEY (operator_id);
COMMENT ON TABLE operators IS 'xxx';
ALTER TABLE public.operators OWNER TO postgres;

--- Table"joint_guarantors"
CREATE TABLE joint_guarantors (
 joint_guarantor_id serial NOT NULL
, name character varying(45) NOT NULL
, phone_number character varying(45) NOT NULL
, address character varying(45) NOT NULL
, debtor_id integer NOT NULL
, person_id integer NOT NULL
);
COMMENT ON COLUMN joint_guarantors.joint_guarantor_id IS 'COMMENT XXX';
ALTER TABLE ONLY joint_guarantors ADD CONSTRAINT m_joint_guarantors_name_uq UNIQUE (name,phone_number,address);
COMMENT ON COLUMN joint_guarantors.name IS '';
ALTER TABLE ONLY joint_guarantors ADD CONSTRAINT m_joint_guarantors_phone_number_uq UNIQUE (name,phone_number,address);
COMMENT ON COLUMN joint_guarantors.phone_number IS '';
ALTER TABLE ONLY joint_guarantors ADD CONSTRAINT m_joint_guarantors_address_uq UNIQUE (name,phone_number,address);
COMMENT ON COLUMN joint_guarantors.address IS 'COMMENT XXX';
ALTER TABLE ONLY joint_guarantors ADD CONSTRAINT fk_joint_guarantors_debtor_id FOREIGN KEY (debtor_id) REFERENCES debtors(id);
COMMENT ON COLUMN joint_guarantors.debtor_id IS '';
ALTER TABLE ONLY joint_guarantors ADD CONSTRAINT fk_joint_guarantors_person_id FOREIGN KEY (person_id) REFERENCES persons(id);
COMMENT ON COLUMN joint_guarantors.person_id IS '';
ALTER TABLE ONLY joint_guarantors ADD CONSTRAINT m_joint_guarantors_pkey PRIMARY KEY (joint_guarantor_id);
COMMENT ON TABLE joint_guarantors IS 'xxx';
ALTER TABLE public.joint_guarantors OWNER TO postgres;

--- Table"families"
CREATE TABLE families (
 family_id serial NOT NULL
, name character varying(45) NOT NULL
, relationship character varying(45) NOT NULL
, created_at timestamp with time zone NOT NULL
, person_id integer NOT NULL
, debtor_id integer NOT NULL
);
COMMENT ON COLUMN families.family_id IS '';
COMMENT ON COLUMN families.name IS 'COMMENT XXX';
COMMENT ON COLUMN families.relationship IS '';
COMMENT ON COLUMN families.created_at IS 'COMMENT XXX';
ALTER TABLE ONLY families ADD CONSTRAINT fk_families_person_id FOREIGN KEY (person_id) REFERENCES persons(id);
COMMENT ON COLUMN families.person_id IS '';
ALTER TABLE ONLY families ADD CONSTRAINT fk_families_debtor_id FOREIGN KEY (debtor_id) REFERENCES debtors(id);
COMMENT ON COLUMN families.debtor_id IS '';
ALTER TABLE ONLY families ADD CONSTRAINT m_families_pkey PRIMARY KEY (family_id);
COMMENT ON TABLE families IS 'xxx';
ALTER TABLE public.families OWNER TO postgres;

--- Table"blacklist"
CREATE TABLE blacklist (
 person_id serial NOT NULL
);
ALTER TABLE ONLY blacklist ADD CONSTRAINT fk_blacklist_person_id FOREIGN KEY (person_id) REFERENCES persons(id);
COMMENT ON COLUMN blacklist.person_id IS 'COMMENT XXX';
ALTER TABLE ONLY blacklist ADD CONSTRAINT m_blacklist_pkey PRIMARY KEY (person_id);
COMMENT ON TABLE blacklist IS 'xxx';
ALTER TABLE public.blacklist OWNER TO postgres;

--- Table"loans"
CREATE TABLE loans (
 loan_id serial NOT NULL
, loan_total integer NOT NULL
, interest_rate integer NOT NULL
, interest_interval integer NOT NULL
, debtor_id integer NOT NULL
, operator_id integer NOT NULL
, deadline timestamp with time zone NOT NULL
, created_at timestamp with time zone NOT NULL
);
COMMENT ON COLUMN loans.loan_id IS '';
COMMENT ON COLUMN loans.loan_total IS '';
COMMENT ON COLUMN loans.interest_rate IS 'COMMENT XXX';
COMMENT ON COLUMN loans.interest_interval IS '';
ALTER TABLE ONLY loans ADD CONSTRAINT fk_loans_debtor_id FOREIGN KEY (debtor_id) REFERENCES debtors(id);
COMMENT ON COLUMN loans.debtor_id IS '';
ALTER TABLE ONLY loans ADD CONSTRAINT fk_loans_operator_id FOREIGN KEY (operator_id) REFERENCES operators(id);
COMMENT ON COLUMN loans.operator_id IS '';
COMMENT ON COLUMN loans.deadline IS '';
COMMENT ON COLUMN loans.created_at IS '';
ALTER TABLE ONLY loans ADD CONSTRAINT m_loans_pkey PRIMARY KEY (loan_id);
COMMENT ON TABLE loans IS 'xxx';
ALTER TABLE public.loans OWNER TO postgres;

--- Table"repayments"
CREATE TABLE repayments (
 repayment_amount integer NOT NULL
, loan_id integer NOT NULL
, created_at timestamp with time zone NOT NULL
);
COMMENT ON COLUMN repayments.repayment_amount IS 'COMMENT XXX';
ALTER TABLE ONLY repayments ADD CONSTRAINT fk_repayments_loan_id FOREIGN KEY (loan_id) REFERENCES loans(id);
COMMENT ON COLUMN repayments.loan_id IS '';
COMMENT ON COLUMN repayments.created_at IS '';
ALTER TABLE ONLY repayments ADD CONSTRAINT m_repayments_pkey PRIMARY KEY (loan_id);
COMMENT ON TABLE repayments IS 'xxx';
ALTER TABLE public.repayments OWNER TO postgres;

--- Table"withdrawals"
CREATE TABLE withdrawals (
 withdrawal_id serial NOT NULL
, operator_id integer NOT NULL
, debtor_id integer NOT NULL
, created_at timestamp with time zone NOT NULL
);
COMMENT ON COLUMN withdrawals.withdrawal_id IS '';
ALTER TABLE ONLY withdrawals ADD CONSTRAINT fk_withdrawals_operator_id FOREIGN KEY (operator_id) REFERENCES operators(id);
COMMENT ON COLUMN withdrawals.operator_id IS 'COMMENT XXX';
ALTER TABLE ONLY withdrawals ADD CONSTRAINT fk_withdrawals_debtor_id FOREIGN KEY (debtor_id) REFERENCES debtors(id);
COMMENT ON COLUMN withdrawals.debtor_id IS '';
COMMENT ON COLUMN withdrawals.created_at IS '';
ALTER TABLE ONLY withdrawals ADD CONSTRAINT m_withdrawals_pkey PRIMARY KEY (withdrawal_id);
COMMENT ON TABLE withdrawals IS 'xxx';
ALTER TABLE public.withdrawals OWNER TO postgres;


