
USING: kernel sequences tools.test ;
IN: chemistry

{ t } [
    {
        { "H" "H" }
        { "Pb" "Pb" }
        { "Pb2" "2Pb" }
        { "H2" "2H" }
        { "3Pb2" "6Pb" }
        { "Pb2SO4" "2Pb S 4O" }
        { "PbH2" "Pb 2H" }
        { "(PbH2)2" "2Pb 4H" }
        { "(CCC)2" "2C 2C 2C" }
        { "Pb(H2)2" "Pb 4H" }
        { "(Pb(H2)2)2" "2Pb 8H" }
        { "(Pb(H2)2)2NO3" "2Pb 8H N 3O" }
        { "(Ag(Pb(H2)2)2)2SO4" "2Ag 4Pb 16H S 4O" }
        { "Pb(CH3(CH2)2CH3)2" "Pb 2C 6H 4C 8H 2C 6H" }
        { "Na2(CH3(CH2)2CH3)2" "2Na 2C 6H 4C 8H 2C 6H" }
        { "Tc(H2O)3Fe3(SO4)2" "Tc 6H 3O 3Fe 2S 8O" }
        { "Tc(H2O)3(Fe3(SO4)2)2" "Tc 6H 3O 6Fe 4S 16O" }
        { "(Tc(H2O)3(Fe3(SO4)2)2)2" "2Tc 12H 6O 12Fe 8S 32O" }
        {
            "(Tc(H2O)3CO(Fe3(SO4)2)2)2"
            "2Tc 12H 6O 2C 2O 12Fe 8S 32O"
        }
        {
            "(Tc(H2O)3CO(BrFe3(ReCl)3(SO4)2)2)2MnO4"
            "2Tc 12H 6O 2C 2O 4Br 12Fe 12Re 12Cl 8S 32O Mn 4O"
        }
        {
            "(CH3)16(Tc(H2O)3CO(BrFe3(ReCl)3(SO4)2)2)2MnO4"
            "16C 48H 2Tc 12H 6O 2C 2O 4Br 12Fe 12Re 12Cl 8S 32O Mn 4O"
        }
    } [
        [ first symbol>string ] [ second ] bi =
    ] all?
] unit-test
