codeunit 7268940 "TCNFuncionesCommissionsCOMI"
{

    var
        rTCNCommissionsSetupCOMI: Record TCNCommissionsSetupCOMI;

    trigger OnRun()
    begin
    end;

    /// <summary>
    /// Devuelve el nombre de la app actual
    /// </summary>
    /// <returns>Return variable xSalida of type Text.</returns>
    procedure appNameF() xSalida: Text
    var
        xModuleInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(xModuleInfo);
        xSalida := xModuleInfo.Name();
    end;

    /*
    procedure FixCommissions()
    var
        rlSalesCrMemoLine: Record "Sales Cr.Memo Line";
        rlSalesInvoiceLine: Record "Sales Invoice Line";
        rlTCNCommissionsCOMI: Record TCNCommissionsCOMI;
    begin
        if rlTCNCommissionsCOMI.FindSet() then
            repeat
                if rlTCNCommissionsCOMI.TipoDocumento = rlTCNCommissionsCOMI.TipoDocumento::Invoice then begin
                    if rlSalesInvoiceLine.Get(rlTCNCommissionsCOMI.NoDocumento, rlTCNCommissionsCOMI.NoLinea) then begin
                        rlTCNCommissionsCOMI."Line Discount %" := rlSalesInvoiceLine."Line Discount %";
                        rlTCNCommissionsCOMI."Shortcut Dimension 1 Code" := rlSalesInvoiceLine."Shortcut Dimension 1 Code";
                    end;
                end else begin
                    if rlSalesCrMemoLine.Get(rlTCNCommissionsCOMI.NoDocumento, rlTCNCommissionsCOMI.NoLinea) then begin
                        rlTCNCommissionsCOMI."Line Discount %" := rlSalesCrMemoLine."Line Discount %";
                        rlTCNCommissionsCOMI."Shortcut Dimension 1 Code" := rlSalesCrMemoLine."Shortcut Dimension 1 Code";
                    end;
                end;
                rlTCNCommissionsCOMI.Modify(false);
            until rlTCNCommissionsCOMI.Next() = 0;
    end;
    */

    local procedure RegistrarComisionesGenericoF(pTipo: Option "Invoice","Cr.Memo";
        pNoDocumento: Code[20];
        pNoLinea: Integer;
        pItemNo: Code[20];
        pVarianteCode: Code[10];
        pQuantity: Decimal;
        pQuantityBase: Decimal;
        pUnitofMeasureCode: Code[10];
        pFechaRegistro: Date;
        pLineDiscountPct: Decimal;
        pCommissionBaseAmount: Decimal;
        pCodCliente: Code[20];
        pShortcutDimension1Code: Code[20];
        pShortcutDimension2Code: Code[20];
        pDimensionSetID: Integer;
        pCodVendedor: Code[20];
        pResponsibilityCenter: Code[10];
        pAmountLCY: Decimal;
        pAmount: Decimal;
        pCurrencyCode: Code[10];
        pCurrencyFactor: Decimal)
    var
        rlTCNCommissionsCOMI: Record TCNCommissionsCOMI;
        rlSalespersonPurchaser: Record "Salesperson/Purchaser";
    begin
        if rlSalespersonPurchaser.Get(pCodVendedor) then begin
            rlTCNCommissionsCOMI.Init();
            rlTCNCommissionsCOMI.Validate(TipoDocumento, pTipo);
            rlTCNCommissionsCOMI.Validate(NoDocumento, pNoDocumento);
            rlTCNCommissionsCOMI.Validate(NoLinea, pNoLinea);
            rlTCNCommissionsCOMI.Validate("Item No.", pItemNo);
            rlTCNCommissionsCOMI.Validate("Variant Code", pVarianteCode);
            rlTCNCommissionsCOMI.Validate(Quantity, pQuantity);
            rlTCNCommissionsCOMI.Validate("Quantity (Base)", pQuantityBase);
            rlTCNCommissionsCOMI.Validate("Unit of Measure Code", pUnitofMeasureCode);
            rlTCNCommissionsCOMI.Validate("Line discount %", pLineDiscountPct);
            rlTCNCommissionsCOMI.Validate("Commission Base Amount", pCommissionBaseAmount);
            rlTCNCommissionsCOMI.Validate("Amount LCY", pAmountLCY);
            rlTCNCommissionsCOMI.Validate(Amount, pAmount);
            rlTCNCommissionsCOMI.Validate("Currency Code", pCurrencyCode);
            rlTCNCommissionsCOMI.Validate("Currency Factor", pCurrencyFactor);
            rlTCNCommissionsCOMI.Validate(FechaRegistro, pFechaRegistro);
            rlTCNCommissionsCOMI.Validate(CodCliente, pCodCliente);
            rlTCNCommissionsCOMI.Validate(CodVendedor, pCodVendedor);
            rlTCNCommissionsCOMI.Validate("Responsibility Center", pResponsibilityCenter);
            rlTCNCommissionsCOMI.Validate("Shortcut Dimension 1 Code", pShortcutDimension1Code);
            rlTCNCommissionsCOMI.Validate("Shortcut Dimension 2 Code", pShortcutDimension2Code);
            rlTCNCommissionsCOMI.Validate("Dimension Set ID", pDimensionSetID);
            OnBeforeSetCommissionPct(rlSalespersonPurchaser, rlTCNCommissionsCOMI);
            rlTCNCommissionsCOMI.Validate("Commission %", rlSalespersonPurchaser."Commission %");
            rlTCNCommissionsCOMI.Insert(true);
        end;
    end;

    procedure RegistrarComisionesF(pSalesInvoiceLine: Record "Sales Invoice Line")
    var
        rlTCNCommissionsCOMI: Record TCNCommissionsCOMI;
        rlSalesInvoiceHeader: Record "Sales Invoice Header";
        xlLineAmount: Decimal;
        xlLineAmountLCY: Decimal;
        xlCommissionBaseAmount: Decimal;
        xlSalesLineType: Integer;
        xlTCNSalesLineTypeCOMI: Enum TCNSalesLineTypeCOMI;
    begin

        // se comprueba si la linea genera comision
        xlSalesLineType := pSalesInvoiceLine.Type;
        xlTCNSalesLineTypeCOMI := xlSalesLineType;
        if not HasCommissionF(xlTCNSalesLineTypeCOMI, pSalesInvoiceLine."No.", pSalesInvoiceLine.RecordId()) then
            exit;

        if rlSalesInvoiceHeader.Get(pSalesInvoiceLine."Document No.") then begin

            //Pasamos el importe de línea sin IVA, sin descuento de linea y sin transporte.
            xlLineAmount := pSalesInvoiceLine."Line Amount";
            xlLineAmountLCY := ConvertCommissionBaseAmountF(xlLineAmount, rlSalesInvoiceHeader."Currency Factor");
            xlCommissionBaseAmount := CalculateCommissionBaseAmountF(xlLineAmountLCY, pSalesInvoiceLine.RecordId(), rlSalesInvoiceHeader.RecordId());

            RegistrarComisionesGenericoF(rlTCNCommissionsCOMI.TipoDocumento::Invoice,
                pSalesInvoiceLine."Document No.",
                pSalesInvoiceLine."Line No.",
                pSalesInvoiceLine."No.",
                pSalesInvoiceLine."Variant Code",
                pSalesInvoiceLine.Quantity,
                pSalesInvoiceLine."Quantity (Base)",
                pSalesInvoiceLine."Unit of Measure Code",
                rlSalesInvoiceHeader."Posting Date",
                pSalesInvoiceLine."Line Discount %",
                xlCommissionBaseAmount,
                pSalesInvoiceLine."Sell-to Customer No.",
                pSalesInvoiceLine."Shortcut Dimension 1 Code",
                pSalesInvoiceLine."Shortcut Dimension 2 Code",
                pSalesInvoiceLine."Dimension Set ID",
                rlSalesInvoiceHeader."Salesperson Code",
                pSalesInvoiceLine."Responsibility Center",
                xlLineAmountLCY,
                xlLineAmount,
                rlSalesInvoiceHeader."Currency Code",
                rlSalesInvoiceHeader."Currency Factor");
        end;
    end;

    procedure RegistrarComisionesF(pSalesCrMemoLine: Record "Sales Cr.Memo Line")
    var
        rlTCNCommissionsCOMI: Record TCNCommissionsCOMI;
        rlSalesCrMemoHeader: Record "Sales Cr.Memo Header";
        xlLineAmount: Decimal;
        xlLineAmountLCY: Decimal;
        xlCommissionBaseAmount: Decimal;
        xlSalesLineType: Integer;
        xlTCNSalesLineTypeCOMI: Enum TCNSalesLineTypeCOMI;
    begin

        // se comprueba si la linea genera comision
        xlSalesLineType := pSalesCrMemoLine.Type;
        xlTCNSalesLineTypeCOMI := xlSalesLineType;
        if not HasCommissionF(xlTCNSalesLineTypeCOMI, pSalesCrMemoLine."No.", pSalesCrMemoLine.RecordId()) then
            exit;

        if rlSalesCrMemoHeader.Get(pSalesCrMemoLine."Document No.") then begin

            //Pasamos el importe de línea sin IVA, sin descuento de linea y sin transporte.
            xlLineAmount := -pSalesCrMemoLine."Line Amount";
            xlLineAmountLCY := ConvertCommissionBaseAmountF(xlLineAmount, rlSalesCrMemoHeader."Currency Factor");
            xlCommissionBaseAmount := CalculateCommissionBaseAmountF(xlLineAmountLCY, pSalesCrMemoLine.RecordId(), rlSalesCrMemoHeader.RecordId());

            RegistrarComisionesGenericoF(rlTCNCommissionsCOMI.TipoDocumento::"Cr.Memo",
                pSalesCrMemoLine."Document No.",
                pSalesCrMemoLine."Line No.",
                pSalesCrMemoLine."No.",
                pSalesCrMemoLine."Variant Code",
                pSalesCrMemoLine.Quantity,
                pSalesCrMemoLine."Quantity (Base)",
                pSalesCrMemoLine."Unit of Measure Code",
                rlSalesCrMemoHeader."Posting Date",
                pSalesCrMemoLine."Line Discount %",
                xlCommissionBaseAmount,
                pSalesCrMemoLine."Sell-to Customer No.",
                pSalesCrMemoLine."Shortcut Dimension 1 Code",
                pSalesCrMemoLine."Shortcut Dimension 2 Code",
                pSalesCrMemoLine."Dimension Set ID",
                rlSalesCrMemoHeader."Salesperson Code",
                pSalesCrMemoLine."Responsibility Center",
                xlLineAmountLCY,
                            xlLineAmount,
                rlSalesCrMemoHeader."Currency Code",
                rlSalesCrMemoHeader."Currency Factor");
        end;
    end;

    local procedure ConvertCommissionBaseAmountF(plAmount: Decimal; pCurrencyFactor: Decimal) xSalida: Decimal
    begin
        //Quitamos descuento de linea
        if pCurrencyFactor = 0 then
            pCurrencyFactor := 1;
        xSalida := plAmount / pCurrencyFactor;
    end;

    local procedure CalculateCommissionBaseAmountF(pAmountLCY: Decimal; pSalesLineRecordId: RecordId; pSalesHeaderRecordId: RecordId) xSalida: Decimal
    var
        IsHandled: Boolean;
    begin
        rTCNCommissionsSetupCOMI.GetF();

        OnBeforeCalculateCommissionBaseAmountF(pAmountLCY, pSalesLineRecordId, pSalesHeaderRecordId, xSalida, IsHandled);
        if IsHandled then
            exit;

        //Restamos el % de transporte a la línea
        if rTCNCommissionsSetupCOMI."Appl. Disc. Shipping Cost" then
            xSalida := Round((pAmountLCY * (100 - rTCNCommissionsSetupCOMI."Ship. Cost %") * 0.01), 0.01)
        else
            xSalida := Round((pAmountLCY), 0.01);

    end;

    local procedure HasCommissionF(pTipoLinea: Enum TCNSalesLineTypeCOMI; pNumero: Code[20]; pSalesLineRecordId: RecordId) xSalida: Boolean
    var
        rlItem: Record Item;
        IsHandled: Boolean;
    begin
        rTCNCommissionsSetupCOMI.GetF();

        OnBeforeHasCommissionF(pTipoLinea, pNumero, pSalesLineRecordId, xSalida, IsHandled);
        if IsHandled then
            exit;

        xSalida := true;

        // no debe ser linea de tipo cargo portes
        if (rTCNCommissionsSetupCOMI."Ship. Cost Line Type" = pTipoLinea) then begin
            if (rTCNCommissionsSetupCOMI."Ship. Cost Line No." = pNumero) then begin
                xSalida := false;
            end;
        end;

        // solo productos
        if pTipoLinea <> pTipoLinea::Item then
            xSalida := false;
        // solo productos que existen
        if not rlItem.Get(pNumero) then
            xSalida := false;
        // solo productos inventariables
        if rlItem.Type <> rlItem.Type::Inventory then
            xSalida := false;

    end;

    procedure ApplyComissions(var parComisiones: Record TCNCommissionsCOMI)
    var
        rlPurchaseHeader: Record "Purchase Header";
        rlPurchaseLine: Record "Purchase Line";
        rlSalesperson: Record "Salesperson/Purchaser";
        xVendorInvoiceNo: Code[35];
        ApplicationError: Label 'Liquidación erronea.';
        DocumentTypeError: Label 'Tipo documento erroneo.';
    begin
        if not (parComisiones.TipoDocumento in [parComisiones.TipoDocumento::Invoice, parComisiones.TipoDocumento::"Cr.Memo"]) then
            Error(DocumentTypeError);

        if parComisiones."Appl. Document Type" <> parComisiones."Appl. Document Type"::" " then
            Error(ApplicationError);

        if not rlSalesperson.Get(parComisiones.CodVendedor) then
            rlSalesperson.TestField(TCNVendorNoCOMI);

        rlSalesperson.TestField(TCNVendorNoCOMI);

        rTCNCommissionsSetupCOMI.GetF();
        rTCNCommissionsSetupCOMI.TestField("Appl. Account No.");

        parComisiones.VALIDATE("Application Date", WorkDate());
        parComisiones.VALIDATE(Applicated, TRUE);
        parComisiones.VALIDATE("Application User Name", UserId());

        rlPurchaseHeader.SETRANGE("Posting Date", parComisiones."Application Date");
        rlPurchaseHeader.SETRANGE("Buy-from Vendor No.", rlSalesperson.TCNVendorNoCOMI);
        IF NOT rlPurchaseHeader.FINDFIRST() THEN BEGIN
            rlPurchaseHeader.INIT();
            rlPurchaseHeader.VALIDATE("Document Type", rlPurchaseHeader."Document Type"::Invoice);
            /*
            IF parComisiones.TipoDocumento = parComisiones.TipoDocumento::Invoice THEN
                rlPurchaseHeader.VALIDATE("Document Type", rlPurchaseHeader."Document Type"::Invoice)
            ELSE
                IF parComisiones.TipoDocumento = parComisiones.TipoDocumento::"Cr.Memo" THEN
                    rlPurchaseHeader.VALIDATE("Document Type", rlPurchaseHeader."Document Type"::"Credit Memo")
                ELSE
                    ERROR(ApplicationError);
            */
            rlPurchaseHeader.VALIDATE("Posting Date", parComisiones."Application Date");
            rlPurchaseHeader.VALIDATE("Buy-from Vendor No.", rlSalesperson.TCNVendorNoCOMI);
            xVendorInvoiceNo := GetNextApplicacionInvoiceNo();
            if xVendorInvoiceNo <> '' then
                rlPurchaseHeader.VALIDATE("Vendor Invoice No.", xVendorInvoiceNo);
            rlPurchaseHeader.INSERT(TRUE);
        END;

        rlPurchaseLine.SETRANGE("Document Type", rlPurchaseHeader."Document Type");
        rlPurchaseLine.SETRANGE("Document No.", rlPurchaseHeader."No.");
        if not rlPurchaseLine.FindLast() then begin
            rlPurchaseLine.Init();
            rlPurchaseLine.Validate("Document Type", rlPurchaseLine."Document Type"::Invoice);
            rlPurchaseLine.Validate("Document No.", rlPurchaseHeader."No.");
            rlPurchaseLine.Validate(Type, rlPurchaseLine.Type::"G/L Account");
            rlPurchaseLine."Line No." := 10000;
            //rlPurchaseLine."Line No." += 10000;
            /*
            IF rlItem.GET(parComisiones."Item No.") THEN
                IF rlGeneralPostingSetup.GET(rlPurchaseHeader."Gen. Bus. Posting Group", rlItem."Gen. Prod. Posting Group") THEN
                    rlPurchaseLine.VALIDATE("No.", rlGeneralPostingSetup."Purch. Account");
            */
            rlPurchaseLine.Validate("No.", rTCNCommissionsSetupCOMI."Appl. Account No.");
            //rlPurchaseLine.Validate(Description, parComisiones.Description);
            rlPurchaseLine.Validate(Quantity, 1);
            rlPurchaseLine.Insert(true);
        end;
        rlPurchaseLine."Direct Unit Cost" += parComisiones."Commission Amount";
        rlPurchaseLine.Validate("Direct Unit Cost");
        /*
        CASE parComisiones.TipoDocumento OF
            parComisiones.TipoDocumento::Invoice:
                BEGIN
                    rlSalesInvoiceLine.GET(parComisiones.NoDocumento, parComisiones.NoLinea);
                    rlPurchaseLine.VALIDATE("Dimension Set ID", rlSalesInvoiceLine."Dimension Set ID");
                    rlPurchaseLine."Shortcut Dimension 1 Code" := rlSalesInvoiceLine."Shortcut Dimension 1 Code";
                    rlPurchaseLine."Shortcut Dimension 2 Code" := rlSalesInvoiceLine."Shortcut Dimension 2 Code";
                END;
            parComisiones.TipoDocumento::"Cr.Memo":
                BEGIN
                    rlSalesCrMemoLine.GET(parComisiones.NoDocumento, parComisiones.NoLinea);
                    rlPurchaseLine.VALIDATE("Dimension Set ID", rlSalesCrMemoLine."Dimension Set ID");
                    rlPurchaseLine."Shortcut Dimension 1 Code" := rlSalesCrMemoLine."Shortcut Dimension 1 Code";
                    rlPurchaseLine."Shortcut Dimension 2 Code" := rlSalesCrMemoLine."Shortcut Dimension 2 Code";
                END;
        END;
        */
        rlPurchaseLine.Modify(true);

        // Revisar el importe del documento por si es negativo y se tiene que cambiar a otro
        /*
        rlPurchaseHeader.CALCFIELDS(Amount);
        IF rlPurchaseHeader.Amount < 0 THEN
            ChangePurchaseDocumentType(rlPurchaseHeader, rlPurchaseLine);
        */

        CASE rlPurchaseHeader."Document Type" OF
            rlPurchaseHeader."Document Type"::Invoice:
                parComisiones."Appl. Document Type" := parComisiones."Appl. Document Type"::Invoice;
            rlPurchaseHeader."Document Type"::"Credit Memo":
                parComisiones."Appl. Document Type" := parComisiones."Appl. Document Type"::"Credit Memo";
        END;
        /*
            Realmente solo hacemos facturas, si sale negativo, se deja para otro mes...
        */
        parComisiones."Appl. Document No." := rlPurchaseHeader."No.";
        parComisiones."Appl. Document Line No." := rlPurchaseLine."Line No.";
        parComisiones.Applicated := true;
    end;

    procedure UnApplyComissions(var parComisiones: Record TCNCommissionsCOMI)
    var
        rlPurchaseHeader: Record "Purchase Header";
        rlPurchaseLine: Record "Purchase Line";
        bMissingHeader: Boolean;
        bMissingLine: Boolean;
        PostedApplication: Label 'Liquidación registrada.';
        ConfirmApplicationError: Label 'Liquidación erronea. ¿Desea continuar?';
        ApplicationError: Label 'Liquidación erronea.';
    begin
        IF parComisiones."Appl. Document Type" = parComisiones."Appl. Document Type"::" " THEN
            EXIT;

        IF parComisiones."Appl. Document Type" IN [parComisiones."Appl. Document Type"::"Posted Invoice", parComisiones."Appl. Document Type"::"Posted Credit Memo"] THEN
            ERROR(PostedApplication);

        bMissingHeader := FALSE;
        bMissingLine := FALSE;

        // busca cabecera
        IF parComisiones."Appl. Document Type" = parComisiones."Appl. Document Type"::Invoice THEN
            IF NOT rlPurchaseHeader.GET(rlPurchaseHeader."Document Type"::Invoice, parComisiones."Appl. Document No.") THEN BEGIN
                IF CONFIRM(ConfirmApplicationError) THEN
                    bMissingHeader := TRUE
                ELSE
                    ERROR(ApplicationError);
            END;

        IF parComisiones."Appl. Document Type" = parComisiones."Appl. Document Type"::"Credit Memo" THEN
            IF rlPurchaseHeader.GET(rlPurchaseHeader."Document Type"::"Credit Memo", parComisiones."Appl. Document No.") THEN BEGIN
                IF CONFIRM(ConfirmApplicationError) THEN
                    bMissingHeader := TRUE
                ELSE
                    ERROR(ApplicationError);
            END;

        // busca linea
        IF NOT bMissingHeader THEN
            IF NOT rlPurchaseLine.GET(rlPurchaseHeader."Document Type", rlPurchaseHeader."No.", parComisiones."Appl. Document Line No.") THEN BEGIN
                IF CONFIRM(ApplicationError) THEN
                    bMissingLine := TRUE
                ELSE
                    ERROR(ApplicationError);
            END;

        // Limpia liquidacion
        parComisiones."Appl. Document Type" := parComisiones."Appl. Document Type"::" ";
        parComisiones."Appl. Document No." := '';
        parComisiones."Appl. Document Line No." := 0;
        parComisiones."Application Date" := 0D;
        parComisiones."Application User Name" := '';
        parComisiones.Applicated := false;
        parComisiones.Modify(true);

        // eliminar linea
        if not bMissingHeader then
            if not bMissingLine then begin
                rlPurchaseLine."Direct Unit Cost" -= parComisiones."Commission Amount";
                if rlPurchaseLine."Direct Unit Cost" = 0 then
                    rlPurchaseLine.Delete(true)
                else begin
                    rlPurchaseLine.Validate("Direct Unit Cost");
                    rlPurchaseLine.Modify(true);
                end;
            end;

        // revisar si el documento tiene mas lineas
        if not bMissingHeader then begin
            rlPurchaseLine.SetRange("Document Type", rlPurchaseHeader."Document Type");
            rlPurchaseLine.SetRange("Document No.", rlPurchaseHeader."No.");
            if rlPurchaseLine.IsEmpty then
                rlPurchaseHeader.Delete(true);
        end;

    end;

    local procedure GetNextApplicacionInvoiceNo() xInvoiceNo: Code[20]
    var
        NoSeriesMgt: Codeunit NoSeriesManagement;
    //NoSeriesMgt: Codeunit "No. Series"; // BC24 
    begin
        rTCNCommissionsSetupCOMI.getF();
        if rTCNCommissionsSetupCOMI."Appl. Invoice Nos." <> '' then
            xInvoiceNo := NoSeriesMgt.GetNextNo(rTCNCommissionsSetupCOMI."Appl. Invoice Nos.", WorkDate(), true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSetCommissionPct(var prSalespersonPurchaser: Record "Salesperson/Purchaser"; var prTCNCommissionsCOMI: Record TCNCommissionsCOMI)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalculateCommissionBaseAmountF(pAmountLCY: Decimal; pSalesLineRecordId: RecordId; pSalesHeaderRecordId: RecordId; var pCommissionBaseAmount: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeHasCommissionF(pTipoLinea: Enum TCNSalesLineTypeCOMI; pNumero: Code[20]; pSalesLineRecordId: RecordId; var pHasCommission: Boolean; var IsHandled: Boolean)
    begin
    end;

}