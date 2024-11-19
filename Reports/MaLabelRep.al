report 70003 MALabelReport
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    ProcessingOnly = true;


    requestpage
    {
        AboutTitle = 'Teaching tip title';
        AboutText = 'Teaching tip content';
        layout
        {
            area(Content)
            {
                group(Filters)
                {
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

    trigger OnPreReport()
    begin
        malabel(FromDate, ToDate);
    end;

    procedure malabel(Sdate: date; Edate: Date)
    var
        GLAcc, GLAcc1 : record "G/L Account";
        Comp: Record Company;
        AmountInCurrencyNew: report AmountInCurrencyNew;
        Amount: Decimal;
        Total: decimal;
    begin
        CreateHeadersForMALABEL();
        GLAcc.ChangeCompany('The Knowledge Academy Limited');
        GLAcc.setfilter("MA Label", '<>%1', '');
        if GLAcc.FindFirst() then
            repeat
                Total := 0;
                ExcelBuffer.NewRow();
                ExcelBuffer.AddColumn(GLAcc."No.", false, '', True, false, false, '', ExcelBuffer."Cell Type"::Text);
                if comp.FindFirst() then
                    repeat
                        GLAcc1.ChangeCompany(comp.Name);
                        if GLAcc1.Get(GLAcc."No.") then begin
                            GLAcc1.SetRange("Date Filter", Sdate, Edate);
                            GLAcc1.CalcFields("Net Change");
                            Amount := Round(AmountInCurrencyNew.ConvertToGBP(Comp.Name, GLAcc1."Net Change", Today, 'GBP'), 1, '=');
                            if amount <> 0 then
                                ExcelBuffer.AddColumn(Amount, false, '', false, false, false, '', ExcelBuffer."Cell Type"::number)
                            else
                                ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                            Total += Amount;
                        end else
                            ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    until comp.next() = 0;
                GLAcc1.ChangeCompany(comp.Name);
                if Total <> 0 then
                    ExcelBuffer.AddColumn(Total, false, '', false, false, false, '', ExcelBuffer."Cell Type"::number)
                else
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
            until GLAcc.Next() = 0;
        ExcelBuffer.CreateNewBook('MA Label');
        ExcelBuffer.WriteSheet('MA Label', CompanyName, UserId);
        ExcelBuffer.SetFriendlyFilename('MA Label ' + Format(Sdate) + '..' + Format(Edate));
        ExcelBuffer.CloseBook();
        ExcelBuffer.OpenExcel();
    end;

    local procedure CreateHeadersForMALABEL()
    var
        Comp: record Company;
        AmountInCurrencyNew: report AmountInCurrencyNew;
    begin
        ExcelBuffer.Reset();
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        if Comp.FindFirst() then
            repeat
                ExcelBuffer.AddColumn(AmountInCurrencyNew.GetCompanyShortName(Comp.Name), false, '', True, false, false, '', ExcelBuffer."Cell Type"::Text);
            until comp.next() = 0;
        ExcelBuffer.AddColumn('Total', false, '', True, false, false, '', ExcelBuffer."Cell Type"::Text);
    end;


    var
        ExcelBuffer: record "Excel Buffer" temporary;
        FromDate: date;
        ToDate: date;
}