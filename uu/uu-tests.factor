
USING: io.streams.string kernel tools.test ;

IN: uu

CONSTANT: plain
"The smooth-scaled python crept over the sleeping dog"

CONSTANT: encoded
"""begin
M5&AE('-M;V]T:"US8V%L960@<'ET:&]N(&-R97!T(&]V97(@=&AE('-L965P
':6YG(&1O9P  
end
"""

{ t } [ plain string>uu encoded = ] unit-test
{ t } [ encoded uu>string plain = ] unit-test
