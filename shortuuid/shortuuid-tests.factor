
USING: kernel namespaces tools.test ;

IN: shortuuid

{ "VoVuUtBhZ6TvQSAYEqNdF5" } [
    t legacy? [
        "12345678-1234-5678-1234-567812345678" encode-uuid
    ] with-variable
] unit-test

{ "12345678-1234-5678-1234-567812345678" } [
    t legacy? [
        "VoVuUtBhZ6TvQSAYEqNdF5" decode-uuid
    ] with-variable
] unit-test

{ "CXc85b4rqinB7s5J52TRYb" }
[ "3b1f8b40-222c-4a6e-b77e-779d5a94e21c" encode-uuid ] unit-test

{ "3b1f8b40-222c-4a6e-b77e-779d5a94e21c" }
[ "CXc85b4rqinB7s5J52TRYb" decode-uuid ] unit-test

{ t } [
    "01" alphabet [
        "12345678-1234-5678-1234-567812345678"
        dup encode-uuid decode-uuid =
    ] with-variable
] unit-test
