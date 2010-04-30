! Copyright (C) 2009 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: help.syntax help.markup ipinfodb sequences strings ;

IN: ipinfodb

HELP: locate-my-ip
{ $description
    "Returns a tuple representing the geolocation of the callers IP address."
} ;

HELP: locate-ip
{ $values { "ip" string } { "info" ip-info } }
{ $description 
    "Returns a tuple representing the geolocation of the specified IP address."
} ;

HELP: locate-ips
{ $values { "ips" sequence } { "infos" sequence } }
{ $description 
    "Returns a sequence of tuples representing the geolocation of the "
    "specified IP addresses."
} ;

HELP: locate-ip2
{ $values { "ip/domain" string } { "info" ip-info } }
{ $description
    "Returns a tuple representing the geolocation of the specified IP "
    "address or domain name."
} ;

