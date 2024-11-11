USING: subdomains tools.test ;

{ "factorcode.org" } [
    "www.mail.ftp.localhost.factorcode.org"
    remove-common-subdomains
] unit-test

{ V{ "b.c" "c.d.e" "e.f" } } [
    { "a.b.c" "b.c" "c.d.e" "e.f" }
       remove-observed-subdomains
] unit-test

{ t } [ "re.factorcode.org" valid-domain? ] unit-test
{ f } [ "not-valid.factorcode.org" valid-domain? ] unit-test

{ { "a.b.c.com" "b.c.com" "c.com" } } [
    "a.b.c.com" split-domain
] unit-test

{ "factorcode.org" } [
    "a.b.c.d.factorcode.org" remove-subdomains
] unit-test
{ "cr.yp.to" } [
    "sorting.cr.yp.to" remove-subdomains
] unit-test
