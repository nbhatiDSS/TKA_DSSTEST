page 61007 "Course Elements API"
{
    APIGroup = 'API';
    APIPublisher = 'Direction_Software_LLP';
    APIVersion = 'v1.0';
    ApplicationArea = All;
    Caption = 'courseElements';
    DelayedInsert = true;
    EntityName = 'events';
    EntitySetName = 'courseElements';
    PageType = API;
    SourceTable = "Course Elements";
    ODataKeyFields = "Course Header", "Element Code";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(SystemId; Rec.SystemId)
                {
                    Caption = 'SystemID';
                }
                field(courseHeader; Rec."Course Header")
                {
                    Caption = 'Course Header';
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description';
                }
                field(durationHours; Rec."Duration (Hours)")
                {
                    Caption = 'Duration (Hours)';
                }
                field(elementCode; Rec."Element Code")
                {
                    Caption = 'Element Code';
                }
                field(elementType; Rec."Element Type")
                {
                    Caption = 'Element Type';
                }
                field(rank; Rec.Rank)
                {
                    Caption = 'Rank';
                }
                field(examType; Rec."Exam Type")
                {
                    Caption = 'Exam Type';
                }
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                { }
                field(SystemModifiedAt; Rec.SystemModifiedAt)
                { }
            }
        }
    }
    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        CreateZZUNATrainer(rec."Course Header");
        InsertCourseDimension(rec."Course Header");
        rec."Element Dimension Code" := rec."Element Code";
        rec."Element Price Inc. VAT" := 2000;
        rec.Name := rec.Description;
    end;

    local procedure InsertCourseDimension(courseheader: code[20])
    var
        DimValue: Record "Dimension Value";
        recCourseHeader: record "Course Header";
    begin
        if DimValue.Get('PROJECT', courseheader) then begin
            if recCourseHeader.get(courseheader) then begin
                if recCourseHeader."Course Dimension Code" = '' then begin
                    recCourseHeader.Validate("Course Dimension Code", courseheader);
                    recCourseHeader.Modify();
                end;
            end
        end;
    end;

    local procedure CreateZZUNATrainer(courseheader: code[20])
    var
        courseTrainer: record "Course Trainer";
    begin
        if not courseTrainer.Get(courseheader, 'ZZUNA') then begin
            courseTrainer.Reset();
            courseTrainer.Init();
            courseTrainer.Validate("Course Header", courseheader);
            courseTrainer.Validate("Course Trainer", 'ZZUNA');
            courseTrainer.Insert();
        end;
    end;
}
