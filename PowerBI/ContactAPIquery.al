query 52001 Contact
{
    QueryType = API;
    APIPublisher = 'DSS';
    APIGroup = 'PowerBI';
    APIVersion = 'v2.0';
    EntityName = 'contacts';
    EntitySetName = 'contact';

    elements
    {
        dataitem(Contact; Contact)
        {
            column(No_; "No.")
            { }
            column(Name; Name)
            { }
            column(Type; Type)
            { }
            column(Salesperson_Code; "Salesperson Code")
            { }
            column(Company_No_; "Company No.")
            { }
            column(E_Mail; "E-Mail")
            { }
        }
    }

}