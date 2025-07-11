tableextension 56200 "TCNSalespersonPurchaserCOMI" extends "Salesperson/Purchaser"
{
    fields
    {
        field(56200; TCNVendorNoCOMI; Code[20])
        {
            Caption = 'Vendor No.';
            TableRelation = Vendor;
            DataClassification = CustomerContent;
        }
    }
}