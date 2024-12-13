codeunit 70000 MyCodeunit
{
    Permissions = tabledata "Sales Invoice Header" = rim;

    //MAsterType
    // [EventSubscriber(ObjectType::Table, Database::"Invoice Post. Buffer", OnAfterCopyToGenJnlLine, '', false, false)]
    // local procedure "Invoice Post. Buffer_OnAfterCopyToGenJnlLine"(var GenJnlLine: Record "Gen. Journal Line"; InvoicePostBuffer: Record "Invoice Post. Buffer" temporary)
    // begin
    //     GenJnlLine.MasterCode := InvoicePostBuffer.MasterCode;
    //     GenJnlLine.MasterType := InvoicePostBuffer.MasterType;
    // end;

    // [EventSubscriber(ObjectType::Table, Database::"Invoice Posting Buffer", OnAfterCopyToGenJnlLine, '', false, false)]
    // local procedure "Invoice Posting Buffer_OnAfterCopyToGenJnlLine"(var GenJnlLine: Record "Gen. Journal Line"; InvoicePostingBuffer: Record "Invoice Posting Buffer" temporary)
    // begin
    //     GenJnlLine.MasterCode := InvoicePostingBuffer.MasterCode;
    //     GenJnlLine.MasterType := InvoicePostingBuffer.MasterType;
    // end;



    //For APIs
    [EventSubscriber(ObjectType::Table, Database::Contact, OnBeforeCheckIfTypeChangePossibleForPerson, '', false, false)]
    local procedure Contact_OnBeforeCheckIfTypeChangePossibleForPerson(var Contact: Record Contact; xContact: Record Contact; var IsHandled: Boolean)
    begin
        if UpperCase(UserId()) in ['WEB SERVICE'] then begin
            IsHandled := true;
        end
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", OnBeforeCheckShipmentDateBeforeWorkDate, '', false, false)]
    local procedure "Sales Line_OnBeforeCheckShipmentDateBeforeWorkDate"(var Sender: Record "Sales Line"; var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line"; var HasBeenShown: Boolean; var IsHandled: Boolean)
    begin
        if not GuiAllowed then ishandled := true;

    end;


    procedure GetPaidAmount(CustLedgEntryNo: integer): decimal
    var
        CustLedgEntry, CustLedgEntry1 : record "Cust. Ledger Entry";
        DetCustLedgEntry, DetCustLedgEntry1 : Record "Detailed Cust. Ledg. Entry";
        PaidAmount: Decimal;
    begin
        if CustLedgEntry.get(CustLedgEntryNo) then begin
            // CustLedgEntry1 := CustLedgEntry;
            // eventTriggers.GetAppliedentries(CustLedgEntry1);
            DetCustLedgEntry.SetFilter("Cust. Ledger Entry No.", '%1', CustLedgEntry."Entry No.");
            DetCustLedgEntry.SetFilter("Entry Type", '%1', DetCustLedgEntry."Entry Type"::Application);
            DetCustLedgEntry.SetFilter(Unapplied, '%1', false);
            if DetCustLedgEntry.FindFirst() then
                repeat
                    DetCustLedgEntry1.SetFilter("Customer No.", '%1', CustLedgEntry."Customer No.");
                    DetCustLedgEntry1.SetFilter("Entry Type", '%1', DetCustLedgEntry1."Entry Type"::Application);
                    DetCustLedgEntry1.SetFilter(Unapplied, '%1', false);
                    DetCustLedgEntry1.SetFilter("Document Type", '%1', DetCustLedgEntry."Document Type");
                    DetCustLedgEntry1.SetFilter("Document No.", '%1', DetCustLedgEntry."Document No.");
                    DetCustLedgEntry1.SetFilter("Entry No.", '<>%1', DetCustLedgEntry."Entry No.");
                    if DetCustLedgEntry1.FindFirst() then begin
                        if CustLedgEntry1.get(DetCustLedgEntry1."Cust. Ledger Entry No.") then begin
                            if (CustLedgEntry1."Document Type" <> CustLedgEntry1."Document Type"::"Credit Memo") then PaidAmount += Abs(DetCustLedgEntry1."Amount (LCY)");
                        end;
                    end;
                until DetCustLedgEntry.Next() = 0;
        end;
        exit(PaidAmount)
    end;

    // // Payment Status Code NB 230924
    // procedure GetAppliedentries(var recCustLedg: record "Cust. Ledger Entry")
    // var
    //     CreateCustLedgEntry: Record "Cust. Ledger Entry";
    // begin
    //     recCustLedg.Reset();
    //     if recCustLedg."Entry No." <> 0 then begin
    //         CreateCustLedgEntry := recCustLedg;
    //         FindApplnEntriesDtldtLedgEntry(recCustLedg, CreateCustLedgEntry);
    //         recCustLedg.SetCurrentKey("Entry No.");
    //         recCustLedg.SetRange("Entry No.");
    //         if CreateCustLedgEntry."Closed by Entry No." <> 0 then begin
    //             recCustLedg."Entry No." := CreateCustLedgEntry."Closed by Entry No.";
    //             recCustLedg.Mark(true);
    //         end;
    //         recCustLedg.SetCurrentKey("Closed by Entry No.");
    //         recCustLedg.SetRange("Closed by Entry No.", CreateCustLedgEntry."Entry No.");
    //         if recCustLedg.Find('-') then
    //             repeat
    //                 recCustLedg.Mark(true);
    //             until recCustLedg.Next() = 0;
    //         recCustLedg.SetCurrentKey("Entry No.");
    //         recCustLedg.SetRange("Closed by Entry No.");
    //     end;
    //     recCustLedg.MarkedOnly(true);
    // end;

    // local procedure FindApplnEntriesDtldtLedgEntry(var recCustLedg: Record "Cust. Ledger Entry"; var CreateCustLedgEntry: Record "Cust. Ledger Entry")
    // var
    //     DtldCustLedgEntry1: Record "Detailed Cust. Ledg. Entry";
    //     DtldCustLedgEntry2: Record "Detailed Cust. Ledg. Entry";
    // begin
    //     DtldCustLedgEntry1.SetCurrentKey("Cust. Ledger Entry No.");
    //     DtldCustLedgEntry1.SetRange("Cust. Ledger Entry No.", CreateCustLedgEntry."Entry No.");
    //     DtldCustLedgEntry1.SetRange(Unapplied, false);
    //     if DtldCustLedgEntry1.Find('-') then
    //         repeat
    //             if DtldCustLedgEntry1."Cust. Ledger Entry No." = DtldCustLedgEntry1."Applied Cust. Ledger Entry No." then begin
    //                 DtldCustLedgEntry2.Init();
    //                 DtldCustLedgEntry2.SetCurrentKey("Applied Cust. Ledger Entry No.", "Entry Type");
    //                 DtldCustLedgEntry2.SetRange("Applied Cust. Ledger Entry No.", DtldCustLedgEntry1."Applied Cust. Ledger Entry No.");
    //                 DtldCustLedgEntry2.SetRange("Entry Type", DtldCustLedgEntry2."Entry Type"::Application);
    //                 DtldCustLedgEntry2.SetRange(Unapplied, false);
    //                 if DtldCustLedgEntry2.Find('-') then
    //                     repeat
    //                         if DtldCustLedgEntry2."Cust. Ledger Entry No." <> DtldCustLedgEntry2."Applied Cust. Ledger Entry No." then begin
    //                             recCustLedg.SetCurrentKey("Entry No.");
    //                             recCustLedg.SetRange("Entry No.", DtldCustLedgEntry2."Cust. Ledger Entry No.");
    //                             if recCustLedg.Find('-') AND (recCustLedg."Entry No." <> 0) then recCustLedg.Mark(true);
    //                         end;
    //                     until DtldCustLedgEntry2.Next() = 0;
    //             end
    //             else begin
    //                 recCustLedg.SetCurrentKey("Entry No.");
    //                 recCustLedg.SetRange("Entry No.", DtldCustLedgEntry1."Applied Cust. Ledger Entry No.");
    //                 if recCustLedg.Find('-') AND (recCustLedg."Entry No." <> 0) then recCustLedg.Mark(true);
    //             end;
    //         until DtldCustLedgEntry1.Next() = 0;
    // end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", OnAfterInitOldDtldCVLedgEntryBuf, '', false, false)]
    // local procedure "Gen. Jnl.-Post Line_OnAfterInitOldDtldCVLedgEntryBuf"(var DtldCVLedgEntryBuf: Record "Detailed CV Ledg. Entry Buffer";
    //  var NewCVLedgEntryBuf: Record "CV Ledger Entry Buffer";
    //  var OldCVLedgEntryBuf: Record "CV Ledger Entry Buffer";
    //  var PrevNewCVLedgEntryBuf: Record "CV Ledger Entry Buffer";
    //  var PrevOldCVLedgEntryBuf: Record "CV Ledger Entry Buffer";
    //  var GenJnlLine: Record "Gen. Journal Line")
    // begin
    //     OldCVLedgEntryBuf."Closed By Doc. Type" := NewCVLedgEntryBuf."Document Type";
    // end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", OnAfterInitNewDtldCVLedgEntryBuf, '', false, false)]
    // local procedure "Gen. Jnl.-Post Line_OnAfterInitNewDtldCVLedgEntryBuf"(var DtldCVLedgEntryBuf: Record "Detailed CV Ledg. Entry Buffer";
    //  var NewCVLedgEntryBuf: Record "CV Ledger Entry Buffer";
    //  var OldCVLedgEntryBuf: Record "CV Ledger Entry Buffer";
    //  var PrevNewCVLedgEntryBuf: Record "CV Ledger Entry Buffer";
    //  var PrevOldCVLedgEntryBuf: Record "CV Ledger Entry Buffer";
    //  var GenJnlLine: Record "Gen. Journal Line")
    // begin
    //     NewCVLedgEntryBuf."Closed By Doc. Type" := OldCVLedgEntryBuf."Document Type";
    // end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"CustEntry-Apply Posted Entries", OnApplyOnBeforeCustPostApplyCustLedgEntry, '', false, false)]
    // local procedure "CustEntry-Apply Posted Entries_OnApplyOnBeforeCustPostApplyCustLedgEntry"(CustLedgerEntry: Record "Cust. Ledger Entry"; var ApplyUnapplyParameters: Record "Apply Unapply Parameters" temporary)
    // var
    //     ApplyToCustLedgEntry: record "Cust. Ledger Entry";
    //     SingleInsCU: codeunit SingleInstanceCU;
    // begin
    //     SingleInsCU.ClearTempCLE();
    //     ApplyToCustLedgEntry.SetCurrentKey("Customer No.", "Applies-to ID");
    //     ApplyToCustLedgEntry.SetRange("Customer No.", CustLedgerEntry."Customer No.");
    //     ApplyToCustLedgEntry.SetRange("Applies-to ID", CustLedgerEntry."Applies-to ID");
    //     ApplyToCustLedgEntry.FindSet();
    //     repeat
    //         SingleInsCU.InsertIntoTempCLE(ApplyToCustLedgEntry);
    //     until ApplyToCustLedgEntry.Next() = 0;

    // end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"CustEntry-Apply Posted Entries", OnCustPostApplyCustLedgEntryOnBeforeCommit, '', false, false)]
    // local procedure "CustEntry-Apply Posted Entries_OnCustPostApplyCustLedgEntryOnBeforeCommit"(var CustLedgerEntry: Record "Cust. Ledger Entry"; var SuppressCommit: Boolean)
    // var
    //     TempCustLedgEntry: record "Cust. Ledger Entry" temporary;
    //     SingleInsCU: codeunit SingleInstanceCU;
    //     payment: Boolean;
    //     Credit: Boolean;
    //     Amount: Decimal;
    //     CLE, cle1, cle2 : record "Cust. Ledger Entry";
    //     SalesInvoiceNo: code[20];
    //     PayStatus: text;
    //     SalesInvHeader: record "Sales Invoice Header";
    //     Invoice_Open: boolean;
    //     TempExcelBuff: record "Excel Buffer" temporary;
    // begin
    //     Credit := false;
    //     payment := false;
    //     Amount := 0;
    //     SingleInsCU.GetTempCLE(TempCustLedgEntry);
    //     SingleInsCU.ClearTempCLE();
    //     if TempCustLedgEntry.FindFirst() then
    //         repeat
    //             cle.get(TempCustLedgEntry."Entry No.");
    //             case Cle."Document Type" of
    //                 "Gen. Journal Document Type"::"Credit Memo":
    //                     begin
    //                         if (cle."Closed By Doc. Type" = cle."Closed By Doc. Type"::Invoice) then begin
    //                             Credit := true;
    //                             UpdateTempExcelBuffer(TempExcelBuff, cle."Closed by Entry No.", Credit); // 031224
    //                         end;
    //                     end;
    //                 "Gen. Journal Document Type"::Invoice:
    //                     begin
    //                         Amount := 0;
    //                         SalesInvoiceNo := CLE."Document No.";
    //                         if cle."Closed by Entry No." <> 0 then begin
    //                             if (cle."Closed By Doc. Type" = cle."Closed By Doc. Type"::" ") OR (cle."Closed By Doc. Type" = cle."Closed By Doc. Type"::Payment) then
    //                                 payment := true
    //                             else if (cle."Closed By Doc. Type" = cle."Closed By Doc. Type"::"Credit Memo") then
    //                                 credit := true;
    //                         end;
    //                         cle1.Reset();
    //                         cle1.get(cle."Entry No.");
    //                         GetAppliedentries(CLE1);
    //                         if cle1.FindFirst() then
    //                             repeat
    //                                 if cle1."Entry No." <> 0 then
    //                                     case cle1."Document Type" of
    //                                         "Gen. Journal Document Type"::" ", "Gen. Journal Document Type"::Payment:
    //                                             begin
    //                                                 cle1.CalcFields("Amount (LCY)");
    //                                                 payment := true;
    //                                                 Amount += cle1."Amount (LCY)";
    //                                             end;
    //                                         "Gen. Journal Document Type"::"Credit Memo":
    //                                             begin
    //                                                 cle1.CalcFields("Amount (LCY)");
    //                                                 Credit := true;
    //                                                 Amount += cle1."Amount (LCY)";
    //                                             end;
    //                                     end;
    //                             until cle1.Next() = 0;
    //                         cle.CalcFields("Amount (LCY)");
    //                         Amount += cle."Amount (LCY)";
    //                         Invoice_Open := cle.open;

    //                         UpdateTempExcelBuffer(TempExcelBuff, CLE."Entry No.", payment, Credit, cle.Open, Amount);
    //                     end;
    //             end;
    //         // Amount += TempCustLedgEntry."Amount to Apply";
    //         until TempCustLedgEntry.Next() = 0;

    //     // 031224
    //     if TempExcelBuff.FindFirst() then begin
    //         cle2.Reset();
    //         if cle2.get(TempExcelBuff."Row No.") then begin
    //             if cle2."Document Type" = cle2."Document Type"::Invoice then begin
    //                 if (Amount <= 0) then begin
    //                     if not Invoice_Open then begin
    //                         if payment and Credit then begin
    //                             PayStatus := 'PARTIALLY PAID';
    //                         end
    //                         else if payment then begin
    //                             PayStatus := 'PAID';
    //                         end
    //                         else if Credit then begin
    //                             PayStatus := 'CREDITED';
    //                         end;
    //                     end
    //                     else begin
    //                         if payment then begin
    //                             PayStatus := 'PARTIALLY PAID';
    //                         end else
    //                             Paystatus := 'UNPAID';
    //                     end;
    //                 end else begin
    //                     if payment then
    //                         PayStatus := 'PARTIALLY PAID'
    //                     else
    //                         Paystatus := 'UNPAID';
    //                 end;
    //                 SalesInvHeader.get(cle2."Document No.");
    //                 SalesInvHeader.PaymentStatus3 := PayStatus;
    //                 SalesInvHeader.Modify();
    //                 UpdateUtilizationKP(SalesInvHeader);
    //             end;
    //         end;
    //     end;
    //     // if SalesInvoiceNo <> '' then begin
    //     //     if (Amount <= 0) then begin
    //     //         if not Invoice_Open then begin
    //     //             if payment and Credit then begin
    //     //                 PayStatus := 'PARTIALLY PAID';
    //     //             end
    //     //             else if payment then begin
    //     //                 PayStatus := 'PAID';
    //     //             end
    //     //             else if Credit then begin
    //     //                 PayStatus := 'CREDITED';
    //     //             end;
    //     //         end
    //     //         else begin
    //     //             if payment then begin
    //     //                 PayStatus := 'PARTIALLY PAID';
    //     //             end else
    //     //                 Paystatus := 'UNPAID';
    //     //         end;
    //     //     end else begin
    //     //         if payment then
    //     //             PayStatus := 'PARTIALLY PAID'
    //     //         else
    //     //             Paystatus := 'UNPAID';
    //     //     end;
    //     //     SalesInvHeader.get(SalesInvoiceNo);
    //     //     SalesInvHeader.PaymentStatus3 := PayStatus;
    //     //     SalesInvHeader.Modify();
    //     //     UpdateUtilizationKP(SalesInvHeader);
    //     // end;


    // end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"CustEntry-Apply Posted Entries", OnPostUnApplyCustomerCommitOnAfterSetFilters, '', false, false)]
    // local procedure "CustEntry-Apply Posted Entries_OnPostUnApplyCustomerCommitOnAfterSetFilters"(var DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry"; DetailedCustLedgEntry2: Record "Detailed Cust. Ledg. Entry")
    // var
    //     Cle: record "Cust. Ledger Entry";
    //     SingleInsCU: codeunit SingleInstanceCU;
    // begin
    //     SingleInsCU.ClearTempCLE();
    //     if DetailedCustLedgEntry.FindFirst() then
    //         repeat
    //             if cle.get(DetailedCustLedgEntry."Cust. Ledger Entry No.") then begin
    //                 if cle."Document Type" = cle."Document Type"::Invoice then begin
    //                     SingleInsCU.InsertIntoTempCLE(cle);
    //                 end;
    //             end;
    //         until DetailedCustLedgEntry.Next() = 0;
    // end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"CustEntry-Apply Posted Entries", OnAfterPostUnapplyCustLedgEntry, '', false, false)]
    // local procedure "CustEntry-Apply Posted Entries_OnAfterPostUnapplyCustLedgEntry"(GenJournalLine: Record "Gen. Journal Line"; CustLedgerEntry: Record "Cust. Ledger Entry"; DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var CommitChanges: Boolean; var TempCustLedgerEntry: Record "Cust. Ledger Entry" temporary)
    // var
    //     TempCustLedgEntry: record "Cust. Ledger Entry" temporary;
    //     SingleInsCU: codeunit SingleInstanceCU;
    //     cle: record "Cust. Ledger Entry";
    //     Payment: Boolean;
    //     SalesInvHeader: record "Sales Invoice Header";
    // begin
    //     SingleInsCU.GetTempCLE(TempCustLedgEntry);
    //     SingleInsCU.ClearTempCLE();
    //     if TempCustLedgEntry.FindFirst() then
    //         repeat
    //             Payment := false;
    //             cle.get(TempCustLedgEntry."Entry No.");
    //             GetAppliedentries(cle);
    //             if cle.findfirst then
    //                 repeat
    //                     if cle."Entry No." <> 0 then
    //                         if (cle."Document Type" = cle."Document Type"::Payment) OR (cle."Document Type" = cle."Document Type"::" ") then payment := true;
    //                 until cle.next = 0;

    //             if SalesInvHeader.get(TempCustLedgEntry."Document No.") then begin
    //                 if Payment then
    //                     SalesInvHeader.PaymentStatus3 := 'PARTIALLY PAID'
    //                 ELSE
    //                     SalesInvHeader.PaymentStatus3 := 'UNPAID';
    //                 SalesInvHeader.Modify();
    //                 UpdateUtilizationKP(SalesInvHeader);
    //             end;
    //         until TempCustLedgerEntry.Next() = 0;
    // end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnAfterPostSalesDoc, '', false, false)]
    // local procedure "Sales-Post_OnAfterPostSalesDoc"(var SalesHeader: Record "Sales Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; SalesShptHdrNo: Code[20]; RetRcpHdrNo: Code[20]; SalesInvHdrNo: Code[20]; SalesCrMemoHdrNo: Code[20]; CommitIsSuppressed: Boolean; InvtPickPutaway: Boolean; var CustLedgerEntry: Record "Cust. Ledger Entry"; WhseShip: Boolean; WhseReceiv: Boolean; PreviewMode: Boolean)
    // var
    //     CstLedgEntry: record "Cust. Ledger Entry";
    //     payment: boolean;
    //     salesInvHeader: record "Sales Invoice Header";
    //     crAmt: decimal;
    // begin
    //     payment := false;
    //     if (SalesHeader."Document Type" = SalesHeader."Document Type"::"Credit Memo") AND
    //     (SalesHeader."Applies-to Doc. Type" = SalesHeader."Applies-to Doc. Type"::Invoice) then begin
    //         CstLedgEntry.SetCurrentKey("Document Type", "Document No.");
    //         CstLedgEntry.SetFilter("Document Type", '%1', CstLedgEntry."Document Type"::Invoice);
    //         CstLedgEntry.SetFilter("Document No.", '%1', SalesHeader."Applies-to Doc. No.");
    //         if CstLedgEntry.FindFirst() then begin
    //             GetAppliedentries(CstLedgEntry);
    //             if CstLedgEntry.FindFirst() then
    //                 repeat
    //                     if CstLedgEntry."Entry No." <> 0 then
    //                         if (CstLedgEntry."Document Type" = CstLedgEntry."Document Type"::" ") OR (CstLedgEntry."Document Type" = CstLedgEntry."Document Type"::Payment)
    //                          then begin
    //                             payment := true;
    //                         end else if (CstLedgEntry."Document Type" = CstLedgEntry."Document Type"::"Credit Memo") then begin
    //                             CstLedgEntry.CalcFields("Amount (LCY)");
    //                             crAmt += abs(CstLedgEntry."Amount (LCY)");
    //                         end;
    //                 until CstLedgEntry.Next() = 0;
    //         end;
    //         if salesInvHeader.get(SalesHeader."Applies-to Doc. No.") then begin
    //             if payment then
    //                 salesInvHeader.PaymentStatus3 := 'PARTIALLY PAID'
    //             else begin
    //                 salesInvHeader.CalcFields("Amount Including VAT");
    //                 SalesHeader.CalcFields("Amount Including VAT");
    //                 if (salesInvHeader."Amount Including VAT" <= SalesHeader."Amount Including VAT" + crAmt) then
    //                     salesInvHeader.PaymentStatus3 := 'CREDITED';
    //             end;
    //             salesInvHeader.Modify();
    //             UpdateUtilizationKP(SalesInvHeader);
    //         end;
    //     end;

    // end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", OnAfterApplyCustLedgEntry, '', false, false)]
    // local procedure "Gen. Jnl.-Post Line_OnAfterApplyCustLedgEntry"(var Sender: Codeunit "Gen. Jnl.-Post Line"; var GenJnlLine: Record "Gen. Journal Line"; var NewCVLedgEntryBuf: Record "CV Ledger Entry Buffer"; var OldCustLedgEntry: Record "Cust. Ledger Entry"; NewRemainingAmtBeforeAppln: Decimal)
    // var
    //     SalesInvHeader: record "Sales Invoice Header";
    //     CLe, cle1 : record "Cust. Ledger Entry";
    //     payment, Credit : boolean;
    // begin
    //     if GenJnlLine."Applies-to Doc. Type" = GenJnlLine."Applies-to Doc. Type"::Invoice then begin
    //         if SalesInvHeader.get(GenJnlLine."Applies-to Doc. No.") then begin
    //             if CLe.get(SalesInvHeader."Cust. Ledger Entry No.") then begin
    //                 cle1 := cle;
    //                 GetAppliedentries(cle1);
    //                 if cle1.FindFirst() then
    //                     repeat
    //                         if cle1."Entry No." <> 0 then
    //                             case cle1."Document Type" of
    //                                 "Gen. Journal Document Type"::"Credit Memo":
    //                                     Credit := true;
    //                             end;
    //                     until cle1.Next() = 0;
    //                 if not cle.Open then begin
    //                     if Credit then
    //                         SalesInvHeader.PaymentStatus3 := 'PARTIALLY PAID'
    //                     ELSE
    //                         SalesInvHeader.PaymentStatus3 := 'PAID';
    //                 end else
    //                     SalesInvHeader.PaymentStatus3 := 'PARTIALLY PAID';
    //                 SalesInvHeader.Modify();
    //                 UpdateUtilizationKP(SalesInvHeader);
    //             end;
    //         end;
    //     end;
    // end;

    // procedure UpdateUtilizationKP(SalesInvHeader: Record "Sales Invoice Header")
    // var
    //     temp_salesInvHeader: record "Sales Invoice Header" temporary;
    //     SalesInvHeader1: Record "Sales Invoice Header";
    //     salesInvLine: record "Sales Invoice Line";
    // begin
    //     if CheckInvoiceKPFP(SalesInvHeader) then begin
    //         salesInvLine.Reset();
    //         salesInvLine.SetFilter("KP No.", '%1', SalesInvHeader."No.");
    //         if salesInvLine.FindFirst() then
    //             repeat
    //                 if SalesInvHeader1.get(salesInvLine."Document No.") then begin
    //                     if not temp_salesInvHeader.get(SalesInvHeader1."No.") then begin
    //                         if not (SalesInvHeader1.PaymentStatus3 = 'CREDITED') then
    //                             SalesInvHeader1.PaymentStatus3 := SalesInvHeader.PaymentStatus3;
    //                         SalesInvHeader1.Modify();

    //                         temp_salesInvHeader.Init();
    //                         temp_salesInvHeader.Copy(SalesInvHeader1);
    //                         temp_salesInvHeader.Insert();
    //                     end;
    //                 end;
    //             until salesInvLine.next() = 0;
    //     end
    // end;

    // procedure CheckInvoiceKPFP(salesInvHeader: record "Sales Invoice Header"): boolean
    // begin
    //     if salesInvHeader."Flexi Pass" OR salesInvHeader."Flexi Pass 2" OR salesInvHeader."Flexi Pass 12" OR salesInvHeader."Knowledge Pass" then
    //         exit(True)
    //     else
    //         exit(false)
    // end;

    // local procedure UpdateTempExcelBuffer(var ExcelBuffer: Record "Excel Buffer"; EntryNo: integer; Credit: boolean)
    // begin
    //     if not ExcelBuffer.get(EntryNo, 0) then begin
    //         ExcelBuffer.Init();
    //         ExcelBuffer."Row No." := EntryNo;
    //         ExcelBuffer.Insert();
    //     end else
    //         ;
    //     ExcelBuffer.B2C := Credit; //B2C used for credit 
    //     ExcelBuffer.Modify();
    // end;

    // local procedure UpdateTempExcelBuffer(var ExcelBuffer: Record "Excel Buffer"; EntryNo: integer; payment: boolean; Credit: boolean; Open: boolean; Amount: Decimal)
    // var
    //     row: Integer;
    // begin
    //     if not ExcelBuffer.get(EntryNo, 0) then begin
    //         ExcelBuffer.Init();
    //         ExcelBuffer."Row No." := EntryNo;
    //         ExcelBuffer.Insert();
    //     end else
    //         ;

    //     ExcelBuffer.B2B := payment; //B2B used for payment 
    //     ExcelBuffer.B2C := Credit; //B2C used for credit 
    //     ExcelBuffer.Bold := Open;
    //     ExcelBuffer.Amount := Amount;
    //     ExcelBuffer.Modify();
    // end;
    // // Payment Status Code  NB 230924



    var
        webhooktype: enum WebhookType;
        CLEDocType: Enum "Gen. Journal Document Type";
        t: page 6405;
        cc: codeunit "Gen. Jnl.-Post Line";
        eventLabel: Label 'Event';

}
