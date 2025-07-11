permissionset 56200 PermissionSet
{
    Assignable = true;
    Permissions = table "Customer" = X,
        table "Sales Invoice Header" = X,
        table "Sales Invoice Line" = X,
        table "Item" = X,
        tabledata TCNCommissionsCOMI = RIMD,
        tabledata TCNCommissionsSetupCOMI = RIMD,
        table TCNCommissionsCOMI = X,
        table TCNCommissionsSetupCOMI = X,
        report TCNSalespersonCommissionCOMI = X,
        codeunit TCNCuActualizacionCOMI = X,
        codeunit TCNCuInstalacionCOMI = X,
        codeunit TCNFuncionesCommissionsCOMI = X,
        codeunit TCNSICommissionsCOMI = X,
        codeunit TCNuscripcionesCOMI = X,
        page TCNCommissionsCOMI = X,
        page TCNCommissionsCuesCOMI = X,
        page TCNCommissionsRolCenterCOMI = X,
        page TCNCommissionsSetupCOMI = X;
}