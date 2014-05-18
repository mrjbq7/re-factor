
USING: tools.test ;

IN: shortuuid

{ "VoVuUtBhZ6TvQSAYEqNdF5" }
[ "12345678-1234-5678-1234-567812345678" encode-uuid ] unit-test

{ "12345678-1234-5678-1234-567812345678" }
[ "VoVuUtBhZ6TvQSAYEqNdF5" decode-uuid ] unit-test
