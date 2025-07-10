tableextension 7268940 "TCNSalespersonPurchaserCOMI" extends "Salesperson/Purchaser"
{
    fields
    {
        field(7268940; TCNVendorNoCOMI; Code[20])
        {
            Caption = 'Vendor No.';
            TableRelation = Vendor;
            DataClassification = CustomerContent;
        }
    }
}