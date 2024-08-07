USE [NAV-SQL-LIVE]
GO

/****** Object:  View [dbo].[All Event Elements]    Script Date: 22/05/2024 10:53:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







ALTER  VIEW [dbo].[All Event Elements] AS
SELECT 
ed.[Event No_] AS 'Event No', e.[Start Date], ed.[Bill-To Customer No_] AS 'BillTo Customer No', 
ed.[Contact_Customer No_] AS 'Contact No',
ed.[Document No_] AS 'Document No', ed.[Document Line No_] AS 'Document Line No',
(SELECT COUNT(*) FROM dbo.[Event Detailed Entry] d 
	WHERE d.[Event No_] = ed.[Event No_] AND ed.[Bill-To Customer No_] = d.[Bill-To Customer No_] AND 
			ed.[Contact_Customer No_] = d.[Contact_Customer No_] AND ed.[Document No_] = d.[Document No_] AND
			ed.[Document No_] = d.[Document No_]AND ed.[Document Line No_] = d.[Document Line No_] AND d.[Element Code] ='1')
AS '1',
(SELECT COUNT(*) FROM dbo.[Event Detailed Entry] d 
	WHERE d.[Event No_] = ed.[Event No_] AND ed.[Bill-To Customer No_] = d.[Bill-To Customer No_] AND 
			ed.[Contact_Customer No_] = d.[Contact_Customer No_] AND ed.[Document No_] = d.[Document No_] AND
			ed.[Document No_] = d.[Document No_]AND ed.[Document Line No_] = d.[Document Line No_] AND d.[Element Code] ='2')
AS '2',
(SELECT COUNT(*) FROM dbo.[Event Detailed Entry] d 
	WHERE d.[Event No_] = ed.[Event No_] AND ed.[Bill-To Customer No_] = d.[Bill-To Customer No_] AND 
			ed.[Contact_Customer No_] = d.[Contact_Customer No_] AND ed.[Document No_] = d.[Document No_] AND
			ed.[Document No_] = d.[Document No_]AND ed.[Document Line No_] = d.[Document Line No_] AND d.[Element Code] ='3')
AS '3',
(SELECT COUNT(*) FROM dbo.[Event Detailed Entry] d 
	WHERE d.[Event No_] = ed.[Event No_] AND ed.[Bill-To Customer No_] = d.[Bill-To Customer No_] AND 
			ed.[Contact_Customer No_] = d.[Contact_Customer No_] AND ed.[Document No_] = d.[Document No_] AND
			ed.[Document No_] = d.[Document No_]AND ed.[Document Line No_] = d.[Document Line No_] AND d.[Element Code] ='4')
AS '4',
(SELECT COUNT(*) FROM dbo.[Event Detailed Entry] d 
	WHERE d.[Event No_] = ed.[Event No_] AND ed.[Bill-To Customer No_] = d.[Bill-To Customer No_] AND 
			ed.[Contact_Customer No_] = d.[Contact_Customer No_] AND ed.[Document No_] = d.[Document No_] AND
			ed.[Document No_] = d.[Document No_]AND ed.[Document Line No_] = d.[Document Line No_] AND d.[Element Code] ='5')
AS '5',
(SELECT COUNT(*) FROM dbo.[Event Detailed Entry] d 
	WHERE d.[Event No_] = ed.[Event No_] AND ed.[Bill-To Customer No_] = d.[Bill-To Customer No_] AND 
			ed.[Contact_Customer No_] = d.[Contact_Customer No_] AND ed.[Document No_] = d.[Document No_] AND
			ed.[Document No_] = d.[Document No_]AND ed.[Document Line No_] = d.[Document Line No_] AND d.[Element Code] ='6')
AS '6',
(SELECT COUNT(*) FROM dbo.[Event Detailed Entry] d 
	WHERE d.[Event No_] = ed.[Event No_] AND ed.[Bill-To Customer No_] = d.[Bill-To Customer No_] AND 
			ed.[Contact_Customer No_] = d.[Contact_Customer No_] AND ed.[Document No_] = d.[Document No_] AND
			ed.[Document No_] = d.[Document No_]AND ed.[Document Line No_] = d.[Document Line No_] AND d.[Element Code] ='7')
AS '7',
(SELECT COUNT(*) FROM dbo.[Event Detailed Entry] d 
	WHERE d.[Event No_] = ed.[Event No_] AND ed.[Bill-To Customer No_] = d.[Bill-To Customer No_] AND 
			ed.[Contact_Customer No_] = d.[Contact_Customer No_] AND ed.[Document No_] = d.[Document No_] AND
			ed.[Document No_] = d.[Document No_]AND ed.[Document Line No_] = d.[Document Line No_] AND d.[Element Code] ='8')
AS '8',
(SELECT COUNT(*) FROM dbo.[Event Detailed Entry] d 
	WHERE d.[Event No_] = ed.[Event No_] AND ed.[Bill-To Customer No_] = d.[Bill-To Customer No_] AND 
			ed.[Contact_Customer No_] = d.[Contact_Customer No_] AND ed.[Document No_] = d.[Document No_] AND
			ed.[Document No_] = d.[Document No_]AND ed.[Document Line No_] = d.[Document Line No_] AND d.[Element Code] ='9')
AS '9',
(SELECT COUNT(*) FROM dbo.[Event Detailed Entry] d 
	WHERE d.[Event No_] = ed.[Event No_] AND ed.[Bill-To Customer No_] = d.[Bill-To Customer No_] AND 
			ed.[Contact_Customer No_] = d.[Contact_Customer No_] AND ed.[Document No_] = d.[Document No_] AND
			ed.[Document No_] = d.[Document No_]AND ed.[Document Line No_] = d.[Document Line No_] AND d.[Element Code] ='10')
AS '10',
COUNT(*) AS 'Total Elements',
 
(	SELECT TOP 1 a1.[Cnt] FROM (
	SELECT  DISTINCT A.* FROM (
	SELECT c.[No_],c.[Name],c.[E-Mail] AS 'Cnt' FROM dbo.[The Knowledge Academy Limited$Contact] c
	WHERE c.[Name] <> '' AND c.[E-Mail] <> ''
	UNION ALL
	SELECT c.[No_],c.[Name],c.[E-Mail] AS 'Cnt' FROM dbo.[Best Practice Training Ltd_$Contact] c
	WHERE c.[Name] <> '' AND c.[E-Mail] <> ''
	UNION ALL
	SELECT c.[No_],c.[Name],c.[E-Mail] AS 'Cnt' FROM dbo.[Datrix Learning Services Ltd_$Contact] c
	WHERE c.[Name] <> '' AND c.[E-Mail] <> ''
	UNION ALL
	SELECT  c.[No_],c.[Name],c.[E-Mail] AS 'Cnt' FROM dbo.[Pearce Mayfield Training Ltd$Contact] c
	WHERE c.[Name] <> '' AND c.[E-Mail] <> ''
	UNION ALL
	SELECT  c.[No_],c.[Name],c.[E-Mail] AS 'Cnt' FROM dbo.[Pentagon Leisure Services Ltd$Contact] c
	WHERE c.[Name] <> '' AND c.[E-Mail] <> ''
	UNION ALL
	SELECT  c.[No_],c.[Name],c.[E-Mail] AS 'Cnt' FROM dbo.[Silicon Beach Training$Contact] c
	WHERE c.[Name] <> '' AND c.[E-Mail] <> ''
	UNION ALL
	SELECT c.[No_],c.[Name],c.[E-Mail] AS 'Cnt' FROM dbo.[The Knowledge Academy Pty Ltd_$Contact] c
	WHERE c.[Name] <> '' AND c.[E-Mail] <> ''
	UNION ALL
	SELECT c.[No_],c.[Name],c.[E-Mail] AS 'Cnt' FROM dbo.[The Knowledge Academy SA$Contact] c
	WHERE c.[Name] <> '' AND c.[E-Mail] <> ''
	UNION ALL
	SELECT c.[No_],c.[Name],c.[E-Mail] AS 'Cnt' FROM dbo.[TKA Canada Corporation$Contact] c
	WHERE c.[Name] <> '' AND c.[E-Mail] <> ''
	UNION ALL
	SELECT c.[No_],c.[Name],c.[E-Mail] AS 'Cnt' FROM dbo.[TKA Hong Kong Ltd_$Contact] c
	WHERE c.[Name] <> '' AND c.[E-Mail] <> ''
	UNION ALL
	SELECT  c.[No_],c.[Name],c.[E-Mail] AS 'Cnt' FROM dbo.[TKA New Zealand Ltd_$Contact] c
	WHERE c.[Name] <> '' AND c.[E-Mail] <> ''
	UNION ALL
	SELECT  c.[No_],c.[Name],c.[E-Mail] AS 'Cnt' FROM dbo.[TKA Singapore PTE Ltd_$Contact] c
	WHERE c.[Name] <> '' AND c.[E-Mail] <> ''
	UNION ALL
	SELECT  c.[No_],c.[Name],c.[E-Mail] AS 'Cnt' FROM dbo.[TKA Europe$Contact] c
	WHERE c.[Name] <> '' AND c.[E-Mail] <> ''
	UNION ALL
	SELECT  c.[No_],c.[Name],c.[E-Mail] AS 'Cnt' FROM dbo.[The Knowledge Academy Inc$Contact] c
	WHERE c.[Name] <> '' AND c.[E-Mail] <> ''
	) A) a1 WHERE a1.No_ = ed.[Contact_Customer No_] ) AS 'E-Mail',

(	SELECT TOP 1 a1.[Name] FROM (
	SELECT  DISTINCT A.* FROM (
	SELECT c.[No_],c.[Name],c.[E-Mail] AS 'Cnt' FROM dbo.[The Knowledge Academy Limited$Contact] c
	WHERE c.[Name] <> '' 
	UNION ALL
	SELECT c.[No_],c.[Name],c.[E-Mail] AS 'Cnt' FROM dbo.[Best Practice Training Ltd_$Contact] c
	WHERE c.[Name] <> '' 
	UNION ALL
	SELECT c.[No_],c.[Name],c.[E-Mail] AS 'Cnt' FROM dbo.[Datrix Learning Services Ltd_$Contact] c
	WHERE c.[Name] <> '' 
	UNION ALL
	SELECT  c.[No_],c.[Name],c.[E-Mail] AS 'Cnt' FROM dbo.[Pearce Mayfield Training Ltd$Contact] c
	WHERE c.[Name] <> '' 
	UNION ALL
	SELECT  c.[No_],c.[Name],c.[E-Mail] AS 'Cnt' FROM dbo.[Pentagon Leisure Services Ltd$Contact] c
	WHERE c.[Name] <> '' 
	UNION ALL
	SELECT  c.[No_],c.[Name],c.[E-Mail] AS 'Cnt' FROM dbo.[Silicon Beach Training$Contact] c
	WHERE c.[Name] <> '' 
	UNION ALL
	SELECT c.[No_],c.[Name],c.[E-Mail] AS 'Cnt' FROM dbo.[The Knowledge Academy Pty Ltd_$Contact] c
	WHERE c.[Name] <> '' 
	UNION ALL
	SELECT c.[No_],c.[Name],c.[E-Mail] AS 'Cnt' FROM dbo.[The Knowledge Academy SA$Contact] c
	WHERE c.[Name] <> '' 
	UNION ALL
	SELECT c.[No_],c.[Name],c.[E-Mail] AS 'Cnt' FROM dbo.[TKA Canada Corporation$Contact] c
	WHERE c.[Name] <> '' 
	UNION ALL
	SELECT c.[No_],c.[Name],c.[E-Mail] AS 'Cnt' FROM dbo.[TKA Hong Kong Ltd_$Contact] c
	WHERE c.[Name] <> '' 
	UNION ALL
	SELECT  c.[No_],c.[Name],c.[E-Mail] AS 'Cnt' FROM dbo.[TKA New Zealand Ltd_$Contact] c
	WHERE c.[Name] <> '' 
	UNION ALL
	SELECT  c.[No_],c.[Name],c.[E-Mail] AS 'Cnt' FROM dbo.[TKA Singapore PTE Ltd_$Contact] c
	WHERE c.[Name] <> '' 
	UNION ALL
	SELECT  c.[No_],c.[Name],c.[E-Mail] AS 'Cnt' FROM dbo.[TKA Europe$Contact] c
	WHERE c.[Name] <> '' 
	UNION ALL
	SELECT  c.[No_],c.[Name],c.[E-Mail] AS 'Cnt' FROM dbo.[The Knowledge Academy Inc$Contact] c
	WHERE c.[Name] <> '' 
	) A) a1 WHERE a1.No_ = ed.[Contact_Customer No_] ) AS 'Name',
--ISNULL((SELECT a.[Exam Item No_] FROM (SELECT  d.[Event No_], d.[Contact_Customer No_], ce.[Exam Item No_] ,
--ROW_NUMBER() OVER(PARTITION BY d.[Event No_], d.[Contact_Customer No_]
--                      ORDER BY d.[Event No_] ) RowNumber
--FROM dbo.[Event Detailed Entry] d INNER JOIN dbo.[Course Elements] ce ON d.[Course Header] = ce.[Course Header]
--AND d.[Element Code] = ce.[Element Code] 
--WHERE ce.[Exam Item No_] <> '' AND d.[Event No_] = ed.[Event No_] AND d.[Contact_Customer No_] = ed.[Contact_Customer No_])a 
--WHERE  a.[RowNumber] = 1),'') 
'' AS 'Exam1',
--ISNULL((SELECT a.[Exam Item No_] FROM (SELECT  d.[Event No_], d.[Contact_Customer No_], ce.[Exam Item No_] ,
--ROW_NUMBER() OVER(PARTITION BY d.[Event No_], d.[Contact_Customer No_]
--                      ORDER BY d.[Event No_] ) RowNumber
--FROM dbo.[Event Detailed Entry] d INNER JOIN dbo.[Course Elements] ce ON d.[Course Header] = ce.[Course Header]
--AND d.[Element Code] = ce.[Element Code] 
--WHERE ce.[Exam Item No_] <> '' AND d.[Event No_] = ed.[Event No_] AND d.[Contact_Customer No_] = ed.[Contact_Customer No_])a 
--WHERE a.[RowNumber] = 2),'') AS 'Exam2'
'' AS 'Exam2'
FROM dbo.[Event Detailed Entry] ed

INNER JOIN dbo.[Event Header] e ON e.[No_] = ed.[Event No_]
WHERE 
ed.[Element Code] <> '' AND 
ed.[Status] <> 0

GROUP BY
ed.[Event No_], e.[Start Date], ed.[Bill-To Customer No_], ed.[Contact_Customer No_],
ed.[Document No_], ed.[Document Line No_]


GO


