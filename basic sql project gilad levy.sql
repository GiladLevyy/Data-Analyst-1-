use master 
GO

if exists (select* from sysdatabases where name='factory')
DROP DATABASE factory
GO

CREATE DATABASE factory
GO

USE factory
GO 

create table store(
store_id int,
store_Name varchar(60),
Sales_PersonID int null,
ModifiedDate datetime not null,
constraint st_stid_pk primary key(store_id),
constraint st_moddate_ck check (ModifiedDate>year(2013)))
go


insert into store
select BusinessEntityID,Name,SalesPersonID,ModifiedDate
from [AdventureWorks2019].[sales].[store]
go

create table person(
business_id int,
first_name varchar (40) not null,
last_name varchar (40) not null, 
constraint per_busid_pk primary key (business_id)
)
go

insert into person
select BusinessEntityID,FirstName,LastName
from [AdventureWorks2019].[person].[person]
go

ALTER TABLE person 
ADD MAIL VARCHAR (50) 
GO

UPDATE person
SET MAIL=first_name+'@gmail.com'
go

create table Territory(
Territory_ID int,
territory_name varchar (20) not null ,
country_region_code nvarchar(3) not null,
Sales_Last_Year money NOT NULL,
constraint ter_terid_pk primary key(Territory_ID))
go

insert into Territory
select TerritoryID,Name,CountryRegionCode,SalesLastYear
from [AdventureWorks2019].[sales].[SalesTerritory]
go

create table orderheader(
order_header_id int identity (1,1) NOT NULL,
orderdate datetime,
subtotal money,
customer_id int  ,
Territory_ID int , 
constraint orh_orhid_pk primary key (order_header_id),
constraint orh_terid_fk foreign key (Territory_ID) references Territory(Territory_ID),
constraint orh_subt_ch check (subtotal>1)

)
go
  
create table customer(
customer_id int identity (1,1) NOT NULL,
person_id int null,
store_id int null,
TerritoryID int null,
AccountNumber varchar(10) null,
ModifiedDate datetime not null,
constraint cu_cuid_pk primary key (customer_id),
constraint cu_stid_fk  foreign key(store_id) references store(store_id),
constraint cus_perid_fk foreign key (person_id) references person(business_id),
constraint cus_terid_fk foreign key (TerritoryID) references Territory(Territory_ID))

go

ALTER TABLE orderheader
ADD CONSTRAINT orh_cusid_fk FOREIGN KEY (customer_id) REFERENCES customer(customer_id)


go

insert into customer ([person_id]
           ,[store_id]
           ,[TerritoryID]
           ,[AccountNumber]
           ,[ModifiedDate])
	 
select PersonID,StoreID,TerritoryID,AccountNumber,ModifiedDate
from [AdventureWorks2019].[sales].[customer]

go

SET IDENTITY_INSERT orderheader ON 
insert into orderheader(order_header_id,orderdate,subtotal,customer_id,Territory_ID)
select SalesOrderID,OrderDate,SubTotal,CustomerID,so.TerritoryID
from [AdventureWorks2019].[sales].[SalesOrderHeader] so
inner join customer c
on so.CustomerID=c.customer_id
SET IDENTITY_INSERT orderheader off 

go






