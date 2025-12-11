report 50126 "Purchase Order Grouped Report"
{
    Caption = 'Purchase Order Grouped';
    DefaultLayout = RDLC;
    RDLCLayout = './src/reports/PurchaseOrderGroupedReport.rdl';
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

            dataitem(PurchaseOrderLine; "Purchase Order Line")
            {
                DataItemLink = "Order No." = field("No.");
                DataItemTableView = sorting("Order No.", "Line No.");

                column(LineNo; "Line No.")
                {
                }
                column(Type; Type)
                {
                }
                column(ItemNo; "No.")
                {
                }
                column(Description; Description)
                {
                }
                column(Quantity; Quantity)
                {
                }
                column(UnitOfMeasure; "Unit of Measure")
                {
                }
                column(UnitPrice; "Unit Price")
                {
                }
                column(Amount; Amount)
                {
                }
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
        TypeLbl = 'Type';
        ItemNoLbl = 'Item No.';
        DescriptionLbl = 'Description';
        QuantityLbl = 'Quantity';
        UnitOfMeasureLbl = 'Unit';
        UnitPriceLbl = 'Unit Price';
        AmountLbl = 'Amount';
    }

    var
        ReportTitleLbl: Label 'Purchase Order';
}
