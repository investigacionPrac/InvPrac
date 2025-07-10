report 56200 "TCNSalespersonCommissionCOMI"
{
    DefaultLayout = RDLC;
    RDLCLayout = './layouts/SalespersonCommission.rdl';
    ApplicationArea = Suite;
    Caption = 'Salesperson - Commission';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Salesperson/Purchaser"; "Salesperson/Purchaser")
        {
            DataItemTableView = SORTING(Code);
            PrintOnlyIfDetail = true;
            RequestFilterFields = "Code";
            column(STRSUBSTNO_Text000_PeriodText_; StrSubstNo(Text000, PeriodText))
            {
            }
            column(COMPANYNAME; COMPANYPROPERTY.DisplayName())
            {
            }
            column(Salesperson_Purchaser__TABLECAPTION__________SalespersonFilter; TableCaption + ': ' + SalespersonFilter)
            {
            }
            column(SalespersonFilter; SalespersonFilter)
            {
            }
            column(Cust__Ledger_Entry__TABLECAPTION__________CustLedgEntryFilter; "Cust. Ledger Entry".TableCaption + ': ' + CustLedgEntryFilter)
            {
            }
            column(CustLedgEntryFilter; CustLedgEntryFilter)
            {
            }
            column(PageGroupNo; PageGroupNo)
            {
            }
            column(Salesperson_Purchaser_Code; Code)
            {
            }
            column(Salesperson_Purchaser_Name; Name)
            {
            }
            column(Salesperson_Purchaser__Commission___; "Commission %")
            {
            }
            column(Cust__Ledger_Entry___Sales__LCY__; "Cust. Ledger Entry"."Sales (LCY)")
            {
            }
            column(Cust__Ledger_Entry___Profit__LCY__; "Cust. Ledger Entry"."Profit (LCY)")
            {
            }
            column(SalesCommissionAmt; SalesCommissionAmt)
            {
                AutoFormatType = 1;
            }
            column(ProfitCommissionAmt; ProfitCommissionAmt)
            {
                AutoFormatType = 1;
            }
            column(AdjProfit; AdjProfit)
            {
                AutoFormatType = 1;
            }
            column(AdjProfitCommissionAmt; AdjProfitCommissionAmt)
            {
                AutoFormatType = 1;
            }
            column(Salesperson___CommissionCaption; Salesperson___CommissionCaptionLbl)
            {
            }
            column(CurrReport_PAGENOCaption; CurrReport_PAGENOCaptionLbl)
            {
            }
            column(All_amounts_are_in_LCYCaption; All_amounts_are_in_LCYCaptionLbl)
            {
            }
            column(Cust__Ledger_Entry__Posting_Date_Caption; Cust__Ledger_Entry__Posting_Date_CaptionLbl)
            {
            }
            column(Cust__Ledger_Entry__Document_No__Caption; "Cust. Ledger Entry".FieldCaption("Document No."))
            {
            }
            column(Cust__Ledger_Entry__Customer_No__Caption; "Cust. Ledger Entry".FieldCaption("Customer No."))
            {
            }
            column(Cust__Ledger_Entry__Sales__LCY__Caption; "Cust. Ledger Entry".FieldCaption("Sales (LCY)"))
            {
            }
            column(Cust__Ledger_Entry__Profit__LCY__Caption; "Cust. Ledger Entry".FieldCaption("Profit (LCY)"))
            {
            }
            column(SalesCommissionAmt_Control32Caption; SalesCommissionAmt_Control32CaptionLbl)
            {
            }
            column(ProfitCommissionAmt_Control33Caption; ProfitCommissionAmt_Control33CaptionLbl)
            {
            }
            column(AdjProfit_Control39Caption; AdjProfit_Control39CaptionLbl)
            {
            }
            column(AdjProfitCommissionAmt_Control45Caption; AdjProfitCommissionAmt_Control45CaptionLbl)
            {
            }
            column(Salesperson_Purchaser__Commission___Caption; FieldCaption("Commission %"))
            {
            }
            column(TotalCaption; TotalCaptionLbl)
            {
            }
            dataitem("Cust. Ledger Entry"; "Cust. Ledger Entry")
            {
                DataItemLink = "Salesperson Code" = FIELD(Code);
                DataItemTableView = SORTING("Salesperson Code", "Posting Date") WHERE("Document Type" = FILTER(Invoice | "Credit Memo"));
                RequestFilterFields = "Posting Date";
                column(Cust__Ledger_Entry__Posting_Date_; Format("Posting Date"))
                {
                }
                column(Cust__Ledger_Entry__Document_No__; "Document No.")
                {
                }
                column(Cust__Ledger_Entry__Customer_No__; "Customer No.")
                {
                }
                column(Cust__Ledger_Entry__Sales__LCY__; "Sales (LCY)")
                {
                }
                column(Cust__Ledger_Entry__Profit__LCY__; "Profit (LCY)")
                {
                }
                column(SalesCommissionAmt_Control32; SalesCommissionAmt)
                {
                    AutoFormatType = 1;
                }
                column(ProfitCommissionAmt_Control33; ProfitCommissionAmt)
                {
                    AutoFormatType = 1;
                }
                column(AdjProfit_Control39; AdjProfit)
                {
                    AutoFormatType = 1;
                }
                column(AdjProfitCommissionAmt_Control45; AdjProfitCommissionAmt)
                {
                    AutoFormatType = 1;
                }
                column(Salesperson_Purchaser__Name; "Salesperson/Purchaser".Name)
                {
                }
                column(Cust__Ledger_Entry__Customer_Name; "Customer Name")
                {
                }
                column(Cust__Ledger_Entry__Customer_NameCaption; FieldCaption("Customer Name"))
                {
                }
                column(Cust__Ledger_Entry__Customer_GloblaDimensionCodeCaption; FieldCaption("Global Dimension 1 Code"))
                {
                }
                column(Global_Dimension_1_Code; "Global Dimension 1 Code")
                {
                }

                trigger OnAfterGetRecord()
                var
                    rlComisiones: Record TCNCommissionsCOMI;
                // CostCalcMgt: Codeunit "Cost Calculation Management";
                begin
                    //SalesCommissionAmt := Round("Sales (LCY)" * "Salesperson/Purchaser"."Commission %" / 100);
                    //ProfitCommissionAmt := Round("Profit (LCY)" * "Salesperson/Purchaser"."Commission %" / 100);
                    //AdjProfit := "Sales (LCY)" + CostCalcMgt.CalcCustLedgActualCostLCY("Cust. Ledger Entry");
                    //AdjProfitCommissionAmt := Round(AdjProfit * "Salesperson/Purchaser"."Commission %" / 100);
                    rlComisiones.SetRange(NoDocumento, "Cust. Ledger Entry"."Document No.");
                    rlComisiones.CalcSums("Commission Amount", "Commission Base Amount");
                    SalesCommissionAmt := rlComisiones."Commission Amount";
                    "Cust. Ledger Entry"."Sales (LCY)" := rlComisiones."Commission Base Amount";
                end;

                trigger OnPreDataItem()
                begin
                    ClearAmounts();
                end;
            }

            trigger OnAfterGetRecord()
            begin
                if xPrintOnlyOnePerPage then
                    PageGroupNo := PageGroupNo + 1;
            end;

            trigger OnPreDataItem()
            begin
                PageGroupNo := 1;
                ClearAmounts();
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(PrintOnlyOnePerPage; xPrintOnlyOnePerPage)
                    {
                        ApplicationArea = Suite;
                        Caption = 'New Page per Person';
                        ToolTip = 'Specifies if each person''s information is printed on a new page if you have chosen two or more persons to be included in the report.';
                    }
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnPreReport()
    begin
        /*
        if rCustLedgerEntry.MarkedOnly then begin
            if rCustLedgerEntry.FindSet() then
                repeat
                    "Cust. Ledger Entry"."Entry No." := rCustLedgerEntry."Entry No.";
                    "Cust. Ledger Entry".Mark(true);
                until rCustLedgerEntry.Next() = 0;
            "Cust. Ledger Entry".MarkedOnly(true);
        end;
        if rSalesperson.GetFilters <> '' then
            "Salesperson/Purchaser".CopyFilters(rSalesperson);
        */
        /*
        if xCustomerNoFilter <> '' then
            "Cust. Ledger Entry".SetFilter("Entry No.", xCustomerNoFilter);
        */

        SalespersonFilter := "Salesperson/Purchaser".GetFilters;
        CustLedgEntryFilter := "Cust. Ledger Entry".GetFilters;
        PeriodText := "Cust. Ledger Entry".GetFilter("Posting Date");
    end;

    var
        rCustLedgerEntry: Record "Cust. Ledger Entry";
        rSalesperson: Record "Salesperson/Purchaser";
        xPrintOnlyOnePerPage: Boolean;
        AdjProfit: Decimal;
        AdjProfitCommissionAmt: Decimal;
        ProfitCommissionAmt: Decimal;
        SalesCommissionAmt: Decimal;
        PageGroupNo: Integer;
        AdjProfit_Control39CaptionLbl: Label 'Adjusted Profit (LCY)';
        AdjProfitCommissionAmt_Control45CaptionLbl: Label 'Adjusted Profit Commission (LCY)';
        All_amounts_are_in_LCYCaptionLbl: Label 'All amounts are in LCY';
        CurrReport_PAGENOCaptionLbl: Label 'Page';
        Text000: Label 'Period: %1';
        Cust__Ledger_Entry__Posting_Date_CaptionLbl: Label 'Posting Date';
        ProfitCommissionAmt_Control33CaptionLbl: Label 'Profit Commission (LCY)';
        SalesCommissionAmt_Control32CaptionLbl: Label 'Sales Commission (LCY)';
        Salesperson___CommissionCaptionLbl: Label 'Salesperson - Commission';
        TotalCaptionLbl: Label 'Total';
        CustLedgEntryFilter: Text;
        PeriodText: Text;
        SalespersonFilter: Text;
        xCustomerNoFilter: Text;

    local procedure ClearAmounts()
    begin
        Clear(AdjProfit);
        Clear(ProfitCommissionAmt);
        Clear(AdjProfitCommissionAmt);
        Clear(SalesCommissionAmt);
    end;

    procedure SetFilter(var parComisiones: Record TCNCommissionsCOMI)
    var
    begin
        rCustLedgerEntry.Reset();
        rSalesperson.Reset();

        rCustLedgerEntry.SetFilter("Document Type", '%1|%2', "Cust. Ledger Entry"."Document Type"::Invoice, "Cust. Ledger Entry"."Document Type"::"Credit Memo");
        if parComisiones.FindSet() then
            repeat
                rCustLedgerEntry.SetRange("Document No.", parComisiones.NoDocumento);
                if rCustLedgerEntry.FindFirst() then begin
                    rCustLedgerEntry.Mark(true);
                    if xCustomerNoFilter <> '' then
                        xCustomerNoFilter := xCustomerNoFilter + '|' + Format(rCustLedgerEntry."Entry No.")
                    else
                        xCustomerNoFilter := Format(rCustLedgerEntry."Entry No.")
                end;
            until parComisiones.Next() = 0;
        rCustLedgerEntry.SetRange("Document No.");
        rCustLedgerEntry.MarkedOnly(true);

        if parComisiones.GetFilter(CodVendedor) <> '' then
            parComisiones.CopyFilter(CodVendedor, rSalesperson.Code);
        if parComisiones.GetFilter(FechaRegistro) <> '' then
            parComisiones.CopyFilter(FechaRegistro, rSalesperson."Date Filter");
    end;
}

