codeunit 70000 MyCodeunit
{
    Permissions = tabledata "Sales Invoice Header" = rim;


    //For APIs
    [EventSubscriber(ObjectType::Table, Database::Contact, OnBeforeCheckIfTypeChangePossibleForPerson, '', false, false)]
    local procedure Contact_OnBeforeCheckIfTypeChangePossibleForPerson(var Contact: Record Contact; xContact: Record Contact; var IsHandled: Boolean)
    begin
        if UpperCase(UserId()) in ['WEB SERVICE'] then begin
            IsHandled := true;
        end
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", OnBeforeCheckShipmentDateBeforeWorkDate, '', false, false)]
    local procedure "Sales Line_OnBeforeCheckShipmentDateBeforeWorkDate"(var Sender: Record "Sales Line"; var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line"; var HasBeenShown: Boolean; var IsHandled: Boolean)
    begin
        if not GuiAllowed then ishandled := true;
    end;

    //FOR APIs
    [EventSubscriber(ObjectType::Table, Database::"Transformation Rule", OnTransformation, '', false, false)]
    local procedure "Transformation Rule_OnTransformation"(TransformationCode: Code[20]; InputText: Text; var OutputText: Text)
    var
        varDecimal: Decimal;
    begin
        if TransformationCode = 'MULTIPLYBY100' then begin
            if Evaluate(varDecimal, InputText) then OutputText := Format(varDecimal * 100);
        end;
    end;

    // Payment Status Code
    procedure GetAppliedentries(var recCustLedg: record "Cust. Ledger Entry")
    var
        CreateCustLedgEntry: Record "Cust. Ledger Entry";
    begin
        recCustLedg.Reset();
        if recCustLedg."Entry No." <> 0 then begin
            CreateCustLedgEntry := recCustLedg;
            FindApplnEntriesDtldtLedgEntry(recCustLedg, CreateCustLedgEntry);
            recCustLedg.SetCurrentKey("Entry No.");
            recCustLedg.SetRange("Entry No.");
            if CreateCustLedgEntry."Closed by Entry No." <> 0 then begin
                recCustLedg."Entry No." := CreateCustLedgEntry."Closed by Entry No.";
                recCustLedg.Mark(true);
            end;
            recCustLedg.SetCurrentKey("Closed by Entry No.");
            recCustLedg.SetRange("Closed by Entry No.", CreateCustLedgEntry."Entry No.");
            if recCustLedg.Find('-') then
                repeat
                    recCustLedg.Mark(true);
                until recCustLedg.Next() = 0;
            recCustLedg.SetCurrentKey("Entry No.");
            recCustLedg.SetRange("Closed by Entry No.");
        end;
        recCustLedg.MarkedOnly(true);
    end;

    local procedure FindApplnEntriesDtldtLedgEntry(var recCustLedg: Record "Cust. Ledger Entry"; var CreateCustLedgEntry: Record "Cust. Ledger Entry")
    var
        DtldCustLedgEntry1: Record "Detailed Cust. Ledg. Entry";
        DtldCustLedgEntry2: Record "Detailed Cust. Ledg. Entry";
    begin
        DtldCustLedgEntry1.SetCurrentKey("Cust. Ledger Entry No.");
        DtldCustLedgEntry1.SetRange("Cust. Ledger Entry No.", CreateCustLedgEntry."Entry No.");
        DtldCustLedgEntry1.SetRange(Unapplied, false);
        if DtldCustLedgEntry1.Find('-') then
            repeat
                if DtldCustLedgEntry1."Cust. Ledger Entry No." = DtldCustLedgEntry1."Applied Cust. Ledger Entry No." then begin
                    DtldCustLedgEntry2.Init();
                    DtldCustLedgEntry2.SetCurrentKey("Applied Cust. Ledger Entry No.", "Entry Type");
                    DtldCustLedgEntry2.SetRange("Applied Cust. Ledger Entry No.", DtldCustLedgEntry1."Applied Cust. Ledger Entry No.");
                    DtldCustLedgEntry2.SetRange("Entry Type", DtldCustLedgEntry2."Entry Type"::Application);
                    DtldCustLedgEntry2.SetRange(Unapplied, false);
                    if DtldCustLedgEntry2.Find('-') then
                        repeat
                            if DtldCustLedgEntry2."Cust. Ledger Entry No." <> DtldCustLedgEntry2."Applied Cust. Ledger Entry No." then begin
                                recCustLedg.SetCurrentKey("Entry No.");
                                recCustLedg.SetRange("Entry No.", DtldCustLedgEntry2."Cust. Ledger Entry No.");
                                if recCustLedg.Find('-') AND (recCustLedg."Entry No." <> 0) then recCustLedg.Mark(true);
                            end;
                        until DtldCustLedgEntry2.Next() = 0;
                end
                else begin
                    recCustLedg.SetCurrentKey("Entry No.");
                    recCustLedg.SetRange("Entry No.", DtldCustLedgEntry1."Applied Cust. Ledger Entry No.");
                    if recCustLedg.Find('-') AND (recCustLedg."Entry No." <> 0) then recCustLedg.Mark(true);
                end;
            until DtldCustLedgEntry1.Next() = 0;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", OnAfterInitOldDtldCVLedgEntryBuf, '', false, false)]
    local procedure "Gen. Jnl.-Post Line_OnAfterInitOldDtldCVLedgEntryBuf"(var DtldCVLedgEntryBuf: Record "Detailed CV Ledg. Entry Buffer";
     var NewCVLedgEntryBuf: Record "CV Ledger Entry Buffer";
     var OldCVLedgEntryBuf: Record "CV Ledger Entry Buffer";
     var PrevNewCVLedgEntryBuf: Record "CV Ledger Entry Buffer";
     var PrevOldCVLedgEntryBuf: Record "CV Ledger Entry Buffer";
     var GenJnlLine: Record "Gen. Journal Line")
    begin
        OldCVLedgEntryBuf."Closed By Doc. Type" := NewCVLedgEntryBuf."Document Type";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", OnAfterInitNewDtldCVLedgEntryBuf, '', false, false)]
    local procedure "Gen. Jnl.-Post Line_OnAfterInitNewDtldCVLedgEntryBuf"(var DtldCVLedgEntryBuf: Record "Detailed CV Ledg. Entry Buffer";
     var NewCVLedgEntryBuf: Record "CV Ledger Entry Buffer";
     var OldCVLedgEntryBuf: Record "CV Ledger Entry Buffer";
     var PrevNewCVLedgEntryBuf: Record "CV Ledger Entry Buffer";
     var PrevOldCVLedgEntryBuf: Record "CV Ledger Entry Buffer";
     var GenJnlLine: Record "Gen. Journal Line")
    begin
        NewCVLedgEntryBuf."Closed By Doc. Type" := OldCVLedgEntryBuf."Document Type";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CustEntry-Apply Posted Entries", OnApplyOnBeforeCustPostApplyCustLedgEntry, '', false, false)]
    local procedure "CustEntry-Apply Posted Entries_OnApplyOnBeforeCustPostApplyCustLedgEntry"(CustLedgerEntry: Record "Cust. Ledger Entry"; var ApplyUnapplyParameters: Record "Apply Unapply Parameters" temporary)
    var
        ApplyToCustLedgEntry: record "Cust. Ledger Entry";
        SingleInsCU: codeunit 70001;
    begin
        SingleInsCU.ClearTempCLE();
        ApplyToCustLedgEntry.SetCurrentKey("Customer No.", "Applies-to ID");
        ApplyToCustLedgEntry.SetRange("Customer No.", CustLedgerEntry."Customer No.");
        ApplyToCustLedgEntry.SetRange("Applies-to ID", CustLedgerEntry."Applies-to ID");
        ApplyToCustLedgEntry.FindSet();
        repeat
            SingleInsCU.InsertIntoTempCLE(ApplyToCustLedgEntry);
        until ApplyToCustLedgEntry.Next() = 0;

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CustEntry-Apply Posted Entries", OnCustPostApplyCustLedgEntryOnBeforeCommit, '', false, false)]
    local procedure "CustEntry-Apply Posted Entries_OnCustPostApplyCustLedgEntryOnBeforeCommit"(var CustLedgerEntry: Record "Cust. Ledger Entry"; var SuppressCommit: Boolean)
    var
        TempCustLedgEntry: record "Cust. Ledger Entry" temporary;
        SingleInsCU: codeunit 70001;
        payment: Boolean;
        Credit: Boolean;
        Amount: Decimal;
        CLE, cle1 : record "Cust. Ledger Entry";
        SalesInvoiceNo: code[20];
        PayStatus: text;
        SalesInvHeader: record "Sales Invoice Header";
    begin
        payment := false;
        Credit := false;
        Amount := 0;
        SingleInsCU.GetTempCLE(TempCustLedgEntry);
        SingleInsCU.ClearTempCLE();
        if TempCustLedgEntry.FindFirst() then
            repeat
                cle.get(TempCustLedgEntry."Entry No.");
                case Cle."Document Type" of
                    // "Gen. Journal Document Type"::" ", "Gen. Journal Document Type"::Payment:
                    //     begin
                    //         if (cle."Closed By Doc. Type" = cle."Closed By Doc. Type"::Invoice) then payment := true;
                    //     end;
                    "Gen. Journal Document Type"::"Credit Memo":
                        begin
                            if (cle."Closed By Doc. Type" = cle."Closed By Doc. Type"::Invoice) then Credit := true;
                        end;
                    "Gen. Journal Document Type"::Invoice:
                        begin
                            SalesInvoiceNo := CLE."Document No.";
                            if cle."Closed by Entry No." <> 0 then begin
                                if (cle."Closed By Doc. Type" = cle."Closed By Doc. Type"::" ") OR (cle."Closed By Doc. Type" = cle."Closed By Doc. Type"::Payment) then
                                    payment := true
                                else if (cle."Closed By Doc. Type" = cle."Closed By Doc. Type"::"Credit Memo") then
                                    credit := true;
                            end;
                            cle1.Reset();
                            cle1.get(cle."Entry No.");
                            GetAppliedentries(CLE1);
                            if cle1.FindFirst() then
                                repeat
                                    if cle1."Entry No." <> 0 then
                                        case cle1."Document Type" of
                                            "Gen. Journal Document Type"::" ", "Gen. Journal Document Type"::Payment:
                                                begin
                                                    cle1.CalcFields(Amount);
                                                    payment := true;
                                                    Amount += cle1."Amount";
                                                end;
                                            "Gen. Journal Document Type"::"Credit Memo":
                                                begin
                                                    cle1.CalcFields(Amount);
                                                    Credit := true;
                                                    Amount += cle1."Amount";
                                                end;
                                        end;
                                until cle1.Next() = 0;
                            cle.CalcFields(Amount);
                            Amount += cle."Amount";
                        end;
                end;
            // Amount += TempCustLedgEntry."Amount to Apply";
            until TempCustLedgEntry.Next() = 0;

        if SalesInvoiceNo <> '' then begin
            if (Amount <= 0) then begin
                if payment and Credit then begin
                    PayStatus := 'PARTIALLY PAID';
                end
                else if payment then begin
                    PayStatus := 'PAID';
                end
                else if Credit then begin
                    PayStatus := 'CREDITED';
                end;
            end else begin
                if payment then
                    PayStatus := 'PARTIALLY PAID'
                else
                    Paystatus := 'UNPAID';
            end;
            SalesInvHeader.get(SalesInvoiceNo);
            SalesInvHeader.PaymentStatus3 := PayStatus;
            SalesInvHeader.Modify();
        end;
        // Error('Hi'); //523401
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CustEntry-Apply Posted Entries", OnPostUnApplyCustomerCommitOnAfterSetFilters, '', false, false)]
    local procedure "CustEntry-Apply Posted Entries_OnPostUnApplyCustomerCommitOnAfterSetFilters"(var DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry"; DetailedCustLedgEntry2: Record "Detailed Cust. Ledg. Entry")
    var
        Cle: record "Cust. Ledger Entry";
        SingleInsCU: codeunit SingleInstanceCU;
    begin
        SingleInsCU.ClearTempCLE();
        if DetailedCustLedgEntry.FindFirst() then
            repeat
                if cle.get(DetailedCustLedgEntry."Cust. Ledger Entry No.") then begin
                    if cle."Document Type" = cle."Document Type"::Invoice then begin
                        SingleInsCU.InsertIntoTempCLE(cle);
                    end;
                end;
            until DetailedCustLedgEntry.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CustEntry-Apply Posted Entries", OnAfterPostUnapplyCustLedgEntry, '', false, false)]
    local procedure "CustEntry-Apply Posted Entries_OnAfterPostUnapplyCustLedgEntry"(GenJournalLine: Record "Gen. Journal Line"; CustLedgerEntry: Record "Cust. Ledger Entry"; DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var CommitChanges: Boolean; var TempCustLedgerEntry: Record "Cust. Ledger Entry" temporary)
    var
        TempCustLedgEntry: record "Cust. Ledger Entry" temporary;
        SingleInsCU: codeunit SingleInstanceCU;
        cle: record "Cust. Ledger Entry";
        Payment: Boolean;
        SalesInvHeader: record "Sales Invoice Header";
    begin
        SingleInsCU.GetTempCLE(TempCustLedgEntry);
        SingleInsCU.ClearTempCLE();
        if TempCustLedgEntry.FindFirst() then
            repeat
                Payment := false;
                cle.get(TempCustLedgEntry."Entry No.");
                GetAppliedentries(cle);
                if cle.findfirst then
                    repeat
                        if cle."Entry No." <> 0 then
                            if (cle."Document Type" = cle."Document Type"::Payment) OR (cle."Document Type" = cle."Document Type"::" ") then payment := true;
                    until cle.next = 0;

                if SalesInvHeader.get(TempCustLedgEntry."Document No.") then begin
                    if Payment then
                        SalesInvHeader.PaymentStatus3 := 'PARTIALLY PAID'
                    ELSE
                        SalesInvHeader.PaymentStatus3 := 'UNPAID';
                    SalesInvHeader.Modify();
                end;
            until TempCustLedgerEntry.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnAfterPostSalesDoc, '', false, false)]
    local procedure "Sales-Post_OnAfterPostSalesDoc"(var SalesHeader: Record "Sales Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; SalesShptHdrNo: Code[20]; RetRcpHdrNo: Code[20]; SalesInvHdrNo: Code[20]; SalesCrMemoHdrNo: Code[20]; CommitIsSuppressed: Boolean; InvtPickPutaway: Boolean; var CustLedgerEntry: Record "Cust. Ledger Entry"; WhseShip: Boolean; WhseReceiv: Boolean; PreviewMode: Boolean)
    var
        CstLedgEntry: record "Cust. Ledger Entry";
        payment: boolean;
        salesInvHeader: record "Sales Invoice Header";
    begin
        payment := false;
        if (SalesHeader."Document Type" = SalesHeader."Document Type"::"Credit Memo") AND
        (SalesHeader."Applies-to Doc. Type" = SalesHeader."Applies-to Doc. Type"::Invoice) then begin
            CstLedgEntry.SetCurrentKey("Document Type", "Document No.");
            CstLedgEntry.SetFilter("Document Type", '%1', CstLedgEntry."Document Type"::Invoice);
            CstLedgEntry.SetFilter("Document No.", '%1', SalesHeader."Applies-to Doc. No.");
            if CstLedgEntry.FindFirst() then begin
                GetAppliedentries(CstLedgEntry);
                if CstLedgEntry.FindFirst() then
                    repeat
                        if CstLedgEntry."Entry No." <> 0 then
                            if (CstLedgEntry."Document Type" = CstLedgEntry."Document Type"::" ") OR (CstLedgEntry."Document Type" = CstLedgEntry."Document Type"::Payment)
                             then
                                payment := true;
                    until CstLedgEntry.Next() = 0;
            end;
            if salesInvHeader.get(SalesHeader."Applies-to Doc. No.") then begin
                if payment then
                    salesInvHeader.PaymentStatus3 := 'PARTIALLY PAID'
                else
                    salesInvHeader.PaymentStatus3 := 'CREDITED';
                salesInvHeader.Modify();
            end;
        end;

    end;


    // Payment Status Code
    var
        // cle: page "Customer Ledger Entries";
        CLEDocType: Enum "Gen. Journal Document Type";

}
