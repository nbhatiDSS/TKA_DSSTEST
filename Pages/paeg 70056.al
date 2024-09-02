page 70056 "Posted Booking "
{
    // //DOC TKA_201106 - Created (Copy of Form 132)
    Permissions = tabledata 112 = rimd, tabledata 113 = rimd, tabledata 254 = rimd, tabledata 17 = rimd;
    Caption = 'Posted Sales Invoice ';
    InsertAllowed = false;
    PageType = Card;
    Editable = false;
    RefreshOnActivate = true;
    SourceTable = 112;
    ApplicationArea = all;
    DataCaptionFields = "No.", "Sell-to Customer No.";
    layout
    {
        area(content)
        {

            group(General)
            {
                Grid(GridControl1)
                {
                    group(SelltoDetails)
                    {
                        Caption = ' Sell-to Details';
                        field("No."; rec."No.")
                        {
                            Editable = false;
                        }
                        field("Sell-to Customer No."; rec."Sell-to Customer No.")
                        {
                            Editable = false;
                        }
                        field("Sell-to Contact No."; rec."Sell-to Contact No.")
                        {
                            Editable = true;
                        }
                        field("Sell-to Customer Name"; rec."Sell-to Customer Name")
                        {
                            Editable = false;
                        }
                        field("Sell-to Address"; rec."Sell-to Address")
                        {
                            Editable = false;
                        }
                        field("Sell-to Address 2"; rec."Sell-to Address 2")
                        {
                            Editable = false;
                        }
                        field("Sell-to Post Code"; rec."Sell-to Post Code")
                        {
                            Caption = 'Sell-to Post Code/City';
                            Editable = false;
                        }
                        field("Sell-to City"; rec."Sell-to City")
                        {
                            Editable = false;
                        }
                        field("Sell-to Contact"; rec."Sell-to Contact")
                        {
                            Editable = false;
                        }
                        field("Nav Portal Reference"; Rec."Nav Portal Reference")
                        { }
                        field("Quote No."; rec."Quote No.")
                        { }
                        field("Order No."; rec."Order No.")
                        {
                            Editable = false;
                        }
                        field(GSTID; rec."GST Gov ID")
                        {
                            // Visible = GSTIDVisible;
                        }
                    }
                    group(BilltoDetails)
                    {
                        caption = 'Bill-to Details';
                        field("Bill-to Customer No."; rec."Bill-to Customer No.")
                        {
                            Editable = false;
                        }
                        field("Bill-to Contact No."; rec."Bill-to Contact No.")
                        {
                            Editable = false;
                        }
                        field("Bill-to Name"; rec."Bill-to Name")
                        {
                            Editable = false;
                        }
                        field("Bill-to Address"; rec."Bill-to Address")
                        {
                            Editable = false;
                        }
                        field("Bill-to Address 2"; rec."Bill-to Address 2")
                        {
                            Editable = false;
                        }
                        field("Bill-to Post Code"; rec."Bill-to Post Code")
                        {
                            Caption = 'Bill-to Post Code/City';
                            Editable = false;
                        }
                        field("Bill-to City"; Rec."Bill-to City")
                        {
                            ApplicationArea = All;
                            Editable = False;
                        }
                        field("Payment Terms Code"; rec."Payment Terms Code")
                        {
                            Editable = false;
                        }
                        field("Payment Information"; rec."Payment Information")
                        {
                            Editable = false;
                        }
                        field("PAS Ref No."; rec."PAS Ref No.")
                        {
                            Editable = false;
                        }
                        field("Your Reference"; rec."Your Reference")
                        {
                            Editable = false;
                            Caption = 'Customer PO NO.';
                        }
                        field("Booker Email"; rec."Booker Email")
                        {
                        }
                        field("Account Email"; rec."Account Email")
                        {
                            Caption = 'Finance Email';
                        }
                    }

                    group(OtherDetails1)
                    {
                        Caption = 'Other Details';
                        field("Salesperson Code"; rec."Salesperson Code")
                        {
                            Editable = false;
                        }
                        field("Order Date"; Rec."Order Date")
                        {
                            ApplicationArea = All;
                            Editable = false;
                        }
                        field("Document Date"; rec."Document Date")
                        {
                            Editable = false;
                        }
                        field("Posting Date"; rec."Posting Date")
                        {
                            Editable = false;
                        }
                        field("Percentage Custom"; rec."Percentage Custom")
                        {
                            Caption = '% Custom';
                        }
                        field("Percentage of RRP"; Rec."Percentage of RRP")
                        {
                            ApplicationArea = all;
                            Visible = true;
                        }
                        field("Percentage of Web Price"; rec."Percentage of Web Price")
                        {
                            caption = '% WebPrice';
                            // Visible = False; //000016873
                        }
                        field(Confirmed; Rec.Confirmed)
                        {
                            ApplicationArea = All;
                        }
                        field("Confirmed By"; rec."Confirmed By")
                        {
                            Editable = false;
                        }
                        field("Confirmed On"; rec."Confirmed On")
                        {
                            Editable = false;
                        }
                        field("Re-Raise Invoice No"; rec."Re-Raise Invoice No")
                        {
                            trigger OnLookup(var Text: Text): Boolean
                            begin
                                IF rec."Re-Raise Invoice No" <> '' THEN BEGIN
                                    IF SalesInvoiceHeader.GET(rec."Re-Raise Invoice No") THEN
                                        PAGE.RUN(PAGE::"Posted Booking", SalesInvoiceHeader);
                                END;
                            end;
                        }
                        field("VAT Registration No."; rec."VAT Registration No.")
                        {
                            Editable = false;
                        }

                        field("pass Type"; ReturnPassType())
                        {
                            ShowCaption = False;
                            ApplicationArea = All;
                            Style = Strong;
                        }

                    }
                    group(OtherDetails2)
                    {
                        Caption = 'Other Details';
                        field("Currency Code"; rec."Currency Code")
                        {
                            Caption = 'Currency Code';
                            Editable = false;

                            trigger OnAssistEdit()
                            begin
                                ChangeExchangeRate.SetParameter(rec."Currency Code", rec."Currency Factor", rec."Posting Date");
                                ChangeExchangeRate.EDITABLE(FALSE);
                                IF ChangeExchangeRate.RUNMODAL = ACTION::OK THEN BEGIN
                                    rec."Currency Factor" := ChangeExchangeRate.GetParameter;
                                    rec.MODIFY;
                                END;
                                CLEAR(ChangeExchangeRate);
                            end;
                        }
                        field(ExclVAT; rec.Amount)
                        {
                            Caption = 'Amount Excluding VAT';
                            Style = StrongAccent;
                        }
                        field("VATAmount"; rec."Amount Including VAT" - rec.Amount)
                        {
                            Caption = 'Vat Amount';
                            Style = Unfavorable;
                            ApplicationArea = All;
                            StyleExpr = TRUE;
                        }
                        field("AmountIncludingVAT"; rec."Amount Including VAT")
                        {
                            Caption = 'Amount Incl. VAT';
                            ApplicationArea = All;
                            Style = Favorable;
                        }
                        field(CountryName; CountryRegion.Name)
                        {
                            Caption = 'Country';
                            Editable = false;
                        }
                        field("National Flag (Card)";
                        CountryRegion."National Flag (Card)")
                        {
                            Caption = 'Flag';
                            Editable = false;
                        }
                        field(I8; rec.PaymentStatus3)
                        {
                            Caption = 'Payment Status';
                            Editable = false;
                        }
                        field(paidAmount; rec."Paid Amount")
                        {
                            Editable = false;
                            Caption = 'Paid Amount';
                            ApplicationArea = All;
                        }
                        field(CreditStatus; Rec.CreditStatus)
                        {
                            Editable = false;
                            Caption = 'Credit Status';
                            ApplicationArea = All;
                        }


                    }

                }
            }
            part(SalesInvLines; 50057)
            {
                SubPageLink = "Document No." = FIELD("No.");
                UpdatePropagation = both;
            }
            // group(PricePanel)
            // {

            //     Caption = 'Pricing Information';

            //     field(Amount; rec.Amount)
            //     {
            //     }
            //     field("Amount Including VAT -Amount"; rec."Amount Including VAT" - rec.Amount)
            //     {
            //         Caption = 'Vat Amount';
            //         Style = Attention;
            //         StyleExpr = TRUE;
            //     }
            //     field("Amount Including VAT"; rec."Amount Including VAT")
            //     {
            //         Caption = 'Amount Incl. VAT';
            //     }
            // }

            group(Comment)
            {
                Caption = 'Comment';
                part("Sales Comment Sheet"; 67)
                {
                    Editable = false;
                    SubPageLink = "No." = FIELD("No.");
                }
            }

        }
    }

    actions
    {
        area(navigation)
        {
            group(BtnEmail)
            {
                Caption = 'E-&Mail';
                Visible = BtnEmailVisible;
                action("Order Confirmation")
                {
                    Caption = 'Order Confirmation';
                    Image = Email;

                    trigger OnAction()
                    var
                        lTKAEmailMgt: Codeunit 50005;
                        lMainEmailID: Text[1024];
                        lOtherEmailIDS: Text[1024];
                        lFileInfo: Text[1024];
                    begin
                        //lTKAEmailMgt.OrderConfirmation2("No.",TRUE);

                        EVECHECK := '';
                        IF rec."E-Learning" THEN BEGIN
                            SalesInvoiceLine1.SETFILTER(SalesInvoiceLine1."Document No.", rec."No.");
                            IF SalesInvoiceLine1.FIND('-') THEN
                                REPEAT
                                    IF EVECHECK <> 'EVE' THEN
                                        EVECHECK := COPYSTR(SalesInvoiceLine1."Event Header", 1, 3);
                                UNTIL SalesInvoiceLine1.NEXT = 0;
                            IF EVECHECK <> 'EVE' THEN
                                OrderConfirmationELearn
                            ELSE BEGIN
                                lTKAEmailMgt.InvoiceFromPostedInvoice(rec."No.", TRUE);
                                lTKAEmailMgt.GetEmailAndFileValues(lMainEmailID, lOtherEmailIDS, lFileInfo);
                            END;
                        END;


                        IF rec."Flexi Pass 12" THEN
                            OrderConfirmationFP
                        ELSE
                            IF rec."Flexi Pass 2" THEN
                                OrderConfirmationFP

                            ELSE
                                IF rec."Flexi Pass" THEN
                                    OrderConfirmationFP
                                ELSE
                                    IF rec."Knowledge Pass" THEN
                                        OrderConfirmationKP
                                    //ELSE
                                    //IF "E-Learning" THEN
                                    //OrderConfirmationELearn
                                    ELSE BEGIN
                                        IF NOT rec."E-Learning" THEN BEGIN
                                            lTKAEmailMgt.InvoiceFromPostedInvoice(rec."No.", TRUE);
                                            lTKAEmailMgt.GetEmailAndFileValues(lMainEmailID, lOtherEmailIDS, lFileInfo);
                                            // IF lFileInfo <> '' THEN
                                            //     IF FILE.ERASE(lFileInfo) THEN;
                                        END;
                                    END;


                        /*
                        
                        IF "Flexi Pass" THEN
                        OrderConfirmationFP
                        ELSE
                        IF "Knowledge Pass" THEN
                        OrderConfirmationKP
                        ELSE
                        IF "E-Learning" THEN
                        OrderConfirmationELearn
                        ELSE BEGIN
                        lTKAEmailMgt.InvoiceFromPostedInvoice("No.",TRUE);
                        lTKAEmailMgt.GetEmailAndFileValues(lMainEmailID,lOtherEmailIDS,lFileInfo);
                        IF lFileInfo <> '' THEN
                          IF FILE.ERASE(lFileInfo) THEN;
                        END;
                        //CurrForm.SETSELECTIONFILTER(SalesInvHeader);
                        //SalesInvHeader.PrintRecords(TRUE);
                        //REPORT.RUNMODAL(FranchiseReportSetup.GetReportID(SalesInvHeader."Sell-to Customer No.",4),TRUE,FALSE,SalesInvHeader)
                        */

                        /*
                        //lTKAEmailMgt.OrderConfirmation2("No.",TRUE);
                        lTKAEmailMgt.InvoiceFromPostedInvoice("No.",TRUE);
                        lTKAEmailMgt.GetEmailAndFileValues(lMainEmailID,lOtherEmailIDS,lFileInfo);
                        IF lFileInfo <> '' THEN
                          IF FILE.ERASE(lFileInfo) THEN;
                        //CurrForm.SETSELECTIONFILTER(SalesInvHeader);
                        //SalesInvHeader.PrintRecords(TRUE);
                        //REPORT.RUNMODAL(FranchiseReportSetup.GetReportID(SalesInvHeader."Sell-to Customer No.",4),TRUE,FALSE,SalesInvHeader)
                        */

                    end;
                }
                action("Sales Invoice")
                {
                    Caption = 'Sales Invoice';
                    Image = Invoice;

                    trigger OnAction()
                    var
                        lTKAEmailMgt: Codeunit 50005;
                        lMainEmailID: Text[1024];
                        lOtherEmailIDS: Text[1024];
                        lFileInfo: Text[1024];
                    begin
                        lTKAEmailMgt.InvoiceFromPostedInvoice1(rec."No.", TRUE);
                        lTKAEmailMgt.GetEmailAndFileValues(lMainEmailID, lOtherEmailIDS, lFileInfo);
                        // IF lFileInfo <> '' THEN
                        //     IF FILE.ERASE(lFileInfo) THEN;

                        /*
                        CurrForm.SETSELECTIONFILTER(SalesInvHeader);
                        //SalesInvHeader.PrintRecords(TRUE);
                        REPORT.RUNMODAL(50117,TRUE,FALSE,SalesInvHeader);
                        */

                        /*
                        lTKAEmailMgt.InvoiceFromPostedInvoice1("No.",TRUE);
                        lTKAEmailMgt.GetEmailAndFileValues(lMainEmailID,lOtherEmailIDS,lFileInfo);
                        IF lFileInfo <> '' THEN
                          IF FILE.ERASE(lFileInfo) THEN;
                        
                        {
                        CurrForm.SETSELECTIONFILTER(SalesInvHeader);
                        //SalesInvHeader.PrintRecords(TRUE);
                        REPORT.RUNMODAL(50117,TRUE,FALSE,SalesInvHeader);
                        }
                        */

                    end;
                }
                action("Order Confirmation Selected Lines")
                {
                    Caption = 'Order Confirmation Selected Lines';
                    image = SendConfirmation;
                    trigger OnAction()
                    var
                        lTKAEmailMgt: Codeunit 50005;
                        lMainEmailID: Text[1024];
                        lOtherEmailIDS: Text[1024];
                        lFileInfo: Text[1024];
                        SalesInvLines2: Record 113;
                    begin
                        rec."Print Selected Lines" := TRUE;
                        rec.MODIFY;

                        SalesInvLines2.SETFILTER("Document No.", rec."No.");
                        SalesInvLines2.SETFILTER("Print Selected Lines", '%1', TRUE);
                        IF NOT SalesInvLines2.FIND('-') THEN
                            ERROR('Select Sales Lines to print on Order confiramtion');
                        //SalesInvoiceLine.SETFILTER("Print Selected Lines",'%1',TRUE);


                        EVECHECK := '';
                        IF rec."E-Learning" THEN BEGIN
                            SalesInvoiceLine1.SETFILTER(SalesInvoiceLine1."Document No.", rec."No.");
                            IF SalesInvoiceLine1.FIND('-') THEN
                                REPEAT
                                    IF EVECHECK <> 'EVE' THEN
                                        EVECHECK := COPYSTR(SalesInvoiceLine1."Event Header", 1, 3);
                                UNTIL SalesInvoiceLine1.NEXT = 0;
                            IF EVECHECK <> 'EVE' THEN
                                OrderConfirmationELearn
                            ELSE BEGIN
                                lTKAEmailMgt.InvoiceFromPostedInvoice(rec."No.", TRUE);
                                lTKAEmailMgt.GetEmailAndFileValues(lMainEmailID, lOtherEmailIDS, lFileInfo);
                            END;
                        END;


                        IF rec."Flexi Pass 12" THEN
                            OrderConfirmationFP
                        ELSE
                            IF rec."Flexi Pass" THEN
                                OrderConfirmationFP
                            ELSE
                                IF rec."Knowledge Pass" THEN
                                    OrderConfirmationKP
                                //ELSE
                                //IF "E-Learning" THEN
                                //OrderConfirmationELearn
                                ELSE BEGIN
                                    IF NOT rec."E-Learning" THEN BEGIN
                                        lTKAEmailMgt.InvoiceFromPostedInvoice(rec."No.", TRUE);
                                        lTKAEmailMgt.GetEmailAndFileValues(lMainEmailID, lOtherEmailIDS, lFileInfo);
                                        // IF lFileInfo <> '' THEN
                                        //     IF FILE.ERASE(lFileInfo) THEN;
                                    END;
                                END;

                        rec."Print Selected Lines" := FALSE;
                        rec.MODIFY;
                    end;
                }
            }

            group(Func2)
            {
                Caption = 'Adv F&unctions';
                Visible = Func2Visible;
                action("Karan Cash PM Report")
                {
                    Caption = 'Karan Cash PM Report';

                    trigger OnAction()
                    begin
                        IF UPPERCASE(USERID) IN ['MARTHA.FOLKES', 'SIMRAT.KAUR', 'DEEPIKA.SINGH', 'KARAN.RANDHAWA', 'BIJU.KURUP'] THEN BEGIN
                            CLEAR(ExcelBuffer);
                            Export_SalesData;
                            //ExcelBuffer.CreateBook;
                            //ExcelBuffer.CreateSheet('Sales Data','','','');
                            //ExcelBuffer.GiveUserControl;
                        END
                        ELSE
                            ERROR('You do not have permission to run Cash PM Report');
                    end;
                }
                action("MEA Sales report from Sept 201")
                {
                    Caption = 'MEA Sales report from Sept 20';

                    trigger OnAction()
                    begin
                        IF UPPERCASE(USERID) IN ['MARTHA.FOLKES', 'SIMRAT.KAUR', 'BIJU.KURUP'] THEN BEGIN
                            CLEAR(ExcelBuffer);
                            Export_InvoiceData;
                            //ExcelBuffer.CreateBook;
                            //ExcelBuffer.CreateSheet('Sales Invoice Data','','','');

                            //ExcelBuffer.SaveExcelFile('D:\Sandip\Martha\Invoice Data\Test.xlsx',TRUE);

                            //ExcelBuffer.GiveUserControl;
                        END
                        ELSE
                            ERROR('You do not have permission to run Invoice Data Report');
                    end;
                }
                action("Add Invoice to KP Inventory")
                {
                    Caption = 'Add Invoice to KP Inventory';

                    trigger OnAction()
                    begin
                        AddInvoiceToKPInventory;
                    end;
                }
                action("Add Invoice to KP Invoice 5344")
                {
                    Caption = 'Add Invoice to KP Invoice 5344';

                    trigger OnAction()
                    begin
                        AddInvoiceToKPInventoryFP;
                    end;
                }
                action("Export Invoice Data from Sept 201")
                {
                    Caption = 'Export Invoice Data from Sept 20';
                    Visible = false;

                    trigger OnAction()
                    begin
                        IF UPPERCASE(USERID) IN ['MARTHA.FOLKES', 'SIMRAT.KAUR', 'DEEPIKA.SINGH', 'KARAN.RANDHAWA', 'BIJU.KURUP'] THEN BEGIN
                            CLEAR(ExcelBuffer);
                            Export_InvoiceData;
                            //ExcelBuffer.CreateBook;
                            //ExcelBuffer.CreateSheet('Sales Invoice Data','','','');
                            //ExcelBuffer.GiveUserControl;
                        END
                        ELSE
                            ERROR('You do not have permission to run Invoice Data Report');
                    end;
                }
                action("Update Missing Elements")
                {
                    ApplicationArea = all;
                    image = UpdateDescription;
                    trigger OnAction()
                    var
                        SubCode: codeunit 50101;
                    begin
                        SubCode.HotfixElementsAction(rec."No.");
                    end;
                }
                action("KP Utilisations Day wise Report1")
                {
                    Caption = 'KP Utilisations Day wise Report';
                    image = Report;
                    trigger OnAction()
                    begin
                        IF UPPERCASE(USERID) IN ['MARTHA.FOLKES', 'BIJU.KURUP'] THEN BEGIN
                            KPUtilisationReport1;
                        END
                        ELSE
                            ERROR('You do not have permission to run this report');
                    end;
                }
                // separator()
                // {
                // }
                action("Update Payment Status1")
                {
                    Caption = 'Update Payment Status';
                    visible = false;
                    trigger OnAction()
                    begin

                        //     IF UPPERCASE(USERID) IN ['MARTHA.FOLKES', 'BIJU.KURUP', 'TRIZA.BEHAL', 'VOMIKA.AGGARWAL', 'PRABHJOT.KAUR'] THEN BEGIN

                        //         Window.OPEN('Enter From Date #1##########  To Date #2##########');
                        //         Window.INPUT(1, FromDate1);
                        //         Window.INPUT(2, ToDate1);
                        //         Window.CLOSE;
                        //         CreditMemoNo := '';
                        //         SalesInvoiceHeader3.SETFILTER(SalesInvoiceHeader3."Posting Date", '%1..%2', FromDate1, ToDate1);
                        //         //300420D,300420D);
                        //         //  SalesInvoiceHeader3.SETFILTER("No." ,'330325');//Rec."No.");
                        //         IF SalesInvoiceHeader3.FIND('-') THEN
                        //             REPEAT
                        //                 UpdateStatus1;

                        //                 SalesInvoiceHeader3.PaymentStatus3 := PaymentStatus2;
                        //                 SalesInvoiceHeader3.CreditMemoNo3 := CreditMemoNo;
                        //                 SalesInvoiceHeader3.MODIFY;

                        //                 IF CreditMemoNo <> '' THEN BEGIN

                        //                     SalesInvoiceHeader3.PaymentStatus3 := 'PAID';// PaymentStatus2;
                        //                     IF AppliedCLE."Document Type" = AppliedCLE."Document Type"::"Credit Memo" THEN
                        //                         SalesInvoiceHeader3.PaymentStatus3 := 'CREDITED';//

                        //                     SalesInvoiceHeader3.CreditMemoNo3 := CreditMemoNo;
                        //                     SalesInvoiceHeader3.MODIFY;
                        //                 END;

                        //                 IF CreditMemoNo = '' THEN BEGIN
                        //                     SalesInvoiceHeader3.PaymentStatus3 := 'UNPAID';// PaymentStatus2;
                        //                     SalesInvoiceHeader3.CreditMemoNo3 := '';
                        //                     SalesInvoiceHeader3.MODIFY;
                        //                 END;

                        //                 a := a + 1;
                        //             UNTIL SalesInvoiceHeader3.NEXT = 0;
                        //         MESSAGE('Process done');
                        //     END
                        //     ELSE
                        //         ERROR('You do not have permission to run Payment Status');
                    end;


                }
                action("UPDATE STATUS One1")
                {
                    Caption = 'UPDATE STATUS One';
                    Visible = false;

                    trigger OnAction()
                    begin
                        a := 0;
                        SalesInvoiceHeader3.SETFILTER("No.", Rec."No.");
                        IF SalesInvoiceHeader3.FIND('-') THEN
                            REPEAT
                                UpdateStatus1;

                                SalesInvoiceHeader3.PaymentStatus3 := PaymentStatus2;
                                SalesInvoiceHeader3.MODIFY;

                                a := a + 1;
                            UNTIL SalesInvoiceHeader3.NEXT = 0;
                        MESSAGE('Process Done');
                    end;
                }
                action("Create Credit Memo1")
                {
                    Caption = 'Create Credit Memo';

                    trigger OnAction()
                    var
                        lSalesHeader: Record 36;
                        lSalesSetup: Record "311";
                        lCopyDocMgt: Codeunit "6620";
                        lDocType: Option Quote,"Blanket Order","Order",Invoice,"Return Order","Credit Memo","Posted Shipment","Posted Invoice","Posted Return Receipt","Posted Credit Memo";
                        lDocNo: Code[20];
                    begin
                        IF CONFIRM('Are you sure you want to create a Credit Memo from this Invoice?', FALSE) THEN
                            CreateCrMemo(Rec);
                    end;
                }
                action("Create Re-Raise Invoice1")
                {
                    Caption = 'Create Re-Raise Invoice';

                    trigger OnAction()
                    begin
                        UserSetup.GET(USERID);
                        IF NOT UserSetup."Re-Raise Invoice" THEN
                            ERROR('You do not have permission to Re-Raise Invoice');

                        ReRaisedText := '';
                        SalesInvoiceHeader1.SETFILTER(SalesInvoiceHeader1."Re-Raise Invoice No", rec."No.");
                        IF SalesInvoiceHeader1.FIND('+') THEN
                            ERROR('This Document has been Re-Raised');

                        IF CONFIRM('Are you sure you want to create a Sales Order from this Invoice?', FALSE) THEN
                            CreateSalesOrder(Rec);
                    end;
                }
                action("Change Address")
                {
                    Caption = 'Change Address';

                    trigger OnAction()
                    begin
                        ChangeAdd1;
                    end;
                }
                action("Change E-Mail address")
                {
                    Caption = 'Change E-Mail address';
                    ApplicationArea = all;
                    Visible = true;
                    trigger OnAction()
                    begin
                        ChangeEmail1;
                    end;
                }
            }
            group(FuncName)
            {
                Caption = '&Invoice';
                Visible = FuncNameVisible;
                action("Update Tax Business Group")
                {
                    Caption = 'Update Tax Business Group';

                    trigger OnAction()
                    begin
                        UpdateTaxBusinessGroup;
                    end;
                }
                action(Statistics)
                {
                    Caption = 'Statistics';
                    Image = Statistics;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page 397;
                    RunPageLink = "No." = FIELD("No.");
                    ShortCutKey = 'F7';
                }
                action("Co&mments")
                {
                    Caption = 'Co&mments';
                    Image = ViewComments;
                    ApplicationArea = all;
                    RunObject = page "Sales Comment Sheet";
                    RunPageLink = "Document Type" = CONST("Posted Invoice"),
                                  "No." = FIELD("No.")
                                  ,
                                  "Document Line No." = CONST(0);
                }
                action("Show Re-Raised To Document")
                {
                    Caption = 'Show Re-Raised To Document';

                    trigger OnAction()
                    begin
                        SalesInvoiceHeader1.SETFILTER(SalesInvoiceHeader1."Re-Raise Invoice No", rec."No.");
                        IF SalesInvoiceHeader1.FIND('+') THEN
                            PAGE.RUN(PAGE::"Posted Booking", SalesInvoiceHeader1);
                    end;
                }
                action(Approvals)
                {
                    Caption = 'Approvals';
                    Image = Approvals;

                    trigger OnAction()
                    var
                        PostedApprovalEntries: Page "Posted Approval Entries";
                    begin
                        //PostedApprovalEntries.Setfilters(DATABASE::"Sales Invoice Header","No.");
                        PostedApprovalEntries.RUN;
                    end;
                }
                // separator()
                // {
                // }
                action("Credit Cards Transaction Lo&g Entries")
                {
                    Caption = 'Credit Cards Transaction Lo&g Entries';
                    // RunObject = Page 829;
                }
                action("Create TDS Journal 10%")
                {
                    Caption = 'Create TDS Journal 10%';

                    trigger OnAction()
                    begin
                        IF COMPANYNAME <> 'TKA India' THEN
                            ERROR('This functionality is not applicable for this company');

                        IF NOT (UPPERCASE(USERID) IN ['MARTHA.FOLKES', 'BIJU.KURUP', 'TRIZA.BEHAL', 'PRABHJOT.KAUR']) THEN
                            ERROR('You do not have permission to run TDS Journal');

                        CreateFAJournal_10sales;
                        //ApplyandPostTDS;

                        salesinvline3.SETFILTER(salesinvline3."Document No.", rec."No.");
                        salesinvline3.SETFILTER(salesinvline3."Apply TDS", '%1', TRUE);
                        IF salesinvline3.FIND('-') THEN
                            REPEAT
                                salesinvline3."Apply TDS" := FALSE;
                                salesinvline3.MODIFY;
                            UNTIL salesinvline3.NEXT = 0;
                    end;
                }
            }
            group(FuncLine)
            {
                Caption = '&Line';
                Visible = FuncLineVisible;
                // separator()
                // {
                // }
                action("Associate with KP Inventory")
                {
                    Caption = 'Associate with KP Inventory';

                    trigger OnAction()
                    begin
                        IF UPPERCASE(USERID) IN ['MARTHA.FOLKES', 'BIJU.KURUP1', 'PRABHJOT.KAUR'] THEN BEGIN

                            IF NOT CONFIRM('Are you sure to Associate KP Nos to KP Inventory ?') THEN
                                ERROR('');

                            SalesInvoiceLine1.SETFILTER(SalesInvoiceLine1."Document No.", rec."No.");
                            SalesInvoiceLine1.SETFILTER(SalesInvoiceLine1."Associate KP No.", '<>%1', '');
                            IF SalesInvoiceLine1.FIND('-') THEN
                                REPEAT
                                    SalesInvoiceLine1."KP No." := SalesInvoiceLine1."Associate KP No.";
                                    SalesInvoiceLine1."KP Line No." := SalesInvoiceLine1."Associate KP Line No.";
                                    SalesInvoiceLine1.MODIFY;
                                UNTIL SalesInvoiceLine1.NEXT = 0;


                            SalesInvoiceLine1.SETFILTER(SalesInvoiceLine1."Document No.", rec."No.");
                            SalesInvoiceLine1.SETFILTER(SalesInvoiceLine1."Associate KP No.", '<>%1', '');
                            IF SalesInvoiceLine1.COUNT = 0 THEN
                                ERROR('No Lines exists for Associate KP No');

                            MESSAGE('Process completed');
                        END
                        ELSE
                            ERROR('You do not have permission for Associate of KP');
                    end;
                }
            }
        }
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Visible = false;
                separator(separator)
                {
                }
                action("Create Credit Memo ")
                {
                    Caption = 'Create Credit Memo';

                    trigger OnAction()
                    var
                        lSalesHeader: Record 36;
                        lSalesSetup: Record "311";
                        lCopyDocMgt: Codeunit "6620";
                        lDocType: Option Quote,"Blanket Order","Order",Invoice,"Return Order","Credit Memo","Posted Shipment","Posted Invoice","Posted Return Receipt","Posted Credit Memo";
                        lDocNo: Code[20];
                    begin
                        IF CONFIRM('Are you sure you want to create a Credit Memo from this Invoice?', FALSE) THEN
                            CreateCrMemo(Rec);
                    end;
                }
            }
            action("New Invoice")
            {
                Caption = 'New Invoice';
                Ellipsis = true;
                Promoted = true;
                PromotedCategory = Process;
                Visible = false;

                trigger OnAction()
                begin
                    CurrPage.SETSELECTIONFILTER(SalesInvHeader);
                    //SalesInvHeader.PrintRecords(TRUE);
                    REPORT.RUNMODAL(50117, TRUE, FALSE, SalesInvHeader);
                    //REPORT.RUNMODAL(FranchiseReportSetup.GetReportID(SalesInvHeader."Sell-to Customer No.",4),TRUE,FALSE,SalesInvHeader)
                end;
            }
            group(FuncFunction)
            {
                Caption = 'F&unctions';
                Visible = FuncFunctionVisible;
                action("Karan Cash PM Report ")
                {
                    Caption = 'Karan Cash PM Report';

                    trigger OnAction()
                    begin
                        IF UPPERCASE(USERID) IN ['MARTHA.FOLKES', 'SIMRAT.KAUR', 'DEEPIKA.SINGH', 'KARAN.RANDHAWA', 'BIJU.KURUP'] THEN BEGIN
                            CLEAR(ExcelBuffer);
                            Export_SalesData;
                            //ExcelBuffer.CreateBook;
                            //ExcelBuffer.CreateSheet('Sales Data','','','');
                            //ExcelBuffer.GiveUserControl;
                        END
                        ELSE
                            ERROR('You do not have permission to run Cash PM Report');
                    end;
                }
                action("Update Due Date")
                {
                    Caption = 'Update Due Date';

                    trigger OnAction()
                    var
                        SalesInvoiceHeader1: Record 112;
                        CustomerLedgerEntry: Record 21;
                        SalesSetup: record "Sales & Receivables Setup";
                        Param: report 50300;
                    begin
                        IF UPPERCASE(USERID) IN ['MARTHA.FOLKES', 'BIJU.KURUP', 'SURAJ.PRAKASH', 'PRABHJOT.KAUR'] THEN BEGIN
                            IF NOT CONFIRM('Are you sure to change Due date of Document No ' + Rec."No.") THEN
                                ERROR('');

                            Param.setreportid(3);
                            Param.RunModal();
                            SalesSetup.get;
                            Fromdate1 := SalesSetup.PostingFromDate;

                            // Window.OPEN('Enter From Date #1##########');
                            // Window.INPUT(1, FromDate1);
                            // Window.CLOSE;

                            IF FromDate1 = 0D THEN
                                ERROR('Date should not be Blank');

                            IF FromDate1 < rec."Posting Date" THEN
                                ERROR('Due date must not be before posting date');

                            IF SalesInvoiceHeader1.GET(rec."No.") THEN BEGIN
                                SalesInvoiceHeader1."Due Date" := FromDate1;
                                SalesInvoiceHeader1.MODIFY;

                                CustomerLedgerEntry.SETCURRENTKEY("Document No.", "Document Type", "Customer No.");
                                CustomerLedgerEntry.SETFILTER(CustomerLedgerEntry."Document No.", SalesInvoiceHeader1."No.");
                                CustomerLedgerEntry.SETFILTER(CustomerLedgerEntry."Document Type", '%1', CustomerLedgerEntry."Document Type"::Invoice);
                                IF CustomerLedgerEntry.FIND('-') THEN BEGIN
                                    CustomerLedgerEntry."Due Date" := FromDate1;
                                    CustomerLedgerEntry.MODIFY;
                                END;
                            END;

                            MESSAGE('Date changed successfully');
                        END
                        ELSE
                            ERROR('You do not have permission to update Due Date');
                    end;
                }
                action("KP Utilisation Report to Excel")
                {
                    Caption = 'KP Utilisation Report to Excel';

                    trigger OnAction()
                    begin
                        IF UPPERCASE(USERID) IN ['MARTHA.FOLKES', 'BIJU.KURUP', 'DEEPIKA.SINGH', 'DEEPKA.HEER'] THEN BEGIN
                            CLEAR(ExcelBuffer);
                            KPUtilisationReportToExcel;
                            //ExcelBuffer.CreateBook;
                            ////ExcelBuffer.CreateSheet(GLCode,'','','');
                            //ExcelBuffer.CreateSheet('KP Utilisation Report','','','');

                            //ExcelBuffer.GiveUserControl;
                        END
                        ELSE
                            ERROR('You do not have permssion to run this report KP Utilisation');
                    end;
                }
                action("Update Posting Date")
                {
                    Caption = 'Update Posting Date';

                    trigger OnAction()
                    begin
                        UpdatePostingDate;
                    end;
                }
                action("MEA Sales report from Sept 20")
                {
                    Caption = 'MEA Sales report from Sept 20';
                    Visible = false;

                    trigger OnAction()
                    begin
                        IF UPPERCASE(USERID) IN ['MARTHA.FOLKES', 'SIMRAT.KAUR', 'BIJU.KURUP'] THEN BEGIN
                            CLEAR(ExcelBuffer);
                            Export_InvoiceData;
                            //ExcelBuffer.CreateBook;
                            //ExcelBuffer.CreateSheet('Sales Invoice Data','','','');

                            //ExcelBuffer.SaveExcelFile('D:\Sandip\Martha\Invoice Data\Test.xlsx',TRUE);

                            //ExcelBuffer.GiveUserControl;
                        END
                        ELSE
                            ERROR('You do not have permission to run Invoice Data Report');
                    end;
                }
                action("Export Invoice Data from Sept 20")
                {
                    Caption = 'Export Invoice Data from Sept 20';
                    Visible = false;

                    trigger OnAction()
                    begin
                        IF UPPERCASE(USERID) IN ['MARTHA.FOLKES', 'SIMRAT.KAUR', 'DEEPIKA.SINGH', 'KARAN.RANDHAWA', 'BIJU.KURUP'] THEN BEGIN
                            CLEAR(ExcelBuffer);
                            Export_InvoiceData;
                            //ExcelBuffer.CreateBook;
                            //ExcelBuffer.CreateSheet('Sales Invoice Data','','','');
                            //ExcelBuffer.GiveUserControl;
                        END
                        ELSE
                            ERROR('You do not have permission to run Invoice Data Report');
                    end;
                }
                action("Cash Report New Simrat")
                {
                    Caption = 'Cash Report New Simrat';

                    trigger OnAction()
                    begin
                        CLEAR(ExcelBuffer);
                        IF UPPERCASE(USERID) IN ['MARTHA.FOLKES', 'SIMRAT.KAUR', 'BIJU.KURUP', 'PRIYA.BAINS'] THEN BEGIN
                            CLEAR(ExcelBuffer);
                            TeamManager := 'Karan Randhawa';
                            ExcelBuffer.DELETEALL;
                            Export_SalesDataDynamic1;
                            //ExcelBuffer.CreateBook;
                            //ExcelBuffer.CreateSheet('Sales Data','','','');
                            //ExcelBuffer.GiveUserControl;
                        END
                        ELSE
                            ERROR('You do not have permission to run Cash PM Report');
                        CLEAR(ExcelBuffer);

                        /*
                        CLEAR(ExcelBuffer);
                        IF UPPERCASE(USERID)IN['MARTHA.FOLKES','SIMRAT.KAUR','BIJU.KURUP','PRIYA.BAINS'] THEN BEGIN
                        CLEAR(ExcelBuffer);
                        TeamManager :='K.RANDHAWA';
                        ExcelBuffer.DELETEALL;
                        Export_SalesDataDynamic1;
                        //ExcelBuffer.CreateBook;
                        //ExcelBuffer.CreateSheet('Sales Data','','','');
                        ExcelBuffer.GiveUserControl;
                        END
                        ELSE
                        ERROR('You do not have permission to run Cash PM Report');
                        CLEAR(ExcelBuffer);
                        */

                    end;
                }
                action("Print Invoice to INV Path")
                {
                    Caption = 'Print Invoice to INV Path';

                    trigger OnAction()
                    begin
                        IF UPPERCASE(USERID) IN ['MARTHA.FOLKES', 'BIJU.KURUP'] THEN
                            PrintInvoiceToPDF(rec."No.")
                        ELSE
                            ERROR('You do not have permission to print PDF on Inv path');
                    end;
                }
                action("KP Utilisations Day wise Report")
                {
                    Caption = 'KP Utilisations Day wise Report';
                    Visible = false;

                    trigger OnAction()
                    begin
                        IF UPPERCASE(USERID) IN ['MARTHA.FOLKES', 'BIJU.KURUP'] THEN BEGIN
                            KPUtilisationReport1;
                        END
                        ELSE
                            ERROR('You do not have permission to run this report');
                    end;
                }
                // separator()
                // {
                // }
                action("Update Payment Status")
                {
                    Caption = 'Update Payment Status';

                    trigger OnAction()
                    VAR
                        CuExtenison: codeunit CUExtension;
                        DateReqRep: report 60104;
                    begin

                        IF UPPERCASE(USERID) IN ['MARTHA.FOLKES', 'BIJU.KURUP', 'TRIZA.BEHAL', 'VOMIKA.AGGARWAL', 'PRABHJOT.KAUR', 'JUHI.SHARMA',
                        'SIMRAT.KAUR', 'SIMRANDEEP.KAUR'] THEN BEGIN

                            // Window.OPEN('Enter From Date #1##########  To Date #2##########');
                            // Window.INPUT(1, FromDate1);
                            // Window.INPUT(2, ToDate1);
                            // Window.CLOSE;
                            DateReqRep.SetReportID(1);
                            DateReqRep.Run;
                            DateReqRep.getdate(Fromdate1, ToDate1);

                            CreditMemoNo := '';
                            SalesInvoiceHeader3.SETFILTER(SalesInvoiceHeader3."Posting Date", '%1..%2', FromDate1, ToDate1);
                            //300420D,300420D);
                            //  SalesInvoiceHeader3.SETFILTER("No." ,'330325');//Rec."No.");
                            IF SalesInvoiceHeader3.FIND('-') THEN
                                REPEAT
                                    UpdateStatus1;

                                    SalesInvoiceHeader3.PaymentStatus3 := PaymentStatus2;
                                    SalesInvoiceHeader3.CreditMemoNo3 := CreditMemoNo;
                                    DateReqRep.Modifysih(SalesInvoiceHeader3);
                                    //SalesInvoiceHeader3.MODIFY;

                                    IF CreditMemoNo <> '' THEN BEGIN

                                        SalesInvoiceHeader3.PaymentStatus3 := 'PAID';// PaymentStatus2;
                                        IF AppliedCLE."Document Type" = AppliedCLE."Document Type"::"Credit Memo" THEN
                                            SalesInvoiceHeader3.PaymentStatus3 := 'CREDITED';//

                                        SalesInvoiceHeader3.CreditMemoNo3 := CreditMemoNo;
                                        DateReqRep.Modifysih(SalesInvoiceHeader3);
                                        // SalesInvoiceHeader3.MODIFY;
                                    END;

                                    IF CreditMemoNo = '' THEN BEGIN
                                        SalesInvoiceHeader3.PaymentStatus3 := 'UNPAID';// PaymentStatus2;
                                        SalesInvoiceHeader3.CreditMemoNo3 := '';
                                        DateReqRep.Modifysih(SalesInvoiceHeader3);
                                        //SalesInvoiceHeader3.MODIFY;
                                    END;

                                    a := a + 1;
                                UNTIL SalesInvoiceHeader3.NEXT = 0;
                            MESSAGE('Process done');
                        END
                        ELSE
                            ERROR('You do not have permission to run Payment Status');
                    end;
                }
                action("UPDATE STATUS One")
                {
                    Caption = 'UPDATE STATUS One';
                    Visible = false;

                    trigger OnAction()
                    begin
                        a := 0;
                        SalesInvoiceHeader3.SETFILTER("No.", Rec."No.");
                        IF SalesInvoiceHeader3.FIND('-') THEN
                            REPEAT
                                UpdateStatus1;

                                SalesInvoiceHeader3.PaymentStatus3 := PaymentStatus2;
                                SalesInvoiceHeader3.MODIFY;

                                a := a + 1;
                            UNTIL SalesInvoiceHeader3.NEXT = 0;
                        MESSAGE('Process Done');
                    end;
                }
                action("Create Credit Memo")
                {
                    Caption = 'Create Credit Memo';

                    trigger OnAction()
                    var
                        lSalesHeader: Record 36;
                        lSalesSetup: Record "311";
                        lCopyDocMgt: Codeunit "6620";
                        lDocType: Option Quote,"Blanket Order","Order",Invoice,"Return Order","Credit Memo","Posted Shipment","Posted Invoice","Posted Return Receipt","Posted Credit Memo";
                        lDocNo: Code[20];
                    begin
                        IF CONFIRM('Are you sure you want to create a Credit Memo from this Invoice?', FALSE) THEN
                            CreateCrMemo(Rec);
                    end;
                }
                action("Create Re-Raise Invoice")
                {
                    Caption = 'Create Re-Raise Invoice';

                    trigger OnAction()
                    begin
                        UserSetup.GET(USERID);
                        IF NOT UserSetup."Re-Raise Invoice" THEN
                            ERROR('You do not have permission to Re-Raise Invoice');

                        ReRaisedText := '';
                        SalesInvoiceHeader1.SETFILTER(SalesInvoiceHeader1."Re-Raise Invoice No", rec."No.");
                        IF SalesInvoiceHeader1.FIND('+') THEN
                            ERROR('This Document has been Re-Raised');

                        IF CONFIRM('Are you sure you want to create a Sales Order from this Invoice?', FALSE) THEN
                            CreateSalesOrder(Rec);
                    end;
                }
                action("Update GST Gov ID")
                {
                    Caption = 'Update GST Gov ID';

                    trigger OnAction()
                    var
                        Window: Dialog;
                        GST: Text[100];
                        CustomerLedger: Record 21;
                        SalesSetup: record "Sales & Receivables Setup";
                        Param: report 50300;
                    begin
                        IF (UPPERCASE(USERID) IN ['PRABHJOT.KAUR', 'BIJU.KURUP', 'MARTHA.FOLKES', 'DIVYA.SALHAN', 'JUHI.SHARMA']) AND (COMPANYNAME = 'TKA India') THEN BEGIN

                            Param.setreportid(4);
                            Param.runmodal;
                            SalesSetup.get;
                            Gst := Salessetup.BilltoAdd2;
                            CustomerLedger.RESET;
                            CustomerLedger.SETRANGE(CustomerLedger."GST Gov ID", GST);
                            IF CustomerLedger.FINDFIRST THEN
                                ERROR('GST Gov ID already exists');


                            rec."GST Gov ID" := GST;
                            rec.MODIFY;
                            CustomerLedger.RESET;
                            CustomerLedger.SETRANGE(CustomerLedger."Document No.", rec."No.");
                            IF CustomerLedger.FINDSET THEN
                                REPEAT
                                    CustomerLedger."GST Gov ID" := GST;
                                    CustomerLedger.MODIFY;
                                UNTIL CustomerLedger.NEXT = 0;
                            PrintInvoiceToPDF(Rec."No.");
                        END ELSE
                            ERROR('No Permission');
                    end;
                }
            }
            action("Update PAS Ref No.")
            {
                trigger OnAction()
                var
                    Param: report ParamReport;
                    SalesSetup: record "Sales & Receivables Setup";
                begin
                    Param.setreportid(11);
                    Param.runmodal;
                    SalesSetup.get;
                    rec."PAS Ref No." := SalesSetup.ToText;
                    rec.Modify();
                    Message('PAS Ref Updated');

                end;
            }
            action("&Print")
            {
                Caption = '&Print';
                Ellipsis = true;
                Image = Print;
                Promoted = true;
                PromotedCategory = Process;
                Visible = true;

                trigger OnAction()
                begin
                    /*
                    CurrForm.SETSELECTIONFILTER(SalesInvHeader);
                    //SalesInvHeader.PrintRecords(TRUE);
                    IF COMPANYNAME='TKA India' THEN
                    REPORT.RUNMODAL(50130,TRUE,FALSE,SalesInvHeader)//REPORT.RUNMODAL(50129,TRUE,FALSE,SalesInvHeader)
                    ELSE
                    REPORT.RUNMODAL(FranchiseReportSetup.GetReportID(SalesInvHeader."Sell-to Customer No.",4),TRUE,FALSE,SalesInvHeader)
                    */

                    CurrPage.SETSELECTIONFILTER(SalesInvHeader);
                    IF COMPANYNAME = 'TKA India' THEN BEGIN
                        Customer1.SETFILTER("No.", rec."Sell-to Customer No.");
                        Customer1.SETFILTER("Territory Code", '29');
                        IF Customer1.FIND('-') THEN
                            REPORT.RUNMODAL(50129, TRUE, FALSE, SalesInvHeader)
                        ELSE
                            REPORT.RUNMODAL(50130, TRUE, FALSE, SalesInvHeader)
                    END;

                    IF COMPANYNAME <> 'TKA India' THEN
                        REPORT.RUNMODAL(FranchiseReportSetup.GetReportID(SalesInvHeader."Sell-to Customer No.", 4), TRUE, FALSE, SalesInvHeader)

                end;
            }
            action(FuncNavigate)
            {
                Caption = '&Navigate';
                Image = Navigate;
                Promoted = true;
                PromotedCategory = Process;
                Visible = FuncNavigateVisible;

                trigger OnAction()
                begin
                    rec.Navigate;
                end;
            }
            action("Update status")
            {
                ApplicationArea = All;
                Caption = 'Update Status';
                Ellipsis = true;
                Image = Print;
                RunPageOnRec = true;
                trigger OnAction()
                var
                    SaleHdr: Record "Sales Invoice Header";
                begin
                    SaleHdr.RESET;
                    SaleHdr.SETRANGE("No.", Rec."No.");
                    IF SaleHdr.FINDFIRST THEN // BEGIN
                        REPORT.RUNMODAL(50056, TRUE, FALSE, SaleHdr);
                end;
            }

            action("Payments - PCIPAL")
            {
                Caption = 'Payments - PCIPAL';
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var

                    Currency: Record "4";
                    lCardEntry: Record "50038";
                    lSourceType: Option " ","Order",Invoice,Payment,Refund;
                    USetup: Record 91;
                    PCIform: Page 50139;
                begin
                    User1.GET(UPPERCASE(USERID));
                    IF User1."Restrict India User" THEN
                        ERROR('No permission');

                    /*USetup.GET(USERID);
                    IF NOT USetup.PCI THEN
                      ERROR('PCI not activated');*///260618
                    IF rec."Payment Terms Code" = 'PAID' THEN
                        ERROR(Text008)
                    ELSE BEGIN
                        //COMMIT;
                        rec.TESTFIELD("Bill-to Customer No.");
                        IF NOT Currency.GET(rec."Currency Code") THEN
                            CLEAR(Currency);
                        lCardEntry.SETRANGE("Customer No.", rec."Bill-to Customer No.");
                        PCIform.SetValues
                          (lSourceType::Payment, rec."No.", rec."Quote No.",
                          rec."Amount Including VAT", Currency, rec."Payment Information", rec."Payment Method Code");
                        PCIform.SETTABLEVIEW(lCardEntry);
                        PCIform.RUNMODAL;
                    END;

                end;
            }
            action("KP Utilisation Link")
            {
                Caption = 'KP Utilisation Link';
                Description = 'CL';
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'KP Inventory Data';
                image = Link;
                trigger OnAction()
                begin
                    KPInventoryForm;
                end;
            }
            action("Invoice PO update")
            {
                Promoted = true;
                PromotedCategory = Process;
                // RunObject = Page 50159;
                // RunPageLink = "No." = FIELD("No.");
                image = UpdateDescription;

                trigger OnAction()
                var
                    SalesInvoiceHeader: record "Sales Invoice Header";
                begin
                    SalesInvoiceHeader.get(rec."No.");
                    Page.Run(50159, SalesInvoiceHeader);
                end;

            }
            action("KP Link")
            {
                Caption = 'KP Link';
                Description = 'CL';
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Page 50113;
                RunPageLink = "KP Invoice No." = FIELD("No.");
                ToolTip = 'KP Inventory Data';
                Visible = false;
            }
            action(CL)
            {
                Caption = 'CL';
                Description = 'CL';
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Page "Customer Ledger Entries";
                RunPageLink = "Customer No." = FIELD("Sell-to Customer No.");
                ToolTip = 'CustomerLedger Data';
                Image = CustomerLedger;
            }
            action("PDF Documents")
            {
                Caption = 'PDF Documents';
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Page "PDF Documents List";
                RunPageLink = "Document Type" = CONST(Invoice),
                              "Document No." = FIELD("No.");
                ToolTip = 'PDF Documents';
                Image = Documents;

                trigger OnAction()
                var
                    CustomerLedger: record 21;
                begin
                    Customerledger.setrange(CustomerLedger."Customer No.", rec."Bill-to Customer No.");
                    // Customerledger.setrange(Customerledger.

                end;
            }
            action(AppliedEntries)
            {
                ApplicationArea = All;
                Caption = 'Applied Entries';
                Promoted = true;
                PromotedCategory = Process;
                Image = Approve;
                RunObject = Page "Applied Customer Entries";
                // RunPageOnRec = true;

                Scope = Repeater;
                ToolTip = 'View the ledger entries that have been applied to this record.';
                trigger onaction()
                var
                    CustomerLedger: record 21;
                begin
                    CustomerLedger.setrange("Customer No.", rec."Bill-to Customer No.");
                    customerledger.SetRange("Document Type", CustomerLedger."Document Type"::Invoice);
                    Customerledger.setrange("Document No.", rec."No.");
                    If CustomerLedger.findset then begin
                        page.run(61, CustomerLedger)

                    end;
                end;
            }
            action("Update Contact No.")
            {
                Caption = 'Update Contact No.';
                Promoted = true;
                PromotedCategory = Process;

                Image = UpdateDescription;

                trigger OnAction()
                var
                    SalesSetup: record "Sales & Receivables Setup";
                    Param: report 50300;
                begin
                    Param.setreportid(9);
                    Param.RunModal();
                    SalesSetup.get;
                    Rec."Sell-to Contact No." := SalesSetup.ContName;
                    rec.modify;
                    currpage.Update();

                end;
            }
            action("Customer")
            {
                Promoted = true;
                PromotedCategory = Process;
                Image = Customer;
                trigger OnAction()
                var
                    lCustomer: Record "18";
                begin
                    IF lCustomer.GET(rec."Sell-to Customer No.") THEN BEGIN
                        lCustomer.SETRECFILTER;
                        PAGE.RUN(21, lCustomer);
                    END;
                end;
            }
        }
    }
    var
        SalesInvHeader: Record 112;
        ChangeExchangeRate: Page "Change Exchange Rate";
        FranchiseReportSetup: Record 50023;
        CompanyInformation: Record 79;
        CountryRegion: Record "9";

        SalesInvLine: Record 113;
        Text008: Label 'This document is already Paid';
        PaymentEntry: Record "50040";
        Paid: Decimal;
        PaymentStatus1: Text[30];
        CustLedgerEntry: Record "21";
        DetailedCustLedgEntry: Record "379";
        FirstTime: Boolean;
        DocumentNo: Code[20];
        Cnt: Integer;
        PreviousDocNo: Code[20];
        ColourValue: Integer;
        SalesInvoiceLine1: Record 113;
        EVECHECK: Text[3];
        CreditMemoNo: Code[20];
        SalesCrMemoHeader: Record 114;
        SalesInvoiceHeader: Record 112;
        UserSetup: Record 91;
        SalesInvoiceHeader1: Record 112;
        ReRaisedText: Text[50];
        AppliedCLE: Record "21";
        SalesDocument1: Code[20];
        SalesInvoiceHeader2: Record 112;
        SalesInvoiceLine: Record 113;
        Team: Record "5083";
        ExchangeRate1: Decimal;
        AmountGBP1: Decimal;
        AmountGBPIncludingTax: Decimal;
        DatePaid1: Date;
        ExcelBuffer: Record "370" temporary;
        POHdr: Record 38;
        POLine: Record "39";
        FromDate: Date;
        ToDate: Date;
        MaxColumns: Integer;
        Window: Dialog;
        RowNum: Integer;
        ColumnNum: Integer;
        SalesInvoiceLine3: Record 113;
        CourseHeader1: Code[20];
        SalesInvoiceHeader3: Record 112;
        PaymentStatus2: Text[30];
        a: Integer;
        FromDate1: Date;
        ToDate1: Date;
        // SMTPSetup: Record "409";
        // SMTPMail: Codeunit "400";
        email: codeunit email;
        emailmsg: codeunit "Email Message";
        Customer1: Record "18";
        TeamManager: Text[50];
        User1: Record 91;
        Salesline1: Record "37";
        NextDocumentNo: Code[20];
        TDSAmount: Decimal;
        salesInvLine1: Record 113;
        salesinvline3: Record 113;
        CreditStatus: Text[30];
        scmh: Record 114;
        rc: Record "231";
        Func2Visible: Boolean;
        BtnEmailVisible: Boolean;
        FuncNameVisible: Boolean;
        FuncLineVisible: Boolean;
        FuncNavigateVisible: Boolean;
        FuncFunctionVisible: Boolean;
        GSTIDVisible: Boolean;
        Text19044005: Label 'Payment';
        Text19069218: Label 'Credit Status';

        //NB 210824
        paidAmount: decimal;
        CLEDocumentNo: code[20];
        CLE: record "Cust. Ledger Entry";

    trigger OnAfterGetRecord()
    var
    begin
        //Paid := 0;

        IF PreviousDocNo <> rec."No." THEN BEGIN
            PaymentStatus1 := '';
            PreviousDocNo := rec."No.";
            CreditMemoNo := '';
            SalesDocument1 := '';


            //Checking Original Knowledge Pass Invoice Payment Status Start
            IF SalesInvoiceHeader2.GET(Rec."No.") THEN BEGIN
                IF SalesInvoiceHeader2."Payment Information" = SalesInvoiceHeader2."Payment Information"::"Knowledge / Flexi Pass" THEN BEGIN
                    SalesInvoiceLine.SETFILTER("Document No.", SalesInvoiceHeader2."No.");
                    SalesInvoiceLine.SETFILTER(SalesInvoiceLine."KP No.", '<>%1', '');
                    IF SalesInvoiceLine.FIND('-') THEN
                        SalesDocument1 := SalesInvoiceLine."KP No.";
                END;
            END;
            //Checking Original Knowledge Pass Invoice Payment Status End
            IF SalesDocument1 = '' THEN
                SalesDocument1 := Rec."No.";
            CLEAR(AppliedCLE);
            //new code
            CLEAR(CustLedgerEntry);
            CustLedgerEntry.SETCURRENTKEY("Document No.", "Document Type", "Customer No.");
            CustLedgerEntry.SETFILTER("Document No.", SalesDocument1);
            CustLedgerEntry.SETFILTER(CustLedgerEntry."Document Type", '%1', CustLedgerEntry."Document Type"::Invoice);
            IF CustLedgerEntry.FIND('-') THEN BEGIN
                CustLedgerEntry.CALCFIELDS(CustLedgerEntry."Remaining Amount");
                IF CustLedgerEntry."Remaining Amount" = 0 THEN BEGIN
                    IF CustLedgerEntry."Closed by Entry No." <> 0 THEN BEGIN
                        AppliedCLE.SETFILTER("Entry No.", '%1', CustLedgerEntry."Closed by Entry No.");
                        IF AppliedCLE.FIND('-') THEN BEGIN
                            IF AppliedCLE."Document Type" = AppliedCLE."Document Type"::"Credit Memo" THEN
                                PaymentStatus1 := 'CREDITED';
                            CreditMemoNo := AppliedCLE."Document No.";

                            IF AppliedCLE."Document Type" = AppliedCLE."Document Type"::Payment THEN
                                PaymentStatus1 := 'PAID';
                            CreditMemoNo := AppliedCLE."Document No.";

                            IF AppliedCLE."Document Type" = AppliedCLE."Document Type"::" " THEN
                                PaymentStatus1 := 'PAID';
                            CreditMemoNo := AppliedCLE."Document No.";
                            EXIT;
                        END;
                    END;

                    IF CustLedgerEntry."Closed by Entry No." = 0 THEN BEGIN
                        AppliedCLE.SETFILTER("Closed by Entry No.", '%1', CustLedgerEntry."Entry No.");
                        IF AppliedCLE.FIND('-') THEN BEGIN
                            IF AppliedCLE."Document Type" = AppliedCLE."Document Type"::"Credit Memo" THEN
                                PaymentStatus1 := 'CREDITED';
                            CreditMemoNo := AppliedCLE."Document No.";

                            IF AppliedCLE."Document Type" = AppliedCLE."Document Type"::Payment THEN
                                PaymentStatus1 := 'PAID';
                            CreditMemoNo := AppliedCLE."Document No.";

                            IF AppliedCLE."Document Type" = AppliedCLE."Document Type"::" " THEN
                                PaymentStatus1 := 'PAID';
                            CreditMemoNo := AppliedCLE."Document No.";
                            //MESSAGE ('Coming in loop closed by entry no 0');
                            EXIT;
                        END;
                    END;


                END;
            END;
            CLEAR(CustLedgerEntry);

            /*
            CLEAR(CustLedgerEntry);
            CustLedgerEntry.SETCURRENTKEY("Document No.","Document Type","Customer No.");
            CustLedgerEntry.SETFILTER("Document No.",SalesDocument1);
            CustLedgerEntry.SETFILTER(CustLedgerEntry."Document Type",'%1',CustLedgerEntry."Document Type"::Invoice);
            IF CustLedgerEntry.FIND('-') THEN BEGIN
               CustLedgerEntry.CALCFIELDS(CustLedgerEntry."Remaining Amount");
               IF CustLedgerEntry."Remaining Amount" =0  THEN BEGIN
                  AppliedCLE.SETFILTER("Entry No." ,'%1',CustLedgerEntry."Closed by Entry No.");
                  IF AppliedCLE.FIND('-') THEN BEGIN

                  IF AppliedCLE."Document Type"=AppliedCLE."Document Type"::"Credit Memo" THEN BEGIN
                     PaymentStatus1 := 'CREDITED';
                     CreditMemoNo := AppliedCLE."Document No.";
                     EXIT;
                  END;

                  IF AppliedCLE."Document Type"=AppliedCLE."Document Type"::Payment THEN BEGIN
                      PaymentStatus2 := 'PAID';
                     CreditMemoNo := AppliedCLE."Document No.";
                  END;

                 END;
               END;
           END;
           CLEAR(CustLedgerEntry);
           */

            //new code

            CustLedgerEntry.SETCURRENTKEY("Document No.", "Document Type", "Customer No.");
            CustLedgerEntry.SETFILTER("Document No.", SalesDocument1);
            CustLedgerEntry.SETFILTER(CustLedgerEntry."Document Type", '%1', CustLedgerEntry."Document Type"::Invoice);
            IF CustLedgerEntry.FIND('-') THEN BEGIN
                CustLedgerEntry.CALCFIELDS(CustLedgerEntry."Remaining Amount");
                IF CustLedgerEntry."Remaining Amount" <> 0 THEN BEGIN
                    PaymentStatus1 := 'UNPAID';
                    CreditMemoNo := '';//DetailedCustLedgEntry."Document No.";
                END;


                IF CustLedgerEntry."Remaining Amount" = 0 THEN BEGIN
                    DetailedCustLedgEntry.RESET;
                    DetailedCustLedgEntry.SETCURRENTKEY("Cust. Ledger Entry No.", "Entry Type", "Posting Date");
                    DetailedCustLedgEntry.SETFILTER("Cust. Ledger Entry No.", '%1', CustLedgerEntry."Entry No.");
                    DetailedCustLedgEntry.SETFILTER(DetailedCustLedgEntry."Entry Type", '%1', DetailedCustLedgEntry."Entry Type"::Application);
                    DetailedCustLedgEntry.SETFILTER(DetailedCustLedgEntry."Document Type",
                                                   '%1', DetailedCustLedgEntry."Document Type"::Payment);
                    IF DetailedCustLedgEntry.FIND('-') THEN BEGIN
                        PaymentStatus1 := 'PAID';
                        CreditMemoNo := DetailedCustLedgEntry."Document No.";
                        EXIT; //24.03.21
                    END;
                END;


                IF CustLedgerEntry."Remaining Amount" = 0 THEN BEGIN
                    DetailedCustLedgEntry.RESET;
                    DetailedCustLedgEntry.SETCURRENTKEY("Cust. Ledger Entry No.", "Entry Type", "Posting Date");
                    DetailedCustLedgEntry.SETFILTER("Cust. Ledger Entry No.", '%1', CustLedgerEntry."Entry No.");
                    DetailedCustLedgEntry.SETFILTER(DetailedCustLedgEntry."Entry Type", '%1', DetailedCustLedgEntry."Entry Type"::Application);
                    DetailedCustLedgEntry.SETFILTER(DetailedCustLedgEntry."Document Type",
                                                   '%1', DetailedCustLedgEntry."Document Type"::"Credit Memo");
                    IF DetailedCustLedgEntry.FIND('-') THEN BEGIN
                        PaymentStatus1 := 'CREDITED';
                        CreditMemoNo := DetailedCustLedgEntry."Document No.";
                    END;
                    //EXIT;
                END;


                IF CustLedgerEntry."Remaining Amount" = 0 THEN BEGIN
                    DetailedCustLedgEntry.RESET;
                    DetailedCustLedgEntry.SETCURRENTKEY("Cust. Ledger Entry No.", "Entry Type", "Posting Date");
                    DetailedCustLedgEntry.SETFILTER("Cust. Ledger Entry No.", '%1', CustLedgerEntry."Entry No.");
                    DetailedCustLedgEntry.SETFILTER("Entry Type", '%1', DetailedCustLedgEntry."Entry Type"::Application);
                    IF DetailedCustLedgEntry.FIND('-') THEN
                        REPEAT
                            IF DetailedCustLedgEntry."Document Type" = DetailedCustLedgEntry."Document Type"::Payment THEN BEGIN
                                PaymentStatus1 := 'PAID';
                                CreditMemoNo := DetailedCustLedgEntry."Document No.";
                            END;
                        UNTIL DetailedCustLedgEntry.NEXT = 0;
                END;


                IF CustLedgerEntry."Remaining Amount" = 0 THEN BEGIN
                    DetailedCustLedgEntry.RESET;
                    DetailedCustLedgEntry.SETCURRENTKEY("Cust. Ledger Entry No.", "Entry Type", "Posting Date");
                    DetailedCustLedgEntry.SETFILTER(DetailedCustLedgEntry."Cust. Ledger Entry No.", '%1', CustLedgerEntry."Entry No.");
                    DetailedCustLedgEntry.SETFILTER(DetailedCustLedgEntry."Entry Type", '%1', DetailedCustLedgEntry."Entry Type"::Application);
                    IF DetailedCustLedgEntry.FIND('-') THEN
                        REPEAT
                            //MESSAGE ( FORMAT(DetailedCustLedgEntry."Entry Type"));
                            PaymentStatus1 := 'PAID';
                            CreditMemoNo := DetailedCustLedgEntry."Document No.";

                            IF DetailedCustLedgEntry."Document Type" = DetailedCustLedgEntry."Document Type"::"Credit Memo" THEN BEGIN
                                PaymentStatus1 := 'CREDITED';
                                CreditMemoNo := DetailedCustLedgEntry."Document No.";
                            END;
                            EXIT;
                        UNTIL DetailedCustLedgEntry.NEXT = 0;
                END;

                IF CustLedgerEntry."Remaining Amount" = 0 THEN BEGIN
                    Cnt := 0;
                    DetailedCustLedgEntry.RESET;
                    DetailedCustLedgEntry.SETCURRENTKEY("Cust. Ledger Entry No.", "Entry Type", "Posting Date");
                    DetailedCustLedgEntry.SETFILTER(DetailedCustLedgEntry."Cust. Ledger Entry No.", '%1', CustLedgerEntry."Entry No.");
                    IF DetailedCustLedgEntry.FIND('-') THEN
                        REPEAT
                            IF DetailedCustLedgEntry."Entry Type" = DetailedCustLedgEntry."Entry Type"::"Initial Entry" THEN
                                Cnt := 0;

                            IF DetailedCustLedgEntry."Entry Type" = DetailedCustLedgEntry."Entry Type"::Application THEN
                                Cnt := Cnt + 1;

                        UNTIL DetailedCustLedgEntry.NEXT = 0;
                    IF Cnt > 0 THEN BEGIN
                        PaymentStatus1 := 'PAID';
                        CreditMemoNo := DetailedCustLedgEntry."Document No.";
                    END;

                    IF Cnt = 0 THEN BEGIN
                        PaymentStatus1 := 'UNPAID';
                        CreditMemoNo := '';//DetailedCustLedgEntry."Document No.";
                    END;
                END;
            END;
        END;


        ReRaisedText := '';
        SalesInvoiceHeader1.SETFILTER(SalesInvoiceHeader1."Re-Raise Invoice No", rec."No.");
        IF SalesInvoiceHeader1.FIND('+') THEN
            ReRaisedText := 'This Document has been Re-Raised'
        ELSE
            ReRaisedText := '';



        /*
        SETRANGE("No.");
        Paid := 0;
        
        IF PreviousDocNo <> "No." THEN BEGIN
            PaymentStatus1 :='';
           PreviousDocNo :="No.";
           CreditMemoNo := '';
           SalesDocument1:='';
        
        
          //Checking Original Knowledge Pass Invoice Payment Status Start
          IF SalesInvoiceHeader2.GET(Rec."No.") THEN BEGIN
          IF SalesInvoiceHeader2."Payment Information"=SalesInvoiceHeader2."Payment Information"::"Knowledge / Flexi Pass" THEN BEGIN
             SalesInvoiceLine.SETFILTER("Document No.",SalesInvoiceHeader2."No.");
             SalesInvoiceLine.SETFILTER(SalesInvoiceLine."KP No.",'<>%1','');
             IF SalesInvoiceLine.FIND('-') THEN
             SalesDocument1 := SalesInvoiceLine."KP No.";
          END;
          END;
          //Checking Original Knowledge Pass Invoice Payment Status End
          IF SalesDocument1='' THEN
          SalesDocument1 := Rec."No.";
          //new code
          CLEAR(CustLedgerEntry);
          CustLedgerEntry.SETCURRENTKEY("Document No.","Document Type","Customer No.");
          CustLedgerEntry.SETFILTER("Document No.",SalesDocument1);
          CustLedgerEntry.SETFILTER(CustLedgerEntry."Document Type",'%1',CustLedgerEntry."Document Type"::Invoice);
          IF CustLedgerEntry.FIND('-') THEN BEGIN
             CustLedgerEntry.CALCFIELDS(CustLedgerEntry."Remaining Amount");
             IF CustLedgerEntry."Remaining Amount" =0  THEN BEGIN
                AppliedCLE.SETFILTER("Closed by Entry No." ,'%1',CustLedgerEntry."Entry No.");
                IF AppliedCLE.FIND('-') THEN BEGIN
                IF AppliedCLE."Document Type"=AppliedCLE."Document Type"::"Credit Memo" THEN BEGIN
                   PaymentStatus1 := 'CREDITED';
                   CreditMemoNo := AppliedCLE."Document No.";
                   EXIT;
                END;
                END;
             END;
         END;
         CLEAR(CustLedgerEntry);
        
          //new code
        
          CustLedgerEntry.SETCURRENTKEY("Document No.","Document Type","Customer No.");
          CustLedgerEntry.SETFILTER("Document No.",SalesDocument1);
          CustLedgerEntry.SETFILTER(CustLedgerEntry."Document Type",'%1',CustLedgerEntry."Document Type"::Invoice);
          IF CustLedgerEntry.FIND('-') THEN BEGIN
             CustLedgerEntry.CALCFIELDS(CustLedgerEntry."Remaining Amount");
             IF CustLedgerEntry."Remaining Amount" <>0  THEN BEGIN
             PaymentStatus1 := 'UNPAID';
             CreditMemoNo := '';//DetailedCustLedgEntry."Document No.";
             END;
        
        
             IF CustLedgerEntry."Remaining Amount" =0  THEN BEGIN
                DetailedCustLedgEntry.RESET;
                DetailedCustLedgEntry.SETCURRENTKEY("Cust. Ledger Entry No.","Entry Type","Posting Date");
                DetailedCustLedgEntry.SETFILTER("Cust. Ledger Entry No.",'%1',CustLedgerEntry."Entry No.");
                DetailedCustLedgEntry.SETFILTER(DetailedCustLedgEntry."Entry Type",'%1',DetailedCustLedgEntry."Entry Type"::Application);
                DetailedCustLedgEntry.SETFILTER(DetailedCustLedgEntry."Document Type",
                                               '%1',DetailedCustLedgEntry."Document Type"::Payment);
                IF DetailedCustLedgEntry.FIND('-') THEN BEGIN
                PaymentStatus1 := 'PAID';
                CreditMemoNo := DetailedCustLedgEntry."Document No.";
                EXIT; //24.03.21
                END;
             END;
        
        
             IF CustLedgerEntry."Remaining Amount" =0  THEN BEGIN
                DetailedCustLedgEntry.RESET;
                DetailedCustLedgEntry.SETCURRENTKEY("Cust. Ledger Entry No.","Entry Type","Posting Date");
                DetailedCustLedgEntry.SETFILTER("Cust. Ledger Entry No.",'%1',CustLedgerEntry."Entry No.");
                DetailedCustLedgEntry.SETFILTER(DetailedCustLedgEntry."Entry Type",'%1',DetailedCustLedgEntry."Entry Type"::Application);
                DetailedCustLedgEntry.SETFILTER(DetailedCustLedgEntry."Document Type",
                                               '%1',DetailedCustLedgEntry."Document Type"::"Credit Memo");
                IF DetailedCustLedgEntry.FIND('-') THEN BEGIN
                PaymentStatus1 := 'CREDITED';
                CreditMemoNo := DetailedCustLedgEntry."Document No.";
                END;
                //EXIT;
             END;
        
        
             IF CustLedgerEntry."Remaining Amount" =0  THEN BEGIN
                DetailedCustLedgEntry.RESET;
                DetailedCustLedgEntry.SETCURRENTKEY("Cust. Ledger Entry No.","Entry Type","Posting Date");
                DetailedCustLedgEntry.SETFILTER("Cust. Ledger Entry No.",'%1',CustLedgerEntry."Entry No.");
                DetailedCustLedgEntry.SETFILTER("Entry Type",'%1',DetailedCustLedgEntry."Entry Type"::Application);
                IF DetailedCustLedgEntry.FIND('-') THEN REPEAT
                  IF DetailedCustLedgEntry."Document Type"= DetailedCustLedgEntry."Document Type"::Payment THEN BEGIN
                  PaymentStatus1 := 'PAID';
                  CreditMemoNo := DetailedCustLedgEntry."Document No.";
                  END;
                UNTIL DetailedCustLedgEntry.NEXT=0;
             END;
        
        
             IF CustLedgerEntry."Remaining Amount" =0  THEN BEGIN
                DetailedCustLedgEntry.RESET;
                DetailedCustLedgEntry.SETCURRENTKEY("Cust. Ledger Entry No.","Entry Type","Posting Date");
                DetailedCustLedgEntry.SETFILTER(DetailedCustLedgEntry."Cust. Ledger Entry No.",'%1',CustLedgerEntry."Entry No.");
                DetailedCustLedgEntry.SETFILTER(DetailedCustLedgEntry."Entry Type",'%1',DetailedCustLedgEntry."Entry Type"::Application);
                IF DetailedCustLedgEntry.FIND('-') THEN REPEAT
                //MESSAGE ( FORMAT(DetailedCustLedgEntry."Entry Type"));
                PaymentStatus1 := 'PAID';
                CreditMemoNo := DetailedCustLedgEntry."Document No.";
        
               IF DetailedCustLedgEntry."Document Type"= DetailedCustLedgEntry."Document Type"::"Credit Memo" THEN BEGIN
                PaymentStatus1 := 'CREDITED';
                CreditMemoNo := DetailedCustLedgEntry."Document No.";
                END;
                EXIT;
                UNTIL DetailedCustLedgEntry.NEXT=0;
             END;
        
             IF CustLedgerEntry."Remaining Amount" =0  THEN BEGIN
                Cnt := 0;
                DetailedCustLedgEntry.RESET;
                DetailedCustLedgEntry.SETCURRENTKEY("Cust. Ledger Entry No.","Entry Type","Posting Date");
                DetailedCustLedgEntry.SETFILTER(DetailedCustLedgEntry."Cust. Ledger Entry No.",'%1',CustLedgerEntry."Entry No.");
                IF DetailedCustLedgEntry.FIND('-') THEN REPEAT
                IF DetailedCustLedgEntry."Entry Type" = DetailedCustLedgEntry."Entry Type"::"Initial Entry" THEN
                Cnt := 0;
        
                IF DetailedCustLedgEntry."Entry Type" = DetailedCustLedgEntry."Entry Type"::Application THEN
                Cnt :=Cnt+1;
        
                UNTIL DetailedCustLedgEntry.NEXT=0;
                IF Cnt>0 THEN BEGIN
                PaymentStatus1 := 'PAID';
                CreditMemoNo := DetailedCustLedgEntry."Document No.";
                END;
        
                IF Cnt=0 THEN BEGIN
                PaymentStatus1 := 'UNPAID';
                CreditMemoNo := '';//DetailedCustLedgEntry."Document No.";
                END;
             END;
          END;
        END;
        
        
        ReRaisedText:='';
        SalesInvoiceHeader1.SETFILTER(SalesInvoiceHeader1."Re-Raise Invoice No","No.");
        IF SalesInvoiceHeader1.FIND('+') THEN
        ReRaisedText := 'This Document has been Re-Raised'
        ELSE
        ReRaisedText := '';
        */
        CreditStatus := '';
        //NB
        IF rec.PaymentStatus3 = 'CREDITED' THEN BEGIN
            scmh.SETFILTER(scmh."No.", rec.CreditMemoNo3);
            IF scmh.FINDFIRST THEN BEGIN
                rc.SETFILTER(rc.Code, scmh."Reason Code");
                IF rc.FINDFIRST THEN CreditStatus := FORMAT(rc."Credit Status");
            END;
        END;
        //Nb

        OnAfterGetCurrRecord;
        // UpdateDocAndAmount; //nb 300824

    end;

    trigger OnInit()
    begin
        GSTIDVisible := TRUE;
        FuncFunctionVisible := TRUE;
        FuncNavigateVisible := TRUE;
        FuncLineVisible := TRUE;
        FuncNameVisible := TRUE;
        BtnEmailVisible := TRUE;
        Func2Visible := TRUE;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        OnAfterGetCurrRecord;
    end;

    trigger OnOpenPage()
    begin
        //DOC TKA130513 -
        CompanyInformation.GET;
        IF NOT CountryRegion.GET(CompanyInformation."Country/Region Code") THEN
            CLEAR(CountryRegion);
        CountryRegion.CALCFIELDS("National Flag (Card)");
        //DOC TKA130513 +


        // IF UPPERCASE(USERID) IN ['MARTHA.FOLKES', 'BIJU.KURUP', 'PRABHJOT.KAUR', 'SIMRAT.KAUR', 'KIRAN.MADHAR'] THEN
        //     Func2Visible := TRUE
        // ELSE
        //     Func2Visible := FALSE; abhi
        //19 Sept 2022
        UserSetup.GET(USERID);
        IF UserSetup.EmailAccess = FALSE THEN
            BtnEmailVisible := FALSE
        ELSE
            BtnEmailVisible := TRUE;

        //19 Sept 2022

        User1.GET(UPPERCASE(USERID));
        IF User1."Restrict India User" THEN BEGIN

            FuncNameVisible := FALSE;
            FuncLineVisible := FALSE;
            FuncNavigateVisible := FALSE;
            FuncFunctionVisible := FALSE;
            BtnEmailVisible := FALSE;

        END;
        IF NOT (COMPANYNAME = 'TKA India') THEN
            GSTIDVisible := FALSE;
    end;


    local procedure UpdateDocAndAmount()
    var
        crMemo: record "Sales Cr.Memo Header";
    begin
        //NB 210824
        rec."Paid Amount" := 0;
        cle.Reset();
        cle.SetCurrentKey("Document Type", "Document No.");
        cle.SetFilter("Document Type", '%1', cle."Document Type"::Invoice);
        cle.SetFilter("Document No.", '%1', rec."No.");
        if cle.FindFirst() then begin
            GetAppliedentries(cle);
            if cle.FindFirst() then;
            CLEDocumentNo := cle."Document No.";
            repeat
                if (cle."Document Type" = cle."Document Type"::payment) OR (cle."Document Type" = cle."Document Type"::" ") then begin
                    cle.CalcFields(Amount);
                    rec.Validate("Paid Amount", rec."Paid Amount" + abs(cle.Amount));
                    // rec."Paid Amount" += cle.Amount;
                end
                else begin
                    cle.CalcFields(Amount);
                    rec.Validate("Paid Amount", rec."Paid Amount" - abs(cle.Amount));
                    if crMemo.get(cle."Document No.") then rec.CreditStatus := crMemo."Reason Code";
                end;
            until cle.next = 0;
            rec.Modify();
        end;
        // CurrPage.Update(true);
        //NB 210824
    end;

    procedure CreateCrMemo(pSalesInvHeader: Record 112)
    var
        lSalesHeader: Record 36;
        lSalesSetup: Record "311";
        lCopyDocMgt: Codeunit "6620";
        lDocType: Option Quote,"Blanket Order","Order",Invoice,"Return Order","Credit Memo","Posted Shipment","Posted Invoice","Posted Return Receipt","Posted Credit Memo";
        lDocNo: Code[20];
    begin
        lDocType := lDocType::"Posted Invoice";
        lDocNo := pSalesInvHeader."No.";
        lSalesHeader.INIT;
        lSalesHeader.VALIDATE("Document Type", lSalesHeader."Document Type"::"Credit Memo");
        lSalesHeader."No." := '';
        lSalesHeader.INSERT(TRUE);
        lSalesSetup.GET;
        lCopyDocMgt.SetProperties(TRUE, FALSE, FALSE, FALSE, FALSE, lSalesSetup."Exact Cost Reversing Mandatory", FALSE);
        lCopyDocMgt.CopySalesDoc(lDocType, lDocNo, lSalesHeader);
        COMMIT;
        lSalesHeader.FIND('=');
        lSalesHeader.SetHideValidationDialog(TRUE);
        //lSalesHeader.VALIDATE("Posting Date",TODAY);
        lSalesHeader.VALIDATE("Document Date", TODAY);
        //DSS
        lSalesHeader."Created By" := USERID;
        lSalesHeader."Created Date" := TODAY;
        lSalesHeader."Created Time" := TIME;
        lSalesHeader."External Document No." := pSalesInvHeader."No.";//11.03.21
        //DSS

        lSalesHeader."Currency Code" := rec."Currency Code";
        lSalesHeader.VALIDATE("Currency Factor", rec."Currency Factor");
        lSalesHeader."Cr Memo created from Invoice" := rec."No.";
        //NB
        lSalesHeader."Payment Information" := rec."Payment Information";

        lSalesHeader.MODIFY(TRUE);
        COMMIT;
        MESSAGE('%1 %2 has been created.', lSalesHeader."Document Type", lSalesHeader."No.");
        lSalesHeader.SETRECFILTER;
        PAGE.RUNMODAL(50060, lSalesHeader);
    end;

    procedure OrderConfirmationKP()
    var
        lTKAEmailMgt: Codeunit 50005;
        lMainEmailID: Text[1024];
        lOtherEmailIDS: Text[1024];
        lFileInfo: Text[1024];
    begin
        IF rec."Knowledge Pass" THEN BEGIN
            lTKAEmailMgt.InvoiceFromPostedInvoice2(rec."No.", TRUE);
            lTKAEmailMgt.GetEmailAndFileValues(lMainEmailID, lOtherEmailIDS, lFileInfo);
            // IF lFileInfo <> '' THEN
            //     IF FILE.ERASE(lFileInfo) THEN;
        END
    end;

    procedure OrderConfirmationFP()
    var
        lTKAEmailMgt: Codeunit 50005;
        lMainEmailID: Text[1024];
        lOtherEmailIDS: Text[1024];
        lFileInfo: Text[1024];
    begin
        //IF ("Flexi Pass" OR "Flexi Pass 12") THEN BEGIN
        IF (rec."Flexi Pass" OR rec."Flexi Pass 12" OR rec."Flexi Pass 2") THEN BEGIN
            lTKAEmailMgt.InvoiceFromPostedInvoiceFP(rec."No.", TRUE);
            lTKAEmailMgt.GetEmailAndFileValues(lMainEmailID, lOtherEmailIDS, lFileInfo);
            // IF lFileInfo <> '' THEN
            //     IF FILE.ERASE(lFileInfo) THEN;
        END
    end;

    procedure OrderConfirmationELearn()
    var
        lTKAEmailMgt: Codeunit 50005;
        lMainEmailID: Text[1024];
        lOtherEmailIDS: Text[1024];
        lFileInfo: Text[1024];
    begin
        IF rec."E-Learning" THEN BEGIN
            lTKAEmailMgt.InvoiceFromPostedInvoiceELearn(rec."No.", TRUE);
            lTKAEmailMgt.GetEmailAndFileValues(lMainEmailID, lOtherEmailIDS, lFileInfo);
            // IF lFileInfo <> '' THEN
            //     IF FILE.ERASE(lFileInfo) THEN;
        END
    end;

    procedure CreateSalesOrder(pSalesInvHeader: Record 112)
    var
        lSalesHeader: Record 36;
        lSalesSetup: Record "311";
        lCopyDocMgt: Codeunit "6620";
        lDocType: Option Quote,"Blanket Order","Order",Invoice,"Return Order","Credit Memo","Posted Shipment","Posted Invoice","Posted Return Receipt","Posted Credit Memo";
        lDocNo: Code[20];
    begin
        lDocType := lDocType::"Posted Invoice";
        lDocNo := pSalesInvHeader."No.";
        lSalesHeader.INIT;
        lSalesHeader.VALIDATE("Document Type", lSalesHeader."Document Type"::Order);
        lSalesHeader."No." := '';
        lSalesHeader.INSERT(TRUE);
        lSalesSetup.GET;
        lCopyDocMgt.SetProperties(TRUE, FALSE, FALSE, FALSE, FALSE, lSalesSetup."Exact Cost Reversing Mandatory", FALSE);
        lCopyDocMgt.CopySalesDoc(lDocType, lDocNo, lSalesHeader);
        COMMIT;
        lSalesHeader.FIND('=');
        lSalesHeader.SetHideValidationDialog(TRUE);
        //lSalesHeader.VALIDATE("Posting Date",TODAY);
        lSalesHeader.VALIDATE("Document Date", TODAY);
        //DSS
        lSalesHeader."Created By" := USERID;
        lSalesHeader."Created Date" := TODAY;
        lSalesHeader."Created Time" := TIME;
        lSalesHeader."Re-Raised from Invoice" := TRUE;
        lSalesHeader.VALIDATE("Posting Date", TODAY);
        lSalesHeader.VALIDATE("Document Date", TODAY);
        lSalesHeader."Re-Raise Invoice No" := rec."No.";
        lSalesHeader."Salesperson Code" := 'C.NOTE';


        //DSS
        //abhishek 15.11.22
        Salesline1.RESET;
        Salesline1.SETRANGE(Salesline1."Document Type", Salesline1."Document Type"::Order);
        Salesline1.SETRANGE(Salesline1."Document No.", lSalesHeader."No.");
        IF Salesline1.FINDSET THEN
            REPEAT
                IF Salesline1."No." = '' THEN
                    Salesline1.DELETE;

            UNTIL Salesline1.NEXT = 0;

        //abhishek

        lSalesHeader.MODIFY(TRUE);
        COMMIT;
        MESSAGE('%1 %2 has been created.', lSalesHeader."Document Type", lSalesHeader."No.");
        lSalesHeader.SETRECFILTER;
        PAGE.RUNMODAL(50046, lSalesHeader);
    end;

    procedure Export_SalesData1()
    var
        lInt: Integer;
        lDate1: Date;
        lDate2: Date;
        GLEntry: Record "17";
        SalesInvoiceLine: Record 113;
        Contact: Record 5050;
        SalesInvoiceHeader: Record 112;
        PreviousDocNo: Code[20];
        GLEntry1: Record "17";
        GLEntry1Description: Text[50];
        EventHeader: Record 50006;
        SalesInvoiceLine1: Record 113;
        "Sales Cr.Memo Line": Record "115";
        "Salesperson/Purchaser1": Record 13;
        SalesPersonName: Text[50];
        "General Ledger Setup1": Record "98";
        CurrencyCode1: Code[10];
        Company: Record 2000000006;
    begin
        CLEAR(ExcelBuffer);
        FromDate := 0D;
        ToDate := 0D;
        //GLCode:='';


        Window.OPEN('Enter From Date #1##########  To Date #2##########  ');
        // Window.INPUT(1,FromDate);
        // Window.INPUT(2,ToDate);
        //Window.INPUT(3,GLCode);
        Window.CLOSE;



        Window.OPEN('Exporting @1@@@@@@@@@@@@@@@@@@@@@@@@@\ \');
        Window.UPDATE(1, 0);
        ////ExcelBuffer.SetUseInfoSheed;
        //ExcelBuffer.NewRow;


        RowNum := 0;
        ColumnNum := 0;
        //RecNo :=0;

        RowNum += 1;
        ColumnNum += 1;
        EnterCell('Date Paid', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('Posting Date', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('Document No', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('Customer No', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('Customer Name', TRUE, FALSE, '@');
        //ColumnNum += 1; EnterCell('Location',TRUE,FALSE,'@');
        ColumnNum += 1;
        EnterCell('SO No', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('Exc Vat LCY', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('Inc Vat LCY', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('Currency Code', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('EX. Rate', TRUE, FALSE, '@');

        ColumnNum += 1;
        EnterCell('Exc Vat In GBP', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('Inc Vat In GBP', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('Status', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('SalesPerson', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('SalesPerson Name', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('Company Name', TRUE, FALSE, '@');

        Company.SETFILTER(Company.Name, '<>%1', 'aa');
        IF Company.FIND('-') THEN
            REPEAT

                CLEAR(SalesInvoiceHeader);
                CLEAR("General Ledger Setup1");
                CLEAR(Team);
                CLEAR("Salesperson/Purchaser1");

                SalesInvoiceHeader.CHANGECOMPANY(Company.Name);

                "General Ledger Setup1".CHANGECOMPANY(Company.Name);
                Team.CHANGECOMPANY(Company.Name);
                "Salesperson/Purchaser1".CHANGECOMPANY(Company.Name);


                "General Ledger Setup1".GET;

                SalesInvoiceHeader.SETCURRENTKEY("Posting Date", "No.");
                SalesInvoiceHeader.SETFILTER("Posting Date", '%1..%2', FromDate, ToDate);//010920D);
                IF SalesInvoiceHeader.FIND('-') THEN
                    REPEAT
                        ExchangeRate1 := 0;
                        AmountGBP1 := 0;
                        AmountGBPIncludingTax := 0;
                        PaymentStatus1 := '';
                        DatePaid1 := 0D;

                        SalesPersonName := '';
                        IF "Salesperson/Purchaser1".GET(SalesInvoiceHeader."Salesperson Code") THEN
                            SalesPersonName := "Salesperson/Purchaser1".Name;

                        SalesInvoiceHeader.CALCFIELDS(Amount, "Amount Including VAT");

                        IF Team.GET(SalesInvoiceHeader."Salesperson Code") THEN BEGIN
                            IF Team."Manager Name" = 'K.RANDAWA' THEN BEGIN
                                IF SalesInvoiceHeader."Currency Factor" <> 0 THEN
                                    ExchangeRate1 := 1 / SalesInvoiceHeader."Currency Factor";

                                IF ExchangeRate1 = 0 THEN
                                    ExchangeRate1 := 1;

                                DatePaid1 := 0D;
                                UpdatePaymentStatus(SalesInvoiceHeader."No.", Company.Name);

                                AmountGBP1 := SalesInvoiceHeader.Amount * ExchangeRate1;//CF;
                                AmountGBPIncludingTax := SalesInvoiceHeader."Amount Including VAT" * ExchangeRate1;//CF;

                                CurrencyCode1 := '';
                                IF SalesInvoiceHeader."Currency Code" = '' THEN
                                    CurrencyCode1 := "General Ledger Setup1"."LCY Code"
                                ELSE
                                    CurrencyCode1 := SalesInvoiceHeader."Currency Code";


                                RowNum += 1;
                                ColumnNum := 0;

                                IF PaymentStatus1 = 'UNPAID' THEN
                                    DatePaid1 := 0D;

                                ColumnNum += 1;
                                EnterCell(FORMAT(DatePaid1), FALSE, FALSE, '@');
                                ColumnNum += 1;
                                EnterCell(FORMAT(SalesInvoiceHeader."Posting Date"), FALSE, FALSE, '@');
                                ColumnNum += 1;
                                EnterCell(FORMAT(SalesInvoiceHeader."No."), FALSE, FALSE, '@');
                                ColumnNum += 1;
                                EnterCell(FORMAT(SalesInvoiceHeader."Sell-to Customer No."), FALSE, FALSE, '@');

                                ColumnNum += 1;
                                EnterCell(FORMAT(SalesInvoiceHeader."Sell-to Customer Name"), FALSE, FALSE, '@');
                                ColumnNum += 1;
                                EnterCell(FORMAT(SalesInvoiceHeader."Order No."), FALSE, FALSE, '@');
                                ColumnNum += 1;
                                EnterCell(FORMAT(SalesInvoiceHeader.Amount), FALSE, FALSE, '#,##0.00');
                                ColumnNum += 1;
                                EnterCell(FORMAT(SalesInvoiceHeader."Amount Including VAT"), FALSE, FALSE, '#,##0.00');
                                ColumnNum += 1;
                                EnterCell(FORMAT(CurrencyCode1), FALSE, FALSE, '#,##0.00');
                                ColumnNum += 1;
                                EnterCell(FORMAT(ExchangeRate1), FALSE, FALSE, '#,##0.00');

                                ColumnNum += 1;
                                EnterCell(FORMAT(AmountGBP1), FALSE, FALSE, '#,##0.00');
                                ColumnNum += 1;
                                EnterCell(FORMAT(AmountGBPIncludingTax), FALSE, FALSE, '#,##0.00');
                                ColumnNum += 1;
                                EnterCell(FORMAT(PaymentStatus1), FALSE, FALSE, '@');
                                ColumnNum += 1;
                                EnterCell(FORMAT(SalesInvoiceHeader."Salesperson Code"), FALSE, FALSE, '#,##0.00');
                                ColumnNum += 1;
                                EnterCell(FORMAT(SalesPersonName), FALSE, FALSE, '@');
                                ColumnNum += 1;
                                EnterCell(FORMAT(Company.Name), FALSE, FALSE, '@');



                            END;
                        END;
                    UNTIL SalesInvoiceHeader.NEXT = 0;
            UNTIL Company.NEXT = 0;

        Window.CLOSE;
    end;

    procedure UpdatePaymentStatus(SINVNO: Code[20]; CompanyName1: Text[80])
    var
        "Remaining Amount": Decimal;
        USetting: Record 91;
        CustName: Text[100];
        Customer: Record "18";
        "GL Balance": Decimal;
        Cnt: Integer;
        ColourValue: Integer;
        SalesInvoiceLine1: Record 113;
        EVECHECK: Text[3];
        CreditMemoNo: Code[20];
        SalesCrMemoHeader: Record 114;
        SalesInvoiceHeader: Record 112;
        UserSetup: Record 91;
        SalesInvoiceHeader1: Record 112;
        CustLedgerEntry: Record "21";
        DetailedCustLedgEntry: Record "379";
    begin
        CLEAR(CustLedgerEntry);
        CLEAR(DetailedCustLedgEntry);


        CustLedgerEntry.CHANGECOMPANY(CompanyName1);
        DetailedCustLedgEntry.CHANGECOMPANY(CompanyName1);



        PaymentStatus1 := '';
        DatePaid1 := 0D;
        CreditMemoNo := '';
        CustLedgerEntry.SETCURRENTKEY("Document No.", "Document Type", "Customer No.");
        CustLedgerEntry.SETFILTER("Document No.", SINVNO);//"Knowledge Pass Inventory"."KP Invoice No.");
        CustLedgerEntry.SETFILTER(CustLedgerEntry."Document Type", '%1', CustLedgerEntry."Document Type"::Invoice);
        IF CustLedgerEntry.FIND('-') THEN BEGIN
            CustLedgerEntry.CALCFIELDS(CustLedgerEntry."Remaining Amount");
            IF CustLedgerEntry."Remaining Amount" <> 0 THEN BEGIN
                PaymentStatus1 := 'UNPAID';
                DatePaid1 := CustLedgerEntry."Posting Date";
                //"Knowledge Pass Inventory".PaymentStatus :='UNPAID';
                //"Knowledge Pass Inventory".MODIFY;

                CreditMemoNo := '';//DetailedCustLedgEntry."Document No.";
            END;


            IF CustLedgerEntry."Remaining Amount" = 0 THEN BEGIN
                DetailedCustLedgEntry.RESET;
                DetailedCustLedgEntry.SETCURRENTKEY("Cust. Ledger Entry No.", "Entry Type", "Posting Date");
                DetailedCustLedgEntry.SETFILTER("Cust. Ledger Entry No.", '%1', CustLedgerEntry."Entry No.");
                DetailedCustLedgEntry.SETFILTER(DetailedCustLedgEntry."Entry Type", '%1', DetailedCustLedgEntry."Entry Type"::Application);
                DetailedCustLedgEntry.SETFILTER(DetailedCustLedgEntry."Document Type",
                                               '%1', DetailedCustLedgEntry."Document Type"::Payment);
                IF DetailedCustLedgEntry.FIND('-') THEN BEGIN
                    PaymentStatus1 := 'PAID';
                    DatePaid1 := DetailedCustLedgEntry."Posting Date";
                    // "Knowledge Pass Inventory".PaymentStatus :='PAID';
                    // "Knowledge Pass Inventory".MODIFY;

                    CreditMemoNo := DetailedCustLedgEntry."Document No.";
                END;
            END;


            IF CustLedgerEntry."Remaining Amount" = 0 THEN BEGIN
                DetailedCustLedgEntry.RESET;
                DetailedCustLedgEntry.SETCURRENTKEY("Cust. Ledger Entry No.", "Entry Type", "Posting Date");
                DetailedCustLedgEntry.SETFILTER("Cust. Ledger Entry No.", '%1', CustLedgerEntry."Entry No.");
                DetailedCustLedgEntry.SETFILTER(DetailedCustLedgEntry."Entry Type", '%1', DetailedCustLedgEntry."Entry Type"::Application);
                DetailedCustLedgEntry.SETFILTER(DetailedCustLedgEntry."Document Type",
                                               '%1', DetailedCustLedgEntry."Document Type"::"Credit Memo");
                IF DetailedCustLedgEntry.FIND('-') THEN BEGIN
                    PaymentStatus1 := 'CREDITED';
                    DatePaid1 := DetailedCustLedgEntry."Posting Date";
                    // "Knowledge Pass Inventory".PaymentStatus :='CREDITED';
                    // "Knowledge Pass Inventory".MODIFY;

                    CreditMemoNo := DetailedCustLedgEntry."Document No.";
                END;
                //EXIT;
            END;


            IF CustLedgerEntry."Remaining Amount" = 0 THEN BEGIN
                DetailedCustLedgEntry.RESET;
                DetailedCustLedgEntry.SETCURRENTKEY("Cust. Ledger Entry No.", "Entry Type", "Posting Date");
                DetailedCustLedgEntry.SETFILTER("Cust. Ledger Entry No.", '%1', CustLedgerEntry."Entry No.");
                DetailedCustLedgEntry.SETFILTER("Entry Type", '%1', DetailedCustLedgEntry."Entry Type"::Application);
                IF DetailedCustLedgEntry.FIND('-') THEN
                    REPEAT
                        IF DetailedCustLedgEntry."Document Type" = DetailedCustLedgEntry."Document Type"::Payment THEN BEGIN
                            PaymentStatus1 := 'PAID';
                            DatePaid1 := DetailedCustLedgEntry."Posting Date";
                            // "Knowledge Pass Inventory".PaymentStatus :='PAID';
                            // "Knowledge Pass Inventory".MODIFY;

                            CreditMemoNo := DetailedCustLedgEntry."Document No.";
                        END;
                    UNTIL DetailedCustLedgEntry.NEXT = 0;
            END;


            IF CustLedgerEntry."Remaining Amount" = 0 THEN BEGIN
                DetailedCustLedgEntry.RESET;
                DetailedCustLedgEntry.SETCURRENTKEY("Cust. Ledger Entry No.", "Entry Type", "Posting Date");
                DetailedCustLedgEntry.SETFILTER(DetailedCustLedgEntry."Cust. Ledger Entry No.", '%1', CustLedgerEntry."Entry No.");
                DetailedCustLedgEntry.SETFILTER(DetailedCustLedgEntry."Entry Type", '%1', DetailedCustLedgEntry."Entry Type"::Application);
                IF DetailedCustLedgEntry.FIND('-') THEN
                    REPEAT
                        //MESSAGE ( FORMAT(DetailedCustLedgEntry."Entry Type"));
                        PaymentStatus1 := 'PAID';
                        DatePaid1 := DetailedCustLedgEntry."Posting Date";
                        //"Knowledge Pass Inventory".PaymentStatus :='PAID';
                        // "Knowledge Pass Inventory".MODIFY;

                        CreditMemoNo := DetailedCustLedgEntry."Document No.";

                        IF DetailedCustLedgEntry."Document Type" = DetailedCustLedgEntry."Document Type"::"Credit Memo" THEN BEGIN
                            PaymentStatus1 := 'CREDITED';
                            DatePaid1 := DetailedCustLedgEntry."Posting Date";
                            //"Knowledge Pass Inventory".PaymentStatus :='CREDITED';
                            // "Knowledge Pass Inventory".MODIFY;

                            CreditMemoNo := DetailedCustLedgEntry."Document No.";
                        END;
                        EXIT;
                    UNTIL DetailedCustLedgEntry.NEXT = 0;
            END;

            IF CustLedgerEntry."Remaining Amount" = 0 THEN BEGIN
                Cnt := 0;
                DetailedCustLedgEntry.RESET;
                DetailedCustLedgEntry.SETCURRENTKEY("Cust. Ledger Entry No.", "Entry Type", "Posting Date");
                DetailedCustLedgEntry.SETFILTER(DetailedCustLedgEntry."Cust. Ledger Entry No.", '%1', CustLedgerEntry."Entry No.");
                IF DetailedCustLedgEntry.FIND('-') THEN
                    REPEAT
                        IF DetailedCustLedgEntry."Entry Type" = DetailedCustLedgEntry."Entry Type"::"Initial Entry" THEN
                            Cnt := 0;

                        IF DetailedCustLedgEntry."Entry Type" = DetailedCustLedgEntry."Entry Type"::Application THEN
                            Cnt := Cnt + 1;

                    UNTIL DetailedCustLedgEntry.NEXT = 0;
                IF Cnt > 0 THEN BEGIN
                    PaymentStatus1 := 'PAID';
                    DatePaid1 := DetailedCustLedgEntry."Posting Date";
                    // "Knowledge Pass Inventory".PaymentStatus :='PAID';
                    // "Knowledge Pass Inventory".MODIFY;

                    CreditMemoNo := DetailedCustLedgEntry."Document No.";
                END;

                IF Cnt = 0 THEN BEGIN
                    PaymentStatus1 := 'UNPAID';
                    DatePaid1 := DetailedCustLedgEntry."Posting Date";
                    // "Knowledge Pass Inventory".PaymentStatus :='UNPAID';
                    // "Knowledge Pass Inventory".MODIFY;

                    CreditMemoNo := '';//DetailedCustLedgEntry."Document No.";
                END;
            END;
        END;
        //END;
        //Show Payment Status
        //UNTIL "Knowledge Pass Inventory".NEXT=0;
    end;

    local procedure EnterCell(pCellValue: Text[250]; pBold: Boolean; pUnderLine: Boolean; Numberformat: Text[50])
    begin
        ExcelBuffer.INIT;
        ExcelBuffer.VALIDATE("Row No.", RowNum);
        ExcelBuffer.VALIDATE("Column No.", ColumnNum);
        ExcelBuffer."Cell Value as Text" := pCellValue;
        ExcelBuffer.Formula := '';
        //ExcelBuffer.NumberFormat := '@';
        ExcelBuffer.NumberFormat := Numberformat;
        ExcelBuffer.Bold := pBold;
        ExcelBuffer.Underline := pUnderLine;
        ExcelBuffer.INSERT;
    end;

    procedure SplitName(pName: Text[50]; pPart: Integer): Text[50]
    begin
        IF pName = '' THEN
            EXIT('');
        pName := DELCHR(pName, '<');
        IF STRPOS(pName, ' ') = 0 THEN BEGIN
            IF pPart = 1 THEN
                EXIT(pName);
            EXIT('');
        END;
        IF pPart = 1 THEN
            EXIT(COPYSTR(pName, 1, STRPOS(pName, ' ') - 1))
        ELSE
            EXIT(COPYSTR(pName, STRPOS(pName, ' ') + 1));
    end;

    procedure Export_SalesData()
    var
        lInt: Integer;
        lDate1: Date;
        lDate2: Date;
        GLEntry: Record "17";
        SalesInvoiceLine: Record 113;
        Contact: Record 5050;
        SalesInvoiceHeader: Record 112;
        PreviousDocNo: Code[20];
        GLEntry1: Record "17";
        GLEntry1Description: Text[50];
        EventHeader: Record 50006;
        SalesInvoiceLine1: Record 113;
        "Sales Cr.Memo Line": Record "115";
        "Salesperson/Purchaser1": Record 13;
        SalesPersonName: Text[50];
        "General Ledger Setup1": Record "98";
        CurrencyCode1: Code[10];
        Company: Record 2000000006;
        Curexch: Record "330";
        CF: Decimal;
    begin
        CLEAR(ExcelBuffer);
        FromDate := 0D;
        ToDate := 0D;
        //GLCode:='';


        Window.OPEN('Enter From Date #1##########  To Date #2##########  ');
        // Window.INPUT(1,FromDate);
        // Window.INPUT(2,ToDate);
        //Window.INPUT(3,GLCode);
        Window.CLOSE;



        Window.OPEN('Exporting @1@@@@@@@@@@@@@@@@@@@@@@@@@\ \');
        Window.UPDATE(1, 0);
        ////ExcelBuffer.SetUseInfoSheed;
        //ExcelBuffer.NewRow;


        RowNum := 0;
        ColumnNum := 0;
        //RecNo :=0;

        RowNum += 1;
        ColumnNum += 1;
        EnterCell('Date Paid', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('Posting Date', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('Document No', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('Customer No', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('Customer Name', TRUE, FALSE, '@');
        //ColumnNum += 1; EnterCell('Location',TRUE,FALSE,'@');
        ColumnNum += 1;
        EnterCell('SO No', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('Exc Vat LCY', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('Inc Vat LCY', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('Currency Code', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('EX. Rate', TRUE, FALSE, '@');

        ColumnNum += 1;
        EnterCell('Exc Vat In GBP', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('Inc Vat In GBP', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('Status', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('SalesPerson', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('SalesPerson Name', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('Course Header', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('Company Name', TRUE, FALSE, '@');

        Company.SETFILTER(Company.Name, '<>%1', 'aa');
        IF Company.FIND('-') THEN
            REPEAT

                CLEAR(SalesInvoiceHeader);
                CLEAR("General Ledger Setup1");
                CLEAR(Team);
                CLEAR("Salesperson/Purchaser1");
                CLEAR(Curexch);
                CLEAR(SalesInvoiceLine);
                CLEAR(SalesInvoiceLine3);

                SalesInvoiceHeader.CHANGECOMPANY(Company.Name);

                "General Ledger Setup1".CHANGECOMPANY(Company.Name);
                Team.CHANGECOMPANY(Company.Name);
                "Salesperson/Purchaser1".CHANGECOMPANY(Company.Name);
                Curexch.CHANGECOMPANY(Company.Name);
                SalesInvoiceLine.CHANGECOMPANY(Company.Name);

                "General Ledger Setup1".GET;

                SalesInvoiceHeader.SETCURRENTKEY("Posting Date", "No.");
                SalesInvoiceHeader.SETFILTER("Posting Date", '%1..%2', FromDate, ToDate);//010920D);
                IF SalesInvoiceHeader.FIND('-') THEN
                    REPEAT
                        ExchangeRate1 := 0;
                        AmountGBP1 := 0;
                        AmountGBPIncludingTax := 0;
                        PaymentStatus1 := '';
                        DatePaid1 := 0D;

                        SalesPersonName := '';
                        IF "Salesperson/Purchaser1".GET(SalesInvoiceHeader."Salesperson Code") THEN
                            SalesPersonName := "Salesperson/Purchaser1".Name;

                        SalesInvoiceHeader.CALCFIELDS(Amount, "Amount Including VAT");


                        CourseHeader1 := '';
                        SalesInvoiceLine3.SETFILTER(SalesInvoiceLine3."Document No.", SalesInvoiceHeader."No.");
                        SalesInvoiceLine3.SETFILTER(SalesInvoiceLine3."Course Header", '<>%1', '');
                        IF SalesInvoiceLine3.FIND('-') THEN
                            CourseHeader1 := SalesInvoiceLine3."Course Header";

                        IF Team.GET(SalesInvoiceHeader."Salesperson Code") THEN BEGIN
                            IF Team."Manager Name" = 'K.RANDAWA' THEN BEGIN //'K.RANDAWA' THEN BEGIN
                                IF SalesInvoiceHeader."Currency Factor" <> 0 THEN
                                    ExchangeRate1 := 1 / SalesInvoiceHeader."Currency Factor";

                                IF ExchangeRate1 = 0 THEN
                                    ExchangeRate1 := 1;

                                DatePaid1 := 0D;
                                UpdatePaymentStatus(SalesInvoiceHeader."No.", Company.Name);

                                //AmountGBP1 := SalesInvoiceHeader.Amount*ExchangeRate1;//CF;
                                //AmountGBPIncludingTax := SalesInvoiceHeader."Amount Including VAT"*ExchangeRate1;//CF;


                                //
                                Curexch.RESET;
                                CF := 0;
                                AmountGBP1 := 0;
                                AmountGBPIncludingTax := 0;

                                IF SalesInvoiceHeader."Currency Code" = 'GBP' THEN BEGIN

                                    AmountGBP1 := SalesInvoiceHeader.Amount;///CF;
                                    AmountGBPIncludingTax := SalesInvoiceHeader."Amount Including VAT";///CF;//CF;

                                END
                                ELSE BEGIN

                                    SalesInvoiceLine.SETFILTER(SalesInvoiceLine."Document No.", SalesInvoiceHeader."No.");
                                    SalesInvoiceLine.SETFILTER(SalesInvoiceLine."No.", '<>%1', '');
                                    IF SalesInvoiceLine.FIND('-') THEN
                                        REPEAT
                                            AmountGBP1 := AmountGBP1 + SalesInvoiceLine."Amt. Excl. VAT (LCY)";
                                            AmountGBPIncludingTax := AmountGBPIncludingTax + SalesInvoiceLine."Amt. Incl. VAT (LCY)";

                                        UNTIL SalesInvoiceLine.NEXT = 0;

                                    Curexch.SETRANGE("Currency Code", 'GBP');
                                    Curexch.SETFILTER("Starting Date", '..%1', TODAY);
                                    IF Curexch.FINDLAST THEN
                                        CF := Curexch."Relational Exch. Rate Amount" / Curexch."Exchange Rate Amount";
                                    IF CF = 0 THEN
                                        CF := 1;
                                    AmountGBP1 := AmountGBP1 / CF;
                                    AmountGBPIncludingTax := AmountGBPIncludingTax / CF;//CF;
                                END;

                                //

                                CurrencyCode1 := '';
                                IF SalesInvoiceHeader."Currency Code" = '' THEN
                                    CurrencyCode1 := "General Ledger Setup1"."LCY Code"
                                ELSE
                                    CurrencyCode1 := SalesInvoiceHeader."Currency Code";


                                RowNum += 1;
                                ColumnNum := 0;

                                IF PaymentStatus1 = 'UNPAID' THEN
                                    DatePaid1 := 0D;

                                ColumnNum += 1;
                                EnterCell(FORMAT(DatePaid1), FALSE, FALSE, '@');
                                ColumnNum += 1;
                                EnterCell(FORMAT(SalesInvoiceHeader."Posting Date"), FALSE, FALSE, '@');
                                ColumnNum += 1;
                                EnterCell(FORMAT(SalesInvoiceHeader."No."), FALSE, FALSE, '@');
                                ColumnNum += 1;
                                EnterCell(FORMAT(SalesInvoiceHeader."Sell-to Customer No."), FALSE, FALSE, '@');

                                ColumnNum += 1;
                                EnterCell(FORMAT(SalesInvoiceHeader."Sell-to Customer Name"), FALSE, FALSE, '@');
                                ColumnNum += 1;
                                EnterCell(FORMAT(SalesInvoiceHeader."Order No."), FALSE, FALSE, '@');
                                ColumnNum += 1;
                                EnterCell(FORMAT(SalesInvoiceHeader.Amount), FALSE, FALSE, '#,##0.00');
                                ColumnNum += 1;
                                EnterCell(FORMAT(SalesInvoiceHeader."Amount Including VAT"), FALSE, FALSE, '#,##0.00');
                                ColumnNum += 1;
                                EnterCell(FORMAT(CurrencyCode1), FALSE, FALSE, '#,##0.00');
                                ColumnNum += 1;
                                EnterCell(FORMAT(ExchangeRate1), FALSE, FALSE, '#,##0.00');
                                // ColumnNum += 1;  EnterCell(FORMAT(CF),FALSE,FALSE,'#,##0.00');

                                ColumnNum += 1;
                                EnterCell(FORMAT(AmountGBP1), FALSE, FALSE, '#,##0.00');
                                ColumnNum += 1;
                                EnterCell(FORMAT(AmountGBPIncludingTax), FALSE, FALSE, '#,##0.00');
                                ColumnNum += 1;
                                EnterCell(FORMAT(PaymentStatus1), FALSE, FALSE, '@');
                                ColumnNum += 1;
                                EnterCell(FORMAT(SalesInvoiceHeader."Salesperson Code"), FALSE, FALSE, '#,##0.00');
                                ColumnNum += 1;
                                EnterCell(FORMAT(SalesPersonName), FALSE, FALSE, '@');
                                ColumnNum += 1;
                                EnterCell(FORMAT(CourseHeader1), FALSE, FALSE, '@');
                                ColumnNum += 1;
                                EnterCell(FORMAT(Company.Name), FALSE, FALSE, '@');

                            END;
                        END;
                    UNTIL SalesInvoiceHeader.NEXT = 0;
            UNTIL Company.NEXT = 0;

        Window.CLOSE;
    end;

    procedure UpdateStatus1()
    begin

        //IF PreviousDocNo <> SalesInvoiceHeader3."No." THEN BEGIN
        PaymentStatus2 := '';
        PreviousDocNo := SalesInvoiceHeader3."No.";
        CreditMemoNo := '';
        SalesDocument1 := '';
        //  MESSAGE (SalesInvoiceHeader3."No.");
        CLEAR(DetailedCustLedgEntry);
        CLEAR(SalesInvoiceLine);
        CLEAR(AppliedCLE);
        CLEAR(CustLedgerEntry);
        CLEAR(SalesInvoiceHeader2);


        //Checking Original Knowledge Pass Invoice Payment Status Start
        IF SalesInvoiceHeader2.GET(SalesInvoiceHeader3."No.") THEN BEGIN
            IF SalesInvoiceHeader2."Payment Information" = SalesInvoiceHeader2."Payment Information"::"Knowledge / Flexi Pass" THEN BEGIN
                SalesInvoiceLine.SETFILTER("Document No.", SalesInvoiceHeader2."No.");
                SalesInvoiceLine.SETFILTER(SalesInvoiceLine."KP No.", '<>%1', '');
                IF SalesInvoiceLine.FIND('-') THEN
                    SalesDocument1 := SalesInvoiceLine."KP No.";
            END;
        END;
        //Checking Original Knowledge Pass Invoice Payment Status End
        IF SalesDocument1 = '' THEN
            SalesDocument1 := SalesInvoiceHeader3."No.";
        CLEAR(AppliedCLE);
        //new code
        CLEAR(CustLedgerEntry);
        CustLedgerEntry.SETCURRENTKEY("Document No.", "Document Type", "Customer No.");
        CustLedgerEntry.SETFILTER("Document No.", SalesDocument1);
        CustLedgerEntry.SETFILTER(CustLedgerEntry."Document Type", '%1', CustLedgerEntry."Document Type"::Invoice);
        IF CustLedgerEntry.FIND('-') THEN BEGIN
            CustLedgerEntry.CALCFIELDS(CustLedgerEntry."Remaining Amount");
            IF CustLedgerEntry."Remaining Amount" = 0 THEN BEGIN
                IF CustLedgerEntry."Closed by Entry No." <> 0 THEN BEGIN
                    AppliedCLE.SETFILTER("Entry No.", '%1', CustLedgerEntry."Closed by Entry No.");
                    IF AppliedCLE.FIND('-') THEN BEGIN
                        IF AppliedCLE."Document Type" = AppliedCLE."Document Type"::"Credit Memo" THEN
                            PaymentStatus2 := 'CREDITED';
                        CreditMemoNo := AppliedCLE."Document No.";

                        IF AppliedCLE."Document Type" = AppliedCLE."Document Type"::Payment THEN
                            PaymentStatus2 := 'PAID';
                        CreditMemoNo := AppliedCLE."Document No.";

                        IF AppliedCLE."Document Type" = AppliedCLE."Document Type"::" " THEN
                            PaymentStatus2 := 'PAID';
                        CreditMemoNo := AppliedCLE."Document No.";
                        EXIT;
                    END;
                END;

                IF CustLedgerEntry."Closed by Entry No." = 0 THEN BEGIN
                    AppliedCLE.SETFILTER("Closed by Entry No.", '%1', CustLedgerEntry."Entry No.");
                    IF AppliedCLE.FIND('-') THEN BEGIN
                        IF AppliedCLE."Document Type" = AppliedCLE."Document Type"::"Credit Memo" THEN
                            PaymentStatus2 := 'CREDITED';
                        CreditMemoNo := AppliedCLE."Document No.";

                        IF AppliedCLE."Document Type" = AppliedCLE."Document Type"::Payment THEN
                            PaymentStatus2 := 'PAID';
                        CreditMemoNo := AppliedCLE."Document No.";

                        IF AppliedCLE."Document Type" = AppliedCLE."Document Type"::" " THEN
                            PaymentStatus2 := 'PAID';
                        CreditMemoNo := AppliedCLE."Document No.";
                        //MESSAGE ('Coming in loop closed by entry no 0');
                        EXIT;
                    END;
                END;


            END;
        END;
        CLEAR(CustLedgerEntry);

        //new code

        CustLedgerEntry.SETCURRENTKEY("Document No.", "Document Type", "Customer No.");
        CustLedgerEntry.SETFILTER("Document No.", SalesDocument1);
        CustLedgerEntry.SETFILTER(CustLedgerEntry."Document Type", '%1', CustLedgerEntry."Document Type"::Invoice);
        IF CustLedgerEntry.FIND('-') THEN BEGIN
            CustLedgerEntry.CALCFIELDS(CustLedgerEntry."Remaining Amount");
            IF CustLedgerEntry."Remaining Amount" <> 0 THEN BEGIN
                PaymentStatus2 := 'UNPAID';
                CreditMemoNo := '';//DetailedCustLedgEntry."Document No.";
            END;


            IF CustLedgerEntry."Remaining Amount" = 0 THEN BEGIN
                DetailedCustLedgEntry.RESET;
                DetailedCustLedgEntry.SETCURRENTKEY("Cust. Ledger Entry No.", "Entry Type", "Posting Date");
                DetailedCustLedgEntry.SETFILTER("Cust. Ledger Entry No.", '%1', CustLedgerEntry."Entry No.");
                DetailedCustLedgEntry.SETFILTER(DetailedCustLedgEntry."Entry Type", '%1', DetailedCustLedgEntry."Entry Type"::Application);
                DetailedCustLedgEntry.SETFILTER(DetailedCustLedgEntry."Document Type",
                                               '%1', DetailedCustLedgEntry."Document Type"::Payment);
                IF DetailedCustLedgEntry.FIND('-') THEN BEGIN
                    PaymentStatus2 := 'PAID';
                    CreditMemoNo := DetailedCustLedgEntry."Document No.";
                    EXIT; //24.03.21
                END;
            END;


            IF CustLedgerEntry."Remaining Amount" = 0 THEN BEGIN
                DetailedCustLedgEntry.RESET;
                DetailedCustLedgEntry.SETCURRENTKEY("Cust. Ledger Entry No.", "Entry Type", "Posting Date");
                DetailedCustLedgEntry.SETFILTER("Cust. Ledger Entry No.", '%1', CustLedgerEntry."Entry No.");
                DetailedCustLedgEntry.SETFILTER(DetailedCustLedgEntry."Entry Type", '%1', DetailedCustLedgEntry."Entry Type"::Application);
                DetailedCustLedgEntry.SETFILTER(DetailedCustLedgEntry."Document Type",
                                               '%1', DetailedCustLedgEntry."Document Type"::"Credit Memo");
                IF DetailedCustLedgEntry.FIND('-') THEN BEGIN
                    PaymentStatus2 := 'CREDITED';
                    CreditMemoNo := DetailedCustLedgEntry."Document No.";
                END;
                //EXIT;
            END;


            IF CustLedgerEntry."Remaining Amount" = 0 THEN BEGIN
                DetailedCustLedgEntry.RESET;
                DetailedCustLedgEntry.SETCURRENTKEY("Cust. Ledger Entry No.", "Entry Type", "Posting Date");
                DetailedCustLedgEntry.SETFILTER("Cust. Ledger Entry No.", '%1', CustLedgerEntry."Entry No.");
                DetailedCustLedgEntry.SETFILTER("Entry Type", '%1', DetailedCustLedgEntry."Entry Type"::Application);
                IF DetailedCustLedgEntry.FIND('-') THEN
                    REPEAT
                        IF DetailedCustLedgEntry."Document Type" = DetailedCustLedgEntry."Document Type"::Payment THEN BEGIN
                            PaymentStatus2 := 'PAID';
                            CreditMemoNo := DetailedCustLedgEntry."Document No.";
                        END;
                    UNTIL DetailedCustLedgEntry.NEXT = 0;
            END;


            IF CustLedgerEntry."Remaining Amount" = 0 THEN BEGIN
                DetailedCustLedgEntry.RESET;
                DetailedCustLedgEntry.SETCURRENTKEY("Cust. Ledger Entry No.", "Entry Type", "Posting Date");
                DetailedCustLedgEntry.SETFILTER(DetailedCustLedgEntry."Cust. Ledger Entry No.", '%1', CustLedgerEntry."Entry No.");
                DetailedCustLedgEntry.SETFILTER(DetailedCustLedgEntry."Entry Type", '%1', DetailedCustLedgEntry."Entry Type"::Application);
                IF DetailedCustLedgEntry.FIND('-') THEN
                    REPEAT
                        //MESSAGE ( FORMAT(DetailedCustLedgEntry."Entry Type"));
                        PaymentStatus2 := 'PAID';
                        CreditMemoNo := DetailedCustLedgEntry."Document No.";

                        IF DetailedCustLedgEntry."Document Type" = DetailedCustLedgEntry."Document Type"::"Credit Memo" THEN BEGIN
                            PaymentStatus2 := 'CREDITED';
                            CreditMemoNo := DetailedCustLedgEntry."Document No.";
                        END;
                        EXIT;
                    UNTIL DetailedCustLedgEntry.NEXT = 0;
            END;

            IF CustLedgerEntry."Remaining Amount" = 0 THEN BEGIN
                Cnt := 0;
                DetailedCustLedgEntry.RESET;
                DetailedCustLedgEntry.SETCURRENTKEY("Cust. Ledger Entry No.", "Entry Type", "Posting Date");
                DetailedCustLedgEntry.SETFILTER(DetailedCustLedgEntry."Cust. Ledger Entry No.", '%1', CustLedgerEntry."Entry No.");
                IF DetailedCustLedgEntry.FIND('-') THEN
                    REPEAT
                        IF DetailedCustLedgEntry."Entry Type" = DetailedCustLedgEntry."Entry Type"::"Initial Entry" THEN
                            Cnt := 0;

                        IF DetailedCustLedgEntry."Entry Type" = DetailedCustLedgEntry."Entry Type"::Application THEN
                            Cnt := Cnt + 1;

                    UNTIL DetailedCustLedgEntry.NEXT = 0;
                IF Cnt > 0 THEN BEGIN
                    PaymentStatus2 := 'PAID';
                    CreditMemoNo := DetailedCustLedgEntry."Document No.";
                END;

                IF Cnt = 0 THEN BEGIN
                    PaymentStatus2 := 'UNPAID';
                    CreditMemoNo := '';//DetailedCustLedgEntry."Document No.";
                END;
            END;
        END;
        //END;
    end;

    procedure KPUtilisationReport1()
    var
        // SMTPSetup: Record "409";
        // SMTPMail: Codeunit "400";
        Company: Record 2000000006;
        "Sales Invoice Header1": Record 112;
        "Sales Invoice Line": Record 113;
        Amount1: Decimal;
        Curexch: Record "330";
        CF: Decimal;
        RecordCount: Integer;
        Compname1: Text[30];
        email: codeunit Email;
        emailmsg: codeunit "Email Message";
    begin
        CLEAR(emailmsg);
        emailmsg.Create('Biju.Kurup@theknowledgeacademy.com',
                           'KP Utilisation Report Daily', '', TRUE);// ,'',TRUE);//for ' +COMPANYNAME ,'',TRUE);

        emailmsg.AppendToBody('Dear All,');
        emailmsg.AppendToBody('<BR><BR>');
        emailmsg.AppendToBody('Please see below a table for KP Utilisation Report Daily');
        emailmsg.AppendToBody('<BR><BR>');
        //SMTPMail.AddCC('barinder.hothiUAT@theknowledgeacademy.com');
        //SMTPMail.AddCC('Sunny.Dhanoa@theknowledgeacademy.com');
        //SMTPMail.AddCC('Vomika.Aggarwal@theknowledgeacademy.com');

        emailmsg.AppendToBody('<table style="border-spacing: 0px;" border="1",font-size:9px">' +
        //original    ('<table cellspacing="10"  style="border-spacing: 0px;" border="1">'+
        //    SMTP.AppendBody('<table style="border-spacing: 0px;" border="1">'

        '<col width="50"><col width="100"><col width="150">' +
         '<col width="150"><col width="80"><col width="80"><col width="150">' +
         '<tr><th align="Left">Posting Date</th>' +
         '<th align="Center">Customer No</th>' +
         '<th align="Center">Customer Name</th>' +
         '<th align="Center">Amount Used Today (GBP)</th>' +
         '<th align="Center">Original KP Inv</th>' +
         '<th align="Center">KP Utilisation</th>' +
         '<th align="Center">Course Name</th>' +
         '<th align="Center">Company</th>');

        Company.SETFILTER(Company.Name, '<>%1', '');
        IF Company.FIND('-') THEN
            REPEAT
                CLEAR("Sales Invoice Header1");
                CLEAR("Sales Invoice Line");
                CLEAR(Curexch);

                "Sales Invoice Header1".CHANGECOMPANY(Company.Name);
                "Sales Invoice Line".CHANGECOMPANY(Company.Name);
                Curexch.CHANGECOMPANY(Company.Name);



                "Sales Invoice Header1".SETCURRENTKEY("Posting Date", "No.");
                "Sales Invoice Header1".SETFILTER("Sales Invoice Header1"."Posting Date", '%1', TODAY);
                "Sales Invoice Header1".SETFILTER("Sales Invoice Header1"."Payment Information", '%1',
                 "Sales Invoice Header1"."Payment Information"::"Knowledge / Flexi Pass");

                IF "Sales Invoice Header1".FIND('-') THEN
                    REPEAT
                        Amount1 := 0;

                        "Sales Invoice Line".SETFILTER("Sales Invoice Line"."Document No.", "Sales Invoice Header1"."No.");
                        "Sales Invoice Line".SETFILTER("Sales Invoice Line".Quantity, '<>%1', 0);
                        "Sales Invoice Line".SETFILTER("Sales Invoice Line"."No.", '%1..%2', '6100', '6995');
                        "Sales Invoice Line".SETFILTER("Sales Invoice Line"."KP No.", '<>%1', '');
                        IF "Sales Invoice Line".FIND('-') THEN
                            REPEAT
                                Amount1 := Amount1 + "Sales Invoice Line"."Amt. Excl. VAT (LCY)";
                                RecordCount := RecordCount + 1;
                            UNTIL "Sales Invoice Line".NEXT = 0;


                        Curexch.RESET;
                        CF := 0;
                        Curexch.SETRANGE("Currency Code", 'GBP');
                        Curexch.SETFILTER("Starting Date", '..%1', TODAY);
                        IF Curexch.FINDLAST THEN
                            CF := Curexch."Relational Exch. Rate Amount" / Curexch."Exchange Rate Amount";
                        IF CF = 0 THEN
                            CF := 1;
                        Amount1 := Amount1 / CF;

                        IF Company.Name = 'The Knowledge Academy Limited' THEN
                            Compname1 := 'TKA UK';


                        IF Company.Name = 'Best Practice Training Ltd.' THEN
                            Compname1 := 'Best Prac';

                        IF Company.Name = 'Datrix Learning Services Ltd.' THEN
                            Compname1 := 'Datrix';

                        IF Company.Name = 'ITIL Training Academy' THEN
                            Compname1 := 'ITIL';

                        IF Company.Name = 'Pearce Mayfield Train Dubai' THEN
                            Compname1 := 'PMD';

                        IF Company.Name = 'Pearce Mayfield Training Ltd' THEN
                            Compname1 := 'PMT';

                        IF Company.Name = 'Pentagon Leisure Services Ltd' THEN
                            Compname1 := 'Pentagon';

                        IF Company.Name = 'Silicon Beach Training' THEN
                            Compname1 := 'Silicon';

                        IF Company.Name = 'The Knowledge Academy FreeZone' THEN
                            Compname1 := 'FREEZONE';

                        IF Company.Name = 'The Knowledge Academy Inc' THEN
                            Compname1 := 'USA';

                        IF Company.Name = 'The Knowledge Academy Pty Ltd.' THEN
                            Compname1 := 'AUS';

                        IF Company.Name = 'The Knowledge Academy SA' THEN
                            Compname1 := 'SA';

                        IF Company.Name = 'TKA Apprenticeship' THEN
                            Compname1 := 'Apprenticeship';

                        IF Company.Name = 'TKA Canada Corporation' THEN
                            Compname1 := 'Canada';

                        IF Company.Name = 'TKA Europe' THEN
                            Compname1 := 'Europe';

                        IF Company.Name = 'TKA Hong Kong Ltd.' THEN
                            Compname1 := 'HK';

                        IF Company.Name = 'TKA New Zealand Ltd.' THEN
                            Compname1 := 'NZ';

                        IF Company.Name = 'TKA Singapore PTE Ltd.' THEN
                            Compname1 := 'Singapore';


                        emailmsg.AppendToBody('<tr>');
                        emailmsg.AppendToBody('<td>' + FORMAT("Sales Invoice Header1"."Posting Date") + '</td>');
                        emailmsg.AppendToBody('<td>' + FORMAT("Sales Invoice Header1"."Sell-to Customer No.") + '</td>');
                        emailmsg.AppendToBody('<td>' + FORMAT("Sales Invoice Header1"."Sell-to Customer Name") + '</td>');
                        emailmsg.AppendToBody('<td align="Right">' + FORMAT(Amount1, 0, '<Precision,2:2><Standard Format,2>') + '</td>');
                        emailmsg.AppendToBody('<td>' + FORMAT("Sales Invoice Line"."KP No.") + '</td>');
                        emailmsg.AppendToBody('<td>' + FORMAT("Sales Invoice Header1"."No.") + '</td>');
                        emailmsg.AppendToBody('<td>' + FORMAT("Sales Invoice Line"."Course Header") + '</td>');
                        emailmsg.AppendToBody('<td>' + FORMAT(Compname1) + '</td>');
                        emailmsg.AppendToBody('</tr>');

                    UNTIL "Sales Invoice Header1".NEXT = 0;
            UNTIL Company.NEXT = 0;

        emailmsg.AppendToBody('</table>');

        emailmsg.AppendToBody('<BR><BR>');
        emailmsg.AppendToBody('Kind Regards,');
        emailmsg.AppendToBody('<BR><BR>');
        emailmsg.AppendToBody('Dynamics');

        IF RecordCount >= 1 THEN
            email.send(emailmsg);
        IF GUIALLOWED THEN
            MESSAGE('DONE');
    end;

    procedure Export_InvoiceData()
    var
        lInt: Integer;
        lDate1: Date;
        lDate2: Date;
        GLEntry: Record "17";
        SalesInvoiceLine: Record 113;
        Contact: Record 5050;
        SalesInvoiceHeader: Record 112;
        PreviousDocNo: Code[20];
        GLEntry1: Record "17";
        GLEntry1Description: Text[50];
        EventHeader: Record 50006;
        SalesInvoiceLine1: Record 113;
        "Sales Cr.Memo Line": Record "115";
        "Salesperson/Purchaser1": Record 13;
        SalesPersonName: Text[50];
        "General Ledger Setup1": Record "98";
        CurrencyCode1: Code[10];
        Company: Record 2000000006;
        Curexch: Record "330";
        CF: Decimal;
        LineAmount1: Decimal;
    begin
        CLEAR(ExcelBuffer);
        FromDate := 0D;
        ToDate := 0D;
        //GLCode:='';


        FromDate := 20200901D;

        ToDate := TODAY;

        Window.OPEN('Enter From Date #1##########  To Date #2##########  ');
        // Window.INPUT(1,FromDate);
        // Window.INPUT(2,ToDate);
        //Window.INPUT(3,GLCode);
        Window.CLOSE;


        //Window.OPEN('Exporting @1@@@@@@@@@@@@@@@@@@@@@@@@@\ \'); 1
        //Window.UPDATE(1,0); 2
        //ExcelBuffer.SetUseInfoSheed;
        //ExcelBuffer.NewRow;


        RowNum := 0;
        ColumnNum := 0;
        //RecNo :=0;

        RowNum += 1;
        //ColumnNum += 1; EnterCell('Date Paid',TRUE,FALSE,'@');
        //ColumnNum += 1; EnterCell('Posting Date',TRUE,FALSE,'@');
        ColumnNum += 1;
        EnterCell('Invoice No', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('Customer No', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('Customer Name', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('Course Header', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('Exc Vat In GBP', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('Inc Vat In GBP', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('Amount in Invoice Currency', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('Currency Code', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('Posting Date', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('SalesPerson Name', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('Payment Status', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('Application Date', TRUE, FALSE, '@');


        /*
        //ColumnNum += 1; EnterCell('Location',TRUE,FALSE,'@');
        ColumnNum += 1; EnterCell('SO No',TRUE,FALSE,'@');
        ColumnNum += 1; EnterCell('Exc Vat LCY',TRUE,FALSE,'@');
        ColumnNum += 1; EnterCell('Inc Vat LCY',TRUE,FALSE,'@');
        ColumnNum += 1; EnterCell('Currency Code',TRUE,FALSE,'@');
        ColumnNum += 1; EnterCell('EX. Rate',TRUE,FALSE,'@');
        
        ColumnNum += 1; EnterCell('Status',TRUE,FALSE,'@');
        ColumnNum += 1; EnterCell('SalesPerson',TRUE,FALSE,'@');
        ColumnNum += 1; EnterCell('Payment Status',TRUE,FALSE,'@');
        ColumnNum += 1; EnterCell('Application Date',TRUE,FALSE,'@');
        
        
        
        
        */

        ColumnNum += 1;
        EnterCell('Company Name', TRUE, FALSE, '@');

        Company.SETFILTER(Company.Name, '<>%1', 'aa');
        //'TKA Singapore PTE Ltd.');
        //
        //'The Knowledge Academy Limited');//
        IF Company.FIND('-') THEN
            REPEAT

                CLEAR(SalesInvoiceHeader);
                CLEAR("General Ledger Setup1");
                CLEAR(Team);
                CLEAR("Salesperson/Purchaser1");
                CLEAR(Curexch);
                CLEAR(SalesInvoiceLine);
                CLEAR(SalesInvoiceLine3);

                SalesInvoiceHeader.CHANGECOMPANY(Company.Name);

                "General Ledger Setup1".CHANGECOMPANY(Company.Name);
                Team.CHANGECOMPANY(Company.Name);
                "Salesperson/Purchaser1".CHANGECOMPANY(Company.Name);
                Curexch.CHANGECOMPANY(Company.Name);
                SalesInvoiceLine.CHANGECOMPANY(Company.Name);
                SalesInvoiceLine3.CHANGECOMPANY(Company.Name);

                "General Ledger Setup1".GET;

                SalesInvoiceHeader.SETCURRENTKEY("Posting Date", "No.");
                SalesInvoiceHeader.SETFILTER("Posting Date", '%1..%2', FromDate, ToDate);//010920D);
                                                                                         //SalesInvoiceHeader.SETFILTER("No.",'339733');
                IF SalesInvoiceHeader.FIND('-') THEN
                    REPEAT
                        ExchangeRate1 := 0;
                        AmountGBP1 := 0;
                        AmountGBPIncludingTax := 0;
                        PaymentStatus1 := '';
                        DatePaid1 := 0D;

                        SalesPersonName := '';
                        IF "Salesperson/Purchaser1".GET(SalesInvoiceHeader."Salesperson Code") THEN
                            SalesPersonName := "Salesperson/Purchaser1".Name;

                        SalesInvoiceHeader.CALCFIELDS(Amount, "Amount Including VAT", CreditMemoDate4);


                        CourseHeader1 := '';
                        SalesInvoiceLine3.SETFILTER(SalesInvoiceLine3."Document No.", SalesInvoiceHeader."No.");
                        SalesInvoiceLine3.SETFILTER(SalesInvoiceLine3."Course Header", '<>%1', '');
                        IF SalesInvoiceLine3.FIND('-') THEN
                            CourseHeader1 := SalesInvoiceLine3."Course Header";

                        //IF Team.GET(SalesInvoiceHeader."Salesperson Code") THEN BEGIN
                        //IF Team."Manager Name"  ='K.RANDAWA' THEN BEGIN
                        DatePaid1 := 0D;
                        //  UpdatePaymentStatus(SalesInvoiceHeader."No.",Company.Name);

                        //AmountGBP1 := SalesInvoiceHeader.Amount*ExchangeRate1;//CF;
                        //AmountGBPIncludingTax := SalesInvoiceHeader."Amount Including VAT"*ExchangeRate1;//CF;


                        //
                        Curexch.RESET;
                        CF := 0;
                        AmountGBP1 := 0;
                        AmountGBPIncludingTax := 0;
                        LineAmount1 := 0;

                        IF SalesInvoiceHeader."Currency Code" = 'GBP' THEN BEGIN

                            AmountGBP1 := SalesInvoiceHeader.Amount;///CF;
                            AmountGBPIncludingTax := SalesInvoiceHeader."Amount Including VAT";///CF;//CF;
                            LineAmount1 := SalesInvoiceHeader.Amount;///CF

                        END
                        ELSE BEGIN

                            SalesInvoiceLine.SETFILTER(SalesInvoiceLine."Document No.", SalesInvoiceHeader."No.");
                            SalesInvoiceLine.SETFILTER(SalesInvoiceLine."No.", '<>%1', '');
                            IF SalesInvoiceLine.FIND('-') THEN
                                REPEAT
                                    AmountGBP1 := AmountGBP1 + SalesInvoiceLine."Amt. Excl. VAT (LCY)";
                                    AmountGBPIncludingTax := AmountGBPIncludingTax + SalesInvoiceLine."Amt. Incl. VAT (LCY)";
                                    LineAmount1 := LineAmount1 + SalesInvoiceLine."Line Amount";

                                UNTIL SalesInvoiceLine.NEXT = 0;

                            Curexch.SETRANGE("Currency Code", 'GBP');
                            Curexch.SETFILTER("Starting Date", '..%1', TODAY);
                            IF Curexch.FINDLAST THEN
                                CF := Curexch."Relational Exch. Rate Amount" / Curexch."Exchange Rate Amount";
                            IF CF = 0 THEN
                                CF := 1;
                            AmountGBP1 := AmountGBP1 / CF;
                            AmountGBPIncludingTax := AmountGBPIncludingTax / CF;//CF;
                        END;


                        //

                        CurrencyCode1 := '';
                        IF SalesInvoiceHeader."Currency Code" = '' THEN
                            CurrencyCode1 := "General Ledger Setup1"."LCY Code"
                        ELSE
                            CurrencyCode1 := SalesInvoiceHeader."Currency Code";


                        RowNum += 1;
                        ColumnNum := 0;

                        IF PaymentStatus1 = 'UNPAID' THEN
                            DatePaid1 := 0D;

                        ColumnNum += 1;
                        EnterCell(FORMAT(SalesInvoiceHeader."No."), FALSE, FALSE, '@');
                        ColumnNum += 1;
                        EnterCell(FORMAT(SalesInvoiceHeader."Sell-to Customer No."), FALSE, FALSE, '@');
                        ColumnNum += 1;
                        EnterCell(FORMAT(SalesInvoiceHeader."Sell-to Customer Name"), FALSE, FALSE, '@');
                        ColumnNum += 1;
                        EnterCell(FORMAT(CourseHeader1), FALSE, FALSE, '@');
                        ColumnNum += 1;
                        EnterCell(FORMAT(AmountGBP1), FALSE, FALSE, '#,##0.00');
                        ColumnNum += 1;
                        EnterCell(FORMAT(AmountGBPIncludingTax), FALSE, FALSE, '#,##0.00');
                        ColumnNum += 1;
                        EnterCell(FORMAT(LineAmount1), FALSE, FALSE, '#,##0.00');
                        ColumnNum += 1;
                        EnterCell(FORMAT(CurrencyCode1), FALSE, FALSE, '#,##0.00');
                        ColumnNum += 1;
                        EnterCell(FORMAT(SalesInvoiceHeader."Posting Date"), FALSE, FALSE, '@');
                        ColumnNum += 1;
                        EnterCell(FORMAT(SalesPersonName), FALSE, FALSE, '@');

                        ColumnNum += 1;
                        EnterCell(FORMAT(SalesInvoiceHeader.PaymentStatus3), FALSE, FALSE, '@');
                        ColumnNum += 1;
                        EnterCell(FORMAT(SalesInvoiceHeader.CreditMemoDate4), FALSE, FALSE, '@');


                        ColumnNum += 1;
                        EnterCell(FORMAT(Company.Name), FALSE, FALSE, '@');
                    /*

                       // ColumnNum += 1;  EnterCell(FORMAT(DatePaid1),FALSE,FALSE,'@');


                    ColumnNum += 1;  EnterCell(FORMAT(SalesInvoiceHeader."Order No."),FALSE,FALSE,'@');

                    ColumnNum += 1;  EnterCell(FORMAT(ExchangeRate1),FALSE,FALSE,'#,##0.00');
                   // ColumnNum += 1;  EnterCell(FORMAT(CF),FALSE,FALSE,'#,##0.00');

                    ColumnNum += 1;  EnterCell(FORMAT(AmountGBP1),FALSE,FALSE,'#,##0.00');
                    ColumnNum += 1;  EnterCell(FORMAT(AmountGBPIncludingTax),FALSE,FALSE,'#,##0.00');
                    ColumnNum += 1;  EnterCell(FORMAT(PaymentStatus1),FALSE,FALSE,'@');
                    ColumnNum += 1;  EnterCell(FORMAT(SalesInvoiceHeader."Salesperson Code"),FALSE,FALSE,'#,##0.00');

                    ColumnNum += 1;  EnterCell(FORMAT(CourseHeader1),FALSE,FALSE,'@');
                    */


                    //END;
                    //END;
                    UNTIL SalesInvoiceHeader.NEXT = 0;
            UNTIL Company.NEXT = 0;
        //  Window.CLOSE; 3
        MESSAGE('Process Done');
        //

    end;

    procedure UpdateTaxBusinessGroup()
    var
        "Sales Invoice Line1": Record 113;
        "VAT Entry1": Record 254;
        "G/L Entry1": Record 17;
        FromTaxBusiness: Code[20];
        ToTaxBUsiness: Code[20];
        "VAT Business Posting Group1": Record 323;
        GeneralLedgerSetup: Record 98;
        SalesSetup: record "Sales & Receivables Setup";

        Param: report 50300;
    begin
        IF NOT CONFIRM('Are you sure to change Tax Business Posting group') THEN
            EXIT;

        IF UPPERCASE(USERID) IN ['BIJU.KURUP', 'PRABHJOT.KAUR', 'MARTHA.FOLKES'] THEN BEGIN


            GeneralLedgerSetup.GET;

            IF Rec."Posting Date" < GeneralLedgerSetup."VAT Posted Date" THEN
                ERROR('VAT Retrun done , Can not change Tax Business Posting Group');

            param.setreportid(5);
            param.RunModal();
            SalesSetup.get;
            FromTaxBusiness := SalesSetup.FromText;
            ToTaxbusiness := SalesSetup.ToText;



            // Window.OPEN('Enter Tax Business Existing #1##########  Update To #2##########');
            // // Window.INPUT(1,FromTaxBusiness);
            // // Window.INPUT(2,ToTaxBUsiness);
            // Window.CLOSE;

            IF NOT "VAT Business Posting Group1".GET(FromTaxBusiness) THEN
                ERROR('Check From Tax Business posting group');

            IF NOT "VAT Business Posting Group1".GET(ToTaxBUsiness) THEN
                ERROR('Check To Tax Business posting group');


            "VAT Entry1".SETCURRENTKEY("Document No.", "Posting Date");
            "VAT Entry1".SETFILTER("VAT Entry1"."Document No.", rec."No.");
            "VAT Entry1".SETFILTER("VAT Entry1"."VAT Bus. Posting Group", '%1', FromTaxBusiness);
            "VAT Entry1".SETFILTER("VAT Entry1".Type, 'Sale');
            IF "VAT Entry1".FIND('-') THEN
                REPEAT
                    IF "VAT Entry1".Closed THEN
                        ERROR('VAT Rerun Done, can not change VAT Business Group');

                    "VAT Entry1"."VAT Bus. Posting Group" := ToTaxBUsiness;
                    "VAT Entry1".MODIFY;
                UNTIL "VAT Entry1".NEXT = 0;

            "Sales Invoice Line1".SETFILTER("Sales Invoice Line1"."Document No.", rec."No.");
            "Sales Invoice Line1".SETFILTER("Sales Invoice Line1"."VAT Bus. Posting Group", '%1', FromTaxBusiness);
            IF "Sales Invoice Line1".FIND('-') THEN
                REPEAT
                    "Sales Invoice Line1"."VAT Bus. Posting Group" := ToTaxBUsiness;
                    "Sales Invoice Line1".MODIFY;
                UNTIL "Sales Invoice Line1".NEXT = 0;


            "G/L Entry1".SETCURRENTKEY("Document No.", "Posting Date");
            "G/L Entry1".SETFILTER("G/L Entry1"."Document No.", rec."No.");
            "G/L Entry1".SETFILTER("G/L Entry1"."VAT Bus. Posting Group", '%1', FromTaxBusiness);
            IF "G/L Entry1".FIND('-') THEN
                REPEAT
                    "G/L Entry1"."VAT Bus. Posting Group" := ToTaxBUsiness;
                    "G/L Entry1".MODIFY;
                UNTIL "G/L Entry1".NEXT = 0;
            //MESSAGE ('Tax Business group updated successfully');

            //send email start
            CLEAR(emailmsg);
            emailmsg.Create('martha.folkes@theknowledgeacademy.com',
                               'Tax Business posting group changed - Sales Invoice', '', TRUE);// ,'',TRUE);
            //SMTPMail.AddBCC('biju.kurup@theknowledgeacademy.com');
            emailmsg.AppendToBody('Hi');
            emailmsg.AppendToBody('<BR><BR>');
            emailmsg.AppendToBody('Tax Business posting group changed');
            emailmsg.AppendToBody('<BR><BR>');
            emailmsg.AppendToBody('<BR><BR>');
            emailmsg.AppendToBody('<table cellspacing="10"  style="border-spacing: 0px;" border="1">' +
           '<col width="50"><col width="150"><col width="100">' +
            '<col width="50">' +
             '<tr><th align="Center">Document No</th>' +
            '<th align="Center">Old Tax Business Group</th>' +
            '<th align="Center">New Business Group</th>' +
            '<th align="Center">User ID</th>');
            emailmsg.AppendToBody('<tr>');
            emailmsg.AppendToBody('<td align="Center">' + FORMAT(rec."No.") + '</td>');
            emailmsg.AppendToBody('<td align="Center">' + FORMAT(FromTaxBusiness) + '</td>');
            emailmsg.AppendToBody('<td align="Center">' + FORMAT(ToTaxBUsiness) + '</td>');
            emailmsg.AppendToBody('<td align="Center">' + FORMAT(USERID) + '</td>');
            emailmsg.AppendToBody('</tr>');
            emailmsg.AppendToBody('</table>');

            emailmsg.AppendToBody('<BR><BR>');
            emailmsg.AppendToBody('<BR><BR>');
            emailmsg.AppendToBody('Kind Regards,');
            emailmsg.AppendToBody('<BR><BR>');
            emailmsg.AppendToBody('Dynamics');
            email.send(emailmsg);
            //send email end

        END

        ELSE
            ERROR('You do not have permission to change Tax Business Posting Group');
    end;

    procedure PrintInvoiceToPDF(InvoiceNo: Code[20])
    var
        RunOnceFile: Text[1024];
        FileInfo: Text[1024];
        lSalesInvoiceHeader: Record 112;
        BlobOutStream: OutStream;
        Recref: RecordRef;
        RptOrderConfirmation: report 50117;
        TempBlob_lRec: Codeunit "Temp Blob";
        BlobInstream: instream;
        Cuext: codeunit CUExtension;
    begin

        IF InvoiceNo = '' THEN
            ERROR('Invoice number can not be Blank');

        lSalesInvoiceHeader.RESET;
        lSalesInvoiceHeader.SETFILTER("No.", InvoiceNo);
        IF lSalesInvoiceHeader.FIND('-') THEN;
        recref.GetTable(lSalesInvoiceHeader);

        TempBlob_lRec.CreateOutStream(BlobOutStream, TEXTENCODING::UTF8);
        IF COMPANYNAME = 'TKA India' THEN BEGIN
            Customer1.SETFILTER("No.", rec."Sell-to Customer No.");
            Customer1.SETFILTER("Territory Code", '29');
            IF Customer1.FIND('-') THEN
                REPORT.SAVEAS(50129, '', REPORTFORMAT::Pdf, BlobOutStream, RecRef)
            ELSE
                REPORT.SAVEAS(50130, '', REPORTFORMAT::Pdf, BlobOutStream, RecRef);
        END;
        IF COMPANYNAME <> 'TKA India' THEN
            REPORT.SAVEAS(FranchiseReportSetup.GetReportID(SalesInvHeader."Sell-to Customer No.", 4), '', REPORTFORMAT::Pdf, BlobOutStream, RecRef);



        TempBlob_lRec.CreateInStream(BlobInstream);

        Cuext.UpdateDocumentInv1(InvoiceNo, '.pdf', BlobInstream);
    end;

    procedure KPUtilisationReportToExcel()
    var
        Company: Record 2000000006;
        "Sales Invoice Header1": Record 112;
        "Sales Invoice Line": Record 113;
        Amount1: Decimal;
        Curexch: Record "330";
        CF: Decimal;
        RecordCount: Integer;
        Compname1: Text[30];
        SerialNo: Integer;
        GLBalance: Decimal;
        KPInventory: Record "50063";
        EventHeader1: Record 50006;
        "Duration (in Days)": Integer;
        AvailableElements: Decimal;
        TotalDelegate: Decimal;
        "Event Cost Heads": Record 50066;
        TrainerCost: Decimal;
        TrainerCostGBP: Decimal;
    begin
        //export to excel
        CLEAR(ExcelBuffer);

        Window.OPEN('Exporting @1@@@@@@@@@@@@@@@@@@@@@@@@@\ \');
        Window.UPDATE(1, 0);
        //ExcelBuffer.SetUseInfoSheed;
        //ExcelBuffer.NewRow;


        RowNum := 0;
        ColumnNum := 0;
        //RecNo :=0;

        RowNum += 1;
        ColumnNum += 1;
        EnterCell('Customer No', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('Customer Name', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('Amount Used Today (GBP)', TRUE, FALSE, '@');

        ColumnNum += 1;
        EnterCell('Quantity', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('GLBalance', TRUE, FALSE, '@');

        ColumnNum += 1;
        EnterCell('Original KP Inv', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('KP Utilisation', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('Course Name', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('Description', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('Company', TRUE, FALSE, '@');

        ColumnNum += 1;
        EnterCell('Event No.', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('Delegate on Event Currently', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('Event Start Date', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('Duration', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('Trainer Cost Forecasted for Event', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('Trainer Cost GBP', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('Salesperson Code', TRUE, FALSE, '@');

        Company.SETFILTER(Company.Name, '<>%1', '');
        IF Company.FIND('-') THEN
            REPEAT
                CLEAR("Sales Invoice Header1");
                CLEAR("Sales Invoice Line");
                CLEAR(Curexch);
                CLEAR(KPInventory);

                "Sales Invoice Header1".CHANGECOMPANY(Company.Name);
                "Sales Invoice Line".CHANGECOMPANY(Company.Name);
                Curexch.CHANGECOMPANY(Company.Name);
                KPInventory.CHANGECOMPANY(Company.Name);
                "Event Cost Heads".CHANGECOMPANY(Company.Name);



                "Sales Invoice Header1".SETCURRENTKEY("Posting Date", "No.");
                "Sales Invoice Header1".SETFILTER("Sales Invoice Header1"."Posting Date", '%1', TODAY);
                "Sales Invoice Header1".SETFILTER("Sales Invoice Header1"."Payment Information", '%1',
                 "Sales Invoice Header1"."Payment Information"::"Knowledge / Flexi Pass");
                IF "Sales Invoice Header1".FIND('-') THEN
                    REPEAT
                        Amount1 := 0;

                        "Sales Invoice Line".SETFILTER("Sales Invoice Line"."Document No.", "Sales Invoice Header1"."No.");
                        "Sales Invoice Line".SETFILTER("Sales Invoice Line".Quantity, '<>%1', 0);
                        "Sales Invoice Line".SETFILTER("Sales Invoice Line"."No.", '%1..%2', '6100', '6995');
                        "Sales Invoice Line".SETFILTER("Sales Invoice Line"."KP No.", '<>%1', '');
                        "Sales Invoice Line".SETFILTER("Sales Invoice Line"."Event Header", '<>%1', 'EXPIRED-KP');

                        IF "Sales Invoice Line".FIND('-') THEN
                            REPEAT
                                Amount1 := Amount1 + "Sales Invoice Line"."Amt. Excl. VAT (LCY)";
                                RecordCount := RecordCount + 1;
                            UNTIL "Sales Invoice Line".NEXT = 0;


                        Curexch.RESET;
                        CF := 0;
                        Curexch.SETRANGE("Currency Code", 'GBP');
                        Curexch.SETFILTER("Starting Date", '..%1', TODAY);
                        IF Curexch.FINDLAST THEN
                            CF := Curexch."Relational Exch. Rate Amount" / Curexch."Exchange Rate Amount";
                        IF CF = 0 THEN
                            CF := 1;
                        Amount1 := Amount1 / CF;

                        GLBalance := 0;
                        KPInventory.SETFILTER(KPInventory."KP Invoice No.", "Sales Invoice Line"."KP No.");
                        KPInventory.SETFILTER(KPInventory."Line No.", '%1', "Sales Invoice Line"."KP Line No.");
                        IF KPInventory.FIND('-') THEN BEGIN
                            KPInventory.CALCFIELDS("Booked Amount", "Used Amount (Invoiced)", "Reversal of Used Amount", "Reversal of Original KP / FP");
                            GLBalance := KPInventory."Booked Amount" - KPInventory."Used Amount (Invoiced)" +
                                          KPInventory."Reversal of Used Amount" - KPInventory."Reversal of Original KP / FP";
                        END;


                        RowNum += 1;
                        ColumnNum := 0;

                        ColumnNum += 1;
                        EnterCell(FORMAT("Sales Invoice Header1"."Sell-to Customer No."), FALSE, FALSE, '@');
                        ColumnNum += 1;
                        EnterCell(FORMAT("Sales Invoice Header1"."Sell-to Customer Name"), FALSE, FALSE, '@');
                        ColumnNum += 1;
                        EnterCell(FORMAT(Amount1), FALSE, FALSE, '#,##0.00');
                        ColumnNum += 1;
                        EnterCell(FORMAT("Sales Invoice Line".Quantity), FALSE, FALSE, '@');
                        ColumnNum += 1;
                        EnterCell(FORMAT(GLBalance), FALSE, FALSE, '#,##0.00');
                        ColumnNum += 1;
                        EnterCell(FORMAT("Sales Invoice Line"."KP No."), FALSE, FALSE, '@');
                        ColumnNum += 1;
                        EnterCell(FORMAT("Sales Invoice Header1"."No."), FALSE, FALSE, '@');
                        ColumnNum += 1;
                        EnterCell("Sales Invoice Line"."Course Header", FALSE, FALSE, '@');
                        ColumnNum += 1;
                        EnterCell("Sales Invoice Line".Description, FALSE, FALSE, '@');

                        IF Company.Name = 'The Knowledge Academy Limited' THEN
                            Compname1 := 'TKA UK';
                        IF Company.Name = 'Best Practice Training Ltd.' THEN
                            Compname1 := 'Best Prac';
                        IF Company.Name = 'Datrix Learning Services Ltd.' THEN
                            Compname1 := 'Datrix';
                        IF Company.Name = 'ITIL Training Academy' THEN
                            Compname1 := 'ITIL';
                        IF Company.Name = 'Pearce Mayfield Train Dubai' THEN
                            Compname1 := 'PMD';
                        IF Company.Name = 'Pearce Mayfield Training Ltd' THEN
                            Compname1 := 'PMT';
                        IF Company.Name = 'Pentagon Leisure Services Ltd' THEN
                            Compname1 := 'Pentagon';
                        IF Company.Name = 'Silicon Beach Training' THEN
                            Compname1 := 'Silicon';
                        IF Company.Name = 'The Knowledge Academy FreeZone' THEN
                            Compname1 := 'FREEZONE';
                        IF Company.Name = 'The Knowledge Academy Inc' THEN
                            Compname1 := 'USA';
                        IF Company.Name = 'The Knowledge Academy Pty Ltd.' THEN
                            Compname1 := 'AUS';
                        IF Company.Name = 'The Knowledge Academy SA' THEN
                            Compname1 := 'SA';
                        IF Company.Name = 'TKA Apprenticeship' THEN
                            Compname1 := 'Apprenticeship';
                        IF Company.Name = 'TKA Canada Corporation' THEN
                            Compname1 := 'Canada';
                        IF Company.Name = 'TKA Europe' THEN
                            Compname1 := 'Europe';
                        IF Company.Name = 'TKA Hong Kong Ltd.' THEN
                            Compname1 := 'HK';
                        IF Company.Name = 'TKA New Zealand Ltd.' THEN
                            Compname1 := 'NZ';
                        IF Company.Name = 'TKA Singapore PTE Ltd.' THEN
                            Compname1 := 'Singapore';
                        IF Company.Name = 'TKA India' THEN
                            Compname1 := 'TKA India';


                        "Duration (in Days)" := 0;
                        AvailableElements := 0;
                        TotalDelegate := 0;
                        TrainerCost := 0;
                        TrainerCostGBP := 0;


                        IF EventHeader1.GET("Sales Invoice Line"."Event Header") THEN BEGIN
                            EventHeader1.CALCFIELDS("Total Seats on Course", "Available Seats", "Confirmed Seats", "Provisional Seats");


                            IF (EventHeader1."Start Date" <> 0D) AND (EventHeader1."End Date" <> 0D) THEN
                                "Duration (in Days)" := (EventHeader1."End Date" - EventHeader1."Start Date") + 1;


                            AvailableElements := EventHeader1."Total Seats on Course" -
                                                (EventHeader1."Available Seats" + EventHeader1."Confirmed Seats" + EventHeader1."Provisional Seats");


                            TotalDelegate := TotalDelegate + (EventHeader1."Confirmed Seats" +
                                                              EventHeader1."Provisional Seats" + AvailableElements);

                            "Event Cost Heads".SETFILTER("Event Cost Heads"."Event Header", EventHeader1."No.");
                            "Event Cost Heads".SETFILTER("Event Cost Heads".MasterType, '%1', "Event Cost Heads".MasterType::Trainer);
                            IF "Event Cost Heads".FIND('-') THEN BEGIN
                                TrainerCost := "Event Cost Heads".Amount;
                                TrainerCostGBP := "Event Cost Heads".AmountLCY / CF;
                            END;
                        END;


                        ColumnNum += 1;
                        EnterCell(FORMAT(Compname1), FALSE, FALSE, '@');
                        ColumnNum += 1;
                        EnterCell(FORMAT("Sales Invoice Line"."Event Header"), FALSE, FALSE, '@');
                        ColumnNum += 1;
                        EnterCell(FORMAT(TotalDelegate), FALSE, FALSE, '@');
                        ColumnNum += 1;
                        EnterCell(FORMAT(EventHeader1."Start Date"), FALSE, FALSE, '@');
                        ColumnNum += 1;
                        EnterCell(FORMAT("Duration (in Days)"), FALSE, FALSE, '@');
                        ColumnNum += 1;
                        EnterCell(FORMAT(TrainerCost), FALSE, FALSE, '#,##0.00');
                        ColumnNum += 1;
                        EnterCell(FORMAT(TrainerCostGBP), FALSE, FALSE, '#,##0.00');
                        ColumnNum += 1;
                        EnterCell(FORMAT("Sales Invoice Header1"."Salesperson Code"), FALSE, FALSE, '@');




                    UNTIL "Sales Invoice Header1".NEXT = 0;
            UNTIL Company.NEXT = 0;

        Window.CLOSE;


        IF GUIALLOWED THEN
            MESSAGE('DONE');
    end;

    procedure AddInvoiceToKPInventory()
    var
        KP1: Record "50063";
        KP: Record "50063";
        SalesInvoiceLine: Record 113;
    begin
        IF NOT rec."Flexi Pass 2" THEN
            ERROR('This is not FP 2 Invoice');

        IF NOT CONFIRM('Are you sure to Create KP Inventory Entry for this Invoice?') THEN
            EXIT;

        KP1.SETFILTER(KP1."KP Invoice No.", rec."No.");
        IF KP1.FIND('-') THEN
            ERROR('KP Inventory already exists for this Invoice');


        KP.INIT;
        IF rec."Flexi Pass 2" THEN BEGIN
            SalesInvoiceLine.SETFILTER(SalesInvoiceLine."Document No.", rec."No.");
            SalesInvoiceLine.SETFILTER(SalesInvoiceLine."No.", '5348');
            IF SalesInvoiceLine.FIND('-') THEN
                REPEAT
                    KP."KP Invoice No." := SalesInvoiceLine."Document No.";// '384554';
                    KP."Line No." := SalesInvoiceLine."Line No.";//10000;
                    KP."Booking Date" := rec."Posting Date";// 151121D;
                    KP."Customer No." := rec."Sell-to Customer No.";//'C230108';
                    KP."Sales Person" := rec."Salesperson Code";//"Sales Person";//'M.SCRACE';
                    KP."Expiry Date" := rec."Posting Date" + 60;//150122D;//110122d111121D+60;
                    KP."Flexi Pass 2" := TRUE;
                    KP.Location := SalesInvoiceLine."Group Location";//'9AM-BST';
                    KP.INSERT;
                UNTIL SalesInvoiceLine.NEXT = 0;

            MESSAGE('Done');
        END;

        //385667
    end;

    procedure UpdatePostingDate()
    var
        "Sales Invoice Line1": Record 113;
        "VAT Entry1": Record "254";
        "G/L Entry1": Record "17";
        PostingDate1: Date;
        "VAT Business Posting Group1": Record "323";
        GeneralLedgerSetup: Record "98";
        SalesInvoiceHeader1: Record 112;
        PrevPostingDate: Date;
        CustLedgerEntry: Record "21";
        DetailedCustLedgerEntry: Record "379";
    begin
        IF NOT CONFIRM('Are you sure to change Posting Date') THEN
            EXIT;

        IF UPPERCASE(USERID) IN ['BIJU.KURUP', 'PRABHJOT.KAUR', 'MARTHA.FOLKES'] THEN BEGIN


            GeneralLedgerSetup.GET;

            IF Rec."Posting Date" < GeneralLedgerSetup."VAT Posted Date" THEN
                ERROR('VAT Retrun done , Can not change Posting Date');

            Window.OPEN('Enter Posting Date #1########## ');
            //Window.INPUT(1,PostingDate1);
            Window.CLOSE;

            IF PostingDate1 < GeneralLedgerSetup."VAT Posted Date" THEN
                ERROR('VAT Retrun done , Can not change Posting Date');

            IF PostingDate1 = 0D THEN
                ERROR('Enter correct Posting Date');

            PrevPostingDate := rec."Posting Date";

            "VAT Entry1".SETCURRENTKEY("Document No.", "Posting Date");
            "VAT Entry1".SETFILTER("VAT Entry1"."Document No.", rec."No.");
            "VAT Entry1".SETFILTER("VAT Entry1"."Posting Date", '%1', rec."Posting Date");
            "VAT Entry1".SETFILTER("VAT Entry1".Type, 'Sale');
            IF "VAT Entry1".FIND('-') THEN
                REPEAT
                    IF "VAT Entry1".Closed THEN
                        ERROR('VAT Rerun Done, can not change Posting Date');

                    "VAT Entry1"."Posting Date" := PostingDate1;
                    "VAT Entry1".MODIFY;
                UNTIL "VAT Entry1".NEXT = 0;

            "Sales Invoice Line1".SETFILTER("Sales Invoice Line1"."Document No.", rec."No.");
            "Sales Invoice Line1".SETFILTER("Sales Invoice Line1"."Posting Date", '%1', rec."Posting Date");
            IF "Sales Invoice Line1".FIND('-') THEN
                REPEAT
                    "Sales Invoice Line1"."Posting Date" := PostingDate1;
                    "Sales Invoice Line1".MODIFY;
                UNTIL "Sales Invoice Line1".NEXT = 0;


            "G/L Entry1".SETCURRENTKEY("Document No.", "Posting Date");
            "G/L Entry1".SETFILTER("G/L Entry1"."Document No.", rec."No.");
            "G/L Entry1".SETFILTER("G/L Entry1"."Posting Date", '%1', rec."Posting Date");
            IF "G/L Entry1".FIND('-') THEN
                REPEAT
                    "G/L Entry1"."Posting Date" := PostingDate1;
                    "G/L Entry1"."Document Date" := PostingDate1;
                    "G/L Entry1".MODIFY;
                UNTIL "G/L Entry1".NEXT = 0;

            CustLedgerEntry.SETCURRENTKEY("Document No.", "Document Type", "Customer No.");
            CustLedgerEntry.SETFILTER(CustLedgerEntry."Document No.", rec."No.");
            CustLedgerEntry.SETFILTER(CustLedgerEntry."Document Type", '%1', CustLedgerEntry."Document Type"::Invoice);
            CustLedgerEntry.SETFILTER(CustLedgerEntry."Customer No.", rec."Sell-to Customer No.");
            IF CustLedgerEntry.FIND('-') THEN
                REPEAT
                    CustLedgerEntry."Posting Date" := PostingDate1;
                    CustLedgerEntry.MODIFY;
                UNTIL CustLedgerEntry.NEXT = 0;

            DetailedCustLedgerEntry.SETCURRENTKEY("Document No.", "Document Type", "Posting Date");
            DetailedCustLedgerEntry.SETFILTER(DetailedCustLedgerEntry."Document No.", rec."No.");
            DetailedCustLedgerEntry.SETFILTER(DetailedCustLedgerEntry."Document Type", '%1', DetailedCustLedgerEntry."Document Type"::Invoice);
            DetailedCustLedgerEntry.SETFILTER(DetailedCustLedgerEntry."Posting Date", '%1', PrevPostingDate);
            IF DetailedCustLedgerEntry.FIND('-') THEN
                REPEAT
                    DetailedCustLedgerEntry."Posting Date" := PostingDate1;
                    DetailedCustLedgerEntry.MODIFY;
                UNTIL DetailedCustLedgerEntry.NEXT = 0;

            Rec."Posting Date" := PostingDate1;
            Rec.MODIFY;

            //send email start
            CLEAR(emailmsg);
            emailmsg.Create('martha.folkes@theknowledgeacademy.com',
                               'Posting Date changed - Posted Sales Invoice', '', TRUE);// ,'',TRUE);
            // SMTPMail.AddBCC('biju.kurup@theknowledgeacademy.com');
            emailmsg.addrecipient(3, 'biju.kurup@theknowledgeacademy.com');
            emailmsg.AppendToBody('Hi');
            emailmsg.AppendToBody('<BR><BR>');
            emailmsg.AppendToBody('Posting Date changed for Posted Sales Invoice');
            emailmsg.AppendToBody('<BR><BR>');
            emailmsg.AppendToBody('<BR><BR>');
            emailmsg.AppendToBody('<table cellspacing="10"  style="border-spacing: 0px;" border="1">' +
           '<col width="50"><col width="150"><col width="100">' +
            '<col width="50">' +
             '<tr><th align="Center">Document No</th>' +
            '<th align="Center">Old Posting Date</th>' +
            '<th align="Center">New Posting Date</th>' +
            '<th align="Center">User ID</th>');
            emailmsg.AppendToBody('<tr>');
            emailmsg.AppendToBody('<td align="Center">' + FORMAT(rec."No.") + '</td>');
            emailmsg.AppendToBody('<td align="Center">' + FORMAT(PrevPostingDate) + '</td>');
            emailmsg.AppendToBody('<td align="Center">' + FORMAT(PostingDate1) + '</td>');
            emailmsg.AppendToBody('<td align="Center">' + FORMAT(USERID) + '</td>');
            emailmsg.AppendToBody('</tr>');
            emailmsg.AppendToBody('</table>');

            emailmsg.AppendToBody('<BR><BR>');
            emailmsg.AppendToBody('<BR><BR>');
            emailmsg.AppendToBody('Kind Regards,');
            emailmsg.AppendToBody('<BR><BR>');
            emailmsg.AppendToBody('Dynamics');
            email.send(emailmsg);
            //send email end

        END

        ELSE
            ERROR('You do not have permission to change Posting Date');
    end;

    procedure KPInventoryForm()
    var
        KPInventory: Record "50063";
        SalesInvoiceLine1: Record 113;
    begin
        KPInventory.SETFILTER(KPInventory."KP Invoice No.", rec."No.");
        IF KPInventory.FIND('-') THEN
            PAGE.RUN(PAGE::"Knowledge Pass Inventory", KPInventory)
        ELSE BEGIN
            SalesInvoiceLine1.SETFILTER(SalesInvoiceLine1."Document No.", rec."No.");
            SalesInvoiceLine1.SETFILTER(SalesInvoiceLine1."KP No.", '<>%1', '');
            IF SalesInvoiceLine1.FIND('-') THEN BEGIN
                KPInventory.SETFILTER(KPInventory."KP Invoice No.", SalesInvoiceLine1."KP No.");
                IF KPInventory.FIND('-') THEN
                    PAGE.RUN(PAGE::"Knowledge Pass Inventory", KPInventory);
            END;
        END;
    end;

    procedure Export_SalesDataDynamic()
    var
        lInt: Integer;
        lDate1: Date;
        lDate2: Date;
        GLEntry: Record "17";
        SalesInvoiceLine: Record 113;
        Contact: Record 5050;
        SalesInvoiceHeader: Record 112;
        PreviousDocNo: Code[20];
        GLEntry1: Record "17";
        GLEntry1Description: Text[50];
        EventHeader: Record 50006;
        SalesInvoiceLine1: Record 113;
        "Sales Cr.Memo Line": Record "115";
        "Salesperson/Purchaser1": Record 13;
        SalesPersonName: Text[50];
        "General Ledger Setup1": Record "98";
        CurrencyCode1: Code[10];
        Company: Record 2000000006;
        Curexch: Record "330";
        CF: Decimal;
        TeamManager: Code[10];
        Customer1: Record "18";
        B2B_B2C: Code[3];
    begin
        CLEAR(ExcelBuffer);
        FromDate := 0D;
        ToDate := 0D;
        TeamManager := '';
        //GLCode:='';

        TeamManager := 'K.RANDHAWA';

        Window.OPEN('Enter From Date #1##########  To Date #2##########  Manager Code #3##########');
        //Window.OPEN('Enter From Date #1##########  To Date #2##########  Manager Code #3##########');
        // Window.INPUT(1,FromDate);
        // Window.INPUT(2,ToDate);
        // Window.INPUT(3,TeamManager);
        Window.CLOSE;



        Window.OPEN('Exporting @1@@@@@@@@@@@@@@@@@@@@@@@@@\ \');
        Window.UPDATE(1, 0);
        //ExcelBuffer.SetUseInfoSheed;
        //ExcelBuffer.NewRow;


        RowNum := 0;
        ColumnNum := 0;
        //RecNo :=0;

        RowNum += 1;
        ColumnNum += 1;
        EnterCell('Date Paid', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('Posting Date', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('Document No', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('Customer No', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('Customer Name', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('B2B/B2C', TRUE, FALSE, '@');

        //ColumnNum += 1; EnterCell('Location',TRUE,FALSE,'@');
        ColumnNum += 1;
        EnterCell('SO No', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('Exc Vat LCY', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('Inc Vat LCY', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('Currency Code', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('EX. Rate', TRUE, FALSE, '@');

        ColumnNum += 1;
        EnterCell('Exc Vat In GBP', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('Inc Vat In GBP', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('Status', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('SalesPerson', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('SalesPerson Name', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('Course Header', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('Company Name', TRUE, FALSE, '@');



        Company.SETFILTER(Company.Name, '<>%1', 'aa');
        IF Company.FIND('-') THEN
            REPEAT

                CLEAR(SalesInvoiceHeader);
                CLEAR("General Ledger Setup1");
                CLEAR(Team);
                CLEAR("Salesperson/Purchaser1");
                CLEAR(Curexch);
                CLEAR(SalesInvoiceLine);
                CLEAR(SalesInvoiceLine3);
                CLEAR(Customer1);

                SalesInvoiceHeader.CHANGECOMPANY(Company.Name);
                Customer1.CHANGECOMPANY(Company.Name);

                "General Ledger Setup1".CHANGECOMPANY(Company.Name);
                Team.CHANGECOMPANY(Company.Name);
                "Salesperson/Purchaser1".CHANGECOMPANY(Company.Name);
                Curexch.CHANGECOMPANY(Company.Name);
                SalesInvoiceLine.CHANGECOMPANY(Company.Name);

                "General Ledger Setup1".GET;

                SalesInvoiceHeader.SETCURRENTKEY("Posting Date", "No.");
                SalesInvoiceHeader.SETFILTER("Posting Date", '%1..%2', FromDate, ToDate);//010920D);
                IF SalesInvoiceHeader.FIND('-') THEN
                    REPEAT
                        ExchangeRate1 := 0;
                        AmountGBP1 := 0;
                        AmountGBPIncludingTax := 0;
                        PaymentStatus1 := '';
                        DatePaid1 := 0D;

                        SalesPersonName := '';
                        IF "Salesperson/Purchaser1".GET(SalesInvoiceHeader."Salesperson Code") THEN
                            SalesPersonName := "Salesperson/Purchaser1".Name;

                        //SalesInvoiceHeader.CALCFIELDS(Amount,"Amount Including VAT");
                        SalesInvoiceHeader.CALCFIELDS(Amount, "Amount Including VAT", CreditMemoDate4);

                        CourseHeader1 := '';
                        SalesInvoiceLine3.SETFILTER(SalesInvoiceLine3."Document No.", SalesInvoiceHeader."No.");
                        SalesInvoiceLine3.SETFILTER(SalesInvoiceLine3."Course Header", '<>%1', '');
                        IF SalesInvoiceLine3.FIND('-') THEN
                            CourseHeader1 := SalesInvoiceLine3."Course Header";

                        IF Team.GET(SalesInvoiceHeader."Salesperson Code") THEN BEGIN
                            IF Team."Manager Name" = TeamManager THEN BEGIN //'K.RANDAWA' THEN BEGIN
                                IF SalesInvoiceHeader."Currency Factor" <> 0 THEN
                                    ExchangeRate1 := 1 / SalesInvoiceHeader."Currency Factor";

                                IF ExchangeRate1 = 0 THEN
                                    ExchangeRate1 := 1;

                                DatePaid1 := 0D;
                                UpdatePaymentStatus(SalesInvoiceHeader."No.", Company.Name);

                                //AmountGBP1 := SalesInvoiceHeader.Amount*ExchangeRate1;//CF;
                                //AmountGBPIncludingTax := SalesInvoiceHeader."Amount Including VAT"*ExchangeRate1;//CF;


                                //
                                Curexch.RESET;
                                CF := 0;
                                AmountGBP1 := 0;
                                AmountGBPIncludingTax := 0;

                                IF SalesInvoiceHeader."Currency Code" = 'GBP' THEN BEGIN

                                    AmountGBP1 := SalesInvoiceHeader.Amount;///CF;
                                    AmountGBPIncludingTax := SalesInvoiceHeader."Amount Including VAT";///CF;//CF;

                                END
                                ELSE BEGIN

                                    SalesInvoiceLine.SETFILTER(SalesInvoiceLine."Document No.", SalesInvoiceHeader."No.");
                                    SalesInvoiceLine.SETFILTER(SalesInvoiceLine."No.", '<>%1', '');
                                    IF SalesInvoiceLine.FIND('-') THEN
                                        REPEAT
                                            AmountGBP1 := AmountGBP1 + SalesInvoiceLine."Amt. Excl. VAT (LCY)";
                                            AmountGBPIncludingTax := AmountGBPIncludingTax + SalesInvoiceLine."Amt. Incl. VAT (LCY)";

                                        UNTIL SalesInvoiceLine.NEXT = 0;

                                    Curexch.SETRANGE("Currency Code", 'GBP');
                                    Curexch.SETFILTER("Starting Date", '..%1', TODAY);
                                    IF Curexch.FINDLAST THEN
                                        CF := Curexch."Relational Exch. Rate Amount" / Curexch."Exchange Rate Amount";
                                    IF CF = 0 THEN
                                        CF := 1;
                                    AmountGBP1 := AmountGBP1 / CF;
                                    AmountGBPIncludingTax := AmountGBPIncludingTax / CF;//CF;
                                END;

                                //

                                CurrencyCode1 := '';
                                IF SalesInvoiceHeader."Currency Code" = '' THEN
                                    CurrencyCode1 := "General Ledger Setup1"."LCY Code"
                                ELSE
                                    CurrencyCode1 := SalesInvoiceHeader."Currency Code";



                                B2B_B2C := '';
                                IF Customer1.GET(SalesInvoiceHeader."Sell-to Customer No.") THEN BEGIN
                                    IF Customer1."Copy Sell-to Addr. to Qte From" = Customer1."Copy Sell-to Addr. to Qte From"::Person THEN
                                        B2B_B2C := 'B2C'
                                    ELSE
                                        B2B_B2C := 'B2B';

                                END;

                                RowNum += 1;
                                ColumnNum := 0;

                                DatePaid1 := SalesInvoiceHeader.CreditMemoDate4;
                                IF PaymentStatus1 = 'UNPAID' THEN
                                    DatePaid1 := 0D;

                                ColumnNum += 1;
                                EnterCell(FORMAT(DatePaid1), FALSE, FALSE, '@');
                                ColumnNum += 1;
                                EnterCell(FORMAT(SalesInvoiceHeader."Posting Date"), FALSE, FALSE, '@');
                                ColumnNum += 1;
                                EnterCell(FORMAT(SalesInvoiceHeader."No."), FALSE, FALSE, '@');
                                ColumnNum += 1;
                                EnterCell(FORMAT(SalesInvoiceHeader."Sell-to Customer No."), FALSE, FALSE, '@');

                                ColumnNum += 1;
                                EnterCell(FORMAT(SalesInvoiceHeader."Sell-to Customer Name"), FALSE, FALSE, '@');
                                ColumnNum += 1;
                                EnterCell(FORMAT(B2B_B2C), FALSE, FALSE, '@');


                                ColumnNum += 1;
                                EnterCell(FORMAT(SalesInvoiceHeader."Order No."), FALSE, FALSE, '@');
                                ColumnNum += 1;
                                EnterCell(FORMAT(SalesInvoiceHeader.Amount), FALSE, FALSE, '#,##0.00');
                                ColumnNum += 1;
                                EnterCell(FORMAT(SalesInvoiceHeader."Amount Including VAT"), FALSE, FALSE, '#,##0.00');
                                ColumnNum += 1;
                                EnterCell(FORMAT(CurrencyCode1), FALSE, FALSE, '#,##0.00');
                                ColumnNum += 1;
                                EnterCell(FORMAT(ExchangeRate1), FALSE, FALSE, '#,##0.00');
                                // ColumnNum += 1;  EnterCell(FORMAT(CF),FALSE,FALSE,'#,##0.00');

                                ColumnNum += 1;
                                EnterCell(FORMAT(AmountGBP1), FALSE, FALSE, '#,##0.00');
                                ColumnNum += 1;
                                EnterCell(FORMAT(AmountGBPIncludingTax), FALSE, FALSE, '#,##0.00');
                                ColumnNum += 1;
                                EnterCell(FORMAT(PaymentStatus1), FALSE, FALSE, '@');
                                ColumnNum += 1;
                                EnterCell(FORMAT(SalesInvoiceHeader."Salesperson Code"), FALSE, FALSE, '#,##0.00');
                                ColumnNum += 1;
                                EnterCell(FORMAT(SalesPersonName), FALSE, FALSE, '@');
                                ColumnNum += 1;
                                EnterCell(FORMAT(CourseHeader1), FALSE, FALSE, '@');
                                ColumnNum += 1;
                                EnterCell(FORMAT(Company.Name), FALSE, FALSE, '@');

                            END;
                        END;
                    UNTIL SalesInvoiceHeader.NEXT = 0;
            UNTIL Company.NEXT = 0;

        Window.CLOSE;
    end;

    procedure Export_SalesDataDynamic1()
    var
        lInt: Integer;
        lDate1: Date;
        lDate2: Date;
        GLEntry: Record "17";
        SalesInvoiceLine: Record 113;
        Contact: Record 5050;
        SalesInvoiceHeader: Record 112;
        PreviousDocNo: Code[20];
        GLEntry1: Record "17";
        GLEntry1Description: Text[50];
        EventHeader: Record 50006;
        SalesInvoiceLine1: Record 113;
        "Sales Cr.Memo Line": Record "115";
        "Salesperson/Purchaser1": Record 13;
        SalesPersonName: Text[50];
        "General Ledger Setup1": Record "98";
        CurrencyCode1: Code[10];
        Company: Record 2000000006;
        Curexch: Record "330";
        CF: Decimal;
        Customer1: Record "18";
        B2B_B2C: Code[3];
    begin
        CLEAR(ExcelBuffer);
        FromDate := 0D;
        ToDate := 0D;
        TeamManager := '';
        //GLCode:='';

        TeamManager := 'Karan Randhawa';

        Window.OPEN('Enter From Date #1##########  To Date #2##########  Manager Code #3##########');
        //Window.OPEN('Enter From Date #1##########  To Date #2##########  Manager Code #3##########');
        // Window.INPUT(1,FromDate);
        // Window.INPUT(2,ToDate);
        // Window.INPUT(3,TeamManager);
        Window.CLOSE;



        Window.OPEN('Exporting @1@@@@@@@@@@@@@@@@@@@@@@@@@\ \');
        Window.UPDATE(1, 0);
        //ExcelBuffer.SetUseInfoSheed;
        //ExcelBuffer.NewRow;


        RowNum := 0;
        ColumnNum := 0;
        //RecNo :=0;

        RowNum += 1;
        ColumnNum += 1;
        EnterCell('Date Paid', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('Posting Date', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('Document No', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('Customer No', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('Customer Name', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('B2B/B2C', TRUE, FALSE, '@');

        //ColumnNum += 1; EnterCell('Location',TRUE,FALSE,'@');
        ColumnNum += 1;
        EnterCell('SO No', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('Exc Vat LCY', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('Inc Vat LCY', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('Currency Code', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('EX. Rate', TRUE, FALSE, '@');

        ColumnNum += 1;
        EnterCell('Exc Vat In GBP', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('Inc Vat In GBP', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('Status', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('SalesPerson', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('SalesPerson Name', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('Course Header', TRUE, FALSE, '@');
        ColumnNum += 1;
        EnterCell('Company Name', TRUE, FALSE, '@');



        Company.SETFILTER(Company.Name, '<>%1', 'aa');
        IF Company.FIND('-') THEN
            REPEAT

                CLEAR(SalesInvoiceHeader);
                CLEAR("General Ledger Setup1");
                CLEAR(Team);
                CLEAR("Salesperson/Purchaser1");
                CLEAR(Curexch);
                CLEAR(SalesInvoiceLine);
                CLEAR(SalesInvoiceLine3);
                CLEAR(Customer1);

                SalesInvoiceHeader.CHANGECOMPANY(Company.Name);
                Customer1.CHANGECOMPANY(Company.Name);

                "General Ledger Setup1".CHANGECOMPANY(Company.Name);
                Team.CHANGECOMPANY(Company.Name);
                "Salesperson/Purchaser1".CHANGECOMPANY(Company.Name);
                Curexch.CHANGECOMPANY(Company.Name);
                SalesInvoiceLine.CHANGECOMPANY(Company.Name);

                "General Ledger Setup1".GET;

                SalesInvoiceHeader.SETCURRENTKEY("Posting Date", "No.");
                SalesInvoiceHeader.SETFILTER("Posting Date", '%1..%2', FromDate, ToDate);//010920D);
                IF SalesInvoiceHeader.FIND('-') THEN
                    REPEAT
                        ExchangeRate1 := 0;
                        AmountGBP1 := 0;
                        AmountGBPIncludingTax := 0;
                        PaymentStatus1 := '';
                        DatePaid1 := 0D;

                        SalesPersonName := '';
                        IF "Salesperson/Purchaser1".GET(SalesInvoiceHeader."Salesperson Code") THEN
                            SalesPersonName := "Salesperson/Purchaser1".Name;

                        //SalesInvoiceHeader.CALCFIELDS(Amount,"Amount Including VAT");
                        SalesInvoiceHeader.CALCFIELDS(Amount, "Amount Including VAT", CreditMemoDate4);

                        CourseHeader1 := '';
                        SalesInvoiceLine3.SETFILTER(SalesInvoiceLine3."Document No.", SalesInvoiceHeader."No.");
                        SalesInvoiceLine3.SETFILTER(SalesInvoiceLine3."Course Header", '<>%1', '');
                        IF SalesInvoiceLine3.FIND('-') THEN
                            CourseHeader1 := SalesInvoiceLine3."Course Header";

                        //IF Team.GET(SalesInvoiceHeader."Salesperson Code") THEN BEGIN
                        IF SalesPersonName = TeamManager THEN BEGIN //'K.RANDAWA' THEN BEGIN
                            IF SalesInvoiceHeader."Currency Factor" <> 0 THEN
                                ExchangeRate1 := 1 / SalesInvoiceHeader."Currency Factor";

                            IF ExchangeRate1 = 0 THEN
                                ExchangeRate1 := 1;

                            DatePaid1 := 0D;
                            //UpdatePaymentStatus(SalesInvoiceHeader."No.",Company.Name);

                            //AmountGBP1 := SalesInvoiceHeader.Amount*ExchangeRate1;//CF;
                            //AmountGBPIncludingTax := SalesInvoiceHeader."Amount Including VAT"*ExchangeRate1;//CF;


                            //
                            Curexch.RESET;
                            CF := 0;
                            AmountGBP1 := 0;
                            AmountGBPIncludingTax := 0;

                            IF SalesInvoiceHeader."Currency Code" = 'GBP' THEN BEGIN

                                AmountGBP1 := SalesInvoiceHeader.Amount;///CF;
                                AmountGBPIncludingTax := SalesInvoiceHeader."Amount Including VAT";///CF;//CF;

                            END
                            ELSE BEGIN

                                SalesInvoiceLine.SETFILTER(SalesInvoiceLine."Document No.", SalesInvoiceHeader."No.");
                                SalesInvoiceLine.SETFILTER(SalesInvoiceLine."No.", '<>%1', '');
                                IF SalesInvoiceLine.FIND('-') THEN
                                    REPEAT
                                        AmountGBP1 := AmountGBP1 + SalesInvoiceLine."Amt. Excl. VAT (LCY)";
                                        AmountGBPIncludingTax := AmountGBPIncludingTax + SalesInvoiceLine."Amt. Incl. VAT (LCY)";

                                    UNTIL SalesInvoiceLine.NEXT = 0;

                                Curexch.SETRANGE("Currency Code", 'GBP');
                                Curexch.SETFILTER("Starting Date", '..%1', TODAY);
                                IF Curexch.FINDLAST THEN
                                    CF := Curexch."Relational Exch. Rate Amount" / Curexch."Exchange Rate Amount";
                                IF CF = 0 THEN
                                    CF := 1;
                                AmountGBP1 := AmountGBP1 / CF;
                                AmountGBPIncludingTax := AmountGBPIncludingTax / CF;//CF;
                            END;

                            CurrencyCode1 := '';
                            IF SalesInvoiceHeader."Currency Code" = '' THEN
                                CurrencyCode1 := "General Ledger Setup1"."LCY Code"
                            ELSE
                                CurrencyCode1 := SalesInvoiceHeader."Currency Code";



                            B2B_B2C := '';
                            IF Customer1.GET(SalesInvoiceHeader."Sell-to Customer No.") THEN BEGIN
                                IF Customer1."Copy Sell-to Addr. to Qte From" = Customer1."Copy Sell-to Addr. to Qte From"::Person THEN
                                    B2B_B2C := 'B2C'
                                ELSE
                                    B2B_B2C := 'B2B';

                            END;

                            RowNum += 1;
                            ColumnNum := 0;

                            PaymentStatus1 := SalesInvoiceHeader.PaymentStatus3;

                            //if SalesInvoiceHeader.PaymentStatus3='' THEN
                            //PaymentStatus1:='UNPAID';

                            DatePaid1 := SalesInvoiceHeader.CreditMemoDate4;
                            IF PaymentStatus1 = 'UNPAID' THEN
                                DatePaid1 := 0D;

                            ColumnNum += 1;
                            EnterCell(FORMAT(DatePaid1), FALSE, FALSE, '@');
                            ColumnNum += 1;
                            EnterCell(FORMAT(SalesInvoiceHeader."Posting Date"), FALSE, FALSE, '@');
                            ColumnNum += 1;
                            EnterCell(FORMAT(SalesInvoiceHeader."No."), FALSE, FALSE, '@');
                            ColumnNum += 1;
                            EnterCell(FORMAT(SalesInvoiceHeader."Sell-to Customer No."), FALSE, FALSE, '@');

                            ColumnNum += 1;
                            EnterCell(FORMAT(SalesInvoiceHeader."Sell-to Customer Name"), FALSE, FALSE, '@');
                            ColumnNum += 1;
                            EnterCell(FORMAT(B2B_B2C), FALSE, FALSE, '@');


                            ColumnNum += 1;
                            EnterCell(FORMAT(SalesInvoiceHeader."Order No."), FALSE, FALSE, '@');
                            ColumnNum += 1;
                            EnterCell(FORMAT(SalesInvoiceHeader.Amount), FALSE, FALSE, '#,##0.00');
                            ColumnNum += 1;
                            EnterCell(FORMAT(SalesInvoiceHeader."Amount Including VAT"), FALSE, FALSE, '#,##0.00');
                            ColumnNum += 1;
                            EnterCell(FORMAT(CurrencyCode1), FALSE, FALSE, '#,##0.00');
                            ColumnNum += 1;
                            EnterCell(FORMAT(ExchangeRate1), FALSE, FALSE, '#,##0.00');
                            // ColumnNum += 1;  EnterCell(FORMAT(CF),FALSE,FALSE,'#,##0.00');

                            ColumnNum += 1;
                            EnterCell(FORMAT(AmountGBP1), FALSE, FALSE, '#,##0.00');
                            ColumnNum += 1;
                            EnterCell(FORMAT(AmountGBPIncludingTax), FALSE, FALSE, '#,##0.00');
                            ColumnNum += 1;
                            EnterCell(FORMAT(PaymentStatus1), FALSE, FALSE, '@');
                            ColumnNum += 1;
                            EnterCell(FORMAT(SalesInvoiceHeader."Salesperson Code"), FALSE, FALSE, '#,##0.00');
                            ColumnNum += 1;
                            EnterCell(FORMAT(SalesPersonName), FALSE, FALSE, '@');
                            ColumnNum += 1;
                            EnterCell(FORMAT(CourseHeader1), FALSE, FALSE, '@');
                            ColumnNum += 1;
                            EnterCell(FORMAT(Company.Name), FALSE, FALSE, '@');

                            //END;
                        END;
                    UNTIL SalesInvoiceHeader.NEXT = 0;
            UNTIL Company.NEXT = 0;

        Window.CLOSE;
    end;

    procedure ChangeAdd1()
    var
        Window: Dialog;
        Name1: Text[50];
        Add1: Text[50];
        Add2: Text[50];
        bmail: Text[50];
        fmail: Text[50];
        COA: report COAExcelReports;

        SalesSetup: record "Sales & Receivables Setup";
        CU: codeunit 50101;

    begin
        // IF UPPERCASE(USERID) IN ['MARTHA.FOLKES', 'PRABHJOT.KAUR', 'BIJU.KURUP', 'KIRAN.MADHAR'] THEN BEGIN
        IF CONFIRM('Are you sure you want to change the address?') THEN BEGIN
            SalesInvHeader.GET(rec."No.");
            SalesSetup.get;
            SalesSetup.BilltoName := rec."Bill-to Name";
            salessetup.BilltoAdd := rec."Bill-to Address";
            salessetup.BilltoAdd2 := rec."Bill-to Address 2";
            salessetup.BookerEMail := rec."Booker Email";
            SalesSetup.FinanceEMail := rec."Account Email";
            SalesSetup.PostCode := rec."Bill-to Post Code";
            SalesSetup.City := rec."Bill-to City";
            //KN 080824
            SalesSetup.Vatnumber := rec."VAT Registration No.";

            SalesSetup.Modify();

            Commit;
            COA.setreport(15);
            COA.runmodal;


            // Window.OPEN('Enter Name ##############1##' +
            // 'Enter Address  ##############2## Enter Address 2  ##############3## Enter Booker Email ###############4##' +
            // 'Enter Finance Email ###############5##', Name1, Add1, Add2, bmail, fmail);

            // // Window.INPUT(1,Name1);
            // // Window.INPUT(2,Add1);
            // // Window.INPUT(3,Add2);
            // // Window.INPUT(4,bmail);
            // // Window.INPUT(5,fmail);

            // Window.CLOSE;
            CU.UpdatePostedSalesInvoice1(rec);


            // rec.MODIFY(TRUE);
            MESSAGE('Address Changed');
        END;
        // END
        // ELSE
        //     ERROR('You dont have permission to change address');



        /*
        Window.OPEN('Enter From Date #1##########  To Date #2##########  ');
        Window.INPUT(1,FromDate);
        Window.INPUT(2,ToDate);
        //Window.INPUT(3,GLCode);
        Window.CLOSE;
        */

    end;

    procedure AddInvoiceToKPInventoryFP()
    var
        KP1: Record "50063";
        KP: Record "50063";
        SalesInvoiceLine: Record 113;
        SalesInvoiceLine1: Record 113;
    begin

        //ERROR('This is not FP Invoice');

        IF NOT CONFIRM('Are you sure to Create KP Inventory Entry for this Invoice?') THEN
            EXIT;


        IF UPPERCASE(USERID) IN ['MARTHA.FOLKES', 'PRABHJOT.KAUR', 'BIJU.KURUP'] THEN BEGIN
            SalesInvoiceLine1.SETFILTER(SalesInvoiceLine1."Document No.", rec."No.");
            SalesInvoiceLine1.SETFILTER(SalesInvoiceLine1."No.", '5344');
            IF SalesInvoiceLine1.FIND('-') THEN BEGIN

                IF NOT rec."Flexi Pass" THEN BEGIN
                    rec."Flexi Pass" := TRUE;
                    rec.MODIFY;
                END;

                KP.INIT;
                IF rec."Flexi Pass" THEN BEGIN
                    SalesInvoiceLine.SETFILTER(SalesInvoiceLine."Document No.", rec."No.");
                    SalesInvoiceLine.SETFILTER(SalesInvoiceLine."No.", '5344');
                    IF SalesInvoiceLine.FIND('-') THEN
                        REPEAT
                            KP."KP Invoice No." := SalesInvoiceLine."Document No.";// '384554';
                            KP."Line No." := SalesInvoiceLine."Line No.";//10000;
                            KP."Booking Date" := rec."Posting Date";// 151121D;
                            KP."Customer No." := rec."Sell-to Customer No.";//'C230108';
                            KP."Sales Person" := rec."Salesperson Code";//"Sales Person";//'M.SCRACE';
                            KP."Expiry Date" := rec."Posting Date" + 60;//150122D;//110122d111121D+60;
                            KP."Flexi Pass" := TRUE;
                            KP.Location := SalesInvoiceLine."Group Location";//'9AM-BST';
                            KP.INSERT;
                        UNTIL SalesInvoiceLine.NEXT = 0;
                END;
            END;



            KP1.SETFILTER(KP1."KP Invoice No.", rec."No.");
            IF KP1.FIND('-') THEN
                ERROR('KP Inventory already exists for this Invoice');
        END
        ELSE
            ERROR('You do not have permission to run 5344 report');


        MESSAGE('Done');
        //385667
    end;

    procedure ChangeEmail1()
    var
        Window: Dialog;
        Name1: Text[50];
        Add1: Text[50];
        Add2: Text[50];
        bmail: Text[50];
        fmail: Text[50];
        COA: report COAExcelReports;
        SalesSetup: record "Sales & Receivables Setup";
        CU: codeunit 50101;
    begin
        //   IF UPPERCASE(USERID) IN ['MARTHA.FOLKES', 'PRABHJOT.KAUR', 'BIJU.KURUP', 'KIRAN.MADHAR'] THEN BEGIN abhi 
        IF CONFIRM('Are you sure you want to change the address?') THEN BEGIN
            SalesInvHeader.GET(rec."No.");
            SalesSetup.get;
            salessetup.BookerEMail := rec."Booker Email";
            SalesSetup.FinanceEMail := rec."Account Email";
            SalesSetup.Modify();
            Commit;
            coa.SetReport(13);
            COA.RunModal();

            CU.UpdatePostedSalesInvoice(rec);
            // bmail := SalesSetup.BookerEMail;
            // fmail := SalesSetup.FinanceEMail;
            // //Window.CLOSE;

            // rec."Booker Email" := bmail;
            // rec."Account Email" := fmail;
            // rec.VALIDATE("Booker Email");
            // rec.VALIDATE("Account Email");


            // rec.MODIFY(TRUE);
            // MESSAGE('E-Mail Address Changed');
        END;
        //END abhi 
        //// ELSE
        // ERROR('You dont have permission to change address');abhi 



        /*
        Window.OPEN('Enter From Date #1##########  To Date #2##########  ');
        Window.INPUT(1,FromDate);
        Window.INPUT(2,ToDate);
        //Window.INPUT(3,GLCode);
        Window.CLOSE;
        */

    end;

    procedure CreateFAJournal_10sales()
    var
        GnlJnl: Record 81;
        "G/L Entry": Record "17";
        LineNo: Integer;
        NoSeriesMgt: Codeunit "396";
        salesInvLine: Record 113;
        CLE1: Record "21";
    begin
        NextDocumentNo := '';
        TDSAmount := 0;

        CLE1.SETCURRENTKEY(CLE1."Customer No.", "Posting Date", "Currency Code");
        CLE1.SETFILTER(CLE1."Customer No.", rec."Sell-to Customer No.");
        CLE1.SETFILTER(CLE1."Posting Date", '%1', rec."Posting Date");
        IF CLE1.FIND('-') THEN
            REPEAT
                CLE1."Applying Entry" := FALSE;
                CLE1."Applies-to ID" := '';
                CLE1."Amount to Apply" := 0;

                CLE1.MODIFY;
            UNTIL CLE1.NEXT = 0;

        CLEAR(salesInvLine);
        salesInvLine.SETFILTER(salesInvLine."Document No.", rec."No.");
        salesInvLine.SETFILTER(salesInvLine."Apply TDS", '%1', TRUE);
        IF salesInvLine.FIND('-') THEN
            REPEAT

                //IF SalesInvLine."TDS JV Doc No."<>'' THEN
                //ERROR('TDS Already created for the Line No. %1', SalesInvLine."Line No.");
                TDSAmount := TDSAmount + (salesInvLine.Amount);
            UNTIL salesInvLine.NEXT = 0;
        TDSAmount := (TDSAmount * 10) / 100;

        IF NOT CONFIRM('Are you sure to post TDS Journal for the Amount %1 ' + FORMAT(TDSAmount)) THEN
            EXIT;

        IF TDSAmount = 0 THEN
            ERROR('TDS Amount is 0, can not post');



        CLEAR(GnlJnl);
        GnlJnl.SETFILTER(GnlJnl."Journal Template Name", 'GENERAL');
        GnlJnl.SETFILTER(GnlJnl."Journal Batch Name", 'DEFAULT-A');
        IF GnlJnl.FIND('-') THEN
            REPEAT
                GnlJnl.DELETE;
            UNTIL GnlJnl.NEXT = 0;
        CLEAR(GnlJnl);
        GnlJnl.VALIDATE(GnlJnl."Journal Template Name", 'GENERAL');
        GnlJnl.VALIDATE(GnlJnl."Journal Batch Name", 'DEFAULT-A');
        LineNo += 10000;
        GnlJnl."Line No." := LineNo;

        IF NextDocumentNo = '' THEN
            NextDocumentNo := NoSeriesMgt.GetNextNo('GJNL-GEN', TODAY, TRUE);

        GnlJnl."Document No." := NextDocumentNo;//"G/L Entry"."Document No.";//GenLineDocumentNo;//PRcptHea."No.";
        GnlJnl.VALIDATE(GnlJnl."Posting Date", TODAY);
        GnlJnl.VALIDATE(GnlJnl."Account Type", GnlJnl."Account Type"::"G/L Account");
        GnlJnl."Account No." := '5917';

        GnlJnl.Description := 'TDS Receivable ' + rec."Sell-to Customer No." + ' ' + rec."No." + ' @10 %';
        GnlJnl."External Document No." := rec."External Document No.";

        rec.CALCFIELDS(Amount);
        GnlJnl.VALIDATE(GnlJnl.Amount, TDSAmount);
        GnlJnl."Event Header" := 'EVE0000000';
        GnlJnl."Event Start Date" := 20171219D;//"G/L Entry"."Event Start Date";

        GnlJnl."Bal. Account Type" := GnlJnl."Bal. Account Type"::Customer;
        GnlJnl."Bal. Account No." := rec."Sell-to Customer No.";
        GnlJnl.VALIDATE("Currency Code", Rec."Currency Code");

        GnlJnl."Bal. Account Type" := GnlJnl."Bal. Account Type"::"G/L Account";
        GnlJnl."Bal. Account No." := '';


        GnlJnl.VALIDATE("Shortcut Dimension 1 Code", 'HEADOFFICE');
        GnlJnl.VALIDATE("Shortcut Dimension 2 Code", 'HEAD OFFICE');
        GnlJnl."Source Type" := GnlJnl."Source Type"::Customer;
        GnlJnl."Source No." := rec."Sell-to Customer No.";
        /*abhishelk
        JournalLineDimension.INIT;
        JournalLineDimension."Table ID"  :=81;
        JournalLineDimension."Journal Template Name" :='GENERAL';
        JournalLineDimension."Journal Batch Name":='DEFAULT-A';
        JournalLineDimension."Journal Line No.":=GnlJnl."Line No.";
        JournalLineDimension."Dimension Code" := 'EVENT';
        JournalLineDimension."Dimension Value Code" := 'EVE0000000';
        JournalLineDimension.INSERT;  */

        GnlJnl.SystemEntry := TRUE;
        GnlJnl."Created By" := USERID;
        GnlJnl."Created Date" := TODAY;
        GnlJnl."Created Time" := TIME;

        GnlJnl."Source Code" := 'GENJNL';
        GnlJnl."Sell-to/Buy-from No." := rec."Sell-to Customer No.";
        GnlJnl."Country/Region Code" := 'IN';
        GnlJnl."TDS % India" := 10;
        GnlJnl.INSERT(TRUE);

        //Insert Bal account
        GnlJnl.VALIDATE(GnlJnl."Journal Template Name", 'GENERAL');
        GnlJnl.VALIDATE(GnlJnl."Journal Batch Name", 'DEFAULT-A');
        LineNo += 10000;
        GnlJnl."Line No." := LineNo;

        GnlJnl."Document No." := NextDocumentNo;//"G/L Entry"."Document No.";//GenLineDocumentNo;//PRcptHea."No.";
        GnlJnl.VALIDATE(GnlJnl."Posting Date", TODAY);
        GnlJnl."Account Type" := GnlJnl."Account Type"::Customer;
        GnlJnl."Account No." := rec."Sell-to Customer No.";//GnlJnl."Account Type"::Vendor;//'5916';

        GnlJnl.Description := 'TDS Receivable ' + rec."Sell-to Customer No." + ' ' + rec."No." + ' @10 %';
        GnlJnl."External Document No." := rec."External Document No.";

        rec.CALCFIELDS(Amount);
        GnlJnl.VALIDATE(GnlJnl.Amount, TDSAmount * -1);
        GnlJnl."Event Header" := 'EVE0000000';
        GnlJnl."Event Start Date" := 20171219D;//"G/L Entry"."Event Start Date";

        GnlJnl.VALIDATE("Currency Code", Rec."Currency Code");

        GnlJnl.VALIDATE("Shortcut Dimension 1 Code", 'HEADOFFICE');
        GnlJnl.VALIDATE("Shortcut Dimension 2 Code", 'HEAD OFFICE');

        GnlJnl."Bal. Account Type" := GnlJnl."Bal. Account Type"::"G/L Account";
        GnlJnl."Bal. Account No." := '';
        GnlJnl."Source Type" := GnlJnl."Source Type"::Customer;
        GnlJnl."Source No." := rec."Sell-to Customer No.";



        /*
        JournalLineDimension.INIT;
        JournalLineDimension."Table ID"  :=81;
        JournalLineDimension."Journal Template Name" :='GENERAL';
        JournalLineDimension."Journal Batch Name":='DEFAULT-A';
        JournalLineDimension."Journal Line No.":=GnlJnl."Line No.";
        JournalLineDimension."Dimension Code" := 'EVENT';
        JournalLineDimension."Dimension Value Code" := 'EVE0000000';
        JournalLineDimension.INSERT;
abhishek*/
        GnlJnl.SystemEntry := TRUE;
        GnlJnl."Created By" := USERID;
        GnlJnl."Created Date" := TODAY;
        GnlJnl."Created Time" := TIME;

        GnlJnl."Source Code" := 'GENJNL';
        GnlJnl."Sell-to/Buy-from No." := rec."Sell-to Customer No.";
        GnlJnl."Country/Region Code" := 'IN';

        GnlJnl."TDS % India" := 10;
        GnlJnl.INSERT(TRUE);

        CODEUNIT.RUN(CODEUNIT::"Gen. Jnl.-Post Batch", GnlJnl);

        salesInvLine1.SETFILTER(salesInvLine1."Document No.", rec."No.");
        salesInvLine1.SETFILTER(salesInvLine1."Apply TDS", '%1', TRUE);
        IF salesInvLine1.FIND('-') THEN
            REPEAT
                salesInvLine1."TDS JV Doc No." := NextDocumentNo + ' @10%';//GnlJnl."Document No.";
                salesInvLine1.MODIFY;
            UNTIL salesInvLine1.NEXT = 0;

        //MESSAGE ('Process completed');

    end;

    //ApplyandPost commented since no reference and giving error

    // procedure ApplyandPostTDS()
    // var
    //     "Vendor Ledger Entry": Record "21";
    //     RemainingAmount: Decimal;
    //     Flag: Boolean;
    //     vendLedEntry: Record "21";
    //     SetVendApplication: Codeunit "101";
    //     VendEntryApplyPostedEntries: Codeunit 226;
    //     Applied: Boolean;
    //     lc_VendorLedgerEntry: Record "21";
    //     VLE1: Record "21";
    // begin
    //     IF TDSAmount = 0 THEN
    //         ERROR('TDS Amount is 0');

    //     IF NextDocumentNo = '' THEN
    //         ERROR('');

    //     "Vendor Ledger Entry".SETCURRENTKEY("Document No.", "Document Type", "Customer No.");

    //     "Vendor Ledger Entry".SETFILTER("Vendor Ledger Entry"."Document No.", rec."No.");
    //     "Vendor Ledger Entry".SETFILTER("Vendor Ledger Entry"."Document Type", '%1', "Vendor Ledger Entry"."Document Type"::Invoice);
    //     "Vendor Ledger Entry".SETFILTER("Vendor Ledger Entry"."Customer No.", rec."Sell-to Customer No.");
    //     IF "Vendor Ledger Entry".FIND('-') THEN BEGIN
    //         //MESSAGE ("Vendor Ledger Entry"."Document No.");
    //         "Vendor Ledger Entry".CALCFIELDS("Remaining Amount");
    //         IF "Vendor Ledger Entry"."Remaining Amount" = 0 THEN
    //             ERROR('Remaining Amount for the Customer %1 is 0', "Vendor Ledger Entry"."Customer No.");

    //         IF "Vendor Ledger Entry".Amount > 0 THEN
    //             ERROR('Amount should be less than 0 in Customer Ledger for the Customer %1 is 0', "Vendor Ledger Entry"."Customer No.");


    //         RemainingAmount := ABS("Vendor Ledger Entry"."Remaining Amount");
    //         "Vendor Ledger Entry"."Applying Entry" := TRUE;
    //         "Vendor Ledger Entry"."Applies-to ID" := USERID;
    //         "Vendor Ledger Entry"."Amount to Apply" := "Vendor Ledger Entry"."Remaining Amount";
    //         CODEUNIT.RUN(CODEUNIT::"Cust. Entry-Edit", "Vendor Ledger Entry");
    //         COMMIT;
    //         Flag := FALSE;

    //         vendLedEntry.SETCURRENTKEY("Document No.", "Document Type", "Customer No.");
    //         vendLedEntry.SETFILTER(vendLedEntry."Document No.", NextDocumentNo);

    //         vendLedEntry.SETFILTER("Document Type", '%1', vendLedEntry."Document Type"::" ");
    //         vendLedEntry.SETRANGE("Customer No.", "Vendor Ledger Entry"."Customer No.");
    //         //vendLedEntry.SETFILTER("Posting Date",'<=%1', "Vendor Ledger Entry"."Posting Date"); MS COMMENT
    //         vendLedEntry.SETFILTER("Posting Date", '%1', "Vendor Ledger Entry"."Posting Date");
    //         vendLedEntry.CALCFIELDS(Amount, "Remaining Amount");
    //         vendLedEntry.SETFILTER(Amount, '>%1', 0);
    //         vendLedEntry.SETRANGE(Open, TRUE);
    //         vendLedEntry.SETFILTER("Remaining Amount", '<>%1', 0);
    //         vendLedEntry.SETFILTER("Applies-to ID", '=%1', '');
    //         IF vendLedEntry.FIND('-') THEN BEGIN
    //             Flag := TRUE;
    //             IF RemainingAmount = 0 THEN BEGIN
    //             END ELSE
    //                 IF ABS(RemainingAmount) <= ABS(vendLedEntry."Remaining Amount") THEN BEGIN
    //                     // SetVendApplication.SetApplId(vendLedEntry,"Vendor Ledger Entry",USERID);
    //                     //SetVendApplication.SetApplId(vendLedEntry,"Vendor Ledger Entry",tdsamount,0,USERID);
    //                     SetVendApplication.SetApplId(vendLedEntry, "Vendor Ledger Entry", USERID);
    //                     RemainingAmount := 0;
    //                 END ELSE
    //                     IF ABS(RemainingAmount) > ABS(vendLedEntry."Remaining Amount") THEN BEGIN
    //                         //          SetVendApplication.SetApplId(vendLedEntry,"Vendor Ledger Entry",USERID);
    //                         SetVendApplication.SetApplId(vendLedEntry, "Vendor Ledger Entry", USERID);
    //                         RemainingAmount := ABS(ABS(RemainingAmount) - ABS(vendLedEntry."Remaining Amount"));

    //                     END;


    //         END;


    //         IF Flag = TRUE THEN
    //             VendEntryApplyPostedEntries.PostTDS(vendLedEntry);
    //         //VendEntryApplyPostedEntries(vendLedEntry);
    //         //VendEntryApplyPostedEntries.ApplyVendEntryformEntry(vendLedEntry);
    //         // Applied := VendEntryApplyPostedEntries.Apply("Vendor Ledger Entry","Vendor Ledger Entry"."Document No.",WORKDATE);
    //         COMMIT;

    //         lc_VendorLedgerEntry.RESET;
    //         /*
    //         lc_VendorLedgerEntry.SETRANGE("Vendor No.","Vendor Ledger Entry" No.");
    //         lc_VendorLedgerEntry.MODIFYALL("Applies-to ID",'');
    //         lc_VendorLedgerEntry.MODIFYALL("Applying Entry",FALSE);
    //         lc_VendorLedgerEntry.MODIFYALL("Amount to Apply",0);
    //         */

    //         //lc_VendorLedgerEntry.SETFILTER(lc_VendorLedgerEntry."Document No.","No.");
    //         lc_VendorLedgerEntry.SETRANGE("Customer No.", rec."Sell-to Customer No.");
    //         IF lc_VendorLedgerEntry.FIND('-') THEN BEGIN
    //             lc_VendorLedgerEntry.MODIFYALL("Applies-to ID", '');
    //             lc_VendorLedgerEntry.MODIFYALL("Applying Entry", FALSE);
    //             lc_VendorLedgerEntry.MODIFYALL("Amount to Apply", 0);
    //         END;

    //     END;

    // end;

    local procedure OnAfterGetCurrRecord()
    begin
        xRec := Rec;

        //NB
        CreditStatus := '';
        IF rec.PaymentStatus3 = 'CREDITED' THEN BEGIN
            scmh.SETFILTER(scmh."No.", rec.CreditMemoNo3);
            IF scmh.FINDFIRST THEN BEGIN
                rc.SETFILTER(rc.Code, scmh."Reason Code");
                IF rc.FINDFIRST THEN CreditStatus := FORMAT(rc."Credit Status");
            END;
        END;
        //Nb
        UpdateDocAndAmount; //nb 300824
    end;

    local procedure OnBeforePutRecord()
    begin
        PaymentEntry.SETCURRENTKEY("Source No.", "Status Code");
        PaymentEntry.SETRANGE(PaymentEntry."Source No.", rec."No.");
        PaymentEntry.SETRANGE(PaymentEntry."Status Code", '0');
        PaymentEntry.CALCSUMS(Amount);
        //abhi Paid := PaymentEntry.Amount;
    end;

    local procedure ReturnPassType(): text[100]
    begin
        if rec."Flexi Pass" then
            exit('Flexi Pass 6 month')
        else if rec."Flexi Pass 2" then
            exit('Flexi Pass 2 month')
        else if rec."Flexi Pass 12" then
            exit('Flexi Pass 12 Month')
        else if rec."Knowledge Pass" then
            exit('Knowledge pass')
        else
            exit('');

    end;


    //NB 210824
    local procedure GetAppliedentries(var recCustLedg: record "Cust. Ledger Entry")
    var
        CreateCustLedgEntry: Record "Cust. Ledger Entry";
    begin
        recCustLedg.Reset();
        if recCustLedg."Entry No." <> 0 then begin
            CreateCustLedgEntry := recCustLedg;
            FindApplnEntriesDtldtLedgEntry(recCustLedg, CreateCustLedgEntry);
            recCustLedg.SetCurrentKey("Entry No.");
            recCustLedg.SetRange("Entry No.");
            if CreateCustLedgEntry."Closed by Entry No." <> 0 then begin
                recCustLedg."Entry No." := CreateCustLedgEntry."Closed by Entry No.";
                recCustLedg.Mark(true);
            end;
            recCustLedg.SetCurrentKey("Closed by Entry No.");
            recCustLedg.SetRange("Closed by Entry No.", CreateCustLedgEntry."Entry No.");
            if recCustLedg.Find('-') then
                repeat
                    recCustLedg.Mark(true);
                until recCustLedg.Next() = 0;
            recCustLedg.SetCurrentKey("Entry No.");
            recCustLedg.SetRange("Closed by Entry No.");
        end;
        recCustLedg.MarkedOnly(true);
    end;

    local procedure FindApplnEntriesDtldtLedgEntry(var recCustLedg: Record "Cust. Ledger Entry"; var CreateCustLedgEntry: Record "Cust. Ledger Entry")
    var
        DtldCustLedgEntry1: Record "Detailed Cust. Ledg. Entry";
        DtldCustLedgEntry2: Record "Detailed Cust. Ledg. Entry";
    begin
        DtldCustLedgEntry1.SetCurrentKey("Cust. Ledger Entry No.");
        DtldCustLedgEntry1.SetRange("Cust. Ledger Entry No.", CreateCustLedgEntry."Entry No.");
        DtldCustLedgEntry1.SetRange(Unapplied, false);
        if DtldCustLedgEntry1.Find('-') then
            repeat
                if DtldCustLedgEntry1."Cust. Ledger Entry No." = DtldCustLedgEntry1."Applied Cust. Ledger Entry No." then begin
                    DtldCustLedgEntry2.Init();
                    DtldCustLedgEntry2.SetCurrentKey("Applied Cust. Ledger Entry No.", "Entry Type");
                    DtldCustLedgEntry2.SetRange("Applied Cust. Ledger Entry No.", DtldCustLedgEntry1."Applied Cust. Ledger Entry No.");
                    DtldCustLedgEntry2.SetRange("Entry Type", DtldCustLedgEntry2."Entry Type"::Application);
                    DtldCustLedgEntry2.SetRange(Unapplied, false);
                    if DtldCustLedgEntry2.Find('-') then
                        repeat
                            if DtldCustLedgEntry2."Cust. Ledger Entry No." <> DtldCustLedgEntry2."Applied Cust. Ledger Entry No." then begin
                                recCustLedg.SetCurrentKey("Entry No.");
                                recCustLedg.SetRange("Entry No.", DtldCustLedgEntry2."Cust. Ledger Entry No.");
                                if recCustLedg.Find('-') then recCustLedg.Mark(true);
                            end;
                        until DtldCustLedgEntry2.Next() = 0;
                end
                else begin
                    recCustLedg.SetCurrentKey("Entry No.");
                    recCustLedg.SetRange("Entry No.", DtldCustLedgEntry1."Applied Cust. Ledger Entry No.");
                    if recCustLedg.Find('-') then recCustLedg.Mark(true);
                end;
            until DtldCustLedgEntry1.Next() = 0;
    end;
}

