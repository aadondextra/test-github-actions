page 50130 "PO Approval Entries Part"
{
    PageType = ListPart;
    SourceTable = "Purchase Order Approval Entry";
    Caption = 'Approval History';
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
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

                field(Comment; Rec.Comment)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies any comments';
                }
            }
        }
    }
}
