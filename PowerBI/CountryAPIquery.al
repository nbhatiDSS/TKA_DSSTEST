query 52004 CountryRegion
{
    QueryType = API;
    APIPublisher = 'DSS';
    APIGroup = 'PowerBI';
    APIVersion = 'v2.0';
    EntityName = 'countryRegions';
    EntitySetName = 'countryRegion';

    elements
    {
        dataitem(Country_Region; "Country/Region")
        {
            column(Code; Code)
            { }
            column(Name; Name)
            { }
            column(ISO_Code; "ISO Code")
            { }
            column(Shift_Timing; "Shift Timing")
            { }
            column(Currency_Code; "Currency Code")
            { }
            column(EFT_Code; "EFT Code")
            { }
        }
    }
}