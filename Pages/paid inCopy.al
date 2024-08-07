page 70081 "Bank Transactions Paid-In "
{
    // //DOC TKA_200611 - created

    DeleteAllowed = false;
    InsertAllowed = true;
    PageType = List;
    SourceTable = 50074;
    SourceTableView = sorting(Date) order(descending);
    ApplicationArea = all;
    // UsageCategory = Lists;
    ModifyAllowed = true;
    layout
    {
        area(content)
        {
            repeater(repeater)
            {


                field(Date; rec.Date)
                {
                }
                field(Information; rec.Information)
                {
                }
                field("Additional Information"; rec."Additional Information")
                {
                    Editable = false;
                }
                field("Credit Card Owner"; rec."Credit Card Owner")
                {
                }
                field("Bill-to Customer No."; rec."Bill-to Customer No.")
                {

                    trigger OnValidate()
                    begin
                        Customer.RESET;
                        IF rec."Bill-to Customer No." <> '' THEN
                            Customer.GET(rec."Bill-to Customer No.");
                        gl.GET;
                        IF Customer."Currency Code" <> '' THEN BEGIN
                            IF Customer."Currency Code" <> gl."LCY Code" THEN
                                ERROR('Different Customer code');

                        END;
                        //BilltoCustomerNoOnAfterValidate;
                    end;
                }
                field("Bill-to Name"; rec."Bill-to Name")
                {
                }
                field(Amount; rec.Amount)
                {
                    Caption = 'Payment Amount';
                    Style = Strong;
                }
                field("Bank Acc. Name"; Rec."Bank Acc. Name")
                {
                    ApplicationArea = All;
                }

                field(Exclude; rec.Exclude)
                {
                }
                field(Card; rec.Card)
                {
                }
                field(BounceBacks; rec.BounceBacks)
                {
                }
                field("Currency Code"; rec."Currency Code")
                {
                }
                field("Exchange Rate"; rec."Exchange Rate")
                {
                }
                field("Balance Account"; rec."Balance Account")
                {
                }
                field("CardSave Summary Entry No."; rec."CardSave Summary Entry No.")
                {
                    Editable = false;
                    Visible = false;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        lCardsaveSummary: Record "50073";
                        lfrmCardsaveSummaryList: Page "50086";
                    begin
                        IF rec."Balance Account" <> rec."Balance Account"::CardSave THEN
                            ERROR(ErrTxt004);
                        IF rec."CardSave Summary Entry No." = 0 THEN BEGIN
                            lCardsaveSummary.SETRANGE("BTIB Entry No.", 0);
                            IF lCardsaveSummary.ISEMPTY THEN
                                ERROR(ErrTxt003);
                            lfrmCardsaveSummaryList.SETTABLEVIEW(lCardsaveSummary);
                            lfrmCardsaveSummaryList.EDITABLE(FALSE);
                            lfrmCardsaveSummaryList.LOOKUPMODE(TRUE);
                            lfrmCardsaveSummaryList.SetBTIB(Rec);
                            IF lfrmCardsaveSummaryList.RUNMODAL = ACTION::LookupOK THEN BEGIN
                                lfrmCardsaveSummaryList.GETRECORD(lCardsaveSummary);
                                lCardsaveSummary."BTIB Entry No." := rec."Entry No.";
                                lCardsaveSummary."Matched/Un-Matched by" := USERID;
                                lCardsaveSummary."Matched/Un-Matched on" := TODAY;
                                lCardsaveSummary."Matched/Un-Matched at" := TIME;
                                lCardsaveSummary.MODIFY;
                                rec."CardSave Summary Entry No." := lCardsaveSummary."Entry No.";
                            END;
                        END ELSE BEGIN
                            lCardsaveSummary.SETRANGE("Entry No.", rec."CardSave Summary Entry No.");
                            IF lCardsaveSummary.ISEMPTY THEN
                                ERROR(ErrTxt003);
                            lfrmCardsaveSummaryList.SETTABLEVIEW(lCardsaveSummary);
                            lfrmCardsaveSummaryList.EDITABLE(FALSE);
                            lfrmCardsaveSummaryList.LOOKUPMODE(TRUE);
                            lfrmCardsaveSummaryList.SetBTIB(Rec);
                            lfrmCardsaveSummaryList.RUNMODAL;
                        END;
                        CurrPage.UPDATE;
                    end;
                }
                field("CardSave Summary Total Amount"; rec."CardSave Summary Total Amount")
                {
                    Visible = false;
                }
                field("Entry Matched"; rec."Entry Matched")
                {
                    Visible = true;
                }
                field("Transaction Type"; rec."Transaction Type")
                {
                    Visible = true;
                }
                field("Process Manually"; rec."Process Manually")
                {
                    Visible = true;
                }
                field("Create Payment Journal"; rec."Create Payment Journal")
                {
                    Visible = true;
                }
                field("Payment Journal Created"; rec."Payment Journal Created")
                {
                    Editable = false;
                    visible = true;
                }
                field("No. of Entries"; rec."No. of Entries")
                {
                    //Blankzero = true;
                    Caption = 'No. of Docs';
                }
                field("Close To-do"; rec."Close To-do")
                {
                }
                field("Total Sales Amount"; rec."Total Sales Amount")
                {
                    //Blankzero = true;
                    Caption = 'Order/ Invoice Amount';
                    Style = Strong;
                }
                field("All Documents Posted"; rec."All Documents Posted")
                {
                    Caption = 'All Docs Posted';
                }
                field("All Payments Applied"; rec."All Payments Applied")
                {
                    Caption = 'All Pmts. Applied';
                }
                field(Notes; rec.Notes)
                {
                }
                field(Processed; rec.Processed)
                {
                    Editable = false;
                }
                field("Error Text"; rec."Error Text")
                {
                    Style = Unfavorable;
                    //Style = Attention;
                    StyleExpr = TRUE;
                }
            }
            field("<Error Text>1"; rec."Error Text")
            {
                Editable = false;
                MultiLine = true;
                Style = Attention;
                StyleExpr = TRUE;

            }
            part(sf; 50080)
            {
                Caption = 'Linked Documents';
                Editable = sfEditable;
                SubPageLink = "Entry No." = FIELD("Entry No.");
            }
            // field(Text19072904; '')
            // {
            //     CaptionClass = Text19072904;
            // }
        }
    }

    actions
    {
        area(processing)
        {
            action("Not Processed")
            {
                Caption = 'Not Processed';
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    rec.SETRANGE(Processed, FALSE);
                end;
            }
            action("Not Matched")
            {
                Caption = 'Not Matched';
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    rec.SETRANGE("Entry Matched", FALSE);
                end;
            }
            action("Remove Filters")
            {
                Caption = 'Remove Filters';
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    rec.reset;
                    Rec.SETCURRENTKEY("Transaction Type", "Balance Account", "Credit Card", "Entry Matched", Processed);
                    Rec.SETRANGE("Credit Card", FALSE);
                    Rec.SETRANGE("Transaction Type", Rec."Transaction Type"::"Paid-In");
                    IF UserSetup."Cash Mgt. User Type" = UserSetup."Cash Mgt. User Type"::Standard THEN
                        Rec.SETRANGE("HR & Accounts", FALSE);
                    rec.SETRANGE("Entry Matched");
                    rec.SETRANGE(Processed);
                    rec.SetCurrentKey(Date);
                    rec.SetAscending(Date, false);
                end;
            }
            group(btnFunctionsStandard)
            {
                Caption = 'Functions';
                Visible = btnFunctionsStandardVisible;
                action("Reset Record ")
                {
                    Caption = 'Reset Record';
                    ApplicationArea = all;
                    trigger OnAction()
                    var
                        lBankTransApp: Record 50079;
                        BTIB: record 50074;
                    begin
                        IF NOT rec.Processed THEN BEGIN

                            IF CONFIRM(TKATxt002, FALSE) THEN BEGIN
                                // BTIB.reset;
                                // BTIB.SetRange("Entry No.", rec."Entry No.");
                                // if BTIB.findfirst then begin
                                rec."Sales Invoice No." := '';
                                rec."Sales Order No." := '';
                                rec."Sales Quote No." := '';
                                rec."Sales Order Posting Date" := 0D;
                                rec."Sales Order Course Date" := 0D;
                                rec."Shortcut Dimension 1 Code" := '';
                                rec."Shortcut Dimension 2 Code" := '';
                                rec."Sales Order Amount" := 0;
                                rec."Warning Amounts Different" := FALSE;
                                rec."Bill-to Customer No." := '';
                                rec."Bill-to Name" := '';
                                rec."Sell-to Contact No." := '';
                                rec."Sell-to Contact Name" := '';
                                rec.Address := '';
                                rec.City := '';
                                rec."Post Code" := '';
                                rec.County := '';
                                rec.Country := '';
                                rec."Phone No." := '';
                                rec."E-Mail Address" := '';
                                rec."Payment Journal Created" := FALSE;
                                rec."Document Posted" := FALSE;
                                rec."Payment Applied" := FALSE;
                                rec."Error Text" := '';
                                rec."Payment Ledger Entry No." := 0;
                                rec."Document Ledger Entry No." := 0;
                                lBankTransApp.SETRANGE("Entry No.", rec."Entry No.");
                                lBankTransApp.DELETEALL(TRUE);
                                rec.MODIFY;
                                // CurrPage.Update(True);
                                COMMIT;
                                // End;
                            END;

                        END ELSE
                            ERROR(ErrTxt001);
                    end;
                }
            }
            group(btnFunctionsMain)
            {
                Caption = 'Functions';
                Visible = btnFunctionsMainVisible;
                action("Process ALL")
                {
                    Caption = 'Process ALL';

                    trigger OnAction()
                    var
                        lBTIB: Record 50074;
                        lFinanceMgtBTIBIN: Codeunit 50006;
                    begin
                        // IF (COMPANYNAME = 'Pearce Mayfield Train Dubai') OR (COMPANYNAME = 'The Knowledge Academy FreeZone') THEN
                        //     ERROR('Process function is disabled in ' + COMPANYNAME);

                        lBTIB.SETVIEW(RecFilters);
                        lBTIB.SETRANGE("Create Payment Journal", TRUE);
                        IF NOT lBTIB.ISEMPTY THEN BEGIN
                            lBTIB.FINDFIRST;
                            REPEAT
                                lBTIB.MARK(TRUE);
                            UNTIL lBTIB.NEXT = 0;
                        END;

                        lBTIB.SETRANGE("Create Payment Journal");
                        lBTIB.SETRANGE("Payment Journal Created", TRUE);
                        //lBTIB.SETRANGE(Processed,FALSE);
                        //lBTIB.SETRANGE("Credit Card",FALSE);
                        IF NOT lBTIB.ISEMPTY THEN BEGIN
                            lBTIB.FINDFIRST;
                            REPEAT
                                lBTIB.MARK(TRUE);
                            UNTIL lBTIB.NEXT = 0;
                        END;

                        lBTIB.SETRANGE("Payment Journal Created");
                        lBTIB.SETRANGE(Processed);

                        lBTIB.MARKEDONLY(TRUE);

                        lFinanceMgtBTIBIN.BTIB_SetRunMode(0);
                        lFinanceMgtBTIBIN.BTIB_SetValues_0(lBTIB);
                        lFinanceMgtBTIBIN.RUN;
                    end;
                }
                action("Marked as Processed - ALL")
                {
                    Caption = 'Marked as Processed - ALL';

                    trigger OnAction()
                    var
                        BTIB: Record 50074;
                    begin
                        IF CONFIRM('Are you sure you want to Process all payments of which Payment Journal are created?') THEN BEGIN

                            BTIB.RESET;
                            BTIB.SETRANGE(BTIB."Payment Journal Created", TRUE);
                            BTIB.SETRANGE(BTIB.Processed, FALSE);
                            // MESSAGE('%1',BTIB.COUNT);
                            IF BTIB.FINDSET THEN
                                REPEAT
                                    BTIB.Processed := TRUE;
                                    BTIB.MODIFY;
                                UNTIL BTIB.NEXT = 0;
                        END;
                    end;
                }
                action("Selected Lines - Mark Processed")
                {
                    Caption = 'Selected Lines - Mark Processed';

                    trigger OnAction()
                    begin

                        CurrPage.SETSELECTIONFILTER(btib1);
                        a := 0;
                        IF btib1.FINDSET THEN
                            REPEAT
                                btib1.Processed := TRUE;
                                btib1.MODIFY;
                                a += 1
                            UNTIL btib1.NEXT = 0;
                        CurrPage.Update();

                        MESSAGE('%1 transactions marked as processed', a);
                    end;
                }
                action("Mark as &Processed")
                {
                    Caption = 'Mark as &Processed';

                    trigger OnAction()
                    begin
                        IF CONFIRM(TKATxt001, FALSE) THEN BEGIN
                            rec.Processed := TRUE;
                            rec.MODIFY;
                        END;
                        CurrPage.Update();
                    end;
                }
                separator(separator)
                {
                }
                action("Reset Record")
                {
                    Caption = 'Reset Record';

                    trigger OnAction()
                    var
                        lBankTransApp: Record 50079;
                        BTIB: record 50074;
                    begin
                        IF NOT rec.Processed THEN BEGIN
                            IF CONFIRM(TKATxt002, FALSE) THEN BEGIN
                                BTIB.reset;
                                BTIB.SetRange("Entry No.", rec."Entry No.");
                                if BTIB.findfirst then begin
                                    ResetRec(BTIB);
                                    lBankTransApp.SETRANGE("Entry No.", BTIB."Entry No.");
                                    lBankTransApp.DELETEALL(TRUE);

                                    // BTIB."Sales Invoice No." := '';
                                    // BTIB."Sales Order No." := '';
                                    // BTIB."Sales Quote No." := '';
                                    // BTIB."Sales Order Posting Date" := 0D;
                                    // BTIB."Sales Order Course Date" := 0D;
                                    // BTIB."Shortcut Dimension 1 Code" := '';
                                    // BTIB."Shortcut Dimension 2 Code" := '';
                                    // BTIB."Sales Order Amount" := 0;
                                    // BTIB."Warning Amounts Different" := FALSE;
                                    // BTIB."Bill-to Customer No." := '';
                                    // BTIB."Bill-to Name" := '';
                                    // BTIB."Sell-to Contact No." := '';
                                    // BTIB."Sell-to Contact Name" := '';
                                    // BTIB.Address := '';
                                    // BTIB.City := '';
                                    // BTIB."Post Code" := '';
                                    // BTIB.County := '';
                                    // BTIB.Country := '';
                                    // BTIB."Phone No." := '';
                                    // BTIB."E-Mail Address" := '';
                                    // BTIB."Payment Journal Created" := FALSE;
                                    // BTIB."Document Posted" := FALSE;
                                    // BTIB."Payment Applied" := FALSE;
                                    // BTIB."Error Text" := '';
                                    // BTIB."Payment Ledger Entry No." := 0;
                                    // BTIB."Document Ledger Entry No." := 0;
                                    // lBankTransApp.SETRANGE("Entry No.", BTIB."Entry No.");
                                    // lBankTransApp.DELETEALL(TRUE);
                                    // BTIB.MODIFY;
                                    // CurrPage.Update(True);
                                    COMMIT;
                                end;
                            END;
                        END ELSE
                            ERROR(ErrTxt001);
                    end;
                }

                action("<Create Payment &Journal>")
                {
                    Caption = '<Create Payment &Journal>';

                    trigger OnAction()
                    var
                        Customer: Record "18";
                        BankTransactionImportBuffer: Record 50074;
                        GenJournalLine: Record 81;
                        OldGenJournalLine: Record 81;
                        LineNo: Integer;
                    begin
                        OldGenJournalLine."Journal Template Name" := 'CASHRCPT';
                        OldGenJournalLine."Journal Batch Name" := 'BANK';

                        GenJournalLine.INIT;
                        GenJournalLine."Journal Template Name" := 'CASHRCPT';
                        GenJournalLine."Journal Batch Name" := 'BANK';
                        GenJournalLine.SetUpNewLine(OldGenJournalLine, 0, FALSE);

                        BankTransactionImportBuffer.SETRANGE("Transaction Type", BankTransactionImportBuffer."Transaction Type"::"Paid-In");
                        BankTransactionImportBuffer.SETRANGE("Create Payment Journal", TRUE);


                        IF BankTransactionImportBuffer.FINDFIRST THEN
                            REPEAT
                                LineNo += 1000;
                                GenJournalLine.INIT;
                                GenJournalLine."Journal Template Name" := 'CASHRCPT';
                                GenJournalLine."Journal Batch Name" := 'BANK';
                                GenJournalLine.SetUpNewLine(OldGenJournalLine, 0, TRUE);

                                GenJournalLine."Line No." := LineNo;
                                GenJournalLine.VALIDATE("Posting Date", BankTransactionImportBuffer.Date);
                                GenJournalLine.VALIDATE("Document Type", GenJournalLine."Document Type"::Payment);

                                IF BankTransactionImportBuffer."Balance Account" = BankTransactionImportBuffer."Balance Account"::" " THEN BEGIN
                                    GenJournalLine.VALIDATE("Account Type", GenJournalLine."Account Type"::Customer);
                                    GenJournalLine.VALIDATE("Account No.", BankTransactionImportBuffer."Bill-to Customer No.");
                                    GenJournalLine.Description := COPYSTR(GenJournalLine.Description, 1, 35) + ': ' +
                                                                  BankTransactionImportBuffer."Sales Order No.";

                                END;

                                IF BankTransactionImportBuffer."Balance Account" = BankTransactionImportBuffer."Balance Account"::Cheque THEN BEGIN
                                    GenJournalLine.VALIDATE("Account Type", GenJournalLine."Account Type"::"G/L Account");
                                    GenJournalLine.VALIDATE("Account No.", '2901');
                                    Customer.GET(BankTransactionImportBuffer."Bill-to Customer No.");
                                    IF ((rec."Additional Information" <> '') AND
                                        (STRLEN(BankTransactionImportBuffer."Additional Information") > 20)) THEN BEGIN
                                        GenJournalLine.Description := COPYSTR(Customer.Name, 1, 25) + ': ' + BankTransactionImportBuffer."Sales Order No."
                                                                      + '; ' + BankTransactionImportBuffer."Additional Information";
                                    END ELSE
                                        GenJournalLine.Description := COPYSTR(Customer.Name, 1, 39) + ': ' + BankTransactionImportBuffer."Sales Order No.";

                                    GenJournalLine.VALIDATE("Shortcut Dimension 1 Code", 'OPERATING');
                                    GenJournalLine.VALIDATE("Shortcut Dimension 2 Code", 'HEAD OFFICE');

                                END;

                                IF BankTransactionImportBuffer."Balance Account" = BankTransactionImportBuffer."Balance Account"::CardSave THEN BEGIN
                                    GenJournalLine.VALIDATE("Account Type", GenJournalLine."Account Type"::"G/L Account");
                                    GenJournalLine.VALIDATE("Account No.", '2915');
                                    GenJournalLine.Description := BankTransactionImportBuffer.Information;
                                    GenJournalLine.VALIDATE("Shortcut Dimension 1 Code", 'OPERATING');
                                    GenJournalLine.VALIDATE("Shortcut Dimension 2 Code", 'HEAD OFFICE');

                                END;

                                GenJournalLine.VALIDATE(Amount, -BankTransactionImportBuffer.Amount);
                                GenJournalLine.INSERT;
                                GenJournalLine.VALIDATE("Shortcut Dimension 1 Code", BankTransactionImportBuffer."Shortcut Dimension 1 Code");
                                GenJournalLine.VALIDATE("Shortcut Dimension 2 Code", BankTransactionImportBuffer."Shortcut Dimension 2 Code");
                                GenJournalLine.MODIFY;

                                BankTransactionImportBuffer."Create Payment Journal" := FALSE;
                                BankTransactionImportBuffer.Processed := TRUE;
                                BankTransactionImportBuffer.MODIFY;

                                OldGenJournalLine := GenJournalLine;
                            UNTIL BankTransactionImportBuffer.NEXT = 0;
                    end;
                }
                separator(separator3)
                {
                }
                action("Process ONE")
                {
                    Caption = 'Process ONE';

                    trigger OnAction()
                    var
                        lBTIB: Record 50074;
                        lFinanceMgtBTIBIN: Codeunit 50006;
                    begin
                        // IF (COMPANYNAME = 'Pearce Mayfield Train Dubai') OR (COMPANYNAME = 'The Knowledge Academy FreeZone') THEN
                        //     ERROR('Process function is disabled in ' + COMPANYNAME);

                        // IF NOT CONFIRM('Are you sure you wish to process this ONE entry only?', FALSE) THEN
                        //     EXIT;
                        lBTIB.GET(rec."Entry No.");

                        // IF lBTIB."Currency Code" <> '' THEN BEGIN
                        //     IF Customer.GET(lBTIB."Bill-to Customer No.") THEN BEGIN
                        //         IF Customer."Currency Code" <> lBTIB."Currency Code" THEN
                        //             ERROR('Currency code on Customer Card is different , can not post');
                        //     END;
                        // END;

                        // IF lBTIB."Currency Code" = '' THEN BEGIN
                        //     GeneralLedgerSetup.GET;
                        //     IF Customer.GET(lBTIB."Bill-to Customer No.") THEN BEGIN

                        //         IF Customer."Currency Code" <> '' THEN BEGIN
                        //             IF Customer."Currency Code" <> GeneralLedgerSetup."LCY Code" THEN
                        //                 ERROR('Currency code on Customer Card is different , can not post');
                        //         END;
                        //     END;
                        // END;

                        lBTIB.MARK(TRUE);
                        lBTIB.MARKEDONLY(TRUE);
                        lFinanceMgtBTIBIN.BTIB_SetRunMode(0);
                        lFinanceMgtBTIBIN.BTIB_SetValues_0(lBTIB);
                        lFinanceMgtBTIBIN.RUN;
                    end;
                }
                separator(separator4)
                {
                }
                action("Process (Pmt. Only)")
                {
                    Caption = 'Process (Pmt. Only)';

                    trigger OnAction()
                    var
                        lBTIB: Record 50074;
                        lFinanceMgtBTIBIN: Codeunit 50006;
                    begin
                        IF NOT CONFIRM('This option will not post Invoice or Payment Application!\ \Do you still want to Continue?', FALSE) THEN
                            EXIT;
                        lBTIB.SETRANGE("Create Payment Journal", TRUE);
                        IF NOT lBTIB.ISEMPTY THEN BEGIN
                            lBTIB.FINDFIRST;
                            REPEAT

                                IF lBTIB."Currency Code" <> '' THEN BEGIN
                                    IF Customer.GET(lBTIB."Bill-to Customer No.") THEN BEGIN
                                        IF Customer."Currency Code" <> lBTIB."Currency Code" THEN
                                            ERROR('Currency code on Customer Card is different , can not post');
                                    END;
                                END;

                                IF lBTIB."Currency Code" = '' THEN BEGIN
                                    GeneralLedgerSetup.GET;
                                    IF Customer.GET(lBTIB."Bill-to Customer No.") THEN BEGIN

                                        IF Customer."Currency Code" <> '' THEN BEGIN
                                            IF Customer."Currency Code" <> GeneralLedgerSetup."LCY Code" THEN
                                                ERROR('Currency code on Customer Card is different , can not post');
                                        END;
                                    END;
                                END;

                                lBTIB.MARK(TRUE);
                            UNTIL lBTIB.NEXT = 0;
                        END;

                        lBTIB.SETRANGE("Create Payment Journal");
                        lBTIB.SETRANGE("Payment Journal Created", TRUE);
                        lBTIB.SETRANGE(Processed, FALSE);
                        IF NOT lBTIB.ISEMPTY THEN BEGIN
                            lBTIB.FINDFIRST;
                            REPEAT

                                IF lBTIB."Currency Code" <> '' THEN BEGIN
                                    IF Customer.GET(lBTIB."Bill-to Customer No.") THEN BEGIN
                                        IF Customer."Currency Code" <> lBTIB."Currency Code" THEN
                                            ERROR('Currency code on Customer Card is different , can not post');
                                    END;
                                END;

                                IF lBTIB."Currency Code" = '' THEN BEGIN
                                    GeneralLedgerSetup.GET;
                                    IF Customer.GET(lBTIB."Bill-to Customer No.") THEN BEGIN

                                        IF Customer."Currency Code" <> '' THEN BEGIN
                                            IF Customer."Currency Code" <> GeneralLedgerSetup."LCY Code" THEN
                                                ERROR('Currency code on Customer Card is different , can not post');
                                        END;
                                    END;
                                END;

                                lBTIB.MARK(TRUE);
                            UNTIL lBTIB.NEXT = 0;
                        END;

                        lBTIB.SETRANGE("Payment Journal Created");
                        lBTIB.SETRANGE(Processed);

                        lBTIB.MARKEDONLY(TRUE);

                        lFinanceMgtBTIBIN.BTIB_SetRunMode(0);
                        lFinanceMgtBTIBIN.EnablePaymentOnlyMode();
                        lFinanceMgtBTIBIN.BTIB_SetValues_0(lBTIB);
                        lFinanceMgtBTIBIN.RUN;
                    end;
                }
                action("Update information")
                {
                    Caption = 'Update information';

                    trigger OnAction()
                    var
                        lWin: Dialog;
                        lText: Text[100];
                        lBTIB: Record 50074;
                    begin
                        lText := rec.Information;
                        lWin.OPEN('#1###############################################################################################');
                        // abhiIF lWin.INPUT(1,lText)  = 1 THEN BEGIN
                        //   lBTIB.GET(rec."Entry No.");
                        //   lBTIB.VALIDATE(Information,lText);
                        //   lBTIB.MODIFY(TRUE);
                        // END;
                        lWin.CLOSE;
                        CurrPage.UPDATE;
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        lToDO: Record "5080";
    begin
        IF NOT UserSetup.GET(USERID) THEN
            CLEAR(UserSetup);
        IF UserSetup."Cash Mgt. User Type" = UserSetup."Cash Mgt. User Type"::Standard THEN BEGIN
            btnFunctionsStandardVisible := TRUE;
            btnFunctionsMainVisible := FALSE;
            CurrPage.EDITABLE(TRUE);
            sfEditable := TRUE;
        END;
        IF UserSetup."Cash Mgt. User Type" = UserSetup."Cash Mgt. User Type"::Admin THEN BEGIN
            btnFunctionsStandardVisible := FALSE;
            btnFunctionsMainVisible := TRUE;
            CurrPage.EDITABLE(TRUE);
            sfEditable := TRUE;
        END;

        IF rec."Warning Amounts Different" THEN
            ColourValue := 255
        ELSE
            ColourValue := 0;

        IF (rec."Sales Invoice No." <> '') OR (rec."Sales Order No." <> '') THEN BEGIN
            lToDO.SETCURRENTKEY("Contact No.", "Document Type", "Document No.", "System To-do Type", Closed);
            lToDO.SETRANGE("Contact No.", rec."Sell-to Contact No.");
            IF rec."Sales Invoice No." <> '' THEN BEGIN
                lToDO.SETRANGE("Document Type", lToDO."Document Type"::Invoice);
                lToDO.SETRANGE("Document No.", rec."Sales Invoice No.");
            END ELSE BEGIN
                lToDO.SETRANGE("Document Type", lToDO."Document Type"::Order);
                lToDO.SETRANGE("Document No.", rec."Sales Order No.");
            END;
            lToDO.SETRANGE("System To-do Type", lToDO."System To-do Type"::"Contact Attendee");
            ToDoExists := NOT lToDO.ISEMPTY;
            IF ToDoExists THEN BEGIN
                lToDO.FINDFIRST;
                ToDoSalesPerson := lToDO."Salesperson Code";
            END ELSE
                CLEAR(ToDoSalesPerson);
        END ELSE BEGIN
            CLEAR(lToDO);
            CLEAR(ToDoSalesPerson);
        END;
        OnAfterGetCurrRecord;
        AmountOnFormat;
        CardSaveSummaryEntryNoOnFormat;
        //CardSaveSummaryTotalAmountOnFormat;
        TotalSalesAmountOnFormat;
    end;

    trigger OnInit()
    begin
        sfEditable := TRUE;
        btnFunctionsMainVisible := TRUE;
        btnFunctionsStandardVisible := TRUE;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        OnAfterGetCurrRecord;
    end;

    trigger OnOpenPage()
    begin
        IF NOT UserSetup.GET(USERID) THEN
            CLEAR(UserSetup);
        IF UserSetup."Cash Mgt. User Type" = UserSetup."Cash Mgt. User Type"::Standard THEN BEGIN
            btnFunctionsStandardVisible := TRUE;
            btnFunctionsMainVisible := FALSE;
            CurrPage.EDITABLE(TRUE);
            sfEditable := TRUE;
        END;
        IF UserSetup."Cash Mgt. User Type" = UserSetup."Cash Mgt. User Type"::Admin THEN BEGIN
            btnFunctionsStandardVisible := FALSE;
            btnFunctionsMainVisible := TRUE;
            CurrPage.EDITABLE(TRUE);
            sfEditable := TRUE;
        END;
    end;

    var
        UserSetup: Record 91;
        ColourValue: Integer;
        TKATxt001: Label 'Do you want to Mark the Record a Processed?';
        TKATxt002: Label 'Do you want to Reset the Record?\\ You will need to Rematch the Record Again';
        ErrTxt001: Label 'Record Already Processed Cannot be Reset';
        ToDoExists: Boolean;
        ToDoSalesPerson: Code[10];
        RecView1: Text[1024];
        RecView2: Text[1024];
        RecFilters: Text[1024];
        ErrTxt003: Label 'No Entries Found to be Matched';
        ErrTxt004: Label 'Only Entries Cardsave Entries can be Matched';
        Customer: Record "18";
        GeneralLedgerSetup: Record "98";
        gl: Record "98";
        btib1: Record 50074;
        a: Integer;
        //[InDataSet]
        btnFunctionsStandardVisible: Boolean;
        //[InDataSet]
        btnFunctionsMainVisible: Boolean;
        //[InDataSet]
        sfEditable: Boolean;
        Text19072904: Label 'Apply Filters';

    procedure SetFilterView(pRecfilters: Text[1024])
    begin
        RecFilters := pRecfilters;
    end;

    local procedure BilltoCustomerNoOnAfterValidat()
    begin
        rec.CALCFIELDS("Bill-to Name");
    end;

    local procedure OnAfterGetCurrRecord()
    begin
        xRec := Rec;
        IF rec."Warning Amounts Different" THEN
            ColourValue := 255
        ELSE
            ColourValue := 0;
    end;

    local procedure AmountOnFormat()
    begin
        IF rec."Warning Amounts Different" THEN;
    end;

    local procedure CardSaveSummaryEntryNoOnFormat()
    begin
        IF (rec."Balance Account" = rec."Balance Account"::CardSave) AND (rec."CardSave Summary Entry No." <> 0) THEN;
    end;

    local procedure CardSaveSummaryTotalAmountOnFo()
    begin
        IF (rec."Balance Account" = rec."Balance Account"::CardSave) AND (rec."CardSave Summary Entry No." <> 0) THEN;
    end;

    local procedure TotalSalesAmountOnFormat()
    begin
        IF rec."Warning Amounts Different" THEN;
    end;

    local procedure ResetRec(var BTIB: Record "Bank Transaction Import Buffer")
    begin
        BTIB."Sales Invoice No." := '';
        BTIB."Sales Order No." := '';
        BTIB."Sales Quote No." := '';
        BTIB."Sales Order Posting Date" := 0D;
        BTIB."Sales Order Course Date" := 0D;
        BTIB."Shortcut Dimension 1 Code" := '';
        BTIB."Shortcut Dimension 2 Code" := '';
        BTIB."Sales Order Amount" := 0;
        BTIB."Warning Amounts Different" := FALSE;
        BTIB."Bill-to Customer No." := '';
        BTIB."Bill-to Name" := '';
        BTIB."Sell-to Contact No." := '';
        BTIB."Sell-to Contact Name" := '';
        BTIB.Address := '';
        BTIB.City := '';
        BTIB."Post Code" := '';
        BTIB.County := '';
        BTIB.Country := '';
        BTIB."Phone No." := '';
        BTIB."E-Mail Address" := '';
        BTIB."Payment Journal Created" := FALSE;
        BTIB."Document Posted" := FALSE;
        BTIB."Payment Applied" := FALSE;
        BTIB."Error Text" := '';
        BTIB."Payment Ledger Entry No." := 0;
        BTIB."Document Ledger Entry No." := 0;
        BTIB.MODIFY;

    end;
}

