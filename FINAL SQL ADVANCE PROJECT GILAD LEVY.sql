----------------------------------------------------------TARGIL 1 ----------------------------
SELECT 
    p.ProductID,
    p.Name,
    p.Color,
    p.ListPrice,
    p.Size
FROM 
    Production.Product p
LEFT JOIN 
    Sales.SalesOrderDetail sod ON p.ProductID = sod.ProductID
WHERE 
    sod.SalesOrderid IS NULL
ORDER BY 
    p.ProductID



------------------------------------------------------------TARGIL 2 -----------------------------------------

SELECT 
    c.CustomerID,
    p.LastName,
    p.FirstName
FROM 
    Sales.Customer c
LEFT JOIN 
    Person.Person p ON c.CustomerID = p.BusinessEntityID
LEFT JOIN 
    Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
WHERE 
    soh.SalesOrderID IS NULL 
ORDER BY 
    c.CustomerID




----------------------------------------------------TARGIL 3-------------------------------

SELECT 
    CustomerID,
    FirstName,
    LastName,
    CountOfOrders
FROM (
    SELECT 
        C.CustomerID,
        P.FirstName,
        P.LastName,
        COUNT(SOH.SalesOrderID) AS CountOfOrders,
        ROW_NUMBER() OVER (ORDER BY COUNT(SOH.SalesOrderID) DESC) AS RN
    FROM 
        SALES.Customer C
    INNER JOIN 
        Person.Person P ON P.BusinessEntityID = C.PersonID
    INNER JOIN 
        Sales.SalesOrderHeader SOH ON SOH.CustomerID = C.CustomerID
    GROUP BY 
        C.CustomerID, P.FirstName, P.LastName
) a
WHERE 
    RN <= 10


-----------------------------------------TARGIL 4-------------------------------------

SELECT 
    P.FirstName,
    P.LastName,
    HR.JobTitle,
    HR.HireDate,
    COUNT(JobTitle) OVER (PARTITION BY JobTitle) AS CountOfTitle
FROM 
    HumanResources.Employee HR
INNER JOIN 
    Person.Person P ON HR.BusinessEntityID = P.BusinessEntityID

-----------------------------------------TARGIL 5-----------------------------------------

WITH CTE AS (
    SELECT
		s.SalesOrderID,
        c.CustomerID,
		p.LastName,
        p.FirstName,
        s.OrderDate,
        LAG(s.OrderDate) OVER (PARTITION BY c.CustomerID ORDER BY s.OrderDate) AS PreviousOrder,
        ROW_NUMBER() OVER (PARTITION BY c.CustomerID ORDER BY s.OrderDate DESC) AS rn
    FROM 
        [Sales].[Customer] c 
    INNER JOIN 
        [Sales].[SalesOrderHeader] s ON c.CustomerID = s.CustomerID
    INNER JOIN  
        [Person].[Person] p ON c.PersonID = p.BusinessEntityID
)

SELECT 
    SalesOrderID,
    CustomerID,
    LastName,
    FirstName,
    OrderDate AS LastOrder,
    PreviousOrder
FROM 
    CTE
WHERE 
    rn = 1



-----------------------------TARGIL 6 -----------------------------

SELECT 
    Year,
    SalesOrderID,
    LastName,
    FirstName,
    CAST(TOTAL AS DECIMAL(10, 1)) AS Total
FROM (
    SELECT 
        YEAR(soh.OrderDate) AS Year,
        soh.SalesOrderID,
        p.LastName,
        p.FirstName,
        SUM(UnitPrice * (1 - UnitPriceDiscount) * OrderQty) AS total,
        ROW_NUMBER() OVER (PARTITION BY YEAR(soh.OrderDate) ORDER BY SUM(UnitPrice * (1 - UnitPriceDiscount) * OrderQty) DESC) AS RN
    FROM 
        Sales.SalesOrderDetail SOD
    INNER JOIN 
        Sales.SalesOrderHeader SOH ON SOD.SalesOrderID = SOH.SalesOrderID
    INNER JOIN 
        Sales.Customer C ON C.CustomerID = SOH.CustomerID
    INNER JOIN 
        Person.Person p ON p.BusinessEntityID = c.PersonID
    GROUP BY 
        YEAR(soh.OrderDate),
        soh.SalesOrderID,
        p.LastName,
        p.FirstName
) C
WHERE 
    RN = 1


---------------------------TARGIL 7------------------------------

WITH CTE AS (
    SELECT 
        MONTH(S.OrderDate) AS "Month",
        YEAR(S.OrderDate) AS "YEAR",
        S.SalesOrderID
    FROM 
        SALES.SalesOrderHeader S
)
SELECT 
    Month,
    [2011],
    [2012],
    [2013],
    [2014]
FROM 
    CTE
PIVOT (
    COUNT(SalesOrderID) 
    FOR YEAR IN ([2011], [2012], [2013], [2014])
) pvt
ORDER BY 
    Month

----------------------------------------------------TARGIL 8-----------------------------------------

WITH CTE AS (
    SELECT
        YEAR(orderdate) AS "Year",
        MONTH(orderdate) AS "Month",
        ROUND(SUM(unitprice), 2) AS Sum_Price,
        SUM(SUM(unitprice)) OVER (ORDER BY YEAR(orderdate), MONTH(orderdate) ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS CumSum
    FROM
        Sales.SalesOrderHeader soh
    INNER JOIN
        Sales.SalesOrderDetail sod ON sod.SalesOrderID = soh.SalesOrderID
    GROUP BY GROUPING SETS ((YEAR(orderdate), MONTH(orderdate)))
)

SELECT
    Year,
    CASE WHEN Month IS NULL THEN 'grand_total' ELSE CAST(Month AS VARCHAR(MAX)) END AS Month,
    Sum_Price,
    ROUND(MAX(CumSum), 2) AS CumSum
FROM CTE 
GROUP BY GROUPING SETS ((Year, Month, Sum_Price), Year)

----------------------------------------------------------------TARGIL 9------------------------------------------
SELECT
    DpartmentName,
    "Employee'sId",
    "Employee'sFullName",
    Hiredate,
    Seniority,
    PreviusEmpName,
    PreviusEmpDate,
    DATEDIFF(dd, PreviusEmpDate, hiredate) as DiffDays  
FROM (
    SELECT
        dh.EndDate,
        Name AS DpartmentName,
        P.BusinessEntityID as "Employee'sId",
        FirstName + ' ' + LastName as "Employee'sFullName",
        HireDate,
        datediff(mm, HireDate, getdate()) as Seniority,
        LEAD(FirstName + ' ' + LastName) OVER (PARTITION BY Name ORDER BY HIREDATE DESC) AS PreviusEmpName,
        LEAD(HIREDATE) OVER (PARTITION BY Name ORDER BY HIREDATE DESC) AS PreviusEmpDate
    FROM 
        HumanResources.Employee HR
    INNER JOIN 
        Person.Person P ON P.BusinessEntityID = HR.BusinessEntityID
    INNER JOIN 
        HumanResources.EmployeeDepartmentHistory DH ON DH.BusinessEntityID = HR.BusinessEntityID
    INNER JOIN 
        HumanResources.Department D ON D.DepartmentID = DH.DepartmentID
) a
WHERE 
    EndDate IS NULL






---------------------------------------------------------------TARGIL 10------------------------------------------


WITH CTE AS (
    SELECT
        EMP.HireDate,
        DH.DepartmentID,
        CAST(EMP.BusinessEntityID AS VARCHAR) + ' ' + P.LastName + ' ' + P.FirstName AS TeamEmployee,
        ROW_NUMBER() OVER (PARTITION BY EMP.BusinessEntityID ORDER BY dh.startdate DESC) AS RN
    FROM 
        HumanResources.Employee EMP
    INNER JOIN 
        HumanResources.EmployeeDepartmentHistory DH ON EMP.BusinessEntityID = DH.BusinessEntityID
    INNER JOIN 
        Person.Person P ON P.BusinessEntityID = EMP.BusinessEntityID
)
SELECT
    HireDate,
    DepartmentID,
    STRING_AGG(TeamEmployee, ', ') AS TeamEmployees
FROM 
    CTE
WHERE 
    RN = 1
GROUP BY 
    HireDate, DepartmentID
ORDER BY 
    HireDate DESC