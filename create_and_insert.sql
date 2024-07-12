--bismillah

-- enum gender type
create type gender_type as enum ('Laki-Laki', 'Perempuan');

-- Mengaktifkan ekstensi pgcrypto
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

--bikin fungsi generate untuk updated_at otomatis
CREATE OR REPLACE FUNCTION customer_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_customer_updated_at
BEFORE UPDATE ON customer
FOR EACH ROW
EXECUTE FUNCTION customer_updated_at_column();

-- ----------------------------------------------- Buat Sequence id-
CREATE SEQUENCE seq_id_address START 1;
CREATE SEQUENCE seq_id_account_type START 1;
CREATE SEQUENCE seq_id_job START 1;
CREATE SEQUENCE seq_id_transaction_type START 1;

--Untuk triggernya 
CREATE OR REPLACE FUNCTION generate_id_transaction_type()
RETURNS TRIGGER AS $$
BEGIN
    NEW.id := 'TT' || TO_CHAR(nextval('seq_id_transaction_type'), 'FM000');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER transaction_type_id_trigger
BEFORE INSERT ON transaction_type
FOR EACH ROW
EXECUTE FUNCTION generate_id_transaction_type();

-- hapus triggger nama_trigger ON nama_table
DROP TRIGGER IF EXISTS transaction_type_id_trigger ON transaction_type;


-- create table customer
create table customer (
	id uuid primary key,
	name varchar(100) not null,
	email varchar(100) not null,
	telephone varchar(20) not null,
	gender gender_type not null,
	mother_name varchar(100) not null,
	place_of_birth varchar(100) not null,
	date_of_birth date not null,
	created_at timestamp not null default current_timestamp,
	updated_at timestamp not null default current_timestamp,
	id_address varchar(10),
	id_job varchar(6)
);

ALTER TABLE customer
	rename column createdAt to created_at;

-- Table account
create table account(
	id uuid primary key,
	balance decimal(15,2) not null default 0,
	pin varchar(6) not null,
	open_date date not null,
	id_customer uuid,
	id_account_type varchar(6)
);

ALTER TABLE account
	rename column opendate to open_date;

alter table account 
	alter column open_date set not null;

alter table account 
	alter column open_date set default current_timestamp;


-- Table accountType
create table account_Type(
	id varchar(6) primary key,
	name varchar(50) not null	
);

-- Table transaction
create table transaction(
	id uuid primary key,
	date date not null,
	total decimal(15,2) not null,
	description text,
	id_account uuid,
	id_transaction_type varchar(6)
);
--
alter table transaction
	--memberi constraint pada total tidak boleh dibawah 0
	add constraint check_total check (total >= 0);


-- Table transactionType
create table transaction_type(
	id varchar(6) primary key,
	name varchar(50) not null
);

-- Table address
create table address(
	id varchar(10) primary key,
	street text not null,
    city varchar(50) not null,
    state varchar(50),
    postal_code varchar(5) not null,
    country varchar(50) not null,
    created_at timestamp not null default current_timestamp,
	updated_at timestamp not null default current_timestamp
);

-- Table job
create table job(
	id varchar(6) primary key,
	name varchar(20) not null
);

----------------------------------------------------- Membuat relasi antar table sesuai ERD
select * from customer;
select * from address;
select * from account;
select * from account_type;
select * from transaction_type;
select * from transaction;
select * from job;

-- table customer
alter table customer 
	add constraint fk_customer_address foreign key (id_address) references address (id);

alter table customer
	add constraint fk_customer_job foreign key (id_job) references job (id);


-- table account
alter table account
	add constraint fk_account_customer foreign key (id_customer) references customer (id);

alter table account
	add constraint fk_account_account_type foreign key (id_account_type) references account_type (id);

-- table transaction
alter table transaction
	add constraint fk_transaction_account foreign key (id_account) references account (id);

alter table transaction
	add constraint fk_transaction_transaction_type foreign key (id_transaction_type) references transaction_type (id);


--------------------------------------------------- Insert data ke table
insert into job (name)
	values 	('Freelancer'),
			('Programmer'),
			('Dokter'),
			('Guru'),
			('Pilot'),
			('Insinyur'),
			('Akuntan'),
			('Ilmuwan'),
			('Desainer Grafis'),
			('Pelatih Olahraga'),
			('Pengusaha'),
			('Karyawan Swasta'),
			('Pegawai Negeri'),
			('Pedagang');
		
	insert into job (name)
	values 	('Pelukis');
			
insert into account_type (name)
	values	('Rekening Tabungan'),
			('Rekening Giro'),
			('Deposito Berjangka'),
			('Rekening Bisnis'),
			('Rekening Investasi');
			
insert into transaction_type (name)
	values	('Debit'),
			('Kredit'),
			('Transfer'),
			('Pembayaran Tagihan'),
			('Setoran Otomatis'),
			('Penarikan Otomatis');

insert into address (street, city, state, postal_code, country)
	values	('Jl. Raya Kalibata No.1, RT.9/RW.4, Rawajati, Kec. Pancoran', 'Jakarta Selatan', 'DKI Jakarta ', '12750', 'Indonesia');

insert into customer (id, name, email, telephone, gender, mother_name, place_of_birth, date_of_birth)
	values	(gen_random_uuid(), 'Zaki', 'zaki@gmail.com', '0810-1010-1010','Laki-Laki' , 'ibu', 'Jakarta', '1998-07-07');

insert into account (id, balance, pin, id_customer, id_account_type)
	values	(gen_random_uuid(), 0, '123456', '6fc32d1b-0ae3-4736-a527-a7a47e944fc6', 'AT001');

-- =========================================================================================== UPDATE DATA
update address 
	set city = 'Kota Bekasi'
	where id = 'ADR001';

update customer 
	set id_job = 'JOB005'
	where id = 'f30ad71d-738c-4031-b69c-7d5734ab499b';


-- =========================================================================================== DELETE DATA
delete from address where id = 'AT006';

select * from customer;
select * from address;
select * from account;
select * from account_type;
select * from transaction_type;
select * from transaction;
select * from job;


-----====================================================================== JOIN
select c.id, a.id, c.name, a.city, j.name
	from customer as c
	join address as a on c.id_address = a.id
	join job as j on c.id_job = j.id;

select cust.id, cust.name, acc.balance, at2.id, at2.name
	from account as acc
	join customer as cust on acc.id_customer  = cust.id
	join account_type as at2 on acc.id_account_type = at2.id;

select *
	from account
	join account_type on account.id_account_type = account_type.id;

select *
	from account
	right join account_type on account.id_account_type = account_type.id;

select *
	from customer
	right join job on customer.id_job = job.id;

select *
	from customer
	inner join address on customer.id_address = address.id;