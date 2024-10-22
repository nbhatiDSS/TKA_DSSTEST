page 71008 "Sales Header TEST"
{
    APIGroup = 'API';
    APIPublisher = 'Direction_Software_LLP';
    APIVersion = 'v2.0';
    ApplicationArea = All;
    Caption = 'sales Orders';
    DelayedInsert = true;
    EntityName = 'SalesHeaders';
    EntitySetName = 'SalesHeader';
    PageType = API;
    SourceTable = "Sales Header";
    ODataKeyFields = "Document Type", "No.";


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
                field("Salesperson"; SalesPersonCode)
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
                field("PartialPayment"; Rec."Partial Payment")
                {
                    ApplicationArea = All;
                }
                field("FullPayment"; Rec."Full Payment")
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
                //Pass Ref
                field(ref; ref)
                {
                    ApplicationArea = All;
                }
                field(PASAmt; PASAmt)
                {
                    ApplicationArea = All;
                }
                //Pass Ref
                field("Currency"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                }
                field("BookerMail"; rec."Booker Email")
                {
                    ApplicationArea = All;
                }
                field("FinanceMail"; rec."Account Email")
                {
                    ApplicationArea = All;
                }
                field(Complimentary; rec.Complimentary)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        rec.Validate("Salesperson Code", SalesPersonCode);
        rec."Created By API" := true;
    end;




    trigger OnAfterGetCurrRecord()
    begin
        SalesPersonCode := Rec."Salesperson Code";
    end;

    trigger OnModifyRecord(): Boolean
    begin
        CreateModifyPassRef(ref, PASAmt);
    end;

    local procedure CreateModifyPassRef(PasRef: text[250]; passAmt: Text[250])
    var
        PassRefList: list of [text];
        PassAmtList: list of [text];
        ArrayLen: Integer;
        i: Integer;
        GlobalIris, GlobalIris2 : Record GlobalIRIS;
        lineno: integer;
        Amt: decimal;
    begin
        i := 1;
        if (ref <> '') AND (PASAmt <> '') AND (Rec."No." <> '') then begin
            GlobalIris.SetCurrentKey("PAS Ref No.");
            GlobalIris.SETRANGE(GlobalIris."SalesOrder No.", rec."No.");
            IF GlobalIris.FINDSET THEN GlobalIris.DELETEALL;

            PassRefList := PasRef.Split(',');
            PassAmtList := passAmt.Split(',');
            ArrayLen := PassRefList.Count;
            while i <= ArrayLen do begin
                GlobalIris.reset;
                GlobalIris.SetFilter("PAS Ref No.", '%1', PassRefList.get(i));
                IF GlobalIris.FINDFIRST THEN ERROR('PAS Ref No already used %1', PassRefList.Get(i));

                GlobalIris2.RESET;
                GlobalIris2.SETRANGE(GlobalIris2."SalesOrder No.", rec."No.");
                IF GlobalIris2.FINDLAST THEN
                    lineno := GlobalIris2."Line No." + 10000
                ELSE
                    lineno := 10000;
                GlobalIris.INIT;
                GlobalIris.VALIDATE("SalesOrder No.", rec."No.");
                GlobalIris.VALIDATE("Line No.", lineno);
                GlobalIris.INSERT;
                GlobalIris.VALIDATE("PAS Ref No.", PassRefList.Get(i));
                Evaluate(Amt, PassAmtList.Get(i));
                GlobalIris.VALIDATE(GlobalIris."Amt Received", Amt);
                GlobalIris.MODIFY;
                i += 1;
            end;

        end;
    end;

    var
        CCCharge: Integer;
        ref: text[250];
        Payment: Integer;
        SalesEmail: Text[50];
        PASAmt: Text[250];
        SalesPersonCode: Code[20];
        bookerEmail: text[80];
        FinanceEmail: text[80];
}
