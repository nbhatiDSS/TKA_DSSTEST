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
    ODataKeyFields = "Document Type", "No.", "Line No.";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Document_Type"; Rec."Document Type")
                { }
                field("No"; Rec."No.")
                { }
                field("Line_No"; Rec."Line No.")
                { }
                field(Description; Rec.Description)
                { }
                field("Event_No"; Rec."Event No.")
                { }
                field(Quantity; Rec.Quantity)
                { }
                field("Unit_Cost"; Rec."Unit Cost")
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
}