pageextension 7268940 "TCNSalespPurchaserCardCOMI" extends "Salesperson/Purchaser Card"
{
    layout
    {
        addafter("E-Mail")
        {
            field(TCNVendorNoCOMI; Rec.TCNVendorNoCOMI)
            {
                ApplicationArea = All;
            }
        }
    }
}

