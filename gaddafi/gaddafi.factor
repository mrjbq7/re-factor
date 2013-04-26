! Copyright (C) 2011 John Benediktsson.
! See http://factorcode.org/license.txt for BSD license.

USING: literals regexp sequences soundex ;

IN: gaddafi

<<
CONSTANT: names {
    "Gadaffi"
    "Gadafi"
    "Gadafy"
    "Gaddafi"
    "Gaddafy"
    "Gaddhafi"
    "Gadhafi"
    "Gathafi"
    "Ghadaffi"
    "Ghadafi"
    "Ghaddafi"
    "Ghaddafy"
    "Gheddafi"
    "Kadaffi"
    "Kadafi"
    "Kad'afi"
    "Kaddafi"
    "Kadhafi"
    "Kazzafi"
    "Khadaffy"
    "Khadafy"
    "Khaddafi"
    "Qadafi"
    "Qaddafi"
    "Qadhafi"
    "Qadhaafi"
    "Qadhdhafi"
    "Qadthafi"
    "Qathafi"
    "Quathafi"
    "Qudhafi"
    ! "Qaḏḏāfī"
}
>>

: gaddafi? ( string -- ? )
    names member? ;

: re1-gaddafi? ( string -- ? )
    $[ names "|" join <regexp> ] matches? ;

CONSTANT: names-pattern
    R/ ((al|el)[-\s]?)?(Kh?|Gh?|Qu?)[aeu](d['dt]?|t|zz|dhd)h?aa?ff?[iy]/i

: re2-gaddafi? ( string -- ? )
    names-pattern matches? ;

: normalize-gaddafi ( string -- string' )
    names-pattern "Gaddafi" re-replace ;

CONSTANT: names-soundex {
    "A423" "E423" "G310" "K210" "K310" "Q310" "Q331"
}

: soundex-gaddafi? ( string -- ? )
    soundex names-soundex member? ;

CONSTANT: full-names {
    "Qaddafi, Muammar"
    "Al-Gathafi, Muammar"
    "al-Qadhafi, Muammar"
    "Al Qathafi, Mu'ammar"
    "Al Qathafi, Muammar"
    "El Gaddafi, Moamar"
    "El Kadhafi, Moammar"
    "El Kazzafi, Moamer"
    "El Qathafi, Mu'Ammar"
    "Gadafi, Muammar"
    "Gaddafi, Moamar"
    "Gadhafi, Mo'ammar"
    "Gathafi, Muammar"
    "Ghadafi, Muammar"
    "Ghaddafi, Muammar"
    "Ghaddafy, Muammar"
    "Gheddafi, Muammar"
    "Gheddafi, Muhammar"
    "Kadaffi, Momar"
    "Kad'afi, Mu`amar al-"
    "Kaddafi, Muamar"
    "Kaddafi, Muammar"
    "Kadhafi, Moammar"
    "Kadhafi, Mouammar"
    "Kazzafi, Moammar"
    "Khadafy, Moammar"
    "Khaddafi, Muammar"
    "Moamar al-Gaddafi"
    "Moamar el Gaddafi"
    "Moamar El Kadhafi"
    "Moamar Gaddafi"
    "Moamer El Kazzafi"
    "Mo'ammar el-Gadhafi"
    "Moammar El Kadhafi"
    "Mo'ammar Gadhafi"
    "Moammar Kadhafi"
    "Moammar Khadafy"
    "Moammar Qudhafi"
    "Mu`amar al-Kad'afi"
    "Mu'amar al-Kadafi"
    "Muamar Al-Kaddafi"
    "Muamar Kaddafi"
    "Muamer Gadafi"
    "Muammar Al-Gathafi"
    "Muammar al-Khaddafi"
    "Mu'ammar al-Qadafi"
    "Mu'ammar al-Qaddafi"
    "Muammar al-Qadhafi"
    "Mu'ammar al-Qadhdhafi"
    "Mu'ammar Al Qathafi"
    "Muammar Al Qathafi"
    "Muammar Gadafi"
    "Muammar Gaddafi"
    "Muammar Ghadafi"
    "Muammar Ghaddafi"
    "Muammar Ghaddafy"
    "Muammar Gheddafi"
    "Muammar Kaddafi"
    "Muammar Khaddafi"
    "Mu'ammar Qadafi"
    "Muammar Qaddafi"
    "Muammar Qadhafi"
    "Mu'ammar Qadhdhafi"
    "Muammar Quathafi"
    "Mulazim Awwal Mu'ammar Muhammad Abu Minyar al-Qadhafi"
    "Qadafi, Mu'ammar"
    "Qadhafi, Muammar"
    "Qathafi, Mu'Ammar el"
    "Quathafi, Muammar"
    "Qudhafi, Moammar"
    "Moamar AI Kadafi"
    "Maummar Gaddafi"
    "Moamar Gadhafi"
    "Moamer Gaddafi"
    "Moamer Kadhafi"
    "Moamma Gaddafi"
    "Moammar Gaddafi"
    "Moammar Gadhafi"
    "Moammar Ghadafi"
    "Moammar Khadaffy"
    "Moammar Khaddafi"
    "Moammar el Gadhafi"
    "Moammer Gaddafi"
    "Mouammer al Gaddafi"
    "Muamar Gaddafi"
    "Muammar Al Ghaddafi"
    "Muammar Al Qaddafi"
    "Muammar Al Qaddafi"
    "Muammar El Qaddafi"
    "Muammar Gadaffi"
    "Muammar Gadafy"
    "Muammar Gaddhafi"
    "Muammar Gadhafi"
    "Muammar Ghadaffi"
    "Muammar Qadthafi"
    "Muammar al Gaddafi"
    "Muammar el Gaddafy"
    "Muammar el Gaddafi"
    "Muammar el Qaddafi"
    "Muammer Gadaffi"
    "Muammer Gaddafi"
    "Mummar Gaddafi"
    "Omar Al Qathafi"
    "Omar Mouammer Al Gaddafi"
    "Omar Muammar Al Ghaddafi"
    "Omar Muammar Al Qaddafi"
    "Omar Muammar Al Qathafi"
    "Omar Muammar Gaddafi"
    "Omar Muammar Ghaddafi"
    "Omar al Ghaddafi"
}
