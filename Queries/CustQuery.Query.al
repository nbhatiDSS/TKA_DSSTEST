query 70000 CustQuery
{
    QueryType = Normal;
    OrderBy = descending(Count);

    elements
    {
        dataitem(Customer;
        Customer)
        {
            column(Post_Code;
            "Post Code")
            {
                ColumnFilter = Post_Code = filter(<> '');
            }
            column(City;
            City)
            {
            }
            column(Country_Region_Code;
            "Country/Region Code")
            {
            }
            column(Count)
            {
                Method = Count;
            }
        }
    }

}
