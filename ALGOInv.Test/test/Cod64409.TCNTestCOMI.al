#if SaaS
codeunit 64409 TCNTestCOMI
#else
codeunit 7268949 TCNTestCOMI
#endif
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    var
        //LibraryRandom: Codeunit "Library - Random";
        //LibraryERM: Codeunit "Library - ERM";
        //LibraryPurchase: Codeunit "Library - Purchase";
        //LibraryInventory: Codeunit "Library - Inventory";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        //LibraryTestInitialize: Codeunit "Library - Test Initialize";
        Assert: Codeunit "Library Assert";
        IsInitialized: Boolean;

    [Test]
    procedure CheckSalespersonVendorNoField()
    var
        Salesperson: Record "Salesperson/Purchaser";
        Vendor: Record Vendor;
        ShouldBeMsg: Label 'Should be Vendor No.';
    begin
        // [Feature] [Salesperson Vendor No.]
        // [Scenario 01] Can select Vendor No.
        //Initialize(false, 0, '');

        // [Given] Salesperson record with an empty Vendor No.
        GetFirstSalesperson(Salesperson, true);

        // [Given] A Vendor
        GetFirstVendor(Vendor);

        // [When] Vendor No. value provided
        AddVendorNo(Salesperson, Vendor."No.");

        // [Then] Vendor No. should be Vendor."No."
        Assert.IsTrue(VerifyVendorNo(Salesperson, Vendor."No."), ShouldBeMsg);
    end;


    [HandlerFunctions('ConfirmCloseSalesInvoiceHandler')]
    [Test]
    procedure GetSalesInvoice()
    var
        Salesperson: Record "Salesperson/Purchaser";
        Customer: Record Customer;
        Item: Record Item;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        // [Feature] [Posting Invoice register Commission]
        // [Scenario 02] Create Sales Invoice 
        //Initialize(true, 0, '');

        // [Given] Salesperson record with an empty Vendor No.
        GetFirstSalesperson(Salesperson, false);

        // [Given] A Customer
        GetFirstCustomer(Customer, false);

        // [Given] A Item
        GetFirstItem(Item);

        // [Given] New Sales Invoice 
        GetNewSalesInvoice(Customer, Salesperson, Item, SalesHeader, SalesLine);

        // [When] Page of Sales Invoice 
        TestGetSalesInvoice(SalesHeader);

        // [Then] Solo pasar al siguiente test
        Assert.IsTrue(true, '');
    end;

    // [Test]
    // [HandlerFunctions('ConfirmPostHandler')]
    // procedure PostSalesInvoice()
    // var
    //     Salesperson: Record "Salesperson/Purchaser";
    //     Customer: Record Customer;
    //     Item: Record Item;
    //     SalesHeader: Record "Sales Header";
    //     SalesLine: Record "Sales Line";
    //     ShipCost: Decimal;
    //     ApplAccountNo: Code[20];
    //     InvoiceNo: Code[20];
    //     ShouldHaveMsg: Label 'Should have Commission registered';
    // begin
    //     // [Feature] [Posting Invoice register Commission]
    //     // [Scenario 03] Posting Sales Invoice register Commission
    //     ShipCost := 2;
    //     ApplAccountNo := '6290001'; // OJO solo versión ES
    //     Initialize(true, ShipCost, ApplAccountNo);

    //     // [Given] Salesperson record with an empty Vendor No.
    //     GetFirstSalesperson(Salesperson, false);

    //     // [Given] A Customer
    //     GetFirstCustomer(Customer, false);

    //     // [Given] A Item
    //     GetFirstItem(Item);

    //     // [Given] New Sales Invoice 
    //     GetNewSalesInvoice(Customer, Salesperson, Item, SalesHeader, SalesLine);

    //     // [When] Sales Invoice is posted
    //     TestPostSalesInvoice(SalesHeader, InvoiceNo);

    //     // [Then] Salesperson should have Commission
    //     Assert.IsTrue(VerifySalespersonCommission(Salesperson, InvoiceNo), ShouldHaveMsg);
    // end;

    // [Test]
    // [HandlerFunctions('ConfirmPostHandler')]
    // procedure PostSalesInvoiceCalcCommission()
    // var
    //     Salesperson: Record "Salesperson/Purchaser";
    //     Customer: Record Customer;
    //     Item: Record Item;
    //     SalesHeader: Record "Sales Header";
    //     SalesLine: Record "Sales Line";
    //     ShipCost: Decimal;
    //     ApplAccountNo: Code[20];
    //     InvoiceNo: Code[20];
    //     CommissionAmout: Decimal;
    //     ShouldHaveMsg: Label 'Should have Commission Amount Correct';
    // begin
    //     // [Feature] [Posting Invoice register Commission]
    //     // [Scenario 04] Posting Sales Invoice register Commission correctly
    //     ShipCost := 2;
    //     ApplAccountNo := '6290001'; // OJO solo versión ES
    //     Initialize(true, ShipCost, ApplAccountNo);

    //     // [Given] Salesperson record with an empty Vendor No.
    //     GetFirstSalesperson(Salesperson, false);

    //     // [Given] A Customer
    //     GetFirstCustomer(Customer, false);

    //     // [Given] A Item
    //     GetFirstItem(Item);

    //     // [Given] New Sales Invoice 
    //     GetNewSalesInvoice(Customer, Salesperson, Item, SalesHeader, SalesLine);
    //     SalesLine.CalcSums("Line Amount");
    //     CommissionAmout := SalesLine."Line Amount" * (100 - ShipCost) / 100 * Salesperson."Commission %" / 100;

    //     // [When] Sales Invoice is posted
    //     TestPostSalesInvoice(SalesHeader, InvoiceNo);

    //     // [Then] Salesperson should have Commission
    //     Assert.IsTrue(VerifySalespersonCommissionCorrect(Salesperson, InvoiceNo, CommissionAmout), ShouldHaveMsg);
    // end;


    // funciones de apoyo

    procedure Initialize(ShipCostPct: Boolean; ShipCost: Decimal; ApplAccountNo: Code[20])
    var
        TCNCommissionsSetupCOMI: Record TCNCommissionsSetupCOMI;
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
    begin
        //LibraryTestInitialize.OnTestInitialize(CODEUNIT::TCNTestCOMI);

        LibraryVariableStorage.Clear();

        /*
        BankAccReconciliation.DeleteAll(true);
        BankAccReconciliationLine.DeleteAll(true);
        AppliedPaymentEntry.DeleteAll(true);
        CloseExistingEntries();

        GeneralLedgerSetup.Get();
        Evaluate(GeneralLedgerSetup."Payment Discount Grace Period", '<0D>');
        GeneralLedgerSetup.Modify();
        */

        if IsInitialized then
            exit;

        //LibraryTestInitialize.OnBeforeTestSuiteInitialize(CODEUNIT::TCNTestCOMI);
        /*
        LibraryERMCountryData.CreateVATData();
        LibraryERMCountryData.UpdateGeneralLedgerSetup();
        LibraryERMCountryData.UpdateGeneralPostingSetup();
        LibraryERMCountryData.UpdatePurchasesPayablesSetup();
        LibraryInventory.NoSeriesSetup(InventorySetup);
        LibraryERM.FindZeroVATPostingSetup(ZeroVATPostingSetup, ZeroVATPostingSetup."VAT Calculation Type"::"Normal VAT");
        */
        TCNCommissionsSetupCOMI.getF();
        if ShipCostPct then
            TCNCommissionsSetupCOMI.Validate("Ship. Cost %", ShipCost);
        if ShipCostPct then
            TCNCommissionsSetupCOMI.Validate("Appl. Disc. Shipping Cost", true);
        if ApplAccountNo <> '' then
            TCNCommissionsSetupCOMI.Validate("Appl. Account No.", ApplAccountNo);
        if PurchasesPayablesSetup.Get() then
            TCNCommissionsSetupCOMI.Validate("Appl. Invoice Nos.", PurchasesPayablesSetup."Invoice Nos.");
        TCNCommissionsSetupCOMI.Modify();
        Commit();
        IsInitialized := true;
        //LibraryTestInitialize.OnAfterTestSuiteInitialize(CODEUNIT::TCNTestCOMI);

    end;

    procedure GetFirstCustomer(var Customer: Record Customer; HasCurrency: Boolean)
    begin
        Customer.SetRange(Blocked, Customer.Blocked::" ");
        if HasCurrency then
            Customer.SetFilter("Currency Code", '<>%1', '')
        else
            Customer.SetRange("Currency Code", '');
        Customer.FindFirst();
    end;

    procedure GetFirstItem(var Item: Record Item)
    begin
        Item.SetRange(Blocked, false);
        Item.SetRange("Sales Blocked", false);
        Item.FindFirst();
    end;

    procedure GetFirstSalesperson(var Salesperson: Record "Salesperson/Purchaser"; EmptyVendorNo: Boolean)
    begin
        Salesperson.SetRange(Blocked, false);
        Salesperson.SetFilter("Commission %", '<>%1', 0);
        if EmptyVendorNo then
            Salesperson.SetRange(TCNVendorNoCOMI, '');
        Salesperson.FindFirst();
    end;

    procedure GetFirstVendor(var Vendor: Record Vendor)
    begin
        Vendor.FindFirst();
    end;


    // Funciones de prueba

    procedure AddVendorNo(var Salesperson: Record "Salesperson/Purchaser"; VendorNo: Code[20])
    begin
        Salesperson.Validate(TCNVendorNoCOMI, VendorNo);
    end;

    procedure GetNewSalesInvoice(Customer: Record Customer; Salesperson: Record "Salesperson/Purchaser"; Item: Record Item; var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    var
    begin
        // Cabecera factura
        SalesHeader."Document Type" := SalesHeader."Document Type"::Invoice;
        SalesHeader."Sell-to Customer No." := Customer."No.";
        SalesHeader.InitRecord();
        SalesHeader.Validate("Sell-to Customer No.");
        SalesHeader.Validate("Salesperson Code", Salesperson.Code);
        SalesHeader.Validate(Ship, true);
        SalesHeader.Validate(Invoice, true);
        SalesHeader.Insert(true);

        // Linea factura
        SalesLine.Validate("Document Type", SalesHeader."Document Type");
        SalesLine.Validate("Document No.", SalesHeader."No.");
        SalesLine.Validate("Line No.", 10000);
        SalesLine.InitHeaderDefaults(SalesHeader);
        SalesLine.Validate(Type, SalesLine.Type::Item);
        SalesLine.Validate("No.", Item."No.");
        SalesLine.Validate(Quantity, 1);
        SalesLine.Validate("Line Discount %", 3);
        SalesLine.Insert(true);

        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
    end;

    procedure TestGetSalesInvoice(SalesHeader: Record "Sales Header")
    var
        SalesInvoice: TestPage "Sales Invoice";
    begin
        SalesInvoice.OpenView();
        SalesInvoice.GoToRecord(SalesHeader);
        SalesInvoice.Close();
    end;

    procedure TestPostSalesInvoice(SalesHeader: Record "Sales Header"; var InvoiceNo: Code[20])
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoice: TestPage "Sales Invoice";
    begin

        SalesInvoice.OpenView();
        SalesInvoice.GoToRecord(SalesHeader);
        SalesInvoice.Post.Invoke();

        SalesInvoiceHeader.SetRange("Pre-Assigned No.", SalesHeader."No.");
        if SalesInvoiceHeader.FindLast() then
            InvoiceNo := SalesInvoiceHeader."No.";

    end;

    // Funciones de comprobacion

    procedure VerifyVendorNo(Salesperson: Record "Salesperson/Purchaser"; VendorNo: Code[20]): Boolean
    begin
        exit(Salesperson.TCNVendorNoCOMI = VendorNo);
    end;

    procedure VerifySalespersonCommission(Salesperson: Record "Salesperson/Purchaser"; InvoiceNo: Code[20]): Boolean
    var
        TCNCommissionsCOMI: Record TCNCommissionsCOMI;
    begin
        TCNCommissionsCOMI.SetRange(CodVendedor, Salesperson.Code);
        TCNCommissionsCOMI.SetRange(NoDocumento, InvoiceNo);
        exit(not TCNCommissionsCOMI.IsEmpty());
    end;

    procedure VerifySalespersonCommissionCorrect(Salesperson: Record "Salesperson/Purchaser"; InvoiceNo: Code[20]; CommissionAmount: Decimal): Boolean
    var
        TCNCommissionsCOMI: Record TCNCommissionsCOMI;
    begin
        TCNCommissionsCOMI.SetRange(CodVendedor, Salesperson.Code);
        TCNCommissionsCOMI.SetRange(NoDocumento, InvoiceNo);
        if TCNCommissionsCOMI.IsEmpty() then
            exit(false);
        TCNCommissionsCOMI.FindSet(false);
        TCNCommissionsCOMI.CalcSums("Commission Amount");
        exit(TCNCommissionsCOMI."Commission Amount" = CommissionAmount);
    end;


    // Funciones de control UI

    [ConfirmHandler]
    procedure ConfirmCloseSalesInvoiceHandler(Question: Text[1024]; var Reply: Boolean)
    var
    //DocumentNotPostedClosePageQst: Label 'The document has been saved but is not yet posted.\\Are you sure you want to exit?'; // 'El documento se ha guardado pero no se ha registrado todavía.\\¿Está seguro de que desea salir?'
    //ClosePageQst: Label 'exit'; // 'salir'
    begin
        if (Question.Contains('exit')) or
           (Question.Contains('salir')) then
            Reply := true;
    end;

    [ConfirmHandler]
    procedure ConfirmPostHandler(Question: Text[1024]; var Reply: Boolean)
    var
    //PostLbl: Label 'Do you want to post the invoice?'; // '¿Confirma que desea registrar la factura?'
    begin
        if (Question.Contains('post')) or
           (Question.Contains('registrar')) or
           (Question.Contains('exit')) or
           (Question.Contains('salir')) then
            Reply := true;
    end;

    [ConfirmHandler]
    procedure ConfirmRegisterHandler(Question: Text[1024]; var Reply: Boolean)
    var
    //RegisterLbl: Label 'register';
    begin
        if (Question.Contains('register')) or
           (Question.Contains('registrar')) then
            Reply := true;
    end;

    [ConfirmHandler]
    procedure ConfirmDeleteHandler(Question: Text[1024]; var Reply: Boolean)
    var
    //DeleteLbl: Label 'delete';
    begin
        if (Question.Contains('delete')) or
           (Question.Contains('eliminar')) then
            Reply := true;
    end;

    [ConfirmHandler]
    procedure ConfirmExitHandler(Question: Text[1024]; var Reply: Boolean)
    var
    //ExitLbl: Label 'exit';
    begin
        if (Question.Contains('exit')) or
           (Question.Contains('salir')) then
            Reply := true;
    end;


    /*
    [Test]
    procedure SetValueToFieldOnPage()
    var
        MyTestPage: TestPage "Customer Card";
        NameValue: Text;
    begin
        MyTestPage.Name.Value('Test');
        NameValue := MyTestPage.Name.Value();
    end;
    */

}