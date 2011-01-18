
USING: help.markup help.syntax strings webbrowser ;

IN: webbrowser

HELP: open-file
{ $values { "path" string } }
{ $description
    "Open a specified path using the default application."
} ;

HELP: open-url
{ $values { "url" string } }
{ $description
    "Open a specified url in the default web browser."
} ;
