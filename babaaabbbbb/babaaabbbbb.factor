
USING: arrays assocs deques dlists formatting grouping io kernel
literals make math prettyprint sequences sequences.extras sets
sorting splitting ;

IN: babaaabbbbb

<<
CONSTANT: rules {
    { "bab" "aaa" }
    { "bbb" "bb" }
}
>>

CONSTANT: all-rules $[
    rules dup [ swap ] assoc-map append
]

:: each-move ( from a b quot: ( next -- ) -- )
    from dup a subseq-indices [
        cut a length tail b glue quot call
    ] with each ; inline

: all-moves ( from -- moves )
    [ all-rules [ first2 [ , ] each-move ] with each ] { } make ;

:: all-paths% ( path -- )
    path last all-rules [
        first2 [ path swap suffix , ] each-move
    ] with each ;

: all-paths ( paths -- paths' )
    [ [ all-paths% ] each ] { } make members ;

:: shortest-paths ( from to -- moves )
    HS{ from } clone :> seen
    { { from } }     :> stack!

    f [
        drop

        ! find all next possibilities
        stack all-paths

        ! reject ones that circle back to visited nodes
        [ last seen in? ] reject

        ! reject any that are over the length of ``to``
        to length '[ last length _ > ] reject stack!

        ! add the newly visited nodes
        stack [ last seen adjoin ] each

        ! stop when we find any solutions
        stack [ last to = ] filter dup empty?
    ] loop ;

: shortest-edges ( from to -- edges )
    shortest-paths [ 2 clump ] map concat [ sort ] map members ;

:: full-graph ( from to -- graph rank )
    HS{ } clone :> seen

    HS{ } clone :> graph

    V{ } clone  :> rank

    { { from } } :> stack!

    [ stack empty? ] [

        ! find all next possibilities
        stack all-paths

        ! reject any that are over the length of ``to``
        to length '[ last length _ > ] reject stack!

        ! update the graph with new edges
        stack [ 2 tail* sort graph adjoin ] each

        ! only include ones that visit new nodes
        stack [ last seen ?adjoin ] filter stack!

        ! track new nodes by rank
        stack [ last ] map [ rank push ] unless-empty

    ] until graph members [ sort ] map members sort rank ;

:: full-graph. ( from to -- )
    "graph D {" print
    "  overlap=false;" print
    "  layout=sfdp;" print
    "  splines=curved;" print
    from "  %s [fillcolor=green, style=filled];\n" printf
    to "  %s [fillcolor=deepskyblue, style=filled];\n" printf
    from to shortest-edges fast-set :> moves
    moves members concat { from to } diff
    [ "  %s [fillcolor=gray, style=filled];\n" printf ] each
    from to full-graph swap
    [ moves in? ] partition
    [ [ "  %s -- %s [color=red,penwidth=3.0];\n" printf ] assoc-each ]
    [ [ "  %s -- %s;\n" printf ] assoc-each ] bi*
    [ ", " join "  { rank=same; %s }\n" printf ] each
    "}" print ;

! "aaaaaaaa" "aaaaaaaaaa" shortest-moves .

! notice symmetry for graph reduction: ababaaaa aaaababa

! cycles:
!
!         0
!     1       2
!         3
