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

    local procedure UpdateKeyEventOnEvent(Confirm: boolean; salesHeader: record "Sales Header")
    var
        cust: Record Customer;
        eventHeader: Record "Event Header";
        salesLine: record "Sales Line";
    begin
        if cust.get(salesHeader."Sell-to Customer No.") then begin
            if cust."Key Account" then begin
                salesLine.reset;
                salesLine.SetCurrentKey("Document Type", "Document No.");
                salesLine.SetFilter("Document Type", '%1', salesHeader."Document Type");
                salesLine.SetFilter("Document No.", '%1', salesHeader."No.");
                if salesLine.FindFirst() then
                    repeat
                        if eventheader.get(salesLine."Event Header") then begin
                            if confirm then begin
                                eventHeader."Key Account" := True;
                                eventHeader."Key Account Count" += 1;
                                eventHeader.Modify();
                            end
                            else begin
                                eventHeader."Key Account Count" -= 1;
                                if eventHeader."Key Account Count" = 0 then begin
                                    eventHeader."Key Account" := false;
                                    eventHeader.modify;
                                end;
                            end;
                        end;
                    until salesLine.Next() = 0;
            end;
        end;
    end;


    procedure GetPaidAmount(CustLedgEntryNo: integer): decimal
    var
        CustLedgEntry, CustLedgEntry1 : record "Cust. Ledger Entry";
        DetCustLedgEntry, DetCustLedgEntry1 : Record "Detailed Cust. Ledg. Entry";
        PaidAmount: Decimal;
    begin
        if CustLedgEntry.get(CustLedgEntryNo) then begin
            // CustLedgEntry1 := CustLedgEntry;
            // eventTriggers.GetAppliedentries(CustLedgEntry1);
            DetCustLedgEntry.SetFilter("Cust. Ledger Entry No.", '%1', CustLedgEntry."Entry No.");
            DetCustLedgEntry.SetFilter("Entry Type", '%1', DetCustLedgEntry."Entry Type"::Application);
            DetCustLedgEntry.SetFilter(Unapplied, '%1', false);
            if DetCustLedgEntry.FindFirst() then
                repeat
                    DetCustLedgEntry1.SetFilter("Customer No.", '%1', CustLedgEntry."Customer No.");
                    DetCustLedgEntry1.SetFilter("Entry Type", '%1', DetCustLedgEntry1."Entry Type"::Application);
                    DetCustLedgEntry1.SetFilter(Unapplied, '%1', false);
                    DetCustLedgEntry1.SetFilter("Document Type", '%1', DetCustLedgEntry."Document Type");
                    DetCustLedgEntry1.SetFilter("Document No.", '%1', DetCustLedgEntry."Document No.");
                    DetCustLedgEntry1.SetFilter("Entry No.", '<>%1', DetCustLedgEntry."Entry No.");
                    if DetCustLedgEntry1.FindFirst() then begin
                        if CustLedgEntry1.get(DetCustLedgEntry1."Cust. Ledger Entry No.") then begin
                            if (CustLedgEntry1."Document Type" <> CustLedgEntry1."Document Type"::"Credit Memo") then PaidAmount += Abs(DetCustLedgEntry1."Amount (LCY)");
                        end;
                    end;
                until DetCustLedgEntry.Next() = 0;
        end;
        exit(PaidAmount)
    end;


    local procedure UpdateOriginalKP()
    var
        myInt: Integer;
    begin

    end;


    var
        // cle: page "Customer Ledger Entries";
        webhooktype: enum WebhookType;
        CLEDocType: Enum "Gen. Journal Document Type";
        t: page 6405;
        cc: codeunit "Gen. Jnl.-Post Line";
        eventLabel: Label 'Event';

}
