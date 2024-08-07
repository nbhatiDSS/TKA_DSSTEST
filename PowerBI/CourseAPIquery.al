query 52003 Course
{
    QueryType = API;
    APIPublisher = 'DSS';
    APIGroup = 'PowerBI';
    APIVersion = 'v2.0';
    EntityName = 'Courses';
    EntitySetName = 'course';

    elements
    {
        dataitem(Course_Header; "Course Header")
        {
            column(Code; Code)
            { }
            column(Name; Name)
            { }
            column(Description; Description)
            { }
            column(Course_Dimension_Code; "Course Dimension Code")
            { }
            column(Duration__Hours_; "Duration (Hours)")
            { }
            column(Duration__Days_; "Duration (Days)")
            { }
            column(G_L_Account_No_; "G/L Account No.")
            { }
            column(G_L_Account_No___Purchase_; "G/L Account No. (Purchase)")
            { }
            column(EI; EI)
            { }
            column(Technical; Technical)
            { }
            column(TKA_Course_Id; "TKA Course id")
            { }
            column(TKA_Course_Name; "TKA Course Name")
            { }
            column(Weekend_Weekday; "Weekend/Weekday")
            { }
            column(Bespoke; Bespoke)
            { }
            column(Bespoke_Type; "Bespoke Type")
            { }
            column(CCat; CCat)
            { }
        }
    }

}
