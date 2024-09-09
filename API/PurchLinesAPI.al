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
<<<<<<< HEAD
    ODataKeyFields = "Document Type", "No.", "Line No.";
=======
    ODataKeyFields = "Document Type", "Document No.", "Line No.";
    DeleteAllowed = false;

>>>>>>> 6806c381c855e47a3bfe21b915b51fc03bc97841

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Document_Type"; Rec."Document Type")
                { }
<<<<<<< HEAD
                field("No"; Rec."No.")
                { }
                field("Line_No"; Rec."Line No.")
                { }
=======
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
>>>>>>> 6806c381c855e47a3bfe21b915b51fc03bc97841
                field(Description; Rec.Description)
                { }
                field("Event_No"; Rec."Event No.")
                { }
                field(Quantity; Rec.Quantity)
                { }
<<<<<<< HEAD
                field("Unit_Cost"; Rec."Unit Cost")
=======
                field("Direct_Unit_Cost"; Rec."Direct Unit Cost")
>>>>>>> 6806c381c855e47a3bfe21b915b51fc03bc97841
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
<<<<<<< HEAD
=======

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
>>>>>>> 6806c381c855e47a3bfe21b915b51fc03bc97841
}