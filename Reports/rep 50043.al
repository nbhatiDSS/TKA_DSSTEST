report 70043 "Seats Remaining Notification "
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    ProcessingOnly = true;

    dataset
    {
        dataitem("Event Header"; "Event Header")
        {
            DataItemTableView = SORTING("Resource Manager", "Event Status", "Start Date") WHERE("Event Status" = FILTER(WatchList), "E-Learning" = CONST(false), Delivery = FILTER(Public | Proctor | Virtual | ' '));
            CalcFields = "Confirmed Seats", "Total Seats on Course", "Available Seats", "Provisional Seats";

            trigger OnPreDataItem()
            var
                myInt: Integer;
            begin
                SETFILTER("Start Date", '>%1', TODAY);
                LRM := '';
                Index := 0;
            end;

            trigger OnAfterGetRecord()
            var
                "Email Message": codeunit "Email Message";
                Email: codeunit Email;
            begin

                CALCFIELDS("Confirmed Seats", "Total Seats on Course", "Available Seats", "Provisional Seats");
                IF "Available Seats" <= 3 THEN BEGIN
                    IF LRM <> "Event Header"."Resource Manager" THEN BEGIN
                        IF (Index <> 0) THEN BEGIN
                            //SB-Comment Start
                            // SMTP.AppendBody('</table>');
                            // SMTP.AppendBody('<BR><BR>');
                            // SMTP.AppendBody('Please increase the class size as a matter of urgency.');
                            // SMTP.AppendBody('<BR><BR>');
                            // SMTP.AppendBody('Kind Regards,');
                            // SMTP.AppendBody('<BR><BR>');
                            // SMTP.AppendBody('Dynamics');
                            // SMTP.Send();
                            //SB-Comment End
                            //SB-New code start
                            SMTP.AppendToBody('</table>');
                            SMTP.AppendToBody('<BR><BR>');
                            SMTP.AppendToBody('Please increase the class size as a matter of urgency.');
                            SMTP.AppendToBody('<BR><BR>');
                            SMTP.AppendToBody('Kind Regards,');
                            SMTP.AppendToBody('<BR><BR>');
                            SMTP.AppendToBody('Dynamics');
                            SMTPSend.Send(SMTP, EmailScenario::Default)
                            //SB-New code end
                        END;

                        CLEAR(SMTP);
                        IF RManager.GET("Resource Manager") AND RManager.Scheduler AND (RManager."E-Mail" <> '') THEN
                            ToMailID := RManager."E-Mail"
                        ELSE
                            ToMailID := 'martha.folkes@theknowledgeAcademy.com';

                        //SB-Comment Start    
                        // SMTP.CreateMessage('Dynamics', 'Dynamics@theknowledgeAcademy.com', ToMailID,
                        //                    'Remaining Seat Notification for your Events', '', TRUE);
                        // SMTP.AddCC('Dynamics@theknowledgeacademy.com');
                        //SB-Comment End

                        //SB-New code end
                        //The Email id set in SMTP will automatically become sender email id

                        SMTP.Create(ToMailID, 'Remaining Seat Notification for your Events', '', true);
                        SMTP.AddRecipient(EmailReceipantType::Cc, 'Dynamics@theknowledgeacademy.com');
                        SMTP.addrecipient(1, 'abhishek.aher@theknowledgeacademy.com'); // remove aa
                        //SB-New code end

                        //SMTP.AddCC('Talveer.Sandhu@theknowledgeacademy.com');
                        //SMTP.AddCC('Robyn.Codd@theknowledgeacademy.com');
                        //SMTP.AddCC('martha.folkes@theknowledgeAcademy.com');
                        //SMTP.AddCC('snehanshu.mandal@theknowledgeacademy.com');
                        //SMTP.AddCC('biju.kurup@theknowledgeacademy.com');

                        //SMTP.AppendBody('<b><strong>');
                        //SMTP.AppendBody('This is a test Mail');
                        //SMTP.AppendBody('</b></strong>');
                        //SMTP.AppendBody('<BR><BR>');

                        //SB-New Code start
                        SMTP.AppendToBody('Hello ' + "Resource Manager");
                        SMTP.AppendToBody('<BR><BR>');
                        SMTP.AppendToBody('The following events have 3 or less seats remaining:');
                        SMTP.AppendToBody('<BR><BR>');

                        SMTP.AppendToBody('<table cellspacing="10">' +
                        '<col width="150"><col width="100"><col width="100">' +
                        '<col width="100"><col width="100"><col width="150"><col width="150">' +
                        '<tr><th align="Left">Course</th>' +
                        '<th align="Left">Start Date</th>' +
                        '<th align="Left">Location</th>' +
                        '<th align="Left">Event No.</th>' +
                        '<th align="Left">Total Seats</th>' +
                        '<th align="Left">Confirmed Seats</th>' +
                        '<th align="Left">Provisional Seats</th>' +
                        '<th align="Left">Remaining Seats</th></tr>');
                    END;

                    SMTP.AppendToBody('<tr><td>' + "Course Header" + '</td><td>' + FORMAT("Start Date") + '</td><td>' + "Group Location Code" + '</td>' +
                    '<td>' + "No." + '</td><td>' + FORMAT("Total Seats on Course") + '</td><td>' + FORMAT("Confirmed Seats") + '</td>' +
                    '<td>' + FORMAT("Provisional Seats") + '</td>' +
                    '<td>' + FORMAT("Available Seats") + '</td></tr>');
                    //SB-New Code end

                    Index += 1;
                    LRM := "Event Header"."Resource Manager";
                END;


            end;

            trigger OnPostDataItem()
            var
                myInt: Integer;
            begin
                //SB-New code start
                SMTP.AppendToBody('</table>');
                SMTP.AppendToBody('<BR><BR>');
                SMTP.AppendToBody('Please increase the class size as a matter of urgency.');
                SMTP.AppendToBody('<BR><BR>');
                SMTP.AppendToBody('Kind Regards,');
                SMTP.AppendToBody('<BR><BR>');
                SMTP.AppendToBody('Dynamics');
                // SMTPSend.Send(SMTP);
                //SB-New code end
                //SB-code commented
                //  SMTP.AppendBody('</table>');
                //     SMTP.AppendBody('<BR><BR>');
                //     SMTP.AppendBody('Please increase the class size as a matter of urgency.');
                //     SMTP.AppendBody('<BR><BR>');
                //     SMTP.AppendBody('Kind Regards,');
                //     SMTP.AppendBody('<BR><BR>');
                //     SMTP.AppendBody('Dynamics');
                //     SMTPSend();
                //SB-Code commented end
            end;
        }


    }

    trigger OnPreReport()
    var
        myInt: Integer;
    begin

        //Auto cuntry wise Revenue report
        Time1 := 110000T;
        IF TIME < Time1 THEN BEGIN
            RevenueSalesUKMonth;
            RevenueSalesEUMonth;
            RevenueSalesEmail;
            UserWiseCountSales;// 30.03.22
            Account5780VATReportDataAUS;

            UniqueTrainer;
            TotalEvents;
        END;
        //Auto cuntry wise Revenue report

    end;



    var

        LRM: Code[20];
        Index: Integer;
        ToMailID: Text[100];
        RManager: Record "Salesperson/Purchaser";
        Curexch: Record "Currency Exchange Rate";
        CF: Decimal;

        Time1: Time;
        Company1: Record Company;
        EventWeek1: Record "Event Week";
        MonthName: Text[30];
        //"Email Message": codeunit "Email Message";
        //Email: codeunit Email;
        //SB-Start comment
        // SMTP: Codeunit "SMTP Mail";
        // SMTPSetup: Record "SMTP Mail Setup";
        SMTP: Codeunit "Email Message";
        SMTPMail: Codeunit "Email Message";
        SMTPSend: Codeunit Email;
        EmailReceipantType: Enum "Email Recipient Type";
        EmailScenario: Enum "Email Scenario";





    procedure RevenueSalesUKMonth()
    var
        GLEntry: Record "G/L Entry";
        CountryRegion: Record "Country/Region";
        GLSetup: Record "General Ledger Setup";
        FromDate: Date;
        ToDate: Date;
        Amount1: Decimal;
        Company1: Record Company;
        RecordFound1: Boolean;
        BlankCountryAmt: Decimal;
        FASetup: Record "FA Setup";
        FirstDate: Date;
        LastDate: Date;
        NewYearDate: Date;
        "Email Message": codeunit "Email Message";
        Email: codeunit Email;

    begin
        GLSetup.GET;

        Company1.SETFILTER(Company1.Name, '%1', 'The Knowledge Academy Limited');
        IF Company1.FIND('-') THEN
            REPEAT

                CountryRegion.CHANGECOMPANY(Company1.Name);

                CLEAR(GLEntry);

                CountryRegion.SETFILTER(CountryRegion.Code, '<>%1', 'AA');//GLEntry."Cust Country Code");//<>%1','aa');
                IF CountryRegion.FIND('-') THEN
                    REPEAT
                        CountryRegion.CountryWiseAmount := 0;
                        CountryRegion.JanCountryAmount := 0;
                        CountryRegion.FebCountryAmount := 0;
                        CountryRegion.MarCountryAmount := 0;
                        CountryRegion.AprCountryAmount := 0;
                        CountryRegion.MayCountryAmount := 0;
                        CountryRegion.JunCountryAmount := 0;
                        CountryRegion.JulCountryAmount := 0;
                        CountryRegion.AugCountryAmount := 0;
                        CountryRegion.SepCountryAmount := 0;
                        CountryRegion.OctCountryAmount := 0;
                        CountryRegion.NovCountryAmount := 0;
                        CountryRegion.DecCountryAmount := 0;

                        CountryRegion.MODIFY;
                    UNTIL CountryRegion.NEXT = 0;

                GLEntry.CHANGECOMPANY(Company1.Name);
                CountryRegion.CHANGECOMPANY(Company1.Name);

                GLSetup.GET;
                FromDate := GLSetup."Financial Year Start Date";
                ToDate := GLSetup."Financial Year End Date";

                //APR START
                FirstDate := GLSetup."Financial Year Start Date";//CALCDATE('-CM',TODAY);
                LastDate := CALCDATE('CM', FirstDate);

                BlankCountryAmt := 0;
                GLEntry.SETCURRENTKEY("Posting Date", "G/L Account No.");
                GLEntry.SETFILTER("Posting Date", '%1..%2', FirstDate, LastDate);
                GLEntry.SETFILTER("G/L Account No.", '%1..%2', '6000', '6999');
                IF GLEntry.FIND('-') THEN
                    REPEAT
                        IF ((GLEntry."G/L Account No." <> '6710') AND (GLEntry."G/L Account No." <> '6720')) THEN BEGIN
                            GLEntry.CALCFIELDS("Cust Country Code");

                            CLEAR(CountryRegion);

                            IF GLEntry."Cust Country Code" <> '' THEN BEGIN
                                CountryRegion.SETFILTER(CountryRegion.Code, '%1', GLEntry."Cust Country Code");//<>%1','aa');
                                IF CountryRegion.FIND('-') THEN BEGIN
                                    CountryRegion.AprCountryAmount := CountryRegion.AprCountryAmount + GLEntry.Amount;
                                    CountryRegion.MODIFY;
                                END;
                            END;

                            IF GLEntry."Cust Country Code" = '' THEN BEGIN
                                BlankCountryAmt := BlankCountryAmt + GLEntry.Amount;
                            END;
                        END;

                    UNTIL GLEntry.NEXT = 0;
                //UNTIL Company1.NEXT=0;

                //MAY START
                FirstDate := CALCDATE('-CM+1M', FirstDate);
                LastDate := CALCDATE('CM', FirstDate);

                BlankCountryAmt := 0;
                GLEntry.SETCURRENTKEY("Posting Date", "G/L Account No.");
                GLEntry.SETFILTER("Posting Date", '%1..%2', FirstDate, LastDate);
                GLEntry.SETFILTER("G/L Account No.", '%1..%2', '6000', '6999');
                IF GLEntry.FIND('-') THEN
                    REPEAT
                        IF ((GLEntry."G/L Account No." <> '6710') AND (GLEntry."G/L Account No." <> '6720')) THEN BEGIN
                            GLEntry.CALCFIELDS("Cust Country Code");

                            CLEAR(CountryRegion);

                            IF GLEntry."Cust Country Code" <> '' THEN BEGIN
                                CountryRegion.SETFILTER(CountryRegion.Code, '%1', GLEntry."Cust Country Code");//<>%1','aa');
                                IF CountryRegion.FIND('-') THEN BEGIN
                                    CountryRegion.MayCountryAmount := CountryRegion.MayCountryAmount + GLEntry.Amount;
                                    CountryRegion.MODIFY;
                                END;
                            END;

                            IF GLEntry."Cust Country Code" = '' THEN BEGIN
                                BlankCountryAmt := BlankCountryAmt + GLEntry.Amount;
                            END;
                        END;

                    UNTIL GLEntry.NEXT = 0;
                // UNTIL Company1.NEXT=0;

                //JUN START
                FirstDate := CALCDATE('-CM+1M', FirstDate);
                LastDate := CALCDATE('CM', FirstDate);

                BlankCountryAmt := 0;
                GLEntry.SETCURRENTKEY("Posting Date", "G/L Account No.");
                GLEntry.SETFILTER("Posting Date", '%1..%2', FirstDate, LastDate);
                GLEntry.SETFILTER("G/L Account No.", '%1..%2', '6000', '6999');
                IF GLEntry.FIND('-') THEN
                    REPEAT
                        IF ((GLEntry."G/L Account No." <> '6710') AND (GLEntry."G/L Account No." <> '6720')) THEN BEGIN
                            GLEntry.CALCFIELDS("Cust Country Code");

                            CLEAR(CountryRegion);

                            IF GLEntry."Cust Country Code" <> '' THEN BEGIN
                                CountryRegion.SETFILTER(CountryRegion.Code, '%1', GLEntry."Cust Country Code");//<>%1','aa');
                                IF CountryRegion.FIND('-') THEN BEGIN
                                    CountryRegion.JunCountryAmount := CountryRegion.JunCountryAmount + GLEntry.Amount;
                                    CountryRegion.MODIFY;
                                END;
                            END;

                            IF GLEntry."Cust Country Code" = '' THEN BEGIN
                                BlankCountryAmt := BlankCountryAmt + GLEntry.Amount;
                            END;
                        END;

                    UNTIL GLEntry.NEXT = 0;
                //UNTIL Company1.NEXT=0;

                //JUL START
                FirstDate := CALCDATE('-CM+1M', FirstDate);
                LastDate := CALCDATE('CM', FirstDate);

                BlankCountryAmt := 0;
                GLEntry.SETCURRENTKEY("Posting Date", "G/L Account No.");
                GLEntry.SETFILTER("Posting Date", '%1..%2', FirstDate, LastDate);
                GLEntry.SETFILTER("G/L Account No.", '%1..%2', '6000', '6999');
                IF GLEntry.FIND('-') THEN
                    REPEAT
                        IF ((GLEntry."G/L Account No." <> '6710') AND (GLEntry."G/L Account No." <> '6720')) THEN BEGIN
                            GLEntry.CALCFIELDS("Cust Country Code");

                            CLEAR(CountryRegion);

                            IF GLEntry."Cust Country Code" <> '' THEN BEGIN
                                CountryRegion.SETFILTER(CountryRegion.Code, '%1', GLEntry."Cust Country Code");//<>%1','aa');
                                IF CountryRegion.FIND('-') THEN BEGIN
                                    CountryRegion.JulCountryAmount := CountryRegion.JulCountryAmount + GLEntry.Amount;
                                    CountryRegion.MODIFY;
                                END;
                            END;

                            IF GLEntry."Cust Country Code" = '' THEN BEGIN
                                BlankCountryAmt := BlankCountryAmt + GLEntry.Amount;
                            END;
                        END;

                    UNTIL GLEntry.NEXT = 0;
                //UNTIL Company1.NEXT=0;

                //AUG START
                FirstDate := CALCDATE('-CM+1M', FirstDate);
                LastDate := CALCDATE('CM', FirstDate);

                BlankCountryAmt := 0;
                GLEntry.SETCURRENTKEY("Posting Date", "G/L Account No.");
                GLEntry.SETFILTER("Posting Date", '%1..%2', FirstDate, LastDate);
                GLEntry.SETFILTER("G/L Account No.", '%1..%2', '6000', '6999');
                IF GLEntry.FIND('-') THEN
                    REPEAT
                        IF ((GLEntry."G/L Account No." <> '6710') AND (GLEntry."G/L Account No." <> '6720')) THEN BEGIN
                            GLEntry.CALCFIELDS("Cust Country Code");

                            CLEAR(CountryRegion);

                            IF GLEntry."Cust Country Code" <> '' THEN BEGIN
                                CountryRegion.SETFILTER(CountryRegion.Code, '%1', GLEntry."Cust Country Code");//<>%1','aa');
                                IF CountryRegion.FIND('-') THEN BEGIN
                                    CountryRegion.AugCountryAmount := CountryRegion.AugCountryAmount + GLEntry.Amount;
                                    CountryRegion.MODIFY;
                                END;
                            END;

                            IF GLEntry."Cust Country Code" = '' THEN BEGIN
                                BlankCountryAmt := BlankCountryAmt + GLEntry.Amount;
                            END;
                        END;

                    UNTIL GLEntry.NEXT = 0;
                //UNTIL Company1.NEXT=0;


                //SEP START
                FirstDate := CALCDATE('-CM+1M', FirstDate);
                LastDate := CALCDATE('CM', FirstDate);

                BlankCountryAmt := 0;
                GLEntry.SETCURRENTKEY("Posting Date", "G/L Account No.");
                GLEntry.SETFILTER("Posting Date", '%1..%2', FirstDate, LastDate);
                GLEntry.SETFILTER("G/L Account No.", '%1..%2', '6000', '6999');
                IF GLEntry.FIND('-') THEN
                    REPEAT
                        IF ((GLEntry."G/L Account No." <> '6710') AND (GLEntry."G/L Account No." <> '6720')) THEN BEGIN
                            GLEntry.CALCFIELDS("Cust Country Code");

                            CLEAR(CountryRegion);

                            IF GLEntry."Cust Country Code" <> '' THEN BEGIN
                                CountryRegion.SETFILTER(CountryRegion.Code, '%1', GLEntry."Cust Country Code");//<>%1','aa');
                                IF CountryRegion.FIND('-') THEN BEGIN
                                    CountryRegion.SepCountryAmount := CountryRegion.SepCountryAmount + GLEntry.Amount;
                                    CountryRegion.MODIFY;
                                END;
                            END;

                            IF GLEntry."Cust Country Code" = '' THEN BEGIN
                                BlankCountryAmt := BlankCountryAmt + GLEntry.Amount;
                            END;
                        END;

                    UNTIL GLEntry.NEXT = 0;
                //UNTIL Company1.NEXT=0;

                //OCT START
                FirstDate := CALCDATE('-CM+1M', FirstDate);
                LastDate := CALCDATE('CM', FirstDate);

                BlankCountryAmt := 0;
                GLEntry.SETCURRENTKEY("Posting Date", "G/L Account No.");
                GLEntry.SETFILTER("Posting Date", '%1..%2', FirstDate, LastDate);
                GLEntry.SETFILTER("G/L Account No.", '%1..%2', '6000', '6999');
                IF GLEntry.FIND('-') THEN
                    REPEAT
                        IF ((GLEntry."G/L Account No." <> '6710') AND (GLEntry."G/L Account No." <> '6720')) THEN BEGIN
                            GLEntry.CALCFIELDS("Cust Country Code");

                            CLEAR(CountryRegion);

                            IF GLEntry."Cust Country Code" <> '' THEN BEGIN
                                CountryRegion.SETFILTER(CountryRegion.Code, '%1', GLEntry."Cust Country Code");//<>%1','aa');
                                IF CountryRegion.FIND('-') THEN BEGIN
                                    CountryRegion.OctCountryAmount := CountryRegion.OctCountryAmount + GLEntry.Amount;
                                    CountryRegion.MODIFY;
                                END;
                            END;

                            IF GLEntry."Cust Country Code" = '' THEN BEGIN
                                BlankCountryAmt := BlankCountryAmt + GLEntry.Amount;
                            END;
                        END;

                    UNTIL GLEntry.NEXT = 0;
                //UNTIL Company1.NEXT=0;


                //NOV START
                FirstDate := CALCDATE('-CM+1M', FirstDate);
                LastDate := CALCDATE('CM', FirstDate);

                BlankCountryAmt := 0;
                GLEntry.SETCURRENTKEY("Posting Date", "G/L Account No.");
                GLEntry.SETFILTER("Posting Date", '%1..%2', FirstDate, LastDate);
                GLEntry.SETFILTER("G/L Account No.", '%1..%2', '6000', '6999');
                IF GLEntry.FIND('-') THEN
                    REPEAT
                        IF ((GLEntry."G/L Account No." <> '6710') AND (GLEntry."G/L Account No." <> '6720')) THEN BEGIN
                            GLEntry.CALCFIELDS("Cust Country Code");

                            CLEAR(CountryRegion);

                            IF GLEntry."Cust Country Code" <> '' THEN BEGIN
                                CountryRegion.SETFILTER(CountryRegion.Code, '%1', GLEntry."Cust Country Code");//<>%1','aa');
                                IF CountryRegion.FIND('-') THEN BEGIN
                                    CountryRegion.NovCountryAmount := CountryRegion.NovCountryAmount + GLEntry.Amount;
                                    CountryRegion.MODIFY;
                                END;
                            END;

                            IF GLEntry."Cust Country Code" = '' THEN BEGIN
                                BlankCountryAmt := BlankCountryAmt + GLEntry.Amount;
                            END;
                        END;

                    UNTIL GLEntry.NEXT = 0;
                //UNTIL Company1.NEXT=0;

                //DEC START
                FirstDate := CALCDATE('-CM+1M', FirstDate);
                LastDate := CALCDATE('CM', FirstDate);

                BlankCountryAmt := 0;
                GLEntry.SETCURRENTKEY("Posting Date", "G/L Account No.");
                GLEntry.SETFILTER("Posting Date", '%1..%2', FirstDate, LastDate);
                GLEntry.SETFILTER("G/L Account No.", '%1..%2', '6000', '6999');
                IF GLEntry.FIND('-') THEN
                    REPEAT
                        IF ((GLEntry."G/L Account No." <> '6710') AND (GLEntry."G/L Account No." <> '6720')) THEN BEGIN
                            GLEntry.CALCFIELDS("Cust Country Code");

                            CLEAR(CountryRegion);

                            IF GLEntry."Cust Country Code" <> '' THEN BEGIN
                                CountryRegion.SETFILTER(CountryRegion.Code, '%1', GLEntry."Cust Country Code");//<>%1','aa');
                                IF CountryRegion.FIND('-') THEN BEGIN
                                    CountryRegion.DecCountryAmount := CountryRegion.DecCountryAmount + GLEntry.Amount;
                                    CountryRegion.MODIFY;
                                END;
                            END;

                            IF GLEntry."Cust Country Code" = '' THEN BEGIN
                                BlankCountryAmt := BlankCountryAmt + GLEntry.Amount;
                            END;
                        END;

                    UNTIL GLEntry.NEXT = 0;
                //UNTIL Company1.NEXT=0;


                //JAN START
                FirstDate := CALCDATE('-CM+1M', FirstDate);
                LastDate := CALCDATE('CM', FirstDate);

                BlankCountryAmt := 0;
                GLEntry.SETCURRENTKEY("Posting Date", "G/L Account No.");
                GLEntry.SETFILTER("Posting Date", '%1..%2', FirstDate, LastDate);
                GLEntry.SETFILTER("G/L Account No.", '%1..%2', '6000', '6999');
                IF GLEntry.FIND('-') THEN
                    REPEAT
                        IF ((GLEntry."G/L Account No." <> '6710') AND (GLEntry."G/L Account No." <> '6720')) THEN BEGIN
                            GLEntry.CALCFIELDS("Cust Country Code");

                            CLEAR(CountryRegion);

                            IF GLEntry."Cust Country Code" <> '' THEN BEGIN
                                CountryRegion.SETFILTER(CountryRegion.Code, '%1', GLEntry."Cust Country Code");//<>%1','aa');
                                IF CountryRegion.FIND('-') THEN BEGIN
                                    CountryRegion.JanCountryAmount := CountryRegion.JanCountryAmount + GLEntry.Amount;
                                    CountryRegion.MODIFY;
                                END;
                            END;

                            IF GLEntry."Cust Country Code" = '' THEN BEGIN
                                BlankCountryAmt := BlankCountryAmt + GLEntry.Amount;
                            END;
                        END;

                    UNTIL GLEntry.NEXT = 0;
                //UNTIL Company1.NEXT=0;


                //FEB START
                FirstDate := CALCDATE('-CM+1M', FirstDate);
                LastDate := CALCDATE('CM', FirstDate);

                BlankCountryAmt := 0;
                GLEntry.SETCURRENTKEY("Posting Date", "G/L Account No.");
                GLEntry.SETFILTER("Posting Date", '%1..%2', FirstDate, LastDate);
                GLEntry.SETFILTER("G/L Account No.", '%1..%2', '6000', '6999');
                IF GLEntry.FIND('-') THEN
                    REPEAT
                        IF ((GLEntry."G/L Account No." <> '6710') AND (GLEntry."G/L Account No." <> '6720')) THEN BEGIN
                            GLEntry.CALCFIELDS("Cust Country Code");

                            CLEAR(CountryRegion);

                            IF GLEntry."Cust Country Code" <> '' THEN BEGIN
                                CountryRegion.SETFILTER(CountryRegion.Code, '%1', GLEntry."Cust Country Code");//<>%1','aa');
                                IF CountryRegion.FIND('-') THEN BEGIN
                                    CountryRegion.FebCountryAmount := CountryRegion.FebCountryAmount + GLEntry.Amount;
                                    CountryRegion.MODIFY;
                                END;
                            END;

                            IF GLEntry."Cust Country Code" = '' THEN BEGIN
                                BlankCountryAmt := BlankCountryAmt + GLEntry.Amount;
                            END;
                        END;

                    UNTIL GLEntry.NEXT = 0;
                //UNTIL Company1.NEXT=0;

                //MAR START
                FirstDate := CALCDATE('-CM+1M', FirstDate);
                LastDate := CALCDATE('CM', FirstDate);
                BlankCountryAmt := 0;
                GLEntry.SETCURRENTKEY("Posting Date", "G/L Account No.");
                GLEntry.SETFILTER("Posting Date", '%1..%2', FirstDate, LastDate);
                GLEntry.SETFILTER("G/L Account No.", '%1..%2', '6000', '6999');
                IF GLEntry.FIND('-') THEN
                    REPEAT
                        IF ((GLEntry."G/L Account No." <> '6710') AND (GLEntry."G/L Account No." <> '6720')) THEN BEGIN
                            GLEntry.CALCFIELDS("Cust Country Code");

                            CLEAR(CountryRegion);

                            IF GLEntry."Cust Country Code" <> '' THEN BEGIN
                                CountryRegion.SETFILTER(CountryRegion.Code, '%1', GLEntry."Cust Country Code");//<>%1','aa');
                                IF CountryRegion.FIND('-') THEN BEGIN
                                    CountryRegion.MarCountryAmount := CountryRegion.MarCountryAmount + GLEntry.Amount;
                                    CountryRegion.MODIFY;
                                END;
                            END;

                            IF GLEntry."Cust Country Code" = '' THEN BEGIN
                                BlankCountryAmt := BlankCountryAmt + GLEntry.Amount;
                            END;
                        END;

                    UNTIL GLEntry.NEXT = 0;
            UNTIL Company1.NEXT = 0;

        CountryRegion.SETFILTER(CountryRegion.Code, '<>%1', 'AA');//GLEntry."Cust Country Code");//<>%1','aa');
        IF CountryRegion.FIND('-') THEN
            REPEAT
                CountryRegion.CountryWiseAmount := CountryRegion.JanCountryAmount +
                CountryRegion.FebCountryAmount +
                CountryRegion.MarCountryAmount +
                CountryRegion.AprCountryAmount +
                CountryRegion.MayCountryAmount +
                CountryRegion.JunCountryAmount +
                CountryRegion.JulCountryAmount +
                CountryRegion.AugCountryAmount +
                CountryRegion.SepCountryAmount +
                CountryRegion.OctCountryAmount +
                CountryRegion.NovCountryAmount +
                CountryRegion.DecCountryAmount;

                CountryRegion.MODIFY;
            UNTIL CountryRegion.NEXT = 0;
    end;

    procedure RevenueSalesEUMonth()
    var
        GLEntry: Record "G/L Entry";
        CountryRegion: Record "Country/Region";
        GLSetup: Record "General Ledger Setup";
        FromDate: Date;
        ToDate: Date;
        Amount1: Decimal;
        Company1: Record Company;
        RecordFound1: Boolean;
        BlankCountryAmt: Decimal;
        FASetup: Record "FA Setup";
        FirstDate: Date;
        LastDate: Date;
        NewYearDate: Date;
        GBPAmount: Decimal;

    begin

        GLSetup.GET;
        Company1.SETFILTER(Company1.Name, '%1', 'TKA Europe');
        IF Company1.FIND('-') THEN
            REPEAT

                //Convert in GBP
                CLEAR(Curexch);
                Curexch.RESET;
                CF := 0;
                GBPAmount := 0;

                Curexch.CHANGECOMPANY('TKA Europe');
                Curexch.SETRANGE("Currency Code", 'GBP');
                Curexch.SETFILTER("Starting Date", '..%1', TODAY);
                IF Curexch.FINDLAST THEN
                    CF := Curexch."Relational Exch. Rate Amount" / Curexch."Exchange Rate Amount";
                IF CF = 0 THEN
                    CF := 1;

                CountryRegion.CHANGECOMPANY(Company1.Name);

                CLEAR(GLEntry);

                CountryRegion.SETFILTER(CountryRegion.Code, '<>%1', 'aa');//GLEntry."Cust Country Code");//<>%1','aa');
                IF CountryRegion.FIND('-') THEN
                    REPEAT
                        CountryRegion.CountryWiseAmount := 0;
                        CountryRegion.JanCountryAmount := 0;
                        CountryRegion.FebCountryAmount := 0;
                        CountryRegion.MarCountryAmount := 0;
                        CountryRegion.AprCountryAmount := 0;
                        CountryRegion.MayCountryAmount := 0;
                        CountryRegion.JunCountryAmount := 0;
                        CountryRegion.JulCountryAmount := 0;
                        CountryRegion.AugCountryAmount := 0;
                        CountryRegion.SepCountryAmount := 0;
                        CountryRegion.OctCountryAmount := 0;
                        CountryRegion.NovCountryAmount := 0;
                        CountryRegion.DecCountryAmount := 0;

                        CountryRegion.MODIFY;
                    UNTIL CountryRegion.NEXT = 0;

                GLEntry.CHANGECOMPANY(Company1.Name);
                CountryRegion.CHANGECOMPANY(Company1.Name);

                GLSetup.GET;
                FromDate := GLSetup."Financial Year Start Date";
                ToDate := GLSetup."Financial Year End Date";

                //APR START
                FirstDate := GLSetup."Financial Year Start Date";//CALCDATE('-CM',TODAY);
                LastDate := CALCDATE('CM', FirstDate);

                BlankCountryAmt := 0;
                GLEntry.SETCURRENTKEY("Posting Date", "G/L Account No.");
                GLEntry.SETFILTER("Posting Date", '%1..%2', FirstDate, LastDate);
                GLEntry.SETFILTER("G/L Account No.", '%1..%2', '6000', '6999');
                IF GLEntry.FIND('-') THEN
                    REPEAT
                        IF ((GLEntry."G/L Account No." <> '6710') AND (GLEntry."G/L Account No." <> '6720')) THEN BEGIN
                            GLEntry.CALCFIELDS("Cust Country Code");

                            //CLEAR(CountryRegion);

                            IF GLEntry."Cust Country Code" <> '' THEN BEGIN
                                CountryRegion.SETFILTER(CountryRegion.Code, '%1', GLEntry."Cust Country Code");//<>%1','aa');
                                IF CountryRegion.FIND('-') THEN BEGIN
                                    GBPAmount := GLEntry.Amount / CF;

                                    CountryRegion.AprCountryAmount := CountryRegion.AprCountryAmount + GBPAmount;
                                    CountryRegion.MODIFY;
                                END;
                            END;

                            IF GLEntry."Cust Country Code" = '' THEN BEGIN
                                BlankCountryAmt := BlankCountryAmt + GLEntry.Amount;
                            END;
                        END;

                    UNTIL GLEntry.NEXT = 0;
                //UNTIL Company1.NEXT=0;

                //MAY START
                FirstDate := CALCDATE('-CM+1M', FirstDate);
                LastDate := CALCDATE('CM', FirstDate);

                BlankCountryAmt := 0;
                GLEntry.SETCURRENTKEY("Posting Date", "G/L Account No.");
                GLEntry.SETFILTER("Posting Date", '%1..%2', FirstDate, LastDate);
                GLEntry.SETFILTER("G/L Account No.", '%1..%2', '6000', '6999');
                IF GLEntry.FIND('-') THEN
                    REPEAT
                        IF ((GLEntry."G/L Account No." <> '6710') AND (GLEntry."G/L Account No." <> '6720')) THEN BEGIN
                            GLEntry.CALCFIELDS("Cust Country Code");

                            //CLEAR(CountryRegion);

                            IF GLEntry."Cust Country Code" <> '' THEN BEGIN
                                CountryRegion.SETFILTER(CountryRegion.Code, '%1', GLEntry."Cust Country Code");//<>%1','aa');
                                IF CountryRegion.FIND('-') THEN BEGIN
                                    GBPAmount := GLEntry.Amount / CF;
                                    CountryRegion.MayCountryAmount := CountryRegion.MayCountryAmount + GBPAmount;
                                    CountryRegion.MODIFY;
                                END;
                            END;

                            IF GLEntry."Cust Country Code" = '' THEN BEGIN
                                BlankCountryAmt := BlankCountryAmt + GLEntry.Amount;
                            END;
                        END;

                    UNTIL GLEntry.NEXT = 0;
                // UNTIL Company1.NEXT=0;

                //JUN START
                FirstDate := CALCDATE('-CM+1M', FirstDate);
                LastDate := CALCDATE('CM', FirstDate);

                BlankCountryAmt := 0;
                GLEntry.SETCURRENTKEY("Posting Date", "G/L Account No.");
                GLEntry.SETFILTER("Posting Date", '%1..%2', FirstDate, LastDate);
                GLEntry.SETFILTER("G/L Account No.", '%1..%2', '6000', '6999');
                IF GLEntry.FIND('-') THEN
                    REPEAT
                        IF ((GLEntry."G/L Account No." <> '6710') AND (GLEntry."G/L Account No." <> '6720')) THEN BEGIN
                            GLEntry.CALCFIELDS("Cust Country Code");

                            //CLEAR(CountryRegion);

                            IF GLEntry."Cust Country Code" <> '' THEN BEGIN
                                CountryRegion.SETFILTER(CountryRegion.Code, '%1', GLEntry."Cust Country Code");//<>%1','aa');
                                IF CountryRegion.FIND('-') THEN BEGIN
                                    GBPAmount := GLEntry.Amount / CF;
                                    CountryRegion.JunCountryAmount := CountryRegion.JunCountryAmount + GBPAmount;
                                    CountryRegion.MODIFY;
                                END;
                            END;

                            IF GLEntry."Cust Country Code" = '' THEN BEGIN
                                BlankCountryAmt := BlankCountryAmt + GLEntry.Amount;
                            END;
                        END;

                    UNTIL GLEntry.NEXT = 0;
                //UNTIL Company1.NEXT=0;

                //JUL START
                FirstDate := CALCDATE('-CM+1M', FirstDate);
                LastDate := CALCDATE('CM', FirstDate);

                BlankCountryAmt := 0;
                GLEntry.SETCURRENTKEY("Posting Date", "G/L Account No.");
                GLEntry.SETFILTER("Posting Date", '%1..%2', FirstDate, LastDate);
                GLEntry.SETFILTER("G/L Account No.", '%1..%2', '6000', '6999');
                IF GLEntry.FIND('-') THEN
                    REPEAT
                        IF ((GLEntry."G/L Account No." <> '6710') AND (GLEntry."G/L Account No." <> '6720')) THEN BEGIN
                            GLEntry.CALCFIELDS("Cust Country Code");

                            //CLEAR(CountryRegion);

                            IF GLEntry."Cust Country Code" <> '' THEN BEGIN
                                CountryRegion.SETFILTER(CountryRegion.Code, '%1', GLEntry."Cust Country Code");//<>%1','aa');
                                IF CountryRegion.FIND('-') THEN BEGIN
                                    GBPAmount := GLEntry.Amount / CF;
                                    CountryRegion.JulCountryAmount := CountryRegion.JulCountryAmount + GBPAmount;
                                    CountryRegion.MODIFY;
                                END;
                            END;

                            IF GLEntry."Cust Country Code" = '' THEN BEGIN
                                BlankCountryAmt := BlankCountryAmt + GLEntry.Amount;
                            END;
                        END;

                    UNTIL GLEntry.NEXT = 0;
                //UNTIL Company1.NEXT=0;

                //AUG START
                FirstDate := CALCDATE('-CM+1M', FirstDate);
                LastDate := CALCDATE('CM', FirstDate);

                BlankCountryAmt := 0;
                GLEntry.SETCURRENTKEY("Posting Date", "G/L Account No.");
                GLEntry.SETFILTER("Posting Date", '%1..%2', FirstDate, LastDate);
                GLEntry.SETFILTER("G/L Account No.", '%1..%2', '6000', '6999');
                IF GLEntry.FIND('-') THEN
                    REPEAT
                        IF ((GLEntry."G/L Account No." <> '6710') AND (GLEntry."G/L Account No." <> '6720')) THEN BEGIN
                            GLEntry.CALCFIELDS("Cust Country Code");

                            //CLEAR(CountryRegion);

                            IF GLEntry."Cust Country Code" <> '' THEN BEGIN
                                CountryRegion.SETFILTER(CountryRegion.Code, '%1', GLEntry."Cust Country Code");//<>%1','aa');
                                IF CountryRegion.FIND('-') THEN BEGIN
                                    GBPAmount := GLEntry.Amount / CF;
                                    CountryRegion.AugCountryAmount := CountryRegion.AugCountryAmount + GBPAmount;
                                    CountryRegion.MODIFY;
                                END;
                            END;

                            IF GLEntry."Cust Country Code" = '' THEN BEGIN
                                BlankCountryAmt := BlankCountryAmt + GLEntry.Amount;
                            END;
                        END;

                    UNTIL GLEntry.NEXT = 0;
                //UNTIL Company1.NEXT=0;


                //SEP START
                FirstDate := CALCDATE('-CM+1M', FirstDate);
                LastDate := CALCDATE('CM', FirstDate);

                BlankCountryAmt := 0;
                GLEntry.SETCURRENTKEY("Posting Date", "G/L Account No.");
                GLEntry.SETFILTER("Posting Date", '%1..%2', FirstDate, LastDate);
                GLEntry.SETFILTER("G/L Account No.", '%1..%2', '6000', '6999');
                IF GLEntry.FIND('-') THEN
                    REPEAT
                        IF ((GLEntry."G/L Account No." <> '6710') AND (GLEntry."G/L Account No." <> '6720')) THEN BEGIN
                            GLEntry.CALCFIELDS("Cust Country Code");

                            //CLEAR(CountryRegion);

                            IF GLEntry."Cust Country Code" <> '' THEN BEGIN
                                CountryRegion.SETFILTER(CountryRegion.Code, '%1', GLEntry."Cust Country Code");//<>%1','aa');
                                IF CountryRegion.FIND('-') THEN BEGIN
                                    GBPAmount := GLEntry.Amount / CF;
                                    CountryRegion.SepCountryAmount := CountryRegion.SepCountryAmount + GBPAmount;
                                    CountryRegion.MODIFY;
                                END;
                            END;

                            IF GLEntry."Cust Country Code" = '' THEN BEGIN
                                BlankCountryAmt := BlankCountryAmt + GLEntry.Amount;
                            END;
                        END;

                    UNTIL GLEntry.NEXT = 0;
                //UNTIL Company1.NEXT=0;

                //OCT START
                FirstDate := CALCDATE('-CM+1M', FirstDate);
                LastDate := CALCDATE('CM', FirstDate);

                BlankCountryAmt := 0;
                GLEntry.SETCURRENTKEY("Posting Date", "G/L Account No.");
                GLEntry.SETFILTER("Posting Date", '%1..%2', FirstDate, LastDate);
                GLEntry.SETFILTER("G/L Account No.", '%1..%2', '6000', '6999');
                IF GLEntry.FIND('-') THEN
                    REPEAT
                        IF ((GLEntry."G/L Account No." <> '6710') AND (GLEntry."G/L Account No." <> '6720')) THEN BEGIN
                            GLEntry.CALCFIELDS("Cust Country Code");

                            //CLEAR(CountryRegion);

                            IF GLEntry."Cust Country Code" <> '' THEN BEGIN
                                CountryRegion.SETFILTER(CountryRegion.Code, '%1', GLEntry."Cust Country Code");//<>%1','aa');
                                IF CountryRegion.FIND('-') THEN BEGIN
                                    GBPAmount := GLEntry.Amount / CF;
                                    CountryRegion.OctCountryAmount := CountryRegion.OctCountryAmount + GBPAmount;
                                    CountryRegion.MODIFY;
                                END;
                            END;

                            IF GLEntry."Cust Country Code" = '' THEN BEGIN
                                BlankCountryAmt := BlankCountryAmt + GLEntry.Amount;
                            END;
                        END;

                    UNTIL GLEntry.NEXT = 0;
                //UNTIL Company1.NEXT=0;


                //NOV START
                FirstDate := CALCDATE('-CM+1M', FirstDate);
                LastDate := CALCDATE('CM', FirstDate);

                BlankCountryAmt := 0;
                GLEntry.SETCURRENTKEY("Posting Date", "G/L Account No.");
                GLEntry.SETFILTER("Posting Date", '%1..%2', FirstDate, LastDate);
                GLEntry.SETFILTER("G/L Account No.", '%1..%2', '6000', '6999');
                IF GLEntry.FIND('-') THEN
                    REPEAT
                        IF ((GLEntry."G/L Account No." <> '6710') AND (GLEntry."G/L Account No." <> '6720')) THEN BEGIN
                            GLEntry.CALCFIELDS("Cust Country Code");

                            //CLEAR(CountryRegion);

                            IF GLEntry."Cust Country Code" <> '' THEN BEGIN
                                CountryRegion.SETFILTER(CountryRegion.Code, '%1', GLEntry."Cust Country Code");//<>%1','aa');
                                IF CountryRegion.FIND('-') THEN BEGIN
                                    GBPAmount := GLEntry.Amount / CF;
                                    CountryRegion.NovCountryAmount := CountryRegion.NovCountryAmount + GBPAmount;
                                    CountryRegion.MODIFY;
                                END;
                            END;

                            IF GLEntry."Cust Country Code" = '' THEN BEGIN
                                BlankCountryAmt := BlankCountryAmt + GLEntry.Amount;
                            END;
                        END;

                    UNTIL GLEntry.NEXT = 0;
                //UNTIL Company1.NEXT=0;

                //DEC START
                FirstDate := CALCDATE('-CM+1M', FirstDate);
                LastDate := CALCDATE('CM', FirstDate);

                BlankCountryAmt := 0;
                GLEntry.SETCURRENTKEY("Posting Date", "G/L Account No.");
                GLEntry.SETFILTER("Posting Date", '%1..%2', FirstDate, LastDate);
                GLEntry.SETFILTER("G/L Account No.", '%1..%2', '6000', '6999');
                IF GLEntry.FIND('-') THEN
                    REPEAT
                        IF ((GLEntry."G/L Account No." <> '6710') AND (GLEntry."G/L Account No." <> '6720')) THEN BEGIN
                            GLEntry.CALCFIELDS("Cust Country Code");

                            //CLEAR(CountryRegion);

                            IF GLEntry."Cust Country Code" <> '' THEN BEGIN
                                CountryRegion.SETFILTER(CountryRegion.Code, '%1', GLEntry."Cust Country Code");//<>%1','aa');
                                IF CountryRegion.FIND('-') THEN BEGIN
                                    GBPAmount := GLEntry.Amount / CF;
                                    CountryRegion.DecCountryAmount := CountryRegion.DecCountryAmount + GBPAmount;
                                    CountryRegion.MODIFY;
                                END;
                            END;

                            IF GLEntry."Cust Country Code" = '' THEN BEGIN
                                BlankCountryAmt := BlankCountryAmt + GLEntry.Amount;
                            END;
                        END;

                    UNTIL GLEntry.NEXT = 0;
                //UNTIL Company1.NEXT=0;


                //JAN START
                FirstDate := CALCDATE('-CM+1M', FirstDate);
                LastDate := CALCDATE('CM', FirstDate);

                BlankCountryAmt := 0;
                GLEntry.SETCURRENTKEY("Posting Date", "G/L Account No.");
                GLEntry.SETFILTER("Posting Date", '%1..%2', FirstDate, LastDate);
                GLEntry.SETFILTER("G/L Account No.", '%1..%2', '6000', '6999');
                IF GLEntry.FIND('-') THEN
                    REPEAT
                        IF ((GLEntry."G/L Account No." <> '6710') AND (GLEntry."G/L Account No." <> '6720')) THEN BEGIN
                            GLEntry.CALCFIELDS("Cust Country Code");

                            //CLEAR(CountryRegion);

                            IF GLEntry."Cust Country Code" <> '' THEN BEGIN
                                CountryRegion.SETFILTER(CountryRegion.Code, '%1', GLEntry."Cust Country Code");//<>%1','aa');
                                IF CountryRegion.FIND('-') THEN BEGIN
                                    GBPAmount := GLEntry.Amount / CF;
                                    CountryRegion.JanCountryAmount := CountryRegion.JanCountryAmount + GBPAmount;
                                    CountryRegion.MODIFY;
                                END;
                            END;

                            IF GLEntry."Cust Country Code" = '' THEN BEGIN
                                BlankCountryAmt := BlankCountryAmt + GLEntry.Amount;
                            END;
                        END;

                    UNTIL GLEntry.NEXT = 0;
                //UNTIL Company1.NEXT=0;


                //FEB START
                FirstDate := CALCDATE('-CM+1M', FirstDate);
                LastDate := CALCDATE('CM', FirstDate);

                BlankCountryAmt := 0;
                GLEntry.SETCURRENTKEY("Posting Date", "G/L Account No.");
                GLEntry.SETFILTER("Posting Date", '%1..%2', FirstDate, LastDate);
                GLEntry.SETFILTER("G/L Account No.", '%1..%2', '6000', '6999');
                IF GLEntry.FIND('-') THEN
                    REPEAT
                        IF ((GLEntry."G/L Account No." <> '6710') AND (GLEntry."G/L Account No." <> '6720')) THEN BEGIN
                            GLEntry.CALCFIELDS("Cust Country Code");

                            //CLEAR(CountryRegion);

                            IF GLEntry."Cust Country Code" <> '' THEN BEGIN
                                CountryRegion.SETFILTER(CountryRegion.Code, '%1', GLEntry."Cust Country Code");//<>%1','aa');
                                IF CountryRegion.FIND('-') THEN BEGIN
                                    GBPAmount := GLEntry.Amount / CF;
                                    CountryRegion.FebCountryAmount := CountryRegion.FebCountryAmount + GBPAmount;
                                    CountryRegion.MODIFY;
                                END;
                            END;

                            IF GLEntry."Cust Country Code" = '' THEN BEGIN
                                BlankCountryAmt := BlankCountryAmt + GLEntry.Amount;
                            END;
                        END;

                    UNTIL GLEntry.NEXT = 0;
                //UNTIL Company1.NEXT=0;

                //MAR START
                FirstDate := CALCDATE('-CM+1M', FirstDate);
                LastDate := CALCDATE('CM', FirstDate);
                BlankCountryAmt := 0;
                GLEntry.SETCURRENTKEY("Posting Date", "G/L Account No.");
                GLEntry.SETFILTER("Posting Date", '%1..%2', FirstDate, LastDate);
                GLEntry.SETFILTER("G/L Account No.", '%1..%2', '6000', '6999');
                IF GLEntry.FIND('-') THEN
                    REPEAT
                        IF ((GLEntry."G/L Account No." <> '6710') AND (GLEntry."G/L Account No." <> '6720')) THEN BEGIN
                            GLEntry.CALCFIELDS("Cust Country Code");

                            //CLEAR(CountryRegion);

                            IF GLEntry."Cust Country Code" <> '' THEN BEGIN
                                CountryRegion.SETFILTER(CountryRegion.Code, '%1', GLEntry."Cust Country Code");//<>%1','aa');
                                IF CountryRegion.FIND('-') THEN BEGIN
                                    GBPAmount := GLEntry.Amount / CF;
                                    CountryRegion.MarCountryAmount := CountryRegion.MarCountryAmount + GBPAmount;
                                    CountryRegion.MODIFY;
                                END;
                            END;

                            IF GLEntry."Cust Country Code" = '' THEN BEGIN
                                BlankCountryAmt := BlankCountryAmt + GLEntry.Amount;
                            END;
                        END;

                    UNTIL GLEntry.NEXT = 0;

            UNTIL Company1.NEXT = 0;

        CountryRegion.SETFILTER(CountryRegion.Code, '<>%1', 'AA');//GLEntry."Cust Country Code");//<>%1','aa');
        IF CountryRegion.FIND('-') THEN
            REPEAT
                CountryRegion.CountryWiseAmount := CountryRegion.JanCountryAmount +
                CountryRegion.FebCountryAmount +
                CountryRegion.MarCountryAmount +
                CountryRegion.AprCountryAmount +
                CountryRegion.MayCountryAmount +
                CountryRegion.JunCountryAmount +
                CountryRegion.JulCountryAmount +
                CountryRegion.AugCountryAmount +
                CountryRegion.SepCountryAmount +
                CountryRegion.OctCountryAmount +
                CountryRegion.NovCountryAmount +
                CountryRegion.DecCountryAmount;

                CountryRegion.MODIFY;
            UNTIL CountryRegion.NEXT = 0;
    end;

    procedure RevenueSalesEmail()
    var
        GLEntry: Record "G/L Entry";
        CountryRegion: Record "Country/Region";
        GLSetup: Record "General Ledger Setup";
        FromDate: Date;
        ToDate: Date;
        Amount1: Decimal;
        Company1: Record Company;
        RecordFound1: Boolean;
        ExcelBuffer1: Record "Excel Buffer";
        SerialNo: Integer;
        CountryRegion2: Record "Country/Region";
        GrandTotal: Decimal;
        Apr1: Decimal;
        May1: Decimal;
        Jun1: Decimal;
        Jul1: Decimal;
        Aug1: Decimal;
        Sep1: Decimal;
        Oct1: Decimal;
        Nov1: Decimal;
        Dec1: Decimal;
        Jan1: Decimal;
        Feb1: Decimal;
        Mar1: Decimal;
        CountryTotal: Decimal;
        TotalApr: Decimal;
        TotalMay: Decimal;
        TotalJun: Decimal;
        TotalJul: Decimal;
        TotalAug: Decimal;
        TotalSep: Decimal;
        TotalOct: Decimal;
        TotalNov: Decimal;
        TotalDec: Decimal;
        TotalJan: Decimal;
        TotalFeb: Decimal;
        TotalMar: Decimal;
        TotalCountry1: Decimal;
        AmountinEUR: Decimal;
        Curexch1: Record "Currency Exchange Rate";
        GrandTotalEUR: Decimal;


    begin

        ExcelBuffer1.SETFILTER(ExcelBuffer1.Formula, 'CountryWiseRevenue');
        IF ExcelBuffer1.FINDSET THEN
            ExcelBuffer1.DELETEALL;

        Curexch1.RESET;
        CF := 0;
        AmountinEUR := 0;
        Curexch1.SETRANGE("Currency Code", 'EUR');
        Curexch1.SETFILTER("Starting Date", '..%1', TODAY);
        IF Curexch1.FINDLAST THEN
            CF := Curexch1."Relational Exch. Rate Amount" / Curexch1."Exchange Rate Amount";
        IF CF = 0 THEN
            CF := 1;

        CountryRegion2.CHANGECOMPANY('TKA Europe');

        IF ExcelBuffer1.FINDLAST THEN
            SerialNo := ExcelBuffer1."Row No."
        ELSE
            SerialNo := 1;

        CountryRegion.SETFILTER(CountryRegion.Code, '<>%1', 'aa');
        IF CountryRegion.FIND('-') THEN
            REPEAT

                SerialNo := SerialNo + 1;
                ExcelBuffer1.INIT;
                ExcelBuffer1."Row No." := SerialNo + 1;
                ExcelBuffer1.Formula := 'CountryWiseRevenue';
                ExcelBuffer1."Document No." := CountryRegion.Code;
                ExcelBuffer1.Comment := 'Data of UK';
                ExcelBuffer1."Cell Value as Text" := CountryRegion.Name;
                ExcelBuffer1."Amt. Excl. VAT (LCY)" := CountryRegion.CountryWiseAmount;

                IF (CountryRegion.CountryWiseAmount) <> 0 THEN
                    ExcelBuffer1.INSERT;
            UNTIL CountryRegion.NEXT = 0;

        CountryRegion2.SETFILTER(CountryRegion2.Code, '<>%1', 'aa');
        IF CountryRegion2.FIND('-') THEN
            REPEAT
                ExcelBuffer1.INIT;
                ExcelBuffer1.SETFILTER(ExcelBuffer1.Formula, 'CountryWiseRevenue');
                ExcelBuffer1.SETFILTER(ExcelBuffer1."Document No.", CountryRegion2.Code);
                IF ExcelBuffer1.FIND('-') THEN BEGIN

                    ExcelBuffer1.Comment := 'Combined Data of UK and EU';
                    ExcelBuffer1."Amt. Excl. VAT (LCY)" := ExcelBuffer1."Amt. Excl. VAT (LCY)" + CountryRegion2.CountryWiseAmount;
                    ExcelBuffer1.MODIFY;
                END
                ELSE BEGIN

                    IF ExcelBuffer1.FINDLAST THEN
                        SerialNo := ExcelBuffer1."Row No." + 1
                    ELSE
                        SerialNo := SerialNo + 1;

                    ExcelBuffer1.INIT;
                    ExcelBuffer1."Row No." := SerialNo + 1;
                    ExcelBuffer1.Formula := 'CountryWiseRevenue';
                    ExcelBuffer1."Document No." := CountryRegion2.Code;
                    ExcelBuffer1.Comment := 'Data of EU';
                    ExcelBuffer1."Cell Value as Text" := CountryRegion2.Name;
                    ExcelBuffer1."Amt. Excl. VAT (LCY)" := CountryRegion2.CountryWiseAmount;

                    IF (CountryRegion2.CountryWiseAmount) <> 0 THEN
                        ExcelBuffer1.INSERT;
                END;
            UNTIL CountryRegion2.NEXT = 0;


        CLEAR(SMTPMail);
        //SB-Comment Start
        // SMTPMail.CreateMessage('Dynamics', 'Dynamics@theknowledgeAcademy.com', 'martha.folkes@theknowledgeacademy.com',
        //                    'Auto Email for Country wise Revenue Data', '', TRUE);// ,'',TRUE);//for ' +COMPANYNAME ,'',TRUE);
        //SB-Comment End

        //SB-New Code start
        SMTPMail.Create('martha.folkes@theknowledgeacademy.com', 'Auto Email for Country wise Revenue Data', '', true);
        //SB-New Cdoe end

        //SMTPMail.AddBCC('biju.kurup@theknowledgeacademy.com');

        //SB-Comment Start
        // SMTPMail.AppendBody('Hi');
        // SMTPMail.AppendBody('<BR><BR>');
        // SMTPMail.AppendBody('Auto Email for Country wise Revenue Data');
        // SMTPMail.AppendBody('<table cellspacing="10"  style="border-spacing: 0px;" border="1">' +
        // '<col width="50"><col width="250"><col width="150">' +
        //  '<tr><th align="Centre">Contry Code</th>' +
        //  '<th align="Centre">Name</th>' +
        //  '<th align="Centre">Amount in GBP</th>' +
        //  '<th align="Centre">Amount in EUR</th>');
        //SB-Comment End
        //SB-New Code start
        SMTPMail.AppendToBody('Hi');
        SMTPMail.AppendToBody('<BR><BR>');
        SMTPMail.AppendToBody('Auto Email for Country wise Revenue Data');
        SMTPMail.AppendToBody('<table cellspacing="10"  style="border-spacing: 0px;" border="1">' +
        '<col width="50"><col width="250"><col width="150">' +
         '<tr><th align="Centre">Contry Code</th>' +
         '<th align="Centre">Name</th>' +
         '<th align="Centre">Amount in GBP</th>' +
         '<th align="Centre">Amount in EUR</th>');
        //SB-New code end

        ExcelBuffer1.RESET;
        ExcelBuffer1.SETCURRENTKEY("Amt. Excl. VAT (LCY)");
        ExcelBuffer1.SETFILTER(ExcelBuffer1."Amt. Excl. VAT (LCY)", '<>%1', 0);
        ExcelBuffer1.SETFILTER(ExcelBuffer1.Formula, 'CountryWiseRevenue');
        IF ExcelBuffer1.FIND('-') THEN
            REPEAT

                AmountinEUR := ExcelBuffer1."Amt. Excl. VAT (LCY)" / CF;

                //SB-Comment Start
                //         SMTPMail.AppendBody('<tr>');

                //         SMTPMail.AppendBody('<td>' + FORMAT(ExcelBuffer1."Document No.") + '</td>');
                //         SMTPMail.AppendBody('<td>' + FORMAT(ExcelBuffer1."Cell Value as Text") + '</td>');
                //         SMTPMail.AppendBody('<td align="Right">' + FORMAT(ExcelBuffer1."Amt. Excl. VAT (LCY)"
                //         , 0, '<Precision,0:0><Standard Format,0>') + '</td>');

                //         SMTPMail.AppendBody('<td align="Right">' + FORMAT(AmountinEUR, 0, '<Precision,0:0><Standard Format,0>') + '</td>');
                //         GrandTotalEUR := GrandTotalEUR + AmountinEUR;

                //         GrandTotal := GrandTotal + ExcelBuffer1."Amt. Excl. VAT (LCY)";
                //         SMTPMail.AppendBody('</tr>');
                //     UNTIL ExcelBuffer1.NEXT = 0;

                // SMTPMail.AppendBody('<tr>');
                // SMTPMail.AppendBody('<td>' + FORMAT('') + '</td>');
                // SMTPMail.AppendBody('<td>' + FORMAT('Grand Total') + '</td>');

                // SMTPMail.AppendBody('<td align="Right">' + FORMAT(GrandTotal, 0, '<Precision,0:0><Standard Format,0>') + '</td>');
                // SMTPMail.AppendBody('<td align="Right">' + FORMAT(GrandTotalEUR, 0, '<Precision,0:0><Standard Format,0>') + '</td>');

                // SMTPMail.AppendBody('</tr>');


                // SMTPMail.AppendBody('</table>');
                // SMTPMail.AppendBody('<BR><BR>');

                // //Month wise
                // SMTPMail.AppendBody('<BR><BR>');
                // SMTPMail.AppendBody('Country wise Revenue Data for each Month');
                // SMTPMail.AppendBody('<table cellspacing="10"  style="border-spacing: 0px;" border="1">' +
                // '<col width="50"><col width="200"><col width="50">' +
                //  '<tr><th align="Centre">Contry Code</th>' +
                //  '<th align="Centre">Name</th>' +
                //  '<th align="Centre">Apr</th>' +
                //  '<th align="Centre">May</th>' +
                //  '<th align="Centre">Jun</th>' +
                //  '<th align="Centre">Jul</th>' +
                //  '<th align="Centre">Aug</th>' +
                //  '<th align="Centre">Sep</th>' +
                //  '<th align="Centre">Oct</th>' +
                //  '<th align="Centre">Nov</th>' +
                //  '<th align="Centre">Dec</th>' +
                //  '<th align="Centre">Jan</th>' +
                //  '<th align="Centre">Feb</th>' +
                //  '<th align="Centre">Mar</th>' +
                //  '<th align="Centre">CountryTotal</th>');
                //SB-Comment End
                //SB-New code start
                SMTPMail.AppendToBody('<tr>');

                SMTPMail.AppendToBody('<td>' + FORMAT(ExcelBuffer1."Document No.") + '</td>');
                SMTPMail.AppendToBody('<td>' + FORMAT(ExcelBuffer1."Cell Value as Text") + '</td>');
                SMTPMail.AppendToBody('<td align="Right">' + FORMAT(ExcelBuffer1."Amt. Excl. VAT (LCY)"
                , 0, '<Precision,0:0><Standard Format,0>') + '</td>');

                SMTPMail.AppendToBody('<td align="Right">' + FORMAT(AmountinEUR, 0, '<Precision,0:0><Standard Format,0>') + '</td>');
                GrandTotalEUR := GrandTotalEUR + AmountinEUR;

                GrandTotal := GrandTotal + ExcelBuffer1."Amt. Excl. VAT (LCY)";
                SMTPMail.AppendToBody('</tr>');
            UNTIL ExcelBuffer1.NEXT = 0;

        SMTPMail.AppendToBody('<tr>');
        SMTPMail.AppendToBody('<td>' + FORMAT('') + '</td>');
        SMTPMail.AppendToBody('<td>' + FORMAT('Grand Total') + '</td>');

        SMTPMail.AppendToBody('<td align="Right">' + FORMAT(GrandTotal, 0, '<Precision,0:0><Standard Format,0>') + '</td>');
        SMTPMail.AppendToBody('<td align="Right">' + FORMAT(GrandTotalEUR, 0, '<Precision,0:0><Standard Format,0>') + '</td>');

        SMTPMail.AppendToBody('</tr>');


        SMTPMail.AppendToBody('</table>');
        SMTPMail.AppendToBody('<BR><BR>');

        //Month wise
        SMTPMail.AppendToBody('<BR><BR>');
        SMTPMail.AppendToBody('Country wise Revenue Data for each Month');
        SMTPMail.AppendToBody('<table cellspacing="10"  style="border-spacing: 0px;" border="1">' +
        '<col width="50"><col width="200"><col width="50">' +
         '<tr><th align="Centre">Contry Code</th>' +
         '<th align="Centre">Name</th>' +
         '<th align="Centre">Apr</th>' +
         '<th align="Centre">May</th>' +
         '<th align="Centre">Jun</th>' +
         '<th align="Centre">Jul</th>' +
         '<th align="Centre">Aug</th>' +
         '<th align="Centre">Sep</th>' +
         '<th align="Centre">Oct</th>' +
         '<th align="Centre">Nov</th>' +
         '<th align="Centre">Dec</th>' +
         '<th align="Centre">Jan</th>' +
         '<th align="Centre">Feb</th>' +
         '<th align="Centre">Mar</th>' +
         '<th align="Centre">CountryTotal</th>');
        //SB-New code end


        ExcelBuffer1.RESET;
        ExcelBuffer1.SETCURRENTKEY("Amt. Excl. VAT (LCY)");
        ExcelBuffer1.SETFILTER(ExcelBuffer1."Amt. Excl. VAT (LCY)", '<>%1', 0);
        ExcelBuffer1.SETFILTER(ExcelBuffer1.Formula, 'CountryWiseRevenue');
        IF ExcelBuffer1.FIND('-') THEN
            REPEAT
                //SB-Comment Start
                // SMTPMail.AppendBody('<tr>');
                // SMTPMail.AppendBody('<td>' + FORMAT(ExcelBuffer1."Document No.") + '</td>');
                // SMTPMail.AppendBody('<td>' + FORMAT(ExcelBuffer1."Cell Value as Text") + '</td>');
                //SB-comment End
                //SB-new code start
                SMTPMail.AppendToBody('<tr>');
                SMTPMail.AppendToBody('<td>' + FORMAT(ExcelBuffer1."Document No.") + '</td>');
                SMTPMail.AppendToBody('<td>' + FORMAT(ExcelBuffer1."Cell Value as Text") + '</td>');
                //SB-New code end

                Apr1 := 0;
                May1 := 0;

                Jun1 := 0;
                Jul1 := 0;
                Aug1 := 0;
                Sep1 := 0;
                Oct1 := 0;
                Nov1 := 0;
                Dec1 := 0;
                Jan1 := 0;
                Feb1 := 0;
                Mar1 := 0;

                CountryRegion.SETFILTER(CountryRegion.Code, '%1', ExcelBuffer1."Document No.");
                IF CountryRegion.FIND('-') THEN BEGIN
                    Apr1 := CountryRegion.AprCountryAmount;
                    May1 := CountryRegion.MayCountryAmount;

                    Jun1 := CountryRegion.JunCountryAmount;
                    Jul1 := CountryRegion.JulCountryAmount;
                    Aug1 := CountryRegion.AugCountryAmount;
                    Sep1 := CountryRegion.SepCountryAmount;
                    Oct1 := CountryRegion.OctCountryAmount;
                    Nov1 := CountryRegion.NovCountryAmount;
                    Dec1 := CountryRegion.DecCountryAmount;
                    Jan1 := CountryRegion.JanCountryAmount;
                    Feb1 := CountryRegion.FebCountryAmount;
                    Mar1 := CountryRegion.MarCountryAmount;

                END;

                CountryRegion2.SETFILTER(CountryRegion2.Code, '%1', ExcelBuffer1."Document No.");
                IF CountryRegion2.FIND('-') THEN BEGIN
                    Apr1 := Apr1 + CountryRegion2.AprCountryAmount;
                    May1 := May1 + CountryRegion2.MayCountryAmount;
                    Jun1 := Jun1 + CountryRegion2.JunCountryAmount;
                    Jul1 := Jul1 + CountryRegion2.JulCountryAmount;
                    Aug1 := Aug1 + CountryRegion2.AugCountryAmount;
                    Sep1 := Sep1 + CountryRegion2.SepCountryAmount;
                    Oct1 := Oct1 + CountryRegion2.OctCountryAmount;
                    Nov1 := Nov1 + CountryRegion2.NovCountryAmount;
                    Dec1 := Dec1 + CountryRegion2.DecCountryAmount;
                    Jan1 := Jan1 + CountryRegion2.JanCountryAmount;
                    Feb1 := Feb1 + CountryRegion2.FebCountryAmount;
                    Mar1 := Mar1 + CountryRegion2.MarCountryAmount;

                END;
                //SB-Code commented start
                //         SMTPMail.AppendBody('<td align="Right">' + FORMAT(Apr1, 0, '<Precision,0:0><Standard Format,0>') + '</td>');
                //         SMTPMail.AppendBody('<td align="Right">' + FORMAT(May1, 0, '<Precision,0:0><Standard Format,0>') + '</td>');
                //         SMTPMail.AppendBody('<td align="Right">' + FORMAT(Jun1, 0, '<Precision,0:0><Standard Format,0>') + '</td>');
                //         SMTPMail.AppendBody('<td align="Right">' + FORMAT(Jul1, 0, '<Precision,0:0><Standard Format,0>') + '</td>');
                //         SMTPMail.AppendBody('<td align="Right">' + FORMAT(Aug1, 0, '<Precision,0:0><Standard Format,0>') + '</td>');
                //         SMTPMail.AppendBody('<td align="Right">' + FORMAT(Sep1, 0, '<Precision,0:0><Standard Format,0>') + '</td>');
                //         SMTPMail.AppendBody('<td align="Right">' + FORMAT(Oct1, 0, '<Precision,0:0><Standard Format,0>') + '</td>');
                //         SMTPMail.AppendBody('<td align="Right">' + FORMAT(Nov1, 0, '<Precision,0:0><Standard Format,0>') + '</td>');
                //         SMTPMail.AppendBody('<td align="Right">' + FORMAT(Dec1, 0, '<Precision,0:0><Standard Format,0>') + '</td>');
                //         SMTPMail.AppendBody('<td align="Right">' + FORMAT(Jan1, 0, '<Precision,0:0><Standard Format,0>') + '</td>');
                //         SMTPMail.AppendBody('<td align="Right">' + FORMAT(Feb1, 0, '<Precision,0:0><Standard Format,0>') + '</td>');
                //         SMTPMail.AppendBody('<td align="Right">' + FORMAT(Mar1, 0, '<Precision,0:0><Standard Format,0>') + '</td>');

                //         CountryTotal := Apr1 + May1 + Jun1 + Jul1 + Aug1 + Sep1 + Oct1 + Nov1 + Dec1 + Jan1 + Feb1 + Mar1;
                //         TotalCountry1 := TotalCountry1 + CountryTotal;
                //         SMTPMail.AppendBody('<td align="Right">' + FORMAT(CountryTotal, 0, '<Precision,0:0><Standard Format,0>') + '</td>');

                //         SMTPMail.AppendBody('</tr>');
                //         TotalApr := TotalApr + Apr1;
                //         TotalMay := TotalMay + May1;
                //         TotalJun := TotalJun + Jun1;
                //         TotalJul := TotalJul + Jul1;
                //         TotalAug := TotalAug + Aug1;
                //         TotalSep := TotalSep + Sep1;
                //         TotalOct := TotalOct + Oct1;
                //         TotalNov := TotalNov + Nov1;
                //         TotalDec := TotalDec + Dec1;
                //         TotalJan := TotalJan + Jan1;
                //         TotalFeb := TotalFeb + Feb1;
                //         TotalMar := TotalMar + Mar1;


                //     UNTIL ExcelBuffer1.NEXT = 0;
                // SMTPMail.AppendBody('<td align="Right">' + FORMAT('') + '</td>');
                // SMTPMail.AppendBody('<td align="Right">' + FORMAT('Total') + '</td>');
                // SMTPMail.AppendBody('<td align="Right">' + FORMAT(TotalApr, 0, '<Precision,0:0><Standard Format,0>') + '</td>');
                // SMTPMail.AppendBody('<td align="Right">' + FORMAT(TotalMay, 0, '<Precision,0:0><Standard Format,0>') + '</td>');
                // SMTPMail.AppendBody('<td align="Right">' + FORMAT(TotalJun, 0, '<Precision,0:0><Standard Format,0>') + '</td>');
                // SMTPMail.AppendBody('<td align="Right">' + FORMAT(TotalJul, 0, '<Precision,0:0><Standard Format,0>') + '</td>');
                // SMTPMail.AppendBody('<td align="Right">' + FORMAT(TotalAug, 0, '<Precision,0:0><Standard Format,0>') + '</td>');
                // SMTPMail.AppendBody('<td align="Right">' + FORMAT(TotalSep, 0, '<Precision,0:0><Standard Format,0>') + '</td>');
                // SMTPMail.AppendBody('<td align="Right">' + FORMAT(TotalOct, 0, '<Precision,0:0><Standard Format,0>') + '</td>');
                // SMTPMail.AppendBody('<td align="Right">' + FORMAT(TotalNov, 0, '<Precision,0:0><Standard Format,0>') + '</td>');
                // SMTPMail.AppendBody('<td align="Right">' + FORMAT(TotalDec, 0, '<Precision,0:0><Standard Format,0>') + '</td>');
                // SMTPMail.AppendBody('<td align="Right">' + FORMAT(TotalJan, 0, '<Precision,0:0><Standard Format,0>') + '</td>');
                // SMTPMail.AppendBody('<td align="Right">' + FORMAT(TotalFeb, 0, '<Precision,0:0><Standard Format,0>') + '</td>');
                // SMTPMail.AppendBody('<td align="Right">' + FORMAT(TotalMar, 0, '<Precision,0:0><Standard Format,0>') + '</td>');
                // SMTPMail.AppendBody('<td align="Right">' + FORMAT(TotalCountry1, 0, '<Precision,0:0><Standard Format,0>') + '</td>');


                // SMTPMail.AppendBody('</table>');
                // SMTPMail.AppendBody('<BR><BR>');

                // SMTPMail.AppendBody('Kind Regards,');
                // SMTPMail.AppendBody('<BR><BR>');
                // SMTPMail.AppendBody('Dynamics');

                // SMTPMail.Send();
                //SB-Code commented end
                //SB-New Code start
                SMTPMail.AppendToBody('<td align="Right">' + FORMAT(Apr1, 0, '<Precision,0:0><Standard Format,0>') + '</td>');
                SMTPMail.AppendToBody('<td align="Right">' + FORMAT(May1, 0, '<Precision,0:0><Standard Format,0>') + '</td>');
                SMTPMail.AppendToBody('<td align="Right">' + FORMAT(Jun1, 0, '<Precision,0:0><Standard Format,0>') + '</td>');
                SMTPMail.AppendToBody('<td align="Right">' + FORMAT(Jul1, 0, '<Precision,0:0><Standard Format,0>') + '</td>');
                SMTPMail.AppendToBody('<td align="Right">' + FORMAT(Aug1, 0, '<Precision,0:0><Standard Format,0>') + '</td>');
                SMTPMail.AppendToBody('<td align="Right">' + FORMAT(Sep1, 0, '<Precision,0:0><Standard Format,0>') + '</td>');
                SMTPMail.AppendToBody('<td align="Right">' + FORMAT(Oct1, 0, '<Precision,0:0><Standard Format,0>') + '</td>');
                SMTPMail.AppendToBody('<td align="Right">' + FORMAT(Nov1, 0, '<Precision,0:0><Standard Format,0>') + '</td>');
                SMTPMail.AppendToBody('<td align="Right">' + FORMAT(Dec1, 0, '<Precision,0:0><Standard Format,0>') + '</td>');
                SMTPMail.AppendToBody('<td align="Right">' + FORMAT(Jan1, 0, '<Precision,0:0><Standard Format,0>') + '</td>');
                SMTPMail.AppendToBody('<td align="Right">' + FORMAT(Feb1, 0, '<Precision,0:0><Standard Format,0>') + '</td>');
                SMTPMail.AppendToBody('<td align="Right">' + FORMAT(Mar1, 0, '<Precision,0:0><Standard Format,0>') + '</td>');

                CountryTotal := Apr1 + May1 + Jun1 + Jul1 + Aug1 + Sep1 + Oct1 + Nov1 + Dec1 + Jan1 + Feb1 + Mar1;
                TotalCountry1 := TotalCountry1 + CountryTotal;
                SMTPMail.AppendToBody('<td align="Right">' + FORMAT(CountryTotal, 0, '<Precision,0:0><Standard Format,0>') + '</td>');

                SMTPMail.AppendToBody('</tr>');
                TotalApr := TotalApr + Apr1;
                TotalMay := TotalMay + May1;
                TotalJun := TotalJun + Jun1;
                TotalJul := TotalJul + Jul1;
                TotalAug := TotalAug + Aug1;
                TotalSep := TotalSep + Sep1;
                TotalOct := TotalOct + Oct1;
                TotalNov := TotalNov + Nov1;
                TotalDec := TotalDec + Dec1;
                TotalJan := TotalJan + Jan1;
                TotalFeb := TotalFeb + Feb1;
                TotalMar := TotalMar + Mar1;


            UNTIL ExcelBuffer1.NEXT = 0;
        SMTPMail.AppendToBody('<td align="Right">' + FORMAT('') + '</td>');
        SMTPMail.AppendToBody('<td align="Right">' + FORMAT('Total') + '</td>');
        SMTPMail.AppendToBody('<td align="Right">' + FORMAT(TotalApr, 0, '<Precision,0:0><Standard Format,0>') + '</td>');
        SMTPMail.AppendToBody('<td align="Right">' + FORMAT(TotalMay, 0, '<Precision,0:0><Standard Format,0>') + '</td>');
        SMTPMail.AppendToBody('<td align="Right">' + FORMAT(TotalJun, 0, '<Precision,0:0><Standard Format,0>') + '</td>');
        SMTPMail.AppendToBody('<td align="Right">' + FORMAT(TotalJul, 0, '<Precision,0:0><Standard Format,0>') + '</td>');
        SMTPMail.AppendToBody('<td align="Right">' + FORMAT(TotalAug, 0, '<Precision,0:0><Standard Format,0>') + '</td>');
        SMTPMail.AppendToBody('<td align="Right">' + FORMAT(TotalSep, 0, '<Precision,0:0><Standard Format,0>') + '</td>');
        SMTPMail.AppendToBody('<td align="Right">' + FORMAT(TotalOct, 0, '<Precision,0:0><Standard Format,0>') + '</td>');
        SMTPMail.AppendToBody('<td align="Right">' + FORMAT(TotalNov, 0, '<Precision,0:0><Standard Format,0>') + '</td>');
        SMTPMail.AppendToBody('<td align="Right">' + FORMAT(TotalDec, 0, '<Precision,0:0><Standard Format,0>') + '</td>');
        SMTPMail.AppendToBody('<td align="Right">' + FORMAT(TotalJan, 0, '<Precision,0:0><Standard Format,0>') + '</td>');
        SMTPMail.AppendToBody('<td align="Right">' + FORMAT(TotalFeb, 0, '<Precision,0:0><Standard Format,0>') + '</td>');
        SMTPMail.AppendToBody('<td align="Right">' + FORMAT(TotalMar, 0, '<Precision,0:0><Standard Format,0>') + '</td>');
        SMTPMail.AppendToBody('<td align="Right">' + FORMAT(TotalCountry1, 0, '<Precision,0:0><Standard Format,0>') + '</td>');


        SMTPMail.AppendToBody('</table>');
        SMTPMail.AppendToBody('<BR><BR>');

        SMTPMail.AppendToBody('Kind Regards,');
        SMTPMail.AppendToBody('<BR><BR>');
        SMTPMail.AppendToBody('Dynamics');

        // SMTPSend.Send(SMTPMail);
        //SB-New Code end

        IF GUIALLOWED THEN
            MESSAGE('DONE');
    end;

    procedure UserWiseCountSales()
    var
        SalesInvHeader: Record "Sales Invoice Header";
        ExcelBuffer7: Record "Excel Buffer";
        date4: Date;
        "User Setup3": Record "User Setup";
        Time1: Time;
        Time2: Time;
        Time3: Time;
        Time4: Time;
        Time5: Time;
        Time6: Time;
        SrNo: Integer;
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        GLEntry: Record "G/L Entry";
        InvCount: Integer;
        CreditCount: Integer;
        CustLedg: Record "Cust. Ledger Entry";
        PaymentCount: Integer;
        TotalCount: Integer;
        Company1: Record Company;


    begin

        date4 := TODAY - 1;//010322D;//311221D;//260222D;//020322D;

        ExcelBuffer7.SETFILTER(ExcelBuffer7.Formula, 'USER COUNT*');
        IF ExcelBuffer7.FIND('-') THEN
            REPEAT
                ExcelBuffer7.DELETE;
            UNTIL ExcelBuffer7.NEXT = 0;

        Company1.SETFILTER(Company1.Name, '<>%1', 'aa');
        IF Company1.FIND('-') THEN
            REPEAT
                CLEAR("User Setup3");
                CLEAR(SalesInvHeader);
                CLEAR(SalesCrMemoHeader);
                CLEAR(GLEntry);
                CLEAR(CustLedg);

                // "User Setup3".CHANGECOMPANY(Company1.Name);
                SalesInvHeader.CHANGECOMPANY(Company1.Name);
                SalesCrMemoHeader.CHANGECOMPANY(Company1.Name);
                GLEntry.CHANGECOMPANY(Company1.Name);
                CustLedg.CHANGECOMPANY(Company1.Name);

                //"User Setup3".SETFILTER("User Setup3"."User ID",'<>%1|<>%2','SVC_NAV_API','BIJU.KURUP');
                "User Setup3".SETFILTER("User Setup3"."User ID", '<>%1 & <>%2', 'SVC_NAV_API', 'BIJU.KURUP');
                IF "User Setup3".FIND('-') THEN
                    REPEAT

                        SalesInvHeader.SETCURRENTKEY("Posting Date", "No.");
                        SalesInvHeader.SETFILTER(SalesInvHeader."User ID", "User Setup3"."User ID");
                        SalesInvHeader.SETFILTER("Posting Date", '%1', date4);//TODAY);
                        IF SalesInvHeader.FIND('-') THEN
                            REPEAT
                                Time1 := 000000T;
                                Time2 := 050000T;

                                Time3 := 050100T;
                                Time4 := 100000T;

                                Time5 := 100100T;
                                Time6 := 235959T;

                                SrNo := SrNo + 1;
                                ExcelBuffer7."Row No." := SrNo;
                                ExcelBuffer7."Column No." := 1;

                                ExcelBuffer7.SalesInvoice12To5AM := 0;
                                ExcelBuffer7.SalesInvoice5AMTo10AM := 0;
                                ExcelBuffer7.SalesInvoice10AMTo12PM := 0;

                                IF ((SalesInvHeader."Posted Time" >= Time1) AND (SalesInvHeader."Posted Time" <= Time2)) THEN BEGIN
                                    ExcelBuffer7.SalesInvoice12To5AM := 1;//ExcelBuffer7.SalesInvoice12To5AM+1;
                                    ExcelBuffer7.Type := '00_TO_05AM';

                                    ExcelBuffer7.UserID1 := "User Setup3"."User ID";
                                    ExcelBuffer7.Formula := 'USER COUNT SALES';
                                    ExcelBuffer7.Formula2 := 'Invoice';
                                    ExcelBuffer7."Document No." := GLEntry."Document No.";
                                    ExcelBuffer7.INSERT;
                                END;

                                IF ((SalesInvHeader."Posted Time" >= Time3) AND (SalesInvHeader."Posted Time" <= Time4)) THEN BEGIN
                                    ExcelBuffer7.SalesInvoice5AMTo10AM := 1;//ExcelBuffer7.SalesInvoice5AMTo10AM+1;
                                    ExcelBuffer7.Type := '05_TO_10AM';

                                    ExcelBuffer7.UserID1 := "User Setup3"."User ID";
                                    ExcelBuffer7.Formula := 'USER COUNT SALES';

                                    ExcelBuffer7.Formula2 := 'Invoice';
                                    ExcelBuffer7."Document No." := GLEntry."Document No.";
                                    ExcelBuffer7.INSERT;
                                END;

                                IF ((SalesInvHeader."Posted Time" >= Time5) AND (SalesInvHeader."Posted Time" <= Time6)) THEN BEGIN
                                    ExcelBuffer7.SalesInvoice10AMTo12PM := 1;//ExcelBuffer7.SalesInvoice10AMTo12PM+1;
                                    ExcelBuffer7.Type := '10_TO_12AM';
                                    ExcelBuffer7.UserID1 := "User Setup3"."User ID";
                                    ExcelBuffer7.Formula := 'USER COUNT SALES';

                                    ExcelBuffer7.Formula2 := 'Invoice';
                                    ExcelBuffer7."Document No." := GLEntry."Document No.";

                                    ExcelBuffer7.INSERT;
                                END;
                            UNTIL SalesInvHeader.NEXT = 0;

                        //Credit Memo Start
                        // SalesCrMemoHeader.SETCURRENTKEY("Posting Date","No.");
                        SalesCrMemoHeader.SETFILTER(SalesCrMemoHeader."User ID", "User Setup3"."User ID");
                        SalesCrMemoHeader.SETFILTER("Posting Date", '%1', date4);//TODAY);
                        IF SalesCrMemoHeader.FIND('-') THEN
                            REPEAT
                                //    MESSAGE (SalesCrMemoHeader."No.");

                                GLEntry.SETCURRENTKEY("Document No.", "Posting Date");
                                GLEntry.SETFILTER(GLEntry."Document No.", SalesCrMemoHeader."No.");
                                IF GLEntry.FIND('-') THEN BEGIN

                                    Time1 := 000000T;
                                    Time2 := 050000T;

                                    Time3 := 050100T;
                                    Time4 := 100000T;

                                    Time5 := 100100T;
                                    Time6 := 235959T;

                                    SrNo := SrNo + 1;
                                    ExcelBuffer7."Row No." := SrNo;
                                    ExcelBuffer7."Column No." := 1;

                                    ExcelBuffer7.SalesCreditMemo12To5AM := 0;
                                    ExcelBuffer7.SalesCreditMemo5AMTo10AM := 0;
                                    ExcelBuffer7.SalesCreditMemo10AMTo12PM := 0;

                                    ExcelBuffer7.INIT;

                                    IF ((GLEntry."Created Time" >= Time1) AND (GLEntry."Created Time" <= Time2)) THEN BEGIN
                                        ExcelBuffer7.SalesCreditMemo12To5AM := 1;//ExcelBuffer7.SalesInvoice12To5AM+1;
                                        ExcelBuffer7.Type := '00_TO_05AM';
                                        ExcelBuffer7.UserID1 := "User Setup3"."User ID";
                                        ExcelBuffer7.Formula := 'USER COUNT SALES';

                                        ExcelBuffer7.Formula2 := 'CREDIT MEMO';
                                        ExcelBuffer7."Document No." := GLEntry."Document No.";
                                        ExcelBuffer7.INSERT;
                                    END;

                                    IF ((GLEntry."Created Time" >= Time3) AND (GLEntry."Created Time" <= Time4)) THEN BEGIN
                                        ExcelBuffer7.SalesCreditMemo5AMTo10AM := 1;//ExcelBuffer7.SalesInvoice5AMTo10AM+1;
                                        ExcelBuffer7.Type := '05_TO_10AM';
                                        //a1:=a1+1;
                                        ExcelBuffer7.UserID1 := "User Setup3"."User ID";
                                        ExcelBuffer7.Formula := 'USER COUNT SALES';

                                        ExcelBuffer7.Formula2 := 'CREDIT MEMO';
                                        ExcelBuffer7."Document No." := GLEntry."Document No.";
                                        ExcelBuffer7.INSERT;
                                    END;

                                    IF ((GLEntry."Created Time" >= Time5) AND (GLEntry."Created Time" <= Time6)) THEN BEGIN
                                        ExcelBuffer7.SalesCreditMemo10AMTo12PM := 1;//ExcelBuffer7.SalesInvoice10AMTo12PM+1;
                                        ExcelBuffer7.Type := '10_TO_12AM';

                                        ExcelBuffer7.UserID1 := "User Setup3"."User ID";
                                        ExcelBuffer7.Formula := 'USER COUNT SALES';

                                        ExcelBuffer7.Formula2 := 'CREDIT MEMO';
                                        ExcelBuffer7."Document No." := GLEntry."Document No.";
                                        ExcelBuffer7.INSERT;
                                    END;
                                END;

                            UNTIL SalesCrMemoHeader.NEXT = 0;
                        //Credit Memo End





                        //Payment Start
                        // CustLedg.SETCURRENTKEY("Posting Date","No.");
                        CustLedg.SETFILTER(CustLedg."User ID", "User Setup3"."User ID");
                        CustLedg.SETFILTER("Posting Date", '%1', date4);//TODAY);
                        IF CustLedg.FIND('-') THEN
                            REPEAT
                                //    MESSAGE (CustLedg."No.");

                                GLEntry.SETCURRENTKEY("Document No.", "Posting Date");
                                GLEntry.SETFILTER(GLEntry."Document No.", CustLedg."Document No.");
                                IF GLEntry.FIND('-') THEN BEGIN

                                    Time1 := 000000T;
                                    Time2 := 050000T;

                                    Time3 := 050100T;
                                    Time4 := 100000T;

                                    Time5 := 100100T;
                                    Time6 := 235959T;

                                    SrNo := SrNo + 1;
                                    ExcelBuffer7."Row No." := SrNo;
                                    ExcelBuffer7."Column No." := 1;

                                    ExcelBuffer7.SalesPayment12To5AM := 0;
                                    ExcelBuffer7.SalesPayment5AMTo10AM := 0;
                                    ExcelBuffer7.SalesPayment10AMTo12PM := 0;

                                    ExcelBuffer7.INIT;

                                    IF ((GLEntry."Created Time" >= Time1) AND (GLEntry."Created Time" <= Time2)) THEN BEGIN
                                        ExcelBuffer7.SalesPayment12To5AM := 1;//ExcelBuffer7.SalesInvoice12To5AM+1;
                                        ExcelBuffer7.Type := '00_TO_05AM';
                                        ExcelBuffer7.UserID1 := "User Setup3"."User ID";
                                        ExcelBuffer7.Formula := 'USER COUNT SALES';

                                        ExcelBuffer7.Formula2 := 'Payment';
                                        ExcelBuffer7."Document No." := GLEntry."Document No.";
                                        ExcelBuffer7.INSERT;
                                    END;

                                    IF ((GLEntry."Created Time" >= Time3) AND (GLEntry."Created Time" <= Time4)) THEN BEGIN
                                        ExcelBuffer7.SalesPayment5AMTo10AM := 1;//ExcelBuffer7.SalesInvoice5AMTo10AM+1;
                                        ExcelBuffer7.Type := '05_TO_10AM';
                                        //a1:=a1+1;
                                        ExcelBuffer7.UserID1 := "User Setup3"."User ID";
                                        ExcelBuffer7.Formula := 'USER COUNT SALES';

                                        ExcelBuffer7.Formula2 := 'Payment';
                                        ExcelBuffer7."Document No." := GLEntry."Document No.";
                                        ExcelBuffer7.INSERT;
                                    END;

                                    IF ((GLEntry."Created Time" >= Time5) AND (GLEntry."Created Time" <= Time6)) THEN BEGIN
                                        ExcelBuffer7.SalesPayment10AMTo12PM := 1;//ExcelBuffer7.SalesInvoice10AMTo12PM+1;
                                        ExcelBuffer7.Type := '10_TO_12AM';

                                        ExcelBuffer7.UserID1 := "User Setup3"."User ID";
                                        ExcelBuffer7.Formula := 'USER COUNT SALES';

                                        ExcelBuffer7.Formula2 := 'Payment';
                                        ExcelBuffer7."Document No." := GLEntry."Document No.";
                                        ExcelBuffer7.INSERT;
                                    END;
                                END;

                            UNTIL CustLedg.NEXT = 0;
                    //Payment End


                    UNTIL "User Setup3".NEXT = 0;
            UNTIL Company1.NEXT = 0;

        //Send Email
        CLEAR(SMTPMail);

        //SB-Comment Start
        // SMTPMail.CreateMessage('Dynamics', 'Dynamics@theknowledgeAcademy.com', 'martha.folkes@theknowledgeacademy.com',
        //                    'User wise Entry count Sales', '', TRUE);
        //SB-Comment End
        //SB-New Code Start
        SMTPMail.Create('martha.folkes@theknowledgeacademy.com', 'User wise Entry count Sales', '', TRUE);
        //SB-New coden end

        //SMTPMail.AddBCC('biju.kurup@theknowledgeacademy.com');
        //SB-Comment Start
        // SMTPMail.AppendBody('Hi');

        // SMTPMail.AppendBody('<BR><BR>');
        // SMTPMail.AppendBody('User wise Entry count for the date ');
        // SMTPMail.AppendBody(FORMAT(date4));

        // SMTPMail.AppendBody('<BR>');
        // SMTPMail.AppendBody('Table for Entries from 00 to 5AM');
        // SMTPMail.AppendBody('<BR>');

        // SMTPMail.AppendBody('<table cellspacing="10"  style="border-spacing: 0px;" border="1">' +
        // '<col width="250"><col width="50"><col width="50">' +
        //  '<col width="50"><col width="50"><col width="50">' +
        //  '<tr><th align="Center">Time</th>' +
        //  '<th align="Center">User Name</th>' +
        //  '<th align="Center">Posted Sales Invoice</th>' +
        //  '<th align="Center">Posted Credit Memo</th>' +
        //  '<th align="Center">Posted Payment</th>' +
        //  //'<th align="Center">Posted Journals</th>'+
        //  '<th align="Center">Total Count</th>');
        //SB-Comment ENd
        //SB-New Code start
        SMTPMail.AppendToBody('Hi');

        SMTPMail.AppendToBody('<BR><BR>');
        SMTPMail.AppendToBody('User wise Entry count for the date ');
        SMTPMail.AppendToBody(FORMAT(date4));

        SMTPMail.AppendToBody('<BR>');
        SMTPMail.AppendToBody('Table for Entries from 00 to 5AM');
        SMTPMail.AppendToBody('<BR>');

        SMTPMail.AppendToBody('<table cellspacing="10"  style="border-spacing: 0px;" border="1">' +
        '<col width="250"><col width="50"><col width="50">' +
         '<col width="50"><col width="50"><col width="50">' +
         '<tr><th align="Center">Time</th>' +
         '<th align="Center">User Name</th>' +
         '<th align="Center">Posted Sales Invoice</th>' +
         '<th align="Center">Posted Credit Memo</th>' +
         '<th align="Center">Posted Payment</th>' +
         //'<th align="Center">Posted Journals</th>'+
         '<th align="Center">Total Count</th>');
        //SB-New code end

        "User Setup3".RESET;
        // "User Setup3".SETFILTER("User Setup3"."User ID",'<>%1|<>%2','SVC_NAV_API','BIJU.KURUP');
        "User Setup3".SETFILTER("User Setup3"."User ID", '<>%1 & <>%2', 'SVC_NAV_API', 'BIJU.KURUP');
        IF "User Setup3".FIND('-') THEN
            REPEAT
                InvCount := 0;
                CreditCount := 0;
                PaymentCount := 0;
                TotalCount := 0;

                ExcelBuffer7.SETCURRENTKEY(Type);
                ExcelBuffer7.RESET;
                ExcelBuffer7.SETFILTER(ExcelBuffer7.Formula, 'USER COUNT SALES');
                ExcelBuffer7.SETFILTER(ExcelBuffer7.UserID1, "User Setup3"."User ID");
                ExcelBuffer7.SETFILTER(ExcelBuffer7.Type, '00_TO_05AM');//00_TO_05AM');

                IF ExcelBuffer7.FIND('-') THEN
                    REPEAT
                        IF ExcelBuffer7.Formula2 = 'Invoice' THEN
                            InvCount := InvCount + 1;

                        IF ExcelBuffer7.Formula2 = 'CREDIT MEMO' THEN
                            CreditCount := CreditCount + 1;

                        IF ExcelBuffer7.Formula2 = 'Payment' THEN
                            PaymentCount := PaymentCount + 1;

                    UNTIL ExcelBuffer7.NEXT = 0;

                //SB-Comment Start
                //         IF (InvCount + CreditCount + PaymentCount) > 0 THEN BEGIN
                //             TotalCount := 0;
                //             TotalCount := InvCount + CreditCount + PaymentCount;
                //             SMTPMail.AppendBody('<tr>');
                //             SMTPMail.AppendBody('<td align="Center">' + FORMAT('00_TO_05AM') + '</td>');
                //             SMTPMail.AppendBody('<td align="Center">' + FORMAT(ExcelBuffer7.UserID1) + '</td>');
                //             SMTPMail.AppendBody('<td align="Center">' + FORMAT(InvCount) + '</td>');
                //             SMTPMail.AppendBody('<td align="Center">' + FORMAT(CreditCount) + '</td>');
                //             SMTPMail.AppendBody('<td align="Center">' + FORMAT(PaymentCount) + '</td>');
                //             SMTPMail.AppendBody('<td align="Center">' + FORMAT(TotalCount) + '</td>');
                //             SMTPMail.AppendBody('</tr>');
                //         END;
                //     UNTIL "User Setup3".NEXT = 0;

                // SMTPMail.AppendBody('<td align="Center">' + FORMAT('') + '</td>');
                // SMTPMail.AppendBody('</table>');

                // SMTPMail.AppendBody('<BR>');
                // SMTPMail.AppendBody('Table for Entries from 5 to 10AM');
                // SMTPMail.AppendBody('<BR>');
                // SMTPMail.AppendBody('<table cellspacing="10"  style="border-spacing: 0px;" border="1">' +
                // '<col width="250"><col width="50"><col width="50">' +
                //  '<col width="50"><col width="50"><col width="50">' +
                //  '<tr><th align="Center">Time</th>' +
                //  '<th align="Center">User Name</th>' +
                //  '<th align="Center">Posted Sales Invoice</th>' +
                //  '<th align="Center">Posted Credit Memo</th>' +
                //  '<th align="Center">Posted Payment</th>' +
                //  //  '<th align="Center">Posted Journals</th>'+
                //  '<th align="Center">Total Count</th>');
                //SB-Comment End

                //SB-New code start
                IF (InvCount + CreditCount + PaymentCount) > 0 THEN BEGIN
                    TotalCount := 0;
                    TotalCount := InvCount + CreditCount + PaymentCount;
                    SMTPMail.AppendToBody('<tr>');
                    SMTPMail.AppendToBody('<td align="Center">' + FORMAT('00_TO_05AM') + '</td>');
                    SMTPMail.AppendToBody('<td align="Center">' + FORMAT(ExcelBuffer7.UserID1) + '</td>');
                    SMTPMail.AppendToBody('<td align="Center">' + FORMAT(InvCount) + '</td>');
                    SMTPMail.AppendToBody('<td align="Center">' + FORMAT(CreditCount) + '</td>');
                    SMTPMail.AppendToBody('<td align="Center">' + FORMAT(PaymentCount) + '</td>');
                    SMTPMail.AppendToBody('<td align="Center">' + FORMAT(TotalCount) + '</td>');
                    SMTPMail.AppendToBody('</tr>');
                END;
            UNTIL "User Setup3".NEXT = 0;

        SMTPMail.AppendToBody('<td align="Center">' + FORMAT('') + '</td>');
        SMTPMail.AppendToBody('</table>');

        SMTPMail.AppendToBody('<BR>');
        SMTPMail.AppendToBody('Table for Entries from 5 to 10AM');
        SMTPMail.AppendToBody('<BR>');
        SMTPMail.AppendToBody('<table cellspacing="10"  style="border-spacing: 0px;" border="1">' +
        '<col width="250"><col width="50"><col width="50">' +
         '<col width="50"><col width="50"><col width="50">' +
         '<tr><th align="Center">Time</th>' +
         '<th align="Center">User Name</th>' +
         '<th align="Center">Posted Sales Invoice</th>' +
         '<th align="Center">Posted Credit Memo</th>' +
         '<th align="Center">Posted Payment</th>' +
         //  '<th align="Center">Posted Journals</th>'+
         '<th align="Center">Total Count</th>');
        //SB-New Code End

        "User Setup3".RESET;
        // "User Setup3".SETFILTER("User Setup3"."User ID",'<>%1|<>%2','SVC_NAV_API','BIJU.KURUP');
        "User Setup3".SETFILTER("User Setup3"."User ID", '<>%1 & <>%2', 'SVC_NAV_API', 'BIJU.KURUP');

        IF "User Setup3".FIND('-') THEN
            REPEAT
                InvCount := 0;
                CreditCount := 0;
                PaymentCount := 0;

                ExcelBuffer7.SETCURRENTKEY(Type);
                ExcelBuffer7.RESET;
                ExcelBuffer7.SETFILTER(ExcelBuffer7.Formula, 'USER COUNT SALES');
                ExcelBuffer7.SETFILTER(ExcelBuffer7.UserID1, "User Setup3"."User ID");
                ExcelBuffer7.SETFILTER(ExcelBuffer7.Type, '05_TO_10AM');//00_TO_05AM');

                IF ExcelBuffer7.FIND('-') THEN
                    REPEAT
                        IF ExcelBuffer7.Formula2 = 'Invoice' THEN
                            InvCount := InvCount + 1;

                        IF ExcelBuffer7.Formula2 = 'CREDIT MEMO' THEN
                            CreditCount := CreditCount + 1;

                        IF ExcelBuffer7.Formula2 = 'Payment' THEN
                            PaymentCount := PaymentCount + 1;

                    UNTIL ExcelBuffer7.NEXT = 0;

                //SB-Comment Start
                //         IF (InvCount + CreditCount + PaymentCount) > 0 THEN BEGIN
                //             TotalCount := 0;
                //             TotalCount := InvCount + CreditCount + PaymentCount;
                //             SMTPMail.AppendBody('<tr>');
                //             SMTPMail.AppendBody('<td align="Center">' + FORMAT('05_TO_10AM') + '</td>');
                //             SMTPMail.AppendBody('<td align="Center">' + FORMAT(ExcelBuffer7.UserID1) + '</td>');
                //             SMTPMail.AppendBody('<td align="Center">' + FORMAT(InvCount) + '</td>');
                //             SMTPMail.AppendBody('<td align="Center">' + FORMAT(CreditCount) + '</td>');
                //             SMTPMail.AppendBody('<td align="Center">' + FORMAT(PaymentCount) + '</td>');
                //             SMTPMail.AppendBody('<td align="Center">' + FORMAT(TotalCount) + '</td>');
                //             SMTPMail.AppendBody('</tr>');
                //         END;

                //     UNTIL "User Setup3".NEXT = 0;
                // SMTPMail.AppendBody('<td align="Center">' + FORMAT('') + '</td>');
                // SMTPMail.AppendBody('</table>');


                // SMTPMail.AppendBody('<BR>');
                // SMTPMail.AppendBody('Table for Entries from 10AM to 12AM');
                // SMTPMail.AppendBody('<BR>');

                // SMTPMail.AppendBody('<table cellspacing="10"  style="border-spacing: 0px;" border="1">' +
                // '<col width="250"><col width="50"><col width="50">' +
                //  '<col width="50"><col width="50"><col width="50">' +
                //  '<tr><th align="Center">Time</th>' +
                //  '<th align="Center">User Name</th>' +
                //  '<th align="Center">Posted Sales Invoice</th>' +
                //  '<th align="Center">Posted Credit Memo</th>' +
                //  '<th align="Center">Posted Payment</th>' +
                //  //'<th align="Center">Posted Journals</th>'+
                //  '<th align="Center">Total Count</th>');
                //SB-Comment End
                //SB-New code Start
                IF (InvCount + CreditCount + PaymentCount) > 0 THEN BEGIN
                    TotalCount := 0;
                    TotalCount := InvCount + CreditCount + PaymentCount;
                    SMTPMail.AppendToBody('<tr>');
                    SMTPMail.AppendToBody('<td align="Center">' + FORMAT('05_TO_10AM') + '</td>');
                    SMTPMail.AppendToBody('<td align="Center">' + FORMAT(ExcelBuffer7.UserID1) + '</td>');
                    SMTPMail.AppendToBody('<td align="Center">' + FORMAT(InvCount) + '</td>');
                    SMTPMail.AppendToBody('<td align="Center">' + FORMAT(CreditCount) + '</td>');
                    SMTPMail.AppendToBody('<td align="Center">' + FORMAT(PaymentCount) + '</td>');
                    SMTPMail.AppendToBody('<td align="Center">' + FORMAT(TotalCount) + '</td>');
                    SMTPMail.AppendToBody('</tr>');
                END;

            UNTIL "User Setup3".NEXT = 0;
        SMTPMail.AppendToBody('<td align="Center">' + FORMAT('') + '</td>');
        SMTPMail.AppendToBody('</table>');


        SMTPMail.AppendToBody('<BR>');
        SMTPMail.AppendToBody('Table for Entries from 10AM to 12AM');
        SMTPMail.AppendToBody('<BR>');

        SMTPMail.AppendToBody('<table cellspacing="10"  style="border-spacing: 0px;" border="1">' +
        '<col width="250"><col width="50"><col width="50">' +
         '<col width="50"><col width="50"><col width="50">' +
         '<tr><th align="Center">Time</th>' +
         '<th align="Center">User Name</th>' +
         '<th align="Center">Posted Sales Invoice</th>' +
         '<th align="Center">Posted Credit Memo</th>' +
         '<th align="Center">Posted Payment</th>' +
         //'<th align="Center">Posted Journals</th>'+
         '<th align="Center">Total Count</th>');
        //SB-New Code end

        "User Setup3".RESET;
        "User Setup3".SETFILTER("User Setup3"."User ID", '<>%1 & <>%2', 'SVC_NAV_API', 'BIJU.KURUP');
        IF "User Setup3".FIND('-') THEN
            REPEAT

                InvCount := 0;
                CreditCount := 0;
                PaymentCount := 0;

                ExcelBuffer7.SETCURRENTKEY(Type);
                ExcelBuffer7.RESET;
                ExcelBuffer7.SETFILTER(ExcelBuffer7.Formula, 'USER COUNT SALES');
                ExcelBuffer7.SETFILTER(ExcelBuffer7.UserID1, "User Setup3"."User ID");
                ExcelBuffer7.SETFILTER(ExcelBuffer7.Type, '10_TO_12AM');//00_TO_05AM');
                IF ExcelBuffer7.FIND('-') THEN
                    REPEAT
                        IF ExcelBuffer7.Formula2 = 'Invoice' THEN
                            InvCount := InvCount + 1;
                        IF ExcelBuffer7.Formula2 = 'CREDIT MEMO' THEN
                            CreditCount := CreditCount + 1;

                        IF ExcelBuffer7.Formula2 = 'Payment' THEN
                            PaymentCount := PaymentCount + 1;

                    UNTIL ExcelBuffer7.NEXT = 0;

                //SB-Comment Start
                //         IF (InvCount + CreditCount + PaymentCount) > 0 THEN BEGIN
                //             TotalCount := 0;
                //             TotalCount := InvCount + CreditCount + PaymentCount;

                //             SMTPMail.AppendToBody('<tr>');
                //             SMTPMail.AppendBody('<td align="Center">' + FORMAT('10_TO_12AM') + '</td>');
                //             SMTPMail.AppendBody('<td align="Center">' + FORMAT(ExcelBuffer7.UserID1) + '</td>');
                //             SMTPMail.AppendBody('<td align="Center">' + FORMAT(InvCount) + '</td>');
                //             SMTPMail.AppendBody('<td align="Center">' + FORMAT(CreditCount) + '</td>');
                //             SMTPMail.AppendBody('<td align="Center">' + FORMAT(PaymentCount) + '</td>');
                //             SMTPMail.AppendBody('<td align="Center">' + FORMAT(TotalCount) + '</td>');

                //             SMTPMail.AppendBody('</tr>');
                //         END;

                //     UNTIL "User Setup3".NEXT = 0;

                // SMTPMail.AppendBody('<td align="Center">' + FORMAT('') + '</td>');
                // SMTPMail.AppendBody('</table>');

                // SMTPMail.AppendBody('<BR><BR>');
                // SMTPMail.AppendBody('Kind Regards,');
                // SMTPMail.AppendBody('<BR><BR>');
                // SMTPMail.AppendBody('Dynamics');
                // SMTPMail.Send();
                //SB-Comment End
                //SB-New Code start
                IF (InvCount + CreditCount + PaymentCount) > 0 THEN BEGIN
                    TotalCount := 0;
                    TotalCount := InvCount + CreditCount + PaymentCount;

                    SMTPMail.AppendToBody('<tr>');
                    SMTPMail.AppendToBody('<td align="Center">' + FORMAT('10_TO_12AM') + '</td>');
                    SMTPMail.AppendToBody('<td align="Center">' + FORMAT(ExcelBuffer7.UserID1) + '</td>');
                    SMTPMail.AppendToBody('<td align="Center">' + FORMAT(InvCount) + '</td>');
                    SMTPMail.AppendToBody('<td align="Center">' + FORMAT(CreditCount) + '</td>');
                    SMTPMail.AppendToBody('<td align="Center">' + FORMAT(PaymentCount) + '</td>');
                    SMTPMail.AppendToBody('<td align="Center">' + FORMAT(TotalCount) + '</td>');

                    SMTPMail.AppendToBody('</tr>');
                END;

            UNTIL "User Setup3".NEXT = 0;

        SMTPMail.AppendToBody('<td align="Center">' + FORMAT('') + '</td>');
        SMTPMail.AppendToBody('</table>');

        SMTPMail.AppendToBody('<BR><BR>');
        SMTPMail.AppendToBody('Kind Regards,');
        SMTPMail.AppendToBody('<BR><BR>');
        SMTPMail.AppendToBody('Dynamics');
        // SMTPSend.Send(SMTPMail);
        //SB-New code end


        IF GUIALLOWED THEN
            MESSAGE('DONE');
    end;

    procedure Account5780VATReportDataAUS()
    var
        "G/L Account": Record "G/L Account";
        "G/L Account1": Record "G/L Account";
        NetChange1: Decimal;
        FirstDate: Date;
        LastDate: Date;
        Balance: Decimal;
        Total5780: Decimal;
        GrandTotal: Decimal;
        VATEntry: Record "VAT Entry";
        VATSalesTotal: Decimal;
        VATPurchaseTotal: Decimal;
        GrandVATEntryTotal: Decimal;
        "G/L Entry": Record "G/L Entry";
        GLTotal: Decimal;
        "General Ledger Setup": Record "General Ledger Setup";
        Difference1: Decimal;


    begin

        FirstDate := CALCDATE('-CM', TODAY);
        LastDate := CALCDATE('CM', TODAY);

        "General Ledger Setup".GET;

        FirstDate := "General Ledger Setup"."VAT Entry Start Date";//010720D;
        LastDate := "General Ledger Setup"."VAT Entry End Date"; //300920D;

        CLEAR(SMTPMail);
        //SB-Comment Start
        // SMTPMail.CreateMessage('Dynamics', 'Dynamics@theknowledgeAcademy.com', 'martha.folkes@theknowledgeacademy.com',
        //                    'Auto Email for G/L Account 5780', '', TRUE);// ,'',TRUE);//for ' +COMPANYNAME ,'',TRUE);
        //SB-Comment End

        //SB-New code start
        SMTPMail.Create('martha.folkes@theknowledgeacademy.com', 'Auto Email for G/L Account 5780', '', TRUE);
        //SB-New code end

        //SMTPMail.AddBCC('biju.kurup@theknowledgeacademy.com');

        //SB-Comment Start
        // SMTPMail.AppendBody('Hi');
        // SMTPMail.AppendBody('<BR><BR>');
        // SMTPMail.AppendBody('Below details are for G/L Account 5780. Date Filter  ');
        // SMTPMail.AppendBody(FORMAT(FirstDate) + '  ' + FORMAT(LastDate));
        // SMTPMail.AppendBody('<BR><BR>');

        // SMTPMail.AppendBody('<table cellspacing="10"  style="border-spacing: 0px;" border="1">' +
        // '<col width="250"><col width="100"><col width="100">' +
        //  // '<col width="100"><col width="100"><col width="150"><col width="150">'+

        //  '<tr><th align="Center">Company Name</th>' +
        //  '<th align="Center">G/L Account</th>' +
        //  '<th align="Center">Month Net Change</th>');
        //SB-Comment End
        //SB-New code start
        SMTPMail.AppendToBody('Hi');
        SMTPMail.AppendToBody('<BR><BR>');
        SMTPMail.AppendToBody('Below details are for G/L Account 5780. Date Filter  ');
        SMTPMail.AppendToBody(FORMAT(FirstDate) + '  ' + FORMAT(LastDate));
        SMTPMail.AppendToBody('<BR><BR>');

        SMTPMail.AppendToBody('<table cellspacing="10"  style="border-spacing: 0px;" border="1">' +
        '<col width="250"><col width="100"><col width="100">' +
         // '<col width="100"><col width="100"><col width="150"><col width="150">'+

         '<tr><th align="Center">Company Name</th>' +
         '<th align="Center">G/L Account</th>' +
         '<th align="Center">Month Net Change</th>');
        //SB-New code end

        Company1.SETFILTER(Company1.Name, '%1', 'The Knowledge Academy Pty Ltd.');
        IF Company1.FIND('-') THEN
            REPEAT

                NetChange1 := 0;
                Balance := 0;

                "G/L Account".CHANGECOMPANY(Company1.Name);
                "G/L Account1".CHANGECOMPANY(Company1.Name);

                "G/L Account1".SETFILTER("G/L Account1"."Date Filter", '%1..%2', FirstDate, LastDate);
                "G/L Account1".SETFILTER("G/L Account1"."No.", '5780');
                IF "G/L Account1".FIND('-') THEN BEGIN
                    "G/L Account1".CALCFIELDS("Net Change");
                    NetChange1 := "G/L Account1"."Net Change";
                END;
                Total5780 := NetChange1;

                //SB-Commenet Start
                //         SMTPMail.AppendBody('<tr>');
                //         SMTPMail.AppendBody('<td align="Center">' + FORMAT(Company1.Name) + '</td>');
                //         SMTPMail.AppendBody('<td align="Center">' + FORMAT("G/L Account1"."No.") + '</td>');
                //         SMTPMail.AppendBody('<td align="Center">' + FORMAT(NetChange1, 0, '<Precision,2:2><Standard Format,2>') + '</td>');

                //         SMTPMail.AppendBody('</tr>');


                //         GrandTotal := Total5780;

                //         SMTPMail.AppendBody('<tr>');
                //         SMTPMail.AppendBody('<td align="Center">' + FORMAT(Company1.Name) + '</td>');
                //         SMTPMail.AppendBody('<td align="Center">' + FORMAT('Total') + '</td>');
                //         SMTPMail.AppendBody('<td align="Center">' + FORMAT(GrandTotal, 0, '<Precision,2:2><Standard Format,2>') + '</td>');
                //         SMTPMail.AppendBody('</tr>');

                //     UNTIL Company1.NEXT = 0;



                // SMTPMail.AppendBody('</table>');

                // SMTPMail.AppendBody('<BR>');

                // SMTPMail.AppendBody('<table cellspacing="10"  style="border-spacing: 0px;" border="1">' +
                // '<col width="300"><col width="200"><col width="100">' +
                //  //     '<col width="100"><col width="100"><col width="150"><col width="150">'+

                //  '<tr><th align="Center">Company Name</th>' +
                //  '<th align="Center">VAT Entry Data</th>' +
                //  '<th align="Center"></th>');
                //SB-Comment End
                //SB-New code start
                SMTPMail.AppendToBody('<tr>');
                SMTPMail.AppendToBody('<td align="Center">' + FORMAT(Company1.Name) + '</td>');
                SMTPMail.AppendToBody('<td align="Center">' + FORMAT("G/L Account1"."No.") + '</td>');
                SMTPMail.AppendToBody('<td align="Center">' + FORMAT(NetChange1, 0, '<Precision,2:2><Standard Format,2>') + '</td>');

                SMTPMail.AppendToBody('</tr>');


                GrandTotal := Total5780;

                SMTPMail.AppendToBody('<tr>');
                SMTPMail.AppendToBody('<td align="Center">' + FORMAT(Company1.Name) + '</td>');
                SMTPMail.AppendToBody('<td align="Center">' + FORMAT('Total') + '</td>');
                SMTPMail.AppendToBody('<td align="Center">' + FORMAT(GrandTotal, 0, '<Precision,2:2><Standard Format,2>') + '</td>');
                SMTPMail.AppendToBody('</tr>');

            UNTIL Company1.NEXT = 0;



        SMTPMail.AppendToBody('</table>');

        SMTPMail.AppendToBody('<BR>');

        SMTPMail.AppendToBody('<table cellspacing="10"  style="border-spacing: 0px;" border="1">' +
        '<col width="300"><col width="200"><col width="100">' +
         //     '<col width="100"><col width="100"><col width="150"><col width="150">'+

         '<tr><th align="Center">Company Name</th>' +
         '<th align="Center">VAT Entry Data</th>' +
         '<th align="Center"></th>');
        //SB-New Code ENd

        VATEntry.CHANGECOMPANY(Company1.Name);

        VATEntry.SETCURRENTKEY(Type, Closed, "Tax Jurisdiction Code", "Use Tax", "Posting Date");
        VATEntry.SETFILTER(Type, 'Sale');
        VATEntry.SETFILTER("Posting Date", '%1..%2', FirstDate, LastDate);
        IF VATEntry.FIND('-') THEN
            REPEAT
                VATSalesTotal := VATSalesTotal + VATEntry.Amount;
            UNTIL VATEntry.NEXT = 0;


        //SB-Comment Start
        // SMTPMail.AppendBody('<tr>');
        // SMTPMail.AppendBody('<td align="Center">' + FORMAT(Company1.Name) + '</td>');
        // SMTPMail.AppendBody('<td align="Center">' + FORMAT('VAT Sales Total') + '</td>');
        // SMTPMail.AppendBody('<td align="Center">' + FORMAT(VATSalesTotal, 0, '<Precision,2:2><Standard Format,2>') + '</td>');
        // SMTPMail.AppendBody('</tr>');
        //SB-Comment end

        //SB-New Code Start
        SMTPMail.AppendToBody('<tr>');
        SMTPMail.AppendToBody('<td align="Center">' + FORMAT(Company1.Name) + '</td>');
        SMTPMail.AppendToBody('<td align="Center">' + FORMAT('VAT Sales Total') + '</td>');
        SMTPMail.AppendToBody('<td align="Center">' + FORMAT(VATSalesTotal, 0, '<Precision,2:2><Standard Format,2>') + '</td>');
        SMTPMail.AppendToBody('</tr>');
        //SB-New code end


        VATEntry.SETCURRENTKEY(Type, Closed, "Tax Jurisdiction Code", "Use Tax", "Posting Date");
        VATEntry.SETFILTER(Type, 'Purchase');
        VATEntry.SETFILTER("Posting Date", '%1..%2', FirstDate, LastDate);
        IF VATEntry.FIND('-') THEN
            REPEAT
                VATPurchaseTotal := VATPurchaseTotal + VATEntry.Amount;
            UNTIL VATEntry.NEXT = 0;

        //SB-Comment start
        // SMTPMail.AppendBody('<tr>');
        // SMTPMail.AppendBody('<td align="Center">' + FORMAT(Company1.Name) + '</td>');
        // SMTPMail.AppendBody('<td align="Center">' + FORMAT('VAT Purchase Total') + '</td>');
        // SMTPMail.AppendBody('<td align="Center">' + FORMAT(VATPurchaseTotal, 0, '<Precision,2:2><Standard Format,2>') + '</td>');
        // SMTPMail.AppendBody('</tr>');
        //SB-Comment End

        //SB-New code start
        SMTPMail.AppendToBody('<tr>');
        SMTPMail.AppendToBody('<td align="Center">' + FORMAT(Company1.Name) + '</td>');
        SMTPMail.AppendToBody('<td align="Center">' + FORMAT('VAT Purchase Total') + '</td>');
        SMTPMail.AppendToBody('<td align="Center">' + FORMAT(VATPurchaseTotal, 0, '<Precision,2:2><Standard Format,2>') + '</td>');
        SMTPMail.AppendToBody('</tr>');
        //SB-New code end


        "G/L Entry".CHANGECOMPANY(Company1.Name);

        "G/L Entry".SETCURRENTKEY("G/L Account No.", "Posting Date");
        "G/L Entry".SETFILTER("G/L Account No.", '%1', '5780');
        "G/L Entry".SETFILTER("Posting Date", '%1..%2', FirstDate, LastDate);
        "G/L Entry".SETFILTER("Document Type", '%1', "G/L Entry"."Document Type"::" ");//' ');//"Document Type"::" ");
        "G/L Entry".SETFILTER("Source Code", 'GENJNL');
        IF "G/L Entry".FIND('-') THEN
            REPEAT
                GLTotal := GLTotal + "G/L Entry".Amount;
            UNTIL "G/L Entry".NEXT = 0;


        //SB-comment start
        // SMTPMail.AppendBody('<tr>');
        // SMTPMail.AppendBody('<td align="Center">' + FORMAT(Company1.Name) + '</td>');
        // SMTPMail.AppendBody('<td align="Center">' + FORMAT('VAT Journal Total') + '</td>');
        // SMTPMail.AppendBody('<td align="Center">' + FORMAT(GLTotal, 0, '<Precision,2:2><Standard Format,2>') + '</td>');
        // SMTPMail.AppendBody('</tr>');

        // GrandVATEntryTotal := VATSalesTotal + VATPurchaseTotal + GLTotal;

        // SMTPMail.AppendBody('<tr>');
        // SMTPMail.AppendBody('<td align="Center">' + FORMAT(Company1.Name) + '</td>');
        // SMTPMail.AppendBody('<td align="Center">' + FORMAT('VAT Total') + '</td>');
        // SMTPMail.AppendBody('<td align="Center">' + FORMAT(GrandVATEntryTotal, 0, '<Precision,2:2><Standard Format,2>') + '</td>');
        // SMTPMail.AppendBody('</tr>');


        // SMTPMail.AppendBody('</table>');


        // SMTPMail.AppendBody('<BR>');

        // SMTPMail.AppendBody('<table cellspacing="10"  style="border-spacing: 0px;" border="1">' +
        // '<col width="250"><col width="100"><col width="100">' +
        //  '<col width="100"><col width="100"><col width="150"><col width="150">' +

        //  '<tr><th align="Center">Company Name</th>' +
        //  '<th align="Center"></th>' +
        //  '<th align="Center">Difference</th>');

        // Difference1 := GrandTotal - GrandVATEntryTotal;

        // SMTPMail.AppendBody('<tr>');
        // SMTPMail.AppendBody('<td align="Center">' + FORMAT(Company1.Name) + '</td>');
        // SMTPMail.AppendBody('<td align="Center">' + FORMAT('') + '</td>');
        // SMTPMail.AppendBody('<td align="Center">' + FORMAT(Difference1, 0, '<Precision,2:2><Standard Format,2>') + '</td>');
        // SMTPMail.AppendBody('</tr>');


        // SMTPMail.AppendBody('</table>');
        //SB-Comment End
        //SB-New code start
        SMTPMail.AppendToBody('<tr>');
        SMTPMail.AppendToBody('<td align="Center">' + FORMAT(Company1.Name) + '</td>');
        SMTPMail.AppendToBody('<td align="Center">' + FORMAT('VAT Journal Total') + '</td>');
        SMTPMail.AppendToBody('<td align="Center">' + FORMAT(GLTotal, 0, '<Precision,2:2><Standard Format,2>') + '</td>');
        SMTPMail.AppendToBody('</tr>');

        GrandVATEntryTotal := VATSalesTotal + VATPurchaseTotal + GLTotal;

        SMTPMail.AppendToBody('<tr>');
        SMTPMail.AppendToBody('<td align="Center">' + FORMAT(Company1.Name) + '</td>');
        SMTPMail.AppendToBody('<td align="Center">' + FORMAT('VAT Total') + '</td>');
        SMTPMail.AppendToBody('<td align="Center">' + FORMAT(GrandVATEntryTotal, 0, '<Precision,2:2><Standard Format,2>') + '</td>');
        SMTPMail.AppendToBody('</tr>');


        SMTPMail.AppendToBody('</table>');


        SMTPMail.AppendToBody('<BR>');

        SMTPMail.AppendToBody('<table cellspacing="10"  style="border-spacing: 0px;" border="1">' +
        '<col width="250"><col width="100"><col width="100">' +
         '<col width="100"><col width="100"><col width="150"><col width="150">' +

         '<tr><th align="Center">Company Name</th>' +
         '<th align="Center"></th>' +
         '<th align="Center">Difference</th>');

        Difference1 := GrandTotal - GrandVATEntryTotal;

        SMTPMail.AppendToBody('<tr>');
        SMTPMail.AppendToBody('<td align="Center">' + FORMAT(Company1.Name) + '</td>');
        SMTPMail.AppendToBody('<td align="Center">' + FORMAT('') + '</td>');
        SMTPMail.AppendToBody('<td align="Center">' + FORMAT(Difference1, 0, '<Precision,2:2><Standard Format,2>') + '</td>');
        SMTPMail.AppendToBody('</tr>');


        SMTPMail.AppendToBody('</table>');
        //SB-New code end

        // {
        //     SMTPMail.AppendBody('<BR><BR>');
        //         SMTPMail.AppendBody('Kind Regards,');
        //         SMTPMail.AppendBody('<BR><BR>');
        //         SMTPMail.AppendBody('Dynamics');
        //         SMTPMail.Send();

        // }
        Account5780VATReportDataNZ;

        //IF GUIALLOWED THEN
        //MESSAGE ('DONE');
    end;

    procedure Account5780VATReportDataNZ()
    var
        "G/L Account": Record "G/L Account";
        "G/L Account1": Record "G/L Account";
        NetChange1: Decimal;
        FirstDate: Date;
        LastDate: Date;
        Balance: Decimal;
        Total5780: Decimal;
        GrandTotal: Decimal;
        VATEntry: Record "VAT Entry";
        VATSalesTotal: Decimal;
        VATPurchaseTotal: Decimal;
        GrandVATEntryTotal: Decimal;
        "G/L Entry": Record "G/L Entry";
        GLTotal: Decimal;
        "General Ledger Setup": Record "General Ledger Setup";
        Difference1: Decimal;

    begin

        FirstDate := CALCDATE('-CM', TODAY);
        LastDate := CALCDATE('CM', TODAY);

        "General Ledger Setup".GET;

        FirstDate := "General Ledger Setup"."VAT Entry Start DateNZ";//010720D;
        LastDate := "General Ledger Setup"."VAT Entry End DateNZ"; //300920D;

        // {
        // CLEAR(SMTPMail);
        // SMTPMail.CreateMessage('Dynamics','Dynamics@theknowledgeAcademy.com','biju.kurup@theknowledgeacademy.com',
        //                    'Auto Email for G/L Account 5780','',TRUE);// ,'',TRUE);//for ' +COMPANYNAME ,'',TRUE);

        // //SMTPMail.AddBCC('biju.kurup@theknowledgeacademy.com');

        // SMTPMail.AppendBody('Hi');
        // SMTPMail.AppendBody('<BR><BR>');
        // SMTPMail.AppendBody('Below details are for G/L Account 5780. Date Filter  ');
        // SMTPMail.AppendBody(FORMAT(FirstDate) + '  '+FORMAT(LastDate));
        // SMTPMail.AppendBody('<BR><BR>');
        // }

        //SB-comment start
        // SMTPMail.AppendBody('<BR><BR>');

        // SMTPMail.AppendBody('<table cellspacing="10"  style="border-spacing: 0px;" border="1">' +
        // '<col width="250"><col width="100"><col width="100">' +
        //  // '<col width="100"><col width="100"><col width="150"><col width="150">'+

        //  '<tr><th align="Center">Company Name</th>' +
        //  '<th align="Center">G/L Account</th>' +
        //  '<th align="Center">Month Net Change</th>');
        //SB-Comment End
        //SB-New code start
        SMTPMail.AppendToBody('<BR><BR>');

        SMTPMail.AppendToBody('<table cellspacing="10"  style="border-spacing: 0px;" border="1">' +
        '<col width="250"><col width="100"><col width="100">' +
         // '<col width="100"><col width="100"><col width="150"><col width="150">'+

         '<tr><th align="Center">Company Name</th>' +
         '<th align="Center">G/L Account</th>' +
         '<th align="Center">Month Net Change</th>');
        //Sb-New code end

        Company1.SETFILTER(Company1.Name, '%1', 'TKA New Zealand Ltd.');
        IF Company1.FIND('-') THEN
            REPEAT

                NetChange1 := 0;
                Balance := 0;

                "G/L Account".CHANGECOMPANY(Company1.Name);
                "G/L Account1".CHANGECOMPANY(Company1.Name);

                "G/L Account1".SETFILTER("G/L Account1"."Date Filter", '%1..%2', FirstDate, LastDate);
                "G/L Account1".SETFILTER("G/L Account1"."No.", '5780');
                IF "G/L Account1".FIND('-') THEN BEGIN
                    "G/L Account1".CALCFIELDS("Net Change");
                    NetChange1 := "G/L Account1"."Net Change";
                END;
                Total5780 := NetChange1;

                //SB-coment Start
                // SMTPMail.AppendBody('<tr>');
                // SMTPMail.AppendBody('<td align="Center">' + FORMAT(Company1.Name) + '</td>');
                // SMTPMail.AppendBody('<td align="Center">' + FORMAT("G/L Account1"."No.") + '</td>');
                // SMTPMail.AppendBody('<td align="Center">' + FORMAT(NetChange1, 0, '<Precision,2:2><Standard Format,2>') + '</td>');

                // SMTPMail.AppendBody('</tr>');
                //SB-Commenet end
                //SB-new code start
                SMTPMail.AppendToBody('<tr>');
                SMTPMail.AppendToBody('<td align="Center">' + FORMAT(Company1.Name) + '</td>');
                SMTPMail.AppendToBody('<td align="Center">' + FORMAT("G/L Account1"."No.") + '</td>');
                SMTPMail.AppendToBody('<td align="Center">' + FORMAT(NetChange1, 0, '<Precision,2:2><Standard Format,2>') + '</td>');

                SMTPMail.AppendToBody('</tr>');
                //SB-New code end


                GrandTotal := Total5780;

                //SB-coment Start
                // SMTPMail.AppendBody('<tr>');
                // SMTPMail.AppendBody('<td align="Center">' + FORMAT(Company1.Name) + '</td>');
                // SMTPMail.AppendBody('<td align="Center">' + FORMAT('Total') + '</td>');
                // SMTPMail.AppendBody('<td align="Center">' + FORMAT(GrandTotal, 0, '<Precision,2:2><Standard Format,2>') + '</td>');
                // SMTPMail.AppendBody('</tr>');
                //SB-Commenet end
                //SB-new code start
                SMTPMail.AppendToBody('<tr>');
                SMTPMail.AppendToBody('<td align="Center">' + FORMAT(Company1.Name) + '</td>');
                SMTPMail.AppendToBody('<td align="Center">' + FORMAT('Total') + '</td>');
                SMTPMail.AppendToBody('<td align="Center">' + FORMAT(GrandTotal, 0, '<Precision,2:2><Standard Format,2>') + '</td>');
                SMTPMail.AppendToBody('</tr>');
            //SB-New code end

            UNTIL Company1.NEXT = 0;



        //SB-comment start
        // SMTPMail.AppendBody('</table>');

        // SMTPMail.AppendBody('<BR>');

        // SMTPMail.AppendBody('<table cellspacing="10"  style="border-spacing: 0px;" border="1">' +
        // '<col width="300"><col width="200"><col width="100">' +
        //  //     '<col width="100"><col width="100"><col width="150"><col width="150">'+

        //  '<tr><th align="Center">Company Name</th>' +
        //  '<th align="Center">VAT Entry Data</th>' +
        //  '<th align="Center"></th>');
        //SB-comment end
        //SB-new code start
        SMTPMail.AppendToBody('</table>');

        SMTPMail.AppendToBody('<BR>');

        SMTPMail.AppendToBody('<table cellspacing="10"  style="border-spacing: 0px;" border="1">' +
        '<col width="300"><col width="200"><col width="100">' +
         //     '<col width="100"><col width="100"><col width="150"><col width="150">'+

         '<tr><th align="Center">Company Name</th>' +
         '<th align="Center">VAT Entry Data</th>' +
         '<th align="Center"></th>');
        //SB-new code end

        VATEntry.CHANGECOMPANY(Company1.Name);

        VATEntry.SETCURRENTKEY(Type, Closed, "Tax Jurisdiction Code", "Use Tax", "Posting Date");
        VATEntry.SETFILTER(Type, 'Sale');
        VATEntry.SETFILTER("Posting Date", '%1..%2', FirstDate, LastDate);
        IF VATEntry.FIND('-') THEN
            REPEAT
                VATSalesTotal := VATSalesTotal + VATEntry.Amount;
            UNTIL VATEntry.NEXT = 0;


        //SB-Comment start
        // SMTPMail.AppendBody('<tr>');
        // SMTPMail.AppendBody('<td align="Center">' + FORMAT(Company1.Name) + '</td>');
        // SMTPMail.AppendBody('<td align="Center">' + FORMAT('VAT Sales Total') + '</td>');
        // SMTPMail.AppendBody('<td align="Center">' + FORMAT(VATSalesTotal, 0, '<Precision,2:2><Standard Format,2>') + '</td>');
        // SMTPMail.AppendBody('</tr>');
        //SB-Comment end
        //SB-New code start
        SMTPMail.AppendtoBody('<tr>');
        SMTPMail.AppendtoBody('<td align="Center">' + FORMAT(Company1.Name) + '</td>');
        SMTPMail.AppendtoBody('<td align="Center">' + FORMAT('VAT Sales Total') + '</td>');
        SMTPMail.AppendtoBody('<td align="Center">' + FORMAT(VATSalesTotal, 0, '<Precision,2:2><Standard Format,2>') + '</td>');
        SMTPMail.AppendtoBody('</tr>');
        //SB-new code end


        VATEntry.SETCURRENTKEY(Type, Closed, "Tax Jurisdiction Code", "Use Tax", "Posting Date");
        VATEntry.SETFILTER(Type, 'Purchase');
        VATEntry.SETFILTER("Posting Date", '%1..%2', FirstDate, LastDate);
        IF VATEntry.FIND('-') THEN
            REPEAT
                VATPurchaseTotal := VATPurchaseTotal + VATEntry.Amount;
            UNTIL VATEntry.NEXT = 0;

        //SB-Comment Start
        // SMTPMail.AppendBody('<tr>');
        // SMTPMail.AppendBody('<td align="Center">' + FORMAT(Company1.Name) + '</td>');
        // SMTPMail.AppendBody('<td align="Center">' + FORMAT('VAT Purchase Total') + '</td>');
        // SMTPMail.AppendBody('<td align="Center">' + FORMAT(VATPurchaseTotal, 0, '<Precision,2:2><Standard Format,2>') + '</td>');
        // SMTPMail.AppendBody('</tr>');
        //SB-Comment End
        //SB-New code start
        SMTPMail.AppendToBody('<tr>');
        SMTPMail.AppendToBody('<td align="Center">' + FORMAT(Company1.Name) + '</td>');
        SMTPMail.AppendToBody('<td align="Center">' + FORMAT('VAT Purchase Total') + '</td>');
        SMTPMail.AppendToBody('<td align="Center">' + FORMAT(VATPurchaseTotal, 0, '<Precision,2:2><Standard Format,2>') + '</td>');
        SMTPMail.AppendToBody('</tr>');
        //SB-New code end


        "G/L Entry".CHANGECOMPANY(Company1.Name);

        "G/L Entry".SETCURRENTKEY("G/L Account No.", "Posting Date");
        "G/L Entry".SETFILTER("G/L Account No.", '%1', '5780');
        "G/L Entry".SETFILTER("Posting Date", '%1..%2', FirstDate, LastDate);
        "G/L Entry".SETFILTER("Document Type", '%1', "G/L Entry"."Document Type"::" ");//' ');//"Document Type"::" ");
        "G/L Entry".SETFILTER("Source Code", 'GENJNL');
        IF "G/L Entry".FIND('-') THEN
            REPEAT
                GLTotal := GLTotal + "G/L Entry".Amount;
            UNTIL "G/L Entry".NEXT = 0;

        //Sb-comment start
        // SMTPMail.AppendBody('<tr>');
        // SMTPMail.AppendBody('<td align="Center">' + FORMAT(Company1.Name) + '</td>');
        // SMTPMail.AppendBody('<td align="Center">' + FORMAT('VAT Journal Total') + '</td>');
        // SMTPMail.AppendBody('<td align="Center">' + FORMAT(GLTotal, 0, '<Precision,2:2><Standard Format,2>') + '</td>');
        // SMTPMail.AppendBody('</tr>');

        // GrandVATEntryTotal := VATSalesTotal + VATPurchaseTotal + GLTotal;

        // SMTPMail.AppendBody('<tr>');
        // SMTPMail.AppendBody('<td align="Center">' + FORMAT(Company1.Name) + '</td>');
        // SMTPMail.AppendBody('<td align="Center">' + FORMAT('VAT Total') + '</td>');
        // SMTPMail.AppendBody('<td align="Center">' + FORMAT(GrandVATEntryTotal, 0, '<Precision,2:2><Standard Format,2>') + '</td>');
        // SMTPMail.AppendBody('</tr>');


        // SMTPMail.AppendBody('</table>');
        // SMTPMail.AppendBody('<BR>');

        // SMTPMail.AppendBody('<table cellspacing="10"  style="border-spacing: 0px;" border="1">' +
        // '<col width="250"><col width="100"><col width="100">' +
        //  '<col width="100"><col width="100"><col width="150"><col width="150">' +

        //  '<tr><th align="Center">Company Name</th>' +
        //  '<th align="Center"></th>' +
        //  '<th align="Center">Difference</th>');

        // Difference1 := GrandTotal - GrandVATEntryTotal;

        // SMTPMail.AppendBody('<tr>');
        // SMTPMail.AppendBody('<td align="Center">' + FORMAT(Company1.Name) + '</td>');
        // SMTPMail.AppendBody('<td align="Center">' + FORMAT('') + '</td>');
        // SMTPMail.AppendBody('<td align="Center">' + FORMAT(Difference1, 0, '<Precision,2:2><Standard Format,2>') + '</td>');
        // SMTPMail.AppendBody('</tr>');


        // SMTPMail.AppendBody('</table>');
        //SB-comment end
        //SB-new code start
        SMTPMail.AppendToBody('<tr>');
        SMTPMail.AppendToBody('<td align="Center">' + FORMAT(Company1.Name) + '</td>');
        SMTPMail.AppendToBody('<td align="Center">' + FORMAT('VAT Journal Total') + '</td>');
        SMTPMail.AppendToBody('<td align="Center">' + FORMAT(GLTotal, 0, '<Precision,2:2><Standard Format,2>') + '</td>');
        SMTPMail.AppendToBody('</tr>');

        GrandVATEntryTotal := VATSalesTotal + VATPurchaseTotal + GLTotal;

        SMTPMail.AppendToBody('<tr>');
        SMTPMail.AppendToBody('<td align="Center">' + FORMAT(Company1.Name) + '</td>');
        SMTPMail.AppendToBody('<td align="Center">' + FORMAT('VAT Total') + '</td>');
        SMTPMail.AppendToBody('<td align="Center">' + FORMAT(GrandVATEntryTotal, 0, '<Precision,2:2><Standard Format,2>') + '</td>');
        SMTPMail.AppendToBody('</tr>');


        SMTPMail.AppendToBody('</table>');
        SMTPMail.AppendToBody('<BR>');

        SMTPMail.AppendToBody('<table cellspacing="10"  style="border-spacing: 0px;" border="1">' +
        '<col width="250"><col width="100"><col width="100">' +
         '<col width="100"><col width="100"><col width="150"><col width="150">' +

         '<tr><th align="Center">Company Name</th>' +
         '<th align="Center"></th>' +
         '<th align="Center">Difference</th>');

        Difference1 := GrandTotal - GrandVATEntryTotal;

        SMTPMail.AppendToBody('<tr>');
        SMTPMail.AppendToBody('<td align="Center">' + FORMAT(Company1.Name) + '</td>');
        SMTPMail.AppendToBody('<td align="Center">' + FORMAT('') + '</td>');
        SMTPMail.AppendToBody('<td align="Center">' + FORMAT(Difference1, 0, '<Precision,2:2><Standard Format,2>') + '</td>');
        SMTPMail.AppendToBody('</tr>');


        SMTPMail.AppendToBody('</table>');
        //SB-new code end

        Account5780VATReportDataCanada;

        // {
        //     SMTPMail.AppendBody('<BR><BR>');
        //     SMTPMail.AppendBody('Kind Regards,');
        //     SMTPMail.AppendBody('<BR><BR>');
        //     SMTPMail.AppendBody('Dynamics');
        //     SMTPMail.Send();

        // IF GUIALLOWED THEN
        // MESSAGE ('DONE');
        // }
    end;

    procedure Account5780VATReportDataCanada()
    var
        "G/L Account": Record "G/L Account";
        "G/L Account1": Record "G/L Account";
        NetChange1: Decimal;
        FirstDate: Date;
        LastDate: Date;
        Balance: Decimal;
        Total5780: Decimal;
        GrandTotal: Decimal;
        VATEntry: Record "VAT Entry";
        VATSalesTotal: Decimal;
        VATPurchaseTotal: Decimal;
        GrandVATEntryTotal: Decimal;
        "G/L Entry": Record "G/L Entry";
        GLTotal: Decimal;
        "General Ledger Setup": Record "General Ledger Setup";
        Difference1: Decimal;
    begin

        FirstDate := CALCDATE('-CM', TODAY);
        LastDate := CALCDATE('CM', TODAY);

        "General Ledger Setup".GET;

        FirstDate := "General Ledger Setup"."VAT Entry Start Date";//010720D;
        LastDate := "General Ledger Setup"."VAT Entry End Date"; //300920D;

        // {
        // CLEAR(SMTPMail);
        //         SMTPMail.CreateMessage('Dynamics', 'Dynamics@theknowledgeAcademy.com', 'biju.kurup@theknowledgeacademy.com',
        //                            'Auto Email for G/L Account 5780', '', TRUE);// ,'',TRUE);//for ' +COMPANYNAME ,'',TRUE);

        //         //SMTPMail.AddBCC('biju.kurup@theknowledgeacademy.com');

        //         SMTPMail.AppendBody('Hi');
        //         SMTPMail.AppendBody('<BR><BR>');
        //         SMTPMail.AppendBody('Below details are for G/L Account 5780. Date Filter  ');
        //         SMTPMail.AppendBody(FORMAT(FirstDate) + '  ' + FORMAT(LastDate));
        //         SMTPMail.AppendBody('<BR><BR>');
        // }

        //SB-comment start
        // SMTPMail.AppendBody('<BR><BR>');

        // SMTPMail.AppendBody('<table cellspacing="10"  style="border-spacing: 0px;" border="1">' +
        // '<col width="250"><col width="100"><col width="100">' +
        //  //'<col width="100"><col width="100"><col width="150"><col width="150">'+

        //  '<tr><th align="Center">Company Name</th>' +
        //  '<th align="Center">G/L Account</th>' +
        //  '<th align="Center">Month Net Change</th>');
        //Sb-Comemnt end

        //SB-new code start

        SMTPMail.AppendToBody('<BR><BR>');

        SMTPMail.AppendToBody('<table cellspacing="10"  style="border-spacing: 0px;" border="1">' +
        '<col width="250"><col width="100"><col width="100">' +
         //'<col width="100"><col width="100"><col width="150"><col width="150">'+

         '<tr><th align="Center">Company Name</th>' +
         '<th align="Center">G/L Account</th>' +
         '<th align="Center">Month Net Change</th>');
        //SB-new code end

        Company1.SETFILTER(Company1.Name, '%1', 'TKA Canada Corporation');
        IF Company1.FIND('-') THEN
            REPEAT

                NetChange1 := 0;
                Balance := 0;

                "G/L Account".CHANGECOMPANY(Company1.Name);
                "G/L Account1".CHANGECOMPANY(Company1.Name);

                "G/L Account1".SETFILTER("G/L Account1"."Date Filter", '%1..%2', FirstDate, LastDate);
                "G/L Account1".SETFILTER("G/L Account1"."No.", '5780');
                IF "G/L Account1".FIND('-') THEN BEGIN
                    "G/L Account1".CALCFIELDS("Net Change");
                    NetChange1 := "G/L Account1"."Net Change";
                END;
                Total5780 := NetChange1;

                //SB-Comment Start
                //         SMTPMail.AppendBody('<tr>');
                //         SMTPMail.AppendBody('<td align="Center">' + FORMAT(Company1.Name) + '</td>');
                //         SMTPMail.AppendBody('<td align="Center">' + FORMAT("G/L Account1"."No.") + '</td>');
                //         SMTPMail.AppendBody('<td align="Center">' + FORMAT(NetChange1, 0, '<Precision,2:2><Standard Format,2>') + '</td>');

                //         SMTPMail.AppendBody('</tr>');

                //         GrandTotal := Total5780;

                //         SMTPMail.AppendBody('<tr>');
                //         SMTPMail.AppendBody('<td align="Center">' + FORMAT(Company1.Name) + '</td>');
                //         SMTPMail.AppendBody('<td align="Center">' + FORMAT('Total') + '</td>');
                //         SMTPMail.AppendBody('<td align="Center">' + FORMAT(GrandTotal, 0, '<Precision,2:2><Standard Format,2>') + '</td>');
                //         SMTPMail.AppendBody('</tr>');

                //     UNTIL Company1.NEXT = 0;

                // SMTPMail.AppendBody('</table>');
                // SMTPMail.AppendBody('<BR>');
                // SMTPMail.AppendBody('<table cellspacing="10"  style="border-spacing: 0px;" border="1">' +
                // '<col width="300"><col width="200"><col width="100">' +
                //  //     '<col width="100"><col width="100"><col width="150"><col width="150">'+

                //  '<tr><th align="Center">Company Name</th>' +
                //  '<th align="Center">VAT Entry Data</th>' +
                //  '<th align="Center"></th>');
                //SB-comment End
                //SB-new code start
                SMTPMail.AppendtoBody('<tr>');
                SMTPMail.AppendtoBody('<td align="Center">' + FORMAT(Company1.Name) + '</td>');
                SMTPMail.AppendtoBody('<td align="Center">' + FORMAT("G/L Account1"."No.") + '</td>');
                SMTPMail.AppendtoBody('<td align="Center">' + FORMAT(NetChange1, 0, '<Precision,2:2><Standard Format,2>') + '</td>');

                SMTPMail.AppendtoBody('</tr>');

                GrandTotal := Total5780;

                SMTPMail.AppendtoBody('<tr>');
                SMTPMail.AppendtoBody('<td align="Center">' + FORMAT(Company1.Name) + '</td>');
                SMTPMail.AppendtoBody('<td align="Center">' + FORMAT('Total') + '</td>');
                SMTPMail.AppendtoBody('<td align="Center">' + FORMAT(GrandTotal, 0, '<Precision,2:2><Standard Format,2>') + '</td>');
                SMTPMail.AppendtoBody('</tr>');

            UNTIL Company1.NEXT = 0;

        SMTPMail.AppendtoBody('</table>');
        SMTPMail.AppendtoBody('<BR>');
        SMTPMail.AppendtoBody('<table cellspacing="10"  style="border-spacing: 0px;" border="1">' +
        '<col width="300"><col width="200"><col width="100">' +
         //     '<col width="100"><col width="100"><col width="150"><col width="150">'+

         '<tr><th align="Center">Company Name</th>' +
         '<th align="Center">VAT Entry Data</th>' +
         '<th align="Center"></th>');
        //SB-new code end

        VATEntry.CHANGECOMPANY(Company1.Name);

        VATEntry.SETCURRENTKEY(Type, Closed, "Tax Jurisdiction Code", "Use Tax", "Posting Date");
        VATEntry.SETFILTER(Type, 'Sale');
        VATEntry.SETFILTER("Posting Date", '%1..%2', FirstDate, LastDate);
        IF VATEntry.FIND('-') THEN
            REPEAT
                VATSalesTotal := VATSalesTotal + VATEntry.Amount;
            UNTIL VATEntry.NEXT = 0;


        //SB-Comment Start
        // SMTPMail.AppendBody('<tr>');
        // SMTPMail.AppendBody('<td align="Center">' + FORMAT(Company1.Name) + '</td>');
        // SMTPMail.AppendBody('<td align="Center">' + FORMAT('VAT Sales Total') + '</td>');
        // SMTPMail.AppendBody('<td align="Center">' + FORMAT(VATSalesTotal, 0, '<Precision,2:2><Standard Format,2>') + '</td>');
        // SMTPMail.AppendBody('</tr>');
        //SB-Comment End
        //SB-new code start
        SMTPMail.AppendToBody('<tr>');
        SMTPMail.AppendToBody('<td align="Center">' + FORMAT(Company1.Name) + '</td>');
        SMTPMail.AppendToBody('<td align="Center">' + FORMAT('VAT Sales Total') + '</td>');
        SMTPMail.AppendToBody('<td align="Center">' + FORMAT(VATSalesTotal, 0, '<Precision,2:2><Standard Format,2>') + '</td>');
        SMTPMail.AppendToBody('</tr>');
        //SB-new code end


        VATEntry.SETCURRENTKEY(Type, Closed, "Tax Jurisdiction Code", "Use Tax", "Posting Date");
        VATEntry.SETFILTER(Type, 'Purchase');
        VATEntry.SETFILTER("Posting Date", '%1..%2', FirstDate, LastDate);
        IF VATEntry.FIND('-') THEN
            REPEAT
                VATPurchaseTotal := VATPurchaseTotal + VATEntry.Amount;
            UNTIL VATEntry.NEXT = 0;

        //SB-Comment Start
        // SMTPMail.AppendBody('<tr>');
        // SMTPMail.AppendBody('<td align="Center">' + FORMAT(Company1.Name) + '</td>');
        // SMTPMail.AppendBody('<td align="Center">' + FORMAT('VAT Purchase Total') + '</td>');
        // SMTPMail.AppendBody('<td align="Center">' + FORMAT(VATPurchaseTotal, 0, '<Precision,2:2><Standard Format,2>') + '</td>');
        // SMTPMail.AppendBody('</tr>');
        // //SB-Comment End
        //SB-new code start
        SMTPMail.AppendToBody('<tr>');
        SMTPMail.AppendToBody('<td align="Center">' + FORMAT(Company1.Name) + '</td>');
        SMTPMail.AppendToBody('<td align="Center">' + FORMAT('VAT Purchase Total') + '</td>');
        SMTPMail.AppendToBody('<td align="Center">' + FORMAT(VATPurchaseTotal, 0, '<Precision,2:2><Standard Format,2>') + '</td>');
        SMTPMail.AppendToBody('</tr>');

        //SB-new code end


        "G/L Entry".CHANGECOMPANY(Company1.Name);

        "G/L Entry".SETCURRENTKEY("G/L Account No.", "Posting Date");
        "G/L Entry".SETFILTER("G/L Account No.", '%1', '5780');
        "G/L Entry".SETFILTER("Posting Date", '%1..%2', FirstDate, LastDate);
        "G/L Entry".SETFILTER("Document Type", '%1', "G/L Entry"."Document Type"::" ");//' ');//"Document Type"::" ");
        "G/L Entry".SETFILTER("Source Code", 'GENJNL');
        IF "G/L Entry".FIND('-') THEN
            REPEAT
                GLTotal := GLTotal + "G/L Entry".Amount;
            UNTIL "G/L Entry".NEXT = 0;

        //SB-Comment Start
        // SMTPMail.AppendBody('<tr>');
        // SMTPMail.AppendBody('<td align="Center">' + FORMAT(Company1.Name) + '</td>');
        // SMTPMail.AppendBody('<td align="Center">' + FORMAT('VAT Journal Total') + '</td>');
        // SMTPMail.AppendBody('<td align="Center">' + FORMAT(GLTotal, 0, '<Precision,2:2><Standard Format,2>') + '</td>');
        // SMTPMail.AppendBody('</tr>');

        // GrandVATEntryTotal := VATSalesTotal + VATPurchaseTotal + GLTotal;

        // SMTPMail.AppendBody('<tr>');
        // SMTPMail.AppendBody('<td align="Center">' + FORMAT(Company1.Name) + '</td>');
        // SMTPMail.AppendBody('<td align="Center">' + FORMAT('VAT Total') + '</td>');
        // SMTPMail.AppendBody('<td align="Center">' + FORMAT(GrandVATEntryTotal, 0, '<Precision,2:2><Standard Format,2>') + '</td>');
        // SMTPMail.AppendBody('</tr>');
        // SMTPMail.AppendBody('</table>');

        // SMTPMail.AppendBody('<BR>');
        // SMTPMail.AppendBody('<table cellspacing="10"  style="border-spacing: 0px;" border="1">' +
        // '<col width="250"><col width="100"><col width="100">' +
        //  '<col width="100"><col width="100"><col width="150"><col width="150">' +

        //  '<tr><th align="Center">Company Name</th>' +
        //  '<th align="Center"></th>' +
        //  '<th align="Center">Difference</th>');

        // Difference1 := GrandTotal - GrandVATEntryTotal;

        // SMTPMail.AppendBody('<tr>');
        // SMTPMail.AppendBody('<td align="Center">' + FORMAT(Company1.Name) + '</td>');
        // SMTPMail.AppendBody('<td align="Center">' + FORMAT('') + '</td>');
        // SMTPMail.AppendBody('<td align="Center">' + FORMAT(Difference1, 0, '<Precision,2:2><Standard Format,2>') + '</td>');
        // SMTPMail.AppendBody('</tr>');


        // SMTPMail.AppendBody('</table>');

        // SMTPMail.AppendBody('<BR><BR>');
        // SMTPMail.AppendBody('Kind Regards,');
        // SMTPMail.AppendBody('<BR><BR>');
        // SMTPMail.AppendBody('Dynamics');
        // SMTPMail.Send();
        // //SB-Comment End
        //SB-new code start
        SMTPMail.AppendToBody('<tr>');
        SMTPMail.AppendToBody('<td align="Center">' + FORMAT(Company1.Name) + '</td>');
        SMTPMail.AppendToBody('<td align="Center">' + FORMAT('VAT Journal Total') + '</td>');
        SMTPMail.AppendToBody('<td align="Center">' + FORMAT(GLTotal, 0, '<Precision,2:2><Standard Format,2>') + '</td>');
        SMTPMail.AppendToBody('</tr>');

        GrandVATEntryTotal := VATSalesTotal + VATPurchaseTotal + GLTotal;

        SMTPMail.AppendToBody('<tr>');
        SMTPMail.AppendToBody('<td align="Center">' + FORMAT(Company1.Name) + '</td>');
        SMTPMail.AppendToBody('<td align="Center">' + FORMAT('VAT Total') + '</td>');
        SMTPMail.AppendToBody('<td align="Center">' + FORMAT(GrandVATEntryTotal, 0, '<Precision,2:2><Standard Format,2>') + '</td>');
        SMTPMail.AppendToBody('</tr>');
        SMTPMail.AppendToBody('</table>');

        SMTPMail.AppendToBody('<BR>');
        SMTPMail.AppendToBody('<table cellspacing="10"  style="border-spacing: 0px;" border="1">' +
        '<col width="250"><col width="100"><col width="100">' +
         '<col width="100"><col width="100"><col width="150"><col width="150">' +

         '<tr><th align="Center">Company Name</th>' +
         '<th align="Center"></th>' +
         '<th align="Center">Difference</th>');

        Difference1 := GrandTotal - GrandVATEntryTotal;

        SMTPMail.AppendToBody('<tr>');
        SMTPMail.AppendToBody('<td align="Center">' + FORMAT(Company1.Name) + '</td>');
        SMTPMail.AppendToBody('<td align="Center">' + FORMAT('') + '</td>');
        SMTPMail.AppendToBody('<td align="Center">' + FORMAT(Difference1, 0, '<Precision,2:2><Standard Format,2>') + '</td>');
        SMTPMail.AppendToBody('</tr>');


        SMTPMail.AppendToBody('</table>');

        SMTPMail.AppendToBody('<BR><BR>');
        SMTPMail.AppendToBody('Kind Regards,');
        SMTPMail.AppendToBody('<BR><BR>');
        SMTPMail.AppendToBody('Dynamics');
        // SMTPSend.Send(SMTPMail);
        //SB-new code end

        IF GUIALLOWED THEN
            MESSAGE('DONE');

    end;

    procedure UniqueTrainer()
    var
        Date1: Date;
        RecordFound1: Boolean;
        Compname1: Text[80];
        ExcelBuffer1: Record "Excel Buffer";
        EventHeader: Record "Event Header";
        SerialNo: Integer;
        EventLine: Record "Event Line";
        CountryRegion: Record "Country/Region";
        RType: Option " ","Internal Trainer","External Trainer","Other Staff","ZZUNA","Internal Invigilator","External Invigilator","IND Internal Trainer","IND External Trainer";
        RMaster: Record Resource;
        ExternalTrainer1: Integer;
        INDInternalTrainer1: Integer;
        UKInternal: Integer;
        GrandTotalRow: Decimal;
        GrandTotalCol: Decimal;
        ExternalTrainerTotal: Decimal;
        InternalTrainerTotal: Decimal;
        UKInternalTotal: Decimal;
        GrandTotal1: Decimal;

    begin

        ExcelBuffer1.SETFILTER(ExcelBuffer1.Formula, 'UniqueTrainer');
        IF ExcelBuffer1.FINDSET THEN
            ExcelBuffer1.DELETEALL;

        CLEAR(SMTPMail);
        //SB-comment Start
        // SMTPMail.CreateMessage('Dynamics', 'Dynamics@theknowledgeAcademy.com', 'martha.folkes@theknowledgeacademy.com',
        //                    'Auto Email for Unique Trainer and Total Events', '', TRUE);// ,'',TRUE);//for ' +COMPANYNAME ,'',TRUE);

        // SMTPMail.AddCC('Tony@theknowledgeacademy.com');
        // SMTPMail.AddCC('dheeraj.arora@theknowledgeacademy.com');


        // //SMTPMail.AddBCC('biju.kurup@theknowledgeacademy.com');

        // SMTPMail.AppendBody('Dear Sir, ');
        // SMTPMail.AppendBody('<BR><BR>');
        // SMTPMail.AppendBody('<font size=5>' + 'UNIQUE TRAINERS USED' + '</font>');


        // //
        // //EVENT COUNT (NOT UNIQUE)

        // //SMTPMail.AppendBody('<td align="Center">' + FORMAT(ExternalTrainer1) + '</td>');

        // //f <font color="red">Purchase Order %1 - %2</font>

        // SMTPMail.AppendBody('<BR><BR>');

        // SMTPMail.AppendBody('<table cellspacing="10"  style="border-spacing: 0px;" border="1">' +
        // '<col width="80"><col width="90"><col width="80">' +
        //  '<col width="80"><col width="80"><col width="80">' +

        //  '<tr><th align="Center">Week No</th>' +
        //  '<th align="Center">Begin. Date</th>' +
        //  '<th align="Center">Month</th>' +
        //  '<th align="Center">External Trainer</th>' +
        //  '<th align="Center">IND Internal Trainer</th>' +
        // '<th align="Center">UK Internal</th>' +
        // '<th align="Center">Grand Total</th>');
        //SB-Comment End
        //SB-NEw code start

        SMTPMail.Create('martha.folkes@theknowledgeacademy.com',
                           'Auto Email for Unique Trainer and Total Events', '', TRUE);

        SMTPMail.AddRecipient(EmailReceipantType::Cc, 'Tony@theknowledgeacademy.com');
        SMTPMail.AddRecipient(EmailReceipantType::Cc, 'dheeraj.arora@theknowledgeacademy.com');


        //SMTPMail.AddBCC('biju.kurup@theknowledgeacademy.com');

        SMTPMail.AppendToBody('Dear Sir, ');
        SMTPMail.AppendToBody('<BR><BR>');
        SMTPMail.AppendToBody('<font size=5>' + 'UNIQUE TRAINERS USED' + '</font>');


        //
        //EVENT COUNT (NOT UNIQUE)

        //SMTPMail.AppendBody('<td align="Center">' + FORMAT(ExternalTrainer1) + '</td>');

        //f <font color="red">Purchase Order %1 - %2</font>

        SMTPMail.AppendToBody('<BR><BR>');

        SMTPMail.AppendToBody('<table cellspacing="10"  style="border-spacing: 0px;" border="1">' +
        '<col width="80"><col width="90"><col width="80">' +
         '<col width="80"><col width="80"><col width="80">' +

         '<tr><th align="Center">Week No</th>' +
         '<th align="Center">Begin. Date</th>' +
         '<th align="Center">Month</th>' +
         '<th align="Center">External Trainer</th>' +
         '<th align="Center">IND Internal Trainer</th>' +
        '<th align="Center">UK Internal</th>' +
        '<th align="Center">Grand Total</th>');
        //SB-new code end

        EventWeek1.SETFILTER(EventWeek1.Year, '2022');
        EventWeek1.SETFILTER(EventWeek1."Week No.", '%1..%2', 14, 53);
        IF EventWeek1.FIND('-') THEN
            REPEAT
                MonthName := FORMAT(EventWeek1."Week Start Date", 0, '<Month Text>');

                EventHeader.SETFILTER(EventHeader."Start Date", '%1..%2', EventWeek1."Week Start Date", EventWeek1."Week End Date");
                IF EventHeader.FIND('-') THEN
                    REPEAT


                        ExcelBuffer1.SETFILTER(ExcelBuffer1.Formula, 'UniqueTrainer');
                        ExcelBuffer1.SETFILTER(ExcelBuffer1."Column No.", '%1', EventWeek1."Week No.");
                        ExcelBuffer1.SETFILTER("Document No.", '%1', EventHeader."Course Trainer");
                        IF NOT ExcelBuffer1.FIND('-') THEN BEGIN
                            ExcelBuffer1.RESET;
                            IF ExcelBuffer1.FINDLAST THEN
                                SerialNo := ExcelBuffer1."Row No."
                            ELSE
                                SerialNo := 1;

                            ExcelBuffer1.INIT;
                            ExcelBuffer1."Row No." := SerialNo + 1;

                            RType := RType::" ";
                            IF RMaster.GET(EventHeader."Course Trainer") THEN
                                RType := RMaster."Resource Type";

                            ExcelBuffer1.Formula := 'UniqueTrainer';
                            ExcelBuffer1."Document No." := EventHeader."Course Trainer";
                            ExcelBuffer1."Column No." := EventWeek1."Week No.";
                            ExcelBuffer1.BookingDate := EventWeek1."Week Start Date";
                            ExcelBuffer1."Cell Value as Text" := FORMAT(RType);

                            ExcelBuffer1.INSERT;
                        END;
                    UNTIL EventHeader.NEXT = 0;
            UNTIL EventWeek1.NEXT = 0;

        CLEAR(EventWeek1);
        EventWeek1.RESET;
        EventWeek1.SETFILTER(EventWeek1.Year, '2022');
        EventWeek1.SETFILTER(EventWeek1."Week No.", '%1..%2', 14, 53);
        IF EventWeek1.FIND('-') THEN
            REPEAT
                MonthName := FORMAT(EventWeek1."Week Start Date", 0, '<Month Text>');
                //MESSAGE ('%1',EventWeek1."Week No.");
                ExternalTrainer1 := 0;
                ExcelBuffer1.RESET;
                ExcelBuffer1.SETFILTER(ExcelBuffer1.Formula, 'UniqueTrainer');
                ExcelBuffer1.SETFILTER(ExcelBuffer1."Column No.", '%1', EventWeek1."Week No.");
                ExcelBuffer1.SETFILTER(ExcelBuffer1."Cell Value as Text", 'External Trainer');
                IF ExcelBuffer1.FIND('-') THEN
                    REPEAT
                        ExternalTrainer1 := ExternalTrainer1 + 1;
                    UNTIL ExcelBuffer1.NEXT = 0;
                ExternalTrainerTotal := ExternalTrainerTotal + ExternalTrainer1;

                INDInternalTrainer1 := 0;
                ExcelBuffer1.RESET;
                ExcelBuffer1.SETFILTER(ExcelBuffer1.Formula, 'UniqueTrainer');
                ExcelBuffer1.SETFILTER(ExcelBuffer1."Column No.", '%1', EventWeek1."Week No.");
                ExcelBuffer1.SETFILTER(ExcelBuffer1."Cell Value as Text", 'IND Internal Trainer');
                IF ExcelBuffer1.FIND('-') THEN
                    REPEAT
                        INDInternalTrainer1 := INDInternalTrainer1 + 1;
                    UNTIL ExcelBuffer1.NEXT = 0;
                InternalTrainerTotal := InternalTrainerTotal + INDInternalTrainer1;

                UKInternal := 0;
                ExcelBuffer1.RESET;
                ExcelBuffer1.SETFILTER(ExcelBuffer1.Formula, 'UniqueTrainer');
                ExcelBuffer1.SETFILTER(ExcelBuffer1."Column No.", '%1', EventWeek1."Week No.");
                ExcelBuffer1.SETFILTER(ExcelBuffer1."Cell Value as Text", 'Internal Trainer');
                IF ExcelBuffer1.FIND('-') THEN
                    REPEAT
                        UKInternal := UKInternal + 1;
                    UNTIL ExcelBuffer1.NEXT = 0;
                UKInternalTotal := UKInternalTotal + UKInternal;

                GrandTotalRow := ExternalTrainer1 + INDInternalTrainer1 + UKInternal;
                //SB-Comment Start
                //         SMTPMail.AppendBody('<tr>');
                //         SMTPMail.AppendBody('<td align="Center">' + FORMAT(EventWeek1."Week No.") + '</td>');
                //         SMTPMail.AppendBody('<td align="Center">' + FORMAT(ExcelBuffer1.BookingDate) + '</td>');
                //         SMTPMail.AppendBody('<td align="Center">' + FORMAT(MonthName) + '</td>');
                //         SMTPMail.AppendBody('<td align="Center">' + FORMAT(ExternalTrainer1) + '</td>');
                //         SMTPMail.AppendBody('<td align="Center">' + FORMAT(INDInternalTrainer1) + '</td>');
                //         SMTPMail.AppendBody('<td align="Center">' + FORMAT(UKInternal) + '</td>');
                //         SMTPMail.AppendBody('<td align="Center">' + FORMAT(GrandTotalRow) + '</td>');


                //         SMTPMail.AppendBody('</tr>');

                //     UNTIL EventWeek1.NEXT = 0;

                // GrandTotal1 := ExternalTrainerTotal + InternalTrainerTotal + UKInternalTotal;
                // SMTPMail.AppendBody('<tr>');
                // SMTPMail.AppendBody('<td align="Center">' + FORMAT('') + '</td>');
                // SMTPMail.AppendBody('<td align="Center">' + FORMAT('') + '</td>');
                // SMTPMail.AppendBody('<td align="Center">' + FORMAT('Grand Total') + '</td>');
                // SMTPMail.AppendBody('<td align="Center">' + FORMAT(ExternalTrainerTotal) + '</td>');
                // SMTPMail.AppendBody('<td align="Center">' + FORMAT(InternalTrainerTotal) + '</td>');
                // SMTPMail.AppendBody('<td align="Center">' + FORMAT(UKInternalTotal) + '</td>');
                // SMTPMail.AppendBody('<td align="Center">' + FORMAT(GrandTotal1) + '</td>');


                // SMTPMail.AppendBody('</tr>');


                // SMTPMail.AppendBody('</table>');
                // SMTPMail.AppendBody('<BR><BR>');
                //SB-comment end
                //SB-new code start
                SMTPMail.AppendToBody('<tr>');
                SMTPMail.AppendToBody('<td align="Center">' + FORMAT(EventWeek1."Week No.") + '</td>');
                SMTPMail.AppendToBody('<td align="Center">' + FORMAT(ExcelBuffer1.BookingDate) + '</td>');
                SMTPMail.AppendToBody('<td align="Center">' + FORMAT(MonthName) + '</td>');
                SMTPMail.AppendToBody('<td align="Center">' + FORMAT(ExternalTrainer1) + '</td>');
                SMTPMail.AppendToBody('<td align="Center">' + FORMAT(INDInternalTrainer1) + '</td>');
                SMTPMail.AppendToBody('<td align="Center">' + FORMAT(UKInternal) + '</td>');
                SMTPMail.AppendToBody('<td align="Center">' + FORMAT(GrandTotalRow) + '</td>');


                SMTPMail.AppendToBody('</tr>');

            UNTIL EventWeek1.NEXT = 0;

        GrandTotal1 := ExternalTrainerTotal + InternalTrainerTotal + UKInternalTotal;
        SMTPMail.AppendToBody('<tr>');
        SMTPMail.AppendToBody('<td align="Center">' + FORMAT('') + '</td>');
        SMTPMail.AppendToBody('<td align="Center">' + FORMAT('') + '</td>');
        SMTPMail.AppendToBody('<td align="Center">' + FORMAT('Grand Total') + '</td>');
        SMTPMail.AppendToBody('<td align="Center">' + FORMAT(ExternalTrainerTotal) + '</td>');
        SMTPMail.AppendToBody('<td align="Center">' + FORMAT(InternalTrainerTotal) + '</td>');
        SMTPMail.AppendToBody('<td align="Center">' + FORMAT(UKInternalTotal) + '</td>');
        SMTPMail.AppendToBody('<td align="Center">' + FORMAT(GrandTotal1) + '</td>');


        SMTPMail.AppendToBody('</tr>');


        SMTPMail.AppendToBody('</table>');
        SMTPMail.AppendToBody('<BR><BR>');
        //SB-new code end

        // {
        // SMTPMail.AppendBody('Kind Regards,');

        // SMTPMail.AppendBody('<BR><BR>');
        // SMTPMail.AppendBody('Dynamics');
        // SMTPMail.Send();
        // }

        //IF GUIALLOWED THEN
        //MESSAGE ('DONE');
    end;

    procedure TotalEvents()
    var
        Date1: Date;
        RecordFound1: Boolean;
        Compname1: Text;
        ExcelBuffer1: Record "Excel Buffer";
        EventHeader: Record "Event Header";
        SerialNo: Integer;
        EventLine: Record "Event Line";
        CountryRegion: Record "Country/Region";
        RType: Option " ","Internal Trainer","External Trainer","Other Staff","ZZUNA","Internal Invigilator","External Invigilator","IND Internal Trainer","IND External Trainer";
        RMaster: Record Resource;
        ExternalTrainer1: Integer;
        INDInternalTrainer1: Integer;
        UKInternal: Integer;
        GrandTotalRow: Decimal;
        GrandTotalCol: Decimal;
        ExternalTrainerTotal: Decimal;
        InternalTrainerTotal: Decimal;
        UKInternalTotal: Decimal;
        GrandTotal1: Decimal;

    begin

        ExcelBuffer1.SETFILTER(ExcelBuffer1.Formula, 'TotalEvents');
        IF ExcelBuffer1.FINDSET THEN
            ExcelBuffer1.DELETEALL;

        ExcelBuffer1.INIT;

        // {
        // CLEAR(SMTPMail);
        // SMTPMail.CreateMessage('Dynamics','Dynamics@theknowledgeAcademy.com','biju.kurup@theknowledgeacademy.com',
        //                    'Auto Email for Total Events','',TRUE);// ,'',TRUE);//for ' +COMPANYNAME ,'',TRUE);

        // SMTPMail.AppendBody('Hi');
        // SMTPMail.AppendBody('<BR><BR>');
        // }

        //SB-Comment Start
        // SMTPMail.AppendBody('<BR><BR>');
        // SMTPMail.AppendBody('<font size=5>' + 'EVENT COUNT (NOT UNIQUE)' + '</font>');

        // //SMTPMail.AppendBody('Below details are for Total Events');

        // SMTPMail.AppendBody('<BR><BR>');

        // SMTPMail.AppendBody('<table cellspacing="10"  style="border-spacing: 0px;" border="1">' +
        // '<col width="80"><col width="90"><col width="80">' +
        //  '<col width="80"><col width="80"><col width="80">' +

        //  '<tr><th align="Center">Week No</th>' +
        //  '<th align="Center">Begin. Date</th>' +
        //  '<th align="Center">Month</th>' +
        //  '<th align="Center">External Trainer</th>' +
        //  '<th align="Center">IND Internal Trainer</th>' +
        // '<th align="Center">UK Internal</th>' +
        // '<th align="Center">Grand Total</th>');
        //SB-Comment End
        //SB-new code start
        SMTPMail.AppendToBody('<BR><BR>');
        SMTPMail.AppendToBody('<font size=5>' + 'EVENT COUNT (NOT UNIQUE)' + '</font>');

        //SMTPMail.AppendBody('Below details are for Total Events');

        SMTPMail.AppendToBody('<BR><BR>');

        SMTPMail.AppendToBody('<table cellspacing="10"  style="border-spacing: 0px;" border="1">' +
        '<col width="80"><col width="90"><col width="80">' +
         '<col width="80"><col width="80"><col width="80">' +

         '<tr><th align="Center">Week No</th>' +
         '<th align="Center">Begin. Date</th>' +
         '<th align="Center">Month</th>' +
         '<th align="Center">External Trainer</th>' +
         '<th align="Center">IND Internal Trainer</th>' +
        '<th align="Center">UK Internal</th>' +
        '<th align="Center">Grand Total</th>');
        //SB-new code end

        EventWeek1.SETFILTER(EventWeek1.Year, '2022');
        EventWeek1.SETFILTER(EventWeek1."Week No.", '%1..%2', 14, 53); //53
        IF EventWeek1.FIND('-') THEN
            REPEAT
                MonthName := FORMAT(EventWeek1."Week Start Date", 0, '<Month Text>');


                EventHeader.SETFILTER(EventHeader."Start Date", '%1..%2', EventWeek1."Week Start Date", EventWeek1."Week End Date");
                IF EventHeader.FIND('-') THEN
                    REPEAT

                        //  {
                        //    ExcelBuffer1.SETFILTER(ExcelBuffer1.Formula ,'TotalEvents');
                        //    ExcelBuffer1.SETFILTER(ExcelBuffer1."Column No.",'%1',EventWeek1."Week No.");
                        //    ExcelBuffer1.SETFILTER("Document No.",'%1',EventHeader."Course Trainer");
                        //    IF NOT ExcelBuffer1.FIND('-') THEN BEGIN
                        //  }
                        SerialNo := SerialNo + 1;

                        ExcelBuffer1."Row No." := SerialNo + 1;

                        RType := RType::" ";
                        IF RMaster.GET(EventHeader."Course Trainer") THEN
                            RType := RMaster."Resource Type";

                        ExcelBuffer1.Formula := 'TotalEvents';
                        ExcelBuffer1."Document No." := EventHeader."No.";
                        ExcelBuffer1."Column No." := EventWeek1."Week No.";
                        ExcelBuffer1."Cell Value as Text" := FORMAT(RType);

                        ExcelBuffer1.BookingDate := EventWeek1."Week Start Date";

                        ExcelBuffer1.INSERT;
                    //END;
                    UNTIL EventHeader.NEXT = 0;
            UNTIL EventWeek1.NEXT = 0;

        CLEAR(EventWeek1);
        EventWeek1.RESET;
        EventWeek1.SETFILTER(EventWeek1.Year, '2022');
        EventWeek1.SETFILTER(EventWeek1."Week No.", '%1..%2', 14, 53); //53
        IF EventWeek1.FIND('-') THEN
            REPEAT
                MonthName := FORMAT(EventWeek1."Week Start Date", 0, '<Month Text>');
                //MESSAGE ('%1',EventWeek1."Week No.");
                ExternalTrainer1 := 0;
                ExcelBuffer1.RESET;
                ExcelBuffer1.SETFILTER(ExcelBuffer1.Formula, 'TotalEvents');
                ExcelBuffer1.SETFILTER(ExcelBuffer1."Column No.", '%1', EventWeek1."Week No.");
                ExcelBuffer1.SETFILTER(ExcelBuffer1."Cell Value as Text", 'External Trainer');
                IF ExcelBuffer1.FIND('-') THEN
                    REPEAT
                        ExternalTrainer1 := ExternalTrainer1 + 1;
                    UNTIL ExcelBuffer1.NEXT = 0;
                ExternalTrainerTotal := ExternalTrainerTotal + ExternalTrainer1;

                INDInternalTrainer1 := 0;
                ExcelBuffer1.RESET;
                ExcelBuffer1.SETFILTER(ExcelBuffer1.Formula, 'TotalEvents');
                ExcelBuffer1.SETFILTER(ExcelBuffer1."Column No.", '%1', EventWeek1."Week No.");
                ExcelBuffer1.SETFILTER(ExcelBuffer1."Cell Value as Text", 'IND Internal Trainer');
                IF ExcelBuffer1.FIND('-') THEN
                    REPEAT
                        INDInternalTrainer1 := INDInternalTrainer1 + 1;
                    UNTIL ExcelBuffer1.NEXT = 0;
                InternalTrainerTotal := InternalTrainerTotal + INDInternalTrainer1;

                UKInternal := 0;
                ExcelBuffer1.RESET;
                ExcelBuffer1.SETFILTER(ExcelBuffer1.Formula, 'TotalEvents');
                ExcelBuffer1.SETFILTER(ExcelBuffer1."Column No.", '%1', EventWeek1."Week No.");
                ExcelBuffer1.SETFILTER(ExcelBuffer1."Cell Value as Text", 'Internal Trainer');
                IF ExcelBuffer1.FIND('-') THEN
                    REPEAT
                        UKInternal := UKInternal + 1;
                    UNTIL ExcelBuffer1.NEXT = 0;
                UKInternalTotal := UKInternalTotal + UKInternal;

                GrandTotalRow := ExternalTrainer1 + INDInternalTrainer1 + UKInternal;
                //SB-Comment Staret
                //         SMTPMail.AppendBody('<tr>');
                //         SMTPMail.AppendBody('<td align="Center">' + FORMAT(EventWeek1."Week No.") + '</td>');
                //         SMTPMail.AppendBody('<td align="Center">' + FORMAT(ExcelBuffer1.BookingDate) + '</td>');
                //         SMTPMail.AppendBody('<td align="Center">' + FORMAT(MonthName) + '</td>');
                //         SMTPMail.AppendBody('<td align="Center">' + FORMAT(ExternalTrainer1) + '</td>');
                //         SMTPMail.AppendBody('<td align="Center">' + FORMAT(INDInternalTrainer1) + '</td>');
                //         SMTPMail.AppendBody('<td align="Center">' + FORMAT(UKInternal) + '</td>');
                //         SMTPMail.AppendBody('<td align="Center">' + FORMAT(GrandTotalRow) + '</td>');


                //         SMTPMail.AppendBody('</tr>');

                //     UNTIL EventWeek1.NEXT = 0;

                // GrandTotal1 := ExternalTrainerTotal + InternalTrainerTotal + UKInternalTotal;
                // SMTPMail.AppendBody('<tr>');
                // SMTPMail.AppendBody('<td align="Center">' + FORMAT('') + '</td>');
                // SMTPMail.AppendBody('<td align="Center">' + FORMAT('') + '</td>');
                // SMTPMail.AppendBody('<td align="Center">' + FORMAT('Grand Total') + '</td>');
                // SMTPMail.AppendBody('<td align="Center">' + FORMAT(ExternalTrainerTotal) + '</td>');
                // SMTPMail.AppendBody('<td align="Center">' + FORMAT(InternalTrainerTotal) + '</td>');
                // SMTPMail.AppendBody('<td align="Center">' + FORMAT(UKInternalTotal) + '</td>');
                // SMTPMail.AppendBody('<td align="Center">' + FORMAT(GrandTotal1) + '</td>');


                // SMTPMail.AppendBody('</tr>');


                // SMTPMail.AppendBody('</table>');
                // SMTPMail.AppendBody('<BR><BR>');
                // SMTPMail.AppendBody('Kind Regards,');
                // SMTPMail.AppendBody('<BR><BR>');
                // SMTPMail.AppendBody('Dynamics');
                // SMTPMail.Send();
                //SB-Comemnt end
                //SB-new code start
                SMTPMail.AppendToBody('<tr>');
                SMTPMail.AppendToBody('<td align="Center">' + FORMAT(EventWeek1."Week No.") + '</td>');
                SMTPMail.AppendToBody('<td align="Center">' + FORMAT(ExcelBuffer1.BookingDate) + '</td>');
                SMTPMail.AppendToBody('<td align="Center">' + FORMAT(MonthName) + '</td>');
                SMTPMail.AppendToBody('<td align="Center">' + FORMAT(ExternalTrainer1) + '</td>');
                SMTPMail.AppendToBody('<td align="Center">' + FORMAT(INDInternalTrainer1) + '</td>');
                SMTPMail.AppendToBody('<td align="Center">' + FORMAT(UKInternal) + '</td>');
                SMTPMail.AppendToBody('<td align="Center">' + FORMAT(GrandTotalRow) + '</td>');


                SMTPMail.AppendToBody('</tr>');

            UNTIL EventWeek1.NEXT = 0;

        GrandTotal1 := ExternalTrainerTotal + InternalTrainerTotal + UKInternalTotal;
        SMTPMail.AppendToBody('<tr>');
        SMTPMail.AppendToBody('<td align="Center">' + FORMAT('') + '</td>');
        SMTPMail.AppendToBody('<td align="Center">' + FORMAT('') + '</td>');
        SMTPMail.AppendToBody('<td align="Center">' + FORMAT('Grand Total') + '</td>');
        SMTPMail.AppendToBody('<td align="Center">' + FORMAT(ExternalTrainerTotal) + '</td>');
        SMTPMail.AppendToBody('<td align="Center">' + FORMAT(InternalTrainerTotal) + '</td>');
        SMTPMail.AppendToBody('<td align="Center">' + FORMAT(UKInternalTotal) + '</td>');
        SMTPMail.AppendToBody('<td align="Center">' + FORMAT(GrandTotal1) + '</td>');


        SMTPMail.AppendToBody('</tr>');


        SMTPMail.AppendToBody('</table>');
        SMTPMail.AppendToBody('<BR><BR>');
        SMTPMail.AppendToBody('Kind Regards,');
        SMTPMail.AppendToBody('<BR><BR>');
        SMTPMail.AppendToBody('Dynamics');
        // SMTPSend.Send(SMTPMail);
        //SB-new code end

        IF GUIALLOWED THEN
            MESSAGE('DONE');
    end;


}