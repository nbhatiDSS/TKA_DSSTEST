report 70030 AmountInDifferentCurrencyCopy
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultLayout = Excel;
    ExcelLayout = '.\Custom Reports\50030AmountInDiffCurrency.xlsx';
    Caption = 'GLs Report - In Diff Currency';
    ExcelLayoutMultipleDataSheets = false;

    dataset
    {
        dataitem("G/L Account"; "G/L Account")
        {
            RequestFilterFields = "No.";
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
                            "G/L Entry_Temp".SetFilter(Description, '%1', Description);
                            "G/L Entry_Temp".SetFilter("Batch ID", '%', COAExcelRep.GetCompanyShortName(Company.Name)); //State code used for company 
                            if "G/L Entry_Temp".FindFirst() then begin
                                "G/L Entry_temp".Amount += "G/L Entry".Amount;
                                "G/L Entry_Temp"."Original Amount (Custom)" += Round(COAExcelRep.ConvertToGBP("G/L Entry".CurrentCompany, "G/L Entry".Amount, ToDate, CurrencyCode), 1, '=');
                                "G/L Entry_Temp".Modify;
                            end else begin
                                "G/L Entry_Temp".SetRange(Description);
                                if "G/L Entry_Temp".FindFirst() then begin
                                    "G/L Entry_temp".Amount += "G/L Entry".Amount;
                                    "G/L Entry_Temp"."Original Amount (Custom)" += Round(COAExcelRep.ConvertToGBP("G/L Entry".CurrentCompany, "G/L Entry".Amount, ToDate, CurrencyCode), 1, '=');
                                    "G/L Entry_Temp".Modify;
                                end else begin
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
                                    "G/L Entry_Temp"."Original Amount (Custom)" := Round(COAExcelRep.ConvertToGBP("G/L Account1".CurrentCompany, "G/L Entry".Amount, ToDate, CurrencyCode), 1, '=');
                                    "G/L Entry_Temp".Description := Description;
                                    "G/L Entry".CalcFields("Purchase Description");
                                    "G/L Entry_Temp"."Comment" := "G/L Entry"."Purchase Description"; //for purchase description
                                    "G/L Entry_Temp"."Batch ID" := COAExcelRep.GetCompanyShortName("G/L Entry".CurrentCompany); //For current company
                                    "G/L Entry_Temp"."Comment Cust" := GetSourceName("G/L Account1".CurrentCompany, "G/L Entry_Temp"."Source Type", "G/L Entry_Temp"."Source No.");
                                    "G/L Entry_Temp".Insert();
                                end;
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
        dataitem(Integer; Integer)
        {
            MaxIteration = 1;

            column(FromDate; FromDate)
            { }
            column(ToDate; ToDate)
            { }
        }
        dataitem("G/L Entry_Temp"; "G/L Entry")
        {
            UseTemporary = true;
            column(Company_Name; "Batch ID")
            { }
            column(G_L_Account_No_; "G/L Account No.")
            { }
            column(Source_Type; "Source Type")
            { }
            column(Source_No_; "Source No.")
            { }
            column(SourceName; "Comment Cust")
            { }
            column(Description; Description)
            { }
            column(Purchase_Description; Comment)
            { }
            column(Amount; Amount)
            { }
            column("Amount_Converted"; "Original Amount (Custom)")
            { }
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

    var
        CurrencyCode: Code[10];
        TestRevenue: codeunit testrevenue;
        FromDate: date;
        ToDate: date;
        COAExcelRep: Report COAExcelReports;
        t: Text;

}