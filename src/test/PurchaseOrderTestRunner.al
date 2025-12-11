page 50131 "Purchase Order Test Runner"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Tasks;
    Caption = 'Purchase Order Test Runner';

    layout
    {
        area(Content)
        {
            group(TestResults)
            {
                Caption = 'Test Results';
                field(TestsRun; TestsRun)
                {
                    Caption = 'Tests Run';
                    Editable = false;
                }
                field(TestsPassed; TestsPassed)
                {
                    Caption = 'Tests Passed';
                    Editable = false;
                    Style = Favorable;
                    StyleExpr = TestsPassed > 0;
                }
                field(TestsFailed; TestsFailed)
                {
                    Caption = 'Tests Failed';
                    Editable = false;
                    Style = Unfavorable;
                    StyleExpr = TestsFailed > 0;
                }
                field(LastError; LastError)
                {
                    Caption = 'Last Error';
                    Editable = false;
                    MultiLine = true;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(RunAll)
            {
                Caption = 'Run All Tests';
                Image = TestReport;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    RunAllTests();
                end;
            }
            action(Test1)
            {
                Caption = 'Test: Auto Number';
                Image = TestFile;

                trigger OnAction()
                begin
                    RunSingleTest(1);
                end;
            }
            action(Test2)
            {
                Caption = 'Test: Order Date';
                Image = TestFile;

                trigger OnAction()
                begin
                    RunSingleTest(2);
                end;
            }
            action(Test3)
            {
                Caption = 'Test: Status Open';
                Image = TestFile;

                trigger OnAction()
                begin
                    RunSingleTest(3);
                end;
            }
            action(Test4)
            {
                Caption = 'Test: Line Auto No';
                Image = TestFile;

                trigger OnAction()
                begin
                    RunSingleTest(4);
                end;
            }
            action(Test5)
            {
                Caption = 'Test: Incremental Lines';
                Image = TestFile;

                trigger OnAction()
                begin
                    RunSingleTest(5);
                end;
            }
            action(Test6)
            {
                Caption = 'Test: Amount Calculation';
                Image = TestFile;

                trigger OnAction()
                begin
                    RunSingleTest(6);
                end;
            }
            action(Test7)
            {
                Caption = 'Test: Total Amount';
                Image = TestFile;

                trigger OnAction()
                begin
                    RunSingleTest(7);
                end;
            }
            action(Test8)
            {
                Caption = 'Test: Lines Linked';
                Image = TestFile;

                trigger OnAction()
                begin
                    RunSingleTest(8);
                end;
            }
            action(Test9)
            {
                Caption = 'Test: Cascade Delete';
                Image = TestFile;

                trigger OnAction()
                begin
                    RunSingleTest(9);
                end;
            }
            action(Test10)
            {
                Caption = 'Test: Vendor Fields';
                Image = TestFile;

                trigger OnAction()
                begin
                    RunSingleTest(10);
                end;
            }
            action(Test11)
            {
                Caption = 'Test: Status Change';
                Image = TestFile;

                trigger OnAction()
                begin
                    RunSingleTest(11);
                end;
            }
        }
    }

    var
        TestsRun: Integer;
        TestsPassed: Integer;
        TestsFailed: Integer;
        LastError: Text;

    local procedure RunAllTests()
    var
        PurchOrderTests: Codeunit "Purchase Order Tests";
        i: Integer;
    begin
        ClearResults();
        for i := 1 to 11 do
            ExecuteTest(PurchOrderTests, i);

        Message('Tests completed.\Total: %1\Passed: %2\Failed: %3', TestsRun, TestsPassed, TestsFailed);
    end;

    local procedure RunSingleTest(TestNo: Integer)
    var
        PurchOrderTests: Codeunit "Purchase Order Tests";
    begin
        ClearResults();
        ExecuteTest(PurchOrderTests, TestNo);
        Message('Test completed.\Result: %1', GetTestResult());
    end;

    local procedure ExecuteTest(var PurchOrderTests: Codeunit "Purchase Order Tests"; TestNo: Integer)
    var
        Success: Boolean;
    begin
        TestsRun += 1;
        LastError := '';
        Commit();

        Success := true;
        case TestNo of
            1:
                if not TryRunTest(PurchOrderTests, 1) then
                    Success := false;
            2:
                if not TryRunTest(PurchOrderTests, 2) then
                    Success := false;
            3:
                if not TryRunTest(PurchOrderTests, 3) then
                    Success := false;
            4:
                if not TryRunTest(PurchOrderTests, 4) then
                    Success := false;
            5:
                if not TryRunTest(PurchOrderTests, 5) then
                    Success := false;
            6:
                if not TryRunTest(PurchOrderTests, 6) then
                    Success := false;
            7:
                if not TryRunTest(PurchOrderTests, 7) then
                    Success := false;
            8:
                if not TryRunTest(PurchOrderTests, 8) then
                    Success := false;
            9:
                if not TryRunTest(PurchOrderTests, 9) then
                    Success := false;
            10:
                if not TryRunTest(PurchOrderTests, 10) then
                    Success := false;
            11:
                if not TryRunTest(PurchOrderTests, 11) then
                    Success := false;
        end;

        if Success then
            TestsPassed += 1
        else begin
            TestsFailed += 1;
            LastError := CopyStr(GetLastErrorText(), 1, 1024);
        end;

        CurrPage.Update(false);
    end;

    [TryFunction]
    local procedure TryRunTest(var PurchOrderTests: Codeunit "Purchase Order Tests"; TestNo: Integer)
    begin
        case TestNo of
            1:
                PurchOrderTests.TestCreatePurchaseOrderWithAutoNumber();
            2:
                PurchOrderTests.TestOrderDateIsAutoInitialized();
            3:
                PurchOrderTests.TestStatusIsSetToOpenOnInsert();
            4:
                PurchOrderTests.TestAddLineWithAutoLineNo();
            5:
                PurchOrderTests.TestMultipleLinesHaveIncrementalLineNo();
            6:
                PurchOrderTests.TestAmountIsCalculatedCorrectly();
            7:
                PurchOrderTests.TestTotalAmountIsCalculatedFromLines();
            8:
                PurchOrderTests.TestLinesAreLinkedToCorrectOrder();
            9:
                PurchOrderTests.TestDeleteHeaderDeletesLines();
            10:
                PurchOrderTests.TestVendorFieldsCanBeSet();
            11:
                PurchOrderTests.TestStatusCanBeChanged();
        end;
    end;

    local procedure ClearResults()
    begin
        TestsRun := 0;
        TestsPassed := 0;
        TestsFailed := 0;
        LastError := '';
        CurrPage.Update(false);
    end;

    local procedure GetTestResult(): Text
    begin
        if TestsFailed > 0 then
            exit('FAILED: ' + LastError);
        exit('PASSED');
    end;
}
