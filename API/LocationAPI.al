page 61013 CreateLocationAPI
{
    APIGroup = 'API';
    APIPublisher = 'Direction_Software_LLP';
    APIVersion = 'v2.0';
    ApplicationArea = All;
    Caption = 'CreateLocationAPI';
    DelayedInsert = true;
    EntityName = 'CreateLocation';
    EntitySetName = 'Location';
    PageType = API;
    SourceTable = "Location";
    SourceTableTemporary = True;
    ODataKeyFields = Code;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Code; Rec.Code)
                { }
                field("Use_for_Grouping"; Rec."Use for Grouping")
                { }
                field("Group_Location_Code"; Rec."Group Location Code")
                { }
                field(Description; Rec.Name)
                { }
<<<<<<< HEAD
                field(Dimension_Code; DimensionCode)
                { }
                field(Dimension_Desc; DimensionDesc)
                { }
=======
>>>>>>> 6806c381c855e47a3bfe21b915b51fc03bc97841
                field(MinAttendees; MinAttendees)
                { }
                field(MaxAttendees; MaxAttendees)
                { }
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
    begin
<<<<<<< HEAD
        CreateDimension(DimensionCode, DimensionDesc);
=======
        CreateDimension(rec.Code, Rec.Name);
>>>>>>> 6806c381c855e47a3bfe21b915b51fc03bc97841
        CreateLocation();
        if not rec."Use for Grouping" then
            CreateTrainingCentre();
    end;

    local procedure CreateTrainingCentre()
    var
        TrainingCentre: record "Training Centre";
    begin
        TrainingCentre.INIT;
        TrainingCentre."Course Header" := '';
        TrainingCentre.VALIDATE("Location Code", rec.Code);
        TrainingCentre.Description := rec.Name;
        TrainingCentre.VALIDATE("Training Centre Dimension Code", DimensionCode);
        TrainingCentre.VALIDATE("Min. Number of Attendees", MinAttendees);
        TrainingCentre.VALIDATE("Max. Number of Attendees", MaxAttendees);
        TrainingCentre.INSERT(TRUE);
    end;

    local procedure CreateLocation()
    var
        Location: Record Location;
    begin
        Location.Reset();
        Location.Init();
        Location.VALIDATE(Code, rec.Code);
        Location.Name := rec.Name;
        if Rec."Use for Grouping" then begin
            Location.VALIDATE("Use for Grouping", rec."Use for Grouping");
            Location.VALIDATE("Group Location Dimension Code", DimensionCode);
        end else begin
            Location.VALIDATE("Group Location Code", rec."Group Location Code");
        end;
        Location.TestField(Code);
        Location.TestField(Name);
        Location.Insert();

        CreateLocationAllCompanies(Location);
    end;

    local procedure CreateLocationAllCompanies(var Loc: Record Location)
    var
        rec_location: record Location;
        comp: record Company;
    begin
        Comp.SetFilter(Name, '<>%1', CompanyName());
        if comp.findfirst then
            repeat
                rec_location.reset;
                rec_location.ChangeCompany(comp.name);
                if not rec_location.Get(Loc.Code) then begin
                    rec_location.Init();
                    rec_location.Copy(loc);
                    rec_location.insert;
                end;
            until comp.Next() = 0;
    end;

    local procedure CreateDimension(var Code: Code[20]; var Desc: text[50])
    var
        DimensionValue: record "Dimension Value";
        GLSetup: record "General Ledger Setup";
    begin
        GLSetup.get;
        IF NOT DimensionValue.GET(GLSetup."Global Dimension 2 Code", Code) THEN BEGIN
            DimensionValue.INIT;
            DimensionValue.VALIDATE("Dimension Code", GLSetup."Global Dimension 2 Code");
            DimensionValue.VALIDATE(Code, Code);
            DimensionValue.VALIDATE(Name, Desc);
            DimensionValue.INSERT(TRUE);
        END;
    end;


    var
        DimensionCode: Code[20];
        DimensionDesc: text[50];
        MinAttendees: Integer;
        MaxAttendees: Integer;

}