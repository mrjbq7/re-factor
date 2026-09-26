USING: assocs help.markup help.syntax strings ;
IN: ternary-search-trees

HELP: ternary-search-tree
{ $class-description "An association with string keys, supporting exact lookup and lexicographic prefix lookup. Keys are compared by Unicode code point; normalization and case folding are the caller's responsibility. Empty keys and false values are supported. The tree is not balanced. Deletion clears the entry but retains its nodes until the tree is cleared or discarded." } ;

HELP: <ternary-search-tree>
{ $values { "tree" ternary-search-tree } }
{ $description "Creates an empty ternary search tree." } ;

HELP: >ternary-search-tree
{ $values { "assoc" assoc } { "tree" ternary-search-tree } }
{ $description "Copies an association with string keys into a new ternary search tree. Insertion order affects its shape." } ;

HELP: prefix>alist
{ $values { "prefix" string } { "tree" ternary-search-tree } { "alist" "an association list" } }
{ $description "Returns all entries whose keys begin with the prefix, sorted by key. The prefix itself is included if it is a stored key. An empty prefix returns all entries. The result contains new key strings and pairs, with the original values." } ;
