codeunit 70000 MyCodeunit
{
    // [EventSubscriber(ObjectType::Table, Database::"Job Queue Entry", OnBeforeIsReadyToStart, '', false, false)]
    // local procedure "Job Queue Entry_OnBeforeIsReadyToStart"(var JobQueueEntry: Record "Job Queue Entry"; var ReadyToStart: Boolean; var IsHandled: Boolean)
    // begin
    //     ReadyToStart := (JobQueueEntry.Status in [JobQueueEntry.Status::Error, JobQueueEntry.Status::Ready, JobQueueEntry.Status::Waiting, JobQueueEntry.Status::"In Process", JobQueueEntry.Status::"On Hold with Inactivity Timeout"]);
    //     Ishandled := true;
    // end;




    var
        myInt: Integer;
}