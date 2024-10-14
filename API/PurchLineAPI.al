// // ------------------------------------------------------------------------------------------------
// // Copyright (c) Microsoft Corporation. All rights reserved.
// // Licensed under the MIT License. See License.txt in the project root for license information.
// // ------------------------------------------------------------------------------------------------

// page 61012 PurchLineAPI
// {
//     Caption = 'Purchase Document Line Entity', Locked = true;
//     DelayedInsert = true;
//     PageType = ListPart;
//     SourceTable = "Purchase Line";

//     layout
//     {
//         area(content)
//         {
//             repeater(Group)
//             {
//                 field(Document_Type; Rec."Document Type")
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Document Type', Locked = true;
//                 }
//                 field(Document_No; Rec."Document No.")
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Document No.', Locked = true;
//                 }
//                 field(Line_No; Rec."Line No.")
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Line No.', Locked = true;
//                 }
//                 field(type; Rec.Type)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Type', Locked = true;
//                 }
//                 field(No; Rec."No.")
//                 {
//                     ApplicationArea = All;
//                     Caption = 'No.', Locked = true;

//                     trigger OnValidate()
//                     begin
//                         EntityChanged := true;
//                     end;
//                 }
//                 field(Description; Rec.Description)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Description', Locked = true;
//                 }
//                 field(Quantity; Rec.Quantity)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Quantity', Locked = true;
//                 }
//                 field(Direct_Unit_Cost; Rec."Direct Unit Cost")
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Direct Unit Cost', Locked = true;
//                 }
//                 field(Unit_Cost; Rec."Unit Cost")
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Unit Cost', Locked = true;
//                 }
//                 field(vatPercent; Rec."VAT %")
//                 {
//                     ApplicationArea = All;
//                     Caption = 'VAT %', Locked = true;
//                 }
//                 field("Event_No"; Rec."Event No.")
//                 {
//                     ApplicationArea = All;
//                     Caption = 'VAT %', Locked = true;
//                 }
//                 field(MasterCode; Rec.MasterCode)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'VAT %', Locked = true;
//                 }
//                 field(MasterType; Rec.MasterType)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'VAT %', Locked = true;
//                 }
//                 field("VATBusPostingGroup"; Rec."VAT Bus. Posting Group")
//                 {
//                     ApplicationArea = All;
//                     Caption = 'VAT Bus. Posting Group', Locked = true;
//                 }

//                 field("VATProdPostingGroup"; Rec."VAT Prod. Posting Group")
//                 {
//                     ApplicationArea = All;
//                     Caption = 'VAT Prod. Posting Group', Locked = true;
//                 }

//             }
//         }
//     }

//     actions
//     {
//     }

//     trigger OnInsertRecord(BelowxRec: Boolean): Boolean
//     var
//         PurchaseLine: Record "Purchase Line";
//     begin
//         rec."Line No." := 10000;
//         PurchaseLine.SetCurrentKey("Document No.", "Document Type");
//         PurchaseLine.SetFilter("Document No.", rec."Document No.");
//         PurchaseLine.SetFilter("Document Type", '%1', rec."Document Type");
//         if PurchaseLine.FindLast() then rec."Line No." += PurchaseLine."Line No.";
//         if InsertExtendedText() then
//             exit(false);
//     end;

//     trigger OnModifyRecord(): Boolean
//     begin
//         if EntityChanged then
//             if InsertExtendedText() then
//                 exit(false);
//     end;

//     var
//         EntityChanged: Boolean;

//     local procedure InsertExtendedText(): Boolean
//     var
//         PurchaseLine: Record "Purchase Line";
//         TransferExtendedText: Codeunit "Transfer Extended Text";
//     begin
//         if TransferExtendedText.PurchCheckIfAnyExtText(Rec, false) then begin
//             if PurchaseLine.Get(Rec."Document Type", Rec."Document No.", Rec."Line No.") then
//                 Rec.Modify(true)
//             else
//                 Rec.Insert(true);
//             Commit();
//             TransferExtendedText.InsertPurchExtText(Rec);
//             exit(true);
//         end;
//         exit(false);
//     end;
// }
