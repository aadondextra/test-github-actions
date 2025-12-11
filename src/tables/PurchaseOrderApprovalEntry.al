table 50123 "Purchase Order Approval Entry"
{
    Caption = 'Purchase Order Approval Entry';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
            AutoIncrement = true;
            Editable = false;
        }

        field(2; "Purchase Order No."; Code[20])
        {
            Caption = 'Purchase Order No.';
            DataClassification = CustomerContent;
            TableRelation = "Purchase Order Header"."No.";
        }

        field(3; "Sequence No."; Integer)
        {
            Caption = 'Sequence No.';
            DataClassification = CustomerContent;
        }

        field(4; "Approver User ID"; Code[50])
        {
            Caption = 'Approver User ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = "User Setup"."User ID";
        }

        field(5; "Approval Status"; Option)
        {
            Caption = 'Approval Status';
            DataClassification = CustomerContent;
            OptionMembers = Pending,Approved,Rejected;
            OptionCaption = 'Pending,Approved,Rejected';
        }

        field(6; "Date-Time Requested"; DateTime)
        {
            Caption = 'Date-Time Requested';
            DataClassification = CustomerContent;
        }

        field(7; "Date-Time Responded"; DateTime)
        {
            Caption = 'Date-Time Responded';
            DataClassification = CustomerContent;
        }

        field(8; "Requested By User ID"; Code[50])
        {
            Caption = 'Requested By User ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
        }

        field(9; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
        }

        field(10; Comment; Text[250])
        {
            Caption = 'Comment';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(OrderNo; "Purchase Order No.", "Sequence No.")
        {
        }
    }
}
