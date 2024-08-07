page 70001 TESTPAGE1
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;


    layout
    {
    }
    actions
    {
        area(Processing)
        {
            action(PostCodes)
            {
                ApplicationArea = All;
                Visible = false;
                trigger OnAction()
                var
                    comp: record Company;
                    IE: record "import ei";
                begin
                    if (UpperCase(UserId) in ['BIJU.KURUP']) then begin
                        if confirm('Are you sure ?') then
                            FillCountryInPostcodes();
                    end
                    else
                        Error('Nope');
                end;
            }
            action(NoSeries)
            {
                ApplicationArea = All;
                Visible = false;

                trigger OnAction()
                begin
                    if (UpperCase(UserId) in ['BIJU.KURUP']) then begin
                        if confirm('Are you sure ?') then
                            CreateNewNoSeries();
                    end
                    else
                        Error('Nope');

                end;
            }
            action(UpdateProdInGLA)
            {
                ApplicationArea = All;
                visible = false;
                trigger OnAction()
                var
                begin
                    UpdateProdInGL();
                end;
            }
            action(DeleteEDE)
            {
                ApplicationArea = All;
                Visible = False;
                trigger OnAction()
                var
                    APIWrite: Codeunit "API Write";
                    EDE: Record "Event Detailed Entry";
                    Eventheader: record "Event Header";
                    Count: Integer;
                    Count1: integer;
                    EL: record "Event Line";
                begin
                    Count := 0;
                    Count1 := 0;
                    Eventheader.setfilter("Start Date", '%1..%2', 20200101D, 20231231D);
                    if eventheader.findfirst then
                        repeat
                            EL.Reset();
                            EL.SetCurrentKey("Event No.", Status);
                            EL.SetFilter("Event No.", Eventheader."No.");
                            EL.SetFilter(Status, '%1', EL.Status::Available);
                            if EL.FindFirst() then begin
                                count1 += Count1;
                                // EL.DeleteAll();
                            end;
                            EDE.reset;
                            EDE.SetCurrentKey("Event No.", Status);
                            EDE.SetFilter("Event No.", Eventheader."No.");
                            EDE.SetFilter(Status, '%1', EDE.Status::Available);
                            if EDE.FindFirst() then begin
                                Count += EDE.Count;
                                // EDE.DeleteAll();
                            End;
                        until Eventheader.Next() = 0;
                    Message('%1 - EDE \ %2 - EL', Count, Count1);

                end;
            }
            action(DeleteNoLines)
            {
                ApplicationArea = All;
                Caption = 'DeleteNoLines';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = SerialNo;
                Visible = false;

                trigger OnAction()
                begin
                    DeleteNoSeriesLines();
                end;
            }

            action(test)
            {
                ApplicationArea = All;
                RunObject = xmlport 70004;
            }


        }


    }


    procedure ExportToMail()
    var
        CSIB: Record 50075;
        email: codeunit email;
        emailmsg: codeunit "Email Message";
        tempamt: Decimal;
        tempdate: Text[30];
        ert: enum "Email Recipient Type";

        GlobalIrisSO: record GlobalIRIS;
        btib: record "Bank Transaction Import Buffer";
    begin
        CLEAR(emailmsg);
        emailmsg.Create('Niraj.Bhati@theknowledgeacademy.com', 'Pending All Transaction', '', TRUE);
        emailmsg.AppendToBody('<BR><BR>');
        emailmsg.AppendToBody('Not Processed BACS Paid-In/Paid-Out Transaction');
        emailmsg.AppendToBody('<BR>');
        emailmsg.AppendToBody('<table cellspacing="10"  style="border-spacing: 0px;" border="1">' +
        '<col width="150"><col width="200"><col width="450"><col width="150"><col width="150">' +
         '<tr><th align="Center">Company Name</th>' +
         '<th align="Center">Date</th>' +
         '<th align="Center">Information</th>' +
          '<th align="Center">Amount </th>' +
          '<th align="Center">Transaction Type</th>'
         );
        Company.SETFILTER(Company.Name, '<>%1', '');
        IF Company.FINDSET THEN
            REPEAT
                Compname();
                BTIB.CHANGECOMPANY(Company.Name);
                BTIB.SETFILTER(BTIB.Processed, 'No');
                BTIB.SETFILTER(BTIB."Entry No.", '<>%1', 0);
                IF BTIB.FINDSET THEN
                    REPEAT
                        emailmsg.AppendToBody('<tr>');
                        emailmsg.AppendToBody('<td align="Center">' + compname1 + '</td>');
                        emailmsg.AppendToBody('<td align="Center">' + FORMAT(BTIB.Date) + '</td>');
                        emailmsg.AppendToBody('<td align="Center">' + BTIB.Information + '</td>');
                        emailmsg.AppendToBody('<td align="Center">' + FORMAT(BTIB.Amount) + '</td>');
                        emailmsg.AppendToBody('<td align="Center">' + FORMAT(BTIB."Transaction Type") + '</td>');
                    UNTIL BTIB.NEXT = 0;
            UNTIL Company.NEXT = 0;
        emailmsg.AppendToBody('</table>');

        email.send(emailmsg);
    end;


    procedure Compname()
    begin
        IF Company.Name = 'The Knowledge Academy Limited' THEN
            compname1 := 'TKA UK';


        IF Company.Name = 'Best Practice Training Ltd.' THEN
            compname1 := 'Best Prac';

        IF Company.Name = 'Datrix Learning Services Ltd.' THEN
            compname1 := 'Datrix';

        IF Company.Name = 'ITIL Training Academy' THEN
            compname1 := 'ITIL';

        IF Company.Name = 'Pearce Mayfield Train Dubai' THEN
            compname1 := 'PMD';

        IF Company.Name = 'Pearce Mayfield Training Ltd' THEN
            compname1 := 'PMT';

        IF Company.Name = 'Pentagon Leisure Services Ltd' THEN
            compname1 := 'Pentagon';

        IF Company.Name = 'Silicon Beach Training' THEN
            compname1 := 'Silicon';

        IF Company.Name = 'The Knowledge Academy FreeZone' THEN
            compname1 := 'FREEZONE';

        IF Company.Name = 'The Knowledge Academy Inc' THEN
            compname1 := 'USA';

        IF Company.Name = 'The Knowledge Academy Pty Ltd.' THEN
            compname1 := 'AUS';

        IF Company.Name = 'The Knowledge Academy SA' THEN
            compname1 := 'SA';

        IF Company.Name = 'TKA Apprenticeship' THEN
            compname1 := 'Apprenticeship';

        IF Company.Name = 'TKA Canada Corporation' THEN
            compname1 := 'Canada';

        IF Company.Name = 'TKA Europe' THEN
            compname1 := 'Europe';

        IF Company.Name = 'TKA India' THEN
            compname1 := 'TKA India';


        IF Company.Name = 'TKA Hong Kong Ltd.' THEN
            compname1 := 'HK';

        IF Company.Name = 'TKA New Zealand Ltd.' THEN
            compname1 := 'NZ';

        IF Company.Name = 'TKA Singapore PTE Ltd.' THEN
            compname1 := 'Singapore';
    end;


    local procedure DeleteNoSeriesLines()
    var
        NoSeries: record "No. Series";
        Noseriesline: record "No. Series Line";
        company: record Company;
    Begin
        if company.findfirst then
            repeat
                NoSeries.Reset();
                NoSeries.ChangeCompany(Company.Name);
                NoSeries.SetFilter("Auto Prefix", '%1', true);
                if NoSeries.FindFirst() then
                    repeat
                        Noseriesline.Reset();
                        Noseriesline.ChangeCompany(Company.Name);
                        Noseriesline.SetFilter("Series Code", NoSeries.Code);
                        Noseriesline.SetFilter("Starting Date", '<%1', 20240630D);
                        Noseriesline.SetFilter("Last No. Used", '<>%1', '');
                        if Noseriesline.FindFirst() then Noseriesline.deleteall;
                    until NoSeries.Next() = 0;
            until company.Next() = 0;
    End;

    local procedure DeleteEDEBatch()
    var
        EDE: Record "Event Detailed Entry";
        Eventheader: record "Event Header";
        Count: Integer;
        Count1: integer;
        EL: record "Event Line";
    begin
        Eventheader.setfilter("End Date", '<%1', TODAY);
        if eventheader.findfirst then
            repeat
                EL.Reset();
                EL.SetCurrentKey("Event No.", Status);
                EL.SetFilter("Event No.", Eventheader."No.");
                EL.SetFilter(Status, '%1', EL.Status::Available);
                if EL.FindFirst() then begin
                    // count1 += Count1;
                    // EL.DeleteAll();
                end;
                EDE.reset;
                EDE.SetCurrentKey("Event No.", Status);
                EDE.SetFilter("Event No.", Eventheader."No.");
                EDE.SetFilter(Status, '%1', EDE.Status::Available);
                if EDE.FindFirst() then begin
                    // Count += EDE.Count;
                    // EDE.DeleteAll();
                End;
            until Eventheader.Next() = 0;

    end;

    local Procedure CreateNewNoSeries()
    var
        NoSeries1: record "No. Series";
        NoSeriesLine1: record "No. Series Line";
        NoSeriesLine2: record "No. Series Line";
        FranchiseDet: record "Franchise Details";
    Begin
        FranchiseDet.SetFilter("Franchise Company (NAV)", CompanyName);
        if FranchiseDet.FindFirst() then;
        NoSeries1.SetFilter("Auto Prefix", '%1', true);
        if NoSeries1.FindFirst() then
            repeat
                NoSeriesLine1.reset;
                Clear(NoSeriesLine1);
                NoSeriesLine1.SetFilter("Series Code", NoSeries1.Code);
                NoSeriesLine1.SetFilter("Last No. Used", '<>%1', '');
                if NoSeriesLine1.FindFirst() then NoSeriesLine1.setrange("Last No. Used");
                if NoSeriesLine1.FindLast() then begin
                    Clear(NoSeriesLine2);
                    NoSeriesLine2.Reset();
                    NoSeriesLine2.Init();
                    NoSeriesLine2.Validate("Series Code", NoSeriesLine1."Series Code");
                    NoSeriesLine2.Validate("Line No.", NoSeriesLine1."Line No." + 10000);
                    NoSeriesLine2.Insert(true);
                    NoSeriesLine2.Validate("Starting Date", Today);
                    NoSeriesLine2.Validate("Starting No.", FranchiseDet."No. Series Prefix" + NoSeriesLine1."Starting No.");
                    NoSeriesLine2.Validate("Ending No.", FranchiseDet."No. Series Prefix" + NoSeriesLine1."Ending No.");
                    NoSeriesLine2.Validate("Last No. Used", FranchiseDet."No. Series Prefix" + NoSeriesLine1."Last No. Used");
                    NoSeriesLine2.Validate("Increment-by No.", NoSeriesLine1."Increment-by No.");
                    NoSeriesLine2.Validate(Open, NoSeriesLine1.Open);
                    NoSeriesLine2.Modify();
                end;
            until NoSeries1.Next() = 0;
    End;

    local procedure FillCountryInPostcodes()
    var
        cust: record Customer;
        vend: record vendor;
        PCode: record "Post Code";
        Count: integer;
        custquery: query CustQuery;
        PCode1: record "Post Code";

    begin
        if not Confirm('Are you sure you want to update the postcodes?') then Exit;
        Message('%1', PCode.count);
        PCode.SetFilter("Country/Region Code", '%1', '');
        if Pcode.findfirst then
            repeat
                custquery.SetFilter(custquery.Post_Code, '%1', PCode.Code);
                custquery.SetFilter(custquery.City, '%1', PCode.City);
                if (custquery.Open()) then
                    if custquery.Read() then begin
                        if Pcode1.Get(PCode.Code, pcode.City) then begin
                            PCode1."Country/Region Code" := custquery.Country_Region_Code;
                            PCode1.Modify(false);
                        end
                    end;
            until pcode.Next() = 0;
    end;

    local procedure UpdateProdInGL()
    var
        gla: record "G/L Account";
        comp: record company;
        genprodposting: Record "Gen. Product Posting Group";
    begin
        if comp.findfirst then
            repeat
                genprodposting.ChangeCompany(comp.Name);
                genprodposting.SetFilter(Code, '%1', 'VAT');
                if genprodposting.FindFirst() then begin
                    //5 series
                    gla.Reset();
                    gla.ChangeCompany(Comp.name);
                    gla.SetFilter("No.", '%1|%2|%3|%4', '5346', '5344', '5348', '5345');
                    gla.SetFilter("Gen. Prod. Posting Group", '%1', '');
                    if gla.findfirst then
                        repeat
                            gla."Gen. Prod. Posting Group" := genprodposting.Code;
                            gla.Modify;
                        until gla.next = 0;

                    //6 Series
                    gla.Reset();
                    gla.ChangeCompany(Comp.name);
                    gla.SetFilter("No.", '%1', '6*');
                    gla.SetFilter("Gen. Prod. Posting Group", '%1', '');
                    if gla.findfirst then
                        repeat
                            gla."Gen. Prod. Posting Group" := genprodposting.Code;
                            gla.Modify;
                        until gla.next = 0;


                    // 8 series             
                    gla.Reset();
                    gla.ChangeCompany(Comp.name);
                    gla.SetFilter("No.", '%1', '8*');
                    gla.SetFilter("Gen. Prod. Posting Group", '%1', '');
                    if gla.findfirst then
                        repeat
                            gla."Gen. Prod. Posting Group" := genprodposting.Code;
                            gla.Modify;
                        until gla.next = 0;

                end;
            until comp.next = 0;
    end;

    trigger OnOpenPage()
    var
    begin
        If not (UpperCase(UserId()) in ['BIJU.KURUP']) then
            error('No permission');
    end;


    var
        starttime: time;
        endtime: time;
        company: record Company;
        compname1: text;
}
