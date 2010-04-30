! Copyright (C) 2008 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: help.syntax help.markup calc strings ;

IN: calc

HELP: calc
{ $values { "expression" string } }
{ $description
    "Calculates a mathematical expression."
    $nl
    "Operations:"
    { $table 
        { "+" "add" }
        { "-" "subtract" }
        { "*" "multiply" }
        { "/" "divide" }
        { "%" "modulo" }
        { "^" "power" }
        { ">>" "right shift" }
        { "<<" "left shift" }
    }
    $nl
    "Functions:"
    { $table 
        { "abs" }
        { "ceil" }
        { "cos" }
        { "cosh" }
        { "cot" }
        { "coth" }
        { "exp" }
        { "float" }
        { "floor" }
        { "int" }
        { "log" }
        { "log10" }
        { "round" }
        { "sin" }
        { "sinh" }
        { "sqrt" }
        { "tan" }
        { "tanh" }
    }
} 
{ $examples
    { $example
        "USING: calc ;"
        "\"2+3\" calc"
        "5" }
    { $example 
        "USING: calc ;"
        "\"sin(3)\" calc"
        "0.1411200080598672" }
    { $example
        "USING: calc ;"
        "\"15+sqrt(2)\" calc"
        "16.4142135623731" }
} ;

