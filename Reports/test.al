reportextension 70001 MyExtension extends 188
{
    dataset
    {

    }

    requestpage
    {
        layout
        {
            addlast(Options)
            {
                field(testbool; testbool)
                {
                    ApplicationArea = All;
                }

            }
        }
    }

    rendering
    {
        layout(LayoutName)
        {
            Type = RDLC;
            LayoutFile = 'mylayout.rdl';
        }
    }




    var
        testbool: Boolean;
}