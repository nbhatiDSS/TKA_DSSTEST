page 70066 "Applied Customer Entries API 1"
{
    pagetype = API;
    APIVersion = 'v1.0';
    APIPublisher = 'bctech';
    APIGroup = 'demo';

    EntityCaption = 'CarModel';
    EntitySetCaption = 'CarModels';
    EntityName = 'GetAppliedEntries';
    EntitySetName = 'GetAppliedEntries';
    Extensible = false;
    DelayedInsert = true;
    ODataKeyFields = SystemId;
    SourceTable = 21;

    layout
    {
        area(content)
        {
            repeater(group)
            {
                field(SystemId; Rec.SystemId)
                {
                }
                field("PostingDate"; rec."Posting Date")
                {
                }
                field("DocumentType"; rec."Document Type")
                {
                }
                field("DocumentNo"; rec."Document No.")
                {
                }
                field("CurrencyCode"; rec."Currency Code")
                {
                }
                field("OriginalAmount"; rec."Original Amount")
                {
                }
                field(Amount; rec.Amount)
                {
                }
                field("EntryNo"; rec."Entry No.")
                {
                }
            }
        }
    }


    trigger OnOpenPage()
    var
        AppliedCLE: record "Cust. Ledger Entry";
        EventTriggers: codeunit EventTriggers;
    begin
        if rec.GetFilter("Document No.") = '' then error('No filters');
        if rec.FindFirst() then EventTriggers.GetAppliedentries(rec);
    end;


    var
        count: integer;
}

