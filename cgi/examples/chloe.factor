#! /Users/jbenedik/Projects/factor/factor 

USE: io

"Content-type: text/html\n\n" print

USE: assocs
USE: cgi
USE: html.forms
USE: html.templates.chloe
USE: html.templates.chloe.compiler
USE: kernel
USE: multiline
USE: sequences
USE: splitting
USE: xml

"""
<html>
<head>
<title>Chloe</title>
</head>
<body>
<form method="get">
<input type="text" name="numbers" value="
""" print

begin-form 

<cgi-simple-form> "numbers" of "" or 
[ write ] 
[ "," split [ empty? not ] filter "numbers" set-value ] bi

"""
">
<input type="submit">
</form>
""" print

"""
<t:chloe xmlns:t="http://factorcode.org/chloe/1.0">

    <ul>
        <t:each t:name="numbers">
            <li><t:label t:name="value"/></li>
        </t:each>
    </ul>

</t:chloe>
""" string>xml compile-template call( -- )

"""
</body>
</html>
""" print


