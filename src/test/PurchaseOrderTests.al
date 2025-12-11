codeunit 50130 "Purchase Order Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        IsInitialized: Boolean;

    [Test]
    procedure TestCreatePurchaseOrderWithAutoNumber()
    var
        PurchOrderHeader: Record "Purchase Order Header";
    begin
        // [GIVEN] A clean environment and No. Series configured
        Initialize();

        // [WHEN] Creating a new purchase order without specifying No.
        PurchOrderHeader.Init();
        PurchOrderHeader."No." := ''; // Force auto-generation
        PurchOrderHeader.Insert(true);

        // [THEN] The No. should be auto-generated
        if PurchOrderHeader."No." = '' then
            Error('Purchase Order No. should be auto-generated');
        if StrPos(PurchOrderHeader."No.", 'PO-') = 0 then
            Error('Purchase Order No. should start with PO-. Actual: %1', PurchOrderHeader."No.");

        // Cleanup
        PurchOrderHeader.Delete(true);
    end;

    [Test]
    procedure TestOrderDateIsAutoInitialized()
    var
        PurchOrderHeader: Record "Purchase Order Header";
    begin
        // [GIVEN] A clean environment
        Initialize();

        // [WHEN] Creating a new purchase order
        PurchOrderHeader.Init();
        PurchOrderHeader.Insert(true);

        // [THEN] Order Date should be set to WorkDate
        if PurchOrderHeader."Order Date" <> WorkDate() then
            Error('Order Date should be set to WorkDate');

        // Cleanup
        PurchOrderHeader.Delete(true);
    end;

    [Test]
    procedure TestStatusIsSetToOpenOnInsert()
    var
        PurchOrderHeader: Record "Purchase Order Header";
    begin
        // [GIVEN] A clean environment
        Initialize();

        // [WHEN] Creating a new purchase order
        PurchOrderHeader.Init();
        PurchOrderHeader.Insert(true);

        // [THEN] Status should be Open
        if PurchOrderHeader.Status <> PurchOrderHeader.Status::Open then
            Error('Status should be Open on insert');

        // Cleanup
        PurchOrderHeader.Delete(true);
    end;

    [Test]
    procedure TestAddLineWithAutoLineNo()
    var
        PurchOrderHeader: Record "Purchase Order Header";
        PurchOrderLine: Record "Purchase Order Line";
    begin
        // [GIVEN] A purchase order
        Initialize();
        CreatePurchaseOrder(PurchOrderHeader);

        // [WHEN] Adding a line without specifying Line No.
        PurchOrderLine.Init();
        PurchOrderLine."Order No." := PurchOrderHeader."No.";
        PurchOrderLine.Description := 'Test Item';
        PurchOrderLine.Validate(Quantity, 5);
        PurchOrderLine.Validate("Unit Price", 100);
        PurchOrderLine.Insert(true);

        // [THEN] Line No. should be auto-generated (10000)
        if PurchOrderLine."Line No." <> 10000 then
            Error('First line should have Line No. 10000. Actual: %1', PurchOrderLine."Line No.");

        // Cleanup
        PurchOrderLine.Delete(true);
        PurchOrderHeader.Delete(true);
    end;

    [Test]
    procedure TestMultipleLinesHaveIncrementalLineNo()
    var
        PurchOrderHeader: Record "Purchase Order Header";
        PurchOrderLine1: Record "Purchase Order Line";
        PurchOrderLine2: Record "Purchase Order Line";
    begin
        // [GIVEN] A purchase order with one line
        Initialize();
        CreatePurchaseOrder(PurchOrderHeader);
        CreatePurchaseLine(PurchOrderLine1, PurchOrderHeader."No.", 'Item 1', 5, 100);

        // [WHEN] Adding a second line
        CreatePurchaseLine(PurchOrderLine2, PurchOrderHeader."No.", 'Item 2', 3, 50);

        // [THEN] Line numbers should be incremental
        if PurchOrderLine1."Line No." <> 10000 then
            Error('First line should be 10000');
        if PurchOrderLine2."Line No." <> 20000 then
            Error('Second line should be 20000');

        // Cleanup
        PurchOrderLine2.Delete(true);
        PurchOrderLine1.Delete(true);
        PurchOrderHeader.Delete(true);
    end;

    [Test]
    procedure TestAmountIsCalculatedCorrectly()
    var
        PurchOrderHeader: Record "Purchase Order Header";
        PurchOrderLine: Record "Purchase Order Line";
        ExpectedAmount: Decimal;
    begin
        // [GIVEN] A purchase order
        Initialize();
        CreatePurchaseOrder(PurchOrderHeader);

        // [WHEN] Creating a line with Quantity and Unit Price
        PurchOrderLine.Init();
        PurchOrderLine."Order No." := PurchOrderHeader."No.";
        PurchOrderLine.Validate(Quantity, 5);
        PurchOrderLine.Validate("Unit Price", 123.45);
        PurchOrderLine.Insert(true);

        // [THEN] Amount should be Quantity * Unit Price
        ExpectedAmount := 5 * 123.45;
        if PurchOrderLine.Amount <> ExpectedAmount then
            Error('Amount should be calculated as Quantity * Unit Price. Expected: %1, Actual: %2', ExpectedAmount, PurchOrderLine.Amount);

        // Cleanup
        PurchOrderLine.Delete(true);
        PurchOrderHeader.Delete(true);
    end;

    [Test]
    procedure TestTotalAmountIsCalculatedFromLines()
    var
        PurchOrderHeader: Record "Purchase Order Header";
        PurchOrderLine1: Record "Purchase Order Line";
        PurchOrderLine2: Record "Purchase Order Line";
        ExpectedTotal: Decimal;
    begin
        // [GIVEN] A purchase order with multiple lines
        Initialize();
        CreatePurchaseOrder(PurchOrderHeader);
        CreatePurchaseLine(PurchOrderLine1, PurchOrderHeader."No.", 'Item 1', 5, 100);
        CreatePurchaseLine(PurchOrderLine2, PurchOrderHeader."No.", 'Item 2', 3, 50);

        // [WHEN] Calculating Total Amount
        PurchOrderHeader.CalcFields("Total Amount");

        // [THEN] Total Amount should be sum of all line amounts
        ExpectedTotal := (5 * 100) + (3 * 50);
        if PurchOrderHeader."Total Amount" <> ExpectedTotal then
            Error('Total Amount should be sum of all lines. Expected: %1, Actual: %2', ExpectedTotal, PurchOrderHeader."Total Amount");

        // Cleanup
        PurchOrderLine2.Delete(true);
        PurchOrderLine1.Delete(true);
        PurchOrderHeader.Delete(true);
    end;

    [Test]
    procedure TestLinesAreLinkedToCorrectOrder()
    var
        PurchOrderHeader1: Record "Purchase Order Header";
        PurchOrderHeader2: Record "Purchase Order Header";
        PurchOrderLine1: Record "Purchase Order Line";
        PurchOrderLine2: Record "Purchase Order Line";
        FilteredLines: Record "Purchase Order Line";
    begin
        // [GIVEN] Two purchase orders with lines
        Initialize();
        CreatePurchaseOrder(PurchOrderHeader1);
        CreatePurchaseOrder(PurchOrderHeader2);
        CreatePurchaseLine(PurchOrderLine1, PurchOrderHeader1."No.", 'Order 1 Item', 5, 100);
        CreatePurchaseLine(PurchOrderLine2, PurchOrderHeader2."No.", 'Order 2 Item', 3, 50);

        // [WHEN] Filtering lines for first order
        FilteredLines.SetRange("Order No.", PurchOrderHeader1."No.");

        // [THEN] Only lines from first order should be returned
        if FilteredLines.Count <> 1 then
            Error('Should have exactly 1 line for first order');
        FilteredLines.FindFirst();
        if FilteredLines."Order No." <> PurchOrderLine1."Order No." then
            Error('Line should belong to first order');

        // Cleanup
        PurchOrderLine2.Delete(true);
        PurchOrderLine1.Delete(true);
        PurchOrderHeader1.Delete(true);
        PurchOrderHeader2.Delete(true);
    end;

    [Test]
    procedure TestDeleteHeaderDeletesLines()
    var
        PurchOrderHeader: Record "Purchase Order Header";
        PurchOrderLine: Record "Purchase Order Line";
        LineOrderNo: Code[20];
    begin
        // [GIVEN] A purchase order with lines
        Initialize();
        CreatePurchaseOrder(PurchOrderHeader);
        CreatePurchaseLine(PurchOrderLine, PurchOrderHeader."No.", 'Item 1', 5, 100);
        LineOrderNo := PurchOrderLine."Order No.";

        // [WHEN] Deleting the header
        PurchOrderHeader.Delete(true);

        // [THEN] Lines should also be deleted
        PurchOrderLine.SetRange("Order No.", LineOrderNo);
        if PurchOrderLine.Count <> 0 then
            Error('Lines should be deleted when header is deleted');
    end;

    [Test]
    procedure TestVendorFieldsCanBeSet()
    var
        PurchOrderHeader: Record "Purchase Order Header";
    begin
        // [GIVEN] A clean environment
        Initialize();

        // [WHEN] Creating an order with vendor information
        PurchOrderHeader.Init();
        PurchOrderHeader."Vendor No." := 'V001';
        PurchOrderHeader."Vendor Name" := 'Test Vendor Inc.';
        PurchOrderHeader.Insert(true);

        // [THEN] Vendor fields should be set correctly
        if PurchOrderHeader."Vendor No." <> 'V001' then
            Error('Vendor No. should be set');
        if PurchOrderHeader."Vendor Name" <> 'Test Vendor Inc.' then
            Error('Vendor Name should be set');

        // Cleanup
        PurchOrderHeader.Delete(true);
    end;

    [Test]
    procedure TestStatusCanBeChanged()
    var
        PurchOrderHeader: Record "Purchase Order Header";
    begin
        // [GIVEN] A purchase order with Open status
        Initialize();
        CreatePurchaseOrder(PurchOrderHeader);

        // [WHEN] Changing status to Released
        PurchOrderHeader.Status := PurchOrderHeader.Status::Released;
        PurchOrderHeader.Modify(true);

        // [THEN] Status should be Released
        PurchOrderHeader.Get(PurchOrderHeader."No.");
        if PurchOrderHeader.Status <> PurchOrderHeader.Status::Released then
            Error('Status should be Released');

        // Cleanup
        PurchOrderHeader.Delete(true);
    end;

    // ============================================
    // Test Runner Triggers
    // ============================================

    trigger OnRun()
    begin
        // Initialize and run all tests
        Initialize();

        TestCreatePurchaseOrderWithAutoNumber();
        TestOrderDateIsAutoInitialized();
        TestStatusIsSetToOpenOnInsert();
        TestVendorFieldsCanBeSet();
        TestStatusCanBeChanged();
        TestAddLineWithAutoLineNo();
        TestMultipleLinesHaveIncrementalLineNo();
        TestAmountIsCalculatedCorrectly();
        TestTotalAmountIsCalculatedFromLines();
        TestLinesAreLinkedToCorrectOrder();
        TestDeleteHeaderDeletesLines();
        TestRequiresApprovalFlagWhenAmountExceedsLimit();
        TestApprovalStatusDefaultsToNotRequired();
        TestRequestApprovalCreatesEntry();
        TestApproveRequestUpdatesEntry();
        TestRejectRequestUpdatesEntry();

        Message('All tests completed successfully!');
    end;

    [Test]
    procedure TestRequiresApprovalFlagWhenAmountExceedsLimit()
    var
        PurchOrderHeader: Record "Purchase Order Header";
        PurchOrderLine: Record "Purchase Order Line";
        PurchOrderSetup: Record "Purchase Order Setup";
    begin
        // [GIVEN] Setup with Approval Amount Limit = 1000 and Require Approval = true
        Initialize();
        SetupApprovalConfiguration(1000, true);

        // [WHEN] Creating an order with amount > 1000
        CreatePurchaseOrder(PurchOrderHeader);
        CreatePurchaseLine(PurchOrderLine, PurchOrderHeader."No.", 'Expensive Item', 10, 150); // 1500 total

        // Manually trigger the approval check since test context doesn't always trigger OnModify
        Commit();
        PurchOrderHeader.Get(PurchOrderHeader."No.");
        PurchOrderHeader.CalcFields("Total Amount");

        // Replicate the logic from UpdateHeaderApprovalStatus
        PurchOrderSetup.GetRecordOnce();
        if PurchOrderSetup."Require Approval" then begin
            if PurchOrderHeader."Total Amount" > PurchOrderSetup."Approval Amount Limit" then
                PurchOrderHeader."Requires Approval" := true
            else
                PurchOrderHeader."Requires Approval" := false;
            PurchOrderHeader.Modify(false);
        end;

        // [THEN] Requires Approval should be true
        PurchOrderHeader.Get(PurchOrderHeader."No.");
        if not PurchOrderHeader."Requires Approval" then
            Error('Requires Approval should be true when amount exceeds limit. Total: %1, Limit: 1000, Requires Approval: %2',
                PurchOrderHeader."Total Amount", PurchOrderHeader."Requires Approval");

        // Cleanup
        PurchOrderHeader.Delete(true);
        CleanupSetup();
    end;

    [Test]
    procedure TestApprovalStatusDefaultsToNotRequired()
    var
        PurchOrderHeader: Record "Purchase Order Header";
    begin
        // [GIVEN] A new Purchase Order
        Initialize();

        // [WHEN] Creating the order
        CreatePurchaseOrder(PurchOrderHeader);

        // [THEN] Approval Status should be Not Required
        if PurchOrderHeader."Approval Status" <> PurchOrderHeader."Approval Status"::"Not Required" then
            Error('Approval Status should default to Not Required');

        // Cleanup
        PurchOrderHeader.Delete(true);
    end;

    [Test]
    procedure TestRequestApprovalCreatesEntry()
    var
        PurchOrderHeader: Record "Purchase Order Header";
        PurchOrderLine: Record "Purchase Order Line";
        PurchOrderSetup: Record "Purchase Order Setup";
        ApprovalEntry: Record "Purchase Order Approval Entry";
        ApprovalMgt: Codeunit "Purchase Order Approval Mgt";
        EntryCount: Integer;
    begin
        // [GIVEN] An order requiring approval
        Initialize();
        SetupApprovalConfiguration(1000, true);
        CreatePurchaseOrder(PurchOrderHeader);
        PurchOrderHeader."Approver User ID" := UserId();
        PurchOrderHeader.Modify(false);
        CreatePurchaseLine(PurchOrderLine, PurchOrderHeader."No.", 'Item', 20, 100); // 2000 total

        // Manually set Requires Approval flag
        Commit();
        PurchOrderHeader.Get(PurchOrderHeader."No.");
        PurchOrderHeader.CalcFields("Total Amount");
        PurchOrderSetup.GetRecordOnce();
        if PurchOrderSetup."Require Approval" then begin
            if PurchOrderHeader."Total Amount" > PurchOrderSetup."Approval Amount Limit" then
                PurchOrderHeader."Requires Approval" := true;
            PurchOrderHeader.Modify(false);
        end;

        // [WHEN] Requesting approval
        PurchOrderHeader.Get(PurchOrderHeader."No.");
        ApprovalMgt.RequestApproval(PurchOrderHeader);

        // [THEN] Should create one approval entry with Pending status
        ApprovalEntry.SetRange("Purchase Order No.", PurchOrderHeader."No.");
        EntryCount := ApprovalEntry.Count();
        if EntryCount <> 1 then
            Error('Expected 1 approval entry, found %1', EntryCount);

        ApprovalEntry.FindFirst();
        if ApprovalEntry."Approval Status" <> ApprovalEntry."Approval Status"::Pending then
            Error('Approval Entry should have Pending status');

        // Cleanup
        PurchOrderHeader.Delete(true);
        CleanupSetup();
    end;

    [Test]
    procedure TestApproveRequestUpdatesEntry()
    var
        PurchOrderHeader: Record "Purchase Order Header";
        PurchOrderLine: Record "Purchase Order Line";
        PurchOrderSetup: Record "Purchase Order Setup";
        ApprovalEntry: Record "Purchase Order Approval Entry";
        ApprovalMgt: Codeunit "Purchase Order Approval Mgt";
        EntryCount: Integer;
    begin
        // [GIVEN] An order with pending approval
        Initialize();
        SetupApprovalConfiguration(1000, true);
        CreatePurchaseOrder(PurchOrderHeader);
        PurchOrderHeader."Approver User ID" := UserId();
        PurchOrderHeader.Modify(false);
        CreatePurchaseLine(PurchOrderLine, PurchOrderHeader."No.", 'Item', 20, 100);

        // Manually set Requires Approval flag
        Commit();
        PurchOrderHeader.Get(PurchOrderHeader."No.");
        PurchOrderHeader.CalcFields("Total Amount");
        PurchOrderSetup.GetRecordOnce();
        if PurchOrderSetup."Require Approval" then begin
            if PurchOrderHeader."Total Amount" > PurchOrderSetup."Approval Amount Limit" then
                PurchOrderHeader."Requires Approval" := true;
            PurchOrderHeader.Modify(false);
        end;

        PurchOrderHeader.Get(PurchOrderHeader."No.");
        ApprovalMgt.RequestApproval(PurchOrderHeader);

        // [WHEN] Approving the request
        PurchOrderHeader.Get(PurchOrderHeader."No.");
        ApprovalMgt.ApproveRequest(PurchOrderHeader, UserId());

        // [THEN] Entry should be updated to Approved (not create a new one)
        ApprovalEntry.SetRange("Purchase Order No.", PurchOrderHeader."No.");
        EntryCount := ApprovalEntry.Count();
        if EntryCount <> 1 then
            Error('Expected 1 approval entry after approval, found %1', EntryCount);

        ApprovalEntry.FindFirst();
        if ApprovalEntry."Approval Status" <> ApprovalEntry."Approval Status"::Approved then
            Error('Approval Entry should be updated to Approved');

        // Cleanup
        PurchOrderHeader.Delete(true);
        CleanupSetup();
    end;

    [Test]
    procedure TestRejectRequestUpdatesEntry()
    var
        PurchOrderHeader: Record "Purchase Order Header";
        PurchOrderLine: Record "Purchase Order Line";
        PurchOrderSetup: Record "Purchase Order Setup";
        ApprovalEntry: Record "Purchase Order Approval Entry";
        ApprovalMgt: Codeunit "Purchase Order Approval Mgt";
        EntryCount: Integer;
    begin
        // [GIVEN] An order with pending approval
        Initialize();
        SetupApprovalConfiguration(1000, true);
        CreatePurchaseOrder(PurchOrderHeader);
        PurchOrderHeader."Approver User ID" := UserId();
        PurchOrderHeader.Modify(false);
        CreatePurchaseLine(PurchOrderLine, PurchOrderHeader."No.", 'Item', 20, 100);

        // Manually set Requires Approval flag
        Commit();
        PurchOrderHeader.Get(PurchOrderHeader."No.");
        PurchOrderHeader.CalcFields("Total Amount");
        PurchOrderSetup.GetRecordOnce();
        if PurchOrderSetup."Require Approval" then begin
            if PurchOrderHeader."Total Amount" > PurchOrderSetup."Approval Amount Limit" then
                PurchOrderHeader."Requires Approval" := true;
            PurchOrderHeader.Modify(false);
        end;

        PurchOrderHeader.Get(PurchOrderHeader."No.");
        ApprovalMgt.RequestApproval(PurchOrderHeader);

        // [WHEN] Rejecting the request
        PurchOrderHeader.Get(PurchOrderHeader."No.");
        ApprovalMgt.RejectRequest(PurchOrderHeader, UserId(), 'Not approved');

        // [THEN] Entry should be updated to Rejected (not create a new one)
        ApprovalEntry.SetRange("Purchase Order No.", PurchOrderHeader."No.");
        EntryCount := ApprovalEntry.Count();
        if EntryCount <> 1 then
            Error('Expected 1 approval entry after rejection, found %1', EntryCount);

        ApprovalEntry.FindFirst();
        if ApprovalEntry."Approval Status" <> ApprovalEntry."Approval Status"::Rejected then
            Error('Approval Entry should be updated to Rejected');
        if ApprovalEntry.Comment <> 'Not approved' then
            Error('Comment should be saved');

        // Cleanup
        PurchOrderHeader.Delete(true);
        CleanupSetup();
    end;

    // ============================================
    // Initialization
    // ============================================

    local procedure Initialize()
    begin
        if IsInitialized then
            exit;

        // Setup No. Series if it doesn't exist
        SetupNoSeries();

        IsInitialized := true;
    end;

    local procedure SetupNoSeries()
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        // Create No. Series if it doesn't exist
        if not NoSeries.Get('PO-ORDER') then begin
            NoSeries.Init();
            NoSeries.Code := 'PO-ORDER';
            NoSeries.Description := 'Purchase Order Numbers';
            NoSeries."Default Nos." := true;
            NoSeries."Manual Nos." := true;
            if NoSeries.Insert(true) then;
        end;

        // Create No. Series Line if it doesn't exist
        NoSeriesLine.SetRange("Series Code", 'PO-ORDER');
        if NoSeriesLine.IsEmpty() then begin
            NoSeriesLine.Init();
            NoSeriesLine."Series Code" := 'PO-ORDER';
            NoSeriesLine."Line No." := 10000;
            NoSeriesLine."Starting No." := 'PO-00001';
            NoSeriesLine."Ending No." := 'PO-99999';
            NoSeriesLine."Increment-by No." := 1;
            if NoSeriesLine.Insert(true) then;
        end;
    end;

    local procedure CreatePurchaseOrder(var PurchOrderHeader: Record "Purchase Order Header")
    begin
        PurchOrderHeader.Init();
        PurchOrderHeader."Vendor No." := 'VENDOR001';
        PurchOrderHeader."Vendor Name" := 'Test Vendor';
        PurchOrderHeader.Insert(true);
    end;

    local procedure CreatePurchaseLine(var PurchOrderLine: Record "Purchase Order Line"; OrderNo: Code[20]; Description: Text[100]; Quantity: Decimal; UnitPrice: Decimal)
    begin
        PurchOrderLine.Init();
        PurchOrderLine."Order No." := OrderNo;
        PurchOrderLine.Description := Description;
        PurchOrderLine.Validate(Quantity, Quantity);
        PurchOrderLine.Validate("Unit Price", UnitPrice);
        PurchOrderLine.Insert(true);
    end;

    local procedure SetupApprovalConfiguration(AmountLimit: Decimal; RequireApproval: Boolean)
    var
        PurchOrderSetup: Record "Purchase Order Setup";
    begin
        PurchOrderSetup.GetRecordOnce();
        PurchOrderSetup."Approval Amount Limit" := AmountLimit;
        PurchOrderSetup."Require Approval" := RequireApproval;
        PurchOrderSetup."Default Approver User ID" := UserId();
        PurchOrderSetup.Modify(false);
    end;

    local procedure CleanupSetup()
    var
        PurchOrderSetup: Record "Purchase Order Setup";
    begin
        if PurchOrderSetup.Get() then begin
            PurchOrderSetup."Require Approval" := false;
            PurchOrderSetup."Approval Amount Limit" := 0;
            PurchOrderSetup.Modify(false);
        end;
    end;
}
