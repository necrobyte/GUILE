#region Graph

var g = new Graph();

g.add_edges_from( irange( 3 ).combinations( 2 ) );

assert( g.has_node( 1 ), "has node 1" );
assert( !g.has_node( 4 ), "has node 2" );
assert( !g.has_node( "b" ), "has node 3" );

assert_equals( 3, g.order(), "order" );
assert_equals( [ 0, 1, 2 ], g.nodes().sorted().to_array(), "nodes" );

assert( g.has_edge( 1, 2 ), "has edge 1" );
assert( !g.has_edge( 0, 3 ), "has edge 2" );

assert( is_undefined( g.get_edge( 0, 3 ) ), "get edge 1" );
assert_equals( 1, g.get_weight( 1, 2 ), "get edge 2" );

assert_equals( [ 0, 2 ], g.neighbors( 1 ).sorted().to_array(), "nodes" );

assert_equals( g.in_degree( ), g.out_degree( ), "degree 1" );
assert_equals( g.in_degree( 1 ), g.out_degree( 1 ), "degree 2" );
assert_equals( g.in_degree( [ 1, 2 ] ).sorted( string ).to_array(), g.out_degree( [ 1, 2 ] ).sorted( string ).to_array(), "degree 3" );

assert_array_equals( iter_permutations( "012", 2 ).to_array(), g.edges().sorted( string ).to_array(), "edges" );

assert_equals( [ 0, 1, 2 ], g.get_from().sorted().to_array(), "get from 1" );
assert_equals( 1, g.get_from( 1 ), "get from 2" );
assert( is_undefined( g.get_from( 3 ) ), "get from 3" );
assert_equals( [ 2 ], g.get_from( irange( 2, 4 ) ).to_array(), "get from 4" );

assert_array_equals( iter_permutations( "012", 2 ).to_array(), g.get_edges_from().sorted( string ).to_array(), "get edges from 1" );
assert_equals( [ 1, 2 ], g.get_edges_from( 1, 2 ), "get edges from 2" );
assert( is_undefined( g.get_edges_from( 1, 3 ) ), "get edges from 3" );
assert_array_equals( iter_combinations( "012", 2 ).to_array(), g.get_edges_from( iter_combinations( "0123", 2 ) ).to_array(), "get edges from 4" );

g = graph_complete( 3, new GraphStructs( ) );
var g1 = g.copy();
g.get( 0 ).text = "hello";
assert_equals( "hello", g1.get( 0 ).text, "shallow copy 1" );
g1.get_edge( 0, 1 ).weight = 2;
assert_equals( 4, g.size(), "size 1" );
assert_equals( 2, g.get_edge( 0, 1 ).weight, "shallow copy 2" );

var g1 = g.copy( true );
g.get( 0 ).text = "world";
assert_equals( "hello", g1.get( 0 ).text, "deep copy 1" );
g.set_weight( 0, 1, 1 );
assert_equals( 2, g1.get_weight( 0, 1 ), "deep copy 2" );

g.update( g1 );
g.get( 0 ).text = "foo";
assert_equals( "foo", g1.get( 0 ).text, "shallow update 1" );
g1.get_edge( 0, 1 ).weight = 3;
assert_equals( 5, g.size(), "size 2" );
assert_equals( 3, g.get_edge( 0, 1 ).weight, "shallow update 2" );

g1.update( g, true );
g.get( 0 ).text = "bar";
assert_equals( "foo", g1.get( 0 ).text, "deep update 1" );
g.set_weight( 0, 1, 2 );
assert_equals( 3, g1.get_weight( 0, 1 ), "deep update 2" );

g1 = g.subgraph( [ 0, 1 ] );
assert_equals( 3, g1.size(), "size 3" );
assert( g1.is_subgraph( g ), "is subgraph 1" );
assert( !g.is_subgraph( g1 ), "is subgraph 2" );
assert_equals( [ 0, 1 ], g1.nodes().sorted().to_array(), "subgraph shallow 1" );
assert_equals( 3, g1.get_edge( 0, 1 ).weight, "subgraph shallow 2" );
g.get( 0 ).text = "herp";
assert_equals( "herp", g1.get( 0 ).text, "subgraph shallow 3" );
g1.get_edge( 0, 1 ).weight = 2;
assert_equals( 2, g.get_edge( 0, 1 ).weight, "subgraph shallow 4" );

g1 = g.subgraph( [ 0, 2 ], true );
assert( g1.is_subgraph( g ), "is subgraph 3 " );
assert_equals( [ 0, 2 ], g1.nodes().sorted().to_array(), "subgraph deep 1" );
assert_equals( 1, g1.get_weight( 0, 2 ), "subgraph deep 2" );
g.get( 0 ).text = "derp";
assert_equals( "herp", g1.get( 0 ).text, "subgraph deep 3" );
g.set_weight( 0, 2, 2 );
assert_equals( 1, g1.get_weight( 0, 2 ), "subgraph deep 4" );

g.add_nodes_from( "hello" );
assert_equals( [ 0, 1, 2, "e", "h", "l", "o" ], g.nodes().sorted( string ).to_array(), "nodes add from" );
g.remove_nodes_from( "hello" );
assert_equals( [ 0, 1, 2 ], g.nodes().sorted().to_array(), "remove nodes from 1" );
g.remove_edges_from( [ 1, 2 ] );
assert_array_equals( [ [ 0, 1 ], [ 0, 2 ], [ 1, 0 ], [ 2, 0 ] ], g.edges().sorted( string ).to_array(), "remove edges from 1" );
g.remove_edges_from( iter_combinations( "012", 2 ) );
assert_equals( [ ], g.edges().to_array(),  "remove edges from 2" );

g.add_edges_from( [ [ 0, 1 ], [ 1, 2 ], [ 1, 3 ] ] );
assert_array_equals( [ [ 1, 0 ], [ 1, 2 ],[ 1, 3 ] ], g.out_edges( 1 ).sorted( string ).to_array(), "out edges 1" );
assert_array_equals( [ [ 0, 1 ], [ 3, 1 ] ], g.out_edges( [ 0, 3 ] ).sorted( string ).to_array(), "out edges 2" );
assert_array_equals( [ [ 0, 1 ], [ 2, 1 ],[ 3, 1 ] ], g.in_edges( 1 ).sorted( string ).to_array(), "in edges 1" );
assert_array_equals( [ [ 1, 0 ], [ 1, 3 ] ], g.in_edges( [ 0, 3 ] ).sorted( string ).to_array(), "in edges 2" );

assert_equals( 4, g.degree( ), "degree 1" );
assert_equals( 3, g.degree( 1 ), "degree 2" );
assert_equals( [ [ 0, 1 ],[ 1, 3 ],[ 2, 1 ],[ 3, 1 ] ], g.degree( irange( 5 ) ).sorted( string ).to_array(), "degree 3" );

g1 = g.subgraph_edges( [ [ 0, 1 ],[ 1, 3 ] ] );
assert( g1.is_subgraph( g ), "is subgraph 4" );
assert_equals( [ 0, 1, 3 ], g1.nodes().sorted().to_array(), "subgraph edges shallow 1" );
g.get( 0 ).text = "cat";
assert_equals( "cat", g1.get( 0 ).text, "subgraph edges shallow 2" );
g1.get_edge( 0, 1 ).weight = 2;
assert_equals( 2, g.get_edge( 0, 1 ).weight, "subgraph edges shallow 3" );

assert_equals( g.successors( 1 ).sorted().to_array, g.predecessors( 1 ).sorted().to_array, "neighbors 1" );

var g1 = graph_cycle( 7 );
var g2 = graph_cycle( 7, true );

assert_equals( [ 0, 1, 2, 3 ], g1.shortest_path( 0, 3 ), "shortest path 1" );
assert_equals( [ 0, 6, 5, 4 ], g1.shortest_path( 0, 4 ), "shortest path 2" );
assert_equals( [ 0, 1, 2, 3 ], g2.shortest_path( 0, 3 ), "shortest path 3" );
assert_equals( [ 0, 1, 2, 3, 4 ], g2.shortest_path( 0, 4 ), "shortest path 4" );

assert_array_equals( [ [ 0, [ 1, 0 ] ], [ 1, [ 1 ] ], [ 2, [ 1, 2 ] ] ], iter_sorted( graph_path( 3 ).shortest_path( 1 ), function( a ) { return a[ 0 ] } ).to_array(), "shortest path 5" );
assert_array_equals( [ [ 0, [ 0, 1 ] ], [ 1, [ 1 ] ], [ 2, [ 2, 1 ] ] ], iter_sorted( graph_path( 3 ).shortest_path( undefined, 1 ), function( a ) { return a[ 0 ] } ).to_array(), "shortest path 6" );

assert_array_equals( [ [ 0, 0 ],[ 1, 1 ],[ 2, 2 ],[ 3, 3 ],[ 4, 3 ],[ 5, 2 ],[ 6, 1 ] ], iter_sorted( g1.shortest_path_length( 0 ), function( a ) { return a[ 0 ] } ).to_array(), "shortest path length 1" );
assert_array_equals( [ [ 0, 0 ],[ 1, 1 ],[ 2, 2 ],[ 3, 3 ],[ 4, 4 ],[ 5, 5 ],[ 6, 6 ] ], iter_sorted( g2.shortest_path_length( 0 ), function( a ) { return a[ 0 ] } ).to_array(), "shortest path length 2" );

assert( g1.has_path( 0, 1 ), "has node 1" );
assert( !g2.has_path( 0, -1 ), "has node 2" );

var g1 = graph_empty();
g1.add_edges_from( [ [ 0, 1 ], [ 1, 2 ], [ 1, 3 ], [ 2, 4 ], [ 3, 4 ] ] );
assert_equals( [ [ 0, 1 ], [ 1, 2 ], [ 1, 3 ], [ 2, 4 ] ], g1.bfs_edges( 0 ).to_array(), "bfs edges 1" );
assert_equals( [ [ 0,[ 1 ] ],[ 1,[ 2, 3 ] ],[ 2,[ 4 ] ] ], iter_sorted( g1.bfs_successors( 0 ), function( e ) { return e[ 0 ]; } ).to_array(), "bfs successors 1" );
assert_equals( [ [ 1, 0 ],[ 2, 1 ],[ 3, 1 ],[ 4, 2 ] ], iter_sorted( g1.bfs_predecessors( 0 ), function( e ) { return e[ 0 ]; } ).to_array(), "bfs predecessors 1" );

assert_equals( [ [ 0, 1 ], [ 1, 2 ], [ 2, 4 ], [ 4, 3 ] ], g1.dfs_edges( 0 ).to_array(), "dfs edges 1" );
assert_equals( [ [ 0, [ 1 ] ], [ 1, [ 2 ] ], [ 2, [ 4 ] ], [ 4, [ 3 ] ] ], iter_sorted( g1.dfs_successors( 0 ), function( e ) { return e[ 0 ]; } ).to_array(), "dfs successors 1" );
assert_equals( [ [ 1, 0 ],[ 2, 1 ],[ 3, 4 ],[ 4, 2 ] ], iter_sorted( g1.dfs_predecessors( 0 ), function( e ) { return e[ 0 ]; } ).to_array(), "dfs predecessors 1" );

g = graph_empty();
g.add_nodes_from( [ 1, 2 ] );
assert_equals( [ 1 ], g.bfs_nodes( 1 ).to_array(), "bfs nodes" );
assert_equals( [ ], g.bfs_edges( 1 ).to_array(), "bfs edges 1" );
assert_equals( [ 1 ], g.dfs_nodes( 1 ).to_array(), "dfs nodes" );
assert_equals( [ ], g.dfs_edges( 1 ).to_array(), "dfs edges 1" );

g1 = graph_path( [ 2, 7, 8, 9, 10 ], graph_path( 7 ) ) ;
g2 = graph_path( [ 3, 2, 7, 8, 9, 10 ], graph_path( 2 ) );

// TODO: make this test more reliable
assert_equals( [ [ 9, 10 ], [ 9, 8 ], [ 8, 7 ], [ 7, 2 ], [ 2, 3 ], [ 2, 1 ] ], g1.bfs_edges( 9, 4 ).to_array(), "bfs edges 2" );
log( [ [ 9, 10 ], [ 9, 8 ], [ 8, 7 ], [ 7, 2 ], [ 2, 3 ], [ 2, 1 ] ], g1.bfs_edges( 9, 4 ).to_array(), "bfs edges 2" );
assert_equals( [ [ 1, [ 0, 2 ] ], [ 2, [ 3, 7 ] ], [ 3,[ 4 ] ], [ 7,[ 8 ] ] ], iter_sorted( g1.bfs_successors( 1, 3 ), function( e ) { return e[ 0 ]; } ).map( function( e ) { return [ e[ 0 ], array_key_sort( e[ 1 ] ) ]; } ).to_array(), "bfs successors 2" );
assert_equals( [ [ 2,[ 3 ] ],[ 7,[ 2, 8 ] ],[ 8,[ 9 ] ] ], iter_sorted( g2.bfs_successors( 7, 2 ), function( e ) { return e[ 0 ]; } ).map( function( e ) { return [ e[ 0 ], array_key_sort( e[ 1 ] ) ]; } ).to_array(), "bfs successors 3" );
assert_equals( [ [ 0 ,1 ], [ 2 ,1 ], [ 3, 2 ], [ 4, 3 ], [ 7, 2 ], [ 8, 7 ] ], iter_sorted( g1.bfs_predecessors( 1, 3 ), function( e ) { return e[ 0 ]; } ).to_array(), "bfs predessors 2" );
assert_equals( [ [ 2, 7 ], [ 3, 2 ], [ 8, 7 ], [ 9, 8 ] ], iter_sorted( g2.bfs_predecessors( 7, 2 ), function( e ) { return e[ 0 ]; } ).to_array(), "bfs predessors 3" );

// TODO: make this test more reliable
assert_equals( [ [ 9, 10 ], [ 9, 8 ], [ 8, 7 ], [ 7, 2 ], [ 2, 3 ], [ 2, 1 ]  ], g1.dfs_edges( 9, 4 ).to_array(), "dfs edges 2" );
assert_equals( [ [ 2, [ 1, 7 ] ], [ 3, [ 2 ] ], [ 4,[ 3, 5 ] ], [ 5,[ 6 ] ] ], iter_sorted( g1.dfs_successors( 4, 3 ), function( e ) { return e[ 0 ]; } ).map( function( e ) { return [ e[ 0 ], array_key_sort( e[ 1 ] ) ]; } ).to_array(), "dfs successors 2" );
assert_equals( [ [ 2,[ 3 ] ],[ 7,[ 2, 8 ] ],[ 8,[ 9 ] ] ], iter_sorted( g2.dfs_successors( 7, 2 ), function( e ) { return e[ 0 ]; } ).map( function( e ) { return [ e[ 0 ], array_key_sort( e[ 1 ] ) ]; } ).to_array(), "dfs successors 3" );
assert_equals( [ [ 1 ,0 ], [ 2 ,1 ], [ 3, 2 ], [ 7, 2 ] ], iter_sorted( g1.dfs_predecessors( 0, 3 ), function( e ) { return e[ 0 ]; } ).to_array(), "dfs predessors 2" );
assert_equals( [ [ 2, 7 ], [ 3, 2 ], [ 8, 7 ], [ 9, 8 ] ], iter_sorted( g2.dfs_predecessors( 7, 2 ), function( e ) { return e[ 0 ]; } ).to_array(), "dfs predessors 3" );

var e1 = [ [ 0, 1, 7 ], [ 0, 3, 5 ], [ 1, 2, 8 ], [ 1, 3, 9 ], [ 1, 4, 7 ], [ 2, 4, 5 ], [ 3, 4, 15 ], [ 3, 5, 6 ], [ 4, 5, 8 ], [ 4, 6, 9 ], [ 5, 6, 11 ] ];

var g = graph_empty();
g.add_edges_from( e1 );

assert_equals( [ [ 0, 1 ], [ 0, 3 ], [ 1, 4 ], [ 2, 4 ], [ 3, 5 ], [ 4, 6 ] ], g.kruskal_mst_edges( ).map( function( e ) { return array_key_sort( e ); } ).sorted( string ).to_array(), "kruskal 1" );
assert_equals( [ [ 0, 1 ], [ 1, 2 ], [ 1, 3 ], [ 3, 4 ], [ 4, 6 ], [ 5, 6 ] ], g.kruskal_mst_edges( true ).map( function( e ) { return array_key_sort( e ); } ).sorted( string ).to_array(), "kruskal 2" );

#endregion

#region Graph constructors

/*
	complete
*/

var g = graph_complete( 9 );
assert_equals( 9, g.number_of_nodes(), "graph complete 1" );
assert_equals( 36, g.size(), "graph complete 2" );

g = graph_complete( irange( 11, 14 ) );
assert_equals( 3, g.number_of_nodes(), "graph complete 3" );
assert_equals( [ 11, 12, 13 ], g.nodes().sorted().to_array(), "graph complete 4" );

/*
	cycle
*/

g = graph_cycle( 4, true );
assert_array_equals( [ [ 0, 1 ], [ 1, 2 ], [ 2, 3 ], [ 3, 0 ] ], g.edges().sorted( string ).to_array(), "graph cycle 1" );

/*
	empty
*/

g = graph_empty( );

assert_equals( 0, g.number_of_nodes(), "graph empty 1" );

g = graph_empty( 10 );

assert_equals( arange( 10 ), g.nodes().sorted().to_array(), "graph empty 2" );
assert_equals( 0, g.number_of_edges(), "graph empty 3" );

g = graph_empty( "abc" );
assert_equals( 3, g.number_of_nodes(), "graph empty 4" );
assert_equals( "abc", g.nodes().sorted().to_string(), "graph empty 5" );

/*
	path
*/

g = graph_path( 4, true );
assert_array_equals( [ [ 0, 1 ], [ 1, 2 ], [ 2, 3 ] ], g.edges().sorted( string ).to_array(), "graph path 1" );

/*
	star
*/

g = graph_star( 3, true );
assert_array_equals( [ [ 0, 1 ], [ 0, 2 ], [ 0, 3 ] ], g.edges().sorted( string ).to_array(), "graph star 1" );

#endregion