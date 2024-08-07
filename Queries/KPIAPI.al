namespace CloudTKA.CloudTKA;
using Microsoft.Sales.History;
using Microsoft.Sales.Document;

query 70100 "KPI API "
{
    APIGroup = 'API';
    APIPublisher = 'Direction_Software_LLP';
    APIVersion = 'v1.0';
    EntityName = 'KnowledgePassInventoryAPI';
    EntitySetName = 'KnowledgePassInventory';
    QueryType = API;

    elements
    {
        dataitem(Knowledge_Pass_Inventory; "Knowledge Pass Inventory")
        {
            Column(SystemId; SystemId)
            {
            }
            Column(Customer_No; "Customer No.")
            {
            }
            Column("Sales_Person"; "Sales Person")
            {
            }
            Column("KP_Invoice_No"; "KP Invoice No.")
            {
            }
            Column("Line_No"; "Line No.")
            {
            }
            Column("Booking_Date"; "Booking Date")
            {
            }
            Column("Expiry_Date"; "Expiry Date")
            {
            }
            Column("Course_Header"; "Course Header")
            {
            }
            Column("Course_Type"; "Course Type")
            {
            }
            Column(Location1; Location)
            {
            }
            Column(Quantity; Quantity)
            {
            }
            Column("Used_Amount_Invoiced"; "Used Amount (Invoiced)")
            {
            }
            Column("Reversal_of_Original_KP_FP"; "Reversal of Original KP / FP")
            {
            }
            Column("Booked_Amount"; "Booked Amount")
            {
            }
            Column("Reversal_of_Used_Amount"; "Reversal of Used Amount")
            {
            }
            Column("Knowledge_Pass"; "Knowledge Pass")
            {
            }
            Column("Flexi_Pass"; "Flexi Pass")
            {
            }
            Column("Unit_Price"; "Unit Price")
            {
            }
            Column("Expiry_Date_Updated_On"; "Expiry Date Updated On")
            {
            }
            Column("Expiry_Date_Updated_By"; "Expiry Date Updated By")
            {
            }
            Column("Expired_KP_Processed"; "Expired KP Processed")
            {
            }
            Column("Booked_Amount_Same_currency"; "Booked Amount Same currency")
            {
            }
            Column("Posting_Date"; "Posting Date")
            {
            }
            Column("Last_Date_Modified"; "Last Date Modified")
            {
            }
            Column("Deafult_Team_Code"; "Default Team Code")
            {
            }
            Column("Flexi_2"; "Flexi Pass 2")
            {
            }
            Column("Flexi_12"; "Flexi Pass 12")
            {
            }
            Column("Bill_to_Customer_No"; "Bill-to Customer No.")
            {
            }

            dataitem(SalesInvLine; "Sales Invoice Line")
            {
                SqlJoinType = LeftOuterJoin;
                DataItemLink = "KP No." = Knowledge_Pass_Inventory."KP Invoice No.",
                "KP Line No." = Knowledge_Pass_Inventory."Line No.";
                // DataItemTableFilter = Quantity = filter('<>0');
                // "No." = filter('6100..6995'),


                Column("Document_No"; "Document No.")
                {
                }
                Column("Contact_Name"; "Contact Name")
                {
                }
                Column("KP_No"; "KP No.")
                {
                }
                Column("KP_Line_No"; "KP Line No.")
                {
                }
                Column(SalesPerson1; "Salesperson Code")
                {
                }

            }

        }
    }
}
