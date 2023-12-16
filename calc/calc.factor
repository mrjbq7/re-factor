! Copyright (C) 2008 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: fry kernel macros math math.functions math.parser 
peg.ebnf quotations sequences strings ;

IN: calc

<PRIVATE

EBNF: parse-calc [=[

space    = (" "|"\t"|"\n")+

sign     = "-"                => [[ >string ]]
whole    = ([0-9])*           => [[ >string ]]
digit    = "." ([0-9])*       => [[ [ >string ] map concat ]]

number_  = sign? whole digit? 
         => [[ [ f eq? ] reject concat string>number ]]

number   = space number_ space => [[ second 1quotation ]]

add      = "+"  => [[ [ +         ] ]] 
sub      = "-"  => [[ [ -         ] ]] 
mul      = "*"  => [[ [ *         ] ]] 
div      = "/"  => [[ [ /         ] ]]
mod      = "%"  => [[ [ mod       ] ]]
pow      = "^"  => [[ [ ^         ] ]]
rshift   = ">>" => [[ [ shift     ] ]]
lshift   = "<<" => [[ [ neg shift ] ]]

ops_     = add|sub|mul|div|mod|pow|rshift|lshift
ops      = space ops_ space => [[ second ]] 

abs      = "abs"   => [[ [ abs     ] ]]
ceil     = "ceil"  => [[ [ ceiling ] ]]
cosh     = "cosh"  => [[ [ cosh    ] ]]
cos      = "cos"   => [[ [ cos     ] ]]
coth     = "coth"  => [[ [ coth    ] ]]
cot      = "cot"   => [[ [ cot     ] ]]
exp      = "exp"   => [[ [ e^      ] ]]
float    = "float" => [[ [ >float  ] ]]
floor    = "floor" => [[ [ floor   ] ]]
int      = "int"   => [[ [ >fixnum ] ]]
log10    = "log10" => [[ [ log10   ] ]]
log      = "log"   => [[ [ log     ] ]]
round    = "round" => [[ [ round   ] ]]
sinh     = "sinh"  => [[ [ sinh    ] ]]
sin      = "sin"   => [[ [ sin     ] ]]
sqrt     = "sqrt"  => [[ [ sqrt    ] ]]
tanh     = "tanh"  => [[ [ tanh    ] ]]
tan      = "tan"   => [[ [ tan     ] ]]

funcs_   = abs|ceil|cosh|cos|coth|cot|exp|float|floor|int|log10|log|round|sinh|sin|sqrt|tanh|tan
funcs    = space funcs_ space => [[ second ]]

function = funcs_? "(" {function|number_}* ")" 
         => [[ [ third concat >quotation ] [ first ] bi [ append ] when* ]]

]=]

! expr     = function|number
! 
! lhs      = expr => [[ ]]
! rhs      = ops expr => [[ reverse concat ]]
! 
! equation = lhs rhs* => [[ [ first ] [ second concat ] bi append ]] 

PRIVATE>

MACRO: calc ( string -- ) parse-calc ;







EBNF: parse-calc2 [=[

number = ([0-9])+ => [[ >string string>number 1quotation ]]

sqrt  = "sqrt" => [[ [ sqrt ] ]]
sin   = "sin"  => [[ [ sin  ] ]]

names = sqrt|sin

space = (" "|"\t"|"\n")+ => [[ [ ] ]]

func  = names "(" number ")" 
      => [[ [ third ] [ first ] bi append ]]

group = "(" {group|number|func}+ ")" => [[ second concat >quotation ]]
expr = number|func|group

add = "+" => [[ [ + ] ]]
sub = "-" => [[ [ - ] ]]
ops = add|sub

lhs      = expr => [[ ]]
rhs      = ops expr => [[ reverse concat ]]

equation = lhs rhs* => [[ [ first ] [ second concat ] bi append ]] 

equations = "(" {equations|equation}+ ")" => [[ second concat >quotation ]]

text = (equation|equations)* => [[ concat ]]

]=]

! error = (.)* => [[ "Invalid expression" throw ]]
! text  = space? equation space? => [[ second concat ]] 
! text_ = text|error

MACRO: calc2 ( string -- ) parse-calc2 ;



