page 7268942 "TCNCommissionsRolCenterCOMI"
{
    UsageCategory = Administration;
    PageType = RoleCenter;
    Caption = 'Role Center AddOn Commissions';
    //PromotedActionCategoriesml = ESP = 'Administrar,Proceso,Informes,Listas,Tareas,Informes y análisis,Administración,Archivos,Objetos';
    ApplicationArea = All;
    layout
    {
        area(RoleCenter)
        {
            part(Pilas; TCNCommissionsCuesCOMI)
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(Sections)
        {
            group(Listas)
            {
                action(Action01)
                {
                    Caption = 'Caption01';
                    Image = List;
                    //Promoted = true;
                    //PromotedIsBig = true;
                    //PromotedCategory = Process;
                    ApplicationArea = all;
                    RunObject = Page "Salespersons/Purchasers";
                }
            }
            /*
            group(Tareas)
            {
                action(Action02)
                {
                    Caption = 'Caption02';
                    ApplicationArea = All;
                    image = Task;
                    //Promoted = true;
                    //PromotedIsBig = true;
                    //PromotedCategory = Category5;
                    RunObject = Page TCNTarea01;
                }
            }
            */
            group("Informes y analisis")
            {
                action(Action03)
                {
                    Caption = 'Caption03';
                    ApplicationArea = All;
                    image = Report;
                    //Promoted = true;
                    //PromotedIsBig = true;
                    //PromotedCategory = Report;
                    RunObject = report TCNSalespersonCommissionCOMI;

                }
            }
            group(Administracion)
            {
                action(Action04)

                {
                    Caption = 'Caption04';
                    Image = Administration;
                    //Promoted = true;
                    //PromotedIsBig = true;
                    //PromotedCategory = Process;
                    ApplicationArea = all;
                    RunObject = Page TCNCommissionsSetupCOMI;
                }
            }
            group(Archivos)
            {
                action(Action05)

                {
                    Caption = 'Caption05';
                    Image = Archive;
                    //Promoted = true;
                    //PromotedIsBig = true;
                    //PromotedCategory = Process;
                    ApplicationArea = all;
                    RunObject = Page TCNCommissionsCOMI;
                }
            }
            group(Objetos)
            {
                action(ListaObjetos)
                {
                    Caption = 'Objetos';
                    Image = Table;
                    //Promoted = true;
                    //PromotedIsBig = true;
                    //PromotedCategory = Category9;
                    ApplicationArea = all;
                    RunObject = codeunit TCNFuncionesCommissionsCOMI;
                }
            }
        }
    }
}
