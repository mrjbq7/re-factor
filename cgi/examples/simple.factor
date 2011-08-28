#! /Users/jbenedik/Projects/factor/factor

USE: system
USE: namespaces
USE: math
USE: math.parser

system-micros "now" set

USING: assocs cgi combinators kernel io multiline ;

"Content-type: text/html\n\n" print

"""
<html>
<head>
<title>Testing</title>
<style>
.debug {
    border: 1px darkgray solid;
    background-color: #ececec;
    padding: 5px;
}
</style>

</head>
<body>

<pre class=debug style='overflow-x: scroll'>
""" print

USE: environment
USE: sequences
USE: sorting

os-envs sort-keys [
    [ "<b>" write first write "</b>" write ]
    [ " = " write second write nl ] bi
] each

"""
</pre>

<form method='post'>
""" print

USE: prettyprint

<cgi-simple-form>
{
    [
        "<label for='a'>A</label>" write
        "<input type='text' name='a' size='20' value='" write
        "a" swap at [ write ] when* 
        "'><br>" print
    ]
    [
        "<label for='b'>B</label>" write
        "<input type='text' name='b' size='20' value='" write
        "b" swap at [ write ] when* "'><br>" print
    ]
} cleave

"""
<input type='submit'>
</form>

<pre class=debug>
""" print

system-micros "now" get - 1000.0 / 
number>string write " ms" write

"""
</pre>
</body>
</html>
""" print

