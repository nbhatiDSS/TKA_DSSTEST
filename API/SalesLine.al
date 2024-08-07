page 61009 "Sales Line"
{
    APIGroup = 'API';
    APIPublisher = 'Direction_Software_LLP';
    APIVersion = 'v2.0';
    ApplicationArea = All;
    Caption = 'sales Lines';
    DelayedInsert = true;
    EntityName = 'events';
    EntitySetName = 'SalesLines';
    PageType = API;
    SourceTable = "Sales Line";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("BookingNo"; Rec."Document No.")
                {
                    ApplicationArea = All;
                }
                field("line"; Rec."Line No.")
                {
                    Editable = false;
                    ApplicationArea = All;
                }
                field("CourseHeader"; CourseHeader)
                {
                    ApplicationArea = All;
                }
                field("eventNo"; Rec."Event Header")
                {
                    ApplicationArea = All;
                }

                field("UnitPrice"; Rec."Unit Price")
                {
                    ApplicationArea = All;
                }
                field(Qty; Rec.Quantity)
                {
                    ApplicationArea = All;
                }
                field("location"; Rec."Group Location")
                {
                    ApplicationArea = All;
                }
                field("ProdPosGrp"; Rec."VAT Prod. Posting Group")
                {
                    ApplicationArea = All;
                }
                field("BusPosGrp"; Rec."VAT Bus. Posting Group")
                {
                    ApplicationArea = All;
                }
                field(Ecode; Ecode)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Description2"; "Description 2")
                {
                    ApplicationArea = All;
                }
                field(CourseElement; CourseElement)
                {
                    ApplicationArea = All;
                }
                field("ContactNo"; Rec."Contact No.")
                {
                    ApplicationArea = All;
                }
                field("Vatreason"; Rec."VAT Difference Reason")
                {
                    ApplicationArea = All;
                }
                field(EmptyLine; EmptyLine)
                {
                    ApplicationArea = All;
                }
                field("KPInvoiceNo"; Rec."KP No.")
                {
                    ApplicationArea = All;
                }
                field("KPLineNo"; Rec."KP Line No.")
                {
                    ApplicationArea = All;
                }

            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        salesHeader: record "Sales Header";
    begin
        if EmptyLine then
            checkEmptyLine(salesHeader) else begin
            GetSalesHeader(rec, salesHeader);
            CheckcourseHeader(salesHeader);
            AddCourseGL;
            checkEventLine;
            checkKPFP(salesHeader, rec);
        end;
    end;

    trigger OnModifyRecord(): Boolean
    var
        salesHeader: record "Sales Header";
    begin
        if EmptyLine then
            checkEmptyLine(salesHeader)
        else begin
            GetSalesHeader(rec, salesHeader);
            if salesHeader.get(rec."Document Type", rec."Document No.") then
                if salesHeader."Booking Confirmed" then ERROR('Order Confirmed cannot edit');

            CheckcourseHeader(salesHeader);
            AddCourseGL;
            checkEventLine;
            checkKPFP(salesHeader, rec);
        end;

    end;

    Local PROCEDURE EventLines(Ecode: Text[30]; var salesHeader: record "Sales Header"; var salesLine: record "Sales Line"; EventNo: Code[20]; ContactNo: Code[30])
    VAR
        Contact: Record 5050;
        EventHeader: Record 50006;
        sl: Record 37;
        CourseLineEle: Record 50003;
        i: Integer;
        temparr: ARRAY[30] OF Code[20];
        count: Integer;
        lCourseElements: Record 50003;
        lTempCourseElements: Record 50003 TEMPORARY;
        CourseHeader1: Record 50002;
        sh1: Record 36;
        DocLineNo: Integer;
        sl1: Record 37;
        EDE: Record 50008;
    BEGIN
        EventHeader.get(EventNo);
        Contact.get(ContactNo);
        count := STRLEN(DELCHR(Ecode, '=', ','));
        i := 1;
        WHILE i <= count DO BEGIN
            temparr[i] := SELECTSTR(i, Ecode);
            i += 1;
        END;
        lCourseElements.SETRANGE(lCourseElements."Course Header", EventHeader."Course Header");
        IF count <> 0 THEN
            lCourseElements.SETFILTER(lCourseElements."Element Code", '%1|%2|%3|%4|%5|%6|%7', temparr[1], temparr[2], temparr[3], temparr[4]
            , temparr[5], temparr[6], temparr[7]);

        ManageBooking(3, EventHeader, Contact, salesLine, salesHeader,
                                 lCourseElements, (lCourseElements.COUNT = CourseLineEle.COUNT), salesLine."Document Type", '', 0);

    End;


    local procedure ManageBooking(Mode: Option "Create Booking","Add Booking","Change Booking","Confirm Elements","Cancel Elements","Make Order","Confirm Order","Un-Confirm Order","Post Order";
     EventHeader: Record "Event Header"; Contact: Record Contact; var salesLine: record "Sales Line"; var salesHeader: Record "Sales Header"; var TempCourseElements: Record "Course Elements" temporary; FullCourse: Boolean; OldDocumentType: enum "Sales Document Type"; OldDocumentNo: Code[20]; OldDocumentLineNo: Integer)
    var
        EventDetailedEntry: record "Event Detailed Entry";
        EventDetailedEntry2: record "Event Detailed Entry";
        Customer: record Customer;
        EventLine: record "Event Line";
        ElementFound: Boolean;
        NoofNewSalesLinesToCreate: Integer;
        ArrExamSalesLineNo: array[10] of Integer;
        OnlyExams: Boolean;
        EventLine2: record "Event Line";
        EventContactRegister: record "Event/Contact Register";
        Index: integer;
        SalesDocLine2: Record "Sales Line";
        NewLineNo: Integer;
    begin
        case Mode of
            Mode::"Confirm Elements":
                begin
                    EventHeader.TestField("No.");
                    Customer.Get(salesHeader."Bill-to Customer No.");
                    if EventHeader."E-Learning" then begin
                        TempCourseElements.SetRange("Exam Type", TempCourseElements."Exam Type"::" ");
                        if TempCourseElements.FindFirst then
                            NoofNewSalesLinesToCreate := 0
                        else
                            NoofNewSalesLinesToCreate := -1;
                        OnlyExams := (NoofNewSalesLinesToCreate < 0);
                        TempCourseElements.SetFilter("Exam Type", '<>%1', TempCourseElements."Exam Type"::" ");
                        NoofNewSalesLinesToCreate := NoofNewSalesLinesToCreate + TempCourseElements.Count;
                        if NoofNewSalesLinesToCreate > 0 then begin
                            SalesDocLine2.SetRange("Document Type", salesLine."Document Type");
                            SalesDocLine2.SetRange("Document No.", salesLine."Document No.");
                            SalesDocLine2.FindLast;
                            if not OnlyExams then
                                // NewLineNo := salesLine."Line No."
                                // else
                                NewLineNo := SalesDocLine2."Line No." + 10000;
                            TempCourseElements.FindFirst;
                            repeat
                                ArrExamSalesLineNo[TempCourseElements."Exam Type"] := NewLineNo;
                                SalesDocLine2.Reset;
                                SalesDocLine2.TransferFields(salesLine);
                                SalesDocLine2."Line No." := NewLineNo;
                                SalesDocLine2.Validate("Qty. to Ship", 0);
                                SalesDocLine2.Insert(true);
                                SalesDocLine2.SetRange("Document Type", salesLine."Document Type");
                                SalesDocLine2.SetRange("Document No.", salesLine."Document No.");
                                SalesDocLine2.FindLast;
                                NewLineNo := SalesDocLine2."Line No." + 10000;
                            until TempCourseElements.Next = 0;
                        end;
                        TempCourseElements.SetRange("Exam Type");
                    end;
                    TempCourseElements.FindFirst;
                    repeat
                        ElementFound := false;
                        EventLine.Reset;
                        EventLine.SetRange("Event No.", EventHeader."No.");
                        if not FullCourse then begin
                            EventLine.SetRange(Status, EventLine.Status::"Partially Booked");
                            if EventLine.FindFirst then begin
                                repeat
                                    EventDetailedEntry.Reset;
                                    EventDetailedEntry.SetRange("Event No.", EventLine."Event No.");
                                    EventDetailedEntry.SetRange("Line No.", EventLine."Line No.");
                                    EventDetailedEntry.SetRange("Element Code", TempCourseElements."Element Code");
                                    EventDetailedEntry.SetRange(Status, EventDetailedEntry.Status::Available);
                                    if EventDetailedEntry.FindFirst then begin
                                        ElementFound := true;
                                        EventDetailedEntry2 := EventDetailedEntry;
                                    end;
                                until (EventLine.Next = 0) or (ElementFound);
                            end;
                            if not ElementFound then begin
                                EventLine.SetRange(Status, EventLine.Status::Provisional);
                                if EventLine.FindFirst then begin
                                    repeat
                                        EventDetailedEntry.Reset;
                                        EventDetailedEntry.SetRange("Event No.", EventLine."Event No.");
                                        EventDetailedEntry.SetRange("Line No.", EventLine."Line No.");
                                        EventDetailedEntry.SetRange("Element Code", TempCourseElements."Element Code");
                                        EventDetailedEntry.SetRange(Status, EventDetailedEntry.Status::Available);
                                        if EventDetailedEntry.FindFirst then begin
                                            ElementFound := true;
                                            EventDetailedEntry2 := EventDetailedEntry;
                                        end;
                                    until (EventLine.Next = 0) or (ElementFound);
                                end;
                            end;
                        end;
                        ElementFound := false;//280922
                        if not ElementFound then begin

                            EventLine.SetRange(Status, EventLine.Status::Available);
                            if EventLine.FindFirst then begin
                                EventDetailedEntry.Reset;
                                EventDetailedEntry.SetRange("Event No.", EventLine."Event No.");
                                EventDetailedEntry.SetRange("Line No.", EventLine."Line No.");
                                EventDetailedEntry.SetRange("Element Code", TempCourseElements."Element Code");
                                EventDetailedEntry.SetRange(Status, EventDetailedEntry.Status::Available);
                                if EventDetailedEntry.FindFirst then begin
                                    ElementFound := true;
                                    EventDetailedEntry2 := EventDetailedEntry;
                                end;
                            end;
                        end;
                        if not ElementFound then begin
                            if not salesLine.ElementNonAvailable then
                                // SendAlert(EventHeader."No.", DocumentType, DocumentNo, DocumentLineNo);
                            Error(Error014, EventHeader."Course Header", EventHeader."Start Date", EventHeader."Training Centre",
                              EventHeader."Resource Manager");
                        end; //150724

                        EventDetailedEntry2."Contact/Customer No." := Contact."No.";
                        EventDetailedEntry2."Document Type" := salesHeader."Document Type" + 1;
                        EventDetailedEntry2."Document No." := salesHeader."No.";
                        EventDetailedEntry2."Document Line No." := salesLine."Line No.";
                        if EventHeader."E-Learning" then
                            if TempCourseElements."Exam Type" <> TempCourseElements."Exam Type"::" " then
                                EventDetailedEntry2."Document Line No." := ArrExamSalesLineNo[TempCourseElements."Exam Type"];
                        EventDetailedEntry2.Status := EventDetailedEntry2.Status::Provisional;
                        EventDetailedEntry2."Salesperson Code" := salesHeader."Salesperson Code";
                        EventDetailedEntry2."Element Price Excl. VAT" := TempCourseElements."Element Price Excl. VAT";
                        //DSTKA#01 19.01.2015 -
                        EventDetailedEntry2."Bill-To Customer No." := Customer."No.";
                        EventDetailedEntry2."Special Cancellation Terms" := Customer."Special Cancellation Terms";
                        //DSTKA#01 19.01.2015 +

                        EventDetailedEntry2."USER ID" := UserId; //13.01.22
                        EventDetailedEntry2.Modify;
                        EventLine2.Get(EventLine."Event No.", EventLine."Line No.");
                        EventLine2.Mark(true);
                        if not EventContactRegister.Get(EventHeader."No.", Contact."No.") then begin
                            EventContactRegister.Init;
                            EventContactRegister.Validate("Event No.", EventHeader."No.");
                            EventContactRegister.Validate("Contact No.", Contact."No.");
                            EventContactRegister.Insert;
                        end;
                    until TempCourseElements.Next = 0;
                    EventLine2.MarkedOnly(true);
                    EventLine2.FindFirst;
                    repeat
                        EventLine2.SetLineStatus();
                        EventLine2.Modify;
                    until EventLine2.Next = 0;
                    // SalesDoc.Get(DocumentType, DocumentNo);
                    // SalesDocLine.Get(SalesDoc."Document Type", SalesDoc."No.", DocumentLineNo);
                    if salesLine.GetNoofCourseElements() = 0 then begin
                        salesLine.Validate(Quantity, 0);
                        // salesLine.Modify;
                    end else begin
                        salesLine.Validate(Quantity, 1);
                        // salesLine.Modify;
                    end;
                    if EventHeader."E-Learning" then begin
                        for Index := 1 to 10 do begin
                            if ArrExamSalesLineNo[Index] <> 0 then begin
                                // SalesDocLine.Get(SalesDoc."Document Type", SalesDoc."No.", ArrExamSalesLineNo[Index]);
                                if salesLine.GetNoofCourseElements() = 0 then begin
                                    salesLine.Validate(Quantity, 0);
                                    // SalesDocLine.Modify;
                                end else begin
                                    salesLine.Validate(Quantity, 1);
                                    // SalesDocLine.Modify;
                                end;
                            end;
                        end;
                    end;
                end;
        end;
    end;

    PROCEDURE elementbooking(elements: Text[30]; salesline: Record "Sales Line");
    VAR
        i: Integer;
        temparr: ARRAY[30] OF Code[20];
        lTempCourseElements: Record "Course Elements";
        CourseElementBooking: Record "IC Inbox Jnl. Line";
        ch: Record "Course Header";
        SrNo: Integer;
        CourseElement: Record "IC Inbox Jnl. Line";
        count: Integer;
    BEGIN
        count := STRLEN(DELCHR(elements, '=', ','));
        i := 1;
        WHILE i <= count DO BEGIN
            temparr[i] := SELECTSTR(i, elements);
            i += 1;
        END;

        CLEAR(CourseElementBooking);
        IF salesline."Document Type" = salesline."Document Type"::Quote THEN
            CourseElementBooking.SETFILTER(CourseElementBooking."Document No.", salesline."Document No.");
        IF salesline."Document Type" = salesline."Document Type"::Order THEN
            CourseElementBooking.SETFILTER(CourseElementBooking."Sales Order No", salesline."Document No.");

        CourseElementBooking.SETFILTER(CourseElementBooking."Line No.", '%1', salesline."Line No.");
        IF CourseElementBooking.FINDSET THEN
            CourseElementBooking.DELETEALL;

        CourseElement.RESET;
        IF CourseElement.FINDLAST THEN
            SrNo := CourseElement."Transaction No." + 1
        ELSE
            SrNo := 1;

        i := 1;
        WHILE i <= count DO BEGIN
            lTempCourseElements.RESET;
            lTempCourseElements.SETFILTER(lTempCourseElements."Course Header", '%1', salesline."Course Header");
            lTempCourseElements.SETFILTER(lTempCourseElements."Element Code", '%1', temparr[i]);
            IF lTempCourseElements.FINDFIRST THEN BEGIN
                CourseElementBooking.INIT;
                CourseElementBooking."Transaction No." := SrNo;
                CourseElementBooking."Course Header" := lTempCourseElements."Course Header";
                IF salesline."Document Type" = salesline."Document Type"::Quote THEN
                    CourseElementBooking."Document No." := salesline."Document No.";
                IF salesline."Document Type" = salesline."Document Type"::Order THEN
                    CourseElementBooking."Sales Order No" := salesline."Document No.";

                CourseElementBooking."Element Code" := lTempCourseElements."Element Code";
                CourseElementBooking."Posted Invoice No" := '';
                CourseElementBooking."Line No." := salesline."Line No.";
                CourseElementBooking."USER ID" := USERID;
                CourseElementBooking.INSERT;
                SrNo := SrNo + 1;
            END;
            i += 1;
        END;
    END;



    local procedure checkEventLine()
    var
        eventHeader: record "Event Header";
        ApiWrite: codeunit "API Write";
    begin
        if eventHeader.get(rec."Event Header") then begin
            eventHeader.CalcFields("Available Seats");
            if eventHeader."Available Seats" < 0 then ApiWrite.AddnewLine(eventHeader."Course Header", eventHeader."No.");
        end;
    end;

    local procedure AddCourseGL()
    var
        courseHeader: record "Course Header";
    begin

        if courseHeader.get(rec."Course Header") then begin
            rec.Type := rec.Type::"G/L Account";
            rec."No." := courseHeader."G/L Account No.";
        end;
    end;

    local procedure checkEmptyLine(var salesHeader: record "Sales Header")
    var
        TempLineNo: integer;
        TempDocumentNo: Code[20];
        TempDesc: text[100];
    begin
        if EmptyLine then begin
            TempLineNo := rec."Line No.";
            TempDesc := rec.Description;
            rec.init();
            rec."Line No." := TempLineNo;
            rec."Document No." := salesHeader."No.";
            rec.Description := TempDesc;
        end;
    end;

    local procedure checkKPFP(var salesHeader: record "sales header"; var salesLine: Record "Sales Line")
    begin
        if salesHeader."Knowledge Pass" then begin
            rec.Type := Rec.Type::"G/L Account";
            rec."No." := '5345';
        end else if salesHeader."Flexi Pass" then begin
            rec.Type := Rec.Type::"G/L Account";
            rec."No." := '5344';
            elementbooking(Ecode, rec);
        end else if salesHeader."Flexi Pass 12" then begin
            rec.Type := Rec.Type::"G/L Account";
            rec."No." := '5346';
            elementbooking(Ecode, rec);
        end else if salesHeader."Flexi Pass 2" then begin
            rec.Type := Rec.Type::"G/L Account";
            rec."No." := '5348';
            elementbooking(Ecode, rec);
        end else begin
            elementbooking(Ecode, Rec);
            // EventLines(Ecode, salesHeader, salesLine, salesLine."Event Header", salesLine."Contact No.");
        end;
    end;


    local procedure CheckcourseHeader(var salesHeader: record "sales header")
    var
        recCourseHeader: record "Course Header";
    begin
        IF (salesHeader."Flexi Pass 2" OR salesHeader."Flexi Pass 12" OR salesHeader."Flexi Pass") THEN
            IF courseHeader = '' THEN
                ERROR('Please check course header') else
                if recCourseHeader.get(courseHeader) then
                    rec.validate(rec."Course Header", courseHeader)
                else
                    error(Err001);
    end;

    local procedure GetSalesHeader(var salesLine: record "Sales Line"; var salesHeader: record "Sales Header")
    begin
        salesHeader.get(salesLine."Document Type", salesLine."Document No.");
    end;

    var
        Description: text[100];
        "Description 2": text[100];
        Ecode: Text[30];
        CourseElement: Code[20];
        EmptyLine: Boolean;
        courseHeader: Code[20];
        Err001: label 'Course Header not found.';
        Error014: Label 'There are no available places left on the %1 course held on %2 at %3. Notification has been sent to the Resource manager to add another seat, please speak to the %4.';


}
