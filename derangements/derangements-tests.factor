USING: derangements tools.test ;

{
    {
        "BADC"
        "BCDA"
        "BDAC"
        "CADB"
        "CDAB"
        "CDBA"
        "DABC"
        "DCAB"
        "DCBA"
    }
} [ "ABCD" all-derangements ] unit-test
