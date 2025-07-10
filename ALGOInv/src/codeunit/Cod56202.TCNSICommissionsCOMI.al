codeunit 56202 "TCNSICommissionsCOMI"
{

    // Single Instance 
    SingleInstance = true;

    var
        xPostingInvoice: Boolean;

    procedure postingInvoice(): Boolean
    begin
        exit(xPostingInvoice);
    end;

    procedure postingInvoice(pPostingInvoice: Boolean)
    begin
        xPostingInvoice := pPostingInvoice;
    end;

}