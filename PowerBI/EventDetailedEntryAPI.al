query 52002 EventDetailedEntries
{
    QueryType = API;
    APIPublisher = 'DSS';
    APIGroup = 'PowerBI';
    APIVersion = 'v2.0';
    EntityName = 'EventDetailedEntries';
    EntitySetName = 'eventDetailedEntries';

    elements
    {
        dataitem(Event_Detailed_Entry; "Event Detailed Entry")
        {
            column(Event_No_; "Event No.")
            { }
            column(Status; Status)
            { }
            column(Document_No_; "Document No.")
            { }
            column(Document_Line_No_; "Document Line No.")
            { }
            column(Posting_Date; "Posting Date")
            { }
            column(Invoiced_Amount__Excl__Tax_; "Invoiced Amount [Excl. Tax]")
            { }
            column(Ordered_Amount__Excl__Tax_; "Ordered Amount [Excl. Tax]")
            { }
            column(Line_No_; "Line No.")
            { }
            column(GL_Account; "GL Account")
            { }
            column(Course_Header; "Course Header")
            { }
            column(Bill_To_Customer_No_; "Bill-To Customer No.")
            { }
            column(Training_Location; "Training Location")
            { }
            column(Training_Date; "Training Date")
            { }
            column(Event_End_Date; "Event End Date")
            { }
            column(Element_Code; "Element Code")
            { }
            column(Element_Name; "Element Name")
            { }
            column(Course_Trainer; "Course Trainer")
            { }
            column(Contact_Customer_No_; "Contact/Customer No.")
            { }
            column(Salesperson_Code; "Salesperson Code")
            { }
            column(Payment_Status; "Payment Status")
            { }
        }
    }
}