USE [Red30Tech]
GO

-- SUBQUERY 
SELECT [ProdCategory]
      ,[ProdNumber]
      ,[ProdName]
	  ,[In Stock]
  FROM [dbo].[Inventory$]
  WHERE [In Stock]<(
					SELECT 
					AVG([In Stock])
					FROM [dbo].[Inventory$])
-- CTE QUERY
WITH LOWSTOCK (STOCK) AS (
					SELECT 
					AVG([In Stock]) AS STOCK
					FROM [dbo].[Inventory$]
					)
SELECT [ProdCategory]
      ,[ProdNumber]
      ,[ProdName]
	  ,[In Stock]
  FROM [dbo].[Inventory$],LOWSTOCK
  WHERE [In Stock]<STOCK

-- CTE RECURSIVE

WITH DIRECTREPORT AS (
SELECT [First Name]
      ,[Last Name]
      ,[EmployeeID]
      ,[Manager]
  FROM [dbo].[EmployeeDirectory$]
  WHERE [EmployeeID] = 42
  UNION ALL
  SELECT E.[First Name]
      ,E.[Last Name]
      ,E.[EmployeeID]
      ,E.[Manager]
  FROM [dbo].[EmployeeDirectory$] AS E
  INNER JOIN  DIRECTREPORT AS D ON E.Manager = D.EmployeeID
  )

  SELECT COUNT(*) AS DIRECT_REPORTS
  FROM DIRECTREPORT AS D
  WHERE D.[EmployeeID] != 42

-- WINDOW FUNCTIONS ROW_NUMBER

WITH TOP3ORDERBOEHM AS (
SELECT [OrderNum]
      ,[OrderDate]
      ,[CustName]
      ,[ProdCategory]
      ,[ProdName]
      ,[Order Total],
	  ROW_NUMBER () OVER(PARTITION BY [ProdCategory] ORDER BY [Order Total] DESC) AS ROW_NUM
	  FROM [dbo].[OnlineRetailSales$]
	  WHERE CustName = 'Boehm Inc.'
	  )
SELECT * FROM TOP3ORDERBOEHM WHERE ROW_NUM <= 3

-- LAG OR LEAD WINDOW FUNCTION

WITH ORDERBYDATES AS (
SELECT SUM([Quantity]) AS Quantity
      ,[OrderDate]
	FROM [dbo].[OnlineRetailSales$]
	  WHERE [ProdCategory] = 'Drones'
	  GROUP BY [OrderDate])
SELECT *,
LAG([Quantity],1) OVER(ORDER BY [Orderdate] ASC ) as LASTDATEQUANTITY_1
,LAG([Quantity],2) OVER(ORDER BY [Orderdate] ASC ) as LASTDATEQUANTITY_2 
,LAG([Quantity],3) OVER(ORDER BY [Orderdate] ASC ) as LASTDATEQUANTITY_3 
,LAG([Quantity],4) OVER(ORDER BY [Orderdate] ASC ) as LASTDATEQUANTITY_4 
,LAG([Quantity],5) OVER(ORDER BY [Orderdate] ASC ) as LASTDATEQUANTITY_5 
FROM ORDERBYDATES 

-- RANK AND RANK_DENSE
WITH RANKS AS (
SELECT *,
DENSE_RANK() OVER ( PARTITION BY [State] ORDER BY [Registration Date]) as denserank
FROM [dbo].ConventionAttendees$)
SELECT * FROM RANKS WHERE denserank <=3

WITH RANKS2 AS (
SELECT *,
RANK() OVER ( PARTITION BY [State] ORDER BY [Registration Date]) as denserank
FROM [dbo].ConventionAttendees$)
SELECT * FROM RANKS2 WHERE denserank <=3



