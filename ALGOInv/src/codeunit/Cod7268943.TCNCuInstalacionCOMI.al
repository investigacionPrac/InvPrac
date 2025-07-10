codeunit 7268943 "TCNCuInstalacionCOMI"
{
    Subtype = Install;

    trigger OnInstallAppPerDatabase()
    begin
    end;

    trigger OnInstallAppPerCompany()
    var
        pglConfAddOn: Page TCNCommissionsSetupCOMI;
    begin
        pglConfAddOn.AccionesAlInstalarYAcutalizarF();
    end;
}