codeunit 50135 "Purchase Order Approval Mgt"
{
    procedure RequestApproval(var PurchOrderHeader: Record "Purchase Order Header")
    var
        ApprovalEntry: Record "Purchase Order Approval Entry";
        LastSequenceNo: Integer;
    begin
        if not PurchOrderHeader."Requires Approval" then
            Error('This order does not require approval.');

        if PurchOrderHeader."Approval Status" <> PurchOrderHeader."Approval Status"::"Not Required" then
            Error('Approval has already been requested for this order.');

        PurchOrderHeader."Approval Status" := PurchOrderHeader."Approval Status"::"Pending Approval";
        PurchOrderHeader."Requested By User ID" := UserId();
        PurchOrderHeader.Modify(true);

        // Get next sequence number
        ApprovalEntry.SetRange("Purchase Order No.", PurchOrderHeader."No.");
        if ApprovalEntry.FindLast() then
            LastSequenceNo := ApprovalEntry."Sequence No." + 1
        else
            LastSequenceNo := 1;

        // Create approval entry
        ApprovalEntry.Init();
        ApprovalEntry."Purchase Order No." := PurchOrderHeader."No.";
        ApprovalEntry."Sequence No." := LastSequenceNo;
        ApprovalEntry."Approver User ID" := PurchOrderHeader."Approver User ID";
        ApprovalEntry."Approval Status" := ApprovalEntry."Approval Status"::Pending;
        ApprovalEntry."Date-Time Requested" := CurrentDateTime();
        ApprovalEntry."Requested By User ID" := UserId();
        PurchOrderHeader.CalcFields("Total Amount");
        ApprovalEntry.Amount := PurchOrderHeader."Total Amount";
        ApprovalEntry.Comment := 'Approval requested';
        ApprovalEntry.Insert(false);

        Message('Approval request submitted successfully.');
    end;

    procedure ApproveRequest(var PurchOrderHeader: Record "Purchase Order Header"; ApproverUserID: Code[50])
    var
        ApprovalEntry: Record "Purchase Order Approval Entry";
    begin
        if PurchOrderHeader."Approval Status" <> PurchOrderHeader."Approval Status"::"Pending Approval" then
            Error('This order is not pending approval.');

        PurchOrderHeader."Approval Status" := PurchOrderHeader."Approval Status"::Approved;
        PurchOrderHeader."Approver User ID" := ApproverUserID;
        PurchOrderHeader."Approval Date" := Today();
        PurchOrderHeader.Modify(true);

        // Update existing approval entry
        ApprovalEntry.SetRange("Purchase Order No.", PurchOrderHeader."No.");
        ApprovalEntry.SetRange("Approval Status", ApprovalEntry."Approval Status"::Pending);
        if ApprovalEntry.FindFirst() then begin
            ApprovalEntry."Approval Status" := ApprovalEntry."Approval Status"::Approved;
            ApprovalEntry."Date-Time Responded" := CurrentDateTime();
            ApprovalEntry.Comment := 'Approved';
            ApprovalEntry.Modify(false);
        end;

        Message('Purchase order approved successfully.');
    end;

    procedure RejectRequest(var PurchOrderHeader: Record "Purchase Order Header"; ApproverUserID: Code[50]; RejectionComment: Text[250])
    var
        ApprovalEntry: Record "Purchase Order Approval Entry";
    begin
        if PurchOrderHeader."Approval Status" <> PurchOrderHeader."Approval Status"::"Pending Approval" then
            Error('This order is not pending approval.');

        PurchOrderHeader."Approval Status" := PurchOrderHeader."Approval Status"::Rejected;
        PurchOrderHeader."Approver User ID" := ApproverUserID;
        PurchOrderHeader."Approval Date" := Today();
        PurchOrderHeader.Modify(true);

        // Update existing approval entry
        ApprovalEntry.SetRange("Purchase Order No.", PurchOrderHeader."No.");
        ApprovalEntry.SetRange("Approval Status", ApprovalEntry."Approval Status"::Pending);
        if ApprovalEntry.FindFirst() then begin
            ApprovalEntry."Approval Status" := ApprovalEntry."Approval Status"::Rejected;
            ApprovalEntry."Date-Time Responded" := CurrentDateTime();
            ApprovalEntry.Comment := RejectionComment;
            ApprovalEntry.Modify(false);
        end;

        Message('Purchase order rejected.');
    end;

    procedure CancelRequest(var PurchOrderHeader: Record "Purchase Order Header")
    begin
        if PurchOrderHeader."Approval Status" <> PurchOrderHeader."Approval Status"::"Pending Approval" then
            Error('This order is not pending approval.');

        PurchOrderHeader."Approval Status" := PurchOrderHeader."Approval Status"::"Not Required";
        PurchOrderHeader.Modify(true);

        Message('Approval request cancelled.');
    end;
}
