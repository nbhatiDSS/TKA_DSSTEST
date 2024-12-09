USE [NAV-SQL-LIVE]
GO

/****** Object:  View [dbo].[All Company Revenue]    Script Date: 09/12/2024 10:32:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





ALTER VIEW [dbo].[All Company Revenue] AS
SELECT 'The Knowledge Academy Limited' as [CName],
           'Invoice' as [DocumentType],
           c1.[Document No_] as [DocNo],
		   h.[Document Date],
		   h.[Order No_] as [Sales Order No],
		   c1.[Sell-to Customer No_],c1.[Contact No_],h.[Salesperson Code],cn.[Country_Region Code],
           c1.[Line No_] as [LineNo],
		   c1.[Amt_ Excl_ VAT (LCY)] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Revenue' as [BucketType],
		   c1.[Amt_ Excl_ VAT (LCY)] / ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[The Knowledge Academy Limited$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[The Knowledge Academy Limited$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country],
			ISNULL((SELECT cr.[Name] FROM dbo.[The Knowledge Academy Limited$Country_Region] cr WHERE cr.[Code] IN 
			(SELECT CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[The Knowledge Academy Limited$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country])),'') AS 'Country Name',
			
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],

			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			ISNULL(CASE
				WHEN h.[Payment Information] <> 6 THEN (
					CASE
						WHEN c1.[No_] IN ('5345', '5343') THEN 'Original KP'
						WHEN c1.[No_] IN ('5344') THEN 'Original FP'
						ELSE
							CASE
								WHEN c1.[KP No_] <> '' THEN 
									(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
												WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
											END
									FROM dbo.[The Knowledge Academy Limited$Sales Invoice Header] SH
									WHERE SH.[No_] = c1.[KP No_])
					
								ELSE  
									(SELECT CASE WHEN (c1.[Event Header] <> '' AND SH.[Knowledge Pass] = 1) THEN 'KPUSED'
												WHEN (c1.[Event Header] <> '' AND SH.[Flexi Pass] = 1) THEN 'FPUSED'
												ELSE 'STANDARD'
											END
									FROM dbo.[The Knowledge Academy Limited$Sales Invoice Header] SH
									WHERE SH.[No_] = c1.[Document No_])
								END
							END)
				ELSE
					CASE
						WHEN c1.[KP No_] <> '' THEN 
							(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
									END
							FROM dbo.[The Knowledge Academy Limited$Sales Invoice Header] SH
							WHERE SH.[No_] = c1.[KP No_])
					
						ELSE  
							(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
										ELSE 'STANDARD'
									END
							FROM dbo.[The Knowledge Academy Limited$Sales Invoice Header] SH
							WHERE SH.[No_] = c1.[Document No_])
						END
				END,'') AS 'OrderType',ct.[MISName], DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'

FROM dbo.[The Knowledge Academy Limited$Sales Invoice Line] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
INNER JOIN dbo.[The Knowledge Academy Limited$Sales Invoice Header] h ON h.[No_] = c1.[Document No_]
LEFT OUTER JOIN dbo.[The Knowledge Academy Limited$Contact] cn on cn.[No_] = c1.[Contact No_]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]
LEFT OUTER JOIN dbo.[The Knowledge Academy Limited$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[The Knowledge Academy Limited$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >=  '2018/01/01'
AND c1.[Quantity] <>0 AND c1.[Type] = 1 AND c1.[No_] LIKE '6%'

UNION ALL
SELECT 'The Knowledge Academy Inc' as [CName],
           'Invoice' as [DocumentType],
           c1.[Document No_] as [DocNo],
		   		  h.[Document Date],
				  h.[Order No_] as [Sales Order No],

		   c1.[Sell-to Customer No_],c1.[Contact No_],h.[Salesperson Code],cn.[Country_Region Code],
           c1.[Line No_] as [LineNo],
		   c1.[Amt_ Excl_ VAT (LCY)] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Revenue' as [BucketType],
		   c1.[Amt_ Excl_ VAT (LCY)] / ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[The Knowledge Academy Inc$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[The Knowledge Academy Inc$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country],
			ISNULL((SELECT cr.[Name] FROM dbo.[The Knowledge Academy Inc$Country_Region] cr WHERE cr.[Code] IN 
			(SELECT CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[The Knowledge Academy Inc$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			ISNULL(CASE
				WHEN h.[Payment Information] <> 6 THEN (
					CASE
						WHEN c1.[No_] IN ('5345', '5343') THEN 'Original KP'
						WHEN c1.[No_] IN ('5344') THEN 'Original FP'
						ELSE
							CASE
								WHEN c1.[KP No_] <> '' THEN 
									(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
												WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
											END
									FROM dbo.[The Knowledge Academy Inc$Sales Invoice Header] SH
									WHERE SH.[No_] = c1.[KP No_])
					
								ELSE  
									(SELECT CASE WHEN (c1.[Event Header] <> '' AND SH.[Knowledge Pass] = 1) THEN 'KPUSED'
												WHEN (c1.[Event Header] <> '' AND SH.[Flexi Pass] = 1) THEN 'FPUSED'
												ELSE 'STANDARD'
											END
									FROM dbo.[The Knowledge Academy Inc$Sales Invoice Header] SH
									WHERE SH.[No_] = c1.[Document No_])
								END
							END)
				ELSE
					CASE
						WHEN c1.[KP No_] <> '' THEN 
							(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
									END
							FROM dbo.[The Knowledge Academy Inc$Sales Invoice Header] SH
							WHERE SH.[No_] = c1.[KP No_])
					
						ELSE  
							(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
										ELSE 'STANDARD'
									END
							FROM dbo.[The Knowledge Academy Inc$Sales Invoice Header] SH
							WHERE SH.[No_] = c1.[Document No_])
						END
				END,'') AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[The Knowledge Academy Inc$Sales Invoice Line] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]
INNER JOIN dbo.[The Knowledge Academy Inc$Sales Invoice Header] h ON h.[No_] = c1.[Document No_]
LEFT OUTER JOIN dbo.[The Knowledge Academy Inc$Contact] cn on cn.[No_] = c1.[Contact No_]
LEFT OUTER JOIN dbo.[The Knowledge Academy Inc$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[The Knowledge Academy Inc$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >= '2018/01/01'
AND c1.[Quantity] <>0 AND c1.[Type] = 1 AND c1.[No_] LIKE '6%'
UNION ALL
SELECT 'Best Practice Training Ltd.' as [CName],
           'Invoice' as [DocumentType],
           c1.[Document No_] as [DocNo],
		  h.[Document Date],
		  h.[Order No_] as [Sales Order No],
		   c1.[Sell-to Customer No_],c1.[Contact No_],h.[Salesperson Code],cn.[Country_Region Code],
           c1.[Line No_] as [LineNo],
		   c1.[Amt_ Excl_ VAT (LCY)] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Revenue' as [BucketType],
		   c1.[Amt_ Excl_ VAT (LCY)] / ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[Best Practice Training Ltd_$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[Best Practice Training Ltd_$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country],
						ISNULL((SELECT cr.[Name] FROM dbo.[Best Practice Training Ltd_$Country_Region] cr WHERE cr.[Code] IN 
			(SELECT CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[Best Practice Training Ltd_$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			ISNULL(CASE
				WHEN h.[Payment Information] <> 6 THEN (
					CASE
						WHEN c1.[No_] IN ('5345', '5343') THEN 'Original KP'
						WHEN c1.[No_] IN ('5344') THEN 'Original FP'
						ELSE
							CASE
								WHEN c1.[KP No_] <> '' THEN 
									(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
												WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
											END
									FROM dbo.[Best Practice Training Ltd_$Sales Invoice Header] SH
									WHERE SH.[No_] = c1.[KP No_])
					
								ELSE  
									(SELECT CASE WHEN (c1.[Event Header] <> '' AND SH.[Knowledge Pass] = 1) THEN 'KPUSED'
												WHEN (c1.[Event Header] <> '' AND SH.[Flexi Pass] = 1) THEN 'FPUSED'
												ELSE 'STANDARD'
											END
									FROM dbo.[Best Practice Training Ltd_$Sales Invoice Header] SH
									WHERE SH.[No_] = c1.[Document No_])
								END
							END)
				ELSE
					CASE
						WHEN c1.[KP No_] <> '' THEN 
							(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
									END
							FROM dbo.[Best Practice Training Ltd_$Sales Invoice Header] SH
							WHERE SH.[No_] = c1.[KP No_])
					
						ELSE  
							(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
										ELSE 'STANDARD'
									END
							FROM dbo.[Best Practice Training Ltd_$Sales Invoice Header] SH
							WHERE SH.[No_] = c1.[Document No_])
						END
				END,'') AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[Best Practice Training Ltd_$Sales Invoice Line] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]
INNER JOIN dbo.[Best Practice Training Ltd_$Sales Invoice Header] h ON h.[No_] = c1.[Document No_]
LEFT OUTER JOIN dbo.[Best Practice Training Ltd_$Contact] cn on cn.[No_] = c1.[Contact No_]
LEFT OUTER JOIN dbo.[Best Practice Training Ltd_$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[Best Practice Training Ltd_$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >= '2018/01/01'
AND c1.[Quantity] <>0 AND c1.[Type] = 1 AND c1.[No_] LIKE '6%'
UNION ALL
SELECT 'Datrix Learning Services Ltd.' as [CName],
           'Invoice' as [DocumentType],
           c1.[Document No_] as [DocNo],
		  h.[Document Date],
		  h.[Order No_] as [Sales Order No],
		   c1.[Sell-to Customer No_],c1.[Contact No_],h.[Salesperson Code],cn.[Country_Region Code],
           c1.[Line No_] as [LineNo],
		   c1.[Amt_ Excl_ VAT (LCY)] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Revenue' as [BucketType],
		   c1.[Amt_ Excl_ VAT (LCY)] / ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[Datrix Learning Services Ltd_$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[Datrix Learning Services Ltd_$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country],
						ISNULL((SELECT cr.[Name] FROM dbo.[Datrix Learning Services Ltd_$Country_Region] cr WHERE cr.[Code] IN 
			(SELECT CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[Datrix Learning Services Ltd_$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			ISNULL(CASE
				WHEN h.[Payment Information] <> 6 THEN (
					CASE
						WHEN c1.[No_] IN ('5345', '5343') THEN 'Original KP'
						WHEN c1.[No_] IN ('5344') THEN 'Original FP'
						ELSE
							CASE
								WHEN c1.[KP No_] <> '' THEN 
									(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
												WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
											END
									FROM dbo.[Datrix Learning Services Ltd_$Sales Invoice Header] SH
									WHERE SH.[No_] = c1.[KP No_])
					
								ELSE  
									(SELECT CASE WHEN (c1.[Event Header] <> '' AND SH.[Knowledge Pass] = 1) THEN 'KPUSED'
												WHEN (c1.[Event Header] <> '' AND SH.[Flexi Pass] = 1) THEN 'FPUSED'
												ELSE 'STANDARD'
											END
									FROM dbo.[Datrix Learning Services Ltd_$Sales Invoice Header] SH
									WHERE SH.[No_] = c1.[Document No_])
								END
							END)
				ELSE
					CASE
						WHEN c1.[KP No_] <> '' THEN 
							(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
									END
							FROM dbo.[Datrix Learning Services Ltd_$Sales Invoice Header] SH
							WHERE SH.[No_] = c1.[KP No_])
					
						ELSE  
							(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
										ELSE 'STANDARD'
									END
							FROM dbo.[Datrix Learning Services Ltd_$Sales Invoice Header] SH
							WHERE SH.[No_] = c1.[Document No_])
						END
				END,'') AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[Datrix Learning Services Ltd_$Sales Invoice Line] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]
INNER JOIN dbo.[Datrix Learning Services Ltd_$Sales Invoice Header] h ON h.[No_] = c1.[Document No_]
LEFT OUTER JOIN dbo.[Datrix Learning Services Ltd_$Contact] cn on cn.[No_] = c1.[Contact No_]
LEFT OUTER JOIN dbo.[Datrix Learning Services Ltd_$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[Datrix Learning Services Ltd_$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >= '2018/01/01'
AND c1.[Quantity] <>0 AND c1.[Type] = 1 AND c1.[No_] LIKE '6%'
UNION ALL
SELECT 'Pearce Mayfield Training Ltd' as [CName],
           'Invoice' as [DocumentType],
           c1.[Document No_] as [DocNo],
		 h.[Document Date],
	     h.[Order No_] as [Sales Order No],
		   c1.[Sell-to Customer No_],c1.[Contact No_],h.[Salesperson Code],cn.[Country_Region Code],
           c1.[Line No_] as [LineNo],
		   c1.[Amt_ Excl_ VAT (LCY)] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Revenue' as [BucketType],
		   c1.[Amt_ Excl_ VAT (LCY)] / ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[Pearce Mayfield Training Ltd$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[Pearce Mayfield Training Ltd$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country],
						ISNULL((SELECT cr.[Name] FROM dbo.[Pearce Mayfield Training Ltd$Country_Region] cr WHERE cr.[Code] IN 
			(SELECT CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[Pearce Mayfield Training Ltd$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			ISNULL(CASE
				WHEN h.[Payment Information] <> 6 THEN (
					CASE
						WHEN c1.[No_] IN ('5345', '5343') THEN 'Original KP'
						WHEN c1.[No_] IN ('5344') THEN 'Original FP'
						ELSE
							CASE
								WHEN c1.[KP No_] <> '' THEN 
									(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
												WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
											END
									FROM dbo.[Pearce Mayfield Training Ltd$Sales Invoice Header] SH
									WHERE SH.[No_] = c1.[KP No_])
					
								ELSE  
									(SELECT CASE WHEN (c1.[Event Header] <> '' AND SH.[Knowledge Pass] = 1) THEN 'KPUSED'
												WHEN (c1.[Event Header] <> '' AND SH.[Flexi Pass] = 1) THEN 'FPUSED'
												ELSE 'STANDARD'
											END
									FROM dbo.[Pearce Mayfield Training Ltd$Sales Invoice Header] SH
									WHERE SH.[No_] = c1.[Document No_])
								END
							END)
				ELSE
					CASE
						WHEN c1.[KP No_] <> '' THEN 
							(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
									END
							FROM dbo.[Pearce Mayfield Training Ltd$Sales Invoice Header] SH
							WHERE SH.[No_] = c1.[KP No_])
					
						ELSE  
							(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
										ELSE 'STANDARD'
									END
							FROM dbo.[Pearce Mayfield Training Ltd$Sales Invoice Header] SH
							WHERE SH.[No_] = c1.[Document No_])
						END
				END,'') AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[Pearce Mayfield Training Ltd$Sales Invoice Line] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]
INNER JOIN dbo.[Pearce Mayfield Training Ltd$Sales Invoice Header] h ON h.[No_] = c1.[Document No_]
LEFT OUTER JOIN dbo.[Pearce Mayfield Training Ltd$Contact] cn on cn.[No_] = c1.[Contact No_]
LEFT OUTER JOIN dbo.[Pearce Mayfield Training Ltd$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[Pearce Mayfield Training Ltd$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >= '2018/01/01'
AND c1.[Quantity] <>0 AND c1.[Type] = 1 AND c1.[No_] LIKE '6%'
UNION ALL
SELECT 'Pentagon Leisure Services Ltd' as [CName],
           'Invoice' as [DocumentType],
           c1.[Document No_] as [DocNo],

		  h.[Document Date],
		  h.[Order No_] as [Sales Order No],
		  c1.[Sell-to Customer No_],c1.[Contact No_],h.[Salesperson Code],cn.[Country_Region Code],
           c1.[Line No_] as [LineNo],
		   c1.[Amt_ Excl_ VAT (LCY)] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Revenue' as [BucketType],
		   c1.[Amt_ Excl_ VAT (LCY)] / ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[Pentagon Leisure Services Ltd$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[Pentagon Leisure Services Ltd$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country],
						ISNULL((SELECT cr.[Name] FROM dbo.[Pentagon Leisure Services Ltd$Country_Region] cr WHERE cr.[Code] IN 
			(SELECT CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[Pentagon Leisure Services Ltd$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			ISNULL(CASE
				WHEN h.[Payment Information] <> 6 THEN (
					CASE
						WHEN c1.[No_] IN ('5345', '5343') THEN 'Original KP'
						WHEN c1.[No_] IN ('5344') THEN 'Original FP'
						ELSE
							CASE
								WHEN c1.[KP No_] <> '' THEN 
									(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
												WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
											END
									FROM dbo.[Pentagon Leisure Services Ltd$Sales Invoice Header] SH
									WHERE SH.[No_] = c1.[KP No_])
					
								ELSE  
									(SELECT CASE WHEN (c1.[Event Header] <> '' AND SH.[Knowledge Pass] = 1) THEN 'KPUSED'
												WHEN (c1.[Event Header] <> '' AND SH.[Flexi Pass] = 1) THEN 'FPUSED'
												ELSE 'STANDARD'
											END
									FROM dbo.[Pentagon Leisure Services Ltd$Sales Invoice Header] SH
									WHERE SH.[No_] = c1.[Document No_])
								END
							END)
				ELSE
					CASE
						WHEN c1.[KP No_] <> '' THEN 
							(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
									END
							FROM dbo.[Pentagon Leisure Services Ltd$Sales Invoice Header] SH
							WHERE SH.[No_] = c1.[KP No_])
					
						ELSE  
							(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
										ELSE 'STANDARD'
									END
							FROM dbo.[Pentagon Leisure Services Ltd$Sales Invoice Header] SH
							WHERE SH.[No_] = c1.[Document No_])
						END
				END,'') AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[Pentagon Leisure Services Ltd$Sales Invoice Line] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]
INNER JOIN dbo.[Pentagon Leisure Services Ltd$Sales Invoice Header] h ON h.[No_] = c1.[Document No_]
LEFT OUTER JOIN dbo.[Pentagon Leisure Services Ltd$Contact] cn on cn.[No_] = c1.[Contact No_]
LEFT OUTER JOIN dbo.[Pentagon Leisure Services Ltd$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[Pentagon Leisure Services Ltd$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >= '2018/01/01'
AND c1.[Quantity] <>0 AND c1.[Type] = 1 AND c1.[No_] LIKE '6%'
UNION ALL
SELECT 'Silicon Beach Training' as [CName],
           'Invoice' as [DocumentType],
           c1.[Document No_] as [DocNo],
		   	h.[Document Date],
			h.[Order No_] as [Sales Order No],
c1.[Sell-to Customer No_],c1.[Contact No_],h.[Salesperson Code],cn.[Country_Region Code],
           c1.[Line No_] as [LineNo],
		   c1.[Amt_ Excl_ VAT (LCY)] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Revenue' as [BucketType],
		   c1.[Amt_ Excl_ VAT (LCY)] / ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[Silicon Beach Training$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[Silicon Beach Training$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country],
						ISNULL((SELECT cr.[Name] FROM dbo.[Silicon Beach Training$Country_Region] cr WHERE cr.[Code] IN 
			(SELECT CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[Silicon Beach Training$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			ISNULL(CASE
				WHEN h.[Payment Information] <> 6 THEN (
					CASE
						WHEN c1.[No_] IN ('5345', '5343') THEN 'Original KP'
						WHEN c1.[No_] IN ('5344') THEN 'Original FP'
						ELSE
							CASE
								WHEN c1.[KP No_] <> '' THEN 
									(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
												WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
											END
									FROM dbo.[Silicon Beach Training$Sales Invoice Header] SH
									WHERE SH.[No_] = c1.[KP No_])
					
								ELSE  
									(SELECT CASE WHEN (c1.[Event Header] <> '' AND SH.[Knowledge Pass] = 1) THEN 'KPUSED'
												WHEN (c1.[Event Header] <> '' AND SH.[Flexi Pass] = 1) THEN 'FPUSED'
												ELSE 'STANDARD'
											END
									FROM dbo.[Silicon Beach Training$Sales Invoice Header] SH
									WHERE SH.[No_] = c1.[Document No_])
								END
							END)
				ELSE
					CASE
						WHEN c1.[KP No_] <> '' THEN 
							(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
									END
							FROM dbo.[Silicon Beach Training$Sales Invoice Header] SH
							WHERE SH.[No_] = c1.[KP No_])
					
						ELSE  
							(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
										ELSE 'STANDARD'
									END
							FROM dbo.[Silicon Beach Training$Sales Invoice Header] SH
							WHERE SH.[No_] = c1.[Document No_])
						END
				END,'') AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[Silicon Beach Training$Sales Invoice Line] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]
INNER JOIN dbo.[Silicon Beach Training$Sales Invoice Header] h ON h.[No_] = c1.[Document No_]
LEFT OUTER JOIN dbo.[Silicon Beach Training$Contact] cn on cn.[No_] = c1.[Contact No_]
LEFT OUTER JOIN dbo.[Silicon Beach Training$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[Silicon Beach Training$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >= '2018/01/01'
AND c1.[Quantity] <>0 AND c1.[Type] = 1 AND c1.[No_] LIKE '6%'
UNION ALL
SELECT 'The Knowledge Academy Pty Ltd.' as [CName],
           'Invoice' as [DocumentType],
           c1.[Document No_] as [DocNo],
		  h.[Document Date],
		  h.[Order No_] as [Sales Order No],
c1.[Sell-to Customer No_],c1.[Contact No_],h.[Salesperson Code],cn.[Country_Region Code],
           c1.[Line No_] as [LineNo],
		   c1.[Amt_ Excl_ VAT (LCY)] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Revenue' as [BucketType],
		   c1.[Amt_ Excl_ VAT (LCY)] / ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[The Knowledge Academy Pty Ltd_$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[The Knowledge Academy Pty Ltd_$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country],
						ISNULL((SELECT cr.[Name] FROM dbo.[The Knowledge Academy Pty Ltd_$Country_Region] cr WHERE cr.[Code] IN 
			(SELECT CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[The Knowledge Academy Pty Ltd_$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			ISNULL(CASE
				WHEN h.[Payment Information] <> 6 THEN (
					CASE
						WHEN c1.[No_] IN ('5345', '5343') THEN 'Original KP'
						WHEN c1.[No_] IN ('5344') THEN 'Original FP'
						ELSE
							CASE
								WHEN c1.[KP No_] <> '' THEN 
									(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
												WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
											END
									FROM dbo.[The Knowledge Academy Pty Ltd_$Sales Invoice Header] SH
									WHERE SH.[No_] = c1.[KP No_])
					
								ELSE  
									(SELECT CASE WHEN (c1.[Event Header] <> '' AND SH.[Knowledge Pass] = 1) THEN 'KPUSED'
												WHEN (c1.[Event Header] <> '' AND SH.[Flexi Pass] = 1) THEN 'FPUSED'
												ELSE 'STANDARD'
											END
									FROM dbo.[The Knowledge Academy Pty Ltd_$Sales Invoice Header] SH
									WHERE SH.[No_] = c1.[Document No_])
								END
							END)
				ELSE
					CASE
						WHEN c1.[KP No_] <> '' THEN 
							(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
									END
							FROM dbo.[The Knowledge Academy Pty Ltd_$Sales Invoice Header] SH
							WHERE SH.[No_] = c1.[KP No_])
					
						ELSE  
							(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
										ELSE 'STANDARD'
									END
							FROM dbo.[The Knowledge Academy Pty Ltd_$Sales Invoice Header] SH
							WHERE SH.[No_] = c1.[Document No_])
						END
				END,'') AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[The Knowledge Academy Pty Ltd_$Sales Invoice Line] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]
INNER JOIN dbo.[The Knowledge Academy Pty Ltd_$Sales Invoice Header] h ON h.[No_] = c1.[Document No_]
LEFT OUTER JOIN dbo.[The Knowledge Academy Pty Ltd_$Contact] cn on cn.[No_] = c1.[Contact No_]
LEFT OUTER JOIN dbo.[The Knowledge Academy Pty Ltd_$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[The Knowledge Academy Pty Ltd_$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >= '2018/01/01'
AND c1.[Quantity] <>0 AND c1.[Type] = 1 AND c1.[No_] LIKE '6%'
UNION ALL
SELECT 'The Knowledge Academy SA' as [CName],
           'Invoice' as [DocumentType],
           c1.[Document No_] as [DocNo],
		   h.[Document Date],
		   h.[Order No_] as [Sales Order No],
c1.[Sell-to Customer No_],c1.[Contact No_],h.[Salesperson Code],cn.[Country_Region Code],
           c1.[Line No_] as [LineNo],
		   c1.[Amt_ Excl_ VAT (LCY)] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Revenue' as [BucketType],
		   c1.[Amt_ Excl_ VAT (LCY)] / ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[The Knowledge Academy SA$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[The Knowledge Academy SA$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country],
						ISNULL((SELECT cr.[Name] FROM dbo.[The Knowledge Academy SA$Country_Region] cr WHERE cr.[Code] IN 
			(SELECT CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[The Knowledge Academy SA$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			ISNULL(CASE
				WHEN h.[Payment Information] <> 6 THEN (
					CASE
						WHEN c1.[No_] IN ('5345', '5343') THEN 'Original KP'
						WHEN c1.[No_] IN ('5344') THEN 'Original FP'
						ELSE
							CASE
								WHEN c1.[KP No_] <> '' THEN 
									(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
												WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
											END
									FROM dbo.[The Knowledge Academy SA$Sales Invoice Header] SH
									WHERE SH.[No_] = c1.[KP No_])
					
								ELSE  
									(SELECT CASE WHEN (c1.[Event Header] <> '' AND SH.[Knowledge Pass] = 1) THEN 'KPUSED'
												WHEN (c1.[Event Header] <> '' AND SH.[Flexi Pass] = 1) THEN 'FPUSED'
												ELSE 'STANDARD'
											END
									FROM dbo.[The Knowledge Academy SA$Sales Invoice Header] SH
									WHERE SH.[No_] = c1.[Document No_])
								END
							END)
				ELSE
					CASE
						WHEN c1.[KP No_] <> '' THEN 
							(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
									END
							FROM dbo.[The Knowledge Academy SA$Sales Invoice Header] SH
							WHERE SH.[No_] = c1.[KP No_])
					
						ELSE  
							(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
										ELSE 'STANDARD'
									END
							FROM dbo.[The Knowledge Academy SA$Sales Invoice Header] SH
							WHERE SH.[No_] = c1.[Document No_])
						END
				END,'') AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[The Knowledge Academy SA$Sales Invoice Line] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]
INNER JOIN dbo.[The Knowledge Academy SA$Sales Invoice Header] h ON h.[No_] = c1.[Document No_]
LEFT OUTER JOIN dbo.[The Knowledge Academy SA$Contact] cn on cn.[No_] = c1.[Contact No_]
LEFT OUTER JOIN dbo.[The Knowledge Academy SA$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[The Knowledge Academy SA$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >= '2018/01/01'
AND c1.[Quantity] <>0 AND c1.[Type] = 1 AND c1.[No_] LIKE '6%'
UNION ALL
SELECT 'TKA Canada Corporation' as [CName],
           'Invoice' as [DocumentType],
           c1.[Document No_] as [DocNo],
		 h.[Document Date],
		 h.[Order No_] as [Sales Order No],
c1.[Sell-to Customer No_],c1.[Contact No_],h.[Salesperson Code],cn.[Country_Region Code],
           c1.[Line No_] as [LineNo],
		   c1.[Amt_ Excl_ VAT (LCY)] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Revenue' as [BucketType],
		   c1.[Amt_ Excl_ VAT (LCY)] / ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[TKA Canada Corporation$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[TKA Canada Corporation$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country],
						ISNULL((SELECT cr.[Name] FROM dbo.[TKA Canada Corporation$Country_Region] cr WHERE cr.[Code] IN 
			(SELECT CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[TKA Canada Corporation$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			ISNULL(CASE
				WHEN h.[Payment Information] <> 6 THEN (
					CASE
						WHEN c1.[No_] IN ('5345', '5343') THEN 'Original KP'
						WHEN c1.[No_] IN ('5344') THEN 'Original FP'
						ELSE
							CASE
								WHEN c1.[KP No_] <> '' THEN 
									(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
												WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
											END
									FROM dbo.[TKA Canada Corporation$Sales Invoice Header] SH
									WHERE SH.[No_] = c1.[KP No_])
					
								ELSE  
									(SELECT CASE WHEN (c1.[Event Header] <> '' AND SH.[Knowledge Pass] = 1) THEN 'KPUSED'
												WHEN (c1.[Event Header] <> '' AND SH.[Flexi Pass] = 1) THEN 'FPUSED'
												ELSE 'STANDARD'
											END
									FROM dbo.[TKA Canada Corporation$Sales Invoice Header] SH
									WHERE SH.[No_] = c1.[Document No_])
								END
							END)
				ELSE
					CASE
						WHEN c1.[KP No_] <> '' THEN 
							(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
									END
							FROM dbo.[TKA Canada Corporation$Sales Invoice Header] SH
							WHERE SH.[No_] = c1.[KP No_])
					
						ELSE  
							(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
										ELSE 'STANDARD'
									END
							FROM dbo.[TKA Canada Corporation$Sales Invoice Header] SH
							WHERE SH.[No_] = c1.[Document No_])
						END
				END,'') AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[TKA Canada Corporation$Sales Invoice Line] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]
INNER JOIN dbo.[TKA Canada Corporation$Sales Invoice Header] h ON h.[No_] = c1.[Document No_]
LEFT OUTER JOIN dbo.[TKA Canada Corporation$Contact] cn on cn.[No_] = c1.[Contact No_]
LEFT OUTER JOIN dbo.[TKA Canada Corporation$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[TKA Canada Corporation$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >= '2018/01/01'
AND c1.[Quantity] <>0 AND c1.[Type] = 1 AND c1.[No_] LIKE '6%'
UNION ALL
SELECT 'TKA Europe' as [CName],
           'Invoice' as [DocumentType],
           c1.[Document No_] as [DocNo],
		   h.[Document Date],
		   h.[Order No_] as [Sales Order No],
c1.[Sell-to Customer No_],c1.[Contact No_],h.[Salesperson Code],cn.[Country_Region Code],
           c1.[Line No_] as [LineNo],
		   c1.[Amt_ Excl_ VAT (LCY)] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Revenue' as [BucketType],
		   c1.[Amt_ Excl_ VAT (LCY)] / ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[TKA Europe$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[TKA Europe$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country],
						ISNULL((SELECT cr.[Name] FROM dbo.[TKA Europe$Country_Region] cr WHERE cr.[Code] IN 
			(SELECT CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[TKA Europe$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			ISNULL(CASE
				WHEN h.[Payment Information] <> 6 THEN (
					CASE
						WHEN c1.[No_] IN ('5345', '5343') THEN 'Original KP'
						WHEN c1.[No_] IN ('5344') THEN 'Original FP'
						ELSE
							CASE
								WHEN c1.[KP No_] <> '' THEN 
									(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
												WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
											END
									FROM dbo.[TKA Europe$Sales Invoice Header] SH
									WHERE SH.[No_] = c1.[KP No_])
					
								ELSE  
									(SELECT CASE WHEN (c1.[Event Header] <> '' AND SH.[Knowledge Pass] = 1) THEN 'KPUSED'
												WHEN (c1.[Event Header] <> '' AND SH.[Flexi Pass] = 1) THEN 'FPUSED'
												ELSE 'STANDARD'
											END
									FROM dbo.[TKA Europe$Sales Invoice Header] SH
									WHERE SH.[No_] = c1.[Document No_])
								END
							END)
				ELSE
					CASE
						WHEN c1.[KP No_] <> '' THEN 
							(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
									END
							FROM dbo.[TKA Europe$Sales Invoice Header] SH
							WHERE SH.[No_] = c1.[KP No_])
					
						ELSE  
							(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
										ELSE 'STANDARD'
									END
							FROM dbo.[TKA Europe$Sales Invoice Header] SH
							WHERE SH.[No_] = c1.[Document No_])
						END
				END,'') AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[TKA Europe$Sales Invoice Line] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]
INNER JOIN dbo.[TKA Europe$Sales Invoice Header] h ON h.[No_] = c1.[Document No_]
LEFT OUTER JOIN dbo.[TKA Europe$Contact] cn on cn.[No_] = c1.[Contact No_]
LEFT OUTER JOIN dbo.[TKA Europe$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[TKA Europe$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >= '2018/01/01'
AND c1.[Quantity] <>0 AND c1.[Type] = 1 AND c1.[No_] LIKE '6%'
UNION ALL
SELECT 'TKA Hong Kong Ltd.' as [CName],
           'Invoice' as [DocumentType],
           c1.[Document No_] as [DocNo],
		   h.[Document Date],
		   h.[Order No_] as [Sales Order No],
c1.[Sell-to Customer No_],c1.[Contact No_],h.[Salesperson Code],cn.[Country_Region Code],
           c1.[Line No_] as [LineNo],
		   c1.[Amt_ Excl_ VAT (LCY)] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Revenue' as [BucketType],
		   c1.[Amt_ Excl_ VAT (LCY)] / ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[TKA Hong Kong Ltd_$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[TKA Hong Kong Ltd_$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country],
						ISNULL((SELECT cr.[Name] FROM dbo.[TKA Hong Kong Ltd_$Country_Region] cr WHERE cr.[Code] IN 
			(SELECT CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[TKA Hong Kong Ltd_$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			ISNULL(CASE
				WHEN h.[Payment Information] <> 6 THEN (
					CASE
						WHEN c1.[No_] IN ('5345', '5343') THEN 'Original KP'
						WHEN c1.[No_] IN ('5344') THEN 'Original FP'
						ELSE
							CASE
								WHEN c1.[KP No_] <> '' THEN 
									(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
												WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
											END
									FROM dbo.[TKA Hong Kong Ltd_$Sales Invoice Header] SH
									WHERE SH.[No_] = c1.[KP No_])
					
								ELSE  
									(SELECT CASE WHEN (c1.[Event Header] <> '' AND SH.[Knowledge Pass] = 1) THEN 'KPUSED'
												WHEN (c1.[Event Header] <> '' AND SH.[Flexi Pass] = 1) THEN 'FPUSED'
												ELSE 'STANDARD'
											END
									FROM dbo.[TKA Hong Kong Ltd_$Sales Invoice Header] SH
									WHERE SH.[No_] = c1.[Document No_])
								END
							END)
				ELSE
					CASE
						WHEN c1.[KP No_] <> '' THEN 
							(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
									END
							FROM dbo.[TKA Hong Kong Ltd_$Sales Invoice Header] SH
							WHERE SH.[No_] = c1.[KP No_])
					
						ELSE  
							(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
										ELSE 'STANDARD'
									END
							FROM dbo.[TKA Hong Kong Ltd_$Sales Invoice Header] SH
							WHERE SH.[No_] = c1.[Document No_])
						END
				END,'') AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[TKA Hong Kong Ltd_$Sales Invoice Line] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]
INNER JOIN dbo.[TKA Hong Kong Ltd_$Sales Invoice Header] h ON h.[No_] = c1.[Document No_]
LEFT OUTER JOIN dbo.[TKA Hong Kong Ltd_$Contact] cn on cn.[No_] = c1.[Contact No_]
LEFT OUTER JOIN dbo.[TKA Hong Kong Ltd_$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[TKA Hong Kong Ltd_$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >= '2018/01/01'
AND c1.[Quantity] <>0 AND c1.[Type] = 1 AND c1.[No_] LIKE '6%'
UNION ALL
SELECT 'TKA New Zealand Ltd.' as [CName],
           'Invoice' as [DocumentType],
           c1.[Document No_] as [DocNo],
		 h.[Document Date],
		 h.[Order No_] as [Sales Order No],
c1.[Sell-to Customer No_],c1.[Contact No_],h.[Salesperson Code],cn.[Country_Region Code],
           c1.[Line No_] as [LineNo],
		   c1.[Amt_ Excl_ VAT (LCY)] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Revenue' as [BucketType],
		   c1.[Amt_ Excl_ VAT (LCY)] / ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[TKA New Zealand Ltd_$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[TKA New Zealand Ltd_$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country],
						ISNULL((SELECT cr.[Name] FROM dbo.[TKA New Zealand Ltd_$Country_Region] cr WHERE cr.[Code] IN 
			(SELECT CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[TKA New Zealand Ltd_$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			ISNULL(CASE
				WHEN h.[Payment Information] <> 6 THEN (
					CASE
						WHEN c1.[No_] IN ('5345', '5343') THEN 'Original KP'
						WHEN c1.[No_] IN ('5344') THEN 'Original FP'
						ELSE
							CASE
								WHEN c1.[KP No_] <> '' THEN 
									(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
												WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
											END
									FROM dbo.[TKA New Zealand Ltd_$Sales Invoice Header] SH
									WHERE SH.[No_] = c1.[KP No_])
					
								ELSE  
									(SELECT CASE WHEN (c1.[Event Header] <> '' AND SH.[Knowledge Pass] = 1) THEN 'KPUSED'
												WHEN (c1.[Event Header] <> '' AND SH.[Flexi Pass] = 1) THEN 'FPUSED'
												ELSE 'STANDARD'
											END
									FROM dbo.[TKA New Zealand Ltd_$Sales Invoice Header] SH
									WHERE SH.[No_] = c1.[Document No_])
								END
							END)
				ELSE
					CASE
						WHEN c1.[KP No_] <> '' THEN 
							(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
									END
							FROM dbo.[TKA New Zealand Ltd_$Sales Invoice Header] SH
							WHERE SH.[No_] = c1.[KP No_])
					
						ELSE  
							(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
										ELSE 'STANDARD'
									END
							FROM dbo.[TKA New Zealand Ltd_$Sales Invoice Header] SH
							WHERE SH.[No_] = c1.[Document No_])
						END
				END,'') AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[TKA New Zealand Ltd_$Sales Invoice Line] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]
INNER JOIN dbo.[TKA New Zealand Ltd_$Sales Invoice Header] h ON h.[No_] = c1.[Document No_]
LEFT OUTER JOIN dbo.[TKA New Zealand Ltd_$Contact] cn on cn.[No_] = c1.[Contact No_]
LEFT OUTER JOIN dbo.[TKA New Zealand Ltd_$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[TKA New Zealand Ltd_$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >= '2018/01/01'
AND c1.[Quantity] <>0 AND c1.[Type] = 1 AND c1.[No_] LIKE '6%'
UNION ALL
SELECT 'TKA Singapore PTE Ltd.' as [CName],
           'Invoice' as [DocumentType],
           c1.[Document No_] as [DocNo],
		 h.[Document Date],
		 h.[Order No_] as [Sales Order No],
c1.[Sell-to Customer No_],c1.[Contact No_],h.[Salesperson Code],cn.[Country_Region Code],
           c1.[Line No_] as [LineNo],
		   c1.[Amt_ Excl_ VAT (LCY)] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Revenue' as [BucketType],
		   c1.[Amt_ Excl_ VAT (LCY)] / ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[TKA Singapore PTE Ltd_$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[TKA Singapore PTE Ltd_$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country],
						ISNULL((SELECT cr.[Name] FROM dbo.[TKA Singapore PTE Ltd_$Country_Region] cr WHERE cr.[Code] IN 
			(SELECT CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[TKA Singapore PTE Ltd_$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			ISNULL(CASE
				WHEN h.[Payment Information] <> 6 THEN (
					CASE
						WHEN c1.[No_] IN ('5345', '5343') THEN 'Original KP'
						WHEN c1.[No_] IN ('5344') THEN 'Original FP'
						ELSE
							CASE
								WHEN c1.[KP No_] <> '' THEN 
									(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
												WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
											END
									FROM dbo.[TKA Singapore PTE Ltd_$Sales Invoice Header] SH
									WHERE SH.[No_] = c1.[KP No_])
					
								ELSE  
									(SELECT CASE WHEN (c1.[Event Header] <> '' AND SH.[Knowledge Pass] = 1) THEN 'KPUSED'
												WHEN (c1.[Event Header] <> '' AND SH.[Flexi Pass] = 1) THEN 'FPUSED'
												ELSE 'STANDARD'
											END
									FROM dbo.[TKA Singapore PTE Ltd_$Sales Invoice Header] SH
									WHERE SH.[No_] = c1.[Document No_])
								END
							END)
				ELSE
					CASE
						WHEN c1.[KP No_] <> '' THEN 
							(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
									END
							FROM dbo.[TKA Singapore PTE Ltd_$Sales Invoice Header] SH
							WHERE SH.[No_] = c1.[KP No_])
					
						ELSE  
							(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
										ELSE 'STANDARD'
									END
							FROM dbo.[TKA Singapore PTE Ltd_$Sales Invoice Header] SH
							WHERE SH.[No_] = c1.[Document No_])
						END
				END,'') AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[TKA Singapore PTE Ltd_$Sales Invoice Line] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]
INNER JOIN dbo.[TKA Singapore PTE Ltd_$Sales Invoice Header] h ON h.[No_] = c1.[Document No_]
LEFT OUTER JOIN dbo.[TKA Singapore PTE Ltd_$Contact] cn on cn.[No_] = c1.[Contact No_]
LEFT OUTER JOIN dbo.[TKA Singapore PTE Ltd_$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[TKA Singapore PTE Ltd_$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >= '2018/01/01'
AND c1.[Quantity] <>0 AND c1.[Type] = 1 AND c1.[No_] LIKE '6%'

---ITIL
UNION ALL
SELECT 'ITIL Training Academy' as [CName],
           'Invoice' as [DocumentType],
           c1.[Document No_] as [DocNo],
		   		  h.[Document Date],
				  h.[Order No_] as [Sales Order No],

		   c1.[Sell-to Customer No_],c1.[Contact No_],h.[Salesperson Code],cn.[Country_Region Code],
           c1.[Line No_] as [LineNo],
		   c1.[Amt_ Excl_ VAT (LCY)] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Revenue' as [BucketType],
		   c1.[Amt_ Excl_ VAT (LCY)] / ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[ITIL Training Academy$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[ITIL Training Academy$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country],
			ISNULL((SELECT cr.[Name] FROM dbo.[ITIL Training Academy$Country_Region] cr WHERE cr.[Code] IN 
			(SELECT CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[ITIL Training Academy$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			ISNULL(CASE
				WHEN h.[Payment Information] <> 6 THEN (
					CASE
						WHEN c1.[No_] IN ('5345', '5343') THEN 'Original KP'
						WHEN c1.[No_] IN ('5344') THEN 'Original FP'
						ELSE
							CASE
								WHEN c1.[KP No_] <> '' THEN 
									(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
												WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
											END
									FROM dbo.[ITIL Training Academy$Sales Invoice Header] SH
									WHERE SH.[No_] = c1.[KP No_])
					
								ELSE  
									(SELECT CASE WHEN (c1.[Event Header] <> '' AND SH.[Knowledge Pass] = 1) THEN 'KPUSED'
												WHEN (c1.[Event Header] <> '' AND SH.[Flexi Pass] = 1) THEN 'FPUSED'
												ELSE 'STANDARD'
											END
									FROM dbo.[ITIL Training Academy$Sales Invoice Header] SH
									WHERE SH.[No_] = c1.[Document No_])
								END
							END)
				ELSE
					CASE
						WHEN c1.[KP No_] <> '' THEN 
							(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
									END
							FROM dbo.[ITIL Training Academy$Sales Invoice Header] SH
							WHERE SH.[No_] = c1.[KP No_])
					
						ELSE  
							(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
										ELSE 'STANDARD'
									END
							FROM dbo.[ITIL Training Academy$Sales Invoice Header] SH
							WHERE SH.[No_] = c1.[Document No_])
						END
				END,'') AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[ITIL Training Academy$Sales Invoice Line] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]
INNER JOIN dbo.[ITIL Training Academy$Sales Invoice Header] h ON h.[No_] = c1.[Document No_]
LEFT OUTER JOIN dbo.[ITIL Training Academy$Contact] cn on cn.[No_] = c1.[Contact No_]
LEFT OUTER JOIN dbo.[ITIL Training Academy$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[ITIL Training Academy$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >= '2018/01/01'
AND c1.[Quantity] <>0 AND c1.[Type] = 1 AND c1.[No_] LIKE '6%'
UNION ALL
---Pearce Mayfield Dubai

SELECT 'Pearce Mayfield Train Dubai' as [CName],
           'Invoice' as [DocumentType],
           c1.[Document No_] as [DocNo],
		   		  h.[Document Date],
				  h.[Order No_] as [Sales Order No],

		   c1.[Sell-to Customer No_],c1.[Contact No_],h.[Salesperson Code],cn.[Country_Region Code],
           c1.[Line No_] as [LineNo],
		   c1.[Amt_ Excl_ VAT (LCY)] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Revenue' as [BucketType],
		   c1.[Amt_ Excl_ VAT (LCY)] / ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[Pearce Mayfield Train Dubai$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[Pearce Mayfield Train Dubai$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country],
			ISNULL((SELECT cr.[Name] FROM dbo.[Pearce Mayfield Train Dubai$Country_Region] cr WHERE cr.[Code] IN 
			(SELECT CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[Pearce Mayfield Train Dubai$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			ISNULL(CASE
				WHEN h.[Payment Information] <> 6 THEN (
					CASE
						WHEN c1.[No_] IN ('5345', '5343') THEN 'Original KP'
						WHEN c1.[No_] IN ('5344') THEN 'Original FP'
						ELSE
							CASE
								WHEN c1.[KP No_] <> '' THEN 
									(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
												WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
											END
									FROM dbo.[Pearce Mayfield Train Dubai$Sales Invoice Header] SH
									WHERE SH.[No_] = c1.[KP No_])
					
								ELSE  
									(SELECT CASE WHEN (c1.[Event Header] <> '' AND SH.[Knowledge Pass] = 1) THEN 'KPUSED'
												WHEN (c1.[Event Header] <> '' AND SH.[Flexi Pass] = 1) THEN 'FPUSED'
												ELSE 'STANDARD'
											END
									FROM dbo.[Pearce Mayfield Train Dubai$Sales Invoice Header] SH
									WHERE SH.[No_] = c1.[Document No_])
								END
							END)
				ELSE
					CASE
						WHEN c1.[KP No_] <> '' THEN 
							(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
									END
							FROM dbo.[Pearce Mayfield Train Dubai$Sales Invoice Header] SH
							WHERE SH.[No_] = c1.[KP No_])
					
						ELSE  
							(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
										ELSE 'STANDARD'
									END
							FROM dbo.[Pearce Mayfield Train Dubai$Sales Invoice Header] SH
							WHERE SH.[No_] = c1.[Document No_])
						END
				END,'') AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[Pearce Mayfield Train Dubai$Sales Invoice Line] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]
INNER JOIN dbo.[Pearce Mayfield Train Dubai$Sales Invoice Header] h ON h.[No_] = c1.[Document No_]
LEFT OUTER JOIN dbo.[Pearce Mayfield Train Dubai$Contact] cn on cn.[No_] = c1.[Contact No_]
LEFT OUTER JOIN dbo.[Pearce Mayfield Train Dubai$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[Pearce Mayfield Train Dubai$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >= '2018/01/01'
AND c1.[Quantity] <>0 AND c1.[Type] = 1 AND c1.[No_] LIKE '6%'

-----TKA INDIA START
UNION ALL
---TKA India

SELECT 'TKA India' as [CName],
           'Invoice' as [DocumentType],
           c1.[Document No_] as [DocNo],
		   		  h.[Document Date],
				  h.[Order No_] as [Sales Order No],

		   c1.[Sell-to Customer No_],c1.[Contact No_],h.[Salesperson Code],cn.[Country_Region Code],
           c1.[Line No_] as [LineNo],
		   c1.[Amt_ Excl_ VAT (LCY)] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Revenue' as [BucketType],
		   c1.[Amt_ Excl_ VAT (LCY)] / ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[TKA India$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[TKA India$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country],
			ISNULL((SELECT cr.[Name] FROM dbo.[TKA India$Country_Region] cr WHERE cr.[Code] IN 
			(SELECT CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[TKA India$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			ISNULL(CASE
				WHEN h.[Payment Information] <> 6 THEN (
					CASE
						WHEN c1.[No_] IN ('5345', '5343') THEN 'Original KP'
						WHEN c1.[No_] IN ('5344') THEN 'Original FP'
						ELSE
							CASE
								WHEN c1.[KP No_] <> '' THEN 
									(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
												WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
											END
									FROM dbo.[TKA India$Sales Invoice Header] SH
									WHERE SH.[No_] = c1.[KP No_])
					
								ELSE  
									(SELECT CASE WHEN (c1.[Event Header] <> '' AND SH.[Knowledge Pass] = 1) THEN 'KPUSED'
												WHEN (c1.[Event Header] <> '' AND SH.[Flexi Pass] = 1) THEN 'FPUSED'
												ELSE 'STANDARD'
											END
									FROM dbo.[TKA India$Sales Invoice Header] SH
									WHERE SH.[No_] = c1.[Document No_])
								END
							END)
				ELSE
					CASE
						WHEN c1.[KP No_] <> '' THEN 
							(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
									END
							FROM dbo.[TKA India$Sales Invoice Header] SH
							WHERE SH.[No_] = c1.[KP No_])
					
						ELSE  
							(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
										ELSE 'STANDARD'
									END
							FROM dbo.[TKA India$Sales Invoice Header] SH
							WHERE SH.[No_] = c1.[Document No_])
						END
				END,'') AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[TKA India$Sales Invoice Line] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]
INNER JOIN dbo.[TKA India$Sales Invoice Header] h ON h.[No_] = c1.[Document No_]
LEFT OUTER JOIN dbo.[TKA India$Contact] cn on cn.[No_] = c1.[Contact No_]
LEFT OUTER JOIN dbo.[TKA India$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[TKA India$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >= '2018/01/01'
AND c1.[Quantity] <>0 AND c1.[Type] = 1 AND c1.[No_] LIKE '6%'



--TKA INDIA END

UNION ALL


SELECT 'The Knowledge Academy Limited' as [CName],
           'CreditMemo' as [DocumentType],
           c1.[Document No_] as [DocNo],
		 h.[Document Date],
		  h.[Original So No] as [Sales Order No],
c1.[Sell-to Customer No_],c1.[Contact No_],h.[Salesperson Code],cn.[Country_Region Code],
           c1.[Line No_] as [LineNo],
		   c1.[Amt_ Excl_ VAT (LCY)] * -1 as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Revenue' as [BucketType],
		   c1.[Amt_ Excl_ VAT (LCY)] * -1 / ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[The Knowledge Academy Limited$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[The Knowledge Academy Limited$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country],
						ISNULL((SELECT cr.[Name] FROM dbo.[The Knowledge Academy Limited$Country_Region] cr WHERE cr.[Code] IN 
			(SELECT CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[The Knowledge Academy Limited$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity]*-1,
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			ISNULL(CASE
				WHEN h.[Payment Information] <> 6 THEN (
					CASE
						WHEN c1.[No_] IN ('5345', '5343') THEN 'Original KP'
						WHEN c1.[No_] IN ('5344') THEN 'Original FP'
						ELSE
							CASE
								WHEN c1.[KP No_] <> '' THEN 
									(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
												WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
											END
									FROM dbo.[The Knowledge Academy Limited$Sales Invoice Header] SH
									WHERE SH.[No_] = c1.[KP No_])
					
								ELSE  
									(SELECT CASE WHEN (c1.[Event Header] <> '' AND SH.[Old KP] = 1) THEN 'KPUSED'
												WHEN (c1.[Event Header] <> '' AND SH.[Flexi Pass] = 1) THEN 'FPUSED'
												ELSE 'STANDARD'
											END
									FROM dbo.[The Knowledge Academy Limited$Sales Cr_Memo Header] SH
									WHERE SH.[No_] = c1.[Document No_])
								END
							END)
				ELSE
					CASE
						WHEN c1.[KP No_] <> '' THEN 
							(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
									END
							FROM dbo.[The Knowledge Academy Limited$Sales Invoice Header] SH
							WHERE SH.[No_] = c1.[KP No_])
					
						ELSE  
							(SELECT CASE WHEN SH.[Old KP] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
										ELSE 'STANDARD'
									END
							FROM dbo.[The Knowledge Academy Limited$Sales Cr_Memo Header] SH
							WHERE SH.[No_] = c1.[Document No_])
						END
				END,'') AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[The Knowledge Academy Limited$Sales Cr_Memo Line] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]
INNER JOIN dbo.[The Knowledge Academy Limited$Sales Cr_Memo Header] h ON h.[No_] = c1.[Document No_]
LEFT OUTER JOIN dbo.[The Knowledge Academy Limited$Contact] cn on cn.[No_] = c1.[Contact No_]
LEFT OUTER JOIN dbo.[The Knowledge Academy Limited$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[The Knowledge Academy Limited$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >=  '2018/01/01'
AND c1.[Quantity] <>0 AND c1.[Type] = 1 AND c1.[No_] LIKE '6%'
UNION ALL
SELECT 'The Knowledge Academy Inc' as [CName],
           'CreditMemo' as [DocumentType],
           c1.[Document No_] as [DocNo],
		 h.[Document Date],
		 h.[Original So No] as [Sales Order No],
c1.[Sell-to Customer No_],c1.[Contact No_],h.[Salesperson Code],cn.[Country_Region Code],
           c1.[Line No_] as [LineNo],
		   c1.[Amt_ Excl_ VAT (LCY)] * -1 as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Revenue' as [BucketType],
		   c1.[Amt_ Excl_ VAT (LCY)] * -1 / ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[The Knowledge Academy Inc$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[The Knowledge Academy Inc$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country],
						ISNULL((SELECT cr.[Name] FROM dbo.[The Knowledge Academy Inc$Country_Region] cr WHERE cr.[Code] IN 
			(SELECT CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[The Knowledge Academy Inc$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity]*-1,
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			ISNULL(CASE
				WHEN h.[Payment Information] <> 6 THEN (
					CASE
						WHEN c1.[No_] IN ('5345', '5343') THEN 'Original KP'
						WHEN c1.[No_] IN ('5344') THEN 'Original FP'
						ELSE
							CASE
								WHEN c1.[KP No_] <> '' THEN 
									(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
												WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
											END
									FROM dbo.[The Knowledge Academy Inc$Sales Invoice Header] SH
									WHERE SH.[No_] = c1.[KP No_])
					
								ELSE  
									(SELECT CASE WHEN (c1.[Event Header] <> '' AND SH.[Old KP] = 1) THEN 'KPUSED'
												WHEN (c1.[Event Header] <> '' AND SH.[Flexi Pass] = 1) THEN 'FPUSED'
												ELSE 'STANDARD'
											END
									FROM dbo.[The Knowledge Academy Inc$Sales Cr_Memo Header] SH
									WHERE SH.[No_] = c1.[Document No_])
								END
							END)
				ELSE
					CASE
						WHEN c1.[KP No_] <> '' THEN 
							(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
									END
							FROM dbo.[The Knowledge Academy Inc$Sales Invoice Header] SH
							WHERE SH.[No_] = c1.[KP No_])
					
						ELSE  
							(SELECT CASE WHEN SH.[Old KP] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
										ELSE 'STANDARD'
									END
							FROM dbo.[The Knowledge Academy Inc$Sales Cr_Memo Header] SH
							WHERE SH.[No_] = c1.[Document No_])
						END
				END,'') AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[The Knowledge Academy Inc$Sales Cr_Memo Line] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]
INNER JOIN dbo.[The Knowledge Academy Inc$Sales Cr_Memo Header] h ON h.[No_] = c1.[Document No_]
LEFT OUTER JOIN dbo.[The Knowledge Academy Inc$Contact] cn on cn.[No_] = c1.[Contact No_]
LEFT OUTER JOIN dbo.[The Knowledge Academy Inc$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[The Knowledge Academy Inc$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >= '2018/01/01'
AND c1.[Quantity] <>0 AND c1.[Type] = 1 AND c1.[No_] LIKE '6%'
UNION ALL
SELECT 'Best Practice Training Ltd.' as [CName],
           'CreditMemo' as [DocumentType],
           c1.[Document No_] as [DocNo],
		  h.[Document Date],
          h.[Original So No] as [Sales Order No],
c1.[Sell-to Customer No_],c1.[Contact No_],h.[Salesperson Code],cn.[Country_Region Code],
           c1.[Line No_] as [LineNo],
		   c1.[Amt_ Excl_ VAT (LCY)] * -1 as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Revenue' as [BucketType],
		   c1.[Amt_ Excl_ VAT (LCY)] * -1 / ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[Best Practice Training Ltd_$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[Best Practice Training Ltd_$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country],
						ISNULL((SELECT cr.[Name] FROM dbo.[Best Practice Training Ltd_$Country_Region] cr WHERE cr.[Code] IN 
			(SELECT CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[Best Practice Training Ltd_$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity]*-1,
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			ISNULL(CASE
				WHEN h.[Payment Information] <> 6 THEN (
					CASE
						WHEN c1.[No_] IN ('5345', '5343') THEN 'Original KP'
						WHEN c1.[No_] IN ('5344') THEN 'Original FP'
						ELSE
							CASE
								WHEN c1.[KP No_] <> '' THEN 
									(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
												WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
											END
									FROM dbo.[Best Practice Training Ltd_$Sales Invoice Header] SH
									WHERE SH.[No_] = c1.[KP No_])
					
								ELSE  
									(SELECT CASE WHEN (c1.[Event Header] <> '' AND SH.[Old KP] = 1) THEN 'KPUSED'
												WHEN (c1.[Event Header] <> '' AND SH.[Flexi Pass] = 1) THEN 'FPUSED'
												ELSE 'STANDARD'
											END
									FROM dbo.[Best Practice Training Ltd_$Sales Cr_Memo Header] SH
									WHERE SH.[No_] = c1.[Document No_])
								END
							END)
				ELSE
					CASE
						WHEN c1.[KP No_] <> '' THEN 
							(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
									END
							FROM dbo.[Best Practice Training Ltd_$Sales Invoice Header] SH
							WHERE SH.[No_] = c1.[KP No_])
					
						ELSE  
							(SELECT CASE WHEN SH.[Old KP] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
										ELSE 'STANDARD'
									END
							FROM dbo.[Best Practice Training Ltd_$Sales Cr_Memo Header] SH
							WHERE SH.[No_] = c1.[Document No_])
						END
				END,'') AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[Best Practice Training Ltd_$Sales Cr_Memo Line] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]
INNER JOIN dbo.[Best Practice Training Ltd_$Sales Cr_Memo Header] h ON h.[No_] = c1.[Document No_]
LEFT OUTER JOIN dbo.[Best Practice Training Ltd_$Contact] cn on cn.[No_] = c1.[Contact No_]
LEFT OUTER JOIN dbo.[Best Practice Training Ltd_$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[Best Practice Training Ltd_$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >= '2018/01/01'
AND c1.[Quantity] <>0 AND c1.[Type] = 1 AND c1.[No_] LIKE '6%'
UNION ALL
SELECT 'Datrix Learning Services Ltd.' as [CName],
           'CreditMemo' as [DocumentType],
           c1.[Document No_] as [DocNo],
		  h.[Document Date],
		  h.[Original So No] as [Sales Order No],
c1.[Sell-to Customer No_],c1.[Contact No_],h.[Salesperson Code],cn.[Country_Region Code],
           c1.[Line No_] as [LineNo],
		   c1.[Amt_ Excl_ VAT (LCY)] * -1 as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Revenue' as [BucketType],
		   c1.[Amt_ Excl_ VAT (LCY)] * -1 / ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[Datrix Learning Services Ltd_$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[Datrix Learning Services Ltd_$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country],
						ISNULL((SELECT cr.[Name] FROM dbo.[Datrix Learning Services Ltd_$Country_Region] cr WHERE cr.[Code] IN 
			(SELECT CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[Datrix Learning Services Ltd_$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity]*-1,
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			ISNULL(CASE
				WHEN h.[Payment Information] <> 6 THEN (
					CASE
						WHEN c1.[No_] IN ('5345', '5343') THEN 'Original KP'
						WHEN c1.[No_] IN ('5344') THEN 'Original FP'
						ELSE
							CASE
								WHEN c1.[KP No_] <> '' THEN 
									(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
												WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
											END
									FROM dbo.[Datrix Learning Services Ltd_$Sales Invoice Header] SH
									WHERE SH.[No_] = c1.[KP No_])
					
								ELSE  
									(SELECT CASE WHEN (c1.[Event Header] <> '' AND SH.[Old KP] = 1) THEN 'KPUSED'
												WHEN (c1.[Event Header] <> '' AND SH.[Flexi Pass] = 1) THEN 'FPUSED'
												ELSE 'STANDARD'
											END
									FROM dbo.[Datrix Learning Services Ltd_$Sales Cr_Memo Header] SH
									WHERE SH.[No_] = c1.[Document No_])
								END
							END)
				ELSE
					CASE
						WHEN c1.[KP No_] <> '' THEN 
							(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
									END
							FROM dbo.[Datrix Learning Services Ltd_$Sales Invoice Header] SH
							WHERE SH.[No_] = c1.[KP No_])
					
						ELSE  
							(SELECT CASE WHEN SH.[Old KP] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
										ELSE 'STANDARD'
									END
							FROM dbo.[Datrix Learning Services Ltd_$Sales Cr_Memo Header] SH
							WHERE SH.[No_] = c1.[Document No_])
						END
				END,'') AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[Datrix Learning Services Ltd_$Sales Cr_Memo Line] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]
INNER JOIN dbo.[Datrix Learning Services Ltd_$Sales Cr_Memo Header] h ON h.[No_] = c1.[Document No_]
LEFT OUTER JOIN dbo.[Datrix Learning Services Ltd_$Contact] cn on cn.[No_] = c1.[Contact No_]
LEFT OUTER JOIN dbo.[Datrix Learning Services Ltd_$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[Datrix Learning Services Ltd_$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >= '2018/01/01'
AND c1.[Quantity] <>0 AND c1.[Type] = 1 AND c1.[No_] LIKE '6%'
UNION ALL
SELECT 'Pearce Mayfield Training Ltd' as [CName],
           'CreditMemo' as [DocumentType],
           c1.[Document No_] as [DocNo],
		  h.[Document Date],
          h.[Original So No] as [Sales Order No],
c1.[Sell-to Customer No_],c1.[Contact No_],h.[Salesperson Code],cn.[Country_Region Code],
           c1.[Line No_] as [LineNo],
		   c1.[Amt_ Excl_ VAT (LCY)] * -1 as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Revenue' as [BucketType],
		   c1.[Amt_ Excl_ VAT (LCY)] * -1 / ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[Pearce Mayfield Training Ltd$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[Pearce Mayfield Training Ltd$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country],
						ISNULL((SELECT cr.[Name] FROM dbo.[Pearce Mayfield Training Ltd$Country_Region] cr WHERE cr.[Code] IN 
			(SELECT CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[Pearce Mayfield Training Ltd$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity]*-1,
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			ISNULL(CASE
				WHEN h.[Payment Information] <> 6 THEN (
					CASE
						WHEN c1.[No_] IN ('5345', '5343') THEN 'Original KP'
						WHEN c1.[No_] IN ('5344') THEN 'Original FP'
						ELSE
							CASE
								WHEN c1.[KP No_] <> '' THEN 
									(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
												WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
											END
									FROM dbo.[Pearce Mayfield Training Ltd$Sales Invoice Header] SH
									WHERE SH.[No_] = c1.[KP No_])
					
								ELSE  
									(SELECT CASE WHEN (c1.[Event Header] <> '' AND SH.[Old KP] = 1) THEN 'KPUSED'
												WHEN (c1.[Event Header] <> '' AND SH.[Flexi Pass] = 1) THEN 'FPUSED'
												ELSE 'STANDARD'
											END
									FROM dbo.[Pearce Mayfield Training Ltd$Sales Cr_Memo Header] SH
									WHERE SH.[No_] = c1.[Document No_])
								END
							END)
				ELSE
					CASE
						WHEN c1.[KP No_] <> '' THEN 
							(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
									END
							FROM dbo.[Pearce Mayfield Training Ltd$Sales Invoice Header] SH
							WHERE SH.[No_] = c1.[KP No_])
					
						ELSE  
							(SELECT CASE WHEN SH.[Old KP] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
										ELSE 'STANDARD'
									END
							FROM dbo.[Pearce Mayfield Training Ltd$Sales Cr_Memo Header] SH
							WHERE SH.[No_] = c1.[Document No_])
						END
				END,'') AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[Pearce Mayfield Training Ltd$Sales Cr_Memo Line] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]
INNER JOIN dbo.[Pearce Mayfield Training Ltd$Sales Cr_Memo Header] h ON h.[No_] = c1.[Document No_]
LEFT OUTER JOIN dbo.[Pearce Mayfield Training Ltd$Contact] cn on cn.[No_] = c1.[Contact No_]
LEFT OUTER JOIN dbo.[Pearce Mayfield Training Ltd$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[Pearce Mayfield Training Ltd$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >= '2018/01/01'
AND c1.[Quantity] <>0 AND c1.[Type] = 1 AND c1.[No_] LIKE '6%'
UNION ALL
SELECT 'Pentagon Leisure Services Ltd' as [CName],
           'CreditMemo' as [DocumentType],
           c1.[Document No_] as [DocNo],
		  h.[Document Date],
          h.[Original So No] as [Sales Order No],
c1.[Sell-to Customer No_],c1.[Contact No_],h.[Salesperson Code],cn.[Country_Region Code],
           c1.[Line No_] as [LineNo],
		   c1.[Amt_ Excl_ VAT (LCY)] * -1 as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Revenue' as [BucketType],
		   c1.[Amt_ Excl_ VAT (LCY)] * -1 / ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[Pentagon Leisure Services Ltd$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[Pentagon Leisure Services Ltd$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country],
						ISNULL((SELECT cr.[Name] FROM dbo.[Pentagon Leisure Services Ltd$Country_Region] cr WHERE cr.[Code] IN 
			(SELECT CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[Pentagon Leisure Services Ltd$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity]*-1,
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			ISNULL(CASE
				WHEN h.[Payment Information] <> 6 THEN (
					CASE
						WHEN c1.[No_] IN ('5345', '5343') THEN 'Original KP'
						WHEN c1.[No_] IN ('5344') THEN 'Original FP'
						ELSE
							CASE
								WHEN c1.[KP No_] <> '' THEN 
									(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
												WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
											END
									FROM dbo.[Pentagon Leisure Services Ltd$Sales Invoice Header] SH
									WHERE SH.[No_] = c1.[KP No_])
					
								ELSE  
									(SELECT CASE WHEN (c1.[Event Header] <> '' AND SH.[Old KP] = 1) THEN 'KPUSED'
												WHEN (c1.[Event Header] <> '' AND SH.[Flexi Pass] = 1) THEN 'FPUSED'
												ELSE 'STANDARD'
											END
									FROM dbo.[Pentagon Leisure Services Ltd$Sales Cr_Memo Header] SH
									WHERE SH.[No_] = c1.[Document No_])
								END
							END)
				ELSE
					CASE
						WHEN c1.[KP No_] <> '' THEN 
							(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
									END
							FROM dbo.[Pentagon Leisure Services Ltd$Sales Invoice Header] SH
							WHERE SH.[No_] = c1.[KP No_])
					
						ELSE  
							(SELECT CASE WHEN SH.[Old KP] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
										ELSE 'STANDARD'
									END
							FROM dbo.[Pentagon Leisure Services Ltd$Sales Cr_Memo Header] SH
							WHERE SH.[No_] = c1.[Document No_])
						END
				END,'') AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[Pentagon Leisure Services Ltd$Sales Cr_Memo Line] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]
INNER JOIN dbo.[Pentagon Leisure Services Ltd$Sales Cr_Memo Header] h ON h.[No_] = c1.[Document No_]
LEFT OUTER JOIN dbo.[Pentagon Leisure Services Ltd$Contact] cn on cn.[No_] = c1.[Contact No_]
LEFT OUTER JOIN dbo.[Pentagon Leisure Services Ltd$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[Pentagon Leisure Services Ltd$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >= '2018/01/01'
AND c1.[Quantity] <>0 AND c1.[Type] = 1 AND c1.[No_] LIKE '6%'
UNION ALL

--TKA INDIA Credit Note Start
SELECT 'TKA India' as [CName],
           'CreditMemo' as [DocumentType],
           c1.[Document No_] as [DocNo],
		  h.[Document Date],
          h.[Original So No] as [Sales Order No],
c1.[Sell-to Customer No_],c1.[Contact No_],h.[Salesperson Code],cn.[Country_Region Code],
           c1.[Line No_] as [LineNo],
		   c1.[Amt_ Excl_ VAT (LCY)] * -1 as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Revenue' as [BucketType],
		   c1.[Amt_ Excl_ VAT (LCY)] * -1 / ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[TKA India$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[TKA India$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country],
						ISNULL((SELECT cr.[Name] FROM dbo.[TKA India$Country_Region] cr WHERE cr.[Code] IN 
			(SELECT CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[TKA India$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity]*-1,
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			ISNULL(CASE
				WHEN h.[Payment Information] <> 6 THEN (
					CASE
						WHEN c1.[No_] IN ('5345', '5343') THEN 'Original KP'
						WHEN c1.[No_] IN ('5344') THEN 'Original FP'
						ELSE
							CASE
								WHEN c1.[KP No_] <> '' THEN 
									(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
												WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
											END
									FROM dbo.[TKA India$Sales Invoice Header] SH
									WHERE SH.[No_] = c1.[KP No_])
					
								ELSE  
									(SELECT CASE WHEN (c1.[Event Header] <> '' AND SH.[Old KP] = 1) THEN 'KPUSED'
												WHEN (c1.[Event Header] <> '' AND SH.[Flexi Pass] = 1) THEN 'FPUSED'
												ELSE 'STANDARD'
											END
									FROM dbo.[TKA India$Sales Cr_Memo Header] SH
									WHERE SH.[No_] = c1.[Document No_])
								END
							END)
				ELSE
					CASE
						WHEN c1.[KP No_] <> '' THEN 
							(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
									END
							FROM dbo.[TKA India$Sales Invoice Header] SH
							WHERE SH.[No_] = c1.[KP No_])
					
						ELSE  
							(SELECT CASE WHEN SH.[Old KP] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
										ELSE 'STANDARD'
									END
							FROM dbo.[TKA India$Sales Cr_Memo Header] SH
							WHERE SH.[No_] = c1.[Document No_])
						END
				END,'') AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[TKA India$Sales Cr_Memo Line] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]
INNER JOIN dbo.[TKA India$Sales Cr_Memo Header] h ON h.[No_] = c1.[Document No_]
LEFT OUTER JOIN dbo.[TKA India$Contact] cn on cn.[No_] = c1.[Contact No_]
LEFT OUTER JOIN dbo.[TKA India$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[TKA India$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >= '2018/01/01'
AND c1.[Quantity] <>0 AND c1.[Type] = 1 AND c1.[No_] LIKE '6%'
UNION ALL

--//TKA India Credit Note End
SELECT 'Silicon Beach Training' as [CName],
           'CreditMemo' as [DocumentType],
           c1.[Document No_] as [DocNo],
		  h.[Document Date],
          h.[Original So No] as [Sales Order No],
c1.[Sell-to Customer No_],c1.[Contact No_],h.[Salesperson Code],cn.[Country_Region Code],
           c1.[Line No_] as [LineNo],
		   c1.[Amt_ Excl_ VAT (LCY)] * -1 as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Revenue' as [BucketType],
		   c1.[Amt_ Excl_ VAT (LCY)] * -1 / ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[Silicon Beach Training$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[Silicon Beach Training$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country],
						ISNULL((SELECT cr.[Name] FROM dbo.[Silicon Beach Training$Country_Region] cr WHERE cr.[Code] IN 
			(SELECT CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[Silicon Beach Training$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity]*-1,
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			ISNULL(CASE
				WHEN h.[Payment Information] <> 6 THEN (
					CASE
						WHEN c1.[No_] IN ('5345', '5343') THEN 'Original KP'
						WHEN c1.[No_] IN ('5344') THEN 'Original FP'
						ELSE
							CASE
								WHEN c1.[KP No_] <> '' THEN 
									(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
												WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
											END
									FROM dbo.[Silicon Beach Training$Sales Invoice Header] SH
									WHERE SH.[No_] = c1.[KP No_])
					
								ELSE  
									(SELECT CASE WHEN (c1.[Event Header] <> '' AND SH.[Old KP] = 1) THEN 'KPUSED'
												WHEN (c1.[Event Header] <> '' AND SH.[Flexi Pass] = 1) THEN 'FPUSED'
												ELSE 'STANDARD'
											END
									FROM dbo.[Silicon Beach Training$Sales Cr_Memo Header] SH
									WHERE SH.[No_] = c1.[Document No_])
								END
							END)
				ELSE
					CASE
						WHEN c1.[KP No_] <> '' THEN 
							(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
									END
							FROM dbo.[Silicon Beach Training$Sales Invoice Header] SH
							WHERE SH.[No_] = c1.[KP No_])
					
						ELSE  
							(SELECT CASE WHEN SH.[Old KP] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
										ELSE 'STANDARD'
									END
							FROM dbo.[Silicon Beach Training$Sales Cr_Memo Header] SH
							WHERE SH.[No_] = c1.[Document No_])
						END
				END,'') AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[Silicon Beach Training$Sales Cr_Memo Line] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]
INNER JOIN dbo.[Silicon Beach Training$Sales Cr_Memo Header] h ON h.[No_] = c1.[Document No_]
LEFT OUTER JOIN dbo.[Silicon Beach Training$Contact] cn on cn.[No_] = c1.[Contact No_]
LEFT OUTER JOIN dbo.[Silicon Beach Training$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[Silicon Beach Training$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >= '2018/01/01'
AND c1.[Quantity] <>0 AND c1.[Type] = 1 AND c1.[No_] LIKE '6%'
UNION ALL
SELECT 'The Knowledge Academy Pty Ltd.' as [CName],
           'CreditMemo' as [DocumentType],
           c1.[Document No_] as [DocNo],
		   h.[Document Date],
           h.[Original So No] as [Sales Order No],
c1.[Sell-to Customer No_],c1.[Contact No_],h.[Salesperson Code],cn.[Country_Region Code],
           c1.[Line No_] as [LineNo],
		   c1.[Amt_ Excl_ VAT (LCY)] * -1 as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Revenue' as [BucketType],
		   c1.[Amt_ Excl_ VAT (LCY)] * -1 / ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[The Knowledge Academy Pty Ltd_$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[The Knowledge Academy Pty Ltd_$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country],
						ISNULL((SELECT cr.[Name] FROM dbo.[The Knowledge Academy Pty Ltd_$Country_Region] cr WHERE cr.[Code] IN 
			(SELECT CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[The Knowledge Academy Pty Ltd_$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity]*-1,
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			ISNULL(CASE
				WHEN h.[Payment Information] <> 6 THEN (
					CASE
						WHEN c1.[No_] IN ('5345', '5343') THEN 'Original KP'
						WHEN c1.[No_] IN ('5344') THEN 'Original FP'
						ELSE
							CASE
								WHEN c1.[KP No_] <> '' THEN 
									(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
												WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
											END
									FROM dbo.[The Knowledge Academy Pty Ltd_$Sales Invoice Header] SH
									WHERE SH.[No_] = c1.[KP No_])
					
								ELSE  
									(SELECT CASE WHEN (c1.[Event Header] <> '' AND SH.[Old KP] = 1) THEN 'KPUSED'
												WHEN (c1.[Event Header] <> '' AND SH.[Flexi Pass] = 1) THEN 'FPUSED'
												ELSE 'STANDARD'
											END
									FROM dbo.[The Knowledge Academy Pty Ltd_$Sales Cr_Memo Header] SH
									WHERE SH.[No_] = c1.[Document No_])
								END
							END)
				ELSE
					CASE
						WHEN c1.[KP No_] <> '' THEN 
							(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
									END
							FROM dbo.[The Knowledge Academy Pty Ltd_$Sales Invoice Header] SH
							WHERE SH.[No_] = c1.[KP No_])
					
						ELSE  
							(SELECT CASE WHEN SH.[Old KP] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
										ELSE 'STANDARD'
									END
							FROM dbo.[The Knowledge Academy Pty Ltd_$Sales Cr_Memo Header] SH
							WHERE SH.[No_] = c1.[Document No_])
						END
				END,'') AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[The Knowledge Academy Pty Ltd_$Sales Cr_Memo Line] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]
INNER JOIN dbo.[The Knowledge Academy Pty Ltd_$Sales Cr_Memo Header] h ON h.[No_] = c1.[Document No_]
LEFT OUTER JOIN dbo.[The Knowledge Academy Pty Ltd_$Contact] cn on cn.[No_] = c1.[Contact No_]
LEFT OUTER JOIN dbo.[The Knowledge Academy Pty Ltd_$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[The Knowledge Academy Pty Ltd_$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >= '2018/01/01'
AND c1.[Quantity] <>0 AND c1.[Type] = 1 AND c1.[No_] LIKE '6%'
UNION ALL
SELECT 'The Knowledge Academy SA' as [CName],
           'CreditMemo' as [DocumentType],
           c1.[Document No_] as [DocNo],
		 h.[Document Date],
         h.[Original So No] as [Sales Order No],
c1.[Sell-to Customer No_],c1.[Contact No_],h.[Salesperson Code],cn.[Country_Region Code],
           c1.[Line No_] as [LineNo],
		   c1.[Amt_ Excl_ VAT (LCY)] * -1 as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Revenue' as [BucketType],
		   c1.[Amt_ Excl_ VAT (LCY)] * -1 / ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[The Knowledge Academy SA$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[The Knowledge Academy SA$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country],
						ISNULL((SELECT cr.[Name] FROM dbo.[The Knowledge Academy SA$Country_Region] cr WHERE cr.[Code] IN 
			(SELECT CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[The Knowledge Academy SA$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity]*-1,
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			ISNULL(CASE
				WHEN h.[Payment Information] <> 6 THEN (
					CASE
						WHEN c1.[No_] IN ('5345', '5343') THEN 'Original KP'
						WHEN c1.[No_] IN ('5344') THEN 'Original FP'
						ELSE
							CASE
								WHEN c1.[KP No_] <> '' THEN 
									(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
												WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
											END
									FROM dbo.[The Knowledge Academy SA$Sales Invoice Header] SH
									WHERE SH.[No_] = c1.[KP No_])
					
								ELSE  
									(SELECT CASE WHEN (c1.[Event Header] <> '' AND SH.[Old KP] = 1) THEN 'KPUSED'
												WHEN (c1.[Event Header] <> '' AND SH.[Flexi Pass] = 1) THEN 'FPUSED'
												ELSE 'STANDARD'
											END
									FROM dbo.[The Knowledge Academy SA$Sales Cr_Memo Header] SH
									WHERE SH.[No_] = c1.[Document No_])
								END
							END)
				ELSE
					CASE
						WHEN c1.[KP No_] <> '' THEN 
							(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
									END
							FROM dbo.[The Knowledge Academy SA$Sales Invoice Header] SH
							WHERE SH.[No_] = c1.[KP No_])
					
						ELSE  
							(SELECT CASE WHEN SH.[Old KP] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
										ELSE 'STANDARD'
									END
							FROM dbo.[The Knowledge Academy SA$Sales Cr_Memo Header] SH
							WHERE SH.[No_] = c1.[Document No_])
						END
				END,'') AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[The Knowledge Academy SA$Sales Cr_Memo Line] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]
INNER JOIN dbo.[The Knowledge Academy SA$Sales Cr_Memo Header] h ON h.[No_] = c1.[Document No_]
LEFT OUTER JOIN dbo.[The Knowledge Academy SA$Contact] cn on cn.[No_] = c1.[Contact No_]
LEFT OUTER JOIN dbo.[The Knowledge Academy SA$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[The Knowledge Academy SA$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >= '2018/01/01'
AND c1.[Quantity] <>0 AND c1.[Type] = 1 AND c1.[No_] LIKE '6%'
UNION ALL
SELECT 'TKA Canada Corporation' as [CName],
           'CreditMemo' as [DocumentType],
           c1.[Document No_] as [DocNo],
		  h.[Document Date],
          h.[Original So No] as [Sales Order No],
c1.[Sell-to Customer No_],c1.[Contact No_],h.[Salesperson Code],cn.[Country_Region Code],
           c1.[Line No_] as [LineNo],
		   c1.[Amt_ Excl_ VAT (LCY)] * -1 as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Revenue' as [BucketType],
		   c1.[Amt_ Excl_ VAT (LCY)] * -1 / ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[TKA Canada Corporation$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[TKA Canada Corporation$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country],
						ISNULL((SELECT cr.[Name] FROM dbo.[TKA Canada Corporation$Country_Region] cr WHERE cr.[Code] IN 
			(SELECT CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[TKA Canada Corporation$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity]*-1,
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			ISNULL(CASE
				WHEN h.[Payment Information] <> 6 THEN (
					CASE
						WHEN c1.[No_] IN ('5345', '5343') THEN 'Original KP'
						WHEN c1.[No_] IN ('5344') THEN 'Original FP'
						ELSE
							CASE
								WHEN c1.[KP No_] <> '' THEN 
									(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
												WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
											END
									FROM dbo.[TKA Canada Corporation$Sales Invoice Header] SH
									WHERE SH.[No_] = c1.[KP No_])
					
								ELSE  
									(SELECT CASE WHEN (c1.[Event Header] <> '' AND SH.[Old KP] = 1) THEN 'KPUSED'
												WHEN (c1.[Event Header] <> '' AND SH.[Flexi Pass] = 1) THEN 'FPUSED'
												ELSE 'STANDARD'
											END
									FROM dbo.[TKA Canada Corporation$Sales Cr_Memo Header] SH
									WHERE SH.[No_] = c1.[Document No_])
								END
							END)
				ELSE
					CASE
						WHEN c1.[KP No_] <> '' THEN 
							(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
									END
							FROM dbo.[TKA Canada Corporation$Sales Invoice Header] SH
							WHERE SH.[No_] = c1.[KP No_])
					
						ELSE  
							(SELECT CASE WHEN SH.[Old KP] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
										ELSE 'STANDARD'
									END
							FROM dbo.[TKA Canada Corporation$Sales Cr_Memo Header] SH
							WHERE SH.[No_] = c1.[Document No_])
						END
				END,'') AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[TKA Canada Corporation$Sales Cr_Memo Line] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]
INNER JOIN dbo.[TKA Canada Corporation$Sales Cr_Memo Header] h ON h.[No_] = c1.[Document No_]
LEFT OUTER JOIN dbo.[TKA Canada Corporation$Contact] cn on cn.[No_] = c1.[Contact No_]
LEFT OUTER JOIN dbo.[TKA Canada Corporation$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[TKA Canada Corporation$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >= '2018/01/01'
AND c1.[Quantity] <>0 AND c1.[Type] = 1 AND c1.[No_] LIKE '6%'
UNION ALL
SELECT 'TKA Europe' as [CName],
           'CreditMemo' as [DocumentType],
           c1.[Document No_] as [DocNo],
		h.[Document Date],
        h.[Original So No] as [Sales Order No],
c1.[Sell-to Customer No_],c1.[Contact No_],h.[Salesperson Code],cn.[Country_Region Code],
           c1.[Line No_] as [LineNo],
		   c1.[Amt_ Excl_ VAT (LCY)] * -1 as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Revenue' as [BucketType],
		   c1.[Amt_ Excl_ VAT (LCY)] * -1 / ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[TKA Europe$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[TKA Europe$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country],
									ISNULL((SELECT cr.[Name] FROM dbo.[TKA Europe$Country_Region] cr WHERE cr.[Code] IN 
			(SELECT CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[TKA Europe$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity]*-1,
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			ISNULL(CASE
				WHEN h.[Payment Information] <> 6 THEN (
					CASE
						WHEN c1.[No_] IN ('5345', '5343') THEN 'Original KP'
						WHEN c1.[No_] IN ('5344') THEN 'Original FP'
						ELSE
							CASE
								WHEN c1.[KP No_] <> '' THEN 
									(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
												WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
											END
									FROM dbo.[TKA Europe$Sales Invoice Header] SH
									WHERE SH.[No_] = c1.[KP No_])
					
								ELSE  
									(SELECT CASE WHEN (c1.[Event Header] <> '' AND SH.[Old KP] = 1) THEN 'KPUSED'
												WHEN (c1.[Event Header] <> '' AND SH.[Flexi Pass] = 1) THEN 'FPUSED'
												ELSE 'STANDARD'
											END
									FROM dbo.[TKA Europe$Sales Cr_Memo Header] SH
									WHERE SH.[No_] = c1.[Document No_])
								END
							END)
				ELSE
					CASE
						WHEN c1.[KP No_] <> '' THEN 
							(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
									END
							FROM dbo.[TKA Europe$Sales Invoice Header] SH
							WHERE SH.[No_] = c1.[KP No_])
					
						ELSE  
							(SELECT CASE WHEN SH.[Old KP] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
										ELSE 'STANDARD'
									END
							FROM dbo.[TKA Europe$Sales Cr_Memo Header] SH
							WHERE SH.[No_] = c1.[Document No_])
						END
				END,'') AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[TKA Europe$Sales Cr_Memo Line] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]
INNER JOIN dbo.[TKA Europe$Sales Cr_Memo Header] h ON h.[No_] = c1.[Document No_]
LEFT OUTER JOIN dbo.[TKA Europe$Contact] cn on cn.[No_] = c1.[Contact No_]
LEFT OUTER JOIN dbo.[TKA Europe$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[TKA Europe$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >= '2018/01/01'
AND c1.[Quantity] <>0 AND c1.[Type] = 1 AND c1.[No_] LIKE '6%'
UNION ALL
SELECT 'TKA Hong Kong Ltd.' as [CName],
           'CreditMemo' as [DocumentType],
           c1.[Document No_] as [DocNo],
		 h.[Document Date],
         h.[Original So No] as [Sales Order No],
c1.[Sell-to Customer No_],c1.[Contact No_],h.[Salesperson Code],cn.[Country_Region Code],
           c1.[Line No_] as [LineNo],
		   c1.[Amt_ Excl_ VAT (LCY)] * -1 as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Revenue' as [BucketType],
		   c1.[Amt_ Excl_ VAT (LCY)] * -1 / ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[TKA Hong Kong Ltd_$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[TKA Hong Kong Ltd_$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country],
									ISNULL((SELECT cr.[Name] FROM dbo.[TKA Hong Kong Ltd_$Country_Region] cr WHERE cr.[Code] IN 
			(SELECT CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[TKA Hong Kong Ltd_$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity]*-1,
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			ISNULL(CASE
				WHEN h.[Payment Information] <> 6 THEN (
					CASE
						WHEN c1.[No_] IN ('5345', '5343') THEN 'Original KP'
						WHEN c1.[No_] IN ('5344') THEN 'Original FP'
						ELSE
							CASE
								WHEN c1.[KP No_] <> '' THEN 
									(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
												WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
											END
									FROM dbo.[TKA Hong Kong Ltd_$Sales Invoice Header] SH
									WHERE SH.[No_] = c1.[KP No_])
					
								ELSE  
									(SELECT CASE WHEN (c1.[Event Header] <> '' AND SH.[Old KP] = 1) THEN 'KPUSED'
												WHEN (c1.[Event Header] <> '' AND SH.[Flexi Pass] = 1) THEN 'FPUSED'
												ELSE 'STANDARD'
											END
									FROM dbo.[TKA Hong Kong Ltd_$Sales Cr_Memo Header] SH
									WHERE SH.[No_] = c1.[Document No_])
								END
							END)
				ELSE
					CASE
						WHEN c1.[KP No_] <> '' THEN 
							(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
									END
							FROM dbo.[TKA Hong Kong Ltd_$Sales Invoice Header] SH
							WHERE SH.[No_] = c1.[KP No_])
					
						ELSE  
							(SELECT CASE WHEN SH.[Old KP] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
										ELSE 'STANDARD'
									END
							FROM dbo.[TKA Hong Kong Ltd_$Sales Cr_Memo Header] SH
							WHERE SH.[No_] = c1.[Document No_])
						END
				END,'') AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[TKA Hong Kong Ltd_$Sales Cr_Memo Line] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]
INNER JOIN dbo.[TKA Hong Kong Ltd_$Sales Cr_Memo Header] h ON h.[No_] = c1.[Document No_]
LEFT OUTER JOIN dbo.[TKA Hong Kong Ltd_$Contact] cn on cn.[No_] = c1.[Contact No_]
LEFT OUTER JOIN dbo.[TKA Hong Kong Ltd_$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[TKA Hong Kong Ltd_$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >= '2018/01/01'
AND c1.[Quantity] <>0 AND c1.[Type] = 1 AND c1.[No_] LIKE '6%'
UNION ALL
SELECT 'TKA New Zealand Ltd.' as [CName],
           'CreditMemo' as [DocumentType],
           c1.[Document No_] as [DocNo],
		 h.[Document Date],
         h.[Original So No] as [Sales Order No],
c1.[Sell-to Customer No_],c1.[Contact No_],h.[Salesperson Code],cn.[Country_Region Code],
           c1.[Line No_] as [LineNo],
		   c1.[Amt_ Excl_ VAT (LCY)] * -1 as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Revenue' as [BucketType],
		   c1.[Amt_ Excl_ VAT (LCY)] * -1 / ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[TKA New Zealand Ltd_$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[TKA New Zealand Ltd_$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country],
									ISNULL((SELECT cr.[Name] FROM dbo.[TKA New Zealand Ltd_$Country_Region] cr WHERE cr.[Code] IN 
			(SELECT CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[TKA New Zealand Ltd_$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity]*-1,
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			ISNULL(CASE
				WHEN h.[Payment Information] <> 6 THEN (
					CASE
						WHEN c1.[No_] IN ('5345', '5343') THEN 'Original KP'
						WHEN c1.[No_] IN ('5344') THEN 'Original FP'
						ELSE
							CASE
								WHEN c1.[KP No_] <> '' THEN 
									(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
												WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
											END
									FROM dbo.[TKA New Zealand Ltd_$Sales Invoice Header] SH
									WHERE SH.[No_] = c1.[KP No_])
					
								ELSE  
									(SELECT CASE WHEN (c1.[Event Header] <> '' AND SH.[Old KP] = 1) THEN 'KPUSED'
												WHEN (c1.[Event Header] <> '' AND SH.[Flexi Pass] = 1) THEN 'FPUSED'
												ELSE 'STANDARD'
											END
									FROM dbo.[TKA New Zealand Ltd_$Sales Cr_Memo Header] SH
									WHERE SH.[No_] = c1.[Document No_])
								END
							END)
				ELSE
					CASE
						WHEN c1.[KP No_] <> '' THEN 
							(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
									END
							FROM dbo.[TKA New Zealand Ltd_$Sales Invoice Header] SH
							WHERE SH.[No_] = c1.[KP No_])
					
						ELSE  
							(SELECT CASE WHEN SH.[Old KP] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
										ELSE 'STANDARD'
									END
							FROM dbo.[TKA New Zealand Ltd_$Sales Cr_Memo Header] SH
							WHERE SH.[No_] = c1.[Document No_])
						END
				END,'') AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[TKA New Zealand Ltd_$Sales Cr_Memo Line] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]
INNER JOIN dbo.[TKA New Zealand Ltd_$Sales Cr_Memo Header] h ON h.[No_] = c1.[Document No_]
LEFT OUTER JOIN dbo.[TKA New Zealand Ltd_$Contact] cn on cn.[No_] = c1.[Contact No_]
LEFT OUTER JOIN dbo.[TKA New Zealand Ltd_$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[TKA New Zealand Ltd_$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >= '2018/01/01'
AND c1.[Quantity] <>0 AND c1.[Type] = 1 AND c1.[No_] LIKE '6%'
UNION ALL
SELECT 'TKA Singapore PTE Ltd.' as [CName],
           'CreditMemo' as [DocumentType],
           c1.[Document No_] as [DocNo],
		  h.[Document Date],
          h.[Original So No] as [Sales Order No],
c1.[Sell-to Customer No_],c1.[Contact No_],h.[Salesperson Code],cn.[Country_Region Code],
           c1.[Line No_] as [LineNo],
		   c1.[Amt_ Excl_ VAT (LCY)] * -1 as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Revenue' as [BucketType],
		   c1.[Amt_ Excl_ VAT (LCY)] * -1 / ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[TKA Singapore PTE Ltd_$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[TKA Singapore PTE Ltd_$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country],
									ISNULL((SELECT cr.[Name] FROM dbo.[TKA Singapore PTE Ltd_$Country_Region] cr WHERE cr.[Code] IN 
			(SELECT CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[TKA Singapore PTE Ltd_$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity]*-1,
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			ISNULL(CASE
				WHEN h.[Payment Information] <> 6 THEN (
					CASE
						WHEN c1.[No_] IN ('5345', '5343') THEN 'Original KP'
						WHEN c1.[No_] IN ('5344') THEN 'Original FP'
						ELSE
							CASE
								WHEN c1.[KP No_] <> '' THEN 
									(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
												WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
											END
									FROM dbo.[TKA Singapore PTE Ltd_$Sales Invoice Header] SH
									WHERE SH.[No_] = c1.[KP No_])
					
								ELSE  
									(SELECT CASE WHEN (c1.[Event Header] <> '' AND SH.[Old KP] = 1) THEN 'KPUSED'
												WHEN (c1.[Event Header] <> '' AND SH.[Flexi Pass] = 1) THEN 'FPUSED'
												ELSE 'STANDARD'
											END
									FROM dbo.[TKA Singapore PTE Ltd_$Sales Cr_Memo Header] SH
									WHERE SH.[No_] = c1.[Document No_])
								END
							END)
				ELSE
					CASE
						WHEN c1.[KP No_] <> '' THEN 
							(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
									END
							FROM dbo.[TKA Singapore PTE Ltd_$Sales Invoice Header] SH
							WHERE SH.[No_] = c1.[KP No_])
					
						ELSE  
							(SELECT CASE WHEN SH.[Old KP] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
										ELSE 'STANDARD'
									END
							FROM dbo.[TKA Singapore PTE Ltd_$Sales Cr_Memo Header] SH
							WHERE SH.[No_] = c1.[Document No_])
						END
				END,'') AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[TKA Singapore PTE Ltd_$Sales Cr_Memo Line] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]
INNER JOIN dbo.[TKA Singapore PTE Ltd_$Sales Cr_Memo Header] h ON h.[No_] = c1.[Document No_]
LEFT OUTER JOIN dbo.[TKA Singapore PTE Ltd_$Contact] cn on cn.[No_] = c1.[Contact No_]
LEFT OUTER JOIN dbo.[TKA Singapore PTE Ltd_$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[TKA Singapore PTE Ltd_$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >= '2018/01/01'
AND c1.[Quantity] <>0 AND c1.[Type] = 1 AND c1.[No_] LIKE '6%'
UNION ALL
--ITIL
SELECT 'ITIL Training Academy' as [CName],
           'CreditMemo' as [DocumentType],
           c1.[Document No_] as [DocNo],
		 h.[Document Date],
		  h.[Original So No] as [Sales Order No],
c1.[Sell-to Customer No_],c1.[Contact No_],h.[Salesperson Code],cn.[Country_Region Code],
           c1.[Line No_] as [LineNo],
		   c1.[Amt_ Excl_ VAT (LCY)] * -1 as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Revenue' as [BucketType],
		   c1.[Amt_ Excl_ VAT (LCY)] * -1 / ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[ITIL Training Academy$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[ITIL Training Academy$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country],
						ISNULL((SELECT cr.[Name] FROM dbo.[ITIL Training Academy$Country_Region] cr WHERE cr.[Code] IN 
			(SELECT CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[ITIL Training Academy$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity]*-1,
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			ISNULL(CASE
				WHEN h.[Payment Information] <> 6 THEN (
					CASE
						WHEN c1.[No_] IN ('5345', '5343') THEN 'Original KP'
						WHEN c1.[No_] IN ('5344') THEN 'Original FP'
						ELSE
							CASE
								WHEN c1.[KP No_] <> '' THEN 
									(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
												WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
											END
									FROM dbo.[ITIL Training Academy$Sales Invoice Header] SH
									WHERE SH.[No_] = c1.[KP No_])
					
								ELSE  
									(SELECT CASE WHEN (c1.[Event Header] <> '' AND SH.[Old KP] = 1) THEN 'KPUSED'
												WHEN (c1.[Event Header] <> '' AND SH.[Flexi Pass] = 1) THEN 'FPUSED'
												ELSE 'STANDARD'
											END
									FROM dbo.[ITIL Training Academy$Sales Cr_Memo Header] SH
									WHERE SH.[No_] = c1.[Document No_])
								END
							END)
				ELSE
					CASE
						WHEN c1.[KP No_] <> '' THEN 
							(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
									END
							FROM dbo.[ITIL Training Academy$Sales Invoice Header] SH
							WHERE SH.[No_] = c1.[KP No_])
					
						ELSE  
							(SELECT CASE WHEN SH.[Old KP] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
										ELSE 'STANDARD'
									END
							FROM dbo.[ITIL Training Academy$Sales Cr_Memo Header] SH
							WHERE SH.[No_] = c1.[Document No_])
						END
				END,'') AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[ITIL Training Academy$Sales Cr_Memo Line] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]
INNER JOIN dbo.[ITIL Training Academy$Sales Cr_Memo Header] h ON h.[No_] = c1.[Document No_]
LEFT OUTER JOIN dbo.[ITIL Training Academy$Contact] cn on cn.[No_] = c1.[Contact No_]
LEFT OUTER JOIN dbo.[ITIL Training Academy$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[ITIL Training Academy$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >=  '2018/01/01'
AND c1.[Quantity] <>0 AND c1.[Type] = 1 AND c1.[No_] LIKE '6%'

UNION ALL

--Pearce Mayfield Dubai
SELECT 'Pearce Mayfield Train Dubai' as [CName],
           'CreditMemo' as [DocumentType],
           c1.[Document No_] as [DocNo],
		 h.[Document Date],
		  h.[Original So No] as [Sales Order No],
c1.[Sell-to Customer No_],c1.[Contact No_],h.[Salesperson Code],cn.[Country_Region Code],
           c1.[Line No_] as [LineNo],
		   c1.[Amt_ Excl_ VAT (LCY)] * -1 as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Revenue' as [BucketType],
		   c1.[Amt_ Excl_ VAT (LCY)] * -1 / ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[Pearce Mayfield Train Dubai$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[Pearce Mayfield Train Dubai$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country],
						ISNULL((SELECT cr.[Name] FROM dbo.[Pearce Mayfield Train Dubai$Country_Region] cr WHERE cr.[Code] IN 
			(SELECT CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[Pearce Mayfield Train Dubai$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity]*-1,
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			ISNULL(CASE
				WHEN h.[Payment Information] <> 6 THEN (
					CASE
						WHEN c1.[No_] IN ('5345', '5343') THEN 'Original KP'
						WHEN c1.[No_] IN ('5344') THEN 'Original FP'
						ELSE
							CASE
								WHEN c1.[KP No_] <> '' THEN 
									(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
												WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
											END
									FROM dbo.[Pearce Mayfield Train Dubai$Sales Invoice Header] SH
									WHERE SH.[No_] = c1.[KP No_])
					
								ELSE  
									(SELECT CASE WHEN (c1.[Event Header] <> '' AND SH.[Old KP] = 1) THEN 'KPUSED'
												WHEN (c1.[Event Header] <> '' AND SH.[Flexi Pass] = 1) THEN 'FPUSED'
												ELSE 'STANDARD'
											END
									FROM dbo.[Pearce Mayfield Train Dubai$Sales Cr_Memo Header] SH
									WHERE SH.[No_] = c1.[Document No_])
								END
							END)
				ELSE
					CASE
						WHEN c1.[KP No_] <> '' THEN 
							(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
									END
							FROM dbo.[Pearce Mayfield Train Dubai$Sales Invoice Header] SH
							WHERE SH.[No_] = c1.[KP No_])
					
						ELSE  
							(SELECT CASE WHEN SH.[Old KP] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
										ELSE 'STANDARD'
									END
							FROM dbo.[Pearce Mayfield Train Dubai$Sales Cr_Memo Header] SH
							WHERE SH.[No_] = c1.[Document No_])
						END
				END,'') AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[Pearce Mayfield Train Dubai$Sales Cr_Memo Line] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]
INNER JOIN dbo.[Pearce Mayfield Train Dubai$Sales Cr_Memo Header] h ON h.[No_] = c1.[Document No_]
LEFT OUTER JOIN dbo.[Pearce Mayfield Train Dubai$Contact] cn on cn.[No_] = c1.[Contact No_]
LEFT OUTER JOIN dbo.[Pearce Mayfield Train Dubai$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[Pearce Mayfield Train Dubai$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >=  '2018/01/01'
AND c1.[Quantity] <>0 AND c1.[Type] = 1 AND c1.[No_] LIKE '6%'


UNION ALL -- NEW ENTERED
---TKA India
SELECT 'TKA India' as [CName],
           CASE
			WHEN c1.[MasterType] = 1 THEN 'Trainer'
			WHEN c1.[MasterType] = 2 THEN 'Venue'
			WHEN c1.[MasterType] = 3 THEN 'Exam'
			WHEN c1.[MasterType] IN (5,6,7) THEN 'Courseware'
			WHEN c1.[MasterType] = 8 THEN 'Manual'
			WHEN c1.[MasterType] = 9 THEN 'Travel'
			WHEN c1.[MasterType] = 11 THEN 'Invigilator'
			WHEN c1.[MasterType] IN (0,11,4) THEN 'Others'
		   END as [DocumentType],
           c1.[MasterCode] as [DocNo], '1753/01/01' as 'Document Date','' AS [Sales Order No],'' AS [Sell-to Customer No_], ''AS [Contact No_], '' AS [Salesperson Code], '' AS [Country_Region Code],
           c1.[Entry No_] as [LineNo],
		   c1.[Amount] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Actual' as [BucketType],
		   c1.[Amount] / ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[TKA India$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			e.[Country Code] AS [Country],
			ISNULL((SELECT cr.[Name] FROM dbo.[TKA India$Country_Region] cr WHERE cr.[Code] IN 
			(e.[Country Code])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			'ACTUAL' AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[TKA India$G_L Entry] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]

LEFT OUTER JOIN dbo.[TKA India$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[TKA India$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >=  '2018/01/01' AND c1.[Posting Date] >= '2018/04/01'
AND c1.[G_L Account No_] LIKE '8%' AND c1.[Event Header] <>''


UNION ALL
SELECT 'The Knowledge Academy Limited' as [CName],
           'Order' as [DocumentType],
           c1.[Document No_] as [DocNo],
		h.[Document Date],
        h.[Original So No] as [Sales Order No],
c1.[Sell-to Customer No_],c1.[Contact No_],h.[Salesperson Code],cn.[Country_Region Code],
           c1.[Line No_] as [LineNo],
		   c1.[Amt_ Excl_ VAT (LCY)] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Revenue' as [BucketType],
		   c1.[Amt_ Excl_ VAT (LCY)] / ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[The Knowledge Academy Limited$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[The Knowledge Academy Limited$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country],
									ISNULL((SELECT cr.[Name] FROM dbo.[The Knowledge Academy Limited$Country_Region] cr WHERE cr.[Code] IN 
			(SELECT CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[The Knowledge Academy Limited$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			ISNULL(CASE
				WHEN h.[Payment Information] <> 6 THEN (
					CASE
						WHEN c1.[No_] IN ('5345', '5343') THEN 'Original KP'
						WHEN c1.[No_] IN ('5344') THEN 'Original FP'
						ELSE
							CASE
								WHEN c1.[KP No_] <> '' THEN 
									(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
												WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
											END
									FROM dbo.[The Knowledge Academy Limited$Sales Invoice Header] SH
									WHERE SH.[No_] = c1.[KP No_])
					
								ELSE  
									(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
												WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
												ELSE 'STANDARD'
											END
									FROM dbo.[The Knowledge Academy Limited$Sales Header] SH
									WHERE SH.[No_] = c1.[Document No_])
								END
							END)
				ELSE
					CASE
						WHEN c1.[KP No_] <> '' THEN 
							(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
									END
							FROM dbo.[The Knowledge Academy Limited$Sales Invoice Header] SH
							WHERE SH.[No_] = c1.[KP No_])
					
						ELSE  
							(SELECT CASE WHEN (c1.[Event Header] <> '' AND SH.[Knowledge Pass] = 1) THEN 'KPUSED'
										WHEN (c1.[Event Header] <> '' AND SH.[Flexi Pass] = 1) THEN 'FPUSED'
										ELSE 'STANDARD'
									END
							FROM dbo.[The Knowledge Academy Limited$Sales Header] SH
							WHERE SH.[No_] = c1.[Document No_])
						END
				END,'') AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[The Knowledge Academy Limited$Sales Line] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]
INNER JOIN dbo.[The Knowledge Academy Limited$Sales Header] h ON h.[Document Type] = c1.[Document Type] AND h.[No_] = c1.[Document No_]
LEFT OUTER JOIN dbo.[The Knowledge Academy Limited$Contact] cn on cn.[No_] = c1.[Contact No_]
LEFT OUTER JOIN dbo.[The Knowledge Academy Limited$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[The Knowledge Academy Limited$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >=  '2018/01/01'
AND c1.[Document Type] = 1
AND c1.[Quantity Invoiced] =0 AND c1.[Type] = 1 AND c1.[No_] LIKE '6%'
UNION ALL
SELECT 'The Knowledge Academy Inc' as [CName],
           'Order' as [DocumentType],
           c1.[Document No_] as [DocNo],
		  h.[Document Date],
          h.[Original So No] as [Sales Order No],
c1.[Sell-to Customer No_],c1.[Contact No_],h.[Salesperson Code],cn.[Country_Region Code],
           c1.[Line No_] as [LineNo],
		   c1.[Amt_ Excl_ VAT (LCY)] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Revenue' as [BucketType],
		   c1.[Amt_ Excl_ VAT (LCY)] / ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[The Knowledge Academy Inc$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[The Knowledge Academy Inc$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country],
									ISNULL((SELECT cr.[Name] FROM dbo.[The Knowledge Academy Inc$Country_Region] cr WHERE cr.[Code] IN 
			(SELECT CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[The Knowledge Academy Inc$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			ISNULL(CASE
				WHEN h.[Payment Information] <> 6 THEN (
					CASE
						WHEN c1.[No_] IN ('5345', '5343') THEN 'Original KP'
						WHEN c1.[No_] IN ('5344') THEN 'Original FP'
						ELSE
							CASE
								WHEN c1.[KP No_] <> '' THEN 
									(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
												WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
											END
									FROM dbo.[The Knowledge Academy Inc$Sales Invoice Header] SH
									WHERE SH.[No_] = c1.[KP No_])
					
								ELSE  
									(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
												WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
												ELSE 'STANDARD'
											END
									FROM dbo.[The Knowledge Academy Inc$Sales Header] SH
									WHERE SH.[No_] = c1.[Document No_])
								END
							END)
				ELSE
					CASE
						WHEN c1.[KP No_] <> '' THEN 
							(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
									END
							FROM dbo.[The Knowledge Academy Inc$Sales Invoice Header] SH
							WHERE SH.[No_] = c1.[KP No_])
					
						ELSE  
							(SELECT CASE WHEN (c1.[Event Header] <> '' AND SH.[Knowledge Pass] = 1) THEN 'KPUSED'
										WHEN (c1.[Event Header] <> '' AND SH.[Flexi Pass] = 1) THEN 'FPUSED'
										ELSE 'STANDARD'
									END
							FROM dbo.[The Knowledge Academy Inc$Sales Header] SH
							WHERE SH.[No_] = c1.[Document No_])
						END
				END,'') AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[The Knowledge Academy Inc$Sales Line] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]
INNER JOIN dbo.[The Knowledge Academy Inc$Sales Header] h ON h.[Document Type] = c1.[Document Type] AND h.[No_] = c1.[Document No_]
LEFT OUTER JOIN dbo.[The Knowledge Academy Inc$Contact] cn on cn.[No_] = c1.[Contact No_]
LEFT OUTER JOIN dbo.[The Knowledge Academy Inc$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[The Knowledge Academy Inc$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >= '2018/01/01'
AND c1.[Document Type] = 1
AND c1.[Quantity Invoiced] =0 AND c1.[Type] = 1 AND c1.[No_] LIKE '6%'
UNION ALL
SELECT 'Best Practice Training Ltd.' as [CName],
           'Order' as [DocumentType],
           c1.[Document No_] as [DocNo],
		  h.[Document Date],
		  h.[Original So No] as [Sales Order No],
c1.[Sell-to Customer No_],c1.[Contact No_],h.[Salesperson Code],cn.[Country_Region Code],
           c1.[Line No_] as [LineNo],
		   c1.[Amt_ Excl_ VAT (LCY)] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Revenue' as [BucketType],
		   c1.[Amt_ Excl_ VAT (LCY)] / ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[Best Practice Training Ltd_$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[Best Practice Training Ltd_$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country],
									ISNULL((SELECT cr.[Name] FROM dbo.[Best Practice Training Ltd_$Country_Region] cr WHERE cr.[Code] IN 
			(SELECT CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[Best Practice Training Ltd_$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			ISNULL(CASE
				WHEN h.[Payment Information] <> 6 THEN (
					CASE
						WHEN c1.[No_] IN ('5345', '5343') THEN 'Original KP'
						WHEN c1.[No_] IN ('5344') THEN 'Original FP'
						ELSE
							CASE
								WHEN c1.[KP No_] <> '' THEN 
									(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
												WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
											END
									FROM dbo.[Best Practice Training Ltd_$Sales Invoice Header] SH
									WHERE SH.[No_] = c1.[KP No_])
					
								ELSE  
									(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
												WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
												ELSE 'STANDARD'
											END
									FROM dbo.[Best Practice Training Ltd_$Sales Header] SH
									WHERE SH.[No_] = c1.[Document No_])
								END
							END)
				ELSE
					CASE
						WHEN c1.[KP No_] <> '' THEN 
							(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
									END
							FROM dbo.[Best Practice Training Ltd_$Sales Invoice Header] SH
							WHERE SH.[No_] = c1.[KP No_])
					
						ELSE  
							(SELECT CASE WHEN (c1.[Event Header] <> '' AND SH.[Knowledge Pass] = 1) THEN 'KPUSED'
										WHEN (c1.[Event Header] <> '' AND SH.[Flexi Pass] = 1) THEN 'FPUSED'
										ELSE 'STANDARD'
									END
							FROM dbo.[Best Practice Training Ltd_$Sales Header] SH
							WHERE SH.[No_] = c1.[Document No_])
						END
				END,'') AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[Best Practice Training Ltd_$Sales Line] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]
INNER JOIN dbo.[Best Practice Training Ltd_$Sales Header] h ON h.[Document Type] = c1.[Document Type] AND h.[No_] = c1.[Document No_]
LEFT OUTER JOIN dbo.[Best Practice Training Ltd_$Contact] cn on cn.[No_] = c1.[Contact No_]
LEFT OUTER JOIN dbo.[Best Practice Training Ltd_$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[Best Practice Training Ltd_$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >= '2018/01/01'
AND c1.[Document Type] = 1
AND c1.[Quantity Invoiced] =0 AND c1.[Type] = 1 AND c1.[No_] LIKE '6%'
UNION ALL
SELECT 'Datrix Learning Services Ltd.' as [CName],
           'Order' as [DocumentType],
           c1.[Document No_] as [DocNo],
		   h.[Document Date],
           h.[Original So No] as [Sales Order No],
c1.[Sell-to Customer No_],c1.[Contact No_],h.[Salesperson Code],cn.[Country_Region Code],
           c1.[Line No_] as [LineNo],
		   c1.[Amt_ Excl_ VAT (LCY)] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Revenue' as [BucketType],
		   c1.[Amt_ Excl_ VAT (LCY)] / ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[Datrix Learning Services Ltd_$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[Datrix Learning Services Ltd_$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country],
									ISNULL((SELECT cr.[Name] FROM dbo.[Datrix Learning Services Ltd_$Country_Region] cr WHERE cr.[Code] IN 
			(SELECT CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[Datrix Learning Services Ltd_$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			ISNULL(CASE
				WHEN h.[Payment Information] <> 6 THEN (
					CASE
						WHEN c1.[No_] IN ('5345', '5343') THEN 'Original KP'
						WHEN c1.[No_] IN ('5344') THEN 'Original FP'
						ELSE
							CASE
								WHEN c1.[KP No_] <> '' THEN 
									(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
												WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
											END
									FROM dbo.[Datrix Learning Services Ltd_$Sales Invoice Header] SH
									WHERE SH.[No_] = c1.[KP No_])
					
								ELSE  
									(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
												WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
												ELSE 'STANDARD'
											END
									FROM dbo.[Datrix Learning Services Ltd_$Sales Header] SH
									WHERE SH.[No_] = c1.[Document No_])
								END
							END)
				ELSE
					CASE
						WHEN c1.[KP No_] <> '' THEN 
							(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
									END
							FROM dbo.[Datrix Learning Services Ltd_$Sales Invoice Header] SH
							WHERE SH.[No_] = c1.[KP No_])
					
						ELSE  
							(SELECT CASE WHEN (c1.[Event Header] <> '' AND SH.[Knowledge Pass] = 1) THEN 'KPUSED'
										WHEN (c1.[Event Header] <> '' AND SH.[Flexi Pass] = 1) THEN 'FPUSED'
										ELSE 'STANDARD'
									END
							FROM dbo.[Datrix Learning Services Ltd_$Sales Header] SH
							WHERE SH.[No_] = c1.[Document No_])
						END
				END,'') AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[Datrix Learning Services Ltd_$Sales Line] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]
INNER JOIN dbo.[Datrix Learning Services Ltd_$Sales Header] h ON h.[Document Type] = c1.[Document Type] AND h.[No_] = c1.[Document No_]
LEFT OUTER JOIN dbo.[Datrix Learning Services Ltd_$Contact] cn on cn.[No_] = c1.[Contact No_]
LEFT OUTER JOIN dbo.[Datrix Learning Services Ltd_$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[Datrix Learning Services Ltd_$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >= '2018/01/01'
AND c1.[Document Type] = 1
AND c1.[Quantity Invoiced] =0 AND c1.[Type] = 1 AND c1.[No_] LIKE '6%'
UNION ALL
SELECT 'Pearce Mayfield Training Ltd' as [CName],
           'Order' as [DocumentType],
           c1.[Document No_] as [DocNo],
		 h.[Document Date],
         h.[Original So No] as [Sales Order No],
c1.[Sell-to Customer No_],c1.[Contact No_],h.[Salesperson Code],cn.[Country_Region Code],
           c1.[Line No_] as [LineNo],
		   c1.[Amt_ Excl_ VAT (LCY)] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Revenue' as [BucketType],
		   c1.[Amt_ Excl_ VAT (LCY)] / ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[Pearce Mayfield Training Ltd$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[Pearce Mayfield Training Ltd$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country],
									ISNULL((SELECT cr.[Name] FROM dbo.[Pearce Mayfield Training Ltd$Country_Region] cr WHERE cr.[Code] IN 
			(SELECT CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[Pearce Mayfield Training Ltd$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			ISNULL(CASE
				WHEN h.[Payment Information] <> 6 THEN (
					CASE
						WHEN c1.[No_] IN ('5345', '5343') THEN 'Original KP'
						WHEN c1.[No_] IN ('5344') THEN 'Original FP'
						ELSE
							CASE
								WHEN c1.[KP No_] <> '' THEN 
									(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
												WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
											END
									FROM dbo.[Pearce Mayfield Training Ltd$Sales Invoice Header] SH
									WHERE SH.[No_] = c1.[KP No_])
					
								ELSE  
									(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
												WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
												ELSE 'STANDARD'
											END
									FROM dbo.[Pearce Mayfield Training Ltd$Sales Header] SH
									WHERE SH.[No_] = c1.[Document No_])
								END
							END)
				ELSE
					CASE
						WHEN c1.[KP No_] <> '' THEN 
							(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
									END
							FROM dbo.[Pearce Mayfield Training Ltd$Sales Invoice Header] SH
							WHERE SH.[No_] = c1.[KP No_])
					
						ELSE  
							(SELECT CASE WHEN (c1.[Event Header] <> '' AND SH.[Knowledge Pass] = 1) THEN 'KPUSED'
										WHEN (c1.[Event Header] <> '' AND SH.[Flexi Pass] = 1) THEN 'FPUSED'
										ELSE 'STANDARD'
									END
							FROM dbo.[Pearce Mayfield Training Ltd$Sales Header] SH
							WHERE SH.[No_] = c1.[Document No_])
						END
				END,'') AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[Pearce Mayfield Training Ltd$Sales Line] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]
INNER JOIN dbo.[Pearce Mayfield Training Ltd$Sales Header] h ON h.[Document Type] = c1.[Document Type] AND h.[No_] = c1.[Document No_]
LEFT OUTER JOIN dbo.[Pearce Mayfield Training Ltd$Contact] cn on cn.[No_] = c1.[Contact No_]
LEFT OUTER JOIN dbo.[Pearce Mayfield Training Ltd$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[Pearce Mayfield Training Ltd$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >= '2018/01/01'
AND c1.[Document Type] = 1
AND c1.[Quantity Invoiced] =0 AND c1.[Type] = 1 AND c1.[No_] LIKE '6%'
UNION ALL
SELECT 'Pentagon Leisure Services Ltd' as [CName],
           'Order' as [DocumentType],
           c1.[Document No_] as [DocNo],
		  h.[Document Date],
          h.[Original So No] as [Sales Order No],
c1.[Sell-to Customer No_],c1.[Contact No_],h.[Salesperson Code],cn.[Country_Region Code],
           c1.[Line No_] as [LineNo],
		   c1.[Amt_ Excl_ VAT (LCY)] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Revenue' as [BucketType],
		   c1.[Amt_ Excl_ VAT (LCY)] / ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[Pentagon Leisure Services Ltd$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[Pentagon Leisure Services Ltd$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country],
									ISNULL((SELECT cr.[Name] FROM dbo.[Pentagon Leisure Services Ltd$Country_Region] cr WHERE cr.[Code] IN 
			(SELECT CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[Pentagon Leisure Services Ltd$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			ISNULL(CASE
				WHEN h.[Payment Information] <> 6 THEN (
					CASE
						WHEN c1.[No_] IN ('5345', '5343') THEN 'Original KP'
						WHEN c1.[No_] IN ('5344') THEN 'Original FP'
						ELSE
							CASE
								WHEN c1.[KP No_] <> '' THEN 
									(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
												WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
											END
									FROM dbo.[Pentagon Leisure Services Ltd$Sales Invoice Header] SH
									WHERE SH.[No_] = c1.[KP No_])
					
								ELSE  
									(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
												WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
												ELSE 'STANDARD'
											END
									FROM dbo.[Pentagon Leisure Services Ltd$Sales Header] SH
									WHERE SH.[No_] = c1.[Document No_])
								END
							END)
				ELSE
					CASE
						WHEN c1.[KP No_] <> '' THEN 
							(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
									END
							FROM dbo.[Pentagon Leisure Services Ltd$Sales Invoice Header] SH
							WHERE SH.[No_] = c1.[KP No_])
					
						ELSE  
							(SELECT CASE WHEN (c1.[Event Header] <> '' AND SH.[Knowledge Pass] = 1) THEN 'KPUSED'
										WHEN (c1.[Event Header] <> '' AND SH.[Flexi Pass] = 1) THEN 'FPUSED'
										ELSE 'STANDARD'
									END
							FROM dbo.[Pentagon Leisure Services Ltd$Sales Header] SH
							WHERE SH.[No_] = c1.[Document No_])
						END
				END,'') AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[Pentagon Leisure Services Ltd$Sales Line] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]
INNER JOIN dbo.[Pentagon Leisure Services Ltd$Sales Header] h ON h.[Document Type] = c1.[Document Type] AND h.[No_] = c1.[Document No_]
LEFT OUTER JOIN dbo.[Pentagon Leisure Services Ltd$Contact] cn on cn.[No_] = c1.[Contact No_]
LEFT OUTER JOIN dbo.[Pentagon Leisure Services Ltd$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[Pentagon Leisure Services Ltd$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >= '2018/01/01'
AND c1.[Document Type] = 1
AND c1.[Quantity Invoiced] =0 AND c1.[Type] = 1 AND c1.[No_] LIKE '6%'
UNION ALL
SELECT 'Silicon Beach Training' as [CName],
           'Order' as [DocumentType],
           c1.[Document No_] as [DocNo],
		  h.[Document Date],
		   h.[Original So No] as [Sales Order No],
c1.[Sell-to Customer No_],c1.[Contact No_],h.[Salesperson Code],cn.[Country_Region Code],
           c1.[Line No_] as [LineNo],
		   c1.[Amt_ Excl_ VAT (LCY)] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Revenue' as [BucketType],
		   c1.[Amt_ Excl_ VAT (LCY)] / ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[Silicon Beach Training$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[Silicon Beach Training$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country],
									ISNULL((SELECT cr.[Name] FROM dbo.[Silicon Beach Training$Country_Region] cr WHERE cr.[Code] IN 
			(SELECT CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[Silicon Beach Training$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			ISNULL(CASE
				WHEN h.[Payment Information] <> 6 THEN (
					CASE
						WHEN c1.[No_] IN ('5345', '5343') THEN 'Original KP'
						WHEN c1.[No_] IN ('5344') THEN 'Original FP'
						ELSE
							CASE
								WHEN c1.[KP No_] <> '' THEN 
									(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
												WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
											END
									FROM dbo.[Silicon Beach Training$Sales Invoice Header] SH
									WHERE SH.[No_] = c1.[KP No_])
					
								ELSE  
									(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
												WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
												ELSE 'STANDARD'
											END
									FROM dbo.[Silicon Beach Training$Sales Header] SH
									WHERE SH.[No_] = c1.[Document No_])
								END
							END)
				ELSE
					CASE
						WHEN c1.[KP No_] <> '' THEN 
							(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
									END
							FROM dbo.[Silicon Beach Training$Sales Invoice Header] SH
							WHERE SH.[No_] = c1.[KP No_])
					
						ELSE  
							(SELECT CASE WHEN (c1.[Event Header] <> '' AND SH.[Knowledge Pass] = 1) THEN 'KPUSED'
										WHEN (c1.[Event Header] <> '' AND SH.[Flexi Pass] = 1) THEN 'FPUSED'
										ELSE 'STANDARD'
									END
							FROM dbo.[Silicon Beach Training$Sales Header] SH
							WHERE SH.[No_] = c1.[Document No_])
						END
				END,'') AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[Silicon Beach Training$Sales Line] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]
INNER JOIN dbo.[Silicon Beach Training$Sales Header] h ON h.[Document Type] = c1.[Document Type] AND h.[No_] = c1.[Document No_]
LEFT OUTER JOIN dbo.[Silicon Beach Training$Contact] cn on cn.[No_] = c1.[Contact No_]
LEFT OUTER JOIN dbo.[Silicon Beach Training$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[Silicon Beach Training$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >= '2018/01/01'
AND c1.[Document Type] = 1
AND c1.[Quantity Invoiced] =0 AND c1.[Type] = 1 AND c1.[No_] LIKE '6%'
UNION ALL
SELECT 'The Knowledge Academy Pty Ltd.' as [CName],
           'Order' as [DocumentType],
           c1.[Document No_] as [DocNo],
		 h.[Document Date],
		  h.[Original So No] as [Sales Order No],
c1.[Sell-to Customer No_],c1.[Contact No_],h.[Salesperson Code],cn.[Country_Region Code],
           c1.[Line No_] as [LineNo],
		   c1.[Amt_ Excl_ VAT (LCY)] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Revenue' as [BucketType],
		   c1.[Amt_ Excl_ VAT (LCY)] / ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[The Knowledge Academy Pty Ltd_$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[The Knowledge Academy Pty Ltd_$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country],
									ISNULL((SELECT cr.[Name] FROM dbo.[The Knowledge Academy Pty Ltd_$Country_Region] cr WHERE cr.[Code] IN 
			(SELECT CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[The Knowledge Academy Pty Ltd_$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			ISNULL(CASE
				WHEN h.[Payment Information] <> 6 THEN (
					CASE
						WHEN c1.[No_] IN ('5345', '5343') THEN 'Original KP'
						WHEN c1.[No_] IN ('5344') THEN 'Original FP'
						ELSE
							CASE
								WHEN c1.[KP No_] <> '' THEN 
									(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
												WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
											END
									FROM dbo.[The Knowledge Academy Pty Ltd_$Sales Invoice Header] SH
									WHERE SH.[No_] = c1.[KP No_])
					
								ELSE  
									(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
												WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
												ELSE 'STANDARD'
											END
									FROM dbo.[The Knowledge Academy Pty Ltd_$Sales Header] SH
									WHERE SH.[No_] = c1.[Document No_])
								END
							END)
				ELSE
					CASE
						WHEN c1.[KP No_] <> '' THEN 
							(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
									END
							FROM dbo.[The Knowledge Academy Pty Ltd_$Sales Invoice Header] SH
							WHERE SH.[No_] = c1.[KP No_])
					
						ELSE  
							(SELECT CASE WHEN (c1.[Event Header] <> '' AND SH.[Knowledge Pass] = 1) THEN 'KPUSED'
										WHEN (c1.[Event Header] <> '' AND SH.[Flexi Pass] = 1) THEN 'FPUSED'
										ELSE 'STANDARD'
									END
							FROM dbo.[The Knowledge Academy Pty Ltd_$Sales Header] SH
							WHERE SH.[No_] = c1.[Document No_])
						END
				END,'') AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[The Knowledge Academy Pty Ltd_$Sales Line] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]
INNER JOIN dbo.[The Knowledge Academy Pty Ltd_$Sales Header] h ON h.[Document Type] = c1.[Document Type] AND h.[No_] = c1.[Document No_]
LEFT OUTER JOIN dbo.[The Knowledge Academy Pty Ltd_$Contact] cn on cn.[No_] = c1.[Contact No_]
LEFT OUTER JOIN dbo.[The Knowledge Academy Pty Ltd_$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[The Knowledge Academy Pty Ltd_$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >= '2018/01/01'
AND c1.[Document Type] = 1
AND c1.[Quantity Invoiced] =0 AND c1.[Type] = 1 AND c1.[No_] LIKE '6%'
UNION ALL
SELECT 'The Knowledge Academy SA' as [CName],
           'Order' as [DocumentType],
           c1.[Document No_] as [DocNo],
		 h.[Document Date],
		  h.[Original So No] as [Sales Order No],
c1.[Sell-to Customer No_],c1.[Contact No_],h.[Salesperson Code],cn.[Country_Region Code],
           c1.[Line No_] as [LineNo],
		   c1.[Amt_ Excl_ VAT (LCY)] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Revenue' as [BucketType],
		   c1.[Amt_ Excl_ VAT (LCY)] / ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[The Knowledge Academy SA$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[The Knowledge Academy SA$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country],
									ISNULL((SELECT cr.[Name] FROM dbo.[The Knowledge Academy SA$Country_Region] cr WHERE cr.[Code] IN 
			(SELECT CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[The Knowledge Academy SA$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			ISNULL(CASE
				WHEN h.[Payment Information] <> 6 THEN (
					CASE
						WHEN c1.[No_] IN ('5345', '5343') THEN 'Original KP'
						WHEN c1.[No_] IN ('5344') THEN 'Original FP'
						ELSE
							CASE
								WHEN c1.[KP No_] <> '' THEN 
									(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
												WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
											END
									FROM dbo.[The Knowledge Academy SA$Sales Invoice Header] SH
									WHERE SH.[No_] = c1.[KP No_])
					
								ELSE  
									(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
												WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
												ELSE 'STANDARD'
											END
									FROM dbo.[The Knowledge Academy SA$Sales Header] SH
									WHERE SH.[No_] = c1.[Document No_])
								END
							END)
				ELSE
					CASE
						WHEN c1.[KP No_] <> '' THEN 
							(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
									END
							FROM dbo.[The Knowledge Academy SA$Sales Invoice Header] SH
							WHERE SH.[No_] = c1.[KP No_])
					
						ELSE  
							(SELECT CASE WHEN (c1.[Event Header] <> '' AND SH.[Knowledge Pass] = 1) THEN 'KPUSED'
										WHEN (c1.[Event Header] <> '' AND SH.[Flexi Pass] = 1) THEN 'FPUSED'
										ELSE 'STANDARD'
									END
							FROM dbo.[The Knowledge Academy SA$Sales Header] SH
							WHERE SH.[No_] = c1.[Document No_])
						END
				END,'') AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[The Knowledge Academy SA$Sales Line] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]
INNER JOIN dbo.[The Knowledge Academy SA$Sales Header] h ON h.[Document Type] = c1.[Document Type] AND h.[No_] = c1.[Document No_]
LEFT OUTER JOIN dbo.[The Knowledge Academy SA$Contact] cn on cn.[No_] = c1.[Contact No_]
LEFT OUTER JOIN dbo.[The Knowledge Academy SA$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[The Knowledge Academy SA$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >= '2018/01/01'
AND c1.[Document Type] = 1
AND c1.[Quantity Invoiced] =0 AND c1.[Type] = 1 AND c1.[No_] LIKE '6%'
UNION ALL
SELECT 'TKA Canada Corporation' as [CName],
           'Order' as [DocumentType],
           c1.[Document No_] as [DocNo],
		 h.[Document Date],
		  h.[Original So No] as [Sales Order No],
c1.[Sell-to Customer No_],c1.[Contact No_],h.[Salesperson Code],cn.[Country_Region Code],
           c1.[Line No_] as [LineNo],
		   c1.[Amt_ Excl_ VAT (LCY)] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Revenue' as [BucketType],
		   c1.[Amt_ Excl_ VAT (LCY)] / ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[TKA Canada Corporation$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[TKA Canada Corporation$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country],
									ISNULL((SELECT cr.[Name] FROM dbo.[TKA Canada Corporation$Country_Region] cr WHERE cr.[Code] IN 
			(SELECT CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[TKA Canada Corporation$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			ISNULL(CASE
				WHEN h.[Payment Information] <> 6 THEN (
					CASE
						WHEN c1.[No_] IN ('5345', '5343') THEN 'Original KP'
						WHEN c1.[No_] IN ('5344') THEN 'Original FP'
						ELSE
							CASE
								WHEN c1.[KP No_] <> '' THEN 
									(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
												WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
											END
									FROM dbo.[TKA Canada Corporation$Sales Invoice Header] SH
									WHERE SH.[No_] = c1.[KP No_])
					
								ELSE  
									(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
												WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
												ELSE 'STANDARD'
											END
									FROM dbo.[TKA Canada Corporation$Sales Header] SH
									WHERE SH.[No_] = c1.[Document No_])
								END
							END)
				ELSE
					CASE
						WHEN c1.[KP No_] <> '' THEN 
							(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
									END
							FROM dbo.[TKA Canada Corporation$Sales Invoice Header] SH
							WHERE SH.[No_] = c1.[KP No_])
					
						ELSE  
							(SELECT CASE WHEN (c1.[Event Header] <> '' AND SH.[Knowledge Pass] = 1) THEN 'KPUSED'
										WHEN (c1.[Event Header] <> '' AND SH.[Flexi Pass] = 1) THEN 'FPUSED'
										ELSE 'STANDARD'
									END
							FROM dbo.[TKA Canada Corporation$Sales Header] SH
							WHERE SH.[No_] = c1.[Document No_])
						END
				END,'') AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[TKA Canada Corporation$Sales Line] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]
INNER JOIN dbo.[TKA Canada Corporation$Sales Header] h ON h.[Document Type] = c1.[Document Type] AND h.[No_] = c1.[Document No_]
LEFT OUTER JOIN dbo.[TKA Canada Corporation$Contact] cn on cn.[No_] = c1.[Contact No_]
LEFT OUTER JOIN dbo.[TKA Canada Corporation$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[TKA Canada Corporation$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >= '2018/01/01'
AND c1.[Document Type] = 1
AND c1.[Quantity Invoiced] =0 AND c1.[Type] = 1 AND c1.[No_] LIKE '6%'
UNION ALL
SELECT 'TKA Europe' as [CName],
           'Order' as [DocumentType],
           c1.[Document No_] as [DocNo],
		h.[Document Date],
		 h.[Original So No] as [Sales Order No],
c1.[Sell-to Customer No_],c1.[Contact No_],h.[Salesperson Code],cn.[Country_Region Code],
           c1.[Line No_] as [LineNo],
		   c1.[Amt_ Excl_ VAT (LCY)] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Revenue' as [BucketType],
		   c1.[Amt_ Excl_ VAT (LCY)] / ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[TKA Europe$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[TKA Europe$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country],
									ISNULL((SELECT cr.[Name] FROM dbo.[TKA Europe$Country_Region] cr WHERE cr.[Code] IN 
			(SELECT CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[TKA Europe$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			ISNULL(CASE
				WHEN h.[Payment Information] <> 6 THEN (
					CASE
						WHEN c1.[No_] IN ('5345', '5343') THEN 'Original KP'
						WHEN c1.[No_] IN ('5344') THEN 'Original FP'
						ELSE
							CASE
								WHEN c1.[KP No_] <> '' THEN 
									(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
												WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
											END
									FROM dbo.[TKA Europe$Sales Invoice Header] SH
									WHERE SH.[No_] = c1.[KP No_])
					
								ELSE  
									(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
												WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
												ELSE 'STANDARD'
											END
									FROM dbo.[TKA Europe$Sales Header] SH
									WHERE SH.[No_] = c1.[Document No_])
								END
							END)
				ELSE
					CASE
						WHEN c1.[KP No_] <> '' THEN 
							(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
									END
							FROM dbo.[TKA Europe$Sales Invoice Header] SH
							WHERE SH.[No_] = c1.[KP No_])
					
						ELSE  
							(SELECT CASE WHEN (c1.[Event Header] <> '' AND SH.[Knowledge Pass] = 1) THEN 'KPUSED'
										WHEN (c1.[Event Header] <> '' AND SH.[Flexi Pass] = 1) THEN 'FPUSED'
										ELSE 'STANDARD'
									END
							FROM dbo.[TKA Europe$Sales Header] SH
							WHERE SH.[No_] = c1.[Document No_])
						END
				END,'') AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[TKA Europe$Sales Line] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]
INNER JOIN dbo.[TKA Europe$Sales Header] h ON h.[Document Type] = c1.[Document Type] AND h.[No_] = c1.[Document No_]
LEFT OUTER JOIN dbo.[TKA Europe$Contact] cn on cn.[No_] = c1.[Contact No_]
LEFT OUTER JOIN dbo.[TKA Europe$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[TKA Europe$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >= '2018/01/01'
AND c1.[Document Type] = 1
AND c1.[Quantity Invoiced] =0 AND c1.[Type] = 1 AND c1.[No_] LIKE '6%'
UNION ALL
SELECT 'TKA Hong Kong Ltd.' as [CName],
           'Order' as [DocumentType],
           c1.[Document No_] as [DocNo],
		h.[Document Date],
		 h.[Original So No] as [Sales Order No],
c1.[Sell-to Customer No_],c1.[Contact No_],h.[Salesperson Code],cn.[Country_Region Code],
           c1.[Line No_] as [LineNo],
		   c1.[Amt_ Excl_ VAT (LCY)] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Revenue' as [BucketType],
		   c1.[Amt_ Excl_ VAT (LCY)] / ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[TKA Hong Kong Ltd_$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[TKA Hong Kong Ltd_$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country],
									ISNULL((SELECT cr.[Name] FROM dbo.[TKA Hong Kong Ltd_$Country_Region] cr WHERE cr.[Code] IN 
			(SELECT CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[TKA Hong Kong Ltd_$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			ISNULL(CASE
				WHEN h.[Payment Information] <> 6 THEN (
					CASE
						WHEN c1.[No_] IN ('5345', '5343') THEN 'Original KP'
						WHEN c1.[No_] IN ('5344') THEN 'Original FP'
						ELSE
							CASE
								WHEN c1.[KP No_] <> '' THEN 
									(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
												WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
											END
									FROM dbo.[TKA Hong Kong Ltd_$Sales Invoice Header] SH
									WHERE SH.[No_] = c1.[KP No_])
					
								ELSE  
									(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
												WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
												ELSE 'STANDARD'
											END
									FROM dbo.[TKA Hong Kong Ltd_$Sales Header] SH
									WHERE SH.[No_] = c1.[Document No_])
								END
							END)
				ELSE
					CASE
						WHEN c1.[KP No_] <> '' THEN 
							(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
									END
							FROM dbo.[TKA Hong Kong Ltd_$Sales Invoice Header] SH
							WHERE SH.[No_] = c1.[KP No_])
					
						ELSE  
							(SELECT CASE WHEN (c1.[Event Header] <> '' AND SH.[Knowledge Pass] = 1) THEN 'KPUSED'
										WHEN (c1.[Event Header] <> '' AND SH.[Flexi Pass] = 1) THEN 'FPUSED'
										ELSE 'STANDARD'
									END
							FROM dbo.[TKA Hong Kong Ltd_$Sales Header] SH
							WHERE SH.[No_] = c1.[Document No_])
						END
				END,'') AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[TKA Hong Kong Ltd_$Sales Line] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]
INNER JOIN dbo.[TKA Hong Kong Ltd_$Sales Header] h ON h.[Document Type] = c1.[Document Type] AND h.[No_] = c1.[Document No_]
LEFT OUTER JOIN dbo.[TKA Hong Kong Ltd_$Contact] cn on cn.[No_] = c1.[Contact No_]
LEFT OUTER JOIN dbo.[TKA Hong Kong Ltd_$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[TKA Hong Kong Ltd_$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >= '2018/01/01'
AND c1.[Document Type] = 1
AND c1.[Quantity Invoiced] =0 AND c1.[Type] = 1 AND c1.[No_] LIKE '6%'
UNION ALL
SELECT 'TKA New Zealand Ltd.' as [CName],
           'Order' as [DocumentType],
           c1.[Document No_] as [DocNo],
		h.[Document Date],
		 h.[Original So No] as [Sales Order No],
c1.[Sell-to Customer No_],c1.[Contact No_],h.[Salesperson Code],cn.[Country_Region Code],
           c1.[Line No_] as [LineNo],
		   c1.[Amt_ Excl_ VAT (LCY)] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Revenue' as [BucketType],
		   c1.[Amt_ Excl_ VAT (LCY)] / ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[TKA New Zealand Ltd_$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[TKA New Zealand Ltd_$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country],
									ISNULL((SELECT cr.[Name] FROM dbo.[TKA New Zealand Ltd_$Country_Region] cr WHERE cr.[Code] IN 
			(SELECT CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[TKA New Zealand Ltd_$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			ISNULL(CASE
				WHEN h.[Payment Information] <> 6 THEN (
					CASE
						WHEN c1.[No_] IN ('5345', '5343') THEN 'Original KP'
						WHEN c1.[No_] IN ('5344') THEN 'Original FP'
						ELSE
							CASE
								WHEN c1.[KP No_] <> '' THEN 
									(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
												WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
											END
									FROM dbo.[TKA New Zealand Ltd_$Sales Invoice Header] SH
									WHERE SH.[No_] = c1.[KP No_])
					
								ELSE  
									(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
												WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
												ELSE 'STANDARD'
											END
									FROM dbo.[TKA New Zealand Ltd_$Sales Header] SH
									WHERE SH.[No_] = c1.[Document No_])
								END
							END)
				ELSE
					CASE
						WHEN c1.[KP No_] <> '' THEN 
							(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
									END
							FROM dbo.[TKA New Zealand Ltd_$Sales Invoice Header] SH
							WHERE SH.[No_] = c1.[KP No_])
					
						ELSE  
							(SELECT CASE WHEN (c1.[Event Header] <> '' AND SH.[Knowledge Pass] = 1) THEN 'KPUSED'
										WHEN (c1.[Event Header] <> '' AND SH.[Flexi Pass] = 1) THEN 'FPUSED'
										ELSE 'STANDARD'
									END
							FROM dbo.[TKA New Zealand Ltd_$Sales Header] SH
							WHERE SH.[No_] = c1.[Document No_])
						END
				END,'') AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[TKA New Zealand Ltd_$Sales Line] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]
INNER JOIN dbo.[TKA New Zealand Ltd_$Sales Header] h ON h.[Document Type] = c1.[Document Type] AND h.[No_] = c1.[Document No_]
LEFT OUTER JOIN dbo.[TKA New Zealand Ltd_$Contact] cn on cn.[No_] = c1.[Contact No_]
LEFT OUTER JOIN dbo.[TKA New Zealand Ltd_$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[TKA New Zealand Ltd_$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >= '2018/01/01'
AND c1.[Document Type] = 1
AND c1.[Quantity Invoiced] =0 AND c1.[Type] = 1 AND c1.[No_] LIKE '6%'
UNION ALL
SELECT 'TKA Singapore PTE Ltd.' as [CName],
           'Order' as [DocumentType],
           c1.[Document No_] as [DocNo],
		h.[Document Date],
		 h.[Original So No] as [Sales Order No],
c1.[Sell-to Customer No_],c1.[Contact No_],h.[Salesperson Code],cn.[Country_Region Code],
           c1.[Line No_] as [LineNo],
		   c1.[Amt_ Excl_ VAT (LCY)] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Revenue' as [BucketType],
		   c1.[Amt_ Excl_ VAT (LCY)] / ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[TKA Singapore PTE Ltd_$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[TKA Singapore PTE Ltd_$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country],
									ISNULL((SELECT cr.[Name] FROM dbo.[TKA Singapore PTE Ltd_$Country_Region] cr WHERE cr.[Code] IN 
			(SELECT CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[TKA Singapore PTE Ltd_$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			ISNULL(CASE
				WHEN h.[Payment Information] <> 6 THEN (
					CASE
						WHEN c1.[No_] IN ('5345', '5343') THEN 'Original KP'
						WHEN c1.[No_] IN ('5344') THEN 'Original FP'
						ELSE
							CASE
								WHEN c1.[KP No_] <> '' THEN 
									(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
												WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
											END
									FROM dbo.[TKA Singapore PTE Ltd_$Sales Invoice Header] SH
									WHERE SH.[No_] = c1.[KP No_])
					
								ELSE  
									(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
												WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
												ELSE 'STANDARD'
											END
									FROM dbo.[TKA Singapore PTE Ltd_$Sales Header] SH
									WHERE SH.[No_] = c1.[Document No_])
								END
							END)
				ELSE
					CASE
						WHEN c1.[KP No_] <> '' THEN 
							(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
									END
							FROM dbo.[TKA Singapore PTE Ltd_$Sales Invoice Header] SH
							WHERE SH.[No_] = c1.[KP No_])
					
						ELSE  
							(SELECT CASE WHEN (c1.[Event Header] <> '' AND SH.[Knowledge Pass] = 1) THEN 'KPUSED'
										WHEN (c1.[Event Header] <> '' AND SH.[Flexi Pass] = 1) THEN 'FPUSED'
										ELSE 'STANDARD'
									END
							FROM dbo.[TKA Singapore PTE Ltd_$Sales Header] SH
							WHERE SH.[No_] = c1.[Document No_])
						END
				END,'') AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[TKA Singapore PTE Ltd_$Sales Line] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]
INNER JOIN dbo.[TKA Singapore PTE Ltd_$Sales Header] h ON h.[Document Type] = c1.[Document Type] AND h.[No_] = c1.[Document No_]
LEFT OUTER JOIN dbo.[TKA Singapore PTE Ltd_$Contact] cn on cn.[No_] = c1.[Contact No_]
LEFT OUTER JOIN dbo.[TKA Singapore PTE Ltd_$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[TKA Singapore PTE Ltd_$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >= '2018/01/01'
AND c1.[Document Type] = 1
AND c1.[Quantity Invoiced] =0 AND c1.[Type] = 1 AND c1.[No_] LIKE '6%'
UNION ALL

--ITIL
SELECT 'ITIL Training Academy' as [CName],
           'Order' as [DocumentType],
           c1.[Document No_] as [DocNo],
		h.[Document Date],
        h.[Original So No] as [Sales Order No],
c1.[Sell-to Customer No_],c1.[Contact No_],h.[Salesperson Code],cn.[Country_Region Code],
           c1.[Line No_] as [LineNo],
		   c1.[Amt_ Excl_ VAT (LCY)] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Revenue' as [BucketType],
		   c1.[Amt_ Excl_ VAT (LCY)] / ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[ITIL Training Academy$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[ITIL Training Academy$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country],
									ISNULL((SELECT cr.[Name] FROM dbo.[ITIL Training Academy$Country_Region] cr WHERE cr.[Code] IN 
			(SELECT CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[ITIL Training Academy$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			ISNULL(CASE
				WHEN h.[Payment Information] <> 6 THEN (
					CASE
						WHEN c1.[No_] IN ('5345', '5343') THEN 'Original KP'
						WHEN c1.[No_] IN ('5344') THEN 'Original FP'
						ELSE
							CASE
								WHEN c1.[KP No_] <> '' THEN 
									(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
												WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
											END
									FROM dbo.[ITIL Training Academy$Sales Invoice Header] SH
									WHERE SH.[No_] = c1.[KP No_])
					
								ELSE  
									(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
												WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
												ELSE 'STANDARD'
											END
									FROM dbo.[ITIL Training Academy$Sales Header] SH
									WHERE SH.[No_] = c1.[Document No_])
								END
							END)
				ELSE
					CASE
						WHEN c1.[KP No_] <> '' THEN 
							(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
									END
							FROM dbo.[ITIL Training Academy$Sales Invoice Header] SH
							WHERE SH.[No_] = c1.[KP No_])
					
						ELSE  
							(SELECT CASE WHEN (c1.[Event Header] <> '' AND SH.[Knowledge Pass] = 1) THEN 'KPUSED'
										WHEN (c1.[Event Header] <> '' AND SH.[Flexi Pass] = 1) THEN 'FPUSED'
										ELSE 'STANDARD'
									END
							FROM dbo.[ITIL Training Academy$Sales Header] SH
							WHERE SH.[No_] = c1.[Document No_])
						END
				END,'') AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[ITIL Training Academy$Sales Line] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]
INNER JOIN dbo.[ITIL Training Academy$Sales Header] h ON h.[Document Type] = c1.[Document Type] AND h.[No_] = c1.[Document No_]
LEFT OUTER JOIN dbo.[ITIL Training Academy$Contact] cn on cn.[No_] = c1.[Contact No_]
LEFT OUTER JOIN dbo.[ITIL Training Academy$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[ITIL Training Academy$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >=  '2018/01/01'
AND c1.[Document Type] = 1
AND c1.[Quantity Invoiced] =0 AND c1.[Type] = 1 AND c1.[No_] LIKE '6%'
UNION ALL

--Pearce Mayfield Dubai
SELECT 'Pearce Mayfield Train Dubai' as [CName],
           'Order' as [DocumentType],
           c1.[Document No_] as [DocNo],
		h.[Document Date],
        h.[Original So No] as [Sales Order No],
c1.[Sell-to Customer No_],c1.[Contact No_],h.[Salesperson Code],cn.[Country_Region Code],
           c1.[Line No_] as [LineNo],
		   c1.[Amt_ Excl_ VAT (LCY)] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Revenue' as [BucketType],
		   c1.[Amt_ Excl_ VAT (LCY)] / ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[Pearce Mayfield Train Dubai$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[Pearce Mayfield Train Dubai$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country],
									ISNULL((SELECT cr.[Name] FROM dbo.[Pearce Mayfield Train Dubai$Country_Region] cr WHERE cr.[Code] IN 
			(SELECT CASE 
				WHEN LEN(e.[Country Code]) = 2 THEN e.[Country Code]
				ELSE (SELECT c.[Country_Region Code] from dbo.[Pearce Mayfield Train Dubai$Customer] c
						WHERE c.[No_] = c1.[Sell-to Customer No_])
			END AS [Country])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			ISNULL(CASE
				WHEN h.[Payment Information] <> 6 THEN (
					CASE
						WHEN c1.[No_] IN ('5345', '5343') THEN 'Original KP'
						WHEN c1.[No_] IN ('5344') THEN 'Original FP'
						ELSE
							CASE
								WHEN c1.[KP No_] <> '' THEN 
									(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
												WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
											END
									FROM dbo.[Pearce Mayfield Train Dubai$Sales Invoice Header] SH
									WHERE SH.[No_] = c1.[KP No_])
					
								ELSE  
									(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
												WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
												ELSE 'STANDARD'
											END
									FROM dbo.[Pearce Mayfield Train Dubai$Sales Header] SH
									WHERE SH.[No_] = c1.[Document No_])
								END
							END)
				ELSE
					CASE
						WHEN c1.[KP No_] <> '' THEN 
							(SELECT CASE WHEN SH.[Knowledge Pass] = 1 THEN 'KPUSED'
										WHEN SH.[Flexi Pass] = 1 THEN 'FPUSED'
									END
							FROM dbo.[Pearce Mayfield Train Dubai$Sales Invoice Header] SH
							WHERE SH.[No_] = c1.[KP No_])
					
						ELSE  
							(SELECT CASE WHEN (c1.[Event Header] <> '' AND SH.[Knowledge Pass] = 1) THEN 'KPUSED'
										WHEN (c1.[Event Header] <> '' AND SH.[Flexi Pass] = 1) THEN 'FPUSED'
										ELSE 'STANDARD'
									END
							FROM dbo.[Pearce Mayfield Train Dubai$Sales Header] SH
							WHERE SH.[No_] = c1.[Document No_])
						END
				END,'') AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[Pearce Mayfield Train Dubai$Sales Line] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]
INNER JOIN dbo.[Pearce Mayfield Train Dubai$Sales Header] h ON h.[Document Type] = c1.[Document Type] AND h.[No_] = c1.[Document No_]
LEFT OUTER JOIN dbo.[Pearce Mayfield Train Dubai$Contact] cn on cn.[No_] = c1.[Contact No_]
LEFT OUTER JOIN dbo.[Pearce Mayfield Train Dubai$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[Pearce Mayfield Train Dubai$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >=  '2018/01/01'
AND c1.[Document Type] = 1
AND c1.[Quantity Invoiced] =0 AND c1.[Type] = 1 AND c1.[No_] LIKE '6%'
UNION ALL

SELECT 'The Knowledge Academy Limited' as [CName],
           CASE
			WHEN c1.[MasterType] = 1 THEN 'Trainer'
			WHEN c1.[MasterType] = 2 THEN 'Venue'
			WHEN c1.[MasterType] = 3 THEN 'Exam'
			WHEN c1.[MasterType] IN (5,6,7) THEN 'Courseware'
			WHEN c1.[MasterType] = 8 THEN 'Manual'
			WHEN c1.[MasterType] = 9 THEN 'Travel'
			WHEN c1.[MasterType] = 11 THEN 'Invigilator'
			WHEN c1.[MasterType] IN (12,4) THEN 'Others'
		   END as [DocumentType],
           c1.[MasterCode] as [DocNo], '1753/01/01' as 'Document Date','' AS [Sales Order No],'' AS [Sell-to Customer No_], ''AS [Contact No_], '' AS [Salesperson Code], '' AS [Country_Region Code],
           c1.[Entry No_] as [LineNo],
		   c1.[Amount] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Projected' as [BucketType],
		   c1.[AmountLCY]	/ ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[The Knowledge Academy Limited$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			e.[Country Code] AS [Country],
			ISNULL((SELECT cr.[Name] FROM dbo.[The Knowledge Academy Limited$Country_Region] cr WHERE cr.[Code] IN 
			(e.[Country Code])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			'PROJECTED' AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[The Knowledge Academy Limited$Event Cost Heads] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]

LEFT OUTER JOIN dbo.[The Knowledge Academy Limited$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[The Knowledge Academy Limited$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >=  '2018/01/01'
AND c1.[Applicable] = 1
UNION ALL
SELECT 'The Knowledge Academy Inc' as [CName],
           CASE
			WHEN c1.[MasterType] = 1 THEN 'Trainer'
			WHEN c1.[MasterType] = 2 THEN 'Venue'
			WHEN c1.[MasterType] = 3 THEN 'Exam'
			WHEN c1.[MasterType] IN (5,6,7) THEN 'Courseware'
			WHEN c1.[MasterType] = 8 THEN 'Manual'
			WHEN c1.[MasterType] = 9 THEN 'Travel'
			WHEN c1.[MasterType] = 11 THEN 'Invigilator'
			WHEN c1.[MasterType] IN (12,4) THEN 'Others'
		   END as [DocumentType],
           c1.[MasterCode] as [DocNo], '1753/01/01' as 'Document Date','' AS [Sales Order No],'' AS [Sell-to Customer No_], ''AS [Contact No_], '' AS [Salesperson Code], '' AS [Country_Region Code],
           c1.[Entry No_] as [LineNo],
		   c1.[Amount] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Projected' as [BucketType],
		   c1.[AmountLCY]	/ ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[The Knowledge Academy Inc$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			e.[Country Code] AS [Country],
			ISNULL((SELECT cr.[Name] FROM dbo.[The Knowledge Academy Inc$Country_Region] cr WHERE cr.[Code] IN 
			(e.[Country Code])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			'PROJECTED' AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[The Knowledge Academy Inc$Event Cost Heads] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]

LEFT OUTER JOIN dbo.[The Knowledge Academy Inc$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[The Knowledge Academy Inc$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >= '2018/01/01'
AND c1.[Applicable] = 1
UNION ALL
SELECT 'Best Practice Training Ltd.' as [CName],
           CASE
			WHEN c1.[MasterType] = 1 THEN 'Trainer'
			WHEN c1.[MasterType] = 2 THEN 'Venue'
			WHEN c1.[MasterType] = 3 THEN 'Exam'
			WHEN c1.[MasterType] IN (5,6,7) THEN 'Courseware'
			WHEN c1.[MasterType] = 8 THEN 'Manual'
			WHEN c1.[MasterType] = 9 THEN 'Travel'
			WHEN c1.[MasterType] = 11 THEN 'Invigilator'
			WHEN c1.[MasterType] IN (12,4) THEN 'Others'
		   END as [DocumentType],
           c1.[MasterCode] as [DocNo], '1753/01/01' as 'Document Date','' AS [Sales Order No],'' AS [Sell-to Customer No_], ''AS [Contact No_], '' AS [Salesperson Code], '' AS [Country_Region Code],
           c1.[Entry No_] as [LineNo],
		   c1.[Amount] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Projected' as [BucketType],
		   c1.[AmountLCY]	/ ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[Best Practice Training Ltd_$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			e.[Country Code] AS [Country],
			ISNULL((SELECT cr.[Name] FROM dbo.[Best Practice Training Ltd_$Country_Region] cr WHERE cr.[Code] IN 
			(e.[Country Code])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			'PROJECTED' AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[Best Practice Training Ltd_$Event Cost Heads] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]

LEFT OUTER JOIN dbo.[Best Practice Training Ltd_$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[Best Practice Training Ltd_$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >= '2018/01/01'
AND c1.[Applicable] = 1
UNION ALL
SELECT 'Datrix Learning Services Ltd.' as [CName],
           CASE
			WHEN c1.[MasterType] = 1 THEN 'Trainer'
			WHEN c1.[MasterType] = 2 THEN 'Venue'
			WHEN c1.[MasterType] = 3 THEN 'Exam'
			WHEN c1.[MasterType] IN (5,6,7) THEN 'Courseware'
			WHEN c1.[MasterType] = 8 THEN 'Manual'
			WHEN c1.[MasterType] = 9 THEN 'Travel'
			WHEN c1.[MasterType] = 11 THEN 'Invigilator'
			WHEN c1.[MasterType] IN (12,4) THEN 'Others'
		   END as [DocumentType],
           c1.[MasterCode] as [DocNo], '1753/01/01' as 'Document Date','' AS [Sales Order No],'' AS [Sell-to Customer No_], ''AS [Contact No_], '' AS [Salesperson Code], '' AS [Country_Region Code],
           c1.[Entry No_] as [LineNo],
		   c1.[Amount] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Projected' as [BucketType],
		   c1.[AmountLCY]	/ ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[Datrix Learning Services Ltd_$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			e.[Country Code] AS [Country],
			ISNULL((SELECT cr.[Name] FROM dbo.[Datrix Learning Services Ltd_$Country_Region] cr WHERE cr.[Code] IN 
			(e.[Country Code])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			'PROJECTED' AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[Datrix Learning Services Ltd_$Event Cost Heads] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]

LEFT OUTER JOIN dbo.[Datrix Learning Services Ltd_$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[Datrix Learning Services Ltd_$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >= '2018/01/01'
AND c1.[Applicable] = 1
UNION ALL
SELECT 'Pearce Mayfield Training Ltd' as [CName],
           CASE
			WHEN c1.[MasterType] = 1 THEN 'Trainer'
			WHEN c1.[MasterType] = 2 THEN 'Venue'
			WHEN c1.[MasterType] = 3 THEN 'Exam'
			WHEN c1.[MasterType] IN (5,6,7) THEN 'Courseware'
			WHEN c1.[MasterType] = 8 THEN 'Manual'
			WHEN c1.[MasterType] = 9 THEN 'Travel'
			WHEN c1.[MasterType] = 11 THEN 'Invigilator'
			WHEN c1.[MasterType] IN (12,4) THEN 'Others'
		   END as [DocumentType],
           c1.[MasterCode] as [DocNo],'1753/01/01' as 'Document Date','' AS [Sales Order No], '' AS [Sell-to Customer No_], ''AS [Contact No_], '' AS [Salesperson Code], '' AS [Country_Region Code],
           c1.[Entry No_] as [LineNo],
		   c1.[Amount] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Projected' as [BucketType],
		   c1.[AmountLCY]	/ ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[Pearce Mayfield Training Ltd$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			e.[Country Code] AS [Country],
			ISNULL((SELECT cr.[Name] FROM dbo.[Pearce Mayfield Training Ltd$Country_Region] cr WHERE cr.[Code] IN 
			(e.[Country Code])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			'PROJECTED' AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[Pearce Mayfield Training Ltd$Event Cost Heads] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]

LEFT OUTER JOIN dbo.[Pearce Mayfield Training Ltd$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[Pearce Mayfield Training Ltd$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >= '2018/01/01'
AND c1.[Applicable] = 1
UNION ALL
SELECT 'Pentagon Leisure Services Ltd' as [CName],
           CASE
			WHEN c1.[MasterType] = 1 THEN 'Trainer'
			WHEN c1.[MasterType] = 2 THEN 'Venue'
			WHEN c1.[MasterType] = 3 THEN 'Exam'
			WHEN c1.[MasterType] IN (5,6,7) THEN 'Courseware'
			WHEN c1.[MasterType] = 8 THEN 'Manual'
			WHEN c1.[MasterType] = 9 THEN 'Travel'
			WHEN c1.[MasterType] = 11 THEN 'Invigilator'
			WHEN c1.[MasterType] IN (12,4) THEN 'Others'
		   END as [DocumentType],
           c1.[MasterCode] as [DocNo],'1753/01/01' as 'Document Date','' AS [Sales Order No], '' AS [Sell-to Customer No_], ''AS [Contact No_], '' AS [Salesperson Code], '' AS [Country_Region Code],
           c1.[Entry No_] as [LineNo],
		   c1.[Amount] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Projected' as [BucketType],
		   c1.[AmountLCY]	/ ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[Pentagon Leisure Services Ltd$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			e.[Country Code] AS [Country],
			ISNULL((SELECT cr.[Name] FROM dbo.[Pentagon Leisure Services Ltd$Country_Region] cr WHERE cr.[Code] IN 
			(e.[Country Code])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			'PROJECTED' AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[Pentagon Leisure Services Ltd$Event Cost Heads] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]

LEFT OUTER JOIN dbo.[Pentagon Leisure Services Ltd$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[Pentagon Leisure Services Ltd$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >= '2018/01/01'
AND c1.[Applicable] = 1
UNION ALL
SELECT 'Silicon Beach Training' as [CName],
           CASE
			WHEN c1.[MasterType] = 1 THEN 'Trainer'
			WHEN c1.[MasterType] = 2 THEN 'Venue'
			WHEN c1.[MasterType] = 3 THEN 'Exam'
			WHEN c1.[MasterType] IN (5,6,7) THEN 'Courseware'
			WHEN c1.[MasterType] = 8 THEN 'Manual'
			WHEN c1.[MasterType] = 9 THEN 'Travel'
			WHEN c1.[MasterType] = 11 THEN 'Invigilator'
			WHEN c1.[MasterType] IN (12,4) THEN 'Others'
		   END as [DocumentType],
           c1.[MasterCode] as [DocNo], '1753/01/01' as 'Document Date','' AS [Sales Order No],'' AS [Sell-to Customer No_], ''AS [Contact No_], '' AS [Salesperson Code], '' AS [Country_Region Code],
           c1.[Entry No_] as [LineNo],
		   c1.[Amount] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Projected' as [BucketType],
		   c1.[AmountLCY]	/ ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[Silicon Beach Training$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			e.[Country Code] AS [Country],
			ISNULL((SELECT cr.[Name] FROM dbo.[Silicon Beach Training$Country_Region] cr WHERE cr.[Code] IN 
			(e.[Country Code])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			'PROJECTED' AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[Silicon Beach Training$Event Cost Heads] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]

LEFT OUTER JOIN dbo.[Silicon Beach Training$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[Silicon Beach Training$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >= '2018/01/01'
AND c1.[Applicable] = 1
UNION ALL
SELECT 'The Knowledge Academy Pty Ltd.' as [CName],
           CASE
			WHEN c1.[MasterType] = 1 THEN 'Trainer'
			WHEN c1.[MasterType] = 2 THEN 'Venue'
			WHEN c1.[MasterType] = 3 THEN 'Exam'
			WHEN c1.[MasterType] IN (5,6,7) THEN 'Courseware'
			WHEN c1.[MasterType] = 8 THEN 'Manual'
			WHEN c1.[MasterType] = 9 THEN 'Travel'
			WHEN c1.[MasterType] = 11 THEN 'Invigilator'
			WHEN c1.[MasterType] IN (12,4) THEN 'Others'
		   END as [DocumentType],
           c1.[MasterCode] as [DocNo], '1753/01/01' as 'Document Date','' AS [Sales Order No],'' AS [Sell-to Customer No_], ''AS [Contact No_], '' AS [Salesperson Code], '' AS [Country_Region Code],
           c1.[Entry No_] as [LineNo],
		   c1.[Amount] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Projected' as [BucketType],
		   c1.[AmountLCY]	/ ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[The Knowledge Academy Pty Ltd_$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			e.[Country Code] AS [Country],
			ISNULL((SELECT cr.[Name] FROM dbo.[The Knowledge Academy Pty Ltd_$Country_Region] cr WHERE cr.[Code] IN 
			(e.[Country Code])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			'PROJECTED' AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[The Knowledge Academy Pty Ltd_$Event Cost Heads] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]

LEFT OUTER JOIN dbo.[The Knowledge Academy Pty Ltd_$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[The Knowledge Academy Pty Ltd_$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >= '2018/01/01'
AND c1.[Applicable] = 1
UNION ALL
SELECT 'The Knowledge Academy SA' as [CName],
           CASE
			WHEN c1.[MasterType] = 1 THEN 'Trainer'
			WHEN c1.[MasterType] = 2 THEN 'Venue'
			WHEN c1.[MasterType] = 3 THEN 'Exam'
			WHEN c1.[MasterType] IN (5,6,7) THEN 'Courseware'
			WHEN c1.[MasterType] = 8 THEN 'Manual'
			WHEN c1.[MasterType] = 9 THEN 'Travel'
			WHEN c1.[MasterType] = 11 THEN 'Invigilator'
			WHEN c1.[MasterType] IN (12,4) THEN 'Others'
		   END as [DocumentType],
           c1.[MasterCode] as [DocNo], '1753/01/01' as 'Document Date','' AS [Sales Order No],'' AS [Sell-to Customer No_], ''AS [Contact No_], '' AS [Salesperson Code], '' AS [Country_Region Code],
           c1.[Entry No_] as [LineNo],
		   c1.[Amount] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Projected' as [BucketType],
		   c1.[AmountLCY]	/ ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[The Knowledge Academy SA$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			e.[Country Code] AS [Country],
			ISNULL((SELECT cr.[Name] FROM dbo.[The Knowledge Academy SA$Country_Region] cr WHERE cr.[Code] IN 
			(e.[Country Code])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			'PROJECTED' AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[The Knowledge Academy SA$Event Cost Heads] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]

LEFT OUTER JOIN dbo.[The Knowledge Academy SA$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[The Knowledge Academy SA$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >= '2018/01/01'
AND c1.[Applicable] = 1
UNION ALL
SELECT 'TKA Canada Corporation' as [CName],
           CASE
			WHEN c1.[MasterType] = 1 THEN 'Trainer'
			WHEN c1.[MasterType] = 2 THEN 'Venue'
			WHEN c1.[MasterType] = 3 THEN 'Exam'
			WHEN c1.[MasterType] IN (5,6,7) THEN 'Courseware'
			WHEN c1.[MasterType] = 8 THEN 'Manual'
			WHEN c1.[MasterType] = 9 THEN 'Travel'
			WHEN c1.[MasterType] = 11 THEN 'Invigilator'
			WHEN c1.[MasterType] IN (12,4) THEN 'Others'
		   END as [DocumentType],
           c1.[MasterCode] as [DocNo], '1753/01/01' as 'Document Date','' AS [Sales Order No],'' AS [Sell-to Customer No_], ''AS [Contact No_], '' AS [Salesperson Code], '' AS [Country_Region Code],
           c1.[Entry No_] as [LineNo],
		   c1.[Amount] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Projected' as [BucketType],
		   c1.[AmountLCY]	/ ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[TKA Canada Corporation$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			e.[Country Code] AS [Country],
			ISNULL((SELECT cr.[Name] FROM dbo.[TKA Canada Corporation$Country_Region] cr WHERE cr.[Code] IN 
			(e.[Country Code])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			'PROJECTED' AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[TKA Canada Corporation$Event Cost Heads] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]

LEFT OUTER JOIN dbo.[TKA Canada Corporation$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[TKA Canada Corporation$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >= '2018/01/01'
AND c1.[Applicable] = 1
UNION ALL
SELECT 'TKA Europe' as [CName],
           CASE
			WHEN c1.[MasterType] = 1 THEN 'Trainer'
			WHEN c1.[MasterType] = 2 THEN 'Venue'
			WHEN c1.[MasterType] = 3 THEN 'Exam'
			WHEN c1.[MasterType] IN (5,6,7) THEN 'Courseware'
			WHEN c1.[MasterType] = 8 THEN 'Manual'
			WHEN c1.[MasterType] = 9 THEN 'Travel'
			WHEN c1.[MasterType] = 11 THEN 'Invigilator'
			WHEN c1.[MasterType] IN (12,4) THEN 'Others'
		   END as [DocumentType],
           c1.[MasterCode] as [DocNo], '1753/01/01' as 'Document Date','' AS [Sales Order No],'' AS [Sell-to Customer No_], ''AS [Contact No_], '' AS [Salesperson Code], '' AS [Country_Region Code],
           c1.[Entry No_] as [LineNo],
		   c1.[Amount] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Projected' as [BucketType],
		   c1.[AmountLCY]	/ ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[TKA Europe$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			e.[Country Code] AS [Country],
			ISNULL((SELECT cr.[Name] FROM dbo.[TKA Europe$Country_Region] cr WHERE cr.[Code] IN 
			(e.[Country Code])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			'PROJECTED' AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[TKA Europe$Event Cost Heads] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]

LEFT OUTER JOIN dbo.[TKA Europe$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[TKA Europe$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >= '2018/01/01'
AND c1.[Applicable] = 1
UNION ALL
SELECT 'TKA Hong Kong Ltd.' as [CName],
           CASE
			WHEN c1.[MasterType] = 1 THEN 'Trainer'
			WHEN c1.[MasterType] = 2 THEN 'Venue'
			WHEN c1.[MasterType] = 3 THEN 'Exam'
			WHEN c1.[MasterType] IN (5,6,7) THEN 'Courseware'
			WHEN c1.[MasterType] = 8 THEN 'Manual'
			WHEN c1.[MasterType] = 9 THEN 'Travel'
			WHEN c1.[MasterType] = 11 THEN 'Invigilator'
			WHEN c1.[MasterType] IN (12,4) THEN 'Others'
		   END as [DocumentType],
           c1.[MasterCode] as [DocNo], '1753/01/01' as 'Document Date','' AS [Sales Order No],'' AS [Sell-to Customer No_], ''AS [Contact No_], '' AS [Salesperson Code], '' AS [Country_Region Code],
           c1.[Entry No_] as [LineNo],
		   c1.[Amount] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Projected' as [BucketType],
		   c1.[AmountLCY]	/ ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[TKA Hong Kong Ltd_$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			e.[Country Code] AS [Country],
			ISNULL((SELECT cr.[Name] FROM dbo.[TKA Hong Kong Ltd_$Country_Region] cr WHERE cr.[Code] IN 
			(e.[Country Code])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			'PROJECTED' AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[TKA Hong Kong Ltd_$Event Cost Heads] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]

LEFT OUTER JOIN dbo.[TKA Hong Kong Ltd_$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[TKA Hong Kong Ltd_$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >= '2018/01/01'
AND c1.[Applicable] = 1
UNION ALL
SELECT 'TKA New Zealand Ltd.' as [CName],
           CASE
			WHEN c1.[MasterType] = 1 THEN 'Trainer'
			WHEN c1.[MasterType] = 2 THEN 'Venue'
			WHEN c1.[MasterType] = 3 THEN 'Exam'
			WHEN c1.[MasterType] IN (5,6,7) THEN 'Courseware'
			WHEN c1.[MasterType] = 8 THEN 'Manual'
			WHEN c1.[MasterType] = 9 THEN 'Travel'
			WHEN c1.[MasterType] = 11 THEN 'Invigilator'
			WHEN c1.[MasterType] IN (12,4) THEN 'Others'
		   END as [DocumentType],
           c1.[MasterCode] as [DocNo], '1753/01/01' as 'Document Date','' AS [Sales Order No],'' AS [Sell-to Customer No_], ''AS [Contact No_], '' AS [Salesperson Code], '' AS [Country_Region Code],
           c1.[Entry No_] as [LineNo],
		   c1.[Amount] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Projected' as [BucketType],
		   c1.[AmountLCY]	/ ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[TKA New Zealand Ltd_$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			e.[Country Code] AS [Country],
			ISNULL((SELECT cr.[Name] FROM dbo.[TKA New Zealand Ltd_$Country_Region] cr WHERE cr.[Code] IN 
			(e.[Country Code])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			'PROJECTED' AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[TKA New Zealand Ltd_$Event Cost Heads] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]

LEFT OUTER JOIN dbo.[TKA New Zealand Ltd_$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[TKA New Zealand Ltd_$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >= '2018/01/01'
AND c1.[Applicable] = 1
UNION ALL
SELECT 'TKA Singapore PTE Ltd.' as [CName],
           CASE
			WHEN c1.[MasterType] = 1 THEN 'Trainer'
			WHEN c1.[MasterType] = 2 THEN 'Venue'
			WHEN c1.[MasterType] = 3 THEN 'Exam'
			WHEN c1.[MasterType] IN (5,6,7) THEN 'Courseware'
			WHEN c1.[MasterType] = 8 THEN 'Manual'
			WHEN c1.[MasterType] = 9 THEN 'Travel'
			WHEN c1.[MasterType] = 11 THEN 'Invigilator'
			WHEN c1.[MasterType] IN (12,4) THEN 'Others'
		   END as [DocumentType],
           c1.[MasterCode] as [DocNo], '1753/01/01' as 'Document Date','' AS [Sales Order No],'' AS [Sell-to Customer No_], ''AS [Contact No_], '' AS [Salesperson Code], '' AS [Country_Region Code],
           c1.[Entry No_] as [LineNo],
		   c1.[Amount] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Projected' as [BucketType],
		   c1.[AmountLCY]	/ ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[TKA Singapore PTE Ltd_$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			e.[Country Code] AS [Country],
			ISNULL((SELECT cr.[Name] FROM dbo.[TKA Singapore PTE Ltd_$Country_Region] cr WHERE cr.[Code] IN 
			(e.[Country Code])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			'PROJECTED' AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[TKA Singapore PTE Ltd_$Event Cost Heads] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]

LEFT OUTER JOIN dbo.[TKA Singapore PTE Ltd_$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[TKA Singapore PTE Ltd_$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >= '2018/01/01'
AND c1.[Applicable] = 1

--ITIL
UNION ALL
SELECT 'ITIL Training Academy' as [CName],
           CASE
			WHEN c1.[MasterType] = 1 THEN 'Trainer'
			WHEN c1.[MasterType] = 2 THEN 'Venue'
			WHEN c1.[MasterType] = 3 THEN 'Exam'
			WHEN c1.[MasterType] IN (5,6,7) THEN 'Courseware'
			WHEN c1.[MasterType] = 8 THEN 'Manual'
			WHEN c1.[MasterType] = 9 THEN 'Travel'
			WHEN c1.[MasterType] = 11 THEN 'Invigilator'
			WHEN c1.[MasterType] IN (12,4) THEN 'Others'
		   END as [DocumentType],
           c1.[MasterCode] as [DocNo], '1753/01/01' as 'Document Date','' AS [Sales Order No],'' AS [Sell-to Customer No_], ''AS [Contact No_], '' AS [Salesperson Code], '' AS [Country_Region Code],
           c1.[Entry No_] as [LineNo],
		   c1.[Amount] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Projected' as [BucketType],
		   c1.[AmountLCY]	/ ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[ITIL Training Academy$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			e.[Country Code] AS [Country],
			ISNULL((SELECT cr.[Name] FROM dbo.[ITIL Training Academy$Country_Region] cr WHERE cr.[Code] IN 
			(e.[Country Code])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			'PROJECTED' AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[ITIL Training Academy$Event Cost Heads] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]

LEFT OUTER JOIN dbo.[ITIL Training Academy$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[ITIL Training Academy$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >=  '2018/01/01'
AND c1.[Applicable] = 1
UNION ALL
--Pearce Mayfield Train Dubai

SELECT 'Pearce Mayfield Train Dubai' as [CName],
           CASE
			WHEN c1.[MasterType] = 1 THEN 'Trainer'
			WHEN c1.[MasterType] = 2 THEN 'Venue'
			WHEN c1.[MasterType] = 3 THEN 'Exam'
			WHEN c1.[MasterType] IN (5,6,7) THEN 'Courseware'
			WHEN c1.[MasterType] = 8 THEN 'Manual'
			WHEN c1.[MasterType] = 9 THEN 'Travel'
			WHEN c1.[MasterType] = 11 THEN 'Invigilator'
			WHEN c1.[MasterType] IN (12,4) THEN 'Others'
		   END as [DocumentType],
           c1.[MasterCode] as [DocNo], '1753/01/01' as 'Document Date','' AS [Sales Order No],'' AS [Sell-to Customer No_], ''AS [Contact No_], '' AS [Salesperson Code], '' AS [Country_Region Code],
           c1.[Entry No_] as [LineNo],
		   c1.[Amount] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Projected' as [BucketType],
		   c1.[AmountLCY]	/ ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[Pearce Mayfield Train Dubai$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			e.[Country Code] AS [Country],
			ISNULL((SELECT cr.[Name] FROM dbo.[Pearce Mayfield Train Dubai$Country_Region] cr WHERE cr.[Code] IN 
			(e.[Country Code])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			'PROJECTED' AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[Pearce Mayfield Train Dubai$Event Cost Heads] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]

LEFT OUTER JOIN dbo.[Pearce Mayfield Train Dubai$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[Pearce Mayfield Train Dubai$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >=  '2018/01/01'
AND c1.[Applicable] = 1

UNION ALL

SELECT 'The Knowledge Academy Limited' as [CName],
           CASE
			WHEN c1.[MasterType] = 1 THEN 'Trainer'
			WHEN c1.[MasterType] = 2 THEN 'Venue'
			WHEN c1.[MasterType] = 3 THEN 'Exam'
			WHEN c1.[MasterType] IN (5,6,7) THEN 'Courseware'
			WHEN c1.[MasterType] = 8 THEN 'Manual'
			WHEN c1.[MasterType] = 9 THEN 'Travel'
			WHEN c1.[MasterType] = 11 THEN 'Invigilator'
			WHEN c1.[MasterType] IN (0,11,4) THEN 'Others'
		   END as [DocumentType],
           c1.[MasterCode] as [DocNo], '1753/01/01' as 'Document Date','' AS [Sales Order No],'' AS [Sell-to Customer No_], ''AS [Contact No_], '' AS [Salesperson Code], '' AS [Country_Region Code],
           c1.[Entry No_] as [LineNo],
		   c1.[Amount] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Actual' as [BucketType],
		   c1.[Amount] / ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[The Knowledge Academy Limited$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			e.[Country Code] AS [Country],
			ISNULL((SELECT cr.[Name] FROM dbo.[The Knowledge Academy Limited$Country_Region] cr WHERE cr.[Code] IN 
			(e.[Country Code])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			'ACTUAL' AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[The Knowledge Academy Limited$G_L Entry] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]

LEFT OUTER JOIN dbo.[The Knowledge Academy Limited$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[The Knowledge Academy Limited$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >=  '2018/01/01' AND c1.[Posting Date] >= '2018/04/01'
AND c1.[G_L Account No_] LIKE '8%' AND c1.[Event Header] <>''
UNION ALL
SELECT 'The Knowledge Academy Inc' as [CName],
           CASE
			WHEN c1.[MasterType] = 1 THEN 'Trainer'
			WHEN c1.[MasterType] = 2 THEN 'Venue'
			WHEN c1.[MasterType] = 3 THEN 'Exam'
			WHEN c1.[MasterType] IN (5,6,7) THEN 'Courseware'
			WHEN c1.[MasterType] = 8 THEN 'Manual'
			WHEN c1.[MasterType] = 9 THEN 'Travel'
			WHEN c1.[MasterType] = 11 THEN 'Invigilator'
			WHEN c1.[MasterType] IN (0,11,4) THEN 'Others'
		   END as [DocumentType],
           c1.[MasterCode] as [DocNo], '1753/01/01' as 'Document Date','' AS [Sales Order No],'' AS [Sell-to Customer No_], ''AS [Contact No_], '' AS [Salesperson Code], '' AS [Country_Region Code],
           c1.[Entry No_] as [LineNo],
		   c1.[Amount] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Actual' as [BucketType],
		   c1.[Amount] / ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[The Knowledge Academy Inc$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			e.[Country Code] AS [Country],
			ISNULL((SELECT cr.[Name] FROM dbo.[The Knowledge Academy Inc$Country_Region] cr WHERE cr.[Code] IN 
			(e.[Country Code])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			'ACTUAL' AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[The Knowledge Academy Inc$G_L Entry] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]

LEFT OUTER JOIN dbo.[The Knowledge Academy Inc$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[The Knowledge Academy Inc$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >=  '2018/01/01' AND c1.[Posting Date] >= '2018/04/01'
AND c1.[G_L Account No_] LIKE '8%'  AND c1.[Event Header] <>''
UNION ALL
SELECT 'Best Practice Training Ltd.' as [CName],
           CASE
			WHEN c1.[MasterType] = 1 THEN 'Trainer'
			WHEN c1.[MasterType] = 2 THEN 'Venue'
			WHEN c1.[MasterType] = 3 THEN 'Exam'
			WHEN c1.[MasterType] IN (5,6,7) THEN 'Courseware'
			WHEN c1.[MasterType] = 8 THEN 'Manual'
			WHEN c1.[MasterType] = 9 THEN 'Travel'
			WHEN c1.[MasterType] = 11 THEN 'Invigilator'
			WHEN c1.[MasterType] IN (0,11,4) THEN 'Others'
		   END as [DocumentType],
           c1.[MasterCode] as [DocNo], '1753/01/01' as 'Document Date','' AS [Sales Order No],'' AS [Sell-to Customer No_], ''AS [Contact No_], '' AS [Salesperson Code], '' AS [Country_Region Code],
           c1.[Entry No_] as [LineNo],
		   c1.[Amount] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Actual' as [BucketType],
		   c1.[Amount] / ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[Best Practice Training Ltd_$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			e.[Country Code] AS [Country],
			ISNULL((SELECT cr.[Name] FROM dbo.[Best Practice Training Ltd_$Country_Region] cr WHERE cr.[Code] IN 
			(e.[Country Code])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			'ACTUAL' AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[Best Practice Training Ltd_$G_L Entry] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]

LEFT OUTER JOIN dbo.[Best Practice Training Ltd_$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[Best Practice Training Ltd_$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >=  '2018/01/01' AND c1.[Posting Date] >= '2018/04/01'
AND c1.[G_L Account No_] LIKE '8%' AND c1.[Event Header] <>''
UNION ALL
SELECT 'Datrix Learning Services Ltd.' as [CName],
           CASE
			WHEN c1.[MasterType] = 1 THEN 'Trainer'
			WHEN c1.[MasterType] = 2 THEN 'Venue'
			WHEN c1.[MasterType] = 3 THEN 'Exam'
			WHEN c1.[MasterType] IN (5,6,7) THEN 'Courseware'
			WHEN c1.[MasterType] = 8 THEN 'Manual'
			WHEN c1.[MasterType] = 9 THEN 'Travel'
			WHEN c1.[MasterType] = 11 THEN 'Invigilator'
			WHEN c1.[MasterType] IN (0,11,4) THEN 'Others'
		   END as [DocumentType],
           c1.[MasterCode] as [DocNo],'1753/01/01' as 'Document Date','' AS [Sales Order No], '' AS [Sell-to Customer No_], ''AS [Contact No_], '' AS [Salesperson Code], '' AS [Country_Region Code],
           c1.[Entry No_] as [LineNo],
		   c1.[Amount] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Actual' as [BucketType],
		   c1.[Amount] / ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[Datrix Learning Services Ltd_$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			e.[Country Code] AS [Country],
			ISNULL((SELECT cr.[Name] FROM dbo.[Datrix Learning Services Ltd_$Country_Region] cr WHERE cr.[Code] IN 
			(e.[Country Code])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			'ACTUAL' AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[Datrix Learning Services Ltd_$G_L Entry] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]

LEFT OUTER JOIN dbo.[Datrix Learning Services Ltd_$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[Datrix Learning Services Ltd_$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >=  '2018/01/01' AND c1.[Posting Date] >= '2018/04/01'
AND c1.[G_L Account No_] LIKE '8%'  AND c1.[Event Header] <>''
UNION ALL
SELECT 'Pearce Mayfield Training Ltd' as [CName],
           CASE
			WHEN c1.[MasterType] = 1 THEN 'Trainer'
			WHEN c1.[MasterType] = 2 THEN 'Venue'
			WHEN c1.[MasterType] = 3 THEN 'Exam'
			WHEN c1.[MasterType] IN (5,6,7) THEN 'Courseware'
			WHEN c1.[MasterType] = 8 THEN 'Manual'
			WHEN c1.[MasterType] = 9 THEN 'Travel'
			WHEN c1.[MasterType] = 11 THEN 'Invigilator'
			WHEN c1.[MasterType] IN (0,11,4) THEN 'Others'
		   END as [DocumentType],
           c1.[MasterCode] as [DocNo], '1753/01/01' as 'Document Date','' AS [Sales Order No],'' AS [Sell-to Customer No_], ''AS [Contact No_], '' AS [Salesperson Code], '' AS [Country_Region Code],
           c1.[Entry No_] as [LineNo],
		   c1.[Amount] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Actual' as [BucketType],
		   c1.[Amount] / ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[Pearce Mayfield Training Ltd$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			e.[Country Code] AS [Country],
			ISNULL((SELECT cr.[Name] FROM dbo.[Pearce Mayfield Training Ltd$Country_Region] cr WHERE cr.[Code] IN 
			(e.[Country Code])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			'ACTUAL' AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[Pearce Mayfield Training Ltd$G_L Entry] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]

LEFT OUTER JOIN dbo.[Pearce Mayfield Training Ltd$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[Pearce Mayfield Training Ltd$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >=  '2018/01/01' AND c1.[Posting Date] >= '2018/04/01'
AND c1.[G_L Account No_] LIKE '8%'  AND c1.[Event Header] <>''
UNION ALL
SELECT 'Pentagon Leisure Services Ltd' as [CName],
           CASE
			WHEN c1.[MasterType] = 1 THEN 'Trainer'
			WHEN c1.[MasterType] = 2 THEN 'Venue'
			WHEN c1.[MasterType] = 3 THEN 'Exam'
			WHEN c1.[MasterType] IN (5,6,7) THEN 'Courseware'
			WHEN c1.[MasterType] = 8 THEN 'Manual'
			WHEN c1.[MasterType] = 9 THEN 'Travel'
			WHEN c1.[MasterType] = 11 THEN 'Invigilator'
			WHEN c1.[MasterType] IN (0,11,4) THEN 'Others'
		   END as [DocumentType],
           c1.[MasterCode] as [DocNo], '1753/01/01' as 'Document Date','' AS [Sales Order No],'' AS [Sell-to Customer No_], ''AS [Contact No_], '' AS [Salesperson Code], '' AS [Country_Region Code],
           c1.[Entry No_] as [LineNo],
		   c1.[Amount] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Actual' as [BucketType],
		   c1.[Amount] / ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[Pentagon Leisure Services Ltd$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			e.[Country Code] AS [Country],
			ISNULL((SELECT cr.[Name] FROM dbo.[Pentagon Leisure Services Ltd$Country_Region] cr WHERE cr.[Code] IN 
			(e.[Country Code])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			'ACTUAL' AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[Pentagon Leisure Services Ltd$G_L Entry] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]

LEFT OUTER JOIN dbo.[Pentagon Leisure Services Ltd$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[Pentagon Leisure Services Ltd$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >=  '2018/01/01' AND c1.[Posting Date] >= '2018/04/01'
AND c1.[G_L Account No_] LIKE '8%'  AND c1.[Event Header] <>''
UNION ALL
SELECT 'Silicon Beach Training' as [CName],
           CASE
			WHEN c1.[MasterType] = 1 THEN 'Trainer'
			WHEN c1.[MasterType] = 2 THEN 'Venue'
			WHEN c1.[MasterType] = 3 THEN 'Exam'
			WHEN c1.[MasterType] IN (5,6,7) THEN 'Courseware'
			WHEN c1.[MasterType] = 8 THEN 'Manual'
			WHEN c1.[MasterType] = 9 THEN 'Travel'
			WHEN c1.[MasterType] = 11 THEN 'Invigilator'
			WHEN c1.[MasterType] IN (0,11,4) THEN 'Others'
		   END as [DocumentType],
           c1.[MasterCode] as [DocNo],'1753/01/01' as 'Document Date','' AS [Sales Order No], '' AS [Sell-to Customer No_], ''AS [Contact No_], '' AS [Salesperson Code], '' AS [Country_Region Code],
           c1.[Entry No_] as [LineNo],
		   c1.[Amount] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Actual' as [BucketType],
		   c1.[Amount] / ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[Silicon Beach Training$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			e.[Country Code] AS [Country],
			ISNULL((SELECT cr.[Name] FROM dbo.[Silicon Beach Training$Country_Region] cr WHERE cr.[Code] IN 
			(e.[Country Code])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			'ACTUAL' AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[Silicon Beach Training$G_L Entry] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]

LEFT OUTER JOIN dbo.[Silicon Beach Training$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[Silicon Beach Training$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >= '2018/01/01' AND c1.[Posting Date] >= '2018/04/01'
AND c1.[G_L Account No_] LIKE '8%'  AND c1.[Event Header] <>''
UNION ALL
SELECT 'The Knowledge Academy Pty Ltd.' as [CName],
           CASE
			WHEN c1.[MasterType] = 1 THEN 'Trainer'
			WHEN c1.[MasterType] = 2 THEN 'Venue'
			WHEN c1.[MasterType] = 3 THEN 'Exam'
			WHEN c1.[MasterType] IN (5,6,7) THEN 'Courseware'
			WHEN c1.[MasterType] = 8 THEN 'Manual'
			WHEN c1.[MasterType] = 9 THEN 'Travel'
			WHEN c1.[MasterType] = 11 THEN 'Invigilator'
			WHEN c1.[MasterType] IN (0,11,4) THEN 'Others'
		   END as [DocumentType],
           c1.[MasterCode] as [DocNo], '1753/01/01' as 'Document Date','' AS [Sales Order No],'' AS [Sell-to Customer No_], ''AS [Contact No_], '' AS [Salesperson Code], '' AS [Country_Region Code],
           c1.[Entry No_] as [LineNo],
		   c1.[Amount] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Actual' as [BucketType],
		   c1.[Amount] / ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[The Knowledge Academy Pty Ltd_$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			e.[Country Code] AS [Country],
			ISNULL((SELECT cr.[Name] FROM dbo.[The Knowledge Academy Pty Ltd_$Country_Region] cr WHERE cr.[Code] IN 
			(e.[Country Code])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			'ACTUAL' AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[The Knowledge Academy Pty Ltd_$G_L Entry] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]

LEFT OUTER JOIN dbo.[The Knowledge Academy Pty Ltd_$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[The Knowledge Academy Pty Ltd_$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >=  '2018/01/01' AND c1.[Posting Date] >= '2018/04/01'
AND c1.[G_L Account No_] LIKE '8%'  AND c1.[Event Header] <>'' 
UNION ALL
SELECT 'The Knowledge Academy SA' as [CName],
           CASE
			WHEN c1.[MasterType] = 1 THEN 'Trainer'
			WHEN c1.[MasterType] = 2 THEN 'Venue'
			WHEN c1.[MasterType] = 3 THEN 'Exam'
			WHEN c1.[MasterType] IN (5,6,7) THEN 'Courseware'
			WHEN c1.[MasterType] = 8 THEN 'Manual'
			WHEN c1.[MasterType] = 9 THEN 'Travel'
			WHEN c1.[MasterType] = 11 THEN 'Invigilator'
			WHEN c1.[MasterType] IN (0,11,4) THEN 'Others'
		   END as [DocumentType],
           c1.[MasterCode] as [DocNo], '1753/01/01' as 'Document Date','' AS [Sales Order No],'' AS [Sell-to Customer No_], ''AS [Contact No_], '' AS [Salesperson Code], '' AS [Country_Region Code],
           c1.[Entry No_] as [LineNo],
		   c1.[Amount] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Actual' as [BucketType],
		   c1.[Amount] / ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[The Knowledge Academy SA$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			e.[Country Code] AS [Country],
			ISNULL((SELECT cr.[Name] FROM dbo.[The Knowledge Academy SA$Country_Region] cr WHERE cr.[Code] IN 
			(e.[Country Code])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			'ACTUAL' AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[The Knowledge Academy SA$G_L Entry] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]

LEFT OUTER JOIN dbo.[The Knowledge Academy SA$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[The Knowledge Academy SA$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >=  '2018/01/01' AND c1.[Posting Date] >= '2018/04/01'
AND c1.[G_L Account No_] LIKE '8%'  AND c1.[Event Header] <>''
UNION ALL
SELECT 'TKA Canada Corporation' as [CName],
           CASE
			WHEN c1.[MasterType] = 1 THEN 'Trainer'
			WHEN c1.[MasterType] = 2 THEN 'Venue'
			WHEN c1.[MasterType] = 3 THEN 'Exam'
			WHEN c1.[MasterType] IN (5,6,7) THEN 'Courseware'
			WHEN c1.[MasterType] = 8 THEN 'Manual'
			WHEN c1.[MasterType] = 9 THEN 'Travel'
			WHEN c1.[MasterType] = 11 THEN 'Invigilator'
			WHEN c1.[MasterType] IN (0,11,4) THEN 'Others'
		   END as [DocumentType],
           c1.[MasterCode] as [DocNo],'1753/01/01' as 'Document Date','' AS [Sales Order No], '' AS [Sell-to Customer No_], ''AS [Contact No_], '' AS [Salesperson Code], '' AS [Country_Region Code],
           c1.[Entry No_] as [LineNo],
		   c1.[Amount] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Actual' as [BucketType],
		   c1.[Amount] / ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[TKA Canada Corporation$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			e.[Country Code] AS [Country],
			ISNULL((SELECT cr.[Name] FROM dbo.[TKA Canada Corporation$Country_Region] cr WHERE cr.[Code] IN 
			(e.[Country Code])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			'ACTUAL' AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[TKA Canada Corporation$G_L Entry] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]

LEFT OUTER JOIN dbo.[TKA Canada Corporation$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[TKA Canada Corporation$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >=  '2018/01/01' AND c1.[Posting Date] >= '2018/04/01'
AND c1.[G_L Account No_] LIKE '8%'  AND c1.[Event Header] <>''
UNION ALL
SELECT 'TKA Europe' as [CName],
           CASE
			WHEN c1.[MasterType] = 1 THEN 'Trainer'
			WHEN c1.[MasterType] = 2 THEN 'Venue'
			WHEN c1.[MasterType] = 3 THEN 'Exam'
			WHEN c1.[MasterType] IN (5,6,7) THEN 'Courseware'
			WHEN c1.[MasterType] = 8 THEN 'Manual'
			WHEN c1.[MasterType] = 9 THEN 'Travel'
			WHEN c1.[MasterType] = 11 THEN 'Invigilator'
			WHEN c1.[MasterType] IN (0,11,4) THEN 'Others'
		   END as [DocumentType],
           c1.[MasterCode] as [DocNo], '1753/01/01' as 'Document Date','' AS [Sales Order No],'' AS [Sell-to Customer No_], ''AS [Contact No_], '' AS [Salesperson Code], '' AS [Country_Region Code],
           c1.[Entry No_] as [LineNo],
		   c1.[Amount] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Actual' as [BucketType],
		   c1.[Amount] / ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[TKA Europe$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			e.[Country Code] AS [Country],
			ISNULL((SELECT cr.[Name] FROM dbo.[TKA Europe$Country_Region] cr WHERE cr.[Code] IN 
			(e.[Country Code])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			'ACTUAL' AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[TKA Europe$G_L Entry] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]

LEFT OUTER JOIN dbo.[TKA Europe$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[TKA Europe$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >=  '2018/01/01' AND c1.[Posting Date] >= '2018/04/01'
AND c1.[G_L Account No_] LIKE '8%'  AND c1.[Event Header] <>''
UNION ALL
SELECT 'TKA Hong Kong Ltd.' as [CName],
           CASE
			WHEN c1.[MasterType] = 1 THEN 'Trainer'
			WHEN c1.[MasterType] = 2 THEN 'Venue'
			WHEN c1.[MasterType] = 3 THEN 'Exam'
			WHEN c1.[MasterType] IN (5,6,7) THEN 'Courseware'
			WHEN c1.[MasterType] = 8 THEN 'Manual'
			WHEN c1.[MasterType] = 9 THEN 'Travel'
			WHEN c1.[MasterType] = 11 THEN 'Invigilator'
			WHEN c1.[MasterType] IN (0,11,4) THEN 'Others'
		   END as [DocumentType],
           c1.[MasterCode] as [DocNo], '1753/01/01' as 'Document Date','' AS [Sales Order No],'' AS [Sell-to Customer No_], ''AS [Contact No_], '' AS [Salesperson Code], '' AS [Country_Region Code],
           c1.[Entry No_] as [LineNo],
		   c1.[Amount] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Actual' as [BucketType],
		   c1.[Amount] / ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[TKA Hong Kong Ltd_$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			e.[Country Code] AS [Country],
			ISNULL((SELECT cr.[Name] FROM dbo.[TKA Hong Kong Ltd_$Country_Region] cr WHERE cr.[Code] IN 
			(e.[Country Code])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			'ACTUAL' AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[TKA Hong Kong Ltd_$G_L Entry] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]

LEFT OUTER JOIN dbo.[TKA Hong Kong Ltd_$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[TKA Hong Kong Ltd_$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >=  '2018/01/01' AND c1.[Posting Date] >= '2018/04/01'
AND c1.[G_L Account No_] LIKE '8%'  AND c1.[Event Header] <>'' 
UNION ALL
SELECT 'TKA New Zealand Ltd.' as [CName],
           CASE
			WHEN c1.[MasterType] = 1 THEN 'Trainer'
			WHEN c1.[MasterType] = 2 THEN 'Venue'
			WHEN c1.[MasterType] = 3 THEN 'Exam'
			WHEN c1.[MasterType] IN (5,6,7) THEN 'Courseware'
			WHEN c1.[MasterType] = 8 THEN 'Manual'
			WHEN c1.[MasterType] = 9 THEN 'Travel'
			WHEN c1.[MasterType] = 11 THEN 'Invigilator'
			WHEN c1.[MasterType] IN (0,11,4) THEN 'Others'
		   END as [DocumentType],
           c1.[MasterCode] as [DocNo], '1753/01/01' as 'Document Date','' AS [Sales Order No],'' AS [Sell-to Customer No_], ''AS [Contact No_], '' AS [Salesperson Code], '' AS [Country_Region Code],
           c1.[Entry No_] as [LineNo],
		   c1.[Amount] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Actual' as [BucketType],
		   c1.[Amount] / ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[TKA New Zealand Ltd_$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			e.[Country Code] AS [Country],
			ISNULL((SELECT cr.[Name] FROM dbo.[TKA New Zealand Ltd_$Country_Region] cr WHERE cr.[Code] IN 
			(e.[Country Code])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			'ACTUAL' AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[TKA New Zealand Ltd_$G_L Entry] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]

LEFT OUTER JOIN dbo.[TKA New Zealand Ltd_$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[TKA New Zealand Ltd_$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >=  '2018/01/01' AND c1.[Posting Date] >= '2018/04/01'
AND c1.[G_L Account No_] LIKE '8%'  AND c1.[Event Header] <>''
UNION ALL
SELECT 'TKA Singapore PTE Ltd.' as [CName],
           CASE
			WHEN c1.[MasterType] = 1 THEN 'Trainer'
			WHEN c1.[MasterType] = 2 THEN 'Venue'
			WHEN c1.[MasterType] = 3 THEN 'Exam'
			WHEN c1.[MasterType] IN (5,6,7) THEN 'Courseware'
			WHEN c1.[MasterType] = 8 THEN 'Manual'
			WHEN c1.[MasterType] = 9 THEN 'Travel'
			WHEN c1.[MasterType] = 11 THEN 'Invigilator'
			WHEN c1.[MasterType] IN (0,11,4) THEN 'Others'
		   END as [DocumentType],
           c1.[MasterCode] as [DocNo], '1753/01/01' as 'Document Date','' AS [Sales Order No],'' AS [Sell-to Customer No_], ''AS [Contact No_], '' AS [Salesperson Code], '' AS [Country_Region Code],
           c1.[Entry No_] as [LineNo],
		   c1.[Amount] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Actual' as [BucketType],
		   c1.[Amount] / ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[TKA Singapore PTE Ltd_$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			e.[Country Code] AS [Country],
			ISNULL((SELECT cr.[Name] FROM dbo.[TKA Singapore PTE Ltd_$Country_Region] cr WHERE cr.[Code] IN 
			(e.[Country Code])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			'ACTUAL' AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[TKA Singapore PTE Ltd_$G_L Entry] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]

LEFT OUTER JOIN dbo.[TKA Singapore PTE Ltd_$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[TKA Singapore PTE Ltd_$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >=  '2018/01/01' AND c1.[Posting Date] >= '2018/04/01'
AND c1.[G_L Account No_] LIKE '8%'  AND c1.[Event Header] <>''
UNION ALL
---ITIL
SELECT 'ITIL Training Academy' as [CName],
           CASE
			WHEN c1.[MasterType] = 1 THEN 'Trainer'
			WHEN c1.[MasterType] = 2 THEN 'Venue'
			WHEN c1.[MasterType] = 3 THEN 'Exam'
			WHEN c1.[MasterType] IN (5,6,7) THEN 'Courseware'
			WHEN c1.[MasterType] = 8 THEN 'Manual'
			WHEN c1.[MasterType] = 9 THEN 'Travel'
			WHEN c1.[MasterType] = 11 THEN 'Invigilator'
			WHEN c1.[MasterType] IN (0,11,4) THEN 'Others'
		   END as [DocumentType],
           c1.[MasterCode] as [DocNo], '1753/01/01' as 'Document Date','' AS [Sales Order No],'' AS [Sell-to Customer No_], ''AS [Contact No_], '' AS [Salesperson Code], '' AS [Country_Region Code],
           c1.[Entry No_] as [LineNo],
		   c1.[Amount] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Actual' as [BucketType],
		   c1.[Amount] / ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[ITIL Training Academy$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			e.[Country Code] AS [Country],
			ISNULL((SELECT cr.[Name] FROM dbo.[ITIL Training Academy$Country_Region] cr WHERE cr.[Code] IN 
			(e.[Country Code])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			'ACTUAL' AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[ITIL Training Academy$G_L Entry] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]

LEFT OUTER JOIN dbo.[ITIL Training Academy$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[ITIL Training Academy$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >=  '2018/01/01' AND c1.[Posting Date] >= '2018/04/01'
AND c1.[G_L Account No_] LIKE '8%' AND c1.[Event Header] <>''
UNION ALL

---Pearce Mayfield Train Dubai
SELECT 'Pearce Mayfield Train Dubai' as [CName],
           CASE
			WHEN c1.[MasterType] = 1 THEN 'Trainer'
			WHEN c1.[MasterType] = 2 THEN 'Venue'
			WHEN c1.[MasterType] = 3 THEN 'Exam'
			WHEN c1.[MasterType] IN (5,6,7) THEN 'Courseware'
			WHEN c1.[MasterType] = 8 THEN 'Manual'
			WHEN c1.[MasterType] = 9 THEN 'Travel'
			WHEN c1.[MasterType] = 11 THEN 'Invigilator'
			WHEN c1.[MasterType] IN (0,11,4) THEN 'Others'
		   END as [DocumentType],
           c1.[MasterCode] as [DocNo], '1753/01/01' as 'Document Date','' AS [Sales Order No],'' AS [Sell-to Customer No_], ''AS [Contact No_], '' AS [Salesperson Code], '' AS [Country_Region Code],
           c1.[Entry No_] as [LineNo],
		   c1.[Amount] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Actual' as [BucketType],
		   c1.[Amount] / ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[Pearce Mayfield Train Dubai$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			e.[Country Code] AS [Country],
			ISNULL((SELECT cr.[Name] FROM dbo.[Pearce Mayfield Train Dubai$Country_Region] cr WHERE cr.[Code] IN 
			(e.[Country Code])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			'ACTUAL' AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[Pearce Mayfield Train Dubai$G_L Entry] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]

LEFT OUTER JOIN dbo.[Pearce Mayfield Train Dubai$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[Pearce Mayfield Train Dubai$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >=  '2018/01/01' AND c1.[Posting Date] >= '2018/04/01'
AND c1.[G_L Account No_] LIKE '8%' AND c1.[Event Header] <>''
UNION ALL

SELECT 'The Knowledge Academy Limited' as [CName],
           CASE
			WHEN c1.[MasterType] = 1 THEN 'Trainer'
			WHEN c1.[MasterType] = 2 THEN 'Venue'
			WHEN c1.[MasterType] = 3 THEN 'Exam'
			WHEN c1.[MasterType] IN (5,6,7) THEN 'Courseware'
			WHEN c1.[MasterType] = 8 THEN 'Manual'
			WHEN c1.[MasterType] = 9 THEN 'Travel'
			WHEN c1.[MasterType] = 11 THEN 'Invigilator'
			WHEN c1.[MasterType] IN (12,4) THEN 'Others'
		   END as [DocumentType],
           c1.[MasterCode] as [DocNo],'1753/01/01' as 'Document Date','' AS [Sales Order No], '' AS [Sell-to Customer No_], ''AS [Contact No_], '' AS [Salesperson Code], '' AS [Country_Region Code],
           c1.[Entry No_] as [LineNo],
		   c1.[Amount] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Actual' as [BucketType],
		   c1.[AmountLCY]	/ ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[The Knowledge Academy Limited$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			e.[Country Code] AS [Country],
			ISNULL((SELECT cr.[Name] FROM dbo.[The Knowledge Academy Limited$Country_Region] cr WHERE cr.[Code] IN 
			(e.[Country Code])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			'ACTUAL' AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[The Knowledge Academy Limited$Event Cost Heads] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]

LEFT OUTER JOIN dbo.[The Knowledge Academy Limited$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[The Knowledge Academy Limited$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >=  '2018/01/01'
AND c1.[Applicable] = 1
AND e.[MarginApproval] = 1
AND ((NOT EXISTS ( SELECT 1 from dbo.[The Knowledge Academy Limited$Purchase Line] p 
					WHERE p.[Event No_] = c1.[Event Header] AND p.[Event Cost Line No_] = c1.[Entry No_])) AND
	(NOT EXISTS ( SELECT 1 from dbo.[The Knowledge Academy Limited$Purch_ Inv_ Line] pp 
					WHERE pp.[Event No_] = c1.[Event Header] AND pp.[Event Cost Line No_] = c1.[Entry No_]))) 
UNION ALL
SELECT 'The Knowledge Academy Inc' as [CName],
           CASE
			WHEN c1.[MasterType] = 1 THEN 'Trainer'
			WHEN c1.[MasterType] = 2 THEN 'Venue'
			WHEN c1.[MasterType] = 3 THEN 'Exam'
			WHEN c1.[MasterType] IN (5,6,7) THEN 'Courseware'
			WHEN c1.[MasterType] = 8 THEN 'Manual'
			WHEN c1.[MasterType] = 9 THEN 'Travel'
			WHEN c1.[MasterType] = 11 THEN 'Invigilator'
			WHEN c1.[MasterType] IN (12,4) THEN 'Others'
		   END as [DocumentType],
           c1.[MasterCode] as [DocNo], '1753/01/01' as 'Document Date','' AS [Sales Order No],'' AS [Sell-to Customer No_], ''AS [Contact No_], '' AS [Salesperson Code], '' AS [Country_Region Code],
           c1.[Entry No_] as [LineNo],
		   c1.[Amount] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Actual' as [BucketType],
		   c1.[AmountLCY]	/ ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[The Knowledge Academy Inc$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			e.[Country Code] AS [Country],
			ISNULL((SELECT cr.[Name] FROM dbo.[The Knowledge Academy Inc$Country_Region] cr WHERE cr.[Code] IN 
			(e.[Country Code])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			'ACTUAL' AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[The Knowledge Academy Inc$Event Cost Heads] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]

LEFT OUTER JOIN dbo.[The Knowledge Academy Inc$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[The Knowledge Academy Inc$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >= '2018/01/01'
AND c1.[Applicable] = 1
AND e.[MarginApproval] = 1
AND ((NOT EXISTS ( SELECT 1 from dbo.[The Knowledge Academy Inc$Purchase Line] p 
					WHERE p.[Event No_] = c1.[Event Header] AND p.[Event Cost Line No_] = c1.[Entry No_])) AND
	(NOT EXISTS ( SELECT 1 from dbo.[The Knowledge Academy Inc$Purch_ Inv_ Line] pp 
					WHERE pp.[Event No_] = c1.[Event Header] AND pp.[Event Cost Line No_] = c1.[Entry No_]))) 
UNION ALL
SELECT 'Best Practice Training Ltd.' as [CName],
           CASE
			WHEN c1.[MasterType] = 1 THEN 'Trainer'
			WHEN c1.[MasterType] = 2 THEN 'Venue'
			WHEN c1.[MasterType] = 3 THEN 'Exam'
			WHEN c1.[MasterType] IN (5,6,7) THEN 'Courseware'
			WHEN c1.[MasterType] = 8 THEN 'Manual'
			WHEN c1.[MasterType] = 9 THEN 'Travel'
			WHEN c1.[MasterType] = 11 THEN 'Invigilator'
			WHEN c1.[MasterType] IN (12,4) THEN 'Others'
		   END as [DocumentType],
           c1.[MasterCode] as [DocNo], '1753/01/01' as 'Document Date','' AS [Sales Order No],'' AS [Sell-to Customer No_], ''AS [Contact No_], '' AS [Salesperson Code], '' AS [Country_Region Code],
           c1.[Entry No_] as [LineNo],
		   c1.[Amount] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Actual' as [BucketType],
		   c1.[AmountLCY]	/ ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[Best Practice Training Ltd_$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			e.[Country Code] AS [Country],
			ISNULL((SELECT cr.[Name] FROM dbo.[Best Practice Training Ltd_$Country_Region] cr WHERE cr.[Code] IN 
			(e.[Country Code])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			'ACTUAL' AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[Best Practice Training Ltd_$Event Cost Heads] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]

LEFT OUTER JOIN dbo.[Best Practice Training Ltd_$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[Best Practice Training Ltd_$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >= '2018/01/01'
AND c1.[Applicable] = 1
AND e.[MarginApproval] = 1
AND ((NOT EXISTS ( SELECT 1 from dbo.[Best Practice Training Ltd_$Purchase Line] p 
					WHERE p.[Event No_] = c1.[Event Header] AND p.[Event Cost Line No_] = c1.[Entry No_])) AND
	(NOT EXISTS ( SELECT 1 from dbo.[Best Practice Training Ltd_$Purch_ Inv_ Line] pp 
					WHERE pp.[Event No_] = c1.[Event Header] AND pp.[Event Cost Line No_] = c1.[Entry No_]))) 
UNION ALL
SELECT 'Datrix Learning Services Ltd.' as [CName],
           CASE
			WHEN c1.[MasterType] = 1 THEN 'Trainer'
			WHEN c1.[MasterType] = 2 THEN 'Venue'
			WHEN c1.[MasterType] = 3 THEN 'Exam'
			WHEN c1.[MasterType] IN (5,6,7) THEN 'Courseware'
			WHEN c1.[MasterType] = 8 THEN 'Manual'
			WHEN c1.[MasterType] = 9 THEN 'Travel'
			WHEN c1.[MasterType] = 11 THEN 'Invigilator'
			WHEN c1.[MasterType] IN (12,4) THEN 'Others'
		   END as [DocumentType],
           c1.[MasterCode] as [DocNo], '1753/01/01' as 'Document Date','' AS [Sales Order No],'' AS [Sell-to Customer No_], ''AS [Contact No_], '' AS [Salesperson Code], '' AS [Country_Region Code],
           c1.[Entry No_] as [LineNo],
		   c1.[Amount] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Actual' as [BucketType],
		   c1.[AmountLCY]	/ ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[Datrix Learning Services Ltd_$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			e.[Country Code] AS [Country],
			ISNULL((SELECT cr.[Name] FROM dbo.[Datrix Learning Services Ltd_$Country_Region] cr WHERE cr.[Code] IN 
			(e.[Country Code])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			'ACTUAL' AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[Datrix Learning Services Ltd_$Event Cost Heads] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]

LEFT OUTER JOIN dbo.[Datrix Learning Services Ltd_$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[Datrix Learning Services Ltd_$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >= '2018/01/01'
AND c1.[Applicable] = 1
AND e.[MarginApproval] = 1
AND ((NOT EXISTS ( SELECT 1 from dbo.[Datrix Learning Services Ltd_$Purchase Line] p 
					WHERE p.[Event No_] = c1.[Event Header] AND p.[Event Cost Line No_] = c1.[Entry No_])) AND
	(NOT EXISTS ( SELECT 1 from dbo.[Datrix Learning Services Ltd_$Purch_ Inv_ Line] pp 
					WHERE pp.[Event No_] = c1.[Event Header] AND pp.[Event Cost Line No_] = c1.[Entry No_]))) 
UNION ALL
SELECT 'Pearce Mayfield Training Ltd' as [CName],
           CASE
			WHEN c1.[MasterType] = 1 THEN 'Trainer'
			WHEN c1.[MasterType] = 2 THEN 'Venue'
			WHEN c1.[MasterType] = 3 THEN 'Exam'
			WHEN c1.[MasterType] IN (5,6,7) THEN 'Courseware'
			WHEN c1.[MasterType] = 8 THEN 'Manual'
			WHEN c1.[MasterType] = 9 THEN 'Travel'
			WHEN c1.[MasterType] = 11 THEN 'Invigilator'
			WHEN c1.[MasterType] IN (12,4) THEN 'Others'
		   END as [DocumentType],
           c1.[MasterCode] as [DocNo], '1753/01/01' as 'Document Date','' AS [Sales Order No],'' AS [Sell-to Customer No_], ''AS [Contact No_], '' AS [Salesperson Code], '' AS [Country_Region Code],
           c1.[Entry No_] as [LineNo],
		   c1.[Amount] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Actual' as [BucketType],
		   c1.[AmountLCY]	/ ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[Pearce Mayfield Training Ltd$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			e.[Country Code] AS [Country],
			ISNULL((SELECT cr.[Name] FROM dbo.[Pearce Mayfield Training Ltd$Country_Region] cr WHERE cr.[Code] IN 
			(e.[Country Code])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			'ACTUAL' AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[Pearce Mayfield Training Ltd$Event Cost Heads] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]

LEFT OUTER JOIN dbo.[Pearce Mayfield Training Ltd$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[Pearce Mayfield Training Ltd$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >= '2018/01/01'
AND c1.[Applicable] = 1
AND e.[MarginApproval] = 1
AND ((NOT EXISTS ( SELECT 1 from dbo.[Pearce Mayfield Training Ltd$Purchase Line] p 
					WHERE p.[Event No_] = c1.[Event Header] AND p.[Event Cost Line No_] = c1.[Entry No_])) AND
	(NOT EXISTS ( SELECT 1 from dbo.[Pearce Mayfield Training Ltd$Purch_ Inv_ Line] pp 
					WHERE pp.[Event No_] = c1.[Event Header] AND pp.[Event Cost Line No_] = c1.[Entry No_]))) 
UNION ALL
SELECT 'Pentagon Leisure Services Ltd' as [CName],
           CASE
			WHEN c1.[MasterType] = 1 THEN 'Trainer'
			WHEN c1.[MasterType] = 2 THEN 'Venue'
			WHEN c1.[MasterType] = 3 THEN 'Exam'
			WHEN c1.[MasterType] IN (5,6,7) THEN 'Courseware'
			WHEN c1.[MasterType] = 8 THEN 'Manual'
			WHEN c1.[MasterType] = 9 THEN 'Travel'
			WHEN c1.[MasterType] = 11 THEN 'Invigilator'
			WHEN c1.[MasterType] IN (12,4) THEN 'Others'
		   END as [DocumentType],
           c1.[MasterCode] as [DocNo], '1753/01/01' as 'Document Date','' AS [Sales Order No],'' AS [Sell-to Customer No_], ''AS [Contact No_], '' AS [Salesperson Code], '' AS [Country_Region Code],
           c1.[Entry No_] as [LineNo],
		   c1.[Amount] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Actual' as [BucketType],
		   c1.[AmountLCY]	/ ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[Pentagon Leisure Services Ltd$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			e.[Country Code] AS [Country],
			ISNULL((SELECT cr.[Name] FROM dbo.[Pentagon Leisure Services Ltd$Country_Region] cr WHERE cr.[Code] IN 
			(e.[Country Code])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			'ACTUAL' AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[Pentagon Leisure Services Ltd$Event Cost Heads] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]

LEFT OUTER JOIN dbo.[Pentagon Leisure Services Ltd$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[Pentagon Leisure Services Ltd$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >= '2018/01/01'
AND c1.[Applicable] = 1
AND e.[MarginApproval] = 1
AND ((NOT EXISTS ( SELECT 1 from dbo.[Pentagon Leisure Services Ltd$Purchase Line] p 
					WHERE p.[Event No_] = c1.[Event Header] AND p.[Event Cost Line No_] = c1.[Entry No_])) AND
	(NOT EXISTS ( SELECT 1 from dbo.[Pentagon Leisure Services Ltd$Purch_ Inv_ Line] pp 
					WHERE pp.[Event No_] = c1.[Event Header] AND pp.[Event Cost Line No_] = c1.[Entry No_]))) 
UNION ALL
SELECT 'Silicon Beach Training' as [CName],
           CASE
			WHEN c1.[MasterType] = 1 THEN 'Trainer'
			WHEN c1.[MasterType] = 2 THEN 'Venue'
			WHEN c1.[MasterType] = 3 THEN 'Exam'
			WHEN c1.[MasterType] IN (5,6,7) THEN 'Courseware'
			WHEN c1.[MasterType] = 8 THEN 'Manual'
			WHEN c1.[MasterType] = 9 THEN 'Travel'
			WHEN c1.[MasterType] = 11 THEN 'Invigilator'
			WHEN c1.[MasterType] IN (12,4) THEN 'Others'
		   END as [DocumentType],
           c1.[MasterCode] as [DocNo],'1753/01/01' as 'Document Date','' AS [Sales Order No], '' AS [Sell-to Customer No_], ''AS [Contact No_], '' AS [Salesperson Code], '' AS [Country_Region Code],
           c1.[Entry No_] as [LineNo],
		   c1.[Amount] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Actual' as [BucketType],
		   c1.[AmountLCY]	/ ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[Silicon Beach Training$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			e.[Country Code] AS [Country],
			ISNULL((SELECT cr.[Name] FROM dbo.[Silicon Beach Training$Country_Region] cr WHERE cr.[Code] IN 
			(e.[Country Code])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			'ACTUAL' AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[Silicon Beach Training$Event Cost Heads] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]

LEFT OUTER JOIN dbo.[Silicon Beach Training$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[Silicon Beach Training$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >= '2018/01/01'
AND c1.[Applicable] = 1
AND e.[MarginApproval] = 1
AND ((NOT EXISTS ( SELECT 1 from dbo.[Silicon Beach Training$Purchase Line] p 
					WHERE p.[Event No_] = c1.[Event Header] AND p.[Event Cost Line No_] = c1.[Entry No_])) AND
	(NOT EXISTS ( SELECT 1 from dbo.[Silicon Beach Training$Purch_ Inv_ Line] pp 
					WHERE pp.[Event No_] = c1.[Event Header] AND pp.[Event Cost Line No_] = c1.[Entry No_]))) 
UNION ALL
SELECT 'The Knowledge Academy Pty Ltd.' as [CName],
           CASE
			WHEN c1.[MasterType] = 1 THEN 'Trainer'
			WHEN c1.[MasterType] = 2 THEN 'Venue'
			WHEN c1.[MasterType] = 3 THEN 'Exam'
			WHEN c1.[MasterType] IN (5,6,7) THEN 'Courseware'
			WHEN c1.[MasterType] = 8 THEN 'Manual'
			WHEN c1.[MasterType] = 9 THEN 'Travel'
			WHEN c1.[MasterType] = 11 THEN 'Invigilator'
			WHEN c1.[MasterType] IN (12,4) THEN 'Others'
		   END as [DocumentType],
           c1.[MasterCode] as [DocNo],'1753/01/01' as 'Document Date','' AS [Sales Order No], '' AS [Sell-to Customer No_], ''AS [Contact No_], '' AS [Salesperson Code], '' AS [Country_Region Code],
           c1.[Entry No_] as [LineNo],
		   c1.[Amount] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Actual' as [BucketType],
		   c1.[AmountLCY]	/ ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[The Knowledge Academy Pty Ltd_$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			e.[Country Code] AS [Country],
			ISNULL((SELECT cr.[Name] FROM dbo.[The Knowledge Academy Pty Ltd_$Country_Region] cr WHERE cr.[Code] IN 
			(e.[Country Code])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			'ACTUAL' AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[The Knowledge Academy Pty Ltd_$Event Cost Heads] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]

LEFT OUTER JOIN dbo.[The Knowledge Academy Pty Ltd_$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[The Knowledge Academy Pty Ltd_$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >= '2018/01/01'
AND c1.[Applicable] = 1
AND e.[MarginApproval] = 1
AND ((NOT EXISTS ( SELECT 1 from dbo.[The Knowledge Academy Pty Ltd_$Purchase Line] p 
					WHERE p.[Event No_] = c1.[Event Header] AND p.[Event Cost Line No_] = c1.[Entry No_])) AND
	(NOT EXISTS ( SELECT 1 from dbo.[The Knowledge Academy Pty Ltd_$Purch_ Inv_ Line] pp 
					WHERE pp.[Event No_] = c1.[Event Header] AND pp.[Event Cost Line No_] = c1.[Entry No_]))) 
UNION ALL
SELECT 'The Knowledge Academy SA' as [CName],
           CASE
			WHEN c1.[MasterType] = 1 THEN 'Trainer'
			WHEN c1.[MasterType] = 2 THEN 'Venue'
			WHEN c1.[MasterType] = 3 THEN 'Exam'
			WHEN c1.[MasterType] IN (5,6,7) THEN 'Courseware'
			WHEN c1.[MasterType] = 8 THEN 'Manual'
			WHEN c1.[MasterType] = 9 THEN 'Travel'
			WHEN c1.[MasterType] = 11 THEN 'Invigilator'
			WHEN c1.[MasterType] IN (12,4) THEN 'Others'
		   END as [DocumentType],
           c1.[MasterCode] as [DocNo], '1753/01/01' as 'Document Date','' AS [Sales Order No],'' AS [Sell-to Customer No_], ''AS [Contact No_], '' AS [Salesperson Code], '' AS [Country_Region Code],
           c1.[Entry No_] as [LineNo],
		   c1.[Amount] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Actual' as [BucketType],
		   c1.[AmountLCY]	/ ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[The Knowledge Academy SA$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			e.[Country Code] AS [Country],
			ISNULL((SELECT cr.[Name] FROM dbo.[The Knowledge Academy SA$Country_Region] cr WHERE cr.[Code] IN 
			(e.[Country Code])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			'ACTUAL' AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[The Knowledge Academy SA$Event Cost Heads] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]

LEFT OUTER JOIN dbo.[The Knowledge Academy SA$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[The Knowledge Academy SA$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >= '2018/01/01'
AND c1.[Applicable] = 1
AND e.[MarginApproval] = 1
AND ((NOT EXISTS ( SELECT 1 from dbo.[The Knowledge Academy SA$Purchase Line] p 
					WHERE p.[Event No_] = c1.[Event Header] AND p.[Event Cost Line No_] = c1.[Entry No_])) AND
	(NOT EXISTS ( SELECT 1 from dbo.[The Knowledge Academy SA$Purch_ Inv_ Line] pp 
					WHERE pp.[Event No_] = c1.[Event Header] AND pp.[Event Cost Line No_] = c1.[Entry No_]))) 
UNION ALL
SELECT 'TKA Canada Corporation' as [CName],
           CASE
			WHEN c1.[MasterType] = 1 THEN 'Trainer'
			WHEN c1.[MasterType] = 2 THEN 'Venue'
			WHEN c1.[MasterType] = 3 THEN 'Exam'
			WHEN c1.[MasterType] IN (5,6,7) THEN 'Courseware'
			WHEN c1.[MasterType] = 8 THEN 'Manual'
			WHEN c1.[MasterType] = 9 THEN 'Travel'
			WHEN c1.[MasterType] = 11 THEN 'Invigilator'
			WHEN c1.[MasterType] IN (12,4) THEN 'Others'
		   END as [DocumentType],
           c1.[MasterCode] as [DocNo],'1753/01/01' as 'Document Date','' AS [Sales Order No], '' AS [Sell-to Customer No_], ''AS [Contact No_], '' AS [Salesperson Code], '' AS [Country_Region Code],
           c1.[Entry No_] as [LineNo],
		   c1.[Amount] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Actual' as [BucketType],
		   c1.[AmountLCY]	/ ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[TKA Canada Corporation$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			e.[Country Code] AS [Country],
			ISNULL((SELECT cr.[Name] FROM dbo.[TKA Canada Corporation$Country_Region] cr WHERE cr.[Code] IN 
			(e.[Country Code])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			'ACTUAL' AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[TKA Canada Corporation$Event Cost Heads] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]

LEFT OUTER JOIN dbo.[TKA Canada Corporation$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[TKA Canada Corporation$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >= '2018/01/01'
AND c1.[Applicable] = 1
AND e.[MarginApproval] = 1
AND ((NOT EXISTS ( SELECT 1 from dbo.[TKA Canada Corporation$Purchase Line] p 
					WHERE p.[Event No_] = c1.[Event Header] AND p.[Event Cost Line No_] = c1.[Entry No_])) AND
	(NOT EXISTS ( SELECT 1 from dbo.[TKA Canada Corporation$Purch_ Inv_ Line] pp 
					WHERE pp.[Event No_] = c1.[Event Header] AND pp.[Event Cost Line No_] = c1.[Entry No_]))) 
UNION ALL
SELECT 'TKA Europe' as [CName],
           CASE
			WHEN c1.[MasterType] = 1 THEN 'Trainer'
			WHEN c1.[MasterType] = 2 THEN 'Venue'
			WHEN c1.[MasterType] = 3 THEN 'Exam'
			WHEN c1.[MasterType] IN (5,6,7) THEN 'Courseware'
			WHEN c1.[MasterType] = 8 THEN 'Manual'
			WHEN c1.[MasterType] = 9 THEN 'Travel'
			WHEN c1.[MasterType] = 11 THEN 'Invigilator'
			WHEN c1.[MasterType] IN (12,4) THEN 'Others'
		   END as [DocumentType],
           c1.[MasterCode] as [DocNo],'1753/01/01' as 'Document Date','' AS [Sales Order No], '' AS [Sell-to Customer No_], ''AS [Contact No_], '' AS [Salesperson Code], '' AS [Country_Region Code],
           c1.[Entry No_] as [LineNo],
		   c1.[Amount] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Actual' as [BucketType],
		   c1.[AmountLCY]	/ ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[TKA Europe$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			e.[Country Code] AS [Country],
			ISNULL((SELECT cr.[Name] FROM dbo.[TKA Europe$Country_Region] cr WHERE cr.[Code] IN 
			(e.[Country Code])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			'ACTUAL' AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[TKA Europe$Event Cost Heads] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]

LEFT OUTER JOIN dbo.[TKA Europe$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[TKA Europe$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >= '2018/01/01'
AND c1.[Applicable] = 1
AND e.[MarginApproval] = 1
AND ((NOT EXISTS ( SELECT 1 from dbo.[TKA Europe$Purchase Line] p 
					WHERE p.[Event No_] = c1.[Event Header] AND p.[Event Cost Line No_] = c1.[Entry No_])) AND
	(NOT EXISTS ( SELECT 1 from dbo.[TKA Europe$Purch_ Inv_ Line] pp 
					WHERE pp.[Event No_] = c1.[Event Header] AND pp.[Event Cost Line No_] = c1.[Entry No_]))) 
UNION ALL
SELECT 'TKA Hong Kong Ltd.' as [CName],
           CASE
			WHEN c1.[MasterType] = 1 THEN 'Trainer'
			WHEN c1.[MasterType] = 2 THEN 'Venue'
			WHEN c1.[MasterType] = 3 THEN 'Exam'
			WHEN c1.[MasterType] IN (5,6,7) THEN 'Courseware'
			WHEN c1.[MasterType] = 8 THEN 'Manual'
			WHEN c1.[MasterType] = 9 THEN 'Travel'
			WHEN c1.[MasterType] = 11 THEN 'Invigilator'
			WHEN c1.[MasterType] IN (12,4) THEN 'Others'
		   END as [DocumentType],
           c1.[MasterCode] as [DocNo],'1753/01/01' as 'Document Date','' AS [Sales Order No], '' AS [Sell-to Customer No_], ''AS [Contact No_], '' AS [Salesperson Code], '' AS [Country_Region Code],
           c1.[Entry No_] as [LineNo],
		   c1.[Amount] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Actual' as [BucketType],
		   c1.[AmountLCY]	/ ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[TKA Hong Kong Ltd_$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			e.[Country Code] AS [Country],
			ISNULL((SELECT cr.[Name] FROM dbo.[TKA Hong Kong Ltd_$Country_Region] cr WHERE cr.[Code] IN 
			(e.[Country Code])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			'ACTUAL' AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[TKA Hong Kong Ltd_$Event Cost Heads] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]

LEFT OUTER JOIN dbo.[TKA Hong Kong Ltd_$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[TKA Hong Kong Ltd_$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >= '2018/01/01'
AND c1.[Applicable] = 1
AND e.[MarginApproval] = 1
AND ((NOT EXISTS ( SELECT 1 from dbo.[TKA Hong Kong Ltd_$Purchase Line] p 
					WHERE p.[Event No_] = c1.[Event Header] AND p.[Event Cost Line No_] = c1.[Entry No_])) AND
	(NOT EXISTS ( SELECT 1 from dbo.[TKA Hong Kong Ltd_$Purch_ Inv_ Line] pp 
					WHERE pp.[Event No_] = c1.[Event Header] AND pp.[Event Cost Line No_] = c1.[Entry No_]))) 
UNION ALL
SELECT 'TKA New Zealand Ltd.' as [CName],
           CASE
			WHEN c1.[MasterType] = 1 THEN 'Trainer'
			WHEN c1.[MasterType] = 2 THEN 'Venue'
			WHEN c1.[MasterType] = 3 THEN 'Exam'
			WHEN c1.[MasterType] IN (5,6,7) THEN 'Courseware'
			WHEN c1.[MasterType] = 8 THEN 'Manual'
			WHEN c1.[MasterType] = 9 THEN 'Travel'
			WHEN c1.[MasterType] = 11 THEN 'Invigilator'
			WHEN c1.[MasterType] IN (12,4) THEN 'Others'
		   END as [DocumentType],
           c1.[MasterCode] as [DocNo], '1753/01/01' as 'Document Date','' AS [Sales Order No],'' AS [Sell-to Customer No_], ''AS [Contact No_], '' AS [Salesperson Code], '' AS [Country_Region Code],
           c1.[Entry No_] as [LineNo],
		   c1.[Amount] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Actual' as [BucketType],
		   c1.[AmountLCY]	/ ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[TKA New Zealand Ltd_$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			e.[Country Code] AS [Country],
			ISNULL((SELECT cr.[Name] FROM dbo.[TKA New Zealand Ltd_$Country_Region] cr WHERE cr.[Code] IN 
			(e.[Country Code])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			'ACTUAL' AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[TKA New Zealand Ltd_$Event Cost Heads] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]

LEFT OUTER JOIN dbo.[TKA New Zealand Ltd_$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[TKA New Zealand Ltd_$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >= '2018/01/01'
AND c1.[Applicable] = 1
AND e.[MarginApproval] = 1
AND ((NOT EXISTS ( SELECT 1 from dbo.[TKA New Zealand Ltd_$Purchase Line] p 
					WHERE p.[Event No_] = c1.[Event Header] AND p.[Event Cost Line No_] = c1.[Entry No_])) AND
	(NOT EXISTS ( SELECT 1 from dbo.[TKA New Zealand Ltd_$Purch_ Inv_ Line] pp 
					WHERE pp.[Event No_] = c1.[Event Header] AND pp.[Event Cost Line No_] = c1.[Entry No_]))) 
UNION ALL
SELECT 'TKA Singapore PTE Ltd.' as [CName],
           CASE
			WHEN c1.[MasterType] = 1 THEN 'Trainer'
			WHEN c1.[MasterType] = 2 THEN 'Venue'
			WHEN c1.[MasterType] = 3 THEN 'Exam'
			WHEN c1.[MasterType] IN (5,6,7) THEN 'Courseware'
			WHEN c1.[MasterType] = 8 THEN 'Manual'
			WHEN c1.[MasterType] = 9 THEN 'Travel'
			WHEN c1.[MasterType] = 11 THEN 'Invigilator'
			WHEN c1.[MasterType] IN (12,4) THEN 'Others'
		   END as [DocumentType],
           c1.[MasterCode] as [DocNo], '1753/01/01' as 'Document Date','' AS [Sales Order No],'' AS [Sell-to Customer No_], ''AS [Contact No_], '' AS [Salesperson Code], '' AS [Country_Region Code],
           c1.[Entry No_] as [LineNo],
		   c1.[Amount] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Actual' as [BucketType],
		   c1.[AmountLCY]	/ ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[TKA Singapore PTE Ltd_$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			e.[Country Code] AS [Country],
			ISNULL((SELECT cr.[Name] FROM dbo.[TKA Singapore PTE Ltd_$Country_Region] cr WHERE cr.[Code] IN 
			(e.[Country Code])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			'ACTUAL' AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[TKA Singapore PTE Ltd_$Event Cost Heads] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]

LEFT OUTER JOIN dbo.[TKA Singapore PTE Ltd_$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[TKA Singapore PTE Ltd_$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >= '2018/01/01'
AND c1.[Applicable] = 1
AND e.[MarginApproval] = 1
AND ((NOT EXISTS ( SELECT 1 from dbo.[TKA Singapore PTE Ltd_$Purchase Line] p 
					WHERE p.[Event No_] = c1.[Event Header] AND p.[Event Cost Line No_] = c1.[Entry No_])) AND
	(NOT EXISTS ( SELECT 1 from dbo.[TKA Singapore PTE Ltd_$Purch_ Inv_ Line] pp 
					WHERE pp.[Event No_] = c1.[Event Header] AND pp.[Event Cost Line No_] = c1.[Entry No_]))) 

UNION ALL
SELECT 'ITIL Training Academy' as [CName],
           CASE
			WHEN c1.[MasterType] = 1 THEN 'Trainer'
			WHEN c1.[MasterType] = 2 THEN 'Venue'
			WHEN c1.[MasterType] = 3 THEN 'Exam'
			WHEN c1.[MasterType] IN (5,6,7) THEN 'Courseware'
			WHEN c1.[MasterType] = 8 THEN 'Manual'
			WHEN c1.[MasterType] = 9 THEN 'Travel'
			WHEN c1.[MasterType] = 11 THEN 'Invigilator'
			WHEN c1.[MasterType] IN (12,4) THEN 'Others'
		   END as [DocumentType],
           c1.[MasterCode] as [DocNo],'1753/01/01' as 'Document Date','' AS [Sales Order No], '' AS [Sell-to Customer No_], ''AS [Contact No_], '' AS [Salesperson Code], '' AS [Country_Region Code],
           c1.[Entry No_] as [LineNo],
		   c1.[Amount] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Actual' as [BucketType],
		   c1.[AmountLCY]	/ ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[ITIL Training Academy$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			e.[Country Code] AS [Country],
			ISNULL((SELECT cr.[Name] FROM dbo.[ITIL Training Academy$Country_Region] cr WHERE cr.[Code] IN 
			(e.[Country Code])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			'ACTUAL' AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[ITIL Training Academy$Event Cost Heads] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]

LEFT OUTER JOIN dbo.[ITIL Training Academy$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[ITIL Training Academy$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >=  '2018/01/01'
AND c1.[Applicable] = 1
AND e.[MarginApproval] = 1
AND ((NOT EXISTS ( SELECT 1 from dbo.[ITIL Training Academy$Purchase Line] p 
					WHERE p.[Event No_] = c1.[Event Header] AND p.[Event Cost Line No_] = c1.[Entry No_])) AND
	(NOT EXISTS ( SELECT 1 from dbo.[ITIL Training Academy$Purch_ Inv_ Line] pp 
					WHERE pp.[Event No_] = c1.[Event Header] AND pp.[Event Cost Line No_] = c1.[Entry No_]))) 

UNION ALL
--Pearce Mayfield Train Dubai
SELECT 'Pearce Mayfield Train Dubai' as [CName],
           CASE
			WHEN c1.[MasterType] = 1 THEN 'Trainer'
			WHEN c1.[MasterType] = 2 THEN 'Venue'
			WHEN c1.[MasterType] = 3 THEN 'Exam'
			WHEN c1.[MasterType] IN (5,6,7) THEN 'Courseware'
			WHEN c1.[MasterType] = 8 THEN 'Manual'
			WHEN c1.[MasterType] = 9 THEN 'Travel'
			WHEN c1.[MasterType] = 11 THEN 'Invigilator'
			WHEN c1.[MasterType] IN (12,4) THEN 'Others'
		   END as [DocumentType],
           c1.[MasterCode] as [DocNo],'1753/01/01' as 'Document Date','' AS [Sales Order No], '' AS [Sell-to Customer No_], ''AS [Contact No_], '' AS [Salesperson Code], '' AS [Country_Region Code],
           c1.[Entry No_] as [LineNo],
		   c1.[Amount] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Actual' as [BucketType],
		   c1.[AmountLCY]	/ ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[Pearce Mayfield Train Dubai$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			e.[Country Code] AS [Country],
			ISNULL((SELECT cr.[Name] FROM dbo.[Pearce Mayfield Train Dubai$Country_Region] cr WHERE cr.[Code] IN 
			(e.[Country Code])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			'ACTUAL' AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[Pearce Mayfield Train Dubai$Event Cost Heads] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]

LEFT OUTER JOIN dbo.[Pearce Mayfield Train Dubai$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[Pearce Mayfield Train Dubai$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >=  '2018/01/01'
AND c1.[Applicable] = 1
AND e.[MarginApproval] = 1
AND ((NOT EXISTS ( SELECT 1 from dbo.[Pearce Mayfield Train Dubai$Purchase Line] p 
					WHERE p.[Event No_] = c1.[Event Header] AND p.[Event Cost Line No_] = c1.[Entry No_])) AND
	(NOT EXISTS ( SELECT 1 from dbo.[Pearce Mayfield Train Dubai$Purch_ Inv_ Line] pp 
					WHERE pp.[Event No_] = c1.[Event Header] AND pp.[Event Cost Line No_] = c1.[Entry No_]))) 
					UNION ALL
--TKA FreeZone
SELECT 'TKA FreeZone' as [CName],
           CASE
			WHEN c1.[MasterType] = 1 THEN 'Trainer'
			WHEN c1.[MasterType] = 2 THEN 'Venue'
			WHEN c1.[MasterType] = 3 THEN 'Exam'
			WHEN c1.[MasterType] IN (5,6,7) THEN 'Courseware'
			WHEN c1.[MasterType] = 8 THEN 'Manual'
			WHEN c1.[MasterType] = 9 THEN 'Travel'
			WHEN c1.[MasterType] = 11 THEN 'Invigilator'
			WHEN c1.[MasterType] IN (12,4) THEN 'Others'
		   END as [DocumentType],
           c1.[MasterCode] as [DocNo],'1753/01/01' as 'Document Date','' AS [Sales Order No], '' AS [Sell-to Customer No_], ''AS [Contact No_], '' AS [Salesperson Code], '' AS [Country_Region Code],
           c1.[Entry No_] as [LineNo],
		   c1.[Amount] as [AmtLCY],
		   c1.[Event Header] as [EventNo],
		   e.[Start Date] as [StartDate], 'Actual' as [BucketType],
		   c1.[AmountLCY]	/ ISNULL((SELECT TOP 1 ce.[Relational Exch_ Rate Amount] FROM dbo.[The Knowledge Academy FreeZone$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= e.[Start Date] ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP],
			e.[Country Code] AS [Country],
			ISNULL((SELECT cr.[Name] FROM dbo.[The Knowledge Academy FreeZone$Country_Region] cr WHERE cr.[Code] IN 
			(e.[Country Code])),'') AS 'Country Name',
			CASE 
				WHEN e.[Start Date] <>  '1753/01/01' AND e.[End Date] <>  '1753/01/01' THEN
					DATEDIFF(dd,e.[Start Date], e.[End Date]) +1
				ELSE 0
			END AS 'Duration',
			e.[Course Trainer],
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal Trainer'
				WHEN r.[Resource Type] = 2 THEN 'External Trainer'
				WHEN r.[Resource Type] = 3 THEN 'Other Staff'
				WHEN r.[Resource Type] = 1 THEN 'ZZUNA'
				WHEN r.[Resource Type] = 1 THEN 'Internal Invigilator'
				WHEN r.[Resource Type] = 1 THEN 'External Invigilator'
			END,'') AS 'Trainer Type',
			ISNULL(CASE  
				WHEN r.[Resource Type] = 0 THEN ''
				WHEN r.[Resource Type] = 1 THEN 'Internal'
				WHEN r.[Resource Type] = 2 THEN 'External'
				WHEN r.[Resource Type] = 3 THEN 'ZZUNA'
			END,'') AS 'Location Type',
			e.[EI],
			e.[Course Type],
			e.[Course Header],
			e.[Group Location Code],
			c1.[Quantity],
			CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',
			CASE 
				WHEN e.[Group Location Code] LIKE '%E-LEARN%' THEN 'E-LEARNING'
				WHEN e.[Group Location Code] LIKE '%VIRTUAL%' THEN 'VIRTUAL'
				WHEN e.[Group Location Code] LIKE '%ONSITE%' THEN 'ONSITE'
				ELSE 'CLASSROOM'
			END AS 'Category',
			'ACTUAL' AS 'OrderType',ct.[MISName],DATENAME(Month,e.[Start Date]) AS 'Month', DATEPART(year,e.[Start Date]) AS 'Year', LEFT(DATENAME(month,e.[Start Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( e.[Start Date] ) % 100)) AS 'MonthYr'
FROM dbo.[The Knowledge Academy FreeZone$Event Cost Heads] c1
INNER JOIN dbo.[Event Header] e ON e.[No_] = c1.[Event Header]
LEFT OUTER JOIN dbo.[Course Type] ct ON ct.[Code] = e.[Course Type]

LEFT OUTER JOIN dbo.[The Knowledge Academy FreeZone$Resource] r ON e.[Course Trainer] = r.[No_]
LEFT OUTER JOIN dbo.[The Knowledge Academy FreeZone$Location] l ON e.[Training Centre] = l.[Code]
WHERE e.[Start Date] >=  '2018/01/01'
AND c1.[Applicable] = 1
AND e.[MarginApproval] = 1
AND ((NOT EXISTS ( SELECT 1 from dbo.[The Knowledge Academy FreeZone$Purchase Line] p 
					WHERE p.[Event No_] = c1.[Event Header] AND p.[Event Cost Line No_] = c1.[Entry No_])) AND
	(NOT EXISTS ( SELECT 1 from dbo.[The Knowledge Academy FreeZone$Purch_ Inv_ Line] pp 
					WHERE pp.[Event No_] = c1.[Event Header] AND pp.[Event Cost Line No_] = c1.[Entry No_]))) 



GO


