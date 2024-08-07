//NB 310724 - Autopost all bank acc transactions
xmlport 70004 "Bank Transactions Import "
{
    Caption = 'Bank Transactions Import';
    Direction = Import;
    Format = VariableText;
    TextEncoding = UTF8;
    FieldSeparator = '<TAB>';
    UseRequestPage = false;

    schema
    {
        textelement(Root)
        {
            tableelement(BTIB; "Bank Transaction Import Buffer")
            {
                UseTemporary = true;
                fieldelement(Date; BTIB."Date")
                {
                    MinOccurs = zero;
                }
                fieldelement(CurrencyCode; BTIB."Currency Code")
                { }
                fieldelement(BankAccNo; BTIB."Bank Acc. No.")
                { }
                textelement(AccountName)
                { }
                fieldelement(Information; BTIB.Information)
                {
                    MinOccurs = zero;
                }
                fieldelement(Amount; BTIB.Amount)
                {
                    MinOccurs = zero;
                }
                fieldelement(Card; BTIB.Card)
                {
                    MinOccurs = zero;
                }
                fieldelement(Exclude; BTIB.Exclude)
                {
                    MinOccurs = zero;
                }
                fieldelement(BounceBacks; BTIB.BounceBacks)
                {
                    MinOccurs = zero;
                }
                trigger OnAfterInitRecord()
                var
                    myInt: Integer;
                begin
                    EntryNo += 1;
                    BTIB."Entry No." := EntryNo;
                end;

                trigger OnBeforeInsertRecord()
                var
                    bankAccounts: Record "Bank Account";
                    company: Record Company;
                    bankAccFound: boolean;
                begin
                    bankAccFound := false;
                    if company.FindFirst() then
                        repeat
                            bankAccounts.Reset();
                            bankAccounts.ChangeCompany(company.Name);
                            bankAccounts.SetFilter("Bank Account No.", '%1', BTIB."Bank Acc. No.");
                            if bankAccounts.FindFirst() then begin
                                bankAccFound := True;
                                Rec_BTIB.Reset();
                                Rec_BTIB.ChangeCompany(company.Name);
                                if Rec_BTIB.FindLast() then EntryNum := Rec_BTIB."Entry No." + 1;
                                Rec_BTIB.SetFilter(Date, '%1', BTIB.Date);
                                Rec_BTIB.SetFilter(Information, '%1', BTIB.Information);
                                Rec_BTIB.SetFilter(Amount, '%1', BTIB.Amount);
                                IF Rec_BTIB.findfirst THEN ERROR(STRSUBSTNO(ErrTxt0001), Rec_BTIB."Entry No.");
                                BTIBuf.ChangeCompany(company.Name);
                                BTIBuf.Init();
                                BTIBuf."Entry No." := EntryNum;
                                BTIBuf.Date := BTIB.Date;
                                if BTIB."Currency Code" <> '' then
                                    BTIBuf."Currency Code" := BTIB."Currency Code";
                                BTIBuf.Information := BTIB.Information;
                                BTIBuf.Amount := BTIB.Amount;
                                IF BTIBuf.Amount > 0 THEN
                                    BTIBuf."Transaction Type" := BTIBuf."Transaction Type"::"Paid-In"
                                ELSE
                                    BTIBuf."Transaction Type" := BTIBuf."Transaction Type"::"Paid-Out";
                                BTIBuf.Card := BTIB.Card;
                                BTIBuf.Exclude := BTIB.Exclude;
                                BTIBuf.BounceBacks := BTIB.BounceBacks;
                                BTIBuf.Processed := False;
                                BTIBuf."Entry Matched" := False;
                                BTIBuf."Payment Journal Created" := False;
                                BTIBuf."Document Posted" := False;
                                BTIBuf."Payment Applied" := False;
                                BTIBuf."Bank Acc. No." := BTIB."Bank Acc. No.";
                                BTIBuf.Insert();
                                count += 1;
                            end;
                        until company.Next() = 0;
                    if not bankAccFound then Error('Unable to find Bank Account No : %1 ', BTIB."Bank Acc. No.");
                end;
            }
        }
    }
    trigger OnPostXmlPort()
    begin
        Message('%1 lines imported successfully.', count);
    end;

    var
        Rec_BTIB: Record "Bank Transaction Import Buffer";
        ErrTxt0001: Label 'Duplicate Record Exists, Previously Imported; Verify File.\\ Record ID: %1: Already Exist in the System';
        EntryNo: Integer;
        EntryNum: Integer;
        BTIBuf: record "Bank Transaction Import Buffer";
        count: integer;
}
