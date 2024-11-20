report 70001 AmountInCurrencyNew
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultLayout = Excel;
    ExcelLayout = '.\Reports\TestRep1.xlsx';
    Caption = 'Amount in Diff Currency New';
    dataset
    {
        dataitem("G/L Account"; "G/L Account")
        {
            DataItemTableView = where("MA Label" = filter(<> ''));

            dataitem(Company; Company)
            {

                dataitem("G/L Account1"; "G/L Account")
                {
                    dataitem("G/L Entry"; "G/L Entry")
                    {
                        trigger OnPreDataItem()
                        begin
                            ChangeCompany(Company.name);
                            SetFilter("G/L Account No.", '%1', "G/L Account1"."No.");
                            SetRange("Posting Date", FromDate, ToDate);
                        end;

                        trigger OnAfterGetRecord()
                        var
                            EntryNo: Integer;
                        begin
                            "G/L Entry_Temp".Reset();
                            "G/L Entry_Temp".SetFilter("G/L Account No.", '%1', "G/L Account No.");
                            "G/L Entry_Temp".SetFilter("Source Type", '%1', "Source Type");
                            "G/L Entry_Temp".SetFilter("Source No.", '%1', "Source No.");
                            "G/L Entry_Temp".SetFilter(Description, '%1', "G/L Account1".CurrentCompany);
                            if "G/L Entry_Temp".FindFirst() then begin
                                "G/L Entry_temp".Amount += "G/L Entry".Amount;
                                "G/L Entry_Temp"."Original Amount (Custom)" += Round(ConvertToGBP("G/L Account1".CurrentCompany, "G/L Entry".Amount, TODAY, CurrencyCode), 1, '=');
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
                                "G/L Entry_Temp"."Original Amount (Custom)" := Round(ConvertToGBP("G/L Account1".CurrentCompany, "G/L Entry".Amount, TODAY, CurrencyCode), 1, '=');
                                "G/L Entry".CalcFields("Purchase Description");
                                "G/L Entry_Temp"."Comment" := "G/L Entry"."Purchase Description"; //for purchase description
                                "G/L Entry_Temp".Description := "G/L Account1".CurrentCompany; // for current company
                                "G/L Entry_Temp"."Comment Cust" := GetSourceName("G/L Account1".CurrentCompany, "G/L Entry_Temp"."Source Type", "G/L Entry_Temp"."Source No.");
                                "G/L Entry_Temp".Insert();
                            end;
                        end;
                    }

                    trigger OnPreDataItem()
                    begin
                        ChangeCompany(Company.Name);
                        SetFilter("No.", '%1', "G/L Account"."No.");
                    end;

                }
            }
        }
        dataitem("G/L Entry_Temp"; "G/L Entry")
        {

            UseTemporary = true;
            column(Company_Name; GetCompanyShortName("G/L Entry_Temp".Description))
            { }
            column(G_L_Account_No_; "G/L Account No.")
            { }
            column(Source_Type; "Source Type")
            { }
            column(Source_No_; "Source No.")
            { }
            column(SourceName; "Comment Cust")
            { }
            column(Purchase_Description; Comment)
            { }
            column(Amount; Amount)
            { }
            column("Amount_Converted"; "Original Amount (Custom)")
            { }

            trigger OnPreDataItem()
            var
                myInt: Integer;
            begin

            end;
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Filters)
                {
                    field(CurrencyCode; CurrencyCode)
                    {
                        TableRelation = Currency;
                        ApplicationArea = All;
                    }
                    field(FromDate; FromDate)
                    {
                        ApplicationArea = All;
                    }
                    field(ToDate; ToDate)
                    {
                        ApplicationArea = All;
                    }


                }
            }
        }


    }



    trigger OnInitReport()
    begin
        CurrencyCode := 'GBP';
        FromDate := CalcDate('-CM', TODAY);
        ToDate := CalcDate('CM', Today);
    end;

    local procedure GetSourceName(CompName: text; SourceType: enum "Gen. Journal Source Type";
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
                    Customer.ChangeCompany(CompName);
                    if Customer.get(SourceNo) then exit(Customer.Name);
                end;
            SourceType::Vendor:
                begin
                    Vendor.Reset();
                    Vendor.ChangeCompany(CompName);
                    if Vendor.get(SourceNo) then exit(Vendor.Name);
                end;
            else
                exit('');
        end;
    end;

    procedure ConvertToGBP(Name: text[50]; lcyamt: decimal; Sdate: date; Currency: Code[10]): decimal
    var
        CurrencyExchange: record "Currency Exchange Rate";
        gbpamt: Decimal;
    begin
        CurrencyExchange.ChangeCompany(Name);
        CurrencyExchange.setrange(CurrencyExchange."Currency Code", Currency);
        CurrencyExchange.setfilter(CurrencyExchange."Starting Date", '%1..', sdate);
        if CurrencyExchange.FindFirst() then begin
            gbpamt := lcyamt / CurrencyExchange."Relational Exch. Rate Amount";
            exit(gbpamt);
        end else begin
            CurrencyExchange.SetRange("Starting Date");
            if CurrencyExchange.FindLast() then begin
                gbpamt := lcyamt / CurrencyExchange."Relational Exch. Rate Amount";
                exit(gbpamt);
            end;
        end;
    end;



    procedure GetCompanyShortName(Name: text): text
    var
    begin
        case Name of
            'Best Practice Training Ltd.':
                exit('BPT');
            'Datrix Learning Services Ltd.':
                exit('DT');
            'ITIL Training Academy':
                exit('ITIL');
            'MPES':
                Exit('MPES');
            'Oakwood':
                exit('OT');
            'Oakwood Dubai':
                exit('OD');
            'Pearce Mayfield Train Dubai':
                exit('PMTD');
            'Pearce Mayfield Training Ltd':
                exit('PMT');
            'Pentagon Leisure Services Ltd':
                exit('PT');
            'Silicon Beach Training':
                exit('SBT');
            'The Knowledge Academy FreeZone':
                exit('TKA FZE');
            'The Knowledge Academy Inc':
                exit('TKA US');
            'The Knowledge Academy Limited':
                exit('TKA UK');
            'The Knowledge Academy Pty Ltd.':
                exit('TKA AU');
            'The Knowledge Academy SA':
                exit('TKA SA');
            'TKA Canada Corporation':
                exit('TKA CA');
            'TKA Europe':
                exit('TKA EU');
            'TKA Hong Kong Ltd.':
                exit('TKA HK');
            'TKA India':
                exit('TKA IN');
            'TKA New Zealand Ltd.':
                exit('TKA NZ');
            'TKA Singapore PTE Ltd.':
                exit('TKA SG');
        end;
    end;

    var
        CurrencyCode: Code[10];
        TestRevenue: codeunit testrevenue;
        FromDate: date;
        ToDate: date;

}