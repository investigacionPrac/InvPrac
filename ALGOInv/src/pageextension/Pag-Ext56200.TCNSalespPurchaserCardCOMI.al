pageextension 56200 "TCNSalespPurchaserCardCOMI" extends "Salesperson/Purchaser Card"
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

