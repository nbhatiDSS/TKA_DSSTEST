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



    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Global Triggers", GetDatabaseTableTriggerSetup, '', false, false)]
    local procedure "Global Triggers_GetDatabaseTableTriggerSetup"(TableId: Integer; var OnDatabaseInsert: Boolean; var OnDatabaseModify: Boolean; var OnDatabaseDelete: Boolean; var OnDatabaseRename: Boolean)
    begin
        case TableId of
            database::"Cust. Ledger Entry":
                begin
                    OnDatabaseModify := true;
                end;
        end;
    end;

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
                                if recCustLedg.Find('-') then recCustLedg.Mark(true);
                            end;
                        until DtldCustLedgEntry2.Next() = 0;
                end
                else begin
                    recCustLedg.SetCurrentKey("Entry No.");
                    recCustLedg.SetRange("Entry No.", DtldCustLedgEntry1."Applied Cust. Ledger Entry No.");
                    if recCustLedg.Find('-') then recCustLedg.Mark(true);
                end;
            until DtldCustLedgEntry1.Next() = 0;
    end;

    local procedure UpdatePostedSalesInvoicePaidAmount(var CustLedgEntry: record "Cust. Ledger Entry")
    var
        PaidAmount: decimal;
    begin
        PaidAmount := 0;


    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::GlobalTriggerManagement, OnAfterOnDatabaseModify, '', false, false)]
    local procedure GlobalTriggerManagement_OnAfterOnDatabaseModify(RecRef: RecordRef)
    var
        custLedgEntry, custledgEntry1 : Record "Cust. Ledger Entry";
        DtldCustLedgEntry: record "Detailed Cust. Ledg. Entry";
        payment, CrMemo : Boolean;
        salesInvHeader: record "Sales Invoice Header";
    begin
        case RecRef.Number of
            database::"Cust. Ledger Entry":
                begin
                    payment := false;
                    CrMemo := false;
                    RecRef.SetTable(custLedgEntry);
                    custLedgEntry.CalcFields("Remaining Amount");
                    if (custLedgEntry.Open = false) AND (custLedgEntry."Document Type" = custLedgEntry."Document Type"::Invoice) AND (custLedgEntry."Source Code" = 'SALES') then begin
                        custledgEntry1.Reset();
                        if custledgEntry."Closed by Entry No." <> 0 then begin
                            case custledgEntry."Closed By Doc. Type" of
                                "Gen. Journal Document Type"::" ", "Gen. Journal Document Type"::Payment:
                                    payment := true;
                                "Gen. Journal Document Type"::"Credit Memo":
                                    CrMemo := true;
                            end;
                        end;
                        custledgEntry1.Reset();
                        if custLedgEntry1.get(custLedgEntry."Entry No.") then begin
                            GetAppliedentries(custLedgEntry1);
                            if custledgEntry1.FindFirst() then
                                repeat
                                    case custledgEntry1."Document Type" of
                                        "Gen. Journal Document Type"::" ", "Gen. Journal Document Type"::Payment:
                                            payment := true;
                                        "Gen. Journal Document Type"::"Credit Memo":
                                            CrMemo := true;
                                    end;
                                until custledgEntry1.Next() = 0;
                        end;

                        if salesInvHeader.get(custLedgEntry."Document No.") then;
                        if payment and crMemo then begin
                            salesInvHeader.PaymentStatus3 := 'PARTIALLY PAID';
                            salesInvHeader.Modify();
                        end
                        else if payment then begin
                            salesInvHeader.PaymentStatus3 := 'PAID';
                            salesInvHeader.Modify();
                        end
                        else if crMemo then begin
                            salesInvHeader.PaymentStatus3 := 'CREDITED';
                            salesInvHeader.Modify();
                        end;
                    end;

                    if (custLedgEntry.Open = true) AND (custLedgEntry."Document Type" = custLedgEntry."Document Type"::Invoice)
                     AND (custLedgEntry."Source Code" = 'SALES') then begin
                        custledgEntry1.Reset();
                        if custLedgEntry1.get(custLedgEntry."Entry No.") then begin
                            GetAppliedentries(custLedgEntry1);
                            if custledgEntry1.FindFirst() then
                                repeat
                                    case custledgEntry1."Document Type" of
                                        "Gen. Journal Document Type"::" ", "Gen. Journal Document Type"::Payment:
                                            payment := true;
                                    end;
                                until custledgEntry1.Next() = 0;

                            if salesInvHeader.get(custLedgEntry."Document No.") then
                                if payment AND (salesInvHeader.PaymentStatus3 <> 'PARTIALLY PAID') then begin
                                    salesInvHeader.PaymentStatus3 := 'PARTIALLY PAID';
                                    salesInvHeader.Modify();
                                end ELSE if (salesInvHeader.PaymentStatus3 <> 'UNPAID') then begin
                                    salesInvHeader.PaymentStatus3 := 'UNPAID';
                                    salesInvHeader.Modify();
                                end;
                        end;
                    end;
                end;
        end;
    end; //453852 //520027 506093  //522438

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

    // [EventSubscriber(ObjectType::Table, Database::"CV Ledger Entry Buffer", OnAfterSetClosedFields, '', false, false)]
    // local procedure "CV Ledger Entry Buffer_OnAfterSetClosedFields"(var CVLedgerEntryBuffer: Record "CV Ledger Entry Buffer")
    // begin
    //     CVLedgerEntryBuffer."Closed By Doc. Type" := CLEDocType;
    // end;

    var
        cle: page "Customer Ledger Entries";
        CLEDocType:
                Enum "Gen. Journal Document Type";

}
