page 61001 "Contacts API"
{
    APIGroup = 'API';
    APIPublisher = 'Direction_Software_LLP';
    APIVersion = 'v1.0', 'v2.0';
    ApplicationArea = All;
    Caption = 'contact';
    DelayedInsert = true;
    EntityName = 'events';
    EntitySetName = 'contact';
    PageType = API;
    ODataKeyFields = "No.";
    SourceTable = 5050;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(SystemId; Rec.SystemId)
                {
                }
                field("No"; rec."No.")
                {
                    Editable = false;
                }
                field(Name; rec.Name)
                {
                }
                field("E_Mail"; rec."E-Mail")
                {
                }
                field(Type; rec.Type)
                {
                }
                field("Phone_No"; rec."Phone No.")
                {
                }
                field("Salesperson_Code"; rec."Salesperson Code")
                {
                }
                field("Last_Date_Modified"; rec."Last Date Modified")
                {
                }
                field("Associated_Cust_No"; ACustomer)
                {
                }
                field("Company_No"; rec."Company No.")
                {
                }
                field("Post_Code"; rec."Post Code")
                {
                    Caption = 'Post Code';
                }
                field("Country_Region_Code"; rec."Country/Region Code")
                {
                }
                field(Address; rec.Address)
                {
                }
                field("Address_2"; rec."Address 2")
                {
                }
                field(City; rec.City)
                {
                }
                field(createdbyemail; createdByEmail)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        portalusers: record "Portal Users";
        APIWrite: Codeunit "API Write";
    begin
        if portalUsers.get(createdbyemail) then
            rec."Created By" := portalUsers."UserID"
        else begin
            tempstr := COPYSTR(createdbyemail, 1, STRPOS(createdbyemail, '@') - 1);
            IF STRLEN(tempstr) > 25 THEN BEGIN
                tempstr := COPYSTR(tempstr, 1, STRPOS(tempstr, '-') - 1)
            END;
            rec."Created By" := APIWrite.CreatePortalUser(createdbyemail, tempstr);
        end;
        rec."Created by API" := TRUE;
        rec."Contact Business Relation" := rec."Contact Business Relation"::Customer;
    end;

    trigger OnAfterGetRecord()
    begin
        //NB
        ACustomer := '';
        contact.SETFILTER(contact."No.", rec."Company No.");
        contact.SETFILTER(contact.Type, '%1', contact.Type::Company);
        IF contact.FINDFIRST THEN BEGIN
            CBR.SETFILTER(CBR."Contact No.", contact."No.");
            CBR.SETFILTER(CBR."Business Relation Code", '%1', 'CUST');
            IF CBR.FINDFIRST THEN ACustomer := CBR."No.";
            //cust.SETFILTER(cust.Name, contact.Name);
            //IF cust.FINDFIRST THEN ACustomer := cust."No.";
        END;
        //NB
    end;

    var
        contact: Record 5050;
        ACustomer: Code[20];
        cust: Record 18;
        CBR: Record 5054;
        createdByEmail: text;
        tempstr: Text[100];
}
