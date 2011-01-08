#! /Users/jbenedik/Projects/factor/factor

USING: assocs brainfuck cgi formatting io kernel ;

"Content-type: text/html\n\n" write

"code" <cgi-simple-form> at
"""
++++++++++[>+++++++>++++++++++>+++>+<<<<-]
>++.>+.+++++++..+++.>++.<<+++++++++++++++.>.+++.
------.--------.>+.>.
""" or dup get-brainfuck

"""
<html>
<head><title>Brainfuck</title></head>
<body>
<form method='get'>
<textarea id="text" name="code" cols="80" rows="15">
%s
</textarea><br>
<input type="submit" value="Submit">&nbsp;
<input type="reset" value="Reset">
</form>
<pre>
%s
</pre>
</body>
</html>
""" printf

