page 61012 "PurchLineAPI"
{
    APIGroup = 'API';
    APIPublisher = 'Direction_Software_LLP';
    APIVersion = 'v2.0';
    ApplicationArea = All;
    Caption = 'PurchaseLineAPI';
    DelayedInsert = true;
    EntityName = 'purchaseLine';
    EntitySetName = 'Purchase';
    PageType = API;
    SourceTable = "Purchase Line";
    ODataKeyFields = "Document Type", "Document No.", "Line No.";
    DeleteAllowed = false;


    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Document_Type"; Rec."Document Type")
                { }
                field("Document_No"; Rec."Document No.")
                { }
                field("Line_No"; Rec."Line No.")
                {
                    Editable = false;
                }
                field(Type; Rec.Type)
                { }
                field("No"; rec."No.")
                {
                    // trigger OnValidate()
                    // begin
                    //     rec.TestField(rec.Type);
                    // end;
                }
                field(Description; Rec.Description)
                { }
                field("Event_No"; Rec."Event No.")
                { }
                field(Quantity; Rec.Quantity)
                { }
                field("Direct_Unit_Cost"; Rec."Direct Unit Cost")
                { }
                field("VAT_Percent"; Rec."VAT %")
                { }
                field(MasterCode; Rec.MasterCode)
                { }
                field(MasterType; Rec.MasterType)
                { }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        NO_ := rec."No.";
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        PurchaseLine: Record "Purchase Line";
    begin
        rec."Line No." := 10000;
        PurchaseLine.SetCurrentKey("Document No.", "Document Type");
        PurchaseLine.SetFilter("Document No.", rec."Document No.");
        PurchaseLine.SetFilter("Document Type", '%1', rec."Document Type");
        if PurchaseLine.FindLast() then rec."Line No." += PurchaseLine."Line No.";
        // rec.validate(rec."No.", No_);
    end;

    var
        No_: code[20];
}