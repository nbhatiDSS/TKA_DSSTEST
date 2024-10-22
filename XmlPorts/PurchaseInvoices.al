// xmlport 70000 ImportPurchaseInvoices
// {

//     Format = VariableText;
//     Direction = Import;
//     TextEncoding = UTF8;
//     UseRequestPage = false;


//     schema
//     {
//         textelement(Root)
//         {
//             tableelement(Integer; Integer)
//             {
//                 AutoSave = false;
//                 AutoReplace = false;
//                 AutoUpdate = false;
//                 textelement(YourRef)
//                 {
//                     MinOccurs = Zero;
//                 }
//                 textelement(DocType)
//                 {
//                     MinOccurs = Zero;
//                 }
//                 textelement(VendorNo)
//                 {
//                     MinOccurs = Zero;
//                 }
//                 textelement(DocDate)
//                 {
//                     MinOccurs = Zero;
//                 }
//                 textelement(PostingDate)
//                 {
//                     MinOccurs = Zero;
//                 }
//                 textelement(VendorInvoiceNo)
//                 {
//                     MinOccurs = Zero;
//                 }
//                 textelement(ProposedPaymentDate)
//                 {
//                     MinOccurs = Zero;
//                 }
//                 textelement(PaymentTerms)
//                 {
//                     MinOccurs = Zero;
//                 }
//                 textelement(PaymentType)
//                 {
//                     MinOccurs = Zero;
//                 }
//                 textelement(GLAccNo)
//                 {
//                     MinOccurs = Zero;
//                 }
//                 textelement(Desc)
//                 {
//                     MinOccurs = Zero;
//                 }
//                 textelement(Qty)
//                 {
//                     MinOccurs = Zero;
//                 }
//                 textelement(UnitCost)
//                 {
//                     MinOccurs = Zero;
//                 }
//                 textelement(VATProd)
//                 {
//                     MinOccurs = Zero;
//                 }
//                 textelement(VATDifReason)
//                 {
//                     MinOccurs = Zero;
//                 }

//                 trigger OnBeforeInsertRecord()
//                 var
//                     PurchaseHeader: record "Purchase Header";
//                 begin
//                     PurchaseHeader := GetPurchDocument();
//                     InsertPurchaseLines(PurchaseHeader);
//                 end;

//             }

//         }

//     }

//     local procedure InsertPurchaseLines(PurchaseHeader: record "Purchase Header")
//     var
//         PurchaseLine: record "Purchase Line";
//         LineNo: Integer;
//     begin
//         LineNo := 10000;
//         PurchaseLine.SetFilter("Document Type", '%1', PurchaseHeader."Document Type");
//         PurchaseLine.SetFilter("Document No.", '%1', PurchaseHeader."No.");
//         if PurchaseLine.FindLast() then LineNo += PurchaseLine."Line No.";
//         PurchaseLine.Init();
//         PurchaseLine.Validate("Document Type", PurchaseHeader."Document Type");
//         PurchaseLine.Validate("Document No.", PurchaseHeader."No.");
//         PurchaseLine.validate("Line No.", LineNo);
//         PurchaseLine.Validate(Type, PurchaseLine.Type::"G/L Account");
//         PurchaseLine.Validate("No.", GLAccNo);
//         PurchaseLine.Validate("Event No.", 'EVE0000000');
//         PurchaseLine.Validate(Description, Desc);
//         Evaluate(varQty, Qty);
//         Evaluate(varUnitCost, UnitCost);
//         PurchaseLine.Validate(Quantity, varQty);
//         PurchaseLine.Validate("Direct Unit Cost", varUnitCost);
//         PurchaseLine.validate(MasterType, PurchaseLine.MasterType::NonEvent);
//         PurchaseLine.validate(MasterCode, 'HEADOFFICE');
//         PurchaseLine.validate("VAT Prod. Posting Group", VATProd);
//         PurchaseLine.validate("VAT Difference Reason", VATDifReason);
//         PurchaseLine.ValidateShortcutDimCode(3, PurchaseLine."Event No.");
//         PurchaseLine.Insert(True);
//     end;

//     local procedure GetPurchDocument(): Record "Purchase Header"
//     var
//         PurchaseHeader: record "Purchase Header";
//     begin
//         Evaluate(varDocType, DocType);


//         PurchaseHeader.SetCurrentKey("Your Reference");
//         PurchaseHeader.SetFilter("Your Reference", '%1', YourRef);
//         PurchaseHeader.SetFilter("Document Type", '%1', varDocType);
//         if PurchaseHeader.FindFirst() then
//             exit(PurchaseHeader)
//         else begin
//             PurchaseHeader.init();
//             PurchaseHeader.validate("Document Type", varDocType);
//             PurchaseHeader.Insert(True);
//             PurchaseHeader.validate("Buy-from Vendor No.", VendorNo);
//             PurchaseHeader.validate("Document Date", EvaluateDate(DocDate));
//             PurchaseHeader.validate("Posting Date", EvaluateDate(PostingDate));
//             PurchaseHeader.validate("Vendor Invoice No.", VendorInvoiceNo);
//             PurchaseHeader.validate("Event No.", 'EVE0000000');
//             PurchaseHeader.validate("Payment Terms Code", PaymentTerms);
//             PurchaseHeader.validate("Proposed Payment Date1", EvaluateDate(ProposedPaymentDate));
//             if Evaluate(PaymentTypeOptions, PaymentType)
//             then
//                 PurchaseHeader.validate("Payment Type", PaymentTypeOptions);
//             PurchaseHeader.Confirmed := True;
//             PurchaseHeader."Confirmed By" := UserId;
//             PurchaseHeader."Confirmed On" := Today;
//             PurchaseHeader."Confirmed At" := Time;
//             PurchaseHeader.validate("Your Reference", YourRef);
//             PurchaseHeader.validate("Currency Code", 'GBP');
//             // PurchaseHeader.validate();
//             PurchaseHeader.Modify(True);
//             exit(PurchaseHeader)
//         end;
//     end;


//     procedure EvaluateDate(DateText: Text): Date
//     var
//         ResultDate: Date;
//     begin
//         if Evaluate(ResultDate, DateText) then
//             exit(ResultDate)
//         else
//             Error('Cannot Evaluate Date');
//     end;

//     var
//         PaymentTypeOptions: Option " ","ACH","SEPA","Priority","Headoffice","DIRECT DEBIT";
//         varQty: Integer;
//         varUnitCost: Decimal;
//         varDocType: enum "Purchase Document Type";
// }