page 61011 "PurchHeaderAPI"
{
    APIGroup = 'API';
    APIPublisher = 'Direction_Software_LLP';
    APIVersion = 'v2.0';
    ApplicationArea = All;
    Caption = 'PurchaseHeaderAPI';
    DelayedInsert = true;
    EntityName = 'purchaseHeader';
    EntitySetName = 'Purchase';
    PageType = API;
    SourceTable = "Purchase Header";
    ODataKeyFields = "Document Type", "No.";


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
                field("Buy_from_Vendor_No"; Rec."Buy-from Vendor No.")
                { }
                field("Buy_from_Vendor_Name"; Rec."Buy-from Vendor Name")
                { }
                field("Buy_from_Address"; Rec."Buy-from Address")
                { }
                field("Buy_from_Address_2"; Rec."Buy-from Address 2")
                { }
                field("Buy_from_City"; Rec."Buy-from City")
                { }
                field("Buy_from_Post_Code"; Rec."Buy-from Post Code")
                { }
                field("Buy_from_Country_Region_Code"; Rec."Buy-from Country/Region Code")
                { }
                field("Vendor_Invoice_No"; Rec."Vendor Invoice No.")
                { }
                field("Due_Date"; Rec."Due Date")
                { }
                field("Proposed_Payment_Date1"; Rec."Proposed Payment Date1")
                { }
                field("Payment_Terms_Code"; Rec."Payment Terms Code")
                { }
                field("Payment_Type"; Rec."Payment Type")
                { }
                field("Prices_Including_VAT"; Rec."Prices Including VAT")
                { }
                field(Amount; Rec.Amount)
                { }
                field("Amount_Including_VAT"; Rec."Amount Including VAT")
                { }
                field("VAT_Amount"; rec."Amount Including VAT" - rec.Amount)
                { }
                field("Currency_Code"; Rec."Currency Code")
                { }
                field("Currency_Factor"; Rec."Currency Factor")
                { }
                field("Company_Name"; CompanyName())
                { }
            }
        }
    }
}
