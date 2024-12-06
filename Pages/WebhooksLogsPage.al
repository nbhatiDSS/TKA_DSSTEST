page 70002 Webhooks
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = Webhooks;
    Editable = false;
    SourceTableView = sorting("Entry No") order(descending);

    layout
    {
        area(Content)
        {
            repeater(Repeater)
            {
                field("Entry No"; Rec."Entry No")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(TableID; Rec.TableID)
                {
                    ApplicationArea = All;
                }
                field("Record Primary Key"; Rec."Record Primary Key")
                {
                    ApplicationArea = All;
                }
                field("In Progress"; Rec."In Progress")
                {
                    ApplicationArea = All;
                }
                field(Response; Rec.Response)
                {
                    ApplicationArea = All;
                }
                field("Event Name"; Rec."Event Name")
                {
                    ApplicationArea = All;
                }
                field("Event Type"; Rec."Event Type")
                {
                    ApplicationArea = All;
                }
                field(RecContent; Rec.Content)
                {
                    Caption = 'Content';
                    ApplicationArea = All;
                }
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    ApplicationArea = All;
                }
                field(SystemModifiedAt; Rec.SystemModifiedAt)
                {
                    ApplicationArea = All;
                }


            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Sendhooks)
            {
                Caption = 'Send Webhooks';
                ApplicationArea = all;
                Image = Web;

                trigger OnAction()
                var
                    AutomateWebhooks: codeunit AutomateWebhooks;
                    webhooks: Record Webhooks;
                    res: HttpResponseMessage;
                begin
                    webhooks.Reset();
                    webhooks.SetFilter("In Progress", '%1', false);
                    webhooks.SetFilter("Response", '<>%1', 200);
                    if webhooks.Findset() then begin
                        webhooks.ModifyAll("In Progress", True);
                        Commit();
                    end;
                    AutomateWebhooks.SendWebHooks();
                    CurrPage.Update();
                end;
            }

            action(CreateTestWebhook)
            {
                Caption = 'Create Test Webhooks';
                ApplicationArea = all;
                Image = Web;

                trigger OnAction()
                var
                    cs: codeunit 80;
                    AutomateWebhooks: codeunit AutomateWebhooks;
                    WebhookType: enum WebhookType;
                    EventHeader: record "Event Header";
                begin
                    AutomateWebhooks.CreateWebhookEntry(Database::"Event Header", 'Event', WebhookType::Created, 'TESTCONTENT', 'EVE0000000');
                    CurrPage.Update();
                end;
            }
        }
    }

    var
        myInt: Integer;
}