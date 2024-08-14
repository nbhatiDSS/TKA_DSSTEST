// page 61002 CustomerAPIPortal
// {
//     APIGroup = 'API';
//     APIPublisher = 'Direction_Software_LLP';
//     APIVersion = 'v2.0';
//     ApplicationArea = All;
//     Caption = 'customerAPI';
//     DelayedInsert = true;
//     EntityName = 'Customers';
//     EntitySetName = 'Customer';
//     PageType = API;
//     SourceTable = Customer;
//     ODataKeyFields = "No.";
//     DeleteAllowed = false;


//     layout
//     {
//         area(Content)
//         {
//             repeater(General)
//             {
//                 field("no"; Rec."No.")
//                 {
//                     ApplicationArea = All;
//                     Editable = false;
//                 }
//                 field(name; Rec.Name)
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("phone"; Rec."Phone No.")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field(address; Rec.Address)
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("address2"; Rec."Address 2")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field(city; Rec.City)
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("postcode"; Rec."Post Code")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field(state; Rec.County)
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("stateCode"; Rec."Territory Code")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("finance_Email"; Rec."Finance Email")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("company_Number"; Rec."Company Number")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("country"; Rec."Country/Region Code")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field(blocked; Rec.Blocked)
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("salesperson"; Rec."Salesperson Code")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field(genPostGrp; Rec."Gen. Bus. Posting Group")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field(vATPostGrp; rec."VAT Bus. Posting Group")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field(custPostingGroup; rec."Customer Posting Group")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field(vATRegistration; rec."VAT Registration No.")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field(type; rec."Copy Sell-to Addr. to Qte From")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field(createdbyEmail; CreatedbyEmail)
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("email"; Rec."E-Mail")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field(B2B; rec.B2B)
//                 {
//                 }
//                 field(B2C; rec.B2C)
//                 {
//                 }
//                 field(Comment; rec.Comment)
//                 {
//                 }
//                 field("Last_Date_Contacted"; rec."Last Date Contacted")
//                 {
//                 }
//                 field("Salesperson_Name"; spname)
//                 {
//                     Caption = 'Salesperson Name';
//                 }
//                 field("Company_No"; CompanyNo)
//                 {
//                 }
//                 field("State_Name"; StateName)
//                 {
//                 }
//                 field("Attachment_Count"; AttachmentCount)
//                 {
//                 }
//                 field("Home_Page"; rec."Home Page")
//                 {
//                 }
//                 field(Balance; rec.Balance)
//                 {
//                 }
//                 field("Balance_LCY"; rec."Balance (LCY)")
//                 {
//                 }
//                 field("Global_Dimension_1_Filter"; Rec."Global Dimension 1 Filter")
//                 {
//                 }
//                 field("Global_Dimension_2_Filter"; Rec."Global Dimension 2 Filter")
//                 {
//                 }
//                 field("Currency_Filter"; Rec."Currency Filter")
//                 {
//                 }
//                 field("Customer_Price_Group"; Rec."Customer Price Group")
//                 {
//                 }
//             }
//         }
//     }

//     trigger OnInsertRecord(BelowxRec: Boolean): Boolean
//     var
//         tempstr: text;
//     begin
//         tempstr := COPYSTR(CreatedbyEmail, 1, STRPOS(CreatedbyEmail, '@') - 1);
//         IF NOT portalUsers.GET(CreatedbyEmail) THEN CreatePortalUser(CreatedbyEmail, tempstr);
//         rec."Created By" := tempstr;
//         rec."Created by API" := true;
//     end;

//     procedure CreatePortalUser(var emailid: text; var USER: text[50]): Code[50]
//     var
//         PortalUser: record "Portal Users";
//     begin
//         PortalUser.init;
//         PortalUser.Email := emailid;
//         PortalUser.UserId := User;
//         PortalUser.Name := User;
//         if PortalUser.Insert(True) then exit(PortalUser.UserId);
//     end;

//     trigger OnModifyRecord(): Boolean
//     var
//         UpdateContFromCust: Codeunit 5056;
//     begin
//         UpdateContFromCust.OnModify(rec);
//     end;

//     trigger OnAfterGetRecord()
//     var
//         pd: Record 50019;
//     begin
//         spname := '';
//         IF rec."Salesperson Code" <> '' THEN BEGIN
//             sp.SETRANGE(sp.Code, rec."Salesperson Code");
//             IF sp.FINDFIRST THEN
//                 spname := sp.Name;
//         END;
//         //Nb
//         CompanyNo := '';
//         CBR.SETFILTER(CBR."Link to Table", '%1', CBR."Link to Table"::Customer);
//         CBR.SETFILTER(CBR."No.", rec."No.");
//         CBR.SETFILTER(CBR."Business Relation Code", '%1', 'CUST');
//         IF CBR.FINDFIRST THEN BEGIN
//             contact1.SETFILTER(contact1."No.", CBR."Contact No.");
//             IF contact1.FINDFIRST THEN CompanyNo := contact1."Company No.";
//         END;

//         StateName := '';
//         state.SETFILTER(state.Code, rec."Territory Code");
//         IF state.FINDFIRST THEN StateName := state.Name;

//         AttachmentCount := 0;
//         pd.SETFILTER(pd."Sell-to Customer No.", rec."No.");
//         IF pd.FINDSET THEN AttachmentCount := pd.COUNT;

//     end;


//     var
//         CreatedbyEmail: Text;
//         APIWrite: Codeunit 50059;
//         PortalUsers: record "Portal Users";
//         sp: Record 13;
//         spname: Text[50];
//         CompanyNo: Code[20];
//         contact1: Record 5050;
//         CBR: Record 5054;
//         StateName: Text[50];
//         state: Record 286;
//         AttachmentCount: Integer;
// }
