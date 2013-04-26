! Copyright (C) 2013 John Benediktsson
! See http://factorcode.org/license.txt for BSD license
USING: accessors assocs hashtables kernel ;
IN: missing-assocs

TUPLE: missing-assoc assoc quot ;

: <missing-assoc> ( assoc quot: ( key -- value ) -- missing-assoc )
    missing-assoc boa ; inline

: <missing-hash> ( capacity quot: ( key -- value ) -- missing-assoc )
    [ <hashtable> ] dip <missing-assoc> ; inline

: <default-assoc> ( assoc quot: ( -- value ) -- default-assoc )
    [ drop ] prepose <missing-assoc> ; inline

: <default-hash> ( capacity quot: ( -- value ) -- default-assoc )
    [ drop ] prepose <missing-hash> ; inline

M: missing-assoc at*
    [ assoc>> at* ] 2keep pick [ 2drop ] [
        [ 2drop ] 2dip
        [ dupd quot>> call( key -- value ) swap ]
        [ [ assoc>> set-at ] 3keep 2drop t ] bi
    ] if ;

M: missing-assoc set-at assoc>> set-at ; inline
M: missing-assoc delete-at assoc>> delete-at ; inline
M: missing-assoc >alist assoc>> >alist ; inline
M: missing-assoc keys assoc>> keys ; inline
M: missing-assoc values assoc>> values ; inline
M: missing-assoc assoc-size assoc>> assoc-size ; inline
M: missing-assoc clear-assoc assoc>> clear-assoc ; inline

INSTANCE: missing-assoc assoc
