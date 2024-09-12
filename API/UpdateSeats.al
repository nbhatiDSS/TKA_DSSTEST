// page 61003 UpdateSeats
// {
//     PageType = API;
//     Caption = 'Update Seat';
//     APIGroup = 'API';
//     APIPublisher = 'Direction_Software_LLP';
//     APIVersion = 'v2.0';
//     EntityName = 'events';
//     EntitySetName = 'updateSeat';
//     SourceTable = "Event Header";
//     SourceTableTemporary = true;
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
//                 }
//                 field(Quantity; Quantity)
//                 {
//                     ApplicationArea = All;
//                 }
//             }
//         }
//     }

//     trigger OnInsertRecord(BelowxRec: Boolean): Boolean
//     var
//         eventLine: record "Event Line";
//         EventDetailedEntry: record "Event Detailed Entry";
//         EventHeader: Record "Event Header";
//         courseHeader: record "Course Header";
//         TempDate: date;
//         PrevDuration: Decimal;
//         CourseElements: Record "Course Elements";
//         CoursePlanningSetup: record "Course Planning Setup";
//         TempCourseElements: record "Course Elements";
//         TrainerEntryDone: boolean;
//         i: Integer;
//         EventTrainerEntry: record "Event Trainer Entry";
//     begin
//         EventHeader.get(Rec."No.");
//         courseHeader.get(EventHeader."Course Header");
//         CoursePlanningSetup.Get();
//         while i < Quantity do begin
//             //TrainerEntryDone := FALSE;
//             Clear(EventLine);
//             EventLine.Init();
//             EventLine."Event No." := EventHeader."No.";
//             EventLine."Line No." := 0;
//             EventLine."Training Location" := EventHeader."Training Centre";
//             EventLine."Course Header" := EventHeader."Course Header";
//             EventLine.Status := EventLine.Status::Available;
//             EventLine."G/L Account No." := courseHeader."G/L Account No.";
//             EventLine.Insert(true);

//             TempDate := EventHeader."Start Date";
//             PrevDuration := 0;
//             CourseElements.Reset;
//             CourseElements.SetCurrentKey("Element Sequence");
//             CourseElements.SetRange("Course Header", EventHeader."Course Header");
//             if CourseElements.FindFirst then
//                 repeat
//                     //MESSAGE (CourseElements."Course Header");
//                     Clear(EventDetailedEntry);
//                     EventDetailedEntry.Init();
//                     EventDetailedEntry."Event No." := EventLine."Event No.";
//                     EventDetailedEntry."Line No." := EventLine."Line No.";
//                     EventDetailedEntry.Status := EventDetailedEntry.Status::Available;
//                     EventDetailedEntry."Element Price Incl. VAT" := CourseElements."Element Price Inc. VAT";
//                     EventDetailedEntry."Course Header" := CourseElements."Course Header";
//                     EventDetailedEntry."Element Code" := CourseElements."Element Code";
//                     EventDetailedEntry."Course Trainer" := EventHeader."Course Trainer";
//                     //DOC TKA_201106 -

//                     TempCourseElements.SetRange("Element Code", CourseElements."Element Code");
//                     if TempCourseElements.FindFirst then
//                         EventDetailedEntry."Course Trainer" := EventHeader."Invigilator Code";

//                     //DOC TKA_201106 +
//                     EventDetailedEntry."Training Date" := TempDate;
//                     EventDetailedEntry."Training Location" := EventHeader."Training Centre";
//                     if (PrevDuration + CourseElements."Duration (Hours)") >= CoursePlanningSetup."Hours in a Day" then
//                         TempDate := TempDate + 1;

//                     PrevDuration := CourseElements."Duration (Hours)";
//                     EventDetailedEntry.Insert(true);

//                     if not TrainerEntryDone then begin
//                         EventTrainerEntry.Init;
//                         EventTrainerEntry.TransferFields(EventDetailedEntry);
//                         EventTrainerEntry."Half-Day" := CourseElements."Half-Day";
//                         EventTrainerEntry."Country Code" := EventHeader."Country Code";
//                         EventTrainerEntry."Company Group Code" := EventHeader."Company Group Code";
//                         EventTrainerEntry.Insert(true);
//                     end;
//                 until CourseElements.Next = 0;
//             EventHeader."End Date" := EventDetailedEntry."Training Date";
//             EventHeader.Modify;
//             TrainerEntryDone := true;
//             i := i + 1;
//         end;
//     end;

//     var
//         Quantity: Integer;
// }

