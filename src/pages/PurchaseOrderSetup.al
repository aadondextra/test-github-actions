page 50128 "Purchase Order Setup"
{
    PageType = Card;
    SourceTable = "Purchase Order Setup";
    Caption = 'Purchase Order Setup';
    InsertAllowed = false;
    DeleteAllowed = false;
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(Numbering)
            {
                Caption = 'Numbering';

                field("Purchase Order Nos."; Rec."Purchase Order Nos.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number series for purchase orders';
                }
            }

            group(Approval)
            {
                Caption = 'Approval Settings';

                field("Require Approval"; Rec."Require Approval")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if purchase orders require approval';
                }

                field("Approval Amount Limit"; Rec."Approval Amount Limit")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the amount limit that triggers approval requirement';
                }

                field("Default Approver User ID"; Rec."Default Approver User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the default approver for purchase orders';
                }

                field("Default Payment Terms"; Rec."Default Payment Terms")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the default payment terms';
                }

                field("Auto-Post on Release"; Rec."Auto-Post on Release")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if orders should auto-post when released';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.GetRecordOnce();
    end;
}
