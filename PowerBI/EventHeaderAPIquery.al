query 52000 EventHeader
{
    QueryType = API;
    APIPublisher = 'DSS';
    APIGroup = 'PowerBI';
    APIVersion = 'v2.0';
    EntityName = 'EventHeaders';
    EntitySetName = 'eventHeader';

    elements
    {
        dataitem(Event_Header; "Event Header")
        {
            column(No_; "No.")
            { }
            column(Course_Header; "Course Header")
            { }
            column(Start_Date; "Start Date")
            { }
            column(End_Date; "End Date")
            { }
            column(Training_Centre; "Training Centre")
            { }
            column(Description; Description)
            { }
            column(Max__Number_of_Candidates; "Max. Number of Candidates")
            { }
            column(Course_Trainer; "Course Trainer")
            { }
            column(Delivery; Delivery)
            { }
            column(Resource_Manager; "Resource Manager")
            { }
            column(Resource_Manager_Name; "Resource Manager Name")
            { }
            column(Shift_Timing; "Shift Timing")
            { }
            column(EI; EI)
            { }
            column(Delivery_Nature; "Delivery Nature")
            { }
            column(Event_Status; "Event Status")
            { }
        }
    }
}