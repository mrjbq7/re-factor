#! /Users/jbenedik/Projects/factor/factor

USING: assocs environment kernel io namespaces
sequences sorting ;

"Content-type: text/html\n\n" print

"""
<html>
<head>
<title>Debug</title>
</head>
<body>
<pre class=debug style='overflow-x: scroll'>
""" print

os-envs sort-keys [
    [ "<b>" write first write "</b>" write ]
    [ " = " write second write nl ] bi
] each

"""
</pre>
</body>
</html>
""" print

