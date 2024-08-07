USE [NAV-SQL-LIVE]
GO

/****** Object:  StoredProcedure [dbo].[AllCompaniesGLDetail4]    Script Date: 12/06/2024 10:32:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO








ALTER  PROCEDURE [dbo].[AllCompaniesGLDetail4]  
    @STDate DATE,   
    @ETDate DATE,
	--,
	@FromGL NVARCHAR(20),
	@TOGL NVARCHAR(20) 
AS
 
IF @ETDate < @STDate 
	SET @ETDate = @STDate 
IF @FromGL = '' 
	SET @TOGL = '9999'
IF @FromGL = '' 
	SET @FromGL = '0' 

SELECT A.CName,A.[G_L Account No_],A.[Name], A.[Event Header], e.[Course Header],A.[Salesperson Code],A.[SalesManager],A.[TKA Course Name], A.[Team Leader],A.[Posting Date],A.[Group Location] ,A.[Customer PO No_],A.[Purchase Description],A.[MA LABEL],A.[FS Mapping],A.[FS FINER MAP21],
A.[Document Date],A.[MonthYr],A.[MonthNum],A.[Year],
gi.[Name] AS 'GLClassification' , gi.[Groups],gi.[SortSequence],gi.[Type],
A.[Document Type],
		A.[Document No_],
		A.[MasterType],
		A.[MasterCode],
		A.[External Document No_],
		A.[Event Start Date],
		A.[Event Cost Line No_],
		A.[Source No_],
		A.[Source Type],
		A.[Description],
		A.[Gen_ Posting Type],
		A.[Gen_ Bus_ Posting Group],
		A.[Gen_ Prod_ Posting Group],
		A.[Tax Amount],
		A.[Bal Account Type],
		A.[Bal_ Account No_],
		A.[User ID],
		A.[Reason Code],
		
		A.[Transaction No_],
		CASE
				WHEN e.[Event Status] = 0 THEN ''
				WHEN e.[Event Status] = 1 THEN 'Provisional'
				WHEN e.[Event Status] = 2 THEN 'WatchList'
				WHEN e.[Event Status] = 3 THEN 'Confirmed'
				WHEN e.[Event Status] = 4 THEN 'Cancelled'
			END AS 'Event Status',

		A.[Entry No_],
A.[Amount], A.[AmtGBP] AS 'AmountGBP'
FROM (
SELECT 'The Knowledge Academy Limited' as [CName],
		g.[Posting Date],
		

		LEFT(DATENAME(month,g.[Posting Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( g.[Posting Date] ) % 100)) AS 'MonthYr',
		CASE 
			WHEN MONTH(g.[Posting Date]) >= 1 AND MONTH(g.[Posting Date]) <= 3 THEN MONTH(g.[Posting Date]) + 9
			ELSE MONTH(g.[Posting Date])-3
		END 'MonthNum',
		CASE
			WHEN MONTH(g.[Posting Date]) >= 1 AND MONTH(g.[Posting Date]) <= 3 THEN  Year(g.[Posting Date])-1
			ELSE Year(g.[Posting Date])
		END AS 'Year',
		g.[G_L Account No_],

		ga.[Name] ,
		g.[Event Header],
		CASE
			WHEN g.[Document Type] =0 THEN ''
			WHEN g.[Document Type] =1 THEN 'Payment'
			WHEN g.[Document Type] =2 THEN 'Invoice'
			WHEN g.[Document Type] =3 THEN 'Credit Memo'
			WHEN g.[Document Type] =4 THEN 'Finance Charge Memo'
			WHEN g.[Document Type] =5 THEN 'Reminder'
			WHEN g.[Document Type] =6 THEN 'Refund'
		END AS [Document Type],
		g.[Document No_],
		CASE
			WHEN g.[MasterType] = 0 THEN ''
			WHEN g.[MasterType] = 1 THEN 'Trainer'
			WHEN g.[MasterType] = 2 THEN 'Venue'
			WHEN g.[MasterType] = 3 THEN 'Exam'
			WHEN g.[MasterType] = 4 THEN 'Misc'
			WHEN g.[MasterType] = 5 THEN 'Print'
			WHEN g.[MasterType] = 6 THEN 'Technical'
			WHEN g.[MasterType] = 7 THEN 'Courseware'
			WHEN g.[MasterType] = 8 THEN 'Manual'
			WHEN g.[MasterType] = 9 THEN 'Travel'
			WHEN g.[MasterType] = 10 THEN 'NonEvent'
			WHEN g.[MasterType] = 11 THEN 'Invigilator'
			WHEN g.[MasterType] = 12 THEN 'External Course Booking'
		END AS [MasterType],
		g.[MasterCode],
		g.[External Document No_],

		g.[Event Cost Line No_],
		g.[Source No_],
		CASE
			WHEN g.[Source Type] = 0 THEN ''
			WHEN g.[Source Type] = 1 THEN 'Customer'
			WHEN g.[Source Type] = 2 THEN 'Vendor'
			WHEN g.[Source Type] = 3 THEN 'Bank Account'
			WHEN g.[Source Type] = 4 THEN 'Fixed Asset'
			WHEN g.[Source Type] = 5 THEN 'Employee'
		END AS [Source Type],
		g.[Description],
		CASE
			WHEN g.[Gen_ Posting Type] = 0 THEN ''
			WHEN g.[Gen_ Posting Type] = 1 THEN 'Purchase'
			WHEN g.[Gen_ Posting Type] = 2 THEN 'Sale'
			WHEN g.[Gen_ Posting Type] = 3 THEN 'Settlement'
		END AS [Gen_ Posting Type],
		g.[Gen_ Bus_ Posting Group],
		g.[Gen_ Prod_ Posting Group],
		g.[VAT Amount] AS [Tax Amount],
		CASE
			WHEN g.[Bal_ Account Type] = 0 THEN 'G/L Account'
			WHEN g.[Bal_ Account Type] = 1 THEN 'Customer'
			WHEN g.[Bal_ Account Type] = 2 THEN 'Vendor'
			WHEN g.[Bal_ Account Type] = 3 THEN 'Bank Account'
			WHEN g.[Bal_ Account Type] = 4 THEN 'Fixed Assets'
			WHEN g.[Bal_ Account Type] = 5 THEN 'IC Partner'
			WHEN g.[Bal_ Account Type] = 6 THEN 'Employee'
		END AS [Bal Account Type],
		g.[Bal_ Account No_],
		g.[User ID],
		g.[Reason Code],
		g.[Transaction No_],

		g.[Document Date],
		g.[Entry No_],

		g.[Event Start Date],
		g.[Amount],
		(select TOP 1 [Group Location] from 
		dbo.[The Knowledge Academy Limited$Sales Invoice Line] as SIL1
		where g.[Document No_]= SIL1.[Document No_]
		and SIL1.[Group Location]IS NOT NULL) as 'Group Location',

(select sum([Quantity]) from dbo.[The Knowledge Academy Limited$Sales Invoice Line] as sil2 where 
g.[Document No_]= sil2.[Document No_] And g.[Event Header] = sil2.[Event Header]) as 'Quantity',

		(select TOP 1 [Salesperson Code] from 
		dbo.[The Knowledge Academy Limited$Sales Invoice Line] as SIL1
		where g.[Document No_]= SIL1.[Document No_]) as 'Salesperson Code',

		(select TOP 1 [Default Team Code] from [dbo].[The Knowledge Academy Limited$Salesperson_Purchaser] as SP
		where (select TOP 1 [Salesperson Code] from 
		dbo.[The Knowledge Academy Limited$Sales Invoice Line] as SIL1
		where g.[Document No_]= SIL1.[Document No_]) = SP.Code) as 'Team Leader',
--Nb
		(select TOP 1 [Manager Name] from [dbo].[The Knowledge Academy Limited$Team] as TM
		where (select TOP 1 [Default Team Code] from [dbo].[The Knowledge Academy Limited$Salesperson_Purchaser] as SP
		where (select TOP 1 [Salesperson Code] from 
		dbo.[The Knowledge Academy Limited$Sales Invoice Line] as SIL1
		where g.[Document No_]= SIL1.[Document No_]) = SP.Code) = TM.Code) as 'SalesManager',

		(select TOP 1 [Course] from [dbo].[Delivery Costs Analytic Datapo] as DC 
where (select TOP 1 [TKA course Id] from [dbo].[Course Header] as CH 
where (select top 1 [Course Header] from [dbo].[Event Header] as EH
where g.[Event Header] = EH.[No_]) = CH.[Code]) = DC.[CounterKey]) as 'TKA Course Name',

		(select [Your Reference] from 
		dbo.[The Knowledge Academy Limited$Sales Invoice Header] as SIH1
		where g.[Document No_]= SIH1.[No_])
		 as 'Customer PO No_',
		

		 (select TOP 1 [Description] from 
		dbo.[The Knowledge Academy Limited$Purch_ Inv_ Line] as PIL1
		where g.[Document No_]= PIL1.[Document No_]
		and
		PIL1.[No_]=g.[G_L Account No_]) as 'Purchase Description',

	   (select TOP 1 [MA Label] from 
		dbo.[The Knowledge Academy Limited$G_L Account] as GLACCOUNT
		where  GLACCOUNT.[No_]=g.[G_L Account No_])
		as 'MA LABEL', 

       (select TOP 1 [FS Mapping] from 
		dbo.[The Knowledge Academy Limited$G_L Account] as GLACCOUNT
		where  GLACCOUNT.[No_]=g.[G_L Account No_])
		as 'FS Mapping', 

		 (select TOP 1 [FS FINER MAP21] from 
		dbo.[The Knowledge Academy Limited$G_L Account] as GLACCOUNT
		where  GLACCOUNT.[No_]=g.[G_L Account No_])
		as 'FS FINER MAP21', 


		g.[Amount] as [AmtGBP]
FROM dbo.[The Knowledge Academy Limited$G_L Entry] g
INNER JOIN dbo.[The Knowledge Academy Limited$G_L Account] ga ON ga.[No_] = g.[G_L Account No_]
--INNER JOIN dbo.[Event Header] e ON e.[No_] = g.[Event Header]
WHERE g.[Posting Date] BETWEEN @STDate AND @ETDate

UNION ALL
SELECT 'TKA India' as [CName],
		g.[Posting Date],
		
		LEFT(DATENAME(month,g.[Posting Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( g.[Posting Date] ) % 100)) AS 'MonthYr',
		CASE 
			WHEN MONTH(g.[Posting Date]) >= 1 AND MONTH(g.[Posting Date]) <= 3 THEN MONTH(g.[Posting Date]) + 9
			ELSE MONTH(g.[Posting Date])-3
		END 'MonthNum',
		CASE
			WHEN MONTH(g.[Posting Date]) >= 1 AND MONTH(g.[Posting Date]) <= 3 THEN  Year(g.[Posting Date])-1
			ELSE Year(g.[Posting Date])
		END AS 'Year',
		g.[G_L Account No_],
		ga.[Name],
		g.[Event Header],
		CASE
			WHEN g.[Document Type] =0 THEN ''
			WHEN g.[Document Type] =1 THEN 'Payment'
			WHEN g.[Document Type] =2 THEN 'Invoice'
			WHEN g.[Document Type] =3 THEN 'Credit Memo'
			WHEN g.[Document Type] =4 THEN 'Finance Charge Memo'
			WHEN g.[Document Type] =5 THEN 'Reminder'
			WHEN g.[Document Type] =6 THEN 'Refund'
		END AS [Document Type],
		g.[Document No_],
		CASE
			WHEN g.[MasterType] = 0 THEN ''
			WHEN g.[MasterType] = 1 THEN 'Trainer'
			WHEN g.[MasterType] = 2 THEN 'Venue'
			WHEN g.[MasterType] = 3 THEN 'Exam'
			WHEN g.[MasterType] = 4 THEN 'Misc'
			WHEN g.[MasterType] = 5 THEN 'Print'
			WHEN g.[MasterType] = 6 THEN 'Technical'
			WHEN g.[MasterType] = 7 THEN 'Courseware'
			WHEN g.[MasterType] = 8 THEN 'Manual'
			WHEN g.[MasterType] = 9 THEN 'Travel'
			WHEN g.[MasterType] = 10 THEN 'NonEvent'
			WHEN g.[MasterType] = 11 THEN 'Invigilator'
			WHEN g.[MasterType] = 12 THEN 'External Course Booking'
		END AS [MasterType],
		g.[MasterCode],
		g.[External Document No_],

		g.[Event Cost Line No_],
		g.[Source No_],
		CASE
			WHEN g.[Source Type] = 0 THEN ''
			WHEN g.[Source Type] = 1 THEN 'Customer'
			WHEN g.[Source Type] = 2 THEN 'Vendor'
			WHEN g.[Source Type] = 3 THEN 'Bank Account'
			WHEN g.[Source Type] = 4 THEN 'Fixed Asset'
			WHEN g.[Source Type] = 5 THEN 'Employee'
		END AS [Source Type],
		g.[Description],
		CASE
			WHEN g.[Gen_ Posting Type] = 0 THEN ''
			WHEN g.[Gen_ Posting Type] = 1 THEN 'Purchase'
			WHEN g.[Gen_ Posting Type] = 2 THEN 'Sale'
			WHEN g.[Gen_ Posting Type] = 3 THEN 'Settlement'
		END AS [Gen_ Posting Type],
		g.[Gen_ Bus_ Posting Group],
		g.[Gen_ Prod_ Posting Group],
		g.[VAT Amount] AS [Tax Amount],
		CASE
			WHEN g.[Bal_ Account Type] = 0 THEN 'G/L Account'
			WHEN g.[Bal_ Account Type] = 1 THEN 'Customer'
			WHEN g.[Bal_ Account Type] = 2 THEN 'Vendor'
			WHEN g.[Bal_ Account Type] = 3 THEN 'Bank Account'
			WHEN g.[Bal_ Account Type] = 4 THEN 'Fixed Assets'
			WHEN g.[Bal_ Account Type] = 5 THEN 'IC Partner'
			WHEN g.[Bal_ Account Type] = 6 THEN 'Employee'
		END AS [Bal Account Type],
		g.[Bal_ Account No_],
		g.[User ID],
		g.[Reason Code],
		g.[Transaction No_],
		g.[Document Date],
		g.[Entry No_],
		g.[Event Start Date],
		g.[Amount],

		
		(select TOP 1 [Group Location] from 
		dbo.[The Knowledge Academy Limited$Sales Invoice Line] as SIL1
		where g.[Document No_]= SIL1.[Document No_]
		and SIL1.[Group Location]IS NOT NULL) as 'Group Location',

(select sum([Quantity]) from dbo.[TKA India$Sales Invoice Line] as sil2 where 
g.[Document No_]= sil2.[Document No_] And g.[Event Header] = sil2.[Event Header]) as 'Quantity',

		(select TOP 1 [Salesperson Code] from 
		dbo.[TKA India$Sales Invoice Line] as SIL1
		where g.[Document No_]= SIL1.[Document No_]) as 'Salesperson Code',

		(select TOP 1 [Default Team Code] from [dbo].[TKA India$Salesperson_Purchaser] as SP
		where (select TOP 1 [Salesperson Code] from 
		dbo.[TKA India$Sales Invoice Line] as SIL1
		where g.[Document No_]= SIL1.[Document No_]) = SP.Code) as 'Team Leader',

		(select TOP 1 [Manager Name] from [dbo].[TKA India$Team] as TM
		where (select TOP 1 [Default Team Code] from [dbo].[TKA India$Salesperson_Purchaser] as SP
		where (select TOP 1 [Salesperson Code] from 
		dbo.[TKA India$Sales Invoice Line] as SIL1
		where g.[Document No_]= SIL1.[Document No_]) = SP.Code) = TM.Code) as 'SalesManager',

		(select TOP 1 [Course] from [dbo].[Delivery Costs Analytic Datapo] as DC 
where (select TOP 1 [TKA course Id] from [dbo].[Course Header] as CH 
where (select top 1 [Course Header] from [dbo].[Event Header] as EH
where g.[Event Header] = EH.[No_]) = CH.[Code]) = DC.[CounterKey]) as 'TKA Course Name',


		(select [Your Reference] from 
		dbo.[TKA India$Sales Invoice Header] as SIH1
		where g.[Document No_]= SIH1.[No_])
		 as 'Customer PO No_',

		 
		 (select TOP 1 [Description] from 
		dbo.[TKA India$Purch_ Inv_ Line] as PIL1
		where g.[Document No_]= PIL1.[Document No_]
		and 
		PIL1.[No_]=g.[G_L Account No_]) as 'Purchase Description',

		
		(select TOP 1 [MA Label] from 
		dbo.[The Knowledge Academy Limited$G_L Account] as GLACCOUNT
		where  GLACCOUNT.[No_]=g.[G_L Account No_])
		as 'MA LABEL', 

		(select TOP 1 [FS Mapping] from 
		dbo.[The Knowledge Academy Limited$G_L Account] as GLACCOUNT
		where  GLACCOUNT.[No_]=g.[G_L Account No_])
		as 'FS Mapping', 


	 (select TOP 1 [FS FINER MAP21] from 
		dbo.[The Knowledge Academy Limited$G_L Account] as GLACCOUNT
		where  GLACCOUNT.[No_]=g.[G_L Account No_])
		as 'FS FINER MAP21', 



		--g.[Amount] as [AmtGBP]
	
	g.[Amount] / ISNULL((SELECT TOP 1 (ce.[Relational Exch_ Rate Amount]/ce.[Exchange Rate Amount]) FROM dbo.[TKA India$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= 
				(SELECT DATEADD(m,1,DATEADD(m,datediff(m,0,g.[Posting Date]),0))) ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP]


FROM dbo.[TKA India$G_L Entry] g
INNER JOIN dbo.[TKA India$G_L Account] ga ON ga.[No_] = g.[G_L Account No_]
--INNER JOIN dbo.[Event Header] e ON e.[No_] = g.[Event Header]
WHERE g.[Posting Date] BETWEEN @STDate AND @ETDate


UNION ALL
SELECT 'Best Practice Training Ltd.' as [CName],
		g.[Posting Date],
		
		LEFT(DATENAME(month,g.[Posting Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( g.[Posting Date] ) % 100)) AS 'MonthYr',
		CASE 
			WHEN MONTH(g.[Posting Date]) >= 1 AND MONTH(g.[Posting Date]) <= 3 THEN MONTH(g.[Posting Date]) + 9
			ELSE MONTH(g.[Posting Date])-3
		END 'MonthNum',
		CASE
			WHEN MONTH(g.[Posting Date]) >= 1 AND MONTH(g.[Posting Date]) <= 3 THEN  Year(g.[Posting Date])-1
			ELSE Year(g.[Posting Date])
		END AS 'Year',
		g.[G_L Account No_],
		ga.[Name],
		g.[Event Header],
		CASE
			WHEN g.[Document Type] =0 THEN ''
			WHEN g.[Document Type] =1 THEN 'Payment'
			WHEN g.[Document Type] =2 THEN 'Invoice'
			WHEN g.[Document Type] =3 THEN 'Credit Memo'
			WHEN g.[Document Type] =4 THEN 'Finance Charge Memo'
			WHEN g.[Document Type] =5 THEN 'Reminder'
			WHEN g.[Document Type] =6 THEN 'Refund'
		END AS [Document Type],
		g.[Document No_],
		CASE
			WHEN g.[MasterType] = 0 THEN ''
			WHEN g.[MasterType] = 1 THEN 'Trainer'
			WHEN g.[MasterType] = 2 THEN 'Venue'
			WHEN g.[MasterType] = 3 THEN 'Exam'
			WHEN g.[MasterType] = 4 THEN 'Misc'
			WHEN g.[MasterType] = 5 THEN 'Print'
			WHEN g.[MasterType] = 6 THEN 'Technical'
			WHEN g.[MasterType] = 7 THEN 'Courseware'
			WHEN g.[MasterType] = 8 THEN 'Manual'
			WHEN g.[MasterType] = 9 THEN 'Travel'
			WHEN g.[MasterType] = 10 THEN 'NonEvent'
			WHEN g.[MasterType] = 11 THEN 'Invigilator'
			WHEN g.[MasterType] = 12 THEN 'External Course Booking'
		END AS [MasterType],
		g.[MasterCode],
		g.[External Document No_],

		g.[Event Cost Line No_],
		g.[Source No_],
		CASE
			WHEN g.[Source Type] = 0 THEN ''
			WHEN g.[Source Type] = 1 THEN 'Customer'
			WHEN g.[Source Type] = 2 THEN 'Vendor'
			WHEN g.[Source Type] = 3 THEN 'Bank Account'
			WHEN g.[Source Type] = 4 THEN 'Fixed Asset'
			WHEN g.[Source Type] = 5 THEN 'Employee'
		END AS [Source Type],
		g.[Description],
		CASE
			WHEN g.[Gen_ Posting Type] = 0 THEN ''
			WHEN g.[Gen_ Posting Type] = 1 THEN 'Purchase'
			WHEN g.[Gen_ Posting Type] = 2 THEN 'Sale'
			WHEN g.[Gen_ Posting Type] = 3 THEN 'Settlement'
		END AS [Gen_ Posting Type],
		g.[Gen_ Bus_ Posting Group],
		g.[Gen_ Prod_ Posting Group],
		g.[VAT Amount] AS [Tax Amount],
		CASE
			WHEN g.[Bal_ Account Type] = 0 THEN 'G/L Account'
			WHEN g.[Bal_ Account Type] = 1 THEN 'Customer'
			WHEN g.[Bal_ Account Type] = 2 THEN 'Vendor'
			WHEN g.[Bal_ Account Type] = 3 THEN 'Bank Account'
			WHEN g.[Bal_ Account Type] = 4 THEN 'Fixed Assets'
			WHEN g.[Bal_ Account Type] = 5 THEN 'IC Partner'
			WHEN g.[Bal_ Account Type] = 6 THEN 'Employee'
		END AS [Bal Account Type],
		g.[Bal_ Account No_],
		g.[User ID],
		g.[Reason Code],
		g.[Transaction No_],
		g.[Document Date],
		g.[Entry No_],
		g.[Event Start Date],
		g.[Amount],

		
		(select TOP 1 [Group Location] from 
		dbo.[The Knowledge Academy Limited$Sales Invoice Line] as SIL1
		where g.[Document No_]= SIL1.[Document No_]
		and SIL1.[Group Location]IS NOT NULL) as 'Group Location',

(select sum([Quantity]) from dbo.[Best Practice Training Ltd_$Sales Invoice Line] as sil2 where 
g.[Document No_]= sil2.[Document No_] And g.[Event Header] = sil2.[Event Header]) as 'Quantity',

		(select TOP 1 [Salesperson Code] from 
		dbo.[Best Practice Training Ltd_$Sales Invoice Line] as SIL1
		where g.[Document No_]= SIL1.[Document No_]) as 'Salesperson Code',

		(select TOP 1 [Default Team Code] from [dbo].[Best Practice Training Ltd_$Salesperson_Purchaser] as SP
		where (select TOP 1 [Salesperson Code] from 
		dbo.[Best Practice Training Ltd_$Sales Invoice Line] as SIL1
		where g.[Document No_]= SIL1.[Document No_]) = SP.Code) as 'Team Leader',

		(select TOP 1 [Manager Name] from [dbo].[Best Practice Training Ltd_$Team] as TM
		where (select TOP 1 [Default Team Code] from [dbo].[Best Practice Training Ltd_$Salesperson_Purchaser] as SP
		where (select TOP 1 [Salesperson Code] from 
		dbo.[Best Practice Training Ltd_$Sales Invoice Line] as SIL1
		where g.[Document No_]= SIL1.[Document No_]) = SP.Code) = TM.Code) as 'SalesManager',

		(select TOP 1 [Course] from [dbo].[Delivery Costs Analytic Datapo] as DC 
where (select TOP 1 [TKA course Id] from [dbo].[Course Header] as CH 
where (select top 1 [Course Header] from [dbo].[Event Header] as EH
where g.[Event Header] = EH.[No_]) = CH.[Code]) = DC.[CounterKey]) as 'TKA Course Name',


		(select [Your Reference] from 
		dbo.[Best Practice Training Ltd_$Sales Invoice Header] as SIH1
		where g.[Document No_]= SIH1.[No_])
		 as 'Customer PO No_',

		 
		 (select TOP 1 [Description] from 
		dbo.[Best Practice Training Ltd_$Purch_ Inv_ Line] as PIL1
		where g.[Document No_]= PIL1.[Document No_]
		and 
		PIL1.[No_]=g.[G_L Account No_]) as 'Purchase Description',

		
		(select TOP 1 [MA Label] from 
		dbo.[The Knowledge Academy Limited$G_L Account] as GLACCOUNT
		where  GLACCOUNT.[No_]=g.[G_L Account No_])
		as 'MA LABEL', 

		(select TOP 1 [FS Mapping] from 
		dbo.[The Knowledge Academy Limited$G_L Account] as GLACCOUNT
		where  GLACCOUNT.[No_]=g.[G_L Account No_])
		as 'FS Mapping', 


	 (select TOP 1 [FS FINER MAP21] from 
		dbo.[The Knowledge Academy Limited$G_L Account] as GLACCOUNT
		where  GLACCOUNT.[No_]=g.[G_L Account No_])
		as 'FS FINER MAP21', 



		g.[Amount] as [AmtGBP]
FROM dbo.[Best Practice Training Ltd_$G_L Entry] g
INNER JOIN dbo.[Best Practice Training Ltd_$G_L Account] ga ON ga.[No_] = g.[G_L Account No_]
--INNER JOIN dbo.[Event Header] e ON e.[No_] = g.[Event Header]
WHERE g.[Posting Date] BETWEEN @STDate AND @ETDate
UNION ALL
SELECT 'Datrix Learning Services Ltd.' as [CName],
		g.[Posting Date],
		
		LEFT(DATENAME(month,g.[Posting Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( g.[Posting Date] ) % 100)) AS 'MonthYr',
		CASE 
			WHEN MONTH(g.[Posting Date]) >= 1 AND MONTH(g.[Posting Date]) <= 3 THEN MONTH(g.[Posting Date]) + 9
			ELSE MONTH(g.[Posting Date])-3
		END 'MonthNum',
		CASE
			WHEN MONTH(g.[Posting Date]) >= 1 AND MONTH(g.[Posting Date]) <= 3 THEN  Year(g.[Posting Date])-1
			ELSE Year(g.[Posting Date])
		END AS 'Year',
		g.[G_L Account No_],
		ga.[Name],
		g.[Event Header],
		CASE
			WHEN g.[Document Type] =0 THEN ''
			WHEN g.[Document Type] =1 THEN 'Payment'
			WHEN g.[Document Type] =2 THEN 'Invoice'
			WHEN g.[Document Type] =3 THEN 'Credit Memo'
			WHEN g.[Document Type] =4 THEN 'Finance Charge Memo'
			WHEN g.[Document Type] =5 THEN 'Reminder'
			WHEN g.[Document Type] =6 THEN 'Refund'
		END AS [Document Type],
		g.[Document No_],
		CASE
			WHEN g.[MasterType] = 0 THEN ''
			WHEN g.[MasterType] = 1 THEN 'Trainer'
			WHEN g.[MasterType] = 2 THEN 'Venue'
			WHEN g.[MasterType] = 3 THEN 'Exam'
			WHEN g.[MasterType] = 4 THEN 'Misc'
			WHEN g.[MasterType] = 5 THEN 'Print'
			WHEN g.[MasterType] = 6 THEN 'Technical'
			WHEN g.[MasterType] = 7 THEN 'Courseware'
			WHEN g.[MasterType] = 8 THEN 'Manual'
			WHEN g.[MasterType] = 9 THEN 'Travel'
			WHEN g.[MasterType] = 10 THEN 'NonEvent'
			WHEN g.[MasterType] = 11 THEN 'Invigilator'
			WHEN g.[MasterType] = 12 THEN 'External Course Booking'
		END AS [MasterType],
		g.[MasterCode],
		g.[External Document No_],

		g.[Event Cost Line No_],
		g.[Source No_],
		CASE
			WHEN g.[Source Type] = 0 THEN ''
			WHEN g.[Source Type] = 1 THEN 'Customer'
			WHEN g.[Source Type] = 2 THEN 'Vendor'
			WHEN g.[Source Type] = 3 THEN 'Bank Account'
			WHEN g.[Source Type] = 4 THEN 'Fixed Asset'
			WHEN g.[Source Type] = 5 THEN 'Employee'
		END AS [Source Type],
		g.[Description],
		CASE
			WHEN g.[Gen_ Posting Type] = 0 THEN ''
			WHEN g.[Gen_ Posting Type] = 1 THEN 'Purchase'
			WHEN g.[Gen_ Posting Type] = 2 THEN 'Sale'
			WHEN g.[Gen_ Posting Type] = 3 THEN 'Settlement'
		END AS [Gen_ Posting Type],
		g.[Gen_ Bus_ Posting Group],
		g.[Gen_ Prod_ Posting Group],
		g.[VAT Amount] AS [Tax Amount],
		CASE
			WHEN g.[Bal_ Account Type] = 0 THEN 'G/L Account'
			WHEN g.[Bal_ Account Type] = 1 THEN 'Customer'
			WHEN g.[Bal_ Account Type] = 2 THEN 'Vendor'
			WHEN g.[Bal_ Account Type] = 3 THEN 'Bank Account'
			WHEN g.[Bal_ Account Type] = 4 THEN 'Fixed Assets'
			WHEN g.[Bal_ Account Type] = 5 THEN 'IC Partner'
			WHEN g.[Bal_ Account Type] = 6 THEN 'Employee'
		END AS [Bal Account Type],
		g.[Bal_ Account No_],
		g.[User ID],
		g.[Reason Code],
		g.[Transaction No_],
		g.[Document Date],
		g.[Entry No_],
		g.[Event Start Date],
		g.[Amount],

		(select TOP 1 [Group Location] from 
		dbo.[The Knowledge Academy Limited$Sales Invoice Line] as SIL1
		where g.[Document No_]= SIL1.[Document No_]
		and SIL1.[Group Location]IS NOT NULL) as 'Group Location',

(select sum([Quantity]) from dbo.[Datrix Learning Services Ltd_$Sales Invoice Line] as sil2 where 
g.[Document No_]= sil2.[Document No_] And g.[Event Header] = sil2.[Event Header]) as 'Quantity',

		(select TOP 1 [Salesperson Code] from 
		dbo.[Datrix Learning Services Ltd_$Sales Invoice Line] as SIL1
		where g.[Document No_]= SIL1.[Document No_]) as 'Salesperson Code',

		(select TOP 1 [Default Team Code] from [dbo].[Datrix Learning Services Ltd_$Salesperson_Purchaser] as SP
		where (select TOP 1 [Salesperson Code] from 
		dbo.[Datrix Learning Services Ltd_$Sales Invoice Line] as SIL1
		where g.[Document No_]= SIL1.[Document No_]) = SP.Code) as 'Team Leader',

		(select TOP 1 [Manager Name] from [dbo].[Datrix Learning Services Ltd_$Team] as TM
		where (select TOP 1 [Default Team Code] from [dbo].[Datrix Learning Services Ltd_$Salesperson_Purchaser] as SP
		where (select TOP 1 [Salesperson Code] from 
		dbo.[Datrix Learning Services Ltd_$Sales Invoice Line] as SIL1
		where g.[Document No_]= SIL1.[Document No_]) = SP.Code) = TM.Code) as 'SalesManager',

		(select TOP 1 [Course] from [dbo].[Delivery Costs Analytic Datapo] as DC 
where (select TOP 1 [TKA course Id] from [dbo].[Course Header] as CH 
where (select top 1 [Course Header] from [dbo].[Event Header] as EH
where g.[Event Header] = EH.[No_]) = CH.[Code]) = DC.[CounterKey]) as 'TKA Course Name',

		(select [Your Reference] from 
		dbo.[Datrix Learning Services Ltd_$Sales Invoice Header] as SIH1
		where g.[Document No_]= SIH1.[No_])
		 as 'Customer PO No_',

		 (select TOP 1 [Description] from 
		dbo.[Datrix Learning Services Ltd_$Purch_ Inv_ Line] as PIL1
		where g.[Document No_]= PIL1.[Document No_]
		and 
		PIL1.[No_]=g.[G_L Account No_]) as 'Purchase Description',

		(select TOP 1 [MA Label] from 
		dbo.[The Knowledge Academy Limited$G_L Account] as GLACCOUNT
		where  GLACCOUNT.[No_]=g.[G_L Account No_])
		as 'MA LABEL', 

		(select TOP 1 [FS Mapping] from 
		dbo.[The Knowledge Academy Limited$G_L Account] as GLACCOUNT
		where  GLACCOUNT.[No_]=g.[G_L Account No_])
		as 'FS Mapping', 

		 (select TOP 1 [FS FINER MAP21] from 
		dbo.[The Knowledge Academy Limited$G_L Account] as GLACCOUNT
		where  GLACCOUNT.[No_]=g.[G_L Account No_])
		as 'FS FINER MAP21', 

		g.[Amount] as [AmtGBP]
FROM dbo.[Datrix Learning Services Ltd_$G_L Entry] g
INNER JOIN dbo.[Datrix Learning Services Ltd_$G_L Account] ga ON ga.[No_] = g.[G_L Account No_]
--INNER JOIN dbo.[Event Header] e ON e.[No_] = g.[Event Header]
WHERE g.[Posting Date] BETWEEN @STDate AND @ETDate
UNION ALL
SELECT 'Pearce Mayfield Training Ltd' as [CName],
		g.[Posting Date],
		
		LEFT(DATENAME(month,g.[Posting Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( g.[Posting Date] ) % 100)) AS 'MonthYr',
		CASE 
			WHEN MONTH(g.[Posting Date]) >= 1 AND MONTH(g.[Posting Date]) <= 3 THEN MONTH(g.[Posting Date]) + 9
			ELSE MONTH(g.[Posting Date])-3
		END 'MonthNum',
		CASE
			WHEN MONTH(g.[Posting Date]) >= 1 AND MONTH(g.[Posting Date]) <= 3 THEN  Year(g.[Posting Date])-1
			ELSE Year(g.[Posting Date])
		END AS 'Year',
		g.[G_L Account No_],
		ga.[Name],
		g.[Event Header],
		CASE
			WHEN g.[Document Type] =0 THEN ''
			WHEN g.[Document Type] =1 THEN 'Payment'
			WHEN g.[Document Type] =2 THEN 'Invoice'
			WHEN g.[Document Type] =3 THEN 'Credit Memo'
			WHEN g.[Document Type] =4 THEN 'Finance Charge Memo'
			WHEN g.[Document Type] =5 THEN 'Reminder'
			WHEN g.[Document Type] =6 THEN 'Refund'
		END AS [Document Type],
		g.[Document No_],
		CASE
			WHEN g.[MasterType] = 0 THEN ''
			WHEN g.[MasterType] = 1 THEN 'Trainer'
			WHEN g.[MasterType] = 2 THEN 'Venue'
			WHEN g.[MasterType] = 3 THEN 'Exam'
			WHEN g.[MasterType] = 4 THEN 'Misc'
			WHEN g.[MasterType] = 5 THEN 'Print'
			WHEN g.[MasterType] = 6 THEN 'Technical'
			WHEN g.[MasterType] = 7 THEN 'Courseware'
			WHEN g.[MasterType] = 8 THEN 'Manual'
			WHEN g.[MasterType] = 9 THEN 'Travel'
			WHEN g.[MasterType] = 10 THEN 'NonEvent'
			WHEN g.[MasterType] = 11 THEN 'Invigilator'
			WHEN g.[MasterType] = 12 THEN 'External Course Booking'
		END AS [MasterType],
		g.[MasterCode],
		g.[External Document No_],

		g.[Event Cost Line No_],
		g.[Source No_],
		CASE
			WHEN g.[Source Type] = 0 THEN ''
			WHEN g.[Source Type] = 1 THEN 'Customer'
			WHEN g.[Source Type] = 2 THEN 'Vendor'
			WHEN g.[Source Type] = 3 THEN 'Bank Account'
			WHEN g.[Source Type] = 4 THEN 'Fixed Asset'
			WHEN g.[Source Type] = 5 THEN 'Employee'
		END AS [Source Type],
		g.[Description],
		CASE
			WHEN g.[Gen_ Posting Type] = 0 THEN ''
			WHEN g.[Gen_ Posting Type] = 1 THEN 'Purchase'
			WHEN g.[Gen_ Posting Type] = 2 THEN 'Sale'
			WHEN g.[Gen_ Posting Type] = 3 THEN 'Settlement'
		END AS [Gen_ Posting Type],
		g.[Gen_ Bus_ Posting Group],
		g.[Gen_ Prod_ Posting Group],
		g.[VAT Amount] AS [Tax Amount],
		CASE
			WHEN g.[Bal_ Account Type] = 0 THEN 'G/L Account'
			WHEN g.[Bal_ Account Type] = 1 THEN 'Customer'
			WHEN g.[Bal_ Account Type] = 2 THEN 'Vendor'
			WHEN g.[Bal_ Account Type] = 3 THEN 'Bank Account'
			WHEN g.[Bal_ Account Type] = 4 THEN 'Fixed Assets'
			WHEN g.[Bal_ Account Type] = 5 THEN 'IC Partner'
			WHEN g.[Bal_ Account Type] = 6 THEN 'Employee'
		END AS [Bal Account Type],
		g.[Bal_ Account No_],
		g.[User ID],
		g.[Reason Code],
		g.[Transaction No_],
		g.[Document Date],
		g.[Entry No_],
		g.[Event Start Date],
		g.[Amount],

		(select TOP 1 [Group Location] from 
		dbo.[The Knowledge Academy Limited$Sales Invoice Line] as SIL1
		where g.[Document No_]= SIL1.[Document No_]
		and SIL1.[Group Location]IS NOT NULL) as 'Group Location',

(select sum([Quantity]) from dbo.[Pearce Mayfield Training Ltd$Sales Invoice Line] as sil2 where 
g.[Document No_]= sil2.[Document No_] And g.[Event Header] = sil2.[Event Header]) as 'Quantity',
		--NEW COLUMN

		(select TOP 1 [Salesperson Code] from 
		dbo.[Pearce Mayfield Training Ltd$Sales Invoice Line] as SIL1
		where g.[Document No_]= SIL1.[Document No_]) as 'Salesperson Code',

		(select TOP 1 [Default Team Code] from [dbo].[Pearce Mayfield Training Ltd$Salesperson_Purchaser] as SP
		where (select TOP 1 [Salesperson Code] from 
		dbo.[Pearce Mayfield Training Ltd$Sales Invoice Line] as SIL1
		where g.[Document No_]= SIL1.[Document No_]) = SP.Code) as 'Team Leader',

		(select TOP 1 [Manager Name] from [dbo].[Pearce Mayfield Training Ltd$Team] as TM
		where (select TOP 1 [Default Team Code] from [dbo].[Pearce Mayfield Training Ltd$Salesperson_Purchaser] as SP
		where (select TOP 1 [Salesperson Code] from 
		dbo.[Pearce Mayfield Training Ltd$Sales Invoice Line] as SIL1
		where g.[Document No_]= SIL1.[Document No_]) = SP.Code) = TM.Code) as 'SalesManager',

		(select TOP 1 [Course] from [dbo].[Delivery Costs Analytic Datapo] as DC 
where (select TOP 1 [TKA course Id] from [dbo].[Course Header] as CH 
where (select top 1 [Course Header] from [dbo].[Event Header] as EH
where g.[Event Header] = EH.[No_]) = CH.[Code]) = DC.[CounterKey]) as 'TKA Course Name',
		 

		
		(select [Your Reference] from 
		dbo.[Pearce Mayfield Training Ltd$Sales Invoice Header] as SIH1
		where g.[Document No_]= SIH1.[No_])
		 as 'Customer PO No_',

		(select TOP 1 [Description] from 
		dbo.[Pearce Mayfield Training Ltd$Purch_ Inv_ Line] as PIL1
		where g.[Document No_]= PIL1.[Document No_]
		and 
		PIL1.[No_]=g.[G_L Account No_]) as 'Purchase Description',

		(select TOP 1 [MA Label] from 
		dbo.[The Knowledge Academy Limited$G_L Account] as GLACCOUNT
		where  GLACCOUNT.[No_]=g.[G_L Account No_])
		as 'MA LABEL', 

	   (select TOP 1 [FS Mapping] from 
		dbo.[The Knowledge Academy Limited$G_L Account] as GLACCOUNT
		where  GLACCOUNT.[No_]=g.[G_L Account No_])
		as 'FS Mapping', 

		 (select TOP 1 [FS FINER MAP21] from 
		dbo.[The Knowledge Academy Limited$G_L Account] as GLACCOUNT
		where  GLACCOUNT.[No_]=g.[G_L Account No_])
		as 'FS FINER MAP21', 


		g.[Amount] as [AmtGBP]
FROM dbo.[Pearce Mayfield Training Ltd$G_L Entry] g
INNER JOIN dbo.[Pearce Mayfield Training Ltd$G_L Account] ga ON ga.[No_] = g.[G_L Account No_]
--INNER JOIN dbo.[Event Header] e ON e.[No_] = g.[Event Header]
WHERE g.[Posting Date] BETWEEN @STDate AND @ETDate
UNION ALL
SELECT 'Pentagon Leisure Services Ltd' as [CName],
		g.[Posting Date],
		
		LEFT(DATENAME(month,g.[Posting Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( g.[Posting Date] ) % 100)) AS 'MonthYr',
		CASE 
			WHEN MONTH(g.[Posting Date]) >= 1 AND MONTH(g.[Posting Date]) <= 3 THEN MONTH(g.[Posting Date]) + 9
			ELSE MONTH(g.[Posting Date])-3
		END 'MonthNum',
		CASE
			WHEN MONTH(g.[Posting Date]) >= 1 AND MONTH(g.[Posting Date]) <= 3 THEN  Year(g.[Posting Date])-1
			ELSE Year(g.[Posting Date])
		END AS 'Year',
		g.[G_L Account No_],
		ga.[Name],
		g.[Event Header],
		CASE
			WHEN g.[Document Type] =0 THEN ''
			WHEN g.[Document Type] =1 THEN 'Payment'
			WHEN g.[Document Type] =2 THEN 'Invoice'
			WHEN g.[Document Type] =3 THEN 'Credit Memo'
			WHEN g.[Document Type] =4 THEN 'Finance Charge Memo'
			WHEN g.[Document Type] =5 THEN 'Reminder'
			WHEN g.[Document Type] =6 THEN 'Refund'
		END AS [Document Type],
		g.[Document No_],
		CASE
			WHEN g.[MasterType] = 0 THEN ''
			WHEN g.[MasterType] = 1 THEN 'Trainer'
			WHEN g.[MasterType] = 2 THEN 'Venue'
			WHEN g.[MasterType] = 3 THEN 'Exam'
			WHEN g.[MasterType] = 4 THEN 'Misc'
			WHEN g.[MasterType] = 5 THEN 'Print'
			WHEN g.[MasterType] = 6 THEN 'Technical'
			WHEN g.[MasterType] = 7 THEN 'Courseware'
			WHEN g.[MasterType] = 8 THEN 'Manual'
			WHEN g.[MasterType] = 9 THEN 'Travel'
			WHEN g.[MasterType] = 10 THEN 'NonEvent'
			WHEN g.[MasterType] = 11 THEN 'Invigilator'
			WHEN g.[MasterType] = 12 THEN 'External Course Booking'
		END AS [MasterType],
		g.[MasterCode],
		g.[External Document No_],

		g.[Event Cost Line No_],
		g.[Source No_],
		CASE
			WHEN g.[Source Type] = 0 THEN ''
			WHEN g.[Source Type] = 1 THEN 'Customer'
			WHEN g.[Source Type] = 2 THEN 'Vendor'
			WHEN g.[Source Type] = 3 THEN 'Bank Account'
			WHEN g.[Source Type] = 4 THEN 'Fixed Asset'
			WHEN g.[Source Type] = 5 THEN 'Employee'
		END AS [Source Type],
		g.[Description],
		CASE
			WHEN g.[Gen_ Posting Type] = 0 THEN ''
			WHEN g.[Gen_ Posting Type] = 1 THEN 'Purchase'
			WHEN g.[Gen_ Posting Type] = 2 THEN 'Sale'
			WHEN g.[Gen_ Posting Type] = 3 THEN 'Settlement'
		END AS [Gen_ Posting Type],
		g.[Gen_ Bus_ Posting Group],
		g.[Gen_ Prod_ Posting Group],
		g.[VAT Amount] AS [Tax Amount],
		CASE
			WHEN g.[Bal_ Account Type] = 0 THEN 'G/L Account'
			WHEN g.[Bal_ Account Type] = 1 THEN 'Customer'
			WHEN g.[Bal_ Account Type] = 2 THEN 'Vendor'
			WHEN g.[Bal_ Account Type] = 3 THEN 'Bank Account'
			WHEN g.[Bal_ Account Type] = 4 THEN 'Fixed Assets'
			WHEN g.[Bal_ Account Type] = 5 THEN 'IC Partner'
			WHEN g.[Bal_ Account Type] = 6 THEN 'Employee'
		END AS [Bal Account Type],
		g.[Bal_ Account No_],
		g.[User ID],
		g.[Reason Code],
		g.[Transaction No_],
		g.[Document Date],
		g.[Entry No_],
		g.[Event Start Date],
		g.[Amount],

		(select TOP 1 [Group Location] from 
		dbo.[The Knowledge Academy Limited$Sales Invoice Line] as SIL1
		where g.[Document No_]= SIL1.[Document No_]
		and SIL1.[Group Location]IS NOT NULL) as 'Group Location',

(select sum([Quantity]) from dbo.[Pentagon Leisure Services Ltd$Sales Invoice Line] as sil2 where 
g.[Document No_]= sil2.[Document No_] And g.[Event Header] = sil2.[Event Header]) as 'Quantity',
		--NEW COLUMN

		(select TOP 1 [Salesperson Code] from 
		dbo.[Pentagon Leisure Services Ltd$Sales Invoice Line] as SIL1
		where g.[Document No_]= SIL1.[Document No_]) as 'Salesperson Code',

		(select TOP 1 [Default Team Code] from [dbo].[Pentagon Leisure Services Ltd$Salesperson_Purchaser] as SP
		where (select TOP 1 [Salesperson Code] from 
		dbo.[Pentagon Leisure Services Ltd$Sales Invoice Line] as SIL1
		where g.[Document No_]= SIL1.[Document No_]) = SP.Code) as 'Team Leader',

		(select TOP 1 [Manager Name] from [dbo].[Pentagon Leisure Services Ltd$Team] as TM
		where (select TOP 1 [Default Team Code] from [dbo].[Pentagon Leisure Services Ltd$Salesperson_Purchaser] as SP
		where (select TOP 1 [Salesperson Code] from 
		dbo.[Pentagon Leisure Services Ltd$Sales Invoice Line] as SIL1
		where g.[Document No_]= SIL1.[Document No_]) = SP.Code) = TM.Code) as 'SalesManager',

		(select TOP 1 [Course] from [dbo].[Delivery Costs Analytic Datapo] as DC 
where (select TOP 1 [TKA course Id] from [dbo].[Course Header] as CH 
where (select top 1 [Course Header] from [dbo].[Event Header] as EH
where g.[Event Header] = EH.[No_]) = CH.[Code]) = DC.[CounterKey]) as 'TKA Course Name',
		
		
		(select [Your Reference] from 
		dbo.[Pentagon Leisure Services Ltd$Sales Invoice Header] as SIH1
		where g.[Document No_]= SIH1.[No_])
		 as 'Customer PO No_',

		(select TOP 1 [Description] from 
		dbo.[Pentagon Leisure Services Ltd$Purch_ Inv_ Line] as PIL1
		where g.[Document No_]= PIL1.[Document No_]
		and 
		PIL1.[No_]=g.[G_L Account No_]) as 'Purchase Description',
	
		(select TOP 1 [MA Label] from 
		dbo.[The Knowledge Academy Limited$G_L Account] as GLACCOUNT
		where  GLACCOUNT.[No_]=g.[G_L Account No_])
		as 'MA LABEL', 

		(select TOP 1 [FS Mapping] from 
		dbo.[The Knowledge Academy Limited$G_L Account] as GLACCOUNT
		where  GLACCOUNT.[No_]=g.[G_L Account No_])
		as 'FS Mapping', 

		 (select TOP 1 [FS FINER MAP21] from 
		dbo.[The Knowledge Academy Limited$G_L Account] as GLACCOUNT
		where  GLACCOUNT.[No_]=g.[G_L Account No_])
		as 'FS FINER MAP21', 


		g.[Amount] as [AmtGBP]
FROM dbo.[Pentagon Leisure Services Ltd$G_L Entry] g
INNER JOIN dbo.[Pentagon Leisure Services Ltd$G_L Account] ga ON ga.[No_] = g.[G_L Account No_]
--INNER JOIN dbo.[Event Header] e ON e.[No_] = g.[Event Header]
WHERE g.[Posting Date] BETWEEN @STDate AND @ETDate
UNION ALL
SELECT 'Silicon Beach Training' as [CName],
		g.[Posting Date],
		
		LEFT(DATENAME(month,g.[Posting Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( g.[Posting Date] ) % 100)) AS 'MonthYr',
		CASE 
			WHEN MONTH(g.[Posting Date]) >= 1 AND MONTH(g.[Posting Date]) <= 3 THEN MONTH(g.[Posting Date]) + 9
			ELSE MONTH(g.[Posting Date])-3
		END 'MonthNum',
		CASE
			WHEN MONTH(g.[Posting Date]) >= 1 AND MONTH(g.[Posting Date]) <= 3 THEN  Year(g.[Posting Date])-1
			ELSE Year(g.[Posting Date])
		END AS 'Year',
		g.[G_L Account No_],
		ga.[Name],
		g.[Event Header],
		CASE
			WHEN g.[Document Type] =0 THEN ''
			WHEN g.[Document Type] =1 THEN 'Payment'
			WHEN g.[Document Type] =2 THEN 'Invoice'
			WHEN g.[Document Type] =3 THEN 'Credit Memo'
			WHEN g.[Document Type] =4 THEN 'Finance Charge Memo'
			WHEN g.[Document Type] =5 THEN 'Reminder'
			WHEN g.[Document Type] =6 THEN 'Refund'
		END AS [Document Type],
		g.[Document No_],
		CASE
			WHEN g.[MasterType] = 0 THEN ''
			WHEN g.[MasterType] = 1 THEN 'Trainer'
			WHEN g.[MasterType] = 2 THEN 'Venue'
			WHEN g.[MasterType] = 3 THEN 'Exam'
			WHEN g.[MasterType] = 4 THEN 'Misc'
			WHEN g.[MasterType] = 5 THEN 'Print'
			WHEN g.[MasterType] = 6 THEN 'Technical'
			WHEN g.[MasterType] = 7 THEN 'Courseware'
			WHEN g.[MasterType] = 8 THEN 'Manual'
			WHEN g.[MasterType] = 9 THEN 'Travel'
			WHEN g.[MasterType] = 10 THEN 'NonEvent'
			WHEN g.[MasterType] = 11 THEN 'Invigilator'
			WHEN g.[MasterType] = 12 THEN 'External Course Booking'
		END AS [MasterType],
		g.[MasterCode],
		g.[External Document No_],

		g.[Event Cost Line No_],
		g.[Source No_],
		CASE
			WHEN g.[Source Type] = 0 THEN ''
			WHEN g.[Source Type] = 1 THEN 'Customer'
			WHEN g.[Source Type] = 2 THEN 'Vendor'
			WHEN g.[Source Type] = 3 THEN 'Bank Account'
			WHEN g.[Source Type] = 4 THEN 'Fixed Asset'
			WHEN g.[Source Type] = 5 THEN 'Employee'
		END AS [Source Type],
		g.[Description],
		CASE
			WHEN g.[Gen_ Posting Type] = 0 THEN ''
			WHEN g.[Gen_ Posting Type] = 1 THEN 'Purchase'
			WHEN g.[Gen_ Posting Type] = 2 THEN 'Sale'
			WHEN g.[Gen_ Posting Type] = 3 THEN 'Settlement'
		END AS [Gen_ Posting Type],
		g.[Gen_ Bus_ Posting Group],
		g.[Gen_ Prod_ Posting Group],
		g.[VAT Amount] AS [Tax Amount],
		CASE
			WHEN g.[Bal_ Account Type] = 0 THEN 'G/L Account'
			WHEN g.[Bal_ Account Type] = 1 THEN 'Customer'
			WHEN g.[Bal_ Account Type] = 2 THEN 'Vendor'
			WHEN g.[Bal_ Account Type] = 3 THEN 'Bank Account'
			WHEN g.[Bal_ Account Type] = 4 THEN 'Fixed Assets'
			WHEN g.[Bal_ Account Type] = 5 THEN 'IC Partner'
			WHEN g.[Bal_ Account Type] = 6 THEN 'Employee'
		END AS [Bal Account Type],
		g.[Bal_ Account No_],
		g.[User ID],
		g.[Reason Code],
		g.[Transaction No_],
		g.[Document Date],
		g.[Entry No_],
		g.[Event Start Date],
		g.[Amount],

		(select TOP 1 [Group Location] from 
		dbo.[The Knowledge Academy Limited$Sales Invoice Line] as SIL1
		where g.[Document No_]= SIL1.[Document No_]
		and SIL1.[Group Location]IS NOT NULL) as 'Group Location',

(select sum([Quantity]) from dbo.[Silicon Beach Training$Sales Invoice Line] as sil2 where 
g.[Document No_]= sil2.[Document No_] And g.[Event Header] = sil2.[Event Header]) as 'Quantity',
		--NEW COLUMN

		(select TOP 1 [Salesperson Code] from 
		dbo.[Silicon Beach Training$Sales Invoice Line] as SIL1
		where g.[Document No_]= SIL1.[Document No_]) as 'Salesperson Code',

		(select TOP 1 [Default Team Code] from [dbo].[Silicon Beach Training$Salesperson_Purchaser] as SP
		where (select TOP 1 [Salesperson Code] from 
		dbo.[Silicon Beach Training$Sales Invoice Line] as SIL1
		where g.[Document No_]= SIL1.[Document No_]) = SP.Code) as 'Team Leader',

		

		(select TOP 1 [Manager Name] from [dbo].[Silicon Beach Training$Team] as TM
		where (select TOP 1 [Default Team Code] from [dbo].[Silicon Beach Training$Salesperson_Purchaser] as SP
		where (select TOP 1 [Salesperson Code] from 
		dbo.[Silicon Beach Training$Sales Invoice Line] as SIL1
		where g.[Document No_]= SIL1.[Document No_]) = SP.Code) = TM.Code) as 'SalesManager',

		(select TOP 1 [Course] from [dbo].[Delivery Costs Analytic Datapo] as DC 
where (select TOP 1 [TKA course Id] from [dbo].[Course Header] as CH 
where (select top 1 [Course Header] from [dbo].[Event Header] as EH
where g.[Event Header] = EH.[No_]) = CH.[Code]) = DC.[CounterKey]) as 'TKA Course Name',
	

		(select [Your Reference] from 
		dbo.[Silicon Beach Training$Sales Invoice Header] as SIH1
		where g.[Document No_]= SIH1.[No_])
		 as 'Customer PO No_',
		 
		 (select TOP 1 [Description] from 
		dbo.[Silicon Beach Training$Purch_ Inv_ Line] as PIL1
		where g.[Document No_]= PIL1.[Document No_]
		and 
		PIL1.[No_]=g.[G_L Account No_]) as 'Purchase Description',

			
		(select TOP 1 [MA Label] from 
		dbo.[The Knowledge Academy Limited$G_L Account] as GLACCOUNT
		where  GLACCOUNT.[No_]=g.[G_L Account No_])
		as 'MA LABEL', 

	   (select TOP 1 [FS Mapping] from 
		dbo.[The Knowledge Academy Limited$G_L Account] as GLACCOUNT
		where  GLACCOUNT.[No_]=g.[G_L Account No_])
		as 'FS Mapping', 

		 (select TOP 1 [FS FINER MAP21] from 
		dbo.[The Knowledge Academy Limited$G_L Account] as GLACCOUNT
		where  GLACCOUNT.[No_]=g.[G_L Account No_])
		as 'FS FINER MAP21', 


		g.[Amount] as [AmtGBP]
FROM dbo.[Silicon Beach Training$G_L Entry] g
INNER JOIN dbo.[Silicon Beach Training$G_L Account] ga ON ga.[No_] = g.[G_L Account No_]
--INNER JOIN dbo.[Event Header] e ON e.[No_] = g.[Event Header]
WHERE g.[Posting Date] BETWEEN @STDate AND @ETDate
UNION ALL
SELECT 'The Knowledge Academy Inc' as [CName],
		g.[Posting Date],
		LEFT(DATENAME(month,g.[Posting Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( g.[Posting Date] ) % 100)) AS 'MonthYr',
		CASE 
			WHEN MONTH(g.[Posting Date]) >= 1 AND MONTH(g.[Posting Date]) <= 3 THEN MONTH(g.[Posting Date]) + 9
			ELSE MONTH(g.[Posting Date])-3
		END 'MonthNum',
		CASE
			WHEN MONTH(g.[Posting Date]) >= 1 AND MONTH(g.[Posting Date]) <= 3 THEN  Year(g.[Posting Date])-1
			ELSE Year(g.[Posting Date])
		END AS 'Year',
		g.[G_L Account No_],
		ga.[Name],
		g.[Event Header],
		CASE
			WHEN g.[Document Type] =0 THEN ''
			WHEN g.[Document Type] =1 THEN 'Payment'
			WHEN g.[Document Type] =2 THEN 'Invoice'
			WHEN g.[Document Type] =3 THEN 'Credit Memo'
			WHEN g.[Document Type] =4 THEN 'Finance Charge Memo'
			WHEN g.[Document Type] =5 THEN 'Reminder'
			WHEN g.[Document Type] =6 THEN 'Refund'
		END AS [Document Type],
		g.[Document No_],
		CASE
			WHEN g.[MasterType] = 0 THEN ''
			WHEN g.[MasterType] = 1 THEN 'Trainer'
			WHEN g.[MasterType] = 2 THEN 'Venue'
			WHEN g.[MasterType] = 3 THEN 'Exam'
			WHEN g.[MasterType] = 4 THEN 'Misc'
			WHEN g.[MasterType] = 5 THEN 'Print'
			WHEN g.[MasterType] = 6 THEN 'Technical'
			WHEN g.[MasterType] = 7 THEN 'Courseware'
			WHEN g.[MasterType] = 8 THEN 'Manual'
			WHEN g.[MasterType] = 9 THEN 'Travel'
			WHEN g.[MasterType] = 10 THEN 'NonEvent'
			WHEN g.[MasterType] = 11 THEN 'Invigilator'
			WHEN g.[MasterType] = 12 THEN 'External Course Booking'
		END AS [MasterType],
		g.[MasterCode],
		g.[External Document No_],

		g.[Event Cost Line No_],
		g.[Source No_],
		CASE
			WHEN g.[Source Type] = 0 THEN ''
			WHEN g.[Source Type] = 1 THEN 'Customer'
			WHEN g.[Source Type] = 2 THEN 'Vendor'
			WHEN g.[Source Type] = 3 THEN 'Bank Account'
			WHEN g.[Source Type] = 4 THEN 'Fixed Asset'
			WHEN g.[Source Type] = 5 THEN 'Employee'
		END AS [Source Type],
		g.[Description],
		CASE
			WHEN g.[Gen_ Posting Type] = 0 THEN ''
			WHEN g.[Gen_ Posting Type] = 1 THEN 'Purchase'
			WHEN g.[Gen_ Posting Type] = 2 THEN 'Sale'
			WHEN g.[Gen_ Posting Type] = 3 THEN 'Settlement'
		END AS [Gen_ Posting Type],
		g.[Gen_ Bus_ Posting Group],
		g.[Gen_ Prod_ Posting Group],
		g.[VAT Amount] AS [Tax Amount],
		CASE
			WHEN g.[Bal_ Account Type] = 0 THEN 'G/L Account'
			WHEN g.[Bal_ Account Type] = 1 THEN 'Customer'
			WHEN g.[Bal_ Account Type] = 2 THEN 'Vendor'
			WHEN g.[Bal_ Account Type] = 3 THEN 'Bank Account'
			WHEN g.[Bal_ Account Type] = 4 THEN 'Fixed Assets'
			WHEN g.[Bal_ Account Type] = 5 THEN 'IC Partner'
			WHEN g.[Bal_ Account Type] = 6 THEN 'Employee'
		END AS [Bal Account Type],
		g.[Bal_ Account No_],
		g.[User ID],
		g.[Reason Code],
		g.[Transaction No_],
		g.[Document Date],
		g.[Entry No_],
		g.[Event Start Date],
		g.[Amount],
		(select TOP 1 [Group Location] from 
		dbo.[The Knowledge Academy Limited$Sales Invoice Line] as SIL1
		where g.[Document No_]= SIL1.[Document No_]
		and SIL1.[Group Location]IS NOT NULL) as 'Group Location',

(select sum([Quantity]) from dbo.[The Knowledge Academy Inc$Sales Invoice Line] as sil2 where 
g.[Document No_]= sil2.[Document No_] And g.[Event Header] = sil2.[Event Header]) as 'Quantity',
		--NEW COLUMN

		(select TOP 1 [Salesperson Code] from 
		dbo.[The Knowledge Academy Inc$Sales Invoice Line] as SIL1
		where g.[Document No_]= SIL1.[Document No_]) as 'Salesperson Code',

		(select TOP 1 [Default Team Code] from [dbo].[The Knowledge Academy Inc$Salesperson_Purchaser] as SP
		where (select TOP 1 [Salesperson Code] from 
		dbo.[The Knowledge Academy Inc$Sales Invoice Line] as SIL1
		where g.[Document No_]= SIL1.[Document No_]) = SP.Code) as 'Team Leader',

		(select TOP 1 [Manager Name] from [dbo].[The Knowledge Academy Inc$Team] as TM
		where (select TOP 1 [Default Team Code] from [dbo].[The Knowledge Academy Inc$Salesperson_Purchaser] as SP
		where (select TOP 1 [Salesperson Code] from 
		dbo.[The Knowledge Academy Inc$Sales Invoice Line] as SIL1
		where g.[Document No_]= SIL1.[Document No_]) = SP.Code) = TM.Code) as 'SalesManager',

		(select TOP 1 [Course] from [dbo].[Delivery Costs Analytic Datapo] as DC 
where (select TOP 1 [TKA course Id] from [dbo].[Course Header] as CH 
where (select top 1 [Course Header] from [dbo].[Event Header] as EH
where g.[Event Header] = EH.[No_]) = CH.[Code]) = DC.[CounterKey]) as 'TKA Course Name',

		(select [Your Reference] from 
		dbo.[The Knowledge Academy Inc$Sales Invoice Header] as SIH1
		where g.[Document No_]= SIH1.[No_])
		 as 'Customer PO No_',
		 	 
		(select TOP 1 [Description] from 
		dbo.[The Knowledge Academy Inc$Purch_ Inv_ Line] as PIL1
		where g.[Document No_]= PIL1.[Document No_]
		and 
		PIL1.[No_]=g.[G_L Account No_]) as 'Purchase Description',

				
		(select TOP 1 [MA Label] from 
		dbo.[The Knowledge Academy Limited$G_L Account] as GLACCOUNT
		where  GLACCOUNT.[No_]=g.[G_L Account No_])
		as 'MA LABEL', 

				(select TOP 1 [FS Mapping] from 
		dbo.[The Knowledge Academy Limited$G_L Account] as GLACCOUNT
		where  GLACCOUNT.[No_]=g.[G_L Account No_])
		as 'FS Mapping', 

		 (select TOP 1 [FS FINER MAP21] from 
		dbo.[The Knowledge Academy Limited$G_L Account] as GLACCOUNT
		where  GLACCOUNT.[No_]=g.[G_L Account No_])
		as 'FS FINER MAP21', 

		g.[Amount] / ISNULL((SELECT TOP 1 (ce.[Relational Exch_ Rate Amount]/ce.[Exchange Rate Amount]) FROM dbo.[The Knowledge Academy Inc$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= 
				(SELECT DATEADD(m,1,DATEADD(m,datediff(m,0,g.[Posting Date]),0))) ORDER BY ce.[Starting Date] DESC),1)	
				--(SELECT DATEADD(Year,1,DATEADD(year,DATEDIFF(month,'20000401',g.[Posting Date])/12,'20000401'))) ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP]
FROM dbo.[The Knowledge Academy Inc$G_L Entry] g 
INNER JOIN dbo.[The Knowledge Academy Inc$G_L Account] ga ON ga.[No_] = g.[G_L Account No_]
--INNER JOIN dbo.[Event Header] e ON e.[No_] = g.[Event Header]
WHERE g.[Posting Date] BETWEEN @STDate AND @ETDate
UNION ALL
SELECT 'The Knowledge Academy Pty Ltd.' as [CName],
		g.[Posting Date],
		
		LEFT(DATENAME(month,g.[Posting Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( g.[Posting Date] ) % 100)) AS 'MonthYr',
		CASE 
			WHEN MONTH(g.[Posting Date]) >= 1 AND MONTH(g.[Posting Date]) <= 3 THEN MONTH(g.[Posting Date]) + 9
			ELSE MONTH(g.[Posting Date])-3
		END 'MonthNum',
		CASE
			WHEN MONTH(g.[Posting Date]) >= 1 AND MONTH(g.[Posting Date]) <= 3 THEN  Year(g.[Posting Date])-1
			ELSE Year(g.[Posting Date])
		END AS 'Year',
		g.[G_L Account No_],
		ga.[Name],
		g.[Event Header],
		CASE
			WHEN g.[Document Type] =0 THEN ''
			WHEN g.[Document Type] =1 THEN 'Payment'
			WHEN g.[Document Type] =2 THEN 'Invoice'
			WHEN g.[Document Type] =3 THEN 'Credit Memo'
			WHEN g.[Document Type] =4 THEN 'Finance Charge Memo'
			WHEN g.[Document Type] =5 THEN 'Reminder'
			WHEN g.[Document Type] =6 THEN 'Refund'
		END AS [Document Type],
		g.[Document No_],
		CASE
			WHEN g.[MasterType] = 0 THEN ''
			WHEN g.[MasterType] = 1 THEN 'Trainer'
			WHEN g.[MasterType] = 2 THEN 'Venue'
			WHEN g.[MasterType] = 3 THEN 'Exam'
			WHEN g.[MasterType] = 4 THEN 'Misc'
			WHEN g.[MasterType] = 5 THEN 'Print'
			WHEN g.[MasterType] = 6 THEN 'Technical'
			WHEN g.[MasterType] = 7 THEN 'Courseware'
			WHEN g.[MasterType] = 8 THEN 'Manual'
			WHEN g.[MasterType] = 9 THEN 'Travel'
			WHEN g.[MasterType] = 10 THEN 'NonEvent'
			WHEN g.[MasterType] = 11 THEN 'Invigilator'
			WHEN g.[MasterType] = 12 THEN 'External Course Booking'
		END AS [MasterType],
		g.[MasterCode],
		g.[External Document No_],

		g.[Event Cost Line No_],
		g.[Source No_],
		CASE
			WHEN g.[Source Type] = 0 THEN ''
			WHEN g.[Source Type] = 1 THEN 'Customer'
			WHEN g.[Source Type] = 2 THEN 'Vendor'
			WHEN g.[Source Type] = 3 THEN 'Bank Account'
			WHEN g.[Source Type] = 4 THEN 'Fixed Asset'
			WHEN g.[Source Type] = 5 THEN 'Employee'
		END AS [Source Type],
		g.[Description],
		CASE
			WHEN g.[Gen_ Posting Type] = 0 THEN ''
			WHEN g.[Gen_ Posting Type] = 1 THEN 'Purchase'
			WHEN g.[Gen_ Posting Type] = 2 THEN 'Sale'
			WHEN g.[Gen_ Posting Type] = 3 THEN 'Settlement'
		END AS [Gen_ Posting Type],
		g.[Gen_ Bus_ Posting Group],
		g.[Gen_ Prod_ Posting Group],
		g.[VAT Amount] AS [Tax Amount],
		CASE
			WHEN g.[Bal_ Account Type] = 0 THEN 'G/L Account'
			WHEN g.[Bal_ Account Type] = 1 THEN 'Customer'
			WHEN g.[Bal_ Account Type] = 2 THEN 'Vendor'
			WHEN g.[Bal_ Account Type] = 3 THEN 'Bank Account'
			WHEN g.[Bal_ Account Type] = 4 THEN 'Fixed Assets'
			WHEN g.[Bal_ Account Type] = 5 THEN 'IC Partner'
			WHEN g.[Bal_ Account Type] = 6 THEN 'Employee'
		END AS [Bal Account Type],
		g.[Bal_ Account No_],
		g.[User ID],
		g.[Reason Code],
		g.[Transaction No_],
		g.[Document Date],
		g.[Entry No_],
		g.[Event Start Date],
		g.[Amount],

		(select TOP 1 [Group Location] from 
		dbo.[The Knowledge Academy Limited$Sales Invoice Line] as SIL1
		where g.[Document No_]= SIL1.[Document No_]
		and SIL1.[Group Location]IS NOT NULL) as 'Group Location',

(select sum([Quantity]) from dbo.[The Knowledge Academy Pty Ltd_$Sales Invoice Line] as sil2 where 
g.[Document No_]= sil2.[Document No_] And g.[Event Header] = sil2.[Event Header]) as 'Quantity',

		(select TOP 1 [Salesperson Code] from 
		dbo.[The Knowledge Academy Pty Ltd_$Sales Invoice Line] as SIL1
		where g.[Document No_]= SIL1.[Document No_]) as 'Salesperson Code',

		(select TOP 1 [Default Team Code] from [dbo].[The Knowledge Academy Pty Ltd_$Salesperson_Purchaser] as SP
		where (select TOP 1 [Salesperson Code] from 
		dbo.[The Knowledge Academy Pty Ltd_$Sales Invoice Line] as SIL1
		where g.[Document No_]= SIL1.[Document No_]) = SP.Code) as 'Team Leader',

		(select TOP 1 [Manager Name] from [dbo].[The Knowledge Academy Pty Ltd_$Team] as TM
		where (select TOP 1 [Default Team Code] from [dbo].[The Knowledge Academy Pty Ltd_$Salesperson_Purchaser] as SP
		where (select TOP 1 [Salesperson Code] from 
		dbo.[The Knowledge Academy Pty Ltd_$Sales Invoice Line] as SIL1
		where g.[Document No_]= SIL1.[Document No_]) = SP.Code) = TM.Code) as 'SalesManager',

		(select TOP 1 [Course] from [dbo].[Delivery Costs Analytic Datapo] as DC 
where (select TOP 1 [TKA course Id] from [dbo].[Course Header] as CH 
where (select top 1 [Course Header] from [dbo].[Event Header] as EH
where g.[Event Header] = EH.[No_]) = CH.[Code]) = DC.[CounterKey]) as 'TKA Course Name',

		
		(select [Your Reference] from 
		dbo.[The Knowledge Academy Pty Ltd_$Sales Invoice Header] as SIH1
		where g.[Document No_]= SIH1.[No_])
		 as 'Customer PO No_',
 
		 (select TOP 1 [Description] from 
		dbo.[The Knowledge Academy Pty Ltd_$Purch_ Inv_ Line] as PIL1
		where g.[Document No_]= PIL1.[Document No_]
		and 
		PIL1.[No_]=g.[G_L Account No_]) as 'Purchase Description',

		--NEW COLUMN
		
		(select TOP 1 [MA Label] from 
		dbo.[The Knowledge Academy Limited$G_L Account] as GLACCOUNT
		where  GLACCOUNT.[No_]=g.[G_L Account No_])
		as 'MA LABEL', 

				(select TOP 1 [FS Mapping] from 
		dbo.[The Knowledge Academy Limited$G_L Account] as GLACCOUNT
		where  GLACCOUNT.[No_]=g.[G_L Account No_])
		as 'FS Mapping',
		
		 (select TOP 1 [FS FINER MAP21] from 
		dbo.[The Knowledge Academy Limited$G_L Account] as GLACCOUNT
		where  GLACCOUNT.[No_]=g.[G_L Account No_])
		as 'FS FINER MAP21', 
 

		g.[Amount] / ISNULL((SELECT TOP 1 (ce.[Relational Exch_ Rate Amount]/ce.[Exchange Rate Amount]) FROM dbo.[The Knowledge Academy Pty Ltd_$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= 
				(SELECT DATEADD(m,1,DATEADD(m,datediff(m,0,g.[Posting Date]),0))) ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP]
FROM dbo.[The Knowledge Academy Pty Ltd_$G_L Entry] g 
INNER JOIN dbo.[The Knowledge Academy Pty Ltd_$G_L Account] ga ON ga.[No_] = g.[G_L Account No_]
--INNER JOIN dbo.[Event Header] e ON e.[No_] = g.[Event Header]
WHERE g.[Posting Date] BETWEEN @STDate AND @ETDate
UNION ALL
SELECT 'The Knowledge Academy SA' as [CName],
		g.[Posting Date],
		
		LEFT(DATENAME(month,g.[Posting Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( g.[Posting Date] ) % 100)) AS 'MonthYr',
		CASE 
			WHEN MONTH(g.[Posting Date]) >= 1 AND MONTH(g.[Posting Date]) <= 3 THEN MONTH(g.[Posting Date]) + 9
			ELSE MONTH(g.[Posting Date])-3
		END 'MonthNum',
		CASE
			WHEN MONTH(g.[Posting Date]) >= 1 AND MONTH(g.[Posting Date]) <= 3 THEN  Year(g.[Posting Date])-1
			ELSE Year(g.[Posting Date])
		END AS 'Year',
		g.[G_L Account No_],
		ga.[Name],
		g.[Event Header],
		CASE
			WHEN g.[Document Type] =0 THEN ''
			WHEN g.[Document Type] =1 THEN 'Payment'
			WHEN g.[Document Type] =2 THEN 'Invoice'
			WHEN g.[Document Type] =3 THEN 'Credit Memo'
			WHEN g.[Document Type] =4 THEN 'Finance Charge Memo'
			WHEN g.[Document Type] =5 THEN 'Reminder'
			WHEN g.[Document Type] =6 THEN 'Refund'
		END AS [Document Type],
		g.[Document No_],
		CASE
			WHEN g.[MasterType] = 0 THEN ''
			WHEN g.[MasterType] = 1 THEN 'Trainer'
			WHEN g.[MasterType] = 2 THEN 'Venue'
			WHEN g.[MasterType] = 3 THEN 'Exam'
			WHEN g.[MasterType] = 4 THEN 'Misc'
			WHEN g.[MasterType] = 5 THEN 'Print'
			WHEN g.[MasterType] = 6 THEN 'Technical'
			WHEN g.[MasterType] = 7 THEN 'Courseware'
			WHEN g.[MasterType] = 8 THEN 'Manual'
			WHEN g.[MasterType] = 9 THEN 'Travel'
			WHEN g.[MasterType] = 10 THEN 'NonEvent'
			WHEN g.[MasterType] = 11 THEN 'Invigilator'
			WHEN g.[MasterType] = 12 THEN 'External Course Booking'
		END AS [MasterType],
		g.[MasterCode],
		g.[External Document No_],

		g.[Event Cost Line No_],
		g.[Source No_],
		CASE
			WHEN g.[Source Type] = 0 THEN ''
			WHEN g.[Source Type] = 1 THEN 'Customer'
			WHEN g.[Source Type] = 2 THEN 'Vendor'
			WHEN g.[Source Type] = 3 THEN 'Bank Account'
			WHEN g.[Source Type] = 4 THEN 'Fixed Asset'
			WHEN g.[Source Type] = 5 THEN 'Employee'
		END AS [Source Type],
		g.[Description],
		CASE
			WHEN g.[Gen_ Posting Type] = 0 THEN ''
			WHEN g.[Gen_ Posting Type] = 1 THEN 'Purchase'
			WHEN g.[Gen_ Posting Type] = 2 THEN 'Sale'
			WHEN g.[Gen_ Posting Type] = 3 THEN 'Settlement'
		END AS [Gen_ Posting Type],
		g.[Gen_ Bus_ Posting Group],
		g.[Gen_ Prod_ Posting Group],
		g.[VAT Amount] AS [Tax Amount],
		CASE
			WHEN g.[Bal_ Account Type] = 0 THEN 'G/L Account'
			WHEN g.[Bal_ Account Type] = 1 THEN 'Customer'
			WHEN g.[Bal_ Account Type] = 2 THEN 'Vendor'
			WHEN g.[Bal_ Account Type] = 3 THEN 'Bank Account'
			WHEN g.[Bal_ Account Type] = 4 THEN 'Fixed Assets'
			WHEN g.[Bal_ Account Type] = 5 THEN 'IC Partner'
			WHEN g.[Bal_ Account Type] = 6 THEN 'Employee'
		END AS [Bal Account Type],
		g.[Bal_ Account No_],
		g.[User ID],
		g.[Reason Code],
		g.[Transaction No_],
		g.[Document Date],
		g.[Entry No_],
		g.[Event Start Date],
		g.[Amount],

		(select TOP 1 [Group Location] from 
		dbo.[The Knowledge Academy Limited$Sales Invoice Line] as SIL1
		where g.[Document No_]= SIL1.[Document No_]
		and SIL1.[Group Location]IS NOT NULL) as 'Group Location',

(select sum([Quantity]) from dbo.[The Knowledge Academy SA$Sales Invoice Line] as sil2 where 
g.[Document No_]= sil2.[Document No_] And g.[Event Header] = sil2.[Event Header]) as 'Quantity',

		--NEW COLUMN
		(select TOP 1 [Salesperson Code] from 
		dbo.[The Knowledge Academy SA$Sales Invoice Line] as SIL1
		where g.[Document No_]= SIL1.[Document No_]) as 'Salesperson Code',

		(select TOP 1 [Default Team Code] from [dbo].[The Knowledge Academy SA$Salesperson_Purchaser] as SP
		where (select TOP 1 [Salesperson Code] from 
		dbo.[The Knowledge Academy SA$Sales Invoice Line] as SIL1
		where g.[Document No_]= SIL1.[Document No_]) = SP.Code) as 'Team Leader',

		(select TOP 1 [Manager Name] from [dbo].[The Knowledge Academy SA$Team] as TM
		where (select TOP 1 [Default Team Code] from [dbo].[The Knowledge Academy SA$Salesperson_Purchaser] as SP
		where (select TOP 1 [Salesperson Code] from 
		dbo.[The Knowledge Academy SA$Sales Invoice Line] as SIL1
		where g.[Document No_]= SIL1.[Document No_]) = SP.Code) = TM.Code) as 'SalesManager',

		(select TOP 1 [Course] from [dbo].[Delivery Costs Analytic Datapo] as DC 
where (select TOP 1 [TKA course Id] from [dbo].[Course Header] as CH 
where (select top 1 [Course Header] from [dbo].[Event Header] as EH
where g.[Event Header] = EH.[No_]) = CH.[Code]) = DC.[CounterKey]) as 'TKA Course Name',
	 

		(select [Your Reference] from 
		dbo.[The Knowledge Academy SA$Sales Invoice Header] as SIH1
		where g.[Document No_]= SIH1.[No_])
		 as 'Customer PO No_',

		(select TOP 1 [Description] from 
		dbo.[The Knowledge Academy SA$Purch_ Inv_ Line] as PIL1
		where g.[Document No_]= PIL1.[Document No_]
		and 
		PIL1.[No_]=g.[G_L Account No_]) as 'Purchase Description',

		(select TOP 1 [MA Label] from 
		dbo.[The Knowledge Academy Limited$G_L Account] as GLACCOUNT
		where  GLACCOUNT.[No_]=g.[G_L Account No_])
		as 'MA LABEL', 

				(select TOP 1 [FS Mapping] from 
		dbo.[The Knowledge Academy Limited$G_L Account] as GLACCOUNT
		where  GLACCOUNT.[No_]=g.[G_L Account No_])
		as 'FS Mapping', 

		 (select TOP 1 [FS FINER MAP21] from 
		dbo.[The Knowledge Academy Limited$G_L Account] as GLACCOUNT
		where  GLACCOUNT.[No_]=g.[G_L Account No_])
		as 'FS FINER MAP21', 


		g.[Amount] / ISNULL((SELECT TOP 1 (ce.[Relational Exch_ Rate Amount]/ce.[Exchange Rate Amount]) FROM dbo.[The Knowledge Academy SA$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= 
				(SELECT DATEADD(m,1,DATEADD(m,datediff(m,0,g.[Posting Date]),0))) ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP]
FROM dbo.[The Knowledge Academy SA$G_L Entry] g 
INNER JOIN dbo.[The Knowledge Academy SA$G_L Account] ga ON ga.[No_] = g.[G_L Account No_]
--INNER JOIN dbo.[Event Header] e ON e.[No_] = g.[Event Header]
WHERE g.[Posting Date] BETWEEN @STDate AND @ETDate
UNION ALL
SELECT 'TKA Canada Corporation' as [CName],
		g.[Posting Date],
		
		LEFT(DATENAME(month,g.[Posting Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( g.[Posting Date] ) % 100)) AS 'MonthYr',
		CASE 
			WHEN MONTH(g.[Posting Date]) >= 1 AND MONTH(g.[Posting Date]) <= 3 THEN MONTH(g.[Posting Date]) + 9
			ELSE MONTH(g.[Posting Date])-3
		END 'MonthNum',
		CASE
			WHEN MONTH(g.[Posting Date]) >= 1 AND MONTH(g.[Posting Date]) <= 3 THEN  Year(g.[Posting Date])-1
			ELSE Year(g.[Posting Date])
		END AS 'Year',
		g.[G_L Account No_],
		ga.[Name],
		g.[Event Header],
		CASE
			WHEN g.[Document Type] =0 THEN ''
			WHEN g.[Document Type] =1 THEN 'Payment'
			WHEN g.[Document Type] =2 THEN 'Invoice'
			WHEN g.[Document Type] =3 THEN 'Credit Memo'
			WHEN g.[Document Type] =4 THEN 'Finance Charge Memo'
			WHEN g.[Document Type] =5 THEN 'Reminder'
			WHEN g.[Document Type] =6 THEN 'Refund'
		END AS [Document Type],
		g.[Document No_],
		CASE
			WHEN g.[MasterType] = 0 THEN ''
			WHEN g.[MasterType] = 1 THEN 'Trainer'
			WHEN g.[MasterType] = 2 THEN 'Venue'
			WHEN g.[MasterType] = 3 THEN 'Exam'
			WHEN g.[MasterType] = 4 THEN 'Misc'
			WHEN g.[MasterType] = 5 THEN 'Print'
			WHEN g.[MasterType] = 6 THEN 'Technical'
			WHEN g.[MasterType] = 7 THEN 'Courseware'
			WHEN g.[MasterType] = 8 THEN 'Manual'
			WHEN g.[MasterType] = 9 THEN 'Travel'
			WHEN g.[MasterType] = 10 THEN 'NonEvent'
			WHEN g.[MasterType] = 11 THEN 'Invigilator'
			WHEN g.[MasterType] = 12 THEN 'External Course Booking'
		END AS [MasterType],
		g.[MasterCode],
		g.[External Document No_],

		g.[Event Cost Line No_],
		g.[Source No_],
		CASE
			WHEN g.[Source Type] = 0 THEN ''
			WHEN g.[Source Type] = 1 THEN 'Customer'
			WHEN g.[Source Type] = 2 THEN 'Vendor'
			WHEN g.[Source Type] = 3 THEN 'Bank Account'
			WHEN g.[Source Type] = 4 THEN 'Fixed Asset'
			WHEN g.[Source Type] = 5 THEN 'Employee'
		END AS [Source Type],
		g.[Description],
		CASE
			WHEN g.[Gen_ Posting Type] = 0 THEN ''
			WHEN g.[Gen_ Posting Type] = 1 THEN 'Purchase'
			WHEN g.[Gen_ Posting Type] = 2 THEN 'Sale'
			WHEN g.[Gen_ Posting Type] = 3 THEN 'Settlement'
		END AS [Gen_ Posting Type],
		g.[Gen_ Bus_ Posting Group],
		g.[Gen_ Prod_ Posting Group],
		g.[VAT Amount] AS [Tax Amount],
		CASE
			WHEN g.[Bal_ Account Type] = 0 THEN 'G/L Account'
			WHEN g.[Bal_ Account Type] = 1 THEN 'Customer'
			WHEN g.[Bal_ Account Type] = 2 THEN 'Vendor'
			WHEN g.[Bal_ Account Type] = 3 THEN 'Bank Account'
			WHEN g.[Bal_ Account Type] = 4 THEN 'Fixed Assets'
			WHEN g.[Bal_ Account Type] = 5 THEN 'IC Partner'
			WHEN g.[Bal_ Account Type] = 6 THEN 'Employee'
		END AS [Bal Account Type],
		g.[Bal_ Account No_],
		g.[User ID],
		g.[Reason Code],
		g.[Transaction No_],
		g.[Document Date],
		g.[Entry No_],
		g.[Event Start Date],
		g.[Amount],
		(select TOP 1 [Group Location] from 
		dbo.[The Knowledge Academy Limited$Sales Invoice Line] as SIL1
		where g.[Document No_]= SIL1.[Document No_]
		and SIL1.[Group Location]IS NOT NULL) as 'Group Location',

(select sum([Quantity]) from dbo.[TKA Canada Corporation$Sales Invoice Line] as sil2 where 
g.[Document No_]= sil2.[Document No_] And g.[Event Header] = sil2.[Event Header]) as 'Quantity',

		--NEW COLUMN
		
		(select TOP 1 [Salesperson Code] from 
		dbo.[TKA Canada Corporation$Sales Invoice Line] as SIL1
		where g.[Document No_]= SIL1.[Document No_]) as 'Salesperson Code',

		(select TOP 1 [Default Team Code] from [dbo].[TKA Canada Corporation$Salesperson_Purchaser] as SP
		where (select TOP 1 [Salesperson Code] from 
		dbo.[TKA Canada Corporation$Sales Invoice Line] as SIL1
		where g.[Document No_]= SIL1.[Document No_]) = SP.Code) as 'Team Leader',

		(select TOP 1 [Manager Name] from [dbo].[TKA Canada Corporation$Team] as TM
		where (select TOP 1 [Default Team Code] from [dbo].[TKA Canada Corporation$Salesperson_Purchaser] as SP
		where (select TOP 1 [Salesperson Code] from 
		dbo.[TKA Canada Corporation$Sales Invoice Line] as SIL1
		where g.[Document No_]= SIL1.[Document No_]) = SP.Code) = TM.Code) as 'SalesManager',

		(select TOP 1 [Course] from [dbo].[Delivery Costs Analytic Datapo] as DC 
where (select TOP 1 [TKA course Id] from [dbo].[Course Header] as CH 
where (select top 1 [Course Header] from [dbo].[Event Header] as EH
where g.[Event Header] = EH.[No_]) = CH.[Code]) = DC.[CounterKey]) as 'TKA Course Name',


		(select [Your Reference] from 
		dbo.[TKA Canada Corporation$Sales Invoice Header] as SIH1
		where g.[Document No_]= SIH1.[No_])
		 as 'Customer PO No_',
 
		 (select TOP 1 [Description] from 
		dbo.[TKA Canada Corporation$Purch_ Inv_ Line] as PIL1
		where g.[Document No_]= PIL1.[Document No_]
		and 
		PIL1.[No_]=g.[G_L Account No_]) as 'Purchase Description',

		
		(select TOP 1 [MA Label] from 
		dbo.[The Knowledge Academy Limited$G_L Account] as GLACCOUNT
		where  GLACCOUNT.[No_]=g.[G_L Account No_])
		as 'MA LABEL', 

			(select TOP 1 [FS Mapping] from 
		dbo.[The Knowledge Academy Limited$G_L Account] as GLACCOUNT
		where  GLACCOUNT.[No_]=g.[G_L Account No_])
		as 'FS Mapping', 

		 (select TOP 1 [FS FINER MAP21] from 
		dbo.[The Knowledge Academy Limited$G_L Account] as GLACCOUNT
		where  GLACCOUNT.[No_]=g.[G_L Account No_])
		as 'FS FINER MAP21', 


		g.[Amount] / ISNULL((SELECT TOP 1 (ce.[Relational Exch_ Rate Amount]/ce.[Exchange Rate Amount]) FROM dbo.[TKA Canada Corporation$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= 
				(SELECT DATEADD(m,1,DATEADD(m,datediff(m,0,g.[Posting Date]),0))) ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP]
FROM dbo.[TKA Canada Corporation$G_L Entry] g 
INNER JOIN dbo.[TKA Canada Corporation$G_L Account] ga ON ga.[No_] = g.[G_L Account No_]
--INNER JOIN dbo.[Event Header] e ON e.[No_] = g.[Event Header]
WHERE g.[Posting Date] BETWEEN @STDate AND @ETDate
UNION ALL
SELECT 'TKA Europe' as [CName],
		g.[Posting Date],
		
		LEFT(DATENAME(month,g.[Posting Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( g.[Posting Date] ) % 100)) AS 'MonthYr',
		CASE 
			WHEN MONTH(g.[Posting Date]) >= 1 AND MONTH(g.[Posting Date]) <= 3 THEN MONTH(g.[Posting Date]) + 9
			ELSE MONTH(g.[Posting Date])-3
		END 'MonthNum',
		CASE
			WHEN MONTH(g.[Posting Date]) >= 1 AND MONTH(g.[Posting Date]) <= 3 THEN  Year(g.[Posting Date])-1
			ELSE Year(g.[Posting Date])
		END AS 'Year',
		g.[G_L Account No_],
		ga.[Name],
		g.[Event Header],
		CASE
			WHEN g.[Document Type] =0 THEN ''
			WHEN g.[Document Type] =1 THEN 'Payment'
			WHEN g.[Document Type] =2 THEN 'Invoice'
			WHEN g.[Document Type] =3 THEN 'Credit Memo'
			WHEN g.[Document Type] =4 THEN 'Finance Charge Memo'
			WHEN g.[Document Type] =5 THEN 'Reminder'
			WHEN g.[Document Type] =6 THEN 'Refund'
		END AS [Document Type],
		g.[Document No_],
		CASE
			WHEN g.[MasterType] = 0 THEN ''
			WHEN g.[MasterType] = 1 THEN 'Trainer'
			WHEN g.[MasterType] = 2 THEN 'Venue'
			WHEN g.[MasterType] = 3 THEN 'Exam'
			WHEN g.[MasterType] = 4 THEN 'Misc'
			WHEN g.[MasterType] = 5 THEN 'Print'
			WHEN g.[MasterType] = 6 THEN 'Technical'
			WHEN g.[MasterType] = 7 THEN 'Courseware'
			WHEN g.[MasterType] = 8 THEN 'Manual'
			WHEN g.[MasterType] = 9 THEN 'Travel'
			WHEN g.[MasterType] = 10 THEN 'NonEvent'
			WHEN g.[MasterType] = 11 THEN 'Invigilator'
			WHEN g.[MasterType] = 12 THEN 'External Course Booking'
		END AS [MasterType],
		g.[MasterCode],
		g.[External Document No_],

		g.[Event Cost Line No_],
		g.[Source No_],
		CASE
			WHEN g.[Source Type] = 0 THEN ''
			WHEN g.[Source Type] = 1 THEN 'Customer'
			WHEN g.[Source Type] = 2 THEN 'Vendor'
			WHEN g.[Source Type] = 3 THEN 'Bank Account'
			WHEN g.[Source Type] = 4 THEN 'Fixed Asset'
			WHEN g.[Source Type] = 5 THEN 'Employee'
		END AS [Source Type],
		g.[Description],
		CASE
			WHEN g.[Gen_ Posting Type] = 0 THEN ''
			WHEN g.[Gen_ Posting Type] = 1 THEN 'Purchase'
			WHEN g.[Gen_ Posting Type] = 2 THEN 'Sale'
			WHEN g.[Gen_ Posting Type] = 3 THEN 'Settlement'
		END AS [Gen_ Posting Type],
		g.[Gen_ Bus_ Posting Group],
		g.[Gen_ Prod_ Posting Group],
		g.[VAT Amount] AS [Tax Amount],
		CASE
			WHEN g.[Bal_ Account Type] = 0 THEN 'G/L Account'
			WHEN g.[Bal_ Account Type] = 1 THEN 'Customer'
			WHEN g.[Bal_ Account Type] = 2 THEN 'Vendor'
			WHEN g.[Bal_ Account Type] = 3 THEN 'Bank Account'
			WHEN g.[Bal_ Account Type] = 4 THEN 'Fixed Assets'
			WHEN g.[Bal_ Account Type] = 5 THEN 'IC Partner'
			WHEN g.[Bal_ Account Type] = 6 THEN 'Employee'
		END AS [Bal Account Type],
		g.[Bal_ Account No_],
		g.[User ID],
		g.[Reason Code],
		g.[Transaction No_],
		g.[Document Date],
		g.[Entry No_],
		g.[Event Start Date],
		g.[Amount],

		(select TOP 1 [Group Location] from 
		dbo.[The Knowledge Academy Limited$Sales Invoice Line] as SIL1
		where g.[Document No_]= SIL1.[Document No_]
		and SIL1.[Group Location]IS NOT NULL) as 'Group Location',

(select sum([Quantity]) from dbo.[TKA Europe$Sales Invoice Line] as sil2 where 
g.[Document No_]= sil2.[Document No_] And g.[Event Header] = sil2.[Event Header]) as 'Quantity',
		--NEW COLUMN

		(select TOP 1 [Salesperson Code] from 
		dbo.[TKA Europe$Sales Invoice Line] as SIL1
		where g.[Document No_]= SIL1.[Document No_]) as 'Salesperson Code',

		(select TOP 1 [Default Team Code] from [dbo].[TKA Europe$Salesperson_Purchaser] as SP
		where (select TOP 1 [Salesperson Code] from 
		dbo.[TKA Europe$Sales Invoice Line] as SIL1
		where g.[Document No_]= SIL1.[Document No_]) = SP.Code) as 'Team Leader',

		(select TOP 1 [Manager Name] from [dbo].[TKA Europe$Team] as TM
		where (select TOP 1 [Default Team Code] from [dbo].[TKA Europe$Salesperson_Purchaser] as SP
		where (select TOP 1 [Salesperson Code] from 
		dbo.[TKA Europe$Sales Invoice Line] as SIL1
		where g.[Document No_]= SIL1.[Document No_]) = SP.Code) = TM.Code) as 'SalesManager',

		(select TOP 1 [Course] from [dbo].[Delivery Costs Analytic Datapo] as DC 
where (select TOP 1 [TKA course Id] from [dbo].[Course Header] as CH 
where (select top 1 [Course Header] from [dbo].[Event Header] as EH
where g.[Event Header] = EH.[No_]) = CH.[Code]) = DC.[CounterKey]) as 'TKA Course Name',
		

		(select [Your Reference] from 
		dbo.[TKA Europe$Sales Invoice Header] as SIH1
		where g.[Document No_]= SIH1.[No_])
		 as 'Customer PO No_',
			 
		 (select TOP 1 [Description] from 
		dbo.[TKA Europe$Purch_ Inv_ Line] as PIL1
		where g.[Document No_]= PIL1.[Document No_]
		and 
		PIL1.[No_]=g.[G_L Account No_]) as 'Purchase Description',

		(select TOP 1 [MA Label] from 
		dbo.[The Knowledge Academy Limited$G_L Account] as GLACCOUNT
		where  GLACCOUNT.[No_]=g.[G_L Account No_])
		as 'MA LABEL', 

				(select TOP 1 [FS Mapping] from 
		dbo.[The Knowledge Academy Limited$G_L Account] as GLACCOUNT
		where  GLACCOUNT.[No_]=g.[G_L Account No_])
		as 'FS Mapping', 


		 (select TOP 1 [FS FINER MAP21] from 
		dbo.[The Knowledge Academy Limited$G_L Account] as GLACCOUNT
		where  GLACCOUNT.[No_]=g.[G_L Account No_])
		as 'FS FINER MAP21', 

		g.[Amount] / ISNULL((SELECT TOP 1 (ce.[Relational Exch_ Rate Amount]/ce.[Exchange Rate Amount]) FROM dbo.[TKA Europe$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= 
				(SELECT DATEADD(m,1,DATEADD(m,datediff(m,0,g.[Posting Date]),0))) ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP]
FROM dbo.[TKA Europe$G_L Entry] g 
INNER JOIN dbo.[TKA Europe$G_L Account] ga ON ga.[No_] = g.[G_L Account No_]
--INNER JOIN dbo.[Event Header] e ON e.[No_] = g.[Event Header]
WHERE g.[Posting Date] BETWEEN @STDate AND @ETDate
UNION ALL
SELECT 'TKA Hong Kong Ltd.' as [CName],
		g.[Posting Date],
		
		LEFT(DATENAME(month,g.[Posting Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( g.[Posting Date] ) % 100)) AS 'MonthYr',
		CASE 
			WHEN MONTH(g.[Posting Date]) >= 1 AND MONTH(g.[Posting Date]) <= 3 THEN MONTH(g.[Posting Date]) + 9
			ELSE MONTH(g.[Posting Date])-3
		END 'MonthNum',
		CASE
			WHEN MONTH(g.[Posting Date]) >= 1 AND MONTH(g.[Posting Date]) <= 3 THEN  Year(g.[Posting Date])-1
			ELSE Year(g.[Posting Date])
		END AS 'Year',
		g.[G_L Account No_],
		ga.[Name],
		g.[Event Header],
		CASE
			WHEN g.[Document Type] =0 THEN ''
			WHEN g.[Document Type] =1 THEN 'Payment'
			WHEN g.[Document Type] =2 THEN 'Invoice'
			WHEN g.[Document Type] =3 THEN 'Credit Memo'
			WHEN g.[Document Type] =4 THEN 'Finance Charge Memo'
			WHEN g.[Document Type] =5 THEN 'Reminder'
			WHEN g.[Document Type] =6 THEN 'Refund'
		END AS [Document Type],
		g.[Document No_],
		CASE
			WHEN g.[MasterType] = 0 THEN ''
			WHEN g.[MasterType] = 1 THEN 'Trainer'
			WHEN g.[MasterType] = 2 THEN 'Venue'
			WHEN g.[MasterType] = 3 THEN 'Exam'
			WHEN g.[MasterType] = 4 THEN 'Misc'
			WHEN g.[MasterType] = 5 THEN 'Print'
			WHEN g.[MasterType] = 6 THEN 'Technical'
			WHEN g.[MasterType] = 7 THEN 'Courseware'
			WHEN g.[MasterType] = 8 THEN 'Manual'
			WHEN g.[MasterType] = 9 THEN 'Travel'
			WHEN g.[MasterType] = 10 THEN 'NonEvent'
			WHEN g.[MasterType] = 11 THEN 'Invigilator'
			WHEN g.[MasterType] = 12 THEN 'External Course Booking'
		END AS [MasterType],
		g.[MasterCode],
		g.[External Document No_],

		g.[Event Cost Line No_],
		g.[Source No_],
		CASE
			WHEN g.[Source Type] = 0 THEN ''
			WHEN g.[Source Type] = 1 THEN 'Customer'
			WHEN g.[Source Type] = 2 THEN 'Vendor'
			WHEN g.[Source Type] = 3 THEN 'Bank Account'
			WHEN g.[Source Type] = 4 THEN 'Fixed Asset'
			WHEN g.[Source Type] = 5 THEN 'Employee'
		END AS [Source Type],
		g.[Description],
		CASE
			WHEN g.[Gen_ Posting Type] = 0 THEN ''
			WHEN g.[Gen_ Posting Type] = 1 THEN 'Purchase'
			WHEN g.[Gen_ Posting Type] = 2 THEN 'Sale'
			WHEN g.[Gen_ Posting Type] = 3 THEN 'Settlement'
		END AS [Gen_ Posting Type],
		g.[Gen_ Bus_ Posting Group],
		g.[Gen_ Prod_ Posting Group],
		g.[VAT Amount] AS [Tax Amount],
		CASE
			WHEN g.[Bal_ Account Type] = 0 THEN 'G/L Account'
			WHEN g.[Bal_ Account Type] = 1 THEN 'Customer'
			WHEN g.[Bal_ Account Type] = 2 THEN 'Vendor'
			WHEN g.[Bal_ Account Type] = 3 THEN 'Bank Account'
			WHEN g.[Bal_ Account Type] = 4 THEN 'Fixed Assets'
			WHEN g.[Bal_ Account Type] = 5 THEN 'IC Partner'
			WHEN g.[Bal_ Account Type] = 6 THEN 'Employee'
		END AS [Bal Account Type],
		g.[Bal_ Account No_],
		g.[User ID],
		g.[Reason Code],
		g.[Transaction No_],
		g.[Document Date],
		g.[Entry No_],
		g.[Event Start Date],
		g.[Amount],

		(select TOP 1 [Group Location] from 
		dbo.[The Knowledge Academy Limited$Sales Invoice Line] as SIL1
		where g.[Document No_]= SIL1.[Document No_]
		and SIL1.[Group Location]IS NOT NULL) as 'Group Location',

(select sum([Quantity]) from dbo.[TKA Hong Kong Ltd_$Sales Invoice Line] as sil2 where 
g.[Document No_]= sil2.[Document No_] And g.[Event Header] = sil2.[Event Header]) as 'Quantity',
		--NEW COLUMN
		
		(select TOP 1 [Salesperson Code] from 
		dbo.[TKA Hong Kong Ltd_$Sales Invoice Line] as SIL1
		where g.[Document No_]= SIL1.[Document No_]) as 'Salesperson Code',

		(select TOP 1 [Default Team Code] from [dbo].[TKA Hong Kong Ltd_$Salesperson_Purchaser] as SP
		where (select TOP 1 [Salesperson Code] from 
		dbo.[TKA Hong Kong Ltd_$Sales Invoice Line] as SIL1
		where g.[Document No_]= SIL1.[Document No_]) = SP.Code) as 'Team Leader',

		(select TOP 1 [Manager Name] from [dbo].[TKA Hong Kong Ltd_$Team] as TM
		where (select TOP 1 [Default Team Code] from [dbo].[TKA Hong Kong Ltd_$Salesperson_Purchaser] as SP
		where (select TOP 1 [Salesperson Code] from 
		dbo.[TKA Hong Kong Ltd_$Sales Invoice Line] as SIL1
		where g.[Document No_]= SIL1.[Document No_]) = SP.Code) = TM.Code) as 'SalesManager',

		(select TOP 1 [Course] from [dbo].[Delivery Costs Analytic Datapo] as DC 
where (select TOP 1 [TKA course Id] from [dbo].[Course Header] as CH 
where (select top 1 [Course Header] from [dbo].[Event Header] as EH
where g.[Event Header] = EH.[No_]) = CH.[Code]) = DC.[CounterKey]) as 'TKA Course Name',


		(select [Your Reference] from 
		dbo.[TKA Hong Kong Ltd_$Sales Invoice Header] as SIH1
		where g.[Document No_]= SIH1.[No_])
		 as 'Customer PO No_',
		 
		 (select TOP 1 [Description] from 
		dbo.[TKA Hong Kong Ltd_$Purch_ Inv_ Line] as PIL1
		where g.[Document No_]= PIL1.[Document No_]
		and 
		PIL1.[No_]=g.[G_L Account No_]) as 'Purchase Description',

		
		(select TOP 1 [MA Label] from 
		dbo.[The Knowledge Academy Limited$G_L Account] as GLACCOUNT
		where  GLACCOUNT.[No_]=g.[G_L Account No_])
		as 'MA LABEL', 

				(select TOP 1 [FS Mapping] from 
		dbo.[The Knowledge Academy Limited$G_L Account] as GLACCOUNT
		where  GLACCOUNT.[No_]=g.[G_L Account No_])
		as 'FS Mapping', 
		 (select TOP 1 [FS FINER MAP21] from 
		dbo.[The Knowledge Academy Limited$G_L Account] as GLACCOUNT
		where  GLACCOUNT.[No_]=g.[G_L Account No_])
		as 'FS FINER MAP21', 



		g.[Amount] / ISNULL((SELECT TOP 1 (ce.[Relational Exch_ Rate Amount]/ce.[Exchange Rate Amount]) FROM dbo.[TKA Hong Kong Ltd_$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= 
				(SELECT DATEADD(m,1,DATEADD(m,datediff(m,0,g.[Posting Date]),0))) ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP]
FROM dbo.[TKA Hong Kong Ltd_$G_L Entry] g
INNER JOIN dbo.[TKA Hong Kong Ltd_$G_L Account] ga ON ga.[No_] = g.[G_L Account No_] 
--INNER JOIN dbo.[Event Header] e ON e.[No_] = g.[Event Header]
WHERE g.[Posting Date] BETWEEN @STDate AND @ETDate
UNION ALL
SELECT 'TKA New Zealand Ltd.' as [CName],
		g.[Posting Date],
		
		LEFT(DATENAME(month,g.[Posting Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( g.[Posting Date] ) % 100)) AS 'MonthYr',
		CASE 
			WHEN MONTH(g.[Posting Date]) >= 1 AND MONTH(g.[Posting Date]) <= 3 THEN MONTH(g.[Posting Date]) + 9
			ELSE MONTH(g.[Posting Date])-3
		END 'MonthNum',
		CASE
			WHEN MONTH(g.[Posting Date]) >= 1 AND MONTH(g.[Posting Date]) <= 3 THEN  Year(g.[Posting Date])-1
			ELSE Year(g.[Posting Date])
		END AS 'Year',
		g.[G_L Account No_],
		ga.[Name],
		g.[Event Header],
		CASE
			WHEN g.[Document Type] =0 THEN ''
			WHEN g.[Document Type] =1 THEN 'Payment'
			WHEN g.[Document Type] =2 THEN 'Invoice'
			WHEN g.[Document Type] =3 THEN 'Credit Memo'
			WHEN g.[Document Type] =4 THEN 'Finance Charge Memo'
			WHEN g.[Document Type] =5 THEN 'Reminder'
			WHEN g.[Document Type] =6 THEN 'Refund'
		END AS [Document Type],
		g.[Document No_],
		CASE
			WHEN g.[MasterType] = 0 THEN ''
			WHEN g.[MasterType] = 1 THEN 'Trainer'
			WHEN g.[MasterType] = 2 THEN 'Venue'
			WHEN g.[MasterType] = 3 THEN 'Exam'
			WHEN g.[MasterType] = 4 THEN 'Misc'
			WHEN g.[MasterType] = 5 THEN 'Print'
			WHEN g.[MasterType] = 6 THEN 'Technical'
			WHEN g.[MasterType] = 7 THEN 'Courseware'
			WHEN g.[MasterType] = 8 THEN 'Manual'
			WHEN g.[MasterType] = 9 THEN 'Travel'
			WHEN g.[MasterType] = 10 THEN 'NonEvent'
			WHEN g.[MasterType] = 11 THEN 'Invigilator'
			WHEN g.[MasterType] = 12 THEN 'External Course Booking'
		END AS [MasterType],
		g.[MasterCode],
		g.[External Document No_],

		g.[Event Cost Line No_],
		g.[Source No_],
		CASE
			WHEN g.[Source Type] = 0 THEN ''
			WHEN g.[Source Type] = 1 THEN 'Customer'
			WHEN g.[Source Type] = 2 THEN 'Vendor'
			WHEN g.[Source Type] = 3 THEN 'Bank Account'
			WHEN g.[Source Type] = 4 THEN 'Fixed Asset'
			WHEN g.[Source Type] = 5 THEN 'Employee'
		END AS [Source Type],
		g.[Description],
		CASE
			WHEN g.[Gen_ Posting Type] = 0 THEN ''
			WHEN g.[Gen_ Posting Type] = 1 THEN 'Purchase'
			WHEN g.[Gen_ Posting Type] = 2 THEN 'Sale'
			WHEN g.[Gen_ Posting Type] = 3 THEN 'Settlement'
		END AS [Gen_ Posting Type],
		g.[Gen_ Bus_ Posting Group],
		g.[Gen_ Prod_ Posting Group],
		g.[VAT Amount] AS [Tax Amount],
		CASE
			WHEN g.[Bal_ Account Type] = 0 THEN 'G/L Account'
			WHEN g.[Bal_ Account Type] = 1 THEN 'Customer'
			WHEN g.[Bal_ Account Type] = 2 THEN 'Vendor'
			WHEN g.[Bal_ Account Type] = 3 THEN 'Bank Account'
			WHEN g.[Bal_ Account Type] = 4 THEN 'Fixed Assets'
			WHEN g.[Bal_ Account Type] = 5 THEN 'IC Partner'
			WHEN g.[Bal_ Account Type] = 6 THEN 'Employee'
		END AS [Bal Account Type],
		g.[Bal_ Account No_],
		g.[User ID],
		g.[Reason Code],
		g.[Transaction No_],
		g.[Document Date],
		g.[Entry No_],
		g.[Event Start Date],
		g.[Amount],

		(select TOP 1 [Group Location] from 
		dbo.[The Knowledge Academy Limited$Sales Invoice Line] as SIL1
		where g.[Document No_]= SIL1.[Document No_]
		and SIL1.[Group Location]IS NOT NULL) as 'Group Location',

(select sum([Quantity]) from dbo.[TKA New Zealand Ltd_$Sales Invoice Line] as sil2 where 
g.[Document No_]= sil2.[Document No_] And g.[Event Header] = sil2.[Event Header]) as 'Quantity',
		--NEW COLUMN

		(select TOP 1 [Salesperson Code] from 
		dbo.[TKA New Zealand Ltd_$Sales Invoice Line] as SIL1
		where g.[Document No_]= SIL1.[Document No_]) as 'Salesperson Code',

		(select TOP 1 [Default Team Code] from [dbo].[TKA New Zealand Ltd_$Salesperson_Purchaser] as SP
		where (select TOP 1 [Salesperson Code] from 
		dbo.[TKA New Zealand Ltd_$Sales Invoice Line] as SIL1
		where g.[Document No_]= SIL1.[Document No_]) = SP.Code) as 'Team Leader',

		(select TOP 1 [Manager Name] from [dbo].[TKA New Zealand Ltd_$Team] as TM
		where (select TOP 1 [Default Team Code] from [dbo].[TKA New Zealand Ltd_$Salesperson_Purchaser] as SP
		where (select TOP 1 [Salesperson Code] from 
		dbo.[TKA New Zealand Ltd_$Sales Invoice Line] as SIL1
		where g.[Document No_]= SIL1.[Document No_]) = SP.Code) = TM.Code) as 'SalesManager',

		(select TOP 1 [Course] from [dbo].[Delivery Costs Analytic Datapo] as DC 
where (select TOP 1 [TKA course Id] from [dbo].[Course Header] as CH 
where (select top 1 [Course Header] from [dbo].[Event Header] as EH
where g.[Event Header] = EH.[No_]) = CH.[Code]) = DC.[CounterKey]) as 'TKA Course Name',
				 

		(select [Your Reference] from 
		dbo.[TKA New Zealand Ltd_$Sales Invoice Header] as SIH1
		where g.[Document No_]= SIH1.[No_])
		 as 'Customer PO No_',

		 
		 (select TOP 1 [Description] from 
		dbo.[TKA New Zealand Ltd_$Purch_ Inv_ Line] as PIL1
		where g.[Document No_]= PIL1.[Document No_]
		and 
		PIL1.[No_]=g.[G_L Account No_]) as 'Purchase Description',

		(select TOP 1 [MA Label] from 
		dbo.[The Knowledge Academy Limited$G_L Account] as GLACCOUNT
		where  GLACCOUNT.[No_]=g.[G_L Account No_])
		as 'MA LABEL', 

				(select TOP 1 [FS Mapping] from 
		dbo.[The Knowledge Academy Limited$G_L Account] as GLACCOUNT
		where  GLACCOUNT.[No_]=g.[G_L Account No_])
		as 'FS Mapping', 

		 (select TOP 1 [FS FINER MAP21] from 
		dbo.[The Knowledge Academy Limited$G_L Account] as GLACCOUNT
		where  GLACCOUNT.[No_]=g.[G_L Account No_])
		as 'FS FINER MAP21', 


		g.[Amount] / ISNULL((SELECT TOP 1 (ce.[Relational Exch_ Rate Amount]/ce.[Exchange Rate Amount]) FROM dbo.[TKA New Zealand Ltd_$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= 
				(SELECT DATEADD(m,1,DATEADD(m,datediff(m,0,g.[Posting Date]),0))) ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP]
FROM dbo.[TKA New Zealand Ltd_$G_L Entry] g 
INNER JOIN dbo.[TKA New Zealand Ltd_$G_L Account] ga ON ga.[No_] = g.[G_L Account No_] 
--INNER JOIN dbo.[Event Header] e ON e.[No_] = g.[Event Header]
WHERE g.[Posting Date] BETWEEN @STDate AND @ETDate
UNION ALL
SELECT 'TKA Singapore PTE Ltd.' as [CName],
		g.[Posting Date],
		
		LEFT(DATENAME(month,g.[Posting Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( g.[Posting Date] ) % 100)) AS 'MonthYr',
		CASE 
			WHEN MONTH(g.[Posting Date]) >= 1 AND MONTH(g.[Posting Date]) <= 3 THEN MONTH(g.[Posting Date]) + 9
			ELSE MONTH(g.[Posting Date])-3
		END 'MonthNum',
		CASE
			WHEN MONTH(g.[Posting Date]) >= 1 AND MONTH(g.[Posting Date]) <= 3 THEN  Year(g.[Posting Date])-1
			ELSE Year(g.[Posting Date])
		END AS 'Year',
		g.[G_L Account No_],
		ga.[Name],
		g.[Event Header],
		CASE
			WHEN g.[Document Type] =0 THEN ''
			WHEN g.[Document Type] =1 THEN 'Payment'
			WHEN g.[Document Type] =2 THEN 'Invoice'
			WHEN g.[Document Type] =3 THEN 'Credit Memo'
			WHEN g.[Document Type] =4 THEN 'Finance Charge Memo'
			WHEN g.[Document Type] =5 THEN 'Reminder'
			WHEN g.[Document Type] =6 THEN 'Refund'
		END AS [Document Type],
		g.[Document No_],
		CASE
			WHEN g.[MasterType] = 0 THEN ''
			WHEN g.[MasterType] = 1 THEN 'Trainer'
			WHEN g.[MasterType] = 2 THEN 'Venue'
			WHEN g.[MasterType] = 3 THEN 'Exam'
			WHEN g.[MasterType] = 4 THEN 'Misc'
			WHEN g.[MasterType] = 5 THEN 'Print'
			WHEN g.[MasterType] = 6 THEN 'Technical'
			WHEN g.[MasterType] = 7 THEN 'Courseware'
			WHEN g.[MasterType] = 8 THEN 'Manual'
			WHEN g.[MasterType] = 9 THEN 'Travel'
			WHEN g.[MasterType] = 10 THEN 'NonEvent'
			WHEN g.[MasterType] = 11 THEN 'Invigilator'
			WHEN g.[MasterType] = 12 THEN 'External Course Booking'
		END AS [MasterType],
		g.[MasterCode],
		g.[External Document No_],
		
		g.[Event Cost Line No_],
		g.[Source No_],
		CASE
			WHEN g.[Source Type] = 0 THEN ''
			WHEN g.[Source Type] = 1 THEN 'Customer'
			WHEN g.[Source Type] = 2 THEN 'Vendor'
			WHEN g.[Source Type] = 3 THEN 'Bank Account'
			WHEN g.[Source Type] = 4 THEN 'Fixed Asset'
			WHEN g.[Source Type] = 5 THEN 'Employee'
		END AS [Source Type],
		g.[Description],
		CASE
			WHEN g.[Gen_ Posting Type] = 0 THEN ''
			WHEN g.[Gen_ Posting Type] = 1 THEN 'Purchase'
			WHEN g.[Gen_ Posting Type] = 2 THEN 'Sale'
			WHEN g.[Gen_ Posting Type] = 3 THEN 'Settlement'
		END AS [Gen_ Posting Type],
		g.[Gen_ Bus_ Posting Group],
		g.[Gen_ Prod_ Posting Group],
		g.[VAT Amount] AS [Tax Amount],
		CASE
			WHEN g.[Bal_ Account Type] = 0 THEN 'G/L Account'
			WHEN g.[Bal_ Account Type] = 1 THEN 'Customer'
			WHEN g.[Bal_ Account Type] = 2 THEN 'Vendor'
			WHEN g.[Bal_ Account Type] = 3 THEN 'Bank Account'
			WHEN g.[Bal_ Account Type] = 4 THEN 'Fixed Assets'
			WHEN g.[Bal_ Account Type] = 5 THEN 'IC Partner'
			WHEN g.[Bal_ Account Type] = 6 THEN 'Employee'
		END AS [Bal Account Type],
		g.[Bal_ Account No_],
		g.[User ID],
		g.[Reason Code],
		g.[Transaction No_],
		g.[Document Date],
		g.[Entry No_],
		g.[Event Start Date],
		g.[Amount],

		(select TOP 1 [Group Location] from 
		dbo.[The Knowledge Academy Limited$Sales Invoice Line] as SIL1
		where g.[Document No_]= SIL1.[Document No_]
		and SIL1.[Group Location]IS NOT NULL) as 'Group Location',

(select sum([Quantity]) from dbo.[TKA Singapore PTE Ltd_$Sales Invoice Line] as sil2 where 
g.[Document No_]= sil2.[Document No_] And g.[Event Header] = sil2.[Event Header]) as 'Quantity',
		--NEW COLUMN
		
		(select TOP 1 [Salesperson Code] from 
		dbo.[TKA Singapore PTE Ltd_$Sales Invoice Line] as SIL1
		where g.[Document No_]= SIL1.[Document No_]) as 'Salesperson Code',

		(select TOP 1 [Default Team Code] from [dbo].[TKA Singapore PTE Ltd_$Salesperson_Purchaser] as SP
		where (select TOP 1 [Salesperson Code] from 
		dbo.[TKA Singapore PTE Ltd_$Sales Invoice Line] as SIL1
		where g.[Document No_]= SIL1.[Document No_]) = SP.Code) as 'Team Leader',

		(select TOP 1 [Manager Name] from [dbo].[TKA Singapore PTE Ltd_$Team] as TM
		where (select TOP 1 [Default Team Code] from [dbo].[TKA Singapore PTE Ltd_$Salesperson_Purchaser] as SP
		where (select TOP 1 [Salesperson Code] from 
		dbo.[TKA Singapore PTE Ltd_$Sales Invoice Line] as SIL1
		where g.[Document No_]= SIL1.[Document No_]) = SP.Code) = TM.Code) as 'SalesManager',

		(select TOP 1 [Course] from [dbo].[Delivery Costs Analytic Datapo] as DC 
where (select TOP 1 [TKA course Id] from [dbo].[Course Header] as CH 
where (select top 1 [Course Header] from [dbo].[Event Header] as EH
where g.[Event Header] = EH.[No_]) = CH.[Code]) = DC.[CounterKey]) as 'TKA Course Name',


		(select [Your Reference] from 
		dbo.[TKA Singapore PTE Ltd_$Sales Invoice Header] as SIH1
		where g.[Document No_]= SIH1.[No_])
		 as 'Customer PO No_',

		 
		 (select TOP 1 [Description] from 
		dbo.[TKA Singapore PTE Ltd_$Purch_ Inv_ Line] as PIL1
		where g.[Document No_]= PIL1.[Document No_]
		and 
		PIL1.[No_]=g.[G_L Account No_]) as 'Purchase Description',

		(select TOP 1 [MA Label] from 
		dbo.[The Knowledge Academy Limited$G_L Account] as GLACCOUNT
		where  GLACCOUNT.[No_]=g.[G_L Account No_])
		as 'MA LABEL', 

				(select TOP 1 [FS Mapping] from 
		dbo.[The Knowledge Academy Limited$G_L Account] as GLACCOUNT
		where  GLACCOUNT.[No_]=g.[G_L Account No_])
		as 'FS Mapping', 

		 (select TOP 1 [FS FINER MAP21] from 
		dbo.[The Knowledge Academy Limited$G_L Account] as GLACCOUNT
		where  GLACCOUNT.[No_]=g.[G_L Account No_])
		as 'FS FINER MAP21', 


		g.[Amount] / ISNULL((SELECT TOP 1 (ce.[Relational Exch_ Rate Amount]/ce.[Exchange Rate Amount]) FROM dbo.[TKA Singapore PTE Ltd_$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= 
				(SELECT DATEADD(m,1,DATEADD(m,datediff(m,0,g.[Posting Date]),0))) ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP]
FROM dbo.[TKA Singapore PTE Ltd_$G_L Entry] g 
INNER JOIN dbo.[TKA Singapore PTE Ltd_$G_L Account] ga ON ga.[No_] = g.[G_L Account No_] 
--INNER JOIN dbo.[Event Header] e ON e.[No_] = g.[Event Header]
WHERE g.[Posting Date] BETWEEN @STDate AND @ETDate




UNION ALL
SELECT 'The Knowledge Academy FreeZone' as [CName],
		g.[Posting Date],
		
		LEFT(DATENAME(month,g.[Posting Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( g.[Posting Date] ) % 100)) AS 'MonthYr',
		CASE 
			WHEN MONTH(g.[Posting Date]) >= 1 AND MONTH(g.[Posting Date]) <= 3 THEN MONTH(g.[Posting Date]) + 9
			ELSE MONTH(g.[Posting Date])-3
		END 'MonthNum',
		CASE
			WHEN MONTH(g.[Posting Date]) >= 1 AND MONTH(g.[Posting Date]) <= 3 THEN  Year(g.[Posting Date])-1
			ELSE Year(g.[Posting Date])
		END AS 'Year',
		g.[G_L Account No_],
		ga.[Name],
		g.[Event Header],
		CASE
			WHEN g.[Document Type] =0 THEN ''
			WHEN g.[Document Type] =1 THEN 'Payment'
			WHEN g.[Document Type] =2 THEN 'Invoice'
			WHEN g.[Document Type] =3 THEN 'Credit Memo'
			WHEN g.[Document Type] =4 THEN 'Finance Charge Memo'
			WHEN g.[Document Type] =5 THEN 'Reminder'
			WHEN g.[Document Type] =6 THEN 'Refund'
		END AS [Document Type],
		g.[Document No_],
		CASE
			WHEN g.[MasterType] = 0 THEN ''
			WHEN g.[MasterType] = 1 THEN 'Trainer'
			WHEN g.[MasterType] = 2 THEN 'Venue'
			WHEN g.[MasterType] = 3 THEN 'Exam'
			WHEN g.[MasterType] = 4 THEN 'Misc'
			WHEN g.[MasterType] = 5 THEN 'Print'
			WHEN g.[MasterType] = 6 THEN 'Technical'
			WHEN g.[MasterType] = 7 THEN 'Courseware'
			WHEN g.[MasterType] = 8 THEN 'Manual'
			WHEN g.[MasterType] = 9 THEN 'Travel'
			WHEN g.[MasterType] = 10 THEN 'NonEvent'
			WHEN g.[MasterType] = 11 THEN 'Invigilator'
			WHEN g.[MasterType] = 12 THEN 'External Course Booking'
		END AS [MasterType],
		g.[MasterCode],
		g.[External Document No_],

		g.[Event Cost Line No_],
		g.[Source No_],
		CASE
			WHEN g.[Source Type] = 0 THEN ''
			WHEN g.[Source Type] = 1 THEN 'Customer'
			WHEN g.[Source Type] = 2 THEN 'Vendor'
			WHEN g.[Source Type] = 3 THEN 'Bank Account'
			WHEN g.[Source Type] = 4 THEN 'Fixed Asset'
			WHEN g.[Source Type] = 5 THEN 'Employee'
		END AS [Source Type],
		g.[Description],
		CASE
			WHEN g.[Gen_ Posting Type] = 0 THEN ''
			WHEN g.[Gen_ Posting Type] = 1 THEN 'Purchase'
			WHEN g.[Gen_ Posting Type] = 2 THEN 'Sale'
			WHEN g.[Gen_ Posting Type] = 3 THEN 'Settlement'
		END AS [Gen_ Posting Type],
		g.[Gen_ Bus_ Posting Group],
		g.[Gen_ Prod_ Posting Group],
		g.[VAT Amount] AS [Tax Amount],
		CASE
			WHEN g.[Bal_ Account Type] = 0 THEN 'G/L Account'
			WHEN g.[Bal_ Account Type] = 1 THEN 'Customer'
			WHEN g.[Bal_ Account Type] = 2 THEN 'Vendor'
			WHEN g.[Bal_ Account Type] = 3 THEN 'Bank Account'
			WHEN g.[Bal_ Account Type] = 4 THEN 'Fixed Assets'
			WHEN g.[Bal_ Account Type] = 5 THEN 'IC Partner'
			WHEN g.[Bal_ Account Type] = 6 THEN 'Employee'
		END AS [Bal Account Type],
		g.[Bal_ Account No_],
		g.[User ID],
		g.[Reason Code],
		g.[Transaction No_],
		g.[Document Date],
		g.[Entry No_],
		g.[Event Start Date],
		g.[Amount],

		
		(select TOP 1 [Group Location] from 
		dbo.[The Knowledge Academy Limited$Sales Invoice Line] as SIL1
		where g.[Document No_]= SIL1.[Document No_]
		and SIL1.[Group Location]IS NOT NULL) as 'Group Location',

(select sum([Quantity]) from dbo.[The Knowledge Academy FreeZone$Sales Invoice Line] as sil2 where 
g.[Document No_]= sil2.[Document No_] And g.[Event Header] = sil2.[Event Header]) as 'Quantity',
		--NEW COLUMN

		(select TOP 1 [Salesperson Code] from 
		dbo.[The Knowledge Academy FreeZone$Sales Invoice Line] as SIL1
		where g.[Document No_]= SIL1.[Document No_]) as 'Salesperson Code',		

		(select TOP 1 [Default Team Code] from [dbo].[The Knowledge Academy FreeZone$Salesperson_Purchaser] as SP
		where (select TOP 1 [Salesperson Code] from 
		dbo.[The Knowledge Academy FreeZone$Sales Invoice Line] as SIL1
		where g.[Document No_]= SIL1.[Document No_]) = SP.Code) as 'Team Leader',

		(select TOP 1 [Manager Name] from [dbo].[The Knowledge Academy FreeZone$Team] as TM
		where (select TOP 1 [Default Team Code] from [dbo].[The Knowledge Academy FreeZone$Salesperson_Purchaser] as SP
		where (select TOP 1 [Salesperson Code] from 
		dbo.[The Knowledge Academy FreeZone$Sales Invoice Line] as SIL1
		where g.[Document No_]= SIL1.[Document No_]) = SP.Code) = TM.Code) as 'SalesManager',

		(select TOP 1 [Course] from [dbo].[Delivery Costs Analytic Datapo] as DC 
where (select TOP 1 [TKA course Id] from [dbo].[Course Header] as CH 
where (select top 1 [Course Header] from [dbo].[Event Header] as EH
where g.[Event Header] = EH.[No_]) = CH.[Code]) = DC.[CounterKey]) as 'TKA Course Name',

		(select [Your Reference] from 
		dbo.[The Knowledge Academy FreeZone$Sales Invoice Header] as SIH1
		where g.[Document No_]= SIH1.[No_])
		 as 'Customer PO No_',

		 (select TOP 1 [Description] from 
		dbo.[The Knowledge Academy FreeZone$Purch_ Inv_ Line] as PIL1
		where g.[Document No_]= PIL1.[Document No_]
		and 
		PIL1.[No_]=g.[G_L Account No_]) as 'Purchase Description',
		
		(select TOP 1 [MA Label] from 
		dbo.[The Knowledge Academy Limited$G_L Account] as GLACCOUNT
		where  GLACCOUNT.[No_]=g.[G_L Account No_])
		as 'MA LABEL', 

		(select TOP 1 [FS Mapping] from 
		dbo.[The Knowledge Academy Limited$G_L Account] as GLACCOUNT
		where  GLACCOUNT.[No_]=g.[G_L Account No_])
		as 'FS Mapping', 

		 (select TOP 1 [FS FINER MAP21] from 
		dbo.[The Knowledge Academy Limited$G_L Account] as GLACCOUNT
		where  GLACCOUNT.[No_]=g.[G_L Account No_])
		as 'FS FINER MAP21', 


		g.[Amount] as [AmtGBP]
FROM dbo.[The Knowledge Academy FreeZone$G_L Entry] g
INNER JOIN dbo.[The Knowledge Academy FreeZone$G_L Account] ga ON ga.[No_] = g.[G_L Account No_]
--INNER JOIN dbo.[Event Header] e ON e.[No_] = g.[Event Header]
WHERE g.[Posting Date] BETWEEN @STDate AND @ETDate

UNION ALL
SELECT 'Pearce Mayfield Train Dubai' as [CName],
		g.[Posting Date],
		
		LEFT(DATENAME(month,g.[Posting Date]),3)+'-'+CONVERT(VARCHAR(2),(YEAR( g.[Posting Date] ) % 100)) AS 'MonthYr',
		CASE 
			WHEN MONTH(g.[Posting Date]) >= 1 AND MONTH(g.[Posting Date]) <= 3 THEN MONTH(g.[Posting Date]) + 9
			ELSE MONTH(g.[Posting Date])-3
		END 'MonthNum',
		CASE
			WHEN MONTH(g.[Posting Date]) >= 1 AND MONTH(g.[Posting Date]) <= 3 THEN  Year(g.[Posting Date])-1
			ELSE Year(g.[Posting Date])
		END AS 'Year',
		g.[G_L Account No_],
		ga.[Name],
		g.[Event Header],
		CASE
			WHEN g.[Document Type] =0 THEN ''
			WHEN g.[Document Type] =1 THEN 'Payment'
			WHEN g.[Document Type] =2 THEN 'Invoice'
			WHEN g.[Document Type] =3 THEN 'Credit Memo'
			WHEN g.[Document Type] =4 THEN 'Finance Charge Memo'
			WHEN g.[Document Type] =5 THEN 'Reminder'
			WHEN g.[Document Type] =6 THEN 'Refund'
		END AS [Document Type],
		g.[Document No_],
		CASE
			WHEN g.[MasterType] = 0 THEN ''
			WHEN g.[MasterType] = 1 THEN 'Trainer'
			WHEN g.[MasterType] = 2 THEN 'Venue'
			WHEN g.[MasterType] = 3 THEN 'Exam'
			WHEN g.[MasterType] = 4 THEN 'Misc'
			WHEN g.[MasterType] = 5 THEN 'Print'
			WHEN g.[MasterType] = 6 THEN 'Technical'
			WHEN g.[MasterType] = 7 THEN 'Courseware'
			WHEN g.[MasterType] = 8 THEN 'Manual'
			WHEN g.[MasterType] = 9 THEN 'Travel'
			WHEN g.[MasterType] = 10 THEN 'NonEvent'
			WHEN g.[MasterType] = 11 THEN 'Invigilator'
			WHEN g.[MasterType] = 12 THEN 'External Course Booking'
		END AS [MasterType],
		g.[MasterCode],
		g.[External Document No_],

		g.[Event Cost Line No_],
		g.[Source No_],
		CASE
			WHEN g.[Source Type] = 0 THEN ''
			WHEN g.[Source Type] = 1 THEN 'Customer'
			WHEN g.[Source Type] = 2 THEN 'Vendor'
			WHEN g.[Source Type] = 3 THEN 'Bank Account'
			WHEN g.[Source Type] = 4 THEN 'Fixed Asset'
			WHEN g.[Source Type] = 5 THEN 'Employee'
		END AS [Source Type],
		g.[Description],
		CASE
			WHEN g.[Gen_ Posting Type] = 0 THEN ''
			WHEN g.[Gen_ Posting Type] = 1 THEN 'Purchase'
			WHEN g.[Gen_ Posting Type] = 2 THEN 'Sale'
			WHEN g.[Gen_ Posting Type] = 3 THEN 'Settlement'
		END AS [Gen_ Posting Type],
		g.[Gen_ Bus_ Posting Group],
		g.[Gen_ Prod_ Posting Group],
		g.[VAT Amount] AS [Tax Amount],
		CASE
			WHEN g.[Bal_ Account Type] = 0 THEN 'G/L Account'
			WHEN g.[Bal_ Account Type] = 1 THEN 'Customer'
			WHEN g.[Bal_ Account Type] = 2 THEN 'Vendor'
			WHEN g.[Bal_ Account Type] = 3 THEN 'Bank Account'
			WHEN g.[Bal_ Account Type] = 4 THEN 'Fixed Assets'
			WHEN g.[Bal_ Account Type] = 5 THEN 'IC Partner'
			WHEN g.[Bal_ Account Type] = 6 THEN 'Employee'
		END AS [Bal Account Type],
		g.[Bal_ Account No_],
		g.[User ID],
		g.[Reason Code],
		g.[Transaction No_],
		g.[Document Date],
		g.[Entry No_],
		g.[Event Start Date],
		g.[Amount],

		
		(select TOP 1 [Group Location] from 
		dbo.[The Knowledge Academy Limited$Sales Invoice Line] as SIL1
		where g.[Document No_]= SIL1.[Document No_]
		and SIL1.[Group Location]IS NOT NULL) as 'Group Location',

(select sum([Quantity]) from dbo.[Pearce Mayfield Train Dubai$Sales Invoice Line] as sil2 where 
g.[Document No_]= sil2.[Document No_] And g.[Event Header] = sil2.[Event Header]) as 'Quantity',
		--NEW COLUMN

		(select TOP 1 [Salesperson Code] from 
		dbo.[Pearce Mayfield Train Dubai$Sales Invoice Line] as SIL1
		where g.[Document No_]= SIL1.[Document No_]) as 'Salesperson Code',

		(select TOP 1 [Default Team Code] from [dbo].[Pearce Mayfield Train Dubai$Salesperson_Purchaser] as SP
		where (select TOP 1 [Salesperson Code] from 
		dbo.[Pearce Mayfield Train Dubai$Sales Invoice Line] as SIL1
		where g.[Document No_]= SIL1.[Document No_]) = SP.Code) as 'Team Leader',

		(select TOP 1 [Manager Name] from [dbo].[Pearce Mayfield Train Dubai$Team] as TM
		where (select TOP 1 [Default Team Code] from [dbo].[Pearce Mayfield Train Dubai$Salesperson_Purchaser] as SP
		where (select TOP 1 [Salesperson Code] from 
		dbo.[Pearce Mayfield Train Dubai$Sales Invoice Line] as SIL1
		where g.[Document No_]= SIL1.[Document No_]) = SP.Code) = TM.Code) as 'SalesManager',

		(select TOP 1 [Course] from [dbo].[Delivery Costs Analytic Datapo] as DC 
where (select TOP 1 [TKA course Id] from [dbo].[Course Header] as CH 
where (select top 1 [Course Header] from [dbo].[Event Header] as EH
where g.[Event Header] = EH.[No_]) = CH.[Code]) = DC.[CounterKey]) as 'TKA Course Name',
		
		
		(select [Your Reference] from 
		dbo.[Pearce Mayfield Train Dubai$Sales Invoice Header] as SIH1
		where g.[Document No_]= SIH1.[No_])
		 as 'Customer PO No_',

		 (select TOP 1 [Description] from 
		dbo.[Pearce Mayfield Train Dubai$Purch_ Inv_ Line] as PIL1
		where g.[Document No_]= PIL1.[Document No_]
		and 
		
		PIL1.[No_]=g.[G_L Account No_]) as 'Purchase Description',
		
		
		(select TOP 1 [MA Label] from 
		dbo.[The Knowledge Academy Limited$G_L Account] as GLACCOUNT
		where  GLACCOUNT.[No_]=g.[G_L Account No_])
		as 'MA LABEL', 

		(select TOP 1 [FS Mapping] from 
		dbo.[The Knowledge Academy Limited$G_L Account] as GLACCOUNT
		where  GLACCOUNT.[No_]=g.[G_L Account No_])
		as 'FS Mapping', 

		 (select TOP 1 [FS FINER MAP21] from 
		dbo.[The Knowledge Academy Limited$G_L Account] as GLACCOUNT
		where  GLACCOUNT.[No_]=g.[G_L Account No_])
		as 'FS FINER MAP21', 

		--g.[Amount] as [AmtGBP]
		g.[Amount] / ISNULL((SELECT TOP 1 (ce.[Relational Exch_ Rate Amount]/ce.[Exchange Rate Amount]) FROM dbo.[Pearce Mayfield Train Dubai$Currency Exchange Rate] ce
				WHERE ce.[Currency Code] = 'GBP' AND ce.[Starting Date] <= 
				(SELECT DATEADD(m,1,DATEADD(m,datediff(m,0,g.[Posting Date]),0))) ORDER BY ce.[Starting Date] DESC),1)
				as [AmtGBP]
FROM dbo.[Pearce Mayfield Train Dubai$G_L Entry] g
INNER JOIN dbo.[Pearce Mayfield Train Dubai$G_L Account] ga ON ga.[No_] = g.[G_L Account No_]
--INNER JOIN dbo.[Event Header] e ON e.[No_] = g.[Event Header]
WHERE g.[Posting Date] BETWEEN @STDate AND @ETDate

)A

LEFT OUTER JOIN dbo.[The Knowledge Academy Limited$G_L Account] g ON A.[G_L Account No_] = g.[No_]
LEFT OUTER JOIN dbo.[The Knowledge Academy Limited$GIFI Code TKA] gi on g.[GIFI Code] = gi.[Code]
LEFT OUTER JOIN dbo.[Event Header] e ON e.[No_] = A.[Event Header]
WHERE A.[G_L Account No_] >= @FromGL AND A.[G_L Account No_]  <= @TOGL

GO


