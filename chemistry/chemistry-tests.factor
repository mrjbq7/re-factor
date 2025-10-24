
USING: kernel sequences tools.test ;
IN: chemistry

{ t } [
    {
        { "H" H{ { "H" 1 } } }
        { "Pb" H{ { "Pb" 1 } } }
        { "Pb2" H{ { "Pb" 2 } } }
        { "H2" H{ { "H" 2 } } }
        { "H2O" H{ { "H" 2 } { "O" 1 } } }
        { "C1.5O3" H{ { "C" 1.5 } { "O" 3 } } }
        { "3Pb2" H{ { "Pb" 6 } } }
        { "Pb2SO4" H{ { "S" 1 } { "Pb" 2 } { "O" 4 } } }
        { "PbH2" H{ { "H" 2 } { "Pb" 1 } } }
        { "(PbH2)2" H{ { "H" 4 } { "Pb" 2 } } }
        { "(CCC)2" H{ { "C" 6 } } }
        { "Pb(H2)2" H{ { "H" 4 } { "Pb" 1 } } }
        { "(Pb(H2)2)2" H{ { "H" 8 } { "Pb" 2 } } }
        {
            "(Pb(H2)2)2NO3"
            H{ { "H" 8 } { "O" 3 } { "Pb" 2 } { "N" 1 } }
        }
        {
            "(Ag(Pb(H2)2)2)2SO4"
            H{
                { "H" 16 }
                { "O" 4 }
                { "S" 1 }
                { "Ag" 2 }
                { "Pb" 4 }
            }
        }
        { "Pb(CH3(CH2)2CH3)2" H{ { "H" 20 } { "C" 8 } { "Pb" 1 } } }
        {
            "Na2(CH3(CH2)2CH3)2"
            H{ { "H" 20 } { "Na" 2 } { "C" 8 } }
        }
        {
            "Tc(H2O)3Fe3(SO4)2"
            H{
                { "Fe" 3 }
                { "S" 2 }
                { "H" 6 }
                { "Tc" 1 }
                { "O" 11 }
            }
        }
        {
            "Tc(H2O)3(Fe3(SO4)2)2"
            H{
                { "Fe" 6 }
                { "S" 4 }
                { "H" 6 }
                { "Tc" 1 }
                { "O" 19 }
            }
        }
        {
            "(Tc(H2O)3(Fe3(SO4)2)2)2"
            H{
                { "Fe" 12 }
                { "S" 8 }
                { "H" 12 }
                { "Tc" 2 }
                { "O" 38 }
            }
        }
        {
            "(Tc(H2O)3CO(Fe3(SO4)2)2)2"
            H{
                { "Fe" 12 }
                { "C" 2 }
                { "S" 8 }
                { "H" 12 }
                { "Tc" 2 }
                { "O" 40 }
            }
        }
        {
            "(Tc(H2O)3CO(BrFe3(ReCl)3(SO4)2)2)2MnO4"
            H{
                { "Br" 4 }
                { "C" 2 }
                { "H" 12 }
                { "Re" 12 }
                { "Tc" 2 }
                { "Mn" 1 }
                { "O" 44 }
                { "Fe" 12 }
                { "S" 8 }
                { "Cl" 12 }
            }
        }
        {
            "(CH3)16(Tc(H2O)3CO(BrFe3(ReCl)3(SO4)2)2)2MnO4"
            H{
                { "Br" 4 }
                { "C" 18 }
                { "H" 60 }
                { "Re" 12 }
                { "Tc" 2 }
                { "Mn" 1 }
                { "O" 44 }
                { "Fe" 12 }
                { "S" 8 }
                { "Cl" 12 }
            }
        }
        {
            "K4[Fe(SCN)6]"
            H{ { "Fe" 1 } { "K" 4 } { "S" 6 } { "C" 6 } { "N" 6 } }
        }
        {
            "K4[Fe(SCN)6]2"
            H{
                { "Fe" 2 }
                { "K" 4 }
                { "S" 12 }
                { "C" 12 }
                { "N" 12 }
            }

        }
    } [
        [ first parse-formula ] [ second ] bi =
    ] all?
] unit-test
