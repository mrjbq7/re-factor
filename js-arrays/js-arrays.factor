USING: accessors delegate delegate.protocols kernel ;

IN: js-arrays

TUPLE: js-array seq assoc ;

: <js-array> ( -- js-array )
    V{ } clone H{ } clone js-array boa ;

INSTANCE: js-array sequence

CONSULT: sequence-protocol js-array seq>> ;

INSTANCE: js-array assoc

CONSULT: assoc-protocol js-array assoc>> ;
