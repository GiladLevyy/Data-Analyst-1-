select cast(avg(p.UnitPrice) as int)
from Products p


select *
from Products p1
inner join Products p2
on p1.UnitPrice>p2.UnitPrice
and 

selec

select *
from Employees e
where e.HireDate>(select e.HireDate 
from Employees e
where e.EmployeeID=5)


תרגיל 2

select p.ProductName,p.UnitPrice
from Products p
where p.UnitPrice>(select p.UnitPrice 
from Products p
where p.ProductName='tofu')


תרגיל 4

select p.ProductID,p.ProductName,p.UnitPrice
from Products p
where p.UnitPrice>(select avg(p.UnitPrice) 
from Products p)

select *
from Products p 
where p.UnitPrice>(select p.UnitPrice from Products where ProductID in (1,3,7,20))



select o.EmployeeID,o.OrderID,o.OrderDate
from Orders o
where exists(select *
from Employees e 
where o.EmployeeID=e.EmployeeID
and e.EmployeeID in (2,5))


select o.EmployeeID,count(o.OrderID),max(o.OrderDate)
from Orders o
where exists(select *
from Employees e 
where o.EmployeeID=e.EmployeeID
and e.EmployeeID in (2,5))
group by o.EmployeeID

select e.ReportsTo
from Employees e
where 

תרגיל 8

select p.ProductName,p.UnitPrice
from Products p
where p.UnitPrice> any( select p.UnitPrice
from Products p 
where CategoryID=5)

תרגיל 9

select p.ProductName,p.UnitPrice
from Products p
where p.UnitPrice> all( select p.UnitPrice
from Products p 
where CategoryID=5)


select p.ProductID,p.ProductName,p.UnitPrice,cast(p.UnitPrice*1.17 as money) as tax_price 
from Products p


תרגיל כיתה 

select *
from Customers c 
where c.CustomerID in (select distinct CustomerID from orders )
 תרגיל 2


select *
from Customers c 
where not exists (select distinct c.CustomerID from orders o  where c.customerid=o.customerid)


תרגיל 3

select *
from Employees e
where e.EmployeeID in (select distinct ReportsTo from Employees)


תרגיל 4

select Employees e
where not exists(select distinct reportsto from Employees e1 where e.employeeid=e1.reportsto)




select *
from Customers c  inner join Orders o
on c.CustomerID=o.CustomerID
where exists (select o.OrderID
from Orders o)




