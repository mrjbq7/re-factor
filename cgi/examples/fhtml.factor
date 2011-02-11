#! /Users/jbenedik/Projects/factor/factor 

USE: io

"Content-type: text/html\n\n" print

USE: html.templates.fhtml

"""
<% USING: calendar formatting math math.parser io ; %>

<html>
    <head><title>Simple Embedded Factor Example</title></head>
    <body>
        The time is <% now "%c" strftime write %>.
        <br>
        <% 5 [ %><p>I like repetition</p><% ] times %>
    </body>
</html>

""" parse-template call( -- ) 


