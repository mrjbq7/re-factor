
USING: kernel namespaces tools.test ;

IN: shortuuid

{ "VoVuUtBhZ6TvQSAYEqNdF5" }
[ "12345678-1234-5678-1234-567812345678" encode-uuid ] unit-test

{ "12345678-1234-5678-1234-567812345678" }
[ "VoVuUtBhZ6TvQSAYEqNdF5" decode-uuid ] unit-test

{ t } [
    "01" alphabet [
        "12345678-1234-5678-1234-567812345678"
        dup encode-uuid decode-uuid =
    ] with-variable
] unit-test
