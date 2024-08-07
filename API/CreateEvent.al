page 70100 CreateEvent
{
    PageType = API;
    Caption = 'Create Event';
    APIGroup = 'API';
    APIPublisher = 'Direction_Software_LLP';
    APIVersion = 'v1.0', 'v2.0';
    EntityName = 'events';
    EntitySetName = 'insertEvent';
    SourceTable = "Event Header";
    DelayedInsert = true;
    ODataKeyFields = "No.";


    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Event_No"; Rec."No.")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    var
                        coursePlanningSetup: Record "Course Planning Setup";
                        NoseriesBatch: Codeunit "No. Series - Batch";
                        NoseriesMgt: Codeunit "No. Series - Setup";
                        NOserMgt: Codeunit NoSeriesManagement;
                    begin
                        CoursePlanningSetup.get;
                        CoursePlanningSetup.TestField("Event Nos.");
                        rec."No." := NOserMgt.GetNextNo(coursePlanningSetup."Event Nos.", WorkDate(), true);
                    end;
                }
                field("CourseHeader"; Rec."Course Header")
                {
                    Caption = 'course Header';
                }
                field("StartDate"; startDate)
                {
                    Caption = 'Start Date';
                    trigger OnValidate()
                    var
                        myInt: Integer;
                    begin
                        rec."Start Date" := startDate;
                        rec."Day Name" := Format(rec."Start Date", 0, '<Weekday Text>');

                    end;
                }
                field(Source; Rec.Source)
                {
                    Caption = 'Source';
                }
                field(Delivery; Rec.Delivery)
                {
                    Caption = 'Delivery';
                }
                field("DeliveryNature"; Rec."Delivery Nature")
                {
                    Caption = 'Delivery Nature';
                }
                field(CountryCode; Rec."Country Code")
                {
                    Caption = 'CountryCode';
                }
                field("PostCode"; Rec."Post Code")
                {
                    Caption = 'Postcode';
                }
                field(GroupLocationCode; Rec."Group Location Code")
                {
                    Caption = 'Group Location Code';
                }
                field("TrainingCentre"; Rec."Training Centre")
                {
                    Caption = 'Training Centre';
                }
                field(Technical; Rec.Technical)
                {
                    Caption = 'Technical';
                }
                field(ZoomMeeting; Rec.ZoomMeeting)
                {
                    Caption = 'Zoom Meeting';
                }
                field("MaxCandidates"; Rec."Max. Number of Candidates")
                {
                    Caption = 'Max. Number of Candidates';
                }
                field(Week; Rec.Week)
                {
                    Caption = 'week';
                }
                field("BespokeType"; Rec."Bespoke Type")
                {
                    Caption = 'BespokeType';
                }

                field(InvigilatorCode; rec."Invigilator Code")
                {
                    Caption = 'Invigilator Code';
                }
                field(ExpirationDate; Rec."Expiration Date")
                {
                    Caption = 'Expiration Date';
                }
                field(Comments; Rec.Comments)
                {

                }
            }
        }
    }


    var
        startDate: Date;

}