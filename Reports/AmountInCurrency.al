report 70000 AmountInDifferentCurrency
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultLayout = Excel;
    ExcelLayout = '.\Reports\TestRep.xlsx';
    Caption = 'Amount in Diff Currency';

    dataset
    {
        dataitem("G/L Entry"; "G/L Entry")
        {
            RequestFilterFields = "G/L Account No.", "Posting Date";

            trigger OnAfterGetRecord()
            var
                EntryNo: Integer;
            begin
                "G/L Entry_Temp".Reset();
                "G/L Entry_Temp".SetFilter("G/L Account No.", '%1', "G/L Account No.");
                "G/L Entry_Temp".SetFilter("Source Type", '%1', "Source Type");
                "G/L Entry_Temp".SetFilter("Source No.", '%1', "Source No.");
                if "G/L Entry_Temp".FindFirst() then begin
                    "G/L Entry_temp".Amount += "G/L Entry".Amount;
                    "G/L Entry_Temp"."Original Amount (Custom)" += ConvertToGBP("G/L Entry".Amount, "G/L Entry"."Posting Date");
                    "G/L Entry_Temp".Modify;
                end
                else begin
                    "G/L Entry_Temp".Reset();
                    if "G/L Entry_Temp".FindLast() then
                        EntryNo := "G/L Entry_Temp"."Entry No." + 1
                    else
                        EntryNo := 1;
                    "G/L Entry_Temp".Init();
                    "G/L Entry_Temp"."Entry No." := EntryNo;
                    "G/L Entry_Temp"."G/L Account No." := "G/L Entry"."G/L Account No.";
                    "G/L Entry_Temp".Amount := "G/L Entry".Amount;
                    "G/L Entry_Temp"."Source Type" := "G/L Entry"."Source Type";
                    "G/L Entry_Temp"."Source No." := "G/L Entry"."Source No.";
                    "G/L Entry_Temp"."Original Amount (Custom)" := ConvertToGBP("G/L Entry".Amount, "G/L Entry"."Posting Date");
                    "G/L Entry_Temp"."Purchase Description" := "G/L Entry"."Purchase Description";
                    "G/L Entry_Temp".Insert();
                end;
            end;
        }
        dataitem("G/L Entry_Temp"; "G/L Entry")
        {
            UseTemporary = true;

            column(G_L_Account_No_; "G/L Account No.")
            { }
            column(Source_Type; "Source Type")
            { }
            column(Source_No_; "Source No.")
            { }
            column(SourceName; GetSourceName("G/L Entry_Temp"."Source Type", "G/L Entry_Temp"."Source No."))
            { }
            column(Purchase_Description; "Purchase Description")
            {

            }
            column(Amount; Amount)
            { }
            column("AmountConverted"; "Original Amount (Custom)")
            { }
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Currency)
                {
                    field(CurrencyCode; CurrencyCode)
                    {
                        TableRelation = Currency;
                    }
                }
            }
        }
    }

    trigger OnInitReport()
    begin
        CurrencyCode := 'GBP';
    end;

    procedure ConvertToGBP(lcyamt: decimal; Sdate: date): decimal
    var
        CurrencyExchange: record "Currency Exchange Rate";
        gbpamt: Decimal;
    begin
        CurrencyExchange.setrange(CurrencyExchange."Currency Code", CurrencyCode);
        CurrencyExchange.setfilter(CurrencyExchange."Starting Date", '<=%1', Sdate);
        if CurrencyExchange.findlast then begin
            gbpamt := lcyamt / CurrencyExchange."Relational Exch. Rate Amount";
            exit(gbpamt);
        end;
    end;

    local procedure GetSourceName(SourceType: enum "Gen. Journal Source Type";
                                                  SourceNo: Code[20]): text[100]
    var
        Customer: record Customer;
        Vendor: record Vendor;
    begin
        case
            SourceType of
            SourceType::Customer:
                begin
                    Customer.Reset();
                    if Customer.get(SourceNo) then exit(Customer.Name);
                end;
            SourceType::Vendor:
                begin
                    Vendor.Reset();
                    if Vendor.get(SourceNo) then exit(Vendor.Name);
                end;
            else
                exit('');
        end;
    end;

    var
        GLE: record "G/L Entry";
        CurrencyCode:
                code[10];
}