
page 70245 "Sales Order List TKA "
{
    ApplicationArea = Basic, Suite, Assembly;
    Caption = 'Sales Orders - TKA';
    CardPageID = "Booking Order Form";
    DataCaptionFields = "Sell-to Customer No.";
    Editable = false;
    PageType = List;
    QueryCategory = 'Sales Order List ';
    RefreshOnActivate = true;
    SourceTable = "Sales Header";
    SourceTableView = sorting("No.") order(descending)
    where("Document Type" = const(Order));

    UsageCategory = Lists;
    AdditionalSearchTerms = 'Sales Commitments, Sales Order Overview, Sale Orders, Order Log, Sale List, Client Orders';

    AboutTitle = 'About sales orders';
    AboutText = 'Use a sales order when you partially ship or invoice an order, and when you use drop shipments or prepayments. For sales that are fully shipped and invoiced in one go, sales invoices are typically used instead.';

    layout
    {
        area(content)
        {
            repeater(control)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a unique number that identifies the sales order. The number can be generated automatically from a number series, or you can number each of them manually.';
                }
                field(TeamLeader; Rec.TeamLeader)
                {
                    ApplicationArea = All;
                }
                field("PF Park"; Rec."PF Park")
                {
                    ApplicationArea = All;
                }
                field("Authorisation Status"; Rec."Authorisation Status")
                {
                    ApplicationArea = All;
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date when the related document was created.';
                }
                field("Customer Order No."; Rec."Customer Order No.")
                {
                    ApplicationArea = All;
                }
                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {
                    ApplicationArea = All;
                }
                field(CopyAmount; 0 + rec.Amount)
                {
                    ApplicationArea = All;
                }

                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the sum of amounts on all the lines in the document. This will include invoice discounts.';
                }
                field("Payment Processed Manually"; Rec."Payment Processed Manually")
                {
                    ApplicationArea = All;
                }
                field("Outstanding Amount (LCY)"; Rec."Outstanding Amount (LCY)")
                {
                    ApplicationArea = All;
                }
                field(OrderCommentsExist; OrderCommentsExist)
                {
                    ApplicationArea = All;
                }
                field("Confirmed By"; Rec."Confirmed By")
                {
                    ApplicationArea = All;
                }
                field("Knowledge Pass"; Rec."Knowledge Pass")
                {
                    ApplicationArea = All;
                }
                field("Flexi Pass"; Rec."Flexi Pass")
                {
                    ApplicationArea = All;
                }
                field("KP Original Amount"; Rec."KP Original Amount")
                {
                    ApplicationArea = All;
                }
                field("KP running Amount"; Rec."KP running Amount")
                {
                    ApplicationArea = All;
                }
                field("Expiration Date"; Rec."Expiration Date")
                {
                    ApplicationArea = All;
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    ApplicationArea = All;
                }
                field("First Confirmed By"; Rec."First Confirmed By")
                {
                    ApplicationArea = All;
                }
                field("Confirmed On"; Rec."Confirmed On")
                {
                    ApplicationArea = All;
                }

                field("First Confirmed On"; Rec."First Confirmed On")
                {
                    ApplicationArea = All;
                }
                field("Confirmed At"; Rec."Confirmed At")
                {
                    ApplicationArea = All;
                }
                field("Nav Portal Reference"; Rec."Nav Portal Reference")
                {
                    ApplicationArea = All;
                }
                field("Payment Terms Code"; Rec."Payment Terms Code")
                {
                    ApplicationArea = All;
                }
                field("Franchise Order"; Rec."Franchise Order")
                {
                    ApplicationArea = All;
                }
                field("Quote No."; Rec."Quote No.")
                {
                    ApplicationArea = All;
                }
                field("Sell-to Contact No."; Rec."Sell-to Contact No.")
                {
                    ApplicationArea = All;
                }
                field("Sell-to Customer No."; Rec."Sell-to Customer No.")
                {
                    ApplicationArea = All;
                }
                field("Order Date"; Rec."Order Date")
                {
                    ApplicationArea = All;
                }

                field("Due Date"; Rec."Due Date")
                {
                    ApplicationArea = All;
                }

                field("Sell-to Customer Name"; Rec."Sell-to Customer Name")
                {
                    ApplicationArea = All;
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = All;
                }
                field("Shipment Date"; Rec."Shipment Date")
                {
                    ApplicationArea = All;
                }

                field("E-Learning"; Rec."E-Learning")
                {
                    ApplicationArea = All;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                }
                field("Payment Information"; Rec."Payment Information")
                {
                    ApplicationArea = All;
                }
                field("KP Balance"; Rec."KP Balance")
                {
                    ApplicationArea = All;
                }
                field("PAS Ref No."; Rec."PAS Ref No.")
                {
                    ApplicationArea = All;
                }
            }

        }
        area(factboxes)
        {
            part("Attached Documents"; "Document Attachment Factbox")
            {
                ApplicationArea = All;
                Caption = 'Attachments';
                SubPageLink = "Table ID" = const(Database::"Sales Header"),
                              "No." = field("No."),
                              "Document Type" = field("Document Type");
            }
            part(PowerBIEmbeddedReportPart; "Power BI Embedded Report Part")
            {
                ApplicationArea = Basic, Suite;
                Visible = false;
            }
            part(Control1902018507; "Customer Statistics FactBox")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "No." = field("Bill-to Customer No."),
                              "Date Filter" = field("Date Filter");
            }
            part(Control1900316107; "Customer Details FactBox")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "No." = field("Bill-to Customer No."),
                              "Date Filter" = field("Date Filter");
            }
            part(IncomingDocAttachFactBox; "Incoming Doc. Attach. FactBox")
            {
                ApplicationArea = Basic, Suite;
                ShowFilter = false;
                Visible = false;
            }
#if not CLEAN21
            // part("Power BI Report FactBox"; "Power BI Report FactBox")
            // {
            //     ApplicationArea = Basic, Suite;
            //     Visible = false;
            //     ObsoleteReason = 'Use the part PowerBIEmbeddedReportPart instead';
            //     ObsoleteState = Pending;
            //     ObsoleteTag = '21.0';
            // }
#endif
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("O&rder")
            {
                Caption = 'O&rder';
                Image = "Order";
                action(Dimensions)
                {
                    AccessByPermission = TableData Dimension = R;
                    ApplicationArea = Dimensions;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    ShortCutKey = 'Alt+D';
                    ToolTip = 'View or edit dimensions, such as area, project, or department, that you can assign to sales and purchase documents to distribute costs and analyze transaction history.';

                    trigger OnAction()
                    begin
                        Rec.ShowDocDim();
                    end;
                }
                action(Statistics)
                {
                    ApplicationArea = Suite;
                    Caption = 'Statistics';
                    Image = Statistics;
                    ShortCutKey = 'F7';
                    ToolTip = 'View statistical information, such as the value of posted entries, for the record.';

                    trigger OnAction()
                    begin
                        Rec.OpenSalesOrderStatistics();
                    end;
                }
                action(Approvals)
                {
                    ApplicationArea = Suite;
                    Caption = 'Approvals';
                    Image = Approvals;
                    ToolTip = 'View a list of the records that are waiting to be approved. For example, you can see who requested the record to be approved, when it was sent, and when it is due to be approved.';

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        ApprovalsMgmt.OpenApprovalsSales(Rec);
                    end;
                }
                action("Co&mments")
                {
                    ApplicationArea = Comments;
                    Caption = 'Co&mments';
                    Image = ViewComments;
                    RunObject = Page "Sales Comment Sheet";
                    RunPageLink = "Document Type" = field("Document Type"),
                                  "No." = field("No."),
                                  "Document Line No." = const(0);
                    ToolTip = 'View or add comments for the record.';
                }
            }
            group(Documents)
            {
                Caption = 'Documents';
                Image = Documents;
                action("S&hipments")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'S&hipments';
                    Image = Shipment;
                    RunObject = Page "Posted Sales Shipments";
                    RunPageLink = "Order No." = field("No.");
                    RunPageView = sorting("Order No.");
                    ToolTip = 'View related posted sales shipments.';
                }
                action(PostedSalesInvoices)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Invoices';
                    Image = Invoice;
                    ToolTip = 'View a list of ongoing sales invoices for the order.';

                    AboutTitle = 'What has been invoiced?';
                    AboutText = 'Here you can look up what has already been invoiced on an order.';

                    trigger OnAction()
                    var
                        TempSalesInvoiceHeader: Record "Sales Invoice Header" temporary;
                        SalesGetShipment: Codeunit "Sales-Get Shipment";
                    begin
                        SalesGetShipment.GetSalesOrderInvoices(TempSalesInvoiceHeader, Rec."No.");
                        Page.Run(Page::"Posted Sales Invoices", TempSalesInvoiceHeader);
                    end;
                }
                action(PostedSalesPrepmtInvoices)
                {
                    ApplicationArea = Prepayments;
                    Caption = 'Prepa&yment Invoices';
                    Image = PrepaymentInvoice;
                    RunObject = Page "Posted Sales Invoices";
                    RunPageLink = "Prepayment Order No." = field("No.");
                    RunPageView = sorting("Prepayment Order No.");
                    ToolTip = 'View related posted sales invoices that involve a prepayment. ';
                }
                action("Prepayment Credi&t Memos")
                {
                    ApplicationArea = Prepayments;
                    Caption = 'Prepayment Credi&t Memos';
                    Image = PrepaymentCreditMemo;
                    RunObject = Page "Posted Sales Credit Memos";
                    RunPageLink = "Prepayment Order No." = field("No.");
                    RunPageView = sorting("Prepayment Order No.");
                    ToolTip = 'View related posted sales credit memos that involve a prepayment. ';
                }
            }
            group(Warehouse)
            {
                Caption = 'Warehouse';
                Image = Warehouse;
                action("Warehouse Shipment Lines")
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Warehouse Shipment Lines';
                    Image = ShipmentLines;
                    RunObject = Page "Whse. Shipment Lines";
                    RunPageLink = "Source Type" = const(37),
#pragma warning disable AL0603
                                  "Source Subtype" = field("Document Type"),
#pragma warning restore
                                  "Source No." = field("No.");
                    RunPageView = sorting("Source Type", "Source Subtype", "Source No.", "Source Line No.");
                    ToolTip = 'View ongoing warehouse shipments for the document, in advanced warehouse configurations.';
                }
                action("In&vt. Put-away/Pick Lines")
                {
                    ApplicationArea = Warehouse;
                    Caption = 'In&vt. Put-away/Pick Lines';
                    Image = PickLines;
                    RunObject = Page "Warehouse Activity List";
                    RunPageLink = "Source Document" = const("Sales Order"),
                                  "Source No." = field("No.");
                    RunPageView = sorting("Source Document", "Source No.", "Location Code");
                    ToolTip = 'View items that are inbound or outbound on inventory put-away or inventory pick documents for the sales order.';
                }
                action("Whse. Pick Lines")
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Warehouse Pick Lines';
                    Image = PickLines;
                    RunObject = page "Warehouse Activity Lines";
                    RunPageLink = "Source Document" = const("Sales Order"), "Source No." = field("No.");
                    RunPageView = sorting("Source Type", "Source Subtype", "Source No.");
                    ToolTip = 'View items that are outbound on warehouse pick documents for the sales order.';
                }
            }
            group(ActionGroupCRM)
            {
                Caption = 'Dynamics 365 Sales';
                Visible = CRMIntegrationEnabled;
                action(CRMGoToSalesOrderListInNAV)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales Order List';
                    Enabled = CRMIntegrationEnabled;
                    Image = "Order";
                    ToolTip = 'Open the Sales Order List - Dynamics 365 Sales page in Business Central';
                    Visible = CRMIntegrationEnabled and (not BidirectionalSalesOrderIntEnabled);

                    trigger OnAction()
                    var
                        CRMSalesorder: Record "CRM Salesorder";
                    begin
                        PAGE.Run(PAGE::"CRM Sales Order List", CRMSalesorder);
                    end;
                }
                action(CRMGoToSalesOrder)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales Order';
                    Enabled = CRMIntegrationEnabled AND CRMIsCoupledToRecord;
                    Image = CoupledOrder;
                    ToolTip = 'View the selected sales order.';
                    Visible = BidirectionalSalesOrderIntEnabled;

                    trigger OnAction()
                    var
                        CRMIntegrationManagement: Codeunit "CRM Integration Management";
                    begin
                        CRMIntegrationManagement.ShowCRMEntityFromRecordID(Rec.RecordId);
                    end;
                }
                action(CRMSynchronizeNow)
                {
                    AccessByPermission = TableData "CRM Integration Record" = IM;
                    ApplicationArea = Suite;
                    Caption = 'Synchronize';
                    Image = Refresh;
                    ToolTip = 'Send updated data to Dynamics 365 Sales.';
                    Visible = BidirectionalSalesOrderIntEnabled;

                    trigger OnAction()
                    var
                        SalesHeader: Record "Sales Header";
                        CRMIntegrationManagement: Codeunit "CRM Integration Management";
                        SalesHeaderRecordRef: RecordRef;
                    begin
                        CurrPage.SetSelectionFilter(SalesHeader);
                        SalesHeader.SetRange(Status, SalesHeader.Status::Released);
                        SalesHeader.Next();

                        if SalesHeader.Count = 1 then
                            CRMIntegrationManagement.UpdateOneNow(SalesHeader.RecordId)
                        else begin
                            SalesHeaderRecordRef.GetTable(SalesHeader);
                            CRMIntegrationManagement.UpdateMultipleNow(SalesHeaderRecordRef);
                        end
                    end;
                }
                group(Coupling)
                {
                    Caption = 'Coupling', Comment = 'Coupling is a noun';
                    Image = LinkAccount;
                    ToolTip = 'Create, change, or delete a coupling between the Business Central record and a Dynamics 365 Sales record.';
                    Enabled = Rec.Status = Rec.Status::Released;
                    Visible = BidirectionalSalesOrderIntEnabled;
                    action(ManageCRMCoupling)
                    {
                        AccessByPermission = TableData "CRM Integration Record" = IM;
                        ApplicationArea = Suite;
                        Caption = 'Set Up Coupling';
                        Image = LinkAccount;
                        ToolTip = 'Create or modify the coupling to a Dynamics 365 Sales order.';

                        trigger OnAction()
                        var
                            CRMIntegrationManagement: Codeunit "CRM Integration Management";
                        begin
                            CRMIntegrationManagement.DefineCoupling(Rec.RecordId);
                        end;
                    }
                    action(DeleteCRMCoupling)
                    {
                        AccessByPermission = TableData "CRM Integration Record" = D;
                        ApplicationArea = Suite;
                        Caption = 'Delete Coupling';
                        Enabled = CRMIsCoupledToRecord;
                        Image = UnLinkAccount;
                        ToolTip = 'Delete the coupling to a Dynamics 365 Sales order.';

                        trigger OnAction()
                        var
                            SalesHeader: Record "Sales Header";
                            CRMCouplingManagement: Codeunit "CRM Coupling Management";
                            RecRef: RecordRef;
                        begin
                            CurrPage.SetSelectionFilter(SalesHeader);
                            RecRef.GetTable(SalesHeader);
                            CRMCouplingManagement.RemoveCoupling(RecRef);
                        end;
                    }
                }
                action(ShowLog)
                {
                    ApplicationArea = Suite;
                    Caption = 'Synchronization Log';
                    Image = Log;
                    ToolTip = 'View integration synchronization jobs for the sales order table.';
                    Visible = BidirectionalSalesOrderIntEnabled;
                    Enabled = Rec.Status = Rec.Status::Released;

                    trigger OnAction()
                    var
                        CRMIntegrationManagement: Codeunit "CRM Integration Management";
                    begin
                        CRMIntegrationManagement.ShowLog(Rec.RecordId);
                    end;
                }
            }
        }
        area(processing)
        {
            group(Action12)
            {
                Caption = 'Release';
                Image = ReleaseDoc;
                action(Release)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Re&lease';
                    Image = ReleaseDoc;
                    ShortCutKey = 'Ctrl+F9';
                    ToolTip = 'Release the document to the next stage of processing. You must reopen the document before you can make changes to it.';

                    trigger OnAction()
                    var
                        SalesHeader: Record "Sales Header";
                    begin
                        CurrPage.SetSelectionFilter(SalesHeader);
                        Rec.PerformManualRelease(SalesHeader);
                    end;
                }
                action(Reopen)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Re&open';
                    Image = ReOpen;
                    ToolTip = 'Reopen the document to change it after it has been approved. Approved documents have the Released status and must be opened before they can be changed.';

                    trigger OnAction()
                    var
                        SalesHeader: Record "Sales Header";
                    begin
                        CurrPage.SetSelectionFilter(SalesHeader);
                        Rec.PerformManualReopen(SalesHeader);
                    end;
                }
            }
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action("Pla&nning")
                {
                    ApplicationArea = Planning;
                    Caption = 'Pla&nning';
                    Image = Planning;
                    ToolTip = 'Open a tool for manual supply planning that displays all new demand along with availability information and suggestions for supply. It provides the visibility and tools needed to plan for demand from sales lines and component lines and then create different types of supply orders directly.';

                    trigger OnAction()
                    var
                        SalesOrderPlanningForm: Page "Sales Order Planning";
                    begin
                        SalesOrderPlanningForm.SetSalesOrder(Rec."No.");
                        SalesOrderPlanningForm.RunModal();
                    end;
                }
                action("Order &Promising")
                {
                    AccessByPermission = TableData "Order Promising Line" = R;
                    ApplicationArea = OrderPromising;
                    Caption = 'Order &Promising';
                    Image = OrderPromising;
                    ToolTip = 'Calculate the shipment and delivery dates based on the item''s known and expected availability dates, and then promise the dates to the customer.';

                    trigger OnAction()
                    var
                        TempOrderPromisingLine: Record "Order Promising Line" temporary;
                    begin
                        TempOrderPromisingLine.SetRange("Source Type", Rec."Document Type");
                        TempOrderPromisingLine.SetRange("Source ID", Rec."No.");
                        PAGE.RunModal(PAGE::"Order Promising Lines", TempOrderPromisingLine);
                    end;
                }
                action("Send IC Sales Order Cnfmn.")
                {
                    AccessByPermission = TableData "IC G/L Account" = R;
                    ApplicationArea = Intercompany;
                    Caption = 'Send IC Sales Order Cnfmn.';
                    Image = IntercompanyOrder;
                    ToolTip = 'Send the document to the intercompany outbox or directly to the intercompany partner if automatic transaction sending is enabled.';

                    trigger OnAction()
                    var
                        ICInOutboxMgt: Codeunit ICInboxOutboxMgt;
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        if ApprovalsMgmt.PrePostApprovalCheckSales(Rec) then
                            ICInOutboxMgt.SendSalesDoc(Rec, false);
                    end;
                }
                action("Delete Invoiced")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Delete Invoiced Sales Orders';
                    Image = Delete;
                    RunObject = Report "Delete Invoiced Sales Orders";
                    ToolTip = 'Delete orders that were not automatically deleted after completion. For example, when several sales orders were completed by a single invoice.';
                }
            }
            group("Request Approval")
            {
                Caption = 'Request Approval';
                action(SendApprovalRequest)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Send A&pproval Request';
                    Enabled = NOT OpenApprovalEntriesExist AND CanRequestApprovalForFlow;
                    Image = SendApprovalRequest;
                    ToolTip = 'Request approval of the document.';

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        if ApprovalsMgmt.CheckSalesApprovalPossible(Rec) then
                            ApprovalsMgmt.OnSendSalesDocForApproval(Rec);
                    end;
                }
                action(CancelApprovalRequest)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Cancel Approval Re&quest';
                    Enabled = CanCancelApprovalForRecord OR CanCancelApprovalForFlow;
                    Image = CancelApprovalRequest;
                    ToolTip = 'Cancel the approval request.';

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                        WorkflowWebhookManagement: Codeunit "Workflow Webhook Management";
                    begin
                        ApprovalsMgmt.OnCancelSalesApprovalRequest(Rec);
                        WorkflowWebhookManagement.FindAndCancel(Rec.RecordId);
                    end;
                }
            }
            group(Action3)
            {
                Caption = 'Warehouse';
                Image = Warehouse;
                action("Create Inventor&y Put-away/Pick")
                {
                    AccessByPermission = TableData "Posted Invt. Pick Header" = R;
                    ApplicationArea = Warehouse;
                    Caption = 'Create Inventor&y Put-away/Pick';
                    Ellipsis = true;
                    Image = CreatePutawayPick;
                    ToolTip = 'Create an inventory put-away or inventory pick to handle items on the document according to a basic warehouse configuration that does not require warehouse receipt or shipment documents.';

                    trigger OnAction()
                    begin
                        Rec.PerformManualRelease();
                        Rec.CreateInvtPutAwayPick();

                        if not Rec.Find('=><') then
                            Rec.Init();
                    end;
                }
                action("Create &Warehouse Shipment")
                {
                    AccessByPermission = TableData "Warehouse Shipment Header" = R;
                    ApplicationArea = Warehouse;
                    Caption = 'Create &Warehouse Shipment';
                    Image = NewShipment;
                    ToolTip = 'Create a warehouse shipment to start a pick a ship process according to an advanced warehouse configuration.';

                    trigger OnAction()
                    var
                        GetSourceDocOutbound: Codeunit "Get Source Doc. Outbound";
                    begin
                        Rec.PerformManualRelease();
                        GetSourceDocOutbound.CreateFromSalesOrder(Rec);

                        if not Rec.Find('=><') then
                            Rec.Init();
                    end;
                }
            }
            group("P&osting")
            {
                Caption = 'P&osting';
                Image = Post;
                action(Post)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'P&ost';
                    Ellipsis = true;
                    Image = PostOrder;
                    ShortCutKey = 'F9';
                    ToolTip = 'Finalize the document or journal by posting the amounts and quantities to the related accounts in your company books.';

                    trigger OnAction()
                    var
                        SalesHeader: Record "Sales Header";
                        SalesBatchPostMgt: Codeunit "Sales Batch Post Mgt.";
                        BatchProcessingMgt: Codeunit "Batch Processing Mgt.";
                        IsHandled: Boolean;
                    begin
                        CurrPage.SetSelectionFilter(SalesHeader);
                        OnAfterPostingSetSelectionFilter(SalesHeader, Rec);
                        if SalesHeader.Count > 1 then begin
                            IsHandled := false;
                            //OnBeforePostActionWithMoreThanOneDoc(SalesHeader, BatchProcessingMgt, IsHandled);
                            if IsHandled then
                                exit;

                            BatchProcessingMgt.SetParametersForPageID(Page::"Sales Order List");

                            SalesBatchPostMgt.SetBatchProcessor(BatchProcessingMgt);
                            SalesBatchPostMgt.RunWithUI(SalesHeader, Rec.Count, ReadyToPostQst);
                        end else
                            PostDocument(CODEUNIT::"Sales-Post (Yes/No)");
                    end;
                }
                action(PostAndSend)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Post and Send';
                    Ellipsis = true;
                    Image = PostMail;
                    ToolTip = 'Finalize and prepare to send the document according to the customer''s sending profile, such as attached to an email. The Send document to window opens where you can confirm or select a sending profile.';

                    trigger OnAction()
                    begin
                        PostDocument(CODEUNIT::"Sales-Post and Send");
                    end;
                }
                action("Test Report")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Test Report';
                    Ellipsis = true;
                    Image = TestReport;
                    ToolTip = 'View a test report so that you can find and correct any errors before you perform the actual posting of the journal or document.';

                    trigger OnAction()
                    begin
                        ReportPrint.PrintSalesHeader(Rec);
                    end;
                }
                action("Post &Batch")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Post &Batch';
                    Ellipsis = true;
                    Image = PostBatch;
                    ToolTip = 'Post several documents at once. A report request window opens where you can specify which documents to post.';

                    trigger OnAction()
                    var
                        SalesHeader: Record "Sales Header";
                        SelectionFilterManagement: Codeunit SelectionFilterManagement;
                    begin
                        CurrPage.SetSelectionFilter(SalesHeader);
                        SalesHeader.SetFilter("No.", SelectionFilterManagement.GetSelectionFilterForSalesHeader(SalesHeader));
                        REPORT.RunModal(REPORT::"Batch Post Sales Orders", true, true, SalesHeader);
                        CurrPage.Update(false);
                    end;
                }
                action("Remove From Job Queue")
                {
                    ApplicationArea = All;
                    Caption = 'Remove From Job Queue';
                    Image = RemoveLine;
                    ToolTip = 'Remove the scheduled processing of this record from the job queue.';
                    Visible = JobQueueActive;

                    trigger OnAction()
                    begin
                        Rec.CancelBackgroundPosting();
                    end;
                }
                action("Preview Posting")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Preview Posting';
                    Image = ViewPostedOrder;
                    ShortCutKey = 'Ctrl+Alt+F9';
                    ToolTip = 'Review the different types of entries that will be created when you post the document or journal.';

                    trigger OnAction()
                    begin
                        ShowPreview();
                    end;
                }
            }
            group("&Print")
            {
                Caption = '&Print';
                Image = Print;
                action("Work Order")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Work Order';
                    Ellipsis = true;
                    Image = Print;
                    ToolTip = 'Prepare to registers actual item quantities or time used in connection with the sales order. For example, the document can be used by staff who perform any kind of processing work in connection with the sales order. It can also be exported to Excel if you need to process the sales line data further.';

                    trigger OnAction()
                    begin
                        PrintForUsage(Usage::"Work Order");
                    end;
                }
                action("Pick Instruction")
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Pick Instruction';
                    Image = Print;
                    ToolTip = 'Print a picking list that shows which items to pick and ship for the sales order. If an item is assembled to order, then the report includes rows for the assembly components that must be picked. Use this report as a pick instruction to employees in charge of picking sales items or assembly components for the sales order.';

                    trigger OnAction()
                    begin
                        PrintForUsage(Usage::"Pick Instruction");
                    end;
                }
            }
            group("&Order Confirmation")
            {
                Caption = '&Order Confirmation';
                Image = Email;
                action("Email Confirmation")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Email Confirmation';
                    Ellipsis = true;
                    Image = Email;
                    ToolTip = 'Send an order confirmation by email. The Send Email window opens prefilled for the customer so you can add or change information before you send the email.';

                    trigger OnAction()
                    begin
                        DocPrint.EmailSalesHeader(Rec);
                    end;
                }
                action("Print Confirmation")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Print Confirmation';
                    Ellipsis = true;
                    Image = Print;
                    ToolTip = 'Print an order confirmation. A report request window opens where you can specify what to include on the print-out.';
                    Visible = NOT IsOfficeAddin;

                    trigger OnAction()
                    begin
                        DocPrint.PrintSalesOrder(Rec, Usage::"Order Confirmation");
                    end;
                }
                action(AttachAsPDF)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Attach as PDF';
                    Image = PrintAttachment;
                    Ellipsis = true;
                    ToolTip = 'Create a PDF file and attach it to the document.';

                    trigger OnAction()
                    var
                        SalesHeader: Record "Sales Header";
                    begin
                        SalesHeader := Rec;
                        CurrPage.SetSelectionFilter(SalesHeader);
                        DocPrint.PrintSalesOrderToDocumentAttachment(SalesHeader, DocPrint.GetSalesOrderPrintToAttachmentOption(Rec));
                    end;
                }
            }
#if not CLEAN21
            // group(Display)
            // {
            //     Caption = 'Display';
            //     Visible = false;
            //     ObsoleteState = Pending;
            //     ObsoleteReason = 'Use the Personalization mode to hide and show this factbox.';
            //     ObsoleteTag = '21.0';
            //     action(ReportFactBoxVisibility)
            //     {
            //         ApplicationArea = Basic, Suite;
            //         Caption = 'Show/Hide Power BI Reports';
            //         Image = "Report";
            //         ToolTip = 'Select if the Power BI FactBox is visible or not.';
            //         Visible = false;
            //         ObsoleteState = Pending;
            //         ObsoleteReason = 'Use the Personalization mode to hide and show this factbox.';
            //         ObsoleteTag = '21.0';

            //         trigger OnAction()
            //         begin
            //             // save visibility value into the table
            //             CurrPage."Power BI Report FactBox".PAGE.SetFactBoxVisibility(PowerBIVisible);
            //         end;
            //     }
            // }
#endif
        }
        area(reporting)
        {
            action("Sales Reservation Avail.")
            {
                ApplicationArea = Reservation;
                Caption = 'Sales Reservation Avail.';
                Image = "Report";
                RunObject = Report "Sales Reservation Avail.";
                ToolTip = 'View, print, or save an overview of availability of items for shipment on sales documents, filtered on shipment status.';
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process', Comment = 'Generated from the PromotedActionCategories property index 1.';

                actionref("Create &Warehouse Shipment_Promoted"; "Create &Warehouse Shipment")
                {
                }
                actionref("Create Inventor&y Put-away/Pick_Promoted"; "Create Inventor&y Put-away/Pick")
                {
                }
            }
            group(Category_Category6)
            {
                Caption = 'Release', Comment = 'Generated from the PromotedActionCategories property index 5.';
                ShowAs = SplitButton;

                actionref(Release_Promoted; Release)
                {
                }
                actionref(Reopen_Promoted; Reopen)
                {
                }
            }
            group(Category_Category7)
            {
                Caption = 'Posting', Comment = 'Generated from the PromotedActionCategories property index 6.';
                ShowAs = SplitButton;

                actionref(Post_Promoted; Post)
                {
                }
                actionref(PostAndSend_Promoted; PostAndSend)
                {
                }
                actionref("Post &Batch_Promoted"; "Post &Batch")
                {
                }
                actionref("Preview Posting_Promoted"; "Preview Posting")
                {
                }
            }
            group(Category_Category8)
            {
                Caption = 'Print/Send', Comment = 'Generated from the PromotedActionCategories property index 7.';

                actionref("Print Confirmation_Promoted"; "Print Confirmation")
                {
                }
                actionref("Pick Instruction_Promoted"; "Pick Instruction")
                {
                }
                actionref("Email Confirmation_Promoted"; "Email Confirmation")
                {
                }
                actionref("Work Order_Promoted"; "Work Order")
                {
                }
                actionref(AttachAsPDF_Promoted; AttachAsPDF)
                {
                }
            }
            group(Category_Category4)
            {
                Caption = 'Request Approval', Comment = 'Generated from the PromotedActionCategories property index 3.';
            }
            group(Category_Category5)
            {
                Caption = 'Order', Comment = 'Generated from the PromotedActionCategories property index 4.';

                actionref(Dimensions_Promoted; Dimensions)
                {
                }
                actionref(Statistics_Promoted; Statistics)
                {
                }
                actionref("Co&mments_Promoted"; "Co&mments")
                {
                }
                actionref(Approvals_Promoted; Approvals)
                {
                }
                separator(Navigate_Separator)
                {
                }
                actionref("S&hipments_Promoted"; "S&hipments")
                {
                }
                actionref(PostedSalesInvoices_Promoted; PostedSalesInvoices)
                {
                }
            }
            group(Category_Category9)
            {
                Caption = 'Navigate', Comment = 'Generated from the PromotedActionCategories property index 8.';
            }
            group(Category_Report)
            {
                Caption = 'Report', Comment = 'Generated from the PromotedActionCategories property index 2.';

#if not CLEAN21
                actionref("Sales Reservation Avail._Promoted"; "Sales Reservation Avail.")
                {
                    Visible = false;
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Action is being demoted based on overall low usage.';
                    ObsoleteTag = '21.0';
                }
#endif
            }
            group(Category_Synchronize)
            {
                Caption = 'Synchronize';
                Visible = CRMIntegrationEnabled;

                actionref(CRMGoToSalesOrderListInNAV_Promoted; CRMGoToSalesOrderListInNAV)
                {
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        FilteredSalesHeader: Record "Sales Header";
        CRMCouplingManagement: Codeunit "CRM Coupling Management";
    begin
        SetControlVisibility();
        CurrPage.IncomingDocAttachFactBox.PAGE.LoadDataFromRecord(Rec);

        if CRMIntegrationEnabled then
            CRMIsCoupledToRecord := CRMCouplingManagement.IsRecordCoupledToCRM(Rec.RecordId);

#if not CLEAN21
        // Contextual Power BI FactBox: send data to filter the report in the FactBox
        // CurrPage."Power BI Report FactBox".PAGE.SetCurrentListSelection(Rec."No.", false, PowerBIVisible);
#endif
        CurrPage.SetSelectionFilter(FilteredSalesHeader);
        CurrPage.PowerBIEmbeddedReportPart.PAGE.SetFilterToMultipleValues(FilteredSalesHeader, FilteredSalesHeader.FieldNo("No."));
    end;

    trigger OnAfterGetRecord()
    begin
        StatusStyleTxt := Rec.GetStatusStyleText();
        FindOrderComments;
    end;

    trigger OnInit()
    begin
#if not CLEAN21
        // PowerBIVisible := false;
        // CurrPage."Power BI Report FactBox".PAGE.InitFactBox(CurrPage.ObjectId(false), CurrPage.Caption, PowerBIVisible);
#endif
        CurrPage.PowerBIEmbeddedReportPart.PAGE.InitPageRatio(PowerBIServiceMgt.GetFactboxRatio());
        CurrPage.PowerBIEmbeddedReportPart.PAGE.SetPageContext(CurrPage.ObjectId(false));
    end;

    trigger OnOpenPage()
    var
        SalesSetup: Record "Sales & Receivables Setup";
        CRMConnectionSetup: Record "CRM Connection Setup";
        CRMIntegrationManagement: Codeunit "CRM Integration Management";
        OfficeMgt: Codeunit "Office Management";
    begin
        Rec.SetSecurityFilterOnRespCenter();

        Rec.SetRange("Date Filter", CalcDate('-2Y', WorkDate()), WorkDate());

        JobQueueActive := SalesSetup.JobQueueActive();
        CRMIntegrationEnabled := CRMIntegrationManagement.IsCRMIntegrationEnabled();
        BidirectionalSalesOrderIntEnabled := CRMConnectionSetup.IsBidirectionalSalesOrderIntEnabled();
        IsOfficeAddin := OfficeMgt.IsAvailable();

        Rec.CopySellToCustomerFilter();
        if OnlyShowHeadersWithVat then
            SetFilterOnPositiveVatPostingGroups();
    end;

    var
        DocPrint: Codeunit "Document-Print";
        ReportPrint: Codeunit "Test Report-Print";
        PowerBIServiceMgt: Codeunit "Power BI Service Mgt.";
        Usage: Option "Order Confirmation","Work Order","Pick Instruction";
        JobQueueActive: Boolean;
        OnlyShowHeadersWithVat: Boolean;
        OpenApprovalEntriesExist: Boolean;
        CRMIntegrationEnabled: Boolean;
        BidirectionalSalesOrderIntEnabled: Boolean;
        CRMIsCoupledToRecord: Boolean;
        IsOfficeAddin: Boolean;
        CanCancelApprovalForRecord: Boolean;
#if not CLEAN21
        PowerBIVisible: Boolean;
#endif
        StatusStyleTxt: Text;
        ReadyToPostQst: Label 'The number of orders that will be posted is %1. \Do you want to continue?', Comment = '%1 - selected count';
        CanRequestApprovalForFlow: Boolean;
        CanCancelApprovalForFlow: Boolean;
        OrderCommentsExist: boolean; //NB
        rSalesCommentLine: record "Sales Comment Line"; //NB

    procedure ShowPreview()
    var
        SalesPostYesNo: Codeunit "Sales-Post (Yes/No)";
    begin
        SalesPostYesNo.Preview(Rec);
    end;

    local procedure SetControlVisibility()
    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        WorkflowWebhookManagement: Codeunit "Workflow Webhook Management";
    begin
        OpenApprovalEntriesExist := ApprovalsMgmt.HasOpenApprovalEntries(Rec.RecordId);

        CanCancelApprovalForRecord := ApprovalsMgmt.CanCancelApprovalForRecord(Rec.RecordId);

        WorkflowWebhookManagement.GetCanRequestAndCanCancel(Rec.RecordId, CanRequestApprovalForFlow, CanCancelApprovalForFlow);
    end;

    protected procedure PostDocument(PostingCodeunitID: Integer)
    var
        LinesInstructionMgt: Codeunit "Lines Instruction Mgt.";
    begin
        LinesInstructionMgt.SalesCheckAllLinesHaveQuantityAssigned(Rec);

        Rec.SendToPosting(PostingCodeunitID);

        CurrPage.Update(false);
    end;

    procedure SkipShowingLinesWithoutVAT()
    begin
        OnlyShowHeadersWithVat := true;
    end;

    local procedure PrintForUsage(UsageParam: Option)
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforePrintForUsage(Rec, UsageParam, IsHandled);
        if IsHandled then
            exit;

        DocPrint.PrintSalesOrder(Rec, UsageParam);
    end;

    local procedure SetFilterOnPositiveVatPostingGroups()
    var
        VatPostingSetup: Record "VAT Posting Setup";
        VatBusPostingCodeFilter: Text;
    begin
        VatPostingSetup.SetFilter("VAT %", '>0');
        VatPostingSetup.SetLoadFields("VAT Bus. Posting Group");
        if not VatPostingSetup.FindSet() then
            exit;
        repeat
            if StrPos(VatBusPostingCodeFilter, VatPostingSetup."VAT Bus. Posting Group") < 1 then begin
                if VatBusPostingCodeFilter <> '' then
                    VatBusPostingCodeFilter += '|';
                VatBusPostingCodeFilter += VatPostingSetup."VAT Bus. Posting Group";
            end;
        until VatPostingSetup.Next() = 0;
        Rec.SetFilter("VAT Bus. Posting Group", VatBusPostingCodeFilter);
    end;

    local procedure FindOrderComments()
    Begin
        CLEAR(OrderCommentsExist);
        rSalesCommentLine.SETRANGE("No.", rec."No.");
        OrderCommentsExist := NOT rSalesCommentLine.ISEMPTY;
    End;

    [IntegrationEvent(true, false)]
    local procedure OnBeforePrintForUsage(var SalesHeader: Record "Sales Header"; UsageParam: Option; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostActionWithMoreThanOneDoc(var SalesHeader: Record "Sales Header"; var BatchProcessingMgt: Codeunit "Batch Processing Mgt."; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostingSetSelectionFilter(var SalesHeaderToPost: Record "Sales Header"; CurrPageSalesHeader: Record "Sales Header")
    begin
    end;
}
