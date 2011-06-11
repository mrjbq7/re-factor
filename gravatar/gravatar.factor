! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors assocs formatting http.client images.http
images.jpeg json.reader kernel sequences strings utils ;

IN: gravatar

TUPLE: info aboutMe accounts currentLocation displayName emails
hash id ims name phoneNumbers photos preferredUsername
profileBackground profileUrl requestHash thumbnailUrl urls ;

: gravatar-info ( gravatar-id -- info )
    "http://gravatar.com/%s.json" sprintf http-get nip
    >string json> "entry" swap at first info from-slots ;

: gravatar. ( gravatar-id -- )
    gravatar-info thumbnailUrl>> http-image. ;


