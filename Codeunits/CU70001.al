codeunit 70000 MyCodeunit
{
    // [EventSubscriber(ObjectType::Table, Database::"Job Queue Entry", OnBeforeIsReadyToStart, '', false, false)]
    // local procedure "Job Queue Entry_OnBeforeIsReadyToStart"(var JobQueueEntry: Record "Job Queue Entry"; var ReadyToStart: Boolean; var IsHandled: Boolean)
    // begin
    //     ReadyToStart := (JobQueueEntry.Status in [JobQueueEntry.Status::Error, JobQueueEntry.Status::Ready, JobQueueEntry.Status::Waiting, JobQueueEntry.Status::"In Process", JobQueueEntry.Status::"On Hold with Inactivity Timeout"]);
    //     Ishandled := true;
    // end;

    [EventSubscriber(ObjectType::Table, Database::Contact, OnBeforeCheckIfTypeChangePossibleForPerson, '', false, false)]
    local procedure Contact_OnBeforeCheckIfTypeChangePossibleForPerson(var Contact: Record Contact; xContact: Record Contact; var IsHandled: Boolean)
    begin
        if UpperCase(UserId()) in ['WEB SERVICE'] then begin
            IsHandled := true;
        end
    end;

    [EventSubscriber(ObjectType::Table, Database::"Transformation Rule", OnTransformation, '', false, false)]
    local procedure "Transformation Rule_OnTransformation"(TransformationCode: Code[20]; InputText: Text; var OutputText: Text)
    var
        varDecimal: Decimal;
    begin
        if TransformationCode = 'MULTIPLYBY100' then begin
            if Evaluate(varDecimal, InputText) then
                OutputText := Format(varDecimal * 100);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CustEntry-Apply Posted Entries", OnCustPostApplyCustLedgEntryOnBeforeCommit, '', false, false)]
    local procedure "CustEntry-Apply Posted Entries_OnCustPostApplyCustLedgEntryOnBeforeCommit"(var CustLedgerEntry: Record "Cust. Ledger Entry"; var SuppressCommit: Boolean)
    var
        salesInvoiceHeader: record "Sales Invoice Header";
        customerLedgEntry: Record "Cust. Ledger Entry";
        DtldCustLedgerEntry: record "Detailed Cust. Ledg. Entry";
    begin
        CustLedgerEntry.CalcFields("Remaining Amount");
        Message('%1', CustLedgerEntry."Remaining Amount");
        customerLedgEntry.SetFilter("Entry No.", '%1 | %2', 6379767, 6386996);
        // customerLedgEntry.SetFilter("Customer No.", '%1', CustLedgerEntry."Customer No.");
        // // customerLedgEntry.SetFilter("open", '%1', true);
        // customerLedgEntry.SetFilter("Applies-to ID", '%1', CustLedgerEntry."Applies-to ID");

        // if customerLedgEntry.FindFirst() then
        //     repeat
        //         Message('%1', customerLedgEntry."Entry No.");
        //     until customerLedgEntry.Next() = 0;




        // error('Hi'); //6159986
        //6379767, 6386996
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CustEntry-Apply Posted Entries", OnApplyOnBeforeCustPostApplyCustLedgEntry, '', false, false)]
    local procedure "CustEntry-Apply Posted Entries_OnApplyOnBeforeCustPostApplyCustLedgEntry"(CustLedgerEntry: Record "Cust. Ledger Entry"; var ApplyUnapplyParameters: Record "Apply Unapply Parameters" temporary)
    var
        CustomerLedg: record "Cust. Ledger Entry";
    begin
        CustomerLedg.SetFilter("Customer No.", CustomerLedg."Customer No.");
        CustomerLedg.SetFilter(Open, '%1', true);
        CustomerLedg.SetFilter("Applies-to ID", CustLedgerEntry."Applies-to ID");
        if CustomerLedg.FindFirst() then
            repeat
                Message('%1', CustomerLedg."Entry No.");
            until CustomerLedg.Next() = 0;

    end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Global Triggers", GetDatabaseTableTriggerSetup, '', false, false)]
    // local procedure "Global Triggers_GetDatabaseTableTriggerSetup"(TableId: Integer; var OnDatabaseInsert: Boolean; var OnDatabaseModify: Boolean; var OnDatabaseDelete: Boolean; var OnDatabaseRename: Boolean)
    // begin
    //     case TableId of
    //         database::"Cust. Ledger Entry":
    //             begin
    //                 OnDatabaseModify := true;
    //             end;
    //     end;
    // end;




    // [EventSubscriber(ObjectType::Codeunit, Codeunit::GlobalTriggerManagement, OnAfterOnDatabaseModify, '', false, false)]
    // local procedure GlobalTriggerManagement_OnAfterOnDatabaseModify(RecRef: RecordRef)
    // var
    //     custLedgEntry: Record "Cust. Ledger Entry";
    // begin
    //     case RecRef.Number of
    //         database::"Cust. Ledger Entry":
    //             begin
    //                 RecRef.SetTable(custLedgEntry);
    //                 custLedgEntry.CalcFields("Remaining Amount");
    //                 if (custLedgEntry.Open = false) AND (custLedgEntry."Remaining Amount" = 0)
    //                 AND (custLedgEntry."Document Type" = custLedgEntry."Document Type"::Invoice)
    //                 AND (custLedgEntry."Source Code" = 'SALES') then begin

    //                 end;

    //             end;
    //     //6159986
    //     //6379767, 6386996
    //     end;
    // end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", OnAfterInsertDtldCustLedgEntry, '', false, false)]
    local procedure "Gen. Jnl.-Post Line_OnAfterInsertDtldCustLedgEntry"(var DtldCustLedgEntry: Record "Detailed Cust. Ledg. Entry"; GenJournalLine: Record "Gen. Journal Line"; DtldCVLedgEntryBuffer: Record "Detailed CV Ledg. Entry Buffer"; Offset: Integer)
    begin
        Message('%1', DtldCustLedgEntry."Cust. Ledger Entry No.");
    end;




    // procedure UpdateStatus1()
    // begin


    //     PaymentStatus2 := '';
    //     PreviousDocNo := SalesInvoiceHeader3."No.";
    //     CreditMemoNo := '';
    //     SalesDocument1 := '';
    //     //  MESSAGE (SalesInvoiceHeader3."No.");
    //     CLEAR(DetailedCustLedgEntry);
    //     CLEAR(SalesInvoiceLine);
    //     CLEAR(AppliedCLE);
    //     CLEAR(CustLedgerEntry);
    //     CLEAR(SalesInvoiceHeader2);


    //     //Checking Original Knowledge Pass Invoice Payment Status Start
    //     IF SalesInvoiceHeader2.GET(SalesInvoiceHeader3."No.") THEN BEGIN
    //         IF SalesInvoiceHeader2."Payment Information" = SalesInvoiceHeader2."Payment Information"::"Knowledge / Flexi Pass" THEN BEGIN
    //             SalesInvoiceLine.SETFILTER("Document No.", SalesInvoiceHeader2."No.");
    //             SalesInvoiceLine.SETFILTER(SalesInvoiceLine."KP No.", '<>%1', '');
    //             IF SalesInvoiceLine.FIND('-') THEN
    //                 SalesDocument1 := SalesInvoiceLine."KP No.";
    //         END;
    //     END;
    //     //Checking Original Knowledge Pass Invoice Payment Status End
    //     IF SalesDocument1 = '' THEN
    //         SalesDocument1 := SalesInvoiceHeader3."No.";
    //     CLEAR(AppliedCLE);
    //     //new code
    //     CLEAR(CustLedgerEntry);
    //     CustLedgerEntry.SETCURRENTKEY("Document No.", "Document Type", "Customer No.");
    //     CustLedgerEntry.SETFILTER("Document No.", SalesDocument1);
    //     CustLedgerEntry.SETFILTER(CustLedgerEntry."Document Type", '%1', CustLedgerEntry."Document Type"::Invoice);
    //     IF CustLedgerEntry.FIND('-') THEN BEGIN
    //         CustLedgerEntry.CALCFIELDS(CustLedgerEntry."Remaining Amount");
    //         IF CustLedgerEntry."Remaining Amount" = 0 THEN BEGIN
    //             IF CustLedgerEntry."Closed by Entry No." <> 0 THEN BEGIN
    //                 AppliedCLE.SETFILTER("Entry No.", '%1', CustLedgerEntry."Closed by Entry No.");
    //                 IF AppliedCLE.FIND('-') THEN BEGIN
    //                     IF AppliedCLE."Document Type" = AppliedCLE."Document Type"::"Credit Memo" THEN
    //                         PaymentStatus2 := 'CREDITED';
    //                     CreditMemoNo := AppliedCLE."Document No.";

    //                     IF AppliedCLE."Document Type" = AppliedCLE."Document Type"::Payment THEN
    //                         PaymentStatus2 := 'PAID';
    //                     CreditMemoNo := AppliedCLE."Document No.";

    //                     IF AppliedCLE."Document Type" = AppliedCLE."Document Type"::" " THEN
    //                         PaymentStatus2 := 'PAID';
    //                     CreditMemoNo := AppliedCLE."Document No.";
    //                     EXIT;
    //                 END;
    //             END;

    //             IF CustLedgerEntry."Closed by Entry No." = 0 THEN BEGIN
    //                 AppliedCLE.SETFILTER("Closed by Entry No.", '%1', CustLedgerEntry."Entry No.");
    //                 IF AppliedCLE.FIND('-') THEN BEGIN
    //                     IF AppliedCLE."Document Type" = AppliedCLE."Document Type"::"Credit Memo" THEN
    //                         PaymentStatus2 := 'CREDITED';
    //                     CreditMemoNo := AppliedCLE."Document No.";

    //                     IF AppliedCLE."Document Type" = AppliedCLE."Document Type"::Payment THEN
    //                         PaymentStatus2 := 'PAID';
    //                     CreditMemoNo := AppliedCLE."Document No.";

    //                     IF AppliedCLE."Document Type" = AppliedCLE."Document Type"::" " THEN
    //                         PaymentStatus2 := 'PAID';
    //                     CreditMemoNo := AppliedCLE."Document No.";
    //                     //MESSAGE ('Coming in loop closed by entry no 0');
    //                     EXIT;
    //                 END;
    //             END;


    //         END;
    //     END;
    //     CLEAR(CustLedgerEntry);

    //     //new code

    //     CustLedgerEntry.SETCURRENTKEY("Document No.", "Document Type", "Customer No.");
    //     CustLedgerEntry.SETFILTER("Document No.", SalesDocument1);
    //     CustLedgerEntry.SETFILTER(CustLedgerEntry."Document Type", '%1', CustLedgerEntry."Document Type"::Invoice);
    //     IF CustLedgerEntry.FIND('-') THEN BEGIN
    //         CustLedgerEntry.CALCFIELDS(CustLedgerEntry."Remaining Amount");
    //         IF CustLedgerEntry."Remaining Amount" <> 0 THEN BEGIN
    //             PaymentStatus2 := 'UNPAID';
    //             CreditMemoNo := '';//DetailedCustLedgEntry."Document No.";
    //         END;


    //         IF CustLedgerEntry."Remaining Amount" = 0 THEN BEGIN
    //             DetailedCustLedgEntry.RESET;
    //             DetailedCustLedgEntry.SETCURRENTKEY("Cust. Ledger Entry No.", "Entry Type", "Posting Date");
    //             DetailedCustLedgEntry.SETFILTER("Cust. Ledger Entry No.", '%1', CustLedgerEntry."Entry No.");
    //             DetailedCustLedgEntry.SETFILTER(DetailedCustLedgEntry."Entry Type", '%1', DetailedCustLedgEntry."Entry Type"::Application);
    //             DetailedCustLedgEntry.SETFILTER(DetailedCustLedgEntry."Document Type",
    //                                            '%1', DetailedCustLedgEntry."Document Type"::Payment);
    //             IF DetailedCustLedgEntry.FIND('-') THEN BEGIN
    //                 PaymentStatus2 := 'PAID';
    //                 CreditMemoNo := DetailedCustLedgEntry."Document No.";
    //                 EXIT; //24.03.21
    //             END;
    //         END;


    //         IF CustLedgerEntry."Remaining Amount" = 0 THEN BEGIN
    //             DetailedCustLedgEntry.RESET;
    //             DetailedCustLedgEntry.SETCURRENTKEY("Cust. Ledger Entry No.", "Entry Type", "Posting Date");
    //             DetailedCustLedgEntry.SETFILTER("Cust. Ledger Entry No.", '%1', CustLedgerEntry."Entry No.");
    //             DetailedCustLedgEntry.SETFILTER(DetailedCustLedgEntry."Entry Type", '%1', DetailedCustLedgEntry."Entry Type"::Application);
    //             DetailedCustLedgEntry.SETFILTER(DetailedCustLedgEntry."Document Type",
    //                                            '%1', DetailedCustLedgEntry."Document Type"::"Credit Memo");
    //             IF DetailedCustLedgEntry.FIND('-') THEN BEGIN
    //                 PaymentStatus2 := 'CREDITED';
    //                 CreditMemoNo := DetailedCustLedgEntry."Document No.";
    //             END;
    //             //EXIT;
    //         END;


    //         IF CustLedgerEntry."Remaining Amount" = 0 THEN BEGIN
    //             DetailedCustLedgEntry.RESET;
    //             DetailedCustLedgEntry.SETCURRENTKEY("Cust. Ledger Entry No.", "Entry Type", "Posting Date");
    //             DetailedCustLedgEntry.SETFILTER("Cust. Ledger Entry No.", '%1', CustLedgerEntry."Entry No.");
    //             DetailedCustLedgEntry.SETFILTER("Entry Type", '%1', DetailedCustLedgEntry."Entry Type"::Application);
    //             IF DetailedCustLedgEntry.FIND('-') THEN
    //                 REPEAT
    //                     IF DetailedCustLedgEntry."Document Type" = DetailedCustLedgEntry."Document Type"::Payment THEN BEGIN
    //                         PaymentStatus2 := 'PAID';
    //                         CreditMemoNo := DetailedCustLedgEntry."Document No.";
    //                     END;
    //                 UNTIL DetailedCustLedgEntry.NEXT = 0;
    //         END;


    //         IF CustLedgerEntry."Remaining Amount" = 0 THEN BEGIN
    //             DetailedCustLedgEntry.RESET;
    //             DetailedCustLedgEntry.SETCURRENTKEY("Cust. Ledger Entry No.", "Entry Type", "Posting Date");
    //             DetailedCustLedgEntry.SETFILTER(DetailedCustLedgEntry."Cust. Ledger Entry No.", '%1', CustLedgerEntry."Entry No.");
    //             DetailedCustLedgEntry.SETFILTER(DetailedCustLedgEntry."Entry Type", '%1', DetailedCustLedgEntry."Entry Type"::Application);
    //             IF DetailedCustLedgEntry.FIND('-') THEN
    //                 REPEAT
    //                     //MESSAGE ( FORMAT(DetailedCustLedgEntry."Entry Type"));
    //                     PaymentStatus2 := 'PAID';
    //                     CreditMemoNo := DetailedCustLedgEntry."Document No.";

    //                     IF DetailedCustLedgEntry."Document Type" = DetailedCustLedgEntry."Document Type"::"Credit Memo" THEN BEGIN
    //                         PaymentStatus2 := 'CREDITED';
    //                         CreditMemoNo := DetailedCustLedgEntry."Document No.";
    //                     END;
    //                     EXIT;
    //                 UNTIL DetailedCustLedgEntry.NEXT = 0;
    //         END;

    //         IF CustLedgerEntry."Remaining Amount" = 0 THEN BEGIN
    //             Cnt := 0;
    //             DetailedCustLedgEntry.RESET;
    //             DetailedCustLedgEntry.SETCURRENTKEY("Cust. Ledger Entry No.", "Entry Type", "Posting Date");
    //             DetailedCustLedgEntry.SETFILTER(DetailedCustLedgEntry."Cust. Ledger Entry No.", '%1', CustLedgerEntry."Entry No.");
    //             IF DetailedCustLedgEntry.FIND('-') THEN
    //                 REPEAT
    //                     IF DetailedCustLedgEntry."Entry Type" = DetailedCustLedgEntry."Entry Type"::"Initial Entry" THEN
    //                         Cnt := 0;

    //                     IF DetailedCustLedgEntry."Entry Type" = DetailedCustLedgEntry."Entry Type"::Application THEN
    //                         Cnt := Cnt + 1;

    //                 UNTIL DetailedCustLedgEntry.NEXT = 0;
    //             IF Cnt > 0 THEN BEGIN
    //                 PaymentStatus2 := 'PAID';
    //                 CreditMemoNo := DetailedCustLedgEntry."Document No.";
    //             END;

    //             IF Cnt = 0 THEN BEGIN
    //                 PaymentStatus2 := 'UNPAID';
    //                 CreditMemoNo := '';//DetailedCustLedgEntry."Document No.";
    //             END;
    //         END;
    //     END;
    //     //END;
    // end;


    var
        cle: page "Customer Ledger Entries";
}