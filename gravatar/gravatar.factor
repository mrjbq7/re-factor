! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: assocs formatting http.client images.http images.jpeg
json.reader kernel sequences strings utils ;

IN: gravatar

TUPLE: info aboutMe accounts currentLocation displayName emails
hash id ims name phoneNumbers photos preferredUsername
profileBackground profileUrl requestHash thumbnailUrl urls ;

: gravatar-info ( gravatar-id -- data )
    "http://gravatar.com/%s.json" sprintf http-get nip
    >string json> "entry" swap at first
    info new [ set-slots ] keep ;

: gravatar. ( gravatar-id -- )
    "http://gravatar.com/avatar/%s.jpg" sprintf http-image. ;


