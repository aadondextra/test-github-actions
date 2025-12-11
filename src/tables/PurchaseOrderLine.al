table 50121 "Purchase Order Line"
{
    Caption = 'Purchase Order Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Order No."; Code[20])
        {
            Caption = 'Order No.';
            DataClassification = CustomerContent;
            TableRelation = "Purchase Order Header"."No.";
        }

        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
            AutoIncrement = true;
        }

        field(3; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            OptionMembers = " ",Item,Resource,Service;
            OptionCaption = ' ,Item,Resource,Service';
        }

        field(4; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
        }

        field(5; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }

        field(6; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                UpdateAmount();
                UpdateHeaderApprovalStatus();
            end;
        }

        field(7; "Unit Price"; Decimal)
        {
            Caption = 'Unit Price';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                UpdateAmount();
                UpdateHeaderApprovalStatus();
            end;
        }

        field(8; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;

            trigger OnValidate()
            begin
                UpdateHeaderApprovalStatus();
            end;
        }

        field(9; "Unit of Measure"; Code[10])
        {
            Caption = 'Unit of Measure';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Order No.", "Line No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        if "Line No." = 0 then
            "Line No." := GetNextLineNo();

        UpdateHeaderApprovalStatus();
    end;

    trigger OnModify()
    begin
        UpdateHeaderApprovalStatus();
    end;

    trigger OnDelete()
    begin
        UpdateHeaderApprovalStatus();
    end;

    local procedure UpdateAmount()
    begin
        Amount := Quantity * "Unit Price";
    end;

    local procedure UpdateHeaderApprovalStatus()
    var
        PurchOrderHeader: Record "Purchase Order Header";
        PurchOrderSetup: Record "Purchase Order Setup";
        TotalAmt: Decimal;
    begin
        if "Order No." = '' then
            exit;

        if not PurchOrderHeader.Get("Order No.") then
            exit;

        // Only update if order is Open and not already in approval process
        if PurchOrderHeader.Status <> PurchOrderHeader.Status::Open then
            exit;

        if PurchOrderHeader."Approval Status" in [PurchOrderHeader."Approval Status"::"Pending Approval",
                                                    PurchOrderHeader."Approval Status"::Approved] then
            exit;

        PurchOrderSetup.GetRecordOnce();
        if not PurchOrderSetup."Require Approval" then
            exit;

        // Calculate total
        PurchOrderHeader.CalcFields("Total Amount");
        TotalAmt := PurchOrderHeader."Total Amount";

        // Update Requires Approval flag based on amount
        if TotalAmt > PurchOrderSetup."Approval Amount Limit" then begin
            if not PurchOrderHeader."Requires Approval" then begin
                PurchOrderHeader."Requires Approval" := true;
                PurchOrderHeader.Modify(false);
            end;
        end else begin
            if PurchOrderHeader."Requires Approval" then begin
                PurchOrderHeader."Requires Approval" := false;
                PurchOrderHeader.Modify(false);
            end;
        end;
    end;

    local procedure GetNextLineNo(): Integer
    var
        PurchOrderLine: Record "Purchase Order Line";
    begin
        PurchOrderLine.SetRange("Order No.", "Order No.");
        if PurchOrderLine.FindLast() then
            exit(PurchOrderLine."Line No." + 10000)
        else
            exit(10000);
    end;
}
