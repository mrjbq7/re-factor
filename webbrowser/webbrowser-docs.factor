
USING: help.markup help.syntax strings webbrowser ;

IN: webbrowser

HELP: open-url
{ $values { "url" string } }
{ $description
    "Open a specified url in the default web browser."
} ;

HELP: open-file
{ $values { "file" string } }
{ $description
    "Open a specified file using the default application."
} ;
