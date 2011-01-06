! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: fry kernel make math math.order math.ranges random
sequences ;

IN: hello-ga


CONSTANT: TARGET "Hello, World!"

: fitness ( chromosome -- n )
    TARGET 0 [ - abs - ] 2reduce ;

CONSTANT: POPULATION 400

: random-chromosome ( -- chromosome )
    TARGET length [ 256 random ] "" replicate-as ;

: random-population ( -- seq )
    POPULATION [ random-chromosome ] replicate ;

CONSTANT: CHILDREN-PROBABILITY 0.9

: children? ( -- ? )
    0.0 1.0 uniform-random-float CHILDREN-PROBABILITY < ;

: head/tail ( seq1 seq2 n -- head1 tail2 )
    [ head ] [ tail ] bi-curry bi* ;

: tail/head ( seq1 seq2 n -- tail1 head2 )
    [ tail ] [ head ] bi-curry bi* ;

: children ( parent1 parent2 -- child1 child2 )
    TARGET length [1,b) random
    [ head/tail append ] [ tail/head prepend ] 3bi ;

CONSTANT: MUTATION-PROBABILITY 0.2

: mutation? ( -- ? )
    0.0 1.0 uniform-random-float MUTATION-PROBABILITY < ;

: mutate ( chromosome -- chromosome' )
    dup length random over [ -5 5 [a,b] random + ] change-nth ;

: fittest ( parent1 parent2 -- parent1' parent2' )
    2dup [ fitness ] bi@ > [ swap ] when ;

: tournament ( seq -- parent )
    dup [ random ] bi@ fittest nip ;

: parents ( seq -- parent1 parent2 )
    dup [ tournament ] bi@ ;

: (1generation) ( seq -- child1 child2 )
    parents children? [ children ] when
    mutation? [ [ mutate ] bi@ ] when ;

: 1generation ( seq -- seq' )
    [ length 2 / ] keep
    '[ _ [ _ (1generation) , , ] times ] { } make ;

: finished? ( seq -- ? )
    TARGET swap member? ;

: all-generations ( seq -- seqs )
    [
        [ 1generation dup , dup finished? not ] loop drop
    ] { } make ;




