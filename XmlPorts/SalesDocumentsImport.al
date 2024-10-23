xmlport 70001 ImportSalesDocuments
{


    Format = VariableText;
    Direction = Import;
    TextEncoding = UTF8;
    UseRequestPage = false;


    schema
    {
        textelement(Root)
        {
            tableelement(Integer; Integer)
            {
                AutoSave = false;
                AutoReplace = false;
                AutoUpdate = false;

                textelement(YourRef)
                {
                    MinOccurs = Zero;
                }
                textelement(DocType)
                {
                    MinOccurs = Zero;
                }
                textelement(CustomerNo)
                {
                    MinOccurs = Zero;
                }
                textelement(OrderDate)
                {
                    MinOccurs = Zero;
                }
                textelement(DocDate)
                {
                    MinOccurs = Zero;
                }
                textelement(PostingDate)
                {
                    MinOccurs = Zero;
                }
                textelement(BookerEmail)
                {
                    MinOccurs = Zero;
                }
                textelement(FinanceEmail)
                {
                    MinOccurs = Zero;
                }
                textelement(salesPersonCode)
                {
                    MinOccurs = Zero;
                }
                textelement(PaymentTerms)
                {
                    MinOccurs = Zero;
                }
                textelement(PaymentType)
                {
                    MinOccurs = Zero;
                }

                textelement(GLAccNo)
                {
                    MinOccurs = Zero;
                }
                textelement(Desc)
                {
                    MinOccurs = Zero;
                }
                textelement(Qty)
                {
                    MinOccurs = Zero;
                }
                textelement(UnitCost)
                {
                    MinOccurs = Zero;
                }
                textelement(VATProd)
                {
                    MinOccurs = Zero;
                }
                textelement(VATDiff)
                {
                    MinOccurs = Zero;
                }

                trigger OnBeforeInsertRecord()
                var
                    SalesHeader: record "Sales Header";
                begin
                    SalesHeader := GetSalesDocument();
                    InsertSalesLines(SalesHeader);
                end;
            }
        }
    }
    local procedure InsertSalesLines(SalesHeader: record "Sales Header")
    var
        SalesLine: record "Sales Line";
        LineNo: Integer;
    begin
        LineNo := 10000;
        SalesLine.SetFilter("Document Type", '%1', SalesHeader."Document Type");
        SalesLine.SetFilter("Document No.", '%1', SalesHeader."No.");
        if SalesLine.FindLast() then LineNo += SalesLine."Line No.";
        SalesLine.Init();
        SalesLine.Validate("Document Type", SalesHeader."Document Type");
        SalesLine.Validate("Document No.", SalesHeader."No.");
        SalesLine.validate("Line No.", LineNo);
        SalesLine.Validate(Type, SalesLine.Type::"G/L Account");
        SalesLine.Validate("No.", GLAccNo);
        SalesLine.Validate("Event Header", 'EVE0000000');
        SalesLine.Validate(Description, Desc);
        Evaluate(varQty, Qty);
        Evaluate(varUnitCost, UnitCost);
        SalesLine.validate("VAT Prod. Posting Group", VATProd);
        SalesLine.Validate(Quantity, varQty);
        SalesLine.Validate("Unit Price", varUnitCost);
        SalesLine.Validate("VAT Difference Reason", VATDiff);
        SalesLine.validate("Contact No.", SalesHeader."Sell-to Contact No.");
        SalesLine.insert(True);
    end;

    local procedure GetSalesDocument(): record "Sales Header";
    var
        Lineno: Integer;
        salesHeader: record "Sales Header";
    begin
        Evaluate(varDocType, DocType);
        salesHeader.SetCurrentKey("Your Reference");
        salesHeader.SetFilter("Your Reference", '%1', YourRef);
        salesHeader.SetFilter("Document Type", '%1', varDocType);
        if salesHeader.FindFirst() then
            exit(salesHeader)
        else begin
            salesHeader.init();
            salesHeader.validate("Document Type", varDocType);
            salesHeader.Insert(True);
            salesHeader.validate("Sell-to Customer No.", CustomerNo);
            salesHeader.validate("Document Date");
            salesHeader.validate("Order Date", EvaluateDate(OrderDate));
            salesHeader.validate("Document Date", EvaluateDate(DocDate));
            salesHeader.validate("Posting Date", EvaluateDate(PostingDate));
            salesHeader.validate("Salesperson Code", salesPersonCode);
            salesHeader.validate("Payment Terms Code", PaymentTerms);
            if Evaluate(PaymentTypeOptions, PaymentType)
             then
                salesHeader.validate("Payment Information", PaymentTypeOptions);
            salesHeader.validate("Authorisation Status", salesHeader."Authorisation Status"::Authorised);
            salesHeader."Booking Confirmed" := True;
            salesHeader."Confirmed on" := today;
            salesHeader."Confirmed by" := UserId;
            salesHeader.validate("Your Reference", YourRef);
            salesHeader.validate("Currency Code", 'GBP');
            salesHeader.validate("Booker Email", BookerEmail);
            salesHeader.validate("Account Email", FinanceEmail);
            // salesHeader.validate();
            if salesHeader."Document Type" = salesHeader."Document Type"::"Credit Memo" then begin
                salesHeader.validate("Reason Code", 'QBCR');
            end;
            salesHeader.Modify();
            exit(salesHeader);
        end;

    end;

    procedure EvaluateDate(DateText: Text): Date
    var
        ResultDate: Date;
    begin
        if Evaluate(ResultDate, DateText) then
            exit(ResultDate)
        else
            Error('Cannot Evaluate Date');
    end;

    var
        varQty: Integer;
        varUnitCost: Decimal;
        varDocType: enum "Sales Document Type";
        // PIxmlport: XmlPort ImportPurchaseInvoices;
        PaymentTypeOptions: Option " ","BACS","Credit Card","Debit Card","Purchase Order","Cheque","Knowledge / Flexi Pass";
}