var a = new Graph();

log( a );

a.add_edge( "a", "b", [[ "color", "red" ]] );
a.add_edge( "a", "c", 2 );
a.add_edge( "b", "c", 3, [[ "color", "blue" ]] );

log( a );

a.remove_edge( "a", "b" );

log( a );