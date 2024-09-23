// codeunit 70001 SingleInstanceCU
// {
//     SingleInstance = true;
//     procedure InsertIntoTempCLE(ApplyToCustLedgEntry: record "Cust. Ledger Entry")
//     begin
//         Temp_CustLedgEntry.Init();
//         Temp_CustLedgEntry.copy(ApplyToCustLedgEntry);
//         Temp_CustLedgEntry.Insert();
//     end;

//     procedure GetTempCLE(var CustLedgEntry: record "Cust. Ledger Entry")
//     begin
//         if Temp_CustLedgEntry.FindFirst() then
//             repeat
//                 CustLedgEntry.Init();
//                 CustLedgEntry.copy(Temp_CustLedgEntry);
//                 CustLedgEntry.Insert();
//             until Temp_CustLedgEntry.Next() = 0
//     end;

//     procedure ClearTempCLE()
//     begin
//         Temp_CustLedgEntry.DeleteAll();
//     end;

//     var

//         Temp_CustLedgEntry: record "Cust. Ledger Entry" temporary;
// }