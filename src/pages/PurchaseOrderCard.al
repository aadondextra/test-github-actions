page 50122 "Purchase Order Card"
{
    PageType = Card;
    SourceTable = "Purchase Order Header";
    Caption = 'Purchase Order Card';
    ApplicationArea = All;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the purchase order.';

                    trigger OnAssistEdit()
                    begin
                        if Rec.AssistEdit(xRec) then
                            CurrPage.Update();
                    end;
                }

                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the vendor number.';
                }

                field("Vendor Name"; Rec."Vendor Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the vendor name.';
                }

                field("Order Date"; Rec."Order Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the order date.';
                }

                field("Expected Receipt Date"; Rec."Expected Receipt Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the expected receipt date.';
                }

                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the status of the order.';
                }

                field("Total Amount"; Rec."Total Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total amount of all lines.';
                }
            }

            group(Approval)
            {
                Caption = 'Approval';

                field("Requires Approval"; Rec."Requires Approval")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if this order requires approval.';
                    Style = Attention;
                    StyleExpr = Rec."Requires Approval";
                }

                field("Approval Status"; Rec."Approval Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the approval status.';
                }

                field("Approver User ID"; Rec."Approver User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the approver user ID.';
                }

                field("Requested By User ID"; Rec."Requested By User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies who requested the approval.';
                }

                field("Approval Date"; Rec."Approval Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the order was approved.';
                }
            }

            part(Lines; "Purchase Order Subpage")
            {
                ApplicationArea = All;
                SubPageLink = "Order No." = field("No.");
                UpdatePropagation = Both;
            }
        }

        area(FactBoxes)
        {
            part(ApprovalHistory; "PO Approval Entries Part")
            {
                ApplicationArea = All;
                SubPageLink = "Purchase Order No." = field("No.");
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Print)
            {
                ApplicationArea = All;
                Caption = 'Print';
                Image = Print;
                ToolTip = 'Print the purchase order.';

                trigger OnAction()
                var
                    PurchOrderHeader: Record "Purchase Order Header";
                begin
                    PurchOrderHeader := Rec;
                    PurchOrderHeader.SetRecFilter();
                    Report.Run(Report::"Purchase Order Grouped Report", true, false, PurchOrderHeader);
                end;
            }

            action(PrintReceipt)
            {
                ApplicationArea = All;
                Caption = 'Print Receipt (Thermal)';
                Image = PrintReport;
                ToolTip = 'Print thermal receipt for purchase order.';

                trigger OnAction()
                var
                    PurchOrderHeader: Record "Purchase Order Header";
                begin
                    PurchOrderHeader := Rec;
                    PurchOrderHeader.SetRecFilter();
                    Report.Run(Report::"Purchase Order Receipt Report", true, false, PurchOrderHeader);
                end;
            }

            action(Release)
            {
                ApplicationArea = All;
                Caption = 'Release';
                Image = ReleaseDoc;
                ToolTip = 'Release the purchase order.';

                trigger OnAction()
                begin
                    if Rec.Status = Rec.Status::Open then begin
                        Rec.Status := Rec.Status::Released;
                        Rec.Modify(true);
                        Message('Purchase order has been released.');
                    end;
                end;
            }

            action(Reopen)
            {
                ApplicationArea = All;
                Caption = 'Reopen';
                Image = ReOpen;
                ToolTip = 'Reopen the purchase order.';

                trigger OnAction()
                begin
                    if Rec.Status = Rec.Status::Released then begin
                        Rec.Status := Rec.Status::Open;
                        Rec.Modify(true);
                        Message('Purchase order has been reopened.');
                    end;
                end;
            }

            group(ApprovalActions)
            {
                Caption = 'Approval';

                action(RequestApproval)
                {
                    ApplicationArea = All;
                    Caption = 'Request Approval';
                    Image = SendApprovalRequest;
                    ToolTip = 'Request approval for this purchase order.';
                    Visible = Rec."Requires Approval" and (Rec."Approval Status" = Rec."Approval Status"::"Not Required");

                    trigger OnAction()
                    var
                        ApprovalMgt: Codeunit "Purchase Order Approval Mgt";
                    begin
                        ApprovalMgt.RequestApproval(Rec);
                        CurrPage.Update(false);
                    end;
                }

                action(Approve)
                {
                    ApplicationArea = All;
                    Caption = 'Approve';
                    Image = Approve;
                    ToolTip = 'Approve this purchase order.';
                    Enabled = IsApprover and (Rec."Approval Status" = Rec."Approval Status"::"Pending Approval");

                    trigger OnAction()
                    var
                        ApprovalMgt: Codeunit "Purchase Order Approval Mgt";
                    begin
                        ApprovalMgt.ApproveRequest(Rec, UserId());
                        CurrPage.Update(false);
                    end;
                }

                action(Reject)
                {
                    ApplicationArea = All;
                    Caption = 'Reject';
                    Image = Reject;
                    ToolTip = 'Reject this purchase order.';
                    Enabled = IsApprover and (Rec."Approval Status" = Rec."Approval Status"::"Pending Approval");

                    trigger OnAction()
                    var
                        ApprovalMgt: Codeunit "Purchase Order Approval Mgt";
                        RejectionComment: Text[250];
                    begin
                        RejectionComment := 'Rejected';
                        ApprovalMgt.RejectRequest(Rec, UserId(), RejectionComment);
                        CurrPage.Update(false);
                    end;
                }

                action(CancelApprovalRequest)
                {
                    ApplicationArea = All;
                    Caption = 'Cancel Approval Request';
                    Image = CancelApprovalRequest;
                    ToolTip = 'Cancel the approval request.';
                    Enabled = Rec."Approval Status" = Rec."Approval Status"::"Pending Approval";

                    trigger OnAction()
                    var
                        ApprovalMgt: Codeunit "Purchase Order Approval Mgt";
                    begin
                        ApprovalMgt.CancelRequest(Rec);
                        CurrPage.Update(false);
                    end;
                }
            }
        }

        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(Print_Promoted; Print)
                {
                }
                actionref(PrintReceipt_Promoted; PrintReceipt)
                {
                }
                actionref(Release_Promoted; Release)
                {
                }
                actionref(Reopen_Promoted; Reopen)
                {
                }
                actionref(RequestApproval_Promoted; RequestApproval)
                {
                }
                actionref(Approve_Promoted; Approve)
                {
                }
                actionref(Reject_Promoted; Reject)
                {
                }
            }
        }
    }

    var
        IsApprover: Boolean;

    trigger OnAfterGetCurrRecord()
    begin
        IsApprover := (Rec."Approver User ID" = UserId());
    end;
}
