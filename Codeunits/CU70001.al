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

    //GLobal Triggers for WebHooks
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Global Triggers", GetGlobalTableTriggerMask, '', false, false)]
    local procedure "Global Triggers_GetGlobalTableTriggerMask"(TableID: Integer; var TableTriggerMask: Integer)
    begin
    end;



    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Global Triggers", GetDatabaseTableTriggerSetup, '', false, false)]
    local procedure "Global Triggers_GetDatabaseTableTriggerSetup"(TableId: Integer; var OnDatabaseInsert: Boolean; var OnDatabaseModify: Boolean; var OnDatabaseDelete: Boolean; var OnDatabaseRename: Boolean)
    begin
        case TableId of
            Database::"Sales Invoice Header":
                begin
                    OnDatabaseInsert := true;
                    OnDatabaseModify := true;
                end;
            Database::"Sales Invoice Line":
                begin
                    OnDatabaseModify := true;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::GlobalTriggerManagement, OnAfterOnDatabaseInsert, '', false, false)]
    local procedure GlobalTriggerManagement_OnAfterOnDatabaseInsert(RecRef: RecordRef)
    var
        salesInvoiceHeader: record "Sales Invoice Header";
    begin
        case RecRef.Number of
            Database::"Sales Invoice Header":
                begin
                    RecRef.SetTable(salesInvoiceHeader);
                    if salesInvoiceHeader."No." <> '' then begin
                        CreateModifySalesInvHeaderWebHook(salesInvoiceHeader, webhooktype::Created);
                    end;
                end;

        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::GlobalTriggerManagement, OnAfterOnDatabaseModify, '', false, false)]
    local procedure GlobalTriggerManagement_OnAfterOnDatabaseModify(RecRef: RecordRef)
    var
        salesInvoiceHeader: record "Sales Invoice Header";
        SalesInvoiceLine: record "Sales Invoice Line";
    begin
        case RecRef.Number of
            Database::"Sales Invoice Header":
                begin
                    RecRef.SetTable(salesInvoiceHeader);
                    if salesInvoiceHeader."No." <> '' then begin
                        CreateModifySalesInvHeaderWebHook(salesInvoiceHeader, webhooktype::Updated);
                    end;
                end;
            Database::"Sales Invoice Line":
                begin
                    RecRef.SetTable(SalesInvoiceLine);
                    if SalesInvoiceLine."No." <> '' then begin
                        CreateModifySalesInvHeaderWebHook(SalesInvoiceLine, webhooktype::Updated);
                    end;
                end;
        end;

    end;

    procedure CreateContentPostedSales(var SalesInvHeader: Record "Sales Invoice Header"; var Content: httpContent; type: enum Webhooktype) //NB 230724
    var
        Payload: JsonObject;
        Data: JsonObject;
        JsonText: Text;
    begin
        Payload.Add(eventLabel, 'Invoice.' + Format(type));
        payload.Add('Created', CurrentDateTime);

        // Data json object
        Data.Add('SystemId', SalesInvHeader.SystemId);
        Data.Add('Invoice_No', SalesInvHeader."No.");
        Data.Add('Company', CompanyName());

        //Adding Data json object in payload
        Payload.Add('Data', Data);
        Payload.WriteTo(JsonText);
        Content.WriteFrom(JsonText);
    end;

    procedure CreateModifySalesInvHeaderWebHook(SalesInvoiceHeader: record "Sales Invoice Header"; webhooktype: Enum WebhookType)
    var
        content: HttpContent;
        WebhookImpl: codeunit "Webhooks Impl";
    begin
        CreateContentPostedSales(SalesInvoiceHeader, content, webhooktype);  //NB 230724
        WebhookImpl.SendHttpRequest(content);
    end;

    procedure CreateModifySalesInvHeaderWebHook(SalesInvLine: record "Sales Invoice Line"; webhooktype: Enum WebhookType)
    var
        content: HttpContent;
        WebhookImpl: codeunit "Webhooks Impl";
        SalesInvHeader: Record "Sales Invoice Header";
    begin
        SalesInvHeader.get(SalesInvLine."Document No.");
        CreateContentPostedSales(SalesInvHeader, content, webhooktype);  //NB 230724
        WebhookImpl.SendHttpRequest(content);
    end;



    //GLobal Triggers for WebHooks

    var
        // cle: page "Customer Ledger Entries";
        webhooktype: enum WebhookType;
        CLEDocType: Enum "Gen. Journal Document Type";
        t: page 6405;
        cc: codeunit "Gen. Jnl.-Post Line";
        eventLabel: Label 'Event';

}
