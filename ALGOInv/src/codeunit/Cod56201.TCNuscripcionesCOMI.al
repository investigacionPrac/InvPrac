codeunit 56201 "TCNuscripcionesCOMI"
{
    SingleInstance = true;

    var
        cuTCNFuncionesCommissionsCOMI: Codeunit TCNFuncionesCommissionsCOMI;
        cuTCNSICommissionsCOMI: Codeunit TCNSICommissionsCOMI;

    [EventSubscriber(ObjectType::Table, Database::"Sales Cr.Memo Line", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnAfterInsertEventTableSalesCrMemoLineF(Rec: Record "Sales Cr.Memo Line")
    begin
        //cuTCNFuncionesCommissionsCOMI.RegistrarComisionesF(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Invoice Line", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnAfterInsertEventTableSalesInvoiceLineF(Rec: Record "Sales Invoice Line")
    begin
        //cuTCNFuncionesCommissionsCOMI.RegistrarComisionesF(Rec);
    end;

    //[EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterPostPurchLines', '', false, false)]
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterProcessPurchLines', '', false, false)] // BC240
    local procedure OnAfterProcessPurchLinesCodeunitPurchPostF(var PurchHeader: Record "Purchase Header"; var PurchRcptHeader: Record "Purch. Rcpt. Header"; var PurchInvHeader: Record "Purch. Inv. Header"; var PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr."; var ReturnShipmentHeader: Record "Return Shipment Header"; WhseShip: Boolean; WhseReceive: Boolean; var PurchLinesProcessed: Boolean; CommitIsSuppressed: Boolean; EverythingInvoiced: Boolean)
    var
        rlPurchCrMemoLine: Record "Purch. Cr. Memo Line";
        rlPurchInvLine: Record "Purch. Inv. Line";
        rlComisiones: Record TCNCommissionsCOMI;
    begin
        if PurchHeader.IsTemporary then
            exit;

        if not (PurchHeader."Document Type" in [PurchHeader."Document Type"::Invoice, PurchHeader."Document Type"::"Credit Memo"]) then
            exit;

        case PurchHeader."Document Type" of
            PurchHeader."Document Type"::Invoice:
                begin
                    rlComisiones.SETRANGE("Appl. Document Type", rlComisiones."Appl. Document Type"::Invoice);
                    rlComisiones.SETRANGE("Appl. Document No.", PurchHeader."No.");
                    if rlComisiones.FINDSET(false) then
                        repeat
                            if rlPurchInvLine.GET(PurchInvHeader."No.", rlComisiones."Appl. Document Line No.") then begin
                                rlComisiones."Appl. Document Type" := rlComisiones."Appl. Document Type"::"Posted Invoice";
                                rlComisiones."Appl. Document No." := PurchInvHeader."No.";
                                rlComisiones.VALIDATE("Posted Application", TRUE);
                                rlComisiones.MODIFY(TRUE);
                            end;
                        until rlComisiones.NEXT() = 0;
                end;
            PurchHeader."Document Type"::"Credit Memo":
                begin
                    rlComisiones.SETRANGE("Appl. Document Type", rlComisiones."Appl. Document Type"::"Credit Memo");
                    rlComisiones.SETRANGE("Appl. Document No.", PurchHeader."No.");
                    if rlComisiones.FINDSET(false) then
                        repeat
                            if rlPurchCrMemoLine.GET(PurchCrMemoHdr."No.", rlComisiones."Appl. Document Line No.") then begin
                                rlComisiones."Appl. Document Type" := rlComisiones."Appl. Document Type"::"Posted Credit Memo";
                                rlComisiones."Appl. Document No." := PurchCrMemoHdr."No.";
                                rlComisiones.VALIDATE("Posted Application", TRUE);
                                rlComisiones.MODIFY(TRUE);
                            end;
                        until rlComisiones.NEXT() = 0;
                end;
        end;
    end;

    /*
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesLine', '', false, false)]
    local procedure OnAfterPostSalesLineCodeunitSalesPostF(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; CommitIsSuppressed: Boolean; var SalesInvLine: Record "Sales Invoice Line"; var SalesCrMemoLine: Record "Sales Cr.Memo Line"; var xSalesLine: Record "Sales Line")
    begin
        if SalesHeader."Document Type" in [SalesHeader."Document Type"::Order, SalesHeader."Document Type"::Invoice] then
            cuTCNFuncionesCommissionsCOMI.RegistrarComisionesF(SalesInvLine);
        if SalesHeader."Document Type" in [SalesHeader."Document Type"::"Return Order", SalesHeader."Document Type"::"Credit Memo"] then
            cuTCNFuncionesCommissionsCOMI.RegistrarComisionesF(SalesCrMemoLine);
    end;
    */

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterSalesInvLineInsert', '', false, false)]
    local procedure OnAfterSalesInvLineInsertCodeunitSalesPostF(VAR SalesInvLine: Record "Sales Invoice Line"; SalesInvHeader: Record "Sales Invoice Header"; SalesLine: Record "Sales Line"; ItemLedgShptEntryNo: Integer; WhseShip: Boolean; WhseReceive: Boolean; CommitIsSuppressed: Boolean; VAR SalesHeader: Record "Sales Header"; VAR TempItemChargeAssgntSales: Record "Item Charge Assignment (Sales)")
    begin
        cuTCNFuncionesCommissionsCOMI.RegistrarComisionesF(SalesInvLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterSalesCrMemoLineInsert', '', false, false)]
    local procedure OnAfterSalesCrMemoLineInsertCodeunitSalesPostF(VAR SalesCrMemoLine: Record "Sales Cr.Memo Line"; SalesCrMemoHeader: Record "Sales Cr.Memo Header"; VAR SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line"; VAR TempItemChargeAssgntSales: Record "Item Charge Assignment (Sales)"; CommitIsSuppressed: Boolean)
    begin
        cuTCNFuncionesCommissionsCOMI.RegistrarComisionesF(SalesCrMemoLine);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure OnBeforeDeleteEventDatabasePurchLinesF(var Rec: Record "Purchase Line"; RunTrigger: Boolean)
    var
        rlComisiones: Record TCNCommissionsCOMI;
    begin
        if Rec.IsTemporary then
            exit;

        if cuTCNSICommissionsCOMI.postingInvoice() then
            exit;

        if not (Rec."Document Type" in [Rec."Document Type"::Invoice, Rec."Document Type"::"Credit Memo"]) then
            exit;

        case Rec."Document Type" of
            Rec."Document Type"::Invoice:
                begin
                    rlComisiones.SETRANGE("Appl. Document Type", rlComisiones."Appl. Document Type"::Invoice);
                    rlComisiones.SETRANGE("Appl. Document No.", Rec."Document No.");
                    if rlComisiones.FindFirst() then
                        rlComisiones.TestField("Appl. Document No.", '');
                end;
            Rec."Document Type"::"Credit Memo":
                begin
                    rlComisiones.SETRANGE("Appl. Document Type", rlComisiones."Appl. Document Type"::"Credit Memo");
                    rlComisiones.SETRANGE("Appl. Document No.", Rec."Document No.");
                    if rlComisiones.FindFirst() then
                        rlComisiones.TestField("Appl. Document No.", '');
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, codeunit::"Purch.-Post", 'OnBeforePurchLineDeleteAll', '', false, false)]
    //local procedure codeunitPurchPostOnBeforePurchLineDeleteAll(var PurchaseLine: Record "Purchase Line"; CommitIsSupressed: Boolean; var TempPurchLine: Record "Purchase Line" temporary)
    local procedure codeunitPurchPostOnBeforePurchLineDeleteAll(var PurchaseLine: Record "Purchase Line"; CommitIsSupressed: Boolean)
    var
        rlPurchaseLine: Record "Purchase Line";
    begin
        //cuTCNSICommissionsCOMI.postingInvoice(TempPurchLine."Document Type" = TempPurchLine."Document Type"::Invoice);
        rlPurchaseLine.SetRange("Document Type", rlPurchaseLine."Document Type"::Invoice);
        cuTCNSICommissionsCOMI.postingInvoice(rlPurchaseLine.GetFilter("Document Type") = PurchaseLine.GetFilter("Document Type"));
    end;

}