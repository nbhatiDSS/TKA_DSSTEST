query 52005 EDE
{
    QueryType = API;
    APIPublisher = 'DSS';
    APIGroup = 'PowerBI';
    APIVersion = 'v2.0';
    EntityName = 'EDE';
    EntitySetName = 'EDE';

    elements
    {
        dataitem(EventHeader; "Event Header")
        {
            column(No_; "No.")
            { }
            column(Start_Date; "Start Date")
            { }
            column(Accredited_Body; EI)
            { }

            column(Delivery; Delivery)
            { }
            column(Delivery_Nature; "Delivery Nature")
            { }
            column(Course_Header; "Course Header")
            { }
            column(Country_Code; "Country Code")
            { }
            dataitem(Event_Detailed_Entry; "Event Detailed Entry")
            {
                DataItemLink = "Event No." = EventHeader."No.";
                DataItemTableFilter = Status = filter('<>Available');
                column(Document_No_; "Document No.")
                { }
                column(Status; Status)
                { }
                column(Document_Line_No_; "Document Line No.") { }
                column(Contact_Customer_No_; "Contact/Customer No.") { }
                column(Posting_Date; "Posting Date")
                { ColumnFilter = "posting_date" = filter(<> ''); }
                column(Invoiced_Amount__Excl__Tax_; "Invoiced Amount [Excl. Tax]")
                { }
                column(Salesperson_Code; "Salesperson Code")
                { }
                column(count)
                {
                    Method = Count;
                }
            }
        }
    }

    var
        myInt: Integer;

    trigger OnBeforeOpen()
    begin

    end;
}