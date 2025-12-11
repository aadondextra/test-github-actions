report 50127 "Purchase Order Receipt Report"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultLayout = RDLC;
    RDLCLayout = './src/reports/PurchaseOrderReceiptReport.rdl';
    Caption = 'Purchase Order Receipt';
    EnableExternalImages = true;

    dataset
    {
        dataitem(PurchaseOrderHeader; "Purchase Order Header")
        {
            RequestFilterFields = "No.", "Vendor No.";

            column(CompanyName; CompanyInfo.Name)
            {
            }
            column(CompanyAddress; CompanyInfo.Address)
            {
            }
            column(CompanyAddress2; CompanyInfo."Address 2")
            {
            }
            column(CompanyCity; CompanyInfo.City)
            {
            }
            column(CompanyPostCode; CompanyInfo."Post Code")
            {

            }
            column(CompanyPhoneNo; CompanyInfo."Phone No.")
            {
            }
            column(CompanyEmail; CompanyInfo."E-Mail")
            {
            }
            column(CompanyPicture; CompanyInfo.Picture)
            {
            }

            column(DocumentNo; "No.")
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

            column(VendorNo; "Vendor No.")
            {
            }
            column(VendorName; "Vendor Name")
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
                column(No; "No.")
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


            trigger OnAfterGetRecord()
            begin
                CalcFields("Total Amount");
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(ShowInternalInfo; ShowInternalInfo)
                    {
                        ApplicationArea = All;
                        Caption = 'Show Internal Information';
                    }
                }
            }
        }
    }

    trigger OnPreReport()
    begin
        CompanyInfo.Get();
        CompanyInfo.CalcFields(Picture);
    end;

    var
        CompanyInfo: Record "Company Information";
        ShowInternalInfo: Boolean;
}