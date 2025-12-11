table 50122 "Purchase Order Setup"
{
    Caption = 'Purchase Order Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = SystemMetadata;
        }

        field(2; "Purchase Order Nos."; Code[20])
        {
            Caption = 'Purchase Order Nos.';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }

        field(3; "Require Approval"; Boolean)
        {
            Caption = 'Require Approval';
            DataClassification = CustomerContent;
        }

        field(4; "Approval Amount Limit"; Decimal)
        {
            Caption = 'Approval Amount Limit';
            DataClassification = CustomerContent;
            MinValue = 0;
        }

        field(5; "Default Approver User ID"; Code[50])
        {
            Caption = 'Default Approver User ID';
            DataClassification = CustomerContent;
            TableRelation = "User Setup"."User ID";
        }

        field(6; "Default Payment Terms"; Code[10])
        {
            Caption = 'Default Payment Terms';
            DataClassification = CustomerContent;
            TableRelation = "Payment Terms";
        }

        field(7; "Auto-Post on Release"; Boolean)
        {
            Caption = 'Auto-Post on Release';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    procedure GetRecordOnce()
    begin
        if not Get() then begin
            Init();
            Insert(true);
        end;
    end;
}
