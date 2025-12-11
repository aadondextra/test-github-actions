page 50123 "Purchase Orders List"
{
    PageType = List;
    SourceTable = "Purchase Order Header";
    Caption = 'Purchase Orders';
    ApplicationArea = All;
    UsageCategory = Lists;
    CardPageId = "Purchase Order Card";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the purchase order.';
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
        }
    }

    actions
    {
        area(Processing)
        {
            action(NewOrder)
            {
                ApplicationArea = All;
                Caption = 'New';
                Image = New;
                ToolTip = 'Create a new purchase order.';

                trigger OnAction()
                var
                    PurchOrderHeader: Record "Purchase Order Header";
                begin
                    PurchOrderHeader.Init();
                    PurchOrderHeader.Insert(true);
                    Page.Run(Page::"Purchase Order Card", PurchOrderHeader);
                end;
            }
        }

        area(Promoted)
        {
            group(Category_New)
            {
                Caption = 'New';

                actionref(NewOrder_Promoted; NewOrder)
                {
                }
            }
        }
    }
}
