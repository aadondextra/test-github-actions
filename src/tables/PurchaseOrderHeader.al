table 50120 "Purchase Order Header"
{
    Caption = 'Purchase Order Header';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "No." <> xRec."No." then begin
                    NoSeries.TestManual(GetNoSeriesCode());
                    "No. Series" := '';
                end;
            end;
        }

        field(2; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            DataClassification = CustomerContent;
            TableRelation = Vendor;

            trigger OnValidate()
            var
                Vendor: Record Vendor;
            begin
                if Vendor.Get("Vendor No.") then
                    "Vendor Name" := Vendor.Name
                else
                    "Vendor Name" := '';
            end;
        }

        field(3; "Vendor Name"; Text[100])
        {
            Caption = 'Vendor Name';
            DataClassification = CustomerContent;
            Editable = false;
        }

        field(4; "Order Date"; Date)
        {
            Caption = 'Order Date';
            DataClassification = CustomerContent;
        }

        field(5; "Expected Receipt Date"; Date)
        {
            Caption = 'Expected Receipt Date';
            DataClassification = CustomerContent;
        }

        field(6; "Total Amount"; Decimal)
        {
            Caption = 'Total Amount';
            FieldClass = FlowField;
            CalcFormula = sum("Purchase Order Line".Amount where("Order No." = field("No.")));
            Editable = false;
        }

        field(7; Status; Option)
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            OptionMembers = Open,Released,Completed;
            OptionCaption = 'Open,Released,Completed';
        }

        field(8; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }

        field(9; "Approval Status"; Option)
        {
            Caption = 'Approval Status';
            DataClassification = CustomerContent;
            OptionMembers = "Not Required","Pending Approval",Approved,Rejected;
            OptionCaption = 'Not Required,Pending Approval,Approved,Rejected';
            Editable = false;
        }

        field(10; "Approver User ID"; Code[50])
        {
            Caption = 'Approver User ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = "User Setup"."User ID";
        }

        field(11; "Requested By User ID"; Code[50])
        {
            Caption = 'Requested By User ID';
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
        }

        field(12; "Approval Date"; Date)
        {
            Caption = 'Approval Date';
            DataClassification = CustomerContent;
            Editable = false;
        }

        field(13; "Requires Approval"; Boolean)
        {
            Caption = 'Requires Approval';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }

    var
        NoSeries: Codeunit "No. Series";

    trigger OnInsert()
    var
        PurchOrderSetup: Record "Purchase Order Setup";
        TotalAmt: Decimal;
    begin
        if "No." = '' then begin
            TestNoSeries();
            "No. Series" := GetNoSeriesCode();
            if NoSeries.AreRelated("No. Series", xRec."No. Series") then
                "No. Series" := xRec."No. Series";
            "No." := NoSeries.GetNextNo("No. Series", 0D);
        end;

        if "Order Date" = 0D then
            "Order Date" := WorkDate();

        Status := Status::Open;
        "Approval Status" := "Approval Status"::"Not Required";

        // Check if approval is required based on setup
        PurchOrderSetup.GetRecordOnce();
        if PurchOrderSetup."Require Approval" then begin
            CalcFields("Total Amount");
            TotalAmt := "Total Amount";
            if TotalAmt > PurchOrderSetup."Approval Amount Limit" then begin
                "Requires Approval" := true;
                "Approver User ID" := PurchOrderSetup."Default Approver User ID";
            end;
        end;
    end;

    trigger OnDelete()
    var
        PurchOrderLine: Record "Purchase Order Line";
    begin
        // Delete all related lines
        PurchOrderLine.SetRange("Order No.", "No.");
        PurchOrderLine.DeleteAll(true);
    end;

    local procedure TestNoSeries()
    begin
        if GetNoSeriesCode() = '' then
            Error('No series is not defined.');
    end;

    local procedure GetNoSeriesCode(): Code[20]
    var
        PurchOrderSetup: Record "Purchase Order Setup";
    begin
        PurchOrderSetup.GetRecordOnce();
        if PurchOrderSetup."Purchase Order Nos." <> '' then
            exit(PurchOrderSetup."Purchase Order Nos.")
        else
            exit('PO-ORDER');
    end;

    procedure AssistEdit(OldPurchOrderHeader: Record "Purchase Order Header"): Boolean
    var
        PurchOrderHeader: Record "Purchase Order Header";
    begin
        PurchOrderHeader := Rec;
        if NoSeries.LookupRelatedNoSeries(GetNoSeriesCode(), OldPurchOrderHeader."No. Series", PurchOrderHeader."No. Series") then begin
            PurchOrderHeader."No." := NoSeries.GetNextNo(PurchOrderHeader."No. Series", 0D);
            Rec := PurchOrderHeader;
            exit(true);
        end;
    end;
}
