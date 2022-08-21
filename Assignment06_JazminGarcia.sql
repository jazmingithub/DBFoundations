--*************************************************************************--
-- Title: Assignment06
-- Author: YourNameHere
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2022-08-20,Jazmin Garcia,Created File
-- 2022-08-20 NOTE: I did not include the order by clasue in the view
-- instead I created then ordered the view 
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_JazminGarcia')
	 Begin 
	  Alter Database [Assignment06DB_JazminGarcia] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_JazminGarcia;
	 End
	Create Database Assignment06DB_JazminGarcia;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_JazminGarcia;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
--print 
--go
--'NOTES------------------------------------------------------------------------------------ 
 --1) You can use any name you like for you views, but be descriptive and consistent
-- 2) You can use your working code from assignment 5 for much of this assignment
 --3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

CREATE OR ALTER VIEW vCategories
WITH SCHEMABINDING
AS 
SELECT
	C.CategoryID, 
	C.CategoryName
FROM dbo.Categories AS C;
go
SELECT * FROM vCategories; 
go

CREATE OR ALTER VIEW vProducts
WITH SCHEMABINDING
AS 
SELECT 
	P.ProductID, 
	P.ProductName,
	P.CategoryID, 
	P.UnitPrice
FROM dbo.Products AS P;
go
SELECT * FROM vProducts
go
CREATE OR ALTER VIEW vEmployees
WITH SCHEMABINDING
AS 
SELECT
	 E.EmployeeID, 
	 E.EmployeeFirstName, 
	 E.EmployeeLastName, 
	 E.ManagerID 
FROM dbo.Employees AS E;
go
SELECT * FROM vEmployees; 
go 

CREATE OR ALTER VIEW vInventories
WITH SCHEMABINDING
AS 
SELECT
	I.InventoryID,
	I.InventoryDate,
	I.EmployeeID, 
	I.ProductID,
	I.Count
From dbo.Inventories AS I; 
go
Select * From vInventories;
go

-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?
Use Assignment06DB_JazminGarcia 

Deny select On Categories to Public; 
Grant select On vCategories to Public; 

Deny select On Products to Public; 
Grant select On vProducts to Public;

Deny select On Employees to Public; 
Grant select On vEmployees to Public;

Deny select On Inventories to Public; 
Grant select On vInventories to Public;
go

-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!
SELECT * FROM vCategories;
go 
SELECT * FROM vProducts; 
go

CREATE OR ALTER 
--DROP
VIEW vProductsByCategories
AS 
SELECT 
	vC.CategoryName, 
	vP.ProductName, 
	vP.UnitPrice
FROM vCategories as vC
JOIN vProducts as vP
	ON vC.CategoryID = vP.CategoryID
go 
SELECT * FROM vProductsByCategories
go 
-- I didnt want to use a TOP clause so I ordered the view instead 
SELECT * FROM vProductsByCategories
ORDER BY CategoryName, ProductName;
go 

-- Here is an example of some rows selected from the view:
-- CategoryName ProductName       UnitPrice
-- Beverages    Chai              18.00
-- Beverages    Chang             19.00
-- Beverages    Chartreuse verte  18.00


-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!
SELECT * FROM vProducts;
go 
SELECT * FROM vInventories; 
go

CREATE OR ALTER 
--DROP
VIEW vInventoriesByProductsByDates
AS 
SELECT 
	vP.ProductName, 
	vI.InventoryDate, 
	SUM(COUNT) AS TotalCount
FROM vProducts as vP 
JOIN vInventories AS vI 
	ON vP.ProductID = vI.ProductID
--WHERE ProductName = 'Alice Mutton'
GROUP BY vP.ProductName, vI.InventoryDate, vI.Count
go 
SELECT * FROM vInventoriesByProductsByDates
go

-- Here is an example of some rows selected from the view:
-- ProductName	  InventoryDate	Count
-- Alice Mutton	  2017-01-01	  0
-- Alice Mutton	  2017-02-01	  10
-- Alice Mutton	  2017-03-01	  20
-- Aniseed Syrup	2017-01-01	  13
-- Aniseed Syrup	2017-02-01	  23
-- Aniseed Syrup	2017-03-01	  33


-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!
SELECT * FROM vInventories;
go 
SELECT * FROM vEmployees; 
go

CREATE OR ALTER 
--DROP
VIEW vInventoriesByEmployeesByDates
AS 
SELECT DISTINCT
	vI.InventoryDate,
	CONCAT(vE.EmployeeFirstName, ' ', vE.EmployeeLastName) AS EmployeeName
FROM vInventories AS vI
JOIN vEmployees AS vE
	ON vI.EmployeeID = vE.EmployeeID; 
go 
SELECT * FROM vInventoriesByEmployeesByDates
ORDER BY InventoryDate
go
-- Here is are the rows selected from the view:
-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!
SELECT * FROM vCategories;
go 
SELECT * FROM vProducts; 
go 
SELECT * FROM vInventories; 
go

-- using joiins
CREATE OR ALTER 
--DROP
VIEW vInventoriesByProductsByCategories
AS 
SELECT 
	vC.CategoryName, 
	vP.ProductName, 
	vI.InventoryDate,
	vI.Count
FROM vCategories as vC
JOIN vProducts as vP
	ON vC.CategoryID = vP.CategoryID
JOIN vInventories as vI 
	ON vP.ProductID = vI.ProductID
-- WHERE vP.ProductName = 'Chai'; 
go
SELECT * FROM vInventoriesByProductsByCategories
ORDER BY CategoryName, ProductName, InventoryDate, Count; 
go 



-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count
-- CategoryName	ProductName	InventoryDate	Count
-- Beverages	  Chai	      2017-01-01	  39
-- Beverages	  Chai	      2017-02-01	  49
-- Beverages	  Chai	      2017-03-01	  59
-- Beverages	  Chang	      2017-01-01	  17
-- Beverages	  Chang	      2017-02-01	  27
-- Beverages	  Chang	      2017-03-01	  37


-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!
SELECT * FROM vCategories;
go
SELECT * FROM vProducts;
go 
SELECT * FROM vInventories; 
go 
SELECT * FROM vEmployees
go

CREATE OR ALTER 
--DROP
VIEW vInventoriesByProductsByEmployees
AS 
SELECT 
	vC.CategoryName, 
	vP.ProductName, 
	vI.InventoryDate,
	vI.Count,
	CONCAT(vE.EmployeeFirstName, ' ', vE.EmployeeLastName) AS EmployeeName
FROM vCategories AS vC
JOIN vProducts as vP
	ON vC.CategoryID = vP.CategoryID
JOIN vInventories as vI 
	ON vP.ProductID = vI.ProductID
JOIN vEmployees AS vE
	ON vE.EmployeeID = vI.EmployeeID
-- WHERE vP.ProductName = 'Chai'; 
go 
SELECT * FROM vInventoriesByProductsByEmployees
ORDER BY InventoryDate, CategoryName, ProductName, EmployeeName
go

-- Here is an example of some rows selected from the view:
-- CategoryName	ProductName	        InventoryDate	Count	EmployeeName
-- Beverages	  Chai	              2017-01-01	  39	  Steven Buchanan
-- Beverages	  Chang	              2017-01-01	  17	  Steven Buchanan
-- Beverages	  Chartreuse verte	  2017-01-01	  69	  Steven Buchanan
-- Beverages	  Côte de Blaye	      2017-01-01	  17	  Steven Buchanan
-- Beverages	  Guaraná Fantástica	2017-01-01	  20	  Steven Buchanan
-- Beverages	  Ipoh Coffee	        2017-01-01	  17	  Steven Buchanan
-- Beverages	  Lakkalikööri	      2017-01-01	  57	  Steven Buchanan

-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 
SELECT * FROM vCategories;
go 
SELECT * FROM vProducts;
go 
SELECT * FROM vInventories;
go 
SELECT * FROM vEmployees; 
go 


CREATE OR ALTER 
--DROP
VIEW vInventoriesForChaiAndChangByEmployees
AS 
SELECT 
	vC.CategoryName, 
	vP.ProductName, 
	vI.InventoryDate,
	SUM(vI.Count) AS TotalCount,
	CONCAT(vE.EmployeeFirstName, ' ', vE.EmployeeLastName) AS EmployeeName
FROM vCategories AS vC
JOIN vProducts as vP
	ON vC.CategoryID = vP.CategoryID
JOIN vInventories as vI 
	ON vP.ProductID = vI.ProductID
JOIN vEmployees AS vE
	ON vE.EmployeeID = vI.EmployeeID
WHERE vP.ProductName = 'Chai' 
		OR vP.ProductName = 'Chang'
GROUP BY CategoryName, ProductName, InventoryDate, Count, EmployeeLastName, EmployeeFirstName
go 
SELECT * FROM vInventoriesForChaiAndChangByEmployees
ORDER BY EmployeeName DESC, TotalCount DESC
go




-- Here are the rows selected from the view:
-- CategoryName	ProductName	InventoryDate	Count	EmployeeName
-- Beverages	  Chai	      2017-01-01	  39	  Steven Buchanan
-- Beverages	  Chang	      2017-01-01	  17	  Steven Buchanan
-- Beverages	  Chai	      2017-02-01	  49	  Robert King
-- Beverages	  Chang	      2017-02-01	  27	  Robert King
-- Beverages	  Chai	      2017-03-01	  59	  Anne Dodsworth
-- Beverages	  Chang	      2017-03-01	  37	  Anne Dodsworth


-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!
SELECT * FROM vEmployees; 
go 

CREATE OR ALTER 
--DROP
VIEW vEmployeesByManager
AS
SELECT 
	--M.ManagerID,
	CONCAT(M.EmployeeFirstName, ' ', M.EmployeeLastName) AS ManagerName,
	--E.EmployeeID,
	CONCAT(E.EmployeeFirstName, ' ', E.EmployeeLastName) AS EmployeeName
FROM vEmployees as M
JOIN vEmployees as E 
	ON M.EmployeeID = E.ManagerID
go 
SELECT * FROM vEmployeesByManager
ORDER BY ManagerName ASC, EmployeeName ASC
go 


CREATE OR ALTER 
--DROP
VIEW vEmployeesByManagerWithID
AS
SELECT 
	M.ManagerID,
	CONCAT(M.EmployeeFirstName, ' ', M.EmployeeLastName) AS ManagerName,
	E.EmployeeID,
	CONCAT(E.EmployeeFirstName, ' ', E.EmployeeLastName) AS EmployeeName
FROM vEmployees AS M
JOIN vEmployees AS E 
	ON M.EmployeeID = E.ManagerID
go 
SELECT * FROM vEmployeesByManager
ORDER BY ManagerName ASC, EmployeeName ASC
go 
SELECT * FROM vEmployeesByManagerWithID; 
go


-- Here are teh rows selected from the view:
-- Manager	        Employee
-- Andrew Fuller	  Andrew Fuller
-- Andrew Fuller	  Janet Leverling
-- Andrew Fuller	  Laura Callahan
-- Andrew Fuller	  Margaret Peacock
-- Andrew Fuller	  Nancy Davolio
-- Andrew Fuller	  Steven Buchanan
-- Steven Buchanan	Anne Dodsworth
-- Steven Buchanan	Michael Suyama
-- Steven Buchanan	Robert King


-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

SELECT * FROM vEmployeesByManagerWithID;
go 


CREATE OR ALTER 
--DROP
VIEW vInventoriesByProductsByCategoriesByEmployees
AS
SELECT 
	vC.CategoryID,
	vC.CategoryName,
	vP.ProductID,
	vP.ProductName, 
	vP.UnitPrice, 
	vI.InventoryID, 
	vI.InventoryDate, 
	vI.Count, 
	vE.EmployeeID, 
	CONCAT(vE.EmployeeFirstName, ' ', vE.EmployeeLastName) AS EmployeeName,
	M.ManagerName
FROM vCategories AS vC
JOIN vProducts as vP
	ON vC.CategoryID = vP.CategoryID
JOIN vInventories AS vI 
	ON vP.ProductID = vI.ProductID
JOIN vEmployees AS vE
	ON vE.EmployeeID = vI.EmployeeID
-- WHERE vC.CategoryID = 1 
JOIN vEmployeesByManagerWithID AS M
	ON M.EmployeeID = vE.EmployeeID
-- WHERE vE.EmployeeLastName = 'Dodsworth'
go 
SELECT * FROM vInventoriesByProductsByCategoriesByEmployees
ORDER BY CategoryID, ProductID, ProductName, UnitPrice, InventoryID, InventoryDate, Count
go 

-- Here is an example of some rows selected from the view:
-- CategoryID	  CategoryName	ProductID	ProductName	        UnitPrice	InventoryID	InventoryDate	Count	EmployeeID	Employee
-- 1	          Beverages	    1	        Chai	              18.00	    1	          2017-01-01	  39	  5	          Steven Buchanan
-- 1	          Beverages	    1	        Chai	              18.00	    78	        2017-02-01	  49	  7	          Robert King
-- 1	          Beverages	    1	        Chai	              18.00	    155	        2017-03-01	  59	  9	          Anne Dodsworth
-- 1	          Beverages	    2	        Chang	              19.00	    2	          2017-01-01	  17	  5	          Steven Buchanan
-- 1	          Beverages	    2	        Chang	              19.00	    79	        2017-02-01	  27	  7	          Robert King
-- 1	          Beverages	    2	        Chang	              19.00	    156	        2017-03-01	  37	  9	          Anne Dodsworth
-- 1	          Beverages	    24	      Guaraná Fantástica	4.50	    24	        2017-01-01	  20	  5	          Steven Buchanan
-- 1	          Beverages	    24	      Guaraná Fantástica	4.50	    101	        2017-02-01	  30	  7	          Robert King
-- 1	          Beverages	    24	      Guaraná Fantástica	4.50	    178	        2017-03-01	  40	  9	          Anne Dodsworth
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    34	        2017-01-01	  111	  5	          Steven Buchanan
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    111	        2017-02-01	  121	  7	          Robert King
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    188	        2017-03-01	  131	  9	          Anne Dodsworth


-- Test your Views (NOTE: You must change the names to match yours as needed!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/