xmlport 70003 BulkEventUpdate
{

    Format = VariableText;
    Direction = Import;
    TextEncoding = UTF8;
    UseRequestPage = false;
    schema
    {
        textelement(Root)
        {
            tableelement(Integer; Integer)
            {
                AutoSave = false;
                AutoReplace = false;
                AutoUpdate = false;


                textelement(EventNo)
                {
                    MinOccurs = Zero;
                }
                textelement(EventStatus)
                {
                    MinOccurs = Zero;
                }
                textelement(Rcode)
                {
                    MinOccurs = Zero;
                }
                textelement(EventCancellationDetails)
                {
                    MinOccurs = Zero;
                }

                trigger OnBeforeInsertRecord()
                var
                    EventHeader: record "Event Header";
                begin
                    if EventHeader.get(EventNo) then begin
                        EventHeader.Validate(EventHeader.ReasonCode, Rcode);
                        if EventCancellationDetails = 'TKA Cancelled' then
                            EventHeader.Validate(EventHeader."Cancellation Event Details", EventHeader."Cancellation Event Details"::"TKA Cancelled");
                        case EventStatus of
                            'Cancelled':
                                EventHeader."Event Status" := EventHeader."Event Status"::Cancelled;
                            'Confirmed':
                                EventHeader."Event Status" := EventHeader."Event Status"::Confirmed;
                        end;
                        EventHeader.Modify();
                        ModifiedCount += 1
                    end;

                end;
            }
        }
    }
    trigger OnPostXmlPort()
    begin
        Message('Records Modified - %1', ModifiedCount);
        // Error('Hi');
    end;

    var
        ModifiedCount: Integer;
}