codeunit 50136 "PO Installation"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        CreateNumberSeries();
    end;

    local procedure CreateNumberSeries()
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        // Create No. Series if it doesn't exist
        if not NoSeries.Get('PO-ORDER') then begin
            NoSeries.Init();
            NoSeries.Code := 'PO-ORDER';
            NoSeries.Description := 'Purchase Orders';
            NoSeries."Default Nos." := true;
            NoSeries."Manual Nos." := false;
            if NoSeries.Insert() then;
        end;

        // Create No. Series Line if it doesn't exist
        NoSeriesLine.SetRange("Series Code", 'PO-ORDER');
        if not NoSeriesLine.FindFirst() then begin
            NoSeriesLine.Init();
            NoSeriesLine."Series Code" := 'PO-ORDER';
            NoSeriesLine."Line No." := 10000;
            NoSeriesLine."Starting No." := 'PO-00001';
            NoSeriesLine."Ending No." := 'PO-99999';
            NoSeriesLine."Increment-by No." := 1;
            if NoSeriesLine.Insert() then;
        end;
    end;
}
