page 61008 "Sales Header"
{
    APIGroup = 'API';
    APIPublisher = 'Direction_Software_LLP';
    APIVersion = 'v2.0';
    ApplicationArea = All;
    Caption = 'sales Orders';
    DelayedInsert = true;
    EntityName = 'events';
    EntitySetName = 'SalesHeaders';
    PageType = API;
    SourceTable = "Sales Header";

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
                field("DocumentType"; Rec."Document Type")
                {
                    ApplicationArea = All;
                }
                field("No"; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field(SellToCont; Rec."Sell-to Contact No.")
                {
                    ApplicationArea = All;
                }
                field("paymentTerms"; Rec."Payment Terms Code")
                {
                    ApplicationArea = All;
                }
                field("Payment_Info"; Rec."Payment Information")
                {
                    ApplicationArea = All;
                }
                field("Salesperson"; Rec."Salesperson Code")
                {
                    ApplicationArea = All;
                }
                field("BillToCont"; Rec."Bill-to Contact No.")
                {
                    ApplicationArea = All;
                }
                field(CCCharge; CCCharge)
                {
                    ApplicationArea = All;
                }
                field("NavPortalRef"; Rec."Nav Portal Reference")
                {
                    ApplicationArea = All;
                }
                field("DueDate"; Rec."Due Date")
                {
                    ApplicationArea = All;
                }
                field("DocumentDate"; Rec."Document Date")
                {
                    ApplicationArea = All;
                }
                field("BillCustName"; Rec."Bill-to Name")
                {
                    ApplicationArea = All;
                }
                field("BillPincode"; Rec."Bill-to Post Code")
                {
                    ApplicationArea = All;
                }
                field("BillCity"; Rec."Bill-to City")
                {
                    ApplicationArea = All;
                }
                field("BillState"; Rec."Bill-to County")
                {
                    ApplicationArea = All;
                }
                field("BillAdd1"; Rec."Bill-to Address")
                {
                    ApplicationArea = All;
                }
                field("BillAdd2"; Rec."Bill-to Address 2")
                {
                    ApplicationArea = All;
                }
                field("BookerMail"; Rec."Booker Email")
                {
                    ApplicationArea = All;
                }
                field(_Payment; Payment)
                {
                    ApplicationArea = All;
                }
                field(PASAmt; PASAmt)
                {
                    ApplicationArea = All;
                }
                field(salesEmail; SalesEmail)
                {
                    ApplicationArea = All;
                }
                field("VatRegNo"; Rec."VAT Registration No.")
                {
                    ApplicationArea = All;
                }
                field("PriceIncVAT"; Rec."Prices Including VAT")
                {
                    ApplicationArea = All;
                }
                field("FinanceMail"; Rec."Account Email")
                {
                    ApplicationArea = All;
                }
                field("customPer"; Rec."Percentage Custom")
                {
                    ApplicationArea = All;
                }
                field("WebPricePer"; Rec."Percentage of Web Price")
                {
                    ApplicationArea = All;
                }
                field("KP"; Rec."Knowledge Pass")
                {
                    ApplicationArea = All;
                }
                field("fp6"; Rec."Flexi Pass 2")
                {
                    ApplicationArea = All;
                }
                field("fp12"; Rec."Flexi Pass 12")
                {
                    ApplicationArea = All;
                }
                field("fp2"; Rec."Flexi Pass")
                {
                    ApplicationArea = All;
                }
                field(ref; ref)
                {
                    ApplicationArea = All;
                }
                field("Currency"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    var
        CCCharge: Integer;
        ref: text[250];
        Payment: Integer;
        SalesEmail: Text[50];
        PASAmt: Text[250];
}
