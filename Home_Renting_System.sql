
-- Creating a table owner
   ---------------------
create table owners
(
oid number,
address varchar(15),
oname varchar(15),
gender varchar(15),
primary key(oid)
);


-- inserting values into owner table
-- ---------------------------------

insert into owners values (106,'yadgir','shivu','male');
insert into owners values (107,'yadgir','keshav','male');
insert into owners values (109,'tumkur','bheema','male');
insert into owners values (123,'mangaluru','sheety','male');
insert into owners values (196,'mysore','veena','female');




-- creating houses table
--------------------

create table houses
(
hid number,
oid number,
rent_amount float,
onebhk number default null,
twobhk number default null,
threebhk number default null,
primary key(hid),
foreign key(oid) references owners(oid)
);



-- inserting values into houses table
-- ----------------------------------

-- 109 not inserted because oid with 109  is currently not owning any house



insert into houses values (401,106,15000,1,0,0);
insert into houses values (406,107,45000,0,1,0);                      
insert into houses values (421,123,53000,0,0,1);          
insert into houses values (431,106,25000,1,0,0);
insert into houses values (481,196,60000,0,0,1);



-- create table locations 
-- ----------------------


create table locations
(
hid number,
location varchar(15),
primary key(hid,location),
foreign key(hid) references houses(hid)
);



-- inserting values into locations table
-- -------------------------------------


insert into locations values (401,'bengaluru');
insert into locations values (481,'gulbarga');
insert into locations values (431,'kopal');
insert into locations values (406,'yadgir');
insert into locations values (421,'mangaluru');


-- creating customers table
-- ------------------------

create table customers 
(
cid number,
name varchar(15),
mobile_number number(10),
gender varchar(15),
dop date,
primary key(cid)
);



-- inserting values into customers table
-- -------------------------------------

insert into customers values(12,'sharath',9876543210,'male','31-aug-2001');
insert into customers values(22,'vishwa',9876543201,'male','09-dec-2000');
insert into customers values(32,'tejas',9876543120,'male','29-oct-2001');
insert into customers values(24,'preeti',9876542210,'female','07-jun-2001');
insert into customers values(16,'kavyashree',9967543210,'female','12-feb-2001');


-- creating buys table
-- -------------------

create table buys
(
cid number,
hid number,
primary key(cid,hid),
foreign key(cid) references customers(cid),
foreign key(hid) references houses(hid)
);

-- inserting data into buys table
-- ------------------------------

insert into buys values(12,406);
insert into buys values(22,481);
insert into buys values(24,421);
insert into buys values(16,431);



-- creating broker table
-- ---------------------

create table broker
(
bname varchar(15),
cid number,
blocation varchar(15),
bmobile_number number(10),
primary key(bname,cid),
foreign key(cid) references customers(cid)
);
 

-- inserting values into broker table
-- ----------------------------------

insert into broker values('danush',22,'mysore','8976543210');
insert into broker values('haveri',16,'hassan','9876543210');
insert into broker values('abhishek',12,'bidar','8967543210');
insert into broker values('akshay',32,'kopal','8976453210');







-- queries
-- -------



-- join operation,aggregate function 
-- _________________________________


-- 1)project name of the customer who is paying highest rent and also project the name of owner who owns the house along with the owner id.
-- -> 
   select c.name customer_name,h.rent_amount rent_amount,o.oid owner_id,o.oname owner_name
   from owners o,houses h,buys b,customers c
   where 
   o.oid=h.oid
   and 
   c.cid=b.cid 
   and
   h.hid=b.hid
   and
   h.rent_amount=
   (select max(rent_amount)
   from customers c,buys b,houses h
   where c.cid=b.cid and h.hid=b.hid) ;

-- group by,having and nested
-- __________________________


-- 2)project the names of owners who owns more than 1 house.
-- ->
   select oname
   from owners
   where
   oid in
   (select oid 
   from houses
   group by oid
   having count(oid)>=2);

    
-- creating view table
-- ___________________


-- 3)create view table of customers whose names do no start with vowels and each name should be distinct.
-- ->
  create view names
  as 
  select distinct name 
  from  customers
  where not (
         name like 'a%'
      or name like 'e%'
      or name like 'i%'
      or name like 'o%'
      or name like 'u%' );

  select * from names;



-- procedure 
-- _________


-- 4)create a procedure to display house details for specified house id.
-- ->
  create or replace procedure enter_house_id(id number)
  is 
  s houses%rowtype;
  cursor c is select * from houses where id=hid;
  begin
  dbms_output.put_line('HOUSE DETAILS ARE AS FOLLOWS');
  for s in c loop
  dbms_output.put_line('HID'||' '||'RENT_AMOUNT'||' '||'ONEBHK'||' '||'TWOBHK'||' '||'THREEBHK');
  dbms_output.put_line('---'||' '||'-----------'||' '||'------'||' '||'------'||' '||'--------');
  dbms_output.put_line(s.hid||' '||s.rent_amount||'        '||s.onebhk||'        '||s.twobhk||'        '||s.threebhk);
  end loop;
  end;
  /
  
 exec enter_house_id(401);





-- trigger
-- _______

-- 5)create a insertion trigger to check date of purchase must be less than current date.
-- ->
  create or replace trigger t
  before insert on customers
  for each row
  declare
  current date;
  begin
  select sysdate into current from dual;
  if(current<:NEW.dop) then
  raise_application_error(-20009,'INCORRECT DATE ENTERED !!!');
  end if;
  end;
  /
insert into customers values(105,'kiran',7876543210,'male','26-jan-2022');