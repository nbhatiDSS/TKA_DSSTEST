codeunit 50200 AutomateWebhooks
{
    trigger OnRun()
    begin

    end;

    procedure CreateWebhookEntry(TableID: integer; EventName: text[50]; eventType: Enum WebhookType; content: Text; PrimaryKeys: text)
    var
        WebHooks, Webhooks1 : record Webhooks;
    begin
        WebHooks.Reset();
        WebHooks.SetFilter(TableID, '%1', TableID);
        WebHooks.SetFilter("Response", '<>%1', 200);
        WebHooks.SetFilter("In Progress", '%1', false);
        WebHooks.SetFilter("Record Primary Key", '%1', PrimaryKeys);
        if WebHooks.FindFirst() then begin
            WebHooks."Event Type" := eventType;
            WebHooks.Content := content;
            WebHooks.Modify();
        end else begin
            WebHooks.Reset();
            WebHooks.Init();
            if Webhooks1.FindLast() then
                WebHooks."Entry No" := Webhooks1."Entry No" + 1
            else
                WebHooks."Entry No" := 1;
            WebHooks.TableID := TableID;
            WebHooks."Event Name" := EventName;
            WebHooks."Event Type" := eventType;
            WebHooks."Record Primary Key" := PrimaryKeys;
            WebHooks.Insert();
        end;
    end;

    procedure SendWebHooks()
    var
        Webhooks: record Webhooks;
        webhookImpl: codeunit "Webhooks Impl";
        Content: HttpContent;
    begin
        WebHooks.Reset();
        WebHooks.SetFilter("In Progress", '%1', True);
        WebHooks.SetFilter("Response", '<>%1', 200);
        if Webhooks.Findset() then begin
            // Webhooks.ModifyAll("In Progress", True);
            // Commit();
            repeat begin
                Content.WriteFrom(Webhooks.Content);
                Webhooks.Response := webhookImpl.SendHttpRequest(Content);
                Webhooks."In Progress" := false;
                Webhooks.Modify();
                commit();
            end until Webhooks.Next() = 0;
        end
    end;


    var
        webhookImpl: codeunit "Webhooks Impl";
        cu: codeunit 80;

}