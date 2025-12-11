page 50129 "PO Approval Entries"
{
    PageType = List;
    SourceTable = "Purchase Order Approval Entry";
    Caption = 'Purchase Order Approval Entries';
    Editable = false;
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the entry number';
                }

                field("Purchase Order No."; Rec."Purchase Order No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the order number';
                }

                field("Sequence No."; Rec."Sequence No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the sequence number';
                }

                field("Approver User ID"; Rec."Approver User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the approver';
                }

                field("Approval Status"; Rec."Approval Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the approval status';
                }

                field("Date-Time Requested"; Rec."Date-Time Requested")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when approval was requested';
                }

                field("Date-Time Responded"; Rec."Date-Time Responded")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the approver responded';
                }

                field("Requested By User ID"; Rec."Requested By User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies who requested the approval';
                }

                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the order amount';
                }

                field(Comment; Rec.Comment)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies any comments';
                }
            }
        }
    }
}
