// page 75001 EventDetails
// {
//     APIGroup = 'API';
//     APIPublisher = 'Direction_Software_LLP';
//     APIVersion = 'v1.0', 'v2.0';
//     ApplicationArea = All;
//     Caption = 'EventDetails';
//     DelayedInsert = true;
//     EntityName = 'EventDetails';
//     EntitySetName = 'EventDetail';
//     PageType = API;
//     SourceTable = "Event header";
//     ODataKeyFields = "No.";
//     DeleteAllowed = false;
//     InsertAllowed = false;
//     ModifyAllowed = false;

//     layout
//     {
//         area(Content)
//         {
//             repeater(Group)
//             {
//                 field(SystemId; Rec.SystemId)
//                 { }
//                 field("No"; rec."No.")
//                 { }
//                 field("Course_Header"; rec."Course Header")
//                 { }
//                 field(Description; rec.Description)
//                 { }
//                 field("Start_Date"; rec."Start Date")
//                 { }
//                 field("Event_Status"; rec."Event Status")
//                 { }
//                 field("Training_Centre"; rec."Training Centre")
//                 { }
//                 field("Group_Location_Code"; rec."Group Location Code")
//                 { }
//                 field("Country_Code"; rec."Country Code")
//                 { }
//                 field("Total_Seats_on_Course"; rec."Total Seats on Course")
//                 { }
//                 field("Confirmed_Seats"; rec."Confirmed Seats")
//                 { }
//                 field(EmailScheduler; recSalesperson."E-Mail")
//                 { }
//                 field(Address1; recLocation.Address)
//                 { }
//                 field(Postcode; recLocation."Post Code")
//                 { }
//                 field(City; recLocation.City)
//                 { }
//                 field("End_Date"; rec."End Date")
//                 { }
//                 field(Technical; rec.Technical)
//                 { }
//                 field(Delivery; rec.Delivery)
//                 { }
//                 field("Course_Trainer"; rec."Course Trainer")
//                 { }
//                 field("Available_Seats"; rec."Available Seats")
//                 { }
//                 field("Partial_Seats"; GetAvailableElements())
//                 { }
//                 field("Provisional_Seats"; rec."Provisional Seats")
//                 { }
//                 field(EI; rec.EI)
//                 { }
//                 field(ResourceEmail; recResource.Email)
//                 { }
//                 field(ProjectedRevenue; Round(ProjectedRevenue, 0.0001, '='))
//                 {
//                     DecimalPlaces = 0 : 2;
//                 }
//                 field(ResourceName; recResource.Name)
//                 { }
//                 field(ResourceType; recResource."Resource Type")
//                 { }
//                 field(CourseCategory; recCourseHeader.CourseCategory)
//                 { }
//                 field(EventComments; EventCommentsExist)
//                 { }
//                 field(ZoomMeeting; rec.ZoomMeeting)
//                 { }
//                 field("Shift_Timing"; rec."Shift Timing")
//                 { }
//                 field(UnpaidRevenue; UnpaidRevenue)
//                 {
//                     DecimalPlaces = 0 : 2;
//                 }
//                 field(LastModified; rec.LastModified)
//                 { }
//                 field(Bespoke; Rec.Bespoke)
//                 { }
//                 field("Bespoke_Course"; recCourseHeader.Bespoke)
//                 { }
//                 field("Bespoke_Type"; recCourseHeader."Bespoke Type")
//                 { }
//                 field("TKA_Course_ID"; recCourseHeader."TKA course ID")
//                 { }
//                 field("Header_Type"; recCourseHeader."Header Type")
//                 { }
//                 field(WeekendWeekday; recCourseHeader."Weekend/Weekday")
//                 { }
//                 field("Cancellation_Event_Details"; rec."Cancellation Event Details")
//                 { }
//                 field("Cancellation_Date"; rec."Cancellation Date")
//                 { }
//                 field("Key_Client"; rec."Local Trainer")
//                 { }
//                 field(PaidCount; GetPaidCount())
//                 { }
//                 field(UnpaidCount; Unpaidcount)
//                 { }
//                 field(AddressOnsite; rec.AddressOnsite)
//                 { }
//                 field("Booker_Contact_No"; rec."Booker Contact No.")
//                 { }
//                 field("Booker_Email"; rec."Booker Email")
//                 { }
//                 field("Booker_Phone_Number"; rec."Booker Phone Number")
//                 { }
//                 field("Booker_Contact_Name"; rec."Booker Contact Name")
//                 { }
//                 field("Trainer_ID_required"; rec."Trainer ID required")
//                 { }
//                 field("Post_Code"; rec."Post Code")
//                 { }
//                 field("Teams_URL"; rec."Teams URL")
//                 { }
//                 field("Teams_Room"; rec."Teams Room")
//                 { }
//                 field("MTM_Feedback_Link"; rec."MTM Feedback Link")
//                 { }
//                 field(LastModified1; rec.LastModified)
//                 { }
//                 field("Delivery_Nature"; Rec."Delivery Nature")
//                 { }
//                 field(ReasonCode; Rec.ReasonCode)
//                 { }
//                 field(Comments; Rec.Comments)
//                 { }
//                 field(CompanyName1; GetCustomerName())
//                 { }
//                 field("KeyAccount"; Rec."Key Account")
//                 { }
//                 field(SystemModifiedAt; Rec.SystemModifiedAt)
//                 { }
//                 field(SystemModifiedBy; Rec.SystemModifiedBy)
//                 { }
//             }
//         }

//     }
//     trigger OnAfterGetRecord()
//     var

//     begin
//         clearVariables();
//         if recSalesperson.get(rec."Resource Manager") then;
//         if recLocation.get(rec."Training Centre") then;
//         if recCourseTrainer.get(rec."Course Header", rec."Course Trainer") then
//             if recResource.get(recCourseTrainer."Course Trainer") then;
//         if recCourseHeader.get(rec."Course Header") then;

//         //
//         testRevenue.CalculateEventRev(rec."No.");
//         testUnpaid.CalculateAllUnpaidRevEvent(rec."No.");
//         recEventHeader := rec;
//         recEventHeader.CalculateRevenueGBPOneEvent();
//         commit;
//         ProjectedRevenue := recEventHeader.ProjectedRevenue;

//         recAllUnpaidRevenue.SetCurrentKey("Event No");
//         recAllUnpaidRevenue.SetFilter("Event No", '%1', Rec."No.");
//         recAllUnpaidRevenue.SetLoadFields("UNPAID Amount");
//         if recAllUnpaidRevenue.FindFirst() then begin
//             Unpaidcount := recAllUnpaidRevenue.Count();
//             repeat
//                 UnpaidRevenue += recAllUnpaidRevenue."UNPAID Amount";
//             until recAllUnpaidRevenue.Next() = 0;
//         end;
//     end;

//     local procedure clearVariables()
//     begin
//         recSalesperson.Reset();
//         recLocation.Reset();
//         recCourseTrainer.Reset();
//         recResource.Reset();
//         recCourseHeader.Reset();
//         clear(recEventHeader);
//         Clear(ProjectedRevenue);
//         Clear(Unpaidcount);
//         Clear(UnpaidRevenue);
//         recAllUnpaidRevenue.Reset();
//     end;

//     local procedure EventCommentsExist(): Boolean
//     var
//         recEventComments: Record "Event Comments";
//     begin
//         recEventComments.Reset();
//         recEventComments.SetFilter("No.", '%1', Rec."No.");
//         exit(not recEventComments.IsEmpty)
//     end;

//     local procedure GetAvailableElements(): Integer
//     var
//         recEventLine: record "Event Line";
//     begin
//         recEventLine.SetCurrentKey("Event No.");
//         recEventLine.SETRANGE("Event No.", rec."No.");
//         recEventLine.CALCFIELDS("Elements Booked", "Elements Available");
//         recEventLine.SETFILTER("Elements Booked", '>%1', 0);
//         recEventLine.SETFILTER("Elements Available", '>%1', 0);
//         exit(recEventLine.count());
//     end;

//     local procedure GetCustomerName(): text
//     var
//         recCustomer: record Customer;
//         recSalesInvLine: record "Sales Invoice Line";
//     begin
//         recSalesInvLine.Reset();
//         recSalesInvLine.SetCurrentKey("Event Header");
//         recSalesInvLine.SetFilter("Event Header", Rec."No.");
//         recSalesInvLine.SetLoadFields("Sell-to Customer No.");
//         if recSalesInvLine.FindFirst() then
//             if recCustomer.Get(recSalesInvLine."Sell-to Customer No.") then
//                 exit(recCustomer.Name)
//             else
//                 exit('')
//     end;

//     local procedure GetPaidCount(): Integer
//     var
//         recEventDetEntry: record "Event Detailed Entry";
//     begin
//         recEventDetEntry.Reset();
//         recEventDetEntry.SetCurrentKey("Event No.", "Payment Status");
//         recEventDetEntry.SETFILTER(recEventDetEntry."Event No.", rec."No.");
//         recEventDetEntry.SETFILTER(recEventDetEntry."Payment Status", 'PAID');
//         IF recEventDetEntry.FindFirst() THEN
//             exit(recEventDetEntry.Count)
//         else
//             exit(0)
//     end;

//     var
//         recSalesperson: record "Salesperson/Purchaser";
//         recLocation: record Location;
//         recCourseTrainer: Record "Course Trainer";
//         recResource: Record Resource;
//         recCourseHeader: Record "Course Header";
//         testRevenue: codeunit testrevenue;
//         testUnpaid: codeunit AllunpaidRevenue;
//         recEventHeader: record "Event Header" temporary;
//         ProjectedRevenue: decimal;
//         recAllUnpaidRevenue: record "All Unpaid Revenue Temp";
//         Unpaidcount: Integer;
//         UnpaidRevenue: Decimal;
// }