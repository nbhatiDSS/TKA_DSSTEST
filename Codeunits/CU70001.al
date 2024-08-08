codeunit 70000 MyCodeunit
{
    // [EventSubscriber(ObjectType::Table, Database::"Job Queue Entry", OnBeforeIsReadyToStart, '', false, false)]
    // local procedure "Job Queue Entry_OnBeforeIsReadyToStart"(var JobQueueEntry: Record "Job Queue Entry"; var ReadyToStart: Boolean; var IsHandled: Boolean)
    // begin
    //     ReadyToStart := (JobQueueEntry.Status in [JobQueueEntry.Status::Error, JobQueueEntry.Status::Ready, JobQueueEntry.Status::Waiting, JobQueueEntry.Status::"In Process", JobQueueEntry.Status::"On Hold with Inactivity Timeout"]);
    //     Ishandled := true;
    // end;

    [EventSubscriber(ObjectType::Table, Database::Contact, OnBeforeCheckIfTypeChangePossibleForPerson, '', false, false)]
    local procedure Contact_OnBeforeCheckIfTypeChangePossibleForPerson(var Contact: Record Contact; xContact: Record Contact; var IsHandled: Boolean)
    begin
        if UpperCase(UserId()) in ['WEB SERVICE'] then begin
            IsHandled := true;
        end
    end;



    var
        myInt: Integer;
}