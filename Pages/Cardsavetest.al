// page 70084 "Card Save "
// {
//     // //DOC TKA_200611 - created

//     DeleteAllowed = false;
//     InsertAllowed = false;
//     PageType = List;
//     SourceTable = 50075;
//     applicationarea = all;
//     UsageCategory = Administration;
//     SourceTableView = SORTING("Cross Reference");

//     layout
//     {
//         area(content)
//         {
//             // field(' Current Filters: ' + GETFILTERS();' Current Filters: ' + GETFILTERS())
//             // {
//             //     Editable = false;
//             //     MultiLine = true;
//             // }
//             repeater(repeater)
//             {
//                 field("Date & Time"; rec."Date & Time")
//                 {
//                 }
//                 field("Cross Reference"; rec."Cross Reference")
//                 {
//                     Caption = 'PAS Ref. No';
//                     Editable = false;
//                 }
//                 field("Order ID"; rec."Order ID")
//                 {
//                     Editable = false;
//                 }
//                 field("Order Description"; rec."Order Description")
//                 {
//                 }
//                 field("Transaction Type"; rec."Transaction Type")
//                 {
//                     Editable = true;
//                 }
//                 field("Card Type"; rec."Card Type")
//                 {
//                 }
//                 field("Amount Received"; "Amount Received")
//                 {
//                     Caption = 'Amount Received';
//                     Editable = false;
//                 }
//                 field("Sales Order No"; "Sales Order No")
//                 {
//                     Caption = 'Sales Order No.';
//                     Editable = false;
//                 }
//                 field(SalesOrderCurrency; SalesOrderCurrency)
//                 {
//                     Caption = 'SalesOrder Currency';
//                     Editable = false;
//                 }
//                 field(CustomerCurrency; CustomerCurrency)
//                 {
//                     Caption = 'Customer Currency';
//                     Editable = false;
//                 }
//                 field("Card Number"; rec."Card Number")
//                 {
//                 }
//                 field(Amount; rec.Amount)
//                 {
//                     Caption = 'Payment Amount';
//                     Editable = false;
//                 }
//                 field("Sales Invoice No."; rec."Sales Invoice No.")
//                 {
//                 }
//                 field(AutoPASEntry; rec.AutoPASEntry)
//                 {
//                     Editable = false;
//                 }
//                 field("Sales Invoice Posted"; rec."Sales Invoice Posted")
//                 {
//                     Editable = false;
//                 }
//                 field("Sales Invoice No"; rec."Sales Invoice No")
//                 {
//                     Editable = false;
//                 }
//                 field("Payment Entry Posted"; rec."Payment Entry Posted")
//                 {
//                     Editable = false;
//                 }
//                 field("Payment Document No"; rec."Payment Document No")
//                 {
//                     Editable = false;
//                 }
//                 field("Auto Sales Order Post Error"; rec."Auto Sales Order Post Error")
//                 {
//                     Editable = false;
//                 }
//                 field(AutoPASDateTime; rec.AutoPASDateTime)
//                 {
//                     Editable = false;
//                 }
//                 field("Card Name"; rec."Card Name")
//                 {
//                 }
//                 field("Authorisation Status"; rec."Authorisation Status")
//                 {
//                 }
//                 field("Trans. Message"; rec."Trans. Message")
//                 {
//                 }
//                 field("Bill-to Customer No."; rec."Bill-to Customer No.")
//                 {
//                 }
//                 field("STRIPE Code"; rec."STRIPE Code")
//                 {
//                     Editable = false;
//                 }
//                 field("Currency Code"; rec."Currency Code")
//                 {
//                 }
//                 field(Comments; rec.Comments)
//                 {
//                 }
//                 field("BATCH ID"; rec."BATCH ID")
//                 {
//                 }
//                 field("Merchant ID"; rec."Merchant ID")
//                 {
//                 }
//                 field(BATCHMerchantID; rec.BATCHMerchantID)
//                 {
//                 }
//                 field("Override Used"; rec."Override Used")
//                 {
//                 }
//                 field("Process Manually"; rec."Process Manually")
//                 {
//                 }
//                 field("Manual Processing Date"; rec."Manual Processing Date")
//                 {
//                 }
//                 field("Create Payment Journal"; rec."Create Payment Journal")
//                 {
//                 }
//                 field("Payment Journal Created"; rec."Payment Journal Created")
//                 {
//                     Editable = true;
//                 }
//                 field("No. of Entries"; rec."No. of Entries")
//                 {
//                     //Blankzero = true;
//                     Caption = 'No. of Docs';
//                 }
//                 field("Close To-do"; rec."Close To-do")
//                 {
//                 }
//                 field("Total Sales Amount"; rec."Total Sales Amount")
//                 {
//                     //Blankzero = true;
//                     Caption = 'Order/ Invoice Amount';
//                 }
//                 field("All Documents Posted"; rec."All Documents Posted")
//                 {
//                     Caption = 'All Docs Posted';
//                 }
//                 field("All Payments Applied"; rec."All Payments Applied")
//                 {
//                     Caption = 'All Pmts. Applied';
//                 }
//                 field(Processed; rec.Processed)
//                 {
//                     Editable = true;
//                 }
//                 field("Error Text"; rec."Error Text")
//                 {
//                     Style = Attention;
//                     StyleExpr = TRUE;
//                 }


//             }
//             field("<Error Text>1"; rec."Error Text")
//             {
//                 Editable = false;
//                 MultiLine = true;
//                 Style = Attention;
//                 StyleExpr = TRUE;
//             }
//             part(sf; 50085)
//             {
//                 Editable = sfEditable;
//                 SubPageLink = "Cross Reference" = FIELD("Cross Reference");
//             }
//             field(Text19072904; '')
//             {
//                 CaptionClass = Text19072904;
//             }
//         }
//     }

//     actions
//     {
//         area(processing)
//         {
//             action(AutoPayment)
//             {
//                 Caption = 'Auto Post Payment';
//                 Promoted = true;
//                 PromotedCategory = Process;
//                 ToolTip = 'Step 2 for Auto payment';
//                 Visible = true;

//                 trigger OnAction()
//                 begin
//                     IF UPPERCASE(USERID) IN ['MARTHA.FOLKES', 'BIJU.KURUP', 'SIMRANDEEP.KAUR', 'TRIZA.BEHAL', 'JUHI.SHARMA',
//                     'PRABHJOT.KAUR'] THEN BEGIN
//                         IF CONFIRM('Are you sure to Post Auto Payment Entry') THEN
//                             MakePaymentEntry1
//                     END
//                     ELSE
//                         ERROR('You do not have permission for Auto payment');

//                     //IF "Web Order" THEN
//                     //"Sales Order PAS Auto Post".WebSales(TRUE);
//                     //ELSE
//                     //"Sales Order PAS Auto Post".WebSales(FALSE);



//                     //"Sales Order PAS Auto Post".RUN;
//                 end;
//             }
//             action(AutoPayment1)
//             {
//                 Caption = 'Check Posted Invoice Data';
//                 Promoted = true;
//                 PromotedCategory = Process;
//                 ToolTip = 'Step 1 for Auto payment';
//                 Visible = true;

//                 trigger OnAction()
//                 begin
//                     IF UPPERCASE(USERID) IN ['MARTHA.FOLKES', 'BIJU.KURUP', 'SIMRANDEEP.KAUR', 'TRIZA.BEHAL', 'JUHI.SHARMA',
//                     'PRABHJOT.KAUR'] THEN
//                         UpdatIndiaInfo1
//                     ELSE
//                         ERROR('You do not have permission for Auto payment');
//                     //IF "Web Order" THEN
//                     //"Sales Order PAS Auto Post".WebSales(TRUE);
//                     //ELSE
//                     //"Sales Order PAS Auto Post".WebSales(FALSE);



//                     //"Sales Order PAS Auto Post".RUN;
//                 end;
//             }
//             action("Auto Post CardSave Entries")
//             {
//                 Caption = 'Auto Post CardSave Entries';
//                 Promoted = true;
//                 PromotedCategory = Process;
//                 Visible = true;

//                 trigger OnAction()
//                 begin
//                     IF rec."Web Order" THEN
//                         "Sales Order PAS Auto Post".WebSales(TRUE)
//                     ELSE
//                         "Sales Order PAS Auto Post".WebSales(FALSE);

//                     "Sales Order PAS Auto Post".RUN;
//                 end;
//             }
//             action("Not Processed")
//             {
//                 Caption = 'Not Processed';
//                 Promoted = true;
//                 PromotedCategory = Process;

//                 trigger OnAction()
//                 begin
//                     rec.SETRANGE(Processed, FALSE);
//                 end;
//             }
//             action("Remove Filters")
//             {
//                 Caption = 'Remove Filters';
//                 Promoted = true;
//                 PromotedCategory = Process;

//                 trigger OnAction()
//                 begin
//                     rec.SETRANGE(Processed);
//                 end;
//             }
//             group(btnFunctionsStandard)
//             {
//                 Caption = 'Functions';
//                 Visible = btnFunctionsStandardVisible;
//                 action("Reset  Record")
//                 {
//                     Caption = 'Reset Record';

//                     trigger OnAction()
//                     var
//                         lCardSaveApp: Record 50069;
//                     begin
//                         IF NOT rec.Processed THEN BEGIN
//                             IF CONFIRM(TKATxt002, FALSE) THEN BEGIN
//                                 rec."Sales Invoice No." := '';
//                                 rec."Sales Order No." := '';
//                                 rec."Sales Quote No." := '';
//                                 rec."Sales Order Posting Date" := 0D;
//                                 rec."Sales Order Course Date" := 0D;
//                                 rec."Shortcut Dimension 1 Code" := '';
//                                 rec."Shortcut Dimension 2 Code" := '';
//                                 rec."Sales Order Amount" := 0;
//                                 rec."Warning Amounts Different" := FALSE;
//                                 rec."Bill-to Customer No." := '';
//                                 rec."Bill-to Name" := '';
//                                 rec."Sell-to Contact No." := '';
//                                 rec."Salesperson Code" := '';
//                                 rec."Documents Found" := FALSE;
//                                 rec."Payment Journal Created" := FALSE;
//                                 rec."Document Posted" := FALSE;
//                                 rec."Payment Applied" := FALSE;
//                                 rec."Error Text" := '';
//                                 rec."Payment Ledger Entry No." := 0;
//                                 rec."Document Ledger Entry No." := 0;

//                                 // Direction ------------------------------------------------------------
//                                 IF NOT rec.Processed THEN BEGIN
//                                     rec.CALCFIELDS("Total Sales Amount");
//                                     rec."Warning Amounts Different" := (rec."Total Sales Amount" <> rec.Amount);
//                                 END;
//                                 rec.MODIFY;

//                                 lCardSaveApp.RESET;
//                                 lCardSaveApp.SETRANGE("Cross Reference", rec."Cross Reference");
//                                 IF lCardSaveApp.FINDSET THEN
//                                     lCardSaveApp.DELETEALL;
//                                 COMMIT;
//                                 // Direction ------------------------------------------------------------

//                                 // Direction ------------------------------------------------------------
//                                 //lCardSaveApp.SETRANGE("Cross Reference","Cross Reference");
//                                 //lCardSaveApp.DELETEALL(TRUE);
//                                 //MODIFY;
//                                 //COMMIT;
//                                 // Direction ------------------------------------------------------------
//                             END;
//                         END ELSE
//                             ERROR(ErrTxt001);
//                     end;
//                 }
//             }
//             group(btnFunctionsMain)
//             {
//                 Caption = 'Functions';
//                 Visible = btnFunctionsMainVisible;
//                 action("Process ALL")
//                 {
//                     Caption = 'Process ALL';

//                     trigger OnAction()
//                     var
//                         lCSIB: Record 50075;
//                         lFinanceMgtCSIB: Codeunit "Finance Mgt. (CSIB)";
//                     begin
//                         //lCSIB.SETRANGE("Web Order",FALSE);
//                         //lCSIB.SETRANGE("Cheque Entry",FALSE);
//                         lCSIB.SETVIEW(RecFilters);
//                         lCSIB.SETRANGE("Create Payment Journal", TRUE);
//                         IF NOT lCSIB.ISEMPTY THEN BEGIN
//                             lCSIB.FINDFIRST;
//                             REPEAT
//                                 lCSIB.MARK(TRUE);
//                             UNTIL lCSIB.NEXT = 0;
//                         END;

//                         lCSIB.SETRANGE("Create Payment Journal");
//                         lCSIB.SETRANGE("Payment Journal Created", TRUE);
//                         lCSIB.SETRANGE(Processed, FALSE);
//                         IF NOT lCSIB.ISEMPTY THEN BEGIN
//                             lCSIB.FINDFIRST;
//                             REPEAT
//                                 lCSIB.MARK(TRUE);
//                             UNTIL lCSIB.NEXT = 0;
//                         END;

//                         lCSIB.SETRANGE("Payment Journal Created");
//                         lCSIB.SETRANGE(Processed);

//                         lCSIB.MARKEDONLY(TRUE);

//                         lFinanceMgtCSIB.CSIB_SetRunMode(0);
//                         lFinanceMgtCSIB.CSIB_SetValues_0(lCSIB);
//                         lFinanceMgtCSIB.RUN;
//                     end;
//                 }
//                 action("Mark as &Processed")
//                 {
//                     Caption = 'Mark as &Processed';

//                     trigger OnAction()
//                     begin
//                         IF CONFIRM(TKATxt001, FALSE) THEN BEGIN
//                             rec.Processed := TRUE;
//                             rec.MODIFY;
//                         END;
//                     end;
//                 }
//                 action("Export Not Processed Transactions")
//                 {
//                     Caption = 'Export Not Processed Transactions';

//                     trigger OnAction()
//                     begin
//                         IF UPPERCASE(USERID) IN ['MARTHA.FOLKES', 'TRIZA.BEHAL', 'BIJU.KURUP', 'JUHI.SHARMA', 'SIMRANDEEP.KAUR'] THEN
//                             ExportToMail();
//                     end;
//                 }
//                 action("Mark as Processed ALL")
//                 {
//                     Caption = 'Mark as Processed ALL';

//                     trigger OnAction()
//                     begin
//                         IF CONFIRM('Are you sure you want to Process all payments of which Payment Journal are created?') THEN BEGIN

//                             CSIB3.RESET;
//                             CSIB3.SETRANGE(CSIB3."Payment Journal Created", TRUE);
//                             CSIB3.SETRANGE(CSIB3.Processed, FALSE);
//                             // MESSAGE('%1',CSIB3.COUNT);
//                             IF CSIB3.FINDSET THEN
//                                 REPEAT
//                                     CSIB3.Processed := TRUE;
//                                     CSIB3.MODIFY;
//                                 UNTIL CSIB3.NEXT = 0;
//                         END;
//                     end;
//                 }
//                 action("Selected Lines - Mark as Processed")
//                 {
//                     Caption = 'Selected Lines - Mark as Processed';

//                     trigger OnAction()
//                     begin
//                         CSIB3.RESET;
//                         CLEAR(CSIB3);
//                         CurrPage.SETSELECTIONFILTER(CSIB3);
//                         a := 0;
//                         IF CSIB3.FINDSET THEN
//                             REPEAT
//                                 CSIB3.Processed := TRUE;
//                                 CSIB3.MODIFY;
//                                 a += 1
//                             UNTIL CSIB3.NEXT = 0;

//                         MESSAGE('%1 transactions marked as processed', a);
//                     end;
//                 }
//                 separator(separator3)
//                 {
//                 }
//                 action("Reset Record")
//                 {
//                     Caption = 'Reset Record';

//                     trigger OnAction()
//                     var
//                         lCardSaveApp: Record 50069;
//                     begin
//                         IF NOT rec.Processed THEN BEGIN
//                             IF CONFIRM(TKATxt002, FALSE) THEN BEGIN
//                                 rec."Sales Invoice No." := '';
//                                 rec."Sales Order No." := '';
//                                 rec."Sales Quote No." := '';
//                                 rec."Sales Order Posting Date" := 0D;
//                                 rec."Sales Order Course Date" := 0D;
//                                 rec."Shortcut Dimension 1 Code" := '';
//                                 rec."Shortcut Dimension 2 Code" := '';
//                                 rec."Sales Order Amount" := 0;
//                                 rec."Warning Amounts Different" := FALSE;
//                                 rec."Bill-to Customer No." := '';
//                                 rec."Bill-to Name" := '';
//                                 rec."Sell-to Contact No." := '';
//                                 rec."Salesperson Code" := '';
//                                 rec."Documents Found" := FALSE;
//                                 rec."Payment Journal Created" := FALSE;
//                                 rec."Document Posted" := FALSE;
//                                 rec."Payment Applied" := FALSE;
//                                 rec."Error Text" := '';
//                                 rec."Payment Ledger Entry No." := 0;
//                                 rec."Document Ledger Entry No." := 0;

//                                 // Direction ------------------------------------------------------------
//                                 IF NOT rec.Processed THEN BEGIN
//                                     rec.CALCFIELDS("Total Sales Amount");
//                                     rec."Warning Amounts Different" := (rec."Total Sales Amount" <> rec.Amount);
//                                 END;
//                                 rec.MODIFY;
//                                 lCardSaveApp.RESET;
//                                 lCardSaveApp.SETRANGE("Cross Reference", rec."Cross Reference");
//                                 IF lCardSaveApp.FINDSET THEN
//                                     lCardSaveApp.DELETEALL;
//                                 COMMIT;

//                                 // Direction ------------------------------------------------------------

//                                 // Direction ------------------------------------------------------------
//                                 //lCardSaveApp.SETRANGE("Cross Reference","Cross Reference");
//                                 //lCardSaveApp.DELETEALL(TRUE);
//                                 //MODIFY;
//                                 //COMMIT;
//                                 // Direction ------------------------------------------------------------
//                             END;
//                         END ELSE
//                             ERROR(ErrTxt001);
//                     end;
//                 }
//                 separator(separator)
//                 {
//                 }
//                 action("<Create Payment &Journal>")
//                 {
//                     Caption = '<Create Payment &Journal>';

//                     trigger OnAction()
//                     var
//                         CardSaveImportBuffer: Record 50075;
//                         GenJournalLine: Record 81;
//                         OldGenJournalLine: Record 81;
//                         LineNo: Integer;
//                     begin
//                         OldGenJournalLine."Journal Template Name" := 'CASHRCPT';
//                         OldGenJournalLine."Journal Batch Name" := 'CARDSAVE';

//                         GenJournalLine.INIT;
//                         GenJournalLine."Journal Template Name" := 'CASHRCPT';
//                         GenJournalLine."Journal Batch Name" := 'CARDSAVE';
//                         GenJournalLine.SetUpNewLine(OldGenJournalLine, 0, FALSE);

//                         CardSaveImportBuffer.SETRANGE("Create Payment Journal", TRUE);
//                         IF CardSaveImportBuffer.FINDFIRST THEN
//                             REPEAT
//                                 LineNo += 1000;
//                                 GenJournalLine.INIT;
//                                 GenJournalLine."Journal Template Name" := 'CASHRCPT';
//                                 GenJournalLine."Journal Batch Name" := 'CARDSAVE';
//                                 GenJournalLine.SetUpNewLine(OldGenJournalLine, 0, TRUE);

//                                 GenJournalLine."Line No." := LineNo;
//                                 GenJournalLine.VALIDATE("Account Type", GenJournalLine."Account Type"::Customer);
//                                 GenJournalLine.VALIDATE("Account No.", CardSaveImportBuffer."Bill-to Customer No.");
//                                 GenJournalLine.VALIDATE("Posting Date", DT2DATE(CardSaveImportBuffer."Date & Time"));
//                                 GenJournalLine.VALIDATE("Document Type", GenJournalLine."Document Type"::Payment);
//                                 GenJournalLine.Description := COPYSTR(GenJournalLine.Description, 1, 35) + ': ' + CardSaveImportBuffer."Sales Order No.";
//                                 GenJournalLine.VALIDATE(Amount, -CardSaveImportBuffer.Amount);
//                                 GenJournalLine.VALIDATE("Shortcut Dimension 1 Code", CardSaveImportBuffer."Shortcut Dimension 1 Code");
//                                 GenJournalLine.VALIDATE("Shortcut Dimension 2 Code", CardSaveImportBuffer."Shortcut Dimension 2 Code");
//                                 GenJournalLine.INSERT;

//                                 CardSaveImportBuffer."Create Payment Journal" := FALSE;
//                                 CardSaveImportBuffer.Processed := TRUE;
//                                 CardSaveImportBuffer.MODIFY;

//                                 OldGenJournalLine := GenJournalLine;
//                             UNTIL CardSaveImportBuffer.NEXT = 0;
//                     end;
//                 }
//                 separator(separator1)
//                 {
//                 }
//                 action("Make Customers Blank")
//                 {
//                     Caption = 'Make Customers Blank';

//                     trigger OnAction()
//                     begin
//                         IF CONFIRM('Are you sure to Blank this Customer') THEN BEGIN
//                             IF rec.Processed THEN
//                                 ERROR('This record is already processed')
//                             ELSE BEGIN
//                                 //IF "Sales Invoice No" <>'' THEN BEGIN
//                                 Rec."Bill-to Customer No." := '';
//                                 Rec.VALIDATE("Bill-to Customer No.", '');
//                                 Rec.MODIFY;
//                                 // END;
//                             END;
//                         END;
//                     end;
//                 }
//                 action("Process ONE")
//                 {
//                     Caption = 'Process ONE';

//                     trigger OnAction()
//                     var
//                         lCSIB: Record 50075;
//                         lFinanceMgtCSIB: Codeunit 50007;
//                     begin
//                         CheckAmountInApplication;

//                         IF (NOT ((lCSIB."Create Payment Journal") OR (lCSIB."Payment Journal Created")) AND (lCSIB."Documents Found")) THEN
//                             ERROR('Nothing to Process, Check Line and Try Again');

//                         IF NOT CONFIRM('Are you sure you wish to process this ONE entry only?', FALSE) THEN
//                             EXIT;

//                         lCSIB.GET(rec."Cross Reference");

//                         CSIB2.GET(rec."Cross Reference"); //131022 abhishek


//                         IF CSIB2."Currency Code" <> '' THEN BEGIN
//                             IF Customer1.GET() THEN BEGIN
//                                 IF Customer1."Currency Code" <> CSIB2."Currency Code" THEN
//                                     ERROR('Currency code on Customer Card is different , can not post');
//                             END;
//                         END;

//                         IF CSIB2."Currency Code" = '' THEN BEGIN
//                             GeneralLedgerSetup.GET;
//                             IF Customer1.GET(CSIB2."Bill-to Customer No.") THEN BEGIN

//                                 IF Customer1."Currency Code" <> '' THEN BEGIN
//                                     IF Customer1."Currency Code" <> GeneralLedgerSetup."LCY Code" THEN
//                                         ERROR('Currency code on Customer Card is different , can not post');
//                                 END;
//                             END;
//                         END;

//                         //end abhishek



//                         /*
//                         //28.10.20
//                         IF lCSIB.Amount=0 THEN
//                         ERROR('Amount must not be 0');
//                         //28.10.20
//                         */

//                         lCSIB.MARK(TRUE);
//                         lCSIB.MARKEDONLY(TRUE);

//                         lFinanceMgtCSIB.CSIB_SetRunMode(0);
//                         lFinanceMgtCSIB.CSIB_SetValues_0(lCSIB);
//                         lFinanceMgtCSIB.RUN;

//                     end;
//                 }
//                 separator(separator2)
//                 {
//                 }
//                 action("Process (Pmt. Only)")
//                 {
//                     Caption = 'Process (Pmt. Only)';

//                     trigger OnAction()
//                     var
//                         lCSIB: Record 50075;
//                         lFinanceMgtCSIB: Codeunit 50007;
//                     begin
//                         CheckAmountInApplication;

//                         IF NOT CONFIRM('This option will not post Invoice or Payment Application!\ \Do you still want to Continue?', FALSE) THEN
//                             EXIT;


//                         lCSIB.SETVIEW(RecFilters);
//                         lCSIB.SETRANGE("Create Payment Journal", TRUE);
//                         IF NOT lCSIB.ISEMPTY THEN BEGIN

//                             /*
//                             //28.10.20
//                             IF lCSIB.Amount=0 THEN
//                             ERROR('Amount must not be 0');
//                             //28.10.20
//                             */

//                             lCSIB.FINDFIRST;
//                             REPEAT
//                                 lCSIB.MARK(TRUE);
//                             UNTIL lCSIB.NEXT = 0;
//                         END;

//                         lCSIB.SETRANGE("Create Payment Journal");
//                         lCSIB.SETRANGE("Payment Journal Created", TRUE);
//                         lCSIB.SETRANGE(Processed, FALSE);
//                         IF NOT lCSIB.ISEMPTY THEN BEGIN
//                             lCSIB.FINDFIRST;
//                             REPEAT
//                                 lCSIB.MARK(TRUE);
//                             UNTIL lCSIB.NEXT = 0;
//                         END;

//                         lCSIB.SETRANGE("Payment Journal Created");
//                         lCSIB.SETRANGE(Processed);

//                         lCSIB.MARKEDONLY(TRUE);

//                         lCSIB.FINDSET;
//                         lFinanceMgtCSIB.CSIB_SetRunMode(0);
//                         lFinanceMgtCSIB.EnablePaymentOnlyMode();
//                         lFinanceMgtCSIB.CSIB_SetValues_0(lCSIB);
//                         lFinanceMgtCSIB.RUN;

//                     end;
//                 }
//             }
//         }
//     }

//     trigger OnAfterGetRecord()
//     var
//         lToDO: Record "5080";
//     begin
//         SalesOrderCurrency := '';
//         CustomerCurrency := '';


//         /*IF "Warning Amounts Different" THEN
//           ColourValue := 255
//         ELSE
//           ColourValue := 0;
//         */

//         /*lToDO.SETCURRENTKEY("Contact No.","Document Type","Document No.","System To-do Type",Closed);
//         lToDO.SETRANGE("Contact No.","Sell-to Contact No.");
//         IF "Sales Invoice No." <> '' THEN  BEGIN
//           lToDO.SETRANGE("Document Type",lToDO."Document Type"::Invoice);
//           lToDO.SETRANGE("Document No.","Sales Invoice No.");
//         END ELSE BEGIN
//           lToDO.SETRANGE("Document Type",lToDO."Document Type"::Order);
//           lToDO.SETRANGE("Document No.","Sales Order No.");
//         END;
//         lToDO.SETRANGE("System To-do Type",lToDO."System To-do Type"::"Contact Attendee");
//         ToDoExists := NOT lToDO.ISEMPTY;
//         IF ToDoExists THEN BEGIN
//           lToDO.FINDFIRST;
//           ToDoSalesPerson := lToDO."Salesperson Code";
//         END ELSE
//           CLEAR(ToDoSalesPerson);
//          */


//         // "Sales Order No" :='';
//         "Cross Reference1" := '';
//         "Amount Received" := 0;
//         "Cross Reference1" := COPYSTR(rec."Cross Reference", 1, 30);
//         // MESSAGE ( "Cross Reference1");
//         // MESSAGE ("Order ID");

//         "Sales Order No" := '';
//         GlobalIrisSO.RESET;
//         GlobalIrisSO.SETFILTER("PAS Ref No.", '%1', "Cross Reference1");
//         //GlobalIrisSO.SETFILTER( GlobalIrisSO."Order ID",COPYSTR("Order ID",1,20)); //21.01.20
//         // GlobalIrisSO.SETFILTER(GlobalIrisSO."PAS Ref No.","Cross Reference1");
//         IF GlobalIrisSO.FIND('-') THEN BEGIN
//             "Sales Order No" := COPYSTR(GlobalIrisSO."SalesOrder No.", 1, 30);
//             "Amount Received" := GlobalIrisSO."Amt Received";

//             // IF "Bill-to Customer No."='' THEN BEGIN
//             /*22.01.20
//             IF "Sales Header1".GET("Sales Header1"."Document Type"::Order,GlobalIrisSO."SalesOrder No.") THEN BEGIN
//                  "Bill-to Customer No.":="Sales Header1"."Bill-to Customer No.";
//                   Rec.VALIDATE("Bill-to Customer No.","Sales Header1"."Bill-to Customer No.");
//             END;
//             22.01.20*/
//             //END;

//             SalesOrderCurrency := '';
//             CustomerCurrency := '';
//             SalesHeader1.SETFILTER(SalesHeader1."Document Type", '%1', SalesHeader1."Document Type"::Order);
//             SalesHeader1.SETFILTER(SalesHeader1."No.", "Sales Order No");
//             IF SalesHeader1.FIND('-') THEN BEGIN
//                 SalesOrderCurrency := SalesHeader1."Currency Code";

//                 IF Customer1.GET(SalesHeader1."Sell-to Customer No.") THEN
//                     CustomerCurrency := Customer1."Currency Code";


//                 IF SalesHeader1."Currency Code" = '' THEN
//                     SalesOrderCurrency := "General Ledger Setup"."LCY Code";

//                 IF Customer1."Currency Code" = '' THEN
//                     CustomerCurrency := "General Ledger Setup"."LCY Code";



//             END ELSE BEGIN
//                 SalesOrderCurrency := '';
//                 CustomerCurrency := '';
//             END;

//         END;
//         OnAfterGetCurrRecord;
//         OrderDescriptionOnFormat;
//         AmountOnFormat;
//         CardNameOnFormat;
//         AuthorisationStatusOnFormat;
//         TransMessageOnFormat;
//         TotalSalesAmountOnFormat;

//     end;

//     trigger OnInit()
//     begin
//         sfEditable := TRUE;
//         btnFunctionsMainVisible := TRUE;
//         btnFunctionsStandardVisible := TRUE;
//     end;

//     trigger OnNewRecord(BelowxRec: Boolean)
//     begin
//         OnAfterGetCurrRecord;
//     end;

//     trigger OnOpenPage()
//     begin
//         IF NOT UserSetup.GET(USERID) THEN
//             CLEAR(UserSetup);
//         IF UserSetup."Cash Mgt. User Type" = UserSetup."Cash Mgt. User Type"::Standard THEN BEGIN
//             btnFunctionsStandardVisible := TRUE;
//             btnFunctionsMainVisible := FALSE;
//             CurrPage.EDITABLE(TRUE);
//             sfEditable := TRUE;
//         END;
//         IF UserSetup."Cash Mgt. User Type" = UserSetup."Cash Mgt. User Type"::Admin THEN BEGIN
//             btnFunctionsStandardVisible := FALSE;
//             btnFunctionsMainVisible := TRUE;
//             CurrPage.EDITABLE(TRUE);
//             sfEditable := TRUE;
//         END;
//         /*
//         IF COMPANYNAME<>'TKA India' THEN BEGIN
//           CurrForm.AutoPayment.VISIBLE := FALSE;
//           CurrForm.AutoPayment1.VISIBLE := FALSE;
//         END;

//         */

//     end;

//     var
//         UserSetup: Record 91;
//         ColourValue: Integer;
//         TKATxt001: Label 'Do you want to Mark the Record a Processed?';
//         TKATxt002: Label 'Do you want to Reset the Record?\\ You will need to Rematch the Record Again';
//         ErrTxt001: Label 'Record Already Processed Cannot be Reset';
//         ToDoExists: Boolean;
//         ToDoSalesPerson: Code[10];
//         RecView1: Text[1024];
//         RecView2: Text[1024];
//         RecFilters: Text[1024];
//         SalesHeader: Record 36;
//         GlobalIrisSO: Record 50047;
//         "Sales Order No": Code[30];
//         "Cross Reference1": Code[30];
//         "Sales Header1": Record 36;
//         "Amount Received": Decimal;
//         "Sales Order PAS Auto Post": Codeunit 50048;
//         Error001: Label 'Payment Information must not be Blank\ You must select an option to be able to Post';
//         Text002: Label 'You must select an applying entry before you can post the application.';
//         Text003: Label 'You must post the application from the window where you entered the applying entry.';
//         Text004: Label 'You are not allowed to set Applies-to ID while selecting Applies-to Doc. No.';
//         Text006: Label 'You are not allowed to apply and post an entry to an entry with an earlier posting date.\\Instead, post %1 %2 and then apply it to %3 %4.';
//         SalesOrderCurrency: Code[20];
//         CustomerCurrency: Code[20];
//         SalesHeader1: Record 36;
//         Customer1: Record "18";
//         "General Ledger Setup": Record "98";
//         Company: Record 2000000006;
//         compname1: Text[30];
//         BTIB: Record 50074;
//         CSIB2: Record 50075;
//         GeneralLedgerSetup: Record "98";
//         CSIB3: Record 50075;
//         a: Integer;
//         //[InDataSet]
//         btnFunctionsStandardVisible: Boolean;
//         //[InDataSet]
//         btnFunctionsMainVisible: Boolean;
//         //[InDataSet]
//         sfEditable: Boolean;
//         //[InDataSet]
//         "Order DescriptionEmphasize": Boolean;
//         //[InDataSet]
//         "Card NameEmphasize": Boolean;
//         //[InDataSet]
//         "Authorisation StatusEmphasize": Boolean;
//         //[InDataSet]
//         "Trans. MessageEmphasize": Boolean;
//         Text19072904: Label 'Apply Filters';

//     procedure SetFilterView(pRecfilters: Text[1024])
//     begin
//         RecFilters := pRecfilters;
//     end;

//     procedure CreatePaymentEntry()
//     var
//         "CardSave Import Buffer6": Record 50075;
//         SalesInvoiceHeader: Record 112;
//         CardSaveImportBuffer3: Record 50075;
//         GlobalIRIS: Record 50047;
//         a: Integer;
//     begin
//         "CardSave Import Buffer6".SETFILTER("CardSave Import Buffer6"."Date & Time", '>%1', CREATEDATETIME(20200112D, 0T));
//         "CardSave Import Buffer6".SETFILTER("CardSave Import Buffer6"."Sales Invoice No", '%1', '');
//         "CardSave Import Buffer6".SETFILTER(AutoPASEntry, '<>%1', TRUE);
//         IF "CardSave Import Buffer6".FIND('-') THEN
//             REPEAT
//                 MESSAGE('%1', "CardSave Import Buffer6"."Cross Reference");
//                 SalesInvoiceHeader.SETFILTER(SalesInvoiceHeader."Order No.", GlobalIrisSO."SalesOrder No.");
//                 IF SalesInvoiceHeader.FIND('-') THEN BEGIN
//                     IF CardSaveImportBuffer3.GET("CardSave Import Buffer6"."Cross Reference") THEN BEGIN
//                         CardSaveImportBuffer3.AutoPASEntry := TRUE;
//                         CardSaveImportBuffer3."Sales Invoice No" := SalesInvoiceHeader."No.";
//                         CardSaveImportBuffer3.MODIFY;
//                         MESSAGE('Sales Invoice already created %1 and %2',
//                         SalesInvoiceHeader."No.", "CardSave Import Buffer6"."Cross Reference");

//                         a := a + 1;
//                         EXIT;
//                     END;
//                 END;

//                 "Cross Reference1" := '';
//                 "Cross Reference1" := COPYSTR("CardSave Import Buffer6"."Cross Reference", 1, 30);
//                 GlobalIRIS.SETFILTER(GlobalIRIS."PAS Ref No.", "Cross Reference1");
//                 GlobalIRIS.SETFILTER(GlobalIRIS."Order ID", "CardSave Import Buffer6"."Order ID");
//                 IF GlobalIRIS.FIND('-') THEN
//                     REPEAT

//                         IF "CardSave Import Buffer6".Amount = GlobalIRIS."Amt Received" THEN BEGIN
//                             IF SalesHeader.GET(SalesHeader."Document Type"::Order, GlobalIRIS."SalesOrder No.") THEN
//                                 IF SalesHeader."Booking Confirmed" THEN BEGIN
//                                     IF SalesHeader."Payment Information" = SalesHeader."Payment Information"::" " THEN
//                                         ERROR(Error001);

//                                     IF SalesHeader."Bill-to Customer No." <> "CardSave Import Buffer6"."Bill-to Customer No." THEN BEGIN
//                                         ERROR('Customer code %1  of Card Save No. %2 and Sales order  %3 is not matching ',
//                                         "CardSave Import Buffer6"."Bill-to Customer No.", "CardSave Import Buffer6"."Cross Reference",
//                                         GlobalIRIS."SalesOrder No.");
//                                     END;


//                                     CreatePaymentEntryNew("CardSave Import Buffer6");

//                                     IF CardSaveImportBuffer3.GET("Cross Reference1") THEN BEGIN
//                                         CardSaveImportBuffer3.AutoPASDateTime := CURRENTDATETIME;
//                                         CardSaveImportBuffer3.MODIFY;
//                                     END;


//                                 END;
//                         END;
//                     UNTIL GlobalIRIS.NEXT = 0;
//             UNTIL "CardSave Import Buffer6".NEXT = 0;

//         IF a = 0 THEN
//             MESSAGE('No records found');


//         IF a > 0 THEN
//             MESSAGE('Entries Created %1', a);
//     end;

//     procedure CreatePaymentEntryNew(CardSaveImportBuffer5: Record 50075)
//     var
//         SalesInvoiceHeader: Record 112;
//         GenJournalLine: Record 81;
//         lGenJnlPostLine: Codeunit 12;
//         CardSaveImportBuffer4: Record 50075;
//         GenLineDocumentNo: Code[20];
//         NoSeriesMgt: Codeunit NoSeriesManagement;
//         LineNo: Integer;
//         "CardSave Import Buffer": Record 50075;
//     begin
//         SalesInvoiceHeader.GET(CardSaveImportBuffer5."Sales Invoice No");
//         //  "CardSave Import Buffer".get(CardSaveImportBuffer5."Cross Reference");

//         CLEAR(GenJournalLine);
//         GenJournalLine.INIT;

//         GenLineDocumentNo := NoSeriesMgt.GetNextNo('GJNL-PMT', WORKDATE, FALSE);
//         GenJournalLine."Document No." := GenLineDocumentNo;

//         GenJournalLine."Journal Template Name" := 'PAYMENT';//AccountTypes."Journal Template"; //'CASHRCPT';
//         GenJournalLine."Journal Batch Name" := 'CARDSAVE';// AccountTypes."Journal Batch"; //'CARDSAVE' or 'CHECK'
//                                                           //GenJournalLine.SetUpNewLine2(GenJournalLine,0,TRUE);

//         LineNo := LineNo + 10000;

//         GenJournalLine."Line No." := LineNo;//10000;
//         GenJournalLine."Applies-to Doc. Type" := GenJournalLine."Applies-to Doc. Type"::Invoice;
//         GenJournalLine."Applies-to Doc. No." := SalesInvoiceHeader."No.";
//         //'304940';

//         GenJournalLine.VALIDATE("Account Type", GenJournalLine."Account Type"::Customer);
//         GenJournalLine.VALIDATE("Account No.", CardSaveImportBuffer5."Bill-to Customer No.");
//         GenJournalLine.VALIDATE("Posting Date", WORKDATE);//DT2DATE(CSIB."Date & Time"));
//         GenJournalLine.VALIDATE("Document Type", GenJournalLine."Document Type"::Payment);
//         GenJournalLine.Description := COPYSTR(GenJournalLine.Description, 1, 35) + ': ' +
//         CardSaveImportBuffer5."Sales Order No.";
//         GenJournalLine.VALIDATE(Amount, -CardSaveImportBuffer5.Amount);
//         GenJournalLine.VALIDATE("Shortcut Dimension 1 Code", CardSaveImportBuffer5."Shortcut Dimension 1 Code");
//         GenJournalLine.VALIDATE("Shortcut Dimension 2 Code", CardSaveImportBuffer5."Shortcut Dimension 2 Code");
//         GenJournalLine."Bal. Account Type" := GenJournalLine."Bal. Account Type"::"G/L Account";
//         GenJournalLine."Bal. Account No." := '2915';
//         GenJournalLine."PAS Ref No." := CardSaveImportBuffer5."Cross Reference";
//         GenJournalLine."Order ID" := CardSaveImportBuffer5."Order ID";

//         GenJournalLine."BATCH ID" := CardSaveImportBuffer5."BATCH ID";
//         GenJournalLine."Merchant ID" := CardSaveImportBuffer5."Merchant ID";
//         GenJournalLine.BATCHMerchantID := CardSaveImportBuffer5.BATCHMerchantID;


//         //  GenJournalLine."Allow Application" := TRUE;

//         //DSS
//         GenJournalLine."Created By" := USERID;
//         GenJournalLine."Created Date" := TODAY;
//         GenJournalLine."Created Time" := TIME;
//         GenJournalLine.AutoPASEntry := TRUE;
//         //DSS

//         GenJournalLine.INSERT;

//         CLEAR(CardSaveImportBuffer4);
//         IF CardSaveImportBuffer4.GET(CardSaveImportBuffer5."Cross Reference") THEN BEGIN
//             CardSaveImportBuffer4."Payment Entry Posted" := TRUE;
//             CardSaveImportBuffer4."Payment Document No" := GenJournalLine."Document No.";
//             CardSaveImportBuffer4.MODIFY;
//         END;

//         //lGenJnlPostLine.RUN(GenJournalLine);

//         //   PostPaymentEntry;
//         CODEUNIT.RUN(CODEUNIT::"Gen. Jnl.-Post Batch", GenJournalLine);

//         MESSAGE(SalesInvoiceHeader."No." + ' Payment doc no.  ' + GenJournalLine."Document No.");
//     end;

//     procedure UpdateInvoiceEntry()
//     var
//         "CardSave Import Buffer6": Record 50075;
//         SalesInvoiceHeader1: Record 112;
//         CardSaveImportBuffer3: Record 50075;
//     begin
//         "CardSave Import Buffer6".SETFILTER("CardSave Import Buffer6"."Date & Time", '>%1', CREATEDATETIME(20200112D, 0T));
//         "CardSave Import Buffer6".SETFILTER("CardSave Import Buffer6"."Sales Invoice No", '%1', '');
//         "CardSave Import Buffer6".SETFILTER(AutoPASEntry, '<>%1', TRUE);
//         //"CardSave Import Buffer6".SETFILTER("CardSave Import Buffer6"."Cross Reference",'15638333217872680');
//         //"CardSave Import Buffer6".SETFILTER("CardSave Import Buffer6"."Auto Sales Order Post Error",'%1','');
//         IF "CardSave Import Buffer6".FIND('-') THEN
//             REPEAT
//                 GlobalIrisSO.RESET;
//                 GlobalIrisSO.SETFILTER("PAS Ref No.", '%1', "CardSave Import Buffer6"."Cross Reference");
//                 GlobalIrisSO.SETFILTER(GlobalIrisSO."Order ID", "CardSave Import Buffer6"."Order ID");
//                 IF GlobalIrisSO.FIND('-') THEN BEGIN
//                     CLEAR(SalesInvoiceHeader1);
//                     SalesInvoiceHeader1.SETFILTER(SalesInvoiceHeader1."Order No.", GlobalIrisSO."SalesOrder No.");
//                     IF SalesInvoiceHeader1.FIND('-') THEN BEGIN
//                         IF CardSaveImportBuffer3.GET("CardSave Import Buffer6"."Cross Reference") THEN BEGIN
//                             CardSaveImportBuffer3.AutoPASEntry := TRUE;
//                             CardSaveImportBuffer3."Sales Invoice No" := SalesInvoiceHeader1."No.";
//                             CardSaveImportBuffer3.MODIFY;
//                             MESSAGE('Sales Invoice already created %1 and %2',
//                             SalesInvoiceHeader1."No.", "CardSave Import Buffer6"."Cross Reference");
//                             //EXIT;
//                         END;
//                     END;
//                 END;
//             UNTIL "CardSave Import Buffer6".NEXT = 0;
//     end;

//     procedure CheckAmountInApplication()
//     var
//         CardSaveApplications1: Record 50069;
//     begin
//         CardSaveApplications1.SETFILTER(CardSaveApplications1."Cross Reference", rec."Cross Reference");
//         IF CardSaveApplications1.FIND('-') THEN BEGIN
//             IF CardSaveApplications1."Sales Order Amount" = 0 THEN
//                 ERROR('Card Save Application Amount must not be 0');
//         END;
//     end;

//     procedure MakePaymentEntry1()
//     var
//         "CardSave Import Buffer9": Record 50075;
//         SalesInvoiceHeader1: Record 112;
//         GlobalIRIS: Record 50047;
//         a: Integer;
//         GenJournalLine: Record 81;
//         GenJournalLine1: Record 81;
//     begin
//         GenJournalLine1.SETFILTER("Journal Template Name", 'PAYMENT');//AccountTypes."Journal Template"; //'CASHRCPT';
//         GenJournalLine1.SETFILTER("Journal Batch Name", 'CARDSAVE');// AccountTypes."Journal Batch"; //'CARDSAVE' or 'CHECK'
//         IF GenJournalLine1.FINDSET THEN
//             GenJournalLine1.DELETEALL;

//         IF COMPANYNAME = 'TKA India' THEN
//             "CardSave Import Buffer9".SETFILTER("CardSave Import Buffer9".CardSaveIndia, '%1', TRUE);
//         "CardSave Import Buffer9".SETFILTER("CardSave Import Buffer9".Processed, '%1', FALSE);
//         IF "CardSave Import Buffer9".FIND('-') THEN
//             REPEAT
//                 GlobalIRIS.SetRange("PAS Ref No.", "CardSave Import Buffer9"."Cross Reference");
//                 if GlobalIRIS.FindFirst() then begin
//                     SalesInvoiceHeader1.SETFILTER("Order No.", GlobalIRIS."SalesOrder No.");
//                     IF SalesInvoiceHeader1.FIND('-') THEN BEGIN

//                         IF "CardSave Import Buffer9"."Sales Invoice No" = '' THEN
//                             ERROR('Sales Invoice No. should not be blank for the PAS Ref No. %1', "CardSave Import Buffer9"."Cross Reference");

//                         "Sales Order PAS Auto Post".CreatePaymentEntryINDIA("CardSave Import Buffer9"."Cross Reference");
//                     END;
//                 end
//             UNTIL "CardSave Import Buffer9".NEXT = 0;


//         CLEAR(GenJournalLine);


//         GenJournalLine.SETFILTER("Journal Template Name", 'PAYMENT');//AccountTypes."Journal Template"; //'CASHRCPT';
//         GenJournalLine.SETFILTER("Journal Batch Name", 'CARDSAVE');// AccountTypes."Journal Batch"; //'CARDSAVE' or 'CHECK'
//         IF GenJournalLine.FIND('-') THEN;
//         CODEUNIT.RUN(CODEUNIT::"Gen. Jnl.-Post Batch", GenJournalLine); // NB 030724

//         //  COMMIT;
//     end;

//     procedure UpdatIndiaInfo1()
//     var
//         "CardSave Import Buffer9": Record 50075;
//         SalesInvoiceHeader1: Record 112;
//         GlobalIRIS: Record 50047;
//         a: Integer;
//     begin
//         IF COMPANYNAME = 'TKA India' THEN
//             "CardSave Import Buffer9".SETFILTER("CardSave Import Buffer9".CardSaveIndia, '%1', TRUE);
//         "CardSave Import Buffer9".SETFILTER("CardSave Import Buffer9".Processed, '%1', FALSE);
//         IF "CardSave Import Buffer9".FIND('-') THEN
//             REPEAT
//                 GlobalIRIS.SetRange("PAS Ref No.", "CardSave Import Buffer9"."Cross Reference");
//                 if GlobalIRIS.FindFirst() then begin
//                     SalesInvoiceHeader1.SETFILTER("Order No.", GlobalIRIS."SalesOrder No.");
//                     IF SalesInvoiceHeader1.FIND('-') THEN BEGIN

//                         // "CardSave Import Buffer9"."Bill-to Customer No." := SalesInvoiceHeader1."Sell-to Customer No.";
//                         //"CardSave Import Buffer9"."Currency Code" := SalesInvoiceHeader1."Currency Code";
//                         //"CardSave Import Buffer9"."Shortcut Dimension 1 Code" := SalesInvoiceHeader1."Shortcut Dimension 1 Code";
//                         // "CardSave Import Buffer9"."Shortcut Dimension 2 Code" := SalesInvoiceHeader1."Shortcut Dimension 2 Code";
//                         //"CardSave Import Buffer9"."sales Order" :=SalesInvoiceHeader1."Order No.";
//                         //"CardSave Import Buffer9"."Sales Invoice No" :=    SalesInvoiceHeader1."No.";
//                         //"CardSave Import Buffer9"."Currency Code" :=SalesInvoiceHeader1."Currency Code";


//                         "CardSave Import Buffer9"."Bill-to Customer No." := SalesInvoiceHeader1."Bill-to Customer No.";
//                         "CardSave Import Buffer9"."Sales Order No." := SalesInvoiceHeader1."Order No.";
//                         "CardSave Import Buffer9"."Sales Invoice No." := SalesInvoiceHeader1."No.";
//                         "CardSave Import Buffer9"."Sales Invoice No" := SalesInvoiceHeader1."No.";

//                         "CardSave Import Buffer9"."Sell-to Contact No." := SalesInvoiceHeader1."Sell-to Contact No.";
//                         "CardSave Import Buffer9"."Shortcut Dimension 1 Code" := SalesInvoiceHeader1."Shortcut Dimension 1 Code";
//                         "CardSave Import Buffer9"."Shortcut Dimension 2 Code" := SalesInvoiceHeader1."Shortcut Dimension 2 Code";
//                         "CardSave Import Buffer9"."Sales Order Posting Date" := SalesInvoiceHeader1."Posting Date";
//                         "CardSave Import Buffer9"."Sales Order Course Date" := SalesInvoiceHeader1."Shipment Date";
//                         "CardSave Import Buffer9"."Sales Order Amount" := SalesInvoiceHeader1."Amount Including VAT";
//                         "CardSave Import Buffer9"."Sales Quote No." := SalesInvoiceHeader1."Quote No.";
//                         "CardSave Import Buffer9"."Sell-to Customer Name" := SalesInvoiceHeader1."Sell-to Customer Name";
//                         "CardSave Import Buffer9"."Bill-to Name" := SalesInvoiceHeader1."Bill-to Name";
//                         "CardSave Import Buffer9"."Salesperson Code" := SalesInvoiceHeader1."Salesperson Code";

//                         "CardSave Import Buffer9".MODIFY;

//                         //"Sales Order PAS Auto Post".CreatePaymentEntryINDIA("CardSave Import Buffer9"."Cross Reference");
//                     END;
//                 end;
//             UNTIL "CardSave Import Buffer9".NEXT = 0;
//     end;

//     procedure Compname()
//     begin
//         IF Company.Name = 'The Knowledge Academy Limited' THEN
//             compname1 := 'TKA UK';


//         IF Company.Name = 'Best Practice Training Ltd.' THEN
//             compname1 := 'Best Prac';

//         IF Company.Name = 'Datrix Learning Services Ltd.' THEN
//             compname1 := 'Datrix';

//         IF Company.Name = 'ITIL Training Academy' THEN
//             compname1 := 'ITIL';

//         IF Company.Name = 'Pearce Mayfield Train Dubai' THEN
//             compname1 := 'PMD';

//         IF Company.Name = 'Pearce Mayfield Training Ltd' THEN
//             compname1 := 'PMT';

//         IF Company.Name = 'Pentagon Leisure Services Ltd' THEN
//             compname1 := 'Pentagon';

//         IF Company.Name = 'Silicon Beach Training' THEN
//             compname1 := 'Silicon';

//         IF Company.Name = 'The Knowledge Academy FreeZone' THEN
//             compname1 := 'FREEZONE';

//         IF Company.Name = 'The Knowledge Academy Inc' THEN
//             compname1 := 'USA';

//         IF Company.Name = 'The Knowledge Academy Pty Ltd.' THEN
//             compname1 := 'AUS';

//         IF Company.Name = 'The Knowledge Academy SA' THEN
//             compname1 := 'SA';

//         IF Company.Name = 'TKA Apprenticeship' THEN
//             compname1 := 'Apprenticeship';

//         IF Company.Name = 'TKA Canada Corporation' THEN
//             compname1 := 'Canada';

//         IF Company.Name = 'TKA Europe' THEN
//             compname1 := 'Europe';

//         IF Company.Name = 'TKA India' THEN
//             compname1 := 'TKA India';


//         IF Company.Name = 'TKA Hong Kong Ltd.' THEN
//             compname1 := 'HK';

//         IF Company.Name = 'TKA New Zealand Ltd.' THEN
//             compname1 := 'NZ';

//         IF Company.Name = 'TKA Singapore PTE Ltd.' THEN
//             compname1 := 'Singapore';
//     end;

//     procedure ExportToMail()
//     var
//         CSIB: Record 50075;
//         email: codeunit email;
//         emailmsg: codeunit "Email Message";
//         tempamt: Decimal;
//         tempdate: Text[30];
//         ert: enum "Email Recipient Type";
//     begin
//         CLEAR(emailmsg);
//         emailmsg.Create('triza.behal@theknowledgeacademy.com', 'Pending All Transaction', '', TRUE);

//         emailmsg.AddRecipient(ert::Cc, 'Juhi.Sharma@theknowledgeacademy.com');
//         emailmsg.AddRecipient(ert::Cc, 'martha.folkes@theknowledgeacademy.com');
//         emailmsg.AddRecipient(ert::Cc, 'simrandeep.kaur@theknowledgeacademy.com');
//         emailmsg.AppendToBody('Hi,');
//         emailmsg.AppendToBody('<BR><BR>');
//         emailmsg.AppendToBody('Not Processed WEBSales/TeleSales Transaction');
//         emailmsg.AppendToBody('<BR>');

//         emailmsg.AppendToBody('<table cellspacing="10"  style="border-spacing: 0px;" border="1">' +
//         '<col width="150"><col width="200"><col width="450"><col width="150"><col width="150"><col width="150"><col width="450">' +
//          '<tr><th align="Center">Company Name</th>' +
//          '<th align="Center">Date</th>' +
//          '<th align="Center">PAS Ref.</th>' +
//          '<th align="Center">Payment</th>' +
//           '<th align="Center">Amount Received</th>' +
//           '<th align="Center">Transaction Type</th>' +
//          '<th align="Center">Comment</th>');


//         Company.SETFILTER(Company.Name, '<>%1', '');
//         IF Company.FINDSET THEN
//             REPEAT
//                 Compname();
//                 CSIB.CHANGECOMPANY(Company.Name);
//                 GlobalIrisSO.CHANGECOMPANY(Company.Name);

//                 CSIB.SETFILTER(CSIB.Processed, 'No');
//                 CSIB.SETFILTER(CSIB."Cross Reference", '<>%1&<>%2', 'UNKNOWN', '20191010153727');
//                 IF CSIB.FINDSET THEN
//                     REPEAT
//                         tempamt := 0;
//                         CLEAR(tempdate);
//                         tempdate := COPYSTR(FORMAT(CSIB."Date & Time"), 1, 8);
//                         GlobalIrisSO.RESET;
//                         GlobalIrisSO.SETFILTER("PAS Ref No.", '%1', CSIB."Cross Reference");
//                         IF GlobalIrisSO.FIND('-') THEN
//                             tempamt := GlobalIrisSO."Amt Received";
//                         IF tempdate <> '' THEN BEGIN

//                             emailmsg.AppendToBody('<tr>');
//                             emailmsg.AppendToBody('<td align="Center">' + compname1 + '</td>');
//                             emailmsg.AppendToBody('<td align="Center">' + tempdate + '</td>');
//                             emailmsg.AppendToBody('<td align="Center">' + CSIB."Cross Reference" + '</td>');
//                             emailmsg.AppendToBody('<td align="Center">' + FORMAT(CSIB.Amount) + '</td>');
//                             emailmsg.AppendToBody('<td align="Center">' + FORMAT(tempamt) + '</td>');
//                             emailmsg.AppendToBody('<td align="Center">' + CSIB."Transaction Type" + '</td>');
//                             emailmsg.AppendToBody('<td align="Center">' + CSIB.Comments + '</td>');
//                             emailmsg.AppendToBody('</tr>');
//                         END;

//                     UNTIL CSIB.NEXT = 0;
//             UNTIL Company.NEXT = 0;
//         emailmsg.AppendToBody('</table>');
//         emailmsg.AppendToBody('<BR><BR>');
//         emailmsg.AppendToBody('Not Processed BACS Paid-In/Paid-Out Transaction');
//         emailmsg.AppendToBody('<BR>');

//         emailmsg.AppendToBody('<table cellspacing="10"  style="border-spacing: 0px;" border="1">' +
//         '<col width="150"><col width="200"><col width="450"><col width="150"><col width="150">' +
//          '<tr><th align="Center">Company Name</th>' +
//          '<th align="Center">Date</th>' +
//          '<th align="Center">Information</th>' +
//           '<th align="Center">Amount </th>' +
//           '<th align="Center">Transaction Type</th>'
//          );


//         Company.SETFILTER(Company.Name, '<>%1', '');
//         IF Company.FINDSET THEN
//             REPEAT
//                 Compname();
//                 BTIB.CHANGECOMPANY(Company.Name);
//                 BTIB.SETFILTER(BTIB.Processed, 'No');
//                 BTIB.SETFILTER(BTIB."Entry No.", '<>%1', 0);
//                 IF BTIB.FINDSET THEN
//                     REPEAT

//                         emailmsg.AppendToBody('<tr>');
//                         emailmsg.AppendToBody('<td align="Center">' + compname1 + '</td>');
//                         emailmsg.AppendToBody('<td align="Center">' + FORMAT(BTIB.Date) + '</td>');
//                         emailmsg.AppendToBody('<td align="Center">' + BTIB.Information + '</td>');
//                         emailmsg.AppendToBody('<td align="Center">' + FORMAT(BTIB.Amount) + '</td>');
//                         emailmsg.AppendToBody('<td align="Center">' + FORMAT(BTIB."Transaction Type") + '</td>');


//                     UNTIL BTIB.NEXT = 0;
//             UNTIL Company.NEXT = 0;
//         emailmsg.AppendToBody('</table>');

//         email.send(emailmsg);
//     end;

//     local procedure OnAfterGetCurrRecord()
//     var
//         lToDO: Record "5080";
//     begin
//         xRec := Rec;
//         IF rec."Warning Amounts Different" THEN
//             ColourValue := 255
//         ELSE
//             ColourValue := 0;

//         lToDO.SETCURRENTKEY("Contact No.", "Document Type", "Document No.", "System To-do Type", Closed);
//         lToDO.SETRANGE("Contact No.", rec."Sell-to Contact No.");
//         IF rec."Sales Invoice No." <> '' THEN BEGIN
//             lToDO.SETRANGE("Document Type", lToDO."Document Type"::Invoice);
//             lToDO.SETRANGE("Document No.", rec."Sales Invoice No.");
//         END ELSE BEGIN
//             lToDO.SETRANGE("Document Type", lToDO."Document Type"::Order);
//             lToDO.SETRANGE("Document No.", rec."Sales Order No.");
//         END;
//         lToDO.SETRANGE("System To-do Type", lToDO."System To-do Type"::"Contact Attendee");
//         ToDoExists := NOT lToDO.ISEMPTY;
//         IF ToDoExists THEN BEGIN
//             lToDO.FINDFIRST;
//             ToDoSalesPerson := lToDO."Salesperson Code";
//         END ELSE
//             CLEAR(ToDoSalesPerson);
//     end;

//     local procedure OrderDescriptionOnFormat()
//     begin
//         IF rec."Override Used" THEN BEGIN
//             "Order DescriptionEmphasize" := TRUE;
//         END ELSE BEGIN
//             "Order DescriptionEmphasize" := FALSE;
//         END;
//     end;

//     local procedure AmountOnFormat()
//     begin
//         IF rec."Warning Amounts Different" THEN;
//     end;

//     local procedure CardNameOnFormat()
//     begin
//         IF rec."Override Used" THEN BEGIN
//             "Card NameEmphasize" := TRUE;
//         END ELSE BEGIN
//             "Card NameEmphasize" := FALSE;
//         END;
//     end;

//     local procedure AuthorisationStatusOnFormat()
//     begin
//         IF rec."Override Used" THEN BEGIN
//             "Authorisation StatusEmphasize" := TRUE;
//         END ELSE BEGIN
//             "Authorisation StatusEmphasize" := FALSE;
//         END;
//     end;

//     local procedure TransMessageOnFormat()
//     begin
//         IF rec."Override Used" THEN BEGIN
//             "Trans. MessageEmphasize" := TRUE;
//         END ELSE BEGIN
//             "Trans. MessageEmphasize" := FALSE;
//         END;
//     end;

//     local procedure TotalSalesAmountOnFormat()
//     begin
//         IF rec."Warning Amounts Different" THEN;
//     end;
// }

