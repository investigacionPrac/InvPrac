table 7268941 "TCNCommissionsCOMI"
{
    Caption = 'Commissions';
    DataClassification = CustomerContent;
    DrillDownPageId = TCNCommissionsCOMI;
    LookupPageId = TCNCommissionsCOMI;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(2; TipoDocumento; Option)
        {
            Caption = 'Document type';
            OptionMembers = "Invoice","Cr.Memo";
            OptionCaption = 'Invoice,Cr.Memo';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(3; NoDocumento; Code[20])
        {
            Caption = 'Document No.';
            //112 -> Histórico cab. factura venta (Sales Invoice Header)
            //114 -> Histórico cab. abono venta (Sales Cr.Memo Header)
            TableRelation = IF (TipoDocumento = Const("Invoice")) "Sales Invoice Header"."No." ELSE
            IF (TipoDocumento = const("Cr.Memo")) "Sales Cr.Memo Header"."No.";
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(4; NoLinea; Integer)
        {
            Caption = 'Line No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(5; FechaRegistro; Date)
        {
            Caption = 'Posting date';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(6; "Commission Base Amount"; Decimal)
        {
            Caption = 'Commission Base Amount'; // ENU=Commission Base Amount;ESP=Importe base comisión
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(7; "Commission %"; Decimal)
        {
            Caption = 'Commission %'; // ENU=Commission %;ESP=% Comisión
            MinValue = 0;
            MaxValue = 100;
            DecimalPlaces = 2 : 2;
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                IsHandled: Boolean;
            begin
                Rec.TestField(Applicated, false);
                OnBeforeCalculateCommissionAmountF(Rec, IsHandled);
                if IsHandled then
                    exit;
                Rec.Validate("Commission Amount", Rec."Commission %" * Rec."Commission Base Amount" * 0.01);
            end;
        }
        field(8; "Commission Amount"; Decimal)
        {
            Caption = 'Comission Amount';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(9; CodCliente; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer."No.";
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(10; Nombrecliente; Text[100])
        {
            Caption = 'Customer name';
            FieldClass = FlowField;
            CalcFormula = lookup(Customer.Name WHERE("No." = field(CodCliente)));
            Editable = false;
        }
        field(11; CodVendedor; Code[20])
        {
            Caption = 'Salesperson No.';
            TableRelation = "Salesperson/Purchaser".Code;
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(12; NombreVendedor; Text[50])
        {
            Caption = 'Salesperson Name';
            FieldClass = FlowField;
            CalcFormula = lookup("Salesperson/Purchaser".Name WHERE("Code" = field(CodVendedor)));
            Editable = false;
        }
        /*
        field(13; FechaLiquidacion; Date)
        {
            //FIXME Añadir proceso para cambiar dato
            Caption = 'Date';
            Editable = false;
            ObsoleteState = Removed;
            ObsoleteReason = 'New fields added';
            DataClassification = CustomerContent;
        }
        field(14; NoLiquidacion; Code[20])
        {
            //FIXME Añadir proceso para cambiar dato
            Caption = 'No.';
            Editable = false;
            ObsoleteState = Removed;
            ObsoleteReason = 'New fields added';
            DataClassification = CustomerContent;
        }
        */
        field(15; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            Editable = false;
            TableRelation = Item."No.";
            DataClassification = CustomerContent;
        }
        field(16; ItemDesc; Text[100])
        {
            Caption = 'Item Desc.';
            FieldClass = FlowField;
            CalcFormula = lookup("Item".Description WHERE("No." = field("Item No.")));
            Editable = false;
        }
        field(17; Applicated; Boolean)
        {
            Caption = 'Applicated'; // Liquidado
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(18; "Application Date"; Date)
        {
            Caption = 'Application Date'; // Fecha liquidación
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(19; "Application User Name"; Code[50])
        {
            Caption = 'Application User Name'; // Nombre usuario liquidación
            TableRelation = "User Setup";
            ValidateTableRelation = false;
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(20; "Appl. Document Type"; Option)
        {
            Caption = 'Appl. Document Type'; // Tipo documento liquidación
            OptionMembers = " ",Invoice,"Credit Memo","Posted Invoice","Posted Credit Memo";
            OptionCaption = ' ,Invoice,Credit Memo,Posted Invoice,Posted Credit Memo'; //  ,Factura,Abono,Factura registrada,Abono registrado
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(21; "Appl. Document No."; Code[20])
        {
            Caption = 'Appl. Document No.'; // Nº documento liquidación
            TableRelation = IF ("Appl. Document Type" = CONST(Invoice)) "Purchase Header"."No." WHERE("Document Type" = CONST(Invoice)) ELSE
            IF ("Appl. Document Type" = CONST("Credit Memo")) "Purchase Header"."No." WHERE("Document Type" = CONST("Credit Memo")) ELSE
            IF ("Appl. Document Type" = CONST("Posted Invoice")) "Purch. Inv. Header"."No." ELSE
            IF ("Appl. Document Type" = CONST("Posted Credit Memo")) "Purch. Cr. Memo Hdr."."No.";
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(22; "Appl. Document Line No."; Integer)
        {
            Caption = 'Appl. Document Line No.'; // Nº linea documento liquidación
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(23; "Posted Application"; Boolean)
        {
            Caption = 'Posted Application'; // Liquidación registrada
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(24; "Line Discount %"; Decimal)
        {
            Caption = 'Line Discount %';
            Editable = false;
            DecimalPlaces = 0 : 5;
            DataClassification = CustomerContent;
        }
        field(25; Quantity; Decimal)
        {
            Caption = 'Quantity';
            Editable = false;
            DecimalPlaces = 0 : 5;
            DataClassification = CustomerContent;
        }
        field(26; "Quantity (Base)"; Decimal)
        {
            Caption = 'Quantity (Base)';
            Editable = false;
            DecimalPlaces = 0 : 5;
            DataClassification = CustomerContent;
        }
        field(27; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            Editable = false;
            DataClassification = CustomerContent;
            TableRelation = "Item Unit of Measure".Code where("Item No." = FIELD("Item No."));
        }
        field(28; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            Editable = false;
            DataClassification = CustomerContent;
            TableRelation = "Item Variant".Code where("Item No." = FIELD("Item No."));
        }
        field(30; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code'; // ENU=Shortcut Dimension 1 Code;ESP=Cód. dim. acceso dir. 1
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1),
                                                          Blocked = CONST(false));
            DataClassification = CustomerContent;
        }
        field(31; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code'; // ENU=Shortcut Dimension 2 Code;ESP=Cód. dim. acceso dir. 2
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2),
                                                          Blocked = CONST(false));
            DataClassification = CustomerContent;
        }
        field(32; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID'; // ENU=Dimension Set ID;ESP=Id. grupo dimensiones
            TableRelation = "Dimension Set Entry";
            DataClassification = CustomerContent;
            Editable = false;

            trigger OnLookup()
            begin
                Rec.ShowDimensions();
            end;
        }
        field(33; CodVendedorCli; Code[20])
        {
            Caption = 'Customer Salesperson No.';
            TableRelation = "Salesperson/Purchaser".Code;
            FieldClass = FlowField;
            CalcFormula = lookup(Customer."Salesperson Code" where("No." = field(CodCliente)));
            Editable = false;
        }
        field(34; "Responsibility Center"; Code[10])
        {
            Caption = 'Responsibility Center'; // ENU=Responsibility Center;ESP=Centro responsabilidad
            DataClassification = CustomerContent;
            TableRelation = "Responsibility Center".Code;
        }
        field(35; Amount; Decimal)
        {
            Caption = 'Amount';
            Editable = false;
            AutoFormatType = 1;
            AutoFormatExpression = "Currency Code";
            DataClassification = CustomerContent;
        }
        field(36; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code'; // ENU=Currency Code;ESP=Cód. divisa
            TableRelation = Currency;
            DataClassification = CustomerContent;
        }
        field(37; "Currency Factor"; Decimal)
        {
            Caption = 'Currency Factor'; // ENU=Currency Factor;ESP=Factor divisa
            DecimalPlaces = 0 : 15;
            MinValue = 0;
            DataClassification = CustomerContent;
        }
        field(38; "Amount LCY"; Decimal)
        {
            Caption = 'Amount LCY';
            Editable = false;
            DataClassification = CustomerContent;
        }

    }

    keys
    {
        key("Entry No."; "Entry No.")
        {
            Clustered = true;
        }
    }

    procedure Navigate(Application: Boolean)
    var
        NavigateForm: page Navigate;
    begin
        if Application then
            NavigateForm.SetDoc("Application Date", "Appl. Document No.")
        else
            NavigateForm.SetDoc("FechaRegistro", "NoDocumento");
        NavigateForm.Run();
    end;

    procedure ShowDimensions()
    var
        DimMgt: Codeunit DimensionManagement;
    begin
        DimMgt.ShowDimensionSet(Rec."Dimension Set ID", CopyStr(STRSUBSTNO('%1 %2', Rec.TableCaption(), Rec."Entry No."), 1, 250));
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalculateCommissionAmountF(var prTCNCommissionsCOMI: Record TCNCommissionsCOMI; var IsHandled: Boolean)
    begin
    end;

}
