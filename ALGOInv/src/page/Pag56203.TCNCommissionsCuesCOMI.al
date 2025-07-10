page 56203 TCNCommissionsCuesCOMI
{
    Caption = 'Commissions';
    PageType = CardPart;
    ShowFilter = false;
    RefreshOnActivate = true;
    layout
    {
        area(content)
        {
            cuegroup(Grupo01)
            {
                Caption = '';
                visible = true;

                field(IncidenciasInterna; cueDataF(1, false))
                {
                    Caption = 'Commissions';
                    ApplicationArea = All;

                    trigger OnDrillDown()
                    begin
                        cueDataF(1, true);
                    end;
                }

                actions
                {
                    action(Accion)
                    {
                        Caption = 'Commissions';
                        ApplicationArea = All;
                        RunObject = Page TCNCommissionsCOMI;
                        RunPageView = where(Applicated = const(false));
                        RunPageMode = View;
                        Image = TileBrickNew;
                    }
                }
            }
        }
    }

    local procedure cueDataF(pNumPila: Integer; pDrillDown: Boolean) xSalida: Integer
    var
        rlTCNCommissionsCOMI: Record TCNCommissionsCOMI;
    begin
        case pNumPila of
            1:
                begin
                    rlTCNCommissionsCOMI.SetRange(Applicated, false);
                end;
            else
                exit(0);
        end;

        if pDrillDown then
            page.Run(Page::TCNCommissionsCOMI, rlTCNCommissionsCOMI)
        else
            xSalida := rlTCNCommissionsCOMI.Count();
    end;
}