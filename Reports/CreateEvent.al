// report 70203 "Create Event - bulk"
// {
//     ApplicationArea = All;
//     Caption = 'Create Event - Mass';
//     // UsageCategory = ReportsAndAnalysis;
//     ProcessingOnly = true;
//     dataset
//     {
//         dataitem(CourseHeader; "Course Header")
//         {
//             DataItemTableView = SORTING(Code);

//             dataitem(AttendeeLoop; Integer)
//             {
//                 DataItemTableView = SORTING(Number);
//                 trigger OnPreDataItem()
//                 var
//                     myInt: Integer;
//                 begin
//                     SETRANGE(Number, 1, MaxCandidates);
//                     CoursePlanningSetup.GET;
//                     CoursePlanningSetup.TESTFIELD("Hours in a Day");
//                     TrainerEntryDone := FALSE;
//                 end;

//                 trigger OnAfterGetRecord()
//                 var
//                     CourseElements: Record 50003;
//                 begin
//                     CLEAR(EventLine);
//                     EventLine.VALIDATE("Event No.", EventHeader."No.");
//                     EventLine."Line No." := 0;
//                     EventLine.VALIDATE("Training Location", EventHeader."Training Centre");
//                     EventLine.VALIDATE("Course Header", EventHeader."Course Header");
//                     EventLine.VALIDATE(Status, EventLine.Status::Available);
//                     EventLine.VALIDATE("G/L Account No.", GetPostingAccount(EventLine."Course Header"));
//                     EventLine.INSERT(TRUE);
//                     TempDate := EventHeader."Start Date";
//                     PrevDuration := 0;
//                     CourseElements.RESET;
//                     CourseElements.SETCURRENTKEY("Element Sequence");
//                     CourseElements.SETRANGE("Course Header", EventHeader."Course Header");
//                     IF CourseElements.FINDFIRST THEN
//                         REPEAT
//                             CLEAR(EventDetailedEntry);
//                             EventDetailedEntry.VALIDATE("Event No.", EventLine."Event No.");
//                             EventDetailedEntry.VALIDATE("Line No.", EventLine."Line No.");
//                             EventDetailedEntry.Status := EventDetailedEntry.Status::Available;
//                             EventDetailedEntry.VALIDATE("Element Price Incl. VAT", CourseElements."Element Price Inc. VAT");
//                             EventDetailedEntry.VALIDATE("Course Header", CourseElements."Course Header");
//                             EventDetailedEntry.VALIDATE("Element Code", CourseElements."Element Code");
//                             EventDetailedEntry.VALIDATE("Course Trainer", EventHeader."Course Trainer");
//                             //DOC TKA_201106 -
//                             IF TutorCode <> InvigilatorCode THEN BEGIN
//                                 TempCourseElements.SETRANGE("Element Code", CourseElements."Element Code");
//                                 IF TempCourseElements.FINDFIRST THEN
//                                     EventDetailedEntry.VALIDATE("Course Trainer", InvigilatorCode);
//                             END;
//                             //DOC TKA_201106 +
//                             EventDetailedEntry.VALIDATE("Training Date", TempDate);
//                             EventDetailedEntry.VALIDATE("Training Location", EventHeader."Training Centre");
//                             IF (PrevDuration + CourseElements."Duration (Hours)") >= CoursePlanningSetup."Hours in a Day" THEN
//                                 TempDate := TempDate + 1;
//                             PrevDuration := CourseElements."Duration (Hours)";
//                             EventDetailedEntry.INSERT(TRUE);
//                             IF NOT TrainerEntryDone THEN BEGIN
//                                 EventTrainerEntry.INIT;
//                                 EventTrainerEntry.TRANSFERFIELDS(EventDetailedEntry);
//                                 EventTrainerEntry."Half-Day" := CourseElements."Half-Day";
//                                 EventTrainerEntry."Country Code" := EventHeader."Country Code";
//                                 EventTrainerEntry."Company Group Code" := EventHeader."Company Group Code";
//                                 EventTrainerEntry.INSERT(TRUE);
//                             END;
//                         UNTIL CourseElements.NEXT = 0;
//                     EventHeader.VALIDATE("End Date", EventDetailedEntry."Training Date");
//                     EventHeader.MODIFY;
//                     TrainerEntryDone := TRUE;
//                 end;
//             }
//             trigger OnPreDataItem()
//             var
//                 CourseElements: Record 50003;
//             begin

//                 SETRANGE(Code, CourseCode);
//                 IF COUNT <> 1 THEN
//                     ERROR(Error001);
//                 IF MaxCandidates <= 0 THEN
//                     ERROR(Error003);
//                 IF TutorCode = '' THEN
//                     ERROR(Error005);

//             end;

//             trigger OnAfterGetRecord()
//             var
//                 DimValue: Record 349;
//             begin
//                 TESTFIELD("G/L Account No.");

//                 CLEAR(EventHeader);
//                 //DSS-- Manual Event No ------------------------
//                 IF NOT AutoEvent THEN BEGIN
//                     EventHeader.INIT;
//                     EventHeader."No." := "EventNo.";
//                 END;
//                 //DSS-- Manual Event No ------------------------
//                 EventHeader.INSERT(TRUE);
//                 EventHeader.VALIDATE("Course Header", CourseHeader.Code);
//                 EventHeader.VALIDATE("Training Centre", EventTrainingCentre);
//                 EventHeader.VALIDATE(Week, Week);
//                 EventHeader.VALIDATE("Max. Number of Candidates", MaxCandidates);
//                 EventHeader.VALIDATE("Start Date", StartDate);
//                 EventHeader.VALIDATE(Technical, Tailored);
//                 EventHeader.VALIDATE(Source, Source);
//                 EventHeader.VALIDATE(Delivery, Deliver);
//                 EventHeader.VALIDATE("Start Date", StartDate);


//                 EventHeader.VALIDATE("Event Price Incl. VAT", CourseHeader."Course Price Incl. VAT");

//                 //DOC TKA_201106 -
//                 EventHeader.VALIDATE("Event Price Excl. VAT", CourseHeader."Course Price Excl. VAT");
//                 EventHeader.VALIDATE("Resource Manager", EventCoordinator);
//                 EventHeader.VALIDATE("Invigilator Code", InvigilatorCode);
//                 //DOC TKA_201106 +

//                 //DSS-- E-Learning -------------------
//                 EventHeader.VALIDATE("E-Learning", "E-Learning");
//                 IF ExpDate <> 0D THEN
//                     EventHeader.VALIDATE("Expiration Date", ExpDate)
//                 ELSE
//                     EventHeader.VALIDATE("Expiration Date", EventHeader."End Date");

//                 eventheader.Validate("Delivery Nature", eventheader."Delivery Nature"::Public);
//                 //DSS-- E-Learning -------------------

//                 EventHeader.VALIDATE("Course Trainer", TutorCode);
//                 EventHeader.VALIDATE("Event Status", EveStatus);
//                 EventHeader.MODIFY(TRUE);
//                 IF NOT DimValue.GET('EVENT', EventHeader."No.") THEN BEGIN
//                     DimValue.INIT;
//                     DimValue."Dimension Code" := 'EVENT';
//                     DimValue.Code := EventHeader."No.";
//                     DimValue.INSERT;
//                 END;

//                 //DOC TKA_201106 -
//                 EventActionCode.Refresh(EventHeader."No.");
//                 //DOC TKA_201106 +

//             end;

//         }

//     }
//     requestpage
//     {
//         layout
//         {
//             area(content)
//             {
//                 group(GroupName)
//                 {
//                     field("Course Header"; CourseCode)
//                     {
//                         ApplicationArea = All;
//                         trigger OnLookup(Var text: Text): Boolean
//                         var
//                             myInt: Integer;
//                         begin

//                             CourseHeader.RESET;
//                             IF Page.RUNMODAL(0, CourseHeader) = ACTION::LookupOK THEN BEGIN
//                                 CourseCode := CourseHeader.Code;
//                             END ELSE BEGIN
//                                 CourseCode := '';
//                                 EventTrainingCentre := '';
//                                 StartDate := 0D;
//                                 Week := '';
//                                 MaxCandidates := 0;
//                                 TutorCode := '';
//                             END;
//                             //DOC TKA_201106 -
//                             TempCourseElements.RESET;
//                             TempCourseElements.DELETEALL;
//                             //DOC TKA_201106 +
//                         end;
//                     }
//                     field("Course Name"; GetTrainingCourseName(CourseCode))
//                     {
//                         ApplicationArea = All;
//                     }
//                     field("Event Start Date"; StartDate)
//                     {
//                         ApplicationArea = All;
//                         trigger OnAssistEdit()
//                         var
//                             //Vaibhav   lFrmCalendar: Page 50059;
//                             rEventWeek: Record 50012;
//                             rCourseElements: Record 50003;
//                             rCourseHeader: Record 50002;
//                         begin
//                             IF CourseCode <> '' THEN BEGIN
//                                 rCourseHeader.RESET;
//                                 rCourseHeader.GET(CourseCode);
//                             END ELSE
//                                 ERROR(Error002);

//                         end;



//                         trigger OnValidate()
//                         var
//                             EventWeek: Record 50012;
//                             rEventWeek: Record 50012;
//                             rCourseElements: Record 50003;
//                             rCourseHeader: Record 50002;
//                         begin
//                             IF CourseCode <> '' THEN BEGIN
//                                 rCourseHeader.RESET;
//                                 rCourseHeader.GET(CourseCode);
//                             END ELSE
//                                 ERROR(Error002);

//                             EventWeek.RESET;
//                             EventWeek.SETRANGE(Year, DATE2DMY(StartDate, 3));
//                             EventWeek.SETFILTER("Week Start Date", '..%1', StartDate);
//                             EventWeek.SETFILTER("Week End Date", '%1..', StartDate);
//                             IF EventWeek.FINDFIRST THEN
//                                 Week := EventWeek."Week Dimension Code"
//                             ELSE
//                                 Week := '';

//                             EndDate := StartDate - 1;
//                             rCourseElements.RESET;
//                             rCourseElements.SETCURRENTKEY("Element Sequence");
//                             rCourseElements.SETRANGE("Course Header", rCourseHeader.Code);
//                             IF rCourseElements.FINDFIRST THEN
//                                 REPEAT
//                                     EndDate := EndDate + 1;
//                                     NoofDays += 1;
//                                 UNTIL rCourseElements.NEXT = 0;
//                         end;
//                     }
//                     field("Week Dimension"; Week)
//                     {
//                         ApplicationArea = All;
//                     }
//                     field("Group Location"; GroupLocation)
//                     {
//                         ApplicationArea = All;
//                         trigger OnLookup(var text: Text): Boolean
//                         VAR
//                             CourseHeader: Record 50002;
//                         BEGIN
//                             GroupLocation := '';
//                             IF CourseCode <> '' THEN BEGIN
//                                 Location.RESET;
//                                 Location.SETRANGE("Use for Grouping", TRUE);
//                                 IF page.RUNMODAL(0, Location) = ACTION::LookupOK THEN
//                                     GroupLocation := Location.Code;
//                             END ELSE
//                                 ERROR(Error002);
//                         END;
//                     }
//                     field("Training Centre"; EventTrainingCentre)
//                     {
//                         ApplicationArea = All;
//                         trigger OnValidate()
//                         var
//                             myInt: Integer;
//                         begin
//                             TrainingCentre.RESET;
//                             TrainingCentre.GET(CourseCode, EventTrainingCentre);
//                             TrainingCentre.TESTFIELD("Max. Number of Attendees");
//                             TrainingCentre.TESTFIELD("Min. Number of Attendees");
//                             MaxCandidates := TrainingCentre."Max. Number of Attendees";
//                         end;

//                         trigger OnLookup(var text: Text): Boolean
//                         var
//                             CourseHeader: Record 50002;
//                             rCourseHeader: Record 50002;
//                             rCourseElements: Record 50003;
//                             rLocation: Record 14;
//                             rTrainingCentre: Record 50009;
//                             rCoursePlanningSetup: Record 50000;
//                             rVendor: Record 23;
//                             rActionCode: Record 50010;
//                             rLocationCostBuffer: Record 50059;
//                             rEventDetailedEntry: Record 50008;
//                             tLocationCostBuffer: Record 50059 TEMPORARY;
//                             //Vaibhav    fTrainingCentreList: Page 50008;
//                             //Vaibhav    fPurchasePricesCentreList: Page 50263;
//                             cPurchPriceCalcMgt: Codeunit 7010;
//                             cCourseMgt: Codeunit 50001;
//                             Selection: Integer;
//                             lText001: Label '&Training Centre,Training Centre by &Cost';
//                             ikey: Integer;
//                             tDateFilter: Text[30];
//                             bHalfDay: Boolean;
//                             bOverLap: Boolean;
//                             dHalfDayDate: Date;
//                         begin
//                             EventTrainingCentre := '';

//                             Selection := STRMENU(lText001);
//                             IF Selection = 0 THEN
//                                 EXIT;

//                             rCourseHeader.RESET;
//                             rCourseHeader.GET(CourseCode);
//                             //rLocation.GET(EventHeader."Training Centre");

//                             IF Selection IN [1] THEN BEGIN
//                                 rTrainingCentre.RESET;
//                                 rTrainingCentre.SETRANGE("Course Header", rCourseHeader.Code);
//                                 rTrainingCentre.SETRANGE("Group Location Code", GroupLocation);

//                             END;

//                             IF Selection IN [2] THEN BEGIN
//                                 rCoursePlanningSetup.GET;
//                                 rTrainingCentre.SETFILTER("Course Header", rCourseHeader.Code);
//                                 rTrainingCentre.SETFILTER("Group Location Code", GroupLocation);
//                                 IF NOT rTrainingCentre.ISEMPTY THEN BEGIN
//                                     IF rTrainingCentre.FINDFIRST THEN
//                                         REPEAT
//                                             rLocation.GET(rTrainingCentre."Location Code");
//                                             IF rLocation."Vendor No." <> '' THEN BEGIN
//                                                 rVendor.GET(rLocation."Vendor No.");
//                                                 tLocationCostBuffer.INIT;
//                                                 tLocationCostBuffer.TRANSFERFIELDS(rLocation, TRUE);
//                                                 //Vaibhav    cPurchPriceCalcMgt.FindPurchCost(rVendor, tLocationCostBuffer, StartDate, rCoursePlanningSetup."Venue Item No.");
//                                                 IF ((rLocation."Venue Cost Action Code" <> '') AND (rActionCode.GET(rLocation."Venue Cost Action Code"))) THEN BEGIN
//                                                     rCourseElements.SETRANGE("Course Header", rCourseHeader.Code);
//                                                     rCourseElements.FINDFIRST;
//                                                     REPEAT
//                                                         IF rActionCode."Per Contact" THEN BEGIN
//                                                             IF NOT rCourseElements."Half-Day" THEN BEGIN
//                                                                 tLocationCostBuffer."Expected Max.Hire Cost" := tLocationCostBuffer."Expected Max.Hire Cost" +
//                                                                   (tLocationCostBuffer."Direct Unit Cost (Per Contact)" * rTrainingCentre."Max. Number of Attendees");
//                                                             END ELSE BEGIN
//                                                                 tLocationCostBuffer."Expected Max.Hire Cost" := tLocationCostBuffer."Expected Max.Hire Cost" +
//                                                                   (tLocationCostBuffer."Direct Unit Cost (Half-Day)" * rTrainingCentre."Max. Number of Attendees");
//                                                             END;
//                                                         END ELSE BEGIN
//                                                             IF NOT rCourseElements."Half-Day" THEN BEGIN
//                                                                 tLocationCostBuffer."Expected Max.Hire Cost" := tLocationCostBuffer."Expected Max.Hire Cost" +
//                                                                                                             tLocationCostBuffer."Direct Unit Cost";
//                                                             END ELSE BEGIN
//                                                                 tLocationCostBuffer."Expected Max.Hire Cost" := tLocationCostBuffer."Expected Max.Hire Cost" +
//                                                                                                                 tLocationCostBuffer."Direct Unit Cost (Half-Day)";
//                                                             END;
//                                                         END;
//                                                     UNTIL rCourseElements.NEXT = 0;
//                                                 END;
//                                             END ELSE
//                                                 tLocationCostBuffer.TRANSFERFIELDS(rLocation, TRUE);
//                                             tLocationCostBuffer.INSERT;
//                                         UNTIL rTrainingCentre.NEXT = 0;
//                                     rLocationCostBuffer.LOCKTABLE;
//                                     IF NOT rLocationCostBuffer.FINDLAST THEN
//                                         ikey := 1
//                                     ELSE
//                                         ikey := rLocationCostBuffer.Key + 1;
//                                     IF tLocationCostBuffer.FINDFIRST THEN
//                                         REPEAT
//                                             rLocationCostBuffer.TRANSFERFIELDS(tLocationCostBuffer);
//                                             rLocationCostBuffer.Key := ikey;
//                                             rLocationCostBuffer.INSERT;
//                                         UNTIL tLocationCostBuffer.NEXT = 0;
//                                     COMMIT;

//                                     rLocationCostBuffer.SETCURRENTKEY("Expected Hire Cost");
//                                     rLocationCostBuffer.SETRANGE(Key, ikey);
//                                     rLocationCostBuffer.SETRANGE(Key, ikey);
//                                     rLocationCostBuffer.DELETEALL;
//                                 END;
//                             END;


//                             rCourseElements.RESET;
//                             rCourseElements.SETCURRENTKEY("Element Sequence");
//                             rCourseElements.SETRANGE("Course Header", rCourseHeader.Code);
//                             rCourseElements.SETRANGE("Half-Day", TRUE);
//                             IF NOT rCourseElements.ISEMPTY THEN BEGIN
//                                 rCourseElements.SETRANGE("Half-Day");
//                                 EndDate := StartDate - 1;
//                                 REPEAT
//                                     IF NOT rCourseElements."Half-Day" THEN
//                                         EndDate := EndDate + 1
//                                     ELSE BEGIN
//                                         dHalfDayDate := EndDate + 1;
//                                         bHalfDay := TRUE;
//                                     END;
//                                 UNTIL rCourseElements.NEXT = 0;
//                                 tDateFilter := FORMAT(StartDate) + '..' + FORMAT(EndDate);
//                             END ELSE
//                                 tDateFilter := FORMAT(StartDate) + '..' + FORMAT(EndDate);

//                             IF NOT cCourseMgt.OkToBookLocation(EventTrainingCentre, tDateFilter, bHalfDay, dHalfDayDate, bOverLap) THEN
//                                 ERROR('Training Centre %1 is already booked between %2 and %3!', EventTrainingCentre, StartDate, EndDate);

//                             IF bOverLap THEN
//                                 IF NOT CONFIRM('There is an Overlap on Date: %1 for Training Centre: %2, Check Before Confirming',
//                                                FALSE, FORMAT(tDateFilter), EventTrainingCentre) THEN
//                                     ERROR('Action Cancelled by User');

//                         end;
//                     }
//                     field("Training Centre Name"; GetTrainingCentreName(CourseCode, EventTrainingCentre))
//                     {
//                         ApplicationArea = All;
//                     }
//                     field(Technical; Tailored)
//                     {
//                         ApplicationArea = All;
//                     }
//                     field("Event Source"; Source)
//                     {
//                         ApplicationArea = All;
//                     }
//                     field("Event Delivery"; Deliver)
//                     {
//                         ApplicationArea = All;
//                         trigger OnLookup(var text: text): Boolean
//                         VAR
//                             CourseHeader: Record 50002;
//                         BEGIN
//                             GroupLocation := '';
//                             IF CourseCode <> '' THEN BEGIN
//                                 Location.RESET;
//                                 Location.SETRANGE("Use for Grouping", TRUE);
//                                 IF Page.RUNMODAL(0, Location) = ACTION::LookupOK THEN
//                                     GroupLocation := Location.Code;
//                             END ELSE
//                                 ERROR(Error002);
//                         END;
//                     }
//                     field("Max. Number of Attendees"; MaxCandidates)
//                     {
//                         ApplicationArea = All;
//                         trigger OnValidate()
//                         var
//                             myInt: Integer;
//                         begin
//                             TrainingCentre.RESET;
//                             TrainingCentre.GET(CourseCode, EventTrainingCentre);
//                             IF NOT (MaxCandidates IN [TrainingCentre."Min. Number of Attendees" .. TrainingCentre."Max. Number of Attendees"]) THEN
//                                 ERROR(STRSUBSTNO(Error004, TrainingCentre."Min. Number of Attendees", TrainingCentre."Max. Number of Attendees"));
//                         end;
//                     }
//                     field("Course Tutor"; TutorCode)
//                     {
//                         ApplicationArea = All;
//                         trigger OnValidate()
//                         var
//                             myInt: Integer;
//                         begin
//                             InvigilatorCode := TutorCode;

//                             //DOC TKA_201106 -
//                             TempCourseElements.RESET;
//                             TempCourseElements.DELETEALL;
//                             //DOC TKA_201106 +
//                         end;

//                         trigger OnLookup(var text: Text): Boolean
//                         var
//                             rCourseHeader: Record 50002;
//                             rCourseElements: Record 50003;
//                             rPurchasePrice: Record 7012;
//                             rCourseTrainer: Record 50013;
//                             rLocation: Record 14;
//                             cCourseMgt: Codeunit 50001;
//                             //Vaibhav fPurchasePrices: Page 50264;
//                             //Vaibhav fTrainerList: Page 50016;
//                             Selection: Integer;
//                             lText001: Label '&Trainer List,Trainer by &Cost';
//                         begin
//                             IF StartDate = 0D THEN
//                                 ERROR(Error007);
//                             IF EventTrainingCentre = '' THEN
//                                 ERROR(Error008);

//                             Selection := STRMENU(lText001);
//                             IF Selection = 0 THEN
//                                 EXIT;

//                             IF CourseCode <> '' THEN BEGIN
//                                 rCourseHeader.RESET;
//                                 rCourseHeader.GET(CourseCode);

//                                 rLocation.GET(EventTrainingCentre);

//                                 EndDate := StartDate - 1;
//                                 rCourseElements.RESET;
//                                 rCourseElements.SETCURRENTKEY("Element Sequence");
//                                 rCourseElements.SETRANGE("Course Header", rCourseHeader.Code);
//                                 IF rCourseElements.FINDFIRST THEN
//                                     REPEAT
//                                         EndDate := EndDate + 1;
//                                     UNTIL rCourseElements.NEXT = 0;

//                                 IF Selection IN [1] THEN BEGIN
//                                     rCourseTrainer.RESET;
//                                     rCourseTrainer.SETRANGE("Course Header", CourseCode);

//                                 END;

//                                 IF Selection IN [2] THEN BEGIN
//                                     rPurchasePrice.SETCURRENTKEY("Direct Unit Cost", "Item No.", "Ending Date");
//                                     rPurchasePrice.SETRANGE("Item No.", rCourseHeader."Course Item No.");
//                                     rPurchasePrice.SETFILTER("Ending Date", '%1|>=%2', 0D, StartDate);
//                                     rPurchasePrice.SETFILTER("Location Code", '%1|%2|%3', '', rLocation.Code,
//                                                               rLocation."Group Location Code");
//                                 END;

//                             end;
//                         End;

//                     }
//                     field("Tutor Name"; TutorName)
//                     {
//                         ApplicationArea = All;
//                     }
//                     field("Event Co-ordinator"; EventCoordinator)
//                     {
//                         ApplicationArea = All;
//                         trigger OnLookup(var text: Text): Boolean
//                         VAR
//                             CourseTrainer: Record 50013;
//                         BEGIN

//                             IF CourseCode <> '' THEN BEGIN
//                                 CourseTrainer.RESET;
//                                 CourseTrainer.SETRANGE("Course Header", CourseCode);
//                                 IF Page.RUNMODAL(0, CourseTrainer) = ACTION::LookupOK THEN BEGIN
//                                     TutorCode := CourseTrainer."Course Trainer";
//                                 END ELSE BEGIN
//                                     TutorCode := '';
//                                 END;
//                             END ELSE
//                                 ERROR(Error002);
//                         END;

//                     }
//                     field("Event Co-ordinator Name"; GetEventCoordinatorName())
//                     {
//                         ApplicationArea = All;
//                     }
//                     field("Invigilator Code"; InvigilatorCode)
//                     {
//                         ApplicationArea = All;

//                         trigger OnLookup(var text: Text): Boolean
//                         VAR
//                             CourseTrainer: Record 50013;
//                             rCourseHeader: Record 50002;
//                             rCourseElements: Record 50003;
//                             rPurchasePrice: Record 7012;
//                             rCourseTrainer: Record 50013;
//                             rLocation: Record 14;
//                             cCourseMgt: Codeunit 50001;
//                             //Vaibhav   fPurchasePrices: Page 50264;
//                             //Vaibhav    fTrainerList: Page 50016;
//                             Selection: Integer;
//                             lText001: label '&Trainer List,Trainer by &Cost';
//                             tFilterDate: Text[30];
//                         BEGIN

//                             IF TempCourseElements.ISEMPTY THEN
//                                 ERROR(Error009);

//                             Selection := STRMENU(lText001);
//                             IF Selection = 0 THEN
//                                 EXIT;

//                             IF CourseCode <> '' THEN BEGIN
//                                 rCourseHeader.RESET;
//                                 rCourseHeader.GET(CourseCode);

//                                 rLocation.GET(EventTrainingCentre);

//                                 EndDate := StartDate - 1;
//                                 rCourseElements.RESET;
//                                 rCourseElements.SETCURRENTKEY("Element Sequence");
//                                 rCourseElements.SETRANGE("Course Header", rCourseHeader.Code);

//                                 IF rCourseElements.FINDFIRST THEN
//                                     REPEAT
//                                         EndDate := EndDate + 1;
//                                         TempCourseElements.SETRANGE("Element Code", rCourseElements."Element Code");
//                                         IF TempCourseElements.FINDFIRST THEN BEGIN
//                                             IF tFilterDate <> '' THEN
//                                                 tFilterDate := tFilterDate + '|' + FORMAT(EndDate)
//                                             ELSE
//                                                 tFilterDate := FORMAT(EndDate);
//                                         END;
//                                     UNTIL rCourseElements.NEXT = 0;


//                                 IF Selection IN [1] THEN BEGIN
//                                     rCourseTrainer.RESET;
//                                     rCourseTrainer.SETRANGE("Course Header", CourseCode);

//                                     //DOC TKA_201106 -
//                                     TempCourseElements.RESET;
//                                     TempCourseElements.DELETEALL;
//                                     //DOC TKA_201106 +
//                                 END;
//                             END;

//                             IF Selection IN [2] THEN BEGIN
//                                 rPurchasePrice.SETCURRENTKEY("Direct Unit Cost", "Item No.", "Ending Date");
//                                 rPurchasePrice.SETRANGE("Item No.", rCourseHeader."Course Item No.");
//                                 rPurchasePrice.SETFILTER("Ending Date", '%1|>=%2', 0D, StartDate);
//                                 rPurchasePrice.SETFILTER("Location Code", '%1|%2|%3', '', rLocation.Code,
//                                                           rLocation."Group Location Code");


//                                 //DOC TKA_201106 -
//                                 TempCourseElements.RESET;
//                                 TempCourseElements.DELETEALL;
//                                 //DOC TKA_201106 +
//                             END;
//                         END;



//                     }
//                     field("Invigilator Name"; GetCourseTrainerName(CourseCode, InvigilatorCode))
//                     {
//                         ApplicationArea = All;
//                     }


//                 }
//             }
//         }
//         actions
//         {
//             area(processing)
//             {
//                 action(Select)
//                 {
//                     ApplicationArea = All;
//                     Image = Approve;

//                     trigger OnAction()

//                     var
//                         lCourseElements: Record 50003;
//                         lBookNow: Boolean;
//                     begin
//                         TempCourseElements.RESET;
//                         TempCourseElements.DELETEALL;
//                         IF TutorCode <> '' THEN BEGIN
//                             lCourseElements.SETRANGE("Course Header", CourseCode);
//                             lCourseElements.SETFILTER("Exam Type", '<>%1', lCourseElements."Exam Type"::" ");
//                             IF lCourseElements.FINDFIRST THEN BEGIN
//                                 REPEAT
//                                     TempCourseElements.INIT;
//                                     TempCourseElements.TRANSFERFIELDS(lCourseElements);
//                                     TempCourseElements.INSERT;
//                                 UNTIL lCourseElements.NEXT = 0;
//                             END;
//                             lBookNow := (page.RUNMODAL(Page::"Event Elements (Booking)", TempCourseElements) = ACTION::LookupOK);
//                             IF lBookNow THEN BEGIN
//                                 TempCourseElements.SETRANGE(Select, TRUE);
//                                 IF NOT TempCourseElements.FINDFIRST THEN BEGIN
//                                     TempCourseElements.RESET;
//                                     TempCourseElements.DELETEALL;
//                                     ERROR('No Exam Days selected!');
//                                 END;
//                             END ELSE BEGIN
//                                 TempCourseElements.RESET;
//                                 TempCourseElements.DELETEALL;
//                                 ERROR('Aborted by User!');
//                             END;
//                         END;
//                         //DOC TKA_201106 +
//                     end;
//                 }

//             }
//         }
//     }
//     trigger OnInitReport()
//     var
//         myInt: Integer;
//     begin

//         //DOC TKA_201106 -
//         UserSetup.GET(USERID);
//         IF NOT UserSetup."Allow Add Line" THEN BEGIN
//             ERROR(Error010);
//             EXIT;
//         END;

//     end;

//     VAR
//         Error001: Label 'You can only specify one Course to build an event from.';
//         CoursePlanningSetup: Record 50000;
//         EventHeader: Record 50006;
//         EventLine: Record 50007;
//         EventDetailedEntry: Record 50008;
//         EventTrainerEntry: Record 50031;
//         TrainingCentre: Record 50009;
//         UserSetup: Record 91;
//         EventActionCode: Record 50026;
//         TempCourseElements: Record 50003 TEMPORARY;
//         Location: Record 14;
//         CourseCode: Code[20];
//         EventTrainingCentre: Code[20];
//         StartDate: Date;
//         EndDate: Date;
//         GroupLocation: Code[20];
//         Week: Code[20];
//         Error002: Label 'Please specify Course Header before selecting other Attributes';
//         MaxCandidates: Integer;
//         TutorCode: Code[20];
//         Error003: Label 'Please specify Max. No. of Attendees.';
//         Error004: Label 'Max. No. of Attendees must be between %1 and %2.';
//         Error005: Label 'Please specify Tutor Code.';
//         Error006: Label 'Please specify Event Co-ordinator Code.';
//         Error007: Label 'You Must Enter a Course Start Date,';
//         Error008: Label 'Please specify Training Centre Code.';
//         Error009: Label 'Please Select Invigilation Days First';
//         Error010: Label 'You are not allowed to create an Event';
//         Text001: Label 'Are you sure you wish to Create the following Course:\\';
//         Text002: Label 'Course Name: %1\';
//         Text003: Label 'Event Location: %1\';
//         Text004: Label 'Event Start Date: %1\';
//         Text005: Label 'Course Tutor: %1';
//         TempDate: Date;
//         PrevDuration: Decimal;
//         TrainerEntryDone: Boolean;
//         EventCoordinator: Code[20];
//         ShowWarning: Boolean;
//         InvigilatorCode: Code[20];
//         Text006: Label 'Course Invigilator: %1';
//         CourseMgt: Codeunit 50001;
//         NoofDays: Integer;
//         Tailored: Boolean;
//         Source: Option "",Vendor,TKA;
//         Deliver: Option " ",Onsite,Public,Virtual,Proctor,Closed,"Re-Closed Virtual",Classroom,Admin,Exam,"E-Learning"; //vaibhav
//         AutoEvent: Boolean;
//         "EventNo.": Code[20];
//         "E-Learning": Boolean;
//         ExpDate: Date;
//         EveStatus: Option "",Provisional,WatchList,Confirmed,Cancelled;
//         EventFound: Boolean;
//         EventReason1: Text[100];
//         EH1: Record 50006;
//         Window: Dialog;
//         TutorName: Text;

//     PROCEDURE GetTrainingCourseName(CourseCode: Code[20]): Text[80];
//     VAR
//         CourseHeader: Record 50002;
//     BEGIN
//         CourseHeader.RESET;
//         CourseHeader.SETRANGE(Code, CourseCode);
//         IF CourseHeader.FINDFIRST THEN
//             EXIT(CourseHeader.Name);
//         EXIT('');
//     END;

//     PROCEDURE GetTrainingCentreName(CourseHeaderCode: Code[20]; TrainingCentreCode: Code[20]): Text[50];
//     VAR
//         TrainingCentre: Record 50009;
//     BEGIN
//         TrainingCentre.RESET;
//         TrainingCentre.SETRANGE("Course Header", CourseHeaderCode);
//         TrainingCentre.SETRANGE("Location Code", TrainingCentreCode);
//         IF TrainingCentre.FINDFIRST THEN
//             EXIT(TrainingCentre.Description);
//         EXIT('');
//     END;

//     PROCEDURE GetCourseTrainerName(CourseHeaderCode: Code[20]; CourseTrainerCode: Code[20]): Text[50];
//     VAR
//         CourseTrainer: Record 50013;
//     BEGIN
//         CourseTrainer.RESET;
//         CourseTrainer.SETRANGE("Course Header", CourseHeaderCode);
//         CourseTrainer.SETRANGE("Course Trainer", CourseTrainerCode);
//         IF CourseTrainer.FINDFIRST THEN
//             EXIT(CourseTrainer."Trainer Name");
//         EXIT('');
//     END;

//     PROCEDURE GetPostingAccount(CourseCode: Code[20]): Code[20];
//     VAR
//         CourseHeader: Record 50002;
//     BEGIN
//         IF CourseHeader.GET(CourseCode) THEN
//             EXIT(CourseHeader."G/L Account No.");
//         EXIT('');
//     END;

//     PROCEDURE GetEventCoordinatorName(): Text[50];
//     VAR
//         EventCoordinators: Record 13;
//     BEGIN
//         //DOC TKA_201106 -
//         IF NOT EventCoordinators.GET(EventCoordinator) THEN
//             CLEAR(EventCoordinators);
//         EXIT(EventCoordinators.Name);
//         //DOC TKA_201106 +
//     END;

//     PROCEDURE SetValues(p1: Code[20]; p2: Date; p3: Code[20]; p4: Code[20]; p5: Text[1];
//     p6: Text[10]; p7: Text[10]; p8: Integer; p9: Code[20]; p10: Code[20]; p11: Code[20]; p12: Text[20]);
//     VAR
//         EventWeek: Record 50012;
//         rEventWeek: Record 50012;
//         rCourseElements: Record 50003;
//         rCourseHeader: Record 50002;
//         DCourse: Record 50002;
//         DLocation: Record 14;
//         DTraining: Record 50009;
//         DTraining2: Record 50059;
//     BEGIN
//         CLEARALL;
//         CourseCode := p1;
//         DCourse.RESET;
//         DCourse.SETRANGE(DCourse.Code, CourseCode);
//         DCourse.SETRANGE(Disable, FALSE);
//         IF DCourse.ISEMPTY() THEN
//             ERROR('%1 Course is Disabled', CourseCode);

//         StartDate := p2;

//         GroupLocation := p3;
//         DLocation.RESET;
//         DLocation.SETRANGE(DLocation.Code, GroupLocation);
//         DLocation.SETRANGE(Disable, FALSE);
//         IF DLocation.ISEMPTY() THEN
//             ERROR('%1 Location is Disabled', GroupLocation);

//         EventTrainingCentre := p4;
//         DTraining.RESET;
//         DTraining.SETRANGE(DTraining."Course Header", CourseCode);
//         DTraining.SETRANGE(DTraining."Location Code", EventTrainingCentre);
//         DTraining.SETRANGE(Disable, FALSE);
//         IF DTraining.ISEMPTY() THEN
//             ERROR('%1 Training Center for %2 Course is Disabled', EventTrainingCentre, CourseCode);



//         IF p5 = 'Y' THEN
//             Tailored := TRUE;
//         CASE p6 OF
//             'TKA':
//                 Source := Source::TKA;
//             'Vendor':
//                 Source := Source::Vendor;
//         END;
//         CASE p7 OF
//             'Onsite':
//                 Deliver := Deliver::Onsite;
//             'Public':
//                 Deliver := Deliver::Public;
//             'Virtual':
//                 Deliver := Deliver::Virtual;
//             'Proctor':
//                 Deliver := Deliver::Proctor;
//             'Closed':
//                 Deliver := Deliver::Closed;
//             'Classroom':
//                 Deliver := Deliver::Classroom;
//             'Admin':
//                 Deliver := Deliver::Admin;

//         //" ",Onsite,Public,Virtual,Proctor,Closed,"Re-Closed Virtual",Classroom,Admin,Exam,"E-Learning";
//         END;

//         MaxCandidates := p8;

//         TutorCode := p9;
//         InvigilatorCode := p11;
//         EventCoordinator := p10;
//         CASE p12 OF
//             'Provisional':
//                 EveStatus := EveStatus::Provisional;
//             'WatchList':
//                 EveStatus := EveStatus::WatchList;
//             'Confirmed':
//                 EveStatus := EveStatus::Confirmed;
//             'Cancelled':
//                 EveStatus := EveStatus::Cancelled;


//         END;

//         //DOC TKA_201106 -
//         TempCourseElements.RESET;
//         TempCourseElements.DELETEALL;
//         //DOC TKA_201106 +

//         //DSS -------------------------------
//         AutoEvent := TRUE;
//         //"E-Learning" := TRUE;
//         //DSS -------------------------------


//         IF CourseCode <> '' THEN BEGIN
//             rCourseHeader.RESET;
//             rCourseHeader.GET(CourseCode);
//         END ELSE
//             ERROR(Error002);

//         EventWeek.RESET;
//         EventWeek.SETRANGE(Year, DATE2DMY(StartDate, 3));
//         EventWeek.SETFILTER("Week Start Date", '..%1', StartDate);
//         EventWeek.SETFILTER("Week End Date", '%1..', StartDate);
//         IF EventWeek.FINDFIRST THEN
//             Week := EventWeek."Week Dimension Code"
//         ELSE
//             Week := '';

//         EndDate := StartDate - 1;
//         rCourseElements.RESET;
//         rCourseElements.SETCURRENTKEY("Element Sequence");
//         rCourseElements.SETRANGE("Course Header", rCourseHeader.Code);
//         IF rCourseElements.FINDFIRST THEN
//             REPEAT
//                 EndDate := EndDate + 1;
//                 NoofDays += 1;
//             UNTIL rCourseElements.NEXT = 0;
//     END;

//     PROCEDURE SetValuesElearn(p1: Code[20]; p2: Date; p3: Code[20]; p4: Code[20]; p5: Text[1];
//     p6: Text[10]; p7: Text[10]; p8: Integer; p9: Code[20]; p10: Code[20]; p11: Code[20];
//     p12: Text[20]; p13: Code[20]; p14: Date);
//     VAR
//         EventWeek: Record 50012;
//         rEventWeek: Record 50012;
//         rCourseElements: Record 50003;
//         rCourseHeader: Record 50002;
//         DCourse: Record 50002;
//         DLocation: Record 14;
//         DTraining: Record 50009;
//         DTraining2: Record 50059;
//     BEGIN
//         CLEARALL;
//         CourseCode := p1;
//         DCourse.RESET;
//         DCourse.SETRANGE(DCourse.Code, CourseCode);
//         DCourse.SETRANGE(Disable, FALSE);
//         IF DCourse.ISEMPTY() THEN
//             ERROR('%1 Course is Disabled', CourseCode);

//         StartDate := p2;

//         GroupLocation := p3;
//         DLocation.RESET;
//         DLocation.SETRANGE(DLocation.Code, GroupLocation);
//         DLocation.SETRANGE(Disable, FALSE);
//         IF DLocation.ISEMPTY() THEN
//             ERROR('%1 Location is Disabled', GroupLocation);

//         EventTrainingCentre := p4;
//         DTraining.RESET;
//         DTraining.SETRANGE(DTraining."Course Header", CourseCode);
//         DTraining.SETRANGE(DTraining."Location Code", EventTrainingCentre);
//         DTraining.SETRANGE(Disable, FALSE);
//         IF DTraining.ISEMPTY() THEN
//             ERROR('%1 Training Center for %2 Course is Disabled', EventTrainingCentre, CourseCode);



//         IF p5 = 'Y' THEN
//             Tailored := TRUE;
//         CASE p6 OF
//             'TKA':
//                 Source := Source::TKA;
//             'Vendor':
//                 Source := Source::Vendor;
//         END;
//         CASE p7 OF
//             'Onsite':
//                 Deliver := Deliver::Onsite;
//             'Public':
//                 Deliver := Deliver::Public;
//             'Virtual':
//                 Deliver := Deliver::Virtual;
//             'Proctor':
//                 Deliver := Deliver::Proctor;
//         END;

//         MaxCandidates := p8;

//         TutorCode := p9;
//         InvigilatorCode := p11;
//         EventCoordinator := p10;
//         CASE p12 OF
//             'Provisional':
//                 EveStatus := EveStatus::Provisional;
//             'WatchList':
//                 EveStatus := EveStatus::WatchList;
//             'Confirmed':
//                 EveStatus := EveStatus::Confirmed;
//             'Cancelled':
//                 EveStatus := EveStatus::Cancelled;
//         END;

//         "EventNo." := p13;
//         ExpDate := p14;

//         //DOC TKA_201106 -
//         TempCourseElements.RESET;
//         TempCourseElements.DELETEALL;
//         //DOC TKA_201106 +

//         //DSS -------------------------------
//         //AutoEvent := TRUE;
//         "E-Learning" := TRUE;
//         //DSS -------------------------------


//         IF CourseCode <> '' THEN BEGIN
//             rCourseHeader.RESET;
//             rCourseHeader.GET(CourseCode);
//         END ELSE
//             ERROR(Error002);

//         EventWeek.RESET;
//         EventWeek.SETRANGE(Year, DATE2DMY(StartDate, 3));
//         EventWeek.SETFILTER("Week Start Date", '..%1', StartDate);
//         EventWeek.SETFILTER("Week End Date", '%1..', StartDate);
//         IF EventWeek.FINDFIRST THEN
//             Week := EventWeek."Week Dimension Code"
//         ELSE
//             Week := '';

//         EndDate := StartDate - 1;
//         rCourseElements.RESET;
//         rCourseElements.SETCURRENTKEY("Element Sequence");
//         rCourseElements.SETRANGE("Course Header", rCourseHeader.Code);
//         IF rCourseElements.FINDFIRST THEN
//             REPEAT
//                 EndDate := EndDate + 1;
//                 NoofDays += 1;
//             UNTIL rCourseElements.NEXT = 0;
//     END;

//     PROCEDURE CheckExistingEvent();
//     BEGIN
//         EventFound := FALSE;
//         EH1.SETFILTER(EH1."Course Header", CourseCode);
//         EH1.SETFILTER(EH1."Training Centre", EventTrainingCentre);
//         EH1.SETFILTER(EH1."Start Date", '%1', StartDate);
//         //EH1.SETFILTER(EH1.Delivery,'%1',Delivery);
//         IF EH1.FIND('+') THEN BEGIN
//             EH1.CALCFIELDS("Confirmed Seats");
//             IF EH1."Confirmed Seats" < 20 THEN BEGIN

//                 IF NOT CONFIRM('Are you sure? A duplicate Event with the same  Course Code, Training Location, Start Date ,' +
//                                'Delivery already exists  If you hit yes - provide reason') THEN
//                     EXIT;

//                 EventFound := TRUE;

//                 Window.OPEN('Enter Reason Code  #1##########');
//                 //Vaibhav Window.INPUT(1, EventReason1);
//                 Window.CLOSE;
//             END
//         END;
//     END;

//     PROCEDURE SetValuesManual(p1: Code[20]; p2: Date; p3: Code[20]; p4: Code[20]; p5: Text[1];
//     p6: Text[10]; p7: Text[10]; p8: Integer; p9: Code[20]; p10: Code[20]; p11: Code[20];
//     p12: Text[20]; p13: Code[20]; p14: Date);
//     VAR
//         EventWeek: Record 50012;
//         rEventWeek: Record 50012;
//         rCourseElements: Record 50003;
//         rCourseHeader: Record 50002;
//         DCourse: Record 50002;
//         DLocation: Record 14;
//         DTraining: Record 50009;
//         DTraining2: Record 50059;
//     BEGIN
//         CLEARALL;
//         CourseCode := p1;
//         DCourse.RESET;
//         DCourse.SETRANGE(DCourse.Code, CourseCode);
//         DCourse.SETRANGE(Disable, FALSE);
//         IF DCourse.ISEMPTY() THEN
//             ERROR('%1 Course is Disabled', CourseCode);

//         StartDate := p2;

//         GroupLocation := p3;
//         DLocation.RESET;
//         DLocation.SETRANGE(DLocation.Code, GroupLocation);
//         DLocation.SETRANGE(Disable, FALSE);
//         IF DLocation.ISEMPTY() THEN
//             ERROR('%1 Location is Disabled', GroupLocation);

//         EventTrainingCentre := p4;
//         DTraining.RESET;
//         DTraining.SETRANGE(DTraining."Course Header", CourseCode);
//         DTraining.SETRANGE(DTraining."Location Code", EventTrainingCentre);
//         DTraining.SETRANGE(Disable, FALSE);
//         IF DTraining.ISEMPTY() THEN
//             ERROR('%1 Training Center for %2 Course is Disabled', EventTrainingCentre, CourseCode);



//         IF p5 = 'Y' THEN
//             Tailored := TRUE;
//         CASE p6 OF
//             'TKA':
//                 Source := Source::TKA;
//             'Vendor':
//                 Source := Source::Vendor;
//         END;
//         CASE p7 OF
//             'Onsite':
//                 Deliver := Deliver::Onsite;
//             'Public':
//                 Deliver := Deliver::Public;
//             'Virtual':
//                 Deliver := Deliver::Virtual;
//             'Proctor':
//                 Deliver := Deliver::Proctor;
//         END;

//         MaxCandidates := p8;

//         TutorCode := p9;
//         InvigilatorCode := p11;
//         EventCoordinator := p10;
//         CASE p12 OF
//             'Provisional':
//                 EveStatus := EveStatus::Provisional;
//             'WatchList':
//                 EveStatus := EveStatus::WatchList;
//             'Confirmed':
//                 EveStatus := EveStatus::Confirmed;
//             'Cancelled':
//                 EveStatus := EveStatus::Cancelled;
//         END;

//         "EventNo." := p13;
//         ExpDate := p14;

//         //DOC TKA_201106 -
//         TempCourseElements.RESET;
//         TempCourseElements.DELETEALL;
//         //DOC TKA_201106 +

//         //DSS -------------------------------
//         //AutoEvent := TRUE;
//         //"E-Learning" := TRUE;
//         //DSS -------------------------------


//         IF CourseCode <> '' THEN BEGIN
//             rCourseHeader.RESET;
//             rCourseHeader.GET(CourseCode);
//         END ELSE
//             ERROR(Error002);

//         EventWeek.RESET;
//         EventWeek.SETRANGE(Year, DATE2DMY(StartDate, 3));
//         EventWeek.SETFILTER("Week Start Date", '..%1', StartDate);
//         EventWeek.SETFILTER("Week End Date", '%1..', StartDate);
//         IF EventWeek.FINDFIRST THEN
//             Week := EventWeek."Week Dimension Code"
//         ELSE
//             Week := '';

//         EndDate := StartDate - 1;
//         rCourseElements.RESET;
//         rCourseElements.SETCURRENTKEY("Element Sequence");
//         rCourseElements.SETRANGE("Course Header", rCourseHeader.Code);
//         IF rCourseElements.FINDFIRST THEN
//             REPEAT
//                 EndDate := EndDate + 1;
//                 NoofDays += 1;
//             UNTIL rCourseElements.NEXT = 0;
//     END;

// }
