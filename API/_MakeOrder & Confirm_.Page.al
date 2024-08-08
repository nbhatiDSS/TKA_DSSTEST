page 61004 "MakeOrder & Confirm"
{
    APIGroup = 'API';
    APIPublisher = 'Direction_Software_LLP';
    APIVersion = 'v1.0';
    ApplicationArea = All;
    Caption = 'MakeOrder & Confirm';
    DelayedInsert = true;
    EntityName = 'events';
    EntitySetName = 'MakeOrderConfirm';
    PageType = API;
    SourceTableTemporary = true;
    SourceTable = "Sales Header";

    layout
    {
        area(Content)
        {
            field("No"; Rec."No.")
            {
            }
            field(makeorder; makeorder)
            {
            }
            field(confirmOrder; confirmOrder)
            {
            }
            field(SONo; SONo)
            {
            }
            field("ConfirmedBy"; confirmedBy)
            {
            }
        }
    }
    trigger OnInsertRecord(BelowxRec: Boolean): Boolean var
    begin
        if makeorder then begin
            SONo:=apiwrite.MakeOrder(Rec."No.")end;
        if confirmOrder then begin
            if confirmedBy = '' then Error('Confirmed By cannot be blank');
            if SONo <> '' then begin
                apiwrite.ConfirmOrder(SONo, true, confirmedBy);
            end
            else
                apiwrite.ConfirmOrder(rec."No.", true, confirmedBy);
        end;
    end;
    var confirmedBy: Text[100];
    SONo: code[20];
    apiwrite: Codeunit 50059;
    makeorder: boolean;
    confirmOrder: boolean;
    UnconfirmOrder: boolean;
}
