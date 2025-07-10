page 7268940 "TCNCommissionsSetupCOMI"
{
    Caption = 'Commissions Setup';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "TCNCommissionsSetupCOMI";

    layout
    {
        area(content)
        {
            field("Ship. Cost %"; Rec."Ship. Cost %")
            {
                ApplicationArea = All;
            }
            field("Ship. Cost Line Type"; Rec."Ship. Cost Line Type")
            {
                ApplicationArea = All;
            }
            field("Ship. Cost Line No."; Rec."Ship. Cost Line No.")
            {
                ApplicationArea = All;
            }
            field("Appl. Account No."; Rec."Appl. Account No.")
            {
                ApplicationArea = All;
            }
            field("Appl. Invoice Nos."; Rec."Appl. Invoice Nos.")
            {
                ApplicationArea = All;
            }
            field("Appl. Disc. Shipping Cost"; Rec."Appl. Disc. Shipping Cost")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        /*
        area(Processing)
        {
            action(FixDatosAction)
            {

                Caption = 'FixDatos';
                ApplicationArea = All;
                Image = Process;

                trigger OnAction()
                var
                    culTCNFuncionesCommissionsCOMI: Codeunit TCNFuncionesCommissionsCOMI;
                    culTCNMensajesCOM:Codeunit TCNMensajesCOM;
                begin
                    culTCNFuncionesCommissionsCOMI.FixCommissions();
                    culTCNMensajesCOM.ProcesoFinalizadoF();
                end;
            }
        }
        */
    }

    trigger OnOpenPage()
    begin
        Rec.getF();
    end;

    /// <summary>
    /// Devuelve un texto con el Nº del objeto de la página
    /// </summary>
    /// <returns></returns>
    procedure confObjectIdF(): Text
    begin
        exit(CurrPage.ObjectId(false));
    end;

    procedure AccionesAlInstalarYAcutalizarF()
    begin
        Rec.getF();
    end;

}