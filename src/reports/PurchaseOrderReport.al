report 50125 "Purchase Order Report"
{
    Caption = 'Purchase Order';
    DefaultLayout = RDLC;
    RDLCLayout = './src/reports/PurchaseOrderReport.rdl';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;

    dataset
    {
        dataitem(PurchaseOrderHeader; "Purchase Order Header")
        {
            RequestFilterFields = "No.", "Vendor No.", Status;

            column(CompanyName; CompanyProperty.DisplayName())
            {
            }
            column(ReportTitle; ReportTitleLbl)
            {
            }
            column(No_; "No.")
            {
            }
            column(VendorNo; "Vendor No.")
            {
            }
            column(VendorName; "Vendor Name")
            {
            }
            column(OrderDate; "Order Date")
            {
            }
            column(ExpectedReceiptDate; "Expected Receipt Date")
            {
            }
            column(Status; Status)
            {
            }
            column(TotalAmount; "Total Amount")
            {
            }
        }
    }

    labels
    {
        OrderNoLbl = 'Order No.';
        VendorNoLbl = 'Vendor No.';
        VendorNameLbl = 'Vendor Name';
        OrderDateLbl = 'Order Date';
        ExpectedReceiptDateLbl = 'Expected Receipt Date';
        StatusLbl = 'Status';
        TotalAmountLbl = 'Total Amount';
    }

    var
        ReportTitleLbl: Label 'Purchase Order';
}
