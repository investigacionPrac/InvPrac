codeunit 7268942 "TCNSICommissionsCOMI"
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