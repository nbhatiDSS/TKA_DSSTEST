// xmlport 70044 "Event Upload 1"
// {
//     Caption = 'Event Upload';
//     Direction = Import;
//     Format = VariableText;
//     TextEncoding = UTF8;
//     TableSeparator = '';
//     // UseRequestPage = true;
//     schema
//     {
//         textelement(Root)
//         {
//             tableelement(Event_Upload; Integer)
//             {
//                 UseTemporary = true;
//                 SourceTableView = sorting(Number) where(Number = const(1));
//                 textelement(p1)
//                 {

//                 }

//                 textelement(p2)
//                 {
//                     trigger OnAfterAssignVariable()
//                     begin
//                         Evaluate(tempp2, p2);
//                     end;
//                 }

//                 textelement(p3)
//                 {

//                 }

//                 textelement(p4)
//                 {

//                 }

//                 textelement(p5)
//                 {

//                 }

//                 textelement(p6)
//                 {

//                 }

//                 textelement(p7)
//                 {

//                 }

//                 textelement(p8)
//                 {
//                     trigger OnAfterAssignVariable()
//                     var
//                         myInt: Integer;
//                     begin
//                         Evaluate(tempp8, p8);
//                     end;
//                 }

//                 textelement(p9)
//                 {

//                 }

//                 textelement(p10)
//                 {

//                 }

//                 textelement(p11)
//                 {

//                 }

//                 textelement(p12)
//                 {

//                 }

//                 trigger OnAfterInsertRecord()
//                 begin

//                     IF p1 = '' THEN
//                         currXMLport.SKIP;
//                     EveUpload.SetValues(p1, tempp2, p3, p4, p5, p6, p7, tempp8, p9, p10, p11, p12);
//                     EveUpload.UseRequestPage(false);
//                     EveUpload.Run();
//                 end;
//             }

//         }
//     }


//     var
//         tempp2: Date;
//         tempp8: Integer;
//         EveUpload: Report 70203;
// }
