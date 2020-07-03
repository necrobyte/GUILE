#region iter

assert_equals( 10, iter( _arange( 5 ) ).reduce( function( _a, _x ) { return _a + _x; } ), "iter reduce 1" );
assert_equals( 24, iter( [1,2,3,4] ).reduce( function( _a, _x ) { return _a * _x; } ), "iter reduce 2" );
assert_equals( 1, iter( [1,2,3,4] ).reduce( min ), "iter reduce 3" );
assert_equals( undefined, iter( [] ).reduce( min ), "iter reduce 4" );

assert_equals( "1234", iter( [1,2,3,4] ).to_string(),								"iter array" );
assert_equals( [ 4, 3, 2, 1 ], iter( [ 1, 2, 3, 4 ] ).reverse().to_array(),			"reverse 1" );
assert_equals( "A, B, C, D", to_string( iter( "ABCD" ), ", " ),						"iter string" );
assert_equals( "DCBA", to_string( iter( "ABCD" ).reverse() ),						"reverse 2" );

assert_array_equals( [ 1,1,1,1,1,1,1,1,1,1 ], _repeat( 1, 10 ).to_array(),			"to_array" );
assert_equals( "1111111111", to_string( _repeat( 1, 10 ) ),							"to_string" );
assert_equals( "1, 1, 1, 1, 1, 1, 1, 1, 1, 1", to_string( _repeat( 1, 10 ), ", " ),	"to_string 2" );

var _ds = _list( 1, 2, 3, 4 );
assert_equals( [ 1, 2, 3, 4 ], ds_list_iter( _ds ).to_array(),					"ds_list_iter 1" );
assert_equals( [ 4, 3, 2, 1 ], ds_list_iter( _ds ).reverse().to_array(),			"ds_list_iter 2" );
ds_list_destroy( _ds );

_ds = _stack( 1, 2, 3, 4 );
assert_equals( [ 4, 3, 2, 1 ], ds_stack_iter( _ds ).to_array(),				"ds_stack_iter" );
ds_stack_destroy( _ds );

_ds = _queue( 1, 2, 3, 4 );
assert_equals( [ 1, 2, 3, 4 ], ds_queue_iter( _ds ).to_array(),				"ds_queue_iter" );
ds_queue_destroy( _ds );

assert_array_equals( [ [ "a", 10 ],[ "b", "Hello" ] ], iter( { a: 10, b: "Hello" } ).sorted( function( _x ) { return _x[ 0 ]; } ).to_array(), "iter struct" );
assert_equals( [ "a", "b" ], _sorted( iter( { a: 10, b: "Hello" } ).names() ).to_array(), "iter struct names" );
assert_equals( [ 10, "Hello" ], _sorted( iter( { a: 10, b: "Hello" } ).values(), string ).to_array(), "iter struct values" );

_ds = _map( [ "A", 1 ],[ "B", 2 ],[ "C", 3 ],[ "D", 4 ] );
assert_array_equals( [ [ "A", 1 ],[ "B", 2 ],[ "C", 3 ],[ "D", 4 ] ], ds_map_iter( _ds ).sorted( function( _x ) { return _x[ 0 ]; } ).to_array(), "ds_map_iter" );
assert_equals( [ "A", "B", "C", "D" ], _sorted( ds_map_iter( _ds ).names() ).to_array(), "ds_map_iter names" );
assert_equals( [ 1,2,3,4 ], _sorted( ds_map_iter( _ds ).values() ).to_array(), "ds_map_iter values" );
assert_array_equals( [ [ "A",1 ],[ "B",2 ],[ "C",3 ],[ "D",4 ] ], _sorted( ds_map_iter( _ds ).to_struct(), function( _x ) { return _x[ 0 ]; } ).to_array(), "IteratorDict to_struct" );

ds_map_clear( _ds );

assert_array_equals( [ [ "a", 10 ],[ "b", "Hello" ] ], _sorted( ds_map_iter( iter( { a: 10, b: "Hello" } ).to_map( _ds ) ), function( _x ) { return _x[ 0 ]; } ).to_array(), "IteratorDict to_map" );
ds_map_destroy( _ds );

_ds = _priority( [ 1, 1 ], [ 2, 2] , [ 3, 3 ], [ 4, 4 ] );
assert_equals( [ 1, 2, 3, 4 ], ds_priority_min_iter( _ds ).to_array(),		"ds_prioriry_min_iter" );
ds_priority_destroy( _ds );

_ds = _priority( [ 1, 1 ], [ 2, 2] , [ 3, 3 ], [ 4, 4 ] );
assert_equals( [ 4, 3, 2, 1 ], ds_priority_max_iter( _ds ).to_array(),		"ds_priority_max_iter" );
ds_priority_destroy( _ds );


/*
	tee
*/

var _t = _tee( [ ] );

assert_equals( [ ], _t[ 0 ].to_array(), "tee 1.1" );
assert_equals( [ ], _t[ 1 ].to_array(), "tee 1.2" );

_t = _tee( _range( 10 ) );

assert_array_equals( _zip( _range( 10 ), _range( 10 ) ).to_array(), _zip( _t[0], _t[1] ).to_array(), "tee 2" );

_t = _tee( _range( 10 ) );

assert_array_equals( _chain( _range( 10 ), _range( 10 ) ).to_array(), _chain( _t[0], _t[1] ).to_array(), "tee 3" );

_t = _tee( _range( 10 ) );

assert_array_equals( _zip( _range( 10 ), _range( 1, 10 ) ).to_array(), _zip( _t[0], _drop( 1, _t[1] ) ).to_array(), "tee 4" );

#endregion

#region range

assert_equals( [ 0, 1, 2 ], _irange( 3 ).to_array(), "irange 1" );
assert_equals( [ 1, 2, 3, 4 ], _irange( 1, 5 ).to_array(), "irange 2" );
assert_equals( [ ], _irange( 0 ).to_array(), "irange 3" );
assert_equals( [ ], _irange( -3 ).to_array(), "irange 4" );
assert_equals( [ 1, 4, 7 ], _irange( 1, 10, 3 ).to_array(), "irange 5" );
assert_equals( [ 5, 2, -1, -4 ], _irange( 5, -5, -3 ).to_array(), "irange 6" );

assert_equals( [ 9,8,7,6,5,4,3,2,1,0 ], _irange( 10 ).reversed().to_array(), "irange 7" );
assert_equals( [ ], _irange( 0 ).reversed().to_array(), "irange 8" );
assert_equals( [ 7,4,1 ], _irange( 1, 9, 3 ).reversed().to_array(), "irange 9" );
assert_equals( [ 2,5,8 ], _irange( 8, 0, -3 ).reversed().to_array(), "irange 10" );

#endregion

#region iterators

/*
	accumulate
*/

assert_equals( [ 0, 1, 3, 6, 10, 15, 21, 28, 36, 45 ], _accumulate( _irange( 10 ) ).to_array(), "accumulate 1" );
assert_equals( [ "a", "ab", "abc" ], _accumulate( "abc" ).to_array(), "accumulate 2" );
assert_equals( [ ], _accumulate( [ ] ).to_array(), "accumulate 3" );
assert_equals( [ 7 ], _accumulate( [ 7 ] ).to_array(), "accumulate 4" );

var _s = [ 2, 8, 9, 5, 7, 0, 3, 4, 1, 6 ];

assert_equals( [ 2, 2, 2, 2, 2, 0, 0, 0, 0, 0 ], _accumulate( _s, _min ).to_array(), "accumulate 5" );
assert_equals( [ 2, 8, 9, 9, 9, 9, 9, 9, 9, 9 ], _accumulate( _s, _max ).to_array(), "accumulate 6" );
assert_equals( [ 2, 16, 144, 720, 5040, 0, 0, 0, 0, 0 ], _accumulate( _s, function( _a, _b ) { return _a * _b } ).to_array(), "accumulate 7" );
assert_equals( [ 10, 15, 16 ], _accumulate( [ 10, 5, 1 ] ).to_array(), "accumulate 8" );
assert_equals( [ 110, 115, 116 ], _accumulate( [ 10, 5, 1 ], 100 ).to_array(), "accumulate 9" );

assert_equals( [ 100 ], _accumulate( [ ], 100 ).to_array(), "accumulate 10" );
assert_equals( [ ], _accumulate( [ ], function( _a, _b ) { return _a + _b } ).to_array(), "accumulate 11" );
assert_equals( [ 100 ], _accumulate( [ ], function( _a, _b ) { return _a + _b }, 100 ).to_array(), "accumulate 12" );

/*
	chain
*/

assert_equals( "abcdef", _chain( "abc", "def" ).to_string(), "chain 1" );
assert_equals( "abc", _chain( "abc" ).to_string(), "chain 2" );
assert_equals( [], _chain( "" ).to_array(), "chain 3" );
assert_equals( "abcd", _take( 4, _chain( "abc", "def" ) ).to_string(), "chain 4" );

/*
	chain_from_iterable
*/

assert_equals( "abcdef", _chain_from_iterable( [ "abc", "def" ] ).to_string(), "chain 1" );
assert_equals( "abc", _chain_from_iterable( [ "abc" ] ).to_string(), "chain 2" );
assert_equals( [], _chain_from_iterable( "" ).to_array(), "chain 3" );
assert_equals( "abcd", _take( 4, _chain_from_iterable( [ "abc", "def" ] ) ).to_string(), "chain 4" );

/*
	imap
*/

assert_array_equals( _imap( function( _a, _b ) { return _a * _b; }, _count(), [ 1, 2, 3 ] ).to_array(),
	_imap_from_iterable( function( _a, _b ) { return _a * _b; }, _zip( _count(), [ 1, 2, 3 ] ) ).to_array(), "imap 1" );
assert_equals( [ 4, 9, 100 ], iter( [ 2, 3, 10 ] ).map( function( x ) { return x * x; } ).to_array(), "imap 2" );
	
/*
	compress
*/

assert_equals( "ACEF", _compress( "ABCDEF", [ 1, 0, 1, 0, 1, 1 ] ).to_string(), "compress 1" );
assert_equals( "", _compress( "ABCDEF", [ 0, 0, 0, 0, 0, 0 ] ).to_string(), "compress 2" );
assert_equals( "ABCDEF", _compress( "ABCDEF", [ 1, 1, 1, 1, 1, 1 ] ).to_string(), "compress 3" );
assert_equals( "AC", _compress( "ABCDEF", [ 1, 0, 1 ] ).to_string(), "compress 4" );
assert_equals( "BC", _compress( "ABC", [ 0, 1, 1, 1, 1, 1 ] ).to_string(), "compress 5" );
assert_equals( [ 1,3,5,1,3,5,1,3,5 ], _compress( _chain_from_iterable( _repeat( _range( 6 ), 3 ) ), _cycle( [ 0, 1 ] ) ).to_array(), "compress 6" );

/*
	count
*/

assert_array_equals( [ [ "a", 0 ], [ "b", 1 ], [ "c", 2 ] ], _zip( "abc", _count() ).to_array(), "count 1" );
assert_array_equals( [ [ "a", 3 ], [ "b", 4 ], [ "c", 5 ] ], _zip( "abc", _count( 3 ) ).to_array(), "count 2" );
assert_array_equals( [ [ "a", 3 ], [ "b", 4 ] ], _take( 2, _zip( "abc", _count( 3 ) ) ).to_array(), "count 3" );
assert_array_equals( [ [ "a", -1 ], [ "b", 0 ] ], _take( 2, _zip( "abc", _count( -1 ) ) ).to_array(), "count 4" );
assert_array_equals( [ [ "a", -3 ], [ "b", -2 ] ], _take( 2, _zip( "abc", _count( -3 ) ) ).to_array(), "count 5" );
assert_equals( [ 3.25, 4.25, 5.25 ], _take( 3, _count( 3.25 ) ).to_array(), "count 6" );
assert_array_equals( [ [ "a", 2 ], [ "b", 5 ], [ "c", 8 ] ], _zip( "abc", _count( 2, 3 ) ).to_array(), "count 7" );
assert_array_equals( [ [ "a", 0 ], [ "b", -1 ], [ "c", -2 ] ], _zip( "abc", _count( 0, -1 ) ).to_array(), "count 8" );
assert_array_equals( [ [ "a", 2 ], [ "b", 2 ], [ "c", 2 ] ], _zip( "abc", _count( 2, 0 ) ).to_array(), "count 9" );
assert_array_equals( [ [ "a", 2 ], [ "b", 3 ], [ "c", 4 ] ], _zip( "abc", _count( 2, 1 ) ).to_array(), "count 10" );

/*
	cycle
*/

assert_equals( "abcabcabca", _take( 10, _cycle( "abc" ) ).to_string(), "cycle 1" );
assert_equals( [ ], _cycle( "" ).to_array(), "cycle 2" );

/*
	group_by
*/

assert_equals( [ ], _group_by( [ ] ).to_array(), "group_by 1" );
assert_equals( [ 0, 1, 2, 3 ], _imap( function( _a ) { return _a.key; }, _group_by( [ [ 0, 10, 20 ], [ 0, 11, 21 ], [ 0, 12, 21 ], [ 1, 13, 21 ], [ 1, 14, 22 ],
             [ 2, 15, 22 ], [ 3, 16, 23 ], [ 3, 17, 23 ] ], function( _a ){ return _a[ 0 ]; } ) ).to_array(), "group_by 2" );
assert_equals(["A","B","C","D","A","B"], _imap( function( _a ) { return _a.key }, _group_by( "AAAABBBCCDAABBB" ) ).to_array(),		"groupby 3" );
assert_array_equals([["A","A","A","A"],["B","B","B"],["C","C"],["D"],["A","A"],["B","B"]], _imap( function( _a ) { return _a.group }, _group_by( "AAAABBBCCDAABBB" ) ).to_array(), "groupby 4" );

/*
	filter
*/

assert_equals( [ 0, 2, 4 ], _filter( _irange( 6 ), function( _a ) { return ( _a % 2 == 0 ); } ).to_array(), "filter 1" );
assert_equals( [ 1, 2 ], _filter( [ 0, 1, 0, 2, 0 ] ).to_array(), "filter 2" );
assert_equals( [ 0, 2, 4, 6 ], _take( 4, _filter( _count(), function( _a ) { return ( _a % 2 == 0 ); } ) ).to_array(), "filter 3" );
assert_equals( [ 0, 2, 4 ], _irange( 6 ).filter( function( _a ) { return ( _a % 2 == 0 ); } ).to_array(), "filter 1" );

/*
	filter_false
*/

assert_equals( [ 1, 3, 5 ], _filter_false( _irange( 6 ), function( _a ) { return ( _a % 2 == 0 ); } ).to_array(), "filter 1" );
assert_equals( [ 0, 0, 0 ], _filter_false( [ 0, 1, 0, 2, 0 ] ).to_array(), "filter 2" );
assert_equals( [ 1, 3, 5, 7 ], _take( 4, _filter_false( _count(), function( _a ) { return ( _a % 2 == 0 ); } ) ).to_array(), "filter 3" );

/*
	enumerate
*/

assert_array_equals( [ [ 0, "a" ], [ 1, "b" ], [ 2, "c" ] ], _enumerate( "abc" ).to_array(), "enumerate 1" );
assert_array_equals( [ [ 11, "a" ], [ 12, "b" ], [ 13, "c" ] ], _enumerate( "abc", 11 ).to_array(), "enumerate 2" );
assert_equals( [ ], _enumerate( [ ] ).to_array(), "enumerate 3" );

/*
	ndenumerate
*/

assert_array_equals( [ [ [ 0,0 ],1 ],[ [ 0,1 ],2 ],[ [ 1,0 ],3 ],[ [ 1,1 ],4 ] ], _ndenumerate( [[ 1, 2 ], [ 3, 4 ]] ).to_array(), "ndenumerate 1" );
assert_array_equals( [ [ [ 0 ],1 ],[ [ 1 ],2 ],[ [ 2 ],3 ],[ [ 3 ],4 ] ], _ndenumerate( [ 1, 2, 3, 4 ] ).to_array(), "ndenumerate 2" );
assert_equals( [ ], _ndenumerate( [ ] ).to_array(), "ndenumerate 3" );
assert_array_equals( [ [ [ 0,0,0 ],1 ],[ [ 0,0,1 ],2 ],[ [ 0,1,0 ],3 ],[ [ 0,1,1 ],4 ],[ [ 1,0,0 ],5 ],[ [ 1,0,1 ],6 ],[ [ 1,1,0 ],7 ],[ [ 1,1,1 ],8 ] ], _ndenumerate( [ [[ 1, 2 ], [ 3, 4 ]], [[ 5, 6 ], [ 7, 8 ]] ] ).to_array(), "ndenumerate 4" );
assert_array_equals( [ [ [ 0 ], [ 1, 2 ] ],[ [ 1 ], [ 3, 4, 5 ] ] ], _ndenumerate( [[ 1, 2 ], [ 3, 4, 5 ]] ).to_array(), "ndenumerate 5" );

/*
	dropwhile
*/

var _s = [ 1, 3, 5, 20, 2, 4, 6, 8 ];

assert_equals( [ 20, 2, 4, 6, 8 ], _dropwhile( _s, function( _x ) { return ( _x < 10 ); } ).to_array(), "dropwhile 1" );
assert_equals( [  ], _dropwhile( [ ], function( _x ) { return ( _x < 10 ); } ).to_array(), "dropwhile 2" );

/*
	takewhile
*/

var _s = [ 1, 3, 5, 20, 2, 4, 6, 8 ];

assert_equals( [ 1, 3, 5 ], _takewhile( _s, function( _x ) { return ( _x < 10 ); } ).to_array(), "takewhile 1" );
assert_equals( [  ], _takewhile( [ ], function( _x ) { return ( _x < 10 ); } ).to_array(), "takewhile 2" );

/*
	reduce
*/

assert_equals( "abcdef", _reduce( [ "abc", "de", "f" ], _add ), "reduce 1" );
assert_equals( 5040, _reduce( _range( 2, 8 ), _mul ), "reduce 2" );
assert_equals( 2432902008176640000, _reduce( _range( 2, 21 ), _mul ), "reduce 3" );
assert_equals( 285, _reduce( _imap( sqr, _range( 10 ) ) , _add ), "reduce 4" );
assert_equals( 285, _reduce( _imap( sqr, _range( 10 ) ) , _add, 0 ), "reduce 5" );
assert_equals( 0, _reduce( _imap( sqr, _range( 0 ) ) , _add, 0 ), "reduce 6" );

/*
	zip
*/

assert_array_equals( [ [ "a", 0 ], [ "b", 1 ], [ "c", 2 ] ], _zip( "abc", _count() ).to_array(), "zip 1" );
assert_array_equals( [ [ "a", 0 ], [ "b", 1 ], [ "c", 2 ] ], _zip( "abc", _range(6) ).to_array(), "zip 2" );
assert_array_equals( [ [ "a", 0 ], [ "b", 1 ], [ "c", 2 ] ], _zip( "abcdef", _range(3) ).to_array(), "zip 3" );
assert_equals( [ ], _zip( ).to_array(), "zip 4" );
assert_equals( [ ], _zip( [ ] ).to_array(), "zip 5" );
assert_array_equals( [ [ "c" ], [ "d" ], [ "e" ], [ "f" ] ], _drop( 2, _zip( "abcdef" ) ).to_array(), "zip 6" );

/*
	zip_longest
*/

assert_array_equals( [ [ "a", 0 ], [ "b", 1 ], [ "c", 2 ], [ "-", 3 ], [ "-", 4 ], [ "-", 5 ] ], 
	_zip_longest( "abc", _range(6), "-" ).to_array(), "zip_longest 1" );
assert_array_equals( [ [ 0, "a" ], [ 1, "b" ], [ 2, "c" ], [ 3, "-" ], [ 4, "-" ], [ 5, "-" ] ], 
	_zip_longest( _range(6), "abc", "-" ).to_array(), "zip_longest 2" );
assert_array_equals( _zip( "abcdef" ).to_array(), _zip_longest( "abcdef" ).to_array(), "zip_longest 3" );
assert_array_equals( _zip( "abc", "def" ).to_array(), _zip_longest( "abc", "def", "" ).to_array(), "zip_longest 4" );
assert_equals( [ ], _zip_longest( ).to_array(), "zip_longest 5" );
assert_equals( [ ], _zip_longest( [ ] ).to_array(), "zip_longest 6" );

#endregion

#region misc

assert_equals( [ 1, 2, 3, 4, 5 ], iter( [ 5, 2, 3, 1, 4 ] ).sorted().to_array(), "sorted 1" );
assert_equals( "abcde", _sorted( "ebcad" ).to_string(), "sorted 2" );
assert_equals( [ 1, 2, 3, 4, 5 ], iter( [ 1, 2, 3, 4, 5 ] ).slice( 0, undefined ).to_array(), "slice 1" );
assert_equals( [ 1, 2, 3 ], _unique( [ 1, 2, 3, 2, 3, 1, 2, 3, 2, 1, 3 ] ), "unique 1" );

#endregion