#! /Users/jbenedik/Projects/factor/factor

IN: calc

USE: assocs
USE: cgi
USE: combinators
USE: formatting
USE: io
USE: kernel
USE: math
USE: math.parser
USE: namespaces
USE: system

system-micros "now" set

"Content-type: text/html\n\n" write

"""
<html>
<head>
<title>Calculator</title>
</head>
<body>

<form method='post'>
""" write

: input-text ( value name size -- )
    "<input type='text' value='%s' name='%s' size='%d'>"
    printf ;

<cgi-simple-form>
{
    [ "x"      [ of "3" or ] keep 10 input-text ]
    [ "action" [ of "+" or ] keep 4  input-text ]
    [ "y"      [ of "5" or ] keep 10 input-text ]
    [ " = " write drop ]
    [ "result" [ of "8" or ] keep 10 input-text ]
} cleave

"""
<input type='submit'>
</form>

<pre>
""" write

system-micros "now" get - 1000.0 / 
number>string write " ms" write

"""
</pre>
</body>
</html>
""" write

