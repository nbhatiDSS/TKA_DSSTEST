page 61005 "Course API"
{
    APIGroup = 'API';
    APIPublisher = 'Direction_Software_LLP';
    APIVersion = 'v2.0';
    ApplicationArea = All;
    Caption = 'course';
    DelayedInsert = true;
    EntityName = 'events';
    EntitySetName = 'course';
    PageType = API;
    SourceTable = "Course Header";
    ODataKeyFields = Code;

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
                field("code"; Rec."Code")
                {
                    Caption = 'Code';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                }
                field(CCat; Rec.CCat)
                {
                    ApplicationArea = All;
                }
                field(courseCategory; Rec.CourseCategory)
                {
                    Caption = 'CourseCategory';
                }
                field(courseTopic; Rec.CourseTopic)
                {
                    Caption = 'CourseTopic';
                }
                field(ei; Rec.EI)
                {
                    Caption = 'EI';
                }
                field(tkaCourseName; Rec."TKA Course Name")
                {
                    Caption = 'TKA Course Name';
                }
                field(tkaCourseId; Rec."TKA course Id")
                {
                    Caption = 'TKA course Id';
                }
                field(headerType; Rec."Header Type")
                {
                    Caption = 'Header Type';
                }
                field(bespoke; Rec.Bespoke)
                {
                    Caption = 'Bespoke';
                }
                field(bespokeType; Rec."Bespoke Type")
                {
                    Caption = 'Bespoke Type';
                }
                field(technical; Rec.Technical)
                {
                    Caption = 'Technical';
                }
                field(weekendWeekday; Rec."Weekend/Weekday")
                {
                    Caption = 'Weekend/Weekday';
                }
                field(gLAccountNo; Rec."G/L Account No.")
                {
                    Caption = 'G/L Account No.';
                }
                field(gLAccountNoPurchase; Rec."G/L Account No. (Purchase)")
                {
                    Caption = 'G/L Account No. (Purchase)';
                }
                field(durationDays; Rec."Duration (Days)")
                {
                    Caption = 'Duration (Days)';
                }
                field(durationHours; Rec."Duration (Hours)")
                {
                    Caption = 'Duration (Hours)';
                }
            }
        }
    }
    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        rec.Description := rec.Name;
    end;

    trigger OnModifyRecord(): Boolean
    begin
        rec.Description := rec.Name;
    end;
}
