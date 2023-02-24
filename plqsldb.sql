-- Create all tables
CREATE TABLE customer(
cust_id VARCHAR2(11),
first_name VARCHAR2(25) not null,
last_name VARCHAR2(25) not null,
passwd VARCHAR2(6) not null
);

ALTER TABLE customer
ADD PRIMARY KEY(cust_id);

select constraint_name,constraint_type
from user_constraints
where table_name
= 'CUSTOMER';

ALTER TABLE customer
RENAME CONSTRAINT SYS_C00112377337 to  customer_first_name;
ALTER TABLE customer
RENAME CONSTRAINT SYS_C00112377338 to  customer_last_name;
ALTER TABLE customer
RENAME CONSTRAINT SYS_C00112377339 to  customer_passwd;
ALTER TABLE customer
RENAME CONSTRAINT SYS_C00112377340 to  customer_cust_id_pk;

CREATE TABLE account_type(
accty_id NUMBER(6),
accty_name VARCHAR2(20) not null,
present_interest NUMBER(5, 2) not null
);

ALTER TABLE account_type
ADD PRIMARY KEY(accty_id);

select constraint_name,constraint_type
from user_constraints
where table_name
= 'ACCOUNT_TYPE';

ALTER TABLE account_type
RENAME CONSTRAINT SYS_C00112377501 to  account_type_accty_name;
ALTER TABLE account_type
RENAME CONSTRAINT SYS_C00112377502 to  account_type_present_interest;
ALTER TABLE account_type
RENAME CONSTRAINT SYS_C00112377503 to  account_type_accty_id_pk;

CREATE TABLE account(
acc_id NUMBER(8),
accty_id NUMBER(6),
date_time DATE not null,
balance NUMBER(10, 2) not null
);

ALTER TABLE account
ADD CONSTRAINT account_acc_id_pk PRIMARY KEY(acc_id)
ADD CONSTRAINT account_accty_id_fk FOREIGN KEY(accty_id) REFERENCES account_type(accty_id);

select constraint_name,constraint_type
from user_constraints
where table_name
= 'ACCOUNT';

ALTER TABLE account
RENAME CONSTRAINT SYS_C00112377692 to  account_date_time;
ALTER TABLE account
RENAME CONSTRAINT SYS_C00112377693 to  account_balance;

CREATE TABLE interest_change(
intch_id NUMBER(8),
accty_id NUMBER(6),
date_time DATE NOT NULL,
interest NUMBER(5, 2) NOT NULL
);

ALTER TABLE interest_change
ADD CONSTRAINT interest_change_intch_id_pk PRIMARY KEY(intch_id)
ADD CONSTRAINT interest_change_accty_id_fk FOREIGN KEY(accty_id) REFERENCES account_type(accty_id);

select constraint_name,constraint_type
from user_constraints
where table_name
= 'INTEREST_CHANGE';

ALTER TABLE interest_change
RENAME CONSTRAINT SYS_C00112378148 to interest_change_date_time;
ALTER TABLE interest_change
RENAME CONSTRAINT SYS_C00112378149 to interest_change_interest;

CREATE TABLE account_owner(
accow_id NUMBER(9),
cust_id VARCHAR2(11),
acc_id NUMBER(8)
);

ALTER TABLE account_owner
ADD CONSTRAINT account_owner_accow_id_pk PRIMARY KEY(accow_id)
ADD CONSTRAINT account_owner_cust_id_fk FOREIGN KEY(cust_id) REFERENCES customer(cust_id)
ADD CONSTRAINT account_owner_acc_id_fk FOREIGN KEY(acc_id) REFERENCES account(acc_id);

CREATE TABLE withdrawal(
wit_id NUMBER(9),
cust_id VARCHAR2(11),
acc_id NUMBER(8),
amount NUMBER(10, 2) not null,
date_time DATE not NULL
);

ALTER TABLE withdrawal
ADD CONSTRAINT withdrawal_wit_id_pk PRIMARY KEY(wit_id)
ADD CONSTRAINT withdrawal_cust_id_fk FOREIGN KEY(cust_id) REFERENCES customer(cust_id)
ADD CONSTRAINT withdrawal_acc_id_fk FOREIGN KEY(acc_id) REFERENCES account(acc_id);

select constraint_name,constraint_type
from user_constraints
where table_name
= 'WITHDRAWAL';

ALTER TABLE withdrawal
RENAME CONSTRAINT SYS_C00112378148 to withdrawal_amount;
ALTER TABLE withdrawal
RENAME CONSTRAINT SYS_C00112378149 to withdrawal_date_time;

CREATE TABLE deposition(
dep_id NUMBER(9),
cust_id VARCHAR2(11),
acc_id NUMBER(8),
amount NUMBER(10, 2) not null,
date_time DATE not NULL
);

ALTER TABLE deposition
ADD CONSTRAINT deposition_wit_id_pk PRIMARY KEY(dep_id)
ADD CONSTRAINT deposition_cust_id_fk FOREIGN KEY(cust_id) REFERENCES customer(cust_id)
ADD CONSTRAINT deposition_acc_id_fk FOREIGN KEY(acc_id) REFERENCES account(acc_id);

select constraint_name,constraint_type
from user_constraints
where table_name
= 'DEPOSITION';

ALTER TABLE deposition
RENAME CONSTRAINT SYS_C00112378148 to deposition_amount;
ALTER TABLE deposition
RENAME CONSTRAINT SYS_C00112378149 to deposition_date_time;

CREATE TABLE transfer(
tra_id NUMBER(9),
cust_id VARCHAR2(11),
from_acc_id NUMBER(8),
to_acc_id NUMBER(8),
amount NUMBER(10, 2) not null,
date_time DATE not NULL
);

ALTER TABLE transfer
ADD CONSTRAINT transfer_tra_id_pk PRIMARY KEY(tra_id)
ADD CONSTRAINT transfer_cust_id_fk FOREIGN KEY(cust_id) REFERENCES customer(cust_id)
ADD CONSTRAINT transfer_from_acc_id_fk FOREIGN KEY(from_acc_id) REFERENCES account(acc_id)
ADD CONSTRAINT transfer_to_acc_id_fk FOREIGN KEY(to_acc_id) REFERENCES account(acc_id);

select constraint_name,constraint_type
from user_constraints
where table_name
= 'TRANSFER';

ALTER TABLE transfer
RENAME CONSTRAINT SYS_C00112378148 to transfer_amount;
ALTER TABLE transfer
RENAME CONSTRAINT SYS_C00112378149 to transfer_date_time;

CREATE OR REPLACE TRIGGER bifuer_customer
BEFORE INSERT OR UPDATE
on customer
FOR EACH ROW
WHEN (LENGTH(new.passwd) <> 6)
BEGIN
	raise_application_error(-20001,'Your password must be 6 charachters long');
END;
/

-- Procedure to create a new customer
create or replace procedure do_new_customer(
p_cust_id in customer.cust_id%type,
p_first_name in customer.first_name%type,
p_last_name in customer.last_name%type,
p_passwd in customer.passwd%type)
as
v_cnr number(6);
begin
	insert into customer(cust_id,first_name,last_name, passwd)
	values(p_cust_id,p_first_name,p_last_name,p_passwd);
	commit;
end;
/

-- Test of new customer procedure
EXEC do_new_customer('861124-4478','Vincent','Ortiz','qwe');

BEGIN
do_new_customer('650707-1111','Tito','Ortiz','qwerTY');
do_new_customer('560126-1148','Margreth','Andersson','olle85');
do_new_customer('840317-1457','Mary','Smith','asdfgh');
do_new_customer('861124-4478','Vincent','Ortiz','qwe123');
COMMIT;
END;
/

-- ID generator sequence
CREATE SEQUENCE pk_seq
START WITH 1
INCREMENT BY 1;

-- Function to log in to db
CREATE OR REPLACE FUNCTION log_in(cust_id IN NUMBER, passwd IN VARCHAR2)
RETURN INTEGER
AS
   result INTEGER;
BEGIN
   SELECT COUNT(*) INTO result
   FROM customer
   WHERE cust_id = cust_id AND passwd = passwd;

   IF result = 1 THEN
      RETURN 1;
   ELSE
      RETURN 0;
   END IF;
END;
/

-- Function to get balance of account number
CREATE OR REPLACE FUNCTION get_balance (p_acc_id IN NUMBER) 
RETURN NUMBER
AS
  v_balance NUMBER;
BEGIN
  SELECT balance INTO v_balance
  FROM account
  WHERE acc_id = p_acc_id;
  
  RETURN v_balance;
END;
/

-- Function to determine account ownership
CREATE OR REPLACE FUNCTION get_authority(p_cust_id IN NUMBER, p_acc_id IN NUMBER)
RETURN INTEGER
AS
   result INTEGER;
BEGIN
   SELECT COUNT(*) INTO result
   FROM account_owner
   WHERE cust_id = p_cust_id AND acc_id = p_acc_id;

   IF result = 1 THEN
      RETURN 1;
   ELSE
      RETURN 0;
   END IF;
END;
/

-- Checks if balance is correct after a deposition
CREATE OR REPLACE TRIGGER aifer_deposition
AFTER INSERT ON deposition
FOR EACH ROW
DECLARE
    account_balance NUMBER;
BEGIN
    SELECT balance INTO account_balance
    FROM account
    WHERE acc_id = :new.acc_id;

    account_balance := account_balance + :new.amount;

    UPDATE account
    SET balance = account_balance
    WHERE acc_id = :new.acc_id;
END;
/

-- Checks that there is enough money on account to withdraw the given amount
CREATE OR REPLACE TRIGGER bifer_withdrawal
BEFORE INSERT ON withdrawal
FOR EACH ROW
DECLARE
    account_balance NUMBER;
BEGIN
    account_balance := get_balance(:new.acc_id)

    IF account_balance - :new.amount < 0 THEN
		raise_application_error(-20002, 'You do not have the balance to take withdraw this amount');
	END IF;
END;
/

-- Checks that the balance is correct after withdrawal
CREATE OR REPLACE TRIGGER aifer_withdrawal
AFTER INSERT ON withdrawal
FOR EACH ROW
DECLARE
    account_balance NUMBER;
BEGIN
    SELECT balance INTO account_balance
    FROM account
    WHERE acc_id = :new.acc_id;

    account_balance := account_balance - :new.amount;

    UPDATE account
    SET balance = account_balance
    WHERE acc_id = :new.acc_id;
END;
/

-- Checks that there is enough money on account to transfer the given amount
CREATE OR REPLACE TRIGGER bifer_transfer
BEFORE INSERT ON transfer
FOR EACH ROW
DECLARE
    account_balance NUMBER;
BEGIN
    account_balance := get_balance(:new.from_acc_id)

    IF account_balance - :new.amount < 0 THEN
		raise_application_error(-20003, 'You do not have the balance to take transfer this amount');
	END IF;
END;
/

-- Checks that the balance is correct after transfer
CREATE OR REPLACE TRIGGER aifer_transfer
AFTER INSERT ON transfer
FOR EACH ROW
DECLARE
    account_balance NUMBER;
BEGIN
    SELECT balance INTO account_balance
    FROM account
    WHERE acc_id = :new.from_acc_id;

    account_balance := account_balance - :new.amount;

    UPDATE account
    SET balance = account_balance
    WHERE acc_id = :new.acc_id;
END;
/

-- Creates procedure for doing depositions
create or replace procedure do_deposition(
p_cust_id in deposition.cust_id%type,
p_acc_id in deposition.acc_id%type,
p_amount in deposition.amount%type)
as
v_dep_id number;
v_new_balance deposition.amount%type;
begin
	v_dep_id := pk_seq.NEXTVAL
	insert into deposition(dep_id,cust_id,acc_id,amount,date_time)
	values(v_dep, p_cust_id,p_acc_id,p_amount,SYSDATE);
	commit;
	select balance into v_new_balance 
	from accounts 
	where acc_id = p_acc_id;
	v_new_balance := v_new_balance + p_amount;
	update accounts set balance = v_new_balance where acc_id = p_acc_id;
	dbms_output.put_line('Your new balance: ' || v_new_balance);
end;
/