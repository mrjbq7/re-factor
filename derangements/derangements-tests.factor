USING: derangements tools.test ;

{
    {
        "ABCD"
        "BADC"
        "BCDA"
        "BDAC"
        "CADB"
        "CDAB"
        "CDBA"
        "DABC"
        "DCAB"
    }
} [ "ABCD" all-derangements ] unit-test
