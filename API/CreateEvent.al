// page 61000 CreateEvent
// {
//     PageType = API;
//     Caption = 'Create Event';
//     APIGroup = 'API';
//     APIPublisher = 'Direction_Software_LLP';
//     APIVersion = 'v1.0', 'v2.0';
//     EntityName = 'events';
//     EntitySetName = 'insertEvent';
//     SourceTable = "Event Header";
//     DelayedInsert = true;
//     ODataKeyFields = "No.";

//     layout
//     {
//         area(Content)
//         {
//             repeater(GroupName)
//             {
//                 field("Event_No"; Rec."No.")
//                 {
//                     ApplicationArea = All;

//                     trigger OnValidate()
//                     var
//                         coursePlanningSetup: Record "Course Planning Setup";
//                         NoseriesBatch: Codeunit "No. Series - Batch";
//                         NoseriesMgt: Codeunit "No. Series - Setup";
//                         NOserMgt: Codeunit NoSeriesManagement;
//                     begin
//                         CoursePlanningSetup.get;
//                         CoursePlanningSetup.TestField("Event Nos.");
//                         if rec."No." = '' then rec."No.":=NOserMgt.GetNextNo(coursePlanningSetup."Event Nos.", WorkDate(), true);
//                     end;
//                 }
//                 field("CourseHeader"; Rec."Course Header")
//                 {
//                     Caption = 'course Header';
//                 }
//                 field("StartDate"; startDate)
//                 {
//                     Caption = 'Start Date';
//                     trigger OnValidate()
//                     var
//                         myInt: Integer;
//                     begin
//                         rec."Start Date" := startDate;
//                         rec."Day Name" := Format(rec."Start Date", 0, '<Weekday Text>');
//                     end;
//                 }
//                 field(Source; Rec.Source)
//                 {
//                     Caption = 'Source';
//                 }
//                 field(Delivery; Rec.Delivery)
//                 {
//                     Caption = 'Delivery';
//                 }
//                 field("DeliveryNature"; Rec."Delivery Nature")
//                 {
//                     Caption = 'Delivery Nature';
//                 }
//                 field(CountryCode; var_CountryCode)
//                 {
//                     Caption = 'CountryCode';
//                 }
//                 field("PostCode"; Rec."Post Code")
//                 {
//                     Caption = 'Postcode';
//                 }
//                 field(GroupLocationCode; var_GroupLocationCode)
//                 {
//                     Caption = 'Group Location Code';
//                 }
//                 field("TrainingCentre"; var_TrainingCentre)
//                 {
//                     Caption = 'Training Centre';
//                 }
//                 field(Technical; Rec.Technical)
//                 {
//                     Caption = 'Technical';
//                 }
//                 field(ZoomMeeting; Rec.ZoomMeeting)
//                 {
//                     Caption = 'Zoom Meeting';
//                 }
//                 field("MaxCandidates"; Rec."Max. Number of Candidates")
//                 {
//                     Caption = 'Max. Number of Candidates';
//                 }
//                 field(Week; Rec.Week)
//                 {
//                     Caption = 'week';
//                 }
//                 field(Bespoke; Rec.Bespoke)
//                 {
//                     Caption = 'Bespoke';
//                 }
//                 field("BespokeType"; Rec."Bespoke Type")
//                 {
//                     Caption = 'BespokeType';
//                 }

//                 field(InvigilatorCode; rec."Invigilator Code")
//                 {
//                     Caption = 'Invigilator Code';
//                 }
//                 field(ExpirationDate; Rec."Expiration Date")
//                 {
//                     Caption = 'Expiration Date';
//                 }
//                 field(Comments; Rec.Comments)
//                 {
//                 }
//                 field(Language; Rec.Language)
//                 {
//                     ApplicationArea = All;
//                 }
//                 field(AddressOnsite; Rec.AddressOnsite)
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("Booker_Contact_Name"; Rec."Booker Contact Name")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("Booker_Email"; Rec."Booker Email")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("Booker_Phone_Number"; Rec."Booker Phone Number")
//                 {
//                     ApplicationArea = All;
//                 }
//             }
//         }
//     }

//     trigger OnAfterGetCurrRecord()
//     begin
//         var_TrainingCentre := rec."Training Centre";
//         var_CompanyGroupCode := rec."Company Group Code";
//         var_GroupLocationCode := rec."Group Location Code";
//         var_CountryCode := rec."Country Code";
//     end;

//     trigger OnInsertRecord(BelowxRec: Boolean): Boolean
//     var
//         TrainingCenter: Record "Training Centre";
//         Country: record "Country/Region";
//     begin
//         rec.Validate("Event Status", rec."Event Status"::Provisional);
//         rec.Validate("Course Trainer", 'ZZUNA');

//         if not rec.Bespoke then Rec.Language := '';

//         if not TrainingCenter.get(rec."Course Header", var_TrainingCentre) then begin
//             TrainingCenter.init();
//             TrainingCenter.validate("Course Header", rec."Course Header");
//             TrainingCenter.validate("Location Code", var_TrainingCentre);
//             TrainingCenter.Insert();
//         end;
//         rec.validate("Training Centre", var_TrainingCentre);
//         rec.Validate("Group Location Code", var_GroupLocationCode);
//         rec.Validate("Country Code", var_CountryCode);
//         if Country.get(var_CountryCode) then
//             rec.Validate("Company Group Code", Country."Company Group Code");
//     end;

//     var
//         startDate: Date;
//         var_TrainingCentre: Code[20];
//         var_GroupLocationCode: code[20];
//         var_CountryCode: code[10];
//         var_CompanyGroupCode: code[10];


// }