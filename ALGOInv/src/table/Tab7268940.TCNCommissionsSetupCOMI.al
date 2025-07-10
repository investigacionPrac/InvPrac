table 7268940 "TCNCommissionsSetupCOMI"
{
    Caption = 'Commissions Setup';
    DataClassification = CustomerContent;
    LookupPageId = TCNCommissionsSetupCOMI;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(4; "Ship. Cost %"; Decimal)
        {
            Caption = 'Ship. Cost %';
            DataClassification = CustomerContent;
        }
        field(5; "Ship. Cost Line Type"; Enum TCNSalesLineTypeCOMI)
        {
            Caption = 'Ship. Cost Line Type';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if not (Rec."Ship. Cost Line Type" in ["Ship. Cost Line Type"::"G/L Account", "Ship. Cost Line Type"::Item, "Ship. Cost Line Type"::Resource, "Ship. Cost Line Type"::"Charge (Item)"])
                    then
                    Rec.TestField("Ship. Cost Line Type", Rec."Ship. Cost Line Type"::"G/L Account");
                if Rec."Ship. Cost Line Type" <> xRec."Ship. Cost Line Type" then
                    Rec."Ship. Cost Line No." := '';
            end;
        }
        field(6; "Ship. Cost Line No."; Code[20])
        {
            Caption = 'Ship. Cost Line No.';
            TableRelation = IF ("Ship. Cost Line Type" = CONST("G/L Account")) "G/L Account" WHERE("Direct Posting" = CONST(true),
                "Account Type" = CONST(Posting),
                Blocked = CONST(false))
            ELSE
            IF ("Ship. Cost Line Type" = CONST(Resource)) Resource WHERE(Blocked = CONST(false))
            ELSE
            IF ("Ship. Cost Line Type" = CONST("Charge (Item)")) "Item Charge"
            ELSE
            IF ("Ship. Cost Line Type" = CONST(Item)) Item WHERE(Blocked = CONST(false),
                "Sales Blocked" = CONST(false));
            ValidateTableRelation = false;
            DataClassification = CustomerContent;
        }
        field(21; "Appl. Account No."; Code[20])
        {
            Caption = 'Appl. Account No.'; // Nº cuenta liquidación
            TableRelation = "G/L Account";
            DataClassification = CustomerContent;
        }
        field(22; "Appl. Invoice Nos."; Code[20])
        {
            Caption = 'Appl. Invoice Nos.'; // Nº serie fact. liquidación
            TableRelation = "No. Series";
            DataClassification = CustomerContent;
        }
        field(24; "Appl. Disc. Shipping Cost"; Boolean)
        {
            Caption = 'Appl. Disc. Shipping Cost';
            // Liq. comisión descuenta portes            DataClassification = CustomerContent;

        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
        }
    }

    fieldgroups
    {
    }

    /// <summary>
    /// Realiza el Get de la tabla de configuración y si no existe lo crea.
    /// </summary>
    /// <returns>Return value of type Boolean.</returns>
    procedure getF(): Boolean
    var
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert(true);
        end;
        exit(true);
    end;
}

